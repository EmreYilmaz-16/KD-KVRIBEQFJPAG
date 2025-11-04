<div class="form-group" style="margin-top: 24px; margin-left: 10px;">
			<select name="BarcodeParser" id="BarcodeParser">
				<option value="0">Barkod Tipi</option>

			</select>
		</div>
<div class="form-group">
    <input type="text" name="barcode" id="barcode" onkeydown="checkKey(this,event)">
</div>
<cfform method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
    <table>
        <tr>
            <th>
                Ürün
            </th>
            <th>
                Miktar
            </th>
            <th></th>
        </tr>
    <tbody id="tablo1">

    </tbody>
    </table>
</cfform>

<script>
var productArray = [];
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
                    var sn=SerialObject.serial_no;
                    var ix=productArray.findIndex(item => item.serial.includes(sn));
                    if(ix!==-1){
                        alert("Bu seri numarası zaten eklendi.");
                        field.value = "";
                        return;
                    }
                    addSerial(SerialObject);
                    window.close();
                } else {
                    alert("Geçersiz barkod. Lütfen tekrar deneyin.");
                    field.value = "";
                }
            }
        }
    }
    function addSerial(SerialObject) {
        var tbody = document.getElementById("tablo1");
        var ix =productArray.findIndex(item => item.product_code_2 === SerialObject.product_code_2);
 
        if (ix !== -1) {
            productArray[ix].quantity += 1;
            document.getElementById("quantity_" + SerialObject.product_code_2).innerText = productArray[ix].quantity;
            productArray[ix].serial.push(SerialObject.serial_no);
        } else {
            productArray.push({
                product_code_2: SerialObject.product_code_2,
                serial: [SerialObject.serial_no],
                quantity: 1
            });
            var row = document.createElement("tr");

            var cellProduct = document.createElement("td");
            cellProduct.innerText = SerialObject.product_code_2;
            row.appendChild(cellProduct);

            var cellQuantity = document.createElement("td");
            cellQuantity.id = "quantity_" + SerialObject.product_code_2;
            cellQuantity.innerText = 1;
            row.appendChild(cellQuantity);

            var cellAction = document.createElement("td");
            var removeButton = document.createElement("button");
            removeButton.innerText = "Kaldır";
            removeButton.onclick = function() {
                removeSerial(SerialObject.product_code_2);
            };
            cellAction.appendChild(removeButton);
            var showSerialsButton = document.createElement("button");
            showSerialsButton.innerText = "Seri Numaralarını Göster";
            showSerialsButton.onclick = function() {
                alert("Seri Numaraları: " + productArray[ix].serial.join(", "));
            };
            cellAction.appendChild(showSerialsButton);
            
            row.appendChild(cellAction);

            tbody.appendChild(row);
        }
        
    }
</script>