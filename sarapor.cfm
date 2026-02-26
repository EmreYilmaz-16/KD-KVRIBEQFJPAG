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
<cfquery name="RRP" datasource="#dsn3#">
    select 
SUM(QUANTITY) AS TOTAL_SALE,
SUM(QUANTITY)/MAX(MONTH(GETDATE())) AS AVG_SALE,
YEAR(ORDERS.ORDER_DATE) YEAR,
STOCK_ID,PRODUCT_ID
 from w3Qa_1.ORDER_ROW INNER JOIN w3Qa_1.ORDERS ON ORDERS.ORDER_ID=ORDER_ROW.ORDER_ID
WHERE ORDERS.PURCHASE_SALES=1 GROUP BY YEAR(ORDERS.ORDER_DATE),STOCK_ID,PRODUCT_ID
</cfquery>

<cfquery name="alinansiparis" datasource="w3Qa_1">
SELECT SUM(SOUT) AS BS,S1,P1,COMPANY_ID FROM (
SELECT  
ORDR.STOCK_ID S1,
ORDR.ORDER_ROW_CURRENCY,
ORDR.PRODUCT_ID P1,
O.COMPANY_ID,
RESERVE_STOCK_IN-STOCK_IN AS SIN,
RESERVE_STOCK_OUT-STOCK_OUT AS SOUT
FROM w3Qa_1.ORDER_ROW_RESERVED AS ORR
LEFT JOIN w3Qa_1.ORDER_ROW AS ORDR ON ORDR.WRK_ROW_ID=ORR.ORDER_WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDERS AS O ON O.ORDER_ID=ORDR.ORDER_ID
WHERE O.PURCHASE_SALES=1 AND ORDR.ORDER_ROW_CURRENCY NOT IN (-9,-10,-3) AND O.RESERVED=1
) AS T WHERE SOUT >0  --AND P1=5350
GROUP BY S1,P1,COMPANY_ID

</cfquery>

<cfset ALINAN_SIPARIS_MAP = {}>
<cfloop query="alinansiparis">
    <cfset ALINAN_SIPARIS_MAP["#COMPANY_ID#-#P1#"] = BS>
</cfloop>

<cfset COMPANIES = []>
<cfloop query="alinansiparis">
    <cfif NOT ArrayFind(COMPANIES, COMPANY_ID)>
        <cfset ArrayAppend(COMPANIES, COMPANY_ID)>
    </cfif>
</cfloop>


<cfset RRP_MAP = {}>
<cfset AVG_MAP = {}>
<cfloop query="RRP">
    <cfset RRP_MAP["#YEAR#-#PRODUCT_ID#"] = TOTAL_SALE>
    <cfset AVG_MAP["#YEAR#-#PRODUCT_ID#"] = AVG_SALE>
</cfloop>

<cfset yearList = []>
<cfset yearMonthList = []>
<cfloop query="getdata">
    <cfif NOT ArrayFind(yearList, ODY)>
        <cfset ArrayAppend(yearList, ODY)>
    </cfif>
    <cfset yearMonth = "#ODY#-#ODM#">
    <cfif NOT ArrayFind(yearMonthList, yearMonth)>
        <cfset ArrayAppend(yearMonthList, yearMonth)>
    </cfif>
</cfloop>
<cfset ArraySort(yearList, "numeric")>
<cfset ArraySort(yearMonthList, "text")>

<table border="1">
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
            <th style="background-color:##e6f3ff;">#year# Toplam</th>
            <th style="background-color:##fff3e6;">#year# Ortalama</th>
        </cfloop>
        <cfloop array="#COMPANIES#" index="company">
            <th style="background-color:##ffe6e6;">#company# Alınan Sipariş</th>
        </cfloop>
        </cfoutput>
    </tr>
    <cfoutput query="getdata" group="P1">
    <tr>
        <td>#PRODUCT_CODE_2#</td>
        <td>#PRODUCT_NAME#</td>
        <td>#BK#</td>
        <cfloop array="#yearList#" index="year">
            <cfloop array="#yearMonthList#" index="yearMonth">
                <cfif ListFirst(yearMonth, "-") EQ year>
                    <cfset parts = ListToArray(yearMonth, "-")>
                    <cfset yy = parts[1]>
                    <cfset mm = parts[2]>
                    <td>
                        <cfoutput group="ODY">
                            <cfoutput group="ODM">
                                <cfif ODY EQ yy AND ODM EQ mm>
                                    #BS#
                                </cfif>
                            </cfoutput>
                        </cfoutput>
                    </td>
                </cfif>
            </cfloop>
            <td style="background-color:##e6f3ff; font-weight:bold;">
                <cfif StructKeyExists(RRP_MAP, "#year#-#P1#")>
                    #NumberFormat(RRP_MAP["#year#-#P1#"], "9,999.99")#
                <cfelse>
                    0
                </cfif>
            </td>
            <td style="background-color:##fff3e6; font-weight:bold;">
                <cfif StructKeyExists(AVG_MAP, "#year#-#P1#")>
                    #NumberFormat(AVG_MAP["#year#-#P1#"], "9,999.99")#
                <cfelse>
                    0
                </cfif>
            </td>
        </cfloop>
        <cfloop array="#COMPANIES#" index="company">
            <td style="background-color:##ffe6e6; font-weight:bold;">
                <cfif StructKeyExists(ALINAN_SIPARIS_MAP, "#company#-#P1#")>
                    #NumberFormat(ALINAN_SIPARIS_MAP["#company#-#P1#"], "9,999.99")#
                <cfelse>
                    0
                </cfif>
            </td>
        </cfloop>
    </tr>
    </cfoutput>
    
</table>