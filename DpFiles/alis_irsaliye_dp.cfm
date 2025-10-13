<script>
    $(document).on('ready',function(){
        var fatid=getParameterByName('order_id');
        var elem=document.getElementsByClassName("detailHeadButton")
        $(elem[0].children).append("<li class='dropdown' id='transformation'><a style='color:#e303fc' title='Takip'onclick='pencereac(1,"+fatid+")'><i class='icon-bell'></i></a></li>")
    });
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
    windowopen('index.cfm?fuseaction=objects.emptypopup_process_db_import&ship_id='+idd,'wide');}else if(tip==2){
        windowopen('index.cfm?fuseaction=sales.popup_list_order_internal_rate&order_id='+idd,'wide');
    }else if(tip==3){
         windowopen('index.cfm?fuseaction=objects.popup_print_files_old&action=sales.list_order&action_id='+idd+'&print_type=73','wide');
    }else if(tip==4){
        windowopen('index.cfm?fuseaction=objects.popup_rekactions_prt&action=ORDER&action_id='+idd,'wide');
    }else if(tip==5){
        windowopen('index.cfm?fuseaction=objects.emptypopup_branch_order_detail_pbs&FROM_PERIOD_ID='+per+'&FROM_ACTION_ID='+act,'wide');
    }
}
</script>