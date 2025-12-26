<cfparam name="form.pallet_code" default="">
<cfparam name="form.pallet_type" default="">

<cfscript>
function generatePalletCode() {
	var currentStamp = Now();
	var randomNumber = RandRange(0, 99999, "SHA1PRNG");
	var randomPart = Right("00000" & randomNumber, 5);
	return "PLT"
		& DateFormat(currentStamp, "dd")
		& DateFormat(currentStamp, "mm")
		& DateFormat(currentStamp, "yyyy")
		& TimeFormat(currentStamp, "HH")
		& TimeFormat(currentStamp, "mm")
		& randomPart;
}
</cfscript>

<cfset successMessage = "">
<cfset errorMessages = []>

<cfset recordEmp = 0>
<cfif StructKeyExists(session, "ep") AND StructKeyExists(session.ep, "userid")>
	<cfset recordEmp = Val(session.ep.userid)>
</cfif>

<cfset recordDate = Now()>

<cfquery name="getPalletTypes" datasource="#dsn3#">
	SELECT ID, PALET_TYPE,IS_WEIGHT_STANDART 
	FROM #dsn#.PALET_TYPES_PBS
	ORDER BY PALET_TYPE
</cfquery>

<cfif NOT StructKeyExists(form, "submitNewPallet") OR NOT Len(Trim(form.pallet_code))>
	<cfset form.pallet_code = generatePalletCode()>
</cfif>

<cfif StructKeyExists(form, "submitNewPallet")>
	<cfset palletCode = Trim(form.pallet_code)>
	<cfset palletType = Trim(form.pallet_type)>
	<cfset company_id = form.company_id>
	<cfset selectedTypeExists = false>

	<cfif NOT Len(palletCode)>
		<cfset ArrayAppend(errorMessages, "Pallet kodu bos birakilamaz.")>
	<cfelseif Len(palletCode) GT 50>
		<cfset ArrayAppend(errorMessages, "Pallet kodu en fazla 50 karakter olabilir.")>
	</cfif>

	<cfif NOT Len(palletType)>
		<cfset ArrayAppend(errorMessages, "Pallet tipi secilmelidir.")>
	<cfelseif NOT IsNumeric(palletType)>
		<cfset ArrayAppend(errorMessages, "Pallet tipi icin gecerli bir kayit secin.")>
	<cfelse>
		<cfif getPalletTypes.RecordCount GT 0>
			<cfloop query="getPalletTypes">
				<cfif ID EQ Val(palletType)>
					<cfset selectedTypeExists = true>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>

		<cfif NOT selectedTypeExists>
			<cfset ArrayAppend(errorMessages, "Secilen pallet tipi bulunamadi.")>
		</cfif>
	</cfif>

	<cfif ArrayIsEmpty(errorMessages)>
		<cftry>
			<cfquery name="checkDuplicate" datasource="#dsn3#">
				SELECT TOP 1 1
				FROM #dsn3#.SHIPPING_PALLETS_PBS
				WHERE UPPER(PALLET_CODE) = <cfqueryparam value="#UCase(palletCode)#" cfsqltype="cf_sql_nvarchar" maxlength="50">
			</cfquery>

			<cfif checkDuplicate.RecordCount GT 0>
				<cfset form.pallet_code = generatePalletCode()>
				<cfset ArrayAppend(errorMessages, "Bu pallet kodu zaten kayitli gorunuyor. Sistem yeni bir kod olusturdu, lutfen tekrar deneyin.")>
			<cfelse>
				<cfquery name="insertNewPallet" datasource="#dsn3#">
					INSERT INTO #dsn3#.SHIPPING_PALLETS_PBS
						(PALLET_CODE, PALLET_TYPE, RECORD_DATE, RECORD_EMP,COMPANY_ID)
					VALUES
						(
							<cfqueryparam value="#palletCode#" cfsqltype="cf_sql_nvarchar" maxlength="50">,
							<cfqueryparam value="#Val(palletType)#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#recordDate#" cfsqltype="cf_sql_timestamp">,
							<cfqueryparam value="#recordEmp#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#company_id#" cfsqltype="cf_sql_integer">
						)
				</cfquery>

				<cfset successMessage = "Pallet kaydi basariyla olusturuldu.">
				<cfset form.pallet_code = generatePalletCode()>
				<cfset form.pallet_type = "">
			</cfif>
<script>
	window.location.href="/index.cfm?fuseaction=eshipping.emptypopup_list_shipping_pallets_pbs"
</script>
			<cfcatch type="any">
				<cfset ArrayAppend(errorMessages, "Kayit sirasinda bir hata olustu: " & cfcatch.message)>
			</cfcatch>
		</cftry>
	</cfif>
</cfif>

<cf_box title="Yeni Pallet Kaydi">
	<style>
		.pallet-entry-wrap {
			font-family: "Segoe UI", Tahoma, Arial, sans-serif;
			color: #1f2933;
			background: linear-gradient(135deg, #f8fafc, #eef2f7);
			border-radius: 16px;
			padding: 28px;
			border: 1px solid #d8e2ef;
			box-shadow: 0 14px 34px rgba(15, 23, 42, 0.08);
			max-width: 560px;
			margin: 0 auto;
		}

		.pallet-entry-header {
			display: flex;
			flex-direction: column;
			gap: 6px;
			margin-bottom: 20px;
		}

		.pallet-entry-header h2 {
			margin: 0;
			font-size: 22px;
			font-weight: 600;
			letter-spacing: 0.02em;
		}

		.pallet-entry-header p {
			margin: 0;
			font-size: 13px;
			color: #4b5563;
		}

		.pallet-alert {
			border-radius: 10px;
			padding: 12px 16px;
			margin-bottom: 18px;
			font-size: 13px;
			line-height: 1.5;
		}

		.pallet-alert.success {
			background: #dcfce7;
			border: 1px solid #86efac;
			color: #166534;
		}

		.pallet-alert.error {
			background: #fee2e2;
			border: 1px solid #fca5a5;
			color: #b91c1c;
		}

		.pallet-alert ul {
			margin: 0;
			padding-left: 18px;
		}

		.pallet-form-grid {
			display: grid;
			gap: 18px;
			grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
		}

		.pallet-field {
			display: flex;
			flex-direction: column;
			gap: 6px;
		}

		.pallet-field-full {
			grid-column: 1 / -1;
		}

		.pallet-field label {
			font-size: 13px;
			font-weight: 600;
			color: #334155;
		}

		.pallet-input,
		.pallet-select {
			border: 1px solid #cbd5f5;
			border-radius: 10px;
			padding: 12px 14px;
			font-size: 14px;
			background: #ffffff;
			transition: border 0.2s ease, box-shadow 0.2s ease;
		}

		.pallet-select {
			-webkit-appearance: none;
			-moz-appearance: none;
			appearance: none;
		}

		.pallet-input:focus,
		.pallet-select:focus {
			border-color: #6366f1;
			box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.18);
			outline: none;
		}

		.pallet-hint {
			font-size: 12px;
			color: #64748b;
		}

		.pallet-input-group {
			display: flex;
			align-items: stretch;
			border: 1px solid #cbd5f5;
			border-radius: 10px;
			overflow: hidden;
			background: #ffffff;
		}

		.pallet-input-group .pallet-input {
			border: none;
			border-radius: 0;
			flex: 1 1 auto;
			padding: 12px 14px;
		}

		.pallet-input-group .pallet-input:focus {
			box-shadow: none;
		}

		.pallet-input-group button {
			border: none;
			background: #1d4ed8;
			color: #ffffff;
			padding: 0 16px;
			font-size: 13px;
			font-weight: 600;
			cursor: pointer;
			transition: background 0.2s ease;
		}

		.pallet-input-group button:hover {
			background: #1e40af;
		}

		.pallet-autocomplete {
			position: relative;
			z-index: 10;
		}

		.pallet-actions {
			display: flex;
			justify-content: flex-end;
			gap: 10px;
			margin-top: 6px;
		}

		.pallet-button {
			border-radius: 10px;
			border: none;
			padding: 12px 20px;
			font-size: 14px;
			font-weight: 600;
			letter-spacing: 0.04em;
			cursor: pointer;
			transition: transform 0.2s ease, box-shadow 0.2s ease;
		}

		.pallet-button.primary {
			background: linear-gradient(135deg, #4f46e5, #1d4ed8);
			color: #ffffff;
			box-shadow: 0 10px 20px rgba(59, 130, 246, 0.25);
		}

		.pallet-button.primary:hover {
			transform: translateY(-2px);
			box-shadow: 0 12px 24px rgba(37, 99, 235, 0.3);
		}

		.pallet-button.secondary {
			background: #f1f5f9;
			color: #475569;
			border: 1px solid #cbd5e1;
		}

		.pallet-button.secondary:hover {
			transform: translateY(-2px);
			box-shadow: 0 12px 24px rgba(148, 163, 184, 0.2);
		}

		.pallet-meta {
			font-size: 12px;
			color: #475569;
		}

		@media (max-width: 520px) {
			.pallet-entry-wrap {
				padding: 22px;
			}

			.pallet-actions {
				flex-direction: column;
				align-items: stretch;
			}
		}
	</style>

	<cfoutput>
		<div class="pallet-entry-wrap">
			<div class="pallet-entry-header">
				<h2>Yeni Pallet Kaydi</h2>
				<p>Pallet kodunu ve bagli oldugu pallet tipini secerek kaydi tamamlayin.</p>
				<div class="pallet-meta">Kaydi olusturan kullanici ID: #recordEmp#</div>
			</div>

			<cfif Len(successMessage)>
				<div class="pallet-alert success">#successMessage#</div>
			</cfif>

			<cfif NOT ArrayIsEmpty(errorMessages)>
				<div class="pallet-alert error">
					<ul>
						<cfloop array="#errorMessages#" index="msg">
							<li>#msg#</li>
						</cfloop>
					</ul>
				</div>
			</cfif>

			<form method="post" name="order_form" id="order_form">
				<div class="pallet-form-grid">
					<div class="pallet-field">
						<label for="pallet_code">Pallet Kodu</label>
						<input
							type="text"
							id="pallet_code"
							name="pallet_code"
							class="pallet-input"
							maxlength="50"
							value="#HTMLEditFormat(form.pallet_code)#"
							required
							readonly
						>
						<span class="pallet-hint">Kod otomatik olusturulur (PLT + gun + ay + yil + saat + dakika + 5 haneli random).</span>
					</div>

					<div class="pallet-field">
						<label for="pallet_type">Pallet Tipi</label>
						<select
							id="pallet_type"
							name="pallet_type"
							class="pallet-select"
							required
						>
							<option value="">Pallet tipi seciniz</option>
							<cfloop query="getPalletTypes">
								<option data-IS_WEIGHT_STANDART="#IS_WEIGHT_STANDART#" value="#ID#" <cfif form.pallet_type EQ ToString(ID)>selected</cfif>>#HTMLEditFormat(PALET_TYPE)#</option>
							</cfloop>
						</select>
						<span class="pallet-hint">Pallet tipi listesi #dsn#.PALET_TYPES_PBS tablosundan yuklenir.</span>
					</div>

					<div class="pallet-field pallet-field-full">
						<label for="member_name">Cari Hesap</label>
						<input type="hidden" name="consumer_id" id="consumer_id" value="">
						<input type="hidden" name="company_id" id="company_id" value="">
						<input type="hidden" name="member_type" id="member_type" value="">
						<div class="pallet-input-group">
							<input
								type="text"
								name="member_name"
								id="member_name"
								class="pallet-input"
								placeholder="Cari hesap ara"
								autocomplete="off"
								onfocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','get_member_autocomplete','\'1,2\'','CONSUMER_ID,COMPANY_ID,MEMBER_TYPE','consumer_id,company_id,member_type','','3','250');"
							>
							<button
								type="button"
								onclick="openBoxDraggable('index.cfm?fuseaction=objects.popup_list_all_pars&field_consumer=order_form.consumer_id&field_comp_id=order_form.company_id&field_member_name=order_form.member_name&field_type=order_form.member_type&select_list=7,8&keyword='+encodeURIComponent(document.order_form.member_name.value));"
							>
								Sec
							</button>
						</div>
						<div id="member_name_div_2" name="member_name_div_2" class="pallet-autocomplete completeListbox" style="display:none;"></div>
						<span class="pallet-hint">Cari hesap secmek icin yazmaya baslayin veya Sec butonunu kullanin.</span>
					</div>
				</div>

				<div class="pallet-actions">
					<button type="reset" class="pallet-button secondary">Temizle</button>
					<button type="submit" name="submitNewPallet" value="1" class="pallet-button primary" <cfif getPalletTypes.RecordCount EQ 0>disabled</cfif>>Kaydet</button>
				</div>
			</form>

			<cfif getPalletTypes.RecordCount EQ 0>
				<div class="pallet-alert error" style="margin-top:18px;">
					Sistem uyarisi: Kaydedilmis pallet tipi bulunamadigi icin yeni pallet eklenemez. Once bir pallet tipi olusturun.
				</div>
			</cfif>
		</div>
	</cfoutput>
</cf_box>
