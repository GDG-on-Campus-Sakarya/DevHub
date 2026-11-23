/// OAuth sağlayıcıları Firebase Console tarafında doğrulanana kadar kapalıdır.
/// İlk aşamada yalnızca e-posta/şifre ile giriş ve kayıt desteklenir.
class AuthConfig {
  AuthConfig._();
  static const bool enableGoogle = false;
  static const bool enableGithub = false;
  static const bool enableMicrosoft = false;
  static const bool enableLinkedin = false;
  static const bool enableGuest = false;
  static bool get hasAnySocialLogin =>
      enableGoogle || enableGithub || enableMicrosoft || enableLinkedin || enableGuest;
}
