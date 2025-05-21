
  <meta charset="UTF-8">
  <title>İç Talepler</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="https://kit.fontawesome.com/a2e0e6cfd9.js" crossorigin="anonymous"></script> <!-- Font Awesome -->
 <style>
    body { padding: 2rem; font-size: 14px; }
    .talep-block { border-left: 4px solid #0d6efd; padding: 0.5rem 1rem; margin-bottom: 1.2rem; background: #f8f9fa; border-radius: 0.375rem; }
    .talep-header { font-weight: 600; color: #0d6efd; margin-bottom: 0.4rem; }
    .text-company { color: #555; font-weight: 500; }
    .offer-line { margin-left: 1.5rem; }
    .icon { width: 18px; display: inline-block; text-align: center; }
    .text-muted { font-size: 13px; }
    .label-green { color: #28a745; font-weight: 500; }
    .label-red { color: #dc3545; font-weight: 500; }
    .search-input { max-width: 300px; margin-bottom: 20px; }
  </style>

<h2 class="mb-4"><i class="fas fa-list-alt"></i> İç Talepler</h2>

<input type="text" id="filterInput" class="form-control search-input" placeholder="Talep No veya Talep Eden...">

<div id="talepListesi"></div>
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

FROM w3Qa_1.INTERNALDEMAND AS IDO
    LEFT JOIN w3Qa_1.OFFER AS OFFER_MAIN 
        ON OFFER_MAIN.INTERNALDEMAND_ID = IDO.INTERNAL_ID
    LEFT JOIN w3Qa_1.OFFER AS OFFER_SUB 
        ON OFFER_SUB.FOR_OFFER_ID = OFFER_MAIN.OFFER_ID
    LEFT JOIN w3Qa.COMPANY AS C 
        ON C.COMPANY_ID = IDO.FROM_COMPANY_ID
    LEFT JOIN w3Qa.EMPLOYEE_POSITIONS AS EP 
        ON EP.POSITION_CODE = IDO.TO_POSITION_CODE
FOR JSON PATH
) AS DATA
</cfquery>
<script>
const data = <cfoutput>#getData.DATA#</cfoutput> // Buraya JSON datanı yapıştır

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
      anaTeklifId: item.ANA_TEKLIF_ID,
      altTeklifNo: item.ALT_TEKLIF_NO,
      altTeklifId: item.ALT_TEKLIF_ID,
      altTeklifTarihi: item.ALT_TEKLIF_TARIHI
    });
  }
});

function renderList(filter = "") {
  const container = document.getElementById("talepListesi");
  container.innerHTML = "";

  Object.values(grouped).forEach(talep => {
    const searchText = `${talep.talepNo} ${talep.talepEden}`.toLowerCase();
    if (!searchText.includes(filter.toLowerCase())) return;

    const block = document.createElement("div");
    block.className = "talep-block";

    block.innerHTML = `
      <div class="talep-header">
        <i class="fas fa-box-open icon"></i>
        <strong>Talep: ${talep.talepNo}</strong>
        <span class="ms-2 text-company"><i class="fas fa-user icon text-secondary"></i>${talep.talepEdenPers || ""} (${talep.talepEden || ""})</span>
      </div>

      ${talep.teklifler.map(t => `
        <div class="offer-line">
          <i class="fas fa-file-download text-primary icon"></i>
          <span>Alış Teklifi: <strong>${t.altTeklifNo}</strong></span>
          <span class="text-muted ms-1">${t.altTeklifTarihi?.slice(0, 10) || ""}</span>
        </div>
      `).join("")}

      ${talep.teklifler.length === 0 ? `<div class="offer-line label-red"><i class="fas fa-times-circle icon"></i> Teklif Yok</div>` : ""}
    `;

    container.appendChild(block);
  });
}

document.getElementById("filterInput").addEventListener("input", e => {
  renderList(e.target.value);
});

renderList();
</script>

