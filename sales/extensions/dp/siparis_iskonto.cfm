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
alternatifkontrol();;;





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
</script>
