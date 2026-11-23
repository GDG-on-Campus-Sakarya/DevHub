# İlk Aşama Entegrasyon Notları

Teslim tarihi: 23 Kasım 2026.

## Kaynakların birleştirilmesi

- `main` tabanı: `125b11119cfb783f52c76ad86aa9e1df92b61c9d` (PR #3 Firebase proje yapılandırması korunmuştur).
- PR #1: `feature/auth-and-profile`, baş `1c217f007329fb0ac024b5ff91b8bbe3f4a090c7`. PR #1 başı main'den iki commit geride olduğundan main'deki Firebase yapılandırması korunup Auth/Profile katmanı buna göre entegre edilmiştir.
- PR #2: `feature/project-discovery-and-applications`, baş `cf03b0c548aac6d62586c3ad8cfe82fe49669796`. Proje modelleri ve servis sözleşmeleri bu güncel sürümle eşleştirilmiştir. Üçüncü taraf veri paketindeki eski e-posta yerel-parçası isim yedeği kaldırılmıştır.
- Üye 4 veri paketi: `data/` sözleşmeleri, tek Firestore Rules kaynağı, Emulator/test koşucuları, denetim ve operasyon dokümanları eklenmiştir. Beş üretim model/servis dosyasının sahibi yine `lib/` ağacıdır.
- Üye 1 patch'i: landing/home teması, route düzeni ve tekrar kullanılabilir proje kartı korunmuştur.

## Entegrasyonda giderilen noktalar

1. Kayıt sonrasında Firebase Auth `displayName` güncellenir ve `users/{uid}` profili oluşturulur. Eski hesabın profil belgesi yoksa girişte bir kez oluşturulur.
2. Profil adı değişimi hem Firebase Auth `displayName` hem Firestore profiline yazılır; böylece yeni proje ve başvuru kayıtları eski adı kullanmaz.
3. Yapılandırılmamış OAuth ve anonim giriş seçenekleri varsayılan kapalıdır. İlk aşama e-posta/şifre ile sınırlıdır.
4. AuthGate oturum akışına bağlanır. Widget smoke testi AuthGate/Firebase plugin başlatılmasına bağımlı olmamak üzere login ekranında çalışır.
5. Proje detay route'u `projectId` argümanı alır; create/edit, başvuru ve karar ekranları ortak `ProjectService` API'sini kullanır.
6. Firestore için tek aktif Rules yolu `data/firestore/firestore.rules` olarak tutulur.
7. CI kapsamı yalnız veri dosyalarıyla sınırlı bırakılmamış; tüm `lib/`, `test/` ve `web/` değişiklikleri için analyze, test ve web build job'u eklenmiştir.

## Bilinen kabul sınırları

- Görünen proje/başvuru ad alanları Rules tarafından güvenilir public profile kaydıyla doğrulanmaz; MVP'de display label snapshot'ı olarak kullanılır. Public profile doğrulaması sonraki güvenlik kararıdır.
- Bu teslimde `flutter` / Dart SDK bu çalışma ortamında bulunmadığı için Flutter analyze, widget test ve Web build burada çalıştırılamadı. CI ve yerel doğrulama komutları repo'ya eklenmiştir.
- Önceki 2.1.0 tesliminde raporlanan 115 PASS bu yeniden oluşturulan UI ağacı için yeni test sonucu olarak sunulmamaktadır. Yeniden çalıştırıldığında yeni rapor üretilecektir.
- `data/validation/firebase-hedefi.json` içindeki gerçek Firebase gözlemi 7 Kasım 2026 tarihli snapshot'tır; güncel durum gibi ele alınmamalıdır.
- Rules deploy ve Hosting deploy yapılmamıştır. Yayın, ekip onayı ve güncel Firebase durum kontrolünden sonra yapılmalıdır.
