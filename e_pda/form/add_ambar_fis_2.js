$(document).ready(function () {
    $(".header").hide();
    DOM.focus('add_other_barcod');
    setTimeout(() => DOM.get('add_other_barcod').select(), 1000);
});


// Event Handlers
document.addEventListener('keydown', function (e) {
    if (e.keyCode === 13) { // Enter key
        const barcode = DOM.getValue('add_other_barcod');
        const shelf = DOM.getValue('add_other_shelf');
        const serialNo = DOM.getValue('serial_number');

        if (serialNo.length > 0) {
            // If serial number is provided, search by serial number
            console.log('Searching by Serial No:', serialNo);
            var stockId=getStockWithSerialNo(serialNo);

        } else if (barcode.length > 0) {
            if (!barcode && shelf) {
                alert('Önce Ürün Barkodu Okutunuz');
                clearForm();
                return;
            }

            if (barcode && shelf) {
                searchShelf(shelf);
            } else if (barcode) {
                getStock(barcode);
            }
        }

    }
});



function getStock(barcode) {
    resetFormState();

    const sql = `SELECT SB.STOCK_ID, SB.BARCODE, PU.MAIN_UNIT, PU.MULTIPLIER, S.PRODUCT_NAME 
		FROM STOCKS_BARCODES AS SB 
		INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID 
		INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID 
		WHERE SB.BARCODE = '${barcode}'`;

    const product = wrk_query(sql, 'dsn3');

    if (!product.STOCK_ID) {
        alert('Ürün Bulunamadı');
        return false;
    }

    FormState.stockId = product.STOCK_ID;
    FormState.stockCode = product.PRODUCT_NAME;
    FormState.barcode = product.BARCODE;

    DOM.focus('add_other_shelf');
    setShelfs(FormState.stockId);
    updateButtonState();
    return true;
}


function getStockWithSerialNo(serialNo) {
    resetFormState();

    const sql = `SELECT TOP 1 SB.STOCK_ID
	,SB.SERIAL_NO
	,PU.MAIN_UNIT
	,PU.MULTIPLIER
	,S.PRODUCT_NAME
FROM w3qa_1.SERVICE_GUARANTY_NEW AS SB
INNER JOIN w3qa_1.STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID
INNER JOIN w3qa_1.PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
WHERE SB.SERIAL_NO = '${serialno}'`;

    const product = wrk_query(sql, 'dsn3');

    if (!product.STOCK_ID) {
        alert('Ürün Bulunamadı');
        return false;
    }

    FormState.stockId = product.STOCK_ID;
    FormState.stockCode = product.PRODUCT_NAME;
    FormState.barcode = product.BARCODE;

    DOM.focus('add_other_shelf');
    setShelfs(FormState.stockId);
    updateButtonState();
    return true;
}

function setShelfs(stockId) {
    DOM.show('shelf_select_td'); // Raf seçim dropdown'unu göster

    // SQL ile o ürünün raflarını ve stok miktarlarını getir
    const shelfs = wrk_query(sql, 'dsn2');
    const selectElement = DOM.get('shelf_select');

    selectElement.innerHTML = ''; // Mevcut seçenekleri temizle

    if (shelfs.recordcount > 0) {
        // Her raf için option oluştur
        for (let i = 0; i < shelfs.recordcount; i++) {
            const option = new Option(
                `${shelfs.SHELF_CODE[i]}-${shelfs.REAL_STOCK[i]}`,
                shelfs.PRODUCT_PLACE_ID[i]
            );
            selectElement.add(option);
        }
    } else {
        selectElement.add(new Option('Raf Tanımsız', ''));
    }
}
function searchShelf(shelfCode) {
    // 1. Raf doğrulama
    const shelf = wrk_query(sql, 'dsn3');
    if (!shelf.recordcount) {
        alert('Seçtiğiniz Raf Hiç Tanımlanmamış!');
        return;
    }

    // 2. Raf lokasyon kontrolü
    const shelfLocation = `${shelf.STORE_ID}-${shelf.LOCATION_ID}`;
    if (exitWarehouse !== shelfLocation) {
        alert('Seçtiğiniz Raf Giriş Lokasyonunda Yoktur!');
        return;
    }

    // 3. Ürün-raf eşleşme kontrolü
    const product = wrk_query(productSql, 'dsn3');
    if (!product.STOCK_ID) {
        alert('Ürün Bu Rafa Tanıtılmamış');
        return;
    }

    // 4. FormState güncelle
    FormState.stockId = product.STOCK_ID;
    FormState.stockCode = product.PRODUCT_NAME;
    FormState.barcode = product.BARCODE;
    FormState.shelfCode = product.SHELF_CODE;

    updateButtonState(); // 🔄 Buton durumunu güncelle
    DOM.get('txt_department_out').disabled = true; // Çıkış deposunu kilitle

    if (addRow(FormState.barcode)) { // 🔄 5. adıma geç
        clearForm(); // Formu temizle
    }
}
function addRow(barcode) {
    FormState.amount = DOM.getValue('add_other_amount');

    if (!addAmount()) { // 🔄 6. adıma geç - stok kontrolü
        return false;
    }

    FormState.rowCount++; // Satır sayısını artır
    DOM.setValue('row_count', FormState.rowCount);

    // Tabloya yeni satır ekle
    const table = DOM.get('table1');
    const newRow = table.insertRow(table.rows.length);
    newRow.id = `frm_row${FormState.rowCount}`;

    // Hücreleri oluştur ve içeriği ekle
    const cells = [/* barcode, ürün adı, miktar, raf */];
    cells.forEach(cellContent => {
        const cell = newRow.insertCell();
        cell.innerHTML = cellContent;
    });

    return true;
}
function addAmount() {
    DOM.hide('shelf_select_td');
    const amount = parseFloat(DOM.getValue('add_other_amount'));
    const shelfCode = DOM.getValue('add_other_shelf');

    // Mevcut satırlarda aynı ürün var mı kontrol et
    for (let i = 1; i <= FormState.rowCount; i++) {
        if (DOM.getValue('stockid' + i) === FormState.stockId) {
            const currentAmount = parseFloat(DOM.getValue('amount' + i));
            const newAmount = currentAmount + amount;

            if (!checkStock(shelfCode, FormState.stockId, newAmount)) { // 🔄 7. adım
                DOM.focus('add_other_amount');
                return false;
            }

            // Aynı ürün ve raf ise miktarı güncelle
            if (DOM.getValue('shelf_code' + i) === FormState.shelfCode) {
                DOM.setValue('amount' + i, newAmount);
                DOM.show('frm_row' + i);
                return true;
            }
        }
    }

    // Yeni satır için stok kontrolü
    return checkStock(shelfCode, FormState.stockId, amount); // 🔄 7. adım
}
function checkStock(shelfCode, stockId, amount) {
    // SQL ile o raftaki gerçek stok miktarını kontrol et
    const stockData = wrk_query(sql, 'dsn2');

    if (stockData.PRODUCT_STOCK < amount) {
        alert(`Yetersiz Stok. Çıkış Rafındaki Stok Miktarı: ${stockData.PRODUCT_STOCK}`);
        return false;
    }
    return true;
}
function updateButtonState() {
    if (FormState.isAdd) {
        FormState.buttonCount++;
    } else if (FormState.buttonCount > 0) {
        FormState.buttonCount--;
    }
    toggleSubmitButton(); // 🔄 9. adım
}

function toggleSubmitButton() {
    const isEnabled = FormState.isAdd ?
        FormState.buttonCount > 0 :
        FormState.buttonCount < 1;
    DOM.get('onay').disabled = !isEnabled;
}
function validateAndSave() {
    const departmentIn = DOM.getValue('txt_department_in');

    // Depo seçimi kontrolü
    if (!departmentIn) {
        alert('Depo Seçmelisiniz.');
        return false;
    }

    if (departmentIn.indexOf('-') === -1) {
        alert('Lütfen giriş için doğru depo seçiniz.');
        return false;
    }

    generateActionId(); // 🔄 10. adım

    // URL parametrelerini oluştur ve sayfayı yönlendir
    const params = new URLSearchParams({
        fuseaction: 'pda.add_ambar_fis',
        tersfis: '1',
        dep_in: departmentIn,
        dep_out: DOM.getValue('txt_department_out'),
        action_id: DOM.getValue('action_id'),
        fis_tipi: DOM.getValue('fis_tipi'),
        process_cat: DOM.getValue('process_cat_id')
    });

    window.location.href = '<cfoutput>#request.self#</cfoutput>?' + params.toString();
}
function generateActionId() {
    let actionItems = [];

    // Tüm satırları kontrol et
    for (let i = 1; i <= FormState.rowCount; i++) {
        if (parseFloat(DOM.getValue('amount' + i)) > 0) {
            const item = [
                i,
                DOM.getValue('stockid' + i),
                DOM.getValue('amount' + i),
                DOM.getValue('shelf_code' + i)
            ].join('-');
            actionItems.push(item);
        }
    }

    // Action ID'yi oluştur ve hidden input'lara yaz
    DOM.setValue('action_id', actionItems.join(','));
    DOM.setValue('row_count', actionItems.length);
}