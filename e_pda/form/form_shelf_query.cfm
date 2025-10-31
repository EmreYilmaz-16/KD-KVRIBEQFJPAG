<style>
.shelf-query-wrapper {
    max-width: 520px;
    margin: 24px auto;
    padding: 0 12px;
}
.shelf-query-card {
    background: #ffffff;
    border: 1px solid #e5e7eb;
    border-radius: 12px;
    box-shadow: 0 8px 18px rgba(15, 23, 42, 0.08);
    overflow: hidden;
}
.shelf-query-header {
    background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);
    color: #ffffff;
    padding: 20px 24px;
}
.shelf-query-header h2 {
    margin: 0 0 4px;
    font-size: 20px;
    font-weight: 600;
}
.shelf-query-header p {
    margin: 0;
    font-size: 13px;
    opacity: 0.85;
}
.shelf-query-body {
    padding: 24px;
}
.shelf-query-form .form-group {
    margin-bottom: 16px;
}
.shelf-query-form label {
    display: block;
    font-weight: 600;
    color: #1f2937;
    margin-bottom: 6px;
}
.shelf-query-form .form-control,
.shelf-query-form select {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid #d1d5db;
    border-radius: 8px;
    font-size: 14px;
    transition: border-color 0.2s ease, box-shadow 0.2s ease;
}
.shelf-query-form .form-control:focus,
.shelf-query-form select:focus {
    border-color: #2563eb;
    box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
    outline: none;
}
.input-actions {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
}
.primary-btn,
.secondary-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    padding: 10px 16px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    cursor: pointer;
    transition: transform 0.15s ease, box-shadow 0.15s ease;
}
.primary-btn {
    background: #2563eb;
    color: #ffffff;
    box-shadow: 0 8px 14px rgba(37, 99, 235, 0.25);
}
.primary-btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 12px 20px rgba(37, 99, 235, 0.28);
}
.secondary-btn {
    background: #f3f4f6;
    color: #1f2937;
}
.secondary-btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 12px rgba(15, 23, 42, 0.12);
}
.helper-text {
    font-size: 12px;
    color: #6b7280;
    margin-top: 4px;
}
.feedback {
    margin: 12px 24px 0;
    padding: 12px 16px;
    border-radius: 8px;
    font-size: 13px;
    display: none;
}
.feedback.info {
    background: #eff6ff;
    color: #1d4ed8;
    border: 1px solid #bfdbfe;
}
.feedback.success {
    background: #ecfdf5;
    color: #047857;
    border: 1px solid #a7f3d0;
}
.feedback.warning {
    background: #fef3c7;
    color: #b45309;
    border: 1px solid #fcd34d;
}
.feedback.error {
    background: #fef2f2;
    color: #b91c1c;
    border: 1px solid #fecaca;
}
.shelf-results {
    padding: 20px 24px 24px;
}
.shelf-results h3 {
    margin: 0 0 12px;
    font-size: 16px;
    font-weight: 600;
    color: #1f2937;
}
.shelf-results table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
    border-radius: 10px;
    overflow: hidden;
}
.shelf-results thead {
    background: #f1f5f9;
    color: #1f2937;
}
.shelf-results th,
.shelf-results td {
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid #e5e7eb;
}
.shelf-results tbody tr:hover {
    background: #f8fafc;
}
.shelf-results tbody tr:last-child td {
    border-bottom: none;
}
.empty-row td {
    text-align: center;
    color: #6b7280;
}
</style>

<div class="shelf-query-wrapper">
    <div class="shelf-query-card">
        <div class="shelf-query-header">
            <h2>Raf Sorgulama</h2>
            <p>Ürün barkodunu okutarak raf yerleşimini hızlıca görüntüleyin.</p>
        </div>
        <div class="shelf-query-body">
            <form class="shelf-query-form" onsubmit="return false;">
                <div class="form-group">
                    <label for="barkod">Barkod</label>
                    <input type="text" placeholder="Barkod" name="barkod" id="barkod" onkeydown="checkbarcode(this,event);" class="form-control" value="">
                    <p class="helper-text">Okutulduktan sonra Enter tuşuna basın ya da Ara düğmesini kullanın.</p>
                </div>
                <div class="form-group">
                    <label for="BarcodeParser">Barkod Tipi</label>
                    <select name="BarcodeParser" id="BarcodeParser" class="form-control">
                        <option value="0">Barkod Tipi</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="raf">Raf Kodu</label>
                    <input type="text" name="raf" id="raf" placeholder="Raf Kodu" onkeydown="checkRaf(this,event)" class="form-control">
                    <p class="helper-text">Raf kodunu girin ve Enter tuşuna basarak kaydedin.</p>
                </div>
                <div class="input-actions">
                    <button type="button" class="primary-btn" id="barcode_search_button">Ara</button>
                    <button type="button" class="secondary-btn" id="reset_form_button">Temizle</button>
                </div>
            </form>
        </div>
        <div id="feedback" class="feedback" aria-live="polite"></div>
        <div class="shelf-results">
            <h3>Tanımlı Raflar</h3>
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th width="50%">Raf Kodu</th>
                        <th width="25%">Kapasite</th>
                        <th width="25%">Mevcut</th>
                    </tr>
                </thead>
                <tbody id="shelf_results_body">
                    <tr class="empty-row">
                        <td colspan="3">Henüz raf bilgisi yok.</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
var bm = null;
var main_product_id = 0;
var main_stock_id = 0;
var activeProductCode = '';
var feedbackElement = null;

$(document).ready(function(){
    bm = new BarcodeManager();
    feedbackElement = document.getElementById('feedback');
    populateBarcodeParsers();
    $('#barcode_search_button').on('click', function(){
        var barcodeVal = $('#barkod').val().trim();
        handleBarcodeLookup(barcodeVal);
    });
    $('#reset_form_button').on('click', function(){
        resetShelfForm();
    });
    $('#barkod').focus();
});

function populateBarcodeParsers(){
    var parsers = bm.listParsers();
    var $parserSelect = $('#BarcodeParser');
    $parserSelect.empty().append('<option value="0">Barkod Tipi</option>');
    for(var i = 0; i < parsers.length; i++){
        $parserSelect.append('<option value="' + parsers[i].id + '">' + parsers[i].name + '</option>');
    }
}

function showFeedback(message, type){
    if(!feedbackElement){
        return;
    }
    feedbackElement.className = 'feedback';
    if(type){
        feedbackElement.className += ' ' + type;
    }
    feedbackElement.textContent = message || '';
    feedbackElement.style.display = message ? 'block' : 'none';
}

function handleBarcodeLookup(barcode){
    if(!barcode){
        showFeedback('Lütfen barkod giriniz.', 'warning');
        return;
    }
    showFeedback('Barkod analiz ediliyor...', 'info');
    var parserVal = document.getElementById('BarcodeParser').value;
    var parserId = parseInt(parserVal, 10);
    var serialObject = null;
    var productCode = barcode;
    try{
        if(!isNaN(parserId) && parserId > 0){
            serialObject = bm.parseWith(barcode, parserId);
            console.log('Barcode parsed:', serialObject);
            if(serialObject && serialObject.serial_no && serialObject.product_code_2){
                productCode = serialObject.product_code_2;
                console.log('Extracted product_code_2:', productCode);
            }
        }else{
            console.log('No barcode parser selected, using raw serial.');
        }
    }catch(parseErr){
        console.warn('Barcode parsing failed, using raw input.', parseErr);
    }
    createRows(productCode);
}

function checkbarcode(input, event){
    if(event.key === 'Enter'){
        event.preventDefault();
        handleBarcodeLookup(input.value.trim());
    }
}

function createRows(product_code_2){
    if(!product_code_2){
        showFeedback('Barkod verisinden ürün kodu alınamadı.', 'error');
        return;
    }
    activeProductCode = product_code_2;
    var sql = "SELECT * FROM STOCKS WHERE PRODUCT_CODE_2='" + product_code_2 + "'";
    console.log(sql);
    var qResult = wrk_query(sql, 'dsn3');
    console.log(qResult);
    if(!qResult || !qResult.recordcount){
        renderShelfRows(null);
        showFeedback('Bu barkoda ait stok bulunamadı.', 'error');
        $('#raf').val('');
        $('#barkod').focus();
        return;
    }
    var stockId = qResult.STOCK_ID ? qResult.STOCK_ID[0] : 0;
    var productId = qResult.PRODUCT_ID ? qResult.PRODUCT_ID[0] : stockId;
    if(!stockId){
        renderShelfRows(null);
        showFeedback('Stok kaydı bulunamadı.', 'error');
        return;
    }
    main_stock_id = stockId;
    main_product_id = productId;
    console.table({stockId: stockId, productId: productId, product_code_2: product_code_2});
    var recordedShelfsQuery = "SELECT PP.SHELF_CODE, PP.PRODUCT_PLACE_ID FROM w3Qa_1.PRODUCT_PLACE AS PP LEFT JOIN w3Qa_1.PRODUCT_PLACE_ROWS AS PPR ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID WHERE PPR.STOCK_ID=" + stockId;
    var recordedShelfsQueryResult = wrk_query(recordedShelfsQuery, 'dsn3');
    renderShelfRows(recordedShelfsQueryResult);
    if(recordedShelfsQueryResult && recordedShelfsQueryResult.recordcount > 0){
        showFeedback('Tanımlı raflar güncellendi.', 'success');
    }else{
        showFeedback('Bu ürüne ait raf bulunamadı.', 'warning');
        $('#raf').val('').focus();
    }
}

function renderShelfRows(result){
    var tableBody = document.getElementById('shelf_results_body');
    if(!tableBody){
        return;
    }
    tableBody.innerHTML = '';
    if(!result || !result.recordcount){
        tableBody.innerHTML = '<tr class="empty-row"><td colspan="3">Henüz raf bilgisi yok.</td></tr>';
        return;
    }
    for(var i = 0; i < result.recordcount; i++){
        var tr = document.createElement('tr');

        var shelfTd = document.createElement('td');
        shelfTd.textContent = result.SHELF_CODE ? result.SHELF_CODE[i] : '-';
        tr.appendChild(shelfTd);

        var capacityTd = document.createElement('td');
        var capacityValue = resolveValue(result, ['CAPACITY', 'MAX_CAPACITY', 'TOTAL_CAPACITY'], i);
        capacityTd.textContent = capacityValue !== null && capacityValue !== '' ? capacityValue : '-';
        tr.appendChild(capacityTd);

        var currentTd = document.createElement('td');
        var currentValue = resolveValue(result, ['CURRENT_STOCK', 'CURRENT_QUANTITY', 'QUANTITY', 'ON_HAND', 'AVAILABLE_QUANTITY'], i);
        currentTd.textContent = currentValue !== null && currentValue !== '' ? currentValue : '-';
        tr.appendChild(currentTd);

        tableBody.appendChild(tr);
    }
}

function resolveValue(target, keys, index){
    for(var i = 0; i < keys.length; i++){
        if(typeof target[keys[i]] !== 'undefined' && target[keys[i]][index] !== undefined && target[keys[i]][index] !== null){
            return target[keys[i]][index];
        }
    }
    return null;
}

function resetShelfForm(){
    $('#barkod').val('');
    $('#raf').val('');
    activeProductCode = '';
    renderShelfRows(null);
    showFeedback('Form sıfırlandı.', 'info');
    $('#barkod').focus();
}

function wrk_query(str_query, data_source, maxrows) {
    if (!data_source) data_source = 'dsn';
    if (!maxrows) maxrows = 0;

    var new_query = {};
    var req = createXMLHttpRequest();

    if (req) {
        req.open('post', '/index.cfm?fuseaction=objects2.emptypopup_get_js_query&isAjax=1&xmlhttp=1', false);
        req.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setRequestHeader('pragma', 'nocache');

        var queryParam = encodeURI(str_query).indexOf('+') === -1 ?
            'str_sql=' + encodeURI(str_query) :
            'str_sql=' + encodeURIComponent(str_query);

        req.send(queryParam + '&data_source=' + data_source + '&maxrows=' + maxrows);

        if (req.readyState === 4 && req.status === 200) {
            try {
                eval(req.responseText.replace(/\u200B/g, ''));
                new_query = get_js_query;
            } catch(e) {
                console.error('Sorgu sonucu işlenemedi.', e);
                showFeedback('Sorgu sonucu işlenirken bir hata oluştu.', 'error');
                new_query = false;
            }
        }
    }

    return new_query;
}

function createXMLHttpRequest() {
    var req = false;

    if (window.XMLHttpRequest) {
        try {
            req = new XMLHttpRequest();
        } catch(e) {
            req = false;
        }
    } else if (window.ActiveXObject) {
        try {
            req = new ActiveXObject('Msxml2.XMLHTTP');
        } catch(e) {
            try {
                req = new ActiveXObject('Microsoft.XMLHTTP');
            } catch(e) {
                req = false;
            }
        }
    }

    return req;
}

function checkRaf(input, event) {
    if(event.key === 'Enter'){
        event.preventDefault();
        var rafCode = input.value.trim();
        console.log('Raf Kodu Girildi:', rafCode);
        if(!rafCode){
            showFeedback('Lütfen raf kodu giriniz.', 'warning');
            return;
        }
        var r = wrk_query("SELECT * FROM PRODUCT_PLACE WHERE SHELF_CODE='" + rafCode + "'", 'dsn3');
        if(r && r.recordcount > 0){
            console.log('Raf Kodu Bulundu:', rafCode);
            var d = {
                shelf_code: rafCode,
                product_id: main_product_id,
                stock_id: main_stock_id,
                product_place_id: r.PRODUCT_PLACE_ID ? r.PRODUCT_PLACE_ID[0] : null
            };
            console.log('Gönderilen Veri:', d);
            $.ajax({
                url:'/AddOns/partner/cfc/depoService.cfc?method=saveProductToShelf',
                type:'POST',
                data:d,
                dataType:'json',
                success:function(response){
                    console.log('Sunucudan Gelen Yanıt:', response);
                    if(response && response.SUCCESS){
                        showFeedback('Raf başarıyla eklendi!', 'success');
                        $('#raf').val('');
                        $('#barkod').val('');
                        $('#barkod').focus();
                        if(activeProductCode){
                            createRows(activeProductCode);
                        } else {
                            renderShelfRows(null);
                        }
                    }else{
                        var message = response && response.message ? response.message : 'Raf eklenirken bir hata oluştu.';
                        showFeedback(message, 'error');
                    }
                },
                error:function(xhr, status, error){
                    console.error('AJAX Hatası:', status, error);
                    showFeedback('Raf eklenirken bir AJAX hatası oluştu.', 'error');
                }
            });
        }else{
            console.log('Raf Kodu Bulunamadı:', rafCode);
            showFeedback('Böyle bir raf kodu bulunamadı!', 'error');
        }
    }
}
</script>

