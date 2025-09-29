function checkSerial(input, event) {
    if (event.key === 'Enter') {
        var serialNo = input.value.trim();
        if (serialNo === '') {
            alert('Seri No boş olamaz.');

            return;
        }
        if (parser === '') {
            alert('Barkod Türü Seçmediniz Lütfen Sayfayı Yenileyiniz.');
            return;
        }
        var product_code_2 = "";
        var serial_no;
        var uretim_tarihi = "";
        var paketleme_tarihi = "";
        if (parser == 1) {

        } if (parser == 2) {
            product_code_2 = serialNo.split("_")[0] //Eta Kodu
            serial_no = serialNo.split("_")[1] //Seri No
            uretim_tarihi = serialNo.split("_")[2] //Üretim Tarihi
            paketleme_tarihi = serialNo.split("_")[3] //Paketleme Tarihi
            console.table({ product_code_2, serial_no, uretim_tarihi, paketleme_tarihi });
            var row = document.querySelector(`tr[data-product_code_2="${product_code_2}"]`);
            var totalQuantity = parseInt(row.children[1].innerText);
            console.log("Bulunan Satır:", row);
            var smc = parseInt(row.lastElementChild.innerText);
            if (row) {
                console.log("Satır bulundu, seri numarası ekleniyor.");
                var wrk_row_id = row.getAttribute('data-wrk_row_id');
                var product_id = row.getAttribute('data-product_id');
                var stock_id = row.getAttribute('data-stock_id');
                var tr = document.createElement("tr");
                var td = document.createElement("td");
                td.innerText = serial_no;
                tr.appendChild(td);
                var serialsTable = document.getElementById('serials_' + product_id);
                var rws = serialsTable.getElementsByTagName("tr").length;
                for (let index = 0; index < rws; index++) {
                    const element = serialsTable.getElementsByTagName("tr")[index];
                    var existingSerialNo = element.firstChild.innerText;
                    console.log("Bulunan Seri No:", element.firstChild.innerText);
                    if (existingSerialNo === serial_no) {
                        alert('Bu Seri No Daha Önce Girilmiştir.');
                        input.value = ''; // Giriş alanını temizle
                        return;
                    }







                    if (serialsTable) {

                        serialsTable.appendChild(tr);
                    }


                }
                smc++
                row.lastElementChild.innerText = smc;
                if (smc > totalQuantity) {
                    row.lastElementChild.setAttribute("style", "background:ff00008a;font-weight:bold");
                    input.value = ''; // Giriş alanını temizle
                } else if (smc == totalQuantity) {
                    row.lastElementChild.setAttribute("style", "background:#00800063;font-weight:bold");
                    input.value = ''; // Giriş alanını temizle
                } else {
                    row.lastElementChild.setAttribute("style", "background:#0079ff70;font-weight:bold;font-weight:bold");
                    input.value = ''; // Giriş alanını temizle
                }
            }

        }


        // Burada seri numarasını doğrulama ve ekleme işlemlerini yapabilirsiniz.
        // Örneğin, AJAX ile sunucuya gönderip kontrol edebilirsiniz.
        console.log('Girilen Seri No:', serialNo);
        input.value = ''; // Giriş alanını temizle
    }
}