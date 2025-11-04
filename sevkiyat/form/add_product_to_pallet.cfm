<div class="form-group" style="margin-top: 24px; margin-left: 10px;">
			<select name="BarcodeParser" id="BarcodeParser">
				<option value="0">Barkod Tipi</option>

			</select>
		</div>
<div class="form-group">
    <input type="text" name="barcode" id="barcode" onkeydown="checkKey(this,event)">
</div>

<script>
var bm=null;
$(document).ready(function() {
    $('#barcode').focus();
    	 bm=new BarcodeManager();
var parsers=bm.listParsers();
for(var i=0;i<parsers.length;i++){
	$("#BarcodeParser").append('<option value="'+parsers[i].id+'">'+parsers[i].name+'</option>');
}

});
    function checkKey(field, event) {
        var keyCode = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
        if (keyCode == 13) {
            event.preventDefault();
            var barcodeValue = field.value.trim();
            if (barcodeValue !== "") {
                var SerialObject = bm.parseWith(barcodeValue, parseInt(document.getElementById('BarcodeParser').value));
            console.log(SerialObject);
                if (SerialObject != null) {
                    window.opener.addShippingToPallet(SerialObject);
                    window.close();
                } else {
                    alert("Geçersiz barkod. Lütfen tekrar deneyin.");
                    field.value = "";
                }
            }
        }
    }
</script>