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
         <cfquery name="getOfferStage" datasource="#DSN3#">
SELECT OFFER_ID,OFFER_STAGE,SUM(SS) SS FROM (
SELECT 
	DISTINCT
	ORR_SATIS_TEKLIFI.OFFER_ID,
	O_SATIS_TEKLIFI.OFFER_STAGE,
	(SELECT COUNT(*) FROM w3Qa_1.ORDER_ROW WHERE WRK_ROW_RELATION_ID=ORR_SATIS_TEKLIFI.WRK_ROW_ID)	AS SS
FROM w3Qa_1.OFFER_ROW AS ORR_SATIS_TEKLIFI
LEFT JOIN w3Qa_1.OFFER_ROW AS ORR_ALIS_TEKLIFI ON ORR_ALIS_TEKLIFI.WRK_ROW_ID=ORR_SATIS_TEKLIFI.WRK_ROW_RELATION_ID
LEFT JOIN w3Qa_1.OFFER AS O_ALIS_TEKLIFI ON O_ALIS_TEKLIFI.OFFER_ID=ORR_ALIS_TEKLIFI.OFFER_ID
LEFT JOIN w3Qa_1.OFFER AS O_SATIS_TEKLIFI ON O_SATIS_TEKLIFI.OFFER_ID=ORR_SATIS_TEKLIFI.OFFER_ID
WHERE ORR_SATIS_TEKLIFI.WRK_ROW_RELATION_ID IN (
SELECT WRK_ROW_ID FROM w3Qa_1.PBS_SELECTED_ROWS WHERE OFFER_ID=#attributes.internal_id#)
) AS T GROUP BY OFFER_ID,OFFER_STAGE

</cfquery>
<cfquery name="GETDEMAND_MONEY" datasource="#dsn3#">
  SELECT OTHER_MONEY FROM w3Qa_1.INTERNALDEMAND WHERE INTERNAL_ID=#attributes.internal_id#
</cfquery>
<script>
  var DEMAND_MONEY = '<cfoutput>#GETDEMAND_MONEY.OTHER_MONEY#</cfoutput>';
</script>

<cfif getOfferStage.recordCount>
<cfelse>
  <cfquery name="upos" datasource="#dsn3#">
    UPDATE w3Qa_1.PBS_SELECTED_ROWS SET IS_OS=1 WHERE OFFER_ID=#attributes.internal_id#
  </cfquery>
</cfif>
            <CFIF getOfferStage.OFFER_STAGE EQ 256 and getOfferStage.SS EQ 0>
            <button class="btn btn-success" onclick="SatinalmaSiparis(<CFOUTPUT>#attributes.internal_id#</CFOUTPUT>)" id="send-btn2">Satınalma Siparişlerini Oluştur</button>
          
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
SELECT ( SELECT * FROM (
SELECT C.FULLNAME, C.COMPANY_ID, OFFER_ID,
(
    
SELECT PRODUCT_NAME
,CAST(PRICE AS DECIMAL(18, 2)) AS PRICE
	, CAST(PRICE_OTHER AS DECIMAL(18, 2)) AS PRICE_OTHER
	, OTHER_MONEY
	, PRODUCT_ID
	, STOCK_ID
	, WRK_ROW_ID
	, CAST(DISCOUNT_1 AS DECIMAL(18, 2)) AS DISCOUNT_1
	, CAST(TAX AS DECIMAL(18, 2)) AS TAX
	, CAST(QUANTITY AS DECIMAL(18, 2)) AS QUANTITY
	, CAST(PRICE - (PRICE * DISCOUNT_1 / 100) AS DECIMAL(18, 2)) AS NET_PRICE
  ,CASE WHEN (SELECT (SELECT COUNT(*) FROM w3Qa_1.ORDER_ROW WHERE WRK_ROW_RELATION_ID=OFR2.WRK_ROW_ID) FROM w3Qa_1.OFFER_ROW OFR2 WHERE WRK_ROW_RELATION_ID=OFFER_ROW.WRK_ROW_ID) >0	THEN 1 ELSE 0 END AS SNT_S
	, CASE 
		WHEN (
				SELECT COUNT(*)
    FROM w3Qa_1.PBS_SELECTED_ROWS
    WHERE WRK_ROW_ID = OFFER_ROW.WRK_ROW_ID
				) > 0
			THEN 1
		ELSE 0
		END AS IS_SELECTED
    ,ISNULL((SELECT IS_OS FROM PBS_SELECTED_ROWS WHERE WRK_ROW_ID = OFFER_ROW.WRK_ROW_ID),1) AS IS_OS
, ISNULL((CASE 
						WHEN (
								SELECT COUNT(*)
    FROM w3Qa_1.OFFER_ROW AS TTTTTTT
    WHERE WRK_ROW_RELATION_ID = OFFER_ROW.WRK_ROW_ID
								) > 0
							THEN 1
						ELSE 0
						END),0) AS IS_SATINALMA
, ISNULL((
							SELECT CAST(PRODUCT_MARJ AS DECIMAL(18, 2)) AS PRODUCT_MARJ
								, CAST(SALE_PRICE AS DECIMAL(18, 2)) AS SALE_PRICE
    FROM w3Qa_1.PBS_SELECTED_ROWS
    WHERE WRK_ROW_ID = OFFER_ROW.WRK_ROW_ID
    FOR JSON AUTO
							), '[]') AS SLP
					, ISNULL((
							SELECT *
    FROM (
								            SELECT PRODUCT_ID
            FROM w3Qa_1.ALTERNATIVE_PRODUCTS
            WHERE PRODUCT_ID = OFFER_ROW.PRODUCT_ID
                OR ALTERNATIVE_PRODUCT_ID = OFFER_ROW.PRODUCT_ID

        UNION ALL

            SELECT ALTERNATIVE_PRODUCT_ID PRODUCT_ID
            FROM w3Qa_1.ALTERNATIVE_PRODUCTS
            WHERE PRODUCT_ID = OFFER_ROW.PRODUCT_ID
                OR ALTERNATIVE_PRODUCT_ID = OFFER_ROW.PRODUCT_ID
								) AS TABLO
    FOR JSON PATH
							), '[]') AS ALTERNATIFLER
FROM w3Qa_1.OFFER_ROW
WHERE OFFER_ID = O.OFFER_ID
FOR JSON PATH
) AS URUNLER
FROM w3Qa_1.OFFER AS O
    LEFT JOIN w3Qa.COMPANY AS C ON C.COMPANY_ID = TRY_CAST(REPLACE(O.OFFER_TO, ',', '') AS INT)

WHERE FOR_OFFER_ID IN (
    SELECT OFFER_ID
FROM w3Qa_1.OFFER
WHERE INTERNALDEMAND_ID=#attributes.internal_id#
)
) AS T FOR JSON PATH

)AS QRESULT


  </cfquery>
  
  <input type="hidden" id="offer_id" name="offer_id" value="<cfoutput>#attributes.internal_id#</cfoutput>">

  <cfset MONEYARRRR=arrayNew(1)>
            <cfquery name="getMoneyext" datasource="#dsn3#">
                SELECT 
             (SELECT RATE1 FROM #dsn#.MONEY_HISTORY WHERE MONEY_HISTORY_ID=(
             SELECT MAX(MONEY_HISTORY_ID) FROM #dsn#.MONEY_HISTORY WHERE MONEY=SM.MONEY) )AS RATE1,
             (SELECT EFFECTIVE_SALE RATE2 FROM #dsn#.MONEY_HISTORY WHERE MONEY_HISTORY_ID=(
             SELECT MAX(MONEY_HISTORY_ID) FROM #dsn#.MONEY_HISTORY WHERE MONEY=SM.MONEY) )AS RATE2,
             SM.MONEY
             FROM #dsn#.SETUP_MONEY AS SM WHERE SM.PERIOD_ID=#session.ep.period_id#
             </cfquery>
        
    <cfloop query="getMoneyext">
        <cfscript>
            arrayAppend(MONEYARRRR,{MONEY=MONEY,RATE1=RATE1,RATE2=RATE2})
        </cfscript>
        
    </cfloop>


  <script>
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
// script.js - Ayrılmış JavaScript dosyası
// Bu dosya, JavaScript kodunu içerir ve HTML'den ayrıdır
// Bu dosya, HTML'den ayrılmıştır ve daha iyi bir yapı sağlar
// Ayrılmış JavaScript dosyası, HTML'den bağımsız olarak çalışabilir
// Ayrılmış JavaScript dosyası, HTML'den bağımsız olarak çalışabilir
var session_variables=<cfoutput>#replace(serializeJSON(session),"//","")#</cfoutput>
    var data = <cfoutput>#getMainPurchaseOffer.QRESULT#</cfoutput>
    data=mergeCompanies(data);
    var ww_data=data;
    const MONEYARRRR=<cfoutput>#replace(serializeJSON(MONEYARRRR),"//","")#</cfoutput>
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
headerRow.innerHTML += `
  <th class="sticky-header bg-info text-white">
    Marj (%)<br>
    <input id="global-marj-input" onchange="setMarjAllRows(this)"  type="number" class="form-control form-control-sm" style="width:80px; margin-top:4px;" placeholder="Toplu">
  </th>
`;
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


uniqueProducts.forEach(productName => {
  const rowHasSatinalma = data.some(supplier => {
    const p = supplier.URUNLER.find(u => u.PRODUCT_NAME === productName);
    return p?.IS_SATINALMA === 1;
  });
  
  const rowHasOS = data.some(supplier => {
    const p = supplier.URUNLER.find(u => u.PRODUCT_NAME === productName);
    return p?.IS_OS === false;
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
const salePriceInput = document.createElement('input');
salePriceInput.type = 'text';
salePriceInput.value = slpInfo.SALE_PRICE != null ? slpInfo.SALE_PRICE.toFixed(2) : "";
salePriceInput.className = 'form-control form-control-sm sale-price-input';
salePriceInput.style.width = '100px';
salePriceInput.dataset.product = productName;

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
  const selectedKey = selectedCells.get(productName);
  const net = parseFloat(selectedKey?.split('|')[6]);
  const marj = parseFloat(marjInput.value);

  if (!isNaN(net) && !isNaN(marj)) {
    const calculatedSalePrice = net + (net * marj / 100);

    // Kur bilgisi için diğerMoney ve ilgili döviz kurları
    const otherMoney = selectedKey?.split('|')[9]; // 9. index = OTHER_MONEY
    const currency = MONEYARRRR.find(c => c.MONEY === DEMAND_MONEY);
    const rate1 = parseFloat(currency?.RATE1 || 1);
    const rate2 = parseFloat(currency?.RATE2 || 1);

    const converted = (calculatedSalePrice * rate1) / rate2;

    salePriceInput.value = converted.toFixed(2);
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
      const cellKey = `${supplier.COMPANY_ID}|${product.PRODUCT_ID}|${product.PRICE}|${product.WRK_ROW_ID}|${product.DISCOUNT_1}|${product.QUANTITY}|${product.NET_PRICE}|${product.TAX}|${product.PRICE_OTHER}|${product.OTHER_MONEY}|${DEMAND_MONEY}|${product.STOCK_ID}|${productName}|${product.IS_SELECTED || 0 }|${product.IS_SATINALMA || 0}`;

      const priceDisplay = product.DISCOUNT_1 > 0
        ? `<div class="tooltip"><span class="price-original">${product.PRICE_OTHER.toFixed(2)} ${product.OTHER_MONEY}</span><span class="tooltiptext">İskonto: ${product.DISCOUNT_1}%</span></div>`
        : `<div><strong>${product.PRICE_OTHER.toFixed(2)} ${product.OTHER_MONEY}</strong></div>`;

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
  ${product.SNT_S === 1 ? '<div class="text-success fw-bold small">💵 S.Alma Oluştu</div>' : ''}
  ${((product.IS_SATINALMA === 0 && product.IS_SELECTED === 1) && product.IS_OS === false)
  ? '<div class="text-warning fw-bold small">⚠️ Satış Teklifinden Kaldırıldı</div>'
  : ''}  
`;

if(product.IS_OS===false){
  console.log("Ürün Satış Teklifine Dönmüşmüş",product.PRODUCT_NAME,product.IS_OS);
}
if(rowHasOS){
  console.log("Satırda  Satış Teklifine Dönmüşmüş Ürün Var",product.PRODUCT_NAME,product.IS_OS);
}

const bgColor = alternativeGroups[product.PRODUCT_ID];
if (bgColor) {
  //cell.style.backgroundColor = bgColor;
}

if (product.IS_SATINALMA===1) {
  $("#send-btn").hide();
  $("#send-btn3").hide();
}
if (!rowHasSatinalma && !rowHasOS) {
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
    if(product.IS_OS===true){
      if(!rowHasOS){
      const checkIcon = document.createElement('div');
      checkIcon.className = 'check-icon text-success';
      checkIcon.innerHTML = '✔️';
      cell.appendChild(checkIcon);
      selectedCells.set(productName, cellKey);}
    else{
      cell.style.pointerEvents = 'none';
      cell.style.opacity = '0.8';
      cell.title = 'Bu ürün için satın alma yapılmış. Seçim yapılamaz.';
    }
    }else{
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
        if(product.IS_OS === true) {
  const checkIcon = document.createElement('div');
  checkIcon.className = 'check-icon text-success';
  checkIcon.innerHTML = '✔️';
  cell.appendChild(checkIcon);
  selectedCells.set(productName, cellKey);
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
  selectedCells.forEach((key, productName) => {
    const [companyId, productId, price, wrkRowId, discount1, quantity, netPrice,tax,priceOther,otherMoney,demandMoney,stockId,isSatinalma] = key.split('|');
    if (!grouped[companyId]) {
      grouped[companyId] = {
        companyId: parseInt(companyId),
        products: []
      };
    }
    const marjInput = [...document.querySelectorAll('td.product-name')].find(td => td.textContent.trim() === productName.trim())?.parentElement.querySelector('input');
    const salePriceInput = document.querySelector(`input.sale-price-input[data-product="${productName}"]`);

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
  convertedsalePriceOther = (parseFloat(salePrice) * rate2 ) / rate1;
} catch (e) {
  console.error("Hata:", e);
  convertedPriceOther = 0;
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
      convertedsalePriceOther: parseFloat(convertedsalePriceOther.toFixed(2)),
      demandMoney: demandMoney,

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

window.setMarjAllRows = function(el) {
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

document.getElementById('send-btn').addEventListener('click', () => {
  if(!sifirKontrl()){
    return;
  }
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

document.getElementById('send-btn3').addEventListener('click', () => {
  const payload = updateOutput(); // Ensure payload is generated correctly
  console.log("Sunucuya gönderilecek veri:", payload);
  var offer_id = document.getElementById("offer_id").value;

  fetch('/AddOns/Partner/purchase/cfc/purchase_service.cfc?method=savePurchaseOfferSelectorOnly', { // Correct endpoint
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

function sifirKontrl(){
  var mx=updateOutput()
  var SFRFIYAT=0;
var SFRMarj=0;
for(let i=0;i<mx.length;i++){
    var my=mx[i].products;
    for(let j=0;j<my.length;j++){
        var p=my[j].salePrice
        if(p==0){
           SFRFIYAT++ 
        }
    }
}

if(SFRFIYAT>0){
   var stk= confirm("Fiyat Girilmemiş Ürünler Var Devam Etmek İstiyormusunuz")
    return stk;
}else{
    return true;
}
}
function SatinalmaSiparis(params) {
  $.ajax({
    url: '/AddOns/Partner/purchase/cfc/purchase_Service.cfc?method=SAVEORDER_gpt&internal_id='+params,
    type: 'GET',
    
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



</script>



</cf_box>

