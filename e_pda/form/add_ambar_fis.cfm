
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
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
<cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
<cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,1)#">
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
	:root {
		--pda-bg: linear-gradient(165deg, #eef2ff 0%, #f8fbff 100%);
		--pda-card-bg: rgba(255, 255, 255, 0.86);
		--pda-text: #1f2937;
		--pda-muted: #64748b;
		--pda-border: rgba(148, 163, 184, 0.28);
		--pda-primary: #0b72ec;
		--pda-primary-dark: #0750a6;
		--pda-success: #0f9d58;
		--pda-alert: #d93025;
		--pda-radius: 18px;
		--pda-shadow: 0 16px 35px rgba(15, 23, 42, 0.16);
	}

	body {
		margin: 0;
		font-family: "Segoe UI", Roboto, sans-serif;
		background: var(--pda-bg);
		color: var(--pda-text);
		line-height: 1.5;
	}

	.header {
		display: none;
	}

	.pda-theme {
		min-height: calc(100vh - 40px);
		padding: 26px 20px 34px;
		display: flex;
		justify-content: center;
	}

	.pda-wrapper {
		width: min(560px, 100%);
		display: flex;
		flex-direction: column;
		gap: 20px;
	}

	.pda-page-header {
		background: rgba(255, 255, 255, 0.72);
		border-radius: var(--pda-radius);
		padding: 20px 22px;
		box-shadow: var(--pda-shadow);
		backdrop-filter: blur(16px);
		position: sticky;
		top: 12px;
		z-index: 2;
	}

	.pda-page-header h2 {
		margin: 0 0 6px;
		font-size: 24px;
		font-weight: 700;
		letter-spacing: 0.25px;
	}

	.pda-page-header p {
		margin: 0;
		font-size: 13px;
		color: var(--pda-muted);
	}

	.pda-card {
		background: var(--pda-card-bg);
		border-radius: var(--pda-radius);
		padding: 20px 22px 24px;
		box-shadow: var(--pda-shadow);
		backdrop-filter: blur(18px);
		display: flex;
		flex-direction: column;
		gap: 20px;
		border: 1px solid var(--pda-border);
	}

	.form-grid {
		display: grid;
		gap: 18px;
		grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
	}

	.field {
		display: flex;
		flex-direction: column;
		gap: 8px;
		position: relative;
	}

	.field label {
		font-size: 12px;
		font-weight: 600;
		letter-spacing: 0.4px;
		text-transform: uppercase;
		color: var(--pda-muted);
	}

	.field input,
	.field select {
		width: 100%;
		padding: 12px 14px;
		border-radius: 12px;
		border: 1px solid var(--pda-border);
		background: #ffffff;
		font-size: 15px;
		color: var(--pda-text);
		transition: border-color 0.2s ease, box-shadow 0.2s ease;
	}

	.field select {
		appearance: none;
		background-image: url('data:image/svg+xml;utf8,<svg fill="%2364748b" height="12" viewBox="0 0 20 20" width="12" xmlns="http://www.w3.org/2000/svg"><path d="M5.516 7.548l4.484 4.57 4.484-4.57 1.414 1.414L10 14.014 4.102 8.962z"/></svg>');
		background-repeat: no-repeat;
		background-position: right 14px center;
		background-size: 12px;
		padding-right: 42px;
	}

	.field input:focus,
	.field select:focus {
		border-color: rgba(11, 114, 236, 0.65);
		box-shadow: 0 0 0 3px rgba(11, 114, 236, 0.18);
		outline: none;
	}

	.field-hint {
		font-size: 11px;
		color: var(--pda-muted);
		opacity: 0.8;
	}

	.field--compact label {
		white-space: nowrap;
	}

	.field--compact select {
		min-width: 160px;
	}

	.data-card {
		background: var(--pda-card-bg);
		border-radius: var(--pda-radius);
		padding: 20px 22px;
		box-shadow: var(--pda-shadow);
		border: 1px solid var(--pda-border);
		backdrop-filter: blur(18px);
		display: flex;
		flex-direction: column;
		gap: 16px;
	}

	.data-card-header {
		display: flex;
		flex-direction: column;
		gap: 4px;
	}

	.data-card-header h3 {
		margin: 0;
		font-size: 17px;
		font-weight: 700;
	}

	.data-card-header p {
		margin: 0;
		font-size: 12px;
		color: var(--pda-muted);
	}

	.data-scroll {
		max-height: 320px;
		overflow-y: auto;
		padding-right: 4px;
	}

	.data-card table,
	.data-card thead,
	.data-card tbody,
	.data-card tr,
	.data-card th,
	.data-card td {
		width: 100%;
		border-collapse: collapse;
	}

	.data-card thead th {
		text-align: left;
		font-size: 11px;
		letter-spacing: 0.35px;
		text-transform: uppercase;
		color: var(--pda-muted);
		padding-bottom: 10px;
		border-bottom: 1px solid rgba(148, 163, 184, 0.35);
	}

	.data-card tbody td {
		padding: 12px 0;
		font-size: 14px;
		border-bottom: 1px solid rgba(148, 163, 184, 0.22);
	}

	.data-card tbody tr:last-child td {
		border-bottom: none;
	}

	.data-card input.boxtext {
		border: none;
		background: transparent;
		padding: 0;
		font-size: 14px;
		color: var(--pda-text);
	}

	.primary-button {
		border: none;
		border-radius: 14px;
		background: var(--pda-primary);
		color: #ffffff;
		font-size: 16px;
		font-weight: 600;
		padding: 14px 22px;
		min-width: 160px;
		transition: background 0.2s ease, transform 0.2s ease, box-shadow 0.2s ease;
	}

	.primary-button:disabled {
		opacity: 0.45;
		cursor: not-allowed;
		transform: none;
		box-shadow: none;
	}

	.primary-button:not(:disabled) {
		cursor: pointer;
		box-shadow: 0 12px 24px rgba(11, 114, 236, 0.32);
	}

	.primary-button:not(:disabled):hover {
		background: var(--pda-primary-dark);
		transform: translateY(-1px);
	}

	.form-actions {
		display: flex;
		justify-content: flex-end;
		margin-top: 18px;
	}

	.boxtext {
		text-decoration: none;
		background: transparent;
		margin: 0;
		padding: 0;
	}

	.tablo {
		text-decoration: none;
		margin: 0;
		padding: 0;
		border: none;
	}

	#loglar {
		display: none;
	}

	@media (max-width: 520px) {
		.pda-page-header,
		.pda-card,
		.data-card {
			padding: 18px;
		}

		.primary-button {
			width: 100%;
		}

		.form-actions {
			margin-top: 14px;
			justify-content: stretch;
		}

		.field select {
			padding-right: 34px;
		}
	}

	@media (prefers-color-scheme: dark) {
		body {
			background: linear-gradient(165deg, #141a2d 0%, #101625 100%);
			color: #e2e8f0;
		}

		.pda-page-header,
		.pda-card,
		.data-card {
			background: rgba(26, 33, 54, 0.82);
			border-color: rgba(94, 103, 135, 0.36);
			box-shadow: 0 18px 40px rgba(3, 7, 18, 0.66);
		}

		.field input,
		.field select {
			background: rgba(15, 23, 42, 0.78);
			color: #f1f5f9;
			border-color: rgba(94, 103, 135, 0.42);
		}

		.field select {
			background-image: url('data:image/svg+xml;utf8,<svg fill="%2394a3b8" height="12" viewBox="0 0 20 20" width="12" xmlns="http://www.w3.org/2000/svg"><path d="M5.516 7.548l4.484 4.57 4.484-4.57 1.414 1.414L10 14.014 4.102 8.962z"/></svg>');
		}

		.field label,
		.field-hint,
		.data-card-header p,
		.data-card thead th {
			color: #94a3b8;
		}

		.data-card tbody td {
			border-bottom-color: rgba(148, 163, 184, 0.24);
		}

		.primary-button:not(:disabled) {
			box-shadow: 0 18px 28px rgba(11, 114, 236, 0.38);
		}
	}

	@media (prefers-reduced-motion: reduce) {
		* {
			transition-duration: 0.01ms !important;
			animation-duration: 0.01ms !important;
		}
	}
</style>
<script language="javascript" type="text/javascript">
  var row_count = 0;
  var barcod = '';
  var stockid = '';
  var spectmainid = '';
  var stockcode = '';
  var serial_no="";
  var amount = '';
  var ekle = 0;
  var cikar = 0;
  var islemtipi = 0;//0-ekle 1-çıkar
  var buton = 0;// <1-buton pasif, >0-buton aktif
</script>
<div style="display:none" name="PagePathPbs">e_pda\form\add_ambar_fis.cfm</div>
<cf_box title="Mal Kabulden Ambara">
	<div class="pda-theme">
		<div class="pda-wrapper">
			<header class="pda-page-header">
				<h2>Mal Kabulden Ambara</h2>
				<p>Barkod veya seri numarası ile ürünlerinizi hızlıca ambara aktarın. Varsayılan depolar otomatik doludur.</p>
			</header>
			<cfform name="form_basket" class="pda-form">
				<cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
				<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
				<input type="hidden" name="kuponlist" value="" />
				<input type="hidden" name="active_period" value="#session.ep.period_id#" />

				<section class="pda-card" aria-label="Mal kabul formu">
					<div class="form-grid">
						<div class="field">
							<label for="add_other_amount">Miktar</label>
							<input id="add_other_amount" name="add_other_amount" type="text" class="moneybox" onfocus="islemtipi=0;" style="text-align:right" value="1" />
							<span class="field-hint">Varsayılan değer 1, gerekirse değiştirin.</span>
						</div>
						<div class="field">
							<label for="add_other_barcod">Barkod</label>
							<input id="add_other_barcod" name="add_other_barcod" type="text" value=""
								   autocomplete="off"
								   autocorrect="off"
								   autocapitalize="off"
								   spellcheck="false"
								   inputmode="text"
								   enterkeyhint="done">
							<span class="field-hint">Barkodu okutup giriş yaptıktan sonra raf seçimine geçin.</span>
						</div>
						<div class="field">
							<label for="serial_number">Seri No</label>
							<input type="text" name="serial_number" id="serial_number"
								   autocomplete="off"
								   autocorrect="off"
								   autocapitalize="off"
								   spellcheck="false"
								   inputmode="text"
								   enterkeyhint="done">
							<span class="field-hint">Seri numarası olan ürünler için kullanın.</span>
						</div>
					</div>

					<div class="form-grid">
						<div class="field">
							<label for="add_other_shelf">Raf</label>
							<input id="add_other_shelf"
								   autocomplete="off"
								   autocorrect="off"
								   autocapitalize="off"
								   spellcheck="false"
								   inputmode="text"
								   enterkeyhint="done"
								   name="add_other_shelf"
								   type="text"
								   class="moneybox"
								   onfocus="islemtipi=0;"
								   value="" />
						</div>
						<div class="field" id="shelf_select_td" style="display:none;">
							<label for="shelf_select">Raf Seçimi</label>
							<select name="shelf_select" id="shelf_select" style="text-align:center">
								<option value="">Ürün Rafları</option>
							</select>
						</div>
					</div>

					<div class="form-grid">
						<div class="field">
							<label for="txt_department_out">Çıkış Depo</label>
							<select name="txt_department_out" id="txt_department_out" onchange="document.getElementById('department_out').value = this.value">
								<cfoutput query="get_all_location" group="department_id">
									<option disabled="disabled" value="#department_id#"<cfif attributes.department_out_id eq department_id> selected</cfif>>#department_head#</option>
									<cfoutput>
										<option <cfif not status>style="color:##FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_out_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#
											<cfif not status>
												-
												<cf_get_lang_main no='82.Pasif'>
											</cfif>
										</option>
									</cfoutput>
								</cfoutput>
							</select>
						</div>
						<div class="field">
							<label for="txt_department_in">Giriş Depo</label>
							<select name="txt_department_in" id="txt_department_in" onchange="document.getElementById('department_in').value = this.value">
								<cfoutput query="get_all_location" group="department_id">
									<option disabled="disabled" value="#department_id#"<cfif attributes.department_in_id eq department_id> selected</cfif>>#department_head#</option>
									<cfoutput>
										<option <cfif not status>style="color:##FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_in_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#
											<cfif not status>
												-
												<cf_get_lang_main no='82.Pasif'>
											</cfif>
										</option>
									</cfoutput>
								</cfoutput>
							</select>
						</div>
						<div class="field field--compact">
							<label for="BarcodeParser">Barkod Parser</label>
							<select name="BarcodeParser" id="BarcodeParser">
								<option value="0">Barkod Parser</option>
							</select>
						</div>
					</div>

					<input id="del_other_amount" name="del_other_amount" type="hidden" onfocus="islemtipi=1;" value="1" />
					<input id="del_other_barcod" name="del_other_barcod" type="hidden" value="" />
				</section>

				<section class="data-card" aria-live="polite">
					<div class="data-card-header">
						<h3>Eklenen Ürünler</h3>
						<p>Okunan barkod ve seri numaraları burada listelenir.</p>
					</div>
					<div class="data-scroll">
						<cf_ajax_list>
							<thead>
								<tr class="color-list" height="20px">
									<th>Seri No</th>
									<th>Ürün</th>
									<th style="display:none">Miktar</th>
									<th>Raf</th>
								</tr>
							</thead>
							<tbody id="table1"></tbody>
						</cf_ajax_list>
					</div>
				</section>

				<input type="hidden" id="department_out" name="department_out" value="" />
				<input type="hidden" id="department_in" name="department_in" value="" />
				<input type="hidden" id="row_count" name="row_count" value="0" />
				<input type="hidden" id="action_id" name="action_id" value="" />

				<div class="form-actions">
					<input id="onay" name="Onay" value="<cf_get_lang_main no="49.Kaydet">" type="button" class="primary-button" disabled="disabled" onClick="kontrol_kayit();" />
				</div>
			</cfform>
		</div>
	</div>
</cf_box>
<div style="display:none" id="loglar"></div>

<!-------------------
<cfabort>
-
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
          <tr class="color-list" height="15px">
            <td align="center" width="45px">Miktar</td>
            <td align="center" width="95px">Barcode</td>
			<td>Seri No</td>
            <td align="center">Raf</td>
            <td></td>
       	  </tr>
          <tr class="color-list" height="20px">
            <td><input id="add_other_amount" name="add_other_amount" type="text" class="moneybox" onfocus="islemtipi=0;" style="width:40px; text-align:right" value="1" /></td>
            <td><input id="add_other_barcod" name="add_other_barcod" type="text" value="" style="width:90px;" ></td>
			<td><input type="text" name="serial_number" id="serial_number"></td>
            <td><input id="add_other_shelf" name="add_other_shelf" type="text" class="moneybox" onfocus="islemtipi=0;" style="width:60px;" value="" /></td>
            <td>
              <table>
              	<tr>
                    <td id="shelf_select_td" style="display:none">
                        <select name="shelf_select" id="shelf_select" style="width:70px;height:20px;text-align:center">
                            <option value="">Ürün Rafları</option>
                        </select>
                    </td>
                  </tr>
                </table>
			</td>
          </tr>
          <input id="del_other_amount" name="del_other_amount" type="hidden"  onfocus="islemtipi=1;" value="1" />
          <input id="del_other_barcod" name="del_other_barcod" type="hidden" value="" >
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
           <tr class="color-list" height="20px">
            <td>
              <select name="txt_department_out"  onchange="document.getElementById('department_out').value = this.value">
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
              <select name="txt_department_in"  onchange="document.getElementById('department_in').value = this.value">
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
      <td width="55" align="center">Barkod</td>
      <td width="55" align="left">Ürün Adı</td>
      <td width="25" align="right">Mikt.</td>
      <td width="50" align="left">Raf</td>
    </tr>
    <tr class="color-list" height="20px">
      <td align="left" colspan="4"><!---  kontrol edilen tablo--->
        <form name="product_row" id="product_row" method="post">
          <table name="table1" id="table1" border="0" cellpadding="0" cellspacing="0" width="100%" class="tablo">
          </table>
        </form>
        <!---  kontrol edilen tablo---></td>
    </tr>
    <tr class="color-list" height="15px">
      <td colspan="6" align="right">
      	<input type="hidden" id="department_in" name="department_in" value="" />
      	<input type="hidden" id="row_count" name="row_count" value="0" />
        <input type="hidden" id="action_id" name="action_id" value="" />
        <input id="onay" name="Onay" value="<cf_get_lang_main no="49.Kaydet">" type="button" disabled="disabled" onClick="kontrol_kayit();" /></td>
    </tr>
  </table>
  </div>
</cfform>------------>
<script language="javascript" type="text/javascript">
var bm=null;
$(document).ready(function(){
$(".header").hide()
 bm=new BarcodeManager();
var parsers=bm.listParsers();
for(var i=0;i<parsers.length;i++){
	$("#BarcodeParser").append('<option value="'+parsers[i].id+'">'+parsers[i].name+'</option>');
}

})

	document.getElementById('add_other_barcod').focus();
	setTimeout("document.getElementById('add_other_barcod').select();",1000);
	
	// Mobil uyumluluk için input event listeners ekle
	document.getElementById('add_other_barcod').addEventListener('keydown', function(e) {
		if (e.keyCode === 13 || e.which === 13) {
			e.preventDefault();
			processBarcode();
		}
	});
	
	// Touch device desteği için blur event ekle
	document.getElementById('add_other_barcod').addEventListener('blur', function(e) {
		var value = this.value.trim();
		if (value.length > 0) {
			setTimeout(function() { processBarcode(); }, 100);
		}
	});
	
	document.onkeydown = checkKeycode
	function checkKeycode(e) 
	{
		console.log('checkKeycode called');
		$("#loglar").append('<p>Key pressed: ' + e.keyCode + '</p>');
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13 )
		{
			processBarcode();
		}
	}
	
	// Mobil uyumlu barcode işleme fonksiyonu
	function processBarcode() {
		console.log('387 - Enter key pressed');
		$("#loglar").append('<p>Enter key pressed</p>');
		var barkod=$("#add_other_barcod").val().trim();
		var raf=$("#add_other_shelf").val().trim();
		var serial=$("#serial_number").val().trim();

		console.table({
			'barkod': barkod,
			'raf': raf,
			'serial': serial
		});

		/**
		 * Undocumented unknown
		 * Eğer Seri No Varsa Seri Nolu Fonksiyonu Çağır 
		 * Eğer Barkod Varsa Barkodlu Fonksiyonu Çağır
		 * 
		 */

		
		if(serial.length>0){
			var SerialObject = bm.parseWith(serial, parseInt(document.getElementById('BarcodeParser').value));
			console.log('Barcode parsed for serial number:', SerialObject);
			if(SerialObject && SerialObject.serial_no){
				serial = SerialObject.serial_no;
			}
			console.log('Serial number detected: ' + serial);
			$("#loglar").append('<p>Serial number detected: ' + serial + '</p>');
			var StockId_=get_stock_with_serial_no(serial);
			if(raf.length > 0){
				console.log('Shelf detected: ' + raf);
				$("#loglar").append('<p>Shelf detected: ' + raf + '</p>');
				//set_shelfs_with_serial_no(serial, stockid);
				search_shelf_with_serial_no(document.getElementById('add_other_shelf').value,StockId_);
			}

		}else if(barkod.length>0){
			console.log('Barcode detected: ' + barkod);
			$("#loglar").append('<p>Barcode detected: ' + barkod + '</p>');
			get_stock_with_barcode(barkod);
		}else{
			console.log('No barcode or serial number detected');
				$("#loglar").append('<p>No barcode or serial number detected</p>');
				alert('Lütfen Barkod veya Seri Numarası Giriniz');
				document.getElementById('add_other_barcod').focus();
				return false;
			}

			/*if (document.getElementById('add_other_barcod').value.length == '' && document.getElementById('add_other_shelf').value.length >0)
			{
				console.log('Shelf input without barcode');
				alert('Önce Ürün Barkodu Okutunuz');
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_shelf').value = '';
				document.getElementById('add_other_amount').value = 1;
				document.getElementById('add_other_barcod').focus();	
			
			}
			else
			{
				console.log('Adding row with barcode: ' + document.getElementById('add_other_barcod').value);
				if (document.getElementById('add_other_barcod').value.length >0 && document.getElementById('add_other_shelf').value.length >0)	
				search_shelf(document.getElementById('add_other_shelf').value);
				else
				get_stock(document.getElementById('add_other_barcod').value);
			}*/
		}
	
	function actionidolustur()
	{
	  var j = 0;
	  for(i=1;i<=row_count;i++)
	  {
		  if(document.getElementById('amount'+i).value > 0)
		  {
			if (j > 0)
			document.getElementById('action_id').value = document.getElementById('action_id').value + ',';
			document.getElementById('action_id').value = document.getElementById('action_id').value + i + '-';
			document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('stockid'+i).value + '-';
			document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('amount'+i).value + '-';
			document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('shelf_code'+i).value 
			j++;
		  }
		  document.getElementById('row_count').value = j;
	  }
	}

	function buton_kontrol()
	{
		if (islemtipi == 0)
			buton++;
		else if (buton>0)
			buton--;
		if (buton < 1)
			document.getElementById('onay').disabled = true;
		else
			document.getElementById('onay').disabled = false;
	}
	function get_stock_with_barcode(barcode)
    {
	 	barcod = ''; stockid = ''; stockcode = ''; spectmainid = ''; 
		serial_no = '';  //ilk önce sıfırlıyoruz
		//ilk önce sıfırlıyoruz
		console.log('get_stock called with barcode: ' + barcode);
		$("#loglar").append('<p>get_stock called with barcode: ' + barcode + '</p>');
	 	k_= 0;
	 	if (k_ == 0)
     	{
			var new_sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER, S.PRODUCT_NAME FROM STOCKS_BARCODES AS SB INNER JOIN              PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '"+barcode+"'";
		 	var get_product = wrk_query(new_sql,'dsn3');
		 	if (get_product.STOCK_ID == undefined)
		 	{
				ekle = 1;
				cikar = 1;
				k_=1;
				alert('Ürün Bulunamadı');
		 	}
		 	else
		 	{	
				stockid = get_product.STOCK_ID;
				stockcode = get_product.PRODUCT_NAME;
				barcode = get_product.BARCODE;
				document.getElementById('add_other_shelf').focus();
				set_shelfs(stockid);
				buton_kontrol();
    		}
		}
		else
		{
			barcod = ''; stockid = ''; stockcode = ''; spectmainid = '';
			return false;
		}
	}
	function get_stock_with_serial_no(serialno)
    {
	 	barcod = ''; stockid = ''; stockcode = ''; spectmainid = ''; 
		serial_no=""; //ilk önce sıfırlıyoruz
		console.log('get_stock_with_serial_no called with serialno: ' + serialno);
		$("#loglar").append('<p>get_stock_with_serial_no called with serialno: ' + serialno + '</p>');
	 	k_= 0;
	 	if (k_ == 0)
     	{
			//var new_sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER, S.PRODUCT_NAME FROM STOCKS_BARCODES AS SB INNER JOIN              PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '"+barcode+"'";
			var new_sql=`SELECT TOP 1 SB.STOCK_ID
	,SB.SERIAL_NO
	,PU.MAIN_UNIT
	,PU.MULTIPLIER
	,S.PRODUCT_NAME
	,'' AS BARCODE
FROM w3qa_1.SERVICE_GUARANTY_NEW AS SB
INNER JOIN w3qa_1.STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID
INNER JOIN w3qa_1.PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
WHERE SB.SERIAL_NO = '${serialno}'`;
		 	
		 	console.log('Executing SQL: ' + new_sql);
			$("#loglar").append('<p>Executing SQL: ' + new_sql + '</p>');
		 	
		 	// Execute the query	
			var get_product = wrk_query(new_sql,'dsn3');
		 	if (get_product.STOCK_ID == undefined)
		 	{
				ekle = 1;
				cikar = 1;
				k_=1;
				alert('Ürün Bulunamadı');
		 	}
		 	else
		 	{	
				
				stockid = get_product.STOCK_ID[0];
				stockcode = get_product.PRODUCT_NAME[0];
				barcode = get_product.BARCODE[0];
				document.getElementById('add_other_shelf').focus();
				set_shelfs_with_serial_no(serialno,stockid);
				buton_kontrol();
    		}
		}
		else
		{
			barcod = ''; stockid = ''; stockcode = ''; spectmainid = '';
			return false;
		}
		return stockid;
	}



	function add_amount()
	{
		ekle=0;
		return;
	  document.getElementById('shelf_select_td').style.display='none';
	  if(row_count >0) /*ilk Satırdan sonrası*/
	  {
		  for(i=1;i<=row_count;i++)
		  {
			  if(document.getElementById('stockid'+i).value == stockid)
			  {
				  var stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL WHERE  DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID ="+stockid;
				  var get_real_stock = wrk_query(stock_sql,'dsn2');
				  if(get_real_stock.PRODUCT_STOCK == undefined)
				  	get_real_stock.PRODUCT_STOCK = 0;
				  if(get_real_stock.PRODUCT_STOCK < document.getElementById('amount'+i).value - (-1 * amount))
				  {
					ekle=0;
					alert("Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı : "+get_real_stock.PRODUCT_STOCK);
					document.getElementById('add_other_amount').focus();
				  }
				  else
				  {
					  if(document.getElementById('stockid'+i).value == stockid && document.getElementById('shelf_code'+i).value == shelf_code)
					  {
						document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
						if (document.getElementById('frm_row'+i).style.display == 'none')
							document.getElementById('frm_row'+i).style.display='block';
						ekle=0;
					  }
				  }
			  }
		   }
	   }
	   else
	   {
		   
		    var stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL WHERE  DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID ="+stockid;
			var get_real_stock = wrk_query(stock_sql,'dsn2');
			if(get_real_stock.PRODUCT_STOCK == undefined)
				get_real_stock.PRODUCT_STOCK = 0;
			if(get_real_stock.PRODUCT_STOCK < (amount*1))
			{
				ekle=1;
				alert("Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı : "+get_real_stock.PRODUCT_STOCK);
				document.getElementById('add_other_amount').focus();
			}
	   }
	}
	
	function add_row(barcode)
	{
		console.log('add_row called with barcode: ' + barcode);
		{
			  amount = document.getElementById('add_other_amount').value;
			  if(amount == 0)
			  {
				alert('Miktar 0 dan Büyük Olmalıdır.');
				document.getElementById('shelf_select_td').style.display='none';
				return false;
			  }
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
				newCell.innerHTML = '<input type="hidden" value="'+stockid+'" name="stockid'+row_count+'" id="stockid'+row_count+'" /><input type="hidden" value="'+spectmainid+'" name="spectmainid'+row_count+'" id="spectmainid'+row_count+'" /><input type="hidden" value="'+barcode+'" name="barcod'+row_count+'" id="barcod'+row_count+'" size="13" class="boxtext" readonly="yes" /><input type="hidden" value="'+barcode+'" name="serino'+row_count+'" id="serino'+row_count+'" size="13" class="boxtext" readonly="yes" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" value="'+stockcode+'" name="stockcode'+row_count+'" id="stockcode'+row_count+'" size="10" class="boxtext" readonly="yes" />';
				newCell = newRow.insertCell();
				newCell.style.display = 'none';
				newCell.innerHTML = '<input type="text" style="text-align:right" value="'+amount+'" name="amount'+row_count+'" id="amount'+row_count+'" size="5" class="boxtext" readonly="yes"  style="text-align:" />';
				
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" value="'+shelf_code+'" name="shelf_code'+row_count+'" id="shelf_code'+row_count+'" size="12" class="boxtext" readonly="yes" style="text-align:right" />';
			  }
			  else
			  {
				 ekle = 0;
			  }
		}
	}
	function add_row_with_serial_no(serialc_)
	{
		console.log('add_row_with_serial_no called with serial: ' + serialc_);
		var serialObj=bm.parseWith(serialc_,parseInt(document.getElementById('BarcodeParser').value));
		if(serialObj && serialObj.serial_no){
			serialc_=serialObj.serial_no;
		}
		{
			  amount = document.getElementById('add_other_amount').value;
			  if(amount == 0)
			  {
				alert('Miktar 0 dan Büyük Olmalıdır.');
				document.getElementById('shelf_select_td').style.display='none';
				return false;
			  }
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
				newCell.innerHTML = '<input type="hidden" value="'+stockid+'" name="stockid'+row_count+'" id="stockid'+row_count+'" /><input type="hidden" value="'+spectmainid+'" name="spectmainid'+row_count+'" id="spectmainid'+row_count+'" /><input type="hidden" value="'+barcode+'" name="barcod'+row_count+'" id="barcod'+row_count+'" size="13" class="boxtext" readonly="yes" /><input type="text" value="'+serialc_+'" name="serino'+row_count+'" id="serino'+row_count+'" size="13" class="boxtext" readonly="yes" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" value="'+stockcode+'" name="stockcode'+row_count+'" id="stockcode'+row_count+'" size="10" class="boxtext" readonly="yes" />';
				newCell = newRow.insertCell();
				newCell.style.display = 'none';
				newCell.innerHTML = '<input type="text" style="text-align:right" value="'+amount+'" name="amount'+row_count+'" id="amount'+row_count+'" size="5" class="boxtext" readonly="yes"  style="text-align:" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" value="'+shelf_code+'" name="shelf_code'+row_count+'" id="shelf_code'+row_count+'" size="12" class="boxtext" readonly="yes" style="text-align:right" />';
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
	function search_shelf(shelf_8)
	{
		var giris_depo = document.all.txt_department_in.value;
		var shelf_sql = "SELECT PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE = '"+shelf_8+"'";
		var get_shelf = wrk_query(shelf_sql,'dsn3');
		if(get_shelf.recordcount)
		{
			var giris_depo_s = get_shelf.STORE_ID.toString()+'-'+get_shelf.LOCATION_ID.toString();
			console.log('Giriş depo: ' + giris_depo + ', Giriş depo SQL: ' + giris_depo_s);
			$("#loglar").append('<p>Giriş depo: ' + giris_depo + ', Giriş depo SQL: ' + giris_depo_s + '</p>');
			if(giris_depo != giris_depo_s)
			{
					alert('Seçtiğiniz Raf Giriş Lokasyonunda Yoktur.!');	
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_shelf').value = '';
					document.getElementById('add_other_barcod').focus();	
			}
			else
			{
				if (document.getElementById('add_other_barcod').value.length > 0)
				{
					var new_sql = "SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, PP.SHELF_CODE FROM STOCKS_BARCODES AS SB INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID INNER JOIN PRODUCT_PLACE_ROWS AS PPR ON S.PRODUCT_ID = PPR.PRODUCT_ID INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID WHERE SB.BARCODE = '"+document.getElementById('add_other_barcod').value+"' AND PP.SHELF_CODE ='"+document.getElementById('add_other_shelf').value+"'";
		 			var get_product = wrk_query(new_sql,'dsn3');
					if (get_product.STOCK_ID == undefined)
					{
						alert('Ürün Bu Rafa Tanıtılmamış');
						document.getElementById('add_other_shelf').value = '';
						document.getElementById('add_other_shelf').focus();
					}
					else
					{	
						stockid = get_product.STOCK_ID[0];
						stockcode = get_product.PRODUCT_NAME[0];
						barcode = get_product.BARCODE[0];
						shelf_code = get_product.SHELF_CODE[0]; 
						buton_kontrol();
						add_row(barcode);
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_shelf').value = '';
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
						document.getElementById('add_other_shelf').value = '';
						document.getElementById('add_other_barcod').focus();
				}
			}
		}
		else
		{
			alert('Seçtiğiniz Raf Hiç Tanımlanmamış!');
			document.getElementById('add_other_shelf').value = '';
			document.getElementById('add_other_shelf').focus();
		}
	}
	function search_shelf_with_serial_no(shelf_8,sid)
	{
		var giris_depo = document.all.txt_department_in.value;
		var shelf_sql = "SELECT PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE = '"+shelf_8+"'";
		var get_shelf = wrk_query(shelf_sql,'dsn3');
		if(get_shelf.recordcount)
		{
			var giris_depo_s = get_shelf.STORE_ID.toString()+'-'+get_shelf.LOCATION_ID.toString();
			console.log('Giriş depo: ' + giris_depo + ', Giriş depo SQL: ' + giris_depo_s);
			$("#loglar").append('<p>Giriş depo: ' + giris_depo + ', Giriş depo SQL: ' + giris_depo_s + '</p>');
			if(giris_depo != giris_depo_s)
			{
					alert('Seçtiğiniz Raf Giriş Lokasyonunda Yoktur.!');	
					document.getElementById('serial_number').value = '';
					document.getElementById('add_other_shelf').value = '';
					document.getElementById('serial_number').focus();	
			}
			else
			{
				if (document.getElementById('serial_number').value.length > 0)
				{
					var new_sql = "SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, PP.SHELF_CODE FROM STOCKS_BARCODES AS SB INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID INNER JOIN PRODUCT_PLACE_ROWS AS PPR ON S.PRODUCT_ID = PPR.PRODUCT_ID INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID WHERE SB.STOCK_ID = '"+sid+"' AND PP.SHELF_CODE ='"+document.getElementById('add_other_shelf').value+"'";
		 			var get_product = wrk_query(new_sql,'dsn3');
					if (get_product.STOCK_ID == undefined)
					{
						alert('Ürün Bu Rafa Tanıtılmamış');
						document.getElementById('add_other_shelf').value = '';
						document.getElementById('add_other_shelf').focus();
					}
					else
					{	
						stockid = get_product.STOCK_ID[0];
						stockcode = get_product.PRODUCT_NAME[0];
						barcode = get_product.BARCODE[0];
						shelf_code = get_product.SHELF_CODE[0];
						serial_no = document.getElementById('serial_number').value;
						buton_kontrol();
						add_row_with_serial_no(serial_no);
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_shelf').value = '';
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
						document.getElementById('add_other_shelf').value = '';
						document.getElementById('add_other_barcod').focus();
				}
			}
		}
		else
		{
			alert('Seçtiğiniz Raf Hiç Tanımlanmamış!');
			document.getElementById('add_other_shelf').value = '';
			document.getElementById('add_other_shelf').focus();
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

			var depo_stock_sql = "SELECT ISNULL(PRODUCT_STOCK,0) AS PRODUCT_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL WHERE  DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID ="+xyz;
			var depo_stock = wrk_query(depo_stock_sql,'dsn2');
			if(depo_stock.PRODUCT_STOCK == undefined)
			depo_stock.PRODUCT_STOCK = 0;
			document.getElementById('add_other_amount').value = depo_stock.PRODUCT_STOCK;
		}
		else
			document.getElementById('shelf_select').options[0] = new Option('Raf Tanımsız','');
	}
		
	function set_shelfs_with_serial_no(serial_no,xyz)
	{
		document.getElementById('shelf_select_td').style.display='';
		//var product_shelfs = wrk_query("SELECT PP.SHELF_CODE, PPR.AMOUNT, PP.PRODUCT_PLACE_ID, ISNULL((SELECT REAL_STOCK FROM GET_STOCK_LAST_SHELF WHERE SHELF_NUMBER = PP.PRODUCT_PLACE_ID AND STOCK_ID = PPR.STOCK_ID),0) AS REAL_STOCK FROM <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS PP LEFT OUTER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE_ROWS AS PPR ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID WHERE PPR.STOCK_ID = "+xyz+" N ORDER BY REAL_STOCK DESC","dsn2");
		//SELECT * FROM w3Qa_2025_1.PBS_SHELF_STOCK_AMOUNTS WHERE STOCK_ID=1114 AND DEPO='2-1' ORDER BY REAL_STOCK DESC
		var product_shelfs=wrk_query(`SELECT * FROM w3Qa_2025_1.PBS_SHELF_STOCK_AMOUNTS WHERE STOCK_ID=${xyz} AND DEPO='${form_basket.txt_department_in.value}' ORDER BY REAL_STOCK DESC`)
		var option_count = document.getElementById('shelf_select').options.length; 
		for(x=option_count;x>=0;x--)
			document.getElementById('shelf_select').options[x] = null;
		if(product_shelfs.recordcount != 0)
		{	
			for(var xx=0;xx<product_shelfs.recordcount;xx++)
			{
				document.getElementById('shelf_select').options[xx]=new Option(product_shelfs.SHELF_CODE[xx]+"-"+product_shelfs.REAL_STOCK[xx],product_shelfs.PRODUCT_PLACE_ID[xx],product_shelfs.AMOUNT[xx]);
			}

			//var depo_stock_sql = "SELECT ISNULL(PRODUCT_STOCK,0) AS PRODUCT_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL WHERE  DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID ="+xyz;
			var depo_stock_sql = `SELECT *FROM w3Qa_1.PBS_SERIAL_LAST_STOCK WHERE 1=1 AND DEPO='${form_basket.txt_department_out.value}' AND SERIAL_NO='${serial_no}'`;
			var depo_stock = wrk_query(depo_stock_sql,'dsn2');
			if(depo_stock.PRODUCT_STOCK == undefined)
			depo_stock.PRODUCT_STOCK = 0;
			document.getElementById('add_other_amount').value = depo_stock.PRODUCT_STOCK;
		}
		else
			document.getElementById('shelf_select').options[0] = new Option('Raf Tanımsız','');
	}

	function kontrol_kayit()
	{
		$("#loglar").append('<p>kontrol_kayit called</p>');
			if(form_basket.txt_department_in.value == "")
			{
				alert('Depo Seçmelisiniz.');
				return false;
			}
			else if(form_basket.txt_department_in.value.indexOf('-') == -1)
			{
				alert('Lütfen giriş için doğru depo seçiniz.');
				return false;
			}
			else
			{
			document.getElementById('onay').disabled = true;
			actionidolustur();
			document.form_basket.action='<cfoutput>#request.self#</cfoutput>?fuseaction=pda.add_ambar_fis&dep_in='+form_basket.txt_department_in.value+'&dep_out='+form_basket.txt_department_out.value+'&action_id='+document.getElementById('action_id').value+'&fis_tipi='+form_basket.fis_tipi.value+'&process_cat='+form_basket.process_cat_id.value;
			document.form_basket.submit();
			//console.log('<cfoutput>#request.self#</cfoutput>?fuseaction=pda.add_ambar_fis&dep_in='+form_basket.txt_department_in.value+'&dep_out='+form_basket.txt_department_out.value+'&action_id='+document.getElementById('action_id').value+'&fis_tipi='+form_basket.fis_tipi.value+'&process_cat='+form_basket.process_cat_id.value);

			//window.location.href='<cfoutput>#request.self#</cfoutput>?fuseaction=pda.add_ambar_fis&dep_in='+form_basket.txt_department_in.value+'&dep_out='+form_basket.txt_department_out.value+'&action_id='+document.getElementById('action_id').value+'&fis_tipi='+form_basket.fis_tipi.value+'&process_cat='+form_basket.process_cat_id.value;
			}
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