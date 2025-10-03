# Satınalma Modülü Teknik Kılavuzu

## 1. Amaç ve Kapsam
Satınalma modülü, iç taleplerden beslenen satınalma tekliflerini değerlendirme, uygun tedarikçileri seçme ve nihai olarak satınalma teklifleri ile siparişlerini oluşturma süreçlerini uçtan uca otomatikleştirir. Modül; ColdFusion CFC servisleri, CFML tabanlı formlar ve JavaScript ile inşa edilen etkileşimli seçim ekranlarından oluşur.

Bu doküman aşağıdaki bileşenleri teknik açıdan açıklar:

- `cfc/purchase_service.cfc` içerisindeki uzak fonksiyonlar
- `form/` klasöründeki seçim ve bakım ekranları
- `query/` klasöründeki veritabanı işlemleri
- `js/` ve formlar içinde gömülü JavaScript dosyaları

## 2. Mimari Genel Bakış

### 2.1 Katmanlar
- **Sunum Katmanı:** `form/` altındaki CFML dosyaları ile render edilen HTML + Bootstrap bileşenleri ve dinamik tablo davranışlarını yöneten JavaScript dosyaları (örn. `product_select.js`, `satin_alma_yeni_urun.js`).
- **Servis Katmanı:** `cfc/purchase_service.cfc` içinde tanımlı uzak (remote) fonksiyonlar. HTTP POST ile JSON payload alır ve JSON döndürür.
- **Veri Katmanı:** `query/` klasöründeki dosyalar aracılığıyla yürütülen parametrik SQL sorguları ve saklı yordam çağrıları. Çekirdek tablolar: `PBS_SELECTED_ROWS`, `OFFER`, `OFFER_ROW`, `ORDERS`, `COMPANY`, `INTERNALDEMAND` vb.

### 2.2 Veri Akışı
1. **Tedarikçi/Ürün Listesi:** `purchase_offer_product_select.cfm` ve `satin_alma_yeni_urun.cfm` sayfaları, `getMainPurchaseOffer` sorgusu ile teklif satırlarını JSON formatında tarayıcıya sunar.
2. **Kullanıcı Seçimleri:** JavaScript tarafında ürün bazlı seçimler `selectedCells` haritasında tutulur ve `updateOutput()` ile şirket bazında gruplanır.
3. **Sunucuya Kaydetme:** `fetch()` çağrıları ile seçimler `purchase_service.cfc` içindeki fonksiyonlara gönderilir (`savePurchaseOfferSelector`, `saveSaleOfferFromSelectedRows`, `savePurchaseOfferSelectorOnly`).
4. **Veritabanı İşlemleri:** Servis fonksiyonları, ilgili satırları `PBS_SELECTED_ROWS` tablosunda günceller ve gerekli maliyet/kur hesaplarını yaptıktan sonra `query/add_offer.cfm` veya `query/add_order.cfm` dosyalarını `<cfinclude>` ile çalıştırarak yeni teklif/sipariş kayıtları oluşturur.
5. **Sipariş Üretimi:** `SAVEORDER_gpt` fonksiyonu seçimleri şirket bazında gruplayıp `ORDERS` tablosuna kayıt atar.

## 3. Servis Fonksiyonları

### 3.1 `saveSaleOfferFromSelectedRows(payload)`
- **Amaç:** PBS seçili satırlardan satış teklifi üretirken satınalma teklifini yeniden oluşturur.
- **Kaynak Verisi:** `PBS_SELECTED_ROWS`, `OFFER_ROW`, `STOCKS`, `SETUP_MONEY`.
- **Öne Çıkan Adımlar:**
  - Seçili satırlar sorgulanır, satır bazlı fiyat ve vergi hesaplamaları yapılır.
  - Kur bilgileri `SETUP_MONEY` ve `MONEY_HISTORY` tablolarından alınır.
  - `<cfinclude>` ile `query/add_offer.cfm` tetiklenerek yeni teklif kaydı açılır.
  - `PURCHAE_OFFER_SALE_OFFER_RELATION_PBS` tablosu güncellenir.

### 3.2 `savePurchaseOfferSelector(payload)`
- **Amaç:** Kullanıcının tablo üzerinden seçtiği alternatif tedarikçileri `PBS_SELECTED_ROWS` tablosuna yazar.
- **Girdi:** `{ payload: [{products:[...] }], offer_id, session_variables }` yapısında JSON.
- **İşlev:**
  - Mevcut satırlar silinir, yeni satırlar eklenir.
  - Seçime göre kur, fiyat ve tutar hesaplamaları yapılır.
  - `query/add_offer.cfm` ile yeni satınalma teklifi üretilir ve ilişki tablosu güncellenir.

### 3.3 `savePurchaseOfferSelectorOnly(payload, offer_id, BEI)`
- **Amaç:** Sadece seçim tablosunu günceller; teklif oluşturma sürecini tetiklemez.
- **Not:** `PBS_SELECTED_ROWS` tablosunda `IS_OS=1` ayarlanır, stok/ürün bilgileri güncellenir.

### 3.4 `getByProductId(product_id)`
- **Amaç:** Alternatif ürün ID listesi döndürür.
- **Kaynak:** `ALTERNATIVE_PRODUCTS` tablosu.

### 3.5 `savePurchaseOffer(payload)`
- **Amaç:** Bir satış teklifindeki satırlara karşılık yeni bir satınalma teklifi oluşturur.
- **Öne Çıkan Nokta:** Ürün listesi doğrudan `OFFER_ROW` üzerinden çekilir, `PBS_SELECTED_ROWS` yerine bellekte `attributes` yapılandırılır.

### 3.6 `SAVEORDER_gpt(internal_id)`
- **Amaç:** Seçili satınalma tekliflerinden satınalma siparişleri açar.
- **Süreç:**
  - `PBS_SELECTED_ROWS` + `OFFER_ROW` + `OFFER` join ile şirket bazlı satırlar alınır.
  - Kur bilgileri `SETUP_MONEY`/`MONEY_HISTORY` üzerinden hesaplanır.
  - Her şirket için `attributes` doldurulur ve `query/add_order.cfm` ile sipariş kaydı yazılır.

### 3.7 Yardımcı Fonksiyonlar
- `basket_kur_ekle`: Çoklu kur bilgilerini ilgili *MONEY* tablolarına yazar.
- `add_internaldemand_row_relation`: İç talep -> teklif/sipariş ilişkilerini `INTERNALDEMAND_RELATION_ROW` tablosuna işler.

## 4. JavaScript Yapısı

### 4.1 Ortak Fonksiyonlar
- `mergeCompanies(data)`: Aynı tedarikçiye ait satırları tek objede birleştirir.
- `updateOutput()`: Seçili hücreleri şirket bazında gruplayarak `fetch` çağrısında kullanılacak JSON payload üretir.
- `updateBestSupplier()`: Tüm ürünleri en düşük net fiyatla sunan tedarikçiyi hesaplar.

### 4.2 `purchase_offer_product_select.cfm`
- **Veri Hazırlığı:** `getMainPurchaseOffer.QRESULT` JSON’u PHP benzeri CF etiketi ile `data` değişkenine aktarılır.
- **Tablo Oluşturma:** Ürün isimleri satır, tedarikçiler sütun olacak şekilde dinamiktir. Alternatif ürün grupları renk kodlanır.
- **Seçim Kısıtları:** Ürünün `IS_SATINALMA=1` veya `IS_OS=false` olması durumunda hücre devre dışı bırakılır.
- **Marj / Satış Fiyatı:** Global ve ürün bazlı marj girişleri, hedef para birimine (`DEMAND_MONEY`) çevrilir.
- **Kaydet:** `send-btn3` → `savePurchaseOfferSelectorOnly`, `send-btn` → `savePurchaseOfferSelector`, `send-btn2` → `SAVEORDER_gpt`.

### 4.3 `satin_alma_yeni_urun.cfm` + `satin_alma_yeni_urun.js`
- `PRODUCT_ID` bazlı eşleştirme yapar.
- Satış fiyatı girildiğinde marjı ters hesaplar.
- `getAktifTeklif` ile seçili satırın ait olduğu teklifin kur bilgilerini bulur.

### 4.4 `product_select.js`
- Eski / minimal seçim ekranı. `net_price` ve `price` değerleri TL bazında gösterilir.

## 5. Form ve Süreç Ekranları

| Dosya | Amaç |
| --- | --- |
| `form/purchase_offer_product_select.cfm` | İç talepten gelen tüm tedarik tekliflerini karşılaştırma ve marj girişi. |
| `form/satin_alma_yeni_urun.cfm` | Yeni ürün satınalma süreci, OEM ve alternatif ürün yönetimi. |
| `form/add_product_from_purchase.cfm` | Satınalma teklif satırından yeni ürün kartı açma popup’ı. |
| `form/depodan_teslim*.cfm/js` | Depodan teslim süreçleri (teslim alma/etkileşim butonları). |
| `form/main_functions.js` | Ortak JS yardımcıları (merge, seçim kontrolü). |

## 6. Veritabanı Tabloları
- **`PBS_SELECTED_ROWS`**: Kullanıcı seçimlerini geçici olarak tutar (`WRK_ROW_ID`, `OFFER_ID`, `PRODUCT_MARJ`, `SALE_PRICE`, `IS_OS`...).
- **`OFFER` / `OFFER_ROW`**: Satış ve satınalma teklifleri. `PURCHASE_SALES=1` satınalma anlamına gelir.
- **`ORDERS` / `ORDER_ROW`**: Satınalma sipariş başlık ve satırları.
- **`INTERNALDEMAND` / `INTERNALDEMAND_ROW`**: İç talepler (başlangıç kaynağı).
- **`SETUP_MONEY`, `MONEY_HISTORY`**: Kur bilgileri.
- **`ALTERNATIVE_PRODUCTS`**: Alternatif ürün eşleştirmeleri.
- **`PURCHAE_OFFER_SALE_OFFER_RELATION_PBS`**: Satınalma teklifi ↔ satış teklifi ilişkisi.

## 7. Dış Bağımlılıklar ve Konfigürasyon
- **Session Kullanımı:** Tüm servis fonksiyonları `session.ep` içinden şirket, kullanıcı ve dönem bilgisi okur. Self-contained testler için oturum mock’lanmalıdır.
- **DSN Tanımları:** `dsn` (`w3Qa`) ve `dsn3` (`w3Qa_1`) alias’ları kullanılmaktadır. Lokalde aynı DSN adları tanımlanmalıdır.
- **Loglar:** `cflog file="purchaseService"` ile hata/işlem logları yazılır.
- **URL:** Frontend `fetch` çağrılarında `/AddOns/Partner/purchase/cfc/purchase_service.cfc` path’i sabittir. IIS/Apache üzerinde bu yolun erişilebilir olması gerekir.

## 8. Test ve Doğrulama Önerileri
1. **Seçim Kaydetme:** Seçim ekranında bir tedarikçi seçip “Kaydet”e basın; `PBS_SELECTED_ROWS`’ta satır oluştuğunu doğrulayın.
2. **Teklif Üretimi:** `savePurchaseOfferSelector` sonrası `OFFER` tablosunda yeni kaydın, `PURCHASE_SALES=1` koşulu ile açıldığını teyit edin.
3. **Sipariş Oluşturma:** `SAVEORDER_gpt` tetikledikten sonra `ORDERS` ve `ORDER_ROW` tablolarında ilgili şirket için kayıt çıktığını kontrol edin.
4. **Yeni Ürün Ekleme:** `add_product_from_purchase.cfm` popup’ında ürün oluşturup, `PRODUCT`, `STOCKS` tablosunda kayıt oluştuğunu ve `OFFER_ROW`’un güncellendiğini kontrol edin.

## 9. Geliştirme Notları
- `attributes` struct’ı her `<cfinclude>` öncesi dikkatle doldurulmalı; eksik alanlar veritabanında `NULL` hatalarına yol açabilir.
- Para birimi dönüşümleri iki aşamalıdır: satır bazlı (`RATE2` çarpanı) ve toplam bazında (`basket_rate1/2`).
- `SAVEORDER_gpt` fonksiyonunda `arguments.last_offer_id` kullanımlarına dikkat edin; opsiyonel parametre kaldığında bazı join’ler redundant olabilir.
- Büyük tablolar üzerinde `DELETE` + `INSERT` işlemleri yapıldığından kilitlenme riskine karşı transaction kapsamları gözden geçirilmelidir.

## 10. Bilinen Sınırlar / İyileştirme Fikirleri
- **Performans:** `purchase_offer_product_select.cfm` büyük JSON çıktıları render eder; pagination veya sanal scrolling önerilir.
- **Validasyon:** `savePurchaseOfferSelectorOnly` fonksiyonunda payload yapısı ve zorunlu alan kontrolleri artırılabilir.
- **Çoklu Para Birimi:** Kur listesi `SETUP_MONEY` ile sınırlıdır; API entegrasyonu düşünülüyorsa kur cache mekanizması gerekebilir.
- **Loglama:** Başarılı işlemler “information” tipinde loglanıyor; log hacmi artarsa rotasyon planlanmalı.

---
Bu teknik kılavuz, geliştiricilerin satınalma modülündeki veri akışlarını, fonksiyon imzalarını ve bağımlılıklarını hızlıca kavraması için hazırlanmıştır. Daha ayrıntılı tablo şemaları için veritabanı diyagramlarına veya ilgili ERD dokümanlarına başvurabilirsiniz.
