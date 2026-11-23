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

  // Kullanıcı profil verisi merge seçeneğiyle diğer alanlar korunarak kaydedildi
  Future<void> saveUserProfile(AppUser user) async {
    await _userDoc(user.id).set(user.toMap(), SetOptions(merge: true));
  }
}
