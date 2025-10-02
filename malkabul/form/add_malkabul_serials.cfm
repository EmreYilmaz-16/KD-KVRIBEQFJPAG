<cfif isDefined("attributes.show_parser")>
    <cf_box title="Barkod Türü Seçimi" scroll="1" collapsible="1" resize="1" popup_box="1">
        <div class="parser-selection-container">
            <div class="alert alert-info mb-3">
                <i class="fas fa-info-circle"></i>
                <strong>Barkod Türünü Seçiniz:</strong> Okutacağınız barkodun türüne göre uygun seçeneği tıklayın.
            </div>
            <div class="button-group">
                <button class="btn btn-success btn-lg parser-btn" onclick="setparser(1,'<cfoutput>#attributes.modal_id#</cfoutput>')">
                    <i class="fas fa-barcode"></i> Dönmez Barkod
                </button>
                <button class="btn btn-success btn-lg parser-btn" onclick="setparser(3,'<cfoutput>#attributes.modal_id#</cfoutput>')">
                    <i class="fas fa-barcode"></i> Dönmez Yeni Barkod
                </button>
                <button class="btn btn-primary btn-lg parser-btn" onclick="setparser(2,'<cfoutput>#attributes.modal_id#</cfoutput>')">
                    <i class="fas fa-qrcode"></i> Diğer Barkodlar
                </button>
            </div>
        </div>
        <style>
            .parser-selection-container {
                padding: 20px;
                text-align: center;
            }
            .button-group {
                display: flex;
                gap: 15px;
                justify-content: center;
                flex-wrap: wrap;
            }
            .parser-btn {
                min-width: 200px;
                padding: 15px 25px;
                font-size: 16px;
                font-weight: 600;
                border-radius: 8px;
                transition: all 0.3s ease;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            .parser-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0,0,0,0.2);
            }
        </style>
    </cf_box>
    <cfabort>
</cfif>



<cfquery name="getPaperData" datasource="#dsn2#">
  SELECT ( select SHIP_NUMBER,SHIP_TYPE,DEPARTMENT_IN,LOCATION_IN,COMPANY_ID,PARTNER_ID,SHIP_ID from w3Qa_2025_1.SHIP WHERE SHIP_ID=#attributes.shipId# FOR JSON PATH) AS jsonData
</cfquery>

<!-- Font Awesome Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
/* Ana Sayfa Stilleri */
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f8f9fa;
}

.main-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

/* Seri No Giriş Alanı */
.serial-input-section {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 15px;
    padding: 25px;
    margin-bottom: 25px;
    box-shadow: 0 8px 25px rgba(0,0,0,0.1);
    color: white;
}

.serial-input-section .form-group {
    margin-bottom: 0;
}

.serial-input-section label {
    font-size: 18px;
    font-weight: 600;
    margin-bottom: 10px;
    display: block;
}

.serial-input-section .form-control {
    font-size: 16px;
    padding: 15px 20px;
    border: none;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    transition: all 0.3s ease;
}

.serial-input-section .form-control:focus {
    box-shadow: 0 0 0 3px rgba(255,255,255,0.3);
    transform: translateY(-2px);
}

/* Tablo Stilleri */
.despatch-table-container {
    background: white;
    border-radius: 15px;
    padding: 25px;
    box-shadow: 0 5px 20px rgba(0,0,0,0.08);
    overflow: hidden;
}

.despatch-table-container h3 {
    color: #2c3e50;
    margin-bottom: 20px;
    font-weight: 600;
}

#despatch_rows_table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 0 20px rgba(0,0,0,0.1);
}

/* Ürün Başlık Satırları */
#despatch_rows_table th {
    background: linear-gradient(135deg, #3498db, #2980b9) !important;
    color: white !important;
    padding: 15px 20px !important;
    font-weight: 600;
    font-size: 16px;
    border: none;
    cursor: pointer;
    transition: all 0.3s ease;
}

#despatch_rows_table th:hover {
    background: linear-gradient(135deg, #2980b9, #2471a3) !important;
    transform: scale(1.02);
}

#despatch_rows_table th a {
    color: white !important;
    text-decoration: none;
    display: block;
    width: 100%;
}

/* Normal Tablo Hücreleri */
#despatch_rows_table td {
    padding: 12px 20px;
    border-bottom: 1px solid #e9ecef;
    background: white;
    transition: background-color 0.3s ease;
}

#despatch_rows_table tr:hover td {
    background-color: #f8f9fa;
}

/* Seri No Tabloları */
.serial-table {
    width: 100%;
    margin-top: 10px;
}

.serial-table tr {
    border-bottom: 1px solid #e9ecef;
}

.serial-table td {
    padding: 8px 15px !important;
    background: #f8f9fa !important;
    border-left: 4px solid #3498db;
    font-family: 'Courier New', monospace;
    font-size: 14px;
}

.serial-table tr[data-readed="0"] td {
    background: #e8f5e8 !important;
    border-left-color: #27ae60;
    font-weight: 600;
}

.serial-table tr[data-readed="1"] td {
    background: #fff3cd !important;
    border-left-color: #f39c12;
    font-style: italic;
}

/* Durum Göstergeleri */
.status-indicator {
    padding: 5px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    display: inline-block;
    min-width: 60px;
    text-align: center;
}

.status-success {
    background: #d4edda;
    color: #155724;
    border: 1px solid #c3e6cb;
}

.status-warning {
    background: #fff3cd;
    color: #856404;
    border: 1px solid #ffeaa7;
}

.status-danger {
    background: #f8d7da;
    color: #721c24;
    border: 1px solid #f5c6cb;
}

/* Kaydet Butonu */
.save-button-container {
    text-align: center;
    margin-top: 30px;
    padding: 20px;
}

.btn-save {
    background: linear-gradient(135deg, #27ae60, #2ecc71);
    border: none;
    color: white;
    padding: 15px 40px;
    font-size: 18px;
    font-weight: 600;
    border-radius: 50px;
    box-shadow: 0 5px 15px rgba(39, 174, 96, 0.3);
    transition: all 0.3s ease;
    min-width: 200px;
}

.btn-save:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 25px rgba(39, 174, 96, 0.4);
    background: linear-gradient(135deg, #2ecc71, #27ae60);
}

/* Responsive */
@media (max-width: 768px) {
    .main-container {
        padding: 10px;
    }
    
    .serial-input-section {
        padding: 15px;
    }
    
    .despatch-table-container {
        padding: 15px;
        overflow-x: auto;
    }
    
    #despatch_rows_table {
        min-width: 600px;
    }
}

/* Animasyonlar */
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}

.fade-in {
    animation: fadeIn 0.5s ease-out;
}

/* İkonlar için */
.fas {
    margin-right: 8px;
}

/* Notification stilleri */
.notification {
    border-radius: 10px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    animation: slideInRight 0.5s ease-out;
}

@keyframes slideInRight {
    from { transform: translateX(100%); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
}

/* Loading overlay */
#loading-overlay {
    backdrop-filter: blur(5px);
}

#loading-overlay > div {
    animation: fadeIn 0.5s ease-out;
}
</style>

<script>
    var getPaperData = <cfoutput>#getPaperData.jsonData#</cfoutput>;
</script>



<cfquery name="getDespatchRow" datasource="#dsn2#">
   SELECT S.STOCK_ID,S.PRODUCT_ID,S.PRODUCT_NAME,SR.AMOUNT,SG.SERIAL_NO,SR.WRK_ROW_ID,PRODUCT_CODE_2,
(SELECT COUNT(*) FROM w3Qa_1.SERVICE_GUARANTY_NEW AS SGA WHERE SGA.WRK_ROW_ID=SR.WRK_ROW_ID) AS OMIK
FROM w3Qa_2025_1.SHIP_ROW AS SR
LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID=SR.STOCK_ID
LEFT JOIN w3Qa_1.SERVICE_GUARANTY_NEW AS SG ON SG.WRK_ROW_ID=SR.WRK_ROW_ID
WHERE SHIP_ID=#attributes.shipId#
 ORDER BY PRODUCT_ID
</cfquery>
<div class="main-container">
    <cf_box>
        <div class="serial-input-section fade-in">
            <div class="form-group">
                <label for="seri_no">
                    <i class="fas fa-barcode"></i>
                    Seri Numarası Okutun veya Girin
                </label>
                <input type="text" 
                       class="form-control" 
                       id="seri_no" 
                       name="seri_no" 
                       placeholder="Barkodu okutun veya seri numarasını yazın..." 
                       onkeydown="checkSerial(this,event)"
                       autocomplete="off">
                <small class="form-text text-light mt-2">
                    <i class="fas fa-info-circle"></i>
                    Enter tuşuna basarak seri numarasını kaydedin
                </small>
            </div>
        </div>
    </cf_box>

    <cf_box title="📦 Mal Kabul Detayları">
        <div class="despatch-table-container fade-in">
            <cf_grid_list id="despatch_rows_table">
                <cfoutput query="getDespatchRow" group="PRODUCT_ID">
                    <tr data-wrk_row_id="#WRK_ROW_ID#" data-product_id="#PRODUCT_ID#" data-stock_id="#STOCK_ID#" data-product_code_2="#PRODUCT_CODE_2#">
                        <th colspan="3" onclick="toggleSerials('#PRODUCT_ID#')" title="Seri numaralarını göster/gizle">
                            <a href="javascript:void(0)">
                                <i class="fas fa-box"></i>
                                #encodeForHTML(PRODUCT_CODE_2)# - #EncodeForHTML(PRODUCT_NAME)#
                                <i class="fas fa-chevron-down float-right"></i>
                            </a>
                        </th>
                        <td>
                            <span class="status-indicator status-warning">
                                <i class="fas fa-cubes"></i> #EncodeForHTML(AMOUNT)#
                            </span>
                        </td>
                        <td>
                            <span class="status-indicator" id="count_#PRODUCT_ID#">
                                <i class="fas fa-check-circle"></i> #EncodeForHTML(OMIK)#
                            </span>
                        </td>
                    </tr>
                    <tr style="display: none;" id="serial_row_#PRODUCT_ID#">
                        <td colspan="5">
                            <div class="serial-container">
                                <h6 class="text-muted mb-2">
                                    <i class="fas fa-list"></i> Seri Numaraları:
                                </h6>
                                <table class="serial-table" id="serials_#PRODUCT_ID#">              
                                    <cfoutput> 
                                        <cfif len(trim(SERIAL_NO)) NEQ 0>
                                        <tr data-readed="1" title="Önceden kaydedilmiş">
                                            <td>
                                                <i class="fas fa-history"></i>
                                                #EncodeForHTML(SERIAL_NO)#
                                                <small class="text-muted">(Mevcut)</small>
                                            </td>
                                        </tr>
                                    </cfif>
                                    </cfoutput>
                                </table>
                            </div>
                        </td>
                    </tr>
                </cfoutput>
            </cf_grid_list>

            <div class="save-button-container">
                <button class="btn btn-save" onclick="savePaper()">
                    <i class="fas fa-save"></i>
                    Kaydet ve Tamamla
                </button>
            </div>
        </div>
    </cf_box>
</div>
<script>
var parser = "";

$(document).ready(function(){
    // Sayfa yüklendiğinde parser seçim penceresini aç
    openBoxDraggable('index.cfm?fuseaction=purchase._emptypopup_read_despatch_rows_pbs&show_parser=1');
    
    // Seri no input alanına focus ver
    setTimeout(function(){
        $('#seri_no').focus();
    }, 1000);
});

function setparser(params, modal_id) {
    parser = params;
    console.log('Parser seçildi:', parser);
    closeBoxDraggable(modal_id);
    
    // Başarı mesajı göster
    showNotification('Barkod türü seçildi!', 'success');
    
    // Input alanına focus ver
    setTimeout(function(){
        $('#seri_no').focus();
    }, 500);
}

function showNotification(message, type) {
    // Basit bir bildirim göster
    const notification = $(`
        <div class="alert alert-${type === 'success' ? 'success' : 'danger'} notification" 
             style="position: fixed; top: 20px; right: 20px; z-index: 9999; min-width: 300px;">
            <i class="fas fa-${type === 'success' ? 'check-circle' : 'exclamation-circle'}"></i>
            ${message}
        </div>
    `);
    
    $('body').append(notification);
    
    setTimeout(function(){
        notification.fadeOut(500, function(){
            $(this).remove();
        });
    }, 3000);
}

function toggleSerials(productId) {
    var serialRow = document.getElementById('serial_row_' + productId);
    var icon = $(`th[onclick="toggleSerials('${productId}')"] .fa-chevron-down, th[onclick="toggleSerials('${productId}')"] .fa-chevron-up`);
    
    if (!serialRow) {
        console.warn('Seri listesi bulunamadı:', productId);
        return;
    }

    var isHidden = serialRow.style.display === 'none' || window.getComputedStyle(serialRow).display === 'none';

    if (isHidden) {
        $(serialRow).fadeIn(300);
        icon.removeClass('fa-chevron-down').addClass('fa-chevron-up');
        serialRow.setAttribute('aria-hidden', 'false');
    } else {
        $(serialRow).fadeOut(300);
        icon.removeClass('fa-chevron-up').addClass('fa-chevron-down');
        serialRow.setAttribute('aria-hidden', 'true');
    }
}

function updateProductStatus(productId, currentCount, totalQuantity) {
    const statusElement = document.getElementById('count_' + productId);
    const row = document.querySelector(`tr[data-product_id="${productId}"]`);
    
    statusElement.innerHTML = `<i class="fas fa-check-circle"></i> ${currentCount}`;
    
    // Durum renklerini güncelle
    statusElement.className = 'status-indicator';
    
    if (currentCount > totalQuantity) {
        statusElement.classList.add('status-danger');
        row.style.backgroundColor = '#fff5f5';
        showNotification('Uyarı: Girilen seri sayısı beklenen miktarı aştı!', 'error');
    } else if (currentCount == totalQuantity) {
        statusElement.classList.add('status-success');
        row.style.backgroundColor = '#f0fff4';
        showNotification('Tebrikler! Bu ürün için tüm seriler girildi.', 'success');
    } else {
        statusElement.classList.add('status-warning');
        row.style.backgroundColor = '#fffaf0';
    }
}

async function checkSerial(input, event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        
        var serialNo = input.value.trim();
        if (serialNo === '') {
            showNotification('Seri numarası boş olamaz!', 'error');
            return;
        }
        
        if (parser === '') {
            showNotification('Önce barkod türünü seçmelisiniz. Sayfa yenileniyor...', 'error');
            setTimeout(function(){ location.reload(); }, 2000);
            return;
        }

        // Barkodu parse et
        console.log('Barkod parse ediliyor:', serialNo, 'Parser tipi:', parser);
        var parseResult = parseBarcode(serialNo, parser);
        console.log('Parse sonucu:', parseResult);
        
        if (!parseResult.success) {
            showNotification(parseResult.error, 'error');
            return;
        }
        
        if (await isSerialRegistered(parseResult.serial_no)) {
            showNotification('Seri numarası sistemde mevcut.', 'error');
            input.value = '';
            return;
        }

        // Ürün satırını bul
        console.log("Ürün Satırı Aranıyor:", parseResult.product_code_2);
        var row = document.querySelector(`tr[data-product_code_2="${parseResult.product_code_2}"]`);
        console.log("Bulunan Satır:", row);
        
        if (!row) {
            showNotification('Bu ETA koduna ait ürün bulunamadı!', 'error');
            input.value = '';
            return;
        }

        console.log("Satır Bilgileri Alınıyor ...");
        var totalQuantity = parseInt(row.children[1].innerText);
        var wrk_row_id = row.getAttribute('data-wrk_row_id');
        var product_id = row.getAttribute('data-product_id');
        var stock_id = row.getAttribute('data-stock_id');
        console.log({totalQuantity, wrk_row_id, product_id, stock_id});
        
        // Seri numarasının daha önce girilip girilmediğini kontrol et
        console.log("Seri numarası kontrol ediliyor:", parseResult.serial_no);
        var serialsTable = document.getElementById('serials_' + product_id);
        var existingRows = serialsTable.getElementsByTagName("tr");
        console.log("Mevcut Seri Satırları:", existingRows);
        
        console.log("Seri Numaraları Kontrol Ediliyor ...");
        for (let i = 0; i < existingRows.length; i++) {
            console.log("Mevcut Seri Satırı:", existingRows[i]);
            
            // HTML etiketlerini ve parantez içindeki metinleri temizle
            var cellContent = existingRows[i].firstElementChild.innerText || existingRows[i].firstElementChild.textContent;
            var existingSerialNo = cellContent
                .replace(/<[^>]*>/g, '') // HTML etiketlerini kaldır
                .replace(/\([^)]*\)/g, '') // Parantez içindeki metinleri kaldır
                .replace(/\s+/g, ' ') // Birden fazla boşluğu tek boşluğa çevir
                .trim();
            
            console.log("Ham içerik:", cellContent);
            console.log("Temizlenmiş seri no:", existingSerialNo);
            console.log("Karşılaştırılıyor:", existingSerialNo, "==", parseResult.serial_no);
            
            if (existingSerialNo === parseResult.serial_no) {
                console.log("Seri numarası zaten mevcut:", existingSerialNo);
                showNotification('Bu seri numarası daha önce girilmiş!', 'error');
                input.value = '';
                return;
            }
        }

        // Yeni seri numarası satırı oluştur
        var newRow = document.createElement("tr");
        newRow.setAttribute("data-readed", "0");
        newRow.className = "fade-in";
        
        var newCell = document.createElement("td");
        newCell.innerHTML = `
            <i class="fas fa-plus-circle text-success"></i>
            ${parseResult.serial_no}
            <small class="text-success">(Yeni eklendi)</small>
        `;
        
        newRow.appendChild(newCell);
        serialsTable.appendChild(newRow);

        // Sayacı güncelle
        var currentCount = serialsTable.getElementsByTagName("tr").length;
        updateProductStatus(product_id, currentCount, totalQuantity);

        // Seri listesini görünür yap
        var serialRow = document.getElementById('serial_row_' + product_id);
        if (serialRow.style.display === 'none') {
            toggleSerials(product_id);
        }

        // Input alanını temizle ve focus ver
        input.value = '';
        input.focus();
        
        // Ses efekti (isteğe bağlı)
        try {
            const audio = new Audio();
            audio.src = 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA=';
            if (audio.canPlayType('audio/wav')) {
                audio.play().catch(() => {});
            }
        } catch (e) { /* sessiz geç */ }
    }
}
async function isSerialRegistered(serialNo) {
    const body = new URLSearchParams({ serialNo });
    const res = await fetch('/AddOns/Partner/cfc/serialservice.cfc?method=isRegistered&returnformat=json', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body
    });
    const data = await res.json();
    return data.exists === true;
}

function GetRows() {
    var SendingArray = [];
    var tablo = document.querySelector("#despatch_rows_table");
    
    for (let i = 0; i < tablo.rows.length; i++) {
        if (((i + 2) % 2) == 0) {
            var rw = tablo.rows[i];
            
            if (rw && rw.getAttribute("data-wrk_row_id")) {
                var wrk_row_id = rw.getAttribute("data-wrk_row_id");
                var product_id = rw.getAttribute("data-product_id");
                var stock_id = rw.getAttribute("data-stock_id");
                var product_code_2 = rw.getAttribute("data-product_code_2");
                
                var serials = [];
                var serialTable = document.getElementById('serials_' + product_id);
                
                if (serialTable) {
                    var rows = serialTable.getElementsByTagName('tr');
                    for (var j = 0; j < rows.length; j++) {
                        var cells = rows[j].getElementsByTagName('td');
                        if (cells.length > 0) {
                            // HTML etiketlerini ve parantez içindeki metinleri temizle
                            var cellContent = cells[0].innerText || cells[0].textContent;
                            var serialNo = cellContent
                                .replace(/<[^>]*>/g, '') // HTML etiketlerini kaldır
                                .replace(/\([^)]*\)/g, '') // Parantez içindeki metinleri kaldır
                                .replace(/\s+/g, ' ') // Birden fazla boşluğu tek boşluğa çevir
                                .trim();
                            
                            var isreaded = rows[j].getAttribute("data-readed") || "1";
                            if (serialNo) {
                                serials.push(serialNo + "|" + isreaded);
                            }
                        }
                    }
                }
                
                var dataObject = {
                    wrk_row_id: wrk_row_id,
                    product_id: product_id,
                    stock_id: stock_id,
                    product_code_2: product_code_2,
                    serials: serials
                };
                
                SendingArray.push(dataObject);
            }
        }
    }
    
    console.log('Gönderilecek veri:', SendingArray);
    return SendingArray;
}

function savePaper() {
    // Veri kontrolü
    var data = GetRows();
    var hasNewSerials = false;
    
    data.forEach(function(item) {
        item.serials.forEach(function(serial) {
            if (serial.endsWith('|0')) {
                hasNewSerials = true;
            }
        });
    });
    
    if (!hasNewSerials) {
        if (!confirm('Hiç yeni seri numarası eklenmemiş. Yine de kaydetmek istiyor musunuz?')) {
            return;
        }
    }
    
    // Loading göster
    $('body').append(`
        <div id="loading-overlay" style="
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(0,0,0,0.7); z-index: 10000; 
            display: flex; align-items: center; justify-content: center;
        ">
            <div style="background: white; padding: 30px; border-radius: 10px; text-align: center;">
                <i class="fas fa-spinner fa-spin fa-2x text-primary"></i>
                <h4 class="mt-3">Kaydediliyor...</h4>
                <p>Lütfen bekleyiniz.</p>
            </div>
        </div>
    `);
    
    var paperData = getPaperData;
    
    // Form oluştur ve gönder
    var form = document.createElement("form");
    form.method = "post";
    form.action = "index.cfm?fuseaction=purchase.emptypopup_save_despatch_serials_pbs";
    document.body.appendChild(form);
    
    var dataInput = document.createElement("input");
    dataInput.type = "hidden";
    dataInput.name = "data";
    dataInput.value = JSON.stringify(data);
    form.appendChild(dataInput);
    
    var paperDataInput = document.createElement("input");
    paperDataInput.type = "hidden";
    paperDataInput.name = "paperData";
    paperDataInput.value = JSON.stringify(paperData);
    form.appendChild(paperDataInput);
    
    form.submit();
    document.body.removeChild(form);
}

/**
 * Dönmez barkod formatını parse eder
 * Format: 700 382 0016-1-3-23.05.2025-3ZEZPKYRGEEZ
 * @param {string} barcode - Parse edilecek barkod
 * @returns {object|null} Parse edilen veri veya null (hata durumunda)
 */
function parseDonmezBarcode(barcode) {
    try {
        var barcodeArr = barcode.split("-");
        
        if (barcodeArr.length < 5) {
            return {
                success: false,
                error: 'Geçersiz Dönmez barkod formatı! Beklenen format: XXXXXX-X-X-TARİH-SERİ'
            };
        }
        
        var result = {
            success: true,
            product_code_2: barcodeArr[0].slice(0, 7),
            serial_no: barcodeArr[4],
            uretim_tarihi: barcodeArr[3] || "",
            paketleme_tarihi: barcodeArr[3] || "",
            parser_type: 1
        };
        
        console.table(result);
        return result;
        
    } catch (error) {
        return {
            success: false,
            error: 'Dönmez barkod parse hatası: ' + error.message
        };
    }
}

/**
 * Diğer barkod formatlarını parse eder
 * Format: ETA_SERI_URETIM_PAKETLEME
 * @param {string} barcode - Parse edilecek barkod
 * @returns {object|null} Parse edilen veri veya null (hata durumunda)
 */
function parseOtherBarcode(barcode) {
    try {
        var parts = barcode.split("_");
        
        if (parts.length < 2) {
            return {
                success: false,
                error: 'Geçersiz barkod formatı! Beklenen format: ETA_SERI_URETIM_PAKETLEME'
            };
        }
        
        var result = {
            success: true,
            product_code_2: parts[0], // ETA Kodu
            serial_no: parts[1], // Seri No
            uretim_tarihi: parts[2] || "", // Üretim Tarihi
            paketleme_tarihi: parts[3] || "", // Paketleme Tarihi
            parser_type: 2
        };
        
        console.table(result);
        return result;
        
    } catch (error) {
        return {
            success: false,
            error: 'Barkod parse hatası: ' + error.message
        };
    }
}

/**
 * Parser tipine göre barkodu parse eder
 * @param {string} barcode - Parse edilecek barkod
 * @param {number} parserType - Parser tipi (1: Dönmez, 2: Diğer)
 * @returns {object} Parse edilen veri
 */
function parseBarcode(barcode, parserType) {
    var bm=new BarcodeManager();
    if (parserType == 1) {
        return bm.parseWith(barcode,1);
    } else if (parserType == 2) {
        return bm.parseWith(barcode,2);
    }else if (parserType == 3) {
        return bm.parseWith(barcode,3);
    } 
    else {
        return {
            success: false,
            error: 'Geçersiz parser tipi: ' + parserType
        };
    }
}

// Klavye kısayolları
$(document).keydown(function(e) {
    // Ctrl+S ile kaydet
    if (e.ctrlKey && e.which === 83) {
        e.preventDefault();
        savePaper();
    }
    
    // ESC ile focus'u seri input'a ver
    if (e.which === 27) {
        $('#seri_no').focus();
    }
});
</script>


