<button onclick="GetPage(1)">Yeni Ürün</button>
<button onclick="GetPage(2)">Depodan</button>
<button>Depodan Tedarik</button>
<input type="hidden" name="INTERNAL_ID" id="INTERNAL_ID" value="<cfoutput>#attributes.INTERNAL_ID#</cfoutput>">
<div id="ShownArea"></div>

<script>
function GetPage(pageid) {
  var INTERNAL_ID = document.getElementById("INTERNAL_ID").value;
  AjaxPageLoad("index.cfm?fuseaction=sales.ajax_list_pbs_offer_purchases_"+pageid+"&INTERNAL_ID"+INTERNAL_ID , "ShownArea", 1, "Yükleniyor")
}
  
</script>