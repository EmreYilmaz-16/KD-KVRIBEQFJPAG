<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Şara Rapor Detayları</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    
    <style>
        body {
            background-color: #f8f9fa;
        }
        .container {
            margin-top: 30px;
        }
        .table-container {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>


<cfdump var="#attributes#" label="URL Parameters">



<cfquery name="getData" datasource="w3Qa_1">
    SELECT SUM(SOUT) AS BS,S1,P1, PRODUCT_CODE_2, PRODUCT_NAME, PRODUCT_CODE FROM (
SELECT  
S.STOCK_ID S1,
ORDR.ORDER_ROW_CURRENCY,
S.PRODUCT_ID P1,
S.PRODUCT_CODE_2,
S.PRODUCT_NAME,
S.PRODUCT_CODE,
O.COMPANY_ID,
RESERVE_STOCK_IN-STOCK_IN AS SIN,
RESERVE_STOCK_OUT-STOCK_OUT AS SOUT
FROM w3Qa_1.ORDER_ROW_RESERVED AS ORR
LEFT JOIN w3Qa_1.ORDER_ROW AS ORDR ON ORDR.WRK_ROW_ID=ORR.ORDER_WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDERS AS O ON O.ORDER_ID=ORDR.ORDER_ID
LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID=ORDR.STOCK_ID
WHERE O.PURCHASE_SALES=1 AND ORDR.ORDER_ROW_CURRENCY NOT IN (-9,-10,-3) AND O.RESERVED=1
AND O.COMPANY_ID=#URL.company# 
) AS T WHERE SOUT >0  --AND P1=5350
GROUP BY S1,P1, PRODUCT_CODE_2, PRODUCT_NAME, PRODUCT_CODE
</cfquery>
<cfset pid_list=valueList(getData.P1)>

<cfquery name="getData2" datasource="w3Qa_1">
    SELECT SUM(SIN) AS BS,S1,P1,PRODUCT_CODE_2,PRODUCT_NAME,
(SELECT SUM(ISNULL(STOCK_IN,0)-ISNULL(STOCK_OUT,0)) FROM w3Qa_2026_1.STOCKS_ROW AS SR WHERE SR.STOCK_ID=T.P1) AS BK FROM (
SELECT  
ORDR.STOCK_ID S1,
ORDR.ORDER_ROW_CURRENCY,
S.PRODUCT_ID P1,
S.PRODUCT_CODE_2,
S.PRODUCT_NAME,
S.PRODUCT_CODE,
O.ORDER_NUMBER,O.PURCHASE_SALES,
O.ORDER_ID O1,
O.RESERVED,
  ORR.ORDER_ID,
RESERVE_STOCK_IN-STOCK_IN AS SIN,
RESERVE_STOCK_OUT-STOCK_OUT AS SOUT
FROM w3Qa_1.ORDER_ROW_RESERVED AS ORR
LEFT JOIN w3Qa_1.ORDER_ROW AS ORDR ON ORDR.WRK_ROW_ID=ORR.ORDER_WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDERS AS O ON O.ORDER_ID=ORDR.ORDER_ID
LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID=ORDR.STOCK_ID
WHERE O.PURCHASE_SALES=0 AND ORDR.ORDER_ROW_CURRENCY NOT IN (-9,-10,-3) AND O.RESERVED=1
) AS T WHERE SIN >0  AND P1 IN (#pid_list#)
GROUP BY S1,P1,PRODUCT_CODE_2,PRODUCT_NAME,PRODUCT_CODE
ORDER BY P1
</cfquery>

<cfset BAKIYE_MAP = {}>
<cfset VERILEN_SIPARIS_MAP = {}>
<cfloop query="getData2">
    <cfset BAKIYE_MAP["-#P1#"] = BK>
    <cfif NOT structKeyExists(VERILEN_SIPARIS_MAP, "-#P1#")>
        <cfset VERILEN_SIPARIS_MAP["-#P1#"] = 0>
    </cfif>
    <cfset VERILEN_SIPARIS_MAP["-#P1#"] += BS>
</cfloop>
<!----
<cfdump var="#getData2#" label="Get Data 2">
<cfdump var="#getData#" label="Get Data 1">
<cfdump var="#BAKIYE_MAP#" label="BAKIYE_MAP">
<cfdump var="#VERILEN_SIPARIS_MAP#" label="VERILEN_SIPARIS_MAP">
----->
<div class="container">
    <div class="table-container">
        <h2 class="mb-4"><i class="bi bi-table"></i> Şara Rapor Detayları</h2>
        
        <div class="table-responsive">
            <table class="table table-striped table-hover">
                <thead class="table-dark">
                    <tr>
                        <th>ÜRÜN KODU</th>
                        <th>ÜRÜN KODU 2</th>
                        <th>ÜRÜN ADI</th>
                        <th>STOKTAKİ MİKTAR</th>
                        <th>ALINAN SİPARİŞ REZERV</th>
                        <th>Sipariş Miktarı</th>                                
                        <th>HAZIR</th>
                        <th>TERMIN</th>
                        <th>VERİLMEYEN</th>
                    </tr>
                </thead>
                <tbody>
                    <cfloop query="getData">
                        <cfoutput>
                        <cfset bakiyeDegeri = structKeyExists(BAKIYE_MAP, "-#P1#") ? BAKIYE_MAP["-#P1#"] : 0>
                        <cfset verilenSiparisDegeri = structKeyExists(VERILEN_SIPARIS_MAP, "-#P1#") ? VERILEN_SIPARIS_MAP["-#P1#"] : 0>
                        <tr>
                            <td><strong>#PRODUCT_CODE#</strong></td>
                            <td><strong>#PRODUCT_CODE_2#</strong></td>
                            <td>#PRODUCT_NAME#</td>            
                            <td><span class="badge bg-warning">#bakiyeDegeri#</span></td>
                            <td><span class="badge bg-success">#verilenSiparisDegeri#</span></td>
                            <td><span class="badge bg-primary">#BS#</span></td>                            
                            
                            <td>
                                <input type="text" class="form-control form-control-sm" name="hazir_#S1#" id="hazir_#S1#" placeholder="HAZIR değeri">
                            </td>
                            <td>
                                <input type="text" class="form-control form-control-sm" name="termin_#S1#" id="termin_#S1#" placeholder="TERMIN değeri">
                            </td>
                            <td>
                                <input type="text" class="form-control form-control-sm" name="verilmeyen_#S1#" id="verilmeyen_#S1#" placeholder="Verilmeyen değeri">
                            </td>
                        </tr>
                        </cfoutput>
                    </cfloop>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Bootstrap 5 JS Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>