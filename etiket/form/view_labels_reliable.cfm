<!--- Etiket Görüntüleme ve Yazdırma Sayfası --->
<cfparam name="url.import_id" default="0">
<cfparam name="url.page" default="1">
<cfparam name="url.per_page" default="4">

<!--- Resolve datasource configuration dynamically --->
<cffile action="read" file="#ExpandPath('/pbs_dsn.txt')#" variable="configContent">
<cfset variables.dsn = trim(configContent)>
<cfquery name="getParams" datasource="#variables.dsn#">
    SELECT PBS_MODUL_COMPANY_ID FROM PBS_PARAMETERS
</cfquery>
<cfset variables.companyId = trim(getParams.PBS_MODUL_COMPANY_ID)>
<cfset variables.dsnCompany = variables.dsn & '_' & variables.companyId>
<cfset variables.dsn3 = variables.dsnCompany>
<cfset variables.dsnShip = variables.dsn & '_#year(now())#_' & variables.companyId>

<!--- Custom tag için gerekli değişkenler --->
<cfset upload_folder = ExpandPath(".")>
<cfset dir_seperator = "/">
<cfif FindNoCase("Windows", server.os.name)>
    <cfset dir_seperator = "\">
</cfif>

<!--- Import bilgilerini al --->
<cfquery name="getImportInfo" datasource="#variables.dsn#">
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
<cfquery name="getTotalRecordsForPaging" datasource="#variables.dsn#">
    SELECT COUNT(*) as total_count
    FROM etiket_temp_data 
    WHERE import_id = <cfqueryparam value="#url.import_id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset offset = (url.page - 1) * url.per_page>
<cfset totalPages = ceiling(getTotalRecordsForPaging.total_count / url.per_page)>
<cflog file="etiket_import" text="view_labels.cfm: Pagination - total_count=#getTotalRecordsForPaging.total_count#, totalPages=#totalPages#, offset=#offset#">

<!--- Etiket verilerini al --->
<cfquery name="getLabelData" datasource="#variables.dsn#">
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
<cfquery name="getTotalRecords" datasource="#variables.dsn#">
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

        /* Etiket kartlarını listeleyen kapsayıcı: yoğun akışlı düzen */
        .label-container {
            display: flex;
            flex-wrap: wrap;
            gap: 1mm; /* mini etiketler için küçük boşluk */
            margin-top: 10px;
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
            /* Yazdırmada boşluklar kaldırılsın */
            .label-container {
                gap: 0;
                padding-top: 0;
                margin-top: 0;
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

        /* 25mm x 25mm kompakt etiket (tablosuz) */
        .mini-label {
            width: 25mm;
            height: 25mm;
            box-sizing: border-box;
            display: grid;
            grid-template-columns: 2.5mm 1fr 2.5mm;
            grid-template-rows: 3mm 1fr;
            grid-template-areas:
                "top top top"
                "left qr right";
            align-items: center;
            justify-items: center;
            gap: 0.2mm;
            margin: 0.5mm 0.5mm 0.5mm 0;
            padding: 0.3mm;
            page-break-inside: avoid;
            break-inside: avoid;
        }

        .mini-label .top-code {
            grid-area: top;
            font-size: 3pt;
            line-height: 0.9;
            text-align: center;
            white-space: nowrap;
            margin: 0;
            padding: 0;
        }

        .mini-label .left-meta,
        .mini-label .right-meta {
            writing-mode: vertical-rl;
            text-orientation: mixed;
            font-size: 3pt;
            line-height: 0.9;
            font-weight: bold;
            margin: 0;
            padding: 0;
        }

        .mini-label .qr-wrap { 
            grid-area: qr; 
            display: flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            height: 100%;
        }

        /* QR resmi için sıkı kırpma (quiet zone'u çok bozmadan) */
        .mini-label .qr-crop {
            /* Ayarlanabilir değerler */
            --qr-size: 20.5mm;   /* hedef QR alanı - daha büyük */
            --qr-crop: 0.4mm;    /* kırpma miktarı - daha az kırpma */
            width: calc(var(--qr-size) - var(--qr-crop));
            height: calc(var(--qr-size) - var(--qr-crop));
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .mini-label .qr-crop img,
        .mini-label .qr-crop canvas {
            width: calc(var(--qr-size) + var(--qr-crop));
            height: calc(var(--qr-size) + var(--qr-crop));
            transform: translate(calc(-1 * var(--qr-crop) / 2), calc(-1 * var(--qr-crop) / 2));
            display: block;
            margin: 0;
        }

        @media print {
            .mini-label {
                margin: 0;
            }
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
    
</cfoutput>
            
            <cfset AllPrint="">
<cfset ZPL_DATA_FULL="">
            <!-- Etiketler -->
            <div class="label-container label-size-medium" id="labelContainer" style="background-color: ##fff;">
                <cfoutput> 
                <!--- Her kayıt için tek etiket --->
                <cfloop query="getLabelData">
                    <!--- Ürün bilgisini bir kez al --->
                    
                    <cfquery name="getStok" datasource="#variables.dsn#">
                        SELECT TOP 1 PRODUCT_NAME 
                        FROM PBS_GETSTOCK 
                        WHERE PRODUCT_CODE_2 = <cfqueryparam value="#eta_kodu#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                    
                    <!--- Etiket verileri --->
                    <cfset TARIH = "#DateFormat(uretim_tarihi, 'mm/yy')# #DateFormat(paket_tarihi, 'mm/yy')#">
                    <cfset URUNKODU = eta_kodu>
                    <cfset SERINO = seri_no>
                    <cfset BARKOD = "#eta_kodu#_#seri_no#_#DateFormat(uretim_tarihi, 'mm.yy')#_#DateFormat(paket_tarihi, 'mm/yy')#_#barkod#_1.00_#marka#">
                    
                    <!--- HTML Etiket --->
                    <div class="mini-label">
                        
                        <div class="qr-wrap">
                            <cfset qr_data = BARKOD>
                            <cfset qr_id = "qr_#temp_id#_#getTickCount()#">
                            <div class="qr-crop">
                                <cftry>
                                    
                                    <cfcatch>
                                        <!--- Hata durumunda basit QR placeholder --->
                                    </cfcatch>
                                </cftry>
                            </div>
                        </div>
                        <div class="right-meta"></div>
                    </div>
                    
                    <!--- Her etiket sonrası sayfa kırma --->
                    <div style="display:block;width:100%;height:0;page-break-after:always;break-after:page;"></div>
                    
                    <!--- Her etiket için tek ZPL kodu --->
                    <cfsavecontent variable="zd">
CT~~CD,~CC^~CT~
^XA
~TA000
~JSN
^LT0
^MNW
^MTD
^PON
^PMN
^LH0,0
^JMA
^PR6,6
~SD15
^JUS
^LRN
^CI27
^PA0,1,1,0
^XZ
^XA
^MMT
^PW305
^LL307
^LS0
^FT59,287^BQN,2,6
^FH\^FDLA,#BARKOD#^FS
^FT292,307^A0B,29,33^FB277,1,7,C^FH\^CI28^FD#URUNKODU#^FS^CI27
^FT47,258^A0B,29,28^FH\^CI28^FD#TARIH#^FS^CI27
^FT0,52^A0N,27,30^FB320,1,7,C^FH\^CI28^FD#SERINO#^FS^CI27
^PQ1,0,1,Y
^XZ
                    </cfsavecontent>
                    <cfset ZPL_DATA_FULL = ZPL_DATA_FULL & zd>
                    
                <div >
                    <table>
                        <tr>
                            <td>
                                Sıra No: #currentRow# / #getLabelData.recordCount#
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Ürün Kodu
                            </td>
                            <td>
                                : #URUNKODU#
                            </td>
                            
                        </tr>
                        <tr>
                            <td>
                                Seri No
                            </td>
                            <td>
                                : #SERINO#
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Tarih
                            </td>
                            <td>
                                : #TARIH#
                            </td>
                        </tr>
                        <tr>    
                            <td>
                                Barkod
                            </td>
                            <td>
                                : #BARKOD#
                            </td>
                        </tr>
                    </table>

                </div>
                </cfloop> <!--- Ana veri döngüsü sonu --->
                
                </cfoutput>
            </div>
            
            <cfif getLabelData.recordCount eq 0>
                <div class="alert alert-warning text-center">
                    <h5><i class="fas fa-exclamation-triangle me-2"></i>Etiket Bulunamadı</h5>
                    <p>Bu import için etiket verisi bulunamadı.</p>
                    <a href="index.cfm?fuseaction=objects.emptypopup_import_write_label" class="btn btn-primary">
                        <i class="fas fa-arrow-left me-2"></i>Ana Sayfaya Dön
                    </a>
                </div>
            </cfif>
        </div>
    </div>
    <cfabort>
    <cfset zplData = trim(ZPL_DATA_FULL)>
    <cfif 1 EQ 1>
      <!--- Tüm satır sonlarını CRLF yap (ZPL yazıcıları genelde sever) --->
      <cfset zplData = replace(zplData, chr(13), "", "all")>
      <cfset zplData = replace(zplData, chr(10), chr(13)&chr(10), "all")>
    </cfif>
      <cfset InetSocketAddress = createObject("java","java.net.InetSocketAddress")>
    <cfset Socket            = createObject("java","java.net.Socket")>
    <cfset addr = InetSocketAddress.init( trim("192.168.2.9"), javacast("int", 9100) )>
    <cfset Socket.connect( addr, javacast("int", 5000 ) )>
    <cfset Socket.setSoTimeout( javacast("int", 5000 ) )>

<cfset os    = Socket.getOutputStream()>
    <cfset bytes = createObject("java","java.lang.String").init( zplData ).getBytes( javacast("string", "US-ASCII" ) )>

    <cfset os.write( bytes )>
    <cfset os.flush()>
    <cfset os.close()>
    <cfset Socket.close()>

    <p class="ok">✅ Gönderildi.</p>

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
    const node = document.getElementById(divId);
    if (!node) return window.print();

    // İçeriği klonla ve varsa canvas'ları resme dönüştür
    const clone = node.cloneNode(true);
    const canvases = clone.querySelectorAll('canvas');
    canvases.forEach((cv) => {
        try {
            const img = document.createElement('img');
            img.src = cv.toDataURL('image/png');
            img.style.width = cv.style.width || (cv.width ? cv.width + 'px' : '');
            img.style.height = cv.style.height || (cv.height ? cv.height + 'px' : '');
            cv.replaceWith(img);
        } catch (e) {
            // toDataURL başarısızsa canvas'ı olduğu gibi bırak
        }
    });

    const printWindow = window.open('', '', 'width=900,height=700');
    const baseTag = '<base href="' + document.baseURI + '">';
    const headHTML = baseTag + document.head.innerHTML;

    // Yeni pencerede sayfayı oluştur
    printWindow.document.open();
    printWindow.document.write('<!DOCTYPE html><html><head>' + headHTML + '</head><body>' + clone.outerHTML + '</body></html>');
    printWindow.document.close();

    const triggerPrint = () => {
        try { printWindow.focus(); } catch (e) {}
        printWindow.print();
        // Bazı tarayıcılarda print asenkron olabilir; küçük gecikme sonrasında kapat
        setTimeout(() => { try { printWindow.close(); } catch (e) {} }, 250);
    };

    // Resimlerin yüklenmesini bekle
    const waitForImages = () => {
        const imgs = Array.from(printWindow.document.images || []);
        if (imgs.length === 0) { triggerPrint(); return; }
        let doneCount = 0;
        const done = () => { doneCount++; if (doneCount >= imgs.length) triggerPrint(); };
        imgs.forEach(img => {
            if (img.complete && img.naturalWidth > 0) { done(); }
            else {
                img.addEventListener('load', done, { once: true });
                img.addEventListener('error', done, { once: true });
            }
        });
        // Emniyet süresi: 2sn sonra yine de yazdır
        setTimeout(triggerPrint, 2000);
    };

    // Yeni pencere tamamen yüklenince kontrol et
    if (printWindow.document.readyState === 'complete') {
        waitForImages();
    } else {
        printWindow.addEventListener('load', waitForImages, { once: true });
    }
}

    </script>

</body>
</html>

