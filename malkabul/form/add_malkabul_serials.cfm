<cfif isDefined("attributes.show_parser")>
    <cf_box title="Barkod Seç" scroll="1" collapsable="1" resize="1" popup_box="1">
<button class="btn btn-primary" onclick="setparser(1,'<cfoutput>#attributes.modal_id#</cfoutput>')">Dönmez</button>
<button class="btn btn-primary" onclick="setparser(2,'<cfoutput>#attributes.modal_id#</cfoutput>')">Diğerleri</button>

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

<cf_grid_list id="despatch_rows_table">
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
function setparser(params,modal_id) {
    parser=params;
    console.log(parser);
    closeBoxDraggable(modal_id);
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
    function GetRows() {
        var SendingArray = [];
    var tablo = document.querySelector("#despatch_rows_table")
    for (let i = 0; i < tablo.rows.length; i++) {

        if (((i + 2) % 2) == 0) {
            var rw = tablo.rows[i];
        
        if (rw) {
            var wrk_row_id = rw.getAttribute("data-wrk_row_id");
            var product_id = rw.getAttribute("data-product_id");
            var stock_id = rw.getAttribute("data-stock_id");
            var product_code_2 = rw.getAttribute("data-product_code_2");    
            var serials = [];
            var serialTable = document.getElementById('serials_' + product_id);
            if (serialTable) {
                var rows = serialTable.getElementsByTagName('tr');
                for (var j = 0; j < rows.length; j++) {
                    var cells = rows[j].getElementsByTagName('td');
                    if (cells.length > 0) {
                        var serialNo = cells[0].innerText.trim();
                        if (serialNo) {
                            serials.push(serialNo);
                        }
                    }
                }
            }
            var O={
                wrk_row_id: wrk_row_id,
                product_id: product_id,
                stock_id: stock_id,
                product_code_2: product_code_2,
                serials: serials
            };  
            console.log(O);
            SendingArray.push(O);
        }
    }
    console.log(SendingArray);

    }
}

<cfinclude template="/AddOns/Partner/malkabul/js/malkabul_form.js">
</script>


</cf_box>