<cfparam name="url.search" default="">
<cfparam name="url.type" default="">

<cfset searchTerm = Trim(url.search)>
<cfset selectedType = Trim(url.type)>

<cfquery name="getPalletTypes" datasource="#dsn3#">
	SELECT ID, PALET_TYPE
	FROM #DSN#.PALET_TYPES_PBS
	ORDER BY PALET_TYPE
</cfquery>

<cfquery name="getPallets" datasource="#dsn3#">
	SELECT
		P.ID,
		P.PALLET_CODE,
		P.PALLET_TYPE,
		P.RECORD_DATE,
		P.RECORD_EMP,
		P.MAIN_PALET_ID,
		T.PALET_TYPE AS PALLET_TYPE_NAME,
		P.COMPANY_ID,		
		C.NICKNAME AS COMPANY_NICKNAME,
		E.EMPLOYEE_NAME,
		E.EMPLOYEE_SURNAME,
		(SELECT COUNT(*) FROM #dsn3#.SHIPPING_PALLETS_PBS WHERE MAIN_PALET_ID = P.ID) AS CHILD_COUNT
	FROM #dsn3#.SHIPPING_PALLETS_PBS P
	LEFT JOIN #DSN#.PALET_TYPES_PBS T ON T.ID = P.PALLET_TYPE
	LEFT JOIN #DSN#.COMPANY AS C ON C.COMPANY_ID = P.COMPANY_ID
	LEFT JOIN #DSN#.EMPLOYEES AS E ON E.EMPLOYEE_ID = P.RECORD_EMP
	WHERE 1 = 1
	AND P.MAIN_PALET_ID IS NULL
	<cfif Len(searchTerm)>
		AND (
			P.PALLET_CODE LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_nvarchar" maxlength="50">
			OR T.PALET_TYPE LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_nvarchar" maxlength="50">
			OR C.NICKNAME LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_nvarchar" maxlength="100">
			OR (COALESCE(E.EMPLOYEE_NAME, '') + ' ' + COALESCE(E.EMPLOYEE_SURNAME, '')) LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_nvarchar" maxlength="100">
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
			min-width: 680px;
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

		.company-pill {
			display: inline-flex;
			align-items: center;
			gap: 6px;
			background: rgba(14, 116, 144, 0.12);
			color: #0e7490;
			border-radius: 999px;
			padding: 6px 12px;
			font-size: 13px;
			font-weight: 600;
		}

		.company-pill i {
			font-style: normal;
			font-weight: 700;
		}

		.company-cell {
			display: flex;
			flex-direction: column;
			gap: 6px;
			font-size: 13px;
			color: #475569;
		}

		.company-meta {
			font-size: 12px;
			color: #64748b;
		}

		.company-meta strong {
			color: #1f2937;
		}

		.child-pallet-indicator {
			display: inline-flex;
			align-items: center;
			gap: 4px;
			background: rgba(251, 146, 60, 0.15);
			color: #ea580c;
			border-radius: 6px;
			padding: 3px 8px;
			font-size: 11px;
			font-weight: 600;
			margin-left: 8px;
		}

		.child-count-badge {
			display: inline-flex;
			align-items: center;
			justify-content: center;
			background: rgba(34, 197, 94, 0.15);
			color: #16a34a;
			border-radius: 999px;
			width: 18px;
			height: 18px;
			font-size: 11px;
			font-weight: 700;
			margin-left: 6px;
		}

		.pallet-action-btn {
			display: inline-flex;
			align-items: center;
			justify-content: center;
			width: 32px;
			height: 32px;
			border-radius: 8px;
			border: 1px solid #cbd5e1;
			background: #ffffff;
			color: #475569;
			font-size: 16px;
			cursor: pointer;
			transition: all 0.2s ease;
			margin-right: 6px;
		}

		.pallet-action-btn:hover {
			background: #f1f5f9;
			border-color: #94a3b8;
			transform: translateY(-1px);
		}

		.pallet-action-btn.add-child {
			color: #16a34a;
			border-color: #86efac;
		}

		.pallet-action-btn.add-child:hover {
			background: #dcfce7;
			border-color: #22c55e;
		}

		.pallet-action-btn.disabled {
			opacity: 0.5;
			cursor: not-allowed;
			pointer-events: none;
		}

		.accordion-toggle-btn {
			display: inline-flex;
			align-items: center;
			justify-content: center;
			width: 24px;
			height: 24px;
			border-radius: 6px;
			border: 1px solid #cbd5e1;
			background: #ffffff;
			color: #475569;
			font-size: 14px;
			cursor: pointer;
			transition: all 0.2s ease;
			margin-right: 8px;
			vertical-align: middle;
		}

		.accordion-toggle-btn:hover {
			background: #f1f5f9;
			border-color: #94a3b8;
		}

		.accordion-toggle-btn.expanded {
			background: #e0e7ff;
			border-color: #818cf8;
			color: #4f46e5;
		}

		.child-pallets-row {
			display: none;
		}

		.child-pallets-row.show {
			display: table-row;
		}

		.child-pallets-container {
			padding: 16px 20px;
			background: linear-gradient(135deg, #fef3c7, #fde68a);
			border-left: 4px solid #f59e0b;
			border-radius: 8px;
		}

		.child-pallet-item {
			background: #ffffff;
			border-radius: 8px;
			padding: 12px 16px;
			margin-bottom: 10px;
			border: 1px solid #fbbf24;
			display: grid;
			grid-template-columns: 1fr 1fr 1fr auto;
			gap: 12px;
			align-items: center;
		}

		.child-pallet-item:last-child {
			margin-bottom: 0;
		}

		.child-pallet-label {
			font-size: 12px;
			color: #92400e;
			font-weight: 600;
			margin-bottom: 4px;
		}

		.child-pallet-value {
			font-size: 13px;
			color: #1f2937;
		}

		.child-pallet-header {
			font-size: 14px;
			font-weight: 600;
			color: #92400e;
			margin-bottom: 12px;
			display: flex;
			align-items: center;
			gap: 8px;
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
							placeholder="Kod, tip veya cari ara"
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
								<th>Cari Hesap</th>
								<th>Kayit Bilgileri</th>
								<th>Islemler</th>
							</tr>
						</thead>
						<tbody>
							<cfloop query="getPallets">
								<cfset companyNameRaw = Trim(COMPANY_NICKNAME)>
								<cfif NOT Len(companyNameRaw) AND Val(COMPANY_ID) GT 0>
									<cfset companyNameRaw = "ID: " & COMPANY_ID>
								<cfelseif NOT Len(companyNameRaw)>
									<cfset companyNameRaw = "Atanmamis">
								</cfif>

								<cfset companyDisplay = HTMLEditFormat(companyNameRaw)>

								<cfset employeeFullName = Trim(EMPLOYEE_NAME & " " & EMPLOYEE_SURNAME)>
								<cfif Len(employeeFullName)>
									<cfset employeeDisplay = HTMLEditFormat(employeeFullName)>
									<cfif Val(RECORD_EMP) GT 0>
										<cfset employeeDisplay = employeeDisplay & " (" & HTMLEditFormat(RECORD_EMP) & ")">
									</cfif>
								<cfelseif Val(RECORD_EMP) GT 0>
									<cfset employeeDisplay = HTMLEditFormat(RECORD_EMP)>
								<cfelse>
									<cfset employeeDisplay = "Atanmamis">
								</cfif>

								<tr>
									<td class="pallet-code">
										<cfif Val(CHILD_COUNT) GT 0>
											<span class="accordion-toggle-btn" onclick="toggleChildPallets(#ID#)" id="toggleBtn_#ID#">▶</span>
										</cfif>
										#HTMLEditFormat(PALLET_CODE)#
										<cfif Val(MAIN_PALET_ID) GT 0>
											<span class="child-pallet-indicator" title="Bu bir yavru palettir">🔗 Yavru</span>
										</cfif>
										<cfif Val(CHILD_COUNT) GT 0>
											<span class="child-count-badge" title="#CHILD_COUNT# yavru palet">#CHILD_COUNT#</span>
										</cfif>
									</td>
									<td>
										<span class="pallet-type-badge">
											#HTMLEditFormat(PALLET_TYPE_NAME)#
										</span>
									</td>
									<td>
										<div class="company-cell">
											<span class="company-pill">#companyDisplay#</span>
											<cfif isdefined("CONSUMER_ID") AND Val(CONSUMER_ID) GT 0>
												<div class="company-meta"><strong>Consumer ID:</strong> #HTMLEditFormat(CONSUMER_ID)#</div>
											</cfif>
											<cfif isdefined("COMPANY_ID") AND Val(COMPANY_ID) GT 0>
												<div class="company-meta"><strong>Company ID:</strong> #HTMLEditFormat(COMPANY_ID)#</div>
											</cfif>
										</div>
									</td>
									<td>
										<div class="pallet-meta">
											<div><strong>Tarih:</strong>
												<cfif IsDate(RECORD_DATE)>
													#DateFormat(RECORD_DATE, "dd.mm.yyyy")# #TimeFormat(RECORD_DATE, "HH:nn")#
												<cfelse>
													Belirtilmedi
												</cfif>
											</div>
											<div><strong>Kayit Eden:</strong> #employeeDisplay#</div>
										</div>
									</td>
									<td>
										<button 
											class="pallet-action-btn add-child" 
											title="Yavru palet olustur"
											onclick="createChildPallet(#ID#, '#encodeForJavaScript(PALLET_CODE)#')"
											id="addChildBtn_#ID#"
										>
											+
										</button>
										<button class="pallet-action-btn" title="Sevkiyat Ekle" onclick="window.location.href='/index.cfm?fuseaction=eshipping.emptypopup_add_svk_to_pallet_pbs&PALLET_ID=#HTMLEditFormat(ID)#'" style="font-size: 18px;">🚚</button>
										<button class="pallet-action-btn" title="Urun Ekle" onclick="window.location.href='/index.cfm?fuseaction=eshipping.emptypopup_add_product_pallet_pbs&pallet_id=#HTMLEditFormat(ID)#'" style="font-size: 18px;">📦</button>
									</td>
								</tr>
								
								<!--- Yavru Paletler Accordion --->
								<cfif Val(CHILD_COUNT) GT 0>
									<tr class="child-pallets-row" id="childRow_#ID#">
										<td colspan="5">
											<div class="child-pallets-container">
												<div class="child-pallet-header">
													🔗 Yavru Paletler (#CHILD_COUNT# adet)
												</div>
												
												<cfquery name="getChildPallets" datasource="#dsn3#">
													SELECT
														P.ID,
														P.PALLET_CODE,
														P.RECORD_DATE,
														T.PALET_TYPE AS PALLET_TYPE_NAME,
														E.EMPLOYEE_NAME,
														E.EMPLOYEE_SURNAME
													FROM #dsn3#.SHIPPING_PALLETS_PBS P
													LEFT JOIN #DSN#.PALET_TYPES_PBS T ON T.ID = P.PALLET_TYPE
													LEFT JOIN #DSN#.EMPLOYEES AS E ON E.EMPLOYEE_ID = P.RECORD_EMP
													WHERE P.MAIN_PALET_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
													ORDER BY P.RECORD_DATE DESC
												</cfquery>
												
												<cfloop query="getChildPallets">
													<cfset childEmployeeFullName = Trim(EMPLOYEE_NAME & " " & EMPLOYEE_SURNAME)>
													<div class="child-pallet-item">
														<div>
															<div class="child-pallet-label">Palet Kodu</div>
															<div class="child-pallet-value">#HTMLEditFormat(PALLET_CODE)#</div>
														</div>
														<div>
															<div class="child-pallet-label">Tip</div>
															<div class="child-pallet-value">#HTMLEditFormat(PALLET_TYPE_NAME)#</div>
														</div>
														<div>
															<div class="child-pallet-label">Kayıt Tarihi</div>
															<div class="child-pallet-value">
																<cfif IsDate(RECORD_DATE)>
																	#DateFormat(RECORD_DATE, "dd.mm.yyyy")# #TimeFormat(RECORD_DATE, "HH:nn")#
																<cfelse>
																	-
																</cfif>
															</div>
														</div>
														<div>
															<button class="pallet-action-btn" title="Sevkiyat Ekle" onclick="window.location.href='/index.cfm?fuseaction=eshipping.emptypopup_add_svk_to_pallet_pbs&PALLET_ID=#HTMLEditFormat(ID)#'" style="font-size: 18px;">🚚</button>
															<button class="pallet-action-btn" title="Urun Ekle" onclick="window.location.href='/index.cfm?fuseaction=eshipping.emptypopup_add_product_pallet_pbs&pallet_id=#HTMLEditFormat(ID)#'" style="font-size: 18px;">📦</button>
														</div>
													</div>
												</cfloop>
											</div>
										</td>
									</tr>
								</cfif>
							</cfloop>
						</tbody>
					</table>
				</div>
			</cfif>
		</div>
	</cfoutput>
</cf_box>

<script>
function toggleChildPallets(parentId) {
	const childRow = document.getElementById('childRow_' + parentId);
	const toggleBtn = document.getElementById('toggleBtn_' + parentId);
	
	if (childRow && toggleBtn) {
		if (childRow.classList.contains('show')) {
			childRow.classList.remove('show');
			toggleBtn.classList.remove('expanded');
			toggleBtn.innerHTML = '▶';
		} else {
			childRow.classList.add('show');
			toggleBtn.classList.add('expanded');
			toggleBtn.innerHTML = '▼';
		}
	}
}

function createChildPallet(parentPalletId, parentPalletCode) {
	// Butonu devre dışı bırak
	const btn = document.getElementById('addChildBtn_' + parentPalletId);
	if (btn) {
		btn.classList.add('disabled');
		btn.innerHTML = '⏳';
	}

	// Onay al
	if (!confirm('Ana Palet: ' + parentPalletCode + '\n\nBu paletin yavru paletini oluşturmak istediğinize emin misiniz?')) {
		if (btn) {
			btn.classList.remove('disabled');
			btn.innerHTML = '+';
		}
		return;
	}

	// Ajax isteği gönder
	fetch('/index.cfm?fuseaction=eshipping.emptypopup_create_child_pallet_pbs&parent_pallet_id=' + parentPalletId+"&ajax=1&ajax_box_page=1&isAjax=1")
		.then(response => response.json())
		.then(data => {
			if (data.SUCCESS) {
				alert('Başarılı!\n\nYavru Palet Kodu: ' + data.data.CHILDPALLETCODE + '\nAna Palet: ' + data.data.PARENTPALLETCODE);
				// Sayfayı yenile
				window.location.reload();
			} else {
				alert('Hata!\n\n' + data.message);
				if (btn) {
					btn.classList.remove('disabled');
					btn.innerHTML = '+';
				}
			}
		})
		.catch(error => {
			alert('İstek sırasında hata oluştu!\n\n' + error.message);
			if (btn) {
				btn.classList.remove('disabled');
				btn.innerHTML = '+';
			}
		});
}
</script>
