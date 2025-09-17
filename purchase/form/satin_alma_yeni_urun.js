data = mergeCompanies(data);
var ww_data = data;

function getAktifTeklif(wrkRowId) {
    var AktifTeklif = null;
    for (let i = 0; i < ww_data.length; i++) {
        console.log(ww_data[i])
        var pr = ww_data[i].URUNLER
        console.log(pr)
        var px = pr.findIndex(p => p.WRK_ROW_ID == wrkRowId)
        console.log(px)
        if (px >= 0) {
            AktifTeklif = ww_data[i]
            break;
        }
    }
    return AktifTeklif;
}

var table = document.getElementById('price-table');
var output = document.getElementById('output');
const selectedCells = new Map();

const productSet = new Set();
const productInfoMap = new Map();
data.forEach(supplier => {
    supplier.URUNLER.forEach(product => {
        productSet.add(product.PRODUCT_ID); // PRODUCT_ID bazlı
        // PRODUCT_ID ve STOCK_ID'yi de sakla
        if (!productInfoMap.has(product.PRODUCT_ID)) {
            productInfoMap.set(product.PRODUCT_ID, {
                PRODUCT_ID: product.PRODUCT_ID,
                STOCK_ID: product.STOCK_ID,
                PRODUCT_NAME: product.PRODUCT_NAME // Gerekirse isim de sakla
            });
        }
    });
});
const uniqueProducts = Array.from(productSet); // Artık PRODUCT_ID listesi

const headerRow = document.createElement('tr');
headerRow.innerHTML = `<th class="sticky-header bg-success text-white">&Uuml;r&uuml;n</th><th class="sticky-header bg-success text-white">Urun Kodu</th><th class="sticky-header bg-success text-white">Oem No</th>`;
headerRow.innerHTML += `
  <th class="sticky-header bg-info text-white">
    Marj (%)<br>
    <input id="global-marj-input" onchange="setMarjAllRows(this)"  type="number" class="form-control form-control-sm" style="width:80px; margin-top:4px;" placeholder="Toplu">
  </th>
`;
headerRow.innerHTML += `<th class="sticky-header bg-info text-white">Son Satış Fiyatı (${DEMAND_MONEY})</th>`;
headerRow.innerHTML += `<th class="sticky-header bg-info text-white">Satış Fiyatı (${DEMAND_MONEY})</th>`;

data.forEach(supplier => {
    const th = document.createElement('th');
    th.className = "sticky-header bg-success text-white";
    th.innerHTML = `${supplier.FULLNAME}<br><small>ID: ${supplier.COMPANY_ID}</small>`;
    headerRow.appendChild(th);
});
const thead = document.createElement('thead');
const tbody = document.createElement('tbody');
thead.appendChild(headerRow);
table.appendChild(thead);

const cellElements = {};
const alternativeGroups = {};

data.forEach(supplier => {
    supplier.URUNLER.forEach(product => {
        const baseId = product.PRODUCT_ID;
        const altIds = (product.ALTERNATIFLER || []).map(a => a.PRODUCT_ID);
        const allIds = [baseId, ...altIds];

        // Bu gruptan herhangi birine atanmış renk var mı?
        let existingColor = allIds.find(id => alternativeGroups[id]);

        const groupColor = existingColor ? alternativeGroups[existingColor] : getRandomColor();

        allIds.forEach(id => {
            alternativeGroups[id] = groupColor;
        });
    });
})


uniqueProducts.forEach(productId => {
    // product bilgisi
    const urunBilgisi = productInfoMap.get(productId);
    const productName = urunBilgisi.PRODUCT_NAME;

    const rowHasSatinalma = data.some(supplier => {
        const p = supplier.URUNLER.find(u => u.PRODUCT_ID === productId);
        return p?.IS_SATINALMA === 1;
    });

    const rowHasOS = data.some(supplier => {
        const p = supplier.URUNLER.find(u => u.PRODUCT_ID === productId);
        return p?.IS_OS === false;
    })

    const row = document.createElement('tr');
    const productCell = document.createElement('td');
    productCell.innerHTML = `<a href="javascript:void(0)" onclick="window.open('http://qa.kdteknik.com.tr/index.cfm?fuseaction=objects.popup_product_price_history_js&sepet_process_type=2502&product_id=${urunBilgisi.PRODUCT_ID}&stock_id=${urunBilgisi.STOCK_ID}&pid=${urunBilgisi.PRODUCT_ID}&product_name=&unit=Adet&row_id=0&TL=1&USD=1.55&EUR=3','popup','width=800,height=600');">${productName}</a>`;
    productCell.className = 'product-name';
    row.appendChild(productCell);

    console.log("Ürün Adı", productName);

    const codeCell = document.createElement('td');

    // Tüm şirketlerde ürünü ara
    let productCode = "";
    for (const supplier of data) {
        const product = supplier.URUNLER.find(p => p.PRODUCT_ID === productId);
        if (product && product.PRODUCT_CODE_2) {
            productCode = product.PRODUCT_CODE_2;
            break; // İlk bulduğunda döngüyü kır
        }
    }

    let last_price = 0;
    for (const supplier of data) {
        const product = supplier.URUNLER.find(p => p.PRODUCT_ID === productId);
        if (product && product.LAST_PRICE) {
            last_price = product.LAST_PRICE;
            break; // İlk bulduğunda döngüyü kır
        }
    }

    codeCell.textContent = productCode || "N/A"; // Eğer bulunamazsa "N/A" yaz
    codeCell.className = 'product-code';
    row.appendChild(codeCell);
    // OEM No
    const oemCell = document.createElement('td');

    // Tüm şirketlerde ürünü ara
    let oemNo = "";
    for (const supplier of data) {
        const product = supplier.URUNLER.find(p => p.PRODUCT_ID === productId);
        if (product && product.OEM_NO) {
            oemNo = product.OEM_NO;
            break; // İlk bulduğunda döngüyü kır
        }
    }

    oemCell.textContent = oemNo || "N/A"; // Eğer bulunamazsa "N/A" yaz
    oemCell.className = 'product-oem';
    row.appendChild(oemCell);

    let slpInfo = {};
    for (const supplier of data) {
        const match = supplier.URUNLER.find(p => p.PRODUCT_ID === productId && p.SLP && p.SLP.length > 0);
        if (match) {
            slpInfo = match.SLP[0];
            break;
        }
    }
    const marjCell = document.createElement('td');
    const marjInput = document.createElement('input');
    marjInput.type = 'number';
    marjInput.value = slpInfo.PRODUCT_MARJ || 0;
    marjInput.className = 'form-control form-control-sm';
    marjInput.style.width = '80px';
    marjInput.dataset.product = productId; // productId eklendi
    marjCell.appendChild(marjInput);

    const lastPriceCell = document.createElement('td');
    lastPriceCell.setAttribute('data-hucre', "lastPriceCell");

    if (last_price === 0) {
        lastPriceCell.textContent = "-";
    } else {
        const currency = MONEYARRRR.find(c => c.MONEY === DEMAND_MONEY);
        const rate1 = parseFloat(currency?.RATE1 || 1);
        const rate2 = parseFloat(currency?.RATE2 || 1);

        const convertedLastPrice = (last_price * rate1) / rate2;
        lastPriceCell.textContent = convertedLastPrice.toFixed(2);
    }


    marjCell.appendChild(marjInput);

    const salePriceCell = document.createElement('td');
    salePriceCell.setAttribute('data-hucre', "salePriceCell");
    const salePriceInput = document.createElement('input');
    salePriceInput.type = 'text';
    console.log("slpInfo", slpInfo);
    salePriceInput.value = slpInfo.SALE_PRICE != null ? slpInfo.SALE_PRICE.toFixed(2) : "";
    salePriceInput.className = 'form-control form-control-sm sale-price-input';
    salePriceInput.style.width = '100px';
    salePriceInput.dataset.product = productId; // productName yerine productId

    salePriceCell.appendChild(salePriceInput);
    /*
    // input değişince hesapla
    marjInput.addEventListener('input', () => {
      const net = parseFloat(selectedCells.get(productName)?.split('|')[6]);
      const marj = parseFloat(marjInput.value);
      if (!isNaN(net) && !isNaN(marj)) {
        const calculatedSalePrice = net + (net * marj / 100);
        salePriceInput.value = calculatedSalePrice.toFixed(2);
      }
    });*/
    marjInput.addEventListener('input', () => {
        const selectedKey = selectedCells.get(productId);
        const net = parseFloat(selectedKey?.split('|')[6]);
        const marj = parseFloat(marjInput.value);
        var net2 = selectedKey?.split('|')[8];

        var At=getAktifTeklif(selectedKey?.split('|')[3]);
        console.log("Aktif Teklif", At)



        console.log("Net2", net2)
        var converted = 0;
        console.log(selectedCells);
        if (!isNaN(net) && !isNaN(marj)) {
            const calculatedSalePrice = net + (net * marj / 100);

            // Kur bilgisi için diğerMoney ve ilgili döviz kurları
            const otherMoney = selectedKey?.split('|')[9]; // 9. index = OTHER_MONEY
            const currency = At.OFFER_MONEY_ARR.find(c => c.MONEY_TYPE === DEMAND_MONEY);
            const rate1 = parseFloat(currency?.RATE1 || 1);
            const rate2 = parseFloat(currency?.RATE2 || 1);
            
                converted = (calculatedSalePrice * rate1) / rate2;
          

            salePriceInput.value = converted.toFixed(2);
        }
    });
    salePriceInput.addEventListener('change', () => {
        const selectedKey = selectedCells.get(productId);
        const salePrice = parseFloat(salePriceInput.value.replace(',', '.')) || 0;
        const otherMoney = selectedKey?.split('|')[9];
        const netPrice = parseFloat(selectedKey?.split('|')[6]);
        var At=getAktifTeklif(selectedKey?.split('|')[3]);
        const currency = At.OFFER_MONEY_ARR.find(c => c.MONEY_TYPE === DEMAND_MONEY);
        const rate1 = parseFloat(currency?.RATE1 || 1);
        const rate2 = parseFloat(currency?.RATE2 || 1);

        const convertedSalePrice = (salePrice * rate2) / rate1;

        //var sm=convertedSalePrice/(netPrice*100)
        var smx = convertedSalePrice - netPrice
        var smx2 = smx / netPrice;
        var smx3 = smx2 * 100
        // smx3=smx3.toFixed(2)
        marjInput.value = smx3
        console.table(
            {
                convertedSalePrice,
                smx,
                smx2,
                smx3,
                salePrice,
                netPrice
            }
        )
    });

    row.appendChild(marjCell);
    row.appendChild(lastPriceCell);
    row.appendChild(salePriceCell);


    cellElements[productId] = [];

    let lowestNetPrice = Infinity;
    data.forEach(supplier => {
        const product = supplier.URUNLER.find(p => p.PRODUCT_ID === productId);
        if (product && product.NET_PRICE < lowestNetPrice) {
            lowestNetPrice = product.NET_PRICE;
        }
    });

    data.forEach(supplier => {
        const product = supplier.URUNLER.find(p => p.PRODUCT_ID === productId);
        const cell = document.createElement('td');

        if (product) {
            const cmqurrency = MONEYARRRR.find(c => c.MONEY === DEMAND_MONEY);
            const cmqrate1 = parseFloat(cmqurrency?.RATE1 || 1);
            const cmqrate2 = parseFloat(cmqurrency?.RATE2 || 1);
            const cmqconvertedPrice = (parseFloat(product.NET_PRICE) / cmqrate2) * cmqrate1;
            // const cellKey = `${supplier.COMPANY_ID}|${product.PRODUCT_ID}|${product.PRICE}|${product.WRK_ROW_ID}|${product.DISCOUNT_1}|${product.QUANTITY}|${product.NET_PRICE}|${productName}`;
            const cellKey = `${supplier.COMPANY_ID}|${product.PRODUCT_ID}|${product.PRICE}|${product.WRK_ROW_ID}|${product.DISCOUNT_1}|${product.QUANTITY}|${product.NET_PRICE}|${product.TAX}|${product.PRICE_OTHER}|${product.OTHER_MONEY}|${DEMAND_MONEY}|${product.STOCK_ID}|${productName}|${product.IS_SELECTED || 0}|${product.IS_SATINALMA || 0}|${product.OEM_NO || ""}|${product.SELECT_INFO_EXTRA || 0}`;

            const priceDisplay = product.DISCOUNT_1 > 0
                ? `<div class="tooltip"><span class="price-original">${product.PRICE_OTHER.toFixed(2)} ${product.OTHER_MONEY}</span><span class="tooltiptext">İskonto: ${product.DISCOUNT_1}%</span></div>`
                : `<div><strong>${product.PRICE_OTHER.toFixed(2)} ${product.OTHER_MONEY}</strong></div>`;

            let netPriceHtml = `<div class=\"net-price\">Net: ${product.NET_PRICE.toFixed(2)} TL <div><strong>${cmqconvertedPrice.toFixed(2)} ${DEMAND_MONEY}</strong></div></div>`;

            if (DEMAND_MONEY == product.OTHER_MONEY) {
                console.log("Aynı para birimi", DEMAND_MONEY, product.OTHER_MONEY);
                netPriceHtml = `<div class=\"net-price\">Net: ${product.NET_PRICE.toFixed(2)} TL <div><strong>${product.PRICE_OTHER.toFixed(2)} ${DEMAND_MONEY}</strong></div></div>`;
            }

            if (product.NET_PRICE === lowestNetPrice) {
                netPriceHtml = `<div class=\"net-price\">⭐ Net: ${product.NET_PRICE.toFixed(2)} TL <div><strong>${cmqconvertedPrice.toFixed(2)} ${DEMAND_MONEY}</strong></div></div>`;
                if (DEMAND_MONEY == product.OTHER_MONEY) {
                    console.log("Aynı para birimi 2", DEMAND_MONEY, product.OTHER_MONEY);
                    netPriceHtml = `<div class=\"net-price\">⭐ Net: ${product.NET_PRICE.toFixed(2)} TL <div><strong>${product.PRICE_OTHER.toFixed(2)} ${DEMAND_MONEY}</strong></div></div>`;

                }
                cell.title = 'En iyi teklif' + product.WRK_ROW_ID;
            }

            cell.innerHTML = `
  ${priceDisplay}
  ${netPriceHtml}
  <div class="text-muted small">Iskonto: ${product.DISCOUNT_1}%</div>
  <div class="text-muted small">Adet: ${product.QUANTITY}</div>
  ${product.IS_SELECTED === 1 ? '<div class="text-primary fw-bold small">✅ Seçili </div>' : ''}
  ${product.IS_SATINALMA === 1 ? '<div class="text-danger fw-bold small">🚩 Satış Teklifinde</div>' : ''}
  ${product.SNT_S === 1 ? '<div class="text-success fw-bold small">💵 S.Alma Oluştu</div>' : ''}
  ${((product.IS_SATINALMA === 0 && product.IS_SELECTED === 1) && product.IS_OS === false)
                    ? '<div class="text-warning fw-bold small">⚠️ Satış Teklifinden Kaldırıldı</div>'
                    : ''}
  ${product.BASKET_INFO_TYPE ? `<div class="text-info fw-bold small"> ${product.BASKET_INFO_TYPE}</div>` : ''}  
`;

            if (product.IS_OS === false) {
                console.log("Ürün Satış Teklifine Dönmüşmüş", product.PRODUCT_NAME, product.IS_OS);
            }
            if (rowHasOS) {
                console.log("Satırda  Satış Teklifine Dönmüşmüş Ürün Var", product.PRODUCT_NAME, product.IS_OS);
            }

            const bgColor = alternativeGroups[product.PRODUCT_ID];
            if (bgColor) {
                //cell.style.backgroundColor = bgColor;
            }

            if (product.IS_SATINALMA === 1) {
                // $("#send-btn").hide();
                // $("#send-btn3").hide();
            }
            if (!rowHasSatinalma && !rowHasOS) {
                cell.classList.add('selectable');
                cell.dataset.key = cellKey;

                cell.addEventListener('click', () => {
                    cellElements[productId].forEach(c => {
                        const icon = c.querySelector('div.check-icon');
                        if (icon) icon.remove();
                    });
                    const checkIcon = document.createElement('div');
                    checkIcon.className = 'check-icon text-success';
                    checkIcon.innerHTML = '✔️';
                    cell.appendChild(checkIcon);
                    selectedCells.set(productId, cellKey);
                    updateOutput();
                    updateBestSupplier();
                });

                if (product.IS_SELECTED === 1) {
                    if (product.IS_OS === true) {
                        if (!rowHasOS) {
                            const checkIcon = document.createElement('div');
                            checkIcon.className = 'check-icon text-success';
                            checkIcon.innerHTML = '✔️';
                            cell.appendChild(checkIcon);
                            selectedCells.set(productId, cellKey);
                        }
                        else {
                            cell.style.pointerEvents = 'none';
                            cell.style.opacity = '0.8';
                            cell.title = 'Bu ürün için satın alma yapılmış. Seçim yapılamaz.';
                        }
                    } else {
                        cell.style.pointerEvents = 'none';
                        cell.style.opacity = '0.8';
                        cell.title = 'Bu ürün için satın alma yapılmış. Seçim yapılamaz.';
                    }
                }
            } else {
                cell.style.pointerEvents = 'none';
                cell.style.opacity = '0.8';
                cell.title = 'Bu ürün için satın alma yapılmış. Seçim yapılamaz.';
            }
            cell.dataset.product = productId;

            cell.addEventListener('click', () => {
                cellElements[productId].forEach(c => {
                    const icon = c.querySelector('div.check-icon');
                    if (icon) icon.remove();
                });
                const checkIcon = document.createElement('div');
                checkIcon.className = 'check-icon text-success';
                checkIcon.innerHTML = '✔️';
                cell.appendChild(checkIcon);
                selectedCells.set(productId, cellKey);
                updateOutput();
                updateBestSupplier();

            });

            cellElements[productId].push(cell);
            if (product.IS_SELECTED === 1) {
                if (product.IS_OS === true) {
                    const checkIcon = document.createElement('div');
                    checkIcon.className = 'check-icon text-success';
                    checkIcon.innerHTML = '✔️';
                    cell.appendChild(checkIcon);
                    selectedCells.set(productId, cellKey);
                }
            }
        } else {
            cell.className = 'no-data';
            cell.textContent = "-";
        }

        row.appendChild(cell);
    });
    tbody.appendChild(row)
    table.appendChild(tbody);



});

function updateOutput() {
    const grouped = {};
    selectedCells.forEach((key, productId) => {
        const [companyId, productIdStr, price, wrkRowId, discount1, quantity, netPrice, tax, priceOther, otherMoney, demandMoney, stockId, isSatinalma, yyy, xxx, oemNo, selectInfoExtra] = key.split('|');
        if (!grouped[companyId]) {
            grouped[companyId] = {
                companyId: parseInt(companyId),
                products: []
            };
        }
        // productName'i productInfoMap'ten al
        const urunBilgisi = productInfoMap.get(productId);
        const productName = urunBilgisi?.PRODUCT_NAME || "";

        const marjInput = document.querySelector(`input[type="number"][data-product="${productId}"]`);
        const salePriceInput = document.querySelector(`input.sale-price-input[data-product="${productId}"]`);

        let productMarj = 0;
        let salePrice = 0;

        if (marjInput) {
            productMarj = parseFloat(marjInput.value) || 0;
        }

        if (salePriceInput) {
            salePrice = parseFloat(salePriceInput.value) || 0;
        }
        let convertedsalePriceOther = 0;
        try {
            const currency = MONEYARRRR.find(c => c.MONEY === demandMoney);
            const rate1 = parseFloat(currency?.RATE1 || 1);
            const rate2 = parseFloat(currency?.RATE2 || 1);
            convertedsalePriceOther = (parseFloat(salePrice) * rate2) / rate1;
        } catch (e) {
            console.error("Hata:", e);
            convertedPriceOther = 0;
        }
        grouped[companyId].products.push({
            productId: parseInt(productIdStr),
            stockId: parseInt(stockId),
            price: parseFloat(price),
            wrkRowId,
            discount1: parseFloat(discount1),
            quantity: parseFloat(quantity),
            netPrice: parseFloat(netPrice),
            tax: parseFloat(tax),
            priceOther: parseFloat(priceOther),
            otherMoney: otherMoney,
            productName: productName,
            isSatinalma: parseInt(isSatinalma),
            productMarj: productMarj,
            salePrice: parseFloat(salePrice.toFixed(2)),
            convertedsalePriceOther: parseFloat(convertedsalePriceOther.toFixed(2)),
            demandMoney: demandMoney,
            oemNo: oemNo,
            xxx: xxx,
            yyy: yyy,
            selectInfoExtra: selectInfoExtra,
        });
    });
    const groupedArray = Object.values(grouped);
    output.textContent = JSON.stringify(groupedArray, null, 2);
    return groupedArray;
}

function updateBestSupplier() {
    const supplierTotals = {};
    console.log(data);
    ww_data.forEach(supplier => {
        const productIds = supplier.URUNLER.map(p => p.PRODUCT_ID);
        const hasAllProducts = uniqueProducts.every(pid => productIds.includes(pid));
        if (!hasAllProducts) return;
        let total = 0;
        supplier.URUNLER.forEach(product => {
            if (product.NET_PRICE > 0) {
                total += product.NET_PRICE;
            }
        });
        if (total > 0) {
            supplierTotals[supplier.FULLNAME] = total;
        }
    });
    const [bestSupplierName, bestTotal] = Object.entries(supplierTotals).sort((a, b) => a[1] - b[1])[0] || ["Belirlenemedi", 0];
    document.getElementById('best-supplier').textContent = `En iyi fiyat veren tedarikçi: ${bestSupplierName} (Toplam: ${bestTotal.toFixed(2)} TL)`;
}

window.setMarjAllRows = function (el) {
    const newMarj = parseFloat(el.value) || 0;
    document.querySelectorAll('td input[type="number"]').forEach(input => {
        input.value = newMarj;
        input.dispatchEvent(new Event('input')); // satış fiyatını güncelle
    });
};

function getRandomColor() {
    const letters = '0123456789ABCDEF';
    let color = '#';
    for (let i = 0; i < 6; i++) {
        color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
}

document.getElementById('send-btn3').addEventListener('click', () => {
    updateOutput();
    const payload = updateOutput(); // Ensure payload is generated correctly
    console.log("Sunucuya gönderilecek veri:", payload);
    var offer_id = document.getElementById("offer_id").value;
    var BEI = 0;
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
                //window.location.reload(); // Refresh the page to see changes;
            } else if (data.RES === "error") {
                alert("Bir hata oluştu!");
            }
        })
        .catch(error => {
            console.error("Hata:", error);
            alert("Sunucuya bağlanırken bir hata oluştu!");
        });
});


updateBestSupplier();

function SatinalmaSiparis(params, last_offer_id) {
    /* $.ajax({
       url: '/AddOns/Partner/purchase/cfc/purchase_Service.cfc?method=SAVEORDER_gpt&internal_id='+params,
       type: 'POST',
       
       success: function (response) {
         // Başarılı yanıt alındığında yapılacak işlemler
         console.log(response);
       },
       error: function (error) {
         // Hata durumunda yapılacak işlemler
         console.error(error);
       }
     }).always(function() {
       // Her durumda çalışacak kod (başarılı veya hata)
       console.log("İşlem tamamlandı.");
     });*/

    fetch('/AddOns/Partner/purchase/cfc/purchase_service.cfc?method=SAVEORDER_gpt&last_offer_id=' + last_offer_id + '&internal_id=' + params, { // Correct endpoint
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

