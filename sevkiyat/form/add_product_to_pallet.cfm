<cfquery name="getPaperSerials" datasource="#dsn3#">
    SELECT (
        SELECT DISTINCT
            SG.SERIAL_NO,SG.STOCK_ID
        FROM w3Qa_1.SHIPPING_PALLET_SVK_PBS SP
        LEFT JOIN w3Qa_1.EZGI_SHIP_RESULT ESR ON ESR.SHIP_RESULT_ID = SP.ORDER_ID
        LEFT JOIN (
            SELECT FIS_ID, REF_NO, 2 AS PERIODID FROM w3Qa_2025_1.STOCK_FIS
            UNION ALL
            SELECT FIS_ID, REF_NO, 1 AS PERIODID FROM w3Qa_2024_1.STOCK_FIS
        ) SF ON SF.REF_NO = ESR.DELIVER_PAPER_NO
        LEFT JOIN w3Qa_1.SERVICE_GUARANTY_NEW SG ON SG.PROCESS_ID = SF.FIS_ID AND SG.PERIOD_ID = SF.PERIODID
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
    <cfif len(getSavedPalletRows.T) EQ 0>
       var savedPalletRows = "[]";
        <cfelse>
            var savedPalletRows=<cfoutput>#getSavedPalletRows.T#</cfoutput>;
    </cfif>
    
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
</cf_box>

<script>
    $(document).ready(function(){
      bm=new BarcodeManager();
var parsers=bm.listParsers();
for(var i=0;i<parsers.length;i++){
	$("#BarcodeParser").append('<option value="'+parsers[i].id+'">'+parsers[i].name+'</option>');
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
    }
    
}
</script>