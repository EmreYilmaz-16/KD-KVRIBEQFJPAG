<cfquery name="getRelOrder" datasource="#dsn#">
    SELECT * FROM workcube_hidtek.COMPANY_REL_ACTIONS_PARTNER WHERE TO_ACTION_ID=#attributes.ORDER_ID# AND TO_PERIOD_ID=#session.ep.period_id#
</cfquery>


<script>
$(document).on('ready',function(){
var fatid=getParameterByName('order_id');
var elem=document.getElementsByClassName("detailHeadButton")
<cfif getRelOrder.recordCount>
$(elem[0].children).append("<li class='dropdown' id='transformation'><a style='color:#fc0303' title='Şube Sipariş Detay'onclick='pencereac(5,"+fatid+",<cfoutput>#getRelOrder.FROM_PERIOD_ID#,#getRelOrder.FROM_ACTION_ID#</cfoutput>)'><i class='icon-link'></i></a></li>") 
</cfif>
$(elem[0].children).append("<li class='dropdown' id='transformation'><a style='color:#e303fc' title='Takip'onclick='pencereac(4,"+fatid+")'><i class='icon-bell'></i></a></li>")
$(elem[0].children).append("<li class='dropdown' id='transformation'><a style='color:#0489c7' title='Sevkiyat Talebi Oluştur' onclick='pencereac(1,"+fatid+")'><i class='icon-exchange'></i></a></li>")
$(elem[0].children).append("<li class='dropdown' id='transformation'><a style='color:#04c76c' title='Şube Sevkiyat Talebi Oluştur'onclick='pencereac(2,"+fatid+")'><i class='icon-industry'></i></a></li>")
$(elem[0].children).append("<li class='dropdown' id='transformation'><a style='color:#fcba03' title='Yazdır'onclick='pencereac(3,"+fatid+")'><i class='icon-print'></i></a></li>")

var eeeee=document.getElementsByClassName("ui-form-list-btn")[0].children[1].children[0];
var btn=document.createElement("button")
    btn.setAttribute("type","button")
    btn.innerText="Güncellemeye İzin Ver"
    btn.setAttribute("onclick","readonlyyy()")
    btn.setAttribute("class","ui-wrk-btn ui-wrk-btn-warning")
    eeeee.appendChild(btn)
    
    var ww=wrk_query("SELECT COUNT(*) AS MM FROM EZGI_SHIP_RESULT_ROW WHERE ORDER_ID="+fatid,"DSN3")
    var mmm=parseInt(ww.MM[0])
    if(mmm>0){
     //   $("#wrk_delete_button").hide();
    }
    
})



function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, '\\$&');
    var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
}
function pencereac(tip,idd,per,act){
    if(tip==1){
    windowopen('index.cfm?fuseaction=sales.popup_add_ezgi_shipping&order_id='+idd,'wide');}else if(tip==2){
        windowopen('index.cfm?fuseaction=sales.popup_list_order_internal_rate&order_id='+idd,'wide');
    }else if(tip==3){
         windowopen('index.cfm?fuseaction=objects.popup_print_files_old&action=sales.list_order&action_id='+idd+'&print_type=73','wide');
    }else if(tip==4){
        windowopen('index.cfm?fuseaction=objects.popup_rekactions_prt&action=ORDER&action_id='+idd,'wide');
    }else if(tip==5){
        windowopen('index.cfm?fuseaction=objects.emptypopup_branch_order_detail_pbs&FROM_PERIOD_ID='+per+'&FROM_ACTION_ID='+act,'wide');
    }
}

function readonlyyy(){
    var PriceElems=document.getElementsByName("Price")
var AmountElems=document.getElementsByName("Amount")
for(let i=0;i<PriceElems.length;i++){
    PriceElems[i].removeAttribute("readonly")
    AmountElems[i].removeAttribute("readonly")
}
}
///objects.popup_rekactions_prt
</script>