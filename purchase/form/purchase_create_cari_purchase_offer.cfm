<cf_box title="Teklif Oluştur">
Burası Orası

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
                data-productname2="#STOCK_PRODUCT_NAME#">
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
    // Filtreleme fonksiyonu
    function filterTable() {
      const cat = $("#filterCategory").val().toLowerCase();
      const brand = $("#filterBrand").val().toLowerCase();
      const model = $("#filterModel").val().toLowerCase();
      const keyword = $("#filterKeyword").val().toLowerCase();
  
      $("#productTable tbody tr").each(function () {
        const $row = $(this);
        const rowCat = $row.find("td[data-category]").data("category")?.toLowerCase();
        const rowBrand = $row.find("td[data-brand]").data("brand")?.toLowerCase();
        const rowModel = $row.find("td[data-model]").data("model")?.toLowerCase();
        const rowNameCode = $row.find("td[data-name]").data("name")?.toLowerCase();
  
        const matchCat = !cat || rowCat === cat;
        const matchBrand = !brand || rowBrand === brand;
        const matchModel = !model || rowModel === model;
        const matchKeyword = !keyword || rowNameCode.includes(keyword);
  
        $row.toggle(matchCat && matchBrand && matchModel && matchKeyword);
      });
    }
  
    // Etkinleştirme
    $("#filterCategory, #filterBrand, #filterModel").on("change", filterTable);
    $("#filterKeyword").on("keyup", filterTable);
  
    // Tüm checkbox'ları seç/kaldır
    $("#selectAll").on("change", function () {
      $(".rowCheckbox").prop("checked", $(this).is(":checked"));
    });
  
    // AJAX Gönderimi
    $("#sendSelected").on("click", function () {
      const selected = [];
        console.log("Selected products: ", selected);
      $(".rowCheckbox:checked").each(function () {
        const $cb = $(this);
        selected.push({
          product_id: $cb.data("productid"),
          product_name: $cb.data("productname"),
          stock_id: $cb.data("stockid"),
          brand: $cb.data("brand"),
          model: $cb.data("model"),
          category: $cb.data("category"),
            product_name2: $cb.data("productname2")
        });
      });
  
      if (selected.length === 0) {
        alert("Lütfen en az bir ürün seçin.");
        return;
      }
  
      $.ajax({
        url: "/api/saveSelectedProducts.cfm", // CFML endpoint
        method: "POST",
        contentType: "application/json",
        data: JSON.stringify({ products: selected }),
        success: function (response) {
          alert("Başarıyla gönderildi!");
          console.log(response);
        },
        error: function (xhr) {
          alert("Hata: " + xhr.statusText);
        }
      });
    });
  </script>
  
</cf_box>