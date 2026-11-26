import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/project.dart';
import '../models/project_application.dart';

/// Proje listeleme, oluşturma, düzenleme, silme ve başvuru işlemleri.
///
/// Yetki kontrolleri burada yalnızca kullanıcıya erken ve anlaşılır hata
/// vermek içindir; asıl koruma `firestore.rules` içindedir.
class ProjectService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Test edilebilirlik için bağımlılık enjeksiyonu sağlandı
  ProjectService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _projects =>
      _firestore.collection('projects');

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection('applications');

  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  // Misafir (anonim) kullanıcılar proje açamaz ve başvuru yapamaz
  bool get canContribute {
    final user = _auth.currentUser;
    return user != null && !user.isAnonymous;
  }

  // ---------------------------------------------------------------------------
  // Projeler
  // ---------------------------------------------------------------------------

  // Tüm projeler anlık dinlendi (durum filtrelemesi istemcide yapılır)
  Stream<List<Project>> streamAllProjects() {
    return _projects.snapshots().map((snap) => _sortProjects(
        snap.docs.map((d) => Project.fromMap(d.data(), d.id)).toList()));
  }

  // Açık projeler anlık dinlendi; birleşik indeks gerekmesin diye sıralama istemcide yapıldı
  Stream<List<Project>> streamOpenProjects() {
    return _projects
        .where('status', isEqualTo: Project.statusOpen)
        .snapshots()
        .map((snap) => _sortProjects(
            snap.docs.map((d) => Project.fromMap(d.data(), d.id)).toList()));
  }

  // Giriş yapan kullanıcının sahibi olduğu projeler dinlendi
  Stream<List<Project>> streamMyProjects() {
    final uid = _requireUid();
    return _projects.where('ownerId', isEqualTo: uid).snapshots().map((snap) =>
        _sortProjects(
            snap.docs.map((d) => Project.fromMap(d.data(), d.id)).toList()));
  }

  // Tek bir proje anlık dinlendi; silinmişse null döner
  Stream<Project?> streamProject(String projectId) {
    return _projects.doc(projectId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Project.fromMap(doc.data()!, doc.id);
    });
  }

  // Proje sahibi formdan değil, oturumdaki kullanıcıdan belirlendi
  Future<String> createProject({
    required String title,
    required String description,
    required List<String> technologies,
    required List<String> neededRoles,
    String? category,
    int? capacity,
    String status = Project.statusOpen,
  }) async {
    final user = _requireContributor();
    if (capacity != null && capacity < 1) {
      throw 'Kontenjan en az 1 olmalıdır.';
    }
    final project = Project(
      id: '',
      title: title.trim(),
      description: description.trim(),
      ownerId: user.uid,
      ownerName: _displayName(user),
      category: category?.trim().isEmpty == true ? null : category?.trim(),
      capacity: capacity,
      technologies: technologies,
      neededRoles: neededRoles,
      status: status,
      memberIds: [user.uid],
    );
    try {
      final doc = await _projects.add({
        ...project.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  // Yalnızca düzenlenebilir alanlar güncellendi; ownerId ve üyeler değiştirilmez
  Future<void> updateProject(Project project) async {
    final user = _requireContributor();
    if (!project.isOwner(user.uid)) {
      throw 'Yalnızca proje sahibi bu projeyi düzenleyebilir.';
    }
    if (project.capacity != null &&
        project.capacity! < project.memberIds.length) {
      throw 'Kontenjan mevcut üye sayısından (${project.memberIds.length}) az olamaz.';
    }
    try {
      final updates = <String, dynamic>{
        'title': project.title.trim(),
        'description': project.description.trim(),
        'technologies': project.technologies,
        'neededRoles': project.neededRoles,
        'status': project.status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (project.category != null && project.category!.trim().isNotEmpty)
          'category': project.category!.trim()
        else
          'category': FieldValue.delete(),
        if (project.capacity != null && project.capacity! > 0)
          'capacity': project.capacity
        else
          'capacity': FieldValue.delete(),
      };
      await _projects.doc(project.id).update(updates);
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  /// Proje sahibi kendi projesini ve ilişkili başvuruları siler.
  Future<void> deleteProject(Project project) async {
    final user = _requireContributor();
    if (!project.isOwner(user.uid)) {
      throw 'Yalnızca proje sahibi bu projeyi silebilir.';
    }
    try {
      final appsSnap = await _applications
          .where('projectId', isEqualTo: project.id)
          .where('ownerId', isEqualTo: user.uid)
          .get();

      final batch = _firestore.batch();
      for (final doc in appsSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_projects.doc(project.id));
      await batch.commit();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Başvurular
  // ---------------------------------------------------------------------------

  // Kullanıcının belirli bir projeye yaptığı başvuru dinlendi (yoksa null)
  Stream<ProjectApplication?> streamMyApplicationFor(String projectId) {
    final uid = _requireUid();
    return _applications
        .doc(ProjectApplication.docId(projectId, uid))
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return ProjectApplication.fromMap(doc.data()!, doc.id);
    });
  }

  // Başvuru sabit belge ID'si ile işlem (transaction) içinde oluşturuldu; mükerrer başvuru ve kontenjan aşımı engellendi
  Future<void> applyToProject(Project project, String message) async {
    final user = _requireContributor();
    if (project.isOwner(user.uid)) {
      throw 'Kendi projene başvuramazsın.';
    }
    if (project.isMember(user.uid)) {
      throw 'Zaten bu projenin üyesisin.';
    }
    if (!project.isOpen) {
      throw 'Bu proje şu anda başvurulara kapalı.';
    }
    if (project.isFull) {
      throw 'Bu projenin kontenjanı dolmuştur.';
    }
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      throw 'Lütfen bir başvuru mesajı yaz.';
    }

    final projectRef = _projects.doc(project.id);
    final ref =
        _applications.doc(ProjectApplication.docId(project.id, user.uid));
    final application = ProjectApplication(
      id: ref.id,
      projectId: project.id,
      applicantId: user.uid,
      ownerId: project.ownerId,
      projectTitle: project.title,
      applicantName: _displayName(user),
      message: trimmed,
    );

    try {
      await _firestore.runTransaction((tx) async {
        final liveProjectSnap = await tx.get(projectRef);
        if (!liveProjectSnap.exists || liveProjectSnap.data() == null) {
          throw 'Proje bulunamadı. Silinmiş olabilir.';
        }
        final liveProject =
            Project.fromMap(liveProjectSnap.data()!, liveProjectSnap.id);
        if (!liveProject.isOpen) {
          throw 'Bu proje şu anda başvurulara kapalı.';
        }
        if (liveProject.isFull) {
          throw 'Bu projenin kontenjanı dolmuştur.';
        }

        final existing = await tx.get(ref);
        if (existing.exists) {
          throw 'Bu projeye zaten başvurdun.';
        }
        tx.set(ref, {
          ...application.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  // Kullanıcının gönderdiği başvurular dinlendi
  Stream<List<ProjectApplication>> streamMyApplications() {
    final uid = _requireUid();
    return _applications
        .where('applicantId', isEqualTo: uid)
        .snapshots()
        .map(_toSortedApplications);
  }

  // Kullanıcının projelerine gelen başvurular dinlendi; istenirse tek projeye süzüldü
  Stream<List<ProjectApplication>> streamIncomingApplications(
      {String? projectId}) {
    final uid = _requireUid();
    return _applications
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map(_toSortedApplications)
        .map((list) => projectId == null
            ? list
            : list.where((a) => a.projectId == projectId).toList());
  }

  // Karar tek bir batch ile yazıldı: kabulde başvuran proje üyelerine eklendi
  Future<void> decideApplication(
    ProjectApplication application, {
    required bool accept,
  }) async {
    final uid = _requireContributor().uid;
    if (application.ownerId != uid) {
      throw 'Yalnızca proje sahibi başvuruya karar verebilir.';
    }
    if (!application.isPending) {
      throw 'Bu başvuru için zaten karar verilmiş.';
    }

    final batch = _firestore.batch();
    batch.update(_applications.doc(application.id), {
      'status': accept
          ? ProjectApplication.statusAccepted
          : ProjectApplication.statusRejected,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (accept) {
      batch.update(_projects.doc(application.projectId), {
        'memberIds': FieldValue.arrayUnion([application.applicantId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Yardımcılar
  // ---------------------------------------------------------------------------

  String _requireUid() {
    final uid = currentUserId;
    if (uid == null) throw 'Bu işlem için giriş yapmalısın.';
    return uid;
  }

  User _requireContributor() {
    final user = _auth.currentUser;
    if (user == null) throw 'Bu işlem için giriş yapmalısın.';
    if (user.isAnonymous) {
      throw 'Misafir hesabıyla bu işlem yapılamaz. Lütfen hesabınla giriş yap.';
    }
    return user;
  }

  String _displayName(User user) {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Kullanıcı';
  }

  // En yeni kayıt en üstte; henüz sunucu zamanı yazılmamış kayıtlar da en üstte
  List<Project> _sortProjects(List<Project> list) {
    list.sort((a, b) => _compareNewest(a.createdAt, b.createdAt));
    return list;
  }

  List<ProjectApplication> _toSortedApplications(
      QuerySnapshot<Map<String, dynamic>> snap) {
    final list = snap.docs
        .map((d) => ProjectApplication.fromMap(d.data(), d.id))
        .toList()
      ..sort((a, b) => _compareNewest(a.createdAt, b.createdAt));
    return list;
  }

  int _compareNewest(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return b.compareTo(a);
  }

  // Firestore hata kodları kullanıcı dostu Türkçe mesajlara dönüştürüldü
  String _handleFirestoreException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Bu işlem için yetkin yok.';
      case 'not-found':
        return 'Kayıt bulunamadı. Silinmiş olabilir.';
      case 'unavailable':
        return 'Sunucuya ulaşılamadı. İnternet bağlantını kontrol et.';
      default:
        return 'Beklenmedik bir hata oluştu: ${e.message ?? e.code}';
    }
  }
}
