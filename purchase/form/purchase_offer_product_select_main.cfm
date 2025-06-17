<cf_box title="Teklif Oluşturma">
<button class=" ui-wrk-btn ui-wrk-btn-extra"  onclick="GetPage(1)">Yeni Ürün</button>
<button class="ui-wrk-btn ui-wrk-btn-extra" onclick="GetPage(2)">Depodan</button>
<button class="ui-wrk-btn ui-wrk-btn-extra" onclick="GetPage(3)">Depodan Tedarik</button>
<button class=" ui-wrk-btn ui-wrk-btn-success" id="send-btn">Kaydet ve Satış Teklifine Dönüştür</button>
<input type="hidden" name="INTERNAL_ID" id="INTERNAL_ID" value="<cfoutput>#attributes.INTERNAL_ID#</cfoutput>">
<div style="clear:both;"></div>

<div id="ShownArea"></div>
</cf_box>
<script src="/AddOns/Partner/purchase/form/main_functions.js"></script>
<script>
function GetPage(pageid) {
  var INTERNAL_ID = document.getElementById("INTERNAL_ID").value;
  AjaxPageLoad("index.cfm?fuseaction=sales.ajax_list_pbs_offer_purchases_"+pageid+"&INTERNAL_ID="+INTERNAL_ID , "ShownArea", 1, "Yükleniyor")
}


$(document).ready(function() {
  GetPage(1); 
});
  
</script>