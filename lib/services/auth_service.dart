import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/app_user.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirestoreService _profiles;

  AuthService({FirebaseAuth? auth, FirestoreService? profiles})
      : _auth = auth ?? FirebaseAuth.instance,
        _profiles = profiles ?? FirestoreService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw 'Kullanıcı kaydı tamamlanamadı.';
      final normalizedName = name.trim();
      await user.updateDisplayName(normalizedName);
      await user.reload();
      final active = _auth.currentUser ?? user;
      await _profiles.saveUserProfile(AppUser(
        id: active.uid,
        name: normalizedName,
        email: active.email,
      ));
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _authMessage(e);
    } on FirebaseException catch (e) {
      throw _firestoreMessage(e);
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _ensureProfile(credential.user);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _authMessage(e);
    } on FirebaseException catch (e) {
      throw _firestoreMessage(e);
    }
  }

  Future<void> _ensureProfile(User? user) async {
    if (user == null) return;
    final existing = await _profiles.getUserProfile(user.uid);
    if (existing != null) return;
    final displayName = user.displayName?.trim();
    await _profiles.saveUserProfile(AppUser(
      id: user.uid,
      name: displayName != null && displayName.isNotEmpty ? displayName : 'Kullanıcı',
      email: user.email,
    ));
  }

  /// Auth displayName ile Firestore profil adı birlikte güncellenir.
  Future<void> updateProfile(AppUser profile) async {
    final user = _auth.currentUser;
    if (user == null) throw 'Bu işlem için giriş yapmalısın.';
    if (profile.id != user.uid) throw 'Yalnızca kendi profilini güncelleyebilirsin.';
    final name = profile.name.trim();
    if (name.isEmpty || name.length > 100) throw 'Ad alanı 1-100 karakter olmalıdır.';
    try {
      await user.updateDisplayName(name);
      await user.reload();
      final active = _auth.currentUser ?? user;
      await _profiles.saveUserProfile(AppUser(
        id: active.uid,
        name: name,
        email: active.email,
        bio: profile.bio,
        department: profile.department,
        skills: profile.skills,
        githubUrl: profile.githubUrl,
      ));
    } on FirebaseAuthException catch (e) {
      throw _authMessage(e);
    } on FirebaseException catch (e) {
      throw _firestoreMessage(e);
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _authMessage(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _authMessage(e);
    }
  }

  String _authMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
      case 'invalid-credential': return 'E-posta veya şifre hatalı.';
      case 'email-already-in-use': return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'invalid-email': return 'Geçersiz e-posta adresi.';
      case 'weak-password': return 'Şifre en az 6 karakter olmalıdır.';
      case 'user-disabled': return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
      case 'too-many-requests': return 'Çok fazla deneme yapıldı. Biraz sonra tekrar dene.';
      case 'network-request-failed': return 'İnternet bağlantını kontrol et.';
      default: return e.message ?? 'Kimlik doğrulama hatası (${e.code}).';
    }
  }

  String _firestoreMessage(FirebaseException e) {
    if (e.code == 'permission-denied') return 'Firestore erişimi reddedildi. Firebase Rules ayarını kontrol et.';
    if (e.code == 'unavailable') return 'Sunucuya ulaşılamadı. İnternet bağlantını kontrol et.';
    return e.message ?? 'Profil kaydedilirken hata oluştu (${e.code}).';
  }
}
