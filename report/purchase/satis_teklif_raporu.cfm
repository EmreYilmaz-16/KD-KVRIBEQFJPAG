
  <meta charset="UTF-8">
  <title>İç Talepler</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="https://kit.fontawesome.com/a2e0e6cfd9.js" crossorigin="anonymous"></script> <!-- Font Awesome -->
  <style>
    body { padding: 2rem; }
    .talep-header i { margin-right: 6px; }
    .search-input { max-width: 300px; margin-bottom: 20px; }
  </style>

<h2 class="mb-4"><i class="fas fa-list-alt"></i> İç Talepler</h2>

<input type="text" id="filterInput" class="form-control search-input" placeholder="Talep No veya Talep Eden...">

<div class="accordion" id="talepAccordion"></div>
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

// Gruplama
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
    });
  }
});

// HTML oluştur
const accordion = document.getElementById("talepAccordion");

function renderAccordion(filter = "") {
  accordion.innerHTML = "";
  Object.values(grouped).forEach((talep, index) => {
    const searchText = `${talep.talepNo} ${talep.talepEden || ""}`.toLowerCase();
    if (!searchText.includes(filter.toLowerCase())) return;

    const collapseId = `collapse${index}`;
    const item = document.createElement("div");
    item.className = "accordion-item";

    item.innerHTML = `
      <h2 class="accordion-header" id="heading${index}">
        <button class="accordion-button collapsed talep-header" type="button" data-bs-toggle="collapse" data-bs-target="#${collapseId}" aria-expanded="false">
          <i class="fas fa-box-open text-primary"></i> ${talep.talepNo} — <small class="ms-2 text-muted">${talep.talepEden || "?"}</small>
        </button>
      </h2>
      <div id="${collapseId}" class="accordion-collapse collapse" aria-labelledby="heading${index}" data-bs-parent="#talepAccordion">
        <div class="accordion-body">
          <p><i class="fas fa-user me-2 text-info"></i><strong>Talep Eden Kişi:</strong> ${talep.talepEdenPers || "-"}</p>
          ${talep.talepTarihi ? `<p><i class="fas fa-calendar-alt me-2 text-success"></i><strong>Talep Tarihi:</strong> ${talep.talepTarihi.slice(0,10)}</p>` : ""}

          ${talep.teklifler.length > 0 ? `
            <div class="table-responsive">
              <table class="table table-bordered table-striped table-sm mt-3">
                <thead class="table-light">
                  <tr>
                    <th><i class="fas fa-tag"></i> Ana Teklif No</th>
                    <th><i class="fas fa-tags"></i> Alt Teklif No</th>
                    <th><i class="fas fa-calendar-day"></i> Alt Teklif Tarihi</th>
                  </tr>
                </thead>
                <tbody>
                  ${talep.teklifler.map(t => `
                    <tr>
                      <td>${t.anaTeklifNo || "-"}</td>
                      <td>${t.altTeklifNo || "-"}</td>
                      <td>${t.altTeklifTarihi ? t.altTeklifTarihi.slice(0, 10) : "-"}</td>
                    </tr>
                  `).join("")}
                </tbody>
              </table>
            </div>
          ` : `<p class="text-muted"><i class="fas fa-info-circle me-1"></i> Bu talep için teklif bulunmamaktadır.</p>`}
        </div>
      </div>
    `;
    accordion.appendChild(item);
  });
}

renderAccordion();

document.getElementById("filterInput").addEventListener("input", e => {
  renderAccordion(e.target.value);
});
</script>

