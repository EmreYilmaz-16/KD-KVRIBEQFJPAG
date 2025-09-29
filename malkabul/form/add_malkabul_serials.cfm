<cfquery name="getDespatchRow" datasource="#dsn2#">
   SELECT S.STOCK_ID,S.PRODUCT_ID,S.PRODUCT_NAME,SR.AMOUNT,SG.SERIAL_NO,SR.WRK_ROW_ID,PRODUCT_CODE_2,
(SELECT COUNT(*) FROM w3Qa_1.SERVICE_GUARANTY_NEW AS SGA WHERE SGA.WRK_ROW_ID=SR.WRK_ROW_ID) AS OMIK
FROM w3Qa_2025_1.SHIP_ROW AS SR
LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID=SR.STOCK_ID
LEFT JOIN w3Qa_1.SERVICE_GUARANTY_NEW AS SG ON SG.WRK_ROW_ID=SR.WRK_ROW_ID
WHERE SHIP_ID=3
 ORDER BY PRODUCT_ID
</cfquery>
<cf_box>
<div class="form-group">
    <label for="despatch_serials">Seri No</label>
    <input type="text" class="form-control" id="seri_no" name="seri_no" placeholder="Seri No" onkeydown="checkSerial(this,event)">
</div>
</cf_box>
<cf_box title="Despatch Row Details">

<table>
    <cfoutput query="getDespatchRow" group="PRODUCT_ID">
        <tr data-wrk_row_id="#WRK_ROW_ID#" data-product_id="#PRODUCT_ID#" data-stock_id="#STOCK_ID#" data-product_code_2="#PRODUCT_CODE_2#">
            
            <th colspan="3" style="text-align: left; background-color: ##f0f0f0; padding: 8px;">
               <a onclick="toggleSerials('#PRODUCT_ID#')">#encodeForHTML(PRODUCT_CODE_2)# - #EncodeForHTML(PRODUCT_NAME)#</a>
            </th>
            <td>#EncodeForHTML(AMOUNT)#</td>
            
            <td>#EncodeForHTML(OMIK)#</td>
            
        </tr>
        <cfif OMIK GT 0>
           <cfoutput> <tr id="serials_#PRODUCT_ID#">
                
                <td colspan="2" style="font-style: italic;">#EncodeForHTML(SERIAL_NO)#</td>
            </tr>
            </cfoutput>
        </cfif>
    </cfoutput>
</table>
<script>
    function toggleSerials(productId) {
        var row = document.getElementById('serials_' + productId);
        if (row.style.display === 'none' || row.style.display === '') {
            row.style.display = 'table-row';
        } else {
            row.style.display = 'none';
        }
    }
function checkSerial(input, event) {
   if(event.key === 'Enter') {
       var serialNo = input.value.trim();
       if(serialNo === '') {
           alert('Seri No boş olamaz.');
           return;
       }
       // Burada seri numarasını doğrulama ve ekleme işlemlerini yapabilirsiniz.
       // Örneğin, AJAX ile sunucuya gönderip kontrol edebilirsiniz.
       console.log('Girilen Seri No:', serialNo);
       input.value = ''; // Giriş alanını temizle
   }
}
</script>

</cf_box>