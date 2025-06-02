<style>
/* Sekmeler fade ile yumuşak geçiş yapsın */
.tab-pane.fade {
  opacity: 0;
  transition: opacity 0.3s ease-in-out;
  display: none;
}

/* Aktif sekme görünür ve opak hale gelsin */
.tab-pane.fade.show {
  opacity: 1;
  display: block;
}
</style>

<button id="Tab1" class="btn btn-primary active" data-bs-toggle="tab" data-bs-target="#Tab1Content" type="button">
  Satınalma Teklifini Seç

</button>
<button id="Tab2" class="btn btn-secondary" data-bs-toggle="tab" data-bs-target="#Tab2Content" type="button">
  Satınalma Teklifini Oluştur
</button>
<button id="Tab3" class="btn btn-secondary" data-bs-toggle="tab" data-bs-target="#Tab3Content" type="button">
  Satınalma Teklifini Dönüştür
</button>
<cfinclude template="includes/satin_alma_yeni_urun.cfm">
<cfinclude template="includes/depodan_teslim.cfm">
<div class="tab-content">
  <div class="tab-pane fade show active" id="Tab1Content">
    <!-- Tab 1 içeriği -->
    tab1 içeriği
    
    tab1 içeriği sonu
  </div>
  <div class="tab-pane fade" id="Tab2Content" style="display: none;">
    <!-- Tab 2 içeriği -->
    tab 2 içeriği
    
    tab 2 içeriği sonu
  </div>
  <div class="tab-pane fade" id="Tab3Content" style="display: none;">
    <!-- Tab 3 içeriği -->
    <cfinclude template="includes/depodan_tedarik.cfm">
  </div>

  <script>
document.addEventListener("DOMContentLoaded", function () {
  const buttons = document.querySelectorAll("button[data-bs-toggle='tab']");
  const contents = document.querySelectorAll(".tab-pane");

  buttons.forEach((btn) => {
    btn.addEventListener("click", function () {
      // Aktif buton sınıflarını ayarla
      buttons.forEach((b) => {
        b.classList.remove("btn-primary", "active");
        b.classList.add("btn-secondary");
      });
      this.classList.remove("btn-secondary");
      this.classList.add("btn-primary", "active");

      // İçerik görünürlüğünü ayarla
      const targetId = this.getAttribute("data-bs-target");

      contents.forEach((pane) => {
        if ("#" + pane.id === targetId) {
          pane.classList.add("show", "active");
        } else {
          pane.classList.remove("show", "active");
        }
      });
    });
  });
});
</script>
