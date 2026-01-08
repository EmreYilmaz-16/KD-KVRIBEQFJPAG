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
@import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600&display=swap');

:root {
    --karma-bg: #f6f7fb;
    --karma-card: #ffffff;
    --karma-card-alt: #fdfdfd;
    --karma-border: #e2e5ee;
    --karma-accent: #3d5afe;
    --karma-accent-strong: #1a237e;
    --karma-green: #27ae60;
}

.karma-wrapper {
    font-family: 'Space Grotesk', 'Trebuchet MS', sans-serif;
    background: var(--karma-bg);
    border-radius: 20px;
    padding: 28px;
    color: #1f2533;
    border: 1px solid #e2e5ee;
    margin-top: 10px;
}

.karma-summary {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.summary-title {
    text-transform: uppercase;
    letter-spacing: 0.22em;
    font-size: 13px;
    color: rgba(255,255,255,0.7);
}

.summary-product {
    font-size: 32px;
    font-weight: 600;
    letter-spacing: -0.5px;
}

.summary-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
    font-size: 15px;
    color: rgba(255,255,255,0.75);
}

.summary-meta strong {
    color: #ffffff;
}

.karma-grid {
    margin-top: 28px;
    display: grid;
    grid-template-columns: minmax(0, 3fr) minmax(260px, 1fr);
    gap: 26px;
    align-items: stretch;
}

@media (max-width: 1024px) {
    .karma-grid {
        grid-template-columns: 1fr;
    }
}

.karma-table-card,
.karma-action-card {
    border-radius: 16px;
    padding: 24px;
    border: 1px solid var(--karma-border);
    background: var(--karma-card);
    box-shadow: 0 18px 30px rgba(20, 30, 70, 0.08);
}

.karma-table-card__header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
}

.eyebrow {
    text-transform: uppercase;
    letter-spacing: 0.3em;
    font-size: 11px;
    color: #8a93a6;
    margin-bottom: 6px;
}

.karma-chip {
    background: #eef0f7;
    border-radius: 999px;
    padding: 6px 16px;
    font-size: 13px;
    letter-spacing: 0.08em;
    color: #52617f;
}

.table-scroll {
    max-height: 460px;
    overflow: auto;
    margin-top: 24px;
    padding-right: 6px;
}

.karma-table {
    width: 100%;
    border-collapse: collapse;
}

.karma-table th {
    text-align: left;
    font-weight: 500;
    font-size: 12px;
    letter-spacing: 0.18em;
    color: #8a93a6;
    padding-bottom: 12px;
    border-bottom: 1px solid #eff1f6;
}

.karma-table td {
    padding: 18px 0;
    border-bottom: 1px solid #f3f4f8;
    vertical-align: middle;
    font-size: 15px;
}

.karma-table tr:last-child td {
    border-bottom: none;
}

.product-name {
    font-weight: 600;
    font-size: 16px;
    color: #1b2130;
}

.karma-row-id {
    font-size: 13px;
    font-weight: 600;
    color: #98a1b3;
}

.karma-serial-chip {
    display: inline-flex;
    margin-top: 6px;
    padding: 4px 10px;
    font-size: 12px;
    border-radius: 999px;
    background: #eef3ff;
    letter-spacing: 0.08em;
    color: #3d5afe;
}

.karma-qty-badge {
    font-weight: 600;
    color: var(--karma-accent-strong);
}

.karma-link {
    color: var(--karma-accent);
    text-decoration: none;
    font-weight: 600;
    letter-spacing: 0.08em;
}

.karma-link:hover {
    color: #0011ff;
}

.karma-action-card {
    background: var(--karma-card-alt);
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.karma-qty-display {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.karma-qty-label {
    text-transform: uppercase;
    font-size: 12px;
    letter-spacing: 0.25em;
    color: #9198ab;
}

.karma-qty-input {
    width: 100%;
    border: 1px solid #dee3ef;
    background: #f8f9fd;
    color: var(--karma-accent-strong);
    font-size: 32px;
    font-weight: 600;
    text-align: center;
    padding: 14px 16px;
    border-radius: 14px;
}

.karma-qty-input--muted {
    color: #5b6378;
}

.karma-qty-input.is-ready {
    color: var(--karma-green);
    border-color: rgba(39, 174, 96, 0.6);
    background: #f4fff7;
}

.karma-action-card__btn {
    width: 100%;
    border: none;
    border-radius: 14px;
    padding: 14px 0;
    font-weight: 600;
    letter-spacing: 0.18em;
    text-transform: uppercase;
    background: var(--karma-accent);
    color: #fff;
    cursor: pointer;
    transition: background 0.2s ease;
}

.karma-action-card__btn:hover {
    background: #304ffe;
}

.karma-hint {
    font-size: 13px;
    line-height: 1.6;
    color: #6b7286;
}

.fade-in {
    animation: fadeIn 0.45s ease forwards;
}

@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(8px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}
</style>

<div class="karma-wrapper fade-in">
    <cfoutput>
    <section class="karma-summary">
        <span class="summary-title">Karma Emir Detayı</span>
        <div class="summary-product">#getEmirDetail.PRODUCT_NAME#</div>
        <div class="summary-meta">
            <span>Emir No <strong>#getEmirDetail.KARMA_EMIR_ID#</strong></span>
            <span>Planlanan <strong>#NumberFormat(getEmirDetail.AMOUNT,"9999")#</strong> koli</span>
        </div>
    </section>
    </cfoutput>
    <div class="karma-grid">
        <section class="karma-table-card">
            <div class="karma-table-card__header">
                <div>
                    <p class="eyebrow">Ürün Listesi</p>
                    <h3>Karma İçerik</h3>
                </div>
                <span class="karma-chip"><cfoutput>#getKarmaProducts.recordCount# Parça</cfoutput></span>
            </div>
            <div class="table-scroll">
                <table class="karma-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Ürün</th>
                            <th>Set</th>
                            <th>Toplam</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="getKarmaProducts">
                        <tr>
                            <td><span class="karma-row-id">#currentRow#</span></td>
                            <td>
                                <div class="product-name">#PRODUCT_NAME#</div>
                                <cfif IS_SERIAL_NO EQ 1>
                                    <span class="karma-serial-chip">Seri Takibi</span>
                                </cfif>
                            </td>
                            <td><span class="karma-qty-badge">#QUANTITY# / koli</span></td>
                            <td><strong>#QUANTITY#X#getEmirDetail.AMOUNT#</strong></td>
                            <td><a class="karma-link" href="javascript:openselectProducts(#PRODUCT_ID#,#QUANTITY#,#IS_SERIAL_NO#)" title="Seç">Seç</a></td>
                        </tr>
                        </cfoutput>
                    </tbody>
                </table>
            </div>
        </section>
        <aside class="karma-action-card">
            <cfoutput>
            <div class="karma-qty-display">
                <span class="karma-qty-label">Planlanan Adet</span>
                <input type="text" class="karma-qty-input" name="KARMA_QUANTITY" id="KARMA_QUANTITY" readonly value="#getEmirDetail.AMOUNT#">
            </div>
            <div class="karma-qty-display">
                <span class="karma-qty-label">Hazır Adet</span>
                <input type="text" class="karma-qty-input karma-qty-input--muted" name="KARMA_QUANTITY1" id="KARMA_QUANTITY1" readonly value="0">
            </div>
            </cfoutput>
            <button type="button" id="UretBtn" class="karma-action-card__btn" onclick="Uret()" style="display:none;">Seçilen Ürünleri Ekle</button>
            <p class="karma-hint">Seçilen parçalar gereksinimleri karşıladığında hazır adet yeşile döner ve üretim butonu aktifleşir.</p>
        </aside>
    </div>
</div>

<script>
    const SelecttedArr = [];
    const karmaEmirQuantity = <cfoutput>#getEmirDetail.AMOUNT#</cfoutput>;
    const requiredProducts = [
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
        let completedKarmaCount = karmaEmirQuantity;
        let allRequirementsMet = true;
        
        for(let i = 0; i < requiredProducts.length; i++){
            const productId = requiredProducts[i].PRODUCT_ID;
            const requiredTotal = requiredProducts[i].REQUIRED_TOTAL;
            const quantityPerKarma = requiredProducts[i].QUANTITY;
            
            let selectedTotal = 0;
            for(let j = 0; j < SelecttedArr.length; j++){
                if(SelecttedArr[j].PRODUCT_ID == productId){
                    selectedTotal += SelecttedArr[j].QUANTITY;
                }
            }
            
            const possibleKarmaFromThisProduct = Math.floor(selectedTotal / quantityPerKarma);
            
            if(possibleKarmaFromThisProduct < completedKarmaCount){
                completedKarmaCount = possibleKarmaFromThisProduct;
            }
            
            if(selectedTotal != requiredTotal  ){
                allRequirementsMet = false;
            }
        }
        
        const karmaQuantity1 = document.getElementById('KARMA_QUANTITY1');
        const uretBtn = document.getElementById('UretBtn');
        
        if(allRequirementsMet && completedKarmaCount > 0){
            karmaQuantity1.value = completedKarmaCount;
            karmaQuantity1.classList.add('is-ready');
            uretBtn.style.display = 'block';
        } else {
            karmaQuantity1.value = 0;
            karmaQuantity1.classList.remove('is-ready');
            uretBtn.style.display = 'none';
        }
    }

    checkKarmaRequirements();
</script>