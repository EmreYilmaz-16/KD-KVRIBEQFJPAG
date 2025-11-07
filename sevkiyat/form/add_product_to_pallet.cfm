<cfquery name="getPaperSerials" datasource="#dsn3#">
    SELECT (
        SELECT DISTINCT
            SG.SERIAL_NO,SG.STOCK_ID,S.PRODUCT_ID
        FROM w3Qa_1.SHIPPING_PALLET_SVK_PBS SP
        LEFT JOIN w3Qa_1.EZGI_SHIP_RESULT ESR ON ESR.SHIP_RESULT_ID = SP.ORDER_ID
        LEFT JOIN (
            SELECT FIS_ID, REF_NO, 2 AS PERIODID FROM w3Qa_2025_1.STOCK_FIS
            UNION ALL
            SELECT FIS_ID, REF_NO, 1 AS PERIODID FROM w3Qa_2024_1.STOCK_FIS
        ) SF ON SF.REF_NO = ESR.DELIVER_PAPER_NO
        LEFT JOIN w3Qa_1.SERVICE_GUARANTY_NEW SG ON SG.PROCESS_ID = SF.FIS_ID AND SG.PERIOD_ID = SF.PERIODID
        LEFT JOIN w3Qa_1.STOCKS S ON S.STOCK_ID = SG.STOCK_ID
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
        FROM w3Qa_1.SHIPPING_PALLET_ROWS_PBS SPR
        INNER JOIN w3Qa_product.PRODUCT P ON P.PRODUCT_ID = SPR.PRODUCT_ID
        WHERE SPR.PALLET_ID = <cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer">
        FOR JSON PATH
        ) AS T
    </cfquery>



<script>
    var paperSerials=<cfoutput>#getPaperSerials.T#</cfoutput>;
    var palletId = <cfoutput>#Val(attributes.pallet_id)#</cfoutput>;
    var savedPalletRows = [];
    <cfif len(getSavedPalletRows.T) EQ 0>
        savedPalletRows = [];
        <cfelse>
             savedPalletRows=<cfoutput>#getSavedPalletRows.T#</cfoutput>;
    </cfif>
    var palletProductsTableProducts=[];
</script>

<cf_box title="Palete Urun Ekle">
<div class="form-group" style="margin-top: 24px; margin-left: 10px;">
			<select name="BarcodeParser" id="BarcodeParser">
				<option value="0">Barkod Tipi</option>

			</select>
		</div>
<div class="form-group">
    <input type="text" id="productBarcodeInput" class="form-control" onkeydown="checkKey(this,event)" placeholder="Urun Barkodu Giriniz" style="width: 300px; display: inline-block; margin-right: 10px;">

</div>

<table>
    <thead>
        <tr>
            <th>Urun Barkodu</th>
            <th>Urun Kodu</th>
            <th>Islem</th>
        </tr>
    </thead>
    <tbody id="palletProductsTableBody">
        <!-- Urun satirlari buraya eklenecek -->
    </tbody>
</table>


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
        }
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

palletProductsTableProducts.push({
    SERIAL_NO:serial_no,
    PRODUCT_ID:paperSerials[ix1].STOCK_ID,
    STOCK_ID:paperSerials[ix1].STOCK_ID,
    PRODUCT_CODE_2:product_code_2
});
renderPalletProductsTable();
$("#productBarcodeInput").val("");

}
function renderPalletProductsTable(){
    var tbody=$("#palletProductsTableBody");
    tbody.empty();
    for(var i=0;i<palletProductsTableProducts.length;i++){
        var row='<tr>'+
            '<td>'+palletProductsTableProducts[i].SERIAL_NO+'</td>'+
            '<td>'+palletProductsTableProducts[i].PRODUCT_CODE_2+'</td>'+
            '<td><button class="btn btn-danger" onclick="removePalletProductRow('+i+')">Kaldir</button></td>'+
            '</tr>';
        tbody.append(row);
    }
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
        url: '/index.cfm?fuseaction=eshipping.save_product_pallet_pbs',
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            pallet_id: palletId,
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