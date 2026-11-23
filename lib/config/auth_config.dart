/// Giriş sağlayıcılarının arayüzde aktif veya pasif olma durumunu yöneten yapılandırma sınıfı.
class AuthConfig {
  // İlk aşamada e-posta/şifre girişi önceliklendirildiği için diğer yöntemler pasif tutuldu.
  // Gerçek sağlayıcı yapılandırmaları tamamlanıp test edildikten sonra aktif edilebilir.
  static const bool enableGoogle = false;
  static const bool enableGithub = false;
  static const bool enableMicrosoft = false;
  static const bool enableLinkedin = false;
  static const bool enableGuest = false;

  // En az bir sosyal giriş aktif mi kontrolü yapıldı
  static bool get hasAnySocialLogin =>
      enableGoogle ||
      enableGithub ||
      enableMicrosoft ||
      enableLinkedin ||
      enableGuest;
}
