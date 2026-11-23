# DevHub

DevHub, üniversite öğrencilerinin yazılım projelerini keşfetmesi, proje oluşturması ve ekip arkadaşı başvurularını yönetmesi için geliştirilmiş Flutter Web uygulamasıdır.

## İlk aşama kapsamı

- Firebase Authentication: e-posta/şifre ile kayıt, giriş, çıkış ve şifre sıfırlama
- Firestore kullanıcı profili: ad, bölüm, kısa biyografi, yetenekler ve GitHub bağlantısı
- Proje oluşturma, açık projeleri listeleme, arama, detay ve düzenleme
- Projeye başvuru gönderme; kendi başvurularının durumunu görme
- Proje sahibinin gelen başvuruyu kabul etmesi veya reddetmesi
- Firestore Security Rules, sözleşme/fixture doğrulaması ve Emulator test altyapısı

Sohbet, AI tabanlı eşleştirme, push bildirimleri ve sosyal/anonim giriş sonraki aşamalara bırakılmıştır.

## Başlangıç

```bash
flutter pub get
flutter run -d chrome
```

Firebase Console, Rules ve Hosting ayarları için [FIREBASE_SETUP.md](FIREBASE_SETUP.md); mevcut Git deposuna güvenli biçimde kopyalama, test ve push adımları için [PUSH_ADIMLARI.md](PUSH_ADIMLARI.md) dosyasını izleyin. Veri sözleşmeleri ve güvenlik/test mimarisi için [data/README.md](data/README.md) dosyasına bakın.

## Test

```bash
flutter analyze
flutter test
cd data
npm ci --ignore-scripts
npm run validate
npm run verify
```

Tam `npm run verify` Node 24.x, Java 21+, Flutter 3.47.7 ve Chrome gerektirir; ortak Firebase'e deploy yapmaz.

## Katkı düzeni

`main` dalına doğrudan push yerine feature branch ve Pull Request kullanın. Dosya sahipliği ve ekip akışı [docs/TEAM_WORKFLOW.md](docs/TEAM_WORKFLOW.md) içindedir.
