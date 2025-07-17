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
<cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,1)#">
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
        TBL.STORE_ID IS NULL
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
	border: 1px solid #aec7f0;
	border-left: none;
	border-right: none;
	margin: 0;
	padding: 0;
}
.header {
	display: none;
}
</style>
<script type="text/javascript">
// Warehouse Operations Manager - Unified and Optimized
const WarehouseManager = {
	// Application state
	state: {
		rowCount: 0,
		buttonCount: 0,
		operationType: 0, // 0-add, 1-remove
		currentStock: {
			multiplier: '',
			unit: '',
			barcode: '',
			stockId: '',
			stockCode: '',
			specMainId: '',
			serialNo: ''
		}
	},
	
	// Initialize the application
	init: function() {
		this.setupUI();
		this.setupEventHandlers();
	},
	
	setupUI: function() {
		const barcodeInput = document.getElementById('add_other_barcod');
		if (barcodeInput) {
			barcodeInput.focus();
			setTimeout(() => barcodeInput.select(), 1000);
		}
		
		// Hide headers on DOM ready
		if (document.readyState === 'loading') {
			document.addEventListener('DOMContentLoaded', this.hideHeaders);
		} else {
			this.hideHeaders();
		}
	},
	
	hideHeaders: function() {
		document.querySelectorAll('.header').forEach(header => {
			header.style.display = 'none';
		});
	},
	
	setupEventHandlers: function() {
		document.onkeydown = (e) => {
			const keycode = e.which || e.keyCode;
			if (keycode === 13) {
				this.handleEnterKey();
			}
		};
	},
	
	handleEnterKey: function() {
		const barcodeInput = document.getElementById('add_other_barcod');
		const serialInput = document.getElementById('serial_number');
		
		const barcode = barcodeInput.value.trim();
		const serial = serialInput.value.trim();
		
		if (serial.length > 0 && this.state.operationType === 0) {
			// Serial number processing logic
			this.addRowWithSerial(serial);
			this.clearInputs();
		} else if (barcode.length > 0 && this.state.operationType === 0) {
			this.addRow(barcode);
			this.clearInputs();
		} else {
			alert('Barkod Hatalı');
			barcodeInput.value = '';
			barcodeInput.focus();
		}
	},
	
	clearInputs: function() {
		document.getElementById('add_other_barcod').value = '';
		document.getElementById('add_other_amount').value = '1';
		if (document.getElementById('serial_number')) {
			document.getElementById('serial_number').value = '';
		}
		document.getElementById('add_other_barcod').focus();
	},
	
	controlButton: function() {
		if (this.state.operationType === 0) {
			this.state.buttonCount++;
		} else if (this.state.buttonCount > 0) {
			this.state.buttonCount--;
		}
		
		const saveButton = document.getElementById('onay');
		if (saveButton) {
			saveButton.disabled = this.state.buttonCount < 1;
		}
	},
	
	getStock: function(barcode) {
		this.resetCurrentStock();
		
		if (!document.getElementById('add_other_amount').value.length) {
			alert('Miktar Giriniz');
			return false;
		}
		
		// Clean barcode (some readers add 'j' prefix)
		if (barcode.length > 9 && barcode.substr(0, 1) === 'j') {
			barcode = barcode.substring(1, 9);
		}
		
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
		
		// Set current stock data
		this.state.currentStock = {
			multiplier: product.MULTIPLIER,
			unit: product.MAIN_UNIT,
			stockId: product.STOCK_ID,
			stockCode: product.PRODUCT_NAME,
			barcode: product.BARCODE,
			specMainId: '',
			serialNo: ''
		};
		
		this.controlButton();
		return true;
	},

	getStockWithSerialNo: function(serialNo) {
		this.resetCurrentStock();
		
		if (!document.getElementById('add_other_amount').value.length) {
			alert('Miktar Giriniz');
			return false;
		}
		
		
		
		const sql = `SELECT TOP 1 SB.STOCK_ID, SB.SERIAL_NO, PU.MAIN_UNIT, PU.MULTIPLIER, S.PRODUCT_NAME
		FROM w3qa_1.SERVICE_GUARANTY_NEW AS SB
		INNER JOIN w3qa_1.STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID
		INNER JOIN w3qa_1.PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
		WHERE SB.SERIAL_NO = '${serialNo}'`;
		
		const product = wrk_query(sql, 'dsn3');
		
		if (!product.STOCK_ID) {
			alert('Ürün Bulunamadı');
			return false;
		}
		
		// Set current stock data
		this.state.currentStock = {
			multiplier: product.MULTIPLIER,
			unit: product.MAIN_UNIT,
			stockId: product.STOCK_ID,
			stockCode: product.PRODUCT_NAME,
			barcode: product.BARCODE,
			specMainId: '',
			serialNo: ''
		};
		
		this.controlButton();
		return true;
	},
	
	resetCurrentStock: function() {
		this.state.currentStock = {
			multiplier: '', unit: '', barcode: '', 
			stockId: '', stockCode: '', specMainId: '', serialNo: ''
		};
	},
	
	checkStockAvailability: function(requestedAmount) {
		const stockSql = `SELECT PRODUCT_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL 
						 WHERE DEPO = '${form_basket.txt_department_out.value}' 
						 AND STOCK_ID = ${this.state.currentStock.stockId}`;
		
		const stockResult = wrk_query(stockSql, 'dsn2');
		const availableStock = stockResult.PRODUCT_STOCK || 0;
		
		if (availableStock < requestedAmount) {
			alert(`Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı: ${availableStock}`);
			document.getElementById('add_other_amount').focus();
			return false;
		}
		
		return true;
	},
	
	addRow: function(barcode) {
		if (!this.getStock(barcode)) return;
		this.processRowAddition();
	},
	
	addRowWithSerial: function( serial) {
		if (!this.getStockWithSerialNo(serial)) return;
		this.state.currentStock.serialNo = serial;
		this.processRowAddition();
	},
	
	processRowAddition: function() {
		const amount = parseFloat(document.getElementById('add_other_amount').value);
		
		// Check if product already exists in the list
		for (let i = 1; i <= this.state.rowCount; i++) {
			const existingStockId = document.getElementById(`stockid${i}`).value;
			if (existingStockId == this.state.currentStock.stockId) {
				const currentAmount = parseFloat(document.getElementById(`amount${i}`).value);
				const newTotal = currentAmount + amount;
				
				if (this.checkStockAvailability(newTotal)) {
					document.getElementById(`amount${i}`).value = newTotal;
					const row = document.getElementById(`frm_row${i}`);
					if (row && row.style.display === 'none') {
						row.style.display = 'block';
					}
				}
				return;
			}
		}
		
		// Add new row
		if (this.state.rowCount === 0) {
			if (!this.checkStockAvailability(amount)) return;
			const deptOut = document.getElementById('txt_department_out');
			if (deptOut) deptOut.disabled = true;
		}
		
		this.createNewRow(amount);
	},
	
	createNewRow: function(amount) {
		this.state.rowCount++;
		const rowCountEl = document.getElementById('row_count');
		if (rowCountEl) rowCountEl.value = this.state.rowCount;
		
		const table = document.getElementById('table1');
		if (!table) return;
		
		const newRow = table.insertRow(table.rows.length);
		newRow.setAttribute('id', `frm_row${this.state.rowCount}`);
		newRow.setAttribute('name', `frm_row${this.state.rowCount}`);
		
		// Create cells
		const cells = [
			this.createBarcodeCell(),
			this.createProductNameCell(),
			this.createAmountCell(amount),
			this.createUnitCell()
		];
		
		cells.forEach(cellHTML => {
			const cell = newRow.insertCell();
			cell.innerHTML = cellHTML;
		});
	},
	
	createBarcodeCell: function() {
		const serialField = this.state.currentStock.serialNo ? 
			`<input type="hidden" value="${this.state.currentStock.serialNo}" name="serial${this.state.rowCount}" id="serial${this.state.rowCount}" />` : '';
		
		return `<input type="hidden" value="${this.state.currentStock.stockId}" name="stockid${this.state.rowCount}" id="stockid${this.state.rowCount}" />
				<input type="hidden" value="${this.state.currentStock.specMainId}" name="spectmainid${this.state.rowCount}" id="spectmainid${this.state.rowCount}" />
				${serialField}
				<input type="text" value="${this.state.currentStock.barcode}" name="barcod${this.state.rowCount}" id="barcod${this.state.rowCount}" size="14" class="boxtext" readonly />`;
	},
	
	createProductNameCell: function() {
		return `<input type="text" value="${this.state.currentStock.stockCode}" name="stockcode${this.state.rowCount}" id="stockcode${this.state.rowCount}" size="23" class="boxtext" readonly />`;
	},
	
	createAmountCell: function(amount) {
		return `<input type="text" style="text-align:right" value="${amount}" name="amount${this.state.rowCount}" id="amount${this.state.rowCount}" size="4" class="boxtext" readonly />`;
	},
	
	createUnitCell: function() {
		return `<input type="hidden" value="${this.state.currentStock.unit}" name="birim${this.state.rowCount}" id="birim${this.state.rowCount}" />`;
	},
	
	generateActionId: function() {
		let actionId = '';
		let validRowCount = 0;
		
		for (let i = 1; i <= this.state.rowCount; i++) {
			const amountEl = document.getElementById(`amount${i}`);
			if (!amountEl) continue;
			
			const amount = amountEl.value;
			if (parseFloat(amount) > 0) {
				if (validRowCount > 0) actionId += ',';
				
				const stockIdEl = document.getElementById(`stockid${i}`);
				const stockId = stockIdEl ? stockIdEl.value : '';
				actionId += `${i}-${stockId}-${amount}-0`;
				validRowCount++;
			}
		}
		
		const actionIdEl = document.getElementById('action_id');
		const rowCountEl = document.getElementById('row_count');
		
		if (actionIdEl) actionIdEl.value = actionId;
		if (rowCountEl) rowCountEl.value = validRowCount;
	},
	
	validateAndSave: function() {
		const formBasket = document.forms.form_basket;
		if (!formBasket) return false;
		
		const departmentIn = formBasket.txt_department_in.value;
		const departmentOut = formBasket.txt_department_out.value;
		
		if (departmentIn === departmentOut) {
			alert('Giriş ve Çıkış Lokasyonu Farklı Olmalıdır.');
			return false;
		}
		
		this.generateActionId();
		
		const actionIdEl = document.getElementById('action_id');
		const actionId = actionIdEl ? actionIdEl.value : '';
		
		const params = new URLSearchParams({
			fuseaction: 'pda.add_ambar_fis',
			dep_in: departmentIn,
			dep_out: departmentOut,
			action_id: actionId,
			fis_tipi: formBasket.fis_tipi.value,
			process_cat: formBasket.process_cat_id.value
		});
		
		window.location.href = `${location.pathname}?${params.toString()}`;
	}
};

// Legacy function aliases for compatibility
function actionidolustur() { WarehouseManager.generateActionId(); }
function buton_kontrol() { WarehouseManager.controlButton(); }
function get_stock(barcode) { return WarehouseManager.getStock(barcode); }
function add_row(barcode) { WarehouseManager.addRow(barcode); }
function kontrol_kayit() { return WarehouseManager.validateAndSave(); }

// Initialize the application
WarehouseManager.init();
</script>
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
            	<table cellpadding="0" cellspacing="0" width="40%">
          			<tr>
                        <td>&nbsp;&nbsp;Miktar&nbsp;</td>
                        <td><input id="add_other_amount" name="add_other_amount" type="text" class="moneybox" style="width:30px; text-align:right" value="1" /></td>
                        <td nowrap="nowrap">&nbsp;&nbsp;&nbsp;Barkod&nbsp;</td>
                        <td><input id="add_other_barcod" name="add_other_barcod" type="text" value="" style="width:90px;" ></td>
						  <td nowrap="nowrap">&nbsp;&nbsp;&nbsp;Seri No&nbsp;</td>
                        <td><input id="serial_number" name="serial_number" type="text" value="" style="width:90px;" ></td>
          			</tr>
                  	<input id="del_other_amount" name="del_other_amount" type="hidden" value="1" />
                  	<input id="del_other_barcod" name="del_other_barcod" type="hidden" value="" />
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
              				<select name="txt_department_out" id="txt_department_out" style="width:100px" onchange="document.getElementById('department_out').value = this.value">
                				<cfoutput query="get_all_location" group="department_id">
                  					<option disabled="disabled" value="#department_id#"<cfif attributes.department_out_id eq department_id>selected</cfif>>#department_head#</option>
                  						<cfoutput>
                    						<option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_out_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#<cfif not status>-<cf_get_lang_main no='82.Pasif'></cfif>
                    						</option>
                  						</cfoutput> 
								</cfoutput>
              				</select>
          				</td>
            			<td width="93%">
              				<select name="txt_department_in" style="width:100px" onchange="document.getElementById('department_in').value = this.value">
                				<cfoutput query="get_all_location" group="department_id">
                  					<option disabled="disabled" value="#department_id#"<cfif attributes.department_in_id eq department_id>selected</cfif>>#department_head#</option>
                  					<cfoutput>
                    					<option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_in_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#<cfif not status>-<cf_get_lang_main no='82.Pasif'></cfif>
                    					</option>
                  					</cfoutput> 
								</cfoutput>
              				</select>
              			</td>
          			</tr>
        		</table>
         	</td>
    	</tr>
    	<tr class="color-list">
          <td width="70" align="center">Barkod</td>
          <td align="left">Ürün Adı</td>
          <td width="30" align="right">Miktar</td>
    	</tr>
    	<tr class="color-list">
      		<td align="left" colspan="4"><!---  kontrol edilen tablo--->
        		<form name="product_row" id="product_row" method="post">
          			<table name="table1" id="table1" border="0" cellpadding="0" cellspacing="0" width="100%" class="tablo">
          			</table>
        		</form>
     		</td>
    	</tr>
    	<tr class="color-list">
      		<td colspan="6" align="right">
                <input type="hidden" id="department_in" name="department_in" value="" />
                <input type="hidden" id="row_count" name="row_count" value="0" />
                <input type="hidden" id="action_id" name="action_id" value="" />
                <input id="onay" name="Onay" value="<cf_get_lang_main no="49.Kaydet">" type="button" disabled="disabled" onClick="kontrol_kayit();" />
          	</td>
    	</tr>
  	</table>
    </div>
</cfform>

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