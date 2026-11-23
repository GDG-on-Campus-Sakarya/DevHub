# Mevcut Veri Icin Gecis Kosullari

Bu teslim herhangi bir migration Ã§alÄ±ÅŸtÄ±rmaz. Ortak Firestore belgeleri ve eski yayÄ±mlanmÄ±ÅŸ Rules/indeks sÃ¼rÃ¼mÃ¼ uzaktan okunmadÄ±. Yeni kurallarÄ±n mevcut her belgeyle uyumlu olduÄŸu iddia edilmez.

Uzak envanterde alan/tip/ID/zaman farkÄ± bulunursa, yetkili kiÅŸi sentetikleÅŸtirilmiÅŸ fark raporu Ã§Ä±karÄ±r. Eski 1.1.0'daki revision/schemaVersion/flags alanlarÄ± veya eski Ã¶zel proje ID'leri varsa, hedef sÃ¶zleÅŸmeye dÃ¶nÃ¼ÅŸÃ¼m ayrÄ± deÄŸiÅŸiklik olarak planlanÄ±r. Veriler topluca silinmez; ilk Ã¶nce yedek, geri yÃ¼kleme kanÄ±tÄ± ve kullanÄ±cÄ± etkisi deÄŸerlendirilir.

Migration iÃ§in zorunlu girdiler: kaynak/hedef sÃ¶zleÅŸme, etkilenen belge sayÄ±larÄ±, dÃ¶nÃ¼ÅŸtÃ¼rme yÃ¶ntemi, create/update Ã§atÄ±ÅŸma politikasÄ±, dry-run, idempotency/yeniden baÅŸlatma, baÅŸarÄ±sÄ±zlÄ±k/geri alma ve yetkili hedef kaydÄ±dÄ±r. Auth hesabÄ± ile Firestore belgesi ayrÄ± kaynaklar olduÄŸundan biri silinince diÄŸerinin temizlendiÄŸi varsayÄ±lamaz.

1.1.0 arÅŸivindeki araÃ§lar referans olarak korunur. Eski ÅŸemaya baÄŸlÄ± doÄŸrulayÄ±cÄ±larÄ± yeni modele uyarlamadan veya ortak hedefe uygun yetki/plan olmadan Ã§alÄ±ÅŸtÄ±rmak YASAKTIR. MVP CI'si migration, seed veya restore zorunluluÄŸu eklemez.
