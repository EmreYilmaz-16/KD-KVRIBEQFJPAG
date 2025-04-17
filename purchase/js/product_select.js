const table = document.getElementById('price-table');
const output = document.getElementById('output');
const selectedCells = new Map();

const productSet = new Set();
data.forEach(supplier => {
    supplier.URUNLER.forEach(product => {
        productSet.add(product.PRODUCT_NAME);
    });
});
const uniqueProducts = Array.from(productSet);

const headerRow = document.createElement('tr');
headerRow.innerHTML = `<th class="sticky-header bg-success text-white">&Uuml;r&uuml;n</th>`;
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

uniqueProducts.forEach(productName => {
    const rowHasSatinalma = data.some(supplier => {
        const p = supplier.URUNLER.find(u => u.PRODUCT_NAME === productName);
        return p?.IS_SATINALMA === 1;
    })

    const row = document.createElement('tr');
    const productCell = document.createElement('td');
    productCell.textContent = productName;
    productCell.className = 'product-name';
    row.appendChild(productCell);

    cellElements[productName] = [];

    let lowestNetPrice = Infinity;
    data.forEach(supplier => {
        const product = supplier.URUNLER.find(p => p.PRODUCT_NAME === productName);
        if (product && product.NET_PRICE < lowestNetPrice) {
            lowestNetPrice = product.NET_PRICE;
        }
    });

    data.forEach(supplier => {
        const product = supplier.URUNLER.find(p => p.PRODUCT_NAME === productName);
        const cell = document.createElement('td');

        if (product) {
            // const cellKey = `${supplier.COMPANY_ID}|${product.PRODUCT_ID}|${product.PRICE}|${product.WRK_ROW_ID}|${product.DISCOUNT_1}|${product.QUANTITY}|${product.NET_PRICE}|${productName}`;
            const cellKey = `${supplier.COMPANY_ID}|${product.PRODUCT_ID}|${product.PRICE}|${product.WRK_ROW_ID}|${product.DISCOUNT_1}|${product.QUANTITY}|${product.NET_PRICE}|${product.TAX}|${product.PRICE_OTHER}|${product.OTHER_MONEY}|${product.STOCK_ID}|${productName}|${product.IS_SELECTED || 0}|${product.IS_SATINALMA || 0}`;

            const priceDisplay = product.DISCOUNT_1 > 0
                ? `<div class="tooltip"><span class="price-original">${product.PRICE.toFixed(2)} TL</span><span class="tooltiptext">İskonto: ${product.DISCOUNT_1}%</span></div>`
                : `<div><strong>${product.PRICE.toFixed(2)} TL</strong></div>`;

            let netPriceHtml = `<div class=\"net-price\">Net: ${product.NET_PRICE.toFixed(2)} TL</div>`;
            if (product.NET_PRICE === lowestNetPrice) {
                netPriceHtml = `<div class=\"net-price\">⭐ Net: ${product.NET_PRICE.toFixed(2)} TL</div>`;
                cell.title = 'En iyi teklif' + product.WRK_ROW_ID;
            }

            cell.innerHTML = `
  ${priceDisplay}
  ${netPriceHtml}
  <div class="text-muted small">Iskonto: ${product.DISCOUNT_1}%</div>
  <div class="text-muted small">Adet: ${product.QUANTITY}</div>
  ${product.IS_SELECTED === 1 ? '<div class="text-primary fw-bold small">✅ Seçili </div>' : ''}
  ${product.IS_SATINALMA === 1 ? '<div class="text-danger fw-bold small">🚩 Satış Teklifinde</div>' : ''}
  ${product.IS_SATINALMA === 0 && product.IS_SELECTED === 1 ? '<div class="text-warning fw-bold small">⚠️Satış Teklifinden Kaldırıldı</div>' : ''}    
`;

            if (product.IS_SATINALMA === 1) {
                $("#send-btn").hide();
                $("#send-btn3").hide();
            }
            if (!rowHasSatinalma) {
                cell.classList.add('selectable');
                cell.dataset.key = cellKey;

                cell.addEventListener('click', () => {
                    cellElements[productName].forEach(c => {
                        const icon = c.querySelector('div.check-icon');
                        if (icon) icon.remove();
                    });
                    const checkIcon = document.createElement('div');
                    checkIcon.className = 'check-icon text-success';
                    checkIcon.innerHTML = '✔️';
                    cell.appendChild(checkIcon);
                    selectedCells.set(productName, cellKey);
                    updateOutput();
                    updateBestSupplier();
                });

                if (product.IS_SELECTED === 1) {
                    const checkIcon = document.createElement('div');
                    checkIcon.className = 'check-icon text-success';
                    checkIcon.innerHTML = '✔️';
                    cell.appendChild(checkIcon);
                    selectedCells.set(productName, cellKey);
                }
            } else {
                cell.style.pointerEvents = 'none';
                cell.style.opacity = '0.8';
                cell.title = 'Bu ürün için satın alma yapılmış. Seçim yapılamaz.';
            }
            cell.dataset.product = productName;

            cellElements[productName].push(cell);
            if (product.IS_SELECTED === 1) {
                const checkIcon = document.createElement('div');
                checkIcon.className = 'check-icon text-success';
                checkIcon.innerHTML = '✔️';
                cell.appendChild(checkIcon);
                selectedCells.set(productName, cellKey);
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
    selectedCells.forEach((key, productName) => {
        const [companyId, productId, price, wrkRowId, discount1, quantity, netPrice, tax, priceOther, otherMoney, stockId, isSatinalma] = key.split('|');
        if (!grouped[companyId]) {
            grouped[companyId] = {
                companyId: parseInt(companyId),
                products: []
            };
        }
        grouped[companyId].products.push({
            productId: parseInt(productId),
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

        });
    });
    const groupedArray = Object.values(grouped);
    output.textContent = JSON.stringify(groupedArray, null, 2);
    return groupedArray;
}

function updateBestSupplier() {
    const supplierTotals = {};
    data.forEach(supplier => {
        const productNames = supplier.URUNLER.map(p => p.PRODUCT_NAME);
        const hasAllProducts = uniqueProducts.every(pName => productNames.includes(pName));
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

document.getElementById('send-btn').addEventListener('click', () => {
    const payload = updateOutput(); // Ensure payload is generated correctly
    console.log("Sunucuya gönderilecek veri:", payload);
    var offer_id = document.getElementById("offer_id").value;

    fetch('/AddOns/Partner/purchase/cfc/purchase_service.cfc?method=savePurchaseOfferSelector', { // Correct endpoint
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
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
