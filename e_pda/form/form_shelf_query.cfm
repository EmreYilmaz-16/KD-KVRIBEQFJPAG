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
                SerialObject = bm.parseWith(serial_number, parserId);
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
</script>

