<cf_box title="Karma Seri No Seçimi" modal_id="#attributes.modal_id#" width="600" height="400">
     
    
    <cfif attributes.IS_SERIAL_NO eq 1>
        <cfoutput><input type="text" name="serial_no" id="serial_no" onkeyup="searchandSelectProduct(event,this.value,'#attributes.PRODUCT_ID#','#attributes.modal_id#')" placeholder="Seri No ile Ara" class="form-control mb-2"> </cfoutput>
        <select name="BarcodeParser" id="BarcodeParser">
				<option value="0">Barkod Tipi</option>

			</select>
        <cfquery name="getSerials" datasource="#dsn3#">
            SELECT TT.*,P.PRODUCT_NAME,P.PRODUCT_CODE_2,P.PRODUCT_CODE FROM (
SELECT STOCK_ID,SUM(CASE WHEN IN_OUT =1 THEN 1 ELSE -1 END) AS BKY,DEPARTMENT_ID,LOCATION_ID,SERIAL_NO  
FROM SERVICE_GUARANTY_NEW WHERE STOCK_ID=(SELECT STOCK_ID FROM STOCKS WHERE PRODUCT_ID=#attributes.PRODUCT_ID#)
GROUP BY STOCK_ID,DEPARTMENT_ID,LOCATION_ID,SERIAL_NO
HAVING DEPARTMENT_ID=#listFirst(attributes.PACKAGING_STORE,"-")# AND LOCATION_ID=#listLast(attributes.PACKAGING_STORE,"-")# 
) AS TT LEFT JOIN #DSN1#.STOCKS AS S ON S.STOCK_ID=TT.STOCK_ID 
LEFT JOIN #DSN1#.PRODUCT AS P ON P.PRODUCT_ID=S.PRODUCT_ID
WHERE TT.BKY>0
        </cfquery>
        <script>
            var UrunBilgi={
                urun_adi:'<cfoutput>#getSerials.PRODUCT_NAME#</cfoutput>',
                urun_kodu:'<cfoutput>#getSerials.PRODUCT_CODE#</cfoutput>',
                urun_eta_kodu:'<cfoutput>#getSerials.PRODUCT_CODE_2#</cfoutput>'

            }
        </script>
<cf_grid_list>
    <thead>
        <tr>            
            <th>Seri No</th>
            <th>Eta Kodu</th>
            <th>Ürün Kodu</th>
            <th>Ürün</th>
        </tr>
    </thead>
    <tbody id="serialTable"><!------(MAIN_PRODUCT_ID,PRODUCT_ID,QUANTITY,SERIAL_NO)------>
        <cfoutput query="getSerials">
            <tr >
                <td><a onclick="selectProducts('#attributes.MAIN_PRODUCT_ID#','#attributes.PRODUCT_ID#','#attributes.QUANTITY#','#SERIAL_NO#',this,'#attributes.modal_id#')">#SERIAL_NO#</a></td>
                <td>#PRODUCT_CODE_2#</td>
                <td>#PRODUCT_CODE#</td>
                <td>#PRODUCT_NAME#</td>
            </tr>
        </cfoutput>
    </tbody>

</cf_grid_list>    
<cfelse>
    <cfquery name="GETsTOCKS" datasource="#DSN2#">
        SELECT SUM(STOCK_IN-STOCK_OUT) AS BKY ,SR.STORE,SR.STORE_LOCATION,P.PRODUCT_NAME,P.PRODUCT_CODE_2,P.PRODUCT_CODE FROM STOCKS_ROW SR 
LEFT JOIN #DSN1#.STOCKS AS S ON S.STOCK_ID=SR.STOCK_ID
LEFT JOIN #DSN1#.PRODUCT AS P ON P.PRODUCT_ID=S.PRODUCT_ID
WHERE P.PRODUCT_ID=#attributes.PRODUCT_ID#
GROUP BY SR.STORE,SR.STORE_LOCATION,P.PRODUCT_NAME,P.PRODUCT_CODE_2,P.PRODUCT_CODE
HAVING STORE=#listFirst(attributes.PACKAGING_STORE,"-")# AND STORE_LOCATION=#listLast(attributes.PACKAGING_STORE,"-")#
    </cfquery>
<cf_grid_list>
    <thead>
        <tr>
            <th>Eta Kodu</th>
            <th>Ürün Kodu</th>
            <th>Ürün</th>
            <th>Stok Miktarı</th>
            <th>Eklenebilir</th>
        </tr>
    </thead>
    <tbody><!------(MAIN_PRODUCT_ID,PRODUCT_ID,QUANTITY,SERIAL_NO)------>
        <cfoutput query="GETsTOCKS">
            
            <tr >
                     <td>#PRODUCT_CODE_2#</td>
                <td>#PRODUCT_CODE#</td>
                <td>#PRODUCT_NAME#</td>
                <td>#BKY#</td>
                <td>
                    <cfif BKY gt attributes.REQUIRED_TOTAL>
                        <a onclick="selectProducts('#attributes.MAIN_PRODUCT_ID#','#attributes.PRODUCT_ID#','#attributes.REQUIRED_TOTAL#','',this,'#attributes.modal_id#')">#attributes.REQUIRED_TOTAL#</a>
                    <cfelseif BKY lte attributes.REQUIRED_TOTAL and BKY gt 0>
                        <a onclick="selectProducts('#attributes.MAIN_PRODUCT_ID#','#attributes.PRODUCT_ID#','#BKY#','',this,'#attributes.modal_id#')">#BKY#</a>
                    <cfelse>
                        0
                    </cfif>

                </td>
            </tr>
        </cfoutput>
    </tbody>
</cf_grid_list>

</cfif>
<cf_box title="Seçilen Ürünler">
<cf_grid_list >
    <thead>
        <tr>
            <th>Seri No</th>
            <th>Eta Kodu</th>
            <th>Ürün Kodu</th>
            <th>Ürün</th>
            <th>Miktar</th>
            <th></th>
        </tr>
    </thead>
    <tbody id="tb1"></tbody>
</cf_grid_list>
</cf_box>


<script>
    $(document).ready(function(){
                 bm=new BarcodeManager();
var parsers=bm.listParsers();
for(var i=0;i<parsers.length;i++){
	$("#BarcodeParser").append('<option value="'+parsers[i].id+'">'+parsers[i].name+'</option>');
}
        if(SELECTED_PRODCT_ARRAY.length > 0){
            var SelecttedArr=SELECTED_PRODCT_ARRAY;
        }else{
            
        }
if (typeof SelectedArr === "undefined" || SelectedArr.length === 0) {
    return;
}

        var selectedProducts=SelecttedArr.filter(p=>p.PRODUCT_ID=='<cfoutput>#attributes.PRODUCT_ID#</cfoutput>');
        var tb1=document.getElementById('tb1');

        selectedProducts.forEach(function(item){
            var tr=document.createElement('tr');
            var tdseri=document.createElement('td');
            tdseri.innerText=item.SERIAL_NO;
            var tdeta=document.createElement('td');
            tdeta.innerText=UrunBilgi.urun_eta_kodu;
            var tdkod=document.createElement('td');
            tdkod.innerText=UrunBilgi.urun_kodu;
            var tdquantity=document.createElement('td');
            tdquantity.innerText=item.QUANTITY;
            var tdname=document.createElement('td');
            tdname.innerText=UrunBilgi.urun_adi;
            var tdaction=document.createElement('td');
            var a=document.createElement('a');
            a.href="javascript:void(0)";
            a.innerText="Kaldır";
            a.onclick=function(){
                removeSelectedProduct(item.PRODUCT_ID,item.SERIAL_NO,'#attributes.modal_id#');
            };
            tdaction.appendChild(a);
            tr.appendChild(tdseri);
            tr.appendChild(tdeta);
            tr.appendChild(tdkod);
            tr.appendChild(tdname);
            tr.appendChild(tdquantity);
            tr.appendChild(tdaction);
            tb1.appendChild(tr);
        });

    });
    function generateRows(slp) {
        slp.forEach(function(item){
            var tr=document.createElement('tr');
            var tdseri=document.createElement('td');
            tdseri.innerText=item.SERIAL_NO;
            var tdeta=document.createElement('td');
            tdeta.innerText=UrunBilgi.urun_eta_kodu;
            var tdkod=document.createElement('td');
            tdkod.innerText=UrunBilgi.urun_kodu;
            var tdquantity=document.createElement('td');
            tdquantity.innerText=item.QUANTITY;
            var tdname=document.createElement('td');
            tdname.innerText=UrunBilgi.urun_adi;
            var tdaction=document.createElement('td');
            var a=document.createElement('a');
            a.href="javascript:void(0)";
            a.innerText="Kaldır";
            a.onclick=function(){
                removeSelectedProduct(item.PRODUCT_ID,item.SERIAL_NO,'#attributes.modal_id#');
            };
            tdaction.appendChild(a);
            tr.appendChild(tdseri);
            tr.appendChild(tdeta);
            tr.appendChild(tdkod);
            tr.appendChild(tdname);
            tr.appendChild(tdquantity);
            tr.appendChild(tdaction);
            tb1.appendChild(tr);
        });
    }
    function searchandSelectProduct(event, value, productId, modalId) {
        
        var SerialObject = bm.parseWith(value, parseInt(document.getElementById('BarcodeParser').value));
        var sn="";
        if(SerialObject && SerialObject.serial_no){
				sn = SerialObject.serial_no;
			}
        console.log(SerialObject);
        
        var rows = document.querySelectorAll("#serialTable tr");
        var visibleRows = [];
        rows.forEach(function(row) {
            var serialNo = row.cells[0].innerText.toLowerCase();
            if (serialNo.includes(sn.toLowerCase())) {
                row.style.display = "";
                visibleRows.push(row);
            } else {
                row.style.display = "none";
            }
        });
        
        // Eğer Enter tuşuna basıldıysa ve tek bir sonuç bulunursa, otomatik olarak seç
        if ((event.keyCode === 13 || event.key === 'Enter') && visibleRows.length === 1 && value.length > 0) {
            var link = visibleRows[0].querySelector('a');
            if (link) {
                link.click();
            }
        }
        
    }
</script>





    <button class="btn btn-danger" onclick="closeBoxDraggable(<cfoutput>#attributes.modal_id#</cfoutput>)">Kapat</button>
</cf_box>