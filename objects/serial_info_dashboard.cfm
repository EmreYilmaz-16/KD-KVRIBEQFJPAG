<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Serial Info Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"                        <div class="col-md-6">
                            <div id="serialsContainer" class="info-card" style="display:none;">
                                <h4 class="icon-text mb-3">
                                    <i class="fas fa-list-ol"></i>
                                    Seri Numaraları
                                </h4>
                                <div class="loading-spinner" id="serialsLoading">
                                    <div class="spinner-border text-primary" role="status">
                                        <span class="visually-hidden">Yükleniyor...</span>
                                    </div>
                                </div>
                                <div class="table-responsive">
                                    <table id="serialsTable" class="table custom-table" style="display:none;">
                                        <thead>
                                            <tr>
                                                <th><i class="fas fa-barcode"></i> Seri Numarası</th>
                                            </tr>
                                        </thead>
                                        <tbody></tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div id="hareketContainer" class="info-card" style="display:none;">
                                <h4 class="icon-text mb-3">
                                    <i class="fas fa-exchange-alt"></i>
                                    Hareket Geçmişi
                                </h4>
                                <div class="loading-spinner" id="hareketLoading">
                                    <div class="spinner-border text-primary" role="status">
                                        <span class="visually-hidden">Yükleniyor...</span>
                                    </div>
                                </div>
                                <div class="table-responsive">
                                    <table id="hareketTable" class="table custom-table" style="display:none;">
                                        <thead>
                                            <tr>
                                                <th><i class="fas fa-barcode"></i> Seri No</th>
                                                <th><i class="fas fa-arrows-alt-v"></i> İşlem</th>
                                                <th><i class="fas fa-building"></i> Depo</th>
                                            </tr>
                                        </thead>
                                        <tbody></tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .main-container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.1);
            margin: 20px auto;
            max-width: 1200px;
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            color: white;
            padding: 2rem;
            text-align: center;
        }
        
        .header h1 {
            margin: 0;
            font-weight: 300;
            font-size: 2.5rem;
        }
        
        .content-section {
            padding: 2rem;
        }
        
        .form-card {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 2rem;
            margin-bottom: 2rem;
            border: 1px solid #e9ecef;
        }
        
        .info-card {
            background: white;
            border-radius: 10px;
            padding: 2rem;
            margin-bottom: 2rem;
            border-left: 4px solid #4facfe;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .stats-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            text-align: center;
        }
        
        .btn-custom {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            border: none;
            border-radius: 25px;
            padding: 12px 30px;
            color: white;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .btn-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(79, 172, 254, 0.3);
            color: white;
        }
        
        .custom-table {
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .custom-table thead {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .custom-table thead th {
            border: none;
            padding: 1rem;
            font-weight: 500;
        }
        
        .custom-table tbody tr {
            transition: all 0.3s ease;
        }
        
        .custom-table tbody tr:hover {
            background-color: #f8f9fa;
            transform: scale(1.01);
        }
        
        .custom-table tbody td {
            padding: 1rem;
            border-color: #e9ecef;
        }
        
        .clickable-link {
            color: #4facfe;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .clickable-link:hover {
            color: #00f2fe;
            text-decoration: underline;
        }
        
        .loading-spinner {
            display: none;
            text-align: center;
            padding: 2rem;
        }
        
        .fade-in {
            animation: fadeIn 0.5s ease-in;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .icon-text {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .badge-custom {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="main-container">
        <div class="header">
            <h1><i class="fas fa-search"></i> Serial Info Dashboard</h1>
            <p class="mb-0">Ürün ve seri numarası bilgilerini yönetin</p>
        </div>

<cfparam name="attributes.product_code_2" default="">
<cfparam name="attributes.is_submitted" default="0">

        <div class="content-section">
            <cfform method="post" action="#request.self#?fuseaction=#attributes.fuseaction#" class="form-card">
                <h3 class="icon-text mb-4">
                    <i class="fas fa-barcode"></i>
                    Ürün Arama
                </h3>
                <div class="row">
                    <div class="col-md-8">
                        <div class="mb-3">
                            <label for="product_code_2" class="form-label fw-bold">
                                <i class="fas fa-tag"></i> Ürün Kodu 2:
                            </label>
                            <input type="text" 
                                   class="form-control form-control-lg" 
                                   id="product_code_2" 
                                   name="product_code_2" 
                                   value="<cfoutput>#attributes.product_code_2#</cfoutput>" 
                                   placeholder="Ürün kodunu giriniz..."
                                   style="border-radius: 10px;">
                        </div>
                    </div>
                    <div class="col-md-4 d-flex align-items-end">
                        <div class="mb-3 w-100">
                            <input type="hidden" name="is_submitted" value="1">
                            <button type="submit" class="btn btn-custom btn-lg w-100">
                                <i class="fas fa-search"></i> Ürün Getir
                            </button>
                        </div>
                    </div>
                </div>
            </cfform>

            <cfif attributes.is_submitted eq 1>
                <cfquery name="getProduct" datasource="#dsn3#">
                    SELECT STOCK_ID,PRODUCT_ID,PRODUCT_NAME,PRODUCT_CODE_2 FROM STOCKS WHERE PRODUCT_CODE_2='#attributes.product_code_2#'
                </cfquery>

                <cfif structKeyExists(getProduct, "PRODUCT_ID")>
                    <div class="info-card fade-in">
                        <h3 class="icon-text mb-4">
                            <i class="fas fa-info-circle"></i>
                            Ürün Detayları
                        </h3>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="stats-card">
                                    <h5><i class="fas fa-hashtag"></i> Ürün ID</h5>
                                    <h3><cfoutput>#getProduct.PRODUCT_ID#</cfoutput></h3>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="stats-card">
                                    <h5><i class="fas fa-cube"></i> Stok ID</h5>
                                    <h3><cfoutput>#getProduct.STOCK_ID#</cfoutput></h3>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="stats-card">
                                    <h5><i class="fas fa-barcode"></i> Ürün Kodu</h5>
                                    <h3><cfoutput>#getProduct.PRODUCT_CODE_2#</cfoutput></h3>
                                </div>
                            </div>
                        </div>
                        <div class="mt-3">
                            <div class="badge-custom">
                                <i class="fas fa-tag"></i> <strong>Ürün Adı:</strong> <cfoutput>#getProduct.PRODUCT_NAME#</cfoutput>
                            </div>
                        </div>
                    </div>
                    <div class="info-card fade-in">
                        <cfquery name="getAllStocks" datasource="#dsn2#">
                           SELECT SUM(STOCK_IN-STOCK_OUT) AS BK,STOCK_ID,STORE,STORE_LOCATION ,
        DEPARTMENT_HEAD+'-'+COMMENT AS DEPO
        FROM w3Qa_2025_1.STOCKS_ROW 
        LEFT JOIN w3Qa.DEPARTMENT AS D ON D.DEPARTMENT_ID=STORE
        LEFT JOIN w3Qa.STOCKS_LOCATION AS SL ON SL.LOCATION_ID=STORE_LOCATION AND SL.DEPARTMENT_ID=D.DEPARTMENT_ID
        WHERE STOCK_ID=#getProduct.STOCK_ID#
        GROUP BY STOCK_ID,STORE,STORE_LOCATION,DEPARTMENT_HEAD,COMMENT
        HAVING STORE_LOCATION IS NOT NULL
                        </cfquery>
                        
                        <h3 class="icon-text mb-4">
                            <i class="fas fa-warehouse"></i>
                            Stok Bilgileri
                        </h3>
                        
                        <div class="table-responsive">
                            <table class="table custom-table">
                                <thead>
                                    <tr>
                                        <th><i class="fas fa-building"></i> Depo</th>
                                        <th><i class="fas fa-boxes"></i> Toplam Stok</th>
                                        <th><i class="fas fa-chart-bar"></i> Durum</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfoutput query="getAllStocks">
                                        <tr>
                                            <td>
                                                <cfif BK gt 0>
                                                    <a href="##" onclick="getSerials('#getAllStocks.STOCK_ID#','#getAllStocks.STORE#','#getAllStocks.STORE_LOCATION#');" class="clickable-link">
                                                        <i class="fas fa-search"></i> #DEPO#
                                                    </a>
                                                <cfelse>
                                                    <span class="text-muted">
                                                        <i class="fas fa-times-circle"></i> #DEPO#
                                                    </span>
                                                </cfif>
                                            </td>
                                            <td>
                                                <span class="badge <cfif BK gt 0>bg-success<cfelse>bg-danger</cfif>">
                                                    #tlformat(BK,2)#
                                                </span>
                                            </td>
                                            <td>
                                                <cfif BK gt 0>
                                                    <i class="fas fa-check-circle text-success"></i> Stokta Var
                                                <cfelse>
                                                    <i class="fas fa-exclamation-triangle text-warning"></i> Stok Yok
                                                </cfif>
                                            </td>
                                        </tr>
                                    </cfoutput>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="row")
            <div id="serialsContainer">
                <table id="serialsTable" style="display:none;">
                    <tr></tr>
                </table>
                <!-- Serial numbers will be loaded here -->
            </div>
            <div id="hareketContainer">
                <table id="hareketTable" style="display:none;">
                    <tr></tr>
                </table>
                <!-- Serial numbers will be loaded here -->
        </div>
                <script>
                    function getSerials(stockId, departmentId, locationId) {
                        // Show container and loading spinner
                        document.getElementById("serialsContainer").style.display = "block";
                        document.getElementById("serialsLoading").style.display = "block";
                        document.getElementById("serialsTable").style.display = "none";
                        
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
                        `;
                        
                        setTimeout(function() {
                            var result = wrk_query(sql_query,"dsn3");
                            var serialsTable = document.getElementById("serialsTable");
                            var tbody = serialsTable.querySelector('tbody');
                            
                            // Hide loading spinner
                            document.getElementById("serialsLoading").style.display = "none";
                            serialsTable.style.display = "table";
                            
                            // Clear previous rows
                            tbody.innerHTML = '';
                            
                            // Add new rows
                            for(let i=0; i<result.recordcount; i++){
                                var row = tbody.insertRow();
                                var cell1 = row.insertCell(0);
                                
                                var a = document.createElement("a");
                                a.href = "#";
                                a.className = "clickable-link";
                                a.innerHTML = '<i class="fas fa-barcode"></i> ' + result.SERIAL_NO[i];
                                a.onclick = function(){ getHareket(result.SERIAL_NO[i]); };
                                cell1.appendChild(a);
                            }
                            
                            // Add fade-in animation
                            document.getElementById("serialsContainer").classList.add("fade-in");
                        }, 500);
                    }

                    function getHareket(serial_no) {
                        // Show container and loading spinner
                        document.getElementById("hareketContainer").style.display = "block";
                        document.getElementById("hareketLoading").style.display = "block";
                        document.getElementById("hareketTable").style.display = "none";
                        
                        var sql_query=`select CASE WHEN SGN.IN_OUT=1 THEN '+++' ELSE'---' END AS TR,SGN.DEPARTMENT_ID,SGN.LOCATION_ID,SGN.SERIAL_NO,DEPARTMENT_HEAD+'-'+COMMENT AS DEPO  from w3Qa_1.SERVICE_GUARANTY_NEW  AS SGN
                        LEFT JOIN w3Qa.DEPARTMENT AS D ON D.DEPARTMENT_ID=SGN.DEPARTMENT_ID
                LEFT JOIN w3Qa.STOCKS_LOCATION AS SL ON SL.LOCATION_ID=SGN.LOCATION_ID AND SL.DEPARTMENT_ID=D.DEPARTMENT_ID
                        where SERIAL_NO='${serial_no}'
                        `;
                        
                        setTimeout(function() {
                            var result = wrk_query(sql_query,"dsn3");
                            var hareketTable = document.getElementById("hareketTable");
                            var tbody = hareketTable.querySelector('tbody');
                            
                            // Hide loading spinner
                            document.getElementById("hareketLoading").style.display = "none";
                            hareketTable.style.display = "table";
                            
                            // Clear previous rows
                            tbody.innerHTML = '';
                            
                            // Add new rows
                            for(let i=0; i<result.recordcount; i++){
                                var row = tbody.insertRow();
                                var cell1 = row.insertCell(0);
                                var cell2 = row.insertCell(1);
                                var cell3 = row.insertCell(2);
                                
                                cell1.innerHTML = '<i class="fas fa-barcode"></i> ' + result.SERIAL_NO[i];
                                
                                if(result.TR[i] === '+++'){
                                    cell2.innerHTML = '<span class="badge bg-success"><i class="fas fa-arrow-up"></i> GİRİŞ</span>';
                                } else {
                                    cell2.innerHTML = '<span class="badge bg-danger"><i class="fas fa-arrow-down"></i> ÇIKIŞ</span>';
                                }
                                
                                cell3.innerHTML = '<i class="fas fa-building"></i> ' + result.DEPO[i];
                            }
                            
                            // Add fade-in animation
                            document.getElementById("hareketContainer").classList.add("fade-in");
                        }, 500);
                    }
                </script>

                <cfelse>
                    <div class="info-card fade-in">
                        <div class="text-center">
                            <i class="fas fa-exclamation-triangle text-warning" style="font-size: 3rem;"></i>
                            <h4 class="mt-3">Ürün Bulunamadı</h4>
                            <p class="text-muted">Girilen ürün kodu ile eşleşen bir ürün bulunamadı.</p>
                            <div class="badge bg-warning text-dark">
                                <i class="fas fa-info-circle"></i> Lütfen ürün kodunu kontrol edin
                            </div>
                        </div>
                    </div>
                </cfif>
            </cfif>
        </div>
    </div>

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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>