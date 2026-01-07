<script>
    
$(document).on('ready',function(){
var pid=getParameterByName('pid');
var elem=document.getElementsByClassName("detailHeadButton")
$(elem[0].children).append("<li class='dropdown' id='transformation'><a style='color:#e303fc' title='Takip'onclick='pencereac(1,"+pid+")'><i class='icon-bell'></i></a></li>")
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
</script>

ColdfusionProjects\kd\karmakoli\form\add_update_karma_products.cfm