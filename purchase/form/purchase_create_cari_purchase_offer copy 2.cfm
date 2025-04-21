<cfsetting enablecfoutputonly="true">


<!--- SQL: Teklif ve alternatifleriyle birlikte detay bilgileri al --->
<cfquery name="getOfferProducts" datasource="#DSN3#">
SELECT 
    ORR.PRODUCT_ID,
    ORR.PRODUCT_NAME,
    ORR.WRK_ROW_ID,
    ORR.QUANTITY,
    ORR.OFFER_ID,
    ISNULL(PC.PRODUCT_CAT, 'Kategori Yok') AS PRODUCT_CAT,
    ISNULL(PC.PRODUCT_CATID, 0) AS PRODUCT_CATID,
    ISNULL(PB.BRAND_NAME, 'Marka Yok') AS BRAND_NAME,
    ISNULL(PB.BRAND_ID, 0) AS BRAND_ID,
    ISNULL(PBM.MODEL_NAME, 'Model Yok') AS MODEL_NAME,
    ISNULL(PBM.MODEL_ID, 0) AS MODEL_ID,

    ALT_ORR.PRODUCT_ID AS ALT_PRODUCT_ID,
    ALT_ORR.PRODUCT_NAME AS ALT_PRODUCT_NAME,
    ALT_ORR.WRK_ROW_ID AS ALT_WRK_ROW_ID,
    ISNULL(ALT_PC.PRODUCT_CAT, 'Kategori Yok') AS ALT_PRODUCT_CAT,
    ISNULL(ALT_PC.PRODUCT_CATID, 0) AS ALT_PRODUCT_CATID,
    ISNULL(ALT_PB.BRAND_NAME, 'Marka Yok') AS ALT_BRAND_NAME,
    ISNULL(ALT_PB.BRAND_ID, 0) AS ALT_BRAND_ID,
    ISNULL(ALT_PBM.MODEL_NAME, 'Model Yok') AS ALT_MODEL_NAME,
    ISNULL(ALT_PBM.MODEL_ID, 0) AS ALT_MODEL_ID

FROM w3Qa_1.OFFER_ROW ORR
LEFT JOIN w3Qa_1.STOCKS S ON S.STOCK_ID = ORR.STOCK_ID
LEFT JOIN w3Qa_1.PRODUCT_CAT PC ON PC.PRODUCT_CATID = S.PRODUCT_CATID
LEFT JOIN w3Qa_1.PRODUCT_BRANDS PB ON PB.BRAND_ID = S.BRAND_ID
LEFT JOIN w3Qa_product.PRODUCT_BRANDS_MODEL PBM ON PBM.MODEL_ID = S.SHORT_CODE_ID

LEFT JOIN (
    SELECT PRODUCT_ID, ALTERNATIVE_PRODUCT_ID FROM w3Qa_1.ALTERNATIVE_PRODUCTS    
) AS AP ON AP.PRODUCT_ID = ORR.PRODUCT_ID

LEFT JOIN w3Qa_1.OFFER_ROW ALT_ORR ON ALT_ORR.PRODUCT_ID = AP.ALTERNATIVE_PRODUCT_ID
    AND ALT_ORR.OFFER_ID = ORR.OFFER_ID
LEFT JOIN w3Qa_1.STOCKS ALT_S ON ALT_S.STOCK_ID = ALT_ORR.STOCK_ID
LEFT JOIN w3Qa_1.PRODUCT_CAT ALT_PC ON ALT_PC.PRODUCT_CATID = ALT_S.PRODUCT_CATID
LEFT JOIN w3Qa_1.PRODUCT_BRANDS ALT_PB ON ALT_PB.BRAND_ID = ALT_S.BRAND_ID
LEFT JOIN w3Qa_product.PRODUCT_BRANDS_MODEL ALT_PBM ON ALT_PBM.MODEL_ID = ALT_S.SHORT_CODE_ID

WHERE ORR.OFFER_ID = 81
</cfquery>

<!--- Veri gruplama --->
<cfset grouped = StructNew()>
<cfset excludedProducts = []>

<cfloop query="getOfferProducts">
    <cfset pid = getOfferProducts.PRODUCT_ID>
    <cfset altId = getOfferProducts.ALT_PRODUCT_ID>

    <cfif NOT StructKeyExists(grouped, pid)>
        <cfset grouped[pid] = {
            "main": {
                "PRODUCT_ID": pid,
                "PRODUCT_NAME": getOfferProducts.PRODUCT_NAME,
                "WRK_ROW_ID": getOfferProducts.WRK_ROW_ID,
                "QUANTITY": getOfferProducts.QUANTITY,
                "PRODUCT_CAT": getOfferProducts.PRODUCT_CAT,
                "BRAND_NAME": getOfferProducts.BRAND_NAME,
                "MODEL_NAME": getOfferProducts.MODEL_NAME
            },
            "alts": []
        }>
    </cfif>

    <cfif Len(altId) AND altId NEQ pid>
        <cfset exists = false>
        <cfloop array="#grouped[pid].alts#" index="existingAlt">
            <cfif existingAlt.PRODUCT_ID EQ altId>
                <cfset exists = true>
                <cfbreak>
            </cfif>
        </cfloop>

        <cfif NOT exists>
            <cfset ArrayAppend(grouped[pid].alts, {
                "PRODUCT_ID": altId,
                "PRODUCT_NAME": getOfferProducts.ALT_PRODUCT_NAME,
                "WRK_ROW_ID": getOfferProducts.ALT_WRK_ROW_ID,
                "PRODUCT_CAT": getOfferProducts.ALT_PRODUCT_CAT,
                "BRAND_NAME": getOfferProducts.ALT_BRAND_NAME,
                "MODEL_NAME": getOfferProducts.ALT_MODEL_NAME
            })>

            <cfif NOT ArrayContains(excludedProducts, altId)>
                <cfset ArrayAppend(excludedProducts, altId)>
            </cfif>
        </cfif>
    </cfif>
</cfloop>

<!--- Bootstrap CSS + JS --->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>


<cfoutput>
  <div class="container py-4">
    <h2 class="text-center text-info mb-4">💼 Teklif Ürünleri (Kart Görünüm)</h2>
    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
      <cfloop collection="#grouped#" item="productId">
        <cfif NOT ArrayContains(excludedProducts, productId)>
          <cfset item = grouped[productId]>
          <div class="col">
            <div class="card shadow h-100 border-info">
              <div class="card-header bg-info text-white d-flex justify-content-between align-items-center">
                <div>
                  <strong>#item.main.PRODUCT_NAME#</strong><br>
                  <small class="text-light">ID: #item.main.PRODUCT_ID#</small>
                </div>
                <input type="checkbox" class="form-check-input product-check" value="#item.main.WRK_ROW_ID#">
              </div>
              <div class="card-body">
                <p><strong>Kategori:</strong> <span class="badge bg-secondary">#item.main.PRODUCT_CAT#</span></p>
                <p><strong>Marka:</strong> <span class="badge bg-primary">#item.main.BRAND_NAME#</span></p>
                <p><strong>Model:</strong> <span class="badge bg-warning text-dark">#item.main.MODEL_NAME#</span></p>
                <p><strong>WRK_ROW_ID:</strong> <code>#item.main.WRK_ROW_ID#</code></p>
              </div>
              <cfif ArrayLen(item.alts)>
                <div class="card-footer">
                  <button class="btn btn-outline-info btn-sm w-100" data-bs-toggle="collapse" data-bs-target="##alt-#productId#">
                    🔽 Alternatifleri Göster (#ArrayLen(item.alts)#)
                  </button>
                  <div class="collapse mt-3" id="alt-#productId#">
                    <cfloop array="#item.alts#" index="alt">
                      <div class="border rounded p-2 mb-2 bg-light">
                        <div class="d-flex justify-content-between">
                          <div>
                            <strong>↳ #alt.PRODUCT_NAME#</strong><br>
                            <small>ID: #alt.PRODUCT_ID#</small>
                          </div>
                          <input type="checkbox" class="form-check-input product-check" value="#alt.WRK_ROW_ID#">
                        </div>
                        <div class="mt-1">
                          <span class="badge bg-secondary">#alt.PRODUCT_CAT#</span>
                          <span class="badge bg-primary">#alt.BRAND_NAME#</span>
                          <span class="badge bg-warning text-dark">#alt.MODEL_NAME#</span>
                          <div><small>WRK_ROW_ID: <code>#alt.WRK_ROW_ID#</code></small></div>
                        </div>
                      </div>
                    </cfloop>
                  </div>
                </div>
              <cfelse>
                <div class="card-footer text-muted text-center">
                  🚫 Alternatif ürün bulunamadı
                </div>
              </cfif>
            </div>
          </div>
        </cfif>
      </cfloop>
    </div>
    <div class="text-center mt-4">
      <button onclick="sendSelected()" class="btn btn-success">✅ Seçilenleri Gönder</button>
    </div>
  </div>
  </cfoutput>
  
  <script>
  function sendSelected() {
    const selected = [];
    document.querySelectorAll('.product-check:checked').forEach(cb => {
      selected.push(cb.value);
    });
  
    if (selected.length === 0) {
      alert("Hiçbir ürün seçilmedi!");
      return;
    }
  
    fetch('/api/sendProducts.cfc?method=submitSelected', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ wrkRowIds: selected })
    })
    .then(res => res.json())
    .then(data => {
      alert("Seçilen ürünler başarıyla gönderildi!");
      console.log(data);
    })
    .catch(err => {
      alert("Hata oluştu!");
      console.error(err);
    });
  }
  </script>
  