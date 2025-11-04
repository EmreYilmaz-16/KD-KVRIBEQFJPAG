<cfparam name="attributes.is_submit" default="0">

<cfscript>
function formatTl(numericValue) {
    if (IsNumeric(numericValue)) {
        return NumberFormat(numericValue, "999999999.00");
    }
    return "0.00";
}

function resolveCompanyName(companyId) {
    var companyName = "";
    if (Val(companyId) GT 0) {
        try {
            var companyQuery = QueryExecute(
                "SELECT TOP 1 NICKNAME FROM w3Qa.COMPANY WHERE COMPANY_ID = ?",
                [companyId],
                {datasource = dsn3}
            );
            if (companyQuery.RecordCount) {
                companyName = companyQuery.NICKNAME;
            }
        } catch(any e) {
            companyName = "Belirtilmedi";
        }
    }
    return Len(Trim(companyName)) ? companyName : "Belirtilmedi";
}
</cfscript>
<CFSET successMessage="">
<cfif attributes.is_submit EQ 1>
    <cfif StructKeyExists(form, "IID") AND Len(form.IID)>
        <cfloop list="#form.IID#" index="sid">
            <cfquery name="insert_to_pallet" datasource="#dsn3#">
                INSERT INTO w3Qa_1.SHIPPING_PALLET_SVK_PBS
                    (PALLET_ID, ORDER_ID, RECORD_DATE, RECORD_EMP)
                VALUES
                    (
                        <cfqueryparam value="#attributes.pallet_id#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#sid#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
                        <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">
                    )
            </cfquery>
        </cfloop>
        <cfset successMessage = "Seçilen sevk kayıtları palete eklendi.">
    <cfelse>
        <cfset errorMessage = "Herhangi bir sevk kaydı seçilmedi.">
    </cfif>
</cfif>

<cfquery name="getPaletBilgi" datasource="#dsn3#">
    SELECT P.ID, P.PALLET_CODE, P.PALLET_TYPE, P.COMPANY_ID, 
           PT.PALET_TYPE, P.RECORD_DATE
    FROM w3Qa_1.SHIPPING_PALLETS_PBS P
    LEFT JOIN w3Qa.PALET_TYPES_PBS PT ON PT.ID = P.PALLET_TYPE
    WHERE P.ID = <cfqueryparam value="#attributes.pallet_id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset paletCompanyName = resolveCompanyName(getPaletBilgi.COMPANY_ID)>

<cfquery name="get_hazir_sevk" datasource="#dsn3#">
    SELECT *
    FROM (
        SELECT
            ESR.SHIP_RESULT_ID,
            ESR.DELIVER_PAPER_NO,
            ESR.COMPANY_ID,
            ISNULL((
                SELECT SUM(AMOUNT) FROM (
                    SELECT AMOUNT
                    FROM #dsn#_#session.ep.PERIOD_YEAR#_1.STOCK_FIS SF
                    LEFT JOIN #dsn#_#session.ep.PERIOD_YEAR#_1.STOCK_FIS_ROW SFR ON SF.FIS_ID = SFR.FIS_ID
                    WHERE SF.REF_NO = ESR.DELIVER_PAPER_NO
                    UNION ALL
                    SELECT AMOUNT
                    FROM #dsn#_#(session.ep.PERIOD_YEAR)-1#_1.STOCK_FIS SF
                    LEFT JOIN #dsn#_#(session.ep.PERIOD_YEAR)-1#_1.STOCK_FIS_ROW SFR ON SF.FIS_ID = SFR.FIS_ID
                    WHERE SF.REF_NO = ESR.DELIVER_PAPER_NO
                ) RT
            ), 0) AS HAZ_MIK,
            ISNULL((
                SELECT SUM(ISNULL(ORDER_ROW_AMOUNT, 0))
                FROM #dsn3#.EZGI_SHIP_RESULT_ROW
                WHERE SHIP_RESULT_ID = ESR.SHIP_RESULT_ID
            ), 0) AS SVK_MIK,
            (
                SELECT COUNT(*)
                FROM w3Qa_1.SHIPPING_PALLET_SVK_PBS
                WHERE ORDER_ID = ESR.SHIP_RESULT_ID
                AND PALLET_ID = <cfqueryparam value="#attributes.pallet_id#" cfsqltype="cf_sql_integer">
            ) AS IN_PALLET
        FROM #dsn3#.EZGI_SHIP_RESULT ESR
    ) AS T
    WHERE HAZ_MIK = SVK_MIK
    AND COMPANY_ID = <cfqueryparam value="#getPaletBilgi.COMPANY_ID#" cfsqltype="cf_sql_integer">
    ORDER BY DELIVER_PAPER_NO DESC
</cfquery>

<cfset totalSelectable = 0>
<cfloop query="get_hazir_sevk">
    <cfif IN_PALLET EQ 0>
        <cfset totalSelectable++>
    </cfif>
</cfloop>

<cfoutput>
<cf_box title="Palete Sevkiyat Ekle">
    <style>
        .pallet-assign-wrap {
            font-family: "Segoe UI", Tahoma, Arial, sans-serif;
            color: ##1f2933;
            background: linear-gradient(135deg, ##f8fafc, ##eef2f7);
            border-radius: 16px;
            padding: 28px;
            border: 1px solid ##d8e2ef;
            box-shadow: 0 14px 30px rgba(15, 23, 42, 0.08);
        }

        .pallet-assign-header {
            display: flex;
            flex-direction: column;
            gap: 6px;
            margin-bottom: 22px;
        }

        .pallet-assign-header h2 {
            margin: 0;
            font-size: 22px;
            font-weight: 600;
            letter-spacing: 0.02em;
        }

        .pallet-meta {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 12px;
            background: ##ffffff;
            border: 1px solid ##cbd5e1;
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 20px;
            font-size: 13px;
        }

        .pallet-meta strong {
            color: ##0f172a;
            font-weight: 600;
        }

        .pallet-alert {
            border-radius: 10px;
            padding: 12px 16px;
            margin-bottom: 18px;
            font-size: 13px;
            line-height: 1.5;
        }

        .pallet-alert.success {
            background: ##dcfce7;
            border: 1px solid ##86efac;
            color: ##166534;
        }

        .pallet-alert.error {
            background: ##fee2e2;
            border: 1px solid ##fca5a5;
            color: ##b91c1c;
        }

        .pallet-actions-bar {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            align-items: center;
            margin-bottom: 14px;
        }

        .pallet-actions-bar button,
        .pallet-actions-bar input[type="submit"] {
            border-radius: 10px;
            border: none;
            padding: 12px 20px;
            font-size: 14px;
            font-weight: 600;
            letter-spacing: 0.04em;
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .pallet-actions-bar .primary {
            background: linear-gradient(135deg, ##22c55e, ##16a34a);
            color: ##ffffff;
            box-shadow: 0 10px 20px rgba(34, 197, 94, 0.2);
        }

        .pallet-actions-bar .primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 24px rgba(34, 197, 94, 0.28);
        }

        .pallet-actions-bar .secondary {
            background: ##f1f5f9;
            color: ##475569;
            border: 1px solid ##cbd5e1;
        }

        .pallet-actions-bar .secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 24px rgba(148, 163, 184, 0.2);
        }

        .pallet-table-wrapper {
            border: 1px solid ##cbd5e1;
            border-radius: 12px;
            overflow: hidden;
            background: ##ffffff;
        }

        table.pallet-table {
            width: 100%;
            border-collapse: collapse;
        }

        table.pallet-table thead {
            background: ##e2e8f0;
        }

        table.pallet-table th,
        table.pallet-table td {
            padding: 14px 16px;
            text-align: left;
            font-size: 13px;
            border-top: 1px solid ##e2e8f0;
        }

        table.pallet-table tbody tr:nth-child(even) {
            background: ##f8fafc;
        }

        table.pallet-table tbody tr:hover {
            background: ##eef2ff;
        }

        .badge-status {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            border-radius: 999px;
            padding: 4px 10px;
            font-size: 12px;
            font-weight: 600;
        }

        .badge-status.free {
            background: rgba(22, 163, 74, 0.1);
            color: ##15803d;
        }

        .badge-status.locked {
            background: rgba(220, 38, 38, 0.1);
            color: ##b91c1c;
        }

        .empty-state {
            padding: 36px;
            text-align: center;
            color: ##6b7280;
            font-size: 14px;
        }

        @media (max-width: 680px) {
            .pallet-actions-bar {
                flex-direction: column;
                align-items: stretch;
            }

            .pallet-actions-bar button,
            .pallet-actions-bar input[type="submit"] {
                width: 100%;
            }
        }
    </style>

    <div class="pallet-assign-wrap">
        <div class="pallet-assign-header">
            <h2>Palet: #HTMLEditFormat(getPaletBilgi.PALLET_CODE)#</h2>
            <span>Palet tipi: #HTMLEditFormat(getPaletBilgi.PALET_TYPE)#</span>
        </div>

        <div class="pallet-meta">
            <div><strong>Şirket:</strong> #HTMLEditFormat(paletCompanyName)#</div>
            <div><strong>Palet ID:</strong> #getPaletBilgi.ID#</div>
            <div><strong>Oluşturma Tarihi:</strong> #DateFormat(getPaletBilgi.RECORD_DATE, "dd.mm.yyyy")# #TimeFormat(getPaletBilgi.RECORD_DATE, "HH:nn")#</div>
            <div><strong>Seçilebilir Sevk:</strong> #totalSelectable#</div>
        </div>

        <cfif Len(successMessage)>
            <div class="pallet-alert success">#successMessage#</div>
        </cfif>

        <cfif Len(errorMessage)>
            <div class="pallet-alert error">#errorMessage#</div>
        </cfif>

        <CFFORM method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
            <div class="pallet-actions-bar">
                <div>
                    <input type="checkbox" id="select_all" class="bulk-toggle" onclick="toggleAllPalletRows(this);" <cfif totalSelectable EQ 0>disabled</cfif>>
                    <label for="select_all">Tümünü Seç</label>
                </div>
                <div class="actions">
                    <button type="button" class="secondary" onclick="clearSelectedRows();" <cfif totalSelectable EQ 0>disabled</cfif>>Seçimleri Temizle</button>
                    <input type="submit" name="submit_add_to_pallet" value="Palete Ekle" class="primary" <cfif totalSelectable EQ 0>disabled</cfif>>
                </div>
            </div>

            <div class="pallet-table-wrapper">
                <table class="pallet-table">
                    <thead>
                        <tr>
                            <th></th>
                            <th>Teslimat Belge No</th>
                            <th>Hazır Miktar</th>
                            <th>Sevk Miktarı</th>
                            <th>Durum</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfif get_hazir_sevk.RecordCount EQ 0>
                            <tr>
                                <td colspan="5" class="empty-state">Bu paletle eşleşen sevkiyat kaydı bulunamadı.</td>
                            </tr>
                        <cfelse>
                            <cfloop query="get_hazir_sevk">
                                <cfset isLocked = (IN_PALLET GT 0)>
                                <tr class="pallet-row">
                                    <td>
                                        <input
                                            type="checkbox"
                                            name="IID"
                                            value="#SHIP_RESULT_ID#"
                                            class="row-checkbox"
                                            <cfif isLocked>checked disabled</cfif>
                                        >
                                    </td>
                                    <td>#HTMLEditFormat(DELIVER_PAPER_NO)#</td>
                                    <td>#formatTl(HAZ_MIK)#</td>
                                    <td>#formatTl(SVK_MIK)#</td>
                                    <td>
                                        <span class="badge-status #IIf(isLocked, "locked", "free")#">
                                            #IIf(isLocked, "Palete Eklenmiş", "Müsait")#
                                        </span>
                                    </td>
                                </tr>
                            </cfloop>
                        </cfif>
                    </tbody>
                </table>
            </div>

            <input type="hidden" name="pallet_id" value="#attributes.pallet_id#">
            <input type="hidden" name="is_submit" value="1">
        </CFFORM>
    </div>
</cf_box>

<script>
    function toggleAllPalletRows(source) {
        var checkboxes = document.querySelectorAll('.pallet-row .row-checkbox');
        checkboxes.forEach(function (checkbox) {
            if (!checkbox.disabled) {
                checkbox.checked = source.checked;
            }
        });
    }

    function clearSelectedRows() {
        document.querySelectorAll('.pallet-row .row-checkbox').forEach(function (checkbox) {
            if (!checkbox.disabled) {
                checkbox.checked = false;
            }
        });
        var selectAll = document.getElementById('select_all');
        if (selectAll) {
            selectAll.checked = false;
        }
    }
</script>
</cfoutput>


