# e_shipping Kullanıcı Kılavuzu

## 1. Amaç ve Kapsam
- **Hedef:** Ezgi sevkiyat modülünde siparişlerin sevk planı, kontrolü ve teslimat takibini uçtan uca yönetmek.
- **Kapsam:** Siparişten sevk planına geçiş, sevk fişi üretimi, stok/lokasyon kontrolleri, sevk planı güncellemeleri, raporlama ve hata kontrol süreçleri.
- **Hedef Kullanıcılar:** Satış operasyonu, lojistik/ambar ekipleri, planlama, sevk kontrol ve yönetim raporlama kullanıcıları.

## 2. Modül Bileşenleri
| Klasör | Dosya | Amaç |
| --- | --- | --- |
| display | `list_ezgi_shipping.cfm` | Sevk planı ve sevk taleplerinin filtrelenip listelendiği ana ekran |
| display | `list_ezgi_shipping_row.cfm` | Sevk planındaki satır bazlı stok/tahsis listesi |
| display | `list_ezgi_shipping_control.cfm` | Sevk kontrolleri, teslimat ve irsaliye takibi |
| display | `list_ezgi_shipping_deliver.cfm` | Teslim edilen sevklerin durum ekranı |
| display | `svk_print_popup.cfm` | Sevk fişi/irsaliye yazdırma |
| form | `add_ezgi_shipping.cfm` | Siparişten sevk planı oluşturma formu |
| form | `upd_ezgi_shipping*.cfm` | Mevcut sevk planında ambar, teminat, sevk emir vb. güncellemeler |
| form | `setup_ezgi_shipping.cfm` | Sevk varsayılanları ve çalışma parametreleri |
| query | `add_*/upd_*/del_*` | Veri tabanı işlemleri (EZGI_SHIP_RESULT, EZGI_SHIP_RESULT_ROW vb.) |

## 3. Yetkiler ve Ön Koşullar
- **Depo/Lokasyon Tanımı:** Kullanıcının `EMPLOYEE_POSITION_BRANCHES` ve `EMPLOYEE_POSITION_DEPARTMENTS` kayıtları tanımlı olmalı; aksi hâlde liste ekranı uyarı verip kapanır (`"Depo ve lokasyon bulunamamıştır"`).
- **Sipariş Rezervasyonu:** `add_ezgi_shipping.cfm` dosyası rezerve olmayan siparişlerde sevk planına izin vermez ("Sipariş rezerve değildir" uyarısı). Sipariş kartında *Stok Rezerve Et* seçeneği zorunlu.
- **Varsayılan Sevk Tipi:** `EZGI_SHIPPING_DEFAULTS` tablosunda tanım bulunmazsa ekran, kullanıcıdan sevk tipi seçmesini ister. Parametre eksikse yöneticiden tanımlanması istenir.
- **Yetkiler:** Kullanıcı, ilgili şirket/şube için sevk oluşturma ve depo erişim yetkilerine sahip olmalıdır. `session.ep` bağlamındaki `COMPANY_ID`, `POSITION_CODE` ve `maxrows` değerleri UI davranışını etkiler.

## 4. Navigasyon ve Hızlı Başlangıç
1. **Sevk Listesi:** `Satış > Sevkiyat > Ezgi Sevkiyat Listesi` (display/list_ezgi_shipping.cfm).
2. **Filtreleri Ayarla:** Tarih aralığı, şube, sevk yöntemi, şehir vb. filtreleri doldurup *Listele* butonuna basın.
3. **Sipariş Seç:** Listelenen sevk planı veya sipariş satırında *Sevk Fişine Git* veya *Plan Oluştur* ikonuna tıklayın.
4. **Sevk Planı Formu:** Açılan pencerede zorunlu alanları (Cari, süreç, çıkış depo, sevk yöntemi, tarih saat) tamamlayın.
5. **Satır Seçimi:** Sevk etmek istediğiniz sipariş satırlarını işaretleyin; stok/depodaki miktarı kontrol edin.
6. **Kaydet & Yazdır:** Sevk planını kaydedip gerekirse `svk_print_popup.cfm` üzerinden fiş alın.
7. **Teslimat İzleme:** Teslimata çıktıktan sonra `list_ezgi_shipping_control.cfm` ve `list_ezgi_shipping_deliver.cfm` ekranlarından durum izleyin.

## 5. Çekirdek Süreçler
### 5.1 Siparişten Sevk Planı Oluşturma
1. `list_ezgi_shipping.cfm` ekranında aradığınız siparişi bulun.
2. Satırın sağındaki *Sevk Fişine Git* simgesine tıklayın (popup `add_ezgi_shipping.cfm`).
3. Form otomatik olarak şu bilgileri getirir: sipariş no, stok satırları, cari bilgisi, sevk adresi, depo/lokasyon.
4. Zorunlu alanları gözden geçirin; gerekirse depo/lokasyon değiştirin.
5. Sevk yöntemi ve sevk/telsim tarih-saatini belirleyin.
6. Sevk alınacak stok satırlarını işaretleyin. Sistem stokta olmayan satırlarda bilgilendirme yapar.
7. *Kaydet* sonrası sevk planı `EZGI_SHIP_RESULT` tablosuna düşer ve liste ekranında görünür.

### 5.2 Sevk Planını Güncelleme
- **Ambar Kontrolü:** `upd_ezgi_shipping_ambar_control.cfm` planın depo onayını yapar.
- **Teminat/Term Kontrolü:** `upd_ezgi_shipping_term_control.cfm` finansal doküman veya teminat şartlarını doğrular.
- **Sevk Emir Çıkışı:** `upd_ezgi_shipping_sevk.cfm` sevk emir tarihini ve sorumlu personeli günceller; `IS_SEVK_EMIR` alanını işaretler.
- **Temizleme & İptal:** `upd_ezgi_shipping_clear.cfm` veya `upd_ezgi_shipping_clear_order_row.cfm` satır veya plan bazlı iptal/temizleme işlemleri yapar; log amaçlı not girilmesi tavsiye edilir.

### 5.3 Teslimat ve Kontrol
1. Sevk fişi çıktıktan sonra `list_ezgi_shipping_control.cfm` ekranına geçin.
2. Şehir, sevk yöntemi veya şube filtreleri ile ilgili kayıtları daraltın.
3. Teslim belge numarası (`DELIVER_PAPER_NO`) ve referans no ile kaydı açın.
4. Teslim tarihini, teslim alan personeli ve ilgili müşteri onayını girin.
5. `list_ezgi_shipping_deliver.cfm` ekranı, teslim edilen sevkleri gösterir; `SHIP_RESULT_ID` üzerinden detay popup'larına geçilebilir.

### 5.4 Raporlama ve Görselleştirme
- **Grafik:** `list_ezgi_shipping_graph.cfm` günlük/haftalık sevk adetlerini, sevk yöntemine göre dağılımı sunar.
- **Üretim/Sevkiyat Oranları:** `list_order_production_rate.cfm` ve `list_order_internal_rate.cfm` siparişin üretim ve sevk ilerleyişini kıyaslar.
- **Plan/Satır Raporu:** `list_ezgi_shipping_row.cfm` stok satırı bazında sevk edilen/kalan miktarı gösterir; stok kodlarını Excel'e aktarmak için kullanın.

## 6. Filtreler ve Listeleme Parametreleri
`list_ezgi_shipping.cfm` ekranında kullanılan başlıca filtreler:
| Parametre | Açıklama | Varsayılan |
| --- | --- | --- |
| `start_date` / `finish_date` | Sevk planı oluşturma veya çıkış tarih aralığı | Bugünün tarihi |
| `branch_id`, `sales_departments`, `location_id` | Şube/depo/lokasyon bazlı süzme | Kullanıcının varsayılanı |
| `SHIP_METHOD_ID` | Sevk yöntemi | Boş (hepsi) |
| `city_name`, `zone_id` | Sevkiyatın yapılacağı şehir/bölge | Boş |
| `product_id`, `prod_cat`, `short_code_id` | Ürün veya kategori filtresi | Boş |
| `order_employee_id` | Siparişi oluşturan personel | Otomatik olarak oturum kullanıcısı |
| `listing_type`, `sort_type` | Liste görünümü ve sıralama | 2 / 3 |
| `report_type_id` | Rapor formatı | 3 |
| `t_point` | Tır/taşıma puanı veya tolerans | 0 |

> Filtre kombinasyonlarını sık kullanıyorsanız URL parametre zincirini (örn. `lnk_str`) kaydedip favori olarak saklayabilirsiniz.

## 7. Form Alanları Referansı (add_ezgi_shipping.cfm)
| Alan | Zorunlu | Açıklama |
| --- | --- | --- |
| Süreç (`cf_workcube_process`) | ✔ | Sevk fişinin bağlı olacağı süreç/kategori |
| Sevkiyat No | ✔ | `cf_papers` ile otomatik üretilir; manuel değişmez |
| Cari Hesap / Yetkili | ✔ | Sipariş varsayılanı gelir; popup ile değiştirilebilir |
| Çıkış Depo & Lokasyon | ✔ | Sipariş depo/lokasyon bilgisi; `popup_list_stores_locations` ile seçilir |
| Sevk Yöntemi | ✔ | Taşıma tipi; `SHIP_METHOD` tablosundan gelir |
| Sevk Başlangıç Tarih-Saat | ✔ | Sevkin yapılacağı zaman damgası |
| Teslim Tarihi-Saat | Opsiyonel | Müşteri iadeli teslim planı |
| Sevk Görevlisi (`deliver_name2`) | ✔ | Sevki gerçekleştirecek personel |
| Referans No | - | Sipariş referans bilgisi, sadece görüntülenir |
| Not/Açıklama | - | Sipariş detayından öntanımlı gelir, düzenlenebilir |
| Ürün Satırları | ✔ | İşaretlenen satırlar sevk planına dahil edilir; stok depo miktarı ve kalan açık miktar gösterilir |

## 8. Sık Karşılaşılan Hatalar ve Çözüm Önerileri
| Hata Mesajı / Durum | Muhtemel Neden | Çözüm |
| --- | --- | --- |
| "Bu şirket için tanımlanmış depo ve lokasyon bulunamamıştır" | Kullanıcının pozisyonu için depo/lokasyon tanımı yok | Yetkili kişiden `EMPLOYEE_POSITION_BRANCHES` ve `...DEPARTMENTS` kayıtlarını güncellemesini isteyin |
| "Sipariş rezerve değildir" | Sipariş kartında stok rezervasyonu kapalı | Siparişi açıp *Stok Rezerve Et* seçeneğini işaretleyin, tekrar deneyin |
| Aynı `SHIP_RESULT_ID` için birden fazla şehir/ilçe bulundu | Sevk planı satırlarının adresleri değiştirilmiş | `list_ezgi_shipping.cfm` açıldığında yapılan otomatik kontrolde listelenen planları güncelleyin, tüm satırların adresini eşleştirin |
| Cari/şirket bilgisi uyuşmuyor | Siparişin cari bilgisi sonradan değişmiş | `upd_ezgi_shipping.cfm` üzerinden doğru cari/consumer bilgilerini güncelleyin, gerekirse planı yeniden oluşturun |
| Sevk fişi yazdırılamıyor | `svk_print_popup.cfm` gerekli veriyi bulamıyor | Sevk planının kaydedildiğinden ve `DELIVER_PAPER_NO` üretildiğinden emin olun |

## 9. İpuçları ve En İyi Uygulamalar
- **Filtre Şablonları:** Sık kullanılan filtre setlerini tarayıcı yer imi olarak kaydedin süre kazanırsınız.
- **Satır Bazlı Kontrol:** Sevk edilen ve kalan miktar için `list_ezgi_shipping_row.cfm` ekranını günlük kontrol edin; eksik sevkleri hızla yakalarsınız.
- **Veri Tutarlılığı:** Sevk planını kaydetmeden önce depo stok özetini (`DEPO` sütunu) kontrol edin; rezervi aşan satırları işaretlemeyin.
- **Roller Arası Handover:** Ambar, finans ve sevk kontrol rollerinin hangi formu kullanacağına dair kısa çalışma talimatı paylaşın (örn. `upd_ezgi_shipping_ambar_control.cfm` yalnızca ambar onayı için).
- **Raporlama:** Yönetim özetleri için `list_ezgi_shipping_graph.cfm` veya `list_order_production_rate.cfm` çıktıları haftalık toplantılara eklenebilir.

---
Bu kılavuz dosyası, `c:\Users\User\Desktop\Projects\ColdfusionProjects\kd\e_shipping` dizinindeki bileşenleri temel alır. Kodda yapılan güncellemeleri kılavuza yansıtmayı unutmayın.
