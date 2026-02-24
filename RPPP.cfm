<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ürün Satış Raporu</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        body {
            background-color: #f8f9fa;
        }
        .table-container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            padding: 20px;
            margin: 20px 0;
        }
        .table thead th {
            background-color: #0d6efd;
            color: white;
            font-weight: 600;
            position: sticky;
            top: 0;
            z-index: 10;
        }
        .table-responsive {
            max-height: 80vh;
            overflow-y: auto;
        }
        .ortalama-cell {
            background-color: #e7f3ff;
            font-weight: 600;
        }
        .yillik-toplam-cell {
            background-color: #fff3cd;
            font-weight: 700;
            border-left: 3px solid #ffc107 !important;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row mt-4">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h2><i class="bi bi-graph-up"></i> Ürün Satış Raporu</h2>
                    <button class="btn btn-success" onclick="exportToExcel()">
                        <i class="bi bi-file-earmark-excel"></i> Excel'e Aktar
                    </button>
                </div>
            </div>
        </div>

<cfquery name="siprapor" datasource="w3Qa">
    SELECT SUM(QUANTITY) AS SMIK,SYIL,SAY,PRODUCT_NAME,PRODUCT_ID,PRODUCT_CODE,PRODUCT_CODE_2 FROM (
SELECT  S.PRODUCT_NAME,S.PRODUCT_ID,ORR.QUANTITY,YEAR(ORDER_DATE) SYIL,MONTH(ORDER_DATE)SAY,
S.PRODUCT_CODE,S.PRODUCT_CODE_2
 FROM w3Qa_1.ORDERS AS O 
LEFT JOIN w3Qa_1.ORDER_ROW AS ORR ON O.ORDER_ID=ORR.ORDER_ID
LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID=ORR.STOCK_ID
WHERE S.PRODUCT_NAME IS NOT NULL AND O.PURCHASE_SALES=1
) AS OSS 
GROUP BY SYIL,SAY,PRODUCT_NAME,PRODUCT_ID,PRODUCT_CODE,PRODUCT_CODE_2
ORDER BY SYIL,SAY
</cfquery>

<cfquery name="yillikOrtalama" datasource="w3Qa">
    SELECT PRODUCT_ID, PRODUCT_NAME, PRODUCT_CODE, PRODUCT_CODE_2,
           AVG(MONTHLY_TOTAL) AS YILLIK_ORTALAMA,
           SUM(MONTHLY_TOTAL) AS TOPLAM_SATIS,
           COUNT(*) AS AY_SAYISI
    FROM (
        SELECT SUM(QUANTITY) AS MONTHLY_TOTAL, S.PRODUCT_NAME, S.PRODUCT_ID, S.PRODUCT_CODE, S.PRODUCT_CODE_2
        FROM w3Qa_1.ORDERS AS O 
        LEFT JOIN w3Qa_1.ORDER_ROW AS ORR ON O.ORDER_ID=ORR.ORDER_ID
        LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID=ORR.STOCK_ID
        WHERE S.PRODUCT_NAME IS NOT NULL AND O.PURCHASE_SALES=1
        GROUP BY YEAR(ORDER_DATE), MONTH(ORDER_DATE), S.PRODUCT_NAME, S.PRODUCT_ID, S.PRODUCT_CODE, S.PRODUCT_CODE_2
    ) AS MONTHLY_SALES
    GROUP BY PRODUCT_ID, PRODUCT_NAME, PRODUCT_CODE, PRODUCT_CODE_2
    ORDER BY PRODUCT_NAME
</cfquery>

<cfset PRODCT_SALE_MAP = structNew()>
<cfset YILLIK_ORTALAMA_MAP = structNew()>

<cfloop query="siprapor">
    <cfset PRODCT_SALE_MAP["#SYIL#-#SAY#-#PRODUCT_ID#"] = SMIK>
</cfloop>

<cfloop query="yillikOrtalama">
    <cfset YILLIK_ORTALAMA_MAP[PRODUCT_ID] = YILLIK_ORTALAMA>
</cfloop>

<cfset START_YEAR=YEAR(dateAdd("m",-12,now()))>
<cfset START_MONTH=MONTH(dateAdd("m",-12,now()))>
<cfset END_YEAR=YEAR(now())>
<cfset END_MONTH=MONTH(now())>

<div class="row">
    <div class="col-12">
        <div class="table-container">
            <div class="table-responsive">
                <table class="table table-striped table-hover table-bordered align-middle" id="salesTable">
                    <thead class="table-primary">
                        <tr>
                            <th class="text-center">ETA Kodu</th>
                            <th class="text-center">Ürün Kodu</th>
                            <th>Ürün</th>
                            <th class="text-center">Yıllık Ortalama</th>
                            <cfset currentDate = createDate(START_YEAR, START_MONTH, 1)>
                            <cfset endDate = createDate(END_YEAR, END_MONTH, 1)>
                            <cfset currentYear = year(currentDate)>
                            <cfloop condition="dateCompare(currentDate, endDate) LTE 0">
                                <th class="text-center"><cfoutput>#year(currentDate)#-#month(currentDate)#</cfoutput></th>
                                <cfset nextDate = dateAdd("m", 1, currentDate)>
                                <cfif year(nextDate) NEQ currentYear OR dateCompare(currentDate, endDate) EQ 0>
                                    <th class="text-center table-warning"><cfoutput>#currentYear# Toplam</cfoutput></th>
                                    <cfset currentYear = year(nextDate)>
                                </cfif>
                                <cfset currentDate = nextDate>
                            </cfloop>
                        </tr>
                    </thead>
                    <tbody>
                    <tbody>
<cfoutput query="siprapor">
                        <tr>
                            <td class="text-center">
                                #PRODUCT_CODE_2#
                            </td>
                            <td class="text-center">
                                #PRODUCT_CODE#
                            </td>
                            <td>
                                #PRODUCT_NAME#
                            </td>
                            <td class="text-center ortalama-cell">
                                #structKeyExists(YILLIK_ORTALAMA_MAP, PRODUCT_ID) ? numberFormat(YILLIK_ORTALAMA_MAP[PRODUCT_ID], "999,999.99") : 0#
                            </td>
                            <cfset currentDate = createDate(START_YEAR, START_MONTH, 1)>
                            <cfset endDate = createDate(END_YEAR, END_MONTH, 1)>
                            <cfset currentYear = year(currentDate)>
                            <cfset yearTotal = 0>
                            <cfloop condition="dateCompare(currentDate, endDate) LTE 0">
                                <cfset mapKey = "#year(currentDate)#-#month(currentDate)#-#PRODUCT_ID#">
                                <cfset monthValue = structKeyExists(PRODCT_SALE_MAP, mapKey) ? VAL(PRODCT_SALE_MAP[mapKey]) : 0>
                                <cfset yearTotal = yearTotal + monthValue>
                                <td class="text-end">
                                    #monthValue#
                                </td>
                                <cfset nextDate = dateAdd("m", 1, currentDate)>
                                <cfif year(nextDate) NEQ currentYear OR dateCompare(currentDate, endDate) EQ 0>
                                    <td class="text-end yillik-toplam-cell">
                                        #numberFormat(yearTotal, "999,999")#
                                    </td>
                                    <cfset currentYear = year(nextDate)>
                                    <cfset yearTotal = 0>
                                </cfif>
                                <cfset currentDate = nextDate>
                            </cfloop>
                        </tr>
</cfoutput>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<script>
function exportToExcel() {
    const table = document.getElementById('salesTable');
    const wb = XLSX.utils.table_to_book(table, {sheet: "Satış Raporu"});
    XLSX.writeFile(wb, 'urun_satis_raporu_' + new Date().toISOString().slice(0,10) + '.xlsx');
}
</script>
</body>
</html>