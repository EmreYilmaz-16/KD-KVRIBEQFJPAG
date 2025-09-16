<!--- Etiket Görüntüleme ve Yazdırma Sayfası --->
<cfparam name="url.import_id" default="0">
<cfparam name="url.page" default="1">
<cfparam name="url.per_page" default="5">

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
        /* Adım göstergesi kapsayıcısı: üstteki süreç adımlarına boşluk bırakır */
        .step-indicator {
            margin-bottom: 30px;
        }
        /* Adım balonları için temel görünüm */
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
        /* Aktif adımın vurgusu */
        .step.active {
            background: #007bff;
            color: white;
        }
        /* Tamamlanan adımların rengi */
        .step.completed {
            background: #28a745;
            color: white;
        }

        /* Etiket kartlarını listeleyen kapsayıcı: responsive grid düzeni */
        .label-container {
            display: grid;
             grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px; 
        }
        
        /* Tek bir etiket kartının görsel stili */
        .label-item {
            border: 2px solid #333;
            padding: 15px;
            background: white;
            page-break-inside: avoid;
            break-inside: avoid;
            font-family: 'Courier New', monospace;
        }
        
        /* Etiket başlığı (üst bant) */
        .label-header {
            text-align: center;
            border-bottom: 1px solid #333;
            padding-bottom: 8px;
            margin-bottom: 10px;
            font-weight: bold;
            font-size: 16px;
        }
        
        /* Etiket içeriği metin boyutu ve satır aralığı */
        .label-content {
            font-size: 12px;
            line-height: 1.4;
        }
        
        /* Etiket içi satırlar: sol-sağ alanlar */
        .label-field {
            margin-bottom: 5px;
            display: flex;
            justify-content: space-between;
        }
        
        /* Sol taraftaki başlık alanı min genişlik */
        .label-field strong {
            min-width: 100px;
        }
        
        /* Barkod/QR bölümünün üst sınırı ve hizası */
        .barcode-section {
            text-align: center;
            margin-top: 10px;
            padding-top: 8px;
            border-top: 1px solid #333;
        }
        
        /* Yazı tipi ve görünüm olarak Code39 tipli barkod yazısı */
        .barcode-display {
            font-family: 'Libre Barcode 39', monospace;
            font-size: 24px;
            letter-spacing: 2px;
            margin: 5px 0;
        }
        
        /* QR kod kapsayıcısı */
        .qr-code {
            margin: 10px auto;
            text-align: center;
        }

        /* QR kodun altında veri metni (küçük puntolu) */
        .qr-data-text {
            font-size: 8px;
            color: #666;
            margin-top: 5px;
            word-break: break-all;
            line-height: 1.2;
            font-family: 'Courier New', monospace;
        }

        /* Yazdırma (print) için özel stiller */
        @media print {
            /* Yazdırma sırasında görünmemesi gereken öğeler */
            .no-print {
                display: none !important;
            }
            /* Dikey yazı alanlarının kenarlığını yazdırmada kaldır */
            .ediv{
                border : none !important;
            }
            /* Yazdırmada grid tek sütuna düşsün, boşluklar kaldırılsın */
            .label-container {
                 grid-template-columns: 1fr;
                gap: 0;
                padding-top:0px;
                margin-top: 0px;
            }
            
            /* Etiket kartı yazdırma: her kart yeni sayfada (bu sayfa düzeni için) */
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
            
            /* Son karttan sonra sayfa kırma uygulama */
            .label-item:last-child {
                page-break-after: auto;
            }
            
            /* QR görüntüsünün yazdırmada maksimum boyutu */
            .qr-code canvas {
                max-width: 120px !important;
                max-height: 120px !important;
            }
            
            /* Yazdırmada sayfa kenar boşluklarını sıfırla (tarayıcı ayarlarına bağlıdır) */
            body {
                margin: 0;
                padding: 0;
            }
            
            /* Kapsayıcı kenar boşluklarını kaldır */
            .container {
                max-width: none;
                padding: 0;
            }
        }

        /* Etiket Boyut Seçenekleri (butonlarla değişen sınıflar) */
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

        /* Üst araç çubuğu: sayfa kayarken üstte sabit kalsın */
        .toolbar {
            position: sticky;
            top: 0;
            background: white;
            z-index: 1000;
            border-bottom: 1px solid #dee2e6;
            padding: 15px 0;
            margin-bottom: 20px;
        }

        /* Sayfalama bilgisinin yatay hizalaması */
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
                        <button type="button" class="btn btn-success" onclick="printDivWithStyles('labelContainer')">
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
            <!--- İstatistikler
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
            </div> --->
</cfoutput>
            
            

            <!-- Etiketler -->
            <div class="label-container label-size-medium" id="labelContainer" style="background-color: ##fff;">
                <cfoutput> 
                <!--- Sayfa başına 6 etiket olacak şekilde sayaç --->
                <cfset labelCounter = 0>
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
                        <!--- Etiket bloğu: tek tek sayfa kırma KALDIRILDI, 6 adette bir kırılacak --->
                        <cfset labelCounter = labelCounter + 1>
                        <div style="display:inline-block;;page-break-inside:avoid;break-inside:avoid;margin-left:0mm">
                           <table>
                            <tr>
                                <td colspan="3" style="font-size:4pt; text-align:center;">
                                    #eta_kodu#
                                </td>
                            </tr>
                            <tr>
                                <td style="margin:0;">
                                   <div class="ediv" style="writing-mode: vertical-rl;font-size:4pt;font-weight: bold; font-family: Arial;"> #DateFormat(uretim_tarihi, 'mm/yy')# #DateFormat(paket_tarihi, 'mm/yy')#</div>
                                </td>
                                <td style="padding:0;">
                            
                                    <cfset qr_data = "#eta_kodu#_#yeni_seri_no#_#DateFormat(uretim_tarihi, 'mm.yy')#_#DateFormat(paket_tarihi, 'mm/yy')#_#barkod#_1.00_#marka#">
                                    <cfset qr_id = "qr_#temp_id#_#etiket_no#_#getTickCount()#">
                                    <cftry>
                                        <cf_pbs_barcode
                                            value="#qr_data#" 
                                            type="qrcode" 
                                            width="41" 
                                            height="41" 
                                            show="1" 
                                            id="#qr_id#"
                                            path="#ExpandPath('../temp/')#"
                                            format="png"
                                            >
                                    <cfcatch>
                                        <!--- Hata durumunda basit QR placeholder göster --->
                                        
                                    </cfcatch>
                                    </cftry>
                                </td>
                                <td style="">
                                    <div style="writing-mode: vertical-rl;font-size:4.3pt; font-weight: bold; ">
                                    #yeni_seri_no#
                                    </div>
                                </td>
                            </tr>
                           </table> 
                        </div>
                        <!--- Her 5 etikette bir sayfa sonu --->
                        <cfif labelCounter MOD 5 EQ 0>
                            <div style="display:block;width:100%;height:0;page-break-after:always;break-after:page;"></div>
                        </cfif>
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

            <!-- Alt sayfalama kaldırıldı: tüm etiketler tek sayfada gösteriliyor -->
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
function printDivWithStyles(divId) {
    var printContents = document.getElementById(divId).innerHTML;
    var originalContents = document.body.innerHTML;

    // Sayfa içeriğini yazdırmak istediğimiz div ile değiştiriyoruz
    document.body.innerHTML = printContents;

    // Yazdırma komutunu çalıştırıyoruz
    window.print();

    // İşlem bittikten sonra sayfanın orijinal içeriğini geri yüklüyoruz
    document.body.innerHTML = originalContents;
}

    </script>

</body>
</html>

