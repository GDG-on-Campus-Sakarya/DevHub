# Indeks Ve Sorgu Uyumu

Esas manifest [firestore.indexes.json](firestore.indexes.json), dört gerçek çağrı [sorgu-envanteri.json](sorgu-envanteri.json). 7 Kasım 2026 gerçek hedef kontrolü [Hedef Kaydi](../validation/firebase-hedefi.json) içindedir.

| Sorgu | Sunucu filtresi | Siralama | Gercek hedef |
|---|---|---|---|
| streamOpenProjects | projects.status == open | istemcide createdAt | aggregate HTTP 200, count 0 |
| streamMyProjects | projects.ownerId == UID | istemcide createdAt | sentetik eşleşmeyen UID ile HTTP 200, count 0 |
| streamMyApplications | applications.applicantId == UID | istemcide createdAt | sentetik eşleşmeyen UID ile HTTP 200, count 0 |
| streamIncomingApplications | applications.ownerId == UID | istemcide createdAt | sentetik eşleşmeyen UID ile HTTP 200, count 0 |

Incoming projectId süzmesi istemcidedir; ikinci sunucu filtresi veya server orderBy sanılmaz. Ortak hedefte özel composite indeks yok, custom field override yok; varsayılan tek alan ASCENDING/DESCENDING/CONTAINS indeksleri READY. Aktif boş manifest bu gözlenen durum ve mevcut servis çağrılarıyla uyumludur. Eski 35 indeks/374 varsayımsal kombinasyon bu kodun gereği değildir.

Gerçek sorgular OAuth IAM ile count olarak çalıştırıldı; müşteri belgesi indirilmedi. Bu; sorgu/indeks biçimi kanıtıdır, istemci Security Rules testi veya performans/kota testi değildir. Yetki testleri Emulator'da ayrıca yapılır. Ortak hedefteki deny-all Rules hâlen istemci işlemlerini kapatır.

Yeni where/orderBy/cursor/collectionGroup eklenirse servis, envanter, manifest ve test birlikte güncellenir. İstemci sıralaması mevcut davranıştır; büyük veri ölçek çözümü sayılmaz. Yayın onayından hemen önce uzak indeksler tekrar incelenir; boş manifest gerekçesiyle sonradan eklenmiş ekip indeksleri silinmez, --force kullanılmaz.
