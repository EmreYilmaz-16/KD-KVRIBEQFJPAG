<!--- Etiket Görüntüleme ve Yazdırma Sayfası --->
<cfparam name="url.import_id" default="0">
<cfparam name="url.page" default="1">
<cfparam name="url.per_page" default="20">

<!--- Import bilgilerini al --->
<cfquery name="getImportInfo" datasource="w3Qa">
    SELECT 
        import_id,
        import_date,
        file_name,
        total_records,
        success_records,
        error_records
    FROM etiket_import_log 
    WHERE import_id = <cfqueryparam value="#url.import_id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif getImportInfo.recordCount eq 0>
    <cflocation url="import_etiket.cfm" addtoken="false">
</cfif>

<!--- Sayfalama hesaplamaları --->
<cfset offset = (url.page - 1) * url.per_page>
<cfset totalPages = ceiling(getImportInfo.success_records / url.per_page)>

<!--- Etiket verilerini al --->
<cfquery name="getLabelData" datasource="w3Qa">
    SELECT 
        temp_id,
        eta_kodu,
        seri_no,
        uretim_tarihi,
        paket_tarihi,
        barkod,
        miktar,
        marka,
        row_number
    FROM etiket_temp_data 
    WHERE import_id = <cfqueryparam value="#url.import_id#" cfsqltype="cf_sql_integer">
    ORDER BY row_number
    OFFSET #offset# ROWS 
    FETCH NEXT #url.per_page# ROWS ONLY
</cfquery>

<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Etiket Yazdırma</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .step-indicator {
            margin-bottom: 30px;
        }
        .step {
            display: inline-block;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            background: #dee2e6;
            color: #6c757d;
            text-align: center;
            line-height: 30px;
            margin-right: 10px;
            font-weight: bold;
        }
        .step.active {
            background: #007bff;
            color: white;
        }
        .step.completed {
            background: #28a745;
            color: white;
        }

        /* Etiket Stilleri */
        .label-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .label-item {
            border: 2px solid #333;
            padding: 15px;
            background: white;
            page-break-inside: avoid;
            break-inside: avoid;
            font-family: 'Courier New', monospace;
        }
        
        .label-header {
            text-align: center;
            border-bottom: 1px solid #333;
            padding-bottom: 8px;
            margin-bottom: 10px;
            font-weight: bold;
            font-size: 16px;
        }
        
        .label-content {
            font-size: 12px;
            line-height: 1.4;
        }
        
        .label-field {
            margin-bottom: 5px;
            display: flex;
            justify-content: space-between;
        }
        
        .label-field strong {
            min-width: 100px;
        }
        
        .barcode-section {
            text-align: center;
            margin-top: 10px;
            padding-top: 8px;
            border-top: 1px solid #333;
        }
        
        .barcode-display {
            font-family: 'Libre Barcode 39', monospace;
            font-size: 24px;
            letter-spacing: 2px;
            margin: 5px 0;
        }
        
        .qr-code {
            margin: 10px auto;
            text-align: center;
        }

        .qr-data-text {
            font-size: 8px;
            color: #666;
            margin-top: 5px;
            word-break: break-all;
            line-height: 1.2;
            font-family: 'Courier New', monospace;
        }

        /* Yazdırma Stilleri */
        @media print {
            .no-print {
                display: none !important;
            }
            
            .label-container {
                grid-template-columns: repeat(2, 1fr);
                gap: 10px;
            }
            
            .label-item {
                border: 2px solid #000;
                margin-bottom: 10px;
                font-size: 11px;
            }
            
            .qr-code canvas {
                max-width: 80px !important;
                max-height: 80px !important;
            }
            
            body {
                margin: 0;
                padding: 10px;
            }
            
            .container {
                max-width: none;
                padding: 0;
            }
        }

        /* Etiket Boyut Seçenekleri */
        .label-size-small .label-item {
            padding: 8px;
            font-size: 10px;
        }
        
        .label-size-small .label-header {
            font-size: 12px;
        }
        
        .label-size-medium .label-item {
            padding: 12px;
            font-size: 11px;
        }
        
        .label-size-large .label-item {
            padding: 18px;
            font-size: 13px;
        }

        .toolbar {
            position: sticky;
            top: 0;
            background: white;
            z-index: 1000;
            border-bottom: 1px solid #dee2e6;
            padding: 15px 0;
            margin-bottom: 20px;
        }

        .pagination-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }
    </style>
    <link href="https://fonts.googleapis.com/css2?family=Libre+Barcode+39&display=swap" rel="stylesheet">
</head>
<body>
    <div class="container-fluid">
        <!-- Toolbar -->
        <div class="toolbar no-print">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <h4 class="mb-0">
                            <i class="fas fa-tags me-2"></i>
                            Etiket Yazdırma
                        </h4>
                   <cfoutput>   <small class="text-muted">
                            Dosya: #getImportInfo.file_name# | 
                            İmport: #DateFormat(getImportInfo.import_date, "dd/mm/yyyy")# #TimeFormat(getImportInfo.import_date, "HH:mm")#
                            </cfoutput>  
                        </small>
                    </div>
                    <div class="col-md-6 text-end">
                        <div class="btn-group me-2">
                            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="changeLabelSize('small')">
                                <i class="fas fa-compress-alt"></i> Küçük
                            </button>
                            <button type="button" class="btn btn-outline-secondary btn-sm active" onclick="changeLabelSize('medium')">
                                <i class="fas fa-expand-arrows-alt"></i> Orta
                            </button>
                            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="changeLabelSize('large')">
                                <i class="fas fa-expand-alt"></i> Büyük
                            </button>
                        </div>
                        <button type="button" class="btn btn-success" onclick="window.print()">
                            <i class="fas fa-print me-2"></i>Yazdır
                        </button>
                        <a href="import_etiket.cfm" class="btn btn-outline-primary">
                            <i class="fas fa-arrow-left me-2"></i>Ana Sayfa
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="container">
            <!-- Adım Göstergesi -->
            <div class="step-indicator no-print">
                <span class="step completed">1</span>
                <span>Dosya Yükle</span>
                <i class="fas fa-arrow-right mx-3 text-muted"></i>
                <span class="step completed">2</span>
                <span>Veri İşle</span>
                <i class="fas fa-arrow-right mx-3 text-muted"></i>
                <span class="step active">3</span>
                <span>Etiket Yazdır</span>
            </div>
<cfoutput> 
            <!-- İstatistikler -->
            <div class="row mb-4 no-print">
                <div class="col-md-3">
                    <div class="card text-center">
                        <div class="card-body">
                            <h5 class="card-title text-primary">#getImportInfo.total_records#</h5>
                            <p class="card-text small">Toplam Satır</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center">
                        <div class="card-body">
                            <h5 class="card-title text-success">#getImportInfo.success_records#</h5>
                            <p class="card-text small">Başarılı</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center">
                        <div class="card-body">
                            <h5 class="card-title text-danger">#getImportInfo.error_records#</h5>
                            <p class="card-text small">Hatalı</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center">
                        <div class="card-body">
                            <h5 class="card-title text-info">#getLabelData.recordCount#</h5>
                            <p class="card-text small">Bu Sayfada</p>
                        </div>
                    </div>
                </div>
            </div>
</cfoutput>
            <!-- Sayfalama (Üst) -->
            <cfif totalPages gt 1>
                <div class="row mb-3 no-print">
                    <div class="col-md-6">
                        <div class="pagination-info">
                            <span>Sayfa #url.page# / #totalPages#</span>
                            <span class="text-muted">|</span>
                            <span>Toplam #getImportInfo.success_records# etiket</span>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <nav aria-label="Sayfalama">
                            <ul class="pagination pagination-sm justify-content-end mb-0">
                                <cfif url.page gt 1>
                                    <li class="page-item">
                                        <a class="page-link" href="?import_id=#url.import_id#&page=#url.page - 1#&per_page=#url.per_page#">
                                            <i class="fas fa-chevron-left"></i>
                                        </a>
                                    </li>
                                </cfif>
                                
                                <cfloop from="#max(1, url.page - 2)#" to="#min(totalPages, url.page + 2)#" index="pageNum">
                                    <li class="page-item #iif(pageNum eq url.page, 'active', '')#">
                                        <a class="page-link" href="?import_id=#url.import_id#&page=#pageNum#&per_page=#url.per_page#">
                                            #pageNum#
                                        </a>
                                    </li>
                                </cfloop>
                                
                                <cfif url.page lt totalPages>
                                    <li class="page-item">
                                        <a class="page-link" href="?import_id=#url.import_id#&page=#url.page + 1#&per_page=#url.per_page#">
                                            <i class="fas fa-chevron-right"></i>
                                        </a>
                                    </li>
                                </cfif>
                            </ul>
                        </nav>
                    </div>
                </div>
            </cfif>

            <!-- Etiketler -->
            <div class="label-container label-size-medium" id="labelContainer">
                <cfoutput> 
                <cfloop query="getLabelData">
                    <div class="label-item">
                        <div class="label-header">
                            #marka# - ÜRÜN ETİKETİ
                        </div>
                        <div class="label-content">
                            <div class="label-field">
                                <strong>ETA Kodu:</strong>
                                <span>#eta_kodu#</span>
                            </div>
                            <div class="label-field">
                                <strong>Seri No:</strong>
                                <span>#seri_no#</span>
                            </div>
                            <cfif isDate(uretim_tarihi)>
                                <div class="label-field">
                                    <strong>Üretim:</strong>
                                    <span>#DateFormat(uretim_tarihi, "dd/mm/yyyy")#</span>
                                </div>
                            </cfif>
                            <cfif isDate(paket_tarihi)>
                                <div class="label-field">
                                    <strong>Paket:</strong>
                                    <span>#DateFormat(paket_tarihi, "dd/mm/yyyy")#</span>
                                </div>
                            </cfif>
                            <div class="label-field">
                                <strong>Miktar:</strong>
                                <span>#NumberFormat(miktar, "0.00")#</span>
                            </div>

                            <!-- QR Code ile Birleştirilmiş Veri -->
                            <div class="qr-code">
                                <div style="font-size: 10px; margin-bottom: 8px; font-weight: bold;">QR KOD:</div>
                                <canvas id="qr_#temp_id#" width="100" height="100"></canvas>
                                <div style="font-size: 8px; margin-top: 5px; word-break: break-all; line-height: 1.2;">
                                    #eta_kodu#_#seri_no#_<cfif isDate(uretim_tarihi)>#DateFormat(uretim_tarihi, "ddmmyyyy")#<cfelse>-</cfif>_<cfif isDate(paket_tarihi)>#DateFormat(paket_tarihi, "ddmmyyyy")#<cfelse>-</cfif>_#barkod#_#NumberFormat(miktar, "0.00")#_#marka#
                                </div>
                            </div>
                        </div>
                    </div>
                </cfloop>
                </cfoutput>
            </div>

            <cfif getLabelData.recordCount eq 0>
                <div class="alert alert-warning text-center">
                    <h5><i class="fas fa-exclamation-triangle me-2"></i>Etiket Bulunamadı</h5>
                    <p>Bu import için etiket verisi bulunamadı.</p>
                    <a href="import_etiket.cfm" class="btn btn-primary">
                        <i class="fas fa-arrow-left me-2"></i>Ana Sayfaya Dön
                    </a>
                </div>
            </cfif>

            <!-- Sayfalama (Alt) -->
            <cfif totalPages gt 1>
                <div class="row mt-4 no-print">
                    <div class="col-12">
                        <nav aria-label="Sayfalama">
                            <ul class="pagination justify-content-center">
                                <cfif url.page gt 1>
                                    <li class="page-item">
                                        <a class="page-link" href="?import_id=#url.import_id#&page=1&per_page=#url.per_page#">
                                            <i class="fas fa-angle-double-left"></i> İlk
                                        </a>
                                    </li>
                                    <li class="page-item">
                                        <a class="page-link" href="?import_id=#url.import_id#&page=#url.page - 1#&per_page=#url.per_page#">
                                            <i class="fas fa-chevron-left"></i> Önceki
                                        </a>
                                    </li>
                                </cfif>
                                
                                <cfloop from="#max(1, url.page - 5)#" to="#min(totalPages, url.page + 5)#" index="pageNum">
                                    <li class="page-item #iif(pageNum eq url.page, 'active', '')#">
                                        <a class="page-link" href="?import_id=#url.import_id#&page=#pageNum#&per_page=#url.per_page#">
                                            #pageNum#
                                        </a>
                                    </li>
                                </cfloop>
                                
                                <cfif url.page lt totalPages>
                                    <li class="page-item">
                                        <a class="page-link" href="?import_id=#url.import_id#&page=#url.page + 1#&per_page=#url.per_page#">
                                            Sonraki <i class="fas fa-chevron-right"></i>
                                        </a>
                                    </li>
                                    <li class="page-item">
                                        <a class="page-link" href="?import_id=#url.import_id#&page=#totalPages#&per_page=#url.per_page#">
                                            Son <i class="fas fa-angle-double-right"></i>
                                        </a>
                                    </li>
                                </cfif>
                            </ul>
                        </nav>
                    </div>
                </div>
            </cfif>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js"></script>
    <script>
        // QRCode kütüphanesinin yüklendiğini kontrol et
        function checkQRCodeLibrary() {
            if (typeof QRCode === 'undefined') {
                console.error('QRCode kütüphanesi yüklenemedi, basit QR kod gösterimi kullanılacak...');
                showSimpleQRCodes();
                return false;
            }
            return true;
        }

        function showSimpleQRCodes() {
            console.log('Basit QR kod gösterimi başlatılıyor...');
            document.querySelectorAll('[id^="qr_"]').forEach(canvas => {
                try {
                    const ctx = canvas.getContext('2d');
                    // QR kod benzeri görsel oluştur
                    ctx.fillStyle = '#000000';
                    
                    // QR kod benzeri desen çiz
                    for(let i = 0; i < 10; i++) {
                        for(let j = 0; j < 10; j++) {
                            if((i + j) % 2 === 0) {
                                ctx.fillRect(i * 10, j * 10, 8, 8);
                            }
                        }
                    }
                    
                    // Köşe kareler (QR kod benzeri)
                    ctx.fillStyle = '#000000';
                    ctx.fillRect(0, 0, 25, 25);
                    ctx.fillRect(75, 0, 25, 25);
                    ctx.fillRect(0, 75, 25, 25);
                    
                    ctx.fillStyle = '#ffffff';
                    ctx.fillRect(5, 5, 15, 15);
                    ctx.fillRect(80, 5, 15, 15);
                    ctx.fillRect(5, 80, 15, 15);
                    
                    ctx.fillStyle = '#000000';
                    ctx.fillRect(10, 10, 5, 5);
                    ctx.fillRect(85, 10, 5, 5);
                    ctx.fillRect(10, 85, 5, 5);
                    
                } catch(e) {
                    console.error('Canvas çizimi hatası:', e);
                }
            });
        }

        // Etiket boyutu değiştirme
        function changeLabelSize(size) {
            const container = document.getElementById('labelContainer');
            container.className = container.className.replace(/label-size-\w+/, 'label-size-' + size);
            
            // Aktif buton güncelle
            document.querySelectorAll('.btn-group .btn').forEach(btn => {
                btn.classList.remove('active');
            });
            event.target.classList.add('active');
        }

        // QR kodlarını oluştur
        function generateQRCodes() {
            console.log('QR kod oluşturma başlatılıyor...');
            
            <cfloop query="getLabelData">
               <cfoutput>
                try {
                    const qrData_#temp_id# = '#JSStringFormat(eta_kodu)#_#JSStringFormat(seri_no)#_<cfif isDate(uretim_tarihi)>#DateFormat(uretim_tarihi, "ddmmyyyy")#<cfelse>-</cfif>_<cfif isDate(paket_tarihi)>#DateFormat(paket_tarihi, "ddmmyyyy")#<cfelse>-</cfif>_#JSStringFormat(barkod)#_#NumberFormat(miktar, "0.00")#_#JSStringFormat(marka)#';
                    
                    console.log('QR Data #temp_id#:', qrData_#temp_id#);
                    
                    const canvas = document.getElementById('qr_#temp_id#');
                    if (!canvas) {
                        console.error('Canvas bulunamadı: qr_#temp_id#');
                        return;
                    }
                    
                    if (typeof QRCode !== 'undefined' && QRCode.toCanvas) {
                        // Ana QRCode kütüphanesi
                        QRCode.toCanvas(canvas, qrData_#temp_id#, {
                            width: 100,
                            height: 100,
                            margin: 2,
                            color: {
                                dark: '#000000',
                                light: '#FFFFFF'
                            },
                            errorCorrectionLevel: 'M'
                        }, function (error) {
                            if (error) {
                                console.error('QR Kod oluşturma hatası #temp_id#:', error);
                                drawFallbackQR(canvas, qrData_#temp_id#);
                            } else {
                                console.log('QR Kod başarıyla oluşturuldu #temp_id#');
                            }
                        });
                    } else {
                        // Fallback: Basit görsel QR kod
                        console.log('QRCode kütüphanesi bulunamadı, fallback çiziliyor #temp_id#');
                        drawFallbackQR(canvas, qrData_#temp_id#);
                    }
                } catch (e) {
                    console.error('QR kod oluşturma genel hatası #temp_id#:', e);
                }
                </cfoutput>
            </cfloop>
        }
        
        // Fallback QR kod çizimi
        function drawFallbackQR(canvas, data) {
            try {
                const ctx = canvas.getContext('2d');
                ctx.clearRect(0, 0, 100, 100);
                
                // Arka plan
                ctx.fillStyle = '#ffffff';
                ctx.fillRect(0, 0, 100, 100);
                
                // QR kod benzeri desen
                ctx.fillStyle = '#000000';
                
                // Basit QR kod deseni oluştur
                const size = 5;
                const hash = data.split('').reduce((a, b) => {
                    a = ((a << 5) - a) + b.charCodeAt(0);
                    return a & a;
                }, 0);
                
                for(let i = 0; i < 20; i++) {
                    for(let j = 0; j < 20; j++) {
                        if((hash + i + j) % 3 === 0) {
                            ctx.fillRect(i * size, j * size, size - 1, size - 1);
                        }
                    }
                }
                
                // Köşe işaretleri
                ctx.fillStyle = '#000000';
                ctx.fillRect(0, 0, 20, 20);
                ctx.fillRect(80, 0, 20, 20);
                ctx.fillRect(0, 80, 20, 20);
                
                ctx.fillStyle = '#ffffff';
                ctx.fillRect(5, 5, 10, 10);
                ctx.fillRect(85, 5, 10, 10);
                ctx.fillRect(5, 85, 10, 10);
                
                console.log('Fallback QR kod çizildi');
            } catch(e) {
                console.error('Fallback QR çizim hatası:', e);
            }
        }

        // Sayfa yüklendiğinde başlat
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Sayfa yüklendi, QR kodlar oluşturuluyor...');
            
            // DOM elementlerinin hazır olduğundan emin ol
            setTimeout(() => {
                console.log('Canvas elementleri kontrol ediliyor...');
                const canvasElements = document.querySelectorAll('[id^="qr_"]');
                console.log('Bulunan canvas sayısı:', canvasElements.length);
                
                if (canvasElements.length === 0) {
                    console.error('Hiç canvas elementi bulunamadı!');
                    return;
                }
                
                // QRCode kütüphanesini kontrol et ve QR kodları oluştur
                if (checkQRCodeLibrary()) {
                    generateQRCodes();
                }
            }, 1000); // 1 saniye bekle
        });

        // Yazdırma öncesi ayarlar
        window.addEventListener('beforeprint', function() {
            // Yazdırma için sayfa düzenini optimize et
            document.body.style.fontSize = '12px';
        });

        window.addEventListener('afterprint', function() {
            // Yazdırma sonrası normal boyuta dön
            document.body.style.fontSize = '';
        });

        // Klavye kısayolları
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey && e.key === 'p') {
                e.preventDefault();
                window.print();
            }
            if (e.key === 'ArrowLeft' && e.altKey) {
                <cfif url.page gt 1>
                    window.location.href = '?import_id=#url.import_id#&page=#url.page - 1#&per_page=#url.per_page#';
                </cfif>
            }
            if (e.key === 'ArrowRight' && e.altKey) {
                <cfif url.page lt totalPages>
                    window.location.href = '?import_id=#url.import_id#&page=#url.page + 1#&per_page=#url.per_page#';
                </cfif>
            }
        });
    </script>
</body>
</html>
