<cfquery name="gets" datasource="#dsn#">
    select * from w3Qa.PROCESS_TYPE_ROWS_CAUID where PROCESS_ROW_ID=253
</cfquery>

<script>
    $(document).ready(function () {
        <cfif listFind(valueList(gets.CAU_POSITION_ID),session.ep.POSITION_CODE)> 
        var btn=document.createElement("button")
btn.setAttribute("type","button")
btn.setAttribute("onclick",'windowopen("index.cfm?fuseaction=sales.emptypopup_add_offer_discount_pbs&offer_id=<cfoutput>#attributes.offer_id#</cfoutput>","horizantal")')
btn.innerText="İskonto Gir"
btn.setAttribute("class"," ui-wrk-btn ui-wrk-btn-warning")
document.getElementById("workcube_button").appendChild(btn)
</cfif>
alternatifkontrol();
VeriAlVeYaz(getParameterByName('offer_id'));
        





    })


    function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, '\\$&');
    var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
}

function alternatifkontrol(params) {
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
    
    
$.ajax({
    url: "/AddOns/Partner/purchase/cfc/purchase_service.cfc?method=getByProductId&returnFormat=json",
    method: "POST",
    contentType: "application/x-www-form-urlencoded",
    data: { product_id: productId },
    dataType: "json",
    success: function(response) {
       console.log(response)
        if (Array.isArray(response)) {
            const randomColor = getRandomColor();
            $("#tblBasket tbody").children().each(function(i, otherRow) {
                const otherProductId = parseInt($(otherRow).find("[name='product_id']").val());
                //console.log(otherProductId)
                if (response.includes(otherProductId)) {
                  console.warn("oms")
                    $(otherRow).css("background-color", randomColor);
                    $($row).css("background-color", randomColor);
                    console.log(otherRow)
                }
            });
        }
    },
    error: function(xhr, status, err) {
        console.error("Alternatif ürün hatası:", err);
    }
});

        
    });


}
function getRandomColor() {
    const letters = "789ABCD";
    let color = "#";
    for (let i = 0; i < 6; i++) {
        color += letters[Math.floor(Math.random() * letters.length)];
    }
    return color;
}


function VeriAlVeYaz(offerId){
fetch('/AddOns/Partner/sales/cfc/sale_service.cfc?method=getOfferMarjs&offerid='+offerId, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },

}).then(res => res.json()).then(data => {
    $('td[yeni_eklendi]').remove();
    $('th[yeni_eklendi]').remove();
    BaslikOlustur();
    console.log(data)
    var trElements = document.querySelectorAll('tr[basketitem]');
    for (let i = 0; i < trElements.length; i++) {
        SatirOlustur(i,data.DATA,trElements[i])
    }
}).catch(err => {console.error(err);});
}
function BaslikOlustur(){
    
    var theadTr = document.querySelector('thead[basketthead] tr');
    var ths = theadTr.querySelectorAll('th');
    var newTh = document.createElement('th');
        newTh.setAttribute('nowrap', 'nowrap'); // diğerleri gibi olsun diye
        newTh.style.minWidth = "90px"; // istersen sabit genişlik de verebilirsin
        newTh.innerHTML = '<span>Marj Oranı</span>'; // başlık ismi burada
        newTh.setAttribute("YENI_EKLENDI","")

        var newTh2 = document.createElement('th');
        newTh2.setAttribute('nowrap', 'nowrap'); // diğerleri gibi olsun diye
        newTh2.style.minWidth = "90px"; // istersen sabit genişlik de verebilirsin
        newTh2.innerHTML = '<span>+Fiyat</span>'; // başlık ismi burada
        newTh2.setAttribute("YENI_EKLENDI","")
        // 3. th'den sonra ekle (yani th[2] den sonra)
        if (ths[7]) {
            ths[7].after(newTh);
            newTh.after(newTh2);
        }
}
function SatirOlustur(i,data,row){
    var tr = row;
    var WRK_ROW_ID = tr.querySelector('#wrk_row_id').value;
    var ROW_INDEX = data.findIndex(p => p.WRK_ROW_ID == WRK_ROW_ID)
    var PRICE=data[ROW_INDEX].PRICE_PBS
    var MARJ=data[ROW_INDEX].MARJ_ORAN_PBS
    
    var tds = tr.querySelectorAll('td');
    var newTd = document.createElement('td');
    newTd.innerHTML = '<div>'+MARJ+'%</div>';
    newTd.setAttribute("YENI_EKLENDI","")
    var newTd2 = document.createElement('td');
    newTd2.innerHTML = '<div YENI_EKLENDI>'+PRICE+'</div>';
    newTd2.setAttribute("YENI_EKLENDI","")
     if (tds[7]) {
                tds[7].after(newTd);
                newTd.after(newTd2)
            }
    /*console.table(
        {
            WRK_ROW_ID,
            ROW_INDEX,
            PRICE,
            MARJ
        }
    )*/
  
}
    



</script>
