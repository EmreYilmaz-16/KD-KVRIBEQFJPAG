<cfparam name="url.search" default="">
<cfparam name="url.type" default="">

<cfset searchTerm = Trim(url.search)>
<cfset selectedType = Trim(url.type)>

<cfquery name="getPalletTypes" datasource="#dsn3#">
	SELECT ID, PALET_TYPE
	FROM w3Qa.PALET_TYPES_PBS
	ORDER BY PALET_TYPE
</cfquery>

<cfquery name="getPallets" datasource="#dsn3#">
	SELECT
		P.ID,
		P.PALLET_CODE,
		P.PALLET_TYPE,
		P.RECORD_DATE,
		P.RECORD_EMP,
		T.PALET_TYPE AS PALLET_TYPE_NAME
	FROM w3Qa_1.SHIPPING_PALLETS_PBS P
	LEFT JOIN w3Qa.PALET_TYPES_PBS T ON T.ID = P.PALLET_TYPE
	WHERE 1 = 1
	<cfif Len(searchTerm)>
		AND (
			P.PALLET_CODE LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_nvarchar" maxlength="50">
			OR T.PALET_TYPE LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_nvarchar" maxlength="50">
		)
	</cfif>
	<cfif Len(selectedType) AND IsNumeric(selectedType)>
		AND P.PALLET_TYPE = <cfqueryparam value="#Val(selectedType)#" cfsqltype="cf_sql_integer">
	</cfif>
	ORDER BY P.RECORD_DATE DESC
</cfquery>

<cf_box title="Pallet Kayitlari">
	<style>
		.pallets-wrap {
			font-family: "Segoe UI", Tahoma, Arial, sans-serif;
			color: #1f2933;
			background: linear-gradient(135deg, #f8fafc, #eef2f7);
			border-radius: 16px;
			padding: 26px;
			border: 1px solid #d8e2ef;
			box-shadow: 0 14px 34px rgba(15, 23, 42, 0.08);
		}

		.pallets-header {
			display: flex;
			justify-content: space-between;
			align-items: center;
			gap: 16px;
			flex-wrap: wrap;
			margin-bottom: 22px;
		}

		.pallets-header h2 {
			margin: 0;
			font-size: 22px;
			font-weight: 600;
			letter-spacing: 0.02em;
		}

		.pallets-controls {
			display: flex;
			gap: 12px;
			flex-wrap: wrap;
			align-items: center;
		}

		.pallets-filter-form {
			display: flex;
			gap: 10px;
			align-items: center;
			background: #ffffff;
			border: 1px solid #cbd5f5;
			border-radius: 12px;
			padding: 10px 12px;
		}

		.pallets-filter-form input,
		.pallets-filter-form select {
			border: none;
			font-size: 14px;
			outline: none;
		}

		.pallets-filter-form button {
			border: none;
			background: #1d4ed8;
			color: #ffffff;
			padding: 8px 14px;
			border-radius: 8px;
			font-size: 13px;
			font-weight: 600;
			cursor: pointer;
			transition: background 0.2s ease, transform 0.2s ease;
		}

		.pallets-filter-form button:hover {
			background: #1e40af;
			transform: translateY(-1px);
		}

		.pallets-add-link {
			border-radius: 12px;
			border: 1px solid #1d4ed8;
			color: #1d4ed8;
			background: #ffffff;
			padding: 10px 16px;
			font-size: 13px;
			font-weight: 600;
			text-decoration: none;
			letter-spacing: 0.04em;
			transition: background 0.2s ease, color 0.2s ease, transform 0.2s ease;
		}

		.pallets-add-link:hover {
			background: #1d4ed8;
			color: #ffffff;
			transform: translateY(-1px);
		}

		.pallets-table-wrapper {
			overflow-x: auto;
			border-radius: 12px;
			border: 1px solid #cbd5e1;
			background: #ffffff;
		}

		table.pallets-table {
			width: 100%;
			border-collapse: collapse;
			min-width: 540px;
		}

		table.pallets-table thead {
			background: #e2e8f0;
		}

		table.pallets-table th {
			text-align: left;
			padding: 14px 16px;
			font-size: 13px;
			font-weight: 600;
			color: #334155;
			text-transform: uppercase;
			letter-spacing: 0.06em;
		}

		table.pallets-table td {
			padding: 14px 16px;
			border-top: 1px solid #e2e8f0;
			font-size: 14px;
		}

		table.pallets-table tbody tr:hover {
			background: #f8fafc;
		}

		.pallet-code {
			font-weight: 600;
			color: #1d4ed8;
		}

		.pallet-type-badge {
			display: inline-flex;
			align-items: center;
			gap: 6px;
			background: rgba(37, 99, 235, 0.12);
			color: #1d4ed8;
			border-radius: 999px;
			padding: 6px 12px;
			font-size: 13px;
			font-weight: 600;
		}

		.pallet-meta {
			display: flex;
			flex-direction: column;
			gap: 4px;
			font-size: 13px;
			color: #475569;
		}

		.pallet-meta strong {
			color: #1f2937;
		}

		.pallet-empty {
			padding: 40px 0;
			text-align: center;
			color: #64748b;
			font-size: 14px;
		}

		.search-meta {
			font-size: 13px;
			color: #475569;
			margin-bottom: 12px;
		}

		@media (max-width: 620px) {
			.pallets-wrap {
				padding: 20px;
			}

			.pallets-filter-form {
				width: 100%;
				flex-wrap: wrap;
			}

			.pallets-filter-form input,
			.pallets-filter-form select {
				width: 100%;
			}
		}
	</style>

	<cfoutput>
		<div class="pallets-wrap">
			<div class="pallets-header">
				<h2>Pallet Kayitlari</h2>

				<div class="pallets-controls">
					<form method="get" class="pallets-filter-form">
						<input
							type="text"
							name="search"
							value="#HTMLEditFormat(searchTerm)#"
							placeholder="Kod veya tip ara"
						>
						<select name="type">
							<option value="">Tum tipler</option>
							<cfloop query="getPalletTypes">
								<option value="#ID#" <cfif selectedType EQ ToString(ID)>selected</cfif>>#HTMLEditFormat(PALET_TYPE)#</option>
							</cfloop>
						</select>
						<button type="submit">Filtrele</button>
					</form>

					<a href="/index.cfm?fuseaction=eshipping.emptypopup_add_new_shipping_pallet_pbs" class="pallets-add-link">Yeni Pallet</a>
				</div>
			</div>

			<cfif Len(searchTerm) OR Len(selectedType)>
				<div class="search-meta">
					Filtre sonucu: #getPallets.RecordCount# kayit.
				</div>
			</cfif>

			<cfif getPallets.RecordCount EQ 0>
				<div class="pallet-empty">
					Kayitli pallet bulunamadi. Yeni pallet eklemek icin sag ustteki baglantiya tiklayin.
				</div>
			<cfelse>
				<div class="pallets-table-wrapper">
					<table class="pallets-table">
						<thead>
							<tr>
								<th>Kod</th>
								<th>Tip</th>
								<th>Kayit Bilgileri</th>
							</tr>
						</thead>
						<tbody>
							<cfloop query="getPallets">
								<tr>
									<td class="pallet-code">#HTMLEditFormat(PALLET_CODE)#</td>
									<td>
										<span class="pallet-type-badge">
											#HTMLEditFormat(PALLET_TYPE_NAME)#
										</span>
									</td>
									<td>
										<div class="pallet-meta">
											<div><strong>Tarih:</strong> #DateFormat(RECORD_DATE, "dd.mm.yyyy")# #TimeFormat(RECORD_DATE, "HH:nn")#</div>
											<div><strong>Kayit Eden:</strong> #RECORD_EMP#</div>
										</div>
									</td>
								</tr>
							</cfloop>
						</tbody>
					</table>
				</div>
			</cfif>
		</div>
	</cfoutput>
</cf_box>
