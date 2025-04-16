<cf_box title="Satınalma Seçim Ekranı">


  <style>
    td.selectable {
      cursor: pointer;
      transition: background-color 0.2s;
      position: relative;
    }
    td.no-data {
      background-color: #f8f9fa !important;
      color: #adb5bd;
    }
    .product-name {
      background-color: #f1f3f5;
      font-weight: bold;
      position: sticky;
      left: 0;
      z-index: 1;
    }
    th.sticky-header {
      position: sticky;
      top: 0;
      z-index: 2;
    }
    pre {
      background-color: #fff3cd;
      border: 1px solid #ffeeba;
      padding: 1rem;
      border-radius: 0.5rem;
    }
    .price-original {
      color: red;
      text-decoration: line-through;
    }
    .net-price {
      color: green;
      font-weight: bold;
    }
    .check-icon {
      position: absolute;
      top: 5px;
      right: 5px;
      font-size: 1.2rem;
      animation: fadeIn 0.4s ease-in-out;
    }
    .tooltip {
      position: relative;
      display: inline-block;
    }
    .tooltip .tooltiptext {
      visibility: hidden;
      width: max-content;
      background-color: #343a40;
      color: #fff;
      text-align: center;
      border-radius: 4px;
      padding: 5px;
      position: absolute;
      z-index: 10;
      bottom: 125%;
      left: 50%;
      transform: translateX(-50%);
      opacity: 0;
      transition: opacity 0.3s;
      font-size: 0.75rem;
    }
    .tooltip:hover .tooltiptext {
      visibility: visible;
      opacity: 1;
    }
    .flex-list .small, .ui-table-list .small {
    width: auto;
}
   /* .net-price.low { color: green; font-weight: bold; }
    .net-price.medium { color: orange; font-weight: bold; }
    .net-price.high { color: red; font-weight: bold; }*/
  </style>
</head>
<CFSET OFFER_STAGE="0">
  <cfquery name="getrelofferID" datasource="#DSN3#">
    SELECT * FROM w3Qa_1.PURCHAE_OFFER_SALE_OFFER_RELATION_PBS WHERE  PURCHASE_OFFER_ID= #attributes.offer_id#
  </cfquery>
  <CFIF getrelofferID.recordCount>
    <cfquery name="GETRELATEDOFFER" datasource="#DSN3#">
      SELECT * FROM w3Qa_1.OFFER WHERE  OFFER_ID = #getrelofferID.SALE_OFFER_ID#
    </cfquery>
    <CFSET OFFER_STAGE=GETRELATEDOFFER.OFFER_STAGE>
  </CFIF>

<body class="bg-light">
  <div class="">
    <div class="">
      <div class="card-body">
        
        <div class="table-responsive">
          <cf_grid_list  class="table table-bordered align-middle text-center" id="price-table"></cf_grid_list>
        </div>
        <div class="mt-4 text-end">
            <button class="btn btn-success" id="send-btn3">Kaydet</button>
            <button class="btn btn-primary" id="send-btn">Kaydet ve Satış Teklifine Dönüştür</button>
         <CFIF OFFER_STAGE EQ 256>
            <button class="btn btn-success" id="send-btn2">Satınalma Siparişlerini Oluştur</button>
          </CFIF>
          
        </div>


    <div class="card mt-4 shadow-sm">
    <div class="card-body">
      <h5 class="card-title">En İyi Fiyatı Veren Tedarikçi</h5>
      <p id="best-supplier" class="fw-bold text-primary">Henüz belirlenmedi.</p>
    </div>
  </div>

  <div class="card mt-4 shadow-sm">
      <div class="card-body">
        <h5 class="card-title">Seçilen Veriler (JSON)</h5>
        <pre id="output">[]</pre>
      </div>
    </div>

   
  </div>
  

  <cfquery name="getMainPurchaseOffer" datasource="#DSN3#">
SELECT (
SELECT 
    C.FULLNAME,
    C.COMPANY_ID,
    (
        SELECT 
            PRODUCT_NAME,
            CAST(PRICE AS DECIMAL(18,2)) AS PRICE,
            CAST(PRICE_OTHER AS DECIMAL(18,2)) AS PRICE_OTHER,
            OTHER_MONEY,
            PRODUCT_ID,
            STOCK_ID,
            WRK_ROW_ID,
            CAST(DISCOUNT_1 AS DECIMAL(18,2)) AS DISCOUNT_1,
            CAST(TAX AS DECIMAL(18,2)) AS TAX,
            CAST(QUANTITY AS DECIMAL(18,2)) AS QUANTITY,
            CAST(PRICE - (PRICE * DISCOUNT_1 / 100) AS DECIMAL(18,2)) AS NET_PRICE,
            CASE WHEN (SELECT COUNT(*) FROM w3Qa_1.PBS_SELECTED_ROWS WHERE WRK_ROW_ID=OFFER_ROW.WRK_ROW_ID)>0 THEN 1 ELSE 0 END AS IS_SELECTED,

            CASE WHEN (SELECT COUNT(*) FROM w3Qa_1.OFFER_ROW AS TTTTTTT WHERE WRK_ROW_RELATION_ID=OFFER_ROW.WRK_ROW_ID)>0 THEN 1 ELSE 0 END AS IS_SATINALMA
            ,ISNULL((SELECT CAST(PRODUCT_MARJ AS DECIMAL(18,2)) AS PRODUCT_MARJ,CAST(SALE_PRICE AS DECIMAL(18,2)) AS SALE_PRICE  FROM w3Qa_1.PBS_SELECTED_ROWS WHERE WRK_ROW_ID=OFFER_ROW.WRK_ROW_ID FOR JSON AUTO),'[]') AS SLP
            ,ISNULL((
				SELECT * FROM (
				SELECT PRODUCT_ID FROM w3Qa_1.ALTERNATIVE_PRODUCTS WHERE PRODUCT_ID=OFFER_ROW.PRODUCT_ID OR ALTERNATIVE_PRODUCT_ID=OFFER_ROW.PRODUCT_ID
				UNION ALL
				SELECT ALTERNATIVE_PRODUCT_ID PRODUCT_ID FROM w3Qa_1.ALTERNATIVE_PRODUCTS WHERE PRODUCT_ID=OFFER_ROW.PRODUCT_ID OR ALTERNATIVE_PRODUCT_ID=OFFER_ROW.PRODUCT_ID
				) AS TABLO
			FOR JSON PATH),'[]') AS ALTERNATIFLER
        FROM 
            #DSN3#.OFFER_ROW 
        WHERE 
            OFFER_ID = O.OFFER_ID
        FOR JSON PATH
    ) AS URUNLER
FROM 
    #DSN3#.OFFER AS O
LEFT JOIN 
    #DSN#.COMPANY AS C 
    ON C.COMPANY_ID = TRY_CAST(REPLACE(O.OFFER_TO, ',', '') AS INT)
WHERE 
    O.OFFER_ID IN (
        SELECT 
            OFFER_ID 
        FROM 
            #DSN3#.OFFER_ROW 
        WHERE 
            WRK_ROW_RELATION_ID IN (
                SELECT WRK_ROW_ID 
                FROM #DSN3#.OFFER_ROW 
                WHERE OFFER_ID = #attributes.offer_id#
            )
    )
FOR JSON PATH
) AS QRESULT

  </cfquery>
  
  <input type="hidden" id="offer_id" name="offer_id" value="<cfoutput>#attributes.offer_id#</cfoutput>">

  <script>
// script.js - Ayrılmış JavaScript dosyası
// Bu dosya, JavaScript kodunu içerir ve HTML'den ayrıdır
// Bu dosya, HTML'den ayrılmıştır ve daha iyi bir yapı sağlar
// Ayrılmış JavaScript dosyası, HTML'den bağımsız olarak çalışabilir
// Ayrılmış JavaScript dosyası, HTML'den bağımsız olarak çalışabilir
var session_variables=<cfoutput>#replace(serializeJSON(session),"//","")#</cfoutput>
    const data = <cfoutput>#getMainPurchaseOffer.QRESULT#</cfoutput>
// script.js - Ayrılmış JavaScript dosyası

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
headerRow.innerHTML += `<th class="sticky-header bg-info text-white">Marj (%)</th>`;
headerRow.innerHTML += `<th class="sticky-header bg-info text-white">Satış Fiyatı (₺)</th>`;
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

  let slpInfo = {};
for (const supplier of data) {
  const match = supplier.URUNLER.find(p => p.PRODUCT_NAME === productName && p.SLP && p.SLP.length > 0);
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
marjCell.appendChild(marjInput);

const salePriceCell = document.createElement('td');
const salePriceSpan = document.createElement('span');
salePriceSpan.textContent = slpInfo.SALE_PRICE != null ? `${slpInfo.SALE_PRICE.toFixed(2)} ₺` : "-";
salePriceCell.appendChild(salePriceSpan);

// input değişince hesapla
marjInput.addEventListener('input', () => {
  const selectedKey = selectedCells.get(productName);
  if (!selectedKey) return;

  const [companyId, productId, price, wrkRowId, discount1, quantity, netPrice] = selectedKey.split('|');
  const net = parseFloat(netPrice);
  const marj = parseFloat(marjInput.value);
  if (!isNaN(net) && !isNaN(marj)) {
    const calculatedSalePrice = net + (net * marj / 100);
    salePriceSpan.textContent = `${calculatedSalePrice.toFixed(2)} ₺`;
  }
});
row.appendChild(marjCell);
row.appendChild(salePriceCell);

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
      const cellKey = `${supplier.COMPANY_ID}|${product.PRODUCT_ID}|${product.PRICE}|${product.WRK_ROW_ID}|${product.DISCOUNT_1}|${product.QUANTITY}|${product.NET_PRICE}|${product.TAX}|${product.PRICE_OTHER}|${product.OTHER_MONEY}|${product.STOCK_ID}|${productName}|${product.IS_SELECTED || 0 }|${product.IS_SATINALMA || 0}`;

      const priceDisplay = product.DISCOUNT_1 > 0
        ? `<div class="tooltip"><span class="price-original">${product.PRICE.toFixed(2)} TL</span><span class="tooltiptext">İskonto: ${product.DISCOUNT_1}%</span></div>`
        : `<div><strong>${product.PRICE.toFixed(2)} TL</strong></div>`;

      let netPriceHtml = `<div class=\"net-price\">Net: ${product.NET_PRICE.toFixed(2)} TL</div>`;
      if (product.NET_PRICE === lowestNetPrice) {
        netPriceHtml = `<div class=\"net-price\">⭐ Net: ${product.NET_PRICE.toFixed(2)} TL</div>`;
        cell.title = 'En iyi teklif'+product.WRK_ROW_ID;
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

const bgColor = alternativeGroups[product.PRODUCT_ID];
if (bgColor) {
  cell.style.backgroundColor = bgColor;
}

if (product.IS_SATINALMA===1) {
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
    const [companyId, productId, price, wrkRowId, discount1, quantity, netPrice,tax,priceOther,otherMoney,stockId,isSatinalma,productName] = key.split('|');
    if (!grouped[companyId]) {
      grouped[companyId] = {
        companyId: parseInt(companyId),
        products: []
      };
    }
    
    let marjInputEl = document.querySelector(`tr:has(td.product-name:contains("${productName}")) input`);
let salePrice = 0;
let productMarj = 0;

if (marjInputEl) {
  productMarj = parseFloat(marjInputEl.value) || 0;
  const net = parseFloat(netPrice);
  salePrice = net + (net * productMarj / 100);
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
      otherMoney:otherMoney,
      productName: productName,
      isSatinalma: parseInt(isSatinalma),
      productMarj: productMarj,
      salePrice: parseFloat(salePrice.toFixed(2)),

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
function getRandomColor() {
  const letters = '0123456789ABCDEF';
  let color = '#';
  for (let i = 0; i < 6; i++) {
    color += letters[Math.floor(Math.random() * 16)];
  }
  return color;
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
    body: JSON.stringify({ payload, offer_id,session_variables }) // Include offer_id in the payload
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



updateBestSupplier();



</script>



</cf_box>

