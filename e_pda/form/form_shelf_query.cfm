<div  class="form-group">
    <input type="text" placeholder="Barkod" name="barkod" id="barkod" onkeydown="checkbarcode(this,event);" class="form-control" value="">
</div>
<div class="form-group" style="margin-top:10px;">
    <input type="text" name="raf" id="raf" placeholder="Raf Kodu" onkeydown="checkRaf(this,event)">
</div>
<div class="form-group">
			<select name="BarcodeParser" id="BarcodeParser">
				<option value="0">Barkod Tipi</option>

			</select>
		</div>
        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="table table-bordered">
          <tr>
            <th width="50%" align="center" valign="middle">Raf Kodu</th>
            <th width="25%" align="center" valign="middle">Kapasite</th>
            <th width="25%" align="center" valign="middle">Mevcut</th>
          </tr>
          <tbody id="shelf_results_body"></tbody>
          

<script>
var bm=null;
var main_product_id=0;
var main_stock_id=0;
$(document).ready(function(){
    bm=new BarcodeManager();
    var parsers=bm.listParsers();
for(var i=0;i<parsers.length;i++){
	$("#BarcodeParser").append('<option value="'+parsers[i].id+'">'+parsers[i].name+'</option>');
}
});
    function checkbarcode(input, event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            var barcode = input.value.trim();
            var parserVal = document.getElementById('BarcodeParser').value;
        var parserId = parseInt(parserVal, 10);
        var SerialObject = null;
        var product_code_2 = '';
        try {
            if (!isNaN(parserId) && parserId > 0) {
                SerialObject = bm.parseWith(barcode, parserId);
                console.log('Barcode parsed for serial number:', SerialObject);
                if (SerialObject && SerialObject.serial_no) {
                   product_code_2= SerialObject.product_code_2;
                   createRows(product_code_2);
                     console.log('Extracted product_code_2:', product_code_2);
                }
            } else {
                console.log('No barcode parser selected, using raw serial.');
            }
        } catch (parseErr) {
            console.warn('Barcode parsing failed, using raw input.', parseErr);
        }
        }
    }
    function createRows(product_code_2){
        



var sql=`SELECT * FROM STOCKS WHERE PRODUCT_CODE_2='${product_code_2}'`
console.log(sql)
var qResult=wrk_query(sql,"dsn3")
console.log(qResult)
var stockId=qResult.STOCK_ID[0];
var productId=qResult.STOCK_ID[0];
var main_stock_id=stockId;
var main_product_id=productId;
console.table({stockId,productId,product_code_2})
var recordedShelfsQuery=`SELECT SHELF_CODE,PP.PRODUCT_PLACE_ID FROM w3Qa_1.PRODUCT_PLACE AS PP LEFT JOIN w3Qa_1.PRODUCT_PLACE_ROWS AS PPR ON PPR.PRODUCT_PLACE_ID=PP.PRODUCT_PLACE_ID
WHERE PPR.STOCK_ID=${stockId}`;
var recordedShelfsQueryResult=wrk_query(recordedShelfsQuery,"dsn3")
var tablo=document.getElementById("shelf_results_body")
if(recordedShelfsQueryResult.recordcount==0){
    tablo.innerHTML="<tr><td colspan='3' align='center'>Bu ürüne ait raf bulunamadı.</td></tr>";
    //return;
    $("#raf").val("");
    $("#raf").focus();
}else{
    tablo.innerHTML="";

for(let i=0;i<recordedShelfsQueryResult.recordcount;i++){
    var tr=document.createElement("tr");
    var td=document.createElement("td");
    td.innerText=recordedShelfsQueryResult.SHELF_CODE[i];
    tr.appendChild(td)
    tablo.appendChild(tr);
}}
    }
    function wrk_query(str_query, data_source, maxrows) {
    if (!data_source) data_source = 'dsn';
    if (!maxrows) maxrows = 0;
    
    var new_query = new Object();
    var req = createXMLHttpRequest();
    
    if (req) {
        req.open("post", '/index.cfm?fuseaction=objects2.emptypopup_get_js_query&isAjax=1&xmlhttp=1', false);
        req.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setRequestHeader('pragma', 'nocache');
        
        var queryParam = encodeURI(str_query).indexOf('+') == -1 ? 
            'str_sql=' + encodeURI(str_query) : 
            'str_sql=' + encodeURIComponent(str_query);
            
        req.send(queryParam + '&data_source=' + data_source + '&maxrows=' + maxrows);
        
        if (req.readyState == 4 && req.status == 200) {
            try {
                eval(req.responseText.replace(/\u200B/g, ''));
                new_query = get_js_query;
            } catch(e) {
                new_query = false;
            }
        }
    }
    
    return new_query;
}
function createXMLHttpRequest() {
    var req = false;
    
    if (window.XMLHttpRequest) {
        try {
            req = new XMLHttpRequest();
        } catch(e) {
            req = false;
        }
    } else if (window.ActiveXObject) {
        try {
            req = new ActiveXObject("Msxml2.XMLHTTP");
        } catch(e) {
            try {
                req = new ActiveXObject("Microsoft.XMLHTTP");
            } catch(e) {
                req = false;
            }
        }
    }
    
    return req;
}
function checkRaf(input,event) {
   if(event.key==='Enter'){
       event.preventDefault();
       var rafCode=input.value.trim();
       console.log('Raf Kodu Girildi:',rafCode);
    var r=wrk_query("SELECT * FROM PRODUCT_PLACE WHERE SHELF_CODE='"+rafCode+"'","dsn3");
    if(r.recordcount>0){
        console.log('Raf Kodu Bulundu:',rafCode);
        var d={
            shelf_code:rafCode,
            product_id:main_product_id,
            stock_id:main_stock_id
        };
        console.log('Gönderilen Veri:',d);
        
   }else{
       console.log('Raf Kodu Bulunamadı:',rafCode);
       alert('Böyle bir raf kodu bulunamadı!');
   }
   }

}
</script>

