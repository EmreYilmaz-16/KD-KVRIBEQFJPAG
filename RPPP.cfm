<cfquery name="siprapor" datasource="w3Qa">
    SELECT SUM(QUANTITY) AS SMIK,SYIL,SAY,PRODUCT_NAME,PRODUCT_ID FROM (
SELECT  S.PRODUCT_NAME,S.PRODUCT_ID,ORR.QUANTITY,YEAR(ORDER_DATE) SYIL,MONTH(ORDER_DATE)SAY FROM w3Qa_1.ORDERS AS O 
LEFT JOIN w3Qa_1.ORDER_ROW AS ORR ON O.ORDER_ID=ORR.ORDER_ID
LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID=ORR.STOCK_ID
WHERE S.PRODUCT_NAME IS NOT NULL
) AS OSS 
GROUP BY SYIL,SAY,PRODUCT_NAME,PRODUCT_ID
ORDER BY SYIL,SAY
</cfquery>

<cfloop query="siprapor">
    <cfset PRODCT_SALE_MAP["#SYIL#-#SAY#-#PRODUCT_ID#"] = SMIK>
</cfloop>


<cfset START_YEAR=YEAR(dateAdd("m",-12,now()))>
<cfset START_MONTH=MONTH(dateAdd("m",-12,now()))>
<cfset END_YEAR=YEAR(now())>
<cfset END_MONTH=MONTH(now())>

<table>
<tr>
    <td>Ürün</td>
    <cfset currentDate = createDate(START_YEAR, START_MONTH, 1)>
    <cfset endDate = createDate(END_YEAR, END_MONTH, 1)>
    <cfloop condition="dateCompare(currentDate, endDate) LTE 0">
        <td><cfoutput>#year(currentDate)#-#month(currentDate)#</cfoutput></td>
        <cfset currentDate = dateAdd("m", 1, currentDate)>
    </cfloop>
</tr>
</table>