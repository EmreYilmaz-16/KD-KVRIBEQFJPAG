<cfparam name="form.palet_type" default="">
<cfparam name="form.maximum_weight" default="">

<cfset successMessage = "">
<cfset errorMessages = []>

<cfif StructKeyExists(form, "submitPalletType")>
	<cfset paletType = Trim(form.palet_type)>
	<cfset maximumWeightRaw = Trim(form.maximum_weight)>
	<cfset maximumWeightNormalized = Replace(maximumWeightRaw, ",", ".", "all")>

	<cfif NOT Len(paletType)>
		<cfset ArrayAppend(errorMessages, "Palet tipi alani bos birakilamaz.")>
	<cfelseif Len(paletType) GT 50>
		<cfset ArrayAppend(errorMessages, "Palet tipi en fazla 50 karakter olabilir.")>
	</cfif>

	<cfif NOT Len(maximumWeightRaw)>
		<cfset ArrayAppend(errorMessages, "Maksimum agirlik alani bos birakilamaz.")>
	<cfelseif NOT IsNumeric(maximumWeightNormalized)>
		<cfset ArrayAppend(errorMessages, "Maksimum agirlik sayisal bir deger olmalidir.")>
	<cfelse>
		<cfset maximumWeightValue = Val(maximumWeightNormalized)>
		<cfif maximumWeightValue LTE 0>
			<cfset ArrayAppend(errorMessages, "Maksimum agirlik sifirdan buyuk olmalidir.")>
		</cfif>
	</cfif>

	<cfif ArrayIsEmpty(errorMessages)>
		<cftry>
			<cfquery name="checkDuplicate" datasource="#dsn3#">
				SELECT TOP 1 1
				FROM w3Qa.PALET_TYPES_PBS
				WHERE UPPER(PALET_TYPE) = <cfqueryparam value="#UCase(paletType)#" cfsqltype="cf_sql_varchar" maxlength="50">
			</cfquery>

			<cfif checkDuplicate.RecordCount GT 0>
				<cfset ArrayAppend(errorMessages, "Bu palet tipi zaten kayitli gorunuyor.")>
			<cfelse>
				<cfquery name="insertPalletType" datasource="#dsn3#">
					INSERT INTO w3Qa.PALET_TYPES_PBS (PALET_TYPE, MAXIMUM_WEIGHT)
					VALUES (
						<cfqueryparam value="#paletType#" cfsqltype="cf_sql_nvarchar" maxlength="50">,
						<cfqueryparam value="#maximumWeightValue#" cfsqltype="cf_sql_float">
					)
				</cfquery>

				<cfset successMessage = "Palet tipi basariyla kaydedildi.">
				<cfset form.palet_type = "">
				<cfset form.maximum_weight = "">
			</cfif>

			<cfcatch type="any">
				<cfset ArrayAppend(errorMessages, "Kayit sirasinda bir hata olustu: " & cfcatch.message)>
			</cfcatch>
		</cftry>
	</cfif>
</cfif>

<cf_box title="Yeni Palet Tipi Ekle">
	<style>
		.pallet-form-wrap {
			font-family: "Segoe UI", Tahoma, Arial, sans-serif;
			color: #1f2933;
			background: linear-gradient(135deg, #f8fafc, #eef2f7);
			border-radius: 14px;
			padding: 26px;
			box-shadow: 0 14px 34px rgba(15, 23, 42, 0.08);
			border: 1px solid #d8e2ef;
			max-width: 520px;
			margin: 0 auto;
		}

		.pallet-form-header {
			margin-bottom: 20px;
			display: flex;
			flex-direction: column;
			gap: 4px;
		}

		.pallet-form-header h2 {
			font-size: 22px;
			margin: 0;
			font-weight: 600;
			letter-spacing: 0.02em;
		}

		.pallet-form-header p {
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
		}

		.pallet-field {
			display: flex;
			flex-direction: column;
			gap: 6px;
		}

		.pallet-field label {
			font-size: 13px;
			font-weight: 600;
			color: #334155;
		}

		.pallet-input {
			border: 1px solid #cbd5f5;
			border-radius: 10px;
			padding: 12px 14px;
			font-size: 14px;
			background: #ffffff;
			transition: border 0.2s ease, box-shadow 0.2s ease;
		}

		.pallet-input:focus {
			border-color: #6366f1;
			box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.18);
			outline: none;
		}

		.pallet-hint {
			font-size: 12px;
			color: #64748b;
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

		@media (max-width: 480px) {
			.pallet-form-wrap {
				padding: 20px;
			}

			.pallet-actions {
				flex-direction: column;
				align-items: stretch;
			}
		}
	</style>

	<cfoutput>
		<div class="pallet-form-wrap">
			<div class="pallet-form-header">
				<h2>Palet Tipi Tanimla</h2>
				<p>Lutfen palet tipi adini ve maksimum tasiyabilecegi agirligi girin.</p>
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

			<form method="post">
				<div class="pallet-form-grid">
					<div class="pallet-field">
						<label for="palet_type">Palet Tipi</label>
						<input
							type="text"
							id="palet_type"
							name="palet_type"
							class="pallet-input"
							maxlength="50"
							value="#HTMLEditFormat(form.palet_type)#"
							required
						>
						<span class="pallet-hint">Ornek: EUR, US, Ozel, vb.</span>
					</div>

					<div class="pallet-field">
						<label for="maximum_weight">Maksimum Agirlik (kg)</label>
						<input
							type="text"
							id="maximum_weight"
							name="maximum_weight"
							class="pallet-input"
							value="#HTMLEditFormat(form.maximum_weight)#"
							required
							inputmode="decimal"
						>
						<span class="pallet-hint">Ondalik icin nokta veya virgul kullanabilirsiniz.</span>
					</div>
				</div>

				<div class="pallet-actions">
					<button type="reset" class="pallet-button secondary">Temizle</button>
					<button type="submit" name="submitPalletType" value="1" class="pallet-button primary">Kaydet</button>
				</div>
			</form>
		</div>
	</cfoutput>
</cf_box>
