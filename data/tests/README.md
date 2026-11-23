# Test Ve Kanit Rehberi

## Tam Kosum

Uygulama kökündeki teslim dosyaları birleştirildikten sonra data/ içinde npm ci --ignore-scripts ve npm run verify çalıştırılır. Node 24.x, Java 21+, Flutter 3.47.7 ve Chrome gerekir. Normal verify Firebase hesabına ihtiyaç duymaz, yalnız demo-devhub-mvp/loopback Emulator'a yazar.

Sıra: uygulama analizi ve mevcut widget smoke -> gerçek Dart codec -> statik config/sözleşme/sorgu/link kontrolü -> Node sözleşme/uzak okuma sınırı -> Rules testleri ve gerçek Dart servisleriyle Chrome/Auth/Firestore testi -> npm audit. Sonuç reports/son-kosum.json. Kaynak hash'i uygulama lib/test/config/CI ve data kaynaklarını kapsar; öncesi/sonrası farklıysa FAIL olur. Skip/TODO başarısız sayılır. Eski rapor dosyası taze koşum kanıtı yerine kabul edilmez.

## Kanit Katmanlari

**Codec:** Gerçek AppUser/Project/ProjectApplication toMap/fromMap, optional alanlar, Timestamp/UTC ve Unicode ölçüleri çalıştırılır. Üretilen dört sentetik harita fixtures/model-ciktilari.json ile karşılaştırılır; Node şeması ve Emulator yazmaları bu haritaları da kullanır.

**Sözleşme ve araç sınırı:** Yanlış tip/alan/durum/uzunluk reddi ve gerçek gösterim etiketleri kontrol edilir. Uzak inceleme aracının başka proje/host, belge payload ve yazma rotaları kapalı olduğu ayrıca sınanır.

**Rules:** Olumlu akışlarla birlikte kendi/başka profil, email, anonim katkı, sahiplik, tekrar/kendi projesine başvuru, özel başvuru, atomik karar/üyelik, terminal karar, yarışlar ve en büyük geçerli belge sınanır. Sırf bütün işlemleri reddeden kurallar başarılı sayılmaz.

**Gerçek Dart servisleri:** Üretim lib/ içindeki beş kaynak geçici browser-test paketine alınır. Gerçek web eklentileri Auth ve Firestore Emulator'a bağlanır; gerçek FirestoreService/ProjectService çalışır. I01..I10 profil merge/stream/get, proje create/read/list/update, transaction başvuru, mükerrerlik, gerçek batch+arrayUnion kabul/ret, özel profil reddi, sahiplik, stale closed proje ve anonim katkı reddini kanıtlar. Firebase/Admin fake servisi kullanılmaz. Web plugin kayıtları ve doğrudan test bağımlılıkları yalnız test harness'ına eklenir; uygulama pubspec'i değişmez.

**Uygulama smoke:** Mevcut widget_test.dart regresyonu korunur; tam UI uçtan uca kanıtı değildir.

## Windows Web Test Ortami

Flutter 3.47.7'nin CanvasKit test asset işleyicisi Windows ayraçları nedeniyle 404 döndü. tools/lib/windows-test-assets.mjs yalnız test koşucusunun açtığı headless Chrome'a, aynı SDK'daki değişmemiş JS/WASM dosyalarını sağlar. Firebase istekleri ve sonuçları yakalanmaz/değiştirilmez; global SDK dosyası düzenlenmez. Dosya hash'leri servis raporuna yazılır. Linux CI bu Windows uyumluluk yolunu kullanmaz.

## Akis Ve Tekrar Uretim

Firestore snapshot akışının ilk olayı cache'den gelebilir. Başka istemcinin kararını bekleyen test .first sonucunu güncel sunucu kararı saymaz; beklenen duruma ulaşan stream olayını sınırlı timeout ile bekler. Zorunlu durumda gelmeyen olay testi başarısız yapar; keyfî sleep ile başarı üretilmez.

Fixture değişikliği yalnız onaylı model farkından sonra npm run test:flutter -- --update-fixtures ile gerçek codec'den üretilir ve tüm verify tekrar çalıştırılır. --pinned yalnız tarihsel codec tekrarında kullanılabilir; bu nihai tam verify entegre lib/ kaynakları gerektirir.

Gerçek Firebase metadata/aggregate denetimi ayrı çalıştırılır; CI ve yerel verify ortak projeyi kullanmaz. OAuth IAM sorgusu istemci Rules yetkisini, Emulator gerçek bulut performansını veya KVKK onayını kanıtlamaz. Başarısız ara koşumlar reports/ altında saklanır; teslimde son başarılı koşum ve sınırları raporlanır.
