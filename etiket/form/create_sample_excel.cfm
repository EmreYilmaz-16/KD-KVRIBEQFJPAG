<!--- Excel Örnek Dosya Oluşturucu --->
<cfparam name="url.action" default="">
<cfparam name="url.recordCount" default="10">

<!--- Excel dosyası oluştur --->
<cfif url.action eq "create">
    <cftry>
        <!--- Excel dosyası oluştur --->
        <cfset excelData = []>
        
        <!--- Başlık satırı --->
        <cfset headerRow = {
            "EtaKodu" = "EtaKodu",
            "SeriNo" = "SeriNo", 
            "UretimTarihi" = "Üretim Tarihi",
            "PaketTarihi" = "Paket Tarihi",
            "Barkod" = "Barkod",
            "Miktar" = "Miktar",
            "Marka" = "Marka"
        }>
        <cfset arrayAppend(excelData, headerRow)>
        
        <!--- Örnek veri satırları --->
        <cfset markalar = ["ABC Elektronik", "XYZ Teknoloji", "DEF Endüstri", "GHI Makine", "JKL Otomotiv", "MNO Plastik", "PQR Tekstil", "STU Gıda", "VWX Kimya", "YZA Metal"]>
        <cfset etiketPrefixes = ["ETA", "PRD", "ITM", "SKU", "REF"]>
        
        <cfloop from="1" to="#url.recordCount#" index="i">
            <cfset randomMarka = markalar[randRange(1, arrayLen(markalar))]>
            <cfset randomPrefix = etiketPrefixes[randRange(1, arrayLen(etiketPrefixes))]>
            
            <cfset dataRow = {
                "EtaKodu" = "#randomPrefix##numberFormat(i, '000')#",
                "SeriNo" = "SN#dateFormat(now(), 'yyyy')##numberFormat(i, '00000')#",
                "UretimTarihi" = dateFormat(dateAdd("d", -randRange(1, 90), now()), "dd.mm.yyyy"),
                "PaketTarihi" = dateFormat(dateAdd("d", randRange(1, 10), now()), "dd.mm.yyyy"),
                "Barkod" = "86#randRange(10000, 99999)##randRange(10000, 99999)#",
                "Miktar" = numberFormat(randRange(1, 1000) + (randRange(0, 99) / 100), "0.00"),
                "Marka" = randomMarka
            }>
            <cfset arrayAppend(excelData, dataRow)>
        </cfloop>
        
        <!--- CSV formatında çıktı oluştur (Excel'e import edilebilir) --->
        <cfset csvContent = "">
        <cfloop array="#excelData#" index="row">
            <cfset csvContent = csvContent & '"' & row.EtaKodu & '","' & row.SeriNo & '","' & row.UretimTarihi & '","' & row.PaketTarihi & '","' & row.Barkod & '","' & row.Miktar & '","' & row.Marka & '"' & chr(13) & chr(10)>
        </cfloop>
        
        <!--- Dosyayı indirme için header ayarla --->
        <cfheader name="Content-Disposition" value="attachment; filename=etiket_ornek_#dateFormat(now(), 'yyyymmdd')#_#timeFormat(now(), 'HHmmss')#.csv">
        <cfheader name="Content-Type" value="application/vnd.ms-excel">
        <cfcontent type="application/vnd.ms-excel" variable="#toBinary(toBase64(csvContent))#">
        
        <cfcatch>
            <cfset errorMessage = "Excel dosyası oluşturulamadı: " & cfcatch.message>
        </cfcatch>
    </cftry>
</cfif>

<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Excel Örnek Dosya Oluşturucu</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .sample-table {
            font-size: 12px;
        }
        .download-card {
            border: 2px solid #28a745;
            background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
        }
        .format-info {
            background: #f8f9fa;
            border-left: 4px solid #007bff;
            padding: 15px;
            margin: 15px 0;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-10">
                <div class="card shadow">
                    <div class="card-header bg-success text-white">
                        <h4 class="mb-0">
                            <i class="fas fa-file-excel me-2"></i>
                            Excel Örnek Dosya Oluşturucu
                        </h4>
                    </div>
                    <div class="card-body">
                        
                        <!--- Ana navigasyon --->
                        <div class="mb-4">
                            <a href="index.cfm?fuseaction=objects.emptypopup_import_write_label" class="btn btn-outline-primary me-2">
                                <i class="fas fa-upload me-2"></i>Excel Import
                            </a>
                            <a href="index.cfm?fuseaction=objects.emptypopup_import_write_label_js" class="btn btn-outline-info me-2">
                                <i class="fas fa-code me-2"></i>JS Import
                            </a>
                            
                        </div>

                        <!--- Format Bilgisi --->
                        <div class="format-info">
                            <h6><i class="fas fa-info-circle me-2"></i>Excel Dosya Formatı</h6>
                            <p class="mb-2">Etiket import sistemi için Excel dosyanızda şu sütunlar olmalıdır:</p>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <ul class="mb-0">
                                        <li><strong>EtaKodu:</strong> Ürün ETA kodu (Zorunlu)</li>
                                        <li><strong>SeriNo:</strong> Seri numarası (Zorunlu)</li>
                                        <li><strong>Üretim Tarihi:</strong> Üretim tarihi (dd.mm.yyyy)</li>
                                        <li><strong>Paket Tarihi:</strong> Paketleme tarihi (dd.mm.yyyy)</li>
                                    </ul>
                                </div>
                                <div class="col-md-6">
                                    <ul class="mb-0">
                                        <li><strong>Barkod:</strong> Ürün barkodu</li>
                                        <li><strong>Miktar:</strong> Ürün miktarı (Sayısal)</li>
                                        <li><strong>Marka:</strong> Ürün markası</li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <!--- Örnek dosya oluşturma --->
                        <div class="card download-card">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0">
                                    <i class="fas fa-download me-2"></i>
                                    Örnek Excel Dosyası İndir
                                </h5>
                            </div>
                            <div class="card-body">
                                <p>Test etmek için örnek verilerle dolu bir Excel dosyası oluşturun ve indirin.</p>
                                
                                <form method="get" class="row g-3">
                                    <input type="hidden" name="action" value="create">
                                    
                                    <div class="col-md-4">
                                        <label for="recordCount" class="form-label">Kayıt Sayısı:</label>
                                        <select name="recordCount" id="recordCount" class="form-select">
                                            <option value="5" <cfif url.recordCount eq 5>selected</cfif>>5 Kayıt</option>
                                            <option value="10" <cfif url.recordCount eq 10>selected</cfif>>10 Kayıt</option>
                                            <option value="25" <cfif url.recordCount eq 25>selected</cfif>>25 Kayıt</option>
                                            <option value="50" <cfif url.recordCount eq 50>selected</cfif>>50 Kayıt</option>
                                            <option value="100" <cfif url.recordCount eq 100>selected</cfif>>100 Kayıt</option>
                                            <option value="500" <cfif url.recordCount eq 500>selected</cfif>>500 Kayıt</option>
                                        </select>
                                    </div>
                                    
                                    <div class="col-md-8 d-flex align-items-end">
                                        <button type="submit" class="btn btn-success btn-lg">
                                            <i class="fas fa-download me-2"></i>
                                            Excel Dosyası Oluştur ve İndir
                                        </button>
                                    </div>
                                </form>
                                
                                <div class="mt-3">
                                    <small class="text-muted">
                                        <i class="fas fa-lightbulb me-1"></i>
                                        İndirilen dosya CSV formatında olacak ve Excel'de açılabilir.
                                        Manuel olarak XLSX formatına dönüştürmek isterseniz Excel'de "Farklı Kaydet" kullanın.
                                    </small>
                                </div>
                            </div>
                        </div>

                        <!--- Örnek veri preview --->
                        <div class="mt-4">
                            <h6>Örnek Veri Önizlemesi:</h6>
                            <div class="table-responsive">
                                <table class="table table-sm table-striped sample-table">
                                    <thead class="table-dark">
                                        <tr>
                                            <th>EtaKodu</th>
                                            <th>SeriNo</th>
                                            <th>Üretim Tarihi</th>
                                            <th>Paket Tarihi</th>
                                            <th>Barkod</th>
                                            <th>Miktar</th>
                                            <th>Marka</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>ETA001</td>
                                            <td>SN202500001</td>
                                            <td>15.01.2025</td>
                                            <td>05.02.2025</td>
                                            <td>8612345678901</td>
                                            <td>25.50</td>
                                            <td>ABC Elektronik</td>
                                        </tr>
                                        <tr>
                                            <td>PRD002</td>
                                            <td>SN202500002</td>
                                            <td>20.01.2025</td>
                                            <td>08.02.2025</td>
                                            <td>8687654321098</td>
                                            <td>150.00</td>
                                            <td>XYZ Teknoloji</td>
                                        </tr>
                                        <tr>
                                            <td>ITM003</td>
                                            <td>SN202500003</td>
                                            <td>25.01.2025</td>
                                            <td>10.02.2025</td>
                                            <td>8611223344556</td>
                                            <td>75.25</td>
                                            <td>DEF Endüstri</td>
                                        </tr>
                                        <tr>
                                            <td>SKU004</td>
                                            <td>SN202500004</td>
                                            <td>28.01.2025</td>
                                            <td>12.02.2025</td>
                                            <td>8699887766554</td>
                                            <td>300.75</td>
                                            <td>GHI Makine</td>
                                        </tr>
                                        <tr>
                                            <td>REF005</td>
                                            <td>SN202500005</td>
                                            <td>30.01.2025</td>
                                            <td>15.02.2025</td>
                                            <td>8644556677889</td>
                                            <td>12.00</td>
                                            <td>JKL Otomotiv</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!--- Manuel Excel hazırlama talimatları --->
                        <div class="mt-4">
                            <div class="card">
                                <div class="card-header">
                                    <h6 class="mb-0">
                                        <i class="fas fa-hand-paper me-2"></i>
                                        Manuel Excel Dosyası Hazırlama
                                    </h6>
                                </div>
                                <div class="card-body">
                                    <p>Kendi Excel dosyanızı manuel olarak hazırlamak istiyorsanız:</p>
                                    
                                    <ol>
                                        <li><strong>Yeni Excel Dosyası Oluşturun:</strong> Microsoft Excel'de yeni bir çalışma kitabı açın</li>
                                        
                                        <li><strong>Başlık Satırını Ekleyin:</strong> A1 hücresinden başlayarak şu başlıkları yazın:
                                            <div class="mt-2 p-2 bg-light rounded">
                                                <code>A1: EtaKodu | B1: SeriNo | C1: Üretim Tarihi | D1: Paket Tarihi | E1: Barkod | F1: Miktar | G1: Marka</code>
                                            </div>
                                        </li>
                                        
                                        <li><strong>Veri Satırlarını Ekleyin:</strong> 2. satırdan başlayarak ürün verilerinizi girin</li>
                                        
                                        <li><strong>Veri Formatları:</strong>
                                            <ul class="mt-2">
                                                <li><strong>Tarihler:</strong> dd.mm.yyyy formatında (örn: 15.01.2025)</li>
                                                <li><strong>Miktar:</strong> Sayısal değer, ondalık için nokta kullanın (örn: 25.50)</li>
                                                <li><strong>Barkod:</strong> Sayı veya metin, boşluk olmadan</li>
                                            </ul>
                                        </li>
                                        
                                        <li><strong>Dosyayı Kaydedin:</strong> .xlsx veya .xls formatında kaydedin</li>
                                    </ol>
                                    
                                    <div class="alert alert-warning mt-3">
                                        <i class="fas fa-exclamation-triangle me-2"></i>
                                        <strong>Önemli Notlar:</strong>
                                        <ul class="mb-0 mt-2">
                                            <li>İlk satır mutlaka başlık satırı olmalıdır</li>
                                            <li>EtaKodu ve SeriNo alanları zorunludur</li>
                                            <li>Boş satırlar import sırasında atlanacaktır</li>
                                            <li>Hatalı tarih formatları sistem tarafından boş olarak işlenecektir</li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!--- Sistem test alanı --->
                        <div class="mt-4">
                            <div class="card border-info">
                                <div class="card-header bg-info text-white">
                                    <h6 class="mb-0">
                                        <i class="fas fa-vial me-2"></i>
                                        Sistem Testi
                                    </h6>
                                </div>
                                <div class="card-body">
                                    <p>Excel dosyanızı hazırladıktan sonra sistemi test etmek için:</p>
                                    
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="d-grid">
                                                <a href="index.cfm?fuseaction=objects.emptypopup_import_write_label" class="btn btn-primary">
                                                    <i class="fas fa-upload me-2"></i>
                                                    Excel Import (Apache POI)
                                                </a>
                                            </div>
                                            <small class="text-muted mt-1 d-block">Server-side işleme, POI gerektirir</small>
                                        </div>
                                        
                                        <div class="col-md-6">
                                            <div class="d-grid">
                                                <a href="index.cfm?fuseaction=objects.emptypopup_import_write_label_js" class="btn btn-success">
                                                    <i class="fas fa-code me-2"></i>
                                                    JavaScript Import
                                                </a>
                                            </div>
                                            <small class="text-muted mt-1 d-block">Client-side işleme, POI gerektirmez</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
