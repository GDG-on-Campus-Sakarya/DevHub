# Teslim Ve Yayin Plani

## Incelemeye Verilecekler

GitHub kaynak ZIP'i; data/ modülü, mevcut FlutterFire nesnesini koruyan kök firebase.json, analysis_options.yaml dışlama ekleri, beş mevcut lib/ model/servis dosyasının kaynak commit'leriyle aynı içerikleri, CI ve .firebaserc referansını içerir. Üretim model/servis kaynağı lib/ içinde tektir. Ayrı branch/PR üzerinden veri sorumlusu, model/servis sahipleri ve yayın yetkilisi inceler.

Bu ZIP, ekip main'ine push edilmemiş yerel bütünleşik ilk aşama çalışma ağacıdır. Mevcut GitHub PR başları teslim notlarında sabitlenmiştir; merge/push işlemi kullanıcı tarafından yapılır. Uzak main'e merge/push yapılmadı. Ekip dalları daha önce birleştirilmişse aynı dosyaları yeniden eklemek yerine güncel içerik farkını inceleyin. Canan feature dalındaki eski kök firestore.rules kaldırılmalı; tek kaynak data/firestore/firestore.rules olmalıdır. Kök FlutterFire nesnesi ve başka ekip ayarları korunur.

## Kabul Olcutleri

1. normal npm run verify PASS; atlanan/başarısız test yok; kaynak hash'i sabit.
2. Salt okunur Firebase incelemesi doğru proje, SDK, veritabanı ve indeks durumunu doğrular.
3. Rules değişikliği PR'da yetkili incelemesinden geçmiş olmalıdır. CLI erişimi veya yerel test başarıları inceleme onayı değildir.
4. Gerçek kullanıcı açılışının kurumsal kişisel veri kararları, destek/saklama/geri dönüş sorumluları tamamlanır. UI akışı diğer ekiplerle ayrıca doğrulanır.

## Onaydan Sonraki Yetkili Uygulama

Önce son uzak indeks/alan/Rules ve veri envanteri tekrar alınır. Yeni belge varsa dönüşüm/backup kararı değerlendirilir. Güncel yayınlanan Rules kaynağı ve release kimliği geri dönüş kaydına alınır. Onay kaydı ve hedef kimliği görünür tutularak yalnız yetkili kişi uygulama kökünde şu hedefli komutu kullanabilir:

```bash
npx --yes --package=firebase-tools@15.34.1 firebase deploy --only "firestore:rules,firestore:indexes" --project devhub-34108
```

Bu komut bu teslim hazırlanırken **çalıştırılmadı**. --force veya genel firebase deploy kullanılmaz. Hosting/Auth/IAM değişiklikleri bu veri yayınına dahil edilmez. CI deploy veya secret içermez.

Yayın sonrası doğru Rules release/hash ve indeks durumu tekrar okunur; yetkili test ortamı/hesaplarıyla gerçek uygulama erişimi sınanır. Denetim sorgusunun IAM üzerinden geçmesi bu istemci testi yerine konulmaz. Deneme hesapları/verileri plansız gerçek kullanıcı veritabanına eklenmez.

## Geri Donus

Önceki gözlenen Rules deny-all'dır. Buna dönmek veri silmez fakat istemci işlemlerini durdurur; etkisi yayın sorumlusunca değerlendirilir. Yeni şemaya yazılmış veriler eski kod/Rules'a dönmekle eski hâline gelmez. İndeks silme veya restore otomatik rollback değildir. Sorun varsa güvenli erişim sınırı korunarak yetkili düzeltme/geri dönüş kaydı tutulur. Eski snapshot/restore aracı onaysız ortak hedefte çalıştırılmaz.
