# Veri Alani Katki Talimatlari

1. Ã–nce README.md, contracts/veri-sozlesmesi.md ve docs/governance/calisma-kurallari.md okunur.
2. Aktif katkÄ± sÃ¼rÃ¼mÃ¼ 2.0.0'dÄ±r; 1.1.0 tarihsel arÅŸivdir. Kaynak kod, hedef tasarÄ±m, yerel kanÄ±t ve canlÄ± kabul ayrÄ± raporlanÄ±r.
3. Ortak Firebase hedefi devhub-34108'dir. Ä°nceleme onayÄ± olmadan Rules/indeks/Hosting daÄŸÄ±tÄ±lmaz. CI deploy iÃ§ermez.
4. KÃ¶k firebase.json iÃ§indeki FlutterFire yapÄ±landÄ±rmasÄ± korunur. Rules'Ä±n tek kaynaÄŸÄ± firestore/firestore.rules'tÄ±r; kÃ¶kte ikinci firestore.rules oluÅŸturulmaz.
5. Model ve servisler uygulama lib/ altÄ±nda kalÄ±r. Test iÃ§in geÃ§ici kaynak kopyalarÄ± yalnÄ±z Git dÄ±ÅŸÄ±ndaki reports/ altÄ±nda Ã¼retilebilir.
6. DeÄŸiÅŸiklik; model, servis, ÅŸema, Rules, sorgu, fixture ve testi birlikte ele alÄ±r. Yeni alan/izin/durum kararÄ± ADR ve sÃ¼rÃ¼m kaydÄ± olmadan deÄŸiÅŸtirilemez.
7. KatkÄ± branch/PR Ã¼zerinden incelenir; main'e doÄŸrudan push yoktur. PR/push iÅŸlemi aÃ§Ä±k kullanÄ±cÄ± talimatÄ± olmadan yapÄ±lmaz.
8. Belge adlarÄ± TÃ¼rkÃ§e ASCII lower-kebab-case, baÅŸlÄ±klar TÃ¼rkÃ§e ASCII; aÃ§Ä±klamalar TÃ¼rkÃ§e karakterli yazÄ±lÄ±r. Dart adlandÄ±rmasÄ± Effective Dart'a uyar.
9. GerÃ§ek kiÅŸisel veri fixture, log, rapor ve AI girdisine konulmaz. Hesap anahtarÄ±/token/servis hesabÄ± dosyasÄ± Git'e eklenmez.
10. Pinned feature testi, entegre main testi yerine gÃ¶sterilemez. Atlanan veya Ã§alÄ±ÅŸmayan test baÅŸarÄ±lÄ± sayÄ±lmaz.
