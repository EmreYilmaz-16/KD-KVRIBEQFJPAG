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
// Global variables
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
	shelfCodeIn: ''
};

// Configuration
var Config = {
	BARCODE_LENGTH: 13,
	SHELF_CODE_LENGTHS: [8, 11]
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
          <input id="del_other_amount" name="del_other_amount" type="hidden"  onfocus="islemtipi=1;" value="1" />
          <input id="del_other_barcod" name="del_other_barcod" type="hidden" value="" style="width:90px;" >
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
              <select name="txt_department_out" style="width:110px" onchange="document.getElementById('department_out').value = this.value">
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
              <select name="txt_department_in" style="width:110px" onchange="document.getElementById('department_in').value = this.value">
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
	getId('add_other_barcod').value = '';
	getId('add_out_shelf').value = '';
	getId('add_in_shelf').value = '';
	getId('add_other_amount').value = 1;
	getId('add_other_amount').disabled = false;
	AppState.barcode = '';
	AppState.stockId = '';
	AppState.stockCode = '';
	AppState.canAdd = false;
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

function getStockInfo(barcode) {
	// Reset state
	AppState.barcode = '';
	AppState.stockId = '';
	AppState.stockCode = '';
	
	var sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER, S.PRODUCT_NAME " +
			  "FROM STOCKS_BARCODES AS SB " +
			  "INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID " +
			  "INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID " +
			  "WHERE SB.BARCODE = '" + barcode + "'";
	
	var result = wrk_query(sql, 'dsn3');
	if (!result.STOCK_ID) {
		AppState.canAdd = true;
		showAlert('Ürün Bulunamadı');
		return false;
	}
	
	AppState.stockId = result.STOCK_ID;
	AppState.stockCode = result.PRODUCT_NAME;
	AppState.barcode = result.BARCODE;
	getId('add_out_shelf').focus();
	setShelfOptions(AppState.stockId);
	toggleSaveButton();
	return true;
}

	function add_amount()
	{
	  document.getElementById('shelf_select_td').style.display='none';
	  if(row_count >0 /*ilk Satırdan sonrası*/)
	  {
		  for(i=1;i<=row_count;i++)
		  {
			  if(document.getElementById('stockid'+i).value == stockid)
			  {
				  var stock_sql = "SELECT ISNULL(S.REAL_STOCK, 0) AS PRODUCT_STOCK FROM GET_STOCK_LAST_SHELF AS S INNER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS P ON S.SHELF_NUMBER = P.PRODUCT_PLACE_ID WHERE P.SHELF_CODE = '"+document.getElementById('add_out_shelf').value+"' AND S.STOCK_ID ="+stockid;
				  var get_real_stock = wrk_query(stock_sql,'dsn2');
				  if(get_real_stock.PRODUCT_STOCK < document.getElementById('amount'+i).value - (-1 * amount))
				  {
					ekle=1;
					alert("Yetersiz Stok. Çıkış Rafındaki Stok Miktarı : "+get_real_stock.PRODUCT_STOCK);
					document.getElementById('add_other_amount').focus();
				  }
				  else
				  {
					  if(document.getElementById('stockid'+i).value == stockid && document.getElementById('shelf_code_out'+i).value == shelf_code_out && document.getElementById('shelf_code_in'+i).value == shelf_code_in)
					  {
						document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
						if (document.getElementById('frm_row'+i).style.display == 'none')
							document.getElementById('frm_row'+i).style.display='block';
						ekle=1;
					  }
				  }
			  }
		   }
	   }
	   else
	   {
		    var stock_sql = "SELECT ISNULL(S.REAL_STOCK, 0) AS PRODUCT_STOCK FROM GET_STOCK_LAST_SHELF AS S INNER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS P ON S.SHELF_NUMBER = P.PRODUCT_PLACE_ID WHERE P.SHELF_CODE = '"+document.getElementById('add_out_shelf').value+"' AND S.STOCK_ID ="+stockid;
			var get_real_stock = wrk_query(stock_sql,'dsn2');
			if(get_real_stock.PRODUCT_STOCK < (amount*1))
			{
				ekle=1;
				alert("Yetersiz Stok. Çıkış Rafındaki Stok Miktarı : "+get_real_stock.PRODUCT_STOCK);
				document.getElementById('add_other_amount').focus();
			}
	   }
	}
	
	function add_row(barcode)
	{
		{
			  amount = document.getElementById('add_other_amount').value;
			  add_amount();
			  if (ekle == 0)
			  {
				row_count++;
				document.getElementById('row_count').value = row_count;
				var newRow;
				var newCell;	
				newRow = document.getElementById("table1").insertRow(document.getElementById("table1").rows.length);
				newRow.setAttribute("name","frm_row" + row_count);
				newRow.setAttribute("id","frm_row" + row_count);		
				newRow.setAttribute("NAME","frm_row" + row_count);
				newRow.setAttribute("ID","frm_row" + row_count);		
				
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="hidden" value="'+stockid+'" name="stockid'+row_count+'" id="stockid'+row_count+'" /><input type="hidden" value="'+spectmainid+'" name="spectmainid'+row_count+'" id="spectmainid'+row_count+'" /><input type="text" value="'+barcode+'" name="barcod'+row_count+'" id="barcod'+row_count+'" size="13" class="boxtext" readonly="yes" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" style="text-align:right" value="'+amount+'" name="amount'+row_count+'" id="amount'+row_count+'" size="5" class="boxtext" readonly="yes"  style="text-align:" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" value="'+shelf_code_out+'" name="shelf_code_out'+row_count+'" id="shelf_code_out'+row_count+'" size="12" class="boxtext" readonly="yes" style="text-align:right" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" value="'+shelf_code_in+'" name="shelf_code_in'+row_count+'" id="shelf_code_in'+row_count+'" size="12" class="boxtext" readonly="yes" style="text-align:right" />';
			  }
			  else
			  {
				 ekle = 0;
			  }
		}
	}
	function include(arr, obj) 
	{
    	for(var i=0; i<arr.length; i++) 
		{
        	if (arr[i] == obj) return true;
    	}
	}
</script>

<script language="JavaScript">
	document.onkeydown = checkKeycode
	function checkKeycode(e) 
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
// Keyboard event handler
document.onkeydown = function(e) {
	var keycode = window.event ? window.event.keyCode : e.which;
	if (keycode !== 13) return; // Only handle Enter key
	
	var barcodeValue = getId('add_other_barcod').value;
	var outShelfValue = getId('add_out_shelf').value;
	var inShelfValue = getId('add_in_shelf').value;
	
	// Validate input lengths
	if (barcodeValue.length === Config.BARCODE_LENGTH && !outShelfValue && !inShelfValue) {
		getStockInfo(barcodeValue);
	}
	else if (Config.SHELF_CODE_LENGTHS.includes(barcodeValue.length)) {
		showAlert('Önce Ürün Barkodu Okutunuz');
		resetForm();
		getId('add_other_barcod').focus();
	}
	else if (barcodeValue.length === Config.BARCODE_LENGTH && Config.SHELF_CODE_LENGTHS.includes(outShelfValue.length)) {
		if (Config.SHELF_CODE_LENGTHS.includes(inShelfValue.length)) {
			if (inShelfValue === outShelfValue) {
				showAlert('Giriş ve Çıkış Rafları Aynı Olamaz');
				getId('add_in_shelf').value = '';
				getId('add_in_shelf').focus();
				return false;
			}
			searchShelf(inShelfValue, 'in');
		} else {
			searchShelf(outShelfValue, 'out');
		}
	}
	else {
		showAlert('Barkod Hatalı');
		resetForm();
		getId('add_other_barcod').focus();
	}
};

// Unified shelf search function
function searchShelf(shelfCode, type) {
	var departmentValue = type === 'out' ? 
		getId('txt_department_out').value : 
		getId('txt_department_in').value;
		
	var sql = "SELECT PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID " +
			  "FROM PRODUCT_PLACE " +
			  "WHERE PLACE_STATUS = 1 AND SHELF_CODE = '" + shelfCode + "'";
	
	var shelfResult = wrk_query(sql, 'dsn3');
	
	if (!shelfResult.recordcount) {
		showAlert('Seçtiğiniz Raf Hiç Tanımlanmamış!');
		resetShelfFields(type);
		return false;
	}
	
	var shelfDepartment = shelfResult.STORE_ID + '-' + shelfResult.LOCATION_ID;
	if (departmentValue !== shelfDepartment) {
		var locationText = type === 'out' ? 'Çıkış' : 'Giriş';
		showAlert('Seçtiğiniz Raf ' + locationText + ' Lokasyonunda Yoktur!');
		resetForm();
		getId('add_other_barcod').focus();
		return false;
	}
	
	return validateProductInShelf(shelfCode, type);
}

function resetShelfFields(type) {
	if (type === 'out') {
		getId('add_out_shelf').value = '';
		getId('add_out_shelf').focus();
	} else {
		getId('add_in_shelf').value = '';
		getId('add_in_shelf').focus();
	}
}

function validateProductInShelf(shelfCode, type) {
	var barcodeValue = getId('add_other_barcod').value;
	
	if (barcodeValue.length !== Config.BARCODE_LENGTH) {
		if (barcodeValue.length === 0) {
			getId('add_other_barcod').focus();
		} else {
			showAlert('Ürün Barkodu Hatalı');
			resetForm();
			getId('add_other_barcod').focus();
		}
		return false;
	}
	
	var sql = "SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, PP.SHELF_CODE " +
			  "FROM STOCKS_BARCODES AS SB " +
			  "INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID " +
			  "INNER JOIN PRODUCT_PLACE_ROWS AS PPR ON S.PRODUCT_ID = PPR.PRODUCT_ID " +
			  "INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID " +
			  "WHERE SB.BARCODE = '" + barcodeValue + "' AND PP.SHELF_CODE = '" + shelfCode + "'";
	
	var productResult = wrk_query(sql, 'dsn3');
	
	if (!productResult.STOCK_ID) {
		showAlert('Ürün Bu Rafa Tanıtılmamış');
		resetShelfFields(type);
		return false;
	}
	
	if (type === 'out') {
		getId('add_other_amount').disabled = true;
		getId('add_in_shelf').focus();
	} else {
		// Process for 'in' shelf
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
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_out_shelf').value = '';
					document.getElementById('add_other_barcod').focus();	
			}
			else
			{
				if (document.getElementById('add_other_barcod').value.length == 13)
				{
					var new_sql = "SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, PP.SHELF_CODE FROM STOCKS_BARCODES AS SB INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID INNER JOIN PRODUCT_PLACE_ROWS AS PPR ON S.PRODUCT_ID = PPR.PRODUCT_ID INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID WHERE SB.BARCODE = '"+document.getElementById('add_other_barcod').value+"' AND PP.SHELF_CODE ='"+document.getElementById('add_out_shelf').value+"'";
		 			var get_product = wrk_query(new_sql,'dsn3');
					if (get_product.STOCK_ID == undefined)
					{
						alert('Ürün Bu Rafa Tanıtılmamış');
						document.getElementById('add_out_shelf').value = '';
						document.getElementById('add_out_shelf').focus();
					}
					else
					{	
						document.getElementById('add_other_amount').disabled = true;
						document.getElementById('add_in_shelf').focus();
					}
				}
				else if (document.getElementById('add_other_barcod').value.length == 0)
				{
						document.getElementById('add_other_barcod').focus();	
				}
				else
				{
						alert('Ürün Barkodu Hatalı');
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_out_shelf').value = '';
						document.getElementById('add_in_shelf').value = '';
						document.getElementById('add_other_barcod').focus();
				}
			}
		}
		else
		{
			alert('Seçtiğiniz Raf Hiç Tanımlanmamış!');
			document.getElementById('add_out_shelf').value = '';
			document.getElementById('add_in_shelf').value = '';
			document.getElementById('add_out_shelf').focus();
		}
	}
	function search_shelf_in(shelf_8)
	{
		var giris_depo = document.all.txt_department_in.value;
		var shelf_sql = "SELECT PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE = '"+shelf_8+"'";
		var get_shelf = wrk_query(shelf_sql,'dsn3');
		if(get_shelf.recordcount)
		{
			var giris_depo_s = get_shelf.STORE_ID.toString()+'-'+get_shelf.LOCATION_ID.toString();
			if(giris_depo != giris_depo_s)
			{
					alert('Seçtiğiniz Raf Giriş Lokasyonunda Yoktur.!');	
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_in_shelf').value = '';
					document.getElementById('add_other_barcod').focus();	
			}
			else
			{
				if (document.getElementById('add_other_barcod').value.length == 13)
				{
					var new_sql = "SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, PP.SHELF_CODE FROM STOCKS_BARCODES AS SB INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID INNER JOIN PRODUCT_PLACE_ROWS AS PPR ON S.PRODUCT_ID = PPR.PRODUCT_ID INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID WHERE SB.BARCODE = '"+document.getElementById('add_other_barcod').value+"' AND PP.SHELF_CODE ='"+document.getElementById('add_in_shelf').value+"'";
		 			var get_product = wrk_query(new_sql,'dsn3');
					if (get_product.STOCK_ID == undefined)
					{
						alert('Ürün Bu Rafa Tanıtılmamış');
						document.getElementById('add_in_shelf').value = '';
						document.getElementById('add_in_shelf').focus();
					}
					else
					{	
						stockid = get_product.STOCK_ID;
						stockcode = get_product.PRODUCT_NAME;
						barcode = get_product.BARCODE;
						shelf_code_in = get_product.SHELF_CODE; 
						shelf_code_out = document.getElementById('add_out_shelf').value; 
						buton_kontrol();
						add_row(barcode);
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_in_shelf').value = '';
						document.getElementById('add_out_shelf').value = '';
						document.getElementById('add_other_amount').disabled = false;
						document.getElementById('add_other_amount').value = 1;
						document.getElementById('add_other_barcod').focus();
					}
				}
				else if (document.getElementById('add_other_barcod').value.length == 0)
				{
						document.getElementById('add_other_barcod').focus();	
				}
				else
				{
						alert('Ürün Barkodu Hatalı');
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_in_shelf').value = '';
						document.getElementById('add_out_shelf').value = '';
						document.getElementById('add_other_barcod').focus();
				}
			}
		}
		else
		{
			alert('Seçtiğiniz Raf Hiç Tanımlanmamış!');
			document.getElementById('add_in_shelf').value = '';
			document.getElementById('add_in_shelf').focus();
		}
	}
	function set_shelfs(xyz)
	{
		document.getElementById('shelf_select_td').style.display='';
		var product_shelfs = wrk_query("SELECT PP.SHELF_CODE, PPR.AMOUNT, PP.PRODUCT_PLACE_ID, ISNULL((SELECT REAL_STOCK FROM GET_STOCK_LAST_SHELF WHERE SHELF_NUMBER = PP.PRODUCT_PLACE_ID AND STOCK_ID = PPR.STOCK_ID),0) AS REAL_STOCK FROM <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS PP LEFT OUTER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE_ROWS AS PPR ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID WHERE PPR.STOCK_ID = "+xyz+" ORDER BY REAL_STOCK DESC","dsn2");
		var option_count = document.getElementById('shelf_select').options.length; 
		for(x=option_count;x>=0;x--)
			document.getElementById('shelf_select').options[x] = null;
		if(product_shelfs.recordcount != 0)
		{	
			for(var xx=0;xx<product_shelfs.recordcount;xx++)
			{
				document.getElementById('shelf_select').options[xx]=new Option(product_shelfs.SHELF_CODE[xx]+"-"+product_shelfs.REAL_STOCK[xx],product_shelfs.PRODUCT_PLACE_ID[xx],product_shelfs.AMOUNT[xx]);
			}
		}
		else
			document.getElementById('shelf_select').options[0] = new Option('Raf Tanımsız','');
	}
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