<script>
$(document).ready(function () {
    var att = document.getElementById("satinalma_teklifi").getAttribute("onclick")
    console.log(att)
    document.getElementById("satinalma_teklifi").setAttribute("onclick", "SanalKontrol()")
    document.getElementById("satinalma_teklifi").setAttribute("type", "button")
})
function SanalKontrol() {
    var SanalCount = 0;

    $(".ui-table-list > tbody > tr").each(function () {
        var $row = $(this);
        var checkbox = $row.find("input[type='checkbox'][name='internal_row_info']");

        if (checkbox.length > 0 && checkbox.is(":checked")) {
            var link = $row.find("td:nth-child(8) > a"); // 8. sütun: Ürün

            if (link.length > 0) {
                var onclickAttr = link.attr("onclick");
                var match = onclickAttr && onclickAttr.match(/pid=(\d+)/);
                if (match && parseInt(match[1]) === 1055) {
                    SanalCount++;
                    $row.css({
                    "background-color": "rgba(255, 0, 0, 0.2)",  // saydam kırmızı
                    "transition": "background-color 0.5s"
                });
                }
            }
        }
    });

    if (SanalCount > 0) {
        alert("Sanal Ürünler var");

    } else {
        document.getElementById("satinalma_teklifi").setAttribute("onclick", "control_action(5)")
        document.getElementById("satinalma_teklifi").click()
        //document.getElementById("satinalma_teklifi").setAttribute("type","submit")
    }
}
</script>