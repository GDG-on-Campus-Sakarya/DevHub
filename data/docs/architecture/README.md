# Veri Mimarisi Girisi

SÃ¼rÃ¼m 2.0.0. [Ana Giris](../../README.md).

```text
Uygulama ekranlari
  -> lib/services/FirestoreService ve ProjectService
  -> lib/models/AppUser, Project, ProjectApplication codec'leri
  -> Firebase Auth kimligi + Firestore istemci SDK
  -> data/firestore/firestore.rules
  -> users / projects / applications
```

Rules uygulama servisinden baÄŸÄ±msÄ±z zorlayÄ±cÄ± sÄ±nÄ±rdÄ±r. Bir dÃ¼ÄŸmeyi gizlemek yetkilendirme deÄŸildir. Admin/IAM eriÅŸimi Rules'Ä± aÅŸar; bu nedenle bu paket Admin hesabÄ± veya uzak veri iÅŸletim yetkisi daÄŸÄ±tmaz.

## Fiziksel Yerlesim

| Konum | Sorumluluk |
|---|---|
| contracts/ | Alanlar, JSON Schema codec sÃ¶zleÅŸmesi ve servis yazma farklarÄ± |
| firestore/ | Tek Rules kaynaÄŸÄ±, CLI indeks manifesti, gerÃ§ek sorgu envanteri |
| fixtures/ | GerÃ§ek Dart toMap testinden Ã¼retilen sentetik haritalar |
| tests/unit/ | SÃ¶zleÅŸme doÄŸrulayÄ±cÄ±sÄ±nÄ±n olumlu/olumsuz senaryolarÄ± |
| tests/emulator/ | GerÃ§ek yerel Firestore Rules ve atomik yazma testleri |
| tests/flutter/ | Mevcut Dart modellerinin codec testleri; model kopyasÄ± iÃ§ermez |
| validation/ | Kaynak commit/hash kaydÄ±, sorgu ve paket uyumu denetimi |
| tools/ | Test koÅŸucularÄ± ve makine okunur kanÄ±t Ã¼retimi |
| operations/ | Uzak hedefe geÃ§iÅŸ ve iÅŸletim sÄ±nÄ±rlarÄ± |
| migrations/ | Mevcut veriye geÃ§iÅŸin koÅŸullarÄ±; otomatik migration yok |
| privacy/ | KiÅŸisel veri kontrolleri ve aÃ§Ä±k kararlar |
| docs/architecture/ | YalnÄ±z mimari giriÅŸ ve ADR |
| docs/governance/ | BaÄŸlayÄ±cÄ± katkÄ± ve teslim kurallarÄ± |
| docs/operations/ | GeliÅŸtirici rehberi |

Model veya servis Ã¼retim kopyalarÄ± `data/` altÄ±nda tutulmaz. `reports/`, node_modules ve ham tasarÄ±m Ã§Ä±ktÄ±larÄ± Git dÄ±ÅŸÄ±dÄ±r. KÃ¶k `firebase.json`, FlutterFire nesnesini korur ve data/firestore kaynaklarÄ±na iÅŸaret eder. `data/firebase.json` yalnÄ±z loopback/demo Emulator koÅŸumudur; ikinci bir Rules dosyasÄ± deÄŸildir.

## Uygulama Akisi

1. Auth katmanÄ± kimliÄŸi saÄŸlar. Misafir Auth hesabÄ± proje okuyabilir; proje oluÅŸturamaz, gÃ¼ncelleyemez, baÅŸvuramaz veya karar veremez.
2. Profil sahibi, users/UID belgesini okur ve merge ile kaydeder. Eksik profil proje oluÅŸturmayÄ± engelleyen yeni bir ÅŸart deÄŸildir.
3. ProjectService aÃ§Ä±k projeleri veya sahibin projelerini eÅŸitlik sorgusuyla dinler. SÄ±ralama mevcut kodda istemcidedir.
4. Proje oluÅŸturulurken ownerId Auth UID, ilk memberIds yalnÄ±z sahibin UID'sidir. Servis zamanlarÄ± serverTimestamp ile ekler.
5. BaÅŸvuru sabit `projectId_applicantId` belgesine transaction ile oluÅŸturulur. Rules canlÄ± projeyi, sahipliÄŸi, Ã¼yeliÄŸi ve aÃ§Ä±klÄ±k durumunu yeniden kontrol eder.
6. BaÅŸvuran kendi baÅŸvurusunu; proje sahibi gelen baÅŸvurularÄ± UID filtresiyle dinler. Serbest baÅŸvuru listeleme reddedilir.
7. Sahip pending baÅŸvuruyu rejected yapabilir. Accepted iÃ§in aynÄ± batch iÃ§inde yalnÄ±z ilgili baÅŸvuran, mevcut Ã¼ye listesinin sonuna eklenir. Her iki belge karÅŸÄ±lÄ±klÄ± `getAfter` kontrolÃ¼nden geÃ§er.
8. Terminal karar deÄŸiÅŸtirilemez. Yeniden baÅŸvuru, Ã¼ye Ã§Ä±karma, proje silme ve sahip devri iÃ§in bu sÃ¼rÃ¼mde istemci izni yoktur.

Kararlar ve eski sÃ¼rÃ¼mden farklar [ADR sicilindedir](mimari-kararlar.md). ArÅŸivdeki 1.1.0 Ã¼rÃ¼n Ã¶nerileri, mevcut MVP'nin onaylanmÄ±ÅŸ Ã¶zellikleri olarak gÃ¶sterilmez.

## Gercek Hedef Ve Entegrasyon

7 Kasım 2026 tarihli [Firebase Denetimi](../operations/firebase-denetimi.md) ortak hedefi doğrular. Beş lib/ kaynağı yerel branch’te entegredir; tam verify gerçek servisleri Chrome/Auth/Firestore Emulator ile de sınar. Uzak main merge ve Rules yayını ayrı ekip onayıdır.
