<cf_box title="Teklif Oluşturma">
<button class=" ui-wrk-btn ui-wrk-btn-extra"  onclick="GetPage(1)">Yeni Ürün</button>
<button class="ui-wrk-btn ui-wrk-btn-extra" onclick="GetPage(2)">Depodan Teslim</button>
<button class="ui-wrk-btn ui-wrk-btn-extra" onclick="GetPage(3)">Depoya Tedarik</button>
<button class=" ui-wrk-btn ui-wrk-btn-success" id="send-btn">Kaydet ve Satış Teklifine Dönüştür</button>
<cfquery NAME="getSatis" datasource="#dsn3#">
  select DISTINCT OFFER.OFFER_ID,OFFER.OFFER_NUMBER from w3Qa_1.OFFER_ROW
INNER JOIN w3Qa_1.OFFER ON OFFER.OFFER_ID=OFFER_ROW.OFFER_ID
where WRK_ROW_RELATION_ID IN (
SELECT WRK_ROW_ID FROM w3Qa_1.PBS_SELECTED_ROWS WHERE OFFER_ID=#attributes.INTERNAL_ID#
)
</cfquery>
<cfoutput query="#getSatis#">
<button class="ui-wrk-btn ui-wrk-btn-success" onclick="window.location.href=index.cfm?fuseaction=sales.list_offer&event=upd&offer_id=#OFFER_ID#'">
  Teklife Gİt #OFFER_NUMBER#</button>
  </cfoutput>
<input type="hidden" name="INTERNAL_ID" id="INTERNAL_ID" value="<cfoutput>#attributes.INTERNAL_ID#</cfoutput>">
<div style="clear:both;"></div>

<div id="ShownArea"></div>
</cf_box>
<script src="/AddOns/Partner/purchase/form/main_functions.js"></script>
<script>
function GetPage(pageid,x=true) {
  
  console.log("GetPage called with pageid: " + pageid + " and x: " + x);

  
  var INTERNAL_ID = document.getElementById("INTERNAL_ID").value;
  if(x){
    if( SecimKontrol()){
      AjaxPageLoad("index.cfm?fuseaction=sales.ajax_list_pbs_offer_purchases_"+pageid+"&INTERNAL_ID="+INTERNAL_ID , "ShownArea", 1, "Yükleniyor")  
    }
  }else{
    AjaxPageLoad("index.cfm?fuseaction=sales.ajax_list_pbs_offer_purchases_"+pageid+"&INTERNAL_ID="+INTERNAL_ID , "ShownArea", 1, "Yükleniyor")
  }
  
  
  
}


$(document).ready(function() {
  GetPage(1,false); 
});
  
</script>