<cfquery name="getProductInfo" datasource="#dsn1#">
    SELECT IS_PACKAGE_PRODUCT FROM PRODUCT WHERE PRODUCT_ID=<cfqueryparam value="#url.pid#" cfsqltype="cf_sql_integer">
</cfquery>
<script>
    
$(document).on('ready',function(){
var pid=getParameterByName('pid');
var elem=document.getElementsByClassName("detailHeadButton")
$(elem[0].children).append("<li class='dropdown' id='transformation'><a style='color:#e303fc' title='Takip'onclick='pencereac(1,"+pid+")'><i class='icon-bell'></i></a></li>")
addR();
})


function pencereac(tip,idd,per,act){
    if(tip==1){
    windowopen('index.cfm?fuseaction=product.emptypopup_karma_products_pbs&action=KARMA_EMIR&pid='+idd,'wide');
    }
}
function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, '\\$&');
    var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
}
function addR(){
    var iiiii=document.getElementById("is_gift_card").parentElement.parentElement.parentElement
var html=`<div class="form-group" id="item-pbs_karma">
										<label class="col col-4 col-md-4 col-sm-4 col-xs-12">Paket Ürünü </label>
										<div class="col col-8 col-md-8 col-sm-8 col-xs-12"><input type="checkbox"<cfif getProductInfo.IS_PACKAGE_PRODUCT EQ 1> checked</cfif> name="is_package_product" id="is_package_product" value="1">Evet/Hayır </div>
									</div>`
iiiii.innerHTML+=html
}
</script>

