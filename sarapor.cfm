<cfset dsn3="w3Qa_1">
<cfquery name="getdata" datasource="#dsn3#">
SELECT SUM(SIN) AS BS,S1,P1,ODM,ODY,PRODUCT_CODE_2,PRODUCT_NAME,
(SELECT SUM(ISNULL(STOCK_IN,0)-ISNULL(STOCK_OUT,0)) FROM w3Qa_2026_1.STOCKS_ROW AS SR WHERE SR.STOCK_ID=T.P1) AS BK FROM (
SELECT  
ORDR.STOCK_ID S1,
ORDR.ORDER_ROW_CURRENCY,
S.PRODUCT_ID P1,
S.PRODUCT_CODE_2,
S.PRODUCT_NAME,
O.ORDER_NUMBER,O.PURCHASE_SALES,
O.ORDER_ID O1,
O.RESERVED,
  ORR.ORDER_ID,
 YEAR(O.ORDER_DATE ) ODY,
MONTH(O.ORDER_DATE ) ODM,
RESERVE_STOCK_IN-STOCK_IN AS SIN,
RESERVE_STOCK_OUT-STOCK_OUT AS SOUT
FROM w3Qa_1.ORDER_ROW_RESERVED AS ORR
LEFT JOIN w3Qa_1.ORDER_ROW AS ORDR ON ORDR.WRK_ROW_ID=ORR.ORDER_WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDERS AS O ON O.ORDER_ID=ORDR.ORDER_ID
LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID=ORDR.STOCK_ID
WHERE O.PURCHASE_SALES=0 AND ORDR.ORDER_ROW_CURRENCY NOT IN (-9,-10,-3) AND O.RESERVED=1
) AS T WHERE SIN >0  --AND P1=5350
GROUP BY S1,P1,ODM,ODY,PRODUCT_CODE_2,PRODUCT_NAME
ORDER BY P1,ODY,ODM
</cfquery>

<cfset yearMonthList = []>
<cfloop query="getdata">
    <cfset yearMonth = "#ODY#-#ODM#">
    <cfif NOT ArrayFind(yearMonthList, yearMonth)>
        <cfset ArrayAppend(yearMonthList, yearMonth)>
    </cfif>
</cfloop>
<cfset ArraySort(yearMonthList, "text")>

<table border="1">
    <tr>
        <th>Ürün Kodu</th>
        <th>Ürün Adı</th>
        <th>Bakiye</th>
        <cfoutput>
        <cfloop array="#yearMonthList#" index="yearMonth">
            <th>#yearMonth#</th>
        </cfloop>
        </cfoutput>
    </tr>
    <cfoutput query="getdata" group="P1">
    <tr>
        <td>#PRODUCT_CODE_2#</td>
        <td>#PRODUCT_NAME#</td>
        <td>#BK#</td>
        <cfloop array="#yearMonthList#" index="yearMonth">
            <cfset parts = ListToArray(yearMonth, "-")>
            <cfset year = parts[1]>
            <cfset month = parts[2]>
            <td>
                <cfif ODY EQ year AND ODM EQ month>
                    #BS#
                </cfif>
            </td>
        </cfloop>
    </tr>
    </cfoutput>
    
</table>