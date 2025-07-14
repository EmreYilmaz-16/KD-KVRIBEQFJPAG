function get_stock_with_serial_no(serialno) {
    barcod = ''; stockid = ''; stockcode = ''; spectmainid = '';
    serial_no = ""; //ilk önce sıfırlıyoruz
    console.log('get_stock_with_serial_no called with serialno: ' + serialno);
    k_ = 0;
    if (k_ == 0) {
        //var new_sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER, S.PRODUCT_NAME FROM STOCKS_BARCODES AS SB INNER JOIN              PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '"+barcode+"'";
        var new_sql = `SELECT TOP 1 SB.STOCK_ID
	,SB.SERIAL_NO
	,PU.MAIN_UNIT
	,PU.MULTIPLIER
	,S.PRODUCT_NAME
FROM w3qa_1.SERVICE_GUARANTY_NEW AS SB
INNER JOIN w3qa_1.STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID
INNER JOIN w3qa_1.PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
WHERE SB.SERIAL_NO = '${serialno}'`;

        console.log('Executing SQL: ' + new_sql);
        var get_product = wrk_query(new_sql, 'dsn3');
        if (get_product.STOCK_ID == undefined) {
            ekle = 1;
            cikar = 1;
            k_ = 1;
            alert('Ürün Bulunamadı');
        }
        else {

            stockid = get_product.STOCK_ID;
            stockcode = get_product.PRODUCT_NAME;
            barcode = get_product.BARCODE;
            document.getElementById('add_other_shelf').focus();
            set_shelfs_with_serial_no(serialno, stockid);
            buton_kontrol();
        }
    }
    else {
        barcod = ''; stockid = ''; stockcode = ''; spectmainid = '';
        return false;
    }
    return stockid;
}


function search_shelf_with_serial_no(shelf_8, sid) {
    var giris_depo = document.all.txt_department_out.value;
    var shelf_sql = "SELECT PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE = '" + shelf_8 + "'";
    var get_shelf = wrk_query(shelf_sql, 'dsn3');
    if (get_shelf.recordcount) {
        var giris_depo_s = get_shelf.STORE_ID.toString() + '-' + get_shelf.LOCATION_ID.toString();
        console.log('Giriş depo: ' + giris_depo + ', Giriş depo SQL: ' + giris_depo_s);
        if (giris_depo != giris_depo_s) {
            alert('Seçtiğiniz Raf Giriş Lokasyonunda Yoktur.!');
            document.getElementById('serial_number').value = '';
            document.getElementById('add_other_shelf').value = '';
            document.getElementById('serial_number').focus();
        }
        else {
            if (document.getElementById('serial_number').value.length > 0) {
                var new_sql = "SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, PP.SHELF_CODE FROM STOCKS_BARCODES AS SB INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID INNER JOIN PRODUCT_PLACE_ROWS AS PPR ON S.PRODUCT_ID = PPR.PRODUCT_ID INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID WHERE SB.STOCK_ID = '" + sid + "' AND PP.SHELF_CODE ='" + document.getElementById('add_other_shelf').value + "'";
                var get_product = wrk_query(new_sql, 'dsn3');
                if (get_product.STOCK_ID == undefined) {
                    alert('Ürün Bu Rafa Tanıtılmamış');
                    document.getElementById('add_other_shelf').value = '';
                    document.getElementById('add_other_shelf').focus();
                }
                else {
                    stockid = get_product.STOCK_ID;
                    stockcode = get_product.PRODUCT_NAME;
                    barcode = get_product.BARCODE;
                    shelf_code = get_product.SHELF_CODE;
                    serial_no = document.getElementById('serial_number').value;
                    buton_kontrol();
                    add_row_with_serial_no(serial_no);
                    document.getElementById('add_other_barcod').value = '';
                    document.getElementById('add_other_shelf').value = '';
                    document.getElementById('add_other_amount').value = 1;
                    document.getElementById('add_other_barcod').focus();
                }
            }
            else if (document.getElementById('add_other_barcod').value.length == 0) {
                document.getElementById('add_other_barcod').focus();
            }
            else {
                alert('Ürün Barkodu Hatalı');
                document.getElementById('add_other_barcod').value = '';
                document.getElementById('add_other_shelf').value = '';
                document.getElementById('add_other_barcod').focus();
            }
        }
    }
    else {
        alert('Seçtiğiniz Raf Hiç Tanımlanmamış!');
        document.getElementById('add_other_shelf').value = '';
        document.getElementById('add_other_shelf').focus();
    }
}