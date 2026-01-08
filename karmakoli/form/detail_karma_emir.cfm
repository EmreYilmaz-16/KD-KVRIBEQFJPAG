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

<style>
    .karma-emir-container {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 15px;
        padding: 25px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        margin: 20px 0;
    }
    
    .karma-table-wrapper {
        background: white;
        border-radius: 10px;
        padding: 20px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }
    
    .karma-products-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
        overflow: hidden;
    }
    
    .karma-products-table thead {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
    }
    
    .karma-products-table th {
        padding: 15px;
        text-align: left;
        font-weight: 600;
        text-transform: uppercase;
        font-size: 12px;
        letter-spacing: 1px;
    }
    
    .karma-products-table th:first-child {
        border-top-left-radius: 8px;
    }
    
    .karma-products-table th:last-child {
        border-top-right-radius: 8px;
    }
    
    .karma-products-table tbody tr {
        transition: all 0.3s ease;
        border-bottom: 1px solid #f0f0f0;
    }
    
    .karma-products-table tbody tr:hover {
        background: linear-gradient(to right, #f8f9ff, #fef6ff);
        transform: scale(1.01);
        box-shadow: 0 3px 10px rgba(102, 126, 234, 0.1);
    }
    
    .karma-products-table td {
        padding: 15px;
        color: #333;
    }
    
    .karma-products-table tbody tr:last-child {
        border-bottom: none;
    }
    
    .select-btn {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 8px 20px;
        border-radius: 25px;
        text-decoration: none;
        font-weight: 600;
        transition: all 0.3s ease;
        display: inline-block;
        box-shadow: 0 3px 10px rgba(102, 126, 234, 0.3);
    }
    
    .select-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 5px 20px rgba(102, 126, 234, 0.5);
        color: white;
        text-decoration: none;
    }
    
    .quantity-panel {
        background: white;
        border-radius: 15px;
        padding: 30px 20px;
        box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 20px;
    }
    
    .quantity-input {
        width: 100%;
        padding: 15px;
        font-size: 28pt;
        font-weight: bold;
        text-align: center;
        border: 3px solid #e0e0e0;
        border-radius: 10px;
        background: #f8f9fa;
        transition: all 0.3s ease;
    }
    
    .quantity-input:focus {
        outline: none;
        border-color: #667eea;
        background: white;
    }
    
    .quantity-label {
        font-size: 14px;
        font-weight: 600;
        color: #666;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: -10px;
    }
    
    .produce-btn {
        width: 100%;
        padding: 15px 20px;
        background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
        color: white;
        border: none;
        border-radius: 10px;
        font-size: 16px;
        font-weight: bold;
        cursor: pointer;
        transition: all 0.3s ease;
        box-shadow: 0 5px 15px rgba(17, 153, 142, 0.3);
        text-transform: uppercase;
        letter-spacing: 1px;
    }
    
    .produce-btn:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(17, 153, 142, 0.5);
    }
    
    .produce-btn:active {
        transform: translateY(-1px);
    }
</style>

<div class="karma-emir-container">
    <div class="row">
        <div class="col col-10">
            <div class="karma-table-wrapper">
                <table class="karma-products-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Ürün Adı</th>
                            <th>Miktar</th>
                            <th>İşlem</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput>
                        <cfloop query="getKarmaProducts">
                            <tr>
                                <td><strong>##currentRow##</strong></td>
                                <td>#PRODUCT_NAME#</td>
                                <td><strong>#QUANTITY# x #getEmirDetail.AMOUNT#</strong></td>
                                <td>
                                    <a href="javascript:openselectProducts(#PRODUCT_ID#,#QUANTITY#,#IS_SERIAL_NO#)" 
                                       class="select-btn" 
                                       title="Ürün Seç">
                                        <i class="fa fa-check"></i> Seç
                                    </a>
                                </td>
                            </tr>
                        </cfloop>
                        </cfoutput>
                    </tbody>
                </table>
            </div>
        </div>
        <div class="col col-2">
            <div class="quantity-panel">
                <cfoutput>
                <div style="width: 100%;">
                    <div class="quantity-label">Hedef Miktar</div>
                    <input type="text" 
                           name="KARMA_QUANTITY" 
                           id="KARMA_QUANTITY" 
                           readonly 
                           value="#getEmirDetail.AMOUNT#" 
                           class="quantity-input" 
                           style="color: ##667eea;">
                </div>
                <div style="width: 100%;">
                    <div class="quantity-label">Üretilen Miktar</div>
                    <input type="text" 
                           name="KARMA_QUANTITY1" 
                           id="KARMA_QUANTITY1" 
                           readonly 
                           value="0" 
                           class="quantity-input" 
                           style="color: ##e74c3c;">
                </div>
                </cfoutput>
                <button type="button" 
                        id="UretBtn" 
                        onclick="Uret()" 
                        class="produce-btn">
                    <i class="fa fa-cogs"></i> Ürünleri Ekle
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    var SelecttedArr = [];
    var karmaEmirQuantity = <cfoutput>#getEmirDetail.AMOUNT#</cfoutput>;
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
            karmaQuantity1.style.color = '#27ae60';
            karmaQuantity1.style.borderColor = '#27ae60';
            karmaQuantity1.style.background = '#e8f8f5';
            uretBtn.style.display = 'block';
        } else {
            karmaQuantity1.value = 0;
            karmaQuantity1.style.color = '#e74c3c';
            karmaQuantity1.style.borderColor = '#e0e0e0';
            karmaQuantity1.style.background = '#f8f9fa';
            uretBtn.style.display = 'none';
        }
    }
</script>