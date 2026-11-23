# Ortak Veri Sozlesmesi

Sürüm 2.0.0. Alanlar lowerCamelCase, koleksiyonlar users/projects/applications. Belge ID'si toMap içine yazılmaz. Koleksiyon dışı yazma kapalıdır. [Kaynak sicili](../validation/kaynaklar.json) gerçek model ve servis commit'lerini gösterir.

## Codec Ile Firestore Yazmasinin Ayrimi

Üç JSON Schema gerçek `toMap()` çıktısını doğrular; bu bir Firestore sunucu şeması değildir. Users haritası doğrudan merge yazılır. Project/Application codec'leri zamanları yazmaz; servis `createdAt` ve `updatedAt` alanlarını serverTimestamp ile ekler. Rules, Firestore'a gelen nihai belge üzerinde iki zaman alanını zorunlu tutar. JSON fixture'daki normal metin tarihi timestamp yerine geçmez. Tipli zaman okuması Dart Timestamp testleriyle ayrıca sınanır.

Modelin yapıcısının nesne oluşturabilmesi, o nesnenin her zaman geçerli yazma olduğu anlamına gelmez. Örneğin boş mesajlı ProjectApplication görüntüleme varsayılanı olabilir; yeni başvuruda mesaj zorunludur. Eksik/tarihsel belgelerin codec'de varsayılana düşmesi migration yapıldığı anlamına gelmez.

String alan sınırları `x-codeUnits` ile Dart String.length / JavaScript UTF-16 / Rules size ölçüsünü eşler. Etiket listelerindeki öğe sınırı JSON Schema maxLength ve RE2 ile **Unicode kod noktası** olarak 200'dür; emoji testleri bu farkı açıkça doğrular.

ProjectService başlık, açıklama ve başvuru mesajını trim ederek yazar. Şema ve Rules bu alanlarda başta/sonda boşluk bulunmamasını da zorlar; yalnız boşluktan oluşan başlık/açıklama/mesaj geçmez. Profil adını veya isteğe bağlı boş profil alanlarını bununla karıştırmayın.

## Users Ve AppUser

Yol `users/{auth.uid}`. Okuma/yazma yalnız sahip; list/delete kapalı.

| Alan | Tip / Sinir | Yazma |
|---|---|---|
| name | string, 0..100 UTF-16 | toMap daima yazar |
| skills | string listesi, 0..50 öğe | toMap daima yazar |
| email | string, 0..320 UTF-16 | yalnız modelde null değilse; Auth token email ile aynı |
| bio | string, 0..1000 UTF-16 | isteğe bağlı; boş string kabul |
| department | string, 0..200 UTF-16 | isteğe bağlı; boş string kabul |
| githubUrl | string, 0..300 UTF-16 | isteğe bağlı; boş string kabul |

İsteğe bağlı alanlar null olarak yazılmaz; toMap bunları atlar. Merge mevcut alanı silmez. copyWith null ile alanı temizlemez. Güncel UI boş string ile temizler. email Firebase Auth tarafından doğrulanmış e-posta iddiası değildir; yalnız oturum token'ındaki değerle eşlenir. Token güncellemesi/sağlayıcı değişimi sonrasında eski email ile yapılan profil yazması reddedilebilir; Auth sorumlusu taze kullanıcı verisini kullanmalıdır.

name için boş değer codec/feature Rules uyumu nedeniyle kabul edilir; kayıt/profil formu kendi zorunluluğunu uygular. Yeni timestamp/university/year/interests/revision zorunluluğu eklenmez. Şema [users.schema.json](users.schema.json).

## Projects Ve Project

Yol `projects/{projectId}`. Yeni ID mevcut Firestore add çağrısına uygun `[A-Za-z0-9]{20}`. Auth oturumları okur; yalnız gerçek hesap sahibi oluşturur/günceller.

| Alan | Tip / Sinir | Degisim |
|---|---|---|
| title | string, 3..100 UTF-16 | sahip düzenler |
| description | string, 10..2000 UTF-16 | sahip düzenler |
| ownerId | string, 1..128 | oluştururken Auth UID; değişmez |
| ownerName | string, 0..200 UTF-16 | mevcut servisin görünen ad kopyası; değişmez |
| technologies | etiket listesi, 0..30 | sahip düzenler; Flutter/C# gibi gösterim değeri |
| neededRoles | etiket listesi, 0..30 | sahip düzenler; Türkçe gösterim değeri |
| status | open / closed | sahip düzenler |
| memberIds | benzersiz UID listesi | başlangıçta yalnız sahip; kabul ile bir UID eklenir |
| createdAt | Firestore Timestamp | oluştururken sunucu zamanı; değişmez |
| updatedAt | Firestore Timestamp | her yazmada sunucu zamanı; createdAt'tan eski olamaz |

Tüm alanlar nihai Firestore belgesinde bulunur. İlk sekiz alan codec çıktısıdır; son iki alan servis tarafından eklenir. Ekip üye sayısı için eski keyfi 50 sınırı zorunlu tutulmaz; Firestore belge/batch sınırları yine geçerlidir. Üye listesi Rules'da her update'te baştan keyfi değerlerle yeniden kurulamaz; yaratma ve atomik ekleme değişmezleriyle korunur. Admin'in geçersiz belge yazması bu garantinin dışındadır.

Şema [projects.schema.json](projects.schema.json). Proje silme servisi gözlenmediğinden istemci silme izni verilmez; bağlı başvurular için plansız orphan üretilmez.

## Applications Ve ProjectApplication

Yol `applications/{projectId}_{applicantId}`. Proje ID'sinde alt çizgi yoktur; UID alt çizgi içerebilir. Aynı proje/UID için tek belge vardır.

| Alan | Tip / Sinir | Kaynak |
|---|---|---|
| projectId | 20 alfanümerik karakter | gerçek proje yolu |
| applicantId | UID string, 1..128 | Auth UID |
| ownerId | UID string, 1..128 | canlı proje sahibi |
| projectTitle | string, 3..100 UTF-16 | başvuru anındaki proje başlığı |
| applicantName | string, 0..200 UTF-16 | mevcut Auth görünen ad kopyası |
| message | string, 1..500 UTF-16 | başvuranın mesajı |
| status | pending / accepted / rejected | pending oluşturulur, sahip tek karar verir |
| createdAt | Firestore Timestamp | servis sunucu zamanı |
| updatedAt | Firestore Timestamp | servis sunucu zamanı |

İlk yedi alan codec çıktısıdır. Tüm alanlar nihai belgede zorunludur. Sadece status ve updatedAt karar sırasında değişebilir. projectTitle bir snapshot'tır; proje yeniden adlandırılınca geçmiş başvurular topluca değiştirilmez. Yeni başvuruda eski başlıkla gelen stale istemci reddedilir ve güncel proje okunmalıdır.

Durum geçişleri: yok -> pending -> accepted veya yok -> pending -> rejected. Terminal durum geri alınmaz. rejected sonrasında yeniden başvuru bu MVP'de yoktur. Başvuru silme/mesaj düzenleme yoktur. decidedAt/decidedBy/revision zorunlu alanı eklenmez; karar zamanına ilişkin mevcut veri updatedAt'tır. Başvuruya henüz karar verilmemişken updatedAt oluşturma zamanıdır.

Şema [applications.schema.json](applications.schema.json). Atomik kabulün karşılıklı kontrolü [Guvenlik Sozlesmesi](../firestore/guvenlik-sozlesmesi.md) içindedir.

## Servis Imzalari

Mevcut FirestoreService: `streamUserProfile(uid)`, `getUserProfile(uid)`, `saveUserProfile(AppUser)`.

Mevcut ProjectService: `streamOpenProjects()`, `streamMyProjects()`, `streamProject(projectId)`, `createProject(...)`, `updateProject(Project)`, `streamMyApplicationFor(projectId)`, `applyToProject(Project, message)`, `streamMyApplications()`, `streamIncomingApplications({projectId})`, `decideApplication(ProjectApplication, {accept})`.

Bu katkı bu imzaları Result/Page/cursor API'sine dönüştürmez. Kesintisiz pagination, server-side arama, rol/teknoloji filtreleri ve tarih sıralamalı sunucu sorguları mevcut kodun dışında kalır. İndeks ve ölçek kararı ilgili servis değiştiğinde ele alınır.
