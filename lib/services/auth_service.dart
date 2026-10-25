import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  // Test edilebilirlik için bağımlılık enjeksiyonu sağlandı
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // Oturum durumunu anlık dinleyen akış tanımlandı
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Aktif kullanıcı nesnesi alındı
  User? get currentUser => _auth.currentUser;

  // Kullanıcının oturum açıp açmadığı kontrol edildi
  bool get isAuthenticated => _auth.currentUser != null;

  // Yeni kullanıcı kaydı ve profil ismi güncellemesi yapıldı
  Future<UserCredential> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (name != null && name.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(name.trim());
        await credential.user?.reload();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Beklenmedik bir hata oluştu: ${e.toString()}';
    }
  }

  // E-posta ve şifre ile giriş yapıldı
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Giriş yapılırken beklenmedik bir hata oluştu: ${e.toString()}';
    }
  }

  // Google hesabı ile popup üzerinden giriş yapıldı
  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();
      return await _auth.signInWithPopup(googleProvider);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Google ile giriş yapılırken beklenmedik bir hata oluştu: ${e.toString()}';
    }
  }

  // GitHub hesabı ile popup üzerinden giriş yapıldı
  Future<UserCredential> signInWithGithub() async {
    try {
      final githubProvider = GithubAuthProvider();
      return await _auth.signInWithPopup(githubProvider);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'GitHub ile giriş yapılırken beklenmedik bir hata oluştu: ${e.toString()}';
    }
  }

  // Microsoft hesabı ile popup üzerinden giriş yapıldı
  Future<UserCredential> signInWithMicrosoft() async {
    try {
      final microsoftProvider = OAuthProvider('microsoft.com');
      return await _auth.signInWithPopup(microsoftProvider);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Microsoft ile giriş yapılırken beklenmedik bir hata oluştu: ${e.toString()}';
    }
  }

  // LinkedIn hesabı ile OpenID Connect üzerinden giriş yapıldı
  Future<UserCredential> signInWithLinkedin() async {
    try {
      final linkedinProvider = OAuthProvider('oidc.linkedin');
      return await _auth.signInWithPopup(linkedinProvider);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'LinkedIn ile giriş yapılırken beklenmedik bir hata oluştu: ${e.toString()}';
    }
  }

  // Aktif oturum sonlandırıldı
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Çıkış yapılırken bir hata oluştu: ${e.toString()}';
    }
  }

  // Şifre sıfırlama e-postası gönderildi
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Firebase hata kodları kullanıcı dostu Türkçe mesajlara dönüştürüldü
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı bir kullanıcı bulunamadı.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı. Lütfen kontrol ediniz.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten başka bir hesap tarafından kullanılıyor.';
      case 'invalid-email':
        return 'Geçersiz bir e-posta adresi formatı girdiniz.';
      case 'weak-password':
        return 'Şifreniz çok zayıf. Lütfen en az 6 karakterli daha güçlü bir şifre seçin.';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı yönetici tarafından devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla başarısız deneme yapıldı. Lütfen biraz bekleyip tekrar deneyin.';
      case 'network-request-failed':
        return 'İnternet bağlantısı kurulamadı. Bağlantınızı kontrol ediniz.';
      default:
        return e.message ?? 'Bir kimlik doğrulama hatası oluştu (${e.code}).';
    }
  }
}
