<cfparam name="attributes.search" default="">
<cfparam name="url.search" default="">
<cfset searchTerm = Trim(attributes.search)>

<div class="page-wrapper">
    <div class="page-header">
        <div>
            <h1>Sevk Listesi</h1>
            <p class="page-subtitle">Satın alma sevkiyatlarını hızlıca arayın, durumunu inceleyin.</p>
        </div>
        <cfif Len(searchTerm)>
            <span class="pill pill-active">Arama: <cfoutput>#EncodeForHTML(searchTerm)#</cfoutput></span>
        </cfif>
    </div>

    <form class="search-card" method="post" name="pform" action="/index.cfm?fuseaction=purchase._emptypopup_list_purchase_despatches_pbs">
        <div class="search-input-group">
            <label for="search">Sevk No veya Firma</label>
            <div class="search-field">
                <span class="search-icon" aria-hidden="true">🔍</span>
                <input type="text" id="search" name="search" placeholder="Örn. PBS-12345 ya da Partner" value="<cfoutput>#EncodeForHTML(attributes.search)#</cfoutput>">
            </div>
        </div>
        <div class="search-actions">
            <button type="submit" class="btn btn-primary">Ara</button>
            <cfif Len(searchTerm)>
                <a href="/index.cfm?fuseaction=purchase._emptypopup_list_purchase_despatches_pbs" class="btn btn-secondary">Temizle</a>
            </cfif>
        </div>
    </form>

    <div class="guide-trigger-bar" role="toolbar" aria-label="Sevk kılavuzları">
        <!---<button type="button" class="btn btn-ghost" data-guide-url="/addons/partner/malkabul/guides/despatch_technical.html" data-guide-title="Teknik Kılavuz">
            🔧 Teknik Kılavuz
        </button>---->
        <button type="button" class="btn btn-ghost" data-guide-url="/addons/partner/malkabul/guides/despatch_user.html" data-guide-title="Kullanıcı Kılavuzu">
            👤 Kullanıcı Kılavuzu
        </button>
    </div>


    <cfquery name="getDespatches" datasource="#dsn2#">
        SELECT
            S.SHIP_ID,
            S.SHIP_NUMBER,
            C.NICKNAME,
            S.SHIP_DATE,
            COALESCE(T.TotalAmount, 0)  AS TOTAL_AMOUNT,
            COALESCE(G.GuaranteeCnt, 0) AS GUARANTY_COUNT
        FROM w3Qa_2025_1.SHIP AS S
        LEFT JOIN w3Qa.COMPANY AS C
               ON C.COMPANY_ID = S.COMPANY_ID
        LEFT JOIN (
            SELECT SR.SHIP_ID, SUM(SR.AMOUNT) AS TotalAmount
            FROM w3Qa_2025_1.SHIP_ROW AS SR
            GROUP BY SR.SHIP_ID
        ) AS T
               ON T.SHIP_ID = S.SHIP_ID
        LEFT JOIN (
            SELECT SR.SHIP_ID, COUNT(*) AS GuaranteeCnt
            FROM w3Qa_2025_1.SHIP_ROW AS SR
            INNER JOIN w3Qa_1.SERVICE_GUARANTY_NEW AS SG
                    ON SG.WRK_ROW_ID = SR.WRK_ROW_ID
            GROUP BY SR.SHIP_ID
        ) AS G
               ON G.SHIP_ID = S.SHIP_ID
        WHERE S.PURCHASE_SALES = 0
          AND S.DEPARTMENT_IN  = 2
          AND S.LOCATION_IN    = 1
        <cfif Len(searchTerm)>
          AND (
                S.SHIP_NUMBER LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
             OR C.NICKNAME    LIKE <cfqueryparam value="%#searchTerm#%" cfsqltype="cf_sql_varchar">
          )
        </cfif>
        ORDER BY S.SHIP_DATE DESC
    </cfquery>

    <style>
        .page-wrapper {
            max-width: 1100px;
            margin: 0 auto;
            padding: 2rem 2.5rem 3rem;
            font-family: "Segoe UI", Arial, sans-serif;
            color: #1f2933;
            background: linear-gradient(160deg, #f3f6fb 0%, #ffffff 100%);
            border-radius: 18px;
            box-shadow: 0 20px 45px rgba(15, 23, 42, 0.12);
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        .page-header h1 {
            margin: 0;
            font-size: 1.75rem;
            font-weight: 700;
            letter-spacing: 0.02em;
        }

        .page-subtitle {
            margin: 0.35rem 0 0;
            color: #52606d;
        }

        .pill {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.4rem 0.8rem;
            border-radius: 999px;
            background: rgba(99, 102, 241, 0.1);
            color: #4338ca;
            font-size: 0.85rem;
        }

        .pill-active {
            background: rgba(99, 102, 241, 0.08);
            border: 1px solid rgba(99, 102, 241, 0.2);
        }

        .search-card {
            display: flex;
            flex-wrap: wrap;
            gap: 1.5rem;
            background: #ffffff;
            padding: 1.5rem;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08);
            margin-bottom: 2rem;
        }

        .search-input-group {
            flex: 1 1 320px;
            min-width: 260px;
        }

        .search-input-group label {
            display: block;
            font-size: 0.85rem;
            letter-spacing: 0.02em;
            text-transform: uppercase;
            color: #64748b;
            margin-bottom: 0.5rem;
        }

        .search-field {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            border: 1px solid #d5dce5;
            border-radius: 12px;
            padding: 0.65rem 0.9rem;
            background: #f8fafc;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .search-field:focus-within {
            border-color: #6366f1;
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.12);
            background: #ffffff;
        }

        .search-field input {
            flex: 1;
            border: none;
            background: transparent;
            font-size: 1rem;
            outline: none;
            color: #1f2933;
        }

        .search-field input::placeholder {
            color: #9aa5b1;
        }

        .search-icon {
            font-size: 1rem;
            color: #94a3b8;
        }

        .search-actions {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.4rem;
            padding: 0.65rem 1.2rem;
            border-radius: 10px;
            font-weight: 600;
            text-decoration: none;
            transition: transform 0.16s ease, box-shadow 0.16s ease;
            cursor: pointer;
            border: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, #6366f1 0%, #4338ca 100%);
            color: #ffffff;
            box-shadow: 0 8px 18px rgba(99, 102, 241, 0.28);
        }

        .btn-secondary {
            background: #e2e8f0;
            color: #334155;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 22px rgba(15, 23, 42, 0.15);
        }

        .summary-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 1rem;
            color: #475569;
        }

        .summary-bar strong {
            font-size: 1.05rem;
            color: #1f2933;
        }

        .guide-trigger-bar {
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
            margin: 0 0 1.75rem;
        }

        .btn-ghost {
            background: #ffffff;
            border: 1px solid rgba(99, 102, 241, 0.2);
            color: #4338ca;
            box-shadow: 0 10px 18px rgba(99, 102, 241, 0.12);
        }

        .btn-ghost:hover {
            background: rgba(99, 102, 241, 0.08);
        }

        .guide-modal {
            position: fixed;
            inset: 0;
            display: none;
            align-items: center;
            justify-content: center;
            background: rgba(15, 23, 42, 0.45);
            padding: 2rem;
            z-index: 9999;
        }

        .guide-modal.is-active {
            display: flex;
        }

        .guide-modal__dialog {
            width: min(960px, 100%);
            background: #ffffff;
            border-radius: 18px;
            box-shadow: 0 24px 48px rgba(15, 23, 42, 0.25);
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .guide-modal__header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 1.5rem;
            border-bottom: 1px solid #e2e8f0;
            background: linear-gradient(135deg, rgba(99, 102, 241, 0.12), rgba(79, 70, 229, 0.08));
        }

        .guide-modal__title {
            margin: 0;
            font-size: 1.1rem;
            color: #312e81;
        }

        .guide-modal__close {
            background: transparent;
            border: none;
            font-size: 1.5rem;
            color: #475569;
            cursor: pointer;
        }

        .guide-frame {
            width: 100%;
            height: 70vh;
            border: 0;
        }

        body.modal-open {
            overflow: hidden;
        }

        .table-container {
            overflow-x: auto;
            background: #ffffff;
            border-radius: 18px;
            box-shadow: 0 18px 35px rgba(15, 23, 42, 0.12);
        }

        .despatch-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.95rem;
        }

        .despatch-table thead th {
            background: linear-gradient(135deg, rgba(99, 102, 241, 0.12), rgba(79, 70, 229, 0.08));
            color: #312e81;
            font-weight: 700;
            letter-spacing: 0.05em;
            padding: 0.9rem 1rem;
            text-transform: uppercase;
            border-bottom: 1px solid #e2e8f0;
            white-space: nowrap;
        }

        .despatch-table tbody td {
            padding: 0.85rem 1rem;
            border-bottom: 1px solid #edf2f7;
        }

        .despatch-table tbody tr:last-child td {
            border-bottom: none;
        }

        .despatch-table tbody tr:hover {
            background: rgba(99, 102, 241, 0.05);
        }

        .despatch-table a {
            color: #4c51bf;
            font-weight: 600;
            text-decoration: none;
        }

        .despatch-table a:hover {
            text-decoration: underline;
        }

        .status-cell {
            text-align: center;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 128px;
            padding: 0.35rem 0.75rem;
            border-radius: 999px;
            font-size: 0.85rem;
            font-weight: 600;
            letter-spacing: 0.02em;
        }

        .status-ok {
            background: rgba(34, 197, 94, 0.16);
            color: #047857;
        }

        .status-partial {
            background: rgba(251, 191, 36, 0.2);
            color: #92400e;
        }

        .status-over {
            background: rgba(59, 130, 246, 0.18);
            color: #1d4ed8;
        }

        .status-missing {
            background: rgba(239, 68, 68, 0.18);
            color: #b91c1c;
        }

        .badge-pill {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.25rem 0.55rem;
            border-radius: 999px;
            background: rgba(148, 163, 184, 0.16);
            color: #475569;
            font-size: 0.8rem;
        }

        .legend {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
            margin-top: 1.25rem;
            color: #475569;
        }

        .legend-item {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.4rem 0.8rem;
            background: #ffffff;
            border-radius: 999px;
            box-shadow: 0 6px 12px rgba(15, 23, 42, 0.08);
            font-size: 0.85rem;
        }

        .legend-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }

        .legend-ok { background: #16a34a; }
        .legend-partial { background: #f59e0b; }
        .legend-over { background: #2563eb; }
        .legend-missing { background: #ef4444; }

        .despatch-empty {
            margin-top: 1.5rem;
            font-style: italic;
            color: #64748b;
            text-align: center;
        }

        @media (max-width: 768px) {
            .page-wrapper {
                padding: 1.75rem 1.25rem 2.5rem;
            }

            .status-badge {
                min-width: unset;
            }

            .search-actions {
                width: 100%;
                justify-content: flex-end;
            }
        }
    </style>

    <cfif getDespatches.recordCount GT 0>
        <div class="summary-bar">
            <strong><cfoutput>#EncodeForHTML(getDespatches.recordCount)#</cfoutput> sevk listelendi</strong>
            <div class="badge-pill">En güncel tarih: <cfoutput>#EncodeForHTML(DateFormat(getDespatches.SHIP_DATE[1], "dd.mm.yyyy"))#</cfoutput></div>
        </div>

        <div class="table-container">
            <table class="despatch-table">
                <thead>
                    <tr>
                        <th>Sevk ID</th>
                        <th>Sevk No</th>
                        <th>Firma</th>
                        <th>Sevk Tarihi</th>
                        <th>Toplam Tutar</th>
                        <th>Garanti Girişi</th>
                        <th>Durum</th>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput query="getDespatches">
                        <cfset formattedTotal = tlformat(TOTAL_AMOUNT)>
                        <cfset statusLabel = "Giriş Yok">
                        <cfset statusClass = "status-missing">

                        <cfif GUARANTY_COUNT GT 0>
                            <cfif GUARANTY_COUNT EQ TOTAL_AMOUNT>
                                <cfset statusLabel = "Tamamlandı">
                                <cfset statusClass = "status-ok">
                            <cfelseif GUARANTY_COUNT LT TOTAL_AMOUNT>
                                <cfset statusLabel = "Eksik Giriş">
                                <cfset statusClass = "status-partial">
                            <cfelseif GUARANTY_COUNT GT TOTAL_AMOUNT>
                                <cfset statusLabel = "Fazla Giriş">
                                <cfset statusClass = "status-over">
                            </cfif>
                        </cfif>

                        <tr>
                            <td>#EncodeForHTML(SHIP_ID)#</td>
                            <td>
                                <a href="/index.cfm?fuseaction=purchase._emptypopup_read_despatch_rows_pbs&shipId=#EncodeForURL(SHIP_ID)#">
                                    #EncodeForHTML(SHIP_NUMBER)#
                                </a>
                            </td>
                            <td>#EncodeForHTML(NICKNAME)#</td>
                            <td>#EncodeForHTML(DateFormat(SHIP_DATE, "dd.mm.yyyy"))#</td>
                            <td>#EncodeForHTML(formattedTotal)#</td>
                            <td>#EncodeForHTML(tlformat(GUARANTY_COUNT))#</td>
                            <td class="status-cell">
                                <span class="status-badge #statusClass#">#statusLabel#</span>
                            </td>
                        </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>

        <div class="legend">
            <span class="legend-item"><span class="legend-dot legend-ok"></span> Tamamlandı</span>
            <span class="legend-item"><span class="legend-dot legend-partial"></span> Eksik Giriş</span>
            <span class="legend-item"><span class="legend-dot legend-over"></span> Fazla Giriş</span>
            <span class="legend-item"><span class="legend-dot legend-missing"></span> Giriş Yok</span>
        </div>
    <cfelse>
        <p class="despatch-empty">Listelenecek sevk kaydı bulunamadı.</p>
    </cfif>

    <div id="guide-modal" class="guide-modal" role="dialog" aria-modal="true" aria-labelledby="guide-modal-title">
        <div class="guide-modal__dialog">
            <div class="guide-modal__header">
                <h2 id="guide-modal-title" class="guide-modal__title">Kılavuz</h2>
                <button id="guide-modal-close" class="guide-modal__close" type="button" aria-label="Pencereyi kapat">×</button>
            </div>
            <iframe id="guide-frame" class="guide-frame" title="Sevk kılavuzu"></iframe>
        </div>
    </div>
</div>

<script>
    (function () {
        var modal = document.getElementById("guide-modal");
        if (!modal) {
            return;
        }

        var frame = document.getElementById("guide-frame");
        var titleEl = document.getElementById("guide-modal-title");
        var closeBtn = document.getElementById("guide-modal-close");

        function openGuide(url, title) {
            if (frame) {
                frame.src = url;
            }
            if (titleEl) {
                titleEl.textContent = title || "Kılavuz";
            }
            modal.classList.add("is-active");
            document.body.classList.add("modal-open");
        }

        function closeGuide() {
            modal.classList.remove("is-active");
            document.body.classList.remove("modal-open");
            if (frame) {
                frame.src = "";
            }
        }

        document.querySelectorAll("[data-guide-url]").forEach(function (trigger) {
            trigger.addEventListener("click", function () {
                var url = trigger.getAttribute("data-guide-url");
                var title = trigger.getAttribute("data-guide-title");
                openGuide(url, title);
            });
        });

        closeBtn && closeBtn.addEventListener("click", closeGuide);

        modal.addEventListener("click", function (event) {
            if (event.target === modal) {
                closeGuide();
            }
        });

        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape" && modal.classList.contains("is-active")) {
                closeGuide();
            }
        });
    })();
</script>

<script>
    (function () {
        var scanBuffer = "";
        var timeoutId = null;
        var bufferResetDelay = 250;

        function resetBuffer() {
            scanBuffer = "";
            if (timeoutId) {
                clearTimeout(timeoutId);
                timeoutId = null;
            }
        }

        function handleScanKey(event) {
            var target = event.target;
            var tagName = target && target.tagName ? target.tagName.toLowerCase() : "";

            if (tagName === "input" || tagName === "textarea" || target.isContentEditable) {
                return;
            }

            if (event.key === "Shift" || event.key === "Control" || event.key === "Alt" || event.key === "Meta") {
                return;
            }

            if (event.key === "Enter") {
                if (scanBuffer.length === 0) {
                    return;
                }

                console.log("Raw scan:", scanBuffer);

                var keyword = scanBuffer;
                var parsed;
                try {
                    parsed = JSON.parse(scanBuffer);
                    if (parsed && parsed.no) {
                        keyword = parsed.no;
                    }
                } catch (error) {
                    parsed = null;
                }

                console.log("Parsed keyword:", keyword, parsed ? parsed : "(not JSON)");
                 if (parsed && parsed.no) {
                        document.pform.search.value=keyword;
                        document.pform.submit();
                    }
                resetBuffer();
                return;
            }

            if (event.key.length === 1 && !event.ctrlKey && !event.altKey && !event.metaKey) {
                scanBuffer += event.key;
                if (timeoutId) {
                    clearTimeout(timeoutId);
                }
                timeoutId = setTimeout(resetBuffer, bufferResetDelay);
            }
        }

        document.addEventListener("keydown", handleScanKey);
    })();
</script>