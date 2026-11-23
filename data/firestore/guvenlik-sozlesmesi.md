# Guvenlik Sozlesmesi

Tek uygulanabilir kaynak [firestore.rules](firestore.rules). Kök firebase.json ve yerel test config bu dosyayı kullanır. Kurallar inceleme/onay bekleyen katkıdır; ortak projeye yayınlanmadı.

## Yetki Matrisi

| Islem | Oturumsuz | Anonim Auth | Gercek hesap | Ek sart |
|---|---|---|---|---|
| users get/create/update | ret | kendi UID'si | kendi UID'si | izinli alan/tip; email token ile aynı |
| users list/delete | ret | ret | ret | bu MVP'de servis işlemi yok |
| projects get/list | ret | izin | izin | tüm alanlar bu Auth kitlesine görünür |
| projects create | ret | ret | izin | owner UID; ilk tek üye sahibi; sunucu zamanı |
| projects update | ret | ret | yalnız sahip | düzenlenebilir alanlar veya atomik kabul eki |
| projects delete | ret | ret | ret | bağlı belge yaşam döngüsü tasarlanmadan açılmaz |
| applications create | ret | ret | başvuran | açık canlı proje, kendi projesi/üyesi değil, sabit yol |
| applications get | ret | kendi tarafı | başvuran veya sahibi | olmayan belge yalnız kendi sabit anahtarıyla okunur |
| applications list | ret | kendi taraf filtresi | başvuran/sahip filtresi | Rules filtre değildir; sorgu UID koşulunu taşımalı |
| applications update | ret | ret | yalnız canlı proje sahibi | pending -> accepted/rejected; atomik değişmezler |
| applications delete | ret | ret | ret | yeniden başvuru/silme akışı kapsam dışı |
| diğer yollar | ret | ret | ret | varsayılan kapalı |

## Atomik Butunluk

Başvuru oluşturma yalnız create iznine dayanır. Aynı sabit belgeye ikinci set update olur ve başvurana update izni verilmez. Servisin ön kontrolü ve transaction'ı kullanıcı deneyimini destekler; güvence keyfî istemciler için de Rules tarafından uygulanır. Rejected sonrası silip tekrar create yapılamaz; istemci delete kapalıdır.

Kabulde başvurunun eski durumu pending olmalıdır. Yeni durum accepted olur ve yalnız status/updatedAt değişir. `getAfter(project)` mevcut üye listesine tam olarak ilgili UID'nin eklendiğini zorlar. Karşı tarafta proje güncellemesi `get(application)` pending ve `getAfter(application)` accepted geçişini zorlar. Üye listesi başa/ortaya yazılamaz, eskiler silinemez, fazladan üye eklenemez. Aynı transaction/batch dışında iki ardışık çağrı başarısız olur. Bu yaklaşım mevcut ProjectService batch/arrayUnion davranışıyla uyumludur.

Rejected karar üyelik sağlamaz. Bekleyen başvurunun sahibi kendi mesajını veya durumunu değiştiremez. Sahip de geçmiş kararını değiştiremez. Yarışan accept/reject işlemlerinden yalnız biri geçebilir. Bir projenin kapanması yeni başvuruyu engeller; mevcut pending başvurunun sahibi tarafından sonuçlandırılmasını bu sürüm engellemez.

## Veri Ve Yetki Sinirlari

Alan listeleri kapalıdır; bilinmeyen alan reddedilir. Proje sahibi/adı/oluşturma zamanı değişmez. Başvurunun kimlik, mesaj ve başlık kopyası değişmez. Sunucu timestamp ve tip kontrolleri gerçek nihai belge üzerinde uygulanır. Liste öğeleri sadece string olabilir; kontrol karakterleri ve aşırı uzun öğeler reddedilir. Büyük geçerli listeler ve kabul batch'i ayrı olumlu testlerle değerlendirme bütçesine karşı sınanır.

Rules Auth kimliğini güvenilir kabul eder; ad/mesaj doğruluğu veya e-posta sahipliğini ayrıca ispatlamaz. Admin SDK, servis hesabı ve Firebase Console/IAM işlemleri bu Rules'tan bağımsızdır. Gerçekten ayrıcalıklı hesapların erişimini sınırlandırmak ekip yöneticisinin sorumluluğudur. Bu paket IAM rolü vermedi, hesap açmadı, Auth sağlayıcısı veya veritabanı bölgesi değiştirmedi.

Teknik kaynaklar: [Rules koşulları ve getAfter](https://firebase.google.com/docs/firestore/security/rules-conditions), [Emulator ile test](https://firebase.google.com/docs/rules/unit-tests). 4 Kasım 2026 incelendi. Resmî ürün davranışı ile proje için seçilen yetki matrisi ayrı tutulur.
