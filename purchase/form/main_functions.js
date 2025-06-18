function mergeCompanies(data) {
    const result = [];

    data.forEach(entry => {
        const existing = result.find(c => c.COMPANY_ID === entry.COMPANY_ID);

        if (existing) {
            existing.URUNLER = existing.URUNLER.concat(entry.URUNLER);
        } else {
            result.push({
                FULLNAME: entry.FULLNAME,
                COMPANY_ID: entry.COMPANY_ID,
                URUNLER: [...entry.URUNLER]
            });
        }
    });

    return result;
}

document.getElementById('send-btn').addEventListener('click', () => {
    if (!sifirKontrl()) {
        return;
    }
    const payload = updateOutput(); // Ensure payload is generated correctly
    console.log("Sunucuya gönderilecek veri:", payload);
    var offer_id = document.getElementById("offer_id").value;

    fetch('/AddOns/Partner/purchase/cfc/purchase_service.cfc?method=saveSaleOfferFromSelectedRows', { // Correct endpoint
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ offer_id, session_variables }) // Include offer_id in the payload
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

function sifirKontrl() {
    return true;
}


function SecimKontrol() {
    var UniqueProduct = [];
    var tx = 0;
    for (const supplier of data) {
        //    console.log(supplier)
        var urunler = supplier.URUNLER;
        for (const urun of urunler) {
            //  console.log(urun)
            if (UniqueProduct.findIndex(p => p.PRODUCT_ID == urun.PRODUCT_ID) == -1) {
                console.log(urun)
                UniqueProduct.push(urun)
            }
        }
    }


    var ux = updateOutput()
    var PL = 0;
    for (var u of ux) {
        PL += u.products.length
    }
    console.log("PL", PL);
    console.log("data", data);
    console.log("UniqueProduct.length", UniqueProduct.length);
    
    console.log("UniqueProduct", UniqueProduct);
    console.log("ux", ux);

    if (!(UniqueProduct.length == PL)) {
        var T = confirm("Seçilmemiş Ürünler Var", "Yinede Devam Et");
        return T
    }
}