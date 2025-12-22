
<cfquery name="HAZIRLIK1" datasource="#dsn#">
   IF OBJECT_ID('CMP_PRICE_ALL', 'U') IS NOT NULL
    DROP TABLE CMP_PRICE_ALL;

    SELECT  CAST(PRICE_OTHER AS DECIMAL(18,2)) AS PRICE,INVOICE_DATE,STOCK_ID,COMPANY_ID INTO CMP_PRICE_ALL FROM (
SELECT PRICE_OTHER,INVOICE_ROW.OTHER_MONEY,INVOICE.INVOICE_DATE,STOCK_ID,COMPANY_ID FROM #dsn2#.INVOICE_ROW 
INNER JOIN #dsn2#.INVOICE ON INVOICE.INVOICE_ID=INVOICE_ROW.INVOICE_ID
WHERE INVOICE.PURCHASE_SALES=1-- AND STOCK_ID=75 AND COMPANY_ID=9
UNION ALL
SELECT PRICE_OTHER,INVOICE_ROW.OTHER_MONEY,INVOICE.INVOICE_DATE,STOCK_ID,COMPANY_ID FROM #dsn#_#year(now())-1#_#session.ep.company_id#.INVOICE_ROW 
INNER JOIN #dsn#_#year(now())-1#_#session.ep.company_id#.INVOICE ON INVOICE.INVOICE_ID=INVOICE_ROW.INVOICE_ID
WHERE INVOICE.PURCHASE_SALES=1 --AND STOCK_ID=75 AND COMPANY_ID=9
) AS T


</cfquery>

<cfquery name="GETDEMAND_MONEY" datasource="#dsn3#">
  SELECT OTHER_MONEY,FROM_COMPANY_ID FROM #dsn3#.INTERNALDEMAND WHERE INTERNAL_ID=#attributes.internal_id#
</cfquery>
<cfquery name="getComppanyPriceCat" datasource="#DSN3#">
SELECT PRICE_CAT FROM #dsn#.COMPANY_CREDIT WHERE COMPANY_ID=#GETDEMAND_MONEY.FROM_COMPANY_ID#

</cfquery>
<CFSET CMPRICE_ID=1>
<cfif getComppanyPriceCat.recordCount>
<cfset CMPRICE_ID=getComppanyPriceCat.PRICE_CAT>
</cfif>


<cfquery name="getMainPurchaseOffer" datasource="#DSN3#">
SELECT ( SELECT * FROM (
SELECT C.FULLNAME, C.COMPANY_ID, OFFER_ID,
(
    
SELECT OFFER_ROW.PRODUCT_NAME
,CAST(PRICE AS DECIMAL(18, 2)) AS PRICE
	, CAST(PRICE_OTHER AS DECIMAL(18, 2)) AS PRICE_OTHER
	, OTHER_MONEY
	, OFFER_ROW.PRODUCT_ID
	, OFFER_ROW.STOCK_ID
  ,OFFER_ROW.DETAIL_INFO_EXTRA  AS OEM_NO 
  ,(SELECT TOP 1 PRICE FROM #DSN#.CMP_PRICE_ALL WHERE STOCK_ID=OFFER_ROW.STOCK_ID AND COMPANY_ID=#GETDEMAND_MONEY.FROM_COMPANY_ID# AND PRICE>0 ORDER BY INVOICE_DATE DESC) AS LAST_PRICE
	, WRK_ROW_ID
  ,#dsn3#.fnGetSelectInfoExtra(WRK_ROW_ID) AS SELECT_INFO_EXTRA
  ,ISNULL((SELECT BASKET_INFO_TYPE FROM #dsn3#.SETUP_BASKET_INFO_TYPES WHERE BASKET_INFO_TYPE_ID=(#dsn3#.fnGetSelectInfoExtra(WRK_ROW_ID))),'') AS BASKET_INFO_TYPE
  ,ISNULL(S.PRODUCT_CODE_2,'')PRODUCT_CODE_2
	, CAST(DISCOUNT_1 AS DECIMAL(18, 2)) AS DISCOUNT_1
	, CAST(OFFER_ROW.TAX AS DECIMAL(18, 2)) AS TAX
	, CAST(QUANTITY AS DECIMAL(18, 2)) AS QUANTITY
  , CAST(ISNULL(ISNULL(GPA_PRICE,0)*R2,-1) AS DECIMAL(18,2)) AS  NET_PRICE
  ,CAST(PRICE - (PRICE * DISCOUNT_1 / 100) AS DECIMAL(18, 2)) AS ONET_PRICE_2
	, CAST(ISNULL(GPA_PRICE,-1) AS DECIMAL(18,2)) AS  NET_PRICEXX 
   ,CASE WHEN (SELECT TOP 1 (SELECT COUNT(*) FROM #dsn3#.ORDER_ROW WHERE WRK_ROW_RELATION_ID=OFR2.WRK_ROW_ID+'_XX') FROM #dsn3#.OFFER_ROW OFR2 WHERE WRK_ROW_RELATION_ID=OFFER_ROW.WRK_ROW_ID <cfif len(attributes.last_offer_id)>AND OFFER_ID=#attributes.last_offer_id#</cfif>) >0	THEN 1 ELSE 0 END AS SNT_S
	,ISNULL(PB.BRAND_NAME,'') AS BRAND_NAME
  , CASE 
		WHEN (
				SELECT COUNT(*)
    FROM #dsn3#.PBS_SELECTED_ROWS
    WHERE WRK_ROW_ID = OFFER_ROW.WRK_ROW_ID
				) > 0
			THEN 1
		ELSE 0
		END AS IS_SELECTED
    ,ISNULL((SELECT IS_OS FROM PBS_SELECTED_ROWS WHERE WRK_ROW_ID = OFFER_ROW.WRK_ROW_ID),1) AS IS_OS
, ISNULL((CASE 
						WHEN (
								SELECT COUNT(*)
    FROM #dsn3#.OFFER_ROW AS TTTTTTT
    WHERE WRK_ROW_RELATION_ID = OFFER_ROW.WRK_ROW_ID
     <cfif LEN(attributes.last_offer_id)>
    AND OFFER_ID = #attributes.last_offer_id#
    </cfif>
								) > 0
							THEN 1
						ELSE 0
						END),0) AS IS_SATINALMA
, ISNULL((
							SELECT CAST(PRODUCT_MARJ AS DECIMAL(18, 2)) AS PRODUCT_MARJ
								, CAST(SALE_PRICE AS DECIMAL(18, 2)) AS SALE_PRICE
                , CAST(ISNULL(DSC1,0) AS DECIMAL(18, 2)) AS DSC1
                , CAST(ISNULL(DSC2,0) AS DECIMAL(18, 2)) AS DSC2
                , CAST(ISNULL(DSC3,0) AS DECIMAL(18, 2)) AS DSC3
    FROM #dsn3#.PBS_SELECTED_ROWS
    WHERE WRK_ROW_ID = OFFER_ROW.WRK_ROW_ID
    FOR JSON AUTO
							), '[]') AS SLP
					, ISNULL((
							SELECT *
    FROM (
								            SELECT PRODUCT_ID
            FROM #dsn3#.ALTERNATIVE_PRODUCTS
            WHERE PRODUCT_ID = OFFER_ROW.PRODUCT_ID
                OR ALTERNATIVE_PRODUCT_ID = OFFER_ROW.PRODUCT_ID

        UNION ALL

            SELECT ALTERNATIVE_PRODUCT_ID PRODUCT_ID
            FROM #dsn3#.ALTERNATIVE_PRODUCTS
            WHERE PRODUCT_ID = OFFER_ROW.PRODUCT_ID
                OR ALTERNATIVE_PRODUCT_ID = OFFER_ROW.PRODUCT_ID
								) AS TABLO
    FOR JSON PATH
							), '[]') AS ALTERNATIFLER,
              GPA.*
             
FROM #dsn3#.OFFER_ROW
LEFT JOIN #dsn3#.STOCKS AS S ON S.STOCK_ID=OFFER_ROW.STOCK_ID
LEFT JOIN #dsn1#.PRODUCT_BRANDS  AS PB ON PB.BRAND_ID =S.BRAND_ID
LEFT JOIN
            (
                SELECT
                    P.UNIT									GPA_UNIT,
                    CAST(P.PRICE AS DECIMAL(18,2))			GPA_PRICE,
                    CAST(P.PRICE_KDV AS DECIMAL(18,2))		GPA_PRICE_KDV,
                    P.PRODUCT_ID							GPA_PRODUCT_ID,
                    P.MONEY									GPA_MONEY,
                    P.PRICE_CATID							GPA_PRICE_CATID,
                    P.CATALOG_ID							GPA_CATALOG_ID,
                    CAST(P.PRICE_DISCOUNT AS DECIMAL(18,2))	GPA_DISCOUNT,
                    #dsn3#.GET_DISCOUNT_RATE(#GETDEMAND_MONEY.FROM_COMPANY_ID#,#CMPRICE_ID#,P.PRODUCT_ID) AS DSC_OX,
                    #dsn3#.GET_DISCOUNT_RATE2(#GETDEMAND_MONEY.FROM_COMPANY_ID#,#CMPRICE_ID#,P.PRODUCT_ID) AS DSC_OX2,
                    'ODL='+CAST(#dsn3#.GET_DISCOUNT_RATE(TRY_CAST(REPLACE(O.OFFER_TO, ',', '') AS INT),P.PRICE_CATID,P.PRODUCT_ID) AS VARCHAR)+'|PRC='+CAST(P.PRICE AS VARCHAR)+'|DSC='+CAST(P.PRICE_DISCOUNT AS VARCHAR)+'|CAT='+CAST(P.PRICE_CATID AS VARCHAR)+'|CID='+CAST(TRY_CAST(REPLACE(O.OFFER_TO, ',', '') AS INT) AS VARCHAR)+'|PID='+CAST(P.PRODUCT_ID AS VARCHAR) AS ODL_INFO,
                    'ODL_2='+CAST(#dsn3#.GET_DISCOUNT_RATE(#GETDEMAND_MONEY.FROM_COMPANY_ID#,#CMPRICE_ID#,P.PRODUCT_ID) AS VARCHAR)+'|PRC='+CAST(P.PRICE AS VARCHAR)+'|DSC='+CAST(P.PRICE_DISCOUNT AS VARCHAR)+'|CAT='+CAST(P.PRICE_CATID AS VARCHAR)+'|CID='+CAST(#GETDEMAND_MONEY.FROM_COMPANY_ID# AS VARCHAR)+'|PID='+CAST(P.PRODUCT_ID AS VARCHAR) AS ODL_INFO_2,
                    (			SELECT 
            
             (SELECT  CONVERT(DECIMAL(18,2),RATE2)  RATE2 FROM #dsn#.MONEY_HISTORY WHERE MONEY_HISTORY_ID=(
             SELECT MAX(MONEY_HISTORY_ID) FROM #dsn#.MONEY_HISTORY WHERE MONEY=SM.MONEY) )AS RATE2
             
             FROM #dsn#.SETUP_MONEY AS SM WHERE SM.PERIOD_ID=#session.ep.PERIOD_ID#
			 AND MONEY=p.MONEY) as R2
                FROM
                    #dsn3#.PRICE P,
                    #dsn3#.PRODUCT PR
                WHERE
                    P.PRODUCT_ID = PR.PRODUCT_ID
                    AND P.PRICE_CATID = #CMPRICE_ID#
                    AND
                    (
                        P.STARTDATE <= convert(date,getdate())
                        AND
                        (
                            P.FINISHDATE >= convert(date,getdate()) OR
                            P.FINISHDATE IS NULL
                        )
                    )
                    AND ISNULL(P.SPECT_VAR_ID, 0) = 0 
            ) AS GPA ON GPA.GPA_PRODUCT_ID = OFFER_ROW.PRODUCT_ID AND GPA.GPA_UNIT = OFFER_ROW.UNIT_ID
WHERE OFFER_ID = O.OFFER_ID AND ISNULL(OFFER_ROW.SELECT_INFO_EXTRA,0) =4
FOR JSON PATH
) AS URUNLER
FROM #dsn3#.OFFER AS O
    LEFT JOIN #dsn#.COMPANY AS C ON C.COMPANY_ID = TRY_CAST(REPLACE(O.OFFER_TO, ',', '') AS INT)

WHERE FOR_OFFER_ID IN (
    SELECT OFFER_ID
FROM #dsn3#.OFFER
WHERE INTERNALDEMAND_ID=#attributes.internal_id#
)
) AS T  
WHERE LEN(URUNLER)>0
FOR JSON PATH

)AS QRESULT


  </cfquery>
  
  
  <span style="display:none">depodan_tedarik.cfm</span>
<cfif len(getMainPurchaseOffer.QRESULT) EQ 0>
    <div class="alert alert-warning">Bu Talep İçin Depodan Teslim Edilecek Ürün Bulunmamaktadır</div><cfabort>
</cfif>
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
    .net-price.invalid {
      color: red !important;
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
            <button class="ui-wrk-btn ui-wrk-btn-success" id="send-btn3">Kaydet</button>
            


<script>
  var DEMAND_MONEY = '<cfoutput>#GETDEMAND_MONEY.OTHER_MONEY#</cfoutput>';
</script>

          
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
  </div>
  </div>
  

  
  
  <input type="hidden" id="offer_id" name="offer_id" value="<cfoutput>#attributes.internal_id#</cfoutput>">

  <cfset MONEYARRRR=arrayNew(1)>
            <cfquery name="getMoneyext" datasource="#dsn3#">
                SELECT 
             (SELECT RATE1 FROM #dsn#.MONEY_HISTORY WHERE MONEY_HISTORY_ID=(
             SELECT MAX(MONEY_HISTORY_ID) FROM #dsn#.MONEY_HISTORY WHERE MONEY=SM.MONEY) )AS RATE1,
             (SELECT RATE2 FROM #dsn#.MONEY_HISTORY WHERE MONEY_HISTORY_ID=(
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
  var session_variables=<cfoutput>#replace(serializeJSON(session),"//","")#</cfoutput>;
  var data = <cfoutput>#getMainPurchaseOffer.QRESULT#</cfoutput>
  var MONEYARRRR=<cfoutput>#replace(serializeJSON(MONEYARRRR),"//","")#</cfoutput>;
  var BEI = 4;
</script>
<script>
  <cfinclude template="depodan_tedarik.js">
</script>


