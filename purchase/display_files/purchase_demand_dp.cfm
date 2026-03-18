
<script>
var OFFER_PRODUCT=<cfoutput>#session.kd.OFFER_PRODUCT_ID#</cfoutput>;
$(document).ready(function () {
            var btn=document.createElement("button")
btn.setAttribute("type","button")
btn.setAttribute("onclick",'windowopen("index.cfm?fuseaction=purchase.purchase_offer_selector_main&internal_id=<cfoutput>#attributes.id#</cfoutput>","page_display")')
btn.innerText="Fiyat Karşılaştırma"
btn.setAttribute("class"," ui-wrk-btn ui-wrk-btn-warning")
document.getElementById("workcube_button").appendChild(btn)
var txt=document.createElement("span")
txt.innerText="Belge Para Biriminde Değişikllik Yaptıktan Sonra Fiyat Karşılaştırma Ekranını Kontrol Etmeyi Unutmayınız !"
txt.setAttribute("style","color:red;font-weight:bold;margin-left:10px")
document.getElementsByClassName("totalBox")[0].appendChild(txt)
//SatinalmaTalebiSayfaIslemleri();

    
})
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

function duplicate_control(){
    var rows = document.querySelectorAll("#tblBasket tr[basketitem]");

var countMap = {};
var hatam=false;

// 1️⃣ kaç tane var say
rows.forEach(row => {
  var pid = row.querySelector("input[id='product_id']").value;
  countMap[pid] = (countMap[pid] || 0) + 1;
});

// 2️⃣ tekrar edenleri boya
rows.forEach(row => {
  var pid = row.querySelector("input[id='product_id']").value;

  if (countMap[pid] > 1) {
    row.style.backgroundColor = "#ffcccc"; // açık kırmızı
    hatam=true;
  }
});
if (hatam){
    alert("Sepette aynı üründen birden fazla var. Lütfen kontrol ediniz.");

}
}
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

function SatinalmaTalebiSayfaIslemleri(){

SanallariIsaretle();
ButonYaz();

// Sepet tablosundaki tüm <tr> satırlarını gez
    $("#tblBasket tbody").children().each(function(index, row) {
        const $row = $(row);
    
        // Ürün bilgilerini al
        const productId = $row.find("[name='product_id']").val();
        const productName = $row.find("[name='product_name']").val();
        const productNameOther = $row.find("[name='product_name_other']").val();
        const wrkRowId = $row.find("[name='wrk_row_id']").val();
        const detail_info_extra = $row.find("[name='detail_info_extra']").val();
    
        const productData = {
            productId,
            productName,
            productNameOther,
            wrkRowId,
            index,
            detail_info_extra
        };
    
        console.log(productData);
    
        // 2. hücreyi (Al sütunu) al
        const $cell = $row.children().eq(1);
    
        // Hücredeki <ul> etiketini bul
        const $ul = $cell.find("ul");
    
        // <a> ve <i> etiketlerini oluştur
        const $icon = $("<i>").addClass("fa fa-plus");
        const $link = $("<a>")
            .attr("href", "#")
            .append($icon)
            .on("click", function(e) {
                e.preventDefault(); // sayfa kaymasını engelle
                showProductAlert(index, productData);
            });
    
        // <li> etiketi oluştur ve linki içine ekle
        const $li = $("<li>").append($link);
    
        // <ul> içine <li> ekle
            if(productId ==OFFER_PRODUCT){
                $ul.append($li);
            }else{
             //   $ul.append($link);
            }
        
    });
    
    
}

</script>

