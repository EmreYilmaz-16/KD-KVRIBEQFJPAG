$(document).ready(function () {
    $(".header").hide();
    document.getElementById('add_other_barcod').focus();
    setTimeout("document.getElementById('add_other_barcod').select();", 1000);

})
function actionidolustur() {
    var j = 0;
    for (i = 1; i <= row_count; i++) {
        if (document.getElementById('amount' + i).value > 0) {
            if (j > 0)
                document.getElementById('action_id').value = document.getElementById('action_id').value + ',';
            document.getElementById('action_id').value = document.getElementById('action_id').value + i + '-';
            document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('stockid' + i).value + '-';
            document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('amount' + i).value + '-';
            document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('shelf_code' + i).value
            j++;
        }
        document.getElementById('row_count').value = j;
    }
}