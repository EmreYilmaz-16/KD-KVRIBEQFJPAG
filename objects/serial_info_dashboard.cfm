<cfparam name="attributes.product_code_2" default="">
<cfparam name="attributes.is_submitted" default="0">
<cfform method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
    <div class="form-group">
        <label for="product_code_2">Ürün Kodu 2:</label>
        <input type="text" class="form-control" id="product_code_2" name="product_code_2" value="<cfoutput>#attributes.product_code_2#</cfoutput>" >
    </div>
    <input type="hidden" name="is_submitted" value="1">
    <input type="submit" class="btn btn-primary" value="Get Product">

</cfform>

<cfif attributes.is_submitted eq 1>
   <cfquery name="getProduct" datasource="#dsn3#">
    SELECT STOCK_ID,PRODUCT_ID,PRODUCT_NAME,PRODUCT_CODE_2 FROM STOCKS WHERE PRODUCT_CODE_2='#attributes.product_code_2#'
</cfquery>

    <cfif structKeyExists(getProduct, "PRODUCT_ID")>
        <h3>Product Details:</h3>
        <p><strong>Product ID:</strong> <cfoutput>#getProduct.PRODUCT_ID#</cfoutput></p>
        <p><strong>Product Name:</strong> <cfoutput>#getProduct.PRODUCT_NAME#</cfoutput></p>
        <p><strong>Stock ID:</strong> <cfoutput>#getProduct.STOCK_ID#</cfoutput></p>
        <div class="row">
            <div>
                <cfquery name="getAllStocks" datasource="#dsn2#">
                   SELECT SUM(STOCK_IN-STOCK_OUT) AS BK,STOCK_ID,STORE,STORE_LOCATION ,
DEPARTMENT_HEAD+'-'+COMMENT AS DEPO
FROM w3Qa_2025_1.STOCKS_ROW 
LEFT JOIN w3Qa.DEPARTMENT AS D ON D.DEPARTMENT_ID=STORE
LEFT JOIN w3Qa.STOCKS_LOCATION AS SL ON SL.LOCATION_ID=STORE_LOCATION AND SL.DEPARTMENT_ID=D.DEPARTMENT_ID
WHERE STOCK_ID=#getProduct.STOCK_ID#
GROUP BY STOCK_ID,STORE,STORE_LOCATION,DEPARTMENT_HEAD,COMMENT
HAVING STORE_LOCATION IS NOT NULL


--HAVING STOCK_ID=1193
                </cfquery>
                <h3>Stock Information:</h3>
                <table>
                    <tr>
                                            
                        <th>Depo</th>
                        <th>Total Stock</th>
                    </tr>
                    <cfoutput query="getAllStocks">
                        <tr>
                            
                            <td><cfif BK gt 0>
                                <a onclick="getSerials('#getAllStocks.STOCK_ID#','#getAllStocks.STORE#','#getAllStocks.STORE_LOCATION#');" style="cursor: pointer; color: blue; text-decoration: underline;">
                                    #DEPO#
                                </a>
                            <cfelse>
                                #DEPO#  
                            </cfif>
                                </td>
                            <td>#tlformat(BK,2)#</td>
                        </tr>
                    </cfoutput>
                </table>
                <table>
                    <tr>
                        <td>
                            
                        </td>
                    </tr>
                </table>
            </div>
            <div id="serialsContainer">
                <table id="serialsTable" style="display:none;">
                    <tr></tr>
                </table>
                <!-- Serial numbers will be loaded here -->
            </div>
        </div>
<script>
    function getSerials(stockId, departmentId, locationId) {
        var sql_query=`
        SELECT 
SUM(CASE WHEN IN_OUT=1 THEN 1 ELSE -1 END)
,SERIAL_NO
,STOCK_ID
,DEPARTMENT_ID
,LOCATION_ID
FROM w3Qa_1.SERVICE_GUARANTY_NEW
GROUP BY
SERIAL_NO,
STOCK_ID
,DEPARTMENT_ID
,LOCATION_ID
HAVING STOCK_ID=${stockId}
AND DEPARTMENT_ID=${departmentId} AND LOCATION_ID=${locationId}
AND SUM(CASE WHEN IN_OUT=1 THEN 1 ELSE -1 END)>0
ORDER BY SERIAL_NO
    
`
var result=wrk_query(sql_query,"dsn3")
        var serialsTable = document.getElementById("serialsTable");
        serialsTable.style.display = "table"; // Show the table
        // Clear previous rows
        while (serialsTable.rows.length > 1) {
            serialsTable.deleteRow(1);
        }
        // Add new rows
        for(let i=0;i<result.recordcount;i++){
            var row = serialsTable.insertRow();
            var cell1 = row.insertCell(0);
            
            cell1.innerHTML = result.SERIAL_NO[i];
           
        }
    }

</script>


    <cfelse>
        <p>No product found with the provided Product Code 2.</p>
    </cfif>
</cfif>

