document.getElementById('send-btn').addEventListener('click', () => {
    if (!sifirKontrl()) {
        return;
    }
    const payload = updateOutput(); // Ensure payload is generated correctly
    console.log("Sunucuya gönderilecek veri:", payload);
    var offer_id = document.getElementById("offer_id").value;

    fetch('/AddOns/Partner/purchase/cfc/purchase_service.cfc?method=savePurchaseOfferSelector', { // Correct endpoint
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ payload, offer_id, session_variables }) // Include offer_id in the payload
    })
        .then(response => response.json())
        .then(data => {
            if (data.RES === "success") {
                alert("İşlem başarılı!");
                window.location.reload(); // Refresh the page to see changes;
            } else if (data.RES === "error") {
                alert("Bir hata oluştu!");
            }
        })
        .catch(error => {
            console.error("Hata:", error);
            alert("Sunucuya bağlanırken bir hata oluştu!");
        });
});

document.getElementById('send-btn3').addEventListener('click', () => {
    updateOutput();
    const payload = updateOutput(); // Ensure payload is generated correctly
    console.log("Sunucuya gönderilecek veri:", payload);
    var offer_id = document.getElementById("offer_id").value;
    var BEI = 3;
    //return false; // Prevent default action for this button
    fetch('/AddOns/Partner/purchase/cfc/purchase_service.cfc?method=savePurchaseOfferSelectorOnly', { // Correct endpoint
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ payload, offer_id, session_variables, BEI }) // Include offer_id in the payload
    })
        .then(response => response.json())
        .then(data => {
            if (data.RES === "success") {
                alert("İşlem başarılı!");
                AjaxPageLoad("index.cfm?fuseaction=sales.ajax_list_pbs_offer_purchases_1&INTERNAL_ID=" + offer_id, "ShownArea", 1, "Yükleniyor")
            } else if (data.RES === "error") {
                alert("Bir hata oluştu!");
            }
        })
        .catch(error => {
            console.error("Hata:", error);
            alert("Sunucuya bağlanırken bir hata oluştu!");
        });
});
$(document).on("click", "#price-table > tbody > tr > td > span", function () {
    var $span = $(this);
    var currentValue = $span.text();
    var $input = $("<input type='text' class='price-editor'>").val(currentValue);

    $span.replaceWith($input);
    $input.focus();

    $input.on("blur", function () {
        var newValue = $input.val();
        $input[0].dispatchEvent(new Event('input')); // satış fiyatını güncelle
        var $newSpan = $("<span>").text(commaSplit(newValue));
        $input.replaceWith($newSpan);
    });

    // İsteğe bağlı: Enter tuşuna basıldığında da blur çalışsın
    $input.on("keydown", function (e) {
        if (e.key === "Enter") {
            $(this).blur();
        }
    });
});