<style>
  .ui-wrk-btn.active {
    background-color: red !important; /* Mavi arka plan */
    color: white;
    font-weight: bold;
  }
</style>
<cfquery NAME="getSatis" datasource="#dsn3#">
  select DISTINCT OFFER.OFFER_ID,OFFER.OFFER_NUMBER from #dsn3#.OFFER_ROW
INNER JOIN #dsn3#.OFFER ON OFFER.OFFER_ID=OFFER_ROW.OFFER_ID
where WRK_ROW_RELATION_ID IN (
SELECT WRK_ROW_ID FROM #dsn3#.PBS_SELECTED_ROWS WHERE OFFER_ID=#attributes.INTERNAL_ID#
)
ORDER BY OFFER_ID DESC
</cfquery>
<cfquery name="qcheck" datasource="#dsn3#">
  SELECT 
    I_ID,
    CASE 
        WHEN COUNT(*) = SUM(CASE WHEN SELECT_INFO_EXTRA = 3 THEN 1 ELSE 0 END)
        THEN 1  -- tüm satırlar 3 ise
        ELSE 0  -- farklı değer varsa
    END AS TUMU_3_MU
FROM #dsn3#.INTERNALDEMAND_ROW
WHERE I_ID = #attributes.INTERNAL_ID# AND SELECT_INFO_EXTRA<> -6 
GROUP BY I_ID;
</cfquery>
<cfset last_offer_id = "">
<cfif getSatis.recordCount>
  <cfset last_offer_id = getSatis.OFFER_ID>
</cfif>
<cfquery name="getInternal" datasource="#dsn3#">
  SELECT INTERNALDEMAND_STAGE FROM #dsn3#.INTERNALDEMAND WHERE INTERNAL_ID=#attributes.INTERNAL_ID#
</cfquery>
<cfquery name="GETORDERS" datasource="#dsn3#">
  
SELECT DISTINCT ORDER_ID,ORDER_NUMBER FROM (
SELECT DISTINCT * FROM (
SELECT	
		
		ALT_TEKLIFM.OFFER_NUMBER AS ALT_TEKLIF_NO,		
		IR.I_ID AS INTERNAL_ID,
		STTK_M.OFFER_NUMBER SATIS_TEKLIF_NO,
		STTK_M.OFFER_STAGE,
		STTK_M.OFFER_ID AS SATIS_TEKLIF_ID, 
		O.ORDER_NUMBER ,
		O.ORDER_ID,
		ALT_TEKLIF.OFFER_ID
		FROM #dsn3#.INTERNALDEMAND_ROW AS IR
	LEFT JOIN #dsn3#.OFFER_ROW AS ANA_TEKLIF ON ANA_TEKLIF.WRK_ROW_RELATION_ID=IR.WRK_ROW_ID
	LEFT JOIN #dsn3#.OFFER AS ANA_TEKLIFM ON ANA_TEKLIFM.OFFER_ID=ANA_TEKLIF.OFFER_ID
	LEFT JOIN #dsn3#.OFFER_ROW  AS ALT_TEKLIF ON ANA_TEKLIF.WRK_ROW_ID=ALT_TEKLIF.WRK_ROW_RELATION_ID
	LEFT JOIN #dsn3#.OFFER AS ALT_TEKLIFM ON ALT_TEKLIFM.OFFER_ID=ALT_TEKLIF.OFFER_ID
	LEFT JOIN #dsn3#.OFFER_ROW AS ST_TEKLIF ON ST_TEKLIF.WRK_ROW_RELATION_ID=ALT_TEKLIF.WRK_ROW_ID 
	LEFT JOIN #dsn3#.OFFER AS STTK_M ON STTK_M.OFFER_ID=ST_TEKLIF.OFFER_ID AND STTK_M.OFFER_STAGE<>267
	LEFT JOIN #dsn3#.ORDER_ROW AS ALS_SIP ON ALS_SIP.WRK_ROW_RELATION_ID=ST_TEKLIF.WRK_ROW_ID+'_XX'
	LEFT JOIN #dsn3#.ORDERS AS O ON O.ORDER_ID=ALS_SIP.ORDER_ID
	
	) AS T WHERE OFFER_STAGE<>267 AND OFFER_STAGE IS NOT NULL 
	) TT WHERE INTERNAL_ID=#attributes.INTERNAL_ID# AND ORDER_ID IS NOT NULL

</cfquery>

<cf_box title="Teklif Oluşturma">
  <cfoutput>
<button class="ui-wrk-btn ui-wrk-btn-extra" data-pageid="1" onclick="GetPage(1,true,#last_offer_id#)">Yeni Ürün</button>
<button class="ui-wrk-btn ui-wrk-btn-extra" data-pageid="2" onclick="GetPage(2,true,#last_offer_id#)">Depodan Teslim</button>
<button class="ui-wrk-btn ui-wrk-btn-extra" data-pageid="3" onclick="GetPage(3,true,#last_offer_id#)">Depoya Tedarik</button>
</cfoutput>
<div style="display:none" class="alert alert-danger">
  <cfoutput>
    <p>session.kd.PURCHASE_DEMAND_ACCEPT_PROCESS_ROW_ID_LIST =========   #session.kd.PURCHASE_DEMAND_ACCEPT_PROCESS_ROW_ID_LIST#</p>
    <p>getInternal.INTERNALDEMAND_STAGE =========   #getInternal.INTERNALDEMAND_STAGE#</p>
  </cfoutput>
</div>

    <button <cfif listFindNoCase(session.kd.PURCHASE_DEMAND_ACCEPT_PROCESS_ROW_ID_LIST,getInternal.INTERNALDEMAND_STAGE) neq 0><cfelse>style="display:none;"</cfif> class=" ui-wrk-btn ui-wrk-btn-success" id="send-btn">Satış Teklifine Dönüştür</button>

  
<cfoutput query="getSatis">
  <button class="ui-wrk-btn ui-wrk-btn-success" onclick="window.location.href='index.cfm?fuseaction=sales.list_offer&event=upd&offer_id=#OFFER_ID#'">Teklife Git #OFFER_NUMBER#</button> <!----Satış Teklifi--->
</cfoutput>

<cfif GETORDERS.recordCount> 
  <cfoutput query="GETORDERS">
    <button class="ui-wrk-btn ui-wrk-btn-warning" onclick="window.location.href='index.cfm?fuseaction=purchase.list_order&event=upd&order_id=#ORDER_ID#'" id="send-btn2aaa">Siparişe Git - #ORDER_NUMBER#</button> <!----Satınalma Sİparişi--->
  </cfoutput>
<cfelse>
  <cfinclude template="includes/get_offer_stage_query.cfm">
  <cfif getOfferStage.recordCount>
  <cfelse>
    <cfquery name="upos" datasource="#dsn3#">
      UPDATE #dsn3#.PBS_SELECTED_ROWS SET IS_OS=1 WHERE OFFER_ID=#attributes.internal_id#
    </cfquery>
  </cfif>
  <cfoutput>
    getOfferStage =#getOfferStage.OFFER_STAGE# <br>
    session.kd.SALE_ORDER_ACCEPT_PROCESS_ROW_ID = #session.kd.SALE_ORDER_ACCEPT_PROCESS_ROW_ID# <br>
    qcheck.TUMU_3_MU = #qcheck.TUMU_3_MU# <br>
    SS = #getOfferStage.SS# <br>
  </cfoutput>
  <CFIF getOfferStage.OFFER_STAGE EQ session.kd.SALE_ORDER_ACCEPT_PROCESS_ROW_ID ><!------and getOfferStage.SS EQ 0------>
    <cfif qcheck.TUMU_3_MU EQ 0>
      <button class="ui-wrk-btn ui-wrk-btn-warning" onclick="SatinalmaSiparis(<CFOUTPUT>#attributes.internal_id#,#last_offer_id#</CFOUTPUT>)" id="send-btn2">Tüm Satınalma Siparişlerini Oluştur</button> <!----Satınalma Sİparişi--->
    </cfif>
    
  </CFIF>
</cfif>
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