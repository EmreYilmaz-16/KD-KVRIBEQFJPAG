<cfparam name="attributes.brand_id" default="6">
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Satış Raporu</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            padding: 20px;
        }
        .table-responsive {
            margin-top: 20px;
        }
        .year-total {
            background-color: #e6f3ff !important;
        }
        .year-avg {
            background-color: #fff3e6 !important;
        }
        .company-order {
            background-color: #ffe6e6 !important;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <h1 class="mb-4">Satış Raporu</h1>

<cfset dsn3="w3Qa_1">
<cfform name="reportForm" method="post" action="sarapor_2.cfm">
    <div style="display:none" class="form-group" id="item-brand_id">
                        <label>Marka </label>
 <select name="brand_id" class="form-control">
    <option value="">Tümü</option>
    <cfquery name="brandQuery" datasource="#dsn3#">
        SELECT DISTINCT BRAND_ID, BRAND_NAME
        FROM w3Qa_product.PRODUCT_BRANDS
        </cfquery>
    <cfoutput query="brandQuery">
        <option value="#BRAND_ID#">#BRAND_NAME#</option>
    </cfoutput>
</select>

                    </div>
                    <div class="form-group">
                        <label>Sadece Satışı Olanlar Gelsin</label>
                        <input type="checkbox" name="only_sales" id="only_sales" value="1">
                    </div>
                    <input type="submit" value="Raporu Göster">
</cfform>
<cfquery name="RAPOR_SQL" datasource="#dsn3#">
   SELECT * FROM (
    SELECT
    PR.PRODUCT_NAME,
    PR.PRODUCT_CODE,
    PR.PRODUCT_ID,
    PR.BRAND_ID,
    (SELECT SUM(ISNULL(STOCK_IN,0)-ISNULL(STOCK_OUT,0)) FROM w3Qa_2026_1.STOCKS_ROW AS SR WHERE SR.STOCK_ID=PR.PRODUCT_ID) AS BK,
    JSON_QUERY(VSIP.GT)   AS VSIP,
    JSON_QUERY(RPR.RPR) AS RPR,
    JSON_QUERY(ASIP.ASIP) AS ASIP
FROM w3Qa_1.STOCKS AS PR

OUTER APPLY (
    SELECT (
        SELECT
            CAST(SUM(T.SIN) AS DECIMAL(18,2)) AS BS,
            T.S1,
            T.P1,
            T.ODM,
            T.ODY
        FROM (
            SELECT
                ORDR.STOCK_ID AS S1,
                ORDR.PRODUCT_ID AS P1,
                YEAR(O.ORDER_DATE)  AS ODY,
                MONTH(O.ORDER_DATE) AS ODM,
                (RESERVE_STOCK_IN - STOCK_IN) AS SIN
            FROM w3Qa_1.ORDER_ROW_RESERVED AS ORR
            LEFT JOIN w3Qa_1.ORDER_ROW AS ORDR ON ORDR.WRK_ROW_ID = ORR.ORDER_WRK_ROW_ID
            LEFT JOIN w3Qa_1.ORDERS   AS O    ON O.ORDER_ID = ORDR.ORDER_ID
            WHERE
                O.PURCHASE_SALES = 0
                AND O.RESERVED = 1
                AND ORDR.ORDER_ROW_CURRENCY NOT IN (-9,-10,-3)
        ) AS T
        WHERE T.SIN > 0
          AND T.P1 = PR.PRODUCT_ID
        GROUP BY T.S1, T.P1, T.ODM, T.ODY
        FOR JSON PATH
    ) AS GT
) AS VSIP

OUTER APPLY (
    SELECT (
        SELECT
            CAST(SUM(ORR.QUANTITY) AS DECIMAL(18,2)) AS TOTAL_SALE,
            CASE
                WHEN YEAR(O.ORDER_DATE) = YEAR(GETDATE())
                    THEN CAST(SUM(ORR.QUANTITY) * 1.0 / NULLIF(MONTH(GETDATE()),0) AS DECIMAL(18,2))
                ELSE CAST(SUM(ORR.QUANTITY) * 1.0 / 12 AS DECIMAL(18,2))
            END AS AVG_SALE,
            YEAR(O.ORDER_DATE) AS [YEAR],
            ORR.STOCK_ID AS S2,
            ORR.PRODUCT_ID AS P2
        FROM w3Qa_1.ORDER_ROW AS ORR
        INNER JOIN w3Qa_1.ORDERS AS O ON O.ORDER_ID = ORR.ORDER_ID
        WHERE
            O.PURCHASE_SALES = 1
            AND ORR.PRODUCT_ID = PR.PRODUCT_ID
        GROUP BY YEAR(O.ORDER_DATE), ORR.STOCK_ID, ORR.PRODUCT_ID
        FOR JSON PATH
    ) AS RPR
) AS RPR

OUTER APPLY (
    SELECT (
        SELECT
            CONVERT(DECIMAL(18,2), SUM(T.SOUT)) AS BS,
            T.S3,
            T.P3,
            T.COMPANY_ID,
            T.NICKNAME,
            T.HAZIR,
            T.TERMIN,
            T.VERILMEYEN
        FROM (
            SELECT
                ORDR.STOCK_ID AS S3,
                ORDR.PRODUCT_ID AS P3,
                O.COMPANY_ID,
                C.NICKNAME,
                (RESERVE_STOCK_OUT - STOCK_OUT) AS SOUT,
                SPB.HAZIR,
                SPB.TERMIN,
                SPB.VERILMEYEN
            FROM w3Qa_1.ORDER_ROW_RESERVED AS ORR
            LEFT JOIN w3Qa_1.ORDER_ROW AS ORDR ON ORDR.WRK_ROW_ID = ORR.ORDER_WRK_ROW_ID
            LEFT JOIN w3Qa_1.ORDERS   AS O    ON O.ORDER_ID = ORDR.ORDER_ID
            LEFT JOIN w3Qa.COMPANY AS C ON C.COMPANY_ID = O.COMPANY_ID
            LEFT JOIN (
                SELECT PRODUCT_ID, HAZIR, TERMIN, VERILMEYEN,COMPANY_ID FROM w3Qa_1.SATINALMA_PLANLAMA_PBS 
            ) AS SPB ON SPB.PRODUCT_ID = ORDR.PRODUCT_ID AND SPB.COMPANY_ID = O.COMPANY_ID
            WHERE
                O.PURCHASE_SALES = 1
                AND O.RESERVED = 1
                AND ORDR.ORDER_ROW_CURRENCY NOT IN (-9,-10,-3)
        ) AS T
        WHERE T.SOUT > 0
          AND T.P3 = PR.PRODUCT_ID
        GROUP BY T.S3, T.P3, T.COMPANY_ID,T.NICKNAME,T.HAZIR,T.TERMIN,T.VERILMEYEN
        FOR JSON PATH
    ) AS ASIP
) AS ASIP
   ) AS PR
--WHERE PR.PRODUCT_ID = 5350
WHERE 1=1  <cfif structKeyExists(attributes, "brand_id") AND len(trim(attributes.brand_id))>
    AND PR.BRAND_ID=#attributes.brand_id#
</cfif>
<cfif structKeyExists(attributes, "only_sales") AND attributes.only_sales EQ "1">
    AND ASIP IS NOT NULL
</cfif>
ORDER BY PR.PRODUCT_ID
</cfquery>

<!--- Parse JSON verileri ve map oluştur --->
<cfset VSIP_MAP = {}>
<cfset RPR_MAP = {}>
<cfset AVG_MAP = {}>
<cfset ASIP_MAP = {}>
<cfset yearList = []>
<cfset yearMonthList = []>
<cfset companyList = []>
<cfset companyNames = {}>

<cfloop query="RAPOR_SQL">
    <!--- VSIP Parse (Alış Siparişi Rezerv) --->
    <cfif len(trim(VSIP)) AND VSIP NEQ "null" AND VSIP NEQ "[]">
        <cfset vsipData = deserializeJSON(VSIP)>
        <cfloop array="#vsipData#" index="item">
            <cfif structKeyExists(item, "ODY") AND structKeyExists(item, "ODM")>
                <cfset yearMonth = "#item.ODY#-#item.ODM#">
                <cfset VSIP_MAP["#PRODUCT_ID#-#yearMonth#"] = item.BS>
                
                <!--- Yıl listesi --->
                <cfif NOT ArrayFind(yearList, item.ODY)>
                    <cfset ArrayAppend(yearList, item.ODY)>
                </cfif>
                
                <!--- Yıl-Ay listesi --->
                <cfif NOT ArrayFind(yearMonthList, yearMonth)>
                    <cfset ArrayAppend(yearMonthList, yearMonth)>
                </cfif>
            </cfif>
        </cfloop>
    </cfif>
    
    <!--- RPR Parse (Satış İstatistikleri) --->
    <cfif len(trim(RPR)) AND RPR NEQ "null" AND RPR NEQ "[]">
        <cfset rprData = deserializeJSON(RPR)>
        <cfloop array="#rprData#" index="item">
            <cfif structKeyExists(item, "YEAR")>
                <cfif structKeyExists(item, "TOTAL_SALE")>
                    <cfset RPR_MAP["#item.YEAR#-#PRODUCT_ID#"] = item.TOTAL_SALE>
                </cfif>
                <cfif structKeyExists(item, "AVG_SALE")>
                    <cfset AVG_MAP["#item.YEAR#-#PRODUCT_ID#"] = item.AVG_SALE>
                </cfif>
                
                <!--- Yıl listesi --->
                <cfif NOT ArrayFind(yearList, item.YEAR)>
                    <cfset ArrayAppend(yearList, item.YEAR)>
                </cfif>
            </cfif>
        </cfloop>
    </cfif>
    <CFSET SBP_MAP = {}>
    <!--- ASIP Parse (Satış Siparişi Rezerv) --->
    <cfif len(trim(ASIP)) AND ASIP NEQ "null" AND ASIP NEQ "[]">
        <cfset asipData = deserializeJSON(ASIP)>
        <cfloop array="#asipData#" index="item">
            <CFSET SBP_MAP["#item.COMPANY_ID#-#item.PRODUCT_ID#"] = {
                HAZIR: structKeyExists(item, "HAZIR") ? item.HAZIR : 0, 
                TERMIN: structKeyExists(item, "TERMIN") ? item.TERMIN : 0, 
                VERILMEYEN: structKeyExists(item, "VERILMEYEN") ? item.VERILMEYEN : 0
            }>
            <cfif structKeyExists(item, "COMPANY_ID")>
                <cfset ASIP_MAP["#item.COMPANY_ID#-#PRODUCT_ID#"] = item.BS>
                
                <!--- Firma listesi --->
                <cfif NOT ArrayFind(companyList, item.COMPANY_ID)>
                    <cfset ArrayAppend(companyList, item.COMPANY_ID)>
                    <!--- Firma adını kaydet --->
                    <cfif structKeyExists(item, "NICKNAME") AND len(trim(item.NICKNAME))>
                        <cfset companyNames[item.COMPANY_ID] = item.NICKNAME>
                    <cfelse>
                        <cfset companyNames[item.COMPANY_ID] = "Firma #item.COMPANY_ID#">
                    </cfif>
                </cfif>
            </cfif>
        </cfloop>
    </cfif>
</cfloop>

<cfset ArraySort(yearList, "numeric")>
<cfset ArraySort(yearMonthList, "text")>
<cfset ArraySort(companyList, "numeric")>

<div class="table-responsive">
<table class="table table-striped table-bordered table-hover table-sm">
    <thead class="table-dark">
    <tr>
        <th>Ürün Kodu</th>
        <th>Ürün Adı</th>
        <th>Bakiye</th>
        <cfoutput>
        <cfloop array="#yearList#" index="year">
            <cfloop array="#yearMonthList#" index="yearMonth">
                <cfif ListFirst(yearMonth, "-") EQ year>
                    <th>#yearMonth#</th>
                </cfif>
            </cfloop>
            <th class="year-total">#year# Toplam</th>
            <th class="year-avg">#year# Ortalama</th>
        </cfloop>
        <cfloop array="#companyList#" index="company">
            <th class="company-order">
                <cfif structKeyExists(companyNames, company)>
                    #companyNames[company]#
                <cfelse>
                    #company#
                </cfif>
            </th>
        </cfloop>
        </cfoutput>
    </tr>
    </thead>
    <tbody>
    <cfoutput query="RAPOR_SQL">
    <tr>
        <td>#PRODUCT_CODE#</td>
        <td>#PRODUCT_NAME#</td>
        <td><cfif isNumeric(BK)>#NumberFormat(BK, "9,999.99")#<cfelse>0</cfif></td>
        <cfloop array="#yearList#" index="year">
            <cfloop array="#yearMonthList#" index="yearMonth">
                <cfif ListFirst(yearMonth, "-") EQ year>
                    <td>
                        <cfif StructKeyExists(VSIP_MAP, "#PRODUCT_ID#-#yearMonth#")>
                            #NumberFormat(VSIP_MAP["#PRODUCT_ID#-#yearMonth#"], "9,999.99")#
                        <cfelse>
                            
                        </cfif>
                    </td>
                </cfif>
            </cfloop>
            <td class="year-total fw-bold">
                <cfif StructKeyExists(RPR_MAP, "#year#-#PRODUCT_ID#")>
                    #NumberFormat(RPR_MAP["#year#-#PRODUCT_ID#"], "9,999.99")#
                <cfelse>
                    
                </cfif>
            </td>
            <td class="year-avg fw-bold">
                <cfif StructKeyExists(AVG_MAP, "#year#-#PRODUCT_ID#")>
                    #NumberFormat(AVG_MAP["#year#-#PRODUCT_ID#"], "9,999.99")#
                <cfelse>
                    
                </cfif>
            </td>
        </cfloop>
        <cfloop array="#companyList#" index="company">
            <td class="company-order fw-bold">
                <cfif StructKeyExists(ASIP_MAP, "#company#-#PRODUCT_ID#")>
                    <a href="javascript:void(0)" onclick="window.open('sarapor_details.cfm?company=#company#&product=#PRODUCT_ID#', '_blank')">#NumberFormat(ASIP_MAP["#company#-#PRODUCT_ID#"], "9,999.99")#</a><br>
                    <cfif StructKeyExists(SBP_MAP, "#company#-#PRODUCT_ID#")>
                        <small>
                            H: #SBP_MAP["#company#-#PRODUCT_ID#"].HAZIR#, 
                            T: #SBP_MAP["#company#-#PRODUCT_ID#"].TERMIN#, 
                            V: #SBP_MAP["#company#-#PRODUCT_ID#"].VERILMEYEN#
                        </small>
                    </cfif>
                <cfelse>
                    #NumberFormat(0, "9,999.99")#
                </cfif>
            </td>
        </cfloop>
    </tr>
    </cfoutput>
    </tbody>
</table>
</div>

    </div>
    
    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>