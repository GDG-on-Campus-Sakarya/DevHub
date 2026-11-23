# Kisisel Veri Ve Yayin Kurallari

Bu belge bu katkÄ±nÄ±n teknik veri iÅŸleme sÄ±nÄ±rÄ±dÄ±r; KVKK uygunluk onayÄ± veya tamamlanmÄ±ÅŸ hukuki gÃ¶rÃ¼ÅŸ deÄŸildir. 1.1.0 arÅŸivindeki 27 Ekim 2026 tarihli araÅŸtÄ±rma ve kaynak sicili korunmuÅŸtur. Tarihsel inceleme gÃ¼ncel kurumsal karar gibi sunulmaz. Bu sÃ¼rÃ¼mde yeni bir hukuki deÄŸerlendirme tamamlandÄ±ÄŸÄ± iddia edilmez.

## Veri Gorunurlugu

| Veri | Konum | Kim Okur | Sinir |
|---|---|---|---|
| Ad, email, bio, bÃ¶lÃ¼m, beceri, GitHub baÄŸlantÄ±sÄ± | users/UID | yalnÄ±z ilgili UID | kullanÄ±cÄ± listesi kapalÄ± |
| Proje iÃ§eriÄŸi, ownerName, ownerId, Ã¼ye UID'leri | projects/ID | tÃ¼m Auth oturumlarÄ±; anonim Auth dahil | oturumsuz eriÅŸim kapalÄ± |
| BaÅŸvuran adÄ±/UID, mesaj, durum, proje kopyasÄ± | applications/ID | baÅŸvuran ve proje sahibi | UID koÅŸulsuz toplu sorgu kapalÄ± |
| Auth hesabÄ±/saÄŸlayÄ±cÄ± ve token | Firebase Auth | Auth/IAM dÃ¼zeni | Firestore Rules Auth hesabÄ±nÄ± yÃ¶netmez |
| Test/CI kanÄ±tlarÄ± | yerel reports ve CI log | geliÅŸtirme ekibi | yalnÄ±z sentetik Ã¶rnekler; Git dÄ±ÅŸÄ± |

UID ve gÃ¶rÃ¼nen adlar da kiÅŸisel veri kapsamÄ±nda deÄŸerlendirilmesi gereken tanÄ±mlayÄ±cÄ±lardÄ±r. Projelerde email alanÄ± yoktur; mevcut servisin gÃ¶rÃ¼nen ad yoksa e-posta yerel kÄ±smÄ±nÄ± kullanmasÄ± ayrÄ±ca Ã¼rÃ¼n/gizlilik incelemesine aÃ§Ä±ktÄ±r. Proje iÃ§ine kopyalanan ownerName, profil deÄŸiÅŸtirilince otomatik gÃ¼ncellenmez. KullanÄ±cÄ± adÄ±/Ã¼yeliÄŸi gÃ¶rÃ¼nÃ¼rlÃ¼ÄŸÃ¼ gerÃ§ek aydÄ±nlatma kapsamÄ±na dahil edilmelidir.

## Zorunlu Teknik Sinirlar

**P01.** GerÃ§ek isim/email/baÅŸvuru mesajÄ±/UID, fixture, screenshot, hata Ã§Ä±ktÄ±sÄ±, AI girdisi veya test raporuna kopyalanmaz. @example.invalid adresleri ve sentetik adlar kullanÄ±lÄ±r.

**P02.** Token, parola, Ã¶zel anahtar ve servis hesabÄ± dosyasÄ± Git'e/ZIP'e eklenmez. Ä°stemci Firebase seÃ§enekleri gizli Admin anahtarÄ± yerine geÃ§mez. GeliÅŸtiriciler kendi hesaplarÄ±yla giriÅŸ yapar; hesap paylaÅŸÄ±mÄ± yapÄ±lmaz.

**P03.** Firestore Rules ile IAM ayrÄ±dÄ±r. Console/Admin eriÅŸiminin hangi kiÅŸide ve hangi amaÃ§la bulunduÄŸu ekip tarafÄ±ndan kaydedilir. Rules testi Admin eriÅŸiminin sÄ±nÄ±rlandÄ±ÄŸÄ±nÄ± kanÄ±tlamaz.

**P04.** Profil belgesi belge seviyesinde korunur. BazÄ± alanlarÄ± gizlediÄŸi varsayÄ±lan genel read izni yazÄ±lamaz. Kamusal profil eklenecekse Ã¶zel alanlar ayrÄ± gÃ¼venli veri yapÄ±sÄ±na taÅŸÄ±nmadan eriÅŸim aÃ§Ä±lamaz.

**P05.** Destek/eriÅŸim talebinde kullanÄ±cÄ± verileri genel GitHub issue veya herkese aÃ§Ä±k PR'a yazÄ±lmaz. TanÄ±lama kayÄ±tlarÄ± metin iÃ§erikleri yerine hata kodu ve gerekli teknik metadatayla sÄ±nÄ±rlandÄ±rÄ±lÄ±r.

**P06.** Bu MVP'de istemci delete kapalÄ±dÄ±r; bu, veri silme hakkÄ±nÄ±n veya kurumsal imha sorumluluÄŸunun ortadan kalktÄ±ÄŸÄ± anlamÄ±na gelmez. Yetkili iÅŸletim akÄ±ÅŸÄ±, baÄŸlÄ± belge etkileri, Auth hesabÄ± ve yedekler birlikte tasarlanmalÄ±dÄ±r. Eski snapshot aracÄ± bunu otomatik tamamlamaz.

**P07.** Mobil/web Ã¶nbellek, oturum kapatma, paylaÅŸÄ±lan cihaz, analytics/Hosting loglarÄ± ve Auth saÄŸlayÄ±cÄ±larÄ± bu veri modÃ¼lÃ¼nÃ¼n dÄ±ÅŸÄ±nda kalan entegrasyon kontrolleridir. Bunlara test edilmediÄŸi hÃ¢lde PASS yazÄ±lamaz.

## Acik Kurumsal Kararlar

| Karar | Bu teslimde durum | Kabul kaniti |
|---|---|---|
| GerÃ§ek veri sorumlusu ve iletiÅŸim | BELIRLENMEDI | yetkili kurum/kiÅŸi ve kayÄ±tlÄ± iletiÅŸim |
| Her iÅŸleme amacÄ±/hukuki ÅŸartÄ± ve aydÄ±nlatma | ONAYLANMADI | gerÃ§ek amaÃ§/veri/kitle eÅŸlemeli onaylÄ± metin |
| Firebase/Auth/diÄŸer saÄŸlayÄ±cÄ± aktarÄ±m deÄŸerlendirmesi | ONAYLANMADI | gerÃ§ek mÃ¼ÅŸteri/saÄŸlayÄ±cÄ±/bÃ¶lge/sÃ¶zleÅŸme Ã¼zerinden inceleme |
| Saklama sÃ¼releri ve imha | BELIRLENMEDI | veri tÃ¼rÃ¼ bazÄ±nda gerekÃ§eli sÃ¼re, sorumlu ve uygulanabilir sÃ¼reÃ§ |
| Veri talebi ve ihlal mÃ¼dahalesi | ATANMADI | yetkili sorumlu, kanÄ±tlÄ± iletiÅŸim ve iÅŸleyen sÃ¼reÃ§ |
| GerÃ§ek kullanÄ±cÄ±ya aÃ§Ä±lÄ±ÅŸ | KAPALI | yukarÄ±daki kararlar ve teknik entegrasyon/Rules onayÄ± |

Bu alanlar tahminle doldurulmaz. Hukuki sÃ¼re/ÅŸart gibi gÃ¼ncel mevzuat iddialarÄ± yeniden resmÃ® kaynak incelemesi olmadan deÄŸiÅŸtirilemez. Mevcut yerel testler bu kapÄ±larÄ± geÃ§mez. Test verisiyle geliÅŸtirme ve Rules PR incelemesi devam edebilir; gerÃ§ek kullanÄ±cÄ± yayÄ±nÄ± bu tablo tamamlanmadan onaylanmÄ±ÅŸ sayÄ±lmaz.

## Gercek Hedef Gozlemi

7 Kasım 2026’da Firestore eur3 konumu ve email/parola sağlayıcısı doğrulandı; denetim belge içerikleri indirmedi ve ortak projeye veri yazmadı. Token/anahtar dışa aktarılmadı. Bu teknik gözlem yukarıdaki kurumsal kararları tamamlamaz; gerçek veri sorumlusu/saklama/aktarım onayı uydurulmaz.
