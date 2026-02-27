<cfdump var="#attributes#" label="URL Parameters">

<cfquery name="getData" datasource="w3Qa_1">
    SELECT SUM(SOUT) AS BS,S1,P1 FROM (
SELECT  
S.STOCK_ID S1,
ORDR.ORDER_ROW_CURRENCY,
S.PRODUCT_ID P1,
S.PRODUCT_CODE_2,
S.PRODUCT_NAME,
O.COMPANY_ID,
RESERVE_STOCK_IN-STOCK_IN AS SIN,
RESERVE_STOCK_OUT-STOCK_OUT AS SOUT
FROM w3Qa_1.ORDER_ROW_RESERVED AS ORR
LEFT JOIN w3Qa_1.ORDER_ROW AS ORDR ON ORDR.WRK_ROW_ID=ORR.ORDER_WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDERS AS O ON O.ORDER_ID=ORDR.ORDER_ID
LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID=ORDR.STOCK_ID
WHERE O.PURCHASE_SALES=1 AND ORDR.ORDER_ROW_CURRENCY NOT IN (-9,-10,-3) AND O.RESERVED=1
) AS T WHERE SOUT >0  --AND P1=5350
GROUP BY S1,P1
</cfquery>
<table>
    <tr>
        <th>ÜRÜN KODU</th>
        <th>ÜRÜN ADI</th>        
        <th>ALINAN SİPARİŞ</th>
        
    </tr>
    <cfloop query="getData">
        <cfoutput>
        <tr>
            <td>#PRODUCT_CODE_2#</td>
            <td>#PRODUCT_NAME#</td>            
            <td>#BS#</td>
            
        </tr>
</cfoutput>
    </cfloop>

</table>