<cfquery name="getEmirDetail" datasource="#dsn3#">
    SELECT KARMA_EMIR.*,STOCKS.PRODUCT_NAME FROM KARMA_EMIR 
    LEFT JOIN STOCKS ON KARMA_EMIR.PRODUCT_ID = STOCKS.PRODUCT_ID
    WHERE KARMA_EMIR_ID = <cfqueryparam value="#URL.EMIR_ID#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="getKarmaProducts" datasource="#dsn1#">
    SELECT KP.PRODUCT_ID,KP.QUANTITY,KP.MAIN_PRODUCT_ID,P.PRODUCT_NAME,P.IS_SERIAL_NO FROM KARMA_PRODUCTS_PBS AS KP
    LEFT JOIN PRODUCT AS P ON KP.PRODUCT_ID=P.PRODUCT_ID
      WHERE KP.MAIN_PRODUCT_ID=<cfqueryparam value="#getEmirDetail.PRODUCT_ID#" cfsqltype="cf_sql_integer">
</cfquery>

<div class="row">
    <div class="col col-10">
        <table>
            <tr>
                <th>#</th>
                <th>PRODUCT_NAME</th>
                <th>QUANTITY</th>
            </tr>
            <cfoutput>
            <cfloop query="getKarmaProducts">
                <tr>
                    <td>#currentRow#</td>
                    <td>#PRODUCT_NAME#</td>
                    <td>#QUANTITY#X#getEmirDetail.QUANTITY#</td>
                    <td><a href="javascript:openselectProducts(#PRODUCT_ID#,#QUANTITY#,#IS_SERIAL_NO#)" title="Seç">Seç </a></td>
                </tr>
            </cfloop>
            </cfoutput>
        </table>
    </div>
    <div class="col col-2">
<cfoutput>    
    <div style="dişplay:flex;flex-direction:column;align-items:center;">
     <input type="text" name="KARMA_QUANTITY" id="KARMA_QUANTITY" readonly value="#getEmirDetail.QUANTITY#" style="font-size:25pt;color:black">
     <input type="text" name="KARMA_QUANTITY1" id="KARMA_QUANTITY1" readonly value="0" style="font-size:25pt;color:red">
    </div>
    </cfoutput>   
        <button type="button" id="UretBtn" onclick="Uret()" style="margin-top:20px;width:100%;">Seçilen Ürünleri Ekle</button>
    </div>

<script>
    var SelecttedArr = [];
    var karmaEmirQuantity = <cfoutput>#getEmirDetail.QUANTITY#</cfoutput>;
    var requiredProducts = [
        <cfoutput query="getKarmaProducts">
            {PRODUCT_ID: #PRODUCT_ID#, QUANTITY: #QUANTITY#, REQUIRED_TOTAL: #QUANTITY# * karmaEmirQuantity}
            <cfif currentRow LT getKarmaProducts.recordCount>,</cfif>
        </cfoutput>
    ];
    
    function openselectProducts(PRODUCT_ID,QUANTITY,IS_SERIAL_NO){
       openBoxDraggable('index.cfm?fuseaction=product.popup_select_karma_serialno&PRODUCT_ID='+PRODUCT_ID+'&QUANTITY='+QUANTITY+'&IS_SERIAL_NO='+IS_SERIAL_NO,'Karma Ürün Seçimi',600,400);
    }
    
    function selectProducts(MAIN_PRODUCT_ID,PRODUCT_ID,QUANTITY){
        SelecttedArr.push({MAIN_PRODUCT_ID:MAIN_PRODUCT_ID,PRODUCT_ID:PRODUCT_ID,QUANTITY:QUANTITY});
        checkKarmaRequirements();
    }
    
    function checkKarmaRequirements(){
        var completedKarmaCount = karmaEmirQuantity;
        var allRequirementsMet = true;
        
        // Her ürün için toplam seçilen miktarı hesapla
        for(var i = 0; i < requiredProducts.length; i++){
            var productId = requiredProducts[i].PRODUCT_ID;
            var requiredTotal = requiredProducts[i].REQUIRED_TOTAL;
            var quantityPerKarma = requiredProducts[i].QUANTITY;
            
            // Bu ürün için seçilen toplam miktar
            var selectedTotal = 0;
            for(var j = 0; j < SelecttedArr.length; j++){
                if(SelecttedArr[j].PRODUCT_ID == productId){
                    selectedTotal += SelecttedArr[j].QUANTITY;
                }
            }
            
            // Bu üründen kaç karma koli yapılabilir
            var possibleKarmaFromThisProduct = Math.floor(selectedTotal / quantityPerKarma);
            
            // En az olanı bul
            if(possibleKarmaFromThisProduct < completedKarmaCount){
                completedKarmaCount = possibleKarmaFromThisProduct;
            }
            
            // Gerekli miktar karşılanmadıysa
            if(selectedTotal != requiredTotal  ){
                allRequirementsMet = false;
            }
        }
        
        var karmaQuantity1 = document.getElementById('KARMA_QUANTITY1');
        var uretBtn = document.getElementById('UretBtn');
        
        if(allRequirementsMet && completedKarmaCount > 0){
            karmaQuantity1.value = completedKarmaCount;
            karmaQuantity1.style.color = 'green';
            uretBtn.style.display = 'block';
        } else {
            karmaQuantity1.value = 0;
            karmaQuantity1.style.color = 'red';
            uretBtn.style.display = 'none';
        }
    }
</script>