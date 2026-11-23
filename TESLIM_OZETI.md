# DevHub – İlk Aşama Teslim Özeti

Bu klasör, mevcut Flutter başlangıç projesi, PR #1 (kimlik doğrulama/profil), PR #2 (proje/başvuru akışı) ve `DatabaseProgressReport003.zip` içindeki veri mimarisi katkısının tek bir yerel çalışma ağacında uzlaştırılmış halidir.

## Kaynaklar ve uzlaştırma

- Taban: `main` commit `125b11119cfb783f52c76ad86aa9e1df92b61c9d`.
- PR #1 başlığı: `feat(auth-and-profile) : auth + session + profil + 0auth logins`; kullanılan incelenmiş head: `1c217f007329fb0ac024b5ff91b8bbe3f4a090c7`.
- PR #2 başlığı: `proje kesfi, proje olusturma ve basvuru akisi yapildi`; kullanılan head: `cf03b0c548aac6d62586c3ad8cfe82fe49669796`.
- Veri paketi: `DatabaseProgressReport003.zip` içindeki `devhub-github-data-mimarisi-2.1.0.zip`.
- Üretim modelleri ve servisleri yalnızca `lib/` altında tutulur. Kuralların tek kaynağı `data/firestore/firestore.rules` dosyasıdır; root `firebase.json` ve Emulator ayarı aynı dosyayı işaret eder.
- PR #2 servisindeki e-posta kullanıcı-adı fallback'i kaldırılmış sürüm korunmuştur. E-posta adresi veya e-posta yerel kısmı proje/başvuru görünen adı olarak yazılmaz.
- Kayıt sırasında Firebase Auth kullanıcısı ve `users/{uid}` profil belgesi oluşturulur; eski hesap girişinde eksik profil tamamlanır; profil adı Auth `displayName` ve Firestore ile senkron tutulur.
- Firebase Console'da doğrulanmamış OAuth ve anonim sağlayıcıları ilk aşamada kapalıdır.
- Flutter Web giriş noktası ve Hosting SPA dosyaları (`web/index.html`, `web/manifest.json`) dahil edilmiştir.

## İlk aşama fonksiyonları

1. E-posta/şifre ile kayıt, giriş, çıkış ve şifre sıfırlama.
2. Kullanıcı profili görüntüleme/düzenleme.
3. Açık projeleri listeleme, arama, detay, proje oluşturma ve güncelleme.
4. Projeye başvuru, kendi başvuru durumunu görme.
5. Proje sahibinin gelen başvuruyu kabul etmesi/reddetmesi; kabulde proje üyeliği ve başvuru durumu aynı batch işleminde güncellenir.
6. Firestore veri sözleşmeleri, Security Rules, Emulator testleri ve CI iş akışları.

## Sınırlamalar / kabul notları

- Bu çıktı yerel entegre ZIP'tir. GitHub'daki PR'lar merge edilmedi, hiçbir branch'e push yapılmadı.
- Firebase Authentication, Firestore Rules ve Hosting üzerinde uzaktan değişiklik veya deploy yapılmadı.
- Üyelerin gerçek kimliği `publicProfiles` gibi herkese açık güvenilir bir profil kaydıyla Rules seviyesinde doğrulanmıyor. Proje/başvuru belgelerindeki `ownerName` ve `applicantName` istemci kaynaklı metin anlık görüntüleridir; MVP için bilinçli sınırlamadır. UI bu isimleri yetkilendirme kararı için kullanmaz.
- Firebase denetim raporundaki durum 7 Kasım 2026 tarihliydi. Bugünkü gerçek proje ayarları yeniden salt okunur kontrol edilmelidir.
- Bu çalışma ortamında Flutter/Dart SDK bulunmadığı için `flutter analyze`, `flutter test` ve `flutter build web` çalıştırılamadı. Veri paketi 2.1.0 raporundaki önceki 115 PASS, önceki kaynak ağacına ait kanıttır; bu entegre UI teslimi için yeni test sonucu olarak sunulmamaktadır.
- Node sürümü bu ortamda 22.16.0 olduğu, veri paketi Node 24.x istediği için `npm ci` tamamlanamadı; npm validate/Emulator verify bu ortamda tamamlanmadı. Kullanıcı makinesinde veya CI'da belgelenen sürümlerle çalıştırılmalıdır.

## Sonraki adım

`FIREBASE_SETUP.md` adımlarını izleyip önce Flutter ve data doğrulamalarını çalıştırın. Ardından mevcut repoda `main` tabanlı yeni bir entegrasyon branch'i açıp bu klasörün içeriğini repo köküne alın, CI sonucunu kontrol edin ve Pull Request açın. Firestore Rules ve Hosting deploy'u ayrı, onaylı işlemler olarak bırakılmıştır.
