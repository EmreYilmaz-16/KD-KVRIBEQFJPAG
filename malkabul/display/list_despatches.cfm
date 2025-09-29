<cfparam name="url.search" default="">
<form method="get" action="/index.cfm?fuseaction=purchase._emptypopup_list_purchase_despatches_pbs" style="margin-bottom: 1rem;">
    <label for="search">Ara:</label>
    <input type="text" id="search" name="search" placeholder="Sevk No veya Firma" value="<cfoutput>#EncodeForHTML(URL.search)#</cfoutput>">
    <button type="submit">Ara</button>
</form>

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
ORDER BY S.SHIP_DATE DESC;

       <cfif StructKeyExists(URL, 'search') AND Len(Trim(URL.search)) GT 0>
           AND (S.SHIP_NUMBER LIKE '%#Trim(URL.search)#%' OR C.NICKNAME LIKE '%#Trim(URL.search)#%')
       </cfif>
</cfquery>

<style>
    .despatch-table {
        border-collapse: collapse;
        width: 100%;
        margin-top: 1rem;
        font-family: Arial, Helvetica, sans-serif;
        font-size: 0.95rem;
    }

    .despatch-table th,
    .despatch-table td {
        border: 1px solid #dcdcdc;
        padding: 0.6rem 0.8rem;
        text-align: left;
    }

    .despatch-table thead th {
        background-color: #f5f5f5;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.03em;
    }

    .despatch-table tbody tr:nth-child(even) {
        background-color: #fafafa;
    }

    .despatch-empty {
        margin-top: 1.5rem;
        font-style: italic;
        color: #666;
    }
</style>

<cfif getDespatches.recordCount GT 0>
    <table class="despatch-table">
        <thead>
            <tr>
                <th>Sevk ID</th>
                <th>Sevk No</th>
                <th>Firma</th>
                <th>Sevk Tarihi</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <cfoutput query="getDespatches">
                <tr>
                    <td>#EncodeForHTML(SHIP_ID)#</td>
                    <td><a href="/index.cfm?fuseaction=purchase._emptypopup_read_despatch_rows_pbs&shipId=#EncodeForURL(SHIP_ID)#">"#EncodeForHTML(SHIP_NUMBER)#</a></td>
                    <td>#EncodeForHTML(NICKNAME)#</td>
                    <td>#EncodeForHTML(DateFormat(SHIP_DATE, "dd.mm.yyyy"))#</td>
                </tr>
            </cfoutput>
        </tbody>
    </table>
<cfelse>
    <p class="despatch-empty">Listelenecek sevk kaydı bulunamadı.</p>
</cfif>

