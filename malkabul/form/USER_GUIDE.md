# Mal Kabul Seri Giriş Ekranı Kullanım Kılavuzu

Bu doküman, `add_malkabul_serials.cfm` sayfasını kullanan depo ve mal kabul personeli için hazırlanmıştır. Aşağıdaki adımlar barkod seçimi, seri numarası girişi ve kaydetme işlemlerinin tamamını kapsar.

## 1. Hazırlık
- Barkod okuyucunuzun klavye modu (keyboard wedge) ile çalıştığından emin olun.
- İnternet tarayıcınızda açılan sayfayı kapatmadan önce tüm seri numaralarını tamamlayın; aksi durumda yaptığınız girişler kaybolur.
- Seri numarasını manuel girecekseniz, numarayı eksiksiz kopyalayacak şekilde hazır bulundurun.

## 2. Barkod Türü Seçimi
Sayfa açılır açılmaz bir seçenek kutusu görüntülenir. Okutacağınız barkod yapısına göre aşağıdakilerden birini tıklayın:
1. **Dönmez Barkod** – Klasik Dönmez formatı (`XXXXXX-X-X-TARİH-SERİ`).
2. **Dönmez Yeni Barkod** – Yeni Dönmez formatı (ürün bilgisi iki parçadan oluşur).
3. **Diğer Barkodlar** – Alt çizgi (`_`) ile ayrılmış ETA kodları (`ETA_SERI_URETIM_PAKETLEME`).

Seçimi yaptıktan sonra ekranın sağ üstünde kısa süreli "Barkod türü seçildi" bildirimi görünecek ve seri girişi alanına odak alınacaktır.

## 3. Seri Numarası Okutma / Girme
1. **Seri Numarası** alanına barkodu okutun veya manuel yazın.
2. Giriş tamamlandığında **Enter** tuşuna basın.
3. Sistem barkodu doğrular ve şu kontrolleri sırasıyla yapar:
   - Barkod formatı seçtiğiniz türe uygun mu?
   - Seri numarası sistemde daha önce kayıtlı mı?
   - Barkoddaki ürün kodu listede bulunan satırlardan biriyle eşleşiyor mu?
   - Aynı seri numarası bu oturumda daha önce girildi mi?
4. Tüm kontroller başarılıysa seri ilgili ürün satırının altına eklenir ve "Yeni eklendi" etiketiyle yeşil renkte görünür.

## 4. Ürün Satırlarını Görüntüleme
- Ürün başlığının bulunduğu satıra tıklayarak seri listelerini açıp kapatabilirsiniz.
- Başlık satırındaki **Seri / Okunan** göstergesi, mevcut seri sayısını ve durum rengini (eksik, tamam, fazla) gösterir.

## 5. Kaydetme İşlemi
1. Tüm seri numaralarını girdikten sonra sayfanın altındaki **Kaydet ve Tamamla** butonuna tıklayın (veya `Ctrl + S`).
2. Sistem yeni seri numarası eklenmediğini tespit ederse onay sorar; emin değilseniz **İptal** edip kontrol edin.
3. Kaydetme süresince ekranda "Kaydediliyor" uyarısı ve dönen ikon görünecektir. İşlem bitene kadar sayfayı kapatmayın.

## 6. Hızlı Kısayollar
- **Ctrl + S** → Kaydetme formunu gönderir.
- **ESC** → Odak tekrar seri numarası giriş alanına taşınır.

## 7. Sık Karşılaşılan Uyarılar
| Mesaj | Anlamı | Yapılması Gereken |
| --- | --- | --- |
| "Seri numarası boş olamaz" | Enter'a basmadan önce alan boş bırakıldı. | Barkodu tekrar okutun veya numarayı yazın. |
| "Önce barkod türünü seçmelisiniz" | Barkod türü seçilmeden Enter'a basıldı. | Sayfayı yenileyip barkod türünü seçin. |
| "Seri numarası sistemde mevcut" | Numara daha önce kayıt altına alınmış. | Seri numarasını doğrulayın, hata yoksa kayıtlı olduğunu kabul edin. |
| "Bu ETA koduna ait ürün bulunamadı" | Barkoddaki ürün kodu listede yok. | Yanlış barkod seçtiyseniz doğru ürünü seçin; sorun devam ederse amirinize bildirin. |
| "Bu seri numarası daha önce girilmiş" | Aynı oturumda aynı numarayı tekrar eklemeye çalıştınız. | Listeyi kontrol edin, gerekirse yanlış satırı silmek için sayfayı yenileyin ve yeniden başlayın. |
| "Girilen seri sayısı beklenen miktarı aştı" | Seri adedi, sevkiyat miktarını geçti. | Girdiğiniz listeleri kontrol edin ve fazla olanları çıkarmak için sayfayı yenileyin. |

## 8. Yanlış Girişleri Düzeltme
- Sayfada mevcut seriyi silme butonu bulunmaz. Yanlış seri girdiyseniz **sayfayı yenileyin** ve baştan girin.
- Kayıt yapılmadığı sürece tüm yeni seri girişleri sadece bu ekranda tutulur.

## 9. Destek
- Teknik sorun yaşarsanız IT ekibiyle iletişime geçmeden önce tarayıcıyı yenileyip işlemi tekrar deneyin.
- Hata mesajı devam ediyorsa ekrandaki uyarıyı not alın (veya ekran görüntüsü alın) ve destek talebinizde paylaşın.

> **Not:** Bu kılavuz yalnızca kullanıcı işlemlerini anlatır. Teknik ayrıntılar için aynı klasördeki `README.md` dosyasına başvurabilirsiniz.
