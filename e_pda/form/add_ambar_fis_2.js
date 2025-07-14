
function checkKeycode(e) {
    var keycode;
    if (window.event) keycode = window.event.keyCode;
    else if (e) keycode = e.which;
    if (keycode == 13) {

        console.log('Enter key pressed');
        var barkod = $("#add_other_barcod").val().trim();
        var raf = $("#add_other_shelf").val().trim();
        var serial = $("#serial_number").val().trim();

        console.table({
            'barkod': barkod,
            'raf': raf,
            'serial': serial
        });

        if (serial.length > 0) {
            console.log('Serial number detected: ' + serial);
            var StockId_ = get_stock_with_serial_no(serial);
            if (raf.length > 0) {
                console.log('Shelf detected: ' + raf);
                //set_shelfs_with_serial_no(serial, stockid);
                search_shelf_with_serial_no(document.getElementById('add_other_shelf').value, StockId_);
            }

        } else if (barkod.length > 0) {
            console.log('Barcode detected: ' + barkod);
            get_stock(barkod);
        } else {
            console.log('No barcode or serial number detected');
            alert('Lütfen Barkod veya Seri Numarası Giriniz');
            document.getElementById('add_other_barcod').focus();
            return false;
        }


        // if (document.getElementById('add_other_barcod').value.length == '' && document.getElementById('add_other_shelf').value.length > 0) {
        //     alert('Önce Ürün Barkodu Okutunuz');
        //     document.getElementById('add_other_barcod').value = '';
        //     document.getElementById('add_other_shelf').value = '';
        //     document.getElementById('add_other_amount').value = 1;
        //     document.getElementById('add_other_barcod').focus();

        // }
        // else {
        //     if (document.getElementById('add_other_barcod').value.length > 0 && document.getElementById('add_other_shelf').value.length > 0)
        //         search_shelf(document.getElementById('add_other_shelf').value);
        //     else
        //         get_stock(document.getElementById('add_other_barcod').value);
        // }
    }
}

function search_shelf(shelf_8) {
    var cikis_depo = document.all.txt_department_out.value;
    var shelf_sql = "SELECT PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE = '" + shelf_8 + "'";
    var get_shelf = wrk_query(shelf_sql, 'dsn3');
    if (get_shelf.recordcount) {
        var cikis_depo_s = get_shelf.STORE_ID.toString() + '-' + get_shelf.LOCATION_ID.toString();
        if (cikis_depo != cikis_depo_s) {
            alert('Seçtiğiniz Raf Giriş Lokasyonunda Yoktur.!');
            document.getElementById('add_other_barcod').value = '';
            document.getElementById('add_other_shelf').value = '';
            document.getElementById('add_other_barcod').focus();
        }
        else {
            if (document.getElementById('add_other_barcod').value.length > 0) {
                var new_sql = "SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, PP.SHELF_CODE FROM STOCKS_BARCODES AS SB INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID INNER JOIN PRODUCT_PLACE_ROWS AS PPR ON S.PRODUCT_ID = PPR.PRODUCT_ID INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID WHERE SB.BARCODE = '" + document.getElementById('add_other_barcod').value + "' AND PP.SHELF_CODE ='" + document.getElementById('add_other_shelf').value + "'";
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
                    buton_kontrol();
                    document.getElementById('txt_department_out').disabled = true;
                    add_row(barcode);
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
            // ekle = 1;
            //cikar = 1;
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
    var cikis_depo = document.all.txt_department_out.value;
    var shelf_sql = "SELECT PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE = '" + shelf_8 + "'";
    var get_shelf = wrk_query(shelf_sql, 'dsn3');
    if (get_shelf.recordcount) {
        var cikis_depo_s = get_shelf.STORE_ID.toString() + '-' + get_shelf.LOCATION_ID.toString();
        if (cikis_depo != cikis_depo_s) {
            alert('Seçtiğiniz Raf Giriş Lokasyonunda Yoktur.!');
            document.getElementById('add_other_barcod').value = '';
            document.getElementById('add_other_shelf').value = '';
            document.getElementById('add_other_barcod').focus();
        }
        else {
            if (document.getElementById('add_other_barcod').value.length > 0) {
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
                    buton_kontrol();
                    document.getElementById('txt_department_out').disabled = true;
                    add_row(barcode);
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

function set_shelfs(xyz) {
    document.getElementById('shelf_select_td').style.display = '';
    var product_shelfs = wrk_query("SELECT PP.SHELF_CODE, PPR.AMOUNT, PP.PRODUCT_PLACE_ID, ISNULL((SELECT REAL_STOCK FROM GET_STOCK_LAST_SHELF WHERE SHELF_NUMBER = PP.PRODUCT_PLACE_ID AND STOCK_ID = PPR.STOCK_ID),0) AS REAL_STOCK FROM"+dsn3_alias+".PRODUCT_PLACE AS PP LEFT OUTER JOIN "+dsn3_alias+".PRODUCT_PLACE_ROWS AS PPR ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID WHERE PPR.STOCK_ID = " + xyz + " ORDER BY REAL_STOCK DESC", "dsn2");
    var option_count = document.getElementById('shelf_select').options.length;
    for (x = option_count; x >= 0; x--)
        document.getElementById('shelf_select').options[x] = null;
    if (product_shelfs.recordcount != 0) {
        for (var xx = 0; xx < product_shelfs.recordcount; xx++) {
            document.getElementById('shelf_select').options[xx] = new Option(product_shelfs.SHELF_CODE[xx] + "-" + product_shelfs.REAL_STOCK[xx], product_shelfs.PRODUCT_PLACE_ID[xx], product_shelfs.AMOUNT[xx]);
        }
    }
    else
        document.getElementById('shelf_select').options[0] = new Option('Raf Tanımsız', '');
}

function set_shelfs_with_serial_no(serial_no, xyz) {
    document.getElementById('shelf_select_td').style.display = '';
    //var product_shelfs = wrk_query("SELECT PP.SHELF_CODE, PPR.AMOUNT, PP.PRODUCT_PLACE_ID, ISNULL((SELECT REAL_STOCK FROM GET_STOCK_LAST_SHELF WHERE SHELF_NUMBER = PP.PRODUCT_PLACE_ID AND STOCK_ID = PPR.STOCK_ID),0) AS REAL_STOCK FROM <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS PP LEFT OUTER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE_ROWS AS PPR ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID WHERE PPR.STOCK_ID = "+xyz+" N ORDER BY REAL_STOCK DESC","dsn2");
    //SELECT * FROM w3Qa_2025_1.PBS_SHELF_STOCK_AMOUNTS WHERE STOCK_ID=1114 AND DEPO='2-1' ORDER BY REAL_STOCK DESCtxt_department_out
    var product_shelfs = wrk_query(`SELECT * FROM w3Qa_2025_1.PBS_SHELF_STOCK_AMOUNTS WHERE STOCK_ID=${xyz} AND DEPO='${form_basket.txt_department_out.value}' ORDER BY REAL_STOCK DESC`)
    var option_count = document.getElementById('shelf_select').options.length;
    for (x = option_count; x >= 0; x--)
        document.getElementById('shelf_select').options[x] = null;
    if (product_shelfs.recordcount != 0) {
        for (var xx = 0; xx < product_shelfs.recordcount; xx++) {
            document.getElementById('shelf_select').options[xx] = new Option(product_shelfs.SHELF_CODE[xx] + "-" + product_shelfs.REAL_STOCK[xx], product_shelfs.PRODUCT_PLACE_ID[xx], product_shelfs.AMOUNT[xx]);
        }

        //var depo_stock_sql = "SELECT ISNULL(PRODUCT_STOCK,0) AS PRODUCT_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL WHERE  DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID ="+xyz;
        var depo_stock_sql = `SELECT *FROM w3Qa_1.PBS_SERIAL_LAST_STOCK WHERE 1=1 AND DEPO='${form_basket.txt_department_in.value}' AND SERIAL_NO='${serial_no}'`;
        var depo_stock = wrk_query(depo_stock_sql, 'dsn2');
        if (depo_stock.PRODUCT_STOCK == undefined)
            depo_stock.PRODUCT_STOCK = 0;
        document.getElementById('add_other_amount').value = depo_stock.PRODUCT_STOCK;
    }
    else
        document.getElementById('shelf_select').options[0] = new Option('Raf Tanımsız', '');
}

function wrk_query(str_query, data_source, maxrows) {
    var new_query = new Object();
    var req;
    if (!data_source) data_source = 'dsn';
    if (!maxrows) maxrows = 0;
    function callpage(url) {
        req = false;
        if (window.XMLHttpRequest)
            try { req = new XMLHttpRequest(); }
            catch (e) { req = false; }
        else if (window.ActiveXObject)
            try {
                req = new ActiveXObject("Msxml2.XMLHTTP");
            }
            catch (e) {
                try { req = new ActiveXObject("Microsoft.XMLHTTP"); }
                catch (e) { req = false; }
            }
        if (req) {
            function return_function_() {

                if (req.readyState == 4 && req.status == 200)
                    try {
                        eval(req.responseText.replace(/\u200B/g, ''));
                        new_query = get_js_query; //alert('Cevap:\n\n'+req.responseText);//
                    }
                    catch (e) { new_query = false; }
            }
            req.open("post", url + '&xmlhttp=1', false);
            req.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setRequestHeader('pragma', 'nocache');
            if (encodeURI(str_query).indexOf('+') == -1) // + isareti encodeURI fonksiyonundan gecmedigi icin encodeURIComponent fonksiyonunu kullaniyoruz. EY 20120125
                req.send('str_sql=' + encodeURI(str_query) + '&data_source=' + data_source + '&maxrows=' + maxrows);
            else
                req.send('str_sql=' + encodeURIComponent(str_query) + '&data_source=' + data_source + '&maxrows=' + maxrows);
            return_function_();
        }

    }

    //TolgaS 20070124 objects yetkisi olmayan partnerlar var diye fuseaction objects2 yapildi
    callpage('/index.cfm?fuseaction=objects2.emptypopup_get_js_query&isAjax=1');
    //alert(new_query);

    return new_query;
}

