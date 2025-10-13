<cfparam name="attributes.product_code_2" default="">
<cfparam name="attributes.is_submitted" default="0">

<style>
    :root {
        --serial-bg: linear-gradient(145deg, #f8fbff 0%, #edf2ff 40%, #f9f5ff 100%);
        --serial-card-shadow: 0 18px 38px rgba(15, 28, 67, 0.08);
        --serial-border: 1px solid rgba(113, 128, 150, 0.12);
        --serial-accent: #3758f9;
        --serial-accent-light: rgba(55, 88, 249, 0.12);
    }

    .serial-dashboard-shell {
        background: var(--serial-bg);
        min-height: 100vh;
        padding: 2rem 0;
    }

    .serial-dashboard {
        background-color: rgba(255, 255, 255, 0.92);
        backdrop-filter: blur(12px);
        border-radius: 1.25rem;
        box-shadow: var(--serial-card-shadow);
        padding: 2.5rem;
    }

    .serial-hero {
        border-radius: 1rem;
        background: #111827;
        color: #f9fafb;
        padding: 2.2rem clamp(1.5rem, 4vw, 2.8rem);
        margin-bottom: 2.2rem;
        box-shadow: inset 0 0 0 1px rgba(255,255,255,0.05);
        position: relative;
        overflow: hidden;
    }

    .serial-hero::before {
        content: "";
        position: absolute;
        inset: auto -40% -60% 40%;
        height: 120%;
        background: radial-gradient(circle at 50% 50%, rgba(55,88,249,0.35), transparent 65%);
        z-index: 0;
    }

    .serial-hero > * {
        position: relative;
        z-index: 1;
    }

    .serial-hero h2 {
        font-size: clamp(1.35rem, 2.2vw, 1.75rem);
        font-weight: 600;
        letter-spacing: 0.03em;
        margin-bottom: 0.5rem;
    }

    .serial-hero p {
        font-size: 0.95rem;
        color: rgba(249, 250, 251, 0.72);
        max-width: 28rem;
    }

    .serial-hero .serial-search {
        background: rgba(17, 24, 39, 0.6);
        border-radius: 1rem;
        padding: 1.5rem;
        border: 1px solid rgba(255,255,255,0.08);
        box-shadow: inset 0 0 0 1px rgba(255,255,255,0.04);
    }

    .serial-search label {
        font-size: 0.85rem;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        color: rgba(249, 250, 251, 0.76);
    }

    .serial-search input[type="text"] {
        background-color: rgba(255, 255, 255, 0.12);
        border: 1px solid rgba(255,255,255,0.18);
        color: #fff;
    }

    .serial-search input[type="text"]::placeholder {
        color: rgba(255,255,255,0.5);
    }

    .serial-search .btn {
        font-weight: 600;
        letter-spacing: 0.04em;
        box-shadow: 0 10px 25px rgba(55, 88, 249, 0.35);
    }

    .serial-section-title {
        font-size: 0.95rem;
        font-weight: 600;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        color: #6c7a91;
        margin-bottom: 1.25rem;
    }

    .serial-card {
        border-radius: 1rem;
        border: var(--serial-border);
        box-shadow: 0 10px 25px rgba(15, 28, 67, 0.05);
        background: #fff;
        height: 100%;
        display: flex;
        flex-direction: column;
    }

    .serial-card__header {
        padding: 1.1rem 1.4rem 0.85rem;
        border-bottom: 1px solid rgba(226, 232, 240, 0.8);
        font-weight: 600;
        letter-spacing: 0.05em;
        color: #1f2937;
    }

    .serial-card__body {
        padding: 1.1rem 1.4rem 1.35rem;
        flex-grow: 1;
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    .serial-card__body .serial-table {
        margin-bottom: 0;
    }

    .serial-meta {
        display: grid;
        gap: 0.75rem;
    }

    .serial-meta__item {
        padding: 0.75rem 1rem;
        background: rgba(55, 88, 249, 0.06);
        border-radius: 0.85rem;
    }

    .serial-meta__label {
        font-size: 0.75rem;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        color: #5d6a85;
        margin-bottom: 0.35rem;
        display: block;
    }

    .serial-meta__value {
        font-weight: 600;
        color: #1f2937;
        font-size: 1rem;
    }

    .serial-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
    }

    .serial-table thead th {
        font-size: 0.75rem;
        font-weight: 700;
        letter-spacing: 0.12em;
        text-transform: uppercase;
        color: #8a94aa;
        padding-bottom: 0.65rem;
        border-bottom: 1px solid rgba(226, 232, 240, 0.9);
    }

    .serial-table tbody td {
        padding: 0.65rem 0;
        font-size: 0.9rem;
        color: #364152;
        border-bottom: 1px dotted rgba(226, 232, 240, 0.7);
    }

    .serial-table tbody tr:last-child td {
        border-bottom: none;
    }

    .serial-table tbody tr:hover td {
        background-color: rgba(55, 88, 249, 0.06);
    }

    .serial-table tbody a {
        font-weight: 600;
        color: var(--serial-accent);
        text-decoration: none;
    }

    .serial-table tbody a:hover {
        color: #1a2dd6;
        text-decoration: underline;
    }

    .serial-empty {
        background: var(--serial-accent-light);
        color: var(--serial-accent);
        border-radius: 0.85rem;
        padding: 0.85rem 1rem;
        font-size: 0.85rem;
        font-weight: 500;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
    }

    .serial-empty::before {
        content: '\2753';
        font-size: 1rem;
    }

    .serial-chip {
        display: inline-flex;
        align-items: center;
        gap: 0.35rem;
        padding: 0.45rem 0.75rem;
        border-radius: 999px;
        background: rgba(55, 88, 249, 0.12);
        color: var(--serial-accent);
        font-size: 0.8rem;
        letter-spacing: 0.04em;
    }

    @media (max-width: 768px) {
        .serial-dashboard {
            padding: 1.5rem;
        }

        .serial-hero {
            padding: 1.75rem 1.5rem;
        }
    }
</style>

<cfform method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
    <div class="serial-dashboard-shell">
        <div class="container-xl">
            <div class="serial-dashboard">
                <div class="serial-hero row g-4 align-items-center">
                    <div class="col-12 col-lg-7">
                        <div class="serial-chip">Seri Paneli</div>
                        <h2>Seri Takip &amp; Depo Görünümü</h2>
                        <p>Ürün kodu girerek stok dağılımını, seri numaralarını ve hareket geçmişini aynı ekrandan hemen inceleyebilirsiniz.</p>
                        <cfif len(trim(attributes.product_code_2))>
                            <div class="serial-chip mt-3">Son arama: <strong><cfoutput>#attributes.product_code_2#</cfoutput></strong></div>
                        </cfif>
                    </div>
                    <div class="col-12 col-lg-5">
                        <div class="serial-search">
                            <div class="mb-3">
                                <label class="form-label" for="product_code_2">Ürün Kodu 2</label>
                                <input type="text" class="form-control form-control-sm" id="product_code_2" name="product_code_2" placeholder="Örn. 123-ABC-456" value="<cfoutput>#attributes.product_code_2#</cfoutput>">
                            </div>
                            <input type="hidden" name="is_submitted" value="1">
                            <input type="submit" class="btn btn-primary btn-sm w-100" value="Ürünü Getir">
                        </div>
                    </div>
                </div>

<cfif attributes.is_submitted eq 1>
   <cfquery name="getProduct" datasource="#dsn3#">
    SELECT STOCK_ID,PRODUCT_ID,PRODUCT_NAME,PRODUCT_CODE_2 FROM STOCKS WHERE PRODUCT_CODE_2='#attributes.product_code_2#'
</cfquery>

    <cfif structKeyExists(getProduct, "PRODUCT_ID")>
        <div class="serial-section-title">Ürün Özeti</div>
        <div class="row g-4">
            <div class="col-12 col-lg-3">
                <div class="serial-card">
                    <div class="serial-card__header">Ürün Bilgisi</div>
                    <div class="serial-card__body">
                        <div class="serial-meta">
                            <div class="serial-meta__item">
                                <span class="serial-meta__label">Product ID</span>
                                <span class="serial-meta__value"><cfoutput>#getProduct.PRODUCT_ID#</cfoutput></span>
                            </div>
                            <div class="serial-meta__item">
                                <span class="serial-meta__label">Stock ID</span>
                                <span class="serial-meta__value"><cfoutput>#getProduct.STOCK_ID#</cfoutput></span>
                            </div>
                            <div class="serial-meta__item">
                                <span class="serial-meta__label">Product Name</span>
                                <span class="serial-meta__value"><cfoutput>#getProduct.PRODUCT_NAME#</cfoutput></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-lg-3">
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
                <cfset totalStock = 0>
                <cfloop query="getAllStocks">
                    <cfset totalStock += getAllStocks.BK>
                </cfloop>
                <div class="serial-card">
                    <div class="serial-card__header d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <span>Stok Dağılımı</span>
                        <cfif getAllStocks.recordcount>
                            <span class="serial-chip">Toplam: <strong>#tlformat(totalStock,2)#</strong></span>
                        </cfif>
                    </div>
                    <div class="serial-card__body">
                        <table class="serial-table">
                            <thead>
                                <tr>
                                    <th scope="col">Depo</th>
                                    <th scope="col" class="text-end">Toplam</th>
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
                        <cfif not getAllStocks.recordcount>
                            <div class="serial-empty mt-3">Bu ürün için kayıtlı stok bulunamadı.</div>
                        </cfif>
                    </div>
                </div>
            </div>
            <div class="col-12 col-lg-3" id="serialsContainer">
                <div class="serial-card h-100">
                    <div class="serial-card__header">Seri Numaraları</div>
                    <div class="serial-card__body">
                        <table class="serial-table d-none" id="serialsTable">
                            <thead>
                                <tr>
                                    <th scope="col">Seri</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                        <div class="serial-empty" id="serialsPlaceholder">Depodaki stok satırına tıklayarak seri numaralarını görüntüleyin.</div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-lg-3" id="hareketContainer">
                <div class="serial-card h-100">
                    <div class="serial-card__header">Hareket Geçmişi</div>
                    <div class="serial-card__body">
                        <table class="serial-table d-none" id="hareketTable">
                            <thead>
                                <tr>
                                    <th scope="col">Seri</th>
                                    <th scope="col">İşlem</th>
                                    <th scope="col">Depo</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                        <div class="serial-empty" id="hareketPlaceholder">Seri numarası seçildiğinde hareket listesi burada görünecek.</div>
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
        <div class="serial-card mt-4">
            <div class="serial-card__body text-center py-5">
                <div class="serial-empty">Girilen ürün kodu için kayıt bulunamadı. Lütfen farklı bir kod deneyin.</div>
            </div>
        </div>
    </cfif>
</cfif>
            </div>
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