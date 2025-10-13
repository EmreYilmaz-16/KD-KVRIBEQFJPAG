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
            <div class="col col-3">
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
            <div class="col col-3" id="serialsContainer">
                <table id="serialsTable" style="display:none;">
                    <tr></tr>
                </table>
                <!-- Serial numbers will be loaded here -->
            </div>
            <div class="col col-3" id="hareketContainer">
                <table id="hareketTable" style="display:none;">
                    <tr></tr>
                </table>
                <!-- Serial numbers will be loaded here -->
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
            var a=document.createElement("a");
            a.href="#";
            a.style.cursor="pointer";
            a.style.color="blue";
            a.style.textDecoration="underline";
            a.textContent=result.SERIAL_NO[i];
            a.onclick= function(){ getHareket(result.SERIAL_NO[i]); };
            cell1.appendChild(a);
            
           
        }
    }

function getHareket(serial_no) {
    var sql_query=`select CASE WHEN SGN.IN_OUT=1 THEN '+++' ELSE'---' END AS TR,SGN.DEPARTMENT_ID,SGN.LOCATION_ID,SGN.SERIAL_NO,DEPARTMENT_HEAD+'-'+COMMENT AS DEPO  from w3Qa_1.SERVICE_GUARANTY_NEW  AS SGN
    LEFT JOIN w3Qa.DEPARTMENT AS D ON D.DEPARTMENT_ID=SGN.DEPARTMENT_ID
LEFT JOIN w3Qa.STOCKS_LOCATION AS SL ON SL.LOCATION_ID=SGN.LOCATION_ID AND SL.DEPARTMENT_ID=D.DEPARTMENT_ID
    where SERIAL_NO='${serial_no}'
    `
    var result=wrk_query(sql_query,"dsn3")
        var hareketTable = document.getElementById("hareketTable");
        hareketTable.style.display = "table"; // Show the table
        // Clear previous rows
        while (hareketTable.rows.length > 1) {
            hareketTable.deleteRow(1);
        }
        // Add new rows
        for(let i=0;i<result.recordcount;i++){
            var row = hareketTable.insertRow();
            var cell1 = row.insertCell(0);
            var cell2 = row.insertCell(1);
            var cell3 = row.insertCell(2);
            cell3.innerHTML = result.DEPO[i];
            if(result.TR[i]==='+++'){
                cell2.style.color="green";
            } else {
                cell2.style.color="red";
            }
            cell2.innerHTML = result.TR[i];
            cell1.innerHTML = result.SERIAL_NO[i];


        }

}
</script>


    <cfelse>
        <p>No product found with the provided Product Code 2.</p>
    </cfif>
</cfif>



<script type="text/javascript">
// Simplified AJAX query function
function wrk_query(query, dataSource, maxRows) {
	console.log('=== WRK_QUERY START ===');
	console.log('Query:', query);
	console.log('DataSource:', dataSource);
	
	dataSource = dataSource || 'dsn';
	maxRows = maxRows || 0;
	
	var result = new Object();
	var xhr = null;
	
	// Create XMLHttpRequest
	if (window.XMLHttpRequest) {
		try {
			xhr = new XMLHttpRequest();
		} catch(e) {
			console.error('XMLHttpRequest creation failed:', e);
			xhr = false;
		}
	} else if (window.ActiveXObject) {
		try {
			xhr = new ActiveXObject("Msxml2.XMLHTTP");
		} catch(e) {
			try {
				xhr = new ActiveXObject("Microsoft.XMLHTTP");
			} catch(e) {
				console.error('ActiveXObject creation failed:', e);
				xhr = false;
			}
		}
	}
	
	if (!xhr) {
		console.error('XMLHttpRequest not supported');
		return false;
	}
	
	xhr.open("POST", '/index.cfm?fuseaction=objects2.emptypopup_get_js_query&isAjax=1&xmlhttp=1', false);
	xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
	xhr.setRequestHeader('pragma', 'nocache');
	
	var params = 'str_sql=' + encodeURIComponent(query) + 
				 '&data_source=' + dataSource + 
				 '&maxrows=' + maxRows;
	
	console.log('Request params:', params);
	
	try {
		xhr.send(params);
		console.log('XHR Status:', xhr.status, 'Ready State:', xhr.readyState);
		console.log('Response Text:', xhr.responseText);
		
		if (xhr.readyState === 4 && xhr.status === 200) {
			eval(xhr.responseText.replace(/\u200B/g, ''));
			result = get_js_query;
			console.log('Query result:', result);
		}
	} catch(e) {
		console.error('Query execution failed:', e);
		result = false;
	}
	
	console.log('=== WRK_QUERY END ===');
	return result;
}
</script>