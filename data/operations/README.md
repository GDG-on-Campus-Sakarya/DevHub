# Veri Isletimi

Ortak hedef devhub-34108, veritabanı (default)/eur3. [Gercek Firebase Denetimi](../docs/operations/firebase-denetimi.md). Bu sürümün tek uzak aracı firebase-durumunu-incele.mjs salt okunurdur; normal verify veya CI bu aracı çalıştırmaz.

## Hesap Ve Inceleme

Kendi hesabınızla Firebase CLI girişi yapın. Windows'ta global firebase komutu bulunmuyorsa:

```powershell
& "C:\Program Files\nodejs\npx.cmd" --yes --package=firebase-tools@15.34.1 firebase login
```

Sonra uygulama deposunun data/ dizininde npm ci --ignore-scripts ve npm run firebase:inspect çalıştırın. Proje sabittir; yeni hedef açılmaz, ortak config değiştirilmez. Son rapor reports/firebase-son-durum.json ve zaman damgalı reports/firebase/ dizinindedir. Araç yeni API anahtarı/servis hesabı istemez; mevcut CLI oturumunu kullanır. Token/anahtar raporlanmaz.

İzinli rotalar operations/lib/firebase-okuma-siniri.mjs içindedir. API yanıtı veya IAM eksikse başarı uydurulmaz. Doküman payload okuması, create/update/delete/commit, Rules/Auth config değişikliği ve başka hedefe yönlendirme kapalıdır. Aggregate ve metadata çağrıları sağlayıcı okuma kotasına tabidir; periyodik otomasyon eklenmemiştir.

## Yayin Ve Gecis

[Teslim Ve Yayin](teslim-ve-yayin.md) onay, uygulama ve geri dönüş sırasını tanımlar. [Migration Kosullari](../migrations/README.md) korunur. Son denetimde top-level koleksiyon listesi boştu; bu gelecekte envanter/backup ihtiyacını kaldırmaz. Eski 1.1.0 işletim araçları tarihsel referanstır, yeni şemayla çalıştırıldığı iddia edilmez.
