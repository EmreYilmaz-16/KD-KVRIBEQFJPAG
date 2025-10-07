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

<cfoutput>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <title>Sayım Listesi (PDA)</title>
    <style>
        :root {
            --surface: #ffffff;
            --background: #eef2f7;
            --primary: #2563eb;
            --primary-dark: #1d4ed8;
            --accent: #0ea5e9;
            --text: #1f2933;
            --text-muted: #6b7280;
            --shadow: 0 12px 24px rgba(15, 23, 42, 0.08);
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
            font-size: 1.55rem;
            margin: 0;
            font-weight: 700;
            letter-spacing: -0.01em;
        }

        .badge {
            background: linear-gradient(135deg, var(--primary), var(--accent));
            color: white;
            padding: 10px 14px;
            border-radius: 999px;
            font-size: 0.95rem;
            font-weight: 600;
            white-space: nowrap;
            box-shadow: 0 6px 16px rgba(37, 99, 235, 0.35);
        }

        .stat-list {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 12px;
            margin: 0;
            padding: 0;
            list-style: none;
        }

        .stat-card {
            background: rgba(37, 99, 235, 0.08);
            border-radius: 14px;
            padding: 12px 14px;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .stat-card:nth-child(2) {
            background: rgba(14, 165, 233, 0.1);
        }

        .stat-card:nth-child(3) {
            background: rgba(94, 234, 212, 0.14);
        }

        .stat-label {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: var(--text-muted);
        }

        .stat-value {
            font-size: 1.35rem;
            font-weight: 700;
            color: var(--primary-dark);
        }

        .message {
            border-radius: 16px;
            padding: 14px 16px;
            background: rgba(220, 38, 38, 0.08);
            color: #b91c1c;
            border: 1px solid rgba(220, 38, 38, 0.2);
            font-size: 0.95rem;
        }

        .search-block {
            background: var(--surface);
            border-radius: 16px;
            padding: 16px;
            box-shadow: var(--shadow);
        }

        .search-block label {
            display: block;
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--text-muted);
            margin-bottom: 6px;
        }

        .search-block input {
            width: 100%;
            padding: 14px 16px;
            border-radius: 12px;
            border: 1px solid rgba(148, 163, 184, 0.45);
            font-size: 1rem;
            background: #f8fafc;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .search-block input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.15);
        }

        .cards {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .sayim-card {
            background: var(--surface);
            border-radius: 18px;
            padding: 16px 18px;
            box-shadow: var(--shadow);
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .card-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
        }

        .id-chip {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--primary-dark);
            background: rgba(37, 99, 235, 0.12);
            padding: 8px 12px;
            border-radius: 12px;
        }

        .date-pill {
            background: rgba(14, 165, 233, 0.12);
            color: var(--accent);
            font-weight: 600;
            padding: 8px 12px;
            border-radius: 999px;
            font-size: 0.9rem;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 12px;
        }

        .info-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .info-label {
            font-size: 0.75rem;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            color: var(--text-muted);
        }

        .info-value {
            font-size: 0.95rem;
            font-weight: 600;
        }

        .info-subtle {
            color: var(--text-muted);
            font-weight: 500;
            display: block;
            margin-top: 2px;
            font-size: 0.85rem;
        }

        .chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 10px;
            border-radius: 999px;
            font-size: 0.85rem;
            font-weight: 600;
            background: rgba(15, 118, 110, 0.1);
            color: #0f766e;
        }

        .card-actions {
            display: flex;
            gap: 12px;
        }

        .primary-button {
            flex: 1;
            text-align: center;
            text-decoration: none;
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: white;
            padding: 14px;
            border-radius: 14px;
            font-size: 1.05rem;
            font-weight: 600;
            letter-spacing: 0.02em;
            box-shadow: 0 10px 20px rgba(37, 99, 235, 0.35);
            transition: transform 0.15s ease, box-shadow 0.15s ease;
        }

        .primary-button:active {
            transform: scale(0.98);
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
        }

        .empty-state {
            text-align: center;
            padding: 48px 24px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.8);
            box-shadow: var(--shadow);
            color: var(--text-muted);
        }

        .empty-state .emoji {
            font-size: 2.4rem;
            display: block;
            margin-bottom: 12px;
        }

        .empty-search {
            text-align: center;
            font-size: 0.95rem;
            color: var(--text-muted);
            padding: 12px;
        }

        .hidden {
            display: none !important;
        }

        @media (min-width: 640px) {
            body {
                align-items: flex-start;
            }

            .wrapper {
                padding-top: 36px;
                max-width: 620px;
            }
        }
    </style>
</head>
<body>
    <div class="wrapper">
        <header class="topbar">
            <div class="title-row">
                <h1>Sayım Listesi</h1>
                <span class="badge">#totalRecords# Kayıt</span>
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

            <section class="cards" id="sayimCards">
                <cfoutput query="getSayimList">
                    <cfset filterText = lcase(trim(SAYIM_ID & " " & PAPER_NUMBER & " " & DEPO_CODE & " " & DEPO_NAME & " " & dateFormat(SAYIM_DATE, "dd.mm.yyyy") & " " & dateFormat(RECORD_DATE, "dd.mm.yyyy") & " " & RECORD_EMP))>
                    <article class="sayim-card" data-filter="#encodeForHtmlAttribute(filterText)#">
                        <div class="card-head">
                            <span class="id-chip">## #SAYIM_ID#</span>
                            <span class="date-pill">#dateFormat(SAYIM_DATE, "dd.mm.yyyy")#</span>
                        </div>

                        <div class="info-grid">
                            <div class="info-item">
                                <span class="info-label">Evrak No</span>
                                <span class="info-value">#PAPER_NUMBER#</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Depo</span>
                                <span class="info-value">
                                    <cfif len(trim(DEPO_NAME))>
                                        #DEPO_NAME#
                                    <cfelse>
                                        Tanımsız
                                    </cfif>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Depo Kod</span>
                                <span class="info-value"><span class="chip">#DEPO_CODE#</span></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Kayıt Tarihi</span>
                                <span class="info-value">#dateFormat(RECORD_DATE, "dd.mm.yyyy")#<span class="info-subtle">#timeFormat(RECORD_DATE, "HH:mm")#</span></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Kayıt Eden</span>
                                <span class="info-value">
                                    <cfif len(trim(RECORD_EMP))>
                                        #RECORD_EMP#
                                    <cfelse>
                                        Bilinmiyor
                                    </cfif>
                                </span>
                            </div>
                        </div>

                        <div class="card-actions">
                            <a href="detail_sayim_pda.cfm?sayim_id=#SAYIM_ID#" class="primary-button">Detay</a>
                        </div>
                    </article>
                </cfoutput>
            </section>
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
        const cardsContainer = document.getElementById('sayimCards');

        if (searchInput && cardsContainer) {
            const cards = Array.from(cardsContainer.querySelectorAll('.sayim-card'));
            const emptyMessage = document.getElementById('emptyFilterState');

            const applyFilter = () => {
                const query = searchInput.value.trim().toLowerCase();
                let visibleCount = 0;

                cards.forEach(card => {
                    const matches = card.dataset.filter.includes(query);
                    card.classList.toggle('hidden', !matches);
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
</body>
</html>
</cfoutput>