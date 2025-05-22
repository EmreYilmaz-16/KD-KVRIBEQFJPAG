<cfquery name="hazirlik1" datasource="#dsn3#">
  IF OBJECT_ID('SATIS_TEKLIF_ALIS_TEKLIF', 'U') IS NOT NULL
    DROP TABLE SATIS_TEKLIF_ALIS_TEKLIF;

SELECT DISTINCT 
    SATIS_TEKLIFI.OFFER_NUMBER AS SATIS_TEKLIF_NO, 
    SATIS_TEKLIFI.OFFER_ID AS SATIS_TEKLIF_ID, 
    SATIS_TEKLIFI.OFFER_DATE AS SATIS_TEKLIF_TARIHI,
    ALIS_TEKLIFI.OFFER_ID AS ALIS_TEKLIF_ID
INTO SATIS_TEKLIF_ALIS_TEKLIF
FROM w3Qa_1.INTERNALDEMAND_ROW AS IRR
LEFT JOIN w3Qa_1.INTERNALDEMAND AS IDD 
    ON IDD.INTERNAL_ID = IRR.I_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI_MAIN 
    ON ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_RELATION_ID = IRR.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI 
    ON ALIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER AS ALIS_TEKLIFI 
    ON ALIS_TEKLIFI.OFFER_ID = ALIS_TEKLIFI_SATIRLARI.OFFER_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS SATIS_TEKLIFI_SATIRLARI 
    ON SATIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER AS SATIS_TEKLIFI 
    ON SATIS_TEKLIFI.OFFER_ID = SATIS_TEKLIFI_SATIRLARI.OFFER_ID
WHERE SATIS_TEKLIFI.OFFER_NUMBER IS NOT NULL;

</cfquery>

<cfquery name="hazirlik2" datasource="#dsn3#">
IF OBJECT_ID('SATIS_SIPARIS_ALIS_TEKLIF', 'U') IS NOT NULL
    DROP TABLE SATIS_SIPARIS_ALIS_TEKLIF;

SELECT DISTINCT 
    ALIS_TEKLIFI.OFFER_ID AS ALIS_TEKLIF_ID,
    SATIS_SIPARISI.ORDER_ID AS SATIS_SIPARIS_ID,
    SATIS_SIPARISI.ORDER_NUMBER AS SATIS_SIPARIS_NO,
    SATIS_SIPARISI.ORDER_DATE AS SATIS_SIPARISI_TARIHI
INTO SATIS_SIPARIS_ALIS_TEKLIF
FROM w3Qa_1.INTERNALDEMAND_ROW AS IRR
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI_MAIN 
    ON ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_RELATION_ID = IRR.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI 
    ON ALIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER AS ALIS_TEKLIFI 
    ON ALIS_TEKLIFI.OFFER_ID = ALIS_TEKLIFI_SATIRLARI.OFFER_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS SATIS_TEKLIFI_SATIRLARI 
    ON SATIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI.WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDER_ROW AS SATIS_SIPARISI_SATIRLARI 
    ON SATIS_SIPARISI_SATIRLARI.WRK_ROW_RELATION_ID = SATIS_TEKLIFI_SATIRLARI.WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDERS AS SATIS_SIPARISI 
    ON SATIS_SIPARISI.ORDER_ID = SATIS_SIPARISI_SATIRLARI.ORDER_ID
WHERE SATIS_SIPARISI.ORDER_NUMBER IS NOT NULL;

</cfquery>
<cfquery name="hazirlik3" datasource="#dsn3#">
  IF OBJECT_ID('SATIS_FATURA_ALIS_TEKLIF', 'U') IS NOT NULL
    DROP TABLE SATIS_FATURA_ALIS_TEKLIF;

SELECT DISTINCT 
    ALIS_TEKLIFI.OFFER_ID AS ALIS_TEKLIF_ID,
    INVOICE.INVOICE_NUMBER AS SATIS_FATURA_NO,
    INVOICE.INVOICE_DATE AS SATIS_FATURA_TARIHI,
    INVOICE.PERIOD_ID AS SATIS_FATURA_PERIOD
INTO SATIS_FATURA_ALIS_TEKLIF
FROM w3Qa_1.INTERNALDEMAND_ROW AS IRR
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI_MAIN 
    ON ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_RELATION_ID = IRR.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI 
    ON ALIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER AS ALIS_TEKLIFI 
    ON ALIS_TEKLIFI.OFFER_ID = ALIS_TEKLIFI_SATIRLARI.OFFER_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS SATIS_TEKLIFI_SATIRLARI 
    ON SATIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI.WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDER_ROW AS SATIS_SIPARISI_SATIRLARI 
    ON SATIS_SIPARISI_SATIRLARI.WRK_ROW_RELATION_ID = SATIS_TEKLIFI_SATIRLARI.WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDERS AS SATIS_SIPARISI 
    ON SATIS_SIPARISI.ORDER_ID = SATIS_SIPARISI_SATIRLARI.ORDER_ID
LEFT JOIN w3Qa_1.ORDERS_INVOICE AS OI 
    ON OI.ORDER_ID = SATIS_SIPARISI.ORDER_ID
LEFT JOIN (
    SELECT INVOICE_NUMBER, INVOICE_DATE, INVOICE_ID, 1 AS PERIOD_ID 
    FROM w3Qa_2024_1.INVOICE
    UNION ALL
    SELECT INVOICE_NUMBER, INVOICE_DATE, INVOICE_ID, 2 AS PERIOD_ID 
    FROM w3Qa_2025_1.INVOICE
) AS INVOICE 
    ON INVOICE.INVOICE_ID = OI.INVOICE_ID 
    AND INVOICE.PERIOD_ID = OI.PERIOD_ID
WHERE INVOICE.INVOICE_NUMBER IS NOT NULL;

</cfquery>
<cfquery name="hazirlik4" datasource="#dsn3#">
  IF OBJECT_ID('ALIS_FATURA_ALIS_TEKLIF', 'U') IS NOT NULL
    DROP TABLE ALIS_FATURA_ALIS_TEKLIF;

SELECT DISTINCT 
    ALIS_TEKLIFI.OFFER_ID AS ALIS_TEKLIF_ID,
    INVOICE2.INVOICE_NUMBER AS ALIS_FATURA_NO,
    INVOICE2.INVOICE_DATE AS ALIS_FATURA_TARIHI,
    INVOICE2.PERIOD_ID AS ALIS_FATURA_PERIOD
INTO ALIS_FATURA_ALIS_TEKLIF
FROM w3Qa_1.INTERNALDEMAND_ROW AS IRR
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI_MAIN 
    ON ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_RELATION_ID = IRR.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI 
    ON ALIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER AS ALIS_TEKLIFI 
    ON ALIS_TEKLIFI.OFFER_ID = ALIS_TEKLIFI_SATIRLARI.OFFER_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS SATIS_TEKLIFI_SATIRLARI 
    ON SATIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI.WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDER_ROW AS ALIS_SIPARIS_SATIRLARI 
    ON ALIS_SIPARIS_SATIRLARI.WRK_ROW_RELATION_ID = CAST(SATIS_TEKLIFI_SATIRLARI.WRK_ROW_ID AS VARCHAR) + '_XX'
LEFT JOIN w3Qa_1.ORDERS AS ALIS_SIPARIS 
    ON ALIS_SIPARIS.ORDER_ID = ALIS_SIPARIS_SATIRLARI.ORDER_ID
LEFT JOIN w3Qa_1.ORDERS_INVOICE AS OI2 
    ON OI2.ORDER_ID = ALIS_SIPARIS.ORDER_ID
LEFT JOIN (
    SELECT INVOICE_NUMBER, INVOICE_DATE, INVOICE_ID, 1 AS PERIOD_ID FROM w3Qa_2024_1.INVOICE
    UNION ALL
    SELECT INVOICE_NUMBER, INVOICE_DATE, INVOICE_ID, 2 AS PERIOD_ID FROM w3Qa_2025_1.INVOICE
) AS INVOICE2 
    ON INVOICE2.INVOICE_ID = OI2.INVOICE_ID 
    AND INVOICE2.PERIOD_ID = OI2.PERIOD_ID
WHERE INVOICE2.INVOICE_NUMBER IS NOT NULL;
</cfquery>

<cfquery name="hazirlik5" datasource="#dsn3#">
  IF OBJECT_ID('ALIS_IRSALIYE_ALIS_TEKLIF', 'U') IS NOT NULL
    DROP TABLE ALIS_IRSALIYE_ALIS_TEKLIF;

SELECT DISTINCT 
    ALIS_TEKLIFI.OFFER_ID AS ALIS_TEKLIF_ID,
    INVOICE2.SHIP_NUMBER AS ALIS_IRSALIYE_NO,
    INVOICE2.SHIP_DATE AS ALIS_IRSALIYE_TARIHI,
    INVOICE2.PERIOD_ID AS ALIS_IRSALIYE_PERIOD
INTO ALIS_IRSALIYE_ALIS_TEKLIF
FROM w3Qa_1.INTERNALDEMAND_ROW AS IRR
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI_MAIN 
    ON ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_RELATION_ID = IRR.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI 
    ON ALIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER AS ALIS_TEKLIFI 
    ON ALIS_TEKLIFI.OFFER_ID = ALIS_TEKLIFI_SATIRLARI.OFFER_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS SATIS_TEKLIFI_SATIRLARI 
    ON SATIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI.WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDER_ROW AS ALIS_SIPARIS_SATIRLARI 
    ON ALIS_SIPARIS_SATIRLARI.WRK_ROW_RELATION_ID = CAST(SATIS_TEKLIFI_SATIRLARI.WRK_ROW_ID AS VARCHAR) + '_XX'
LEFT JOIN w3Qa_1.ORDERS AS ALIS_SIPARIS 
    ON ALIS_SIPARIS.ORDER_ID = ALIS_SIPARIS_SATIRLARI.ORDER_ID
LEFT JOIN w3Qa_1.ORDERS_SHIP AS OI2 
    ON OI2.ORDER_ID = ALIS_SIPARIS.ORDER_ID
LEFT JOIN (
    SELECT SHIP_NUMBER, SHIP_DATE, SHIP_ID, 1 AS PERIOD_ID FROM w3Qa_2024_1.SHIP
    UNION ALL
    SELECT SHIP_NUMBER, SHIP_DATE, SHIP_ID,2 AS PERIOD_ID FROM w3Qa_2025_1.SHIP
) AS INVOICE2 
    ON INVOICE2.SHIP_ID = OI2.SHIP_ID 
    AND INVOICE2.PERIOD_ID = OI2.PERIOD_ID
WHERE INVOICE2.SHIP_NUMBER IS NOT NULL;
</cfquery>

<cfquery name="hazirlik6" datasource="#dsn3#">
  IF OBJECT_ID('SATIS_IRSALIYE_ALIS_TEKLIF', 'U') IS NOT NULL
    DROP TABLE SATIS_IRSALIYE_ALIS_TEKLIF;

SELECT DISTINCT 
    ALIS_TEKLIFI.OFFER_ID AS ALIS_TEKLIF_ID,
    INVOICE.SHIP_NUMBER AS SATIS_IRSALIYE_NO,
    INVOICE.SHIP_DATE AS SATIS_IRSALIYE_TARIHI,
    INVOICE.PERIOD_ID AS SATIS_IRSALIYE_PERIOD
INTO SATIS_IRSALIYE_ALIS_TEKLIF
FROM w3Qa_1.INTERNALDEMAND_ROW AS IRR
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI_MAIN 
    ON ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_RELATION_ID = IRR.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI 
    ON ALIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER AS ALIS_TEKLIFI 
    ON ALIS_TEKLIFI.OFFER_ID = ALIS_TEKLIFI_SATIRLARI.OFFER_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS SATIS_TEKLIFI_SATIRLARI 
    ON SATIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI.WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDER_ROW AS SATIS_SIPARISI_SATIRLARI 
    ON SATIS_SIPARISI_SATIRLARI.WRK_ROW_RELATION_ID = SATIS_TEKLIFI_SATIRLARI.WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDERS AS SATIS_SIPARISI 
    ON SATIS_SIPARISI.ORDER_ID = SATIS_SIPARISI_SATIRLARI.ORDER_ID
LEFT JOIN w3Qa_1.ORDERS_SHIP AS OI2 
    ON OI2.ORDER_ID = SATIS_SIPARISI.ORDER_ID
LEFT JOIN (
    SELECT SHIP_NUMBER, SHIP_DATE, SHIP_ID, 1 AS PERIOD_ID FROM w3Qa_2024_1.SHIP
    UNION ALL
    SELECT SHIP_NUMBER, SHIP_DATE, SHIP_ID,2 AS PERIOD_ID FROM w3Qa_2025_1.SHIP
) AS INVOICE 
    ON INVOICE.SHIP_ID = OI2.SHIP_ID 
    AND INVOICE.PERIOD_ID = OI2.PERIOD_ID
WHERE INVOICE.SHIP_NUMBER IS NOT NULL;


</cfquery>

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
    OFFER_SUB.OFFER_DATE AS ALT_TEKLIF_TARIHI,
    C2.NICKNAME AS ALT_TEKLIF_FIRMA,
    O.ORDER_NUMBER AS ALT_TEKLIF_SIPARIS,
    SATIS_TEKLIF.SATIS_TEKLIF_ID AS SATIS_TEKLIF_ID,
    SATIS_TEKLIF.SATIS_TEKLIF_NO AS SATIS_TEKLIF_NO,
    SATIS_TEKLIF.SATIS_TEKLIF_TARIHI AS SATIS_TEKLIF_TARIHI,
    SATIS_SIPARIS.SATIS_SIPARIS_ID AS SATIS_SIPARIS_ID,
    SATIS_SIPARIS.SATIS_SIPARIS_NO AS SATIS_SIPARIS_NO,
    SATIS_SIPARIS.SATIS_SIPARISI_TARIHI AS SATIS_SIPARIS_TARIHI,
    SATIS_FATURA.SATIS_FATURA_NO AS SATIS_FATURA_NO,
    SATIS_FATURA.SATIS_FATURA_TARIHI AS SATIS_FATURA_TARIHI,
    SATIS_FATURA.SATIS_FATURA_PERIOD AS SATIS_FATURA_PERIOD,
    ALIS_FATURA.ALIS_FATURA_NO AS ALIS_FATURA_NO,
    ALIS_FATURA.ALIS_FATURA_TARIHI AS ALIS_FATURA_TARIHI,
    ALIS_FATURA.ALIS_FATURA_PERIOD AS ALIS_FATURA_PERIOD,
    ALIS_IRSALIYE.ALIS_IRSALIYE_NO AS ALIS_IRSALIYE_NO,
    ALIS_IRSALIYE.ALIS_IRSALIYE_TARIHI AS ALIS_IRSALIYE_TARIHI,
    ALIS_IRSALIYE.ALIS_IRSALIYE_PERIOD AS ALIS_IRSALIYE_PERIOD,
    SATIS_IRSALIYE.SATIS_IRSALIYE_NO AS SATIS_IRSALIYE_NO,
    SATIS_IRSALIYE.SATIS_IRSALIYE_TARIHI AS SATIS_IRSALIYE_TARIHI,
    SATIS_IRSALIYE.SATIS_IRSALIYE_PERIOD AS SATIS_IRSALIYE_PERIOD

        
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
      
    LEFT JOIN SATIS_TEKLIF_ALIS_TEKLIF AS SATIS_TEKLIF 
        ON SATIS_TEKLIF.ALIS_TEKLIF_ID = OFFER_SUB.OFFER_ID
          OUTER APPLY (
        SELECT ORDER_NUMBER,ORDER_ID FROM w3Qa_1.ORDERS WHERE ORDER_ID IN (
        SELECT ORDER_ID FROM w3Qa_1.ORDER_ROW AS ORR WHERE ORR.WRK_ROW_RELATION_ID IN(
            SELECT WRK_ROW_ID+'_XX' FROM w3Qa_1.OFFER_ROW WHERE OFFER_ID=SATIS_TEKLIF.SATIS_TEKLIF_ID
        ))
    ) AS O
    LEFT JOIN SATIS_SIPARIS_ALIS_TEKLIF AS SATIS_SIPARIS
        ON SATIS_SIPARIS.ALIS_TEKLIF_ID = OFFER_SUB.OFFER_ID
    LEFT JOIN SATIS_FATURA_ALIS_TEKLIF AS SATIS_FATURA
        ON SATIS_FATURA.ALIS_TEKLIF_ID = OFFER_SUB.OFFER_ID
    LEFT JOIN ALIS_FATURA_ALIS_TEKLIF AS ALIS_FATURA
        ON ALIS_FATURA.ALIS_TEKLIF_ID = OFFER_SUB.OFFER_ID
    LEFT JOIN ALIS_IRSALIYE_ALIS_TEKLIF AS ALIS_IRSALIYE
        ON ALIS_IRSALIYE.ALIS_TEKLIF_ID = OFFER_SUB.OFFER_ID
    LEFT JOIN SATIS_IRSALIYE_ALIS_TEKLIF AS SATIS_IRSALIYE
        ON SATIS_IRSALIYE.ALIS_TEKLIF_ID = OFFER_SUB.OFFER_ID

    
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

    .ana-teklif {
      margin-left: 15px;
      font-weight: bold;
      color: #198754;
      margin-top: 5px;
    }

    .alt-teklif {
      margin-left: 30px;
      margin-top: 3px;
    }

    .text-muted {
      color: #777;
      font-size: 13px;
      margin-left: 5px;
    }

    .label-red {
      color: #d62828;
      margin-left: 20px;
      font-weight: bold;
    }
   body {
  font-family: "Segoe UI", sans-serif;
  background-color: #f5f6f8;
  padding: 10px;
  font-size: 13px;
  color: #333;
}

#filterInput {
  width: 100%;
  padding: 6px 10px;
  margin-bottom: 12px;
  border: 1px solid #ccc;
  border-radius: 6px;
  font-size: 13px;
}

.talep-block {
  background: #fff;
  border: 1px solid #ccc;
  border-left: 3px solid #1a73e8;
  border-radius: 6px;
  margin-bottom: 10px;
  padding: 10px;
  font-size: 13px;
}

.talep-header {
  font-weight: bold;
  margin-bottom: 6px;
  display: flex;
  justify-content: flex-start;
  flex-wrap: wrap;
}

.talep-header a {
  text-decoration: none;
  color: #1a73e8;
}

.text-company {
  font-size: 12px;
  color: #666;
}

.ana-teklif {
  font-weight: bold;
  margin: 6px 0 4px;
  color: #1a73e8;
  font-size: 13px;
}

.alt-teklif {
  background-color: #f1f3f4;
  border: 1px solid #ddd;
  border-radius: 4px;
  margin: 4px 0;
  padding: 6px 8px;
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  align-items: center;
}

.alt-teklif a {
  color: #1a73e8;
  font-weight: 500;
  text-decoration: none;
}

.alt-teklif span {
  padding: 2px 6px;
  background-color: #e8f0fe;
  border-radius: 4px;
  color: #333;
  font-size: 12px;
}

.firma {
  background-color: #ffe0b2;
  color: #5d4037;
}

.etiket {
  background-color: #d7ffd9;
  color: #2e7d32;
}

.tarih {
  background-color: #f3e5f5;
  color: #6a1b9a;
}

.label-red {
  background-color: #ef5350;
  color: #fff;
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
}
.satis-blok {
  margin-top: 8px;
  padding: 6px 10px;
  background-color: #e0f7fa;
  border-left: 3px solid #00acc1;
  border-radius: 4px;
  font-size: 12px;
}

.satis-listesi {
  list-style: none;
  padding-left: 0;
  margin-top: 4px;
}

.satis-listesi li {
  margin: 2px 0;
  padding: 2px 0;
  border-bottom: 1px dashed #b2ebf2;
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

  </style>

<h2>📋 İç Talepler</h2>

<input type="text" id="filterInput" class="search-input" placeholder="🔍 Talep No veya Talep Eden Firma...">

<div id="talepListesi"></div>

<script>
const data = <cfoutput>#getData.DATA#</cfoutput>; // JSON verini buraya yapıştır
// Talepleri grupla
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
      teklifler: {}
    };
  }

  const anaTeklifKey = item.ANA_TEKLIF_NO || "YOK";
  if (!grouped[key].teklifler[anaTeklifKey]) {
    grouped[key].teklifler[anaTeklifKey] = {
      anaTeklifNo: item.ANA_TEKLIF_NO,
      anaTeklifId: item.ANA_TEKLIF_ID,
      altTeklifler: []
    };
  }

  if (item.ALT_TEKLIF_NO) {
    grouped[key].teklifler[anaTeklifKey].altTeklifler.push({
      altTeklifNo: item.ALT_TEKLIF_NO,
      altTeklifId: item.ALT_TEKLIF_ID,
      altTeklifTarihi: item.ALT_TEKLIF_TARIHI,
      altTeklifFirma: item.ALT_TEKLIF_FIRMA,
      altTeklifSiparis: item.ALT_TEKLIF_SIPARIS,      
      satisTeklifId: item.SATIS_TEKLIF_ID,
      satisTeklifNo: item.SATIS_TEKLIF_NO,
      satisTeklifTarihi: item.SATIS_TEKLIF_TARIHI,
      satisSiparisId: item.SATIS_SIPARIS_ID,
      satisSiparisNo: item.SATIS_SIPARIS_NO,
      satisSiparisTarihi: item.SATIS_SIPARIS_TARIHI,
      satisFaturaNo: item.SATIS_FATURA_NO,
      satisFaturaTarihi: item.SATIS_FATURA_TARIHI,
      satisFaturaPeriod: item.SATIS_FATURA_PERIOD,
      alisFaturaNo: item.ALIS_FATURA_NO,
      alisFaturaTarihi: item.ALIS_FATURA_TARIHI,
      alisFaturaPeriod: item.ALIS_FATURA_PERIOD,
      alisIrsaliyeNo: item.ALIS_IRSALIYE_NO,
      alisIrsaliyeTarihi: item.ALIS_IRSALIYE_TARIHI,
      alisIrsaliyePeriod: item.ALIS_IRSALIYE_PERIOD,
      satisIrsaliyeNo: item.SATIS_IRSALIYE_NO,
      satisIrsaliyeTarihi: item.SATIS_IRSALIYE_TARIHI,
      satisIrsaliyePeriod: item.SATIS_IRSALIYE_PERIOD



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
      <div class="talep-header">📦 Talep: <a href='/index.cfm?fuseaction=purchase.list_purchasedemand&event=upd&id=${talep.talepId}&is_hidden=1' target='_blank'> ${talep.talepNo}</a>
        <span class="text-company">👤 ${talep.talepEdenPers || "-"} (${talep.talepEden || "-"})</span>
      </div>
    `;

    const teklifKeys = Object.keys(talep.teklifler);
    if (teklifKeys.length > 0) {
      teklifKeys.forEach(key => {
        const ana = talep.teklifler[key];
        block.innerHTML += `
          <div class="ana-teklif">📄 Ana Teklif: <a href='/index.cfm?fuseaction=purchase.list_offer&event=det&offer_id=${ana.anaTeklifId}'>${ana.anaTeklifNo || "YOK"}</a></div>
        `;
        ana.altTeklifler.forEach(alt => {
          // block.innerHTML += `
          //   <div class="alt-teklif">
          //     📥 <strong><a href='/index.cfm?fuseaction=purchase.list_offer&event=upd&offer_id=${alt.altTeklifId}'>${alt.altTeklifNo}</a></strong>
          //     ${alt.altTeklifTarihi ? `<span class="text-muted">📅 ${alt.altTeklifTarihi.slice(0,10)}</span>` : ""}
          //     ${alt.altTeklifFirma ? `<span class="firma">🏢 ${alt.altTeklifFirma}</span>` : ""}
          //     ${alt.altTeklifSiparis ? `<span class="siparis">📦 Alış Siparişi: ${alt.altTeklifSiparis}</span>` : ""}
          //     ${alt.satisTeklifNo ? `<span class="siparis">📦 Satış Teklifi: ${alt.satisTeklifNo}</span>` : ""}
          //     ${alt.satisTeklifTarihi ? `<span class="text-muted">📅 ${alt.satisTeklifTarihi.slice(0,10)}</span>` : ""}
          //      ${alt.satisSiparisNo ? `<span class="siparis">📦 Satış Siparişi: ${alt.satisSiparisNo}</span>` : ""}
          //     ${alt.satisSiparisTarihi ? `<span class="text-muted">📅 ${alt.satisSiparisTarihi.slice(0,10)}</span>` : ""}
          //   </div>
          // `;
          block.innerHTML += `
  <div class="alt-teklif">
    <div class="alt-teklif-header">
      <a href='/index.cfm?fuseaction=purchase.list_offer&event=upd&offer_id=${alt.altTeklifId}' class="alt-teklif-no">
        📥 ${alt.altTeklifNo}
      </a>
      ${alt.altTeklifTarihi ? `<span class="tarih">📅 ${alt.altTeklifTarihi.slice(0, 10)}</span>` : ""}
    </div>
    <div class="alt-teklif-body">
      ${alt.altTeklifFirma ? `<span class="firma">🏢 ${alt.altTeklifFirma}</span>` : ""}
      ${alt.altTeklifSiparis ? `<span class="etiket">📦 Alış Siparişi: ${alt.altTeklifSiparis}</span>` : ""}
      ${alt.alisFaturaNo ? `<span class="etiket">🧾 Alış Fatura: ${alt.alisFaturaNo}</span>` : ""}
      ${alt.alisIrsaliyeNo ? `<span class="etiket">🧾 Alış İrsaliye: ${alt.alisIrsaliyeNo}</span>` : ""}
    </div>
  </div>
`;
        });
      });
      const satislarRaw = teklifKeys.flatMap(key => talep.teklifler[key].altTeklifler)
  .filter(x => x.satisTeklifNo || x.satisSiparisNo);

// Tekrarları önlemek için JSON string'e çevirerek benzersizleştir
const uniqueMap = new Map();
satislarRaw.forEach(item => {
  const key = [
    item.satisTeklifNo || "",
    item.satisTeklifTarihi || "",
    item.satisSiparisNo || "",
    item.satisSiparisTarihi || ""
  ].join("|");

  if (!uniqueMap.has(key)) {
    uniqueMap.set(key, item);
  }
});

const satislarUnique = Array.from(uniqueMap.values());
      // Satış bilgileri en sona, tek blok olarak
    const satislar = teklifKeys.flatMap(key => talep.teklifler[key].altTeklifler)
      .filter(x => x.satisTeklifNo || x.satisSiparisNo);

    if (satislarUnique.length > 0) {
      block.innerHTML += `<div class="satis-blok"><strong>📈 Satış Teklif , Sipariş & Fatura Bilgileri</strong><ul class="satis-listesi">`;

      satislarUnique.forEach(sat => {
        block.innerHTML += `
          <li>
            ${sat.satisTeklifNo ? `📄 <strong>${sat.satisTeklifNo}</strong>` : ""}
            ${sat.satisTeklifTarihi ? `<span class="tarih">📅 ${sat.satisTeklifTarihi.slice(0, 10)}</span>` : ""}
            ${sat.satisSiparisNo ? `📦 <strong>${sat.satisSiparisNo}</strong>` : ""}
            ${sat.satisSiparisTarihi ? `<span class="tarih">📅 ${sat.satisSiparisTarihi.slice(0, 10)}</span>` : ""}
            ${sat.satisFaturaNo ? `<span class="tarih">🧾 ${sat.satisFaturaNo}</span>` : ""}
            ${sat.satisFaturaTarihi ? `<span class="tarih">📅 ${sat.satisFaturaTarihi.slice(0, 10)}</span>` : ""}
            ${sat.satisIrsaliyeNo ? `<span class="tarih">📦 ${sat.satisIrsaliyeNo}</span>` : ""}

          </li>
        `;
      });

      block.innerHTML += `</ul></div>`;
    }
      
    } else {
      block.innerHTML += `<div class="label-red">🚫 Teklif Yok</div>`;
    }

    container.appendChild(block);
  });
}
console.log("Hazırlanan veri:");
document.getElementById("filterInput").addEventListener("input", e => {
  renderList(e.target.value);
});

renderList();
</script>