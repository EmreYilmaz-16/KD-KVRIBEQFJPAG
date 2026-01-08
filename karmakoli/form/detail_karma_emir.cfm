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
    .karma-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 15px;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }
    
    .karma-row {
        display: flex;
        gap: 15px;
        align-items: flex-start;
    }
    
    .karma-table-wrapper {
        flex: 1;
        background: #ffffff;
        border: 1px solid #e0e0e0;
        border-radius: 4px;
        overflow: hidden;
    }
    
    .karma-products-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
    }
    
    .karma-products-table thead {
        background: #f8f9fa;
        border-bottom: 2px solid #dee2e6;
    }
    
    .karma-products-table th {
        padding: 10px 12px;
        text-align: left;
        font-weight: 600;
        color: #2c3e50;
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .karma-products-table tbody tr {
        border-bottom: 1px solid #e9ecef;
        transition: background-color 0.15s ease;
    }
    
    .karma-products-table tbody tr:hover {
        background-color: #f8f9fa;
    }
    
    .karma-products-table td {
        padding: 10px 12px;
        color: #495057;
    }
    
    .karma-products-table td:first-child {
        font-weight: 600;
        color: #6c757d;
        width: 40px;
        text-align: center;
    }
    
    .karma-action-link {
        color: #0066cc;
        text-decoration: none;
        font-weight: 500;
        padding: 4px 10px;
        border-radius: 3px;
        display: inline-block;
        transition: all 0.2s ease;
    }
    
    .karma-action-link:hover {
        background-color: #e8f4ff;
        color: #004999;
    }
    
    .karma-sidebar {
        width: 220px;
        background: #ffffff;
        border: 1px solid #e0e0e0;
        border-radius: 4px;
        padding: 20px;
        display: flex;
        
        gap: 12px;
    }
    
    .karma-quantity-display {
        display: flex;
        flex-direction: column;
        gap: 10px;
    }
    
    .quantity-input {
        width: 100%;
        padding: 12px 10px;
        font-size: 24px;
        font-weight: 700;
        text-align: center;
        border: 2px solid #dee2e6;
        border-radius: 4px;
        background: #f8f9fa;
        outline: none;
        font-family: 'Segoe UI', monospace;
    }
    
    .quantity-input.target {
        color: #2c3e50;
        border-color: #adb5bd;
    }
    
    .quantity-input.current {
        color: #dc3545;
        border-color: #dc3545;
    }
    
    .quantity-input.current.completed {
        color: #28a745;
        border-color: #28a745;
    }
    
    .karma-submit-btn {
        width: 100%;
        padding: 12px 20px;
        background-color: #0066cc;
        color: white;
        border: none;
        border-radius: 4px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-top: 8px;
    }
    
    .karma-submit-btn:hover {
        background-color: #0052a3;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .karma-submit-btn:active {
        transform: translateY(1px);
    }
    
    .karma-submit-btn:disabled {
        background-color: #6c757d;
        cursor: not-allowed;
        opacity: 0.6;
    }
    
    .quantity-label {
        font-size: 11px;
        font-weight: 600;
        color: #6c757d;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 10px;
    }
</style>

<div class="karma-container">
    <div class="karma-row">
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
                            <td>#currentRow#</td>
                            <td>#PRODUCT_NAME#</td>
                            <td>#QUANTITY# x #getEmirDetail.AMOUNT#</td>
                            <td>
                                <a href="javascript:openselectProducts(#PRODUCT_ID#,#QUANTITY#,#IS_SERIAL_NO#)" 
                                   class="karma-action-link" 
                                   title="Seç">Seç</a>
                            </td>
                        </tr>
                    </cfloop>
                    </cfoutput>
                </tbody>
            </table>
        </div>
        <cfquery name="getParams" datasource="#dsn#">
            SELECT PACKAGING_STORE_LIST FROM PBS_PARAMETERS
        </cfquery>
        <cfquery name="getStores" datasource="#dsn#">
            SELECT * FROM (
SELECT CAST(D.DEPARTMENT_ID AS VARCHAR) +'-'+CAST(SL.LOCATION_ID AS VARCHAR) DEPO,D.DEPARTMENT_HEAD+'-'+SL.COMMENT AS DEPO_ADI  FROM w3Qa.STOCKS_LOCATION AS SL 
LEFT JOIN w3Qa.DEPARTMENT AS D ON D.DEPARTMENT_ID=SL.DEPARTMENT_ID 
  ) AS TTT WHERE DEPO IN (
    <cfset currentRow=1>
    <cfloop list="#getParams.PACKAGING_STORE_LIST#" index="storeId">
        <cfif currentRow GT 1>,</cfif>'#storeId#'
        <cfset currentRow=currentRow+1>
    </cfloop>

  )
        </cfquery>
        <cfdump var="#getStores#" label="Stores">
        
        
        <div class="karma-sidebar">
            <cfoutput>
                <div class="karma-quantity-display">
                    <div>
                        <div class="quantity-label">Hedef Miktar</div>
                        <input type="text" 
                               name="KARMA_QUANTITY" 
                               id="KARMA_QUANTITY" 
                               class="quantity-input target"
                               readonly 
                               value="#getEmirDetail.AMOUNT#">
                    </div>
                    <div>
                        <div class="quantity-label">Tamamlanan</div>
                        <input type="text" 
                               name="KARMA_QUANTITY1" 
                               id="KARMA_QUANTITY1" 
                               class="quantity-input current"
                               readonly 
                               value="0">
                    </div>
                </div>
            </cfoutput>
            <button type="button" 
                    id="UretBtn" 
                    class="karma-submit-btn" 
                    onclick="Uret()" 
                    style="display:none;">Seçilen Ürünleri Ekle</button>
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
            karmaQuantity1.classList.add('completed');
            uretBtn.style.display = 'block';
            uretBtn.disabled = false;
        } else {
            karmaQuantity1.value = 0;
            karmaQuantity1.classList.remove('completed');
            uretBtn.style.display = 'none';
            uretBtn.disabled = true;
        }
    }
</script>