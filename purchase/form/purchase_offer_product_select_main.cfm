<button class="btn btn-primary"  onclick="GetPage(1)">Yeni Ürün</button>
<button class="btn btn-primary" onclick="GetPage(2)">Depodan</button>
<button class="btn btn-primary" onclick="GetPage(3)">Depodan Tedarik</button>
<button class="btn btn-success" id="send-btn">Kaydet ve Satış Teklifine Dönüştür</button>
<input type="hidden" name="INTERNAL_ID" id="INTERNAL_ID" value="<cfoutput>#attributes.INTERNAL_ID#</cfoutput>">
<div id="ShownArea"></div>

<script>
function GetPage(pageid) {
  var INTERNAL_ID = document.getElementById("INTERNAL_ID").value;
  AjaxPageLoad("index.cfm?fuseaction=sales.ajax_list_pbs_offer_purchases_"+pageid+"&INTERNAL_ID="+INTERNAL_ID , "ShownArea", 1, "Yükleniyor")
}
  
</script>