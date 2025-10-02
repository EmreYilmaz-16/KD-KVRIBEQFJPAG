# `add_malkabul_serials.cfm`

Bu belge, `add_malkabul_serials.cfm` sayfasının Mal Kabul sürecindeki seri numarası yönetimini nasıl ele aldığını özetler.

## Genel Bakış
- Amaç: Sevkiyat satırları için barkod okuma veya manuel girişle seri numarası toplamak, doğrulamak ve kayda hazır hale getirmek.
- Teknolojiler: ColdFusion (`cf_box`, `cf_grid_list`), CFML sorguları, jQuery, Fetch API, Font Awesome, şirket içi `BarcodeManager` sınıfı.
- Giriş noktası: Sayfa yüklendiğinde kullanıcıdan barkod tipi seçmesini isteyen bir modal açılır. Devamında seri numarası girişi için tek bir input alanı ve satırlara göre gruplanmış bir seri listesi yer alır.

## Verinin Hazırlanması
- **`getPaperData` sorgusu:** İlgili sevkiyatın (`SHIP`) temel bilgilerini JSON olarak hazırlar ve kaydetme esnasında sunucuya gönderilecek `paperData` değerini üretir.
- **`getDespatchRow` sorgusu:** Her sevkiyat satırı için stok, ürün, miktar ve mevcut seri kayıtlarını getirir. `SERVICE_GUARANTY_NEW` tablosundan daha önce kaydedilmiş seri sayısını (`OMIK`) hesaplar.
- Sorgu sonuçları `cf_grid_list` bileşeni ile ürün koduna göre gruplanmış satırlara dönüştürülür; her satır kendi seri listesini (`serials_<PRODUCT_ID>`) içerir.

## Kullanıcı Akışı
1. **Barkod türü seçimi:** `attributes.show_parser` parametresi ile tetiklenen modal kullanıcıya Dönmez barkod (klasik/yeni) veya diğer barkod seçeneklerini sunar. Seçim `parser` değişkenine yazılır ve başarı bildirimi gösterilir.
2. **Seri girişi:** `#seri_no` inputu Enter tuşu ile dinlenir (`checkSerial`).
   - Boş girişler ve seçilmemiş parser kombinasyonları engellenir, gerekirse sayfa yenilenir.
   - Barkod, seçilen parser tipi ile `BarcodeManager.parseWith` üzerinden parse edilir. Parse başarısızsa kullanıcı uyarılır.
   - Parse edilen seri numarası `isSerialRegistered` fonksiyonu ile sunucuya (`/AddOns/Partner/cfc/serialservice.cfc?method=isRegistered`) sorularak sistemde kayıtlı olup olmadığı kontrol edilir.
   - Seri numarasına karşılık gelen ürün satırı `data-product_code_2` attribute'u ile bulunur; bulunamazsa uyarı verilir.
   - Seri numarası hem mevcut (önceden kaydedilmiş) hem de yeni eklenen satırlar arasında tekrar kontrolünden geçer.
3. **Seri listesine ekleme:** Yeni seri satırı `data-readed="0"` olarak tablonun sonuna eklenir, görsel olarak vurgulanır ve satırın sayaç durumu `updateProductStatus` ile güncellenir.
4. **Seri listesi yönetimi:** Ürün başlıklarına tıklayarak seri listelerini açıp kapatmak mümkündür (`toggleSerials`).
5. **Bildirimler ve geri bildirim:** Başarı/hata mesajları için özel bir bildirim bileşeni kullanılır; doğru miktar tamamlandığında veya aşıldığında durum renkleri değişir. Ek olarak giriş anında kısa bir ses efekti tetiklenmeye çalışılır.

## Kaydetme Süreci
- **`GetRows`:** Tüm ürün satırlarını dolaşarak her satır için `wrk_row_id`, `product_id`, `stock_id`, `product_code_2` ve seri kayıtlarını toplar. Seri değerleri `SERIAL_NO|okundu_flag` formatında üretilir (`okundu_flag`: `0` yeni, `1` mevcut).
- **`savePaper`:**
  - Yeni seri eklenmemişse kullanıcıdan onay ister.
  - Tam sayfa üzerinde yükleme katmanı gösterir.
  - `data` (seri listesi) ve `paperData` (sevkiyat meta verisi) JSON stringleri ile `purchase.emptypopup_save_despatch_serials_pbs` adresine gizli form POST'u yapar.

## Ek Özellikler
- **Klavye Kısayolları:** `Ctrl+S` kaydetme işlemini tetikler, `ESC` seri giriş alanına odaklanır.
- **Durum Göstergeleri:** Ürün satırındaki `status-indicator` etiketi, girilen seri sayısını ve eksik/tam/taşma durumlarını renklerle vurgular.
- **Responsive Tasarım:** 768px altındaki ekranlar için tablo ve giriş alanı ayarlamaları yapılır.
- **Yardımcı Fonksiyonlar:** `parseDonmezBarcode` ve `parseOtherBarcode` fonksiyonları orijinal parser mantığının doküman olarak korunmuş halleridir; şu an yalnızca `BarcodeManager` üzerinden parse işlemi yapılır.

## Bağımlılıklar ve Entegrasyonlar
- jQuery ve Bootstrap benzeri CSS sınıfları (tema tarafından sağlanıyor) ile çalışır.
- Font Awesome CDN'i ikonlar için yüklenir.
- Barkod ayrıştırma `kd/js/barcodeMenager.js` dosyasında tanımlı `BarcodeManager` sınıfına dayanır; sınıf global kapsamda hazır olmalıdır.
- Sunucu tarafı doğrulama ve kayıt işlemleri için `/AddOns/Partner/cfc/serialservice.cfc` ve `purchase.emptypopup_save_despatch_serials_pbs` uç noktalarına ihtiyaç duyar.

## BarcodeManager Ayrıntıları
- `BarcodeManager` varsayılan olarak üç parser kaydeder:
  - **1 – Dönmez:** `XXXXXX-X-X-TARİH-SERİ` formatını çözer ve ürün kodunu ilk 7 karakterden türetir.
  - **2 – Diğer:** `ETA_SERI_URETIM_PAKETLEME` formatındaki alt çizgi ayrılmış kodları işler.
  - **3 – Dönmez Yeni:** Dönmez’in yeni barkod yapısını destekler; ürün kodunu ilk iki segmentin birleşimiyle oluşturur.
- `BarcodeManager(options)` çağrısı ile `normalizeDates` (varsayılan `true`) ve `strict` (varsayılan `false`) seçenekleri kontrol edilir. Tarihler tanınırsa ISO `YYYY-MM-DD` formatına normalize edilir; başarısızlık durumunda `success:false` döner.
- `parseWith(barcode, parserId)` sayfadaki `parseBarcode` fonksiyonunun kullandığı temel çağrıdır. Gerektiğinde `parse(barcode)` veya `autoDetectAndParse(barcode)` ile parser seçimi otomatikleştirilebilir.
- Her başarılı sonuç `ParseResult` tipini takip eder: `product_code_2`, `serial_no`, isteğe bağlı üretim/paketleme tarihleri ve `parser_type`. Ayrıca ham barkod `raw` alanına yazılır.
- `tryAll(barcode)` fonksiyonu hata ayıklama sırasında tüm parser sonuçlarını karşılaştırmak için kullanılabilir; üretim ortamında kullanılmamaktadır ancak geliştirici konsolundan çağrıldığında faydalıdır.

## Geliştirme Notları
- `totalQuantity` hesaplaması DOM sırasına bağlıdır; tablo yapısı değişirse seri sayaçları sapabilir.
- Sunucuya gönderilen payload tamamen JSON stringleştirilmiş gizli inputlardan oluştuğu için karakter limitleri ve güvenlik kontrolleri gözden geçirilmelidir.
- Parse başarısızlıkları ve uzaktaki doğrulama hataları kullanıcıya yalnızca genel bildirimlerle iletilir; ayrıntılı hata günlükleri için konsol logları kullanılır.
