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
function getConvertedNetPriceWithMarj(productId, marj = 0) {
    let net = 0;
    for (const supplier of data) {
        const product = supplier.URUNLER.find(p => p.PRODUCT_ID === productId);
        if (product && product.NET_PRICE) {
            net = product.NET_PRICE;
            break;
        }
    }

    const netWithMarj = net + (net * marj / 100);

    const currency = MONEYARRRR.find(c => c.MONEY === DEMAND_MONEY);
    const rate1 = parseFloat(currency?.RATE1 || 1);
    const rate2 = parseFloat(currency?.RATE2 || 1);
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
        var dsc1 = 0;
        var discount2 = 0;
        var discount3 = 0;
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
            discount1: dsc1,
            discount3: discount2,
            discount2: discount3
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
function sifirKontrl() {
    var mx = updateOutput()
    var SFRFIYAT = 0;
    var SFRMarj = 0;
    for (let i = 0; i < mx.length; i++) {
        var my = mx[i].products;
        for (let j = 0; j < my.length; j++) {
            var p = my[j].productMarj
            if (p == 0) {
                SFRFIYAT++
            }
        }
    }

    if (SFRFIYAT > 0) {
        var fx = confirm("Marj Girilmemiş Ürünler Var; Lütfen Kontrol Edin!")
        return fx;
    } else {
        return true;
    }
}