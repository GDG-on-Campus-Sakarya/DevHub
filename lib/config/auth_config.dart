/// Giriş sağlayıcılarının arayüzde aktif veya pasif olma durumunu yöneten yapılandırma sınıfı.
class AuthConfig {
  // Sağlayıcıların görünürlük bayrakları tanımlandı (hepsi varsayılan olarak aktif)
  static const bool enableGoogle = true;
  static const bool enableGithub = true;
  static const bool enableMicrosoft = true;
  static const bool enableLinkedin = true;
  static const bool enableGuest = true;

  // En az bir sosyal giriş aktif mi kontrolü yapıldı
  static bool get hasAnySocialLogin =>
      enableGoogle ||
      enableGithub ||
      enableMicrosoft ||
      enableLinkedin ||
      enableGuest;
}
