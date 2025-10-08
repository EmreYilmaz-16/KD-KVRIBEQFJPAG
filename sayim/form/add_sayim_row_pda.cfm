<div class="form-group">
    <input type="text" class="form-control" id="rafNo" placeholder="Raf No" onkeyup="CheckRaf(this,event)">
</div>
<div style="display:none" id="barcodeSection">
<div class="form-group" style="margin-top: 24px; margin-left: 10px;">
			<select name="BarcodeParser" id="BarcodeParser">
				<option value="0">Barkod Parser</option>

			</select>
		</div>

<div class="form-group">
    <input type="text" class="form-control" id="barcode" placeholder="Barkod" onkeyup="checkBarcode(event,this)">
</div>
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
<cf_grid_list>
    <thead>
        <tr>
            <th>
                Seri No
            </th>
            
            <th>
                Stok Kodu
            </th>            
            <th>
                Raf
            </th>

        </tr>
    </thead>
    <tbody id="sayimRows">
        <!-- Sayım satırları buraya eklenecek -->
</tbody>
</cf_grid_list>
</cfform>




<script>
var bm=null;
var O=new Object();
var AllShelves=[];
var ActiveShelf=null;
 function checkBarcode(ev,el){
    var barcode = el.value;
    if(ev.key === 'Enter' && barcode.length >= 3){
        var SerialObject = bm.parseWith(barcode, parseInt(document.getElementById('BarcodeParser').value));
        console.log(SerialObject);
        if(SerialObject && SerialObject.serial_no){
				
			
			var tr=document.createElement('tr');
                tr.innerHTML='<td>'+SerialObject.serial_no+'</td><td>'+SerialObject.product_code_2+'</td><td id="shelfCodeCell">'+$("#activeShelfCode").val()+'</td>';
				document.getElementById('sayimRows').appendChild(tr);
				el.value='';
				var rowCount=parseInt(document.getElementById('rowCount').value)+1;
				document.getElementById('rowCount').value=rowCount;
				document.getElementById('rowCountLabel').innerText=rowCount;
				//var sayimForm=document.getElementById('sayimForm');
				//sayimForm.submit();
			}

    }
}
  function CheckRaf(el,ev) {
        var rafNo = document.getElementById("rafNo").value;
       if(ev.key === 'Enter' && rafNo.length >= 2){
           console.log(rafNo);
         ActiveShelf=AllShelves.find(p=>p.SHELF_CODE.toLowerCase() == rafNo.toLowerCase())
       console.log(ActiveShelf);
       $("#activeShelfID").val(ActiveShelf.PRODUCT_PLACE_ID);
       $("#activeShelfCode").val(ActiveShelf.SHELF_CODE);
         $("#activeShelfLabel").text("Aktif Raf: "+ActiveShelf.SHELF_CODE);
            //$("#rafNo").val('');
			$("#barcodeSection").show();
            $("#barcode").focus();

            }
    }

$(document).ready(function(){
     var sh=wrk_query("SELECT PPR.STOCK_ID,PPR.PRODUCT_PLACE_ID,S.PRODUCT_CODE_2 FROM PRODUCT_PLACE_ROWS AS PPR LEFT JOIN STOCKS AS S ON S.STOCK_ID=PPR.STOCK_ID","DSN3");

O.recordcount=sh.recordcount
O.SHELVES=[];
for(let i=0;i<sh.recordcount;i++){
    console.log(sh)
    var ix=O.SHELVES.findIndex(p=>p.SHELF_ID==sh.PRODUCT_PLACE_ID[i]);
    var SHELF_ID=sh.PRODUCT_PLACE_ID[i]
    var STOCK_ID=sh.STOCK_ID[i]
	var PRODUCT_CODE_2=sh.PRODUCT_CODE_2[i]
    if(ix ==-1){
        O.SHELVES.push({
            SHELF_ID,
            STOCKS:[{STOCK_ID,PRODUCT_CODE_2}]
        })
    }else{
        O.SHELVES[ix].STOCKS.push({STOCK_ID,PRODUCT_CODE_2})
    }
}
console.log(O)
var r=wrk_query("SELECT SHELF_CODE,PRODUCT_PLACE_ID FROM PRODUCT_PLACE","DSN3")

for(let i=0;i<r.recordcount;i++){
    var SHELF_CODE=r.SHELF_CODE[i];
    var PRODUCT_PLACE_ID=r.PRODUCT_PLACE_ID[i];
    AllShelves.push({SHELF_CODE,PRODUCT_PLACE_ID})
}
console.log(AllShelves)
 bm=new BarcodeManager();
var parsers=bm.listParsers();
for(var i=0;i<parsers.length;i++){
	$("#BarcodeParser").append('<option value="'+parsers[i].id+'">'+parsers[i].name+'</option>');
}

});
</script>



<script>
    function wrk_query(str_query,data_source,maxrows)
{
	/*console.log(str_query);
	alert('Bu sayfada wrk_query kullanılmıştır. İlgili kontrolü ajax yapısına çeviriniz.');
	return false;
	*/
	/*
	by  Workcube
	Created 20060315
	Modified 20060324
	Usage:
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1');
		veya
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1','dsn2');
		veya
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1 ORDER BY COL2 DESC','dsn2',1);
		ifadesi ile my_query degiskeni cfquery ile donen sonucun tamamen aynisi bir javascript query degeri alir
		data_source : optional , default olarak 'dsn' kullaniliyor
		maxrows : optional , default olarak 0 ataniyor, 0 olunca query sonucundaki tum kayitlar gelir
	*/
	
	var new_query=new Object();
	var req;
	if(!data_source) data_source='dsn';
	if(!maxrows) maxrows=0;
	function callpage(url) {
		req = false;
		if(window.XMLHttpRequest)
			try
				{req = new XMLHttpRequest();}
			catch(e)
				{req = false;}
		else if(window.ActiveXObject)
			try {
				req = new ActiveXObject("Msxml2.XMLHTTP");
				}
			catch(e)
				{
				try {req = new ActiveXObject("Microsoft.XMLHTTP");}
				catch(e)
					{req = false;}
				}
		if(req)
			{
				function return_function_()
				{

				if (req.readyState == 4 && req.status == 200)
					try
						{
							eval(req.responseText.replace(/\u200B/g,''));
							new_query = get_js_query; //alert('Cevap:\n\n'+req.responseText);//
						}
					catch(e)
						{new_query = false;}
				}
			req.open("post", url+'&xmlhttp=1', false);
			req.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
			req.setRequestHeader('pragma','nocache');
			if(encodeURI(str_query).indexOf('+') == -1) // + isareti encodeURI fonksiyonundan gecmedigi icin encodeURIComponent fonksiyonunu kullaniyoruz. EY 20120125
				req.send('str_sql='+encodeURI(str_query)+'&data_source='+data_source+'&maxrows='+maxrows);
			else
				req.send('str_sql='+encodeURIComponent(str_query)+'&data_source='+data_source+'&maxrows='+maxrows);
			return_function_();
			}
		
	}
	
	//TolgaS 20070124 objects yetkisi olmayan partnerlar var diye fuseaction objects2 yapildi
	callpage('/index.cfm?fuseaction=objects2.emptypopup_get_js_query&isAjax=1');
	//alert(new_query);
	
	return new_query;
}
</script>