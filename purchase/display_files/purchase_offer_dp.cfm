<script>
$(document).ready(function () {
    

// Sepet tablosundaki tüm <tr> satırlarını gez
    $("#tblBasket tbody").children().each(function(index, row) {
        const $row = $(row);
    
        // Ürün bilgilerini al
        const productId = $row.find("[name='product_id']").val();
        const productName = $row.find("[name='product_name']").val();
        const productNameOther = $row.find("[name='product_name_other']").val();
        const wrkRowId = $row.find("[name='wrk_row_id']").val();
    
        const productData = {
            productId,
            productName,
            productNameOther,
            wrkRowId,
            index
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
            if(productId =="1055"){
                $ul.append($li);
            }else{
             //   $ul.append($link);
            }
        
    });
    
    
    // Bilgi gösterme fonksiyonu
    function showProductAlert(index, data) {
        console.log("Index:", index);
        console.log("Product Data:", data);
    
          const url = new URL(window.location.origin + "/index.cfm?fuseaction=product.emptypopup_add_product_from_purchase");
        const params = new URLSearchParams(window.location.search);
        var offer_id=params.get("offer_id")
        // Veriyi query string olarak ekle (encode ederek)
        url.searchParams.set("productId", data.productId);
        url.searchParams.set("productName", data.productName);
        url.searchParams.set("productNameOther", data.productNameOther);
        url.searchParams.set("wrkRowId", data.wrkRowId);
        url.searchParams.set("index", index);
        url.searchParams.set("offer_id", offer_id);
    
        // Yeni pencereyi aç
        windowopen(url.toString(), "adminTv");
    }
})
</script>

