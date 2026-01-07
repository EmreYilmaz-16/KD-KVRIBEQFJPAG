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
</script>

