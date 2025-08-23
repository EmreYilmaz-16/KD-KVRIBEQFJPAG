<!--- Etiket Görüntüleme ve Yazdırma Sayfası --->
<cfparam name="url.import_id" default="0">
<cfparam name="url.page" default="1">
<cfparam name="url.per_page" default="20">

<!--- Custom tag için gerekli değişkenler --->
<cfset upload_folder = ExpandPath(".")>
<cfset dir_seperator = "/">
<cfif FindNoCase("Windows", server.os.name)>
    <cfset dir_seperator = "\">
</cfif>

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
    <cflocation url="index.cfm?fuseaction=objects.emptypopup_import_write_label" addtoken="false">
</cfif>

<!--- Sayfalama hesaplamaları - gerçek kayıt sayısına göre yap --->
<cfquery name="getTotalRecordsForPaging" datasource="w3Qa">
    SELECT COUNT(*) as total_count
    FROM etiket_temp_data 
    WHERE import_id = <cfqueryparam value="#url.import_id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset offset = (url.page - 1) * url.per_page>
<cfset totalPages = ceiling(getTotalRecordsForPaging.total_count / url.per_page)>
<cflog file="etiket_import" text="view_labels.cfm: Pagination - total_count=#getTotalRecordsForPaging.total_count#, totalPages=#totalPages#, offset=#offset#">

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
    ORDER BY row_number, temp_id
    OFFSET #offset# ROWS 
    FETCH NEXT #url.per_page# ROWS ONLY
</cfquery>

<!--- Debug: Log query results --->
<cflog file="etiket_import" text="view_labels.cfm: import_id=#url.import_id#, found #getLabelData.recordCount# records">

<!--- Debug: Total records in temp table for this import --->
<cfquery name="getTotalRecords" datasource="w3Qa">
    SELECT COUNT(*) as total_count
    FROM etiket_temp_data 
    WHERE import_id = <cfqueryparam value="#url.import_id#" cfsqltype="cf_sql_integer">
</cfquery>
<cflog file="etiket_import" text="view_labels.cfm: Total records in temp table for import_id #url.import_id#: #getTotalRecords.total_count#">

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
                grid-template-columns: 1fr;
                gap: 0;
            }
            
            .label-item {
                border: 2px solid #000;
                margin: 0;
                padding: 20px;
                font-size: 12px;
                page-break-after: always;
                page-break-inside: avoid;
                width: 100%;
                height: auto;
                min-height: 50vh;
                display: block;
            }
            
            .label-item:last-child {
                page-break-after: auto;
            }
            
            .qr-code canvas {
                max-width: 120px !important;
                max-height: 120px !important;
            }
            
            body {
                margin: 0;
                padding: 0;
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
                        <a href="index.cfm?fuseaction=objects.emptypopup_import_write_label" class="btn btn-outline-primary">
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
                            <span><cfoutput>Sayfa #url.page# / #totalPages#</cfoutput></span>
                            <span class="text-muted">|</span>
                            <span><cfoutput>Toplam #getImportInfo.success_records# etiket</cfoutput></span>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <nav aria-label="Sayfalama">
                            <ul class="pagination pagination-sm justify-content-end mb-0">
                                <cfif url.page gt 1>
                                    <li class="page-item">
                                        <a class="page-link" href="index.cfm?fuseaction=objects.emptypopup_view_labels<cfoutput>&import_id=#url.import_id#&page=#url.page - 1#&per_page=#url.per_page#</cfoutput>">
                                            <i class="fas fa-chevron-left"></i>
                                        </a>
                                    </li>
                                </cfif>
                                
                                <cfloop from="#max(1, url.page - 2)#" to="#min(totalPages, url.page + 2)#" index="pageNum">
                                    <li class="page-item #iif(pageNum eq url.page, 'active', '')#">
                                        <a class="page-link" href="index.cfm?fuseaction=objects.emptypopup_view_labels<cfoutput>&import_id=#url.import_id#&page=#pageNum#&per_page=#url.per_page#</cfoutput>">
                                            <cfoutput>#pageNum#</cfoutput>
                                        </a>
                                    </li>
                                </cfloop>
                                
                                <cfif url.page lt totalPages>
                                    <li class="page-item">
                                        <a class="page-link" href="index.cfm?fuseaction=objects.emptypopup_view_labels<cfoutput>&import_id=#url.import_id#&page=#url.page + 1#&per_page=#url.per_page#</cfoutput>">
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
                    <!--- Ürün bilgisini bir kez al --->
                    <cfquery name="getStok" datasource="w3Qa">
                        SELECT TOP 1 PRODUCT_NAME 
                        FROM PBS_GETSTOCK 
                        WHERE PRODUCT_CODE_2 = <cfqueryparam value="#eta_kodu#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                    
                    <!--- Miktar kadar etiket oluştur --->
                    <cfloop from="1" to="#Int(miktar)#" index="etiket_no">
                        <!--- Her etiket için yeni seri numarası üret --->
                        <cfset yeni_seri_no = seri_no >
                        <div>
                            <cfset qr_data = "#eta_kodu#_#yeni_seri_no#_#DateFormat(uretim_tarihi, 'mm.yy')#_#DateFormat(paket_tarihi, 'mm/yy')#_#barkod#_1.00_#marka#">
                                    <cfset qr_id = "qr_#temp_id#_#etiket_no#_#getTickCount()#">
                              <cftry>
                                        <cf_pbs_barcode 
                                            value="#qr_data#" 
                                            type="qrcode" 
                                            width="100" 
                                            height="100" 
                                            show="1" 
                                            id="#qr_id#"
                                            path="#ExpandPath('../temp/')#"
                                            format="png">
                                    <cfcatch>
                                        <!--- Hata durumunda basit QR placeholder göster --->
                                        <div style="width: 100px; height: 100px; border: 2px solid ##000; display: flex; align-items: center; justify-content: center; font-size: 10px; text-align: center;">
                                            QR KOD<br>OLUŞTURULUYOR
                                        </div>
                                    </cfcatch>
                                    </cftry>
                        </div>
                        <!-----<div class="label-item">
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
                                    <span>#yeni_seri_no#</span>
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
                                    <span>1.00</span> <!--- Her etiket için miktar 1 --->
                                </div>
                                <div class="label-field">
                                    <strong>Etiket:</strong>
                                    <span>#etiket_no# / #Int(miktar)#</span> <!--- Kaçıncı etiket olduğunu göster --->
                                </div>
                                <div class="label-field">
                                    <strong>Ürün:</strong>
                                    <span <cfif getStok.recordCount><cfelse>style='color:red;font-weight:bold'</cfif> > <cfif getStok.recordCount> #getStok.PRODUCT_NAME#<cfelse>Ürün Sisteme Kayıtlı Değil </cfif></span>
                                </div>

                                <!-- QR Code ile Birleştirilmiş Veri -->
                                <div class="qr-code">
                                    <div style="font-size: 10px; margin-bottom: 8px; font-weight: bold;">QR KOD:</div>
                                    
                                    <!--- Workcube Barcode Custom Tag ile QR kod oluştur --->
                                    <cfset qr_data = "#eta_kodu#_#yeni_seri_no#_#DateFormat(uretim_tarihi, 'mm.yy')#_#DateFormat(paket_tarihi, 'mm/yy')#_#barkod#_1.00_#marka#">
                                    <cfset qr_id = "qr_#temp_id#_#etiket_no#_#getTickCount()#">
                                
                                    
                                    <cftry>
                                        <cf_pbs_barcode 
                                            value="#qr_data#" 
                                            type="qrcode" 
                                            width="100" 
                                            height="100" 
                                            show="1" 
                                            id="#qr_id#"
                                            path="#ExpandPath('../temp/')#"
                                            format="png">
                                    <cfcatch>
                                        <!--- Hata durumunda basit QR placeholder göster --->
                                        <div style="width: 100px; height: 100px; border: 2px solid ##000; display: flex; align-items: center; justify-content: center; font-size: 10px; text-align: center;">
                                            QR KOD<br>OLUŞTURULUYOR
                                        </div>
                                    </cfcatch>
                                    </cftry>
                                    
                                    <div style="font-size: 8px; margin-top: 5px; word-break: break-all; line-height: 1.2;">
                                        #qr_data#
                                    </div>
                                </div>
                            </div>
                        </div>---->
                    </cfloop> <!--- Etiket sayısı döngüsü sonu --->
                </cfloop> <!--- Ana veri döngüsü sonu --->
                </cfoutput>
            </div>            <cfif getLabelData.recordCount eq 0>
                <div class="alert alert-warning text-center">
                    <h5><i class="fas fa-exclamation-triangle me-2"></i>Etiket Bulunamadı</h5>
                    <p>Bu import için etiket verisi bulunamadı.</p>
                    <a href="index.cfm?fuseaction=objects.emptypopup_import_write_label" class="btn btn-primary">
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
                               <cfoutput>    <li class="page-item">
                                        <a class="page-link" href="index.cfm?fuseaction=objects.emptypopup_view_labels&import_id=#url.import_id#&page=1&per_page=#url.per_page#">
                                            <i class="fas fa-angle-double-left"></i> İlk
                                        </a>
                                    </li>
                                    <li class="page-item">
                                        <a class="page-link" href="index.cfm?fuseaction=objects.emptypopup_view_labels&import_id=#url.import_id#&page=#url.page - 1#&per_page=#url.per_page#">
                                            <i class="fas fa-chevron-left"></i> Önceki
                                        </a>
                                    </li>
                                    </cfoutput> 
                                </cfif>
                                
                                <cfloop from="#max(1, url.page - 5)#" to="#min(totalPages, url.page + 5)#" index="pageNum">
                                    <li class="page-item #iif(pageNum eq url.page, 'active', '')#">
                                        <a class="page-link" href="index.cfm?fuseaaction=objects.emptypopup_view_labels<cfoutput>&import_id=#url.import_id#&page=#pageNum#&per_page=#url.per_page#</cfoutput>">
                                           <cfoutput>#pageNum#</cfoutput>
                                        </a>
                                    </li>
                                </cfloop>
                                
                                <cfif url.page lt totalPages>
                                    <li class="page-item">
                                        <a class="page-link" href="index.cfm?fuseaction=objects.emptypopup_view_labels<cfoutput>&import_id=#url.import_id#&page=#url.page + 1#&per_page=#url.per_page#</cfoutput>">
                                            Sonraki <i class="fas fa-chevron-right"></i>
                                        </a>
                                    </li>
                                    <li class="page-item">
                                        <a class="page-link" href="index.cfm?fuseaction=objects.emptypopup_view_labels<cfoutput>&import_id=#url.import_id#&page=#totalPages#&per_page=#url.per_page#</cfoutput>">
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

        // Sayfa yüklendiğinde başlat
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Etiket sayfası yüklendi - Workcube Barcode Custom Tag kullanılıyor');
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
                    window.location.href = 'index.cfm?fuseaction=objects.emptypopup_view_labels<cfoutput>&import_id=#url.import_id#&page=#url.page - 1#&per_page=#url.per_page#</cfoutput>';
                </cfif>
            }
            if (e.key === 'ArrowRight' && e.altKey) {
                <cfif url.page lt totalPages>
                    window.location.href = 'index.cfm?fuseaction=objects.emptypopup_view_labels<cfoutput>&import_id=#url.import_id#&page=#url.page + 1#&per_page=#url.per_page#</cfoutput>';
                </cfif>
            }
        });
    </script>
</body>
</html>
