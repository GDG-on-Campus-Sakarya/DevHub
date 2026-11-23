# DevHub – Firebase ve ilk aşama kurulum rehberi

Bu sürümün hedefi `devhub-34108` Firebase projesidir. Mevcut uygulama yalnızca Flutter Web yapılandırması içerir. `lib/firebase_options.dart` içindeki Firebase Web ayarları istemci yapılandırmasıdır; servis hesabı veya Admin SDK anahtarı değildir. Bu dosya takımın aynı Firebase projesiyle çalışabilmesi için Git'te tutulur.

## 1. Firebase Console kontrolü

1. Firebase Console'da `devhub-34108` projesini açın ve takım üyelerinin doğru projeye eriştiğini doğrulayın. Yanlışlıkla yeni proje oluşturmayın.
2. **Authentication → Sign-in method** bölümünde **Email/Password** sağlayıcısını etkinleştirin. Google, GitHub, Microsoft, LinkedIn ve Anonymous ilk aşamada uygulama arayüzünde kapalıdır; bunları Console'da ayrıca yapılandırmadan açmayın.
3. **Authentication → Settings → Authorized domains** altında en az `localhost`, `devhub-34108.firebaseapp.com` ve `devhub-34108.web.app` olmasını doğrulayın. Yeni özel domain eklerseniz onu da ekleyin.
4. **Firestore Database** bölümünde `(default)` veritabanının Native mode ve `eur3` bölgesinde olduğunu kontrol edin. 7 Kasım 2026 tarihli denetim bu durumu doğrulamıştı; bu tarihli kayıt güncel durum garantisi değildir. Mevcut veritabanını silmeyin veya başka bölgede tekrar oluşturmayın.
5. **Hosting** bölümünde `devhub-34108.web.app` varsayılan sitesinin erişilebilir olduğunu doğrulayın. `firebase.json` artık `build/web` klasörünü ve Flutter Web SPA yönlendirmesini tanımlar.

## 2. Yerel ortam

Gerekenler: Flutter 3.47.7 stable, Dart 3.13.x, Node.js 24.x, npm ve Java 21+.

```bash
flutter --version
node --version
java -version
flutter pub get
cd data
npm ci --ignore-scripts
npm run validate
```

Tam yerel veri doğrulaması ve Emulator testleri için `data/README.md` ve `data/tests/README.md` dosyalarını izleyin. `npm run verify` Node 24.x, Java 21+, Flutter 3.47.7 ve Chrome gerektirir. Verify yalnızca `demo-devhub-mvp` Emulator projesini kullanır; ortak Firebase'e test verisi yazmaz.

## 3. Firebase CLI ile ortak projeyi seçme

Firebase CLI, `data` paketinin `firebase-tools` bağımlılığından kullanılabilir. Terminalde repo köküne dönün:

```bash
cd ..
./data/node_modules/.bin/firebase login
./data/node_modules/.bin/firebase projects:list
./data/node_modules/.bin/firebase use devhub-34108
```

macOS/Linux dışındaki kabuklarda `data/node_modules/.bin/firebase` yerine `data/node_modules/.bin/firebase.cmd` kullanın. `.firebaserc` varsayılan alias'ı zaten `devhub-34108` olarak tanımlar; `projects:list` ve `firebase use` çıktısını kontrol etmeden deploy etmeyin.

## 4. Firestore Rules – dikkatli yayın

Üretim Rules kaynağı **tek bir dosyadır**: `data/firestore/firestore.rules`. Kök `firebase.json` bu dosyayı `firestore.rules` olarak işaret eder. Emulator yapılandırması `data/firebase.json` içinden aynı kaynağa gider. İkinci bir kök `firestore.rules` dosyası eklemeyin. Özel composite index listesi şu an bilerek boştur; kullanılan sorgular tek alan eşitlik sorgularıdır.

7 Kasım 2026 tarihli salt okunur Firebase denetiminde yayımdaki Rules `DENY_ALL` idi. Bu kayıt eski tarihli olduğundan önce Console veya `npm run firebase:inspect` ile güncel durumu kontrol edin. Denetim komutu salt okunurdur ve uygulama kullanıcısının Rules yetkisini test etmez.

Kurallar PR incelemesinden geçip proje sorumlusu açıkça onayladıktan sonra, yalnızca Firestore Rules yayınlamak için repo kökünden:

```bash
./data/node_modules/.bin/firebase deploy --only firestore:rules
```

Bu adım gerçek uygulama kullanıcılarının profil, proje ve başvuru erişimini etkiler. Yetkili ekip onayı olmadan çalıştırmayın. İlk testte ortak projeye örnek kullanıcı veya belge eklemeyin; önce yerel Emulator testleri çalıştırılmalıdır.

## 5. Web'i yerelde çalıştırma

```bash
flutter pub get
flutter run -d chrome
```

Kayıt, Firestore'da `users/{uid}` profil belgesini oluşturur. Proje akışları `projects/{projectId}` ve `applications/{projectId}_{applicantUid}` koleksiyonlarını kullanır. İlk aşamada sohbet, AI eşleştirme, push bildirimleri ve anonim kullanıcı katkısı yoktur.

## 6. Hosting yayınlama

Önce `flutter build web --release` ile çıktıyı üretin. Hosting domain/site ayarını Console'da doğruladıktan ve web kabul testini yaptıktan sonra:

```bash
./data/node_modules/.bin/firebase deploy --only hosting
```

Rules ve Hosting'i tek komutta deploy etmek yerine ilk aşamada ayrı ayrı yayınlayın. Yayın öncesi geri dönüş için mevcut Rules/Hosting sürümünü Console'da not edin.

## 7. Bu teslimde özellikle yapılmayanlar

- Gerçek Firebase Rules, Authentication, Hosting veya IAM ayarlarına dokunulmadı.
- Firestore'a gerçek kullanıcı veya proje yazılmadı; deploy yapılmadı.
- App Check enforcement, PITR ve delete protection ayarları otomatik değiştirilmedi.
- Mobil platformlar için Firebase seçenekleri üretilmedi. Android/iOS desteği eklenecekse `flutterfire configure --project=devhub-34108` ile platform uygulamalarını kaydedin ve yeni seçenekleri commit edin.
