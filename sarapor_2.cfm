<cfquery name="RAPOR_SQL" datasource="w3Qa_1">
    SELECT
    PR.PRODUCT_NAME,
    PR.PRODUCT_CODE,
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
            T.COMPANY_ID
        FROM (
            SELECT
                ORDR.STOCK_ID AS S3,
                ORDR.PRODUCT_ID AS P3,
                O.COMPANY_ID,
                (RESERVE_STOCK_OUT - STOCK_OUT) AS SOUT
            FROM w3Qa_1.ORDER_ROW_RESERVED AS ORR
            LEFT JOIN w3Qa_1.ORDER_ROW AS ORDR ON ORDR.WRK_ROW_ID = ORR.ORDER_WRK_ROW_ID
            LEFT JOIN w3Qa_1.ORDERS   AS O    ON O.ORDER_ID = ORDR.ORDER_ID
            WHERE
                O.PURCHASE_SALES = 1
                AND O.RESERVED = 1
                AND ORDR.ORDER_ROW_CURRENCY NOT IN (-9,-10,-3)
        ) AS T
        WHERE T.SOUT > 0
          AND T.P3 = PR.PRODUCT_ID
        GROUP BY T.S3, T.P3, T.COMPANY_ID
        FOR JSON PATH
    ) AS ASIP
) AS ASIP

--WHERE PR.PRODUCT_ID = 5350;
</cfquery>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Stok Raporu</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        h1 {
            color: #333;
            text-align: center;
            margin-bottom: 30px;
        }
        .report-container {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            padding: 20px;
            margin-bottom: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th {
            background-color: #4CAF50;
            color: white;
            padding: 12px;
            text-align: left;
            font-weight: bold;
        }
        td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .json-detail {
            background-color: #f9f9f9;
            padding: 10px;
            border-radius: 4px;
            margin: 5px 0;
            font-size: 12px;
        }
        .section-title {
            font-weight: bold;
            color: #2196F3;
            margin-top: 10px;
            margin-bottom: 5px;
        }
        .detail-row {
            margin: 3px 0;
            padding: 3px;
            background-color: white;
            border-left: 3px solid #2196F3;
            padding-left: 8px;
        }
        .no-data {
            color: #999;
            font-style: italic;
        }
        .stat-value {
            font-weight: bold;
            color: #333;
        }
    </style>
</head>
<body>
    <h1>📊 Ürün Stok ve Satış Raporu</h1>
    
    <div class="report-container">
        <table>
            <thead>
                <tr>
                    <th>Ürün Kodu</th>
                    <th>Ürün Adı</th>
                    <th>Alış Siparişi Rezerv</th>
                    <th>Satış İstatistikleri</th>
                    <th>Satış Siparişi Rezerv</th>
                </tr>
            </thead>
            <tbody>
                <cfoutput query="RAPOR_SQL">
                    <tr>
                        <td><strong>#PRODUCT_CODE#</strong></td>
                        <td>#PRODUCT_NAME#</td>
                        
                        <!-- VSIP - Alış Siparişi Rezerv -->
                        <td>
                            <cfif len(trim(VSIP)) AND VSIP NEQ "null" AND VSIP NEQ "[]">
                                <cfset vsipData = deserializeJSON(VSIP)>
                                <cfif arrayLen(vsipData) GT 0>
                                    <div class="json-detail">
                                        <cfloop array="#vsipData#" index="item">
                                            <div class="detail-row">
                                                <strong>Miktar:</strong> <span class="stat-value">#numberFormat(item.BS, "999,999.99")#</span><br>
                                                <cfif structKeyExists(item, "ODY") AND structKeyExists(item, "ODM")>
                                                    Tarih: #item.ODY#/#item.ODM#<br>
                                                </cfif>
                                                <cfif structKeyExists(item, "S1")>
                                                    Stok ID: #item.S1#
                                                </cfif>
                                            </div>
                                        </cfloop>
                                    </div>
                                <cfelse>
                                    <span class="no-data">Veri yok</span>
                                </cfif>
                            <cfelse>
                                <span class="no-data">Veri yok</span>
                            </cfif>
                        </td>
                        
                        <!-- RPR - Satış İstatistikleri -->
                        <td>
                            <cfif len(trim(RPR)) AND RPR NEQ "null" AND RPR NEQ "[]">
                                <cfset rprData = deserializeJSON(RPR)>
                                <cfif arrayLen(rprData) GT 0>
                                    <div class="json-detail">
                                        <cfloop array="#rprData#" index="item">
                                            <div class="detail-row">
                                                <cfif structKeyExists(item, "YEAR")>
                                                    <strong>Yıl:</strong> #item.YEAR#<br>
                                                </cfif>
                                                <cfif structKeyExists(item, "TOTAL_SALE")>
                                                    <strong>Toplam Satış:</strong> <span class="stat-value">#numberFormat(item.TOTAL_SALE, "999,999.99")#</span><br>
                                                </cfif>
                                                <cfif structKeyExists(item, "AVG_SALE")>
                                                    <strong>Ortalama:</strong> <span class="stat-value">#numberFormat(item.AVG_SALE, "999,999.99")#</span><br>
                                                </cfif>
                                                <cfif structKeyExists(item, "S2")>
                                                    Stok ID: #item.S2#
                                                </cfif>
                                            </div>
                                        </cfloop>
                                    </div>
                                <cfelse>
                                    <span class="no-data">Veri yok</span>
                                </cfif>
                            <cfelse>
                                <span class="no-data">Veri yok</span>
                            </cfif>
                        </td>
                        
                        <!-- ASIP - Satış Siparişi Rezerv -->
                        <td>
                            <cfif len(trim(ASIP)) AND ASIP NEQ "null" AND ASIP NEQ "[]">
                                <cfset asipData = deserializeJSON(ASIP)>
                                <cfif arrayLen(asipData) GT 0>
                                    <div class="json-detail">
                                        <cfloop array="#asipData#" index="item">
                                            <div class="detail-row">
                                                <strong>Miktar:</strong> <span class="stat-value">#numberFormat(item.BS, "999,999.99")#</span><br>
                                                <cfif structKeyExists(item, "COMPANY_ID")>
                                                    Firma ID: #item.COMPANY_ID#<br>
                                                </cfif>
                                                <cfif structKeyExists(item, "S3")>
                                                    Stok ID: #item.S3#
                                                </cfif>
                                            </div>
                                        </cfloop>
                                    </div>
                                <cfelse>
                                    <span class="no-data">Veri yok</span>
                                </cfif>
                            <cfelse>
                                <span class="no-data">Veri yok</span>
                            </cfif>
                        </td>
                    </tr>
                </cfoutput>
            </tbody>
        </table>
        
        <cfoutput>
            <div style="margin-top: 20px; padding: 10px; background-color: ##e8f5e9; border-radius: 4px;">
                <strong>Toplam Kayıt:</strong> #RAPOR_SQL.recordCount#
            </div>
        </cfoutput>
    </div>
    
    <div style="text-align: center; color: #666; margin-top: 20px; font-size: 12px;">
        Rapor Tarihi: <cfoutput>#dateFormat(now(), "dd/mm/yyyy")# - #timeFormat(now(), "HH:mm:ss")#</cfoutput>
    </div>
</body>
</html>