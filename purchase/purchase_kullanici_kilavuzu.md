# Satınalma Modülü Kullanıcı Kılavuzu

## 1. Modülün Amacı
Satınalma modülü; iç taleplerinizi tedarik tekliflerine dönüştürmenizi, en uygun fiyatı veren tedarikçiyi seçmenizi ve tek tıkla satınalma siparişi oluşturmanızı sağlar. Bu kılavuz, günlük kullanıcıların ekranlar arasında nasıl ilerleyeceğini ve hangi adımlarda dikkatli olması gerektiğini özetler.

## 2. Ön Koşullar
- İç talep süreci tamamlanmış ve ilgili talep statüsü "Teklife Açık" olmalıdır.
- Kullanıcının güncel dönem, şirket ve depo bilgilerine erişim yetkisi bulunmalıdır.
- Tarayıcıda pop-up engelleyiciler kapalı olmalı (yeni ürün ekleme penceresi için).

## 3. Satınalma Teklifi Seçim Ekranı
### 3.1 Ekrana Giriş
1. Menüden **Satınalma > Teklif Seçimi** ekranını açın.
2. Sisteme yönlendirildiğinizde `purchase_offer_product_select.cfm` ekranı yüklenecek ve ilgili iç talebe bağlı tüm teklif satırları listelenecektir.

### 3.2 Tablo Yapısı
- Satırlar ürünleri, kolonlar tedarikçileri temsil eder.
- Yeşil yıldız ikonlu değerler, ilgili ürün için en düşük net fiyatı gösterir.
- Hücrede "🚩 Satış Teklifinde" uyarısı varsa ürün daha önce satış teklifine dönmüştür, seçim yapılamaz.
- Hücrede kilit ikonu veya soluklaşma varsa ürün için satınalma tamamlanmış ya da satır kilitlidir.

### 3.3 Ürün Seçimi
1. Her ürün için tercih ettiğiniz tedarikçinin hücresine tıklayın.
2. Seçilen hücre sağ üst köşesinde yeşil ✔️ işareti belirir.
3. Sağdaki "Seçilen Veriler (JSON)" kutusu canlı olarak güncellenir.

### 3.4 Marj ve Satış Fiyatı
- Ürün satırındaki "Marj (%)" sütununa hedef marjınızı girin.
- Marj alanı dolduktan sonra "Satış Fiyatı" kutusu otomatik hesaplanır.
- Toplu marj atamak için kolon başlığındaki "Toplu" girişine değer yazıp Enter’a basın.

### 3.5 En İyi Tedarikçi
- Ekranın altındaki kart, tüm ürünleri eksiksiz sağlayabilen ve en düşük toplam net fiyatı sunan tedarikçiyi gösterir.
- Tedarikçi adına tıklarsanız detaylarını görebilirsiniz.

### 3.6 İşlemi Kaydetme
- **Sadece seçimleri kaydetmek** için `Kaydet` (send-btn3) düğmesine basın.
  - Sistem seçimlerinizi `PBS_SELECTED_ROWS` tablosuna yazacak, sayfa yenilenecektir.
- **Satınalma teklifini yeniden oluşturmak** istiyorsanız yöneticinizin talimatıyla `Satış Teklifine Aktar` (send-btn) düğmesini kullanın.

### 3.7 Satınalma Siparişi Oluşturma
- Tüm ürünlerde seçim tamamlandığında "Satınalma Siparişlerini Oluştur" düğmesi aktif hale gelir (sadece teklif durumu 256 ve daha önce sipariş üretilmemişse görünür).
- Düğmeye bastığınızda sistem her tedarikçi için ayrı bir sipariş oluşturur. Başarılı olduğunda bilgilendirme mesajı gelir.

## 4. Yeni Ürün Ekleme İş Akışı
Bazı teklif satırlarında ürün kartı bulunmuyorsa "Yeni Ürün" butonu (popup) ile ürün oluşturabilirsiniz.

1. Listeden ilgili satırda "Yeni Ürün" bağlantısına tıklayın. Pop-up açılır.
2. Zorunlu alanları doldurun:
   - Ürün adı, marka, model, ana birim
   - Alış/Satış KDV oranları
   - Gerekli ise OEM numaraları ("Ekle" butonu ile çoklu satır açabilirsiniz).
3. Kaydete bastığınızda sistem ürün kartını oluşturur ve teklif satırını yeni ürün bilgisi ile günceller.
4. Pop-up kapanıp ana ekran yenilenecektir.

## 5. Depodan Teslim Senaryoları
Modül içinde `depodan_teslim.cfm` ve `depodan_tedarik.cfm` gibi ekranlar bulunur.

- **Depodan Teslim:** Satınalma siparişi onaylandıktan sonra depo çalışanlarının ürünü teslim aldığı ekran. Butonlar üzerinden teslim alma ve iade işlemleri yapılır.
- **Depodan Tedarik:** Depodaki stoklardan tedarik yapılırken kayıt oluşturulur. Bu ekranda ürün arama, miktar girme ve depolara göre yönlendirme alanları vardır.
- **Fonksiyonlar:** `ajax_depodan_teslim.js` ve `fonksiyonlar_depodan_teslim.js` dosyaları buton işlemlerini sunucuya iletir.

İşlem sırası:
1. Sipariş numarası ile kaydı açın.
2. Teslim alınacak satırları işaretleyin.
3. "Depodan Teslim Al" veya ilgili işlem düğmesine tıklayın.
4. Başarılı işlemde sistem bilgi mesajı gösterir.

## 6. Sık Karşılaşılan Senaryolar

| Durum | Çözüm |
| --- | --- |
| Bir üründe seçim yapamıyorum | Satır kilitlenmiş olabilir; satırdaki uyarıyı kontrol edin. Gerekirse teknik ekibe başvurun. |
| Kaydet butonuna bastım ama değişiklik görmüyorum | Tarayıcıyı yenileyin. Sorun devam ederse log kayıtlarını teknik ekibin incelemesi gerekir. |
| Satınalma siparişi oluşmadı | Sipariş butonu sadece teklif durumu 256 iken ve önceki sipariş kaydı yoksa çıkar. Seçilmeyen ürün var mı kontrol edin. |
| Yeni ürün ekranı açılmıyor | Pop-up engelleyicileri kapatın veya farklı tarayıcı deneyin. |

## 7. İyi Uygulamalar
- Her ürün için mutlaka marj değeri girin; sıfır marj uyarısı alınırsa işlem yapmayın.
- Sipariş oluşturmadan önce "En İyi Tedarikçi" bilgisi ile seçimlerinizi tekrar gözden geçirin.
- JSON özetini kopyalayarak başka kullanıcılarla paylaşabilirsiniz.
- Depo teslim ekranlarında işlem yapmadan önce doğru şirket ve depo seçildiğinden emin olun.

## 8. Destek
- Fonksiyonel sorular için: Satınalma departmanı yöneticiniz.
- Teknik problemler için: IT Destek / Uygulama Geliştirme ekibi (log dosyası `purchaseService.log`).

Bu kılavuz, satınalma modülünü etkin bir şekilde kullanmanız için hazırlanmıştır. Geliştirmeler veya yeni özellikler eklendiğinde kılavuz güncellenecektir.
