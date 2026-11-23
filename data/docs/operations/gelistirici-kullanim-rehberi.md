# Gelistirici Kullanim Rehberi

## Once Okunacaklar

Her geliştirici [Ana Giris](../../README.md) ve [Veri Sozlesmesi](../../contracts/veri-sozlesmesi.md) ile başlar. Profil geliştiricisi [Kisisel Veri Kurallari](../../privacy/kisisel-veri-kurallari.md) ve users izinlerini; proje/başvuru geliştiricisi [Guvenlik](../../firestore/guvenlik-sozlesmesi.md) ve [Sorgu Envanteri](../../firestore/sorgu-envanteri.json) dosyalarını okur. Veri katkısı ve inceleme için [Calisma Kurallari](../governance/calisma-kurallari.md), [Testler](../../tests/README.md), [Gercek Firebase Denetimi](firebase-denetimi.md) ve [Yayin Plani](../../operations/teslim-ve-yayin.md) kullanılır.

## Dosyalari Uygulama

Kaynak ZIP'i tam Flutter uygulaması değildir. Güncel uygulama deposunda ayrı branch açın; docs/TEAM_WORKFLOW.md sahipliğini koruyun. data/ yanında kök firebase.json/analysis_options.yaml ve mevcut lib/models/lib/services dosyaları da teslimin parçasıdır. Bunlar Enes/Canan kaynaklarının aynısıdır; sicilde hash/commit bulunur. Ekip bu feature kodlarını zaten birleştirmişse karşılıklı diff'i çözün; mevcut daha yeni kodu körlemesine ezmeyin. Üretim modelleri yalnız lib/ içinde kalır.

Kök firebase.json içindeki FlutterFire nesnesini koruyarak data/firestore yollarını birleştirin. .firebaserc referansı devhub-34108 default'unu gösterir; başka takım alias'larını silmeyin. Feature dalından gelen eski kök firestore.rules kaldırılır; tek kaynak data/firestore/firestore.rules'tır. analysis_options.yaml yalnız node_modules/reports içindeki yabancı/üretilmiş Dart kaynaklarını analizden çıkarır. Uygulama pubspec.yaml ve UI kaynakları değiştirilmedi.

## Kurulum

VS Code editördür. Dart uygulama dilidir; Flutter uygulama/test SDK'sıdır. Node.js veri araçlarını çalıştırır; npm paket ve komut yöneticisidir. Java Firestore Emulator'ı çalıştırır. Firebase CLI Emulator ve yetkili bulut işlemlerinin aracıdır. Git/GitHub değişiklik/inceleme geçmişidir.

flutter doctor -v, Node 24.x, Java 21+ ve Chrome kontrolünden sonra data/ içinde:

```bash
npm ci --ignore-scripts
npm run verify
```

Yerel verify için Firebase login gerekmez. Son test özeti reports/son-kosum.json; servis kanıtı reports/flutter-servis-uyumu.json içindedir. Veri testleri gerçek kullanıcıya veya ortak projeye yazmaz. Başarısız test atlanmaz.

Gerçek Firebase'i incelemek için kendi CLI hesabınızla giriş yapıp data/ içinde npm run firebase:inspect çalıştırın. Windows'ta firebase komutu bulunmuyorsa operations/README.md tam npx yolunu gösterir. Console veya CLI'da yeni proje açmayın. Ortak ID devhub-34108'dir; hesaba verilmiş bulut yetkisi, DevHub uygulama kullanıcı hesabı değildir.

## Uygulama Servisleri

Profil ekranı FirestoreService.streamUserProfile/getUserProfile/saveUserProfile ile mevcut Auth UID'sini kullanır. Başka kişinin özel profilini okumak permission-denied üretir. email token email ile aynı olmalı; isteğe bağlı null alanlar toMap tarafından atlanır. Merge eksik alanı silmez; copyWith null ile eski değeri temizlemez. Mevcut UI boş string kullanır. Profil e-postasını proje kartına kopyalamayın.

ProjectService mevcut streamOpenProjects/streamMyProjects/streamProject/createProject/updateProject metotlarını sunar. ownerId oturumdan gelir. Yeni revision/flags/sahip alanları forma eklenmez. Zamanları servis serverTimestamp ile yazar. Koleksiyon, alan ve durumlar sözleşmeye uyar.

Başvuru applyToProject ile sabit projectId_applicantId yolunda transaction ile oluşur. Güncel proje kullanılmalı; Rules canlı sahiplik/üyelik/açıklığı kontrol eder. Proje kapanmış veya başlığı değişmişse istemcideki eski nesne yazmayı geçiremez. Hata sonrası güncel projeyi okuyun. Mükerrer veya reddedilen başvuru için yeni belge ID'si üretmeyin.

Karar decideApplication ile verilir. Accepted ve üye ekleme aynı batch+arrayUnion içindedir. Bunları iki çağrıya ayırmayın. Terminal karar yeniden açılmaz. Başvuran kendi durumunu, sahip başka projeyi değiştiremez. Üye çıkarma/yeniden başvuru/sahip devri ayrı kapsam kararı gerektirir.

Snapshot stream'inin ilk olayı cache'den gelebilir; ekranda akışı dinlemeyi sürdürün. Başka cihazın yazmasını .first ile kesin sunucu durumu saymayın. Incoming projectId ve createdAt sıralaması mevcut kodda istemcidedir; sunucuda iki filtre/orderBy var sanmayın. Yeni sorgu tasarımı envanter/indeks/Rules/test incelemesini açar.

## Firebase Mevcut Durumu Ve Teslim

Email/parola açık, anonim Auth sağlayıcısı kapalı gözlendi. Rules anonim Auth okumayı destekler; bu, ortak projede misafir girişin etkin olduğu anlamına gelmez. Misafir akışı isteniyorsa Auth/ürün sorumlusu ayrı karar verir. Veri paketi sağlayıcı ayarını değiştirmez.

Ortak hedefteki deny-all Rules PR onayıyla yetkili kişi tarafından değiştirilmeden uygulama veri erişimi açılmaz. [Teslim Ve Yayin](../../operations/teslim-ve-yayin.md) sıra ve geri dönüşü açıklar. Ayrı branch/PR, normal verify ve test raporu zorunludur. Yerel kaynak entegrasyonu uzak main merge'i değildir; uzak PR/push/deploy bu teslimde yapılmadı.
