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
                        <small class="text-muted">
                            Dosya: #getImportInfo.file_name# | 
                            İmport: #DateFormat(getImportInfo.import_date, "dd/mm/yyyy")# #TimeFormat(getImportInfo.import_date, "HH:mm")#
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
                            
                            <cfif len(trim(barkod)) gt 0>
                                <div class="barcode-section">
                                    <div style="font-size: 10px; margin-bottom: 5px;">BARKOD:</div>
                                    <div class="barcode-display">*#barkod#*</div>
                                    <div style="font-size: 9px; letter-spacing: 1px;">#barkod#</div>
                                </div>
                            </cfif>

                            <!-- QR Code için placeholder -->
                            <div class="qr-code">
                                <canvas id="qr_#temp_id#" width="80" height="80"></canvas>
                            </div>
                        </div>
                    </div>
                </cfloop>
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
        <cfloop query="getLabelData">
            document.addEventListener('DOMContentLoaded', function() {
                const qrData = JSON.stringify({
                    eta_kodu: '#JSStringFormat(eta_kodu)#',
                    seri_no: '#JSStringFormat(seri_no)#',
                    marka: '#JSStringFormat(marka)#',
                    barkod: '#JSStringFormat(barkod)#'
                });
                
                QRCode.toCanvas(document.getElementById('qr_#temp_id#'), qrData, {
                    width: 80,
                    height: 80,
                    margin: 1,
                    color: {
                        dark: '#000000',
                        light: '#FFFFFF'
                    }
                }, function (error) {
                    if (error) console.error(error);
                });
            });
        </cfloop>

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
