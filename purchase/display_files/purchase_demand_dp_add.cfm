
<script>
var OFFER_PRODUCT=<cfoutput>#session.kd.OFFER_PRODUCT_ID#</cfoutput>;
$(document).ready(function () {
ButonYaz();
        
    });
    
    
    // Bilgi gösterme fonksiyonu
    function showProductAlert(index, data) {
        console.log("Index:", index);
        console.log("Product Data:", data);
    
          const url = new URL(window.location.origin + "/index.cfm?fuseaction=product.emptypopup_add_product_from_purchase_demand");
        const params = new URLSearchParams(window.location.search);
        var offer_id=params.get("id")
        // Veriyi query string olarak ekle (encode ederek)
        url.searchParams.set("productId", data.productId);
        url.searchParams.set("productName", data.productName);
        url.searchParams.set("productNameOther", data.productNameOther);
        url.searchParams.set("wrkRowId", data.wrkRowId);
        url.searchParams.set("index", index);
        url.searchParams.set("offer_id", offer_id);
        url.searchParams.set("oem_no", data.detail_info_extra);
    
        // Yeni pencereyi aç
        windowopen(url.toString(), "adminTv");
    }

    function SanallariIsaretle() {
        //var rows=$("#tblBasket tr[basketitem]")
var rows=document.querySelectorAll("#tblBasket tr[basketitem]")
rows.forEach(function (row) {
  //console.log(row)
    var pid=row.querySelector("input[id='product_id']").value
    console.log(pid)
    if(parseInt(pid)==OFFER_PRODUCT){
        $(row).css("background","#ffa50069")
    }
})
    }
})
function open_product_popup_special(satir)
	  {
		  url_str = 'index.cfm?fuseaction=stock.emptypopup_stock_detail_pbs';
		  var data = window.basket.items[satir];
		  var stock_id = data.STOCK_ID;
		  var product_id = data.PRODUCT_ID;
		  var spect_id = data.SPECT_ID;
		  var spect_name = data.SPECT_NAME;
		  if(spect_id != undefined && spect_id != '' && spect_name != '')
			  url_str = url_str+'&spec_id='+spect_id;
		  
		  
		  if(product_id != "")
			  openBoxDraggable(url_str + '&pid='+ product_id + '&sid='+stock_id);
	  }

function ButonYaz(){
   var els = document.querySelectorAll("#tblBasket > tbody > tr > td:nth-child(4) > div > div");
for (let i = 0; i < els.length; i++) {
  var span = document.createElement("span");
  span.className = "input-group-addon";
  span.id = `product_popup_${i}`;
  span.title = "Ürün Detayları İçin Tıklayınız";
span.style.color="green"
  span.onclick = function () { open_product_popup_special(i); };

  var icon = document.createElement("i");
  icon.className = "fa fa-ellipsis-v";

  span.appendChild(icon);
  els[i].appendChild(span);
}
 
}
</script>

