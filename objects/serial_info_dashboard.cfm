<cfparam name="attributes.product_code_2" default="">
<cfparam name="attributes.is_submitted" default="0">

<style>
    .serial-dashboard {
        background-color: #f8f9fa;
        border-radius: 0.75rem;
        padding: 1.25rem;
        box-shadow: 0 0.25rem 1rem rgba(12, 18, 28, 0.08);
    }

    .serial-dashboard h3 {
        font-size: 1rem;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        margin-bottom: 0.75rem;
        color: #495057;
    }

    .serial-dashboard .card {
        border: none;
        border-radius: 0.75rem;
        box-shadow: 0 0.25rem 0.75rem rgba(9, 30, 66, 0.08);
    }

    .serial-dashboard .card-header {
        background: linear-gradient(135deg, #3151b7, #23b4d2);
        color: #fff;
        font-weight: 600;
        letter-spacing: 0.03em;
    }

    .serial-dashboard .card-body {
        padding: 0;
    }

    .serial-dashboard .table {
        margin-bottom: 0;
    }

    .serial-dashboard .table thead th {
        background-color: #eef3fb;
        border: none;
        color: #495057;
        font-size: 0.85rem;
    }

    .serial-dashboard .table td {
        border-top: 1px solid #edf1f7;
        font-size: 0.85rem;
        vertical-align: middle;
    }

    .serial-dashboard .table a {
        color: #1e88e5;
        font-weight: 600;
        text-decoration: none;
    }

    .serial-dashboard .table a:hover {
        text-decoration: underline;
    }
</style>

<cfform method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
    <div class="container-fluid py-3">
        <div class="serial-dashboard">
            <div class="row g-3 align-items-end">
                <div class="col-12 col-sm-6 col-md-4 col-lg-3">
                    <div class="form-group mb-2">
                        <label class="form-label" for="product_code_2">Ürün Kodu 2</label>
                        <input type="text" class="form-control form-control-sm" id="product_code_2" name="product_code_2" value="<cfoutput>#attributes.product_code_2#</cfoutput>">
                    </div>
                </div>
                <div class="col-12 col-sm-4 col-md-3 col-lg-2">
                    <input type="hidden" name="is_submitted" value="1">
                    <input type="submit" class="btn btn-primary btn-sm w-100" value="Get Product">
                </div>
            </div>

<cfif attributes.is_submitted eq 1>
   <cfquery name="getProduct" datasource="#dsn3#">
    SELECT STOCK_ID,PRODUCT_ID,PRODUCT_NAME,PRODUCT_CODE_2 FROM STOCKS WHERE PRODUCT_CODE_2='#attributes.product_code_2#'
</cfquery>

    <cfif structKeyExists(getProduct, "PRODUCT_ID")>
        <div class="row g-3 mt-2">
            <div class="col-12 col-md-6 col-lg-3">
                <div class="card h-100">
                    <div class="card-header">Ürün Bilgisi</div>
                    <div class="card-body">
                        <ul class="list-unstyled mb-0 small text-muted">
                            <li class="d-flex justify-content-between py-1 border-bottom"><span class="fw-semibold text-dark">Product ID</span><span><cfoutput>#getProduct.PRODUCT_ID#</cfoutput></span></li>
                            <li class="d-flex justify-content-between py-1 border-bottom"><span class="fw-semibold text-dark">Stock ID</span><span><cfoutput>#getProduct.STOCK_ID#</cfoutput></span></li>
                            <li class="pt-2"><span class="fw-semibold text-dark d-block mb-1">Product Name</span><span class="text-body"> <cfoutput>#getProduct.PRODUCT_NAME#</cfoutput></span></li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="col-12 col-md-6 col-lg-3">
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
                <div class="card h-100">
                    <div class="card-header">Stock Information</div>
                    <div class="card-body">
                        <table class="table table-sm mb-0">
                            <thead>
                                <tr>
                                    <th>Depo</th>
                                    <th class="text-end">Total</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfoutput query="getAllStocks">
                                <tr>
                                    <td>
                                        <cfif BK gt 0>
                                            <a onclick="getSerials('#getAllStocks.STOCK_ID#','#getAllStocks.STORE#','#getAllStocks.STORE_LOCATION#');">#DEPO#</a>
                                        <cfelse>
                                            #DEPO#
                                        </cfif>
                                    </td>
                                    <td class="text-end">#tlformat(BK,2)#</td>
                                </tr>
                                </cfoutput>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-12 col-md-6 col-lg-3" id="serialsContainer">
                <div class="card h-100">
                    <div class="card-header">Seri Numaraları</div>
                    <div class="card-body">
                        <table class="table table-sm mb-0 d-none" id="serialsTable">
                            <thead>
                                <tr>
                                    <th>Seri</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                        <div class="text-muted small" id="serialsPlaceholder">Depodaki stoklara tıklayın.</div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-md-6 col-lg-3" id="hareketContainer">
                <div class="card h-100">
                    <div class="card-header">Hareket Geçmişi</div>
                    <div class="card-body">
                        <table class="table table-sm mb-0 d-none" id="hareketTable">
                            <thead>
                                <tr>
                                    <th>Seri</th>
                                    <th>İşlem</th>
                                    <th>Depo</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                        <div class="text-muted small" id="hareketPlaceholder">Seri numarası seçildiğinde hareketler listelenir.</div>
                    </div>
                </div>
            </div>
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
        var serialsBody = serialsTable.querySelector("tbody");
        serialsBody.innerHTML = "";
    serialsTable.classList.add("d-none");
    document.getElementById("serialsPlaceholder").classList.remove("d-none");
        if(result && result.recordcount>0){
            serialsTable.classList.remove("d-none");
            document.getElementById("serialsPlaceholder").classList.add("d-none");
            for(let i=0;i<result.recordcount;i++){
                var row = document.createElement("tr");
                var cell1 = document.createElement("td");
                var a=document.createElement("a");
                a.href="#";
                a.className="text-decoration-none";
                a.textContent=result.SERIAL_NO[i];
                a.onclick= function(){ getHareket(result.SERIAL_NO[i]); return false; };
                cell1.appendChild(a);
                row.appendChild(cell1);
                serialsBody.appendChild(row);
            }
        } else {
            serialsTable.classList.add("d-none");
            document.getElementById("serialsPlaceholder").classList.remove("d-none");
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
        var hareketBody = hareketTable.querySelector("tbody");
        hareketBody.innerHTML = "";
        hareketTable.classList.add("d-none");
        document.getElementById("hareketPlaceholder").classList.remove("d-none");
        if(result && result.recordcount>0){
            hareketTable.classList.remove("d-none");
            document.getElementById("hareketPlaceholder").classList.add("d-none");
            for(let i=0;i<result.recordcount;i++){
                var row = document.createElement("tr");
                var cellSerial = document.createElement("td");
                var cellTr = document.createElement("td");
                var cellDepo = document.createElement("td");
                cellDepo.textContent = result.DEPO[i];
                cellTr.textContent = result.TR[i];
                cellTr.className = result.TR[i] === '+++' ? 'text-success fw-semibold' : 'text-danger fw-semibold';
                cellSerial.textContent = result.SERIAL_NO[i];
                row.appendChild(cellSerial);
                row.appendChild(cellTr);
                row.appendChild(cellDepo);
                hareketBody.appendChild(row);
            }
        } else {
            hareketTable.classList.add("d-none");
            document.getElementById("hareketPlaceholder").classList.remove("d-none");
        }

}
</script>


    <cfelse>
        <p>No product found with the provided Product Code 2.</p>
    </cfif>
</cfif>
        </div>
    </div>
</cfform>



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