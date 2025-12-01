<cfset default_process_type = 113> <!---Dikkat Firmaya Göre Değişebilir--->
<cfparam name="attributes.department_in_id" default="">
<cfparam name="attributes.department_out_id" default="">
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT TOP (1)    
    	SPC.PROCESS_CAT_ID
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE = #default_process_type# AND 
        SPCF.FUSE_NAME = 'pda.form_shipping_ambar_stock' 
  	ORDER BY
    	SPC.PROCESS_CAT_ID DESC      
</cfquery>
<cfif not get_process_cat.recordcount>
	<script type="text/javascript">
		alert("İşlem Kategorisi Tanımlayınız!");
		history.back();	
	</script>
</cfif>
<cfquery name="get_stock_info" datasource="#dsn3#">
	SELECT        
    	SB.STOCK_ID, 
        SB.BARCODE, 
        S.PRODUCT_NAME, 
        S.STOCK_CODE, 
        S.STOCK_CODE_2
	FROM            
    	STOCKS_BARCODES AS SB INNER JOIN
       	STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID
	WHERE        
    	SB.STOCK_ID = #f_stock_id#
</cfquery>
<cfquery name="get_store_type" datasource="#dsn3#">
	SELECT        
    	COUNT(*) AS RAF
	FROM            
    	PRODUCT_PLACE
	WHERE        
    	LOCATION_ID = #ListGetAt(attributes.department_out_id,2,"-")#  AND 
        STORE_ID = #ListGetAt(attributes.department_in_id,1,"-")# AND 
        PLACE_STATUS = 1
</cfquery>
<cfif get_store_type.raf gt 0>
    <cfquery name="get_ambar_fis" datasource="#dsn2#">
        SELECT        
            SUM(SFR.AMOUNT) AS AMOUNT, 
            PP.SHELF_CODE, 
            S.STOCK_CODE, 
            S.PRODUCT_ID, 
            S.PROPERTY, 
            S.BARCOD, 
            S.PRODUCT_NAME,
            SFR.STOCK_ID
        FROM            
            STOCK_FIS AS SF INNER JOIN
            STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
            #dsn3_alias#.PRODUCT_PLACE AS PP ON SFR.SHELF_NUMBER = PP.PRODUCT_PLACE_ID INNER JOIN
            #dsn3_alias#.STOCKS AS S ON SFR.STOCK_ID = S.STOCK_ID
        WHERE        
            SF.REF_NO = '#attributes.deliver_paper_no#' AND 
            SFR.STOCK_ID = #f_stock_id#
        GROUP BY 
            PP.SHELF_CODE, 
            S.STOCK_CODE, 
            S.PRODUCT_ID, 
            S.PROPERTY, 
            S.BARCOD, 
            S.PRODUCT_NAME,
            SFR.STOCK_ID
    </cfquery>
    <cfquery name="get_shelf_stock" datasource="#dsn2#">
        SELECT        
            PP.SHELF_CODE, 
            PPR.AMOUNT, 
            PP.PRODUCT_PLACE_ID, 
            ISNULL((
                    SELECT        
                        REAL_STOCK
                    FROM            
                        GET_STOCK_LAST_SHELF
                    WHERE        
                        SHELF_NUMBER = PP.PRODUCT_PLACE_ID AND 
                        STOCK_ID = PPR.STOCK_ID
            ), 0) AS REAL_STOCK
        FROM            
            #dsn3_alias#.PRODUCT_PLACE AS PP LEFT OUTER JOIN
            #dsn3_alias#.PRODUCT_PLACE_ROWS AS PPR ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID
        WHERE        
            PPR.STOCK_ID = #f_stock_id#
        ORDER BY
            REAL_STOCK DESC
    </cfquery>
<cfelse>

	<cfquery name="get_ambar_fis" datasource="#dsn2#">
		SELECT        
        	SUM(SFR.AMOUNT) AS AMOUNT, 
            S.STOCK_CODE, 
            S.PRODUCT_ID, 
            S.PROPERTY, 
            S.BARCOD, 
            S.PRODUCT_NAME, 
            SFR.STOCK_ID
		FROM            
        	STOCK_FIS AS SF INNER JOIN
         	STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
          	#dsn3_alias#.STOCKS AS S ON SFR.STOCK_ID = S.STOCK_ID
		WHERE 
        	SF.REF_NO = '#attributes.deliver_paper_no#' AND 
            SFR.STOCK_ID = #f_stock_id# AND 
            SF.DEPARTMENT_OUT = #ListGetAt(attributes.department_out_id,1,"-")#  AND 
            SF.LOCATION_OUT = #ListGetAt(attributes.department_out_id,2,"-")# 
		GROUP BY 
        	S.STOCK_CODE, 
            S.PRODUCT_ID, 
            S.PROPERTY, 
            S.BARCOD, 
            S.PRODUCT_NAME, 
            SFR.STOCK_ID
   	</cfquery>
    <cfquery name="get_depo_stok" datasource="#dsn2#">
    	SELECT 
        	PRODUCT_STOCK 
       	FROM 
        	PRTOTM_GET_STOCK_LOCATION_TOTAL 
       	WHERE  
        	DEPO = '#attributes.department_out_id#' AND 
            STOCK_ID =#f_stock_id#
    </cfquery>
    
</cfif>
<cfquery name="get_ambar_fis_group" datasource="#dsn2#">
		SELECT        
        	SUM(SFR.AMOUNT) AS AMOUNT
		FROM            
        	STOCK_FIS AS SF INNER JOIN
         	STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID
		WHERE 
        	SF.REF_NO = '#attributes.deliver_paper_no#' AND 
            SFR.STOCK_ID = #f_stock_id#
</cfquery>
<cfif get_ambar_fis_group.recordcount>
	<cfset all_amount = get_ambar_fis_group.amount>
<cfelse>
	<cfset all_amount = 0>
</cfif>
<style type="text/css">
.boxtext {
	text-decoration: none;
	background-color: #e6e6fe;
	margin: 0px;
	padding: 0px;
	border-top-width: 0px;
	border-right-width: 0px;
	border-bottom-width: 0px;
	border-left-width: 0px;
}
.tablo {
	text-decoration: none;
	margin: 0px;
	padding: 0px;
	border-top-width: 1px;
	border-right-width: 0px;
	border-bottom-width: 1px;
	border-left-width: 0px;
	border-top-color: aec7f0;
	border-right-color: aec7f0;
	border-bottom-color: aec7f0;
	border-left-color: aec7f0;
}
table,td,th,div{
    font-size:13px;
		font-weight: 600;
}
.form-title{
    font-size:13px;
}
input{
	  font-size:13px !important;
}
</style>
<!-----
<cfform name="form_basket">
  <cfinput id="txt_department_out" name="txt_department_out" type="hidden" value="#attributes.department_out_id#">
  <cfinput id="txt_department_in" name="txt_department_in" type="hidden" value="#attributes.department_in_id#">
  <cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
  <cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
  <div style="width:100%">
  	<table cellpadding="2" cellspacing="1" align="left" class="color-border" width="99%">
	  	    <tr>
  
  </tr>
    	<tr class="color-list" height="20px">
    		<td colspan="4"><strong><cfoutput>#get_stock_info.product_name#</cfoutput></strong></td>
    	</tr>
    	<tr class="color-list">
      		<td colspan="4">
            	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="color-border">
          			<tr class="color-list">
            			<td width="45px">Miktar</td>
            			<cfif get_store_type.raf gt 0><td width="75px">Raf</td></cfif>
            			<td width="95px">Barcode</td>
            			<td>Kontrol</td>
       	  			</tr>
          			<tr class="color-list">
            			<td>
                        	<input id="add_other_amount" name="add_other_amount" type="text" class="moneybox" onfocus="islemtipi=0;" style="width:40px; text-align:right" value="" />
                      	</td>
            			<cfif get_store_type.raf gt 0>
            				<td>
                            	<input id="add_other_shelf" name="add_other_shelf" type="text" class="moneybox" onfocus="islemtipi=0;" style="width:75px;" value="" />
                          	</td>
           				</cfif>
            			<td>
                        	<cfinput id="add_other_barcod" name="add_other_barcod" readonly="yes" type="text" value="#get_stock_info.BARCODE#" style="width:110px;" >
                       	</td>
            			<td nowrap="nowrap">
            				<cfinput type="text" value="#all_amount#" name="all_amount" id="all_amount" class="boxtext" style="text-align:right; font-weight:bold; width:30px">/
        					<cfinput type="text" value="#attributes.paket_sayisi#" name="paket_sayisi" id="paket_sayisi" class="boxtext" style="text-align:right;font-weight:bold;width:30px">
            			</td>
          			</tr>
        		</table>
         	</td>
    	</tr>
    	<tr class="color-list">
      		<td width="90" align="center">Barkod</td>
      		<td width="90" align="left">Ürün Adı</td>
      		<td width="40" align="right">Mikt.</td>
      		<cfif get_store_type.raf gt 0>
      			<td align="left">Raf</td>
      		</cfif>
    	</tr>
    	<tr class="color-list">
      		<td align="left" colspan="4">
        		<form name="product_row" id="product_row" method="post">
          			<table name="table1" id="table1" border="0" cellpadding="0" cellspacing="0" width="100%" class="tablo">
          				<cfoutput query="get_ambar_fis">
            				<cfinput type="hidden" value="#stock_id#" name="stockid#currentrow#" id="stockid#currentrow#" />
                			<cfinput type="hidden" value="" name="spectmainid#currentrow#" id="spectmainid#currentrow#" />
          	 				<tr id="row#currentrow#" height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                				<td><cfinput type="text" value="#barcod#" name="barcod#currentrow#" id="barcod#currentrow#" size="13" class="boxtext" readonly="yes" /></td>
                    			<td><cfinput type="text" value="#PRODUCT_NAME#" name="stockcode#currentrow#" id="stockcode#currentrow#" size="11" class="boxtext" readonly="yes" /></td>
                    			<td><cfinput type="text" value="#amount#" name="amount#currentrow#" id="amount#currentrow#" size="4" class="boxtext" readonly="yes" style="text-align:right" /></td>
                    			<cfif get_store_type.raf gt 0>
                    				<td><cfinput type="text" value="#shelf_code#" name="shelf_code#currentrow#" id="shelf_code#currentrow#" size="8" class="boxtext" readonly="yes" style="text-align:right" /></td>
                    			</cfif>
                			</tr>
           				</cfoutput>
          			</table>
          			<cfinput type="hidden" id="row_count" name="row_count" value="#get_ambar_fis.recordcount#" />
        		</form>
          	</td>
    	</tr>
    	<tr class="color-list">
      		<td colspan="4" valign="middle" align="center">
				<cfif get_store_type.raf gt 0>
                    <select name="shelf_select" style="width:100px; text-align:center">
                        <cfoutput query="get_shelf_stock">
                            <option value="">#SHELF_CODE# - #REAL_STOCK#</option>
                        </cfoutput>
                    </select>
                <cfelse>
                    Depo Miktarı : <cfoutput>#AmountFormat(get_depo_stok.product_stock)#</cfoutput>
                </cfif>
                <input type="hidden" id="department_in" name="department_in" value="" />
                <input type="hidden" id="action_id" name="action_id" value="" />
                <input id="geri" name="geri" value="Vazgeç" type="button" onClick="history.go(-1);" />
                <input id="sil" name="sil" value="Sil" type="button" style="width:30px" onClick="kontrol_sil();" />
                <input id="onay" name="Onay" value="<cf_get_lang_main no="49.Kaydet">" type="button" disabled="disabled" onClick="kontrol_kayit();" />
   	  		</td>
    	</tr>
  	</table>
  </div>
</cfform>----->
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
		
		<cfform name="form_basket" action="#request.self#?fuseaction=pda.emptypopup_add_shipping_ambar_stock_wb">
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
              <cfinput id="txt_department_out" name="txt_department_out" type="hidden" value="#attributes.department_out_id#">
  <cfinput id="txt_department_in" name="txt_department_in" type="hidden" value="#attributes.department_in_id#">
  <cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
			
			<!--- Orijinal Form Hidden Alanları --->
			<cfinput id="txt_department_out" name="txt_department_out" type="hidden" value="#attributes.department_out_id#">
			<cfinput id="txt_department_in" name="txt_department_in" type="hidden" value="#attributes.department_in_id#">
			<cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
			<cfinput type="hidden" name="row_count" id="row_count" value="#get_ambar_fis.recordcount#">
			<cfinput type="hidden" name="all_amount" id="all_amount" value="#all_amount#">
			<cfinput type="hidden" name="paket_sayisi" id="paket_sayisi" value="#attributes.paket_sayisi#">
			
			<div style="display:flex">
				<div class="form-group">
					<label for="add_other_amount">Miktar</label>
					<input type="text" class="moneybox" name="add_other_amount" id="add_other_amount" value="1" readonly>
				</div>
				<div class="form-group">
					<label for="add_other_barcod">Seri Numarası</label>
					<input type="text" name="add_other_barcod" id="add_other_barcod" class="moneybox" value="<cfoutput>#get_stock_info.BARCODE#</cfoutput>" placeholder="Seri Numarası">
				</div>
				<cfif get_store_type.raf gt 0>
					<div class="form-group">
						<label for="add_other_shelf">Raf Numarası</label>
						<input type="text" class="moneybox" name="add_other_shelf" id="add_other_shelf" value="" placeholder="Raf Numarası">
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
            <div class="form-group">
			<select name="BarcodeParser" id="BarcodeParser">
				<option value="0">Barkod Tipi</option>

			</select>
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
<script type="text/javascript">
(function () {
	'use strict';

	const state = {
		rowCount: <cfoutput>#get_ambar_fis.recordcount#</cfoutput>,
		stockId: '',
		barcode: '',
		stockCode: '',
		spectMainId: '',
		amount: 0,
		shelfCode: '',
		ekle: 0
	};

	const config = {
		hasShelf: <cfoutput>#iif(get_store_type.raf gt 0,1,0)#</cfoutput> === 1,
		saveBase: '<cfoutput>#request.self#?fuseaction=pda.emptypopup_add_shipping_ambar_stock_wb&shelf_type=#get_store_type.raf#&date1=#attributes.date1#&date2=#attributes.date2#&is_type=#attributes.is_type#&keyword=#attributes.keyword#&dep_in=#attributes.department_in_id#&dep_out=#attributes.department_out_id#&ref_no=#attributes.deliver_paper_no#&ship_id=#attributes.ship_id#&f_stock_id=#f_stock_id#&</cfoutput>',
		deleteUrl: '<cfoutput>#request.self#?fuseaction=pda.emptypopup_add_shipping_ambar_stock_wb&shelf_type=#get_store_type.raf#&date1=#attributes.date1#&date2=#attributes.date2#&is_type=#attributes.is_type#&keyword=#attributes.keyword#&dep_in=#attributes.department_in_id#&dep_out=#attributes.department_out_id#&ref_no=#attributes.deliver_paper_no#&ship_id=#attributes.ship_id#&f_stock_id=#f_stock_id#&type=1</cfoutput>'
	};

	const initialData = {
		allAmount: Number(<cfoutput>#all_amount#</cfoutput>) || 0
	};

	const dom = {
		form: null,
		inputs: {},
		hidden: {},
		tableBody: null
	};

	function init() {
		cacheDom();
		if (!dom.form) {
			return;
		}
		bindEvents();
		focusAmount();
		setTimeout(selectAmount, 1000);
	}

	function cacheDom() {
		dom.form = document.forms.form_basket || document.getElementById('form_basket');
		if (!dom.form) {
			return;
		}
		dom.inputs.amount = document.getElementById('add_other_amount');
		dom.inputs.barcode = document.getElementById('add_other_barcod');
		dom.inputs.shelf = document.getElementById('add_other_shelf');
		dom.hidden.actionId = document.getElementById('action_id');
		dom.hidden.rowCount = document.getElementById('row_count');
		dom.hidden.fisTipi = document.getElementById('fis_tipi');
		dom.hidden.processCat = document.getElementById('process_cat_id');
		dom.hidden.deptOut = document.getElementById('txt_department_out');
		dom.hidden.allAmount = document.getElementById('all_amount');
		dom.hidden.paketSayisi = document.getElementById('paket_sayisi');
		const table = document.getElementById('table1');
		dom.tableBody = table && table.tBodies && table.tBodies.length ? table.tBodies[0] : table;
	}

	function bindEvents() {
		dom.form.addEventListener('keydown', handleKeyDown);
		dom.form.addEventListener('submit', handleSubmit);
	}

	function focusAmount() {
		if (dom.inputs.amount) {
			dom.inputs.amount.focus();
		}
	}

	function selectAmount() {
		if (dom.inputs.amount) {
			dom.inputs.amount.select();
		}
	}

	function handleKeyDown(event) {
		if (event.key !== 'Enter' || !event.target.matches('input[type="text"]')) {
			return;
		}
		event.preventDefault();
		if (config.hasShelf) {
			handleShelfFlow();
		} else {
			handleBarcodeFlow();
		}
	}

	function handleBarcodeFlow() {
		if (dom.inputs.barcode && dom.inputs.barcode.value.length > 0) {
			addRow(dom.inputs.barcode.value);
			if (dom.inputs.amount) {
				dom.inputs.amount.value = '';
			}
			focusAmount();
		} else {
			alert('Barcod Hatalı');
			if (dom.inputs.barcode) {
				dom.inputs.barcode.value = '';
				dom.inputs.barcode.focus();
			}
		}
	}

	function handleShelfFlow() {
		if (dom.inputs.shelf && dom.inputs.shelf.value.length > 0) {
			searchShelf(dom.inputs.shelf.value);
		} else {
			alert('Raf Borkodu Hatalı');
			if (dom.inputs.shelf) {
				dom.inputs.shelf.value = '';
				dom.inputs.shelf.focus();
			}
		}
	}

	function buildActionId() {
		if (!dom.hidden.actionId) {
			return;
		}
		const payload = [];
		for (let i = 1; i <= state.rowCount; i++) {
			const amountField = document.getElementById('amount' + i);
			const stockField = document.getElementById('stockid' + i);
			if (!amountField || !stockField) {
				continue;
			}
			if (Number(amountField.value) > 0) {
				const rowParts = [i, stockField.value, amountField.value];
				if (config.hasShelf) {
					const shelfField = document.getElementById('shelf_code' + i);
					rowParts.push(shelfField ? shelfField.value : '');
				}
				payload.push(rowParts.join('-'));
			}
		}
		dom.hidden.actionId.value = payload.join(',');
		if (dom.hidden.rowCount) {
			dom.hidden.rowCount.value = payload.length;
		}
	}

	function adjustAllAmount(delta) {
		if (!dom.hidden.allAmount) {
			return;
		}
		const current = Number(dom.hidden.allAmount.value) || 0;
		dom.hidden.allAmount.value = current + delta;
	}

	function getStock(barcode) {
		state.barcode = '';
		state.stockId = '';
		state.stockCode = '';
		state.spectMainId = '';
		state.shelfCode = '';
		const sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER,S.PRODUCT_NAME FROM STOCKS_BARCODES AS SB INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE='" + barcode + "'";
		const product = wrk_query(sql, 'dsn3');
		if (product.STOCK_ID === undefined) {
			state.ekle = 1;
			alert('Ürün Bulunamadı');
			return;
		}
		const amountField = dom.inputs.amount;
		if (dom.hidden.allAmount && amountField) {
			adjustAllAmount(Number(amountField.value) || 0);
			const paketLimit = Number(dom.hidden.paketSayisi ? dom.hidden.paketSayisi.value : 0) || 0;
			if ((Number(dom.hidden.allAmount.value) || 0) <= paketLimit) {
				state.stockId = product.STOCK_ID;
				state.stockCode = product.PRODUCT_NAME;
				state.barcode = product.BARCODE;
				return;
			}
			alert('Sevk Emrinden Fazla Çıkış Yaptınız !');
			adjustAllAmount(-(Number(amountField.value) || 0));
			focusAmount();
			state.ekle = 1;
		}
	}

	function addAmount() {
		const currentAmount = Number(state.amount) || 0;
		if (state.rowCount > 0) {
			for (let i = 1; i <= state.rowCount; i++) {
				const stockField = document.getElementById('stockid' + i);
				if (!stockField || stockField.value !== String(state.stockId)) {
					continue;
				}
				if (config.hasShelf) {
					const shelfField = document.getElementById('shelf_code' + i);
					if (!shelfField || shelfField.value !== state.shelfCode) {
						continue;
					}
					const stockSql = "SELECT ISNULL(S.REAL_STOCK, 0) AS REAL_STOCK FROM GET_STOCK_LAST_SHELF AS S INNER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS P ON S.SHELF_NUMBER = P.PRODUCT_PLACE_ID WHERE P.SHELF_CODE='" + state.shelfCode + "' AND S.STOCK_ID=" + state.stockId;
					const shelfStock = wrk_query(stockSql, 'dsn2');
					const available = shelfStock.REAL_STOCK === undefined ? 0 : shelfStock.REAL_STOCK;
					const amountField = document.getElementById('amount' + i);
					if (!amountField) {
						continue;
					}
					if ((available * 1) < (Number(amountField.value) - (-1 * currentAmount))) {
						state.ekle = 1;
						alert('Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı : ' + available);
						amountField.value = Number(amountField.value) - (1 * currentAmount);
						focusAmount();
					} else {
						amountField.value = Number(amountField.value) - (-1 * currentAmount);
						state.ekle = 1;
					}
				} else {
					const stockSql = "SELECT PRODUCT_STOCK FROM PRTOTM_GET_STOCK_LOCATION_TOTAL WHERE DEPO='" + (dom.hidden.deptOut ? dom.hidden.deptOut.value : '') + "' AND STOCK_ID=" + state.stockId;
					const depotStock = wrk_query(stockSql, 'dsn2');
					const available = depotStock.PRODUCT_STOCK === undefined ? 0 : depotStock.PRODUCT_STOCK;
					if ((available * 1) < (-1 * currentAmount)) {
						state.ekle = 1;
						alert('Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı : ' + available);
						adjustAllAmount(-(Number(dom.inputs.amount ? dom.inputs.amount.value : 0)));
						focusAmount();
					} else {
						const amountField = document.getElementById('amount' + i);
						if (amountField) {
							amountField.value = Number(amountField.value) - (-1 * currentAmount);
						}
						state.ekle = 1;
					}
				}
			}
		} else {
			const qry = config.hasShelf
				? "SELECT ISNULL(S.REAL_STOCK, 0) AS REAL_STOCK FROM GET_STOCK_LAST_SHELF AS S INNER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS P ON S.SHELF_NUMBER = P.PRODUCT_PLACE_ID WHERE P.SHELF_CODE='" + state.shelfCode + "' AND S.STOCK_ID=" + state.stockId
				: "SELECT PRODUCT_STOCK FROM PRTOTM_GET_STOCK_LOCATION_TOTAL WHERE DEPO='" + (dom.hidden.deptOut ? dom.hidden.deptOut.value : '') + "' AND STOCK_ID=" + state.stockId;
			const stockInfo = wrk_query(qry, config.hasShelf ? 'dsn2' : 'dsn2');
			const available = config.hasShelf ? (stockInfo.REAL_STOCK === undefined ? 0 : stockInfo.REAL_STOCK) : (stockInfo.PRODUCT_STOCK === undefined ? 0 : stockInfo.PRODUCT_STOCK);
			if ((available * 1) < (1 * currentAmount)) {
				state.ekle = 1;
				alert('Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı : ' + available);
				focusAmount();
			}
		}
	}

	function createRow(barcode) {
		const table = dom.tableBody;
		if (!table) {
			return;
		}
		state.rowCount += 1;
		if (dom.hidden.rowCount) {
			dom.hidden.rowCount.value = state.rowCount;
		}
		const row = table.insertRow(table.rows.length);
		row.id = 'frm_row' + state.rowCount;
		const barcodeCell = row.insertCell();
		barcodeCell.innerHTML = '<input type="hidden" value="' + state.stockId + '" name="stockid' + state.rowCount + '" id="stockid' + state.rowCount + '" /><input type="hidden" value="' + state.spectMainId + '" name="spectmainid' + state.rowCount + '" id="spectmainid' + state.rowCount + '" /><input type="text" value="' + barcode + '" name="barcod' + state.rowCount + '" id="barcod' + state.rowCount + '" size="13" class="boxtext" readonly="yes" />';
		const codeCell = row.insertCell();
		codeCell.innerHTML = '<input type="text" value="' + state.stockCode + '" name="stockcode' + state.rowCount + '" id="stockcode' + state.rowCount + '" size="13" class="boxtext" readonly="yes" />';
		const amountCell = row.insertCell();
		amountCell.innerHTML = '<input type="text" style="text-align:center" value="' + state.amount + '" name="amount' + state.rowCount + '" id="amount' + state.rowCount + '" size="5" class="boxtext" readonly="yes" />';
		const shelfCell = row.insertCell();
		shelfCell.innerHTML = '<input type="text" value="' + state.shelfCode + '" name="shelf_code' + state.rowCount + '" id="shelf_code' + state.rowCount + '" size="8" class="boxtext" readonly="yes" style="text-align:right" />';
	}

	function addRow(barcode) {
		if (!config.hasShelf) {
			getStock(barcode);
		}
		state.amount = dom.inputs.amount ? dom.inputs.amount.value : 0;
		addAmount();
		if (state.ekle === 0) {
			createRow(barcode);
		} else {
			state.ekle = 0;
		}
	}

	function searchShelf(shelfCode) {
		const outDept = dom.hidden.deptOut ? dom.hidden.deptOut.value : '';
		const shelfSql = "SELECT PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE='" + shelfCode + "'";
		const shelf = wrk_query(shelfSql, 'dsn3');
		if (!shelf.recordcount) {
			alert('Seçtiğiniz Raf Bulunamadı!');
			if (dom.inputs.shelf) {
				dom.inputs.shelf.value = '';
				dom.inputs.shelf.focus();
			}
			return;
		}
		const shelfDept = shelf.STORE_ID.toString() + '-' + shelf.LOCATION_ID.toString();
		if (outDept !== shelfDept) {
			alert('Seçtiğiniz Raf Giriş Lokasyonunda Değildir.!');
			if (dom.inputs.shelf) {
				dom.inputs.shelf.value = '';
				dom.inputs.shelf.focus();
			}
			return;
		}
		if (!dom.inputs.barcode || dom.inputs.barcode.value.length === 0) {
			if (dom.inputs.barcode) {
				dom.inputs.barcode.focus();
			}
			return;
		}
		const sql = "SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, PP.SHELF_CODE FROM STOCKS_BARCODES AS SB INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID INNER JOIN PRODUCT_PLACE_ROWS AS PPR ON S.PRODUCT_ID = PPR.PRODUCT_ID INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID WHERE SB.BARCODE='" + dom.inputs.barcode.value + "' AND PP.SHELF_CODE='" + dom.inputs.shelf.value + "'";
		const product = wrk_query(sql, 'dsn3');
		if (product.STOCK_ID === undefined) {
			alert('Ürün Bulunamadı');
			if (dom.inputs.shelf) {
				dom.inputs.shelf.value = '';
				dom.inputs.shelf.focus();
			}
			return;
		}
		if (dom.hidden.allAmount && dom.inputs.amount) {
			adjustAllAmount(Number(dom.inputs.amount.value) || 0);
			const paketLimit = Number(dom.hidden.paketSayisi ? dom.hidden.paketSayisi.value : 0) || 0;
			if ((Number(dom.hidden.allAmount.value) || 0) <= paketLimit) {
				state.stockId = product.STOCK_ID;
				state.stockCode = product.PRODUCT_NAME;
				state.barcode = product.BARCODE;
				state.shelfCode = product.SHELF_CODE;
				addRow(product.BARCODE);
				if (dom.inputs.shelf) {
					dom.inputs.shelf.value = '';
				}
				if (dom.inputs.amount) {
					dom.inputs.amount.value = '';
				}
				focusAmount();
			} else {
				alert('Sevk Emrinden Fazla Çıkış Yaptınız !');
				adjustAllAmount(-(Number(dom.inputs.amount.value) || 0));
				if (dom.inputs.shelf) {
					dom.inputs.shelf.value = '';
				}
				focusAmount();
			}
		}
	}

	function handleSubmit(event) {
		if (event) {
			event.preventDefault();
		}
		if (!dom.hidden.deptOut || dom.hidden.deptOut.value === '') {
			alert('Depo Seçmelisiniz.');
			return false;
		}
		if (dom.hidden.deptOut.value.indexOf('-') === -1) {
			alert('Lütfen giriş için doğru depo seçiniz.');
			return false;
		}
		buildActionId();
		const actionId = dom.hidden.actionId ? dom.hidden.actionId.value : '';
		const fis = dom.hidden.fisTipi ? dom.hidden.fisTipi.value : '';
		const processCat = dom.hidden.processCat ? dom.hidden.processCat.value : '';
		const target = config.saveBase + 'action_id=' + encodeURIComponent(actionId) + '&fis_tipi=' + encodeURIComponent(fis) + '&process_cat=' + encodeURIComponent(processCat);
		window.location.href = target;
		return false;
	}

	function clearAllInputs(event) {
		if (event) {
			event.preventDefault();
		}
		if (dom.inputs.barcode) {
			dom.inputs.barcode.value = '';
		}
		if (dom.inputs.shelf) {
			dom.inputs.shelf.value = '';
		}
		if (dom.inputs.amount) {
			dom.inputs.amount.value = '1';
		}
		if (dom.tableBody) {
			dom.tableBody.innerHTML = '';
		}
		if (dom.hidden.rowCount) {
			dom.hidden.rowCount.value = 0;
		}
		if (dom.hidden.actionId) {
			dom.hidden.actionId.value = '';
		}
		if (dom.hidden.allAmount) {
			dom.hidden.allAmount.value = initialData.allAmount;
		}
		state.rowCount = 0;
		state.barcode = '';
		state.spectMainId = '';
		state.stockId = '';
		state.stockCode = '';
		state.shelfCode = '';
		state.amount = 0;
		state.ekle = 0;
	}

	function handleDelete() {
		const wantsDelete = confirm('Ambar Fişini Silmek İster misiniz ?');
		if (wantsDelete) {
			window.location.href = config.deleteUrl;
		}
	}

	window.addEventListener('DOMContentLoaded', init);
	window.kontrol_kayit = handleSubmit;
	window.submitForm = handleSubmit;
	window.clearAllInputs = clearAllInputs;
	window.kontrol_sil = handleDelete;
})();
</script>
<script>
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