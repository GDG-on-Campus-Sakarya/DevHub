# Ekip çalışma düzeni

- Koordinasyon / ana ekran: `lib/app.dart`, `lib/screens/home/`, `lib/widgets/`
- Kayıt / giriş / profil: `lib/screens/auth/`, `lib/screens/profile/`, `lib/services/auth_service.dart`
- Projeler: `lib/screens/projects/`, `lib/widgets/project_card.dart`
- Firebase / modeller / başvurular: `lib/models/`, `lib/services/`, `lib/screens/applications/`

Önerilen branch'ler: `feature/home`, `feature/auth`, `feature/projects`, `feature/firebase`.
`main` dalına doğrudan push yapmayın; Pull Request kullanın. `main.dart` ve `pubspec.yaml` gibi ortak dosyaları değiştirmeden önce haberleşin.

Firestore koleksiyon taslağı:
- `users/{userId}`
- `projects/{projectId}`
- `applications/{applicationId}`

Üretim öncesinde Firestore Security Rules yazılmalı ve test edilmelidir. Herkese açık yazma izni veren kurallar kullanılmamalıdır.
