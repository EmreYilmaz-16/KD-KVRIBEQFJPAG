<div class="form-group">
    <input type="text" class="form-control" id="rafNo" placeholder="Raf No" onkeyup="CheckRaf()">
</div>
<cfform id="sayimForm" method="post" action="add_sayim_row_action_pda.cfm">
    <input type="hidden" name="sayimID" value="#sayimID#">        
<div id="activeShelf">
<span id="activeShelfLabel" class="badge badge-info">Raf Okutunuz</span>
<span id="rowCountLabel" class="badge badge-info">0</span>
<input type="hidden" name="activeShelfID" id="activeShelfID" value="">
<input type="hidden" name="activeShelfCode" id="activeShelfCode" value="">
<input type="hidden" name="rowCount" id="rowCount" value="0">

</div>
</cfform>
<script>
    function CheckRaf() {
        var rafNo = document.getElementById("rafNo").value;
        if (rafNo.length >= 3) {
            fetch('check_raf.cfm?rafNo=' + encodeURIComponent(rafNo))
                .then(response => response.text())
                .then(data => {
                    document.getElementById("activeShelf").innerHTML = data;
                })
                .catch(error => console.error('Error:', error));
        } else {
            document.getElementById("activeShelf").innerHTML = '';
        }
    }
</script>
<div class="form-group">
    <input type="text" class="form-control" id="barcode" placeholder="Barkod" onkeyup="checkBarcode(event,this)">
</div>


<script>
var bm=null;
 function checkBarcode(ev,el){
    var barcode = el.value;
    if(ev.key === 'Enter' && barcode.length >= 3){

    }
}
</script>
