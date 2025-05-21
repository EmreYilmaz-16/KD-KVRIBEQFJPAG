<cfquery name="getData" datasource="#dsn3#">
SELECT (
SELECT DISTINCT 
    IDO.INTERNAL_ID AS TALEP_ID, 
    IDO.INTERNAL_NUMBER AS TALEP_NO, 
    IDO.TARGET_DATE AS TALEP_TARIHI,
    C.NICKNAME AS TALEP_EDEN,
    EP.EMPLOYEE_NAME + ' ' + EP.EMPLOYEE_SURNAME AS TALEP_EDEN_PERS,

    OFFER_MAIN.OFFER_NUMBER AS ANA_TEKLIF_NO, 
    OFFER_MAIN.OFFER_ID AS ANA_TEKLIF_ID, 

    OFFER_SUB.OFFER_NUMBER AS ALT_TEKLIF_NO, 
    OFFER_SUB.OFFER_ID AS ALT_TEKLIF_ID,
    OFFER_SUB.OFFER_DATE AS ALT_TEKLIF_TARIHI
    C2.NICKNAME AS ALT_TEKLIF_FIRMA

FROM w3Qa_1.INTERNALDEMAND AS IDO
    LEFT JOIN w3Qa_1.OFFER AS OFFER_MAIN 
        ON OFFER_MAIN.INTERNALDEMAND_ID = IDO.INTERNAL_ID
    LEFT JOIN w3Qa_1.OFFER AS OFFER_SUB 
        ON OFFER_SUB.FOR_OFFER_ID = OFFER_MAIN.OFFER_ID
    LEFT JOIN w3Qa.COMPANY AS C 
        ON C.COMPANY_ID = IDO.FROM_COMPANY_ID
    LEFT JOIN w3Qa.EMPLOYEE_POSITIONS AS EP 
        ON EP.POSITION_CODE = IDO.TO_POSITION_CODE
    LEFT JOIN w3Qa.COMPANY AS C2 
        ON C2.COMPANY_ID=TRY_CAST(REPLACE(OFFER_SUB.OFFER_TO, ',', '') AS INT)
FOR JSON PATH
) AS DATA


</cfquery>


  <title>Talep Listesi</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 20px;
      background-color: #f2f2f2;
      font-size: 14px;
    }

    h2 {
      margin-bottom: 15px;
    }

    .search-input {
      width: 300px;
      padding: 6px 10px;
      font-size: 14px;
      margin-bottom: 20px;
      border: 1px solid #ccc;
      border-radius: 4px;
    }

    .talep-block {
      background: #fff;
      border-left: 4px solid #2a9df4;
      padding: 10px 15px;
      margin-bottom: 15px;
      border-radius: 6px;
      box-shadow: 0 1px 2px rgba(0,0,0,0.05);
    }

    .talep-header {
      font-weight: bold;
      color: #2a9df4;
      margin-bottom: 5px;
    }

    .text-company {
      color: #444;
      font-weight: 500;
      font-size: 13px;
    }

    .offer-line {
      margin-left: 20px;
      padding-left: 5px;
      border-left: 2px solid #eee;
      margin-top: 4px;
    }

    .label-red {
      color: #d62828;
      margin-left: 20px;
      font-weight: bold;
    }

    .label-green {
      color: #2f9e44;
      margin-left: 20px;
      font-weight: bold;
    }

    .text-muted {
      color: #777;
      font-size: 13px;
      margin-left: 5px;
    }
  </style>

<h2>📋 İç Talepler</h2>

<input type="text" id="filterInput" class="search-input" placeholder="🔍 Talep No veya Talep Eden...">

<div id="talepListesi"></div>

<script>
const data = <cfoutput>#getData.DATA#</cfoutput>; // JSON verini buraya yapıştır

// Grupla
const grouped = {};
data.forEach(item => {
  const key = item.TALEP_NO;
  if (!grouped[key]) {
    grouped[key] = {
      talepId: item.TALEP_ID,
      talepNo: item.TALEP_NO,
      talepEden: item.TALEP_EDEN,
      talepEdenPers: item.TALEP_EDEN_PERS,
      talepTarihi: item.TALEP_TARIHI,
      teklifler: []
    };
  }
  if (item.ANA_TEKLIF_NO || item.ALT_TEKLIF_NO) {
    grouped[key].teklifler.push({
      anaTeklifNo: item.ANA_TEKLIF_NO,
      altTeklifNo: item.ALT_TEKLIF_NO,
      altTeklifTarihi: item.ALT_TEKLIF_TARIHI
      altTeklifFirma: item.ALT_TEKLIF_FIRMA
    });
  }
});

// Listeyi çiz
function renderList(filter = "") {
  const container = document.getElementById("talepListesi");
  container.innerHTML = "";

  Object.values(grouped).forEach(talep => {
    const searchText = `${talep.talepNo} ${talep.talepEden}`.toLowerCase();
    if (!searchText.includes(filter.toLowerCase())) return;

    const block = document.createElement("div");
    block.className = "talep-block";

    block.innerHTML = `
      <div class="talep-header">📦 Talep: ${talep.talepNo}
        <span class="text-company">👤 ${talep.talepEdenPers || "-"} (${talep.talepEden || "-"})</span>
      </div>

      ${talep.teklifler.length > 0 ? talep.teklifler.map(t => `
        <div class="offer-line">📥 Alış Teklifi: <strong>${t.altTeklifNo}</strong>
          ${t.altTeklifTarihi ? `<span class="text-muted">📅 ${t.altTeklifTarihi.slice(0,10)}</span> <span>${t.altTeklifFirma}</span>` : ""}
        </div>
      `).join("") : `<div class="label-red">🚫 Teklif Yok</div>`}
    `;

    container.appendChild(block);
  });
}

document.getElementById("filterInput").addEventListener("input", e => {
  renderList(e.target.value);
});

renderList();
</script>


