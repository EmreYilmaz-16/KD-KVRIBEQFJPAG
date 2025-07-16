<cfset default_process_type = 113>
<cfquery name="get_default_departments" datasource="#dsn#">
	SELECT        
    	DEFAULT_MK_TO_RF_DEP, 
        DEFAULT_MK_TO_RF_LOC
	FROM            
    	EZGI_PDA_DEPARTMENT_DEFAULTS
	WHERE        
    	EPLOYEE_ID = #session.ep.userid#
</cfquery>
<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("Default Depo Ayarları Yapılmamış! Sistem Yöneticinizle Görüşün");
		history.back();	
	</script>
</cfif>
<cfset default_departments = '#get_default_departments.DEFAULT_MK_TO_RF_DEP#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
<cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,1)#">
<cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT 
		D.DEPARTMENT_HEAD,
		SL.DEPARTMENT_ID,
		SL.LOCATION_ID,
		SL.STATUS,
		SL.COMMENT
	FROM 
		STOCKS_LOCATION SL,
		DEPARTMENT D,
		BRANCH B
	WHERE
		D.DEPARTMENT_ID IN (#default_departments#) AND
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
		SL.STATUS = 1 AND
		D.BRANCH_ID = B.BRANCH_ID
</cfquery>
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT TOP (1)    
    	SPC.PROCESS_CAT_ID
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE = #default_process_type# AND 
        SPCF.FUSE_NAME = 'pda.form_add_ambar_fis' 
  	ORDER BY
    	SPC.PROCESS_CAT_ID DESC      
</cfquery>
<cfif not get_process_cat.recordcount>
	<script type="text/javascript">
		alert("İşlem Kategorisi Tanımlayınız!");
		history.back();	
	</script>
</cfif>
<style type="text/css">
.boxtext {
	background-color: #e6e6fe;
	border: none;
	margin: 0;
	padding: 0;
}
.tablo {
	border-top: 1px solid #aec7f0;
	border-bottom: 1px solid #aec7f0;
	margin: 0;
	padding: 0;
}
.header {
	display: none;
}
</style>
<script type="text/javascript">
// Global Variables
const FormState = {
	rowCount: 0,
	barcode: '',
	stockId: '',
	stockCode: '',
	amount: '',
	shelfCode: '',
	isAdd: true,
	buttonCount: 0,
	serialNo: ''
};


// DOM Helper Functions
const DOM = {
	get: (id) => document.getElementById(id),
	focus: (id) => document.getElementById(id).focus(),
	getValue: (id) => document.getElementById(id).value,
	setValue: (id, value) => document.getElementById(id).value = value,
	show: (id) => document.getElementById(id).style.display = '',
	hide: (id) => document.getElementById(id).style.display = 'none'
};

// Form Functions
function clearForm() {
	DOM.setValue('add_other_barcod', '');
	DOM.setValue('add_other_shelf', '');
	DOM.setValue('add_other_amount', '1');
	DOM.focus('add_other_barcod');
	DOM.setValue('serial_number', '');
}

function resetFormState() {
	FormState.barcode = '';
	FormState.stockId = '';
	FormState.stockCode = '';
	FormState.shelfCode = '';
	FormState.serialNo = '';
}
var DsnVariables = {
	dsn: '<cfoutput>#dsn#</cfoutput>',
	dsn2: '<cfoutput>#dsn2#</cfoutput>',
	dsn3: '<cfoutput>#dsn3#</cfoutput>',
	dsn3_alias: '<cfoutput>#dsn3_alias#</cfoutput>'
};
</script>
<cfform name="form_basket">
  <cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
  <cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
  <input type="hidden" name="kuponlist" value="" />
  <input type="hidden" name="active_period" value="#session.ep.period_id#" />
  <div style="width:290px">
  <table cellpadding="2" cellspacing="1" align="left" class="color-border" width="99%">
    <tr class="color-list">
      <td colspan="4">
      	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="color-border">
          <tr class="color-list">
            <td align="center" width="45px">Miktar</td>
            <td align="center" width="95px">Barcode</td>
			<td align="center" width="95px">Seri No</td>
            <td align="center">Raf</td>
            <td></td>
       	  </tr>
          <tr height="20px" class="color-list">
            <td><input id="add_other_amount" name="add_other_amount" type="text" class="moneybox" onfocus="FormState.isAdd=true;" style="width:40px; text-align:right" value="1" /></td>
            <td><input id="add_other_barcod" name="add_other_barcod" type="text" value="" style="width:90px;" ></td>
			<td><input id="serial_number" name="serial_number" type="text" value="" style="width:90px;" ></td>
            <td><input id="add_other_shelf" name="add_other_shelf" type="text" class="moneybox" onfocus="FormState.isAdd=true;" style="width:60px;" value="" /></td>
            <td>
              <div id="shelf_select_td" style="display:none">
                <select name="shelf_select" id="shelf_select" style="width:70px;height:20px;text-align:center">
                  <option value="">Ürün Rafları</option>
                </select>
              </div>
            </td>
          </tr>
          <input id="del_other_amount" name="del_other_amount" type="hidden" onfocus="FormState.isAdd=false;" value="1" />
          <input id="del_other_barcod" name="del_other_barcod" type="hidden" value="" style="width:90px;" >
        </table>
      </td>
    </tr>
    <tr class="color-list">
      <td colspan="4">
      	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="color-border">
           <tr class="color-list" height="15px">
            <td align="center" width="50%">Çıkış Depo</td>
            <td align="center" width="50%">Giriş Depo</td>
           </tr>
           <tr class="color-list" height="25px">
            <td>
              <select name="txt_department_out" id="txt_department_out" style="width:120px; height:20px" onchange="document.getElementById('department_out').value = this.value">
                <cfoutput query="get_all_location" group="department_id">
                  <option disabled="disabled" value="#department_id#"<cfif attributes.department_out_id eq department_id>selected</cfif>>#department_head#</option>
                  <cfoutput>
                    <option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_out_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#
                    <cfif not status>
                      -
                      <cf_get_lang_main no='82.Pasif'>
                    </cfif>
                    </option>
                  </cfoutput> </cfoutput>
              </select>
          	</td>
            <td>
              <select name="txt_department_in" id="txt_department_in" style="width:120px; height:20px" onchange="document.getElementById('department_in').value = this.value">
                <cfoutput query="get_all_location" group="department_id">
                  <option disabled="disabled"  value="#department_id#"<cfif attributes.department_in_id eq department_id>selected</cfif>>#department_head#</option>
                  <cfoutput>
                    <option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_in_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#
                    <cfif not status>
                      -
                      <cf_get_lang_main no='82.Pasif'>
                    </cfif>
                    </option>
                  </cfoutput> </cfoutput>
              </select>
              </td>
          </tr>
        </table>
      </td>
    </tr>
    <tr class="color-list" height="15px">
      <td width="85" align="center">Barkod</td>
      <td width="90" align="left">Ürün Adı</td>
      <td width="40" align="right">Mikt.</td>
      <td align="left">Raf</td>
    </tr>
    <tr class="color-list" height="25px">
      <td align="left" colspan="4"><!---  kontrol edilen tablo--->
        <form name="product_row" id="product_row" method="post">
          <table name="table1" id="table1" border="0" cellpadding="0" cellspacing="0" width="100%" class="tablo">
          </table>
        </form>
        <!---  kontrol edilen tablo---></td>
    </tr>
    <tr class="color-list" height="25px">
      <td colspan="6" align="right">
      	<input type="hidden" id="department_in" name="department_in" value="" />
      	<input type="hidden" id="row_count" name="row_count" value="0" />
        <input type="hidden" id="action_id" name="action_id" value="" />
        <input id="onay" name="Onay" value="<cf_get_lang_main no="49.Kaydet">" type="button" disabled="disabled" onClick="validateAndSave();" /></td>
    </tr>
  </table>
  </div>
</cfform>
<script type="text/javascript">
$(document).ready(function() {
	$(".header").hide();
	DOM.focus('add_other_barcod');
	setTimeout(() => DOM.get('add_other_barcod').select(), 1000);
});

function generateActionId() {
	let actionItems = [];
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
	DOM.setValue('action_id', actionItems.join(','));
	DOM.setValue('row_count', actionItems.length);
}

function toggleSubmitButton() {
	const isEnabled = FormState.isAdd ? 
		FormState.buttonCount > 0 : 
		FormState.buttonCount < 1;
	DOM.get('onay').disabled = !isEnabled;
}

function updateButtonState() {
	if (FormState.isAdd) {
		FormState.buttonCount++;
	} else if (FormState.buttonCount > 0) {
		FormState.buttonCount--;
	}
	toggleSubmitButton();
}

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

function checkStock(shelfCode, stockId, amount) {
	const sql = `SELECT ISNULL(S.REAL_STOCK, 0) AS PRODUCT_STOCK 
		FROM GET_STOCK_LAST_SHELF AS S 
		INNER JOIN ${DsnVariables.dsn3_alias}.PRODUCT_PLACE AS P 
		ON S.SHELF_NUMBER = P.PRODUCT_PLACE_ID 
		WHERE P.SHELF_CODE = '${shelfCode}' AND S.STOCK_ID = ${stockId}`;
	
	const stockData = wrk_query(sql, 'dsn2');
	
	if (stockData.PRODUCT_STOCK < amount) {
		alert(`Yetersiz Stok. Çıkış Rafındaki Stok Miktarı: ${stockData.PRODUCT_STOCK}`);
		return false;
	}
	return true;
}

function addAmount() {
	DOM.hide('shelf_select_td');
	const amount = parseFloat(DOM.getValue('add_other_amount'));
	const shelfCode = DOM.getValue('add_other_shelf');
	
	// Check existing rows first
	for (let i = 1; i <= FormState.rowCount; i++) {
		if (DOM.getValue('stockid' + i) === FormState.stockId) {
			const currentAmount = parseFloat(DOM.getValue('amount' + i));
			const newAmount = currentAmount + amount;
			
			if (!checkStock(shelfCode, FormState.stockId, newAmount)) {
				DOM.focus('add_other_amount');
				return false;
			}
			
			if (DOM.getValue('stockid' + i) === FormState.stockId && 
				DOM.getValue('shelf_code' + i) === FormState.shelfCode) {
				DOM.setValue('amount' + i, newAmount);
				DOM.show('frm_row' + i);
				return true;
			}
		}
	}
	
	// New row - check stock
	return checkStock(shelfCode, FormState.stockId, amount);
}
function addRow(barcode) {
	FormState.amount = DOM.getValue('add_other_amount');
	
	if (!addAmount()) {
		return false;
	}
	
	FormState.rowCount++;
	DOM.setValue('row_count', FormState.rowCount);
	
	const table = DOM.get('table1');
	const newRow = table.insertRow(table.rows.length);
	newRow.id = `frm_row${FormState.rowCount}`;
	
	const cells = [
		`<input type="hidden" value="${FormState.stockId}" name="stockid${FormState.rowCount}" id="stockid${FormState.rowCount}" />
		 <input type="text" value="${barcode}" name="barcod${FormState.rowCount}" id="barcod${FormState.rowCount}" size="13" class="boxtext" readonly />`,
		
		`<input type="text" value="${FormState.stockCode}" name="stockcode${FormState.rowCount}" id="stockcode${FormState.rowCount}" size="13" class="boxtext" readonly />`,
		
		`<input type="text" style="text-align:right" value="${FormState.amount}" name="amount${FormState.rowCount}" id="amount${FormState.rowCount}" size="5" class="boxtext" readonly />`,
		
		`<input type="text" value="${FormState.shelfCode}" name="shelf_code${FormState.rowCount}" id="shelf_code${FormState.rowCount}" size="12" class="boxtext" readonly />`
	];
	
	cells.forEach(cellContent => {
		const cell = newRow.insertCell();
		cell.innerHTML = cellContent;
	});
	
	return true;
}

// Event Handlers
document.addEventListener('keydown', function (e) {
    if (e.keyCode === 13) { // Enter key
        const barcode = DOM.getValue('add_other_barcod');
        const shelf = DOM.getValue('add_other_shelf');
        const serialNo = DOM.getValue('serial_number');

        if (serialNo.length > 0) {
            // If serial number is provided, search by serial number
            console.log('Searching by Serial No:', serialNo);
            var isHaveStock=getStockWithSerialNo(serialNo);
			console.log(isHaveStock);
			console.table(FormState)

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
WHERE SB.SERIAL_NO = '${serialNo}'`;

    const product = wrk_query(sql, 'dsn3');

    if (!product.STOCK_ID) {
        alert('Ürün Bulunamadı');
        return false;
    }

    FormState.stockId = product.STOCK_ID;
    FormState.stockCode = product.PRODUCT_NAME;
    FormState.barcode = product.BARCODE;
	FormState.serialNo = serialNo;

    DOM.focus('add_other_shelf');
    setShelfs(FormState.stockId);
    updateButtonState();
    return true;
}

function searchShelf(shelfCode) {
	const exitWarehouse = DOM.getValue('txt_department_out');
	const sql = `SELECT PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID 
		FROM PRODUCT_PLACE 
		WHERE PLACE_STATUS = 1 AND SHELF_CODE = '${shelfCode}'`;
	
	const shelf = wrk_query(sql, 'dsn3');
	
	if (!shelf.recordcount) {
		alert('Seçtiğiniz Raf Hiç Tanımlanmamış!');
		DOM.setValue('add_other_shelf', '');
		DOM.focus('add_other_shelf');
		return;
	}
	
	const shelfLocation = `${shelf.STORE_ID}-${shelf.LOCATION_ID}`;
	if (exitWarehouse !== shelfLocation) {
		alert('Seçtiğiniz Raf Giriş Lokasyonunda Yoktur!');
		clearForm();
		return;
	}
	
	const barcode = DOM.getValue('add_other_barcod');
	if (!barcode) {
		DOM.focus('add_other_barcod');
		return;
	}
	
	const productSql = `SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, PP.SHELF_CODE 
		FROM STOCKS_BARCODES AS SB 
		INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID 
		INNER JOIN PRODUCT_PLACE_ROWS AS PPR ON S.PRODUCT_ID = PPR.PRODUCT_ID 
		INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID 
		WHERE SB.BARCODE = '${barcode}' AND PP.SHELF_CODE = '${shelfCode}'`;
	
	const product = wrk_query(productSql, 'dsn3');
	
	if (!product.STOCK_ID) {
		alert('Ürün Bu Rafa Tanıtılmamış');
		DOM.setValue('add_other_shelf', '');
		DOM.focus('add_other_shelf');
		return;
	}
	
	FormState.stockId = product.STOCK_ID;
	FormState.stockCode = product.PRODUCT_NAME;
	FormState.barcode = product.BARCODE;
	FormState.shelfCode = product.SHELF_CODE;
	
	updateButtonState();
	DOM.get('txt_department_out').disabled = true;
	
	if (addRow(FormState.barcode)) {
		clearForm();
	}
}

function setShelfs(stockId) {
	DOM.show('shelf_select_td');
	
	const sql = `SELECT PP.SHELF_CODE, PPR.AMOUNT, PP.PRODUCT_PLACE_ID, 
		ISNULL((SELECT REAL_STOCK FROM GET_STOCK_LAST_SHELF 
			WHERE SHELF_NUMBER = PP.PRODUCT_PLACE_ID AND STOCK_ID = PPR.STOCK_ID), 0) AS REAL_STOCK 
		FROM <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS PP 
		LEFT OUTER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE_ROWS AS PPR 
		ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID 
		WHERE PPR.STOCK_ID = ${stockId} 
		ORDER BY REAL_STOCK DESC`;
	
	const shelfs = wrk_query(sql, 'dsn2');
	const selectElement = DOM.get('shelf_select');
	
	// Clear existing options
	selectElement.innerHTML = '';
	
	if (shelfs.recordcount > 0) {
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
function validateAndSave() {
	const departmentIn = DOM.getValue('txt_department_in');
	
	if (!departmentIn) {
		alert('Depo Seçmelisiniz.');
		return false;
	}
	
	if (departmentIn.indexOf('-') === -1) {
		alert('Lütfen giriş için doğru depo seçiniz.');
		return false;
	}
	
	generateActionId();
	
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
</script>


<script>
    function wrk_query(str_query,data_source,maxrows)
{
	/*console.log(str_query);
	alert('Bu sayfada wrk_query kullanılmıştır. İlgili kontrolü ajax yapısına çeviriniz.');
	return false;
	*/
	/*
	by  Workcube
	Created 20060315
	Modified 20060324
	Usage:
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1');
		veya
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1','dsn2');
		veya
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1 ORDER BY COL2 DESC','dsn2',1);
		ifadesi ile my_query degiskeni cfquery ile donen sonucun tamamen aynisi bir javascript query degeri alir
		data_source : optional , default olarak 'dsn' kullaniliyor
		maxrows : optional , default olarak 0 ataniyor, 0 olunca query sonucundaki tum kayitlar gelir
	*/
	
	var new_query=new Object();
	var req;
	if(!data_source) data_source='dsn';
	if(!maxrows) maxrows=0;
	function callpage(url) {
		req = false;
		if(window.XMLHttpRequest)
			try
				{req = new XMLHttpRequest();}
			catch(e)
				{req = false;}
		else if(window.ActiveXObject)
			try {
				req = new ActiveXObject("Msxml2.XMLHTTP");
				}
			catch(e)
				{
				try {req = new ActiveXObject("Microsoft.XMLHTTP");}
				catch(e)
					{req = false;}
				}
		if(req)
			{
				function return_function_()
				{

				if (req.readyState == 4 && req.status == 200)
					try
						{
							eval(req.responseText.replace(/\u200B/g,''));
							new_query = get_js_query; //alert('Cevap:\n\n'+req.responseText);//
						}
					catch(e)
						{new_query = false;}
				}
			req.open("post", url+'&xmlhttp=1', false);
			req.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
			req.setRequestHeader('pragma','nocache');
			if(encodeURI(str_query).indexOf('+') == -1) // + isareti encodeURI fonksiyonundan gecmedigi icin encodeURIComponent fonksiyonunu kullaniyoruz. EY 20120125
				req.send('str_sql='+encodeURI(str_query)+'&data_source='+data_source+'&maxrows='+maxrows);
			else
				req.send('str_sql='+encodeURIComponent(str_query)+'&data_source='+data_source+'&maxrows='+maxrows);
			return_function_();
			}
		
	}
	
	//TolgaS 20070124 objects yetkisi olmayan partnerlar var diye fuseaction objects2 yapildi
	callpage('/index.cfm?fuseaction=objects2.emptypopup_get_js_query&isAjax=1');
	//alert(new_query);
	
	return new_query;
}
</script>