# Baglayici Calisma Kurallari

Bu sÃ¼rÃ¼mÃ¼n katkÄ± kurallarÄ±dÄ±r. ZORUNLU ifadesi yerine getirilmeden ilgili katkÄ± kabul edilmez; YASAK aÃ§Ä±k bir ret koÅŸuludur. KullanÄ±cÄ±nÄ±n aÃ§Ä±k talimatÄ± ve belgelenmiÅŸ ekip kararÄ± Ã¶nceliklidir. Eski arÅŸivin ek alan/servis Ã¶nerileri aktif MVP zorunluluÄŸu deÄŸildir.

## Kaynak Ve Sozlesme

**K01.** DeÄŸiÅŸiklikten Ã¶nce data/README.md, veri sÃ¶zleÅŸmesi ve uygulama docs/TEAM_WORKFLOW.md okunur. Ä°lgili model/servis sahibiyle ortak dosya deÄŸiÅŸimi koordine edilir.

**K02.** Main, feature kaynaÄŸÄ±, Ã¶nerilen tasarÄ±m, test edilen yerel davranÄ±ÅŸ ve canlÄ± kabul ayrÄ± etiketlenir. Feature testinden main entegrasyonu sonucu Ã¼retmek YASAKTIR.

**K03.** Koleksiyon/alan adlarÄ± sÃ¶zleÅŸmedeki deÄŸerlerle aynÄ±dÄ±r. Yeni alanÄ± yalnÄ±z bir istemci dosyasÄ±na eklemek YASAKTIR. Model, servis, ÅŸema, Rules, fixture, indeks ve test etkisi birlikte deÄŸerlendirilir.

**K04.** Mevcut modelin ihtiyaÃ§ duymadÄ±ÄŸÄ± alan, migration planÄ± ve ekip kararÄ± olmadan zorunlu yapÄ±lamaz. TasarÄ±mda gÃ¶rÃ¼lmeyen iÅŸ kuralÄ± Figma gereÄŸi diye sunulamaz.

**K05.** Veri sÃ¶zleÅŸmesi veya gÃ¶rÃ¼nÃ¼rlÃ¼k deÄŸiÅŸikliÄŸi ADR ve sÃ¼rÃ¼m kaydÄ± iÃ§erir. KÄ±rÄ±cÄ± izin/alan/durum deÄŸiÅŸikliÄŸi yalnÄ±z belge dÃ¼zeltmesi olarak sÃ¼rÃ¼mlenemez.

**K06.** Ãœretim model ve servis kaynaÄŸÄ± yalnÄ±z uygulama lib/ yollarÄ±ndadÄ±r. data/ iÃ§ine kopya AppUser/Project/ProjectService koymak YASAKTIR. Test derleme kopyalarÄ± yalnÄ±z Git dÄ±ÅŸÄ±ndaki reports/ iÃ§inde olabilir.

**K07.** Belge dosya adlarÄ± TÃ¼rkÃ§e ASCII lower-kebab-case; baÅŸlÄ±klar TÃ¼rkÃ§e ASCII olur. AÃ§Ä±klamalarda TÃ¼rkÃ§e karakterler kullanÄ±lÄ±r. Dart lower_snake_case/UpperCamelCase/lowerCamelCase kurallarÄ± izlenir. README.md, AGENTS.md ve araÃ§larÄ±n zorunlu isimleri korunur.

## Yetki Ve Butunluk

**K08.** Kimlik kaynaÄŸÄ± Auth UID'dir. Formdan ownerId/applicantId seÃ§mek veya UI kontrolÃ¼nÃ¼ tek yetki denetimi saymak YASAKTIR.

**K09.** Rules'Ä±n tek kaynaÄŸÄ± data/firestore/firestore.rules'tÄ±r. KÃ¶k firestore.rules dahil ikinci aktif kaynak YASAKTIR. Ä°ki config aynÄ± fiziksel kaynaÄŸÄ± gÃ¶stermelidir.

**K10.** VarsayÄ±lan diÄŸer yollar kapalÄ± kalÄ±r. Sorun Ã§Ã¶zmek iÃ§in allow-all veya kullanÄ±cÄ± profilini bÃ¼tÃ¼n oturumlara aÃ§mak YASAKTIR.

**K11.** Users belgesindeki email dahil Ã¶zel alanlar yalnÄ±z sahibine aÃ§Ä±ktÄ±r. BaÅŸka kullanÄ±cÄ±ya profil gÃ¶stermek ayrÄ± veri gÃ¶rÃ¼nÃ¼rlÃ¼k kararÄ± ve alan ayrÄ±mÄ± gerektirir.

**K12.** Proje sahibi yalnÄ±z kendi projesini dÃ¼zenler. ownerId/ownerName/createdAt gÃ¼ncellenemez. Sahip devri ve silme ayrÄ± yaÅŸam dÃ¶ngÃ¼sÃ¼ tasarÄ±mÄ± olmadan aÃ§Ä±lamaz.

**K13.** BaÅŸvuru anahtarÄ± projectId_applicantId'dir. Rastgele belge ID'siyle baÅŸvuru veya rejected kaydÄ± silerek yeniden baÅŸvuru YASAKTIR.

**K14.** Pending kararÄ± yalnÄ±z canlÄ± proje sahibi tarafÄ±ndan accepted/rejected yapÄ±lÄ±r. Karar sÄ±rasÄ±nda baÅŸvuru kimliÄŸi/mesajÄ± deÄŸiÅŸemez. Terminal kararÄ± yeniden aÃ§mak YASAKTIR.

**K15.** Accepted ve Ã¼yelik aynÄ± atomik yazmadÄ±r. Ä°ki baÄŸÄ±msÄ±z yazma, sadece istemci Ã¶n kontrolÃ¼, Ã¼yeleri elle diziye yazma veya geÃ§miÅŸ accepted kaydÄ±yla sonradan ekleme YASAKTIR.

**K16.** createdAt ve updatedAt uygulama saatinden gÃ¶nderilmez. Ä°lgili servis serverTimestamp kullanÄ±r. Profil iÃ§in modelde olmayan zorunlu zaman alanÄ± icat edilmez.

## Test Ve Kanit

**K17.** Node 24.x ve package-lock kullanÄ±lÄ±r. npm ci --ignore-scripts ile temiz kurulum yapÄ±lÄ±r. BaÄŸÄ±mlÄ±lÄ±k deÄŸiÅŸikliÄŸi lock ve audit kanÄ±tÄ±yla birlikte teslim edilir.

**K18.** Normal verify Ã§alÄ±ÅŸma aÄŸacÄ±ndaki gerÃ§ek lib/ kaynaklarÄ±nÄ± sÄ±nar. --pinned yalnÄ±z kaydedilmiÅŸ feature kaynaklarÄ±nÄ±n denetimidir. Pinned modu normal CI'nin yerine sessizce geÃ§irilemez.

**K19.** Testler yalnÄ±z demo-devhub-mvp ve loopback Emulator'a yazabilir. Ortak proje test hedefi yapÄ±lamaz. Admin/Rules-disabled test kurulumu yalnÄ±z sentetik baÅŸlangÄ±Ã§ verisi iÃ§indir.

**K20.** Pozitif yazmalar ve gÃ¼venlik ihlallerinin reddi birlikte sÄ±nanÄ±r. TÃ¼m yazmalarÄ± reddeden Rules, baÅŸarÄ±lÄ± gÃ¼venlik Ã§Ã¶zÃ¼mÃ¼ sayÄ±lmaz. Atomik kabul, en bÃ¼yÃ¼k geÃ§erli listeler ve yarÄ±ÅŸ durumlarÄ± pozitif kanÄ±t iÃ§erir.

**K21.** Test sonucu olay/exit-code kanÄ±tÄ±ndan Ã¼retilir. Skip/TODO/Ã§alÄ±ÅŸmayan test PASS sayÄ±lmaz. Kaynak hash'i koÅŸum boyunca deÄŸiÅŸirse sonuÃ§ geÃ§ersizdir.

**K22.** JSON Schema, Dart codec, Emulator Rules, gerÃ§ek indeks ve UI testleri ayrÄ± raporlanÄ±r. Birinin geÃ§mesi diÄŸerine PASS yazdÄ±rmaz. Kaynakta yÃ¶ntem adÄ± gÃ¶rmek, o servisin Ã§alÄ±ÅŸma zamanÄ± testi deÄŸildir.

**K23.** Sorgu deÄŸiÅŸikliÄŸi envanter ve indeks incelemesini tekrar aÃ§ar. Emulator'Ä±n baÅŸarÄ±lÄ± olmasÄ± gerÃ§ek indeksi hazÄ±r kabul etmeye yetmez.

## Git Ve Yayin

**K24.** AyrÄ± branch ve PR incelemesi kullanÄ±lÄ±r. main'e doÄŸrudan push veya onaysÄ±z Rules/index/Hosting deploy YASAKTIR. CI'de deploy job'u veya Firebase anahtarÄ± bulunmaz.

**K25.** KÃ¶k firebase.json iÃ§indeki FlutterFire nesnesi korunur. DosyanÄ±n Ã¼stÃ¼ne genel Ã¶rnek config yazmak YASAKTIR. .firebaserc default hedefi devhub-34108 olur; uzak eriÅŸim ayrÄ±ca doÄŸrulanÄ±r.

**K26.** CLI proje listesinde ortak hedef yoksa yeni proje aÃ§Ä±lmaz. Ã–nce giriÅŸ durumu ve ekip IAM eriÅŸimi ayrÄ±ÅŸtÄ±rÄ±lÄ±r. Oturum hatasÄ± eriÅŸim yetkisi yok ÅŸeklinde raporlanamaz.

**K27.** GerÃ§ek veriye geÃ§iÅŸten Ã¶nce belge/indeks envanteri, uyum farklarÄ±, yedekleme ve geri dÃ¶nÃ¼ÅŸ planÄ± gerekir. Tarihsel seed/migration/restore araÃ§larÄ± yeni ÅŸemaya uyarlanmadan ortak projeye Ã§alÄ±ÅŸtÄ±rÄ±lamaz.

**K28.** Yeni paket eski Ã§Ä±ktÄ±yÄ± deÄŸiÅŸtirmez. Dosya sayÄ±sÄ± bitmiÅŸ ZIP'in gerÃ§ek dosyalarÄ±ndan hesaplanÄ±r; iÃ§ ZIP, dÄ±ÅŸ dosyalar ve tarihsel arÅŸiv ayrÄ± sayÄ±lÄ±r. node_modules/log/ham tasarÄ±m/gerÃ§ek kiÅŸi verisi kaynak ZIP'ine girmez.

**K29.** GerÃ§ek veri sorumlusu, amaÃ§/hukuki ÅŸart, aktarÄ±m, saklama, hak talepleri ve sorumlular onaylanmadan productionReady=true yazÄ±lamaz. Sentetik test bu kararlarÄ±n yerine geÃ§mez.

**K30.** Kesintiden sonra son koÅŸum ve kaynak hash'i yeniden karÅŸÄ±laÅŸtÄ±rÄ±lÄ±r. Tamamlanmayan madde aÃ§Ä±k kaydedilir; kredi veya sÃ¼re bitmesi teknik kabul Ã¶lÃ§Ã¼tÃ¼ deÄŸildir.

Ä°stisna gerekiyorsa kural ID'si, gerekÃ§e, etkilenen veri/izin, sÃ¼re, telafi kontrolÃ¼ ve yetkili karar aynÄ± PR'da kayÄ±tlÄ± olmalÄ±dÄ±r. GÃ¼venlik sÄ±nÄ±rÄ±nÄ± kaldÄ±ran geÃ§ici allow-all istisnasÄ± kabul edilmez.

## Nihai Teslim Eki

**K31.** firebase:inspect yalnız açıkça istenen salt okunur denetimdir; veri içeriği, token/anahtar dışa aktarma veya başka hedef rotası açılamaz. IAM sorgu başarısı uygulama Rules izni sayılmaz.

**K32.** Yerel kaynak entegrasyonunda katkı sahiplerinin dosyaları ve commit/hash kökeni kaydedilir. Uzak main’e alınmış gibi sunulamaz; daha yeni ekip değişiklikleri ZIP ile körlemesine ezilemez.

**K33.** Gerçek servis browser testinin SDK asset uyumluluğu yalnız test ortamına uygulanır; Firebase çağrısı/sonucu veya global SDK kaynakları değiştirilmez. Atlanan servis testiyle tam verify PASS üretilemez.
