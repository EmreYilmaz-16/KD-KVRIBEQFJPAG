<cfquery name="siprapor" datasource="w3Qa">
    SELECT SUM(QUANTITY) AS SMIK,SYIL,SAY,PRODUCT_NAME,PRODUCT_ID,PRODUCT_CODE,PRODUCT_CODE_2 FROM (
SELECT  S.PRODUCT_NAME,S.PRODUCT_ID,ORR.QUANTITY,YEAR(ORDER_DATE) SYIL,MONTH(ORDER_DATE)SAY,
S.PRODUCT_CODE,S.PRODUCT_CODE_2
 FROM w3Qa_1.ORDERS AS O 
LEFT JOIN w3Qa_1.ORDER_ROW AS ORR ON O.ORDER_ID=ORR.ORDER_ID
LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID=ORR.STOCK_ID
WHERE S.PRODUCT_NAME IS NOT NULL
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
        WHERE S.PRODUCT_NAME IS NOT NULL
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

<table>
<tr>
    <td>ETA Kodu</td>
    <td>Ürün Kodu</td>
    <td>Ürün</td>
    <td>Yıllık Ortalama</td>
    <cfset currentDate = createDate(START_YEAR, START_MONTH, 1)>
    <cfset endDate = createDate(END_YEAR, END_MONTH, 1)>
    <cfloop condition="dateCompare(currentDate, endDate) LTE 0">
        <td><cfoutput>#year(currentDate)#-#month(currentDate)#</cfoutput></td>
        <cfset currentDate = dateAdd("m", 1, currentDate)>
    </cfloop>
</tr>
<cfoutput query="siprapor">
    <tr>
        <td>
            #PRODUCT_CODE_2#
        </td>
        <td>
            #PRODUCT_CODE#
        </td>
        <td>
            #PRODUCT_NAME#
        </td>
        <td>
            #structKeyExists(YILLIK_ORTALAMA_MAP, PRODUCT_ID) ? numberFormat(YILLIK_ORTALAMA_MAP[PRODUCT_ID], "999,999.99") : 0#
        </td>
        <cfset currentDate = createDate(START_YEAR, START_MONTH, 1)>
        <cfset endDate = createDate(END_YEAR, END_MONTH, 1)>
        <cfloop condition="dateCompare(currentDate, endDate) LTE 0">
            <td>
                <cfset mapKey = "#year(currentDate)#-#month(currentDate)#-#PRODUCT_ID#">
                #structKeyExists(PRODCT_SALE_MAP, mapKey) ? VAL(PRODCT_SALE_MAP[mapKey]) : 0#
            </td>
            <cfset currentDate = dateAdd("m", 1, currentDate)>
        </cfloop>

    </tr>
</cfoutput>
</table>