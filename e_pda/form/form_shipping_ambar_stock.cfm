<style>
.ui-table-list>tfoot>tr>td, 
.ui-table-list>tbody>tr>td, 
.ui-table-list>thead>tr>td {
    border: 1px solid #bbb;
    font-size: 12px;
    padding: 0px;
    color: #555;
    min-width: 30px;
}
</style>

<cf_box title="Sevkiyat Hazırlama">
<cfset default_process_type = 113> <!---Dikkat Firmaya Göre Değişebilir--->
<cfparam name="attributes.department_in_id" default="">
<cfparam name="attributes.department_out_id" default="">
<!--- İşlem Kategorisi Kontrolü --->
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT TOP (1) SPC.PROCESS_CAT_ID
	FROM SETUP_PROCESS_CAT AS SPC 
		INNER JOIN SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID 
		INNER JOIN SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE SPC.PROCESS_TYPE = #default_process_type# 
		AND SPCF.FUSE_NAME = 'pda.form_shipping_ambar_stock' 
	ORDER BY SPC.PROCESS_CAT_ID DESC
</cfquery>

<cfif not get_process_cat.recordcount>
	<script type="text/javascript">
		alert("İşlem Kategorisi Tanımlayınız!");
		history.back();	
	</script>
</cfif>
<!--- Stok Bilgilerini Getir --->
<cfquery name="get_stock_info" datasource="#dsn3#">
	SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, S.STOCK_CODE, S.STOCK_CODE_2
	FROM STOCKS_BARCODES AS SB 
		INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID
	WHERE SB.STOCK_ID = #f_stock_id#
</cfquery>

<!--- Raf Tipi Kontrolü --->
<cfquery name="get_store_type" datasource="#dsn3#">
	SELECT COUNT(*) AS RAF
	FROM PRODUCT_PLACE
	WHERE LOCATION_ID = #ListGetAt(attributes.department_out_id,2,"-")#  
		AND STORE_ID = #ListGetAt(attributes.department_in_id,1,"-")# 
		AND PLACE_STATUS = 1
</cfquery>
<!--- Raflı Depo İşlemleri --->
<cfif get_store_type.raf gt 0>
	<!--- Ambar Fişi Sorgula (Raflı) --->
	<cfquery name="get_ambar_fis" datasource="#dsn2#">
		SELECT SUM(SFR.AMOUNT) AS AMOUNT, PP.SHELF_CODE, S.STOCK_CODE, S.PRODUCT_ID, 
			   S.PROPERTY, S.BARCOD, S.PRODUCT_NAME, SFR.STOCK_ID
		FROM STOCK_FIS AS SF 
			INNER JOIN STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID 
			INNER JOIN #dsn3_alias#.PRODUCT_PLACE AS PP ON SFR.SHELF_NUMBER = PP.PRODUCT_PLACE_ID 
			INNER JOIN #dsn3_alias#.STOCKS AS S ON SFR.STOCK_ID = S.STOCK_ID
		WHERE SF.REF_NO = '#attributes.deliver_paper_no#' 
			AND SFR.STOCK_ID = #f_stock_id#
		GROUP BY PP.SHELF_CODE, S.STOCK_CODE, S.PRODUCT_ID, S.PROPERTY, S.BARCOD, S.PRODUCT_NAME, SFR.STOCK_ID
	</cfquery>
	
	<!--- Raf Stok Durumu --->
	<cfquery name="get_shelf_stock" datasource="#dsn2#">
		SELECT PP.SHELF_CODE, PPR.AMOUNT, PP.PRODUCT_PLACE_ID, 
			   ISNULL((SELECT REAL_STOCK FROM GET_STOCK_LAST_SHELF 
					   WHERE SHELF_NUMBER = PP.PRODUCT_PLACE_ID AND STOCK_ID = PPR.STOCK_ID), 0) AS REAL_STOCK
		FROM #dsn3_alias#.PRODUCT_PLACE AS PP 
			LEFT OUTER JOIN #dsn3_alias#.PRODUCT_PLACE_ROWS AS PPR ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID
		WHERE PPR.STOCK_ID = #f_stock_id#
		ORDER BY PP.SHELF_CODE ASC
	</cfquery>
<cfelse>
	<!--- Normal Depo İşlemleri --->
	<cfquery name="get_ambar_fis" datasource="#dsn2#">
		SELECT SUM(SFR.AMOUNT) AS AMOUNT, S.STOCK_CODE, S.PRODUCT_ID, S.PROPERTY, S.BARCOD, S.PRODUCT_NAME, SFR.STOCK_ID
		FROM STOCK_FIS AS SF 
			INNER JOIN STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID 
			INNER JOIN #dsn3_alias#.STOCKS AS S ON SFR.STOCK_ID = S.STOCK_ID
		WHERE SF.REF_NO = '#attributes.deliver_paper_no#' 
			AND SFR.STOCK_ID = #f_stock_id# 
			AND SF.DEPARTMENT_OUT = #ListGetAt(attributes.department_out_id,1,"-")#  
			AND SF.LOCATION_OUT = #ListGetAt(attributes.department_out_id,2,"-")# 
		GROUP BY S.STOCK_CODE, S.PRODUCT_ID, S.PROPERTY, S.BARCOD, S.PRODUCT_NAME, SFR.STOCK_ID
	</cfquery>
	
	<!--- Depo Stok Kontrolü --->
	<cfquery name="get_depo_stok" datasource="#dsn2#">
		SELECT PRODUCT_STOCK 
		FROM EZGI_GET_STOCK_LOCATION_TOTAL 
		WHERE DEPO = '#attributes.department_out_id#' AND STOCK_ID = #f_stock_id#
	</cfquery>
</cfif>
<!--- Toplam Miktar Hesaplama --->
<cfquery name="get_ambar_fis_group" datasource="#dsn2#">
	SELECT ISNULL(SUM(SFR.AMOUNT), 0) AS AMOUNT
	FROM STOCK_FIS AS SF 
		INNER JOIN STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID
	WHERE SF.REF_NO = '#attributes.deliver_paper_no#' 
		AND SFR.STOCK_ID = #f_stock_id#
</cfquery>

<cfset all_amount = get_ambar_fis_group.recordcount ? get_ambar_fis_group.amount : 0>

<div class="row">
	<div class="col col-md-2 col-sm-12 col-xs-12">
		<cf_grid_list>
			<cfoutput>
				<tr>
					<td style="font-size:12pt">#attributes.product_name#</td>
					<td style="font-size:12pt;text-align:center">
						<span style="font-size:12pt">#attributes.paket_sayisi#</span>/<span style="font-size:12pt">#all_amount#</span>
					</td>
				</tr>
			</cfoutput>
		</cf_grid_list>
		
		<cfform name="form_basket" action="#request.self#?fuseaction=pda.emptypopup_add_shipping_ambar_stock">
			<!--- Form URL Parametreleri --->
			<cfinput id="shelf_type" name="shelf_type" type="hidden" value="#get_store_type.raf#">
			<cfinput id="date1" name="date1" type="hidden" value="#attributes.date1#">
			<cfinput id="date2" name="date2" type="hidden" value="#attributes.date2#">
			<cfinput id="is_type" name="is_type" type="hidden" value="#attributes.is_type#">
			<cfinput id="keyword" name="keyword" type="hidden" value="#attributes.keyword#">
			<cfinput id="dep_in" name="dep_in" type="hidden" value="#attributes.department_in_id#">
			<cfinput id="dep_out" name="dep_out" type="hidden" value="#attributes.department_out_id#">
			<cfinput id="ref_no" name="ref_no" type="hidden" value="#attributes.deliver_paper_no#">
			<cfinput id="ship_id" name="ship_id" type="hidden" value="#attributes.ship_id#">
			<cfinput id="f_stock_id" name="f_stock_id" type="hidden" value="#f_stock_id#">
			<input type="hidden" name="action_id" id="action_id" value="">
			<input type="hidden" name="fis_tipi" id="fis_tipi" value="">
			<cfinput id="PROCESS_CAT " name="PROCESS_CAT" type="hidden" value="#get_process_cat.process_cat_id#">
			
			<!--- Orijinal Form Hidden Alanları --->
			<cfinput id="txt_department_out" name="txt_department_out" type="hidden" value="#attributes.department_out_id#">
			<cfinput id="txt_department_in" name="txt_department_in" type="hidden" value="#attributes.department_in_id#">
			<cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
			<input type="hidden" name="row_count" id="row_count" value="0">
			
			<div style="display:flex">
				<div class="form-group">
					<label for="miktar">Miktar</label>
					<input type="text" class="moneybox" name="miktar" id="miktar" value="1" readonly>
				</div>
				<div class="form-group">
					<label for="serial_number">Seri Numarası</label>
					<input type="text" name="serial_number" id="serial_number" class="moneybox" placeholder="Seri Numarası">
				</div>
				<cfif get_store_type.raf gt 0>
					<div class="form-group">
						<label for="txt_shelf_number">Raf Numarası</label>
						<input type="text" class="moneybox" name="txt_shelf_number" id="txt_shelf_number" value="" placeholder="Raf Numarası">
					</div>
				</cfif>
			</div>
			
			<div class="form-group">
				<cfif get_store_type.raf gt 0>
					<select name="shelf_select" style="width:100px; text-align:center">
						<cfoutput query="get_shelf_stock">
							<option value="">#SHELF_CODE# - #REAL_STOCK#</option>
						</cfoutput>
					</select>
				<cfelse>
					Depo Miktarı : <cfoutput>#AmountFormat(get_depo_stok.product_stock)#</cfoutput>
				</cfif>
			</div>
			
			<cf_grid_list id="table1" name="table1">
				<thead><tr><th>Seri No</th><th>Barkod</th><th>Miktar</th><th>Raf</th></tr></thead>
				<tbody id="table1" name="table1"></tbody>
			</cf_grid_list>
			
			<!--- Form Submit Butonları --->
			<div class="form-group" style="margin-top: 10px;">
				<button type="submit" class="btn btn-primary" onclick="submitForm()">Kaydet</button>
				<button type="button" class="btn btn-secondary" onclick="clearAllInputs()">Temizle</button>
			</div>
		</cfform>
	</div>
</div>
<script>
// Global Variables
var stock_id = <cfoutput>#f_stock_id#;</cfoutput>
var is_rafli = <cfoutput>#get_store_type.raf#</cfoutput>;
var all_amount = <cfoutput>#all_amount#</cfoutput>;
var serial_number = '';
var department_in_id = <cfoutput>#listgetat(attributes.department_in_id,1,"-")#</cfoutput>;
var location_in_id = <cfoutput>#listgetat(attributes.department_in_id,2,"-")#</cfoutput>;
var department_out_id = <cfoutput>#listgetat(attributes.department_out_id,1,"-")#</cfoutput>;
var location_out_id = <cfoutput>#listgetat(attributes.department_out_id,2,"-")#</cfoutput>;
var paketSayisi = <cfoutput>#attributes.paket_sayisi#</cfoutput>;
var row_count = 0;
var TarihKontrol=false;
var TarihKontrolLokasyonIds="'2-1','2-2'";
var formArgs = {
    stock_id: stock_id,
    is_rafli: is_rafli,
    all_amount: all_amount,
    serial_number: serial_number,
    department_in_id: department_in_id,
    location_in_id: location_in_id,
    department_out_id: department_out_id,
    location_out_id: location_out_id,
    paketSayisi: paketSayisi,
    TarihKontrol: TarihKontrol

};

// DOM Ready
$(document).ready(function(){
    $(".header").hide();
});

// Klavye Kontrolü
document.onkeydown = function(e) {
    var keycode = window.event ? window.event.keyCode : e.which;
    if (keycode == 13) {
        console.log('Enter tuşuna basıldı');
        e.preventDefault();
        processSerialNumber();
    }
}

// Ana İşlem Fonksiyonu
function processSerialNumber() {
    var miktar = document.getElementById('miktar').value;
    var serial_number = document.getElementById('serial_number').value;
    
    if (!serial_number) {
        alert('Seri numarası giriniz!');
        return false;
    }
    
    // Seri Numarası Kontrolü
    var hasStock = checkSerialNumber(serial_number);
    
    if (!hasStock) {
        alert('Seri Numarası Bulunamadı veya Seri Numarası Kullanımda!');
        return false;
    }
    
    // Raf kontrolü
    if (is_rafli > 0) {
        return processRafliDepo(serial_number);
    } else {
        return processNormalDepo(serial_number);
    }
}

// Seri Numarası Kontrol Fonksiyonu
function checkSerialNumber(serialNumber) {
    var sql = `SELECT IS_ALIVE, PURCHASE_DATE FROM w3Qa_1.SERIAL_IN_OUT_PBS WHERE SERIAL_NUMBER='${serialNumber}' AND STOCK_ID=${formArgs.stock_id}`;
    var result = wrk_query(sql, 'dsn3', 1);
    
    console.log('Serial Check Result:', result);
    
    if (result.recordcount > 0 && result.IS_ALIVE[0] == 1) {
        // Eski tarihli seri kontrolü
       // var oncekiSql = `SELECT COUNT(*) MK FROM w3Qa_1.SERIAL_IN_OUT_PBS WHERE STOCK_ID=${formArgs.stock_id} AND CAST(PURCHASE_DATE AS DATE) < CAST('${result.PURCHASE_DATE}' AS DATE) AND IS_ALIVE=1`;
//         var oncekiSql=`
//         SELECT * FROM w3Qa_1.vw_SerialAliveWithDepo
//         WHERE 1=1
//         AND DEPO IN (${TarihKontrolLokasyonIds})
//         AND PURCHASE_DATE < CAST('${result.PURCHASE_DATE}' AS DATE) 
//         AND STOCK_ID = ${formArgs.stock_id}
//   `

//         var oncekiResult = wrk_query(oncekiSql, "DSN3");

var oncekiSql=`
        SELECT * FROM w3Qa_1.vw_SerialAliveWithDepo
        WHERE 1=1
        AND DEPO IN (${TarihKontrolLokasyonIds})
        AND PURCHASE_DATE < CAST('${result.PURCHASE_DATE}' AS DATE) 
        AND STOCK_ID = ${formArgs.stock_id} AND SERIAL_NUMBER NOT IN (${SerialNumberList})
  `

        var oncekiResult = wrk_query(oncekiSql, "DSN3");
        console.log('Onceki Check Result:', oncekiResult);


        
        if (formArgs.TarihKontrol && parseInt(oncekiResult.MK) > 0) {
            alert("Daha Eski Tarihli Seriler Var");
            clearInputs();
            return false;
        }
        return true;
    }
    return false;
}

// Raflı Depo İşlemi
function processRafliDepo(serialNumber) {
    var shelf_number = document.getElementById('txt_shelf_number').value;
    
    if (!shelf_number) {
        document.getElementById('txt_shelf_number').focus();
        return false;
    }
    
    // Raf kontrolü
    var rafSql = `SELECT * FROM PRODUCT_PLACE_ROWS AS PPR INNER JOIN PRODUCT_PLACE AS PP ON PP.PRODUCT_PLACE_ID=PPR.PRODUCT_PLACE_ID WHERE PPR.STOCK_ID=${formArgs.stock_id} AND SHELF_CODE='${shelf_number}' AND STORE_ID=${formArgs.department_out_id} AND LOCATION_ID=${formArgs.location_out_id}`;
    var rafResult = wrk_query(rafSql, "dsn3");
    
    if (rafResult.recordcount == 0) {
        alert("Çıkış Deposunda Bu Raf Bulunmamaktadır ve ya Ürün Bu Rafa Tanımlı Değildir");
        return false;
    }
    var shelf_id = rafResult.PRODUCT_PLACE_ID[0];
    
    // Raf-seri eşleşme kontrolü
    var rafKontrolSql = `SELECT SHELF_NUMBER, SUM(CASE WHEN IN_OUT = 1 THEN 1 ELSE -1 END) AS V FROM w3Qa_1.SERVICE_GUARANTY_NEW WHERE SERIAL_NO='${serialNumber}' GROUP BY SHELF_NUMBER HAVING SHELF_NUMBER=${rafResult.PRODUCT_PLACE_ID[0]}`;
    var rafKontrolSonuc = wrk_query(rafKontrolSql, 'dsn3', 1);
    
    if (rafKontrolSonuc.recordcount == 0 || rafKontrolSonuc.V[0] <= 0) {
        alert("Raf Numarası ve Seri Numarası Eşleşmiyor veya Rafta Ürün Bulunmamaktadır!");
        return false;
    }
    
    // Başarılı işlem - satır ekle
    addRowToTable(serialNumber, '', 1, shelf_number,shelf_id);
    clearInputs();
    return true;
}

// Normal Depo İşlemi
function processNormalDepo(serialNumber) {
    addRowToTable(serialNumber, '', 1, '');
    clearInputs();
    return true;
}

// Tabloya Satır Ekleme
function addRowToTable(serialNo, stockCode, amount, shelfCode,shelf_id) {
    row_count++;
    document.getElementById('row_count').value = row_count;
    
    var table = document.getElementById("table1");
    var newRow = table.insertRow(table.rows.length);
    
    newRow.setAttribute("id", "frm_row" + row_count);
    
    // Hücreler
    var cells = [
        `<input type="hidden" value="${formArgs.stock_id}" name="stockid${row_count}" id="stockid${row_count}" />
         <input type="hidden" value="" name="spectmainid${row_count}" id="spectmainid${row_count}" />
         <input type="text" value="${serialNo}" name="serino${shelf_id}" id="serino${row_count}" size="13" class="boxtext" readonly />`,
        
        `<input type="text" value="${stockCode}" name="stockcode${row_count}" id="stockcode${row_count}" size="13" class="boxtext" readonly />`,
        
        `<input type="text" style="text-align:center" value="${amount}" name="TTamount${row_count}" id="amount${row_count}" size="5" class="boxtext" readonly />`,
        
        `<input type="text" value="${shelfCode}" name="TTshelf_code${row_count}" id="shelf_code${row_count}" size="8" class="boxtext" readonly style="text-align:right" />`
    ];
    
    cells.forEach(function(cellContent) {
        var newCell = newRow.insertCell();
        newCell.innerHTML = `<div class="form-group">${cellContent}</div>`;
    });
}

// Input Temizleme
function clearInputs() {
    document.getElementById('serial_number').value = "";
    if (is_rafli > 0) {
        document.getElementById('txt_shelf_number').value = "";
    }
    document.getElementById('serial_number').focus();
}

// Form Submit Fonksiyonu
function submitForm() {
    if (row_count == 0) {
        alert('En az bir seri numarası eklemelisiniz!');
        return false;
    }
    
    // action_id ve fis_tipi değerlerini güncelle
    //document.getElementById('action_id').value = 'save'; // veya gerekli değer
	actionidolustur();
    document.getElementById('fis_tipi').value = 'shipping'; // veya gerekli değer
    
    // Formu submit et
    document.form_basket.submit();
}

// Tüm Input'ları Temizle
function clearAllInputs() {
    if (confirm('Tüm veriler silinecek. Emin misiniz?')) {
        // Tabloyu temizle
        var table = document.getElementById("table1");
        var rowCount = table.rows.length;
        for (var i = rowCount - 1; i > 0; i--) {
            table.deleteRow(i);
        }
        
        // Row count'u sıfırla
        row_count = 0;
        document.getElementById('row_count').value = 0;
        
        // Input'ları temizle
        clearInputs();
    }
}


// AJAX Query Fonksiyonu - Workcube
function wrk_query(str_query, data_source, maxrows) {
    if (!data_source) data_source = 'dsn';
    if (!maxrows) maxrows = 0;
    
    var new_query = new Object();
    var req = createXMLHttpRequest();
    
    if (req) {
        req.open("post", '/index.cfm?fuseaction=objects2.emptypopup_get_js_query&isAjax=1&xmlhttp=1', false);
        req.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setRequestHeader('pragma', 'nocache');
        
        var queryParam = encodeURI(str_query).indexOf('+') == -1 ? 
            'str_sql=' + encodeURI(str_query) : 
            'str_sql=' + encodeURIComponent(str_query);
            
        req.send(queryParam + '&data_source=' + data_source + '&maxrows=' + maxrows);
        
        if (req.readyState == 4 && req.status == 200) {
            try {
                eval(req.responseText.replace(/\u200B/g, ''));
                new_query = get_js_query;
            } catch(e) {
                new_query = false;
            }
        }
    }
    
    return new_query;
}
function actionidolustur()
	{
	  document.getElementById("action_id").value="";
var ARRR=[];
for(let i=1;i<=row_count;i++){
    var STOCK_ID=$("#stockid"+i).val()
    var SHELF_NUMBER=$("#shelf_code"+i).val();
    var AMOUNT=1;
    var ix=ARRR.findIndex(p=>p.SHELF_NUMBER==SHELF_NUMBER)
    if(ix==-1){
        ARRR.push({SHELF_NUMBER,STOCK_ID,AMOUNT})
    }else{
        ARRR[ix].AMOUNT++
    }
}
console.log(ARRR)
var ACSTR=document.getElementById("action_id").value;
for(let i=0;i<ARRR.length;i++){    
    if(ACSTR.length>0) ACSTR+=",";
    ACSTR+=(i+1)+"-";
    ACSTR+=ARRR[i].STOCK_ID+"-";
    ACSTR+=ARRR[i].AMOUNT+"-";
    ACSTR+=ARRR[i].SHELF_NUMBER;
    

}
 document.getElementById("action_id").value=ACSTR;
	}

// XMLHttpRequest oluşturma fonksiyonu
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
            req = new ActiveXObject("Msxml2.XMLHTTP");
        } catch(e) {
            try {
                req = new ActiveXObject("Microsoft.XMLHTTP");
            } catch(e) {
                req = false;
            }
        }
    }
    
    return req;
}
</script>
</cf_box>
