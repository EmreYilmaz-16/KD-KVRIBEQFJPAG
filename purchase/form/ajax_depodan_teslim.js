function SatinalmaSiparis(params) {


    fetch('/AddOns/Partner/purchase/cfc/purchase_service.cfc?method=SAVEORDER_gpt&internal_id=' + params, { // Correct endpoint
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
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
}