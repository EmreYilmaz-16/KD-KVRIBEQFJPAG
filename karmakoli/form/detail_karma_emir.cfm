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
    --karma-bg: #0f172a;
    --karma-card: #111e36;
    --karma-card-alt: #162447;
    --karma-border: rgba(255,255,255,0.08);
    --karma-accent: #ffb347;
    --karma-accent-strong: #ff9e00;
    --karma-green: #65f7c0;
}

.karma-wrapper {
    font-family: 'Space Grotesk', 'Trebuchet MS', sans-serif;
    background: radial-gradient(circle at 15% 10%, rgba(255, 179, 71, 0.18), transparent 55%),
                radial-gradient(circle at 85% 0%, rgba(101, 247, 192, 0.18), transparent 50%),
                linear-gradient(135deg, #0b1220, #1a1f33);
    border-radius: 28px;
    padding: 32px;
    color: #f4f6fb;
    box-shadow: 0 25px 60px rgba(10, 15, 30, 0.55);
    position: relative;
    overflow: hidden;
    margin-top: 10px;
}

.karma-wrapper > * {
    position: relative;
    z-index: 2;
}

.karma-wrapper::after {
    content: "";
    position: absolute;
    inset: 12px;
    border-radius: 22px;
    border: 1px solid rgba(255,255,255,0.05);
    pointer-events: none;
    z-index: 1;
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
    border-radius: 20px;
    padding: 26px;
    border: 1px solid var(--karma-border);
    background: rgba(9, 12, 23, 0.5);
    backdrop-filter: blur(12px);
    box-shadow: 0 20px 45px rgba(4, 6, 12, 0.5);
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
    color: rgba(255,255,255,0.5);
    margin-bottom: 6px;
}

.karma-chip {
    background: rgba(255,255,255,0.08);
    border-radius: 999px;
    padding: 6px 16px;
    font-size: 13px;
    letter-spacing: 0.08em;
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
    color: rgba(255,255,255,0.6);
    padding-bottom: 12px;
    border-bottom: 1px solid rgba(255,255,255,0.1);
}

.karma-table td {
    padding: 18px 0;
    border-bottom: 1px solid rgba(255,255,255,0.05);
    vertical-align: middle;
    font-size: 15px;
}

.karma-table tr:last-child td {
    border-bottom: none;
}

.product-name {
    font-weight: 600;
    font-size: 16px;
}

.karma-row-id {
    font-size: 13px;
    font-weight: 600;
    color: rgba(255,255,255,0.6);
}

.karma-serial-chip {
    display: inline-flex;
    margin-top: 6px;
    padding: 4px 10px;
    font-size: 12px;
    border-radius: 999px;
    background: rgba(255,255,255,0.08);
    letter-spacing: 0.08em;
}

.karma-qty-badge {
    font-weight: 600;
    color: var(--karma-accent);
}

.karma-link {
    color: var(--karma-accent);
    text-decoration: none;
    font-weight: 600;
    letter-spacing: 0.08em;
}

.karma-link:hover {
    color: #ffe29a;
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
    color: rgba(255,255,255,0.6);
}

.karma-qty-input {
    width: 100%;
    border: none;
    background: rgba(7,11,20,0.7);
    color: var(--karma-accent-strong);
    font-size: 32px;
    font-weight: 600;
    text-align: center;
    padding: 14px 16px;
    border-radius: 14px;
    box-shadow: inset 0 0 0 1px rgba(255,255,255,0.08);
}

.karma-qty-input--muted {
    color: rgba(255,255,255,0.85);
}

.karma-qty-input.is-ready {
    color: var(--karma-green);
    box-shadow: inset 0 0 0 1px var(--karma-green);
}

.karma-action-card__btn {
    width: 100%;
    border: none;
    border-radius: 16px;
    padding: 16px 0;
    font-weight: 600;
    letter-spacing: 0.2em;
    text-transform: uppercase;
    background: linear-gradient(120deg, #ffbb55, #ff9d3f);
    color: #1c120b;
    cursor: pointer;
    box-shadow: 0 25px 35px rgba(255,153,0,0.35);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.karma-action-card__btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 30px 35px rgba(255,153,0,0.45);
}

.karma-hint {
    font-size: 13px;
    line-height: 1.6;
    color: rgba(255,255,255,0.75);
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