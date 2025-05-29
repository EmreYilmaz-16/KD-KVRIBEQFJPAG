<button id="Tab1" class="btn btn-primary active" data-bs-toggle="tab" data-bs-target="#Tab1Content" type="button">
  Satınalma Teklifini Seç

</button>
<button id="Tab2" class="btn btn-secondary" data-bs-toggle="tab" data-bs-target="#Tab2Content" type="button">
  Satınalma Teklifini Oluştur
</button>
<button id="Tab3" class="btn btn-secondary" data-bs-toggle="tab" data-bs-target="#Tab3Content" type="button">
  Satınalma Teklifini Dönüştür
</button>
<div class="tab-content">
  <div class="tab-pane fade show active" id="Tab1Content">
    <!-- Tab 1 içeriği -->
    <cf_include template="includes/satin_alma_yeni_urun.cfm">
  </div>
  <div class="tab-pane fade" id="Tab2Content">
    <!-- Tab 2 içeriği -->
    <cf_include template="includes/depodan_teslim.cfm">
  </div>
  <div class="tab-pane fade" id="Tab3Content">
    <!-- Tab 3 içeriği -->
    <cf_include template="includes/depodan_tedarik.cfm">
  </div>