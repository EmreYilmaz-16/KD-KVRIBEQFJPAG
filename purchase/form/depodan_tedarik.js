
function getConvertedNetPriceWithMarj(productId, marj = 0) {
    let net = 0;
    let gpa_money = "";
    for (const supplier of data) {
        const product = supplier.URUNLER.find(p => p.PRODUCT_ID === productId);
        if (product && product.NET_PRICE) {
            net = product.NET_PRICE;
            gpa_money = product.GPA_MONEY;
            break;
        }
    }

    const netWithMarj = net + (net * marj / 100);

    const currency = MONEYARRRR.find(c => c.MONEY === DEMAND_MONEY);
    let rate1 = 1;
    let rate2 = 1;
    if (DEMAND_MONEY != gpa_money) {

        rate1 = parseFloat(currency?.RATE1 || 1);
        rate2 = parseFloat(currency?.RATE2 || 1);
    }
    const converted = (netWithMarj * rate1) / rate2;

    return converted.toFixed(2);
}

function applyDiscounts(basePrice, d1 = 0, d2 = 0, d3 = 0) {
    let price = basePrice;
    price *= (1 - d1 / 100);
    price *= (1 - d2 / 100);
    price *= (1 - d3 / 100);
    return price;
}

function calculateFinalSalePrice(productId) {
    console.log("Calculating final sale price for product ID:", productId);
    const selectedKey = selectedCells.get(productId);
    if (!selectedKey) return;

    const net = parseFloat(selectedKey?.split('|')[6]);
    console.log("Net Price Extracted:", net);
    const gpaPrice = parseFloat(selectedKey?.split('|')[16]);
    const gpaPrice1 = parseFloat(selectedKey?.split('|')[17]);
    const gpaMoney = selectedKey?.split('|')[18];
    console.log("Selected Key:", selectedKey);
    console.log("Net Price:", net);
    console.log("GPA Price:", gpaPrice);
    console.log("GPA Price 1:", gpaPrice1);
    console.log("GPA Money:", gpaMoney);
    console.log("Demand Money:", DEMAND_MONEY);


    if (isNaN(net) || net === 0) return;
    if (isNaN(gpaPrice1) || gpaPrice1 === 0) return;


    const currency = MONEYARRRR.find(c => c.MONEY === DEMAND_MONEY);
    let rate1 = 1;
    let rate2 = 1;

    if (DEMAND_MONEY != gpaMoney) {
        rate1 = parseFloat(currency?.RATE1 || 1);
        rate2 = parseFloat(currency?.RATE2 || 1);
    }
    // İlgili inputları bul
    const row = [...document.querySelectorAll('td.product-name')].find(td => td.dataset.productid == productId)?.parentElement;
    if (!row) return;

    const marjInput = row.querySelector('input.marj-input');
    const dsc1Input = row.querySelector('input.dsc1-input');
    const dsc2Input = row.querySelector('input.dsc2-input');
    const dsc3Input = row.querySelector('input.dsc3-input');
    const salePriceInput = row.querySelector('input.sale-price-input');

    const marj = parseFloat(marjInput?.value) || 0;
    const d1 = parseFloat(dsc1Input?.value) || 0;
    const d2 = parseFloat(dsc2Input?.value) || 0;
    const d3 = parseFloat(dsc3Input?.value) || 0;

    // Marj + kur dönüşümü
    const base = net + (net * marj / 100);
    const converted = (base * rate1) / rate2;

    // İskontolar
    const final = applyDiscounts(converted, d1, d2, d3);

    salePriceInput.value = final.toFixed(2);
}

function calculateMarjFromSalePrice(productId) {
    const selectedKey = selectedCells.get(productId);
    if (!selectedKey) return;

    const net = parseFloat(selectedKey?.split('|')[6]);
    if (isNaN(net) || net === 0) return;

    const currency = MONEYARRRR.find(c => c.MONEY === DEMAND_MONEY);
    const rate1 = parseFloat(currency?.RATE1 || 1);
    const rate2 = parseFloat(currency?.RATE2 || 1);

    // İlgili inputları bul
    const row = [...document.querySelectorAll('td.product-name')].find(td => td.dataset.productid == productId)?.parentElement;
    if (!row) return;

    const salePriceInput = row.querySelector('input.sale-price-input');
    const marjInput = row.querySelector('input.marj-input');

    const d1 = parseFloat(row.querySelector('input.dsc1-input')?.value) || 0;
    const d2 = parseFloat(row.querySelector('input.dsc2-input')?.value) || 0;
    const d3 = parseFloat(row.querySelector('input.dsc3-input')?.value) || 0;

    let salePrice = parseFloat(salePriceInput?.value.replace(',', '.')) || 0;

    // Önce iskonto etkisini geri al
    let grossSalePrice = salePrice;
    if (d1 || d2 || d3) {
        grossSalePrice = salePrice / ((1 - d1 / 100) * (1 - d2 / 100) * (1 - d3 / 100));
    }

    // Kur geri dönüşümü
    const original = (grossSalePrice * rate2) / rate1;

    // Marj hesapla
    const marj = ((original / net) - 1) * 100;
    marjInput.value = marj.toFixed(2);

    console.table({
        net,
        grossSalePrice,
        original,
        marj
    });
}



// script.js - Ayrılmış JavaScript dosyası
// Bu dosya, JavaScript kodunu içerir ve HTML'den ayrıdır
// Bu dosya, HTML'den ayrılmıştır ve daha iyi bir yapı sağlar
// Ayrılmış JavaScript dosyası, HTML'den bağımsız olarak çalışabilir
// Ayrılmış JavaScript dosyası, HTML'den bağımsız olarak çalışabilir

data = mergeCompanies(data);
var ww_data = data;

// script.js - Ayrılmış JavaScript dosyası

const table = document.getElementById('price-table');
const output = document.getElementById('output');
const selectedCells = new Map();

const productSet = new Set();
const productInfoMap = new Map();
data.forEach(supplier => {
    supplier.URUNLER.forEach(product => {
        productSet.add(product.PRODUCT_ID); // PRODUCT_NAME yerine PRODUCT_ID
        // PRODUCT_ID ve STOCK_ID'yi de sakla
        if (!productInfoMap.has(product.PRODUCT_ID)) {
            productInfoMap.set(product.PRODUCT_ID, {
                PRODUCT_NAME: product.PRODUCT_NAME,
                STOCK_ID: product.STOCK_ID
            });
        }
    });
});
const uniqueProducts = Array.from(productSet);

const headerRow = document.createElement('tr');
headerRow.innerHTML = `<th class="sticky-header bg-success text-white">&Uuml;r&uuml;n</th><th class="sticky-header bg-success text-white">Urun Kodu</th><th class="sticky-header bg-success text-white">Oem No</th>`;
headerRow.innerHTML += `
  <th class="sticky-header bg-info text-white">
    Marj (%)<br>
    <input id="global-marj-input" onchange="setMarjAllRows(this)"  type="number" class="form-control form-control-sm" style="width:80px; margin-top:4px;" placeholder="Toplu">
  </th>
  <th>İskonto 1 (%)<br>
    <input id="global-dsc1-input" onchange="setAllDsc1Rows(this)"  type="number" class="form-control form-control-sm" style="width:80px; margin-top:4px;" placeholder="Toplu">
    
    </th>
  <th>İskonto 2
    (%)<br>
    <input id="global-dsc2-input" onchange="setAllDsc2Rows(this)"  type="number" class="form-control form-control-sm" style="width:80px; margin-top:4px;" placeholder="Toplu">
    </th>
  <th>İskonto 3
    (%)<br>
    <input id="global-dsc3-input" onchange="setAllDsc3Rows(this)"  type="number" class="form-control form-control-sm" style="width:80px; margin-top:4px;" placeholder="Toplu">
    </th>
`;
headerRow.innerHTML += `<th class="sticky-header bg-info text-white">Son Satış Fiyatı (${DEMAND_MONEY})</th>`;
headerRow.innerHTML += `<th class="sticky-header bg-info text-white">Satış Fiyatı (${DEMAND_MONEY})</th>`;
headerRow.innerHTML += `<th class="sticky-header bg-info text-white">Liste Fiyatı (${DEMAND_MONEY})</th>`;

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
    productCell.innerHTML = `<a href="javascript:void(0)" onclick="window.open('http://qa.kdteknik.com.tr/index.cfm?fuseaction=objects.popup_product_price_history_js&sepet_process_type=2502&product_id=${productId}&stock_id=${urunBilgisi.STOCK_ID}&pid=${productId}&product_name=&unit=Adet&row_id=0&TL=1&USD=1.55&EUR=3','popup','width=800,height=600');">${productName}</a>`;
    productCell.className = 'product-name';
    productCell.dataset.productid = productId;
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
    codeCell.textContent = productCode || "-"; // Eğer kod bulunamazsa "-" göster
    codeCell.className = 'product-code';
    codeCell.dataset.productid = productId;
    row.appendChild(codeCell);
     var brandcell = document.createElement('td');
    // Marka
    let brandName = "";
    for (const supplier of data) {
        const product = supplier.URUNLER.find(p => p.PRODUCT_ID === productId);
        if (product && product.BRAND_NAME) {
            brandName = product.BRAND_NAME;
            break; // İlk bulduğunda döngüyü kır
        }
    }
    brandcell.textContent = brandName || "-"; // Eğer marka bulunamazsa "-" göster
    brandcell.className = 'product-brand';
    brandcell.dataset.productid = productId;
    row.appendChild(brandcell);

    // Son fiyat
    let last_price = 0;
    for (const supplier of data) {
        const product = supplier.URUNLER.find(p => p.PRODUCT_ID === productId);
        if (product && product.LAST_PRICE) {
            last_price = product.LAST_PRICE;
            break; // İlk bulduğunda döngüyü kır
        }
    }

    let listPrice = 0;
    let convertedListPrice = 0;
    let listMoney = "";
    let listPriceCell = document.createElement('td');
    listPriceCell.className = 'product-list-price';
    listPriceCell.dataset.productid = productId;
    listPriceCell.textContent = "-";
    // Varsayılan olarak boş göster
    for (const supplier of data) {
        const product = supplier.URUNLER.find(p => p.PRODUCT_ID === productId);
        console.log("Liste Fiyatı Kontrol Ediliyor:", productId, product);
        if (product && product.GPA_PRICE) {
            listPrice = product.GPA_PRICE;
            const currency = MONEYARRRR.find(c => c.MONEY === DEMAND_MONEY);
            let rate1 = 1;
            let rate2 = 1;
            if (product.GPA_MONEY != DEMAND_MONEY) {
                rate1 = parseFloat(currency?.RATE1 || 1);
                rate2 = parseFloat(currency?.RATE2 || 1);
            } else {
                rate1 = 1;
                rate2 = 1;
            }


            convertedListPrice = product.NET_PRICE / rate2;
            listMoney = product.GPA_MONEY;
            //listPriceCell.textContent = convertedListPrice.toFixed(2) + " " + listMoney;
            listPriceCell.innerHTML = `<div><span class="list-price-value">${listPrice.toFixed(2)}</span> <span class="list-price-money">${listMoney}</span></div>
            <div><span class="list-price-value">${convertedListPrice.toFixed(2)}</span> <span class="list-price-money">${DEMAND_MONEY}</span></div>`;

            break; // İlk bulduğunda döngüyü kır
        }
    }


    const oemCell = document.createElement('td');
    // OEM No
    let oemNo = "";
    for (const supplier of data) {
        const product = supplier.URUNLER.find(p => p.PRODUCT_ID === productId);
        if (product && product.OEM_NO) {
            oemNo = product.OEM_NO;
            break; // İlk bulduğunda döngüyü kır
        }
    }
    oemCell.textContent = oemNo || "-"; // Eğer OEM No bulunamazsa "-" göster
    oemCell.className = 'product-oem';
    oemCell.dataset.productid = productId;
    row.appendChild(oemCell);

    // SLP info
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
    marjInput.className = 'form-control form-control-sm marj-input';
    marjInput.style.width = '80px';
    marjCell.appendChild(marjInput);

    const dsc1Cell = document.createElement('td');
    const dsc1Input = document.createElement('input');
    dsc1Input.type = 'number';
    let productInfo = null;
for (const supplier of data) {
    productInfo = supplier.URUNLER.find(p => p.PRODUCT_ID === productId);
    if (productInfo) break;
}
    if (slpInfo.DSC1) {
        dsc1Input.value = slpInfo.DSC1 || 0; //#TODO: Burası İskonto 1 Kontrol Edecek Tabloya EKlenecek
    } else {
        dsc1Input.value = productInfo.DSC_OX || 0;
    } //#TODO: Burası İskonto 1 Kontrol Edecek Tabloya EKlenecek
    dsc1Input.className = 'form-control form-control-sm dsc1-input';
    dsc1Input.style.width = '80px';
    dsc1Cell.appendChild(dsc1Input);

    const dsc2Cell = document.createElement('td');
    const dsc2Input = document.createElement('input');
    dsc2Input.type = 'number';
   // dsc2Input.value = slpInfo.DSC2 || 0; //#TODO: Burası İskonto 2 Kontrol Edecek Tabloya EKlenecek
    if (slpInfo.DSC2) {
        dsc2Input.value = slpInfo.DSC2 || 0; //#TODO: Burası İskonto 2 Kontrol Edecek Tabloya EKlenecek
    } else {
        dsc2Input.value = productInfo.DSC_OX2 || 0;
    } 
   
   dsc2Input.className = 'form-control form-control-sm dsc2-input';
    dsc2Input.style.width = '80px';
    dsc2Cell.appendChild(dsc2Input);


    const dsc3Cell = document.createElement('td');
    const dsc3Input = document.createElement('input');
    dsc3Input.type = 'number';
    dsc3Input.value = slpInfo.DSC3 || 0; //#TODO: Burası İskonto 3 Kontrol Edecek Tabloya EKlenecek
    dsc3Input.className = 'form-control form-control-sm dsc3-input';
    dsc3Input.style.width = '80px';
    dsc3Cell.appendChild(dsc3Input);

    const lastPriceCell = document.createElement('td');
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
    const salePriceInput = document.createElement('input');
    salePriceInput.type = 'text';

    if (1 === 1) {
        // Tek tedarikçi varsa, marj ve kur dönüşümü ile hesapla
        const marj = parseFloat(slpInfo.PRODUCT_MARJ || 0);
        salePriceInput.value = getConvertedNetPriceWithMarj(productId, marj);

    } else {
        // Çoklu tedarikçi varsa, son satış fiyatını kullan
        salePriceInput.value = slpInfo.SALE_PRICE != null ? slpInfo.SALE_PRICE.toFixed(2) : "";
    }


    salePriceInput.className = 'form-control form-control-sm sale-price-input';
    salePriceInput.style.width = '100px';
    salePriceInput.dataset.productid = productId;

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
        calculateFinalSalePrice(productId);
    });


    dsc1Input.addEventListener('input', () => {
        calculateFinalSalePrice(productId);
    });
    dsc2Input.addEventListener('input', () => {
        calculateFinalSalePrice(productId);
    });
    dsc3Input.addEventListener('input', () => {
        calculateFinalSalePrice(productId);
    });





    salePriceInput.addEventListener('change', () => {
        calculateMarjFromSalePrice(productId);
    });

    row.appendChild(marjCell);
    row.appendChild(dsc1Cell);
    row.appendChild(dsc2Cell);
    row.appendChild(dsc3Cell);
    row.appendChild(lastPriceCell);
    row.appendChild(salePriceCell);
    row.appendChild(listPriceCell);


    cellElements[productId] = [];

    let lowestNetPrice = Infinity;
    data.forEach(supplier => {
        const product = supplier.URUNLER.find(p => p.PRODUCT_ID === productId);
        if (product && product.ONET_PRICE_2 < lowestNetPrice) {
            lowestNetPrice = product.ONET_PRICE_2;
        }
    });

    // Tek tedarikçi kontrolü - bu ürün için kaç tedarikçi var?
    const suppliersWithThisProduct = data.filter(supplier =>
        supplier.URUNLER.find(p => p.PRODUCT_ID === productId)
    );
    const isSingleSupplier = suppliersWithThisProduct.length === 1;

    data.forEach(supplier => {
        const product = supplier.URUNLER.find(p => p.PRODUCT_ID === productId);
        const cell = document.createElement('td');

        if (product) {
            console.log("Ürün Bulundu:", product, "Tedarikçi:", supplier.FULLNAME);
            const cmqurrency = MONEYARRRR.find(c => c.MONEY === DEMAND_MONEY);
            const cmqrate1 = parseFloat(cmqurrency?.RATE1 || 1);
            const cmqrate2 = parseFloat(cmqurrency?.RATE2 || 1);
            const cmqconvertedPrice = (parseFloat(product.ONET_PRICE_2) / cmqrate2) * cmqrate1;
            // const cellKey = `${supplier.COMPANY_ID}|${product.PRODUCT_ID}|${product.PRICE}|${product.WRK_ROW_ID}|${product.DISCOUNT_1}|${product.QUANTITY}|${product.NET_PRICE}|${productName}`;
            const cellKey = `${supplier.COMPANY_ID}|${product.PRODUCT_ID}|${product.PRICE}|${product.WRK_ROW_ID}|${product.DISCOUNT_1}|${product.QUANTITY}|${product.NET_PRICE}|${product.TAX}|${product.PRICE_OTHER}|${product.OTHER_MONEY}|${DEMAND_MONEY}|${product.STOCK_ID}|${product.PRODUCT_ID}|${product.IS_SELECTED || 0}|${product.IS_SATINALMA || 0}|${product.OEM_NO || ""}|${product.SELECT_INFO_EXTRA || 0}|${product.GPA_PRICE || 0}|${product.GPA_MONEY || ""}`;

            const priceDisplay = product.DISCOUNT_1 > 0
                ? `<div class="tooltip"><span class="price-original">${product.PRICE_OTHER.toFixed(2)} ${product.OTHER_MONEY}</span><span class="tooltiptext">İskonto: ${product.DISCOUNT_1}%</span></div>`
                : `<div><strong>${product.PRICE_OTHER.toFixed(2)} ${product.OTHER_MONEY}</strong></div>`;
            var netPriceHtml = "";
            console.log("Lowest Net Price for Product ID", productId, "is", lowestNetPrice);
            if (product.ONET_PRICE_2 > 0) {
                netPriceHtml = `<div class=\"net-price\">Net: ${product.ONET_PRICE_2.toFixed(2)} TL <div><strong>${cmqconvertedPrice.toFixed(2)} ${DEMAND_MONEY}</strong></div></div>`;
                if (product.ONET_PRICE_2 === lowestNetPrice) {
                    netPriceHtml = `<div class=\"net-price\">⭐ Net: ${product.ONET_PRICE_2.toFixed(2)} TL <div><strong>${cmqconvertedPrice.toFixed(2)} ${DEMAND_MONEY}</strong></div></div>`;
                    cell.title = 'En iyi teklif' + product.WRK_ROW_ID;
                }
            } else {
                netPriceHtml = `<div class=\"net-price invalid\">Net: - TL <div><strong>-</strong> Fiyat Listesinde Bulunamadı</div></div>`;
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
                //  $("#send-btn3").hide();
            }
            if (!rowHasSatinalma && !rowHasOS) {
                cell.classList.add('selectable');
                cell.dataset.key = cellKey;

                cell.addEventListener('click', () => {
                    // cellElements[productName].forEach(c => { ... }) yanlış!
                    // Doğru kullanım:
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
            cell.dataset.productid = productId;

            cell.addEventListener('click', () => {
                // cellElements[productName].forEach(c => { ... }) yanlış!
                // Doğru kullanım:
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

            // Tek tedarikçi varsa otomatik seç
            if (isSingleSupplier && !rowHasSatinalma && !rowHasOS) {
                const checkIcon = document.createElement('div');
                checkIcon.className = 'check-icon text-success';
                checkIcon.innerHTML = '✔️';
                cell.appendChild(checkIcon);
                selectedCells.set(productId, cellKey);
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
        const [companyId, productIdStr, price, wrkRowId, discount1, quantity, netPrice, tax, priceOther, otherMoney, demandMoney, stockId, isSatinalma, yyy, xxx, oemNo, selectInfoExtra, gpaPrice, gpaMoney] = key.split('|');
        if (!grouped[companyId]) {
            grouped[companyId] = {
                companyId: parseInt(companyId),
                products: []
            };
        }
        const row = [...document.querySelectorAll('td.product-name')].find(td => td.dataset.productid == productId)?.parentElement;
        const marjInput = row?.querySelector('input.marj-input');
        const salePriceInput = row?.querySelector('input.sale-price-input');
        const dsc1Input = row?.querySelector('input.dsc1-input');
        const dsc2Input = row?.querySelector('input.dsc2-input');
        const dsc3Input = row?.querySelector('input.dsc3-input');

        let productMarj = 0;
        let salePrice = 0;

        if (marjInput) {
            productMarj = parseFloat(marjInput.value) || 0;
        }
        if (dsc1Input) {
            dsc1 = parseFloat(dsc1Input.value) || 0;
        }
        if (dsc2Input) {
            discount2 = parseFloat(dsc2Input.value) || 0;
        }
        if (dsc3Input) {
            discount3 = parseFloat(dsc3Input.value) || 0;
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
            discount: parseFloat(discount1),
            quantity: parseFloat(quantity),
            netPrice: parseFloat(netPrice),
            tax: parseFloat(tax),
            priceOther: parseFloat(priceOther),
            otherMoney: otherMoney,
            productName: productInfoMap.get(parseInt(productIdStr))?.PRODUCT_NAME || "",
            isSatinalma: parseInt(isSatinalma),
            productMarj: productMarj,
            salePrice: parseFloat(salePrice.toFixed(2)),
            convertedsalePriceOther: parseFloat(convertedsalePriceOther.toFixed(2)),
            demandMoney: demandMoney,
            oemNo: oemNo,
            xxx: xxx,
            yyy: yyy,
            selectInfoExtra: selectInfoExtra,
            discount1: parseFloat(dsc1Input?.value) || 0,
            discount3: parseFloat(dsc3Input?.value) || 0,
            discount2: parseFloat(dsc2Input?.value) || 0,
            gpaPrice: parseFloat(gpaPrice) || 0,
            gpaMoney: gpaMoney || ""
        });
    });
    const groupedArray = Object.values(grouped);
    output.textContent = JSON.stringify(groupedArray, null, 2);
    return groupedArray;
}

function updateBestSupplier() {
    const supplierTotals = {};
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
    document.querySelectorAll('td input.marj-input').forEach(input => {
        input.value = newMarj;
        input.dispatchEvent(new Event('input')); // satış fiyatını güncelle
    });
};
window.setAllDsc1Rows = function (el) {
    const newDsc1 = parseFloat(el.value) || 0;
    document.querySelectorAll('td input.dsc1-input').forEach(input => {
        input.value = newDsc1;
        input.dispatchEvent(new Event('input')); // satış fiyatını güncelle
    });
};
window.setAllDsc2Rows = function (el) {
    const newDsc2 = parseFloat(el.value) || 0;
    document.querySelectorAll('td input.dsc2-input').forEach(input => {
        input.value = newDsc2;
        input.dispatchEvent(new Event('input')); // satış fiyatını güncelle
    });
};
window.setAllDsc3Rows = function (el) {
    const newDsc3 = parseFloat(el.value) || 0;
    document.querySelectorAll('td input.dsc3-input').forEach(input => {
        input.value = newDsc3;
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
                //AjaxPageLoad("index.cfm?fuseaction=sales.ajax_list_pbs_offer_purchases_1&INTERNAL_ID=" + offer_id, "ShownArea", 1, "Yükleniyor")
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


function SatinalmaSiparis(params) {
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

