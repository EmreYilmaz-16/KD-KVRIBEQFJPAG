<cfsetting enablecfoutputonly="true">


<!--- Ürün ve alternatifleri çek --->
<cfquery name="getOfferProductsWithAlts" datasource="#DSN3#">
SELECT 
    ORR.WRK_ROW_ID,
    ORR.OFFER_ID,
    ORR.PRODUCT_ID AS MAIN_PRODUCT_ID,
    ORR.PRODUCT_NAME AS MAIN_PRODUCT_NAME,
    ORR.QUANTITY,

    S.PRODUCT_NAME AS STOCK_PRODUCT_NAME,
    S.PRODUCT_CODE,
    S.STOCK_ID,

    ISNULL(PC.PRODUCT_CAT, 'Kategori Yok') AS PRODUCT_CAT,
    ISNULL(PC.PRODUCT_CATID, 0) AS PRODUCT_CATID,

    ISNULL(PB.BRAND_NAME, 'Marka Yok') AS BRAND_NAME,
    ISNULL(PB.BRAND_ID, 0) AS BRAND_ID,

    ISNULL(PBM.MODEL_NAME, 'Model Yok') AS MODEL_NAME,
    ISNULL(PBM.MODEL_ID, 0) AS MODEL_ID,

    ALT.PRODUCT_ID AS ALT_PRODUCT_ID,
    ALT.PRODUCT_NAME AS ALT_PRODUCT_NAME,
    ISNULL(ALT_BRAND.BRAND_NAME, 'Marka Yok') AS ALT_BRAND_NAME,
    ISNULL(ALT_MODEL.MODEL_NAME, 'Model Yok') AS ALT_MODEL_NAME

FROM w3Qa_1.OFFER_ROW AS ORR
LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID = ORR.STOCK_ID
LEFT JOIN w3Qa_1.PRODUCT_CAT AS PC ON PC.PRODUCT_CATID = S.PRODUCT_CATID
LEFT JOIN w3Qa_1.PRODUCT_BRANDS AS PB ON PB.BRAND_ID = S.BRAND_ID
LEFT JOIN w3Qa_product.PRODUCT_BRANDS_MODEL AS PBM ON PBM.MODEL_ID = S.SHORT_CODE_ID

LEFT JOIN (
    SELECT PRODUCT_ID, ALTERNATIVE_PRODUCT_ID FROM w3Qa_1.ALTERNATIVE_PRODUCTS
    UNION
    SELECT ALTERNATIVE_PRODUCT_ID AS PRODUCT_ID, PRODUCT_ID AS ALTERNATIVE_PRODUCT_ID FROM w3Qa_1.ALTERNATIVE_PRODUCTS
) AS AP ON AP.PRODUCT_ID = ORR.PRODUCT_ID

LEFT JOIN w3Qa_1.STOCKS AS ALT ON ALT.PRODUCT_ID = AP.ALTERNATIVE_PRODUCT_ID
LEFT JOIN w3Qa_1.PRODUCT_BRANDS AS ALT_BRAND ON ALT_BRAND.BRAND_ID = ALT.BRAND_ID
LEFT JOIN w3Qa_product.PRODUCT_BRANDS_MODEL AS ALT_MODEL ON ALT_MODEL.MODEL_ID = ALT.SHORT_CODE_ID

WHERE ORR.OFFER_ID = 81
</cfquery>

<!--- Struct ve Array ile gruplama --->
<cfset groupedProducts = StructNew()>

<cfloop query="getOfferProductsWithAlts">
    <cfset mainId = MAIN_PRODUCT_ID>
    <cfif NOT StructKeyExists(groupedProducts, mainId)>
        <cfset groupedProducts[mainId] = {
            "productInfo": {
                "PRODUCT_ID": MAIN_PRODUCT_ID,
                "PRODUCT_NAME": MAIN_PRODUCT_NAME,
                "QUANTITY": QUANTITY,
                "BRAND_NAME": BRAND_NAME,
                "MODEL_NAME": MODEL_NAME,
                "WRK_ROW_ID": WRK_ROW_ID
            },
            "alternatives": []
        }>
    </cfif>

    <cfif Len(ALT_PRODUCT_ID)>
        <cfset ArrayAppend(groupedProducts[mainId].alternatives, {
            "ALT_PRODUCT_ID": ALT_PRODUCT_ID,
            "ALT_PRODUCT_NAME": ALT_PRODUCT_NAME,
            "ALT_BRAND_NAME": ALT_BRAND_NAME,
            "ALT_MODEL_NAME": ALT_MODEL_NAME
        })>
    </cfif>
</cfloop>
<head>
  <style>
      body { font-family: Arial; padding: 20px; background-color: #f5f5f5; }
      table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
      th, td { padding: 10px; border: 1px solid #ccc; }
      th { background-color: #007bff; color: white; }
      .alt { background-color: #e9f7ef; }
      .no-alt { color: #999; font-style: italic; }
      h3 { margin-top: 40px; color: #333; }
  </style>
</head>
<cfoutput>

<h2>Teklif Ürünleri ve Alternatifleri</h2>

<cfloop collection="#groupedProducts#" item="productId">
    <cfset item = groupedProducts[productId]>
    <cfset info = item.productInfo>
    
    <h3>#info.PRODUCT_NAME# (Adet: #info.QUANTITY#)</h3>
    
    <table>
        <tr>
            <th>Ürün ID</th>
            <th>Ürün Adı</th>
            <th>Marka</th>
            <th>Model</th>
        </tr>

        <tr>
            <td>#info.PRODUCT_ID#</td>
            <td>#info.PRODUCT_NAME#</td>
            <td>#info.BRAND_NAME#</td>
            <td>#info.MODEL_NAME#</td>
        </tr>

        <cfif ArrayLen(item.alternatives)>
            <cfloop array="#item.alternatives#" index="alt">
                <tr class="alt">
                    <td>#alt.ALT_PRODUCT_ID#</td>
                    <td>#alt.ALT_PRODUCT_NAME#</td>
                    <td>#alt.ALT_BRAND_NAME#</td>
                    <td>#alt.ALT_MODEL_NAME#</td>
                </tr>
            </cfloop>
        <cfelse>
            <tr>
                <td colspan="4" class="no-alt">Alternatif ürün bulunamadı.</td>
            </tr>
        </cfif>
    </table>

</cfloop>


</cfoutput>

<cfabort>
<cf_box title="Teklif Oluştur">


<cfdump var="#attributes#">

<cfquery name="qResults" datasource="#DSN3#">
SELECT 
    ORR.PRODUCT_NAME AS OFFER_PRODUCT_NAME,
    ORR.QUANTITY,
    ORR.WRK_ROW_ID,
    S.PRODUCT_NAME AS STOCK_PRODUCT_NAME,
    S.PRODUCT_CODE,
    S.PRODUCT_ID,
    S.STOCK_ID,
    PC.PRODUCT_CAT,
    PC.PRODUCT_CATID,
    ISNULL(PB.BRAND_NAME,'Marka Yok') AS BRAND_NAME,
    ISNULL(PB.BRAND_ID,0) AS BRAND_ID,
    ISNULL(PBM.MODEL_NAME,'Model Yok') AS MODEL_NAME,
    ISNULL(PBM.MODEL_ID,0) AS MODEL_ID

    
FROM 
    w3Qa_1.OFFER_ROW AS ORR
LEFT JOIN 
    w3Qa_1.STOCKS AS S ON S.STOCK_ID = ORR.STOCK_ID
LEFT JOIN 
    w3Qa_1.PRODUCT_CAT AS PC ON PC.PRODUCT_CATID = S.PRODUCT_CATID
LEFT JOIN 
    w3Qa_1.PRODUCT_BRANDS AS PB ON PB.BRAND_ID = S.BRAND_ID
LEFT JOIN 
    w3Qa_product.PRODUCT_BRANDS_MODEL AS PBM ON PBM.MODEL_ID = S.SHORT_CODE_ID
WHERE 
    ORR.OFFER_ID = 81;
</cfquery>
<cfquery name="GETOFFER" datasource="#DSN3#">
    SELECT * FROM OFFER WHERE OFFER_ID = #attributes.for_offer_id#
</cfquery>
<cfoutput>
    <input type="hidden" id="company_ids" value="#attributes.company_ids#">
    <input type="hidden" id="for_offer_id" value="#attributes.for_offer_id#">
    <input type="hidden" id="partner_ids" value="#attributes.partner_ids#">
    <input type="hidden" id="ref_no" value="#GETOFFER.REF_NO#">
</cfoutput>
<!-- Bootstrap Filtre Alanı -->
<div class="container my-4">
    <div style="display:flex" class="row g-3 align-items-end">
      <div class="form-group">
        <label for="filterCategory" class="form-label">Kategori</label>
        <select id="filterCategory" class="form-select">
          <option value="">Tümü</option>
          <cfoutput query="qResults" group="PRODUCT_CATID">
            <option value="#PRODUCT_CAT#">#PRODUCT_CAT#</option>
          </cfoutput>
        </select>
      </div>
  
      <div class="form-group">
        <label for="filterBrand" class="form-label">Marka</label>
        <select id="filterBrand" class="form-select">
          <option value="">Tümü</option>
          <cfoutput query="qResults" group="BRAND_ID">
            <option value="#BRAND_NAME#">#BRAND_NAME#</option>
          </cfoutput>
        </select>
      </div>
  
      <div class="form-group">
        <label for="filterModel" class="form-label">Model</label>
        <select id="filterModel" class="form-select">
          <option value="">Tümü</option>
          <cfoutput query="qResults" group="MODEL_ID">
            <option value="#MODEL_NAME#">#MODEL_NAME#</option>
          </cfoutput>
        </select>
      </div>
  
      <div class="form-group">
        <label for="filterKeyword" class="form-label">Anahtar Kelime</label>
        <input type="text" id="filterKeyword" class="form-control" placeholder="Ürün adı veya kodu...">
      </div>
    </div>
  

  </div>
  
  <!-- Bootstrap Tablo -->
  <div class="container mb-5">
    <cf_grid_list id="productTable" class="table table-bordered table-hover mt-3 align-middle">
      <thead class="table-dark">
        <tr>
          <th style="width:40px;"><input type="checkbox" id="selectAll"></th>
          <th>Ürün Adı</th>
          <th>Stok Adı</th>
          <th>Kategori</th>
          <th>Marka</th>
          <th>Model</th>
        </tr>
      </thead>
      <tbody>
        <cfoutput query="qResults">
          <tr>
            <td>
              <input type="checkbox" class="form-check-input rowCheckbox"
                data-productid="#PRODUCT_ID#"
                data-productname="#OFFER_PRODUCT_NAME#"
                data-stockid="#STOCK_ID#"
                data-brand="#BRAND_NAME#"
                data-model="#MODEL_NAME#"
                data-category="#PRODUCT_CAT#"
                data-productname2="#STOCK_PRODUCT_NAME#"
                data-quantity="#QUANTITY#"
                data-wrkRowId="#WRK_ROW_ID#">
            </td>
            <td data-name="#OFFER_PRODUCT_NAME# #PRODUCT_CODE# #STOCK_PRODUCT_NAME#">#STOCK_PRODUCT_NAME#</td>
            <td>#STOCK_PRODUCT_NAME#</td>
            <td data-category="#PRODUCT_CAT#">#PRODUCT_CAT#</td>
            <td data-brand="#BRAND_NAME#">#BRAND_NAME#</td>
            <td data-model="#MODEL_NAME#">#MODEL_NAME#</td>
          </tr>
        </cfoutput>
      </tbody>
    </cf_grid_list>
  </div>
  
  <button id="sendSelected" class="btn btn-primary">Seçilenleri Gönder</button>
  <script>
  var sessionData=<cfoutput>#replace(serializeJSON(session),"//","")#</cfoutput>;
    document.addEventListener("DOMContentLoaded", function () {
      const filterCategory = document.getElementById("filterCategory");
      const filterBrand = document.getElementById("filterBrand");
      const filterModel = document.getElementById("filterModel");
      const filterKeyword = document.getElementById("filterKeyword");
      const selectAll = document.getElementById("selectAll");
      const sendButton = document.getElementById("sendSelected");
    
      const filterTable = () => {
  const cat = filterCategory.value.toLowerCase();
  const brand = filterBrand.value.toLowerCase();
  const model = filterModel.value.toLowerCase();
  const keyword = filterKeyword.value.toLowerCase();

  const rows = document.querySelectorAll("#productTable tbody tr");

  rows.forEach(row => {
    const rowCat = (row.querySelector("td[data-category]")?.dataset.category || "").toLowerCase();
    const rowBrand = (row.querySelector("td[data-brand]")?.dataset.brand || "").toLowerCase();
    const rowModel = (row.querySelector("td[data-model]")?.dataset.model || "").toLowerCase();
    const rowNameCode = (row.querySelector("td[data-name]")?.dataset.name || "").toLowerCase();

    const matchCat = !cat || rowCat === cat;
    const matchBrand = !brand || rowBrand === brand;
    const matchModel = !model || rowModel === model;
    const matchKeyword = !keyword || rowNameCode.includes(keyword);

    row.style.display = (matchCat && matchBrand && matchModel && matchKeyword) ? "" : "none";
  });

  // SelectAll checkbox'ı görünürdeki her şey seçili değilse sıfırlanabilir, ama bu opsiyonel:
  selectAll.checked = false; // Sadece "görünen tümünü seç" davranışı için uygundur
};
    
      // Filtre olayları
      filterCategory.addEventListener("change", filterTable);
      filterBrand.addEventListener("change", filterTable);
      filterModel.addEventListener("change", filterTable);
      filterKeyword.addEventListener("keyup", filterTable);
    
      // Tümünü seç (sadece görünenler)
      selectAll.addEventListener("change", function () {
        const isChecked = this.checked;
        const rows = document.querySelectorAll("#productTable tbody tr");
    
        rows.forEach(row => {
          if (row.offsetParent !== null) { // sadece görünen satır
            const cb = row.querySelector(".rowCheckbox");
            if (cb) cb.checked = isChecked;
          }
        });
      });
    
      // Seçilenleri gönder
      sendButton.addEventListener("click", function () {
  const selected = [];

  // Seçili ürünleri topla
  document.querySelectorAll(".rowCheckbox:checked").forEach(cb => {
    selected.push({
      product_id: cb.dataset.productid,
      product_name: cb.dataset.productname,
      stock_id: cb.dataset.stockid,
      brand: cb.dataset.brand,
      model: cb.dataset.model,
      category: cb.dataset.category,
        product_name2: cb.dataset.productname2,
        quantity: cb.dataset.quantity,
        wrkRowId: cb.dataset.wrkrowid

    });
  });

  if (selected.length === 0) {
    alert("Lütfen en az bir ürün seçiniz.");
    return;
  }

  // Hidden input'lardan ek verileri al
  const companyIds = document.getElementById("company_ids")?.value || "";
  const forOfferId = document.getElementById("for_offer_id")?.value || "";
  const partnerIds = document.getElementById("partner_ids")?.value || "";
  const refNo = document.getElementById("ref_no")?.value || "";

  // Gönderilecek veri paketi
  const payload = {
    products: selected,
    company_ids: companyIds,
    for_offer_id: forOfferId,
    partner_ids: partnerIds,
    ref_no: refNo,
    session: sessionData
  };

  // AJAX Gönderimi
  fetch("/AddOns/Partner/purchase/cfc/purchase_service.cfc?method=savePurchaseOffer", {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify(payload)
  })
    .then(res => res.json())
    .then(data => {
      alert("Başarıyla gönderildi!");
      console.log(data);
    })
    .catch(error => {
      alert("Hata oluştu: " + error.message);
    });
});

    });
    </script>
</cf_box>