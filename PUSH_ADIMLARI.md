# DevHub – Repoya Push ve ilk yayın adımları

Bu ZIP, `DevHub/` klasörü içinde repo köküne kopyalanacak kaynak ağacını içerir. `.git` klasörü içermez; mevcut Git geçmişini silmez.

## 1. Temiz bir entegrasyon branch'i oluştur

Mevcut `PR #1` dalı `main` dalının iki commit gerisinde ve dallar ayrışmış durumda. `PR #2` ise farklı, güncel bir `main` tabanından ilerliyor. Bu nedenle bu bütünleşik çıktıyı eski PR dallarından birine doğrudan açmak yerine güncel `main` tabanından yeni bir branch'e al:

```bash
cd /path/to/your/DevHub

git status --short
# Çıktı boş değilse önce kendi değişikliklerini commit et veya güvenle stash et.

git switch main
git pull --ff-only origin main
git switch -c feat/phase-1-integrated
```

## 2. ZIP içeriğini repo köküne kopyala

ZIP'i aç. İçindeki `DevHub/` klasörünün içeriğini mevcut Git deposunun köküne kopyala. macOS/Linux örneği:

```bash
rsync -av --exclude='.git' /path/to/extracted/DevHub/ ./
```

`/path/to/extracted/DevHub/` kısmını kendi çıkardığın klasörün gerçek yolu ile değiştir. `.git` klasörünü kopyalama veya silme. Bu ZIP'te `.git` zaten bulunmaz.

Sonra değişiklikleri incele:

```bash
git status --short
git diff --check
```

Kök dizinde yalnızca tek üretim Firestore Rules kaynağı kalmalı: `data/firestore/firestore.rules`. Ayrı bir `firestore.rules` dosyası oluşturma.

## 3. Flutter uygulamasını yerelde doğrula

Gereken sürümler: Flutter 3.47.7 stable ve Dart 3.13.x.

```bash
flutter --version
flutter pub get
flutter analyze
flutter test
flutter build web --release
```

Flutter Web geliştirme sunucusu:

```bash
flutter run -d chrome
```

`flutter pub get` ile oluşan `pubspec.lock` dosyasını ekip kararı doğrultusunda Git'e ekle. Build çıktısı `build/` altında oluşur ve `.gitignore` tarafından dışlanır.

## 4. Veri sözleşmesi ve Firestore Emulator testleri

Node.js 24.x, npm ve Java 21+ gerekir. Repo kökünden:

```bash
cd data
node --version
npm ci --ignore-scripts
npm run validate
npm run verify
npm audit --audit-level=moderate
cd ..
```

`npm run verify` Flutter analyze/widget smoke, Dart model codec testleri, veri/config denetimi, Node birim testleri, Auth/Firestore Emulator Rules testleri ve bağımlılık audit'ini çalıştırır. Normal doğrulama `demo-devhub-mvp` Emulator projesini kullanır; ortak Firebase projesine test hesabı veya veri yazmaz. Chrome/Chromium gereklidir.

Tüm testler geçtiğinde ve kod gözden geçirildiğinde:

```bash
git add -A
git commit -m "feat: integrate DevHub phase one"
git push -u origin feat/phase-1-integrated
```

Ardından GitHub'da `main` hedefli bir Pull Request aç. PR #1 ve PR #2'nin sahipleri yeni PR ile kapsamın birleştirildiğini gördükten sonra eski PR'ları superseded olarak kapatabilir; önce onların yorumlarını ve kaybolmaması gereken değişikliklerini kontrol et.

## 5. Firebase Console yapılandırması

Ayrıntılar `FIREBASE_SETUP.md` içindedir. Özet:

1. Projenin `devhub-34108` olduğunu ve takımın erişimi bulunduğunu doğrula.
2. Authentication'da yalnızca Email/Password sağlayıcısını etkinleştir. OAuth ve Anonymous giriş bu ilk teslimde kapalıdır.
3. Authorized domains bölümünde `localhost`, `devhub-34108.firebaseapp.com` ve `devhub-34108.web.app` bulunduğunu doğrula.
4. `(default)` Firestore veritabanının mevcut olduğunu, Native mode ve `eur3` bölgesinde bulunduğunu doğrula. Mevcut veritabanını silip yeniden oluşturma.
5. Hosting varsayılan sitesi `devhub-34108.web.app` olduğunu doğrula.

Firebase Console'daki gerçek ayarlar 7 Kasım 2026 tarihli rapordan farklılaşmış olabilir; deploy öncesi güncel durum okunmalıdır.

## 6. Firebase CLI ve kontrollü deploy

Önce doğru hesabı ve projeyi seç:

```bash
./data/node_modules/.bin/firebase login
./data/node_modules/.bin/firebase projects:list
./data/node_modules/.bin/firebase use devhub-34108
```

Güncel uzak proje durumunu salt okunur incele:

```bash
cd data
npm run firebase:inspect
cd ..
```

Rules tek kaynaktan gelir: `data/firestore/firestore.rules`. Yerel Emulator testleri ve PR incelemesi başarılı olduktan, Firebase sorumlusu açıkça onay verdikten sonra yalnızca Rules yayınla:

```bash
./data/node_modules/.bin/firebase deploy --only firestore:rules
```

Web uygulamasını ayrı bir yayın olarak, `flutter build web --release` sonrasında ve Hosting kabul kontrolü tamamlanınca yayınla:

```bash
./data/node_modules/.bin/firebase deploy --only hosting
```

Rules ve Hosting'i ayrı ayrı yayınla. Bu ZIP'i push etmek için herhangi bir Firebase deploy işlemi gerekmez. Servis hesabı JSON'u, Admin SDK anahtarı veya özel anahtar Git'e ekleme.
