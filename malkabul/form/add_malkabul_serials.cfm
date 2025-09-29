<cfif isDefined("attributes.show_parser")>
    <cf_box title="Barkod Seç" scroll="1" collapsable="1" resize="1" popup_box="1">
<button class="btn btn-primary" onclick="setparser(1)">Dönmez</button>
<button class="btn btn-primary" onclick="setparser(2)">Diğerleri</button>
</cf_box>
<cfabort>
</cfif>

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

<cf_grid_list>
    <cfoutput query="getDespatchRow" group="PRODUCT_ID">
        <tr data-wrk_row_id="#WRK_ROW_ID#" data-product_id="#PRODUCT_ID#" data-stock_id="#STOCK_ID#" data-product_code_2="#PRODUCT_CODE_2#">
            
            <th colspan="3" style="text-align: left; background-color: ##f0f0f0; padding: 8px;">
               <a onclick="toggleSerials('#PRODUCT_ID#')">#encodeForHTML(PRODUCT_CODE_2)# - #EncodeForHTML(PRODUCT_NAME)#</a>
            </th>
            <td>#EncodeForHTML(AMOUNT)#</td>
            
            <td>#EncodeForHTML(OMIK)#</td>
            
        </tr>
        
            <tr>
                <td>
                    <table id="serials_#PRODUCT_ID#">              
                    <cfoutput> 
                        <tr>
                            
                            <td colspan="4" style="font-style: italic;">#EncodeForHTML(SERIAL_NO)#</td>
                        </tr>
                    </cfoutput>
                    </table>
              </td>
            </tr>
        
    </cfoutput>
</cf_grid_list>
<script>
var parser="";
$(document).ready(function(){
    openBoxDraggable('index.cfm?fuseaction=purchase._emptypopup_read_despatch_rows_pbs&show_parser=1');
});
function setparser(params) {
    parser=params;
    console.log(parser);
}
    function toggleSerials(productId) {
        var serialTable = document.getElementById('serials_' + productId);
        if (!serialTable) {
            console.warn('Seri listesi bulunamadı:', productId);
            return;
        }

        var containerRow = serialTable.closest('tr');
        var target = containerRow || serialTable;

        var isHidden = target.style.display === 'none' || window.getComputedStyle(target).display === 'none';

        if (isHidden) {
            target.style.display = '';
            target.setAttribute('aria-hidden', 'false');
        } else {
            target.style.display = 'none';
            target.setAttribute('aria-hidden', 'true');
        }
    }
function checkSerial(input, event) {
   if(event.key === 'Enter') {
       var serialNo = input.value.trim();
       if(serialNo === '') {
           alert('Seri No boş olamaz.');
           
           return;
       }
       if(parser === '') {
           alert('Barkod Türü Seçmediniz Lütfen Sayfayı Yenileyiniz.');
           return;
       }
       var product_code_2="";
       var serial_no;
       var uretim_tarihi="";
       var paketleme_tarihi="";
       if(parser==1){

       }if(parser==2){
        product_code_2=serialNo.split("_")[0] //Eta Kodu
        serial_no=serialNo.split("_")[1] //Seri No
        uretim_tarihi=serialNo.split("_")[2] //Üretim Tarihi
        paketleme_tarihi=serialNo.split("_")[3] //Paketleme Tarihi
        console.table({product_code_2,serial_no,uretim_tarihi,paketleme_tarihi});
        var row = document.querySelector(`tr[data-product_code_2="${product_code_2}"]`);
          console.log("Bulunan Satır:", row);
          if(row){
            console.log("Satır bulundu, seri numarası ekleniyor.");
            var wrk_row_id = row.getAttribute('data-wrk_row_id');
            var product_id = row.getAttribute('data-product_id');
            var stock_id = row.getAttribute('data-stock_id');
            var tr=document.createElement("tr");
            var td=document.createElement("td");
            td.innerText=serial_no;
            tr.appendChild(td);
            var serialsTable = document.getElementById('serials_' + product_id);
            var rws=serialsTable.getElementsByTagName("tr").length;
                for (let index = 0; index < rws; index++) {
                    const element = serialsTable.getElementsByTagName("tr")[index];
                    console.log("Seri No:", element.firstChild.innerText);
                }
            if(serialsTable){
                serialsTable.appendChild(tr);
            }

       }
   }

       
       // Burada seri numarasını doğrulama ve ekleme işlemlerini yapabilirsiniz.
       // Örneğin, AJAX ile sunucuya gönderip kontrol edebilirsiniz.
       console.log('Girilen Seri No:', serialNo);
       input.value = ''; // Giriş alanını temizle
   }
}

</script>

</cf_box>