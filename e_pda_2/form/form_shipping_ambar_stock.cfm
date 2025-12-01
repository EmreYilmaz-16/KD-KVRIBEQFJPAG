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
:root {
	--color-surface: #ffffff;
	--color-border: #dbe0ea;
	--color-accent: #0f62fe;
	--color-accent-muted: #e6efff;
	--color-text-dark: #1a1c20;
	--color-text-muted: #6b6f76;
	--shadow-soft: 0 6px 24px rgba(15, 32, 68, 0.08);
}
.boxtext {
	background-color: transparent;
	border: none;
	font-size: 13px;
	font-weight: 600;
}
table,td,th,div {
	font-size: 13px;
	font-weight: 600;
	color: var(--color-text-dark);
}
input, select {
	font-size: 13px !important;
}
.form-shell {
	max-width: 900px;
	margin: 0 auto;
	padding: 8px;
}
.card {
	background: var(--color-surface);
	border: 1px solid var(--color-border);
	border-radius: 12px;
	padding: 16px 18px;
	box-shadow: var(--shadow-soft);
	margin-bottom: 14px;
}
.card__header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 12px;
	margin-bottom: 12px;
}
.card__title {
	font-size: 15px;
	font-weight: 700;
	margin: 0;
}
.badge {
	background: var(--color-accent-muted);
	color: var(--color-accent);
	border-radius: 999px;
	padding: 4px 10px;
	font-size: 12px;
	font-weight: 600;
}
.quick-nav {
	display: flex;
	gap: 12px;
	flex-wrap: wrap;
	margin-bottom: 16px;
}
.quick-nav__link {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 6px 10px;
	border-radius: 10px;
	border: 1px solid var(--color-border);
	background: var(--color-surface);
	transition: border-color 0.2s ease, transform 0.2s ease;
}
.quick-nav__link:hover {
	border-color: var(--color-accent);
	transform: translateY(-1px);
}
.quick-nav__icon {
	width: 30px;
	height: 30px;
}
.form-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
	gap: 12px;
}
.field {
	display: flex;
	flex-direction: column;
	gap: 4px;
}
.field__label {
	color: var(--color-text-muted);
	font-weight: 600;
}
.field__input {
	border: 1px solid var(--color-border);
	border-radius: 8px;
	padding: 6px 8px;
	font-weight: 600;
}
.field__input:focus {
	outline: 2px solid var(--color-accent);
	border-color: transparent;
}
.stats-pill {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	border-radius: 999px;
	padding: 6px 12px;
	background: var(--color-accent-muted);
	color: var(--color-accent);
	font-weight: 700;
}
.stats-pill__input {
	background: transparent;
	border: none;
	width: 36px;
	text-align: right;
	color: var(--color-accent);
	font-weight: 700;
}
.table-wrapper {
	overflow-x: auto;
}
.data-table {
	width: 100%;
	border-collapse: collapse;
}
.data-table th,
.data-table td {
	padding: 8px 10px;
	border-bottom: 1px solid var(--color-border);
	text-align: left;
}
.data-table th {
	text-transform: uppercase;
	font-size: 11px;
	letter-spacing: 0.5px;
	color: var(--color-text-muted);
}
.btn-bar {
	display: flex;
	align-items: center;
	flex-wrap: wrap;
	gap: 10px;
}
.btn {
	border: none;
	border-radius: 10px;
	padding: 8px 18px;
	font-weight: 700;
	cursor: pointer;
	transition: opacity 0.2s ease, transform 0.2s ease;
}
.btn:disabled {
	opacity: 0.5;
	cursor: not-allowed;
}
.btn-primary {
	background: var(--color-accent);
	color: #ffffff;
}
.btn-secondary {
	background: #edf1f7;
	color: var(--color-text-dark);
}
.btn-danger {
	background: #f56565;
	color: #ffffff;
}
.alert-text {
	color: var(--color-text-muted);
	font-size: 12px;
}
.table-legend {
	display: flex;
	justify-content: space-between;
	align-items: center;
	flex-wrap: wrap;
	gap: 12px;
}
</style>
<cfform name="form_basket">
	<cfinput id="txt_department_out" name="txt_department_out" type="hidden" value="#attributes.department_out_id#">
	<cfinput id="txt_department_in" name="txt_department_in" type="hidden" value="#attributes.department_in_id#">
	<cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
	<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
	<div class="form-shell">
		<div class="quick-nav">
			<cfoutput>
				<a class="quick-nav__link" href="#request.self#?fuseaction=epda_prtotm_welcome" title="Ana Sayfa">
					<img src="../../images/e-pd/Home.png" alt="Ana Sayfa" class="quick-nav__icon">
					<span>Ana Sayfa</span>
				</a>
				<a class="quick-nav__link" href="#request.self#?fuseaction=epda.prtotm_ambar_sevk" title="Ambardan Malkabule">
					<img src="../../images/e-pd/up30.png" alt="Ambardan Malkabule" class="quick-nav__icon">
					<span>Ambardan Malkabule</span>
				</a>
				<a class="quick-nav__link" href="#request.self#?fuseaction=epda.prtotm_mal_ambar" title="Mal Kabulden Ambara">
					<img src="../../images/e-pd/down30.png" alt="Mal Kabulden Ambara" class="quick-nav__icon">
					<span>Mal Kabul</span>
				</a>
				<a class="quick-nav__link" href="#request.self#?fuseaction=epda.prtotm_svk_kontrol" title="Sevkiyat Kontrol">
					<img src="../../images/e-pd/tickmav30.png" alt="Sevkiyat Kontrol" class="quick-nav__icon">
					<span>Sevkiyat Kontrol</span>
				</a>
			</cfoutput>
		</div>
		<section class="card">
			<div class="card__header">
				<h2 class="card__title">Ürün Bilgisi</h2>
				<cfoutput><span class="badge">#get_stock_info.STOCK_CODE#</span></cfoutput>
			</div>
			<div class="form-grid">
				<div class="field">
					<span class="field__label">Ürün</span>
					<cfoutput><span>#get_stock_info.PRODUCT_NAME#</span></cfoutput>
				</div>
				<div class="field">
					<span class="field__label">Barkod</span>
					<cfoutput><span>#get_stock_info.BARCODE#</span></cfoutput>
				</div>
				<div class="field">
					<span class="field__label">Stok Kodu 2</span>
					<cfoutput><span>#get_stock_info.STOCK_CODE_2#</span></cfoutput>
				</div>
			</div>
		</section>
		<section class="card">
			<div class="card__header">
				<h3 class="card__title">Ürün Çıkışı</h3>
				<span class="stats-pill">
					<span>Toplam</span>
					<cfinput type="text" value="#all_amount#" name="all_amount" id="all_amount" class="boxtext stats-pill__input" readonly="yes">
					<span>/</span>
					<cfinput type="text" value="#attributes.paket_sayisi#" name="paket_sayisi" id="paket_sayisi" class="boxtext stats-pill__input" readonly="yes">
				</span>
			</div>
			<div class="form-grid">
				<label class="field">
					<span class="field__label">Miktar</span>
					<input id="add_other_amount" name="add_other_amount" type="text" class="field__input" value="" autocomplete="off" />
				</label>
				<cfif get_store_type.raf gt 0>
					<label class="field">
						<span class="field__label">Raf</span>
						<input id="add_other_shelf" name="add_other_shelf" type="text" class="field__input" value="" autocomplete="off" />
					</label>
				</cfif>
				<label class="field">
					<span class="field__label">Barkod</span>
					<cfinput id="add_other_barcod" name="add_other_barcod" readonly="yes" type="text" value="#get_stock_info.BARCODE#" class="field__input" >
				</label>
			</div>
			<p class="alert-text">Enter tuşu ile hızlıca satır ekleyebilirsiniz. Raflı sistemlerde raf kodunu okutmayı unutmayın.</p>
		</section>
		<section class="card">
			<div class="card__header">
				<h3 class="card__title">İşlem Satırları</h3>
				<span class="alert-text">Yeni satırlar listenin en altına eklenir.</span>
			</div>
			<div class="table-wrapper">
				<table name="table1" id="table1" class="data-table">
					<thead>
						<tr>
							<th>Barkod</th>
							<th>Ürün Adı</th>
							<th>Miktar</th>
							<cfif get_store_type.raf gt 0>
								<th>Raf</th>
							</cfif>
						</tr>
					</thead>
					<tbody>
						<cfoutput query="get_ambar_fis">
							<cfinput type="hidden" value="#stock_id#" name="stockid#currentrow#" id="stockid#currentrow#" />
							<cfinput type="hidden" value="" name="spectmainid#currentrow#" id="spectmainid#currentrow#" />
							<tr id="row#currentrow#" class="color-row">
								<td><cfinput type="text" value="#barcod#" name="barcod#currentrow#" id="barcod#currentrow#" class="boxtext" readonly="yes" /></td>
								<td><cfinput type="text" value="#PRODUCT_NAME#" name="stockcode#currentrow#" id="stockcode#currentrow#" class="boxtext" readonly="yes" /></td>
								<td><cfinput type="text" value="#amount#" name="amount#currentrow#" id="amount#currentrow#" class="boxtext" readonly="yes" style="text-align:right" /></td>
								<cfif get_store_type.raf gt 0>
									<td><cfinput type="text" value="#shelf_code#" name="shelf_code#currentrow#" id="shelf_code#currentrow#" class="boxtext" readonly="yes" style="text-align:right" /></td>
								</cfif>
							</tr>
						</cfoutput>
					</tbody>
				</table>
				<cfinput type="hidden" id="row_count" name="row_count" value="#get_ambar_fis.recordcount#" />
			</div>
		</section>
		<section class="card">
			<div class="table-legend">
				<div>
					<cfif get_store_type.raf gt 0>
						<label class="field">
							<span class="field__label">Raf Stoğu</span>
							<select name="shelf_select" class="field__input" style="text-align:center">
								<cfoutput query="get_shelf_stock">
									<option value="">#SHELF_CODE# - #REAL_STOCK#</option>
								</cfoutput>
							</select>
						</label>
					<cfelse>
						<span class="field__label">Depo Miktarı</span>
						<strong><cfoutput>#AmountFormat(get_depo_stok.product_stock)#</cfoutput></strong>
					</cfif>
				</div>
				<div class="btn-bar">
					<input type="hidden" id="department_in" name="department_in" value="" />
					<input type="hidden" id="action_id" name="action_id" value="" />
					<input id="geri" name="geri" value="Vazgeç" type="button" class="btn btn-secondary" onClick="history.go(-1);" />
					<input id="sil" name="sil" value="Sil" type="button" class="btn btn-danger" onClick="ShippingStockForm.handleDelete();" />
					<input id="onay" name="Onay" value="<cf_get_lang_main no="49.Kaydet">" type="button" class="btn btn-primary" disabled="disabled" onClick="ShippingStockForm.handleSubmit();" />
				</div>
			</div>
		</section>
	</div>
</cfform>
<script type="text/javascript">
const ShippingStockForm = (() => {
	let rowCount = 0;
	let barcod = '';
	let stockid = '';
	let spectmainid = '';
	let stockcode = '';
	let amount = 0;
	let shelf_code = '';
	let ekle = 0;
	let cikar = 0;
	let islemTipi = 0;
	let buton = 0;
	const hasShelf = <cfif get_store_type.raf gt 0>true<cfelse>false</cfif>;
	const dom = {};

	function cacheDom() {
		dom.form = document.forms.form_basket;
		dom.amountInput = document.getElementById('add_other_amount');
		dom.shelfInput = document.getElementById('add_other_shelf');
		dom.barcodeInput = document.getElementById('add_other_barcod');
		dom.allAmountInput = document.getElementById('all_amount');
		dom.packageInput = document.getElementById('paket_sayisi');
		dom.actionInput = document.getElementById('action_id');
		dom.rowCountInput = document.getElementById('row_count');
		dom.submitButton = document.getElementById('onay');
		dom.departmentOut = document.getElementById('txt_department_out');
		dom.tableBody = document.querySelector('#table1 tbody') || document.getElementById('table1');
	}

	function init() {
		cacheDom();
		rowCount = parseInt(dom.rowCountInput ? dom.rowCountInput.value || '0' : '0', 10);
		focusAmount();
		bindEvents();
	}

	function focusAmount() {
		if (!dom.amountInput) return;
		dom.amountInput.focus();
		setTimeout(() => dom.amountInput.select(), 1000);
	}

	function bindEvents() {
		document.addEventListener('keydown', handleKeydown);
		if (dom.amountInput) {
			dom.amountInput.addEventListener('focus', () => { islemTipi = 0; });
		}
		if (dom.shelfInput) {
			dom.shelfInput.addEventListener('focus', () => { islemTipi = 0; });
		}
	}

	function updateButtonState() {
		if (islemTipi === 0) {
			buton++;
		} else if (buton > 0) {
			buton--;
		}
		if (dom.submitButton) {
			dom.submitButton.disabled = buton < 1;
		}
	}

	function buildActionMap() {
		if (!dom.actionInput) return;
		dom.actionInput.value = '';
		let j = 0;
		for (let i = 1; i <= rowCount; i++) {
			const amountEl = document.getElementById('amount' + i);
			const stockEl = document.getElementById('stockid' + i);
			if (!amountEl || !stockEl) continue;
			if (parseFloat(amountEl.value) > 0) {
				if (j > 0) {
					dom.actionInput.value += ',';
				}
				dom.actionInput.value += i + '-' + stockEl.value + '-' + amountEl.value;
				if (hasShelf) {
					const shelfEl = document.getElementById('shelf_code' + i);
					dom.actionInput.value += '-' + (shelfEl ? shelfEl.value : '');
				}
				j++;
			}
		}
		if (dom.rowCountInput) {
			dom.rowCountInput.value = j;
		}
	}

	function adjustTotal(delta) {
		if (!dom.allAmountInput) return 0;
		const current = parseFloat(dom.allAmountInput.value || 0);
		const numericDelta = isNaN(delta) ? 0 : delta;
		const updated = current + numericDelta;
		dom.allAmountInput.value = updated;
		return updated;
	}

	function revertTotal(delta) {
		adjustTotal(delta * -1);
	}

	function lookupStock(barcode) {
		barcod = '';
		stockid = '';
		stockcode = '';
		spectmainid = '';
		if (!barcode) {
			return false;
		}
		const sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER,S.PRODUCT_NAME FROM STOCKS_BARCODES AS SB INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '" + barcode + "'";
		const product = wrk_query(sql,'dsn3');
		if (product.STOCK_ID == undefined) {
			ekle = 1;
			cikar = 1;
			alert('Ürün Bulunamadı');
			return false;
		}
		const enteredAmount = parseFloat(dom.amountInput ? dom.amountInput.value || 0 : 0);
		if (!enteredAmount || enteredAmount <= 0) {
			alert('Geçerli miktar giriniz.');
			return false;
		}
		const newTotal = adjustTotal(enteredAmount);
		const paketLimit = parseFloat(dom.packageInput ? dom.packageInput.value || 0 : 0);
		if (newTotal <= paketLimit) {
			stockid = product.STOCK_ID;
			stockcode = product.PRODUCT_NAME;
			barcod = product.BARCODE;
			updateButtonState();
			return true;
		}
		alert('Sevk Emrinden Fazla Çıkış Yaptınız !');
		revertTotal(enteredAmount);
		if (dom.amountInput) dom.amountInput.focus();
		ekle = 1;
		return false;
	}

	function add_amount() {
		const depotValue = dom.departmentOut ? dom.departmentOut.value : (dom.form && dom.form.txt_department_out ? dom.form.txt_department_out.value : '');
		if (rowCount > 0) {
			for (let i = 1; i <= rowCount; i++) {
				<cfif get_store_type.raf gt 0>
				if (document.getElementById('stockid' + i) && document.getElementById('stockid' + i).value == stockid && document.getElementById('shelf_code' + i).value == shelf_code) {
					var stock_sql = "SELECT ISNULL(S.REAL_STOCK, 0) AS REAL_STOCK FROM GET_STOCK_LAST_SHELF AS S INNER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS P ON S.SHELF_NUMBER = P.PRODUCT_PLACE_ID WHERE P.SHELF_CODE = '" + shelf_code + "' AND S.STOCK_ID =" + stockid;
					var get_real_stock = wrk_query(stock_sql,'dsn2');
					if(get_real_stock.REAL_STOCK==undefined) get_real_stock.REAL_STOCK = 0;
					if((get_real_stock.REAL_STOCK*1) < document.getElementById('amount'+i).value - (-1 * amount)) {
						ekle=1;
						alert("Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı : " + get_real_stock.REAL_STOCK);
						document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (1 * amount);
						if (dom.amountInput) dom.amountInput.focus();
					} else {
						document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
						ekle=1;
					}
				}
				<cfelse>
				if (document.getElementById('stockid' + i) && document.getElementById('stockid' + i).value == stockid) {
					var stock_sql = "SELECT PRODUCT_STOCK FROM PRTOTM_GET_STOCK_LOCATION_TOTAL WHERE  DEPO = '"+depotValue+"' AND STOCK_ID ="+stockid;
					var get_real_stock = wrk_query(stock_sql,'dsn2');
					if(get_real_stock.PRODUCT_STOCK==undefined) get_real_stock.PRODUCT_STOCK = 0;
					if((get_real_stock.PRODUCT_STOCK*1) < (-1 * amount)) {
						ekle=1;
						alert("Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı : " + get_real_stock.PRODUCT_STOCK);
						revertTotal(amount);
						if (dom.amountInput) dom.amountInput.focus();
					} else {
						document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
						ekle=1;
					}
				}
				</cfif>
			}
		} else {
			<cfif get_store_type.raf gt 0>
			var stock_sql_1 = "SELECT ISNULL(S.REAL_STOCK, 0) AS REAL_STOCK FROM GET_STOCK_LAST_SHELF AS S INNER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS P ON S.SHELF_NUMBER = P.PRODUCT_PLACE_ID WHERE P.SHELF_CODE = '" + shelf_code + "' AND S.STOCK_ID =" + stockid;
			var get_real_stock_1 = wrk_query(stock_sql_1,'dsn2');
			if(get_real_stock_1.REAL_STOCK==undefined) get_real_stock_1.REAL_STOCK = 0;
			if((get_real_stock_1.REAL_STOCK*1) < (1*amount)) {
				ekle=1;
				alert("Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı : " + get_real_stock_1.REAL_STOCK);
				if (dom.amountInput) dom.amountInput.focus();
			}
			<cfelse>
			var stock_sql_1 = "SELECT PRODUCT_STOCK FROM PRTOTM_GET_STOCK_LOCATION_TOTAL WHERE  DEPO = '"+depotValue+"' AND STOCK_ID ="+stockid;
			var get_real_stock_1 = wrk_query(stock_sql_1,'dsn2');
			if(get_real_stock_1.PRODUCT_STOCK==undefined) get_real_stock_1.PRODUCT_STOCK = 0;
			if((get_real_stock_1.PRODUCT_STOCK*1) < (1*amount)) {
				ekle=1;
				alert("Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı : " + get_real_stock_1.PRODUCT_STOCK);
				revertTotal(amount);
				if (dom.amountInput) dom.amountInput.focus();
			}
			</cfif>
		}
	}

	function addRow(barcode) {
		if (!hasShelf && !lookupStock(barcode)) {
			return;
		}
		amount = parseFloat(dom.amountInput ? dom.amountInput.value || 0 : 0);
		if (!amount || amount <= 0) {
			alert('Geçerli miktar giriniz.');
			return;
		}
		if (!hasShelf) {
			shelf_code = '';
		}
		add_amount();
		if (ekle === 0) {
			rowCount++;
			if (dom.rowCountInput) dom.rowCountInput.value = rowCount;
			const tableBody = dom.tableBody;
			if (!tableBody) {
				return;
			}
			const newRow = tableBody.insertRow(tableBody.rows.length);
			newRow.setAttribute('id','frm_row' + rowCount);
			const displayBarcode = barcod || barcode;
			let newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="hidden" value="' + stockid + '" name="stockid' + rowCount + '" id="stockid' + rowCount + '" />'
				+ '<input type="hidden" value="' + spectmainid + '" name="spectmainid' + rowCount + '" id="spectmainid' + rowCount + '" />'
				+ '<input type="text" value="' + displayBarcode + '" name="barcod' + rowCount + '" id="barcod' + rowCount + '" class="boxtext" readonly="yes" />';
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="text" value="' + stockcode + '" name="stockcode' + rowCount + '" id="stockcode' + rowCount + '" class="boxtext" readonly="yes" />';
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="text" value="' + amount + '" name="amount' + rowCount + '" id="amount' + rowCount + '" class="boxtext" readonly="yes" style="text-align:right" />';
			if (hasShelf) {
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" value="' + shelf_code + '" name="shelf_code' + rowCount + '" id="shelf_code' + rowCount + '" class="boxtext" readonly="yes" style="text-align:right" />';
			}
			shelf_code = '';
			ekle = 0;
		} else {
			ekle = 0;
		}
	}

	function handleKeydown(e) {
		const keycode = e ? (e.which || e.keyCode) : window.event.keyCode;
		if (keycode !== 13) {
			return;
		}
		if (hasShelf) {
			if (dom.shelfInput && dom.shelfInput.value.length > 0) {
				searchShelf(dom.shelfInput.value);
			} else {
				alert('Raf Barkodu Hatalı');
				if (dom.shelfInput) {
					dom.shelfInput.value = '';
					dom.shelfInput.focus();
				}
			}
		} else {
			if (dom.barcodeInput && dom.barcodeInput.value.length > 0) {
				addRow(dom.barcodeInput.value);
				if (dom.amountInput) {
					dom.amountInput.value = '';
					dom.amountInput.focus();
				}
			} else {
				alert('Barkod Hatalı');
				if (dom.barcodeInput) {
					dom.barcodeInput.value = '';
					dom.barcodeInput.focus();
				}
			}
		}
	}

	function searchShelf(shelfValue) {
		const giris_depo = dom.departmentOut ? dom.departmentOut.value : '';
		const shelf_sql = "SELECT PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE = '" + shelfValue + "'";
		const get_shelf = wrk_query(shelf_sql,'dsn3');
		if(get_shelf.recordcount) {
			const giris_depo_s = get_shelf.STORE_ID.toString() + '-' + get_shelf.LOCATION_ID.toString();
			if(giris_depo !== giris_depo_s) {
				alert('Seçtiğiniz Raf Giriş Lokasyonunda Değildir.!');
				if (dom.shelfInput) {
					dom.shelfInput.value = '';
					dom.shelfInput.focus();
				}
				return;
			}
			if (dom.barcodeInput && dom.barcodeInput.value.length > 0) {
				const new_sql = "SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, PP.SHELF_CODE FROM STOCKS_BARCODES AS SB INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID INNER JOIN PRODUCT_PLACE_ROWS AS PPR ON S.PRODUCT_ID = PPR.PRODUCT_ID INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID WHERE SB.BARCODE = '" + dom.barcodeInput.value + "' AND PP.SHELF_CODE ='" + dom.shelfInput.value + "'";
				const get_product = wrk_query(new_sql,'dsn3');
				if (get_product.STOCK_ID == undefined) {
					alert('Ürün Bulunamadı');
					dom.shelfInput.value = '';
					dom.shelfInput.focus();
					return;
				}
				const enteredAmount = parseFloat(dom.amountInput ? dom.amountInput.value || 0 : 0);
				if (!enteredAmount || enteredAmount <= 0) {
					alert('Geçerli miktar giriniz.');
					return;
				}
				const newTotal = adjustTotal(enteredAmount);
				const paketLimit = parseFloat(dom.packageInput ? dom.packageInput.value || 0 : 0);
				if (newTotal <= paketLimit) {
					stockid = get_product.STOCK_ID;
					stockcode = get_product.PRODUCT_NAME;
					barcod = get_product.BARCODE;
					shelf_code = get_product.SHELF_CODE;
					updateButtonState();
					addRow(barcod);
					if (dom.shelfInput) dom.shelfInput.value = '';
					if (dom.amountInput) dom.amountInput.value = '';
					if (dom.amountInput) dom.amountInput.focus();
				} else {
					alert('Sevk Emrinden Fazla Çıkış Yaptınız !');
					revertTotal(enteredAmount);
					if (dom.shelfInput) dom.shelfInput.value = '';
					if (dom.amountInput) dom.amountInput.focus();
				}
			} else {
				if (dom.barcodeInput) {
					dom.barcodeInput.focus();
				}
			}
		} else {
			alert('Seçtiğiniz Raf Bulunamadı!');
			if (dom.shelfInput) {
				dom.shelfInput.value = '';
				dom.shelfInput.focus();
			}
		}
	}

	function handleSubmit() {
		const depValue = dom.departmentOut ? dom.departmentOut.value : '';
		if (depValue === '') {
			alert('Depo Seçmelisiniz.');
			return false;
		}
		if (depValue.indexOf('-') === -1) {
			alert('Lütfen giriş için doğru depo seçiniz.');
			return false;
		}
		buildActionMap();
		const fisValue = dom.form && dom.form.fis_tipi ? dom.form.fis_tipi.value : '';
		const processCatValue = dom.form && dom.form.process_cat_id ? dom.form.process_cat_id.value : '';
		const targetUrl = '<cfoutput>#request.self#?fuseaction=epda.emptypopup_add_prtotm_shipping_ambar_stock_q&shelf_type=#get_store_type.raf#&date1=#attributes.date1#&date2=#attributes.date2#&is_type=#attributes.is_type#&keyword=#attributes.keyword#&dep_in=#attributes.department_in_id#&dep_out=#attributes.department_out_id#&ref_no=#attributes.deliver_paper_no#&ship_id=#attributes.ship_id#&f_stock_id=#f_stock_id#&</cfoutput>'
			+ 'action_id=' + encodeURIComponent(dom.actionInput ? dom.actionInput.value : '')
			+ '&fis_tipi=' + encodeURIComponent(fisValue)
			+ '&process_cat=' + encodeURIComponent(processCatValue);
		window.location.href = targetUrl;
		return true;
	}

	function handleDelete() {
		const sil_kontrol = confirm('Ambar Fişini Silmek İster misiniz ?');
		if (sil_kontrol === true) {
			window.location.href = '<cfoutput>#request.self#?fuseaction=epda.emptypopup_del_prtotm_shipping_ambar_stock_q&shelf_type=#get_store_type.raf#&date1=#attributes.date1#&date2=#attributes.date2#&is_type=#attributes.is_type#&keyword=#attributes.keyword#&dep_in=#attributes.department_in_id#&dep_out=#attributes.department_out_id#&ref_no=#attributes.deliver_paper_no#&ship_id=#attributes.ship_id#&f_stock_id=#f_stock_id#&type=1'</cfoutput>;
		}
	}

	return {
		init,
		handleSubmit,
		handleDelete
	};
})();

document.addEventListener('DOMContentLoaded', ShippingStockForm.init);
</script>