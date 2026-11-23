import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  // Test edilebilirlik için bağımlılık enjeksiyonu sağlandı
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // users/{uid} doküman referansı oluşturuldu
  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  // Kullanıcı profili Firestore'dan anlık olarak dinlendi
  Stream<AppUser?> streamUserProfile(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.data()!, doc.id);
    });
  }

  // Kullanıcı profili Firestore'dan tek seferlik çekildi
  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap(doc.data()!, doc.id);
  }

  /// Yeni kayıt olan kullanıcı için `users/{uid}` belgesi yoksa oluşturur.
  /// Belge zaten varsa mevcut profil bilgilerini ezmeden çıkar.
  Future<void> createUserProfileIfMissing(AppUser user) async {
    final docRef = _userDoc(user.id);
    final snapshot = await docRef.get();
    if (snapshot.exists) return;

    final data = user.toMap()
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['updatedAt'] = FieldValue.serverTimestamp();

    await docRef.set(data, SetOptions(merge: true));
  }

  /// Kullanıcı profil verisini merge seçeneğiyle mevcut alanları koruyarak kaydeder.
  Future<void> saveUserProfile(AppUser user) async {
    final docRef = _userDoc(user.id);
    final data = user.toMap()..['updatedAt'] = FieldValue.serverTimestamp();

    if (user.createdAt == null) {
      final snapshot = await docRef.get();
      if (!snapshot.exists || snapshot.data()?['createdAt'] == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }
    }

    await docRef.set(data, SetOptions(merge: true));
  }
}
