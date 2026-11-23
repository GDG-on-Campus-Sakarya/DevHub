# DevHub Veri Altyapisi

Paket **2.1.0**, veri sözleşmesi **2.0.0**, 7 Kasım 2026. Ortak hedef **devhub-34108**; veritabanı **(default), eur3, FIRESTORE_NATIVE / STANDARD**. Bu teslim inceleme ve entegrasyon için hazırlanmış veri mühendisliği katkısıdır. Giriş bu dosyadır.

## Tamamlanan Is

Ortak Firebase gerçek API'lerle salt okunur incelendi: hesap erişimi, proje/uygulama, SDK eşleşmesi, veritabanı, yayımdaki Rules, indeks/alan yapılandırması, dört gerçek sorgu, Auth ve Hosting bilgileri doğrulandı. [Firebase Denetimi](docs/operations/firebase-denetimi.md), tarihli [Hedef Kaydi](validation/firebase-hedefi.json).

Enes'in AppUser/FirestoreService ve Canan'ın Project/ProjectApplication/ProjectService kaynakları mevcut `lib/` yollarına, kendi feature commit'lerindeki içerikleri değiştirilmeden alındı. Aynı modelleri data/ içine kopyalayan yeni bir üretim katmanı yoktur. [Kaynak Sicili](validation/kaynaklar.json) commit/hash ve yerel entegrasyonu kaydeder. Uzak main'e merge/push yapılmadı; bu teslim yerel birleştirilmiş çalışma ağacıdır. Bu paket birleştirmeye hazır yerel katkıyı içerir.

Güvenlik; kendi profilini değiştirme, özel email, proje sahipliği, sabit başvuru anahtarı, canlı proje durumu, terminal karar ve atomik kabul/üyelik üzerinde zorlanır. [Ortak Veri Sozlesmesi](contracts/veri-sozlesmesi.md), [Guvenlik](firestore/guvenlik-sozlesmesi.md).

## Calistirma

Node.js 24.x, npm, Java 21+, Flutter 3.47.7 ve Chrome gerekir. CLI kilitli paket bağımlılığıdır. Uygulama deposunda bu teslimin kök config ve lib/ dosyalarını kontrollü birleştirin; sonra `data/` içinde:

```bash
npm ci --ignore-scripts
npm run verify
```

Verify; uygulama analizi/mevcut widget testi, gerçek Dart codec'leri, statik veri/config/sorgu denetimi, Node sözleşme/uzak okuma sınırı testleri, Firestore Rules ve **gerçek Dart servislerini Chrome + Auth/Firestore Emulator üzerinde** çalıştırır; bağımlılık audit'iyle tamamlar. Her yazma yalnız demo-devhub-mvp içindir. Ortak projeye test belgesi veya Auth hesabı eklenmez. Normal verify için Firebase login gerekmez. Üretim kodu `lib/` içinden okunur; bu teslimin tam koşumu pinned kaynak modunu kullanmaz.

Raporlar Git dışındaki reports/ altındadır. Başarısız/atlanan senaryo PASS sayılmaz; koşum öncesi/sonrası veri, uygulama ve config kaynak hash'i aynı olmalıdır. Sonuç reports/son-kosum.json. [Test Rehberi](tests/README.md).

Ortak proje durumunu **isteyerek ve salt okunur** yeniden incelemek için kendi hesabınızla Firebase CLI girişinden sonra:

```bash
npm run firebase:inspect
```

Bu komut sabit ortak hedefe yalnız izinli metadata ve count sorguları gönderir. Veri içeriklerini, token veya anahtarları rapora yazmaz; CI/verify tarafından otomatik çalıştırılmaz. [Isletim](operations/README.md).

## Nereden Baslamali

| Ihtiyac | Kaynak |
|---|---|
| Mimari ve değişiklik gerekçeleri | [Mimari Giris](docs/architecture/README.md), [ADR](docs/architecture/mimari-kararlar.md) |
| Alanlar / servisler | [Veri Sozlesmesi](contracts/veri-sozlesmesi.md), üç JSON Schema |
| Tek Rules kaynağı | [firestore.rules](firestore/firestore.rules) |
| Dört sorgu ve indeks | [Envanter](firestore/sorgu-envanteri.json), [Indeks Aciklamasi](firestore/indeks-aciklamasi.md) |
| Katkı disiplini | [Calisma Kurallari](docs/governance/calisma-kurallari.md) |
| Diğer geliştiricilerin kullanımı | [Gelistirici Rehberi](docs/operations/gelistirici-kullanim-rehberi.md) |
| Kişisel veri | [Kisisel Veri Kurallari](privacy/kisisel-veri-kurallari.md) |
| Onaylı yayın / geri dönüş | [Teslim Ve Yayin](operations/teslim-ve-yayin.md) |

## Yayin Durumu

Ortak Firebase'de halen **deny-all Rules** yayındadır. İstemci veri akışlarının orada çalışması için bu katkının Rules'ı PR'da incelenip yetkili kişi tarafından yayımlanmalıdır. Yerel test başarısı bu onayın yerine geçmez. Gerçek Firebase sorguları OAuth IAM ile indeks/sorgu biçimini doğrular; yayımdaki istemci Rules izinlerini geçmiş saymaz. UI uçtan uca test ve kurumsal kişisel veri kararları ayrıca tamamlanır. **productionReady=false; deploy yapılmadı.**

1.1.0 ve 2.0.0 çıktıları tarihsel arşivde korunur; önceki teslim yeni ZIP'in tarihsel bölümündedir. Eski data/ klasörü yeni data/ üzerine açılmaz. Seed/migration/snapshot/restore referansları yeni sözleşmeye uyarlanmadan çalıştırılmaz; bu MVP'nin zorunlu dağıtım adımları değildir.
