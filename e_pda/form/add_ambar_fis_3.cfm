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
<cf_get_lang_set module_name="stock">
<cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
<cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT        
    	D.DEPARTMENT_HEAD, 
        SL.DEPARTMENT_ID, 
        SL.LOCATION_ID, 
        SL.STATUS, 
        SL.COMMENT, 
        TBL.STORE_ID
	FROM            
    	STOCKS_LOCATION AS SL INNER JOIN
    	DEPARTMENT AS D ON SL.DEPARTMENT_ID = D.DEPARTMENT_ID INNER JOIN
      	BRANCH AS B ON D.BRANCH_ID = B.BRANCH_ID LEFT OUTER JOIN
     	(
        	SELECT        
            	STORE_ID, LOCATION_ID
         	FROM            
            	#dsn3_alias#.PRODUCT_PLACE
        	GROUP BY STORE_ID, LOCATION_ID
    	) AS TBL ON SL.LOCATION_ID = TBL.LOCATION_ID AND SL.DEPARTMENT_ID = TBL.STORE_ID
	WHERE        
    	D.DEPARTMENT_ID IN (#default_departments#) AND 
        SL.STATUS = 1 AND 
        TBL.STORE_ID IS NOT NULL
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
	padding: 2px;
}

.tablo {
	margin: 0;
	padding: 0;
	border-top: 1px solid #aec7f0;
	border-bottom: 1px solid #aec7f0;
}

.header {
	display: none;
}

.input-container {
	width: 100%;
}

.shelf-info {
	font-size: 12px;
	color: #666;
}
</style>
<script type="text/javascript">
// Global variables with better organization
var AppState = {
	rowCount: 0,
	barcode: '',
	stockId: '',
	stockCode: '',
	amount: '',
	canAdd: false,
	operationType: 0, // 0-ekle 1-çıkar
	buttonActive: 0,
	shelfCodeOut: '',
	shelfCodeIn: '',
	serialNo: '',
	useSerialNo: false
};

// Configuration
var Config = {
	BARCODE_LENGTH: 13,
	SHELF_CODE_LENGTHS: [8, 11],
	QUERIES: {
		STOCK_BY_BARCODE: "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER, S.PRODUCT_NAME FROM STOCKS_BARCODES AS SB INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE = '{{barcode}}'",
		STOCK_BY_SERIAL: "SELECT TOP 1 SB.STOCK_ID,SB.SERIAL_NO,PU.MAIN_UNIT,PU.MULTIPLIER,S.PRODUCT_NAME FROM w3qa_1.SERVICE_GUARANTY_NEW AS SB INNER JOIN w3qa_1.STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID INNER JOIN w3qa_1.PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID WHERE SB.SERIAL_NO = '{{serial}}'",
		SHELF_VALIDATION: "SELECT PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE = '{{shelf}}'",
		PRODUCT_IN_SHELF: "SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, PP.SHELF_CODE FROM STOCKS_BARCODES AS SB INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID INNER JOIN PRODUCT_PLACE_ROWS AS PPR ON S.PRODUCT_ID = PPR.PRODUCT_ID INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID WHERE {{condition}} AND PP.SHELF_CODE = '{{shelf}}'"
	}
};
</script>
<cfform name="form_basket">
  <cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
  <cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
  <input type="hidden" name="kuponlist" value="" />
  <input type="hidden" name="active_period" value="#session.ep.period_id#" />
  <table cellpadding="2" cellspacing="1" align="left" class="color-border" >
    <tr class="color-list">
      <td colspan="4">
      	<table border="0" cellpadding="0" cellspacing="0"  class="color-border">
          <tr class="color-list">
            <td align="center" width="25px">Miktar</td>
            <td align="center" width="57px">Barcode</td>
			<td align="center" width="60px">Seri No</td>
            <td align="center" width="60px">Çıkış Raf</td>
            <td align="center" width="60px">Giriş Raf</td>
       	  </tr>
          <tr class="color-list">
            <td><input id="add_other_amount" type="text" class="boxtext" onfocus="AppState.operationType=0;" style="width:25px; text-align:right" value="1" /></td>
            <td><input id="add_other_barcod" type="text" class="boxtext" style="width:55px;" /></td>
			<td><input id="serial_number" type="text" class="boxtext" style="width:55px;" /></td>
            <td><input id="add_out_shelf" type="text" class="boxtext" onfocus="AppState.operationType=0;" style="width:60px;" /></td>
            <td><input id="add_in_shelf" type="text" class="boxtext" onfocus="AppState.operationType=0;" style="width:60px;" /></td>
          </tr>
          <tr class="color-list">
          	<td colspan="4">
              <table>
              	<tr>
                	<td style="height:15px">Çıkış Raf Miktar</td>
                    <td id="shelf_select_td" style="display:none">
                        <select name="shelf_select" id="shelf_select" style="width:85px; text-align:center">
                            <option value="">Ürün Rafları</option>
                        </select>
                    </td>
                  </tr>
                </table>
			</td>
          </tr>
          <input id="del_other_amount" name="del_other_amount" type="hidden" onfocus="AppState.operationType=1;" value="1" />
          <input id="del_other_barcod" name="del_other_barcod" type="hidden" value="" style="width:90px;" />
        </table>
      </td>
    </tr>
    <tr class="color-list">
      <td colspan="4">
      	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="color-border">
           <tr class="color-list">
            <td align="center" width="50%">Çıkış Depo</td>
            <td align="center" width="50%">Giriş Depo</td>
           </tr>
           <tr class="color-list">
            <td>
              <select name="txt_department_out" id="txt_department_out" style="width:110px" onchange="document.getElementById('department_out').value = this.value">
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
              <select name="txt_department_in" id="txt_department_in" style="width:110px" onchange="document.getElementById('department_in').value = this.value">
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
    <tr class="color-list">
      <td width="55" align="center">Barkod</td>
	  
      <td width="25" align="right">Mikt.</td>
      <td width="50" align="left">Çıkış Raf</td>
      <td width="50" align="left">Giriş Raf</td>
    </tr>
    <tr class="color-list">
      <td align="left" colspan="4"><!---  kontrol edilen tablo--->
        <form name="product_row" id="product_row" method="post">
          <table name="table1" id="table1" border="0" cellpadding="0" cellspacing="0" width="100%" class="tablo">
          </table>
        </form>
        <!---  kontrol edilen tablo---></td>
    </tr>
    <tr class="color-list">
      <td colspan="6" align="right">
      	<input type="hidden" id="department_in" name="department_in" value="" />
		<input type="hidden" id="department_out" name="department_out" value="" />
      	<input type="hidden" id="row_count" name="row_count" value="0" />
        <input type="hidden" id="action_id" name="action_id" value="" />
        <input id="onay" name="Onay" value="<cf_get_lang_main no="49.Kaydet">" type="button" disabled="disabled" onclick="validateAndSave();" /></td>
        
    </tr>



  </table>
</cfform>
<script type="text/javascript">
// Utility functions
function getId(id) {
	return document.getElementById(id);
}

function showAlert(message) {
	alert(message);
}

function resetForm() {
	var fields = ['add_other_barcod', 'add_out_shelf', 'add_in_shelf', 'serial_number'];
	fields.forEach(function(fieldId) {
		getId(fieldId).value = '';
	});
	
	getId('add_other_amount').value = 1;
	getId('add_other_amount').disabled = false;
	
	// Reset AppState
	Object.assign(AppState, {
		barcode: '',
		stockId: '',
		stockCode: '',
		canAdd: false,
		serialNo: '',
		useSerialNo: false
	});
}

// Main application functions
$(document).ready(function(){
	$(".header").hide();
	getId('add_other_barcod').focus();
	setTimeout(function() { getId('add_other_barcod').select(); }, 1000);
});

function generateActionId() {
	var actions = [];
	for(var i = 1; i <= AppState.rowCount; i++) {
		var amountEl = getId('amount' + i);
		if(amountEl && amountEl.value > 0) {
			var action = [
				i,
				getId('stockid' + i).value,
				amountEl.value,
				getId('shelf_code_out' + i).value,
				getId('shelf_code_in' + i).value
			].join('-');
			actions.push(action);
		}
	}
	getId('action_id').value = actions.join(',');
	getId('row_count').value = actions.length;
}

function toggleSaveButton() {
	if (AppState.operationType == 0) {
		AppState.buttonActive++;
	} else if (AppState.buttonActive > 0) {
		AppState.buttonActive--;
	}
	getId('onay').disabled = (AppState.buttonActive < 1);
}

// Unified stock information retrieval
function getStockInfo(identifier, isSerial = false) {
	// Reset state
	Object.assign(AppState, {
		barcode: '',
		stockId: '',
		stockCode: '',
		serialNo: '',
		useSerialNo: isSerial
	});
	
	var sql = isSerial ? 
		Config.QUERIES.STOCK_BY_SERIAL.replace('{{serial}}', identifier) :
		Config.QUERIES.STOCK_BY_BARCODE.replace('{{barcode}}', identifier);
	
	var result = wrk_query(sql, 'dsn3');
	if (!result.STOCK_ID) {
		AppState.canAdd = true;
		showAlert('Ürün Bulunamadı');
		return false;
	}
	
	AppState.stockId = result.STOCK_ID;
	AppState.stockCode = result.PRODUCT_NAME;
	
	if (isSerial) {
		AppState.serialNo = result.SERIAL_NO;
		console.log('Serial No:', AppState.serialNo);
	} else {
		AppState.barcode = result.BARCODE;
	}
	
	getId('add_out_shelf').focus();
	setShelfOptions(AppState.stockId);
	toggleSaveButton();
	return true;
}

// Unified product row creation
function addProductRow() {
	var amount = getId('add_other_amount').value;
	console.log('Adding product row with amount:', amount);
	if (!validateStock(amount)) {
		return false;
	}
	
	if (!AppState.canAdd) {
		AppState.rowCount++;
		getId('row_count').value = AppState.rowCount;
		
		var table = getId('table1');
		var newRow = table.insertRow(table.rows.length);
		newRow.setAttribute('id', 'frm_row' + AppState.rowCount);
		
		// Create cells based on whether using serial number or barcode
		var cells = createProductRowCells(amount);
		
		cells.forEach(function(cellHtml) {
			var newCell = newRow.insertCell();
			newCell.innerHTML = cellHtml;
		});
	}
	
	AppState.canAdd = false;
}

function createProductRowCells(amount) {
	var baseInputs = '<input type="hidden" value="' + AppState.stockId + '" name="stockid' + AppState.rowCount + '" id="stockid' + AppState.rowCount + '" />';
	
	var displayInput;
	if (AppState.useSerialNo) {
		displayInput = '<input type="hidden" value="' + AppState.barcode + '" name="barcod' + AppState.rowCount + '" id="barcod' + AppState.rowCount + '" />' +
					   '<input type="text" value="' + AppState.serialNo + '" name="serino' + AppState.rowCount + '" id="serino' + AppState.rowCount + '" size="13" class="boxtext" readonly />';
	} else {
		displayInput = '<input type="text" value="' + AppState.barcode + '" name="barcod' + AppState.rowCount + '" id="barcod' + AppState.rowCount + '" size="13" class="boxtext" readonly />';
	}
	
	return [
		baseInputs + displayInput,
		'<input type="text" style="text-align:right" value="' + amount + '" name="amount' + AppState.rowCount + '" id="amount' + AppState.rowCount + '" size="5" class="boxtext" readonly />',
		'<input type="text" value="' + AppState.shelfCodeOut + '" name="shelf_code_out' + AppState.rowCount + '" id="shelf_code_out' + AppState.rowCount + '" size="12" class="boxtext" readonly style="text-align:right" />',
		'<input type="text" value="' + AppState.shelfCodeIn + '" name="shelf_code_in' + AppState.rowCount + '" id="shelf_code_in' + AppState.rowCount + '" size="12" class="boxtext" readonly style="text-align:right" />'
	];
}

function validateStock(amount) {
	getId('shelf_select_td').style.display = 'none';
	
	var stockSql = "SELECT ISNULL(S.REAL_STOCK, 0) AS PRODUCT_STOCK " +
				   "FROM GET_STOCK_LAST_SHELF AS S " +
				   "INNER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS P ON S.SHELF_NUMBER = P.PRODUCT_PLACE_ID " +
				   "WHERE P.SHELF_CODE = '" + getId('add_out_shelf').value + "' AND S.STOCK_ID = " + AppState.stockId;
	
	var stockResult = wrk_query(stockSql, 'dsn2');
	
	if (AppState.rowCount > 0) {
		// Check existing rows for same product
		for (var i = 1; i <= AppState.rowCount; i++) {
			var stockIdEl = getId('stockid' + i);
			if (stockIdEl && stockIdEl.value == AppState.stockId) {
				var currentAmount = getId('amount' + i).value;
				var newTotal = parseFloat(currentAmount) + parseFloat(amount);
				
				if (stockResult.PRODUCT_STOCK < newTotal) {
					AppState.canAdd = true;
					showAlert("Yetersiz Stok. Çıkış Rafındaki Stok Miktarı: " + stockResult.PRODUCT_STOCK);
					getId('add_other_amount').focus();
					return false;
				}
				
				// If using serial number, always create new row (skip merging)
				if (AppState.useSerialNo) {
					continue; // Skip to next iteration, don't merge
				}
				
				// For barcode-only products, merge quantities if same product and shelves
				if (getId('stockid' + i).value == AppState.stockId && 
					getId('shelf_code_out' + i).value == AppState.shelfCodeOut && 
					getId('shelf_code_in' + i).value == AppState.shelfCodeIn) {
					getId('amount' + i).value = newTotal;
					var rowEl = getId('frm_row' + i);
					if (rowEl && rowEl.style.display == 'none') {
						rowEl.style.display = 'block';
					}
					AppState.canAdd = true;
					return false;
				}
			}
		}
	} else {
		if (stockResult.PRODUCT_STOCK < parseFloat(amount)) {
			AppState.canAdd = true;
			showAlert("Yetersiz Stok. Çıkış Rafındaki Stok Miktarı: " + stockResult.PRODUCT_STOCK);
			getId('add_other_amount').focus();
			return false;
		}
	}
	
	return true;
}

function setShelfOptions(stockId) {
	getId('shelf_select_td').style.display = '';
	
	var sql = "SELECT PP.SHELF_CODE, PPR.AMOUNT, PP.PRODUCT_PLACE_ID, " +
			  "ISNULL((SELECT REAL_STOCK FROM GET_STOCK_LAST_SHELF WHERE SHELF_NUMBER = PP.PRODUCT_PLACE_ID AND STOCK_ID = PPR.STOCK_ID), 0) AS REAL_STOCK " +
			  "FROM <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS PP " +
			  "LEFT OUTER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE_ROWS AS PPR ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID " +
			  "WHERE PPR.STOCK_ID = " + stockId + " ORDER BY REAL_STOCK DESC";
	
	var shelfOptions = wrk_query(sql, 'dsn2');
	var selectEl = getId('shelf_select');
	
	// Clear existing options
	selectEl.innerHTML = '';
	
	if (shelfOptions.recordcount) {
		for (var i = 0; i < shelfOptions.recordcount; i++) {
			var option = new Option(
				shelfOptions.SHELF_CODE[i] + "-" + shelfOptions.REAL_STOCK[i],
				shelfOptions.PRODUCT_PLACE_ID[i]
			);
			selectEl.add(option);
		}
	} else {
		selectEl.add(new Option('Raf Tanımsız', ''));
	}
}

function validateAndSave() {
	var departmentIn = getId('txt_department_in').value;
	
	if (!departmentIn) {
		showAlert('Depo Seçmelisiniz.');
		return false;
	}
	
	if (departmentIn.indexOf('-') === -1) {
		showAlert('Lütfen giriş için doğru depo seçiniz.');
		return false;
	}
	
	generateActionId();
	
	var params = [
		'fuseaction=pda.add_ambar_fis',
		'change_shelf_fis=1',
		'dep_in=' + departmentIn,
		'dep_out=' + getId('txt_department_out').value,
		'action_id=' + getId('action_id').value,
		'fis_tipi=' + getId('fis_tipi').value,
		'process_cat=' + getId('process_cat_id').value
	];
	
	//window.location.href = '<cfoutput>#request.self#</cfoutput>?' + params.join('&');
	document.form_basket.action='<cfoutput>#request.self#</cfoutput>?fuseaction=pda.add_ambar_fis&dep_in='+form_basket.txt_department_in.value+'&dep_out='+form_basket.txt_department_out.value+'&action_id='+document.getElementById('action_id').value+'&fis_tipi='+form_basket.fis_tipi.value+'&process_cat='+form_basket.process_cat_id.value+ params.join('&');
	
			document.form_basket.submit();
}
</script>

<script type="text/javascript">
// Keyboard event handler with improved logic
document.onkeydown = function(e) {
	var keycode = window.event ? window.event.keyCode : e.which;
	if (keycode !== 13) return; // Only handle Enter key
	
	var inputs = {
		barcode: getId('add_other_barcod').value,
		outShelf: getId('add_out_shelf').value,
		inShelf: getId('add_in_shelf').value,
		serial: getId('serial_number').value
	};
	console.log('Key pressed:', keycode, 'Inputs:', inputs);
	// Handle serial number workflow
	if (inputs.serial.length > 0) {
		console.log('Handling serial number workflow');
		return handleSerialWorkflow(inputs);
	}
	
	// Handle barcode workflow
	return handleBarcodeWorkflow(inputs);
};

function handleSerialWorkflow(inputs) {
	console.log('Handling serial number:', inputs.serial);
	if (!inputs.outShelf && !inputs.inShelf) {
		console.log('No shelves provided, fetching stock info by serial');
		getStockInfo(inputs.serial, true);
		return false;
	}
	console.log('Checking shelf codes:', inputs.outShelf, inputs.inShelf);
	if (Config.SHELF_CODE_LENGTHS.includes(inputs.outShelf.length) && 
		Config.SHELF_CODE_LENGTHS.includes(inputs.inShelf.length)) {
		if (inputs.inShelf === inputs.outShelf) {
			console.log('In and Out shelves are the same:', inputs.inShelf);
			showAlert('Giriş ve Çıkış Rafları Aynı Olamaz');
			getId('add_in_shelf').value = '';
			getId('add_in_shelf').focus();
			return false;
		}
		console.log('Searching shelves:', inputs.inShelf, inputs.outShelf);
		searchShelf(inputs.inShelf, 'in', true);
	} else {
		console.log('Searching out shelf:', inputs.outShelf);
		searchShelf(inputs.outShelf, 'out', true);
	}
	return false;
}

function handleBarcodeWorkflow(inputs) {
	// Validate input lengths
	if (inputs.barcode.length === Config.BARCODE_LENGTH && !inputs.outShelf && !inputs.inShelf) {
		getStockInfo(inputs.barcode, false);
	}
	else if (Config.SHELF_CODE_LENGTHS.includes(inputs.barcode.length)) {
		showAlert('Önce Ürün Barkodu Okutunuz');
		resetForm();
		getId('add_other_barcod').focus();
	}
	else if (inputs.barcode.length === Config.BARCODE_LENGTH && 
			 Config.SHELF_CODE_LENGTHS.includes(inputs.outShelf.length)) {
		if (Config.SHELF_CODE_LENGTHS.includes(inputs.inShelf.length)) {
			if (inputs.inShelf === inputs.outShelf) {
				showAlert('Giriş ve Çıkış Rafları Aynı Olamaz');
				getId('add_in_shelf').value = '';
				getId('add_in_shelf').focus();
				return false;
			}
			searchShelf(inputs.inShelf, 'in', false);
		} else {
			searchShelf(inputs.outShelf, 'out', false);
		}
	}
	else {
		showAlert('Barkod Hatalı');
		resetForm();
		getId('add_other_barcod').focus();
	}
}

// Unified shelf search function
function searchShelf(shelfCode, type, useSerial = false) {
	console.log('Searching shelf:', shelfCode, 'Type:', type, 'Use Serial:', useSerial);
	var departmentValue = type === 'out' ? 
		getId('txt_department_out').value : 
		getId('txt_department_in').value;
		
	var sql = Config.QUERIES.SHELF_VALIDATION.replace('{{shelf}}', shelfCode);
	var shelfResult = wrk_query(sql, 'dsn3');
	
	if (!shelfResult.recordcount) {
		console.log('Shelf not found:', shelfCode);
		showAlert('Seçtiğiniz Raf Hiç Tanımlanmamış!');
		resetShelfFields(type);
		return false;
	}
	
	var shelfDepartment = shelfResult.STORE_ID + '-' + shelfResult.LOCATION_ID;
	console.log('Shelf Department:', shelfDepartment, 'Selected Department:', departmentValue);
	if (departmentValue !== shelfDepartment) {
		var locationText = type === 'out' ? 'Çıkış' : 'Giriş';
		showAlert('Seçtiğiniz Raf ' + locationText + ' Lokasyonunda Yoktur!');
		resetForm();
		getId('add_other_barcod').focus();
		return false;
	}
	console.log('Shelf validation passed for:', shelfCode);
	return validateProductInShelf(shelfCode, type, useSerial);
}

function validateProductInShelf(shelfCode, type, useSerial = false) {
	var condition, inputValue;
	console.log('Validating product in shelf:', shelfCode, 'Type:', type, 'Use Serial:', useSerial);
	if (useSerial) {
		condition = "SB.STOCK_ID = '" + AppState.stockId + "'";
	} else {
		inputValue = getId('add_other_barcod').value;
		if (inputValue.length !== Config.BARCODE_LENGTH) {
			if (inputValue.length === 0) {
				getId('add_other_barcod').focus();
			} else {
				showAlert('Ürün Barkodu Hatalı');
				resetForm();
				getId('add_other_barcod').focus();
			}
			return false;
		}
		condition = "SB.BARCODE = '" + inputValue + "'";
	}
	console.log('Condition for SQL:', condition);
	
	var sql = Config.QUERIES.PRODUCT_IN_SHELF
		.replace('{{condition}}', condition)
		.replace('{{shelf}}', shelfCode);
	
	var productResult = wrk_query(sql, 'dsn3');
	console.log('Product Result:', productResult);
	if (!productResult.STOCK_ID) {
		console.log('Product not found in shelf:', shelfCode);
		showAlert('Ürün Bu Rafa Tanıtılmamış');
		resetShelfFields(type);
		return false;
	}
	console.log('Product found in shelf:', productResult);
	if (type === 'out') {
		console.log('Processing for out shelf:', productResult);
		getId('add_other_amount').disabled = true;
		getId('add_in_shelf').focus();
	} else {
		// Process for 'in' shelf
		console.log('Processing for in shelf:', productResult);
		AppState.stockId = productResult.STOCK_ID;
		AppState.stockCode = productResult.PRODUCT_NAME;
		AppState.barcode = productResult.BARCODE;
		AppState.shelfCodeIn = productResult.SHELF_CODE;
		AppState.shelfCodeOut = getId('add_out_shelf').value;
		
		toggleSaveButton();
		addProductRow();
		resetForm();
		getId('add_other_barcod').focus();
	}
	
	return true;
}

function resetShelfFields(type) {
	var fieldId = type === 'out' ? 'add_out_shelf' : 'add_in_shelf';
	getId(fieldId).value = '';
	getId(fieldId).focus();
}
</script>

<script type="text/javascript">
// Simplified AJAX query function
function wrk_query(query, dataSource, maxRows) {
	dataSource = dataSource || 'dsn';
	maxRows = maxRows || 0;
	
	var result = new Object();
	var xhr = null;
	
	// Create XMLHttpRequest
	if (window.XMLHttpRequest) {
		try {
			xhr = new XMLHttpRequest();
		} catch(e) {
			xhr = false;
		}
	} else if (window.ActiveXObject) {
		try {
			xhr = new ActiveXObject("Msxml2.XMLHTTP");
		} catch(e) {
			try {
				xhr = new ActiveXObject("Microsoft.XMLHTTP");
			} catch(e) {
				xhr = false;
			}
		}
	}
	
	if (!xhr) {
		console.error('XMLHttpRequest not supported');
		return false;
	}
	
	xhr.open("POST", '/index.cfm?fuseaction=objects2.emptypopup_get_js_query&isAjax=1&xmlhttp=1', false);
	xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
	xhr.setRequestHeader('pragma', 'nocache');
	
	var params = 'str_sql=' + encodeURIComponent(query) + 
				 '&data_source=' + dataSource + 
				 '&maxrows=' + maxRows;
	
	try {
		xhr.send(params);
		if (xhr.readyState === 4 && xhr.status === 200) {
			eval(xhr.responseText.replace(/\u200B/g, ''));
			result = get_js_query;
		}
	} catch(e) {
		console.error('Query execution failed:', e);
		result = false;
	}
	
	return result;
}
</script>

<cf_get_lang_set module_name="stock">