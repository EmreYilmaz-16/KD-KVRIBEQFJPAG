<!--- Etiket Şablon Tasarım Sayfası --->
<cfparam name="url.import_id" default="0">
<cfparam name="url.template_id" default="1">

<!--- Resolve datasource configuration dynamically --->
<cffile action="read" file="#ExpandPath('/pbs_dsn.txt')#" variable="configContent">
<cfset variables.dsn = trim(configContent)>
<cfquery name="getParams" datasource="#variables.dsn#">
    SELECT PBS_MODUL_COMPANY_ID FROM PBS_PARAMETERS
</cfquery>
<cfset variables.companyId = trim(getParams.PBS_MODUL_COMPANY_ID)>
<cfset variables.dsn3 = variables.dsn & '_' & variables.companyId>
    
<!--- Mevcut şablonları al --->
<cfquery name="getTemplates" datasource="#variables.dsn#">
    SELECT * FROM etiket_templates_s 
    ORDER BY template_name
</cfquery>

<!--- Eğer template yoksa varsayılan şablonları oluştur --->
<cfif getTemplates.recordCount eq 0>
    <cfquery datasource="#variables.dsn#">
        INSERT INTO etiket_templates_s (template_name, template_description, label_width, label_height, qr_size, font_size, show_qr, show_barcode, fields_layout)
        VALUES 
        ('Standart Etiket', 'Temel etiket şablonu - QR kod ile', 300, 200, 100, 12, 1, 0, 'standard'),
        ('Küçük Etiket', 'Kompakt etiket tasarımı', 250, 150, 80, 10, 1, 0, 'compact'),
        ('Büyük Etiket', 'Detaylı büyük etiket', 400, 300, 120, 14, 1, 1, 'detailed'),
        ('Barkod Odaklı', 'Geleneksel barkod etiket', 300, 150, 60, 11, 0, 1, 'barcode_focus'),
        ('QR Odaklı', 'Büyük QR kod etiket', 200, 200, 150, 10, 1, 0, 'qr_focus')
    </cfquery>
    <cflocation url="template_design.cfm?import_id=#url.import_id#" addtoken="false">
</cfif>

<!--- Seçili şablon bilgilerini al --->
<cfquery name="getSelectedTemplate" datasource="#variables.dsn#">
    SELECT * FROM etiket_templates_s 
    WHERE template_id = <cfqueryparam value="#url.template_id#" cfsqltype="cf_sql_integer">
</cfquery>

<!--- Örnek veri --->
<cfset sample_data = {
    eta_kodu = "ABC123",
    seri_no = "SN202500001",
    uretim_tarihi = CreateDate(2025, 07, 15),
    paket_tarihi = CreateDate(2025, 07, 30),
    barkod = "1234567890123",
    miktar = 25.50,
    marka = "ÖRNEK MARKA"
}>

<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Etiket Şablon Tasarımı</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .template-designer {
            background: #f8f9fa;
            min-height: 100vh;
        }
        
        .design-panel {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .template-list {
            max-height: 400px;
            overflow-y: auto;
        }
        
        .template-item {
            border: 2px solid #dee2e6;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .template-item:hover {
            border-color: #007bff;
            background: #f8f9fa;
        }
        
        .template-item.active {
            border-color: #007bff;
            background: #e3f2fd;
        }
        
        .preview-area {
            background: #fff;
            border: 2px dashed #dee2e6;
            border-radius: 10px;
            padding: 30px;
            text-align: center;
            min-height: 500px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
        }
        
        .label-preview {
            border: 2px solid #333;
            background: white;
            font-family: 'Courier New', monospace;
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
            transform: scale(1.2);
            margin: 20px;
        }
        
        .label-header {
            text-align: center;
            border-bottom: 1px solid #333;
            padding: 8px;
            font-weight: bold;
            background: #f8f9fa;
        }
        
        .label-content {
            padding: 15px;
        }
        
        .label-field {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 11px;
        }
        
        .qr-placeholder {
            width: 80px;
            height: 80px;
            border: 2px solid #000;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 10px auto;
            font-size: 8px;
            text-align: center;
        }
        
        .barcode-placeholder {
            width: 120px;
            height: 30px;
            border: 1px solid #000;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 10px auto;
            font-size: 8px;
            background: #f0f0f0;
        }
        
        .control-panel {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            padding: 20px;
        }
        
        .size-input {
            width: 80px;
        }
        
        .field-toggle {
            margin: 5px 0;
        }
        
        .custom-range {
            width: 100%;
        }
        
        .preview-toolbar {
            position: sticky;
            top: 20px;
            background: white;
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
    </style>
</head>
<body class="template-designer">
    <div class="container-fluid">
        <!-- Header -->
        <div class="preview-toolbar">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h4 class="mb-0">
                        <i class="fas fa-palette me-2"></i>
                        Etiket Şablon Tasarımı
                    </h4>
                    <small class="text-muted">Etiket görünümünü özelleştirin</small>
                </div>
                <div>
                    <button class="btn btn-success me-2" onclick="saveTemplate()">
                        <i class="fas fa-save me-2"></i>Şablonu Kaydet
                    </button>
                    <button class="btn btn-primary me-2" onclick="previewWithData()">
                        <i class="fas fa-eye me-2"></i>Verilerle Önizle
                    </button>
                    <a href="view_labels.cfm?import_id=<cfoutput>#url.import_id#</cfoutput>" class="btn btn-outline-secondary">
                        <i class="fas fa-arrow-left me-2"></i>Etiketlere Dön
                    </a>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Sol Panel: Şablon Listesi -->
            <div class="col-md-3">
                <div class="design-panel">
                    <h5><i class="fas fa-list me-2"></i>Hazır Şablonlar</h5>
                    <div class="template-list">
                        <cfoutput query="getTemplates">
                            <div class="template-item <cfif(template_id eq url.template_id)> active</cfif>" 
                                 onclick="selectTemplate(#template_id#)">
                                <div class="d-flex justify-content-between">
                                    <strong>#template_name#</strong>
                                    <span class="badge bg-primary">#label_width#x#label_height#</span>
                                </div>
                                <small class="text-muted">#template_description#</small>
                                <div class="mt-2">
                                    <cfif show_qr><span class="badge bg-success">QR</span></cfif>
                                    <cfif show_barcode><span class="badge bg-info">Barkod</span></cfif>
                                    <span class="badge bg-secondary">Font: #font_size#px</span>
                                </div>
                            </div>
                        </cfoutput>
                    </div>
                    
                    <button class="btn btn-outline-primary w-100 mt-3" onclick="createNewTemplate()">
                        <i class="fas fa-plus me-2"></i>Yeni Şablon
                    </button>
                </div>
            </div>

            <!-- Orta Panel: Önizleme Alanı -->
            <div class="col-md-6">
                <div class="design-panel">
                    <h5><i class="fas fa-eye me-2"></i>Önizleme</h5>
                    <div class="preview-area" id="previewArea">
                        <cfif getSelectedTemplate.recordCount gt 0>
                            <cfoutput>
                                <div class="label-preview" id="labelPreview" 
                                     style="width: #getSelectedTemplate.label_width#px; height: #getSelectedTemplate.label_height#px;">
                                    <div class="label-header" style="font-size: #getSelectedTemplate.font_size + 2#px;">
                                        #sample_data.marka# - ÜRÜN ETİKETİ
                                    </div>
                                    <div class="label-content" style="font-size: #getSelectedTemplate.font_size#px;">
                                        <div class="label-field">
                                            <strong>ETA Kodu:</strong>
                                            <span>#sample_data.eta_kodu#</span>
                                        </div>
                                        <div class="label-field">
                                            <strong>Seri No:</strong>
                                            <span>#sample_data.seri_no#</span>
                                        </div>
                                        <div class="label-field">
                                            <strong>Üretim:</strong>
                                            <span>#DateFormat(sample_data.uretim_tarihi, "dd/mm/yyyy")#</span>
                                        </div>
                                        <div class="label-field">
                                            <strong>Paket:</strong>
                                            <span>#DateFormat(sample_data.paket_tarihi, "dd/mm/yyyy")#</span>
                                        </div>
                                        <div class="label-field">
                                            <strong>Miktar:</strong>
                                            <span>#NumberFormat(sample_data.miktar, "0.00")#</span>
                                        </div>
                                        
                                        <cfif getSelectedTemplate.show_qr>
                                            <div class="qr-placeholder" style="width: #getSelectedTemplate.qr_size#px; height: #getSelectedTemplate.qr_size#px;">
                                                QR KOD<br>
                                                <small>#getSelectedTemplate.qr_size#x#getSelectedTemplate.qr_size#</small>
                                            </div>
                                        </cfif>
                                        
                                        <cfif getSelectedTemplate.show_barcode>
                                            <div class="barcode-placeholder">
                                                |||| |||| ||||<br>
                                                <small>BARKOD</small>
                                            </div>
                                        </cfif>
                                    </div>
                                </div>
                            </cfoutput>
                        <cfelse>
                            <div class="text-center text-muted">
                                <i class="fas fa-exclamation-triangle fa-3x mb-3"></i>
                                <h5>Şablon Bulunamadı</h5>
                                <p>Lütfen sol panelden bir şablon seçin</p>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>

            <!-- Sağ Panel: Kontrol Paneli -->
            <div class="col-md-3">
                <div class="control-panel">
                    <h5><i class="fas fa-sliders-h me-2"></i>Özelleştirme</h5>
                    
                    <cfif getSelectedTemplate.recordCount gt 0>
                        <cfoutput>
                            <!-- Boyut Ayarları -->
                            <div class="mb-4">
                                <h6><i class="fas fa-expand-arrows-alt me-2"></i>Boyut</h6>
                                <div class="row">
                                    <div class="col-6">
                                        <label class="form-label">Genişlik</label>
                                        <input type="number" class="form-control size-input" 
                                               id="labelWidth" value="#getSelectedTemplate.label_width#" 
                                               min="200" max="600" onchange="updatePreview()">
                                    </div>
                                    <div class="col-6">
                                        <label class="form-label">Yükseklik</label>
                                        <input type="number" class="form-control size-input" 
                                               id="labelHeight" value="#getSelectedTemplate.label_height#" 
                                               min="100" max="400" onchange="updatePreview()">
                                    </div>
                                </div>
                            </div>

                            <!-- Font Ayarları -->
                            <div class="mb-4">
                                <h6><i class="fas fa-font me-2"></i>Font</h6>
                                <label class="form-label">Font Boyutu: <span id="fontSizeValue">#getSelectedTemplate.font_size#</span>px</label>
                                <input type="range" class="form-range" id="fontSize" 
                                       min="8" max="18" value="#getSelectedTemplate.font_size#" 
                                       oninput="updateFontSize(this.value)">
                            </div>

                            <!-- QR Kod Ayarları -->
                            <div class="mb-4">
                                <h6><i class="fas fa-qrcode me-2"></i>QR Kod</h6>
                                <div class="form-check field-toggle">
                                    <input class="form-check-input" type="checkbox" id="showQR" 
                                           <cfif(getSelectedTemplate.show_qr)>'checked'<cfelse>'unchecked'</cfif>
                                           onchange="updatePreview()">
                                    <label class="form-check-label" for="showQR">QR Kod Göster</label>
                                </div>
                                <div id="qrSizeControl" style="display: <cfif (getSelectedTemplate.show_qr)>block<cfelse>none</cfif>;">
                                    <label class="form-label">QR Boyutu: <span id="qrSizeValue">#getSelectedTemplate.qr_size#</span>px</label>
                                    <input type="range" class="form-range" id="qrSize" 
                                           min="60" max="200" value="#getSelectedTemplate.qr_size#" 
                                           oninput="updateQRSize(this.value)">
                                </div>
                            </div>

                            <!-- Barkod Ayarları -->
                            <div class="mb-4">
                                <h6><i class="fas fa-barcode me-2"></i>Barkod</h6>
                                <div class="form-check field-toggle">
                                    <input class="form-check-input" type="checkbox" id="showBarcode" 
                                           <cfif(getSelectedTemplate.show_barcode)>'checked'<cfelse>'unchecked'</cfif>
                                           onchange="updatePreview()">
                                    <label class="form-check-label" for="showBarcode">Barkod Göster</label>
                                </div>
                            </div>

                            <!-- Alan Seçimi -->
                            <div class="mb-4">
                                <h6><i class="fas fa-list-check me-2"></i>Gösterilecek Alanlar</h6>
                                <div class="form-check field-toggle">
                                    <input class="form-check-input" type="checkbox" id="showEtaKodu" checked>
                                    <label class="form-check-label" for="showEtaKodu">ETA Kodu</label>
                                </div>
                                <div class="form-check field-toggle">
                                    <input class="form-check-input" type="checkbox" id="showSeriNo" checked>
                                    <label class="form-check-label" for="showSeriNo">Seri No</label>
                                </div>
                                <div class="form-check field-toggle">
                                    <input class="form-check-input" type="checkbox" id="showUretimTarihi" checked>
                                    <label class="form-check-label" for="showUretimTarihi">Üretim Tarihi</label>
                                </div>
                                <div class="form-check field-toggle">
                                    <input class="form-check-input" type="checkbox" id="showPaketTarihi" checked>
                                    <label class="form-check-label" for="showPaketTarihi">Paket Tarihi</label>
                                </div>
                                <div class="form-check field-toggle">
                                    <input class="form-check-input" type="checkbox" id="showMiktar" checked>
                                    <label class="form-check-label" for="showMiktar">Miktar</label>
                                </div>
                            </div>
                        </cfoutput>
                    </cfif>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Şablon seçimi
        function selectTemplate(templateId) {
            window.location.href = 'template_design.cfm?import_id=<cfoutput>#url.import_id#</cfoutput>&template_id=' + templateId;
        }

        // Önizleme güncelleme
        function updatePreview() {
            const preview = document.getElementById('labelPreview');
            if (!preview) return;
            
            const width = document.getElementById('labelWidth') ? document.getElementById('labelWidth').value : 300;
            const height = document.getElementById('labelHeight') ? document.getElementById('labelHeight').value : 200;
            const showQR = document.getElementById('showQR') ? document.getElementById('showQR').checked : true;
            const showBarcode = document.getElementById('showBarcode') ? document.getElementById('showBarcode').checked : false;
            
            preview.style.width = width + 'px';
            preview.style.height = height + 'px';
            
            // QR kod kontrolü
            const qrElement = preview.querySelector('.qr-placeholder');
            if (qrElement) {
                qrElement.style.display = showQR ? 'flex' : 'none';
            }
            
            // Barkod kontrolü
            const barcodeElement = preview.querySelector('.barcode-placeholder');
            if (barcodeElement) {
                barcodeElement.style.display = showBarcode ? 'flex' : 'none';
            }
            
            // QR boyut kontrolü göster/gizle
            const qrSizeControl = document.getElementById('qrSizeControl');
            if (qrSizeControl) {
                qrSizeControl.style.display = showQR ? 'block' : 'none';
            }
        }

        // Font boyutu güncelleme
        function updateFontSize(size) {
            const fontSizeValue = document.getElementById('fontSizeValue');
            if (fontSizeValue) {
                fontSizeValue.textContent = size;
            }
            
            const preview = document.getElementById('labelPreview');
            if (preview) {
                const content = preview.querySelector('.label-content');
                const header = preview.querySelector('.label-header');
                
                if (content) content.style.fontSize = size + 'px';
                if (header) header.style.fontSize = (parseInt(size) + 2) + 'px';
            }
        }

        // QR boyutu güncelleme
        function updateQRSize(size) {
            const qrSizeValue = document.getElementById('qrSizeValue');
            if (qrSizeValue) {
                qrSizeValue.textContent = size;
            }
            
            const qrElement = document.querySelector('.qr-placeholder');
            if (qrElement) {
                qrElement.style.width = size + 'px';
                qrElement.style.height = size + 'px';
                qrElement.innerHTML = 'QR KOD<br><small>' + size + 'x' + size + '</small>';
            }
        }

        // Şablon kaydetme
        function saveTemplate() {
            // Kontrol elementlerinin varlığını kontrol et
            const templateIdElement = document.querySelector('[data-template-id]');
            const templateId = templateIdElement ? templateIdElement.dataset.templateId : <cfoutput>#url.template_id#</cfoutput>;
            
            const templateData = {
                template_id: templateId,
                label_width: document.getElementById('labelWidth') ? document.getElementById('labelWidth').value : 300,
                label_height: document.getElementById('labelHeight') ? document.getElementById('labelHeight').value : 200,
                font_size: document.getElementById('fontSize') ? document.getElementById('fontSize').value : 12,
                qr_size: document.getElementById('qrSize') ? document.getElementById('qrSize').value : 100,
                show_qr: document.getElementById('showQR') ? (document.getElementById('showQR').checked ? 1 : 0) : 1,
                show_barcode: document.getElementById('showBarcode') ? (document.getElementById('showBarcode').checked ? 1 : 0) : 0
            };
            
            console.log('Kaydedilecek şablon verisi:', templateData);
            
            // AJAX ile kaydet
            fetch('save_template.cfm', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(templateData)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('HTTP error! status: ' + response.status);
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    alert('Şablon başarıyla kaydedildi!');
                    // Sayfayı yenile
                    location.reload();
                } else {
                    alert('Hata: ' + data.message);
                }
            })
            .catch(error => {
                console.error('Kaydetme hatası:', error);
                alert('Kaydetme sırasında hata oluştu: ' + error.message);
            });
        }

        // Verilerle önizleme
        function previewWithData() {
            const templateData = {
                template_id: <cfoutput>#url.template_id#</cfoutput>,
                label_width: document.getElementById('labelWidth') ? document.getElementById('labelWidth').value : 300,
                label_height: document.getElementById('labelHeight') ? document.getElementById('labelHeight').value : 200,
                font_size: document.getElementById('fontSize') ? document.getElementById('fontSize').value : 12,
                qr_size: document.getElementById('qrSize') ? document.getElementById('qrSize').value : 100,
                show_qr: document.getElementById('showQR') ? (document.getElementById('showQR').checked ? 1 : 0) : 1,
                show_barcode: document.getElementById('showBarcode') ? (document.getElementById('showBarcode').checked ? 1 : 0) : 0
            };
            
            const params = new URLSearchParams(templateData);
            window.open('view_labels.cfm?import_id=<cfoutput>#url.import_id#</cfoutput>&' + params.toString(), '_blank');
        }

        // Yeni şablon oluştur
        function createNewTemplate() {
            const name = prompt('Yeni şablon adı:');
            if (name && name.trim() !== '') {
                window.location.href = 'create_template.cfm?name=' + encodeURIComponent(name.trim()) + '&import_id=<cfoutput>#url.import_id#</cfoutput>';
            }
        }

        // Sayfa yüklendiğinde
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Şablon tasarım sayfası yüklendi');
            
            // Event listener'ları ekle
            const elements = {
                'labelWidth': updatePreview,
                'labelHeight': updatePreview,
                'showQR': updatePreview,
                'showBarcode': updatePreview
            };
            
            Object.keys(elements).forEach(id => {
                const element = document.getElementById(id);
                if (element) {
                    element.addEventListener('change', elements[id]);
                }
            });
            
            // Range slider'lar için oninput event'leri
            const fontSize = document.getElementById('fontSize');
            if (fontSize) {
                fontSize.addEventListener('input', function() {
                    updateFontSize(this.value);
                });
            }
            
            const qrSize = document.getElementById('qrSize');
            if (qrSize) {
                qrSize.addEventListener('input', function() {
                    updateQRSize(this.value);
                });
            }
        });
    </script>
</body>
</html>
