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

<!-- Filtre Alanları -->
<div class="row mb-3">
    <div class="col-md-3">
      <label>Kategori</label>
      <select id="filterCategory" class="form-control">
        <option value="">Tümü</option>
        <cfoutput query="qResults" group="PRODUCT_CATID">
          <option value="#PRODUCT_CAT#">#PRODUCT_CAT#</option>
        </cfoutput>
      </select>
    </div>
  
    <div class="col-md-3">
      <label>Marka</label>
      <select id="filterBrand" class="form-control">
        <option value="">Tümü</option>
        <cfoutput query="qResults" group="BRAND_ID">
          <option value="#BRAND_NAME#">#BRAND_NAME#</option>
        </cfoutput>
      </select>
    </div>
  
    <div class="col-md-3">
      <label>Model</label>
      <select id="filterModel" class="form-control">
        <option value="">Tümü</option>
        <cfoutput query="qResults" group="MODEL_ID">
          <option value="#MODEL_NAME#">#MODEL_NAME#</option>
        </cfoutput>
      </select>
    </div>
  
    <div class="col-md-3">
      <label>Ürün Ara</label>
      <input type="text" id="filterKeyword" class="form-control" placeholder="Ürün adı veya kodu...">
    </div>
  </div>
  
  <!-- Tablo -->
  <table id="productTable" class="table table-bordered table-striped">
    <thead class="bg-dark text-white">
      <tr>
        <th><input type="checkbox" id="selectAll"></th> <!-- Tümünü Seç -->
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
            <input type="checkbox" class="rowCheckbox"
              data-productid="#PRODUCT_ID#"
              data-productname="#OFFER_PRODUCT_NAME#"
              data-productname2="#STOCK_PRODUCT_NAME#"
              data-stockid="#STOCK_ID#"
              data-brand="#BRAND_NAME#"
              data-model="#MODEL_NAME#"
              data-category="#PRODUCT_CAT#"
            >
          </td>
          <td data-name="#OFFER_PRODUCT_NAME# #PRODUCT_CODE# #STOCK_PRODUCT_NAME#">#OFFER_PRODUCT_NAME#</td>
          <td>#STOCK_PRODUCT_NAME#</td>
          <td data-category="#PRODUCT_CAT#">#PRODUCT_CAT#</td>
          <td data-brand="#BRAND_NAME#">#BRAND_NAME#</td>
          <td data-model="#MODEL_NAME#">#MODEL_NAME#</td>
        </tr>
      </cfoutput>
    </tbody>
  </table>
  
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
        const rowCat = $row.find("td[data-category]").data("category").toLowerCase();
        const rowBrand = $row.find("td[data-brand]").data("brand").toLowerCase();
        const rowModel = $row.find("td[data-model]").data("model").toLowerCase();
        const rowNameCode = $row.find("td[data-name]").data("name").toLowerCase();
  
        const matchCat = !cat || rowCat === cat;
        const matchBrand = !brand || rowBrand === brand;
        const matchModel = !model || rowModel === model;
        const matchKeyword = !keyword || rowNameCode.includes(keyword);
  
        if (matchCat && matchBrand && matchModel && matchKeyword) {
          $row.show();
        } else {
          $row.hide();
        }
      });
    }
  
    // Olay dinleyicileri
    $("#filterCategory, #filterBrand, #filterModel").on("change", filterTable);
    $("#filterKeyword").on("keyup", filterTable);
  </script>
  
  <script>
    // Tümünü seç / kaldır
    $("#selectAll").on("change", function () {
      $(".rowCheckbox").prop("checked", $(this).is(":checked"));
    });
  
    // Seçilenleri gönder
    $("#sendSelected").on("click", function () {
      const selected = [];
  
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
        alert("Lütfen en az bir ürün seçiniz.");
        return;
      }
  
      // AJAX Gönderimi
      $.ajax({
        url: "/api/saveSelectedProducts.cfm", // Senin CFML endpoint'in
        method: "POST",
        contentType: "application/json",
        data: JSON.stringify({ products: selected }),
        success: function (response) {
          alert("Seçilen ürünler başarıyla gönderildi!");
          console.log(response);
        },
        error: function (xhr) {
          alert("Hata oluştu: " + xhr.statusText);
        }
      });
    });
  </script>