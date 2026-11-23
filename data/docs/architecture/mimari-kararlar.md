# Mimari Kararlari

## ADR-201 - Mevcut Flutter Sozlesmesi Esastir

Durum: ekip geri bildirimiyle uygulanmÄ±ÅŸ yerel katkÄ±, PR incelemesi bekliyor. 4 KasÄ±m 2026.

1.1.0, ekip modellerinde bulunmayan revision/schemaVersion/flags/karar metadatasÄ±nÄ± zorunlu kÄ±lÄ±yor ve geÃ§erli codec alanlarÄ±nÄ± reddediyordu. Kaynak model ve servisler yeniden yazÄ±lmayacak; bu sÃ¼rÃ¼m onlarÄ±n alanlarÄ±na uyarlanacaktÄ±r. Zorunlu yeni belge metadatasÄ± eklenmez. SÃ¶zleÅŸme ve izin deÄŸiÅŸiklikleri kÄ±rÄ±cÄ± olduÄŸu iÃ§in paket sÃ¼rÃ¼mÃ¼ 2.0.0 seÃ§ildi; veritabanÄ±na schemaVersion=2 alanÄ± eklenmedi.

Dayanak: kullanÄ±cÄ±nÄ±n aktardÄ±ÄŸÄ± ekip feedback'i ve [sabit kaynaklar](../../validation/kaynaklar.json). Main'in tamamlandÄ±ÄŸÄ± veya feature dallarÄ±nÄ±n birleÅŸtirildiÄŸi varsayÄ±lmadÄ±. Pinned test bunun aÃ§Ä±k alternatif kanÄ±tÄ±dÄ±r.

## ADR-202 - Ortak Proje Hedefi

Eski yeni-proje kararÄ±, ekip tarafÄ±ndan verilen ortak `devhub-34108` hedefiyle deÄŸiÅŸti. `.firebaserc` default ve FlutterFire projectId uyuÅŸur. Bu, hesap eriÅŸimi veya deploy yetkisi kanÄ±tÄ± deÄŸildir. Oturum doÄŸrulanamadÄ±ÄŸÄ±ndan proje gÃ¶rÃ¼nÃ¼rlÃ¼ÄŸÃ¼ aÃ§Ä±k kalÄ±r. Yeni Firebase projesi oluÅŸturulmaz. HiÃ§bir uzak yazma/daÄŸÄ±tÄ±m yapÄ±lmaz.

## ADR-203 - Tek Rules Kaynagi

Esas dosya `data/firestore/firestore.rules` olur. Bu sÃ¼rÃ¼mde Ã¼retici veya src/ kopyasÄ± yoktur. KÃ¶k firebase.json ve yerel Emulator config aynÄ± fiziksel dosyaya farklÄ± gÃ¶reli yollarla iÅŸaret eder. Canan'Ä±n feature dalÄ±ndaki kÃ¶k `firestore.rules`, entegrasyon sÄ±rasÄ±nda kaldÄ±rÄ±lmalÄ±dÄ±r; iki dosyayÄ± birlikte gÃ¼ncellemek kabul edilmez. Statik kontrol ikinci kÃ¶k dosyayÄ± reddeder.

## ADR-204 - Ozel Profil Belgesi

AppUser.email aynÄ± belgede olduÄŸu ve mevcut profil ekranÄ± yalnÄ±z oturum sahibini dinlediÄŸi iÃ§in users belgelerine yalnÄ±z sahibi eriÅŸir. Firestore belge okumasÄ±nda alanlarÄ± gizleyen Rules yaklaÅŸÄ±mÄ± kullanÄ±lmaz. Projeler tÃ¼m Auth oturumlarÄ±na aÃ§Ä±ktÄ±r; buradaki ownerName ve Ã¼ye UID'leri bu gÃ¶rÃ¼nÃ¼rlÃ¼ÄŸe dahildir. E-posta projeye kopyalanmaz; fakat mevcut servis gÃ¶rÃ¼nen ad yoksa e-postanÄ±n yerel kÄ±smÄ±nÄ± ad yapmaktadÄ±r. Bu Ã¼rÃ¼n/gizlilik konusu ayrÄ±ca karara baÄŸlanmalÄ±dÄ±r. BaÅŸvuru mesajlarÄ± yalnÄ±z taraflara aÃ§Ä±ktÄ±r.

Kamusal geliÅŸtirici profili eklenirse public/private veri ayrÄ±mÄ±, yeni servis Ã§aÄŸrÄ±larÄ± ve testleri ayrÄ± kararla yapÄ±lacaktÄ±r. Bu sÃ¼rÃ¼mde ayrÄ± usersPrivate koleksiyonu uydurulmadÄ±.

## ADR-205 - Atomik Kabul Ve Uye Listesi

Mevcut decideApplication batch API'si korunur. Accepted kararÄ±, pending kaydÄ±nÄ±n aynÄ± atomik iÅŸlemde kabulÃ¼ ve bir UID'nin mevcut listenin sonuna eklenmesiyle mÃ¼mkÃ¼ndÃ¼r. Sadece accepted belge var diye sonradan Ã¼ye eklenemez. Ãœye silme/deÄŸiÅŸtirme, baÅŸka baÅŸvuranÄ± ekleme ve terminal kararÄ± yeniden aÃ§ma reddedilir. BaÅŸvuru kararÄ± sÄ±rasÄ±nda proje closed olabilir; mevcut servis bunu yasaklamadÄ±ÄŸÄ± iÃ§in bu sÃ¼rÃ¼m yeni bir aÃ§Ä±k-proje zorunluluÄŸu getirmez. Yeni baÅŸvuru yalnÄ±z open projeye yapÄ±lÄ±r.

## ADR-206 - Mevcut Sorgulara Gore Indeks

Mevcut ProjectService dÃ¶rt adet tek alan eÅŸitlik sorgusu yapar. Eski 35 birleÅŸik indeks ve 374 olasÄ± filtre kombinasyonu bugÃ¼nkÃ¼ kodun zorunluluÄŸu deÄŸildir. Aktif manifest boÅŸ birleÅŸik indeks listesi taÅŸÄ±r. VarsayÄ±lan tek alan indeksleri gereklidir; uzaktan kapatÄ±lmÄ±ÅŸ olabilecekleri henÃ¼z kontrol edilmedi. Yeni where/orderBy/cursor deÄŸiÅŸikliÄŸi sorgu envanteri ve indeks incelemesini tekrar aÃ§ar.

## ADR-207 - Kimlik, Limit Ve Tarihsel Veri

Proje belge ID'si, mevcut `.add()` yÃ¶nteminin Ã¼rettiÄŸi 20 alfanÃ¼merik karaktere gÃ¶re doÄŸrulanÄ±r. BÃ¶ylece `_` ayÄ±racÄ±yla baÅŸvuru anahtarÄ± Ã¼retimi proje/UID Ã§akÄ±ÅŸmasÄ±na aÃ§Ä±k olmaz; Auth UID iÃ§indeki alt Ã§izgiler korunur. Eski keyfi proje ID'leri veya eski 1.1.0 belgeleri uzaktan taranmadÄ±. Bunlar varsa otomatik silme/dÃ¶nÃ¼ÅŸtÃ¼rme yapÄ±lmaz.

BaÅŸlÄ±k/aÃ§Ä±klama/mesaj sÄ±nÄ±rlarÄ± mevcut form/feature Rules'tan alÄ±nÄ±r. Profil ve liste sayÄ±sÄ± sÄ±nÄ±rlarÄ± feature Rules tabanÄ±dÄ±r. Liste Ã¶ÄŸelerinde string tipi, kontrol karakteri yasaÄŸÄ± ve 200 Unicode kod noktasÄ± sÄ±nÄ±rÄ± bu katkÄ±nÄ±n aÃ§Ä±k teknik doÄŸrulama tercihidir; bir tasarÄ±m gereksinimi deÄŸildir. GÃ¶sterim etiketleri slug'a Ã§evrilmez. BoÅŸ teknoloji/rol listeleri model varsayÄ±lanlarÄ±nÄ± korumak iÃ§in veri katmanÄ±nda kabul edilir; UI daha sÄ±kÄ± form doÄŸrulamasÄ± yapabilir.

## ADR-208 - Eski Altyapiyi Saklama

Eski 99 dosyalÄ± kaynak ZIP'i deÄŸiÅŸmeden tarihsel arÅŸiv olarak teslim edilir. Eski migration/seed/snapshot/restore araÃ§larÄ± yeni ÅŸemaya otomatik uyarlanmÄ±ÅŸ sayÄ±lmaz, MVP CI'sine baÄŸlanmaz. Eski KVKK araÅŸtÄ±rmasÄ± korunur; gerÃ§ekleÅŸmemiÅŸ veri sorumlusu/saklama/aktarÄ±m kararlarÄ± onaylanmÄ±ÅŸ sayÄ±lmaz. GÃ¼ncel katkÄ±nÄ±n gÃ¼venlik kaynaÄŸÄ± bu sÃ¼rÃ¼mÃ¼n Rules dosyasÄ±dÄ±r.

## ADR-209 - Gercek Hedef Dogrulamasi

7 Kasım 2026'da ortak devhub-34108 hesabı ve SDK eşleşmesi gerçek API'lerden doğrulandı. Veritabanı (default)/eur3 Native Standard, top-level koleksiyon listesi boş; özel indeks/override yok, varsayılanlar READY. Dört gerçek aggregate sorgusu IAM ile geçti. Bu kayıt ADR-202/206/207'deki erişim ve gerçek indeks belirsizliğini tarihli gözlem olarak giderir. Yayımdaki Rules deny-all; PR onayı gereği değişmez.

## ADR-210 - Yerel Kaynak Entegrasyonu Ve Gercek Servis Testi

Enes ve Canan'ın beş model/servis kaynağı mevcut lib/ yollarında kendi commit içerikleri korunarak yerel branch'e alındı. Ayrı üretim kopyası veya yeniden yazılmış servis yoktur. Paket 2.1.0, veri sözleşmesi 2.0.0 kalır. Tam verify artık pinned kaynak yerine bu entegre lib/ koduyla çalışır. Dart servisleri gerçek Chrome eklentileriyle Auth/Firestore Emulator üzerinde sınanır. Uzak feature/main dalları birleştirilmedi. Bu kayıt ADR-201'in main entegrasyon bağımlılığını yerel teslim için tamamlar; uzak PR kabulünü tamamlamaz.

## ADR-211 - Yayin Ve Yetki Siniri

Firebase mimari/veri mühendisliği sorumluluğu; kurallar, sözleşme, indeks, doğrulama ve inceleme araçlarını kapsar. Uzak inceleme GET/okuma RPC sınırıyla test edilir; otomatik veri/Rules/Auth/IAM/Hosting değişimi yoktur. Metadata ve gerçek aggregate sorguları ayrı; yerel Rules/servis testleri ayrı kanıttır. Kullanıcı yayını onayı ve kurumsal kişisel veri kararları productionReady=false olarak açık tutulur. Eski teslimler tarihsel arşivde korunur.
