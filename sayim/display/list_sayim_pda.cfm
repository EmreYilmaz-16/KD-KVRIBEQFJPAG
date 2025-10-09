<cftry>
    <cfquery name="getSayimList" datasource="w3Qa_1">
        SELECT 
            s.SAYIM_ID,
            s.PAPER_NUMBER,
            s.DEPARTMENT_ID,
            s.LOCATION_ID,
            CAST(s.DEPARTMENT_ID AS VARCHAR)+'-'+CAST(s.LOCATION_ID AS VARCHAR) AS DEPO_CODE,
            sl.COMMENT AS DEPO_NAME,
            s.SAYIM_DATE,
            s.RECORD_DATE,
            s.RECORD_EMP
        FROM PBS_SERIAL_SAYIM s
        LEFT JOIN w3Qa.STOCKS_LOCATION sl ON (
            s.DEPARTMENT_ID = sl.DEPARTMENT_ID AND 
            s.LOCATION_ID = sl.LOCATION_ID
        )
        ORDER BY s.RECORD_DATE DESC, s.SAYIM_ID DESC
    </cfquery>
    <cfcatch>
        <cfset getSayimList = queryNew("SAYIM_ID,PAPER_NUMBER,DEPARTMENT_ID,LOCATION_ID,DEPO_CODE,DEPO_NAME,SAYIM_DATE,RECORD_DATE,RECORD_EMP", "integer,varchar,integer,integer,varchar,varchar,date,date,integer")>
        <cfset errorMessage = "Veritabanı hatası: #cfcatch.message#">
    </cfcatch>
</cftry>

<cfset totalRecords = getSayimList.recordCount>
<cfset todayCount = 0>
<cfset depotCount = 0>
<cfset userCount = 0>
<cfset todayString = dateFormat(now(), "yyyy-mm-dd")>

<cfif totalRecords gt 0>
    <cfset uniqueDepos = structNew()>
    <cfset uniqueUsers = structNew()>

    <cfloop query="getSayimList">
        <cfif dateFormat(RECORD_DATE, "yyyy-mm-dd") eq todayString>
            <cfset todayCount = todayCount + 1>
        </cfif>

        <cfif len(trim(DEPO_CODE))>
            <cfset uniqueDepos[DEPO_CODE] = true>
        </cfif>

        <cfif len(trim(RECORD_EMP))>
            <cfset uniqueUsers[RECORD_EMP] = true>
        </cfif>
    </cfloop>

    <cfset depotCount = structCount(uniqueDepos)>
    <cfset userCount = structCount(uniqueUsers)>
</cfif>




        <style>
            :root {
                --surface: #ffffff;
                --background: #eef2f7;
                --primary: #2563eb;
                --primary-dark: #1d4ed8;
                --accent: #0ea5e9;
                --text: #1f2933;
                --text-muted: #6b7280;
                --shadow: 0 10px 20px rgba(15, 23, 42, 0.08);
            }

            * {
                box-sizing: border-box;
            }

            body {
                margin: 0;
                padding: env(safe-area-inset-top) env(safe-area-inset-right) env(safe-area-inset-bottom) env(safe-area-inset-left);
                min-height: 100vh;
                background: var(--background);
                font-family: "Segoe UI", "Inter", "Helvetica Neue", sans-serif;
                color: var(--text);
                display: flex;
                justify-content: center;
            }

            .wrapper {
                width: 100%;
                max-width: 520px;
                padding: 20px 16px 32px;
                display: flex;
                flex-direction: column;
                gap: 16px;
            }

            header.topbar {
                display: flex;
                flex-direction: column;
                gap: 12px;
            }

            .title-row {
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 12px;
            }

            .title-row h1 {
                font-size: 1.45rem;
                margin: 0;
                font-weight: 700;
                letter-spacing: -0.01em;
            }

            .badge {
                background: linear-gradient(135deg, var(--primary), var(--accent));
                color: white;
                padding: 8px 12px;
                border-radius: 999px;
                font-size: 0.9rem;
                font-weight: 600;
                white-space: nowrap;
                box-shadow: 0 6px 16px rgba(37, 99, 235, 0.25);
            }

            .stat-list {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(110px, 1fr));
                gap: 10px;
                margin: 0;
                padding: 0;
                list-style: none;
            }

            .stat-card {
                background: rgba(37, 99, 235, 0.07);
                border-radius: 12px;
                padding: 10px 12px;
                display: flex;
                flex-direction: column;
                gap: 4px;
            }

            .stat-card:nth-child(2) {
                background: rgba(14, 165, 233, 0.09);
            }

            .stat-card:nth-child(3) {
                background: rgba(15, 118, 110, 0.12);
            }

            .stat-label {
                font-size: 0.72rem;
                text-transform: uppercase;
                letter-spacing: 0.06em;
                color: var(--text-muted);
            }

            .stat-value {
                font-size: 1.18rem;
                font-weight: 700;
                color: var(--primary-dark);
            }

            .message {
                border-radius: 14px;
                padding: 12px 14px;
                background: rgba(220, 38, 38, 0.08);
                color: #b91c1c;
                border: 1px solid rgba(220, 38, 38, 0.2);
                font-size: 0.92rem;
            }

            .search-block {
                background: var(--surface);
                border-radius: 14px;
                padding: 14px;
                box-shadow: var(--shadow);
            }

            .search-block label {
                display: block;
                font-size: 0.82rem;
                font-weight: 600;
                color: var(--text-muted);
                margin-bottom: 6px;
            }

            .search-block input {
                width: 100%;
                padding: 12px 14px;
                border-radius: 10px;
                border: 1px solid rgba(148, 163, 184, 0.45);
                font-size: 0.95rem;
                background: #f8fafc;
                transition: border-color 0.2s ease, box-shadow 0.2s ease;
            }

            .search-block input:focus {
                outline: none;
                border-color: var(--primary);
                box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.14);
            }

            .record-list {
                margin: 0;
                padding: 0;
                list-style: none;
                display: flex;
                flex-direction: column;
                gap: 10px;
            }

            .record-item {
                background: var(--surface);
                border-radius: 14px;
                padding: 12px 14px;
                box-shadow: var(--shadow);
                display: flex;
                align-items: flex-start;
                gap: 12px;
                justify-content: space-between;
            }

            .item-info {
                flex: 1;
                display: flex;
                flex-direction: column;
                gap: 8px;
            }

            .item-top {
                display: flex;
                flex-wrap: wrap;
                align-items: center;
                gap: 8px;
            }

            .item-id {
                font-weight: 700;
                font-size: 0.95rem;
                color: var(--primary-dark);
                background: rgba(37, 99, 235, 0.12);
                padding: 6px 10px;
                border-radius: 10px;
            }

            .item-paper {
                font-size: 1rem;
                font-weight: 600;
                color: var(--text);
            }

            .item-meta {
                display: flex;
                flex-wrap: wrap;
                gap: 6px;
                font-size: 0.82rem;
                color: var(--text-muted);
            }

            .meta-chip {
                background: rgba(148, 163, 184, 0.16);
                color: var(--text);
                padding: 4px 8px;
                border-radius: 999px;
                font-weight: 500;
            }

            .meta-chip strong {
                margin-right: 4px;
                color: var(--text);
            }

            .item-dates {
                font-size: 0.8rem;
                color: var(--text-muted);
                display: flex;
                flex-direction: column;
                gap: 2px;
            }

            .item-action {
                align-self: center;
            }

            .primary-button {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
                text-decoration: none;
                background: linear-gradient(135deg, var(--primary), var(--primary-dark));
                color: white;
                padding: 10px 14px;
                border-radius: 12px;
                font-size: 0.95rem;
                font-weight: 600;
                letter-spacing: 0.01em;
                box-shadow: 0 8px 16px rgba(37, 99, 235, 0.28);
                transition: transform 0.15s ease, box-shadow 0.15s ease;
            }

            .primary-button:active {
                transform: scale(0.97);
                box-shadow: 0 4px 10px rgba(37, 99, 235, 0.26);
            }

            .empty-state {
                text-align: center;
                padding: 40px 24px;
                border-radius: 16px;
                background: rgba(255, 255, 255, 0.85);
                box-shadow: var(--shadow);
                color: var(--text-muted);
            }

            .empty-state .emoji {
                font-size: 2.2rem;
                display: block;
                margin-bottom: 10px;
            }

            .empty-search {
                text-align: center;
                font-size: 0.9rem;
                color: var(--text-muted);
                padding: 10px;
            }

            .hidden {
                display: none !important;
            }

            @media (min-width: 640px) {
                body {
                    align-items: flex-start;
                }

                .wrapper {
                    padding-top: 32px;
                    max-width: 600px;
                }
            }
        </style>
      <cfoutput>
        <div class="wrapper">
        <header class="topbar">
            <div class="title-row">
                <h1>Sayım Listesi</h1>
                <span class="badge">#totalRecords# Kayıt</span>
                <span onclick="location.href='/index.cfm?fuseaction=stock.emptypopup_add_sayim_paper'" class="badge">Yeni Kayıt</span>
            </div>

            <ul class="stat-list">
                <li class="stat-card">
                    <span class="stat-label">Bugün</span>
                    <span class="stat-value">#todayCount#</span>
                </li>
                <li class="stat-card">
                    <span class="stat-label">Depo</span>
                    <span class="stat-value">#depotCount#</span>
                </li>
                <li class="stat-card">
                    <span class="stat-label">Kullanıcı</span>
                    <span class="stat-value">#userCount#</span>
                </li>
            </ul>
        </header>

        <cfif isDefined("errorMessage")>
            <div class="message">
                ⚠️ #errorMessage#
            </div>
        </cfif>

        <cfif totalRecords gt 0>
            <div class="search-block">
                <label for="searchInput">Kayıtlarda Ara</label>
                <input type="search" id="searchInput" inputmode="search" placeholder="Evrak, depo veya kullanıcı ara...">
            </div>

            <ul class="record-list" id="sayimList">
                <cfloop query="getSayimList">
                    <cfset filterText = lcase(trim(SAYIM_ID & " " & PAPER_NUMBER & " " & DEPO_CODE & " " & DEPO_NAME & " " & dateFormat(SAYIM_DATE, "dd.mm.yyyy") & " " & dateFormat(RECORD_DATE, "dd.mm.yyyy") & " " & RECORD_EMP))>
                    <li class="record-item" data-filter="#encodeForHtmlAttribute(filterText)#">
                        <div class="item-info">
                            <div class="item-top">
                                <span class="item-id">## #SAYIM_ID#</span>
                                <span class="item-paper">#PAPER_NUMBER#</span>
                            </div>
                            <div class="item-meta">
                                <span class="meta-chip"><strong>Depo:</strong> <cfif len(trim(DEPO_NAME))>#DEPO_NAME#<cfelse>Tanımsız</cfif></span>
                                <span class="meta-chip"><strong>Kod:</strong> #DEPO_CODE#</span>
                                <span class="meta-chip"><strong>Kayıt Eden:</strong> <cfif len(trim(RECORD_EMP))>#RECORD_EMP#<cfelse>Bilinmiyor</cfif></span>
                            </div>
                        </div>
                        <div class="item-dates">
                            <span>Sayım: #dateFormat(SAYIM_DATE, "dd.mm.yyyy")#</span>
                            <span>Kayıt: #dateFormat(RECORD_DATE, "dd.mm.yyyy")# • #timeFormat(RECORD_DATE, "HH:mm")#</span>
                        </div>
                        <div class="item-action">
                            <a href="detail_sayim_pda.cfm?sayim_id=#SAYIM_ID#" class="primary-button">Detay</a>
                        </div>
                    </li>
                </cfloop>
            </ul>
            <p id="emptyFilterState" class="empty-search hidden">Aramanızla eşleşen kayıt bulunamadı.</p>
        <cfelse>
            <section class="empty-state">
                <span class="emoji">📭</span>
                <h2>Henüz sayım kaydı yok</h2>
                <p>Yeni kayıtlar geldiğinde burada hızlıca görüntüleyebilirsiniz.</p>
            </section>
        </cfif>
    </div>

    <script>
        const searchInput = document.getElementById('searchInput');
        const recordContainer = document.getElementById('sayimList');

        if (searchInput && recordContainer) {
            const items = Array.from(recordContainer.querySelectorAll('.record-item'));
            const emptyMessage = document.getElementById('emptyFilterState');

            const applyFilter = () => {
                const query = searchInput.value.trim().toLowerCase();
                let visibleCount = 0;

                items.forEach(item => {
                    const matches = item.dataset.filter.includes(query);
                    item.classList.toggle('hidden', !matches);
                    if (matches) {
                        visibleCount++;
                    }
                });

                if (emptyMessage) {
                    emptyMessage.classList.toggle('hidden', visibleCount !== 0);
                }
            };

            searchInput.addEventListener('input', applyFilter);
        }
    </script>

</cfoutput>