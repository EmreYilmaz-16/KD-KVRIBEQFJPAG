<cfquery name="GETPERIODS" datasource="#DSN#">
    SELECT TOP 2 PERIOD_ID,OUR_COMPANY_ID,PERIOD_YEAR FROM SETUP_PERIOD ORDER BY PERIOD_ID DESC
</cfquery>
<cfquery name="getPaperSerials" datasource="#dsn3#">
    SELECT (
        SELECT DISTINCT
            SG.SERIAL_NO,SG.STOCK_ID,S.PRODUCT_ID
        FROM #dsn3#.SHIPPING_PALLET_SVK_PBS SP
        LEFT JOIN #dsn3#.EZGI_SHIP_RESULT ESR ON ESR.SHIP_RESULT_ID = SP.ORDER_ID
        LEFT JOIN (
           <!---- SELECT FIS_ID, REF_NO, 2 AS PERIODID FROM #dsn2#.STOCK_FIS
            UNION ALL
            SELECT FIS_ID, REF_NO, 1 AS PERIODID FROM STOCK_FIS---->
            <cfloop query="GETPERIODS">
                <cfif GETPERIODS.currentRow GT 1>
                    UNION ALL
                </cfif>
                SELECT FIS_ID, REF_NO, #GETPERIODS.PERIOD_ID# AS PERIODID FROM #dsn#_#GETPERIODS.PERIOD_YEAR#_#GETPERIODS.OUR_COMPANY_ID#.STOCK_FIS
            </cfloop>
        ) SF ON SF.REF_NO = ESR.DELIVER_PAPER_NO
        LEFT JOIN #dsn3#.SERVICE_GUARANTY_NEW SG ON SG.PROCESS_ID = SF.FIS_ID AND SG.PERIOD_ID = SF.PERIODID
        LEFT JOIN #dsn3#.STOCKS S ON S.STOCK_ID = SG.STOCK_ID
        WHERE SP.PALLET_ID=<cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer">
        FOR JSON PATH
    ) AS T
</cfquery>
   <cfquery name="getSavedPalletRows" datasource="#dsn3#">
        SELECT (
        SELECT SPR.SERIAL_NUMBER,
               SPR.PRODUCT_ID,
               SPR.STOCK_ID,
               P.PRODUCT_CODE_2
        FROM #dsn3#.SHIPPING_PALLET_ROWS_PBS SPR
        INNER JOIN #DSN1#.PRODUCT P ON P.PRODUCT_ID = SPR.PRODUCT_ID
        WHERE SPR.PALLET_ID = <cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer">
        FOR JSON PATH
        ) AS T
    </cfquery>



<style>
.pallet-form-container {
    padding: 24px 28px;
    background: #f6f9fc;
    border-radius: 12px;
    border: 1px solid #e0e6ed;
    max-width: 720px;
}

.pallet-form-title {
    font-size: 18px;
    font-weight: 600;
    color: #1f2933;
    margin-bottom: 16px;
}

.pallet-form-row {
    display: flex;
    gap: 16px;
    flex-wrap: wrap;
    margin-bottom: 18px;
}

.pallet-form-group {
    flex: 1;
    min-width: 220px;
}

.pallet-form-group label {
    display: block;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    color: #52606d;
    margin-bottom: 6px;
}

.pallet-form-select,
.pallet-form-input {
    width: 100%;
    padding: 10px 12px;
    border-radius: 8px;
    border: 1px solid #cbd2d9;
    font-size: 14px;
    transition: border 0.2s ease, box-shadow 0.2s ease;
    background: #ffffff;
}

.pallet-form-select:focus,
.pallet-form-input:focus {
    outline: none;
    border: 1px solid #2bb0ed;
    box-shadow: 0 0 0 3px rgba(43, 176, 237, 0.2);
}

.pallet-table-wrapper {
    background: #ffffff;
    border-radius: 12px;
    border: 1px solid #e0e6ed;
    overflow: hidden;
}

.pallet-table {
    width: 100%;
    border-collapse: collapse;
}

.pallet-table thead {
    background: linear-gradient(90deg, #2bb0ed 0%, #0a6cbd 100%);
    color: #ffffff;
    text-align: left;
    font-size: 12px;
    letter-spacing: 0.5px;
    text-transform: uppercase;
}

.pallet-table th,
.pallet-table td {
    padding: 12px 16px;
    border-bottom: 1px solid #e9edf3;
    font-size: 14px;
    color: #1f2933;
}

.pallet-table tbody tr:nth-child(even) {
    background: #f8fafc;
}

.pallet-actions {
    display: flex;
    justify-content: flex-end;
    margin-top: 20px;
}

.pallet-save-button {
    min-width: 220px;
    padding: 12px 16px;
    font-weight: 600;
    font-size: 14px;
    border-radius: 8px;
}

.pallet-counter {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    font-size: 13px;
    color: #3d4852;
    background: #e3f8ff;
    border-radius: 999px;
    padding: 6px 14px;
    border: 1px solid #b3ecff;
    margin-bottom: 18px;
}

.pallet-counter strong {
    font-size: 16px;
    color: #0a6cbd;
}

.pallet-empty-state {
    text-align: center;
    padding: 32px 16px;
    color: #7b8794;
    font-size: 14px;
}
</style>

<script>
    var paperSerials=<cfoutput>#getPaperSerials.T#</cfoutput>;
    var palletId=<cfoutput>#Val(attributes.pallet_id)#</cfoutput>;
    var userId=<cfoutput>#session.ep.USERID#</cfoutput>;
    var savedPalletRows=[];
    <cfif len(getSavedPalletRows.T) EQ 0>
        savedPalletRows=[];
    <cfelse>
        savedPalletRows=<cfoutput>#getSavedPalletRows.T#</cfoutput>;
    </cfif>
    var palletProductsTableProducts=[];
</script>

<cf_box title="Palete Urun Ekle">
<div class="pallet-form-container">
    <div class="pallet-form-title">Palete ürün eklemek için barkod bilgilerini girin.</div>
    <div class="pallet-form-row">
        <div class="pallet-form-group">
            <label for="BarcodeParser">Barkod Tipi</label>
            <select name="BarcodeParser" id="BarcodeParser" class="pallet-form-select">
                <option value="0">Barkod tipini seçiniz</option>
            </select>
        </div>
        <div class="pallet-form-group">
            <label for="productBarcodeInput">Ürün Barkodu</label>
            <input type="text" id="productBarcodeInput" class="pallet-form-input" onkeydown="checkKey(this,event)" placeholder="Barkodu okutun veya yazın">
        </div>
    </div>

    <div class="pallet-counter">
        <span>Palete eklenen ürün sayısı:</span>
        <strong id="palletProductCount">0</strong>
    </div>

    <div class="pallet-table-wrapper">
        <table class="pallet-table">
            <thead>
                <tr>
                    <th>Ürün Barkodu</th>
                    <th>Ürün Kodu</th>
                    <th>İşlem</th>
                </tr>
            </thead>
            <tbody id="palletProductsTableBody">
                <tr class="pallet-empty-state">
                    <td colspan="3">Palete henüz ürün eklenmedi.</td>
                </tr>
            </tbody>
        </table>
    </div>

    <div class="pallet-actions">
        <input type="button" class="btn btn-success pallet-save-button" value="Ürünleri Palete Kaydet" onclick="savePaper()">
    </div>
</div>

</cf_box>

<script>
    $(document).ready(function(){
      bm=new BarcodeManager();
var parsers=bm.listParsers();
for(var i=0;i<parsers.length;i++){
	$("#BarcodeParser").append('<option value="'+parsers[i].id+'">'+parsers[i].name+'</option>');
}
    if(savedPalletRows.length>0){
        for(var j=0;j<savedPalletRows.length;j++){
            //addRow("Kayitli Urun: ",savedPalletRows[j]);
            palletProductsTableProducts.push({
                SERIAL_NO:savedPalletRows[j].SERIAL_NUMBER,
                PRODUCT_ID:savedPalletRows[j].PRODUCT_ID,
                STOCK_ID:savedPalletRows[j].STOCK_ID,
                PRODUCT_CODE_2:savedPalletRows[j].PRODUCT_CODE_2
            });
        }
        renderPalletProductsTable();
    }
    });

function checkKey(el,event){
    if(event.keyCode==13){
        event.preventDefault();
        var parserId=$("#BarcodeParser").val();
        var serial_=el.value;
        if(parserId==0){
            alert("Lutfen bir barkod tipi seciniz.");
            return;
        }
        var bm=new BarcodeManager();
        var serialObject=bm.parseWith(serial_, parseInt(document.getElementById('BarcodeParser').value));
        console.log(serialObject);
        if(serialObject.success){
            addProductToPallet(serialObject.serial_no,serialObject.product_code_2);
        }else{
            alert("Barkod okunamadi: "+serialObject.error);
            $(el).val("");
        }
    }
    
}

function addProductToPallet(serial_no,product_code_2){
    var ix1=paperSerials.findIndex(p=>p.SERIAL_NO==serial_no);
    if(ix1==-1){
        alert("Girilen barkoda ait urun bulunamadi.");
        $("#productBarcodeInput").val("");
        return;
    }
    var ix2=palletProductsTableProducts.findIndex(p=>p.SERIAL_NO==serial_no);
    if(ix2!=-1){
        alert("Bu urun zaten palete eklenmis.");
        $("#productBarcodeInput").val("");
        return;
    }

    var qr=`SELECT PRODUCT_ID,STOCK_ID,PRODUCT_CODE_2 FROM STOCKS WHERE PRODUCT_CODE_2='${product_code_2}'`;
    console.log(qr);
    var result=wrk_query(qr,'dsn3',1);
    console.log(result);
    if(result.recordCount==0){
        alert("Urun koduna ait stok kaydi bulunamadi.");
        $("#productBarcodeInput").val("");
        return;
    }else{
        var rpid=result.PRODUCT_ID[0];
        var rsid=result.STOCK_ID[0];
        if(rpid!=paperSerials[ix1].PRODUCT_ID || rsid!=paperSerials[ix1].STOCK_ID){
            alert("Urun kodu ile barkod uyusmuyor.");
            $("#productBarcodeInput").val("");
            return;
        }
    }

palletProductsTableProducts.push({
    SERIAL_NO:serial_no,
    PRODUCT_ID:paperSerials[ix1].PRODUCT_ID,
    STOCK_ID:paperSerials[ix1].STOCK_ID,
    PRODUCT_CODE_2:product_code_2
});
renderPalletProductsTable();
$("#productBarcodeInput").val("");

}
function renderPalletProductsTable(){
    var tbody=$("#palletProductsTableBody");
    tbody.empty();
    if(palletProductsTableProducts.length===0){
        tbody.append('<tr class="pallet-empty-state"><td colspan="3">Palete henüz ürün eklenmedi.</td></tr>');
    }else{
        for(var i=0;i<palletProductsTableProducts.length;i++){
            var row='<tr>'+
                '<td>'+palletProductsTableProducts[i].SERIAL_NO+'</td>'+
                '<td>'+palletProductsTableProducts[i].PRODUCT_CODE_2+'</td>'+
                '<td><button class="btn btn-danger btn-sm" onclick="removePalletProductRow('+i+')">Kaldır</button></td>'+
                '</tr>';
            tbody.append(row);
        }
    }
    $('#palletProductCount').text(palletProductsTableProducts.length);
}
function removePalletProductRow(index){
    palletProductsTableProducts.splice(index,1);
    renderPalletProductsTable();
}
function savePaper() {
    if (palletProductsTableProducts.length == 0) {
        alert("Palete eklenmis urun bulunamadi.");
        return;
    }

    

    $.ajax({
        url: '/AddOns/Partner/cfc/sevkiyat_service.cfc?method=saveProductsToPallet',
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            pallet_id: palletId,
            userid: userId,
            products: palletProductsTableProducts
        }),
        success: function (response) {
            alert("Urunler palete basariyla eklendi.");
            // Isterseniz sayfayi yenileyebilir veya baska islemler yapabilirsiniz
        },
        error: function (xhr, status, error) {
            alert("Hata olustu: " + error);
        }
    });
    
}


</script>


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