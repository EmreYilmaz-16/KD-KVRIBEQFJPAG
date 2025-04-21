
<cfsetting enablecfoutputonly="true">



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
    ALT_ORR.QUANTITY AS ALT_QUANTITY,
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

WHERE ORR.OFFER_ID = #attributes.for_offer_id#
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

<!--- Veri gruplama --->
<cfset grouped = StructNew()>
<cfset excludedProducts = []>

<cfloop query="getOfferProducts">
    <cfset pid = getOfferProducts.PRODUCT_ID>
    <cfset altId = getOfferProducts.ALT_PRODUCT_ID>

    <!-- Ana ürün grubu oluştur -->
    <cfif NOT StructKeyExists(grouped, pid)>
        <cfset grouped[pid] = {
            "main": {
                "PRODUCT_ID": pid,
                "PRODUCT_NAME": getOfferProducts.PRODUCT_NAME,
                "WRK_ROW_ID": getOfferProducts.WRK_ROW_ID,
                "QUANTITY": getOfferProducts.QUANTITY,
                "QUANTITY": getOfferProducts.QUANTITY,
                "PRODUCT_CAT": getOfferProducts.PRODUCT_CAT,
                "BRAND_NAME": getOfferProducts.BRAND_NAME,
                "MODEL_NAME": getOfferProducts.MODEL_NAME
            },
            "alts": []
        }>
    </cfif>

    <!-- Alternatif varsa -->
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
                "MODEL_NAME": getOfferProducts.ALT_MODEL_NAME,
                "QUANTITY": getOfferProducts.ALT_QUANTITY
                
            })>

            <!-- Alternatif olarak zaten gösterilecek, ana ürün olarak yazılmasın -->
            <cfif NOT ArrayContains(excludedProducts, altId)>
                <cfset ArrayAppend(excludedProducts, altId)>
            </cfif>
        </cfif>
    </cfif>
</cfloop>

<style>
  body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: linear-gradient(135deg, #1e1e2f, #2a2a40);
    color: #eee;
    padding: 30px;
  }

  h2 {
    text-align: center;
    margin-bottom: 30px;
    font-weight: 600;
    color: #fff;
    text-shadow: 0 0 10px #0ff;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    background-color: #2b2d42;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 0 20px rgba(0,255,255,0.2);
  }

  th, td {
    padding: 14px 10px;
    text-align: left;
    border-bottom: 1px solid #444;
  }

  th {
    background-color: #00adb5;
    color: #fff;
    text-transform: uppercase;
    font-size: 12px;
  }

  tr:hover {
    background-color: #3a3d5c;
    transition: 0.3s;
  }

  tr.main-row {
    background-color: #222831;
    font-weight: bold;
    cursor: pointer;
    border-left: 4px solid #00adb5;
  }

  tr.alt-row {
    background-color: #393e46;
    border-left: 4px solid #6fffe9;
  }

  tr.selected-row {
    background-color: #144d4d !important;
    box-shadow: 0 0 10px #0ff inset;
  }

  .badge {
    display: inline-block;
    padding: 3px 8px;
    border-radius: 6px;
    font-size: 11px;
    font-weight: bold;
    color: #fff;
  }

  .badge-blue { background-color: #3a86ff; }
  .badge-green { background-color: #06d6a0; }
  .badge-yellow { background-color: #ffbe0b; color: #333; }
  .badge-gray { background-color: #6c757d; }

  .alt-indicator {
    font-size: 11px;
    color: #00f0ff;
    background: #1a2a3a;
    padding: 3px 6px;
    margin-left: 8px;
    border-radius: 5px;
  }

  .collapse-icon {
    float: right;
    color: #ccc;
    margin-right: 10px;
    transition: transform 0.2s;
  }

  .hidden { display: none; }

  .no-alt td {
    text-align: center;
    font-style: italic;
    color: #aaa;
  }
</style>
<!--- HTML Çıktısı --->
<cfoutput>

    <meta charset="utf-8">
    
    <cf_box title="Teklif Ürünleri ve Alternatifleri" >


<h2>Teklifteki Ürünler ve Alternatifleri</h2>
<div class="filter-box">
  <input type="text" id="filter-name" onkeyup="filterTable()" placeholder="Ürün Adı Filtrele">
  <input type="text" id="filter-cat" onkeyup="filterTable()" placeholder="Kategori Filtrele">
  <input type="text" id="filter-brand" onkeyup="filterTable()" placeholder="Marka Filtrele">
  <input type="text" id="filter-model" onkeyup="filterTable()" placeholder="Model Filtrele">
  <script>
    var sessionData=<cfoutput>#replace(serializeJSON(session),"//","")#</cfoutput>;
    function toggleAlternatives(groupId, el) {
      document.querySelectorAll('.alt-of-' + groupId).forEach(row => {
        row.classList.toggle('hidden');
      });

      // Collapse simgesi değişsin
      const icon = el.querySelector('.collapse-icon');
      if (icon.innerText === '▼') {
        icon.innerText = '▲';
      } else {
        icon.innerText = '▼';
      }
    }

    function toggleAll(source) {
      const checkboxes = document.querySelectorAll('.product-check');
      checkboxes.forEach(cb => {
        cb.checked = source.checked;
        cb.closest('tr').classList.toggle('selected-row', cb.checked);
      });
    }

    function sendSelected() {
      const selected = [];
      document.querySelectorAll('.product-check:checked').forEach(cb => {
        selected.push(cb.value);
      });

      if (selected.length === 0) {
        alert("Seçim yapmadın dostum 😅");
        return;
      }

      const companyIds = document.getElementById("company_ids")?.value || "";
  const forOfferId = document.getElementById("for_offer_id")?.value || "";
  const partnerIds = document.getElementById("partner_ids")?.value || "";
  const refNo = document.getElementById("ref_no")?.value || "";

      fetch('/api/sendProducts.cfc?method=submitSelected', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ wrkRowIds: selected })
      })
      .then(res => res.json())
      .then(data => {
        alert("Gönderildi! 😎");
        console.log(data);
      })
      .catch(err => {
        alert("Hata! 🚨");
        console.error(err);
      });
    }
  </script>
</div>
<button onclick="sendSelected()" style="margin-bottom:20px;">✅ Seçilenleri Gönder</button>
<table class="table table-bordered table-hover mt-3 align-middle">
  <tr>
    <th><input type="checkbox" onclick="toggleAll(this)"></th>
    <th>Ürün ID</th>
    <th>Ürün Adı</th>
    <th>Kategori</th>
    <th>Marka</th>
    <th>Model</th>
    <th>WRK_ROW_ID</th>
  </tr>

  <cfloop collection="#grouped#" item="productId">
    <cfif NOT ArrayContains(excludedProducts, productId)>
      <cfset item = grouped[productId]>

      <!-- Ana Ürün -->
      <tr class="main-row" onclick="toggleAlternatives('#productId#', this)">
        <td><input type="checkbox" class="product-check" value="#item.main.WRK_ROW_ID#"></td>
        <td>#item.main.PRODUCT_ID#</td>
        <td>
          #item.main.PRODUCT_NAME#
          <cfif ArrayLen(item.alts)>
            <span class="alt-indicator">🔽 Alternatif (#ArrayLen(item.alts)#)</span>
          </cfif>
        </td>
        <td><span class="badge #getBadgeClass(item.main.PRODUCT_CAT)#">#item.main.PRODUCT_CAT#</span></td>
        <td><span class="badge #getBadgeClass(item.main.BRAND_NAME)#">#item.main.BRAND_NAME#</span></td>
        <td><span class="badge #getBadgeClass(item.main.MODEL_NAME)#">#item.main.MODEL_NAME#</span></td>
        <td>#item.main.WRK_ROW_ID# <span class="collapse-icon">▼</span></td>
      </tr>

      <!-- Alternatifler -->
      <cfif ArrayLen(item.alts)>
        <cfloop array="#item.alts#" index="alt">
          <tr class="alt-row alt-of-#productId# hidden">
            <td><input type="checkbox" class="product-check" value="#alt.WRK_ROW_ID#"></td>
            <td>#alt.PRODUCT_ID#</td>
            <td>↳ #alt.PRODUCT_NAME#</td>
            <td><span class="badge #getBadgeClass(alt.PRODUCT_CAT)#">#alt.PRODUCT_CAT#</span></td>
            <td><span class="badge #getBadgeClass(alt.BRAND_NAME)#">#alt.BRAND_NAME#</span></td>
            <td><span class="badge #getBadgeClass(alt.MODEL_NAME)#">#alt.MODEL_NAME#</span></td>
            <td>#alt.WRK_ROW_ID#</td>
          </tr>
        </cfloop>
      <cfelse>
        <tr class="no-alt alt-of-#productId# hidden">
          <td colspan="7">🛑 Alternatif ürün bulunamadı</td>
        </tr>
      </cfif>
    </cfif>
  </cfloop>
</table>
</cf_box>
<cffunction name="getBadgeClass" access="public" returntype="string">
  <cfargument name="label" type="string" required="true">

  <cfset label = Trim(LCase(arguments.label))>

  <cfif label EQ "marka yok" OR label EQ "model yok" OR label EQ "kategori yok">
      <cfreturn "badge-gray">
  <cfelseif label CONTAINS "yedek">
      <cfreturn "badge-green">
  <cfelseif label CONTAINS "bosch">
      <cfreturn "badge-blue">
  <cfelseif label CONTAINS "model">
      <cfreturn "badge-yellow">
  <cfelse>
      <cfreturn "badge-default">
  </cfif>
</cffunction>
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
