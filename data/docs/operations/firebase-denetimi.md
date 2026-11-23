# Ortak Firebase Denetimi

Kontrol zamanı: `2026-11-07T16:27:13.971Z`. Hedef devhub-34108 / 903757169979. Oturum Firebase CLI hesabından alındı; token/hesap anahtarı dışa aktarılmadı. Rapor [firebase-hedefi.json](../../validation/firebase-hedefi.json) içinde tarihli gözlemdir, gelecekteki durum garantisi değildir.

| Kontrol | Gozlem |
|---|---|
| Proje | DevHub, ACTIVE; ortak ID doğrulandı |
| Web uygulama SDK'sı | projectId, appId ve apiKey yerel firebase_options.dart ile eşleşti; anahtar değeri rapora konulmadı |
| Veritabanı | (default), eur3, Native / Standard |
| Koleksiyonlar | listCollectionIds tam yanıtında top-level liste boş |
| Yayımdaki Rules | Bütün istemci read/write işlemleri false; yayın zamanı 2026-10-23T16:15:56.987046Z |
| Birleşik indeks | 0 |
| Alan indeksleri | Özel override 0; varsayılan ASCENDING / DESCENDING / CONTAINS READY |
| Q01-Q04 | Gerçek runAggregationQuery istekleri HTTP 200; her biri count=0 |
| Auth | Email/parola açık; anonim sağlayıcı kapalı |
| Hosting | devhub-34108 varsayılan sitesi mevcut; bu denetim Hosting yayını yapmadı |
| App Check | Servis yapılandırma listesi boş; enforcement onayı çıkarılmadı |
| Koruma / geri dönüş | Delete protection ve PITR disabled gözlendi; işletim sorumlusu yayın planında değerlendirmeli |

## Kanitin Siniri

Gerçek sorgular Google OAuth / IAM üzerinden aggregate count olarak çalıştırıldı. Belge içeriği, kullanıcı profili veya başvuru mesajı indirilmedi. Bu dört sorgunun gerçek indeks yapılandırmasında kabul edildiğini kanıtlar. Firebase uygulama kullanıcısının aynı işlemleri yayımdaki Rules üzerinden yapabildiğini kanıtlamaz; yayımdaki deny-all politika bunu zaten kapatmaktadır.

Etkili izinler testIamPermissions ile salt okunur sınandı. IAM rolü verilmedi/değiştirilmedi; Owner/Editor olduğu varsayılmadı. Yeni proje, veritabanı, indeks, Auth kullanıcısı veya Rules yayını oluşturulmadı. İnceleme aracı yalnız izinli metadata GET ve üç okuma RPC'sine POST yapabilir; başka proje/host, belge içeriği okuma ve yazma rotaları testlerle reddedilir.

İlk denetimde indeks/field API'sinin pageSize/filter gereklilikleri görüldü; araç mevcut CLI'nın doğru listeleme biçimine uyarlandı ve son koşum başarılı sonuçları içerir. Ara hata çıktıları nihai kanıt sayılmaz.

Firestore'un eur3 konumu bir teknik bulgudur; tek başına KVKK uygunluk onayı veya bütün Firebase hizmetlerinin veri yerleşimi kararı değildir. [Kisisel Veri Kurallari](../../privacy/kisisel-veri-kurallari.md) açık kararları korur.

Kaynak API'ler: [Firestore indeksleri](https://firebase.google.com/docs/firestore/reference/rest/v1/projects.databases.collectionGroups.indexes/list), [Rules release](https://firebase.google.com/docs/reference/rules/rest/v1/projects.releases/get). Ham denetim raporu ve gözlenen Rules kaynağı dış teslimin kanitlar/ alanındadır; GitHub için ikinci aktif Rules kaynağı oluşturmaz.
