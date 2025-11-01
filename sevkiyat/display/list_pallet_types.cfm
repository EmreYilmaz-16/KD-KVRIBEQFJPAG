<cfparam name="url.search" default="">

<cfset searchTerm = Trim(url.search)>

<cfquery name="getPalletTypes" datasource="#dsn3#">
	SELECT ID, PALET_TYPE, MAXIMUM_WEIGHT
	FROM w3Qa.PALET_TYPES_PBS
	<cfif Len(searchTerm)>
		WHERE PALET_TYPE LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_nvarchar" maxlength="50">
	</cfif>
	ORDER BY PALET_TYPE
</cfquery>

<cf_box title="Palet Tipleri">
	<style>
		.pallet-list-wrapper {
			font-family: "Segoe UI", Tahoma, Arial, sans-serif;
			color: #1f2933;
			background: linear-gradient(135deg, #f8fafc, #eef2f7);
			border-radius: 16px;
			padding: 26px;
			border: 1px solid #d8e2ef;
			box-shadow: 0 14px 34px rgba(15, 23, 42, 0.08);
		}

		.pallet-list-header {
			display: flex;
			justify-content: space-between;
			align-items: center;
			gap: 16px;
			margin-bottom: 22px;
			flex-wrap: wrap;
		}

		.pallet-list-header h2 {
			font-size: 22px;
			margin: 0;
			font-weight: 600;
			letter-spacing: 0.02em;
		}

		.pallet-actions-group {
			display: flex;
			gap: 10px;
			align-items: center;
		}

		.pallet-search-form {
			display: flex;
			align-items: center;
			gap: 10px;
			background: #ffffff;
			border: 1px solid #cbd5f5;
			border-radius: 12px;
			padding: 10px 12px;
		}

		.pallet-search-form input {
			border: none;
			font-size: 14px;
			outline: none;
			min-width: 180px;
		}

		.pallet-search-form button {
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

		.pallet-search-form button:hover {
			background: #1e40af;
			transform: translateY(-1px);
		}

		.pallet-add-link {
			border-radius: 12px;
			border: 1px solid #1d4ed8;
			color: #1d4ed8;
			background: #ffffff;
			padding: 10px 16px;
			font-size: 13px;
			font-weight: 600;
			letter-spacing: 0.04em;
			text-decoration: none;
			transition: background 0.2s ease, color 0.2s ease, transform 0.2s ease;
		}

		.pallet-add-link:hover {
			background: #1d4ed8;
			color: #ffffff;
			transform: translateY(-1px);
		}

		.pallet-table-wrapper {
			overflow-x: auto;
			border-radius: 12px;
			border: 1px solid #cbd5e1;
			background: #ffffff;
		}

		table.pallet-table {
			width: 100%;
			border-collapse: collapse;
			min-width: 480px;
		}

		table.pallet-table thead {
			background: #e2e8f0;
		}

		table.pallet-table th {
			text-align: left;
			padding: 14px 16px;
			font-size: 13px;
			font-weight: 600;
			color: #334155;
			text-transform: uppercase;
			letter-spacing: 0.06em;
		}

		table.pallet-table td {
			padding: 14px 16px;
			border-top: 1px solid #e2e8f0;
			font-size: 14px;
		}

		table.pallet-table tbody tr:hover {
			background: #f8fafc;
		}

		.badge-weight {
			display: inline-flex;
			align-items: center;
			gap: 6px;
			background: rgba(37, 99, 235, 0.1);
			color: #1d4ed8;
			border-radius: 999px;
			padding: 6px 12px;
			font-size: 13px;
			font-weight: 600;
		}

		.empty-state {
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

		@media (max-width: 600px) {
			.pallet-list-wrapper {
				padding: 20px;
			}

			.pallet-search-form {
				width: 100%;
			}

			.pallet-search-form input {
				width: 100%;
			}
		}
	</style>

	<cfoutput>
		<div class="pallet-list-wrapper">
			<div class="pallet-list-header">
				<h2>Palet Tipleri</h2>

				<div class="pallet-actions-group">
					<form method="get" class="pallet-search-form">
						<input type="text" name="search" value="#HTMLEditFormat(searchTerm)#" placeholder="Palet tipi ara...">
						<button type="submit">Ara</button>
					</form>

					<a href="/index.cfm?fuseaction=eshipping.emptypopup_add_pallet_type_pbs" class="pallet-add-link">Yeni Palet Tipi</a>
				</div>
			</div>

			<cfif Len(searchTerm)>
				<div class="search-meta">
					"#HTMLEditFormat(searchTerm)#" icin #getPalletTypes.RecordCount# sonuc bulundu.
				</div>
			</cfif>

			<cfif getPalletTypes.RecordCount EQ 0>
				<div class="empty-state">
					Henuz palet tipi bulunmuyor. Sag ustten yeni bir palet tipi ekleyebilirsiniz.
				</div>
			<cfelse>
				<div class="pallet-table-wrapper">
					<table class="pallet-table">
						<thead>
							<tr>
								<th>ID</th>
								<th>Palet Tipi</th>
								<th>Maksimum Agirlik (kg)</th>
							</tr>
						</thead>
						<tbody>
							<cfloop query="getPalletTypes">
								<tr>
									<td>#ID#</td>
									<td>#HTMLEditFormat(PALET_TYPE)#</td>
									<td>
										<span class="badge-weight">#NumberFormat(MAXIMUM_WEIGHT, "999999999.99")# kg</span>
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
