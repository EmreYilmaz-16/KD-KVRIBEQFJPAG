<button onclick="GetPage(1)">Yeni Ürün</button>
<button onclick="GetPage(2)">Depodan</button>
<button>Depodan Tedarik</button>
<div id="ShownArea"></div>

<script>
function GetPage(pageid) {
  AjaxPageLoad("index.cfm?fuseaction=sales.ajax_list_pbs_offer_purchases_"+pageid , "ShownArea", 1, "Yükleniyor")
}
  
</script>