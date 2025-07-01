<style>
  .ui-wrk-btn.active {
    background-color: red !important; /* Mavi arka plan */
    color: white;
    font-weight: bold;
  }
</style>
<cfquery NAME="getSatis" datasource="#dsn3#">
  select DISTINCT OFFER.OFFER_ID,OFFER.OFFER_NUMBER from w3Qa_1.OFFER_ROW
INNER JOIN w3Qa_1.OFFER ON OFFER.OFFER_ID=OFFER_ROW.OFFER_ID
where WRK_ROW_RELATION_ID IN (
SELECT WRK_ROW_ID FROM w3Qa_1.PBS_SELECTED_ROWS WHERE OFFER_ID=#attributes.INTERNAL_ID#
)
ORDER BY OFFER_ID DESC
</cfquery>
<cfset last_offer_id = "">
<cfif getSatis.recordCount>
  <cfset last_offer_id = getSatis.OFFER_ID>
</cfif>
<cf_box title="Teklif Oluşturma">
  <cfoutput>
<button class="ui-wrk-btn ui-wrk-btn-extra" data-pageid="1" onclick="GetPage(1,true,#last_offer_id#)">Yeni Ürün</button>
<button class="ui-wrk-btn ui-wrk-btn-extra" data-pageid="2" onclick="GetPage(2,true,#last_offer_id#)">Depodan Teslim</button>
<button class="ui-wrk-btn ui-wrk-btn-extra" data-pageid="3" onclick="GetPage(3,true,#last_offer_id#)">Depoya Tedarik</button>
</cfoutput>
<button class=" ui-wrk-btn ui-wrk-btn-success" id="send-btn">Satış Teklifine Dönüştür</button>

  
<cfoutput query="getSatis">
<button class="ui-wrk-btn ui-wrk-btn-success" onclick="window.location.href='index.cfm?fuseaction=sales.list_offer&event=upd&offer_id=#OFFER_ID#'">
  Teklife Git #OFFER_NUMBER#</button>
  </cfoutput>
<input type="hidden" name="INTERNAL_ID" id="INTERNAL_ID" value="<cfoutput>#attributes.INTERNAL_ID#</cfoutput>">
<div style="clear:both;"></div>

<div id="ShownArea"></div>
</cf_box>
<script src="/AddOns/Partner/purchase/form/main_functions.js"></script>
<script>
function GetPage(pageid, x = true,last_offer_id="") {
  console.log("GetPage called with pageid: " + pageid + " and x: " + x);

  var INTERNAL_ID = document.getElementById("INTERNAL_ID").value;

  // Butonların aktif durumunu güncelle
  document.querySelectorAll(".ui-wrk-btn[data-pageid]").forEach(function(btn) {
    btn.classList.remove("active");
  });
  var activeBtn = document.querySelector(".ui-wrk-btn[data-pageid='" + pageid + "']");
  if (activeBtn) activeBtn.classList.add("active");

  // Sayfa içeriğini yükle
  if (x) {
    if (SecimKontrol()) {
      AjaxPageLoad("index.cfm?fuseaction=sales.ajax_list_pbs_offer_purchases_" + pageid + "&last_offer_id="+last_offer_id+"&INTERNAL_ID=" + INTERNAL_ID, "ShownArea", 1, "Yükleniyor");
    }
  } else {
    AjaxPageLoad("index.cfm?fuseaction=sales.ajax_list_pbs_offer_purchases_" + pageid + "&last_offer_id="+last_offer_id+"&INTERNAL_ID=" + INTERNAL_ID, "ShownArea", 1, "Yükleniyor");
  }
}



$(document).ready(function() {
  GetPage(1,false,<cfoutput>"#last_offer_id#"</cfoutput>); 
});
  
</script>