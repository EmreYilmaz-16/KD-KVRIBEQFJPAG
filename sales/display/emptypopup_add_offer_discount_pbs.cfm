<cf_box title="Toplu İskonto Uygula">
<cfform>

<cfquery name="getofferrow" datasource="#dsn3#">
    SELECT ORR.WRK_ROW_ID,ORR.PRODUCT_ID,ORR.PRICE,ORR.PRICE_OTHER,ORR.QUANTITY,ORR.DISCOUNT_1,ORR.DISCOUNT_2,ORR.DISCOUNT_3,(SELECT TOP 1 BARCODE FROM w3Qa_product.STOCKS_BARCODES AS S WHERE S.STOCK_ID=PS.STOCK_ID) AS OEM_NUMARA,ORR.PRODUCT_NAME,PC.PRODUCT_CAT,ISNULL(PB.BRAND_NAME,'MARKA YOK') BRAND_NAME,ISNULL(PBM.MODEL_NAME,'MODEL YOK') MODEL_NAME,PBM.MODEL_ID FROM w3Qa_1.OFFER_ROW AS ORR
LEFT JOIN w3Qa_product.PRODUCT AS P ON P.PRODUCT_ID=ORR.PRODUCT_ID
LEFT JOIN w3Qa_product.STOCKS AS PS ON PS.STOCK_ID=ORR.STOCK_ID
LEFT JOIN w3Qa_product.PRODUCT_CAT AS PC ON PC.PRODUCT_CATID=P.PRODUCT_CATID
LEFT JOIN w3Qa_product.PRODUCT_BRANDS AS PB ON PB.BRAND_ID=P.BRAND_ID
LEFT JOIN w3Qa_product.PRODUCT_BRANDS_MODEL AS PBM ON PBM.MODEL_ID=P.SHORT_CODE_ID
WHERE ORR.OFFER_ID=#attributes.OFFER_ID#
</cfquery>
<cfoutput>
<cfquery name="GETPB" dbtype="query">
    SELECT DISTINCT BRAND_NAME FROM getofferrow
</cfquery>
<cfquery name="GETPC" dbtype="query">
    SELECT DISTINCT PRODUCT_CAT FROM getofferrow
</cfquery>
<cfquery name="GETPBM" dbtype="query">
    SELECT DISTINCT MODEL_NAME FROM getofferrow
</cfquery>

    <cf_ajax_list id="tablo1">
<thead>
<tr>
    <th>Ürün</th>
    <th>Miktar</th>
    <th>Fiyat</th>
    <th><select id="MarkaMain">
        <option value="">Marka</option>
    <cfloop query="GETPB">
        <option value="#BRAND_NAME#">#BRAND_NAME#</option>
    </cfloop>
    </select></th>
    <th><select id="ModelMain">
        <option value="">Model</option>
    <cfloop query="GETPBM">
        <option value="#MODEL_NAME#">#MODEL_NAME#</option>
    </cfloop>
    </select></th>
    <th><select id="KategoriMain">
        <option value="">Kategori</option>
    <cfloop query="GETPC">
        <option value="#PRODUCT_CAT#">#PRODUCT_CAT#</option>
    </cfloop>
    </select></th>
    <th><input type="text" name="iskonto_1" placeholder="İskonto 1" ></th>
    <th><input type="text" name="iskonto_2" placeholder="İskonto 2"></th>
    <th><input type="text" name="iskonto_3" placeholder="İskonto 3" ></th>
    <th><input type="text" name="marj" placeholder="Marj" ></th>
    <th>Marj Sonrası Fiyat</th>
</tr>
</thead>
<tbody>
    <cfloop query="getofferrow">
<tr data-row_id="#WRK_ROW_ID#">
    <td>
        #PRODUCT_NAME#
    </td>
    <td>
        #QUANTITY#
    </td>
    <td name="PriceArea" class="price">
        #PRICE#
    </td>
    <td name="BrandArea">#BRAND_NAME#</td>
    <td name="ModelArea">#MODEL_NAME#</td>
    <td>#PRODUCT_CAT#</td>
    <td>
        <input type="text" data-row_id="#WRK_ROW_ID#" class="discount1" name="discount1" value="#DISCOUNT_1#">
    </td>
    <td>
        <input type="text" data-row_id="#WRK_ROW_ID#" class="discount2" name="discount2" value="#DISCOUNT_2#">
    </td>
    <td>
        <input type="text" data-row_id="#WRK_ROW_ID#" class="discount3" name="discount3" value="#DISCOUNT_3#">
    </td>
    <td>
        <input type="text" data-row_id="#WRK_ROW_ID#" class="marj" onchange="satirHesaplaB(this)" name="marj" value="">
    </td>
    <td>
        <input type="text" data-row_id="#WRK_ROW_ID#" class="after_marj" name="after_marj" value="#PRICE#">
    </td>
</tr>
</cfloop>
</tbody>
</cf_ajax_list>
<button type="button" onclick="iskontoyaz()" class=" ui-wrk-btn ui-wrk-btn-success">İskontoları Ekle</button>
</cfoutput>




<script>// Function to filter table based on selected values
    function filterTable() {
        // Get selected values
        const selectedMarka = document.getElementById('MarkaMain').value;
        const selectedKategori = document.getElementById('KategoriMain').value;
        const selectedModel = document.getElementById('ModelMain').value;
        // Get all table rows that contain data (all rows from tbody)
        // Note: The first row in tbody contains the filter controls, so we need to skip it
        const rows = Array.from(document.querySelectorAll('#tablo1 tbody tr'));
        
        // Start from index 1 to skip the header/filter row
        for (let i = 0; i < rows.length; i++) {
            const row = rows[i];
            
            // Get the marka and kategori values from the row
            const markaCell = row.cells[3].textContent;
            const modelCell = row.cells[4].textContent;
            const kategoriCell = row.cells[5].textContent;
            
            // Determine if row should be visible based on filters
            const markaMatch = selectedMarka === '' || markaCell === selectedMarka;
            const kategoriMatch = selectedKategori === '' || kategoriCell === selectedKategori;
            const modelMatch = selectedModel === '' || modelCell === selectedModel;
            // Hide or show row based on filter match
            if (markaMatch && kategoriMatch && modelMatch) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        }
    }
    
    // Function to apply discount values to visible rows
    function applyDiscountToVisibleRows(discountNumber, value) {
        // Get all table rows
        const rows = Array.from(document.querySelectorAll('#tablo1 tbody tr'));
        if(!MarkaModelKontrol()){
            return false;
        }
        // Start from index 1 to skip the header/filter row
        for (let i = 0; i < rows.length; i++) {
            const row = rows[i];
            
            // Check if the row is visible
            if (row.style.display !== 'none') {
                const discountInput = row.querySelector(`.discount${discountNumber}`);
                if (discountInput) {
                    discountInput.value = value;
                }
            }
        }
    }
    function applyMarjToVisibleRows(discountNumber, value) {
        const rows = Array.from(document.querySelectorAll('#tablo1 tbody tr'));
        if(!MarkaModelKontrol()){
            return false;
        }
        // Start from index 1 to skip the header/filter row
        for (let i = 0; i < rows.length; i++) {
            const row = rows[i];
            
            // Check if the row is visible
            if (row.style.display !== 'none') {
                const discountInput = row.querySelector(`.marj`);
                const priceInput = row.querySelector(`.price`);
                const afterMarjInput = row.querySelector(`.after_marj`);
                if( priceInput) {
                    var price=priceInput.innerText.replace("TL","").replace(".","").replace(",",".")
                    var new_price=Number(price)*(1+Number(value)/100)
                    afterMarjInput.value=commaSplit(new_price)
                }
                if (discountInput) {
                    discountInput.value = value;
                }
            }
        }
        
    }
    $(".marj").on("change", function (e) {
    const value = this.value;
    const row = this.closest("tr"); // Daha temiz ve güvenli erişim

    const discountInput = row.querySelector(".marj");
    const priceInput = row.querySelector(".price");
    const afterMarjInput = row.querySelector(".after_marj");

    if (priceInput && afterMarjInput) {
        let priceRaw = priceInput.value || priceInput.innerText;
        let cleanedPrice = priceRaw.replace("TL", "").replace(/\./g, "").replace(",", ".");
        let price = parseFloat(cleanedPrice);

        let marj = parseFloat(value);
        if (!isNaN(price) && !isNaN(marj)) {
            let newPrice = price * (1 + marj / 100);
            afterMarjInput.value = commaSplit(newPrice);
        } else {
            console.warn("Geçersiz fiyat veya marj:", price, marj);
        }
    }

    if (discountInput) {
        discountInput.value = value;
    }
});
    
    // Add event listeners to select boxes and discount inputs
    document.addEventListener('DOMContentLoaded', function() {
        const markaSelect = document.getElementById('MarkaMain');
        const kategoriSelect = document.getElementById('KategoriMain');
        const modelSelect = document.getElementById('ModelMain');
        // Add change event listeners for filtering
        markaSelect.addEventListener('change', filterTable);
        kategoriSelect.addEventListener('change', filterTable);
        modelSelect.addEventListener('change', filterTable);
        
        // Add event listeners for discount inputs in header
        const discount1Input = document.querySelector('input[name="iskonto_1"]');
        const discount2Input = document.querySelector('input[name="iskonto_2"]');
        const discount3Input = document.querySelector('input[name="iskonto_3"]');
        const marjInput = document.querySelector('input[name="marj"]');
        
        
        discount1Input.addEventListener('input', function() {
            applyDiscountToVisibleRows(1, this.value);
        });
        
        discount2Input.addEventListener('input', function() {
            applyDiscountToVisibleRows(2, this.value);
        });
        
        discount3Input.addEventListener('input', function() {
            applyDiscountToVisibleRows(3, this.value);
        });
        
        marjInput.addEventListener('input', function() {
            applyMarjToVisibleRows(3, this.value);
        });
        // Initial filtering (in case a value is pre-selected)
        filterTable();
    });

    function MarkaModelKontrol() {
        var rows = Array.from(document.querySelectorAll('#tablo1 tbody tr'));
var BrandListArr=[];
var ModelListArr=[];
for (let i = 0; i < rows.length; i++) {
            const row = rows[i];
            if (row.style.display !== 'none') {
                var brnd=$(row).find("td[name='BrandArea']").text();
                var mdl=$(row).find("td[name='ModelArea']").text();
                var ix=BrandListArr.findIndex(p=>p==brnd);
                var iy=ModelListArr.findIndex(p=>p==mdl);
                
                if(ix==-1){
                    BrandListArr.push(brnd)
                }
                if(iy==-1){
                    ModelListArr.push(mdl)
                }
            }
    
     
 }
var alert_str="";
if(BrandListArr.length>1){
    alert_str+="Birden Fazla Marka var"
}
if(ModelListArr.length>1){
    alert_str+="\nBirden Fazla Model var"
}
if(alert_str.length>0){
alert(alert_str)
return false;
}
return true;
    }
</script>
</cfform>
</cf_box>

<script>
function iskontoyaz(){
    var rows=document.getElementById("tablo1").children[1].children
for(let i=0;i<rows.length;i++){
    var Row=rows[i]
    var WrkRowId=Row.getAttribute("data-row_id")
    console.log(WrkRowId)
    var ix=window.opener.basket.items.findIndex(p=>p.WRK_ROW_ID==WrkRowId)
    var d1=$(Row).find("input[name='discount1']").val()
    var d2=$(Row).find("input[name='discount2']").val()
    var d3=$(Row).find("input[name='discount3']").val()
    var d4=$(Row).find("input[name='after_marj']").val()
    //console.log(d1)
    window.opener.basket.items[ix].INDIRIM1=d1;
    window.opener.basket.items[ix].INDIRIM2=d2;
    window.opener.basket.items[ix].INDIRIM3=d3;
    
    window.opener.basket.items[ix].PRICE=filterNum(d4);
    
}

for (let index = 0; index < window.opener.basket.items.length; index++) {
    window.opener.hesapla("price",index)
    window.opener.hesapla("indirim1",index)
    window.opener.hesapla("indirim2",index)
    window.opener.hesapla("indirim3",index)
    
}    
}
</script>