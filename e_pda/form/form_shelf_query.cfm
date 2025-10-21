<div  class="form-group">
    <input type="text" placeholder="Barkod" name="barkod" id="barkod" onkeydown="checkbarcode(this,event);" class="form-control" value="">
</div>
<div class="form-group">
			<select name="BarcodeParser" id="BarcodeParser">
				<option value="0">Barkod Tipi</option>

			</select>
		</div>

<script>
var bm=null;
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
</script>

