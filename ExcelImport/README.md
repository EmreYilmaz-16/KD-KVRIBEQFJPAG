# 📊 CFML Excel Import System

Bu proje, Adobe ColdFusion (CFML) kullanarak Excel dosyalarını yükleyip veritabanına aktaran kapsamlı bir sistemdir.

## 🎯 Özellikler

- ✅ Excel (.xlsx, .xls) dosyası yükleme
- 👀 Veri önizleme ve onay sistemi
- 🗄️ PRODUCT_OEMS tablosuna güvenli veri aktarımı (51 kolon)
- 🔒 SQL Injection koruması (cfqueryparam)
- 📊 Detaylı istatistikler ve hata raporlama
- 🎨 Modern, responsive web arayüzü
- 📝 Kapsamlı hata yakalama ve loglama
- ⚡ Performans optimizasyonları

## 📁 Dosya Yapısı

```
ExcelImport/
├── Application.cfc              # Uygulama yapılandırması
├── upload_excel.cfm            # Dosya yükleme formu
├── import_excel.cfm            # Basit import (direkt aktarım)
├── import_excel_preview.cfm    # Gelişmiş import (önizleme + onay)
├── error_page.cfm              # Hata sayfası
├── create_table.sql            # Veritabanı tablo oluşturma script'i
├── uploads/                    # Yüklenen dosyalar klasörü
└── README.md                   # Bu dosya
```

## 🚀 Kurulum

### 1. Dosyaları Yerleştirin
```bash
# ColdFusion web root klasörüne kopyalayın
C:\ColdFusion2021\cfusion\wwwroot\ExcelImport\
# veya
C:\inetpub\wwwroot\ExcelImport\
```

### 2. Veritabanı Kurulumu
```sql
-- create_table.sql dosyasını çalıştırın
-- SQL Server Management Studio'da:
EXEC sp_executesql @sql = 'CREATE TABLE PRODUCT_OEMS...'
```

### 3. Veri Kaynağı Ayarları
`Application.cfc` dosyasında veri kaynağı ayarlarını güncelleyin:

```javascript
this.datasources = {
    "YOUR_DSN" = {
        driver = "MSSQLServer",      // Veritabanı türü
        host = "localhost",          // Sunucu adresi
        port = 1433,                 // Port numarası
        database = "YourDatabase",   // Veritabanı adı
        username = "YourUsername",   // Kullanıcı adı
        password = "YourPassword"    // Şifre
    }
};
```

### 4. Klasör İzinleri
```bash
# uploads/ klasörüne yazma izni verin
icacls "C:\path\to\ExcelImport\uploads" /grant "IIS_IUSRS:(OI)(CI)F"
```

## 📋 Excel Dosyası Formatı

### Zorunlu Kolon Yapısı
| A (ETA_KODU) | B (OEM_1) | C (OEM_2) | ... | AX (OEM_50) |
|--------------|-----------|-----------|-----|-------------|
| ETA001       | VALUE1    | VALUE2    | ... | VALUE50     |
| ETA002       | VALUE3    | VALUE4    | ... | VALUE51     |

### Önemli Notlar
- ✅ **İlk satır** kolon başlıkları olmalı
- ✅ **ETA_KODU** kolonu zorunlu (boş olamaz)
- ✅ **OEM_1** - **OEM_50** kolonları isteğe bağlı
- ✅ Maksimum dosya boyutu: **10MB**
- ✅ Desteklenen formatlar: **.xlsx**, **.xls**

## 🔧 Kullanım

### Basit Import (Direkt Aktarım)
```
1. http://localhost/ExcelImport/upload_excel.cfm adresine gidin
2. Excel dosyanızı seçin
3. "Dosyayı Yükle ve İşle" butonuna tıklayın
4. Sonuçları görüntüleyin
```

### Gelişmiş Import (Önizleme + Onay)
```
1. upload_excel.cfm formunu import_excel_preview.cfm'e yönlendirin
2. Excel dosyanızı seçin
3. Veri önizlemesini kontrol edin
4. "Onayla ve Veritabanına Aktar" butonuna tıklayın
```

## 🗄️ Veritabanı Tablosu

### PRODUCT_OEMS Tablo Yapısı
```sql
CREATE TABLE PRODUCT_OEMS (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    ETA_KODU NVARCHAR(255) NOT NULL,
    OEM_1 NVARCHAR(255) NULL,
    OEM_2 NVARCHAR(255) NULL,
    -- ... OEM_3 to OEM_49
    OEM_50 NVARCHAR(255) NULL,
    CREATED_DATE DATETIME DEFAULT GETDATE(),
    UPDATED_DATE DATETIME DEFAULT GETDATE()
);
```

## 🔒 Güvenlik Özellikleri

### SQL Injection Koruması
```cfml
<cfqueryparam value="#trim(data)#" cfsqltype="cf_sql_varchar">
```

### Dosya Doğrulama
```cfml
- Dosya uzantısı kontrolü (.xlsx, .xls)
- Dosya boyutu sınırı (10MB)
- MIME type doğrulama
- Güvenlik başlıkları (XSS, CSRF koruması)
```

## 📊 Hata Yönetimi

### Otomatik Hata Yakalama
- Excel okuma hataları
- Veritabanı bağlantı hataları
- Veri doğrulama hataları
- Dosya yükleme hataları

### Log Sistemi
```cfml
# Log dosyaları şurada bulunur:
C:\ColdFusion2021\cfusion\logs\excelimport.log
```

## 🎨 Özelleştirme

### CSS Temaları
```css
/* Ana renk paleti değiştirme */
:root {
    --primary-color: #667eea;
    --secondary-color: #764ba2;
    --success-color: #28a745;
    --error-color: #dc3545;
}
```

### Upload Limitleri
```cfml
# Application.cfc içinde
this.requestTimeOut = 300;           // 5 dakika
application.maxFileSize = 10485760;  // 10MB
application.allowedExtensions = "xlsx,xls";
```

## 🚨 Sorun Giderme

### Yaygın Hatalar ve Çözümleri

#### 1. "Dosya yüklenemedi" Hatası
```
✅ Çözüm: uploads/ klasörü izinlerini kontrol edin
✅ Çözüm: Dosya boyutunu kontrol edin (max 10MB)
✅ Çözüm: Dosya formatını kontrol edin (.xlsx, .xls)
```

#### 2. "Veritabanı bağlantı hatası"
```
✅ Çözüm: Application.cfc'deki DSN ayarlarını kontrol edin
✅ Çözüm: ColdFusion Admin'de veri kaynağını test edin
✅ Çözüm: Veritabanı kullanıcı izinlerini kontrol edin
```

#### 3. "Excel dosyası okunamıyor"
```
✅ Çözüm: cfspreadsheet desteğini kontrol edin
✅ Çözüm: POI kütüphanelerinin yüklü olduğundan emin olun
✅ Çözüm: Excel dosyasının bozuk olmadığından emin olun
```

#### 4. "ETA_KODU bulunamadı"
```
✅ Çözüm: Excel'in ilk satırında "ETA_KODU" başlığının olduğundan emin olun
✅ Çözüm: Kolon başlıklarında boşluk karakteri olmadığından emin olun
```

### Debug Modu
```
# Debug bilgilerini görmek için URL'e ekleyin:
?debug=true

# Uygulamayı yeniden başlatmak için:
?reload=app
```

## 📈 Performans İpuçları

### Büyük Dosyalar İçin
```cfml
1. requestTimeout süresini artırın
2. Batch işleme ekleyin (1000'lik gruplar)
3. Transaction kullanın
4. Index'leri optimize edin
```

### Bellek Optimizasyonu
```cfml
1. Excel dosyasını parça parça okuyun
2. Gereksiz değişkenleri temizleyin
3. cfspreadsheet yerine POI kullanmayı düşünün
```

## 🔄 Versiyon Geçmişi

### v1.0.0 (Mevcut)
- ✅ Temel Excel import özelliği
- ✅ Önizleme sistemi
- ✅ Hata yakalama
- ✅ Modern UI

### Gelecek Versiyonlar
- 🔄 Batch işleme
- 🔄 Excel template indirme
- 🔄 Veri güncelleme modu
- 🔄 CSV desteği
- 🔄 Multi-sheet desteği

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit yapın (`git commit -m 'Add some AmazingFeature'`)
4. Push yapın (`git push origin feature/AmazingFeature`)
5. Pull Request oluşturun

## 📞 Destek

Sorularınız için:
- 📧 Email: [your-email@domain.com]
- 🐛 Issue açın: [GitHub Issues]
- 📚 Wiki: [Project Wiki]

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

---

**📌 Not:** Bu sistem production ortamında kullanımdan önce test edilmeli ve güvenlik değerlendirmesi yapılmalıdır.
