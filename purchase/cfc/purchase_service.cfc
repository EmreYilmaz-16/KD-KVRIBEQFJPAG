<!---
/**
 * PurchaseService Component
 * Handles purchase-related operations.
 *
 * Functions:
 * 1. savePurchaseOfferSelector
 *    - Saves selected purchase offers.
 *    - Access: Remote
 *    - Return Type: Struct (JSON)
 *    - HTTP Method: POST
 *    - Parameters:
 *        - payload: JSON payload containing purchase offer data.
 *    - Returns: A response struct with success or error details.
 *
 * 2. savePurchaseOfferSelectorOnly
 *    - Saves selected purchase offers without additional processing.
 *    - Access: Remote
 *    - Return Type: Struct (JSON)
 *    - HTTP Method: POST
 *    - Parameters:
 *        - payload: JSON payload containing purchase offer data.
 *    - Returns: A response struct with success or error details.
 *
 * 3. getByProductId
 *    - Retrieves alternative product IDs for a given product ID.
 *    - Access: Remote
 *    - Return Type: Array (JSON)
 *    - HTTP Method: POST
 *    - Parameters:
 *        - product_id: String (Required) - The ID of the product.
 *    - Returns: An array of alternative product IDs.
 *
 * 4. savePurchaseOffer
 *    - Saves purchase offers based on provided payload.
 *    - Access: Remote
 *    - Return Type: Struct (JSON)
 *    - HTTP Method: POST
 *    - Parameters:
 *        - payload: JSON payload containing purchase offer data.
 *    - Returns: A response struct with success or error details.
 *
 * Notes:
 * - The component uses multiple database queries to process and save purchase offers.
 * - Error handling is implemented using <cftry> and <cfcatch>.
 * - Logs are written to the "purchaseService" log file for debugging and error tracking.
 */
--->
<cfcomponent displayname="PurchaseService" output="false" hint="Handles purchase-related operations">
   
   
    <cfset wrk_eval = application.functions.wrk_eval>
    <cfset workcube_mode=0>
      <cfscript>
        variables.dsn  = "";
        variables.dsn2 = "";
        variables.dsn3 = "";
        variables.OUR_COMPANY_ID = "";
    </cfscript>

      <cffunction name="init" access="public" returntype="any" output="false" hint="Init component and set datasources">
        <cfscript>
            setDatasources();
            return this;
        </cfscript>
    </cffunction>

    <cffunction name="setDatasources" access="public" returntype="void" output="false"
                hint="Reads base DSN from file and builds dsn2/dsn3 dynamically">

        <!--- Lokal değişken --->
        <cfset var configContent = "">

        <!--- DSN temel adını dosyadan al --->
        <cffile 
            action="read" 
            file="#ExpandPath('/pbs_dsn.txt')#" 
            variable="configContent">

        <!--- Örn: w3qa --->
        <cfset variables.dsn = trim(configContent)>

        <!--- Şirket id’yi al --->
        <cfquery name="getParams" datasource="#variables.dsn#">
            SELECT PBS_MODUL_COMPANY_ID 
            FROM PBS_PARAMETERS
        </cfquery>

        <!--- Örn: w3qa_1 --->
        <cfset variables.dsn3 = "#variables.dsn#_#getParams.PBS_MODUL_COMPANY_ID#">

        <!--- Örn: w3qa_2025_1 --->
        <cfset variables.dsn2 = "#variables.dsn#_#year(now())#_#getParams.PBS_MODUL_COMPANY_ID#">
        <cfset variables.OUR_COMPANY_ID = getParams.PBS_MODUL_COMPANY_ID>

    </cffunction>


<cffunction name="saveSaleOfferFromSelectedRows" access="remote" returntype="struct" output="false" hint="Saves selected purchase offers" returnFormat="json" httpMethod="POST">
   

            <cfinclude template="saveSaleOfferFromSelectedRows.cfm">
        
            <cfset response.res = "success">
            <cfset response.message = "Purchase offers saved successfully.">
            <cfset response.data = attributes>
            <cfreturn response>
</cffunction>
    <cffunction name="savePurchaseOfferSelector" access="remote" returntype="struct" output="false" hint="Saves selected purchase offers" returnFormat="json" httpMethod="POST">
         <cfscript>
         if (!len(variables.dsn)) {
                setDatasources();
            }
              dsn  = variables.dsn;
                dsn2 = variables.dsn2;
                dsn3 = variables.dsn3;
                ourcmpny = variables.our_company_id;
    </cfscript>  
        <cfset var response = {}>
        <cfset arguments.payload = getHTTPRequestData().content>

        <cftry>
            <!-- Deserialize JSON payload if it's a string -->
        <cfinclude template="savePurchaseOfferSelector.cfm">            

            <!-- Set success response -->
            <cfset response.res = "success">
            <cfset response.message = "Purchase offers saved successfully.">
            <cfset response.data = attributes>
            <cfreturn response>
        <cfcatch>
            <!-- Handle errors -->
            <cfset response.res = "error">
            <cfset response.message = cfcatch>
            <cflog file="purchaseService" text="Error: #cfcatch.message#" type="error">
        </cfcatch>
        </cftry>

        <cfreturn response>
    </cffunction>

    <cffunction name="savePurchaseOfferSelectorOnly" access="remote" returntype="struct" output="false" hint="Saves selected purchase offers" returnFormat="json" httpMethod="POST">
         <cfscript>
         if (!len(variables.dsn)) {
                setDatasources();
            }
              dsn  = variables.dsn;
                dsn2 = variables.dsn2;
                dsn3 = variables.dsn3;
                ourcmpny = variables.our_company_id;
    </cfscript>  
        <cfset var response = {}>
        <cfset arguments.payload = getHTTPRequestData().content>

        <cftry>
         <cfinclude template="savePurchaseOfferSelectorOnly.cfm">            


            <!-- Set success response -->
            <cfset response.res = "success">
            <cfset response.message = "Purchase offers saved successfully.">
            <cfset response.data = attributes>
        <cfcatch>
            <!-- Handle errors -->
            <cfset response.res = "error">
            <cfset response.message = cfcatch>
            <cflog file="purchaseService" text="Error: #cfcatch.message#" type="error">
        </cfcatch>
        </cftry>

        <cfreturn response>
    </cffunction>



    <cffunction name="getByProductId" access="remote" returntype="array" output="false" httpMethod="POST" returnFormat="json">
        

        <cfargument name="product_id" type="string" required="true">
         <cfscript>
         if (!len(variables.dsn)) {
                setDatasources();
            }
              dsn  = variables.dsn;
                dsn2 = variables.dsn2;
                dsn3 = variables.dsn3;
                ourcmpny = variables.our_company_id;
    </cfscript>  

        <cfset var result = []>

        <cfquery name="qAlt" datasource="#dsn3#">
            SELECT ALTERNATIVE_PRODUCT_ID as ALTERNATIF_PRODUCT_ID
            FROM #dsn3#.ALTERNATIVE_PRODUCTS
            WHERE PRODUCT_ID = <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_varchar">
        </cfquery>

        <cfloop query="qAlt">
            <cfset arrayAppend(result, qAlt.ALTERNATIF_PRODUCT_ID)>
        </cfloop>

        <cfreturn result>
    </cffunction>

    <cffunction name="savePurchaseOffer" access="remote" returntype="struct" output="false" hint="Saves selected purchase offers" returnFormat="json" httpMethod="POST">
 <cfscript>
         if (!len(variables.dsn)) {
                setDatasources();
            }
              dsn  = variables.dsn;
                dsn2 = variables.dsn2;
                dsn3 = variables.dsn3;
                ourcmpny = variables.our_company_id;
    </cfscript>  
        <cfset var response = {}>
        <cfset arguments.payload = getHTTPRequestData().content>
        <cfdump var="#arguments.payload#">
        <cfset arguments.payload = deserializeJSON(arguments.payload)>
        
        <cfset session=arguments.payload.payload.session>
        <cfset var products = arguments.payload.payload.products>
        <cfset var company_id = arguments.payload.payload.company_ids>
        <cfquery name="getOffer" datasource="#dsn3#" result="RES">
            SELECT * FROM OFFER_ROW
            LEFT JOIN  #dsn3#.PRODUCT_UNIT AS PU ON PU.PRODUCT_ID=OFFER_ROW.PRODUCT_ID AND IS_MAIN=1
            LEFT JOIN #dsn3#.STOCKS AS P ON P.PRODUCT_ID=OFFER_ROW.PRODUCT_ID
             WHERE OFFER_ID=#arguments.payload.payload.for_offer_id#
        </cfquery>

        <cfloop  query="getOffer">
            <CFSET "PID_#getOffer.WRK_ROW_ID#"=getOffer.PRODUCT_ID>
            <CFSET "SID_#getOffer.WRK_ROW_ID#"=getOffer.STOCK_ID>
            <cfset "PRODUCT_NAME_#getOffer.WRK_ROW_ID#"=getOffer.PRODUCT_NAME>
            <cfset "PRODUCT_UNIT_#getOffer.WRK_ROW_ID#"=getOffer.PRODUCT_UNIT>
            <cfset "PRODUCT_UNIT_ID_#getOffer.WRK_ROW_ID#"=getOffer.PRODUCT_UNIT_ID>
            <CFSET "TAX_PURCHASE_#getOffer.WRK_ROW_ID#"=getOffer.TAX_PURCHASE>
            <cfset "QUANTITY_#getOffer.WRK_ROW_ID#"=getOffer.QUANTITY>
            <CFSET "OTHER_MONEY_#getOffer.WRK_ROW_ID#"=getOffer.OTHER_MONEY>
        </cfloop>
        <cfset ix=0>
        <cfloop array="#products#" item="product">
            <cfset AwrkRowId=product>
            <cfscript>
                ix=ix+1;
                attributes["product_id#ix#"] = evaluate("PID_#AwrkRowId#");
                attributes["stock_id#ix#"] = evaluate("SID_#AwrkRowId#");
                attributes["product_name#ix#"] = evaluate("PRODUCT_NAME_#AwrkRowId#");
                attributes["unit#ix#"] = evaluate("PRODUCT_UNIT_#AwrkRowId#");
                attributes["unit_id#ix#"] = evaluate("PRODUCT_UNIT_ID_#AwrkRowId#");
                attributes["price#ix#"] = 0;
                attributes["price_other#ix#"] = 0;
                attributes["tax#ix#"] = evaluate("TAX_PURCHASE_#AwrkRowId#");
                attributes["amount#ix#"] = evaluate("QUANTITY_#AwrkRowId#");
                attributes["indirim1#ix#"] = 0;
                attributes["other_money_#ix#"] = evaluate("OTHER_MONEY_#AwrkRowId#");
                attributes["other_money_value_#ix#"] = 0;
                attributes["description#ix#"] = "";
                attributes["wrk_row_id#ix#"] = "PBS#session.ep.userid##dateFormat(now(), 'yyyymmdd')##timeFormat(now(), 'hhmmnnl')#";
                attributes["wrk_row_relation_id#ix#"] = AwrkRowId;
                attributes["is_virtual#ix#"] = 0;
                attributes["SHELF_CODE#ix#"] = "";
                attributes["OFFER_ROW_CURRENCY#ix#"] = "";


            </cfscript>
            

        </cfloop>
        <cfset attributes.rows_=ix>
        <cfquery name="GETCOMPANY" datasource="#dsn#">
            select CASE WHEN LEN(COMPANY_ADDRESS)=0 THEN '-'ELSE ISNULL(COMPANY_ADDRESS,'-') END AS COMPANY_ADDRESS,CITY,COUNTY from #dsn#.COMPANY WHERE COMPANY_ID=#company_id#
        </cfquery>

<cfset attributes.offer_date=now()>
<cfset attributes.deliverdate=now()>
<cfset attributes.ship_date=now()>
<cfset attributes.finishdate=now()>
<cfset company_ids=",#arguments.payload.payload.company_ids#,">
<cfscript>
    DISCOUNT_TOTAL=0;
    GROSS_TOTAL=0;
    SUBNETTOTAL=0;
    SUBTAXTOTAL=0;
    SUBTOTAL=0;
    TAX_TOTAL=0;
    TOTAL_WITHOUT_KDV=0;
    TOTAL_WITH_KDV=0;
    BASKET_NET_TOTAL=0;
    BASKET_NET_TOTAL_=0;
    BASKET_TAX_TOTAL=0;
    BASKET_TAX_TOTAL_=0;
</cfscript>
<CFLOOP from="1" to="#attributes.rows_#" index="ix">
    <cfset PRICE=evaluate("attributes.price#ix#")>
    <cfset PRICE_OTHER=evaluate("attributes.price_other#ix#")>
    <cfset TAX=evaluate("attributes.tax#ix#")>
    <CFSET AMOUNT=evaluate("attributes.amount#ix#")>
    <CFSET DISCOUNT=evaluate("attributes.indirim1#ix#")>
    <CFSET OTHER_MONEY=evaluate("attributes.other_money_#ix#")>
    <cfscript>
     SATIR_KUR= arrayFilter(MONEYARRRR, function(item) {
            return item.MONEY == OTHER_MONEY;
        })[1];
    OLD_SATIR_KUR= SATIR_KUR;
    </cfscript>

    <CFSET PR_HESAP=PRICE_OTHER*SATIR_KUR.RATE2>
    <cfset ox=structNew()>
    <cfset ox.PRICE=PRICE>
    <cfset ox.PRICE_=PR_HESAP>
    <cfscript>
        dp=PRICE-(PRICE*DISCOUNT)/100;  
        dp_=PR_HESAP-(PR_HESAP*DISCOUNT)/100;                    

        TUTAR=dp*AMOUNT;
        TUTAR_=dp_*AMOUNT;

        TX=(TUTAR*TAX)/100
        TX_=(TUTAR_*TAX)/100
        ox.DP=dp;
        ox.DP_=dp_;
        ox.TUTAR=TUTAR;
        ox.TUTAR_=TUTAR_;
        OX.OTM_V=TUTAR/OLD_SATIR_KUR.RATE2;
        OX.OTM_V_=TUTAR_/SATIR_KUR.RATE2;
        ox.TX=TX;
        ox.TX_=TX_;
        BASKET_TAX_TOTAL=BASKET_TAX_TOTAL+TX;
        BASKET_TAX_TOTAL_=BASKET_TAX_TOTAL_+TX_;
        BASKET_NET_TOTAL=BASKET_NET_TOTAL+(TUTAR+TX);
        BASKET_NET_TOTAL_=BASKET_NET_TOTAL_+(TUTAR_+TX_);

        "attributes.other_money_value_#ix#"=ox.OTM_V_;
        "attributes.price#ix#"=ox.PRICE_;
    </cfscript>
    


    



</CFLOOP>



        


        <cfreturn RES>




    </cffunction>
    <cffunction name="SAVEORDER_gpt" access="remote" returntype="struct" output="false" hint="Saves selected purchase offers" returnFormat="json" httpMethod="POST">
        <cfargument name="internal_id" type="numeric" required="true">
         <cfscript>
         if (!len(variables.dsn)) {
                setDatasources();
            }
              dsn  = variables.dsn;
                dsn2 = variables.dsn2;
                dsn3 = variables.dsn3;
                ourcmpny=variables.our_company_id;
    </cfscript>  
    <cfquery name="getParameters" datasource="#dsn#">
        SELECT  * FROM PBS_PARAMETERS
    </cfquery>
      <cfset var response = {}>
        <cfset var dsn = variables.dsn>
        <cfset var dsn3 = variables.dsn3>
        <cfset var attributes = {}>
    <cftry>
        <!--- Teklif satırlarını çek --->
        <cfquery name="getSelectedRows" datasource="#dsn3#">
SELECT 
    TRY_CAST(REPLACE(O_ALIS_TEKLIFI.OFFER_TO, ',', '') AS INT) AS COMPANY_ID,
    TRY_CAST(REPLACE(O_ALIS_TEKLIFI.OFFER_TO_PARTNER, ',', '') AS INT) AS PARTNER_ID,
    ORR_SATIS_TEKLIFI.*,
	PSR.OFFER_ID,
    PSR.BASKET_EXTRA_INFO
    --PSR.SOME_COLUMN_1, -- Kullanmak istediğin PBS_SELECTED_ROWS alanlarını buraya ekle
    --PSR.SOME_COLUMN_2
FROM #dsn3#.PBS_SELECTED_ROWS AS PSR
INNER JOIN #dsn3#.OFFER_ROW AS ORR_SATIS_TEKLIFI 
    ON PSR.WRK_ROW_ID = ORR_SATIS_TEKLIFI.WRK_ROW_RELATION_ID AND ORR_SATIS_TEKLIFI.OFFER_ID= #arguments.last_offer_id#
LEFT JOIN #dsn3#.OFFER_ROW AS ORR_ALIS_TEKLIFI 
    ON ORR_ALIS_TEKLIFI.WRK_ROW_ID = ORR_SATIS_TEKLIFI.WRK_ROW_RELATION_ID
LEFT JOIN #dsn3#.OFFER AS O_ALIS_TEKLIFI 
    ON O_ALIS_TEKLIFI.OFFER_ID = ORR_ALIS_TEKLIFI.OFFER_ID
WHERE PSR.OFFER_ID =<cfqueryparam value="#arguments.internal_id#" cfsqltype="cf_sql_integer"> AND PSR.BASKET_EXTRA_INFO <>#getParameters.DEPO_TESLIM_ID#  ORDER BY COMPANY_ID


        </cfquery>
        <cfquery name="GETIDEMAND" datasource="#dsn3#">
                SELECT FROM_COMPANY_ID,FROM_PARTNER_ID,DEPARTMENT_IN,LOCATION_IN,
                (select MONEY_TYPE, CAST(RATE2 AS DECIMAL(18,2)) AS RATE2,CAST(RATE1 AS DECIMAL(18,2)) AS RATE1 FROM #dsn3#.INTERNALDEMAND_MONEY  WHERE ACTION_ID=INTERNAL_ID AND IS_SELECTED=1 FOR JSON PATH) AS PARA
                FROM #dsn3#.INTERNALDEMAND
                WHERE INTERNAL_ID =#arguments.internal_id#
            </cfquery>
        <!---<cfquery name="getSelectedRows" datasource="#dsn3#">
            SELECT 
                TRY_CAST(REPLACE(O_ALIS_TEKLIFI.OFFER_TO, ',', '') AS INT) AS COMPANY_ID,
                TRY_CAST(REPLACE(O_ALIS_TEKLIFI.OFFER_TO_PARTNER, ',', '') AS INT) AS PARTNER_ID,
                ORR_SATIS_TEKLIFI.*
            FROM OFFER_ROW AS ORR_SATIS_TEKLIFI
            LEFT JOIN OFFER_ROW AS ORR_ALIS_TEKLIFI ON ORR_ALIS_TEKLIFI.WRK_ROW_ID = ORR_SATIS_TEKLIFI.WRK_ROW_RELATION_ID
            LEFT JOIN OFFER AS O_ALIS_TEKLIFI ON O_ALIS_TEKLIFI.OFFER_ID = ORR_ALIS_TEKLIFI.OFFER_ID
            WHERE ORR_SATIS_TEKLIFI.WRK_ROW_RELATION_ID IN (
                SELECT WRK_ROW_ID FROM PBS_SELECTED_ROWS WHERE OFFER_ID = <cfqueryparam value="#arguments.internal_id#" cfsqltype="cf_sql_integer">)
            ORDER BY COMPANY_ID
        </cfquery>----->
    
        <!--- Kur bilgilerini çek --->
        <cfquery name="getMoneyext" datasource="#dsn3#">
            SELECT 
                SM.MONEY,
                (SELECT TOP 1 RATE1 FROM #dsn#.MONEY_HISTORY WHERE MONEY = SM.MONEY ORDER BY MONEY_HISTORY_ID DESC) AS RATE1,
                (SELECT TOP 1 EFFECTIVE_SALE FROM #dsn#.MONEY_HISTORY WHERE MONEY = SM.MONEY ORDER BY MONEY_HISTORY_ID DESC) AS RATE2
            FROM #dsn#.SETUP_MONEY AS SM
            WHERE SM.PERIOD_ID = <cfqueryparam value="#session.ep.period_id#" cfsqltype="cf_sql_integer">
        </cfquery>
    
        <!--- Kur Struct Oluştur (KurMap) --->
        <cfset var kurMap = structNew()>
        <cfloop query="getMoneyext">
            <cfset kurMap[getMoneyext.MONEY] = {
                RATE1 = getMoneyext.RATE1,
                RATE2 = getMoneyext.RATE2
            }>
        </cfloop>
    
        <!--- Şirket bazlı loop başlat --->
        <cfloop query="getSelectedRows" group="COMPANY_ID">
            <cfset var ix = 0>
            <cfset var rows_ = 0>
            <cfset var BASKET_NET_TOTAL = 0>
            <cfset var BASKET_NET_TOTAL_ = 0>
            <cfset var BASKET_TAX_TOTAL = 0>
            <cfset var BASKET_TAX_TOTAL_ = 0>
            <cfset var nowTS = now()>
    
            <!--- Ürünleri dön --->
            <cfloop >
                <cfif 1 eq 1>
                    <cfset ix++>
                    <cfset otherMoney = getSelectedRows.OTHER_MONEY>
                    <cfset satirKur = structKeyExists(kurMap, otherMoney) ? kurMap[otherMoney] : {RATE1=1, RATE2=1}>
    
                    <cfset PRICE_OTHER = getSelectedRows.PRICE_OTHER>
                    <cfset PRICE = getSelectedRows.PRICE>
                    <cfset AMOUNT = getSelectedRows.QUANTITY>
                    <cfset TAX = getSelectedRows.TAX>
                    <cfset DISCOUNT = 0>
                    <cfset PR_HESAP = PRICE_OTHER * satirKur.RATE2>
    
                    <cfset dp = PRICE - ((PRICE * DISCOUNT) / 100)>
                    <cfset dp_ = PR_HESAP - ((PR_HESAP * DISCOUNT) / 100)>
                    <cfset TUTAR = dp * AMOUNT>
                    <cfset TUTAR_ = dp_ * AMOUNT>
                    <cfset TX = (TUTAR * TAX) / 100>
                    <cfset TX_ = (TUTAR_ * TAX) / 100>
    
                    <!--- Toplamları güncelle --->
                    <cfset BASKET_TAX_TOTAL += TX>
                    <cfset BASKET_TAX_TOTAL_ += TX_>
                    <cfset BASKET_NET_TOTAL += TUTAR + TX>
                    <cfset BASKET_NET_TOTAL_ += TUTAR_ + TX_>
    
                    <!--- Attributes içine yerleştir --->
                    <cfset attributes["product_id#ix#"] = getSelectedRows.PRODUCT_ID>
                    <cfset attributes["stock_id#ix#"] = getSelectedRows.STOCK_ID>
                    <cfset attributes["product_name#ix#"] = getSelectedRows.PRODUCT_NAME>
                    <cfset attributes["unit#ix#"] = getSelectedRows.UNIT>
                    <cfset attributes["unit_id#ix#"] = getSelectedRows.UNIT_ID>
                    <cfset attributes["price#ix#"] = PR_HESAP>
                    <cfset attributes["price_other#ix#"] = PRICE_OTHER>
                    <cfset attributes["tax#ix#"] = TAX>
                    <cfset attributes["amount#ix#"] = AMOUNT>
                    <cfset attributes["indirim1#ix#"] = DISCOUNT>
                    <cfset attributes["other_money_#ix#"] = otherMoney>
                    <cfset attributes["other_money_value_#ix#"] = TUTAR_ / satirKur.RATE2>
                    <cfset attributes["description#ix#"] = "">
                    <cfset attributes["wrk_row_id#ix#"] = "PBS#session.ep.userid##dateFormat(nowTS, 'yyyymmdd')##timeFormat(nowTS, 'hhmmssL')#_#ix#">
                    <cfset attributes["wrk_row_relation_id#ix#"] = "#getSelectedRows.WRK_ROW_ID#_XX">
                    <CFSET attributes["row_nettotal#ix#"] = PR_HESAP*AMOUNT>
                </cfif>
            </cfloop>
    
            <cfset attributes.rows_ = ix>
    
            <!--- Şirket Bilgilerini Ekle --->
            <cfquery name="GETCOMPANY" datasource="#dsn#">
                SELECT ISNULL(NULLIF(COMPANY_ADDRESS, ''), '-') AS COMPANY_ADDRESS, CITY, COUNTY,CC.SHIP_METHOD_ID
                FROM COMPANY
                LEFT JOIN #dsn#.COMPANY_CREDIT AS CC ON CC.COMPANY_ID = COMPANY.COMPANY_ID AND CC.OUR_COMPANY_ID = <cfqueryparam value="#ourcmpny#" cfsqltype="cf_sql_integer">
                WHERE COMPANY_ID = <cfqueryparam value="#getSelectedRows.COMPANY_ID#" cfsqltype="cf_sql_integer">
            </cfquery>
    
            <cfset attributes.company_id = getSelectedRows.COMPANY_ID>
            <cfset attributes.PARTNER_ID = getSelectedRows.PARTNER_ID>
            <cfset attributes.CONSUMER_ID ="">
            <cfset attributes.CONSUMER_NAME ="">
            <cfset attributes.ORDER_HEAD = "Siparişimiz">
            <cfset attributes.ORDER_DESCRIPTION = "">
            <cfset attributes.ORDER_DETAIL = "">
            <cfset attributes.order_date = nowTS>
            <cfset attributes.deliverdate = nowTS>
            <cfset attributes.PUBLISHDATE = nowTS>
            <cfset attributes.SHIP_METHOD_ID = #GETCOMPANY.SHIP_METHOD_ID#> <!----Risk ve Çalışma Bilgilerinden Alınacak ---->
            <cfset attributes.SHIP_METHOD = "kargo">
    
            <cfset attributes.BASKET_NET_TOTAL = BASKET_NET_TOTAL_>
            <cfset attributes.BASKET_TAX_TOTAL = BASKET_TAX_TOTAL_>
            <cfset attributes.BASKET_GROSS_TOTAL = BASKET_NET_TOTAL_ - BASKET_TAX_TOTAL_>
            <cfset attributes.BASKET_DISCOUNT_TOTAL = 0>
            <cfset attributes.PRICE = BASKET_NET_TOTAL_>
    
            <cfset attributes.ACTIVE_COMPANY = session.ep.company_id>
            <cfset attributes.DELIVER_DEPT_ID = GETIDEMAND.DEPARTMENT_IN>
            <cfset attributes.DELIVER_LOC_ID = GETIDEMAND.LOCATION_IN>
            <cfset attributes.DELIVER_DEPT_NAME = "ASDASD2">
            <cfset attributes.BASKET_MONEY = "TL">
            <cfset attributes.BASKET_RATE1 = 1>
            <cfset attributes.BASKET_RATE2 = 1>
            <cfset attributes.kur_say = getMoneyext.recordCount>
            <cfset attributes.internaldemand_id_list = ",#arguments.internal_id#,">
            <cfset attributes.process_stage = "#GET#">
    
            <!--- Kur bilgilerini tekrar setle --->
            <cfset i=1>
            <cfloop query="getMoneyext" >
                <cfset attributes["txt_rate1_#i#"] = RATE1>
                <cfset attributes["txt_rate2_#i#"] = RATE2>
                <cfset attributes["hidden_rd_money_#i#"] = MONEY>
                <cfset attributes["_hidden_rd_money_#i#"] = MONEY>
                <cfset i=i+1>
            </cfloop>
    
            <!--- Kağıt numarası üret --->
            <cfquery name="get_offer_number" datasource="#dsn3#">
                EXEC GET_PAPER_NUMBER 1
            </cfquery>
            <cfset attributes.PAPER_NO = get_offer_number.PAPER_NO>
    
            <!--- Siparişi oluştur --->
            <cfinclude template="../query/add_order.cfm">
    
            <!--- Temizle --->
            <cfscript>
                structClear(attributes);
            </cfscript>
        </cfloop>
         <!-- Set success response -->
            <cfset response.res = "success">
            <cfset response.message = "Purchase Orders saved successfully.">
            <cfset response.data = attributes>
        <cfcatch>
            <!-- Handle errors -->
            <cfset response.res = "error">
            <cfset response.message = cfcatch>
            <cflog file="purchaseService" text="Error: #cfcatch.message#" type="error">
        </cfcatch>
        </cftry>
        <cfreturn response>
    </cffunction>

<cffunction name="basket_kur_ekle">
	<cfargument name="action_id" required="true">
	<cfargument name="table_type_id" required="true">
	<cfargument name="process_type" required="true">
	<cfargument name="basket_money_db" type="string" default="">
	<cfargument name="transaction_dsn">
    <cfscript>
         if (!len(variables.dsn)) {
                setDatasources();
            }
              dsn  = variables.dsn;
                dsn2 = variables.dsn2;
                dsn3 = variables.dsn3;
                ourcmpny=variables.our_company_id;
    </cfscript> 

	<cfscript>
		switch (arguments.table_type_id){
			case 1: fnc_table_name="INVOICE_MONEY"; fnc_dsn_name="#dsn2#";break;
			case 2: fnc_table_name="SHIP_MONEY"; fnc_dsn_name="#dsn2#"; break;
			case 3: fnc_table_name="ORDER_MONEY"; fnc_dsn_name="#dsn3#"; break;
			case 4: fnc_table_name="OFFER_MONEY"; fnc_dsn_name="#dsn3#"; break;
			case 5: fnc_table_name="SERVICE_MONEY"; fnc_dsn_name="#dsn3#";break;
			case 6: fnc_table_name="STOCK_FIS_MONEY"; fnc_dsn_name="#dsn2#"; break;
			case 7: fnc_table_name="INTERNALDEMAND_MONEY"; fnc_dsn_name="#dsn3#"; break;
			case 8: fnc_table_name="CATALOG_MONEY"; fnc_dsn_name="#dsn3#"; break;
			case 10: fnc_table_name="SHIP_INTERNAL_MONEY"; fnc_dsn_name="#dsn2#"; break;	
			case 11: fnc_table_name="PAYROLL_MONEY"; fnc_dsn_name="#dsn2#"; break;
			case 12: fnc_table_name="VOUCHER_PAYROLL_MONEY"; fnc_dsn_name="#dsn2#"; break;
			case 13: fnc_table_name="SUBSCRIPTION_CONTRACT_MONEY"; fnc_dsn_name="#dsn3#"; break;			
			case 14: fnc_table_name="PRO_MATERIAL_MONEY"; fnc_dsn_name="#dsn#"; break;
		}
		if(len(arguments.basket_money_db))fnc_dsn_name = "#arguments.basket_money_db#";
	</cfscript>
	<cfif not (isdefined('arguments.transaction_dsn') and len(arguments.transaction_dsn))>
		<cfset arguments.transaction_dsn = fnc_dsn_name>
		<cfset arguments.action_table_dsn_alias = ''>
	<cfelse>
		<cfset arguments.action_table_dsn_alias = '#fnc_dsn_name#.'>
	</cfif>
	<cfif arguments.process_type eq 1>
		<cfquery name="del_money_obj_bskt" datasource="#arguments.transaction_dsn#">
			DELETE FROM 
				#arguments.action_table_dsn_alias##fnc_table_name#
			WHERE 
				ACTION_ID=#arguments.action_id#
		</cfquery>
	</cfif>
    
	<cfloop from="1" to="#attributes.kur_say#" index="fnc_i">
		<cfquery name="add_money_obj_bskt" datasource="#arguments.transaction_dsn#">
			INSERT INTO #arguments.action_table_dsn_alias##fnc_table_name# 
			(
				ACTION_ID,
				MONEY_TYPE,
				RATE2,
				RATE1,
				IS_SELECTED
			)
			VALUES
			(
				#arguments.action_id#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_eval('attributes.hidden_rd_money_#fnc_i#')#">,
				#evaluate("attributes.txt_rate2_#fnc_i#")#,
				#evaluate("attributes.txt_rate1_#fnc_i#")#,
				<cfif evaluate("attributes.hidden_rd_money_#fnc_i#") is attributes.BASKET_MONEY>
					1
				<cfelse>
					0
				</cfif>					
			)
		</cfquery>
	</cfloop>
</cffunction>
<cffunction name="add_internaldemand_row_relation" returntype="boolean" output="false">
        <cfscript>
         if (!len(variables.dsn)) {
                setDatasources();
            }
              dsn  = variables.dsn;
                dsn2 = variables.dsn2;
                dsn3 = variables.dsn3;
                ourcmpny=variables.our_company_id;
                dsn3_alias=variables.dsn3;
    </cfscript> 
	<cfargument name="internaldemand_id" default=""> <!--- ic talep id si --->
	<cfargument name="to_related_action_id" required="yes" default=""> <!--- iç talebin ilişkili oldugu işlemin action_id si --->
	<cfargument name="to_related_action_type" required="yes" default=""><!---iç talep hangi işlemle ilişkilendirilmis  0: satınalma siparişi, 1: depolararası sevk irs. ,2: ambar fişi 3: satinalma teklifi--->
	<cfargument name="is_related_action_iptal"> <!--- ilgili işlem iptal --->
	<cfargument name="action_status" required="yes" type="numeric"><!--- 0: ekleme 1: guncelleme--->
	<cfargument name="process_db" required="yes" default="#dsn3#" type="string">
	<cfargument name="process_db_alias" type="string">
	<cfif arguments.process_db is not 'dsn3'>
		<cfset arguments.process_db_alias = '#dsn3_alias#.'>
	<cfelse>
		<cfset arguments.process_db_alias = ''>
	</cfif>
	<cfset related_ships = "">
	<cfset related_ship_periods = "">
	<cfif arguments.action_status eq 1>
		<!--- guncelleme ve silme islemlerinden cagrıldıgında kayıtlar temizleniyor.--->
		<cfquery name="DEL_INT_RELATION_" datasource="#arguments.process_db#">
			DELETE 
				FROM #arguments.process_db_alias#INTERNALDEMAND_RELATION_ROW
			WHERE
				<cfif to_related_action_type eq 0> <!--- satınalma siparisi --->
					TO_ORDER_ID = #to_related_action_id#
				<cfelseif to_related_action_type eq 1>
					TO_SHIP_ID = #to_related_action_id#
					AND PERIOD_ID = #session.ep.period_id#
				<cfelseif to_related_action_type eq 2>
					TO_STOCK_FIS_ID = #to_related_action_id#
					AND PERIOD_ID =#session.ep.period_id#
				<cfelseif to_related_action_type eq 3><!--- Satinalma Teklifi --->
					TO_OFFER_ID = #to_related_action_id#
                <cfelseif to_related_action_type eq 4><!--- Satinalma Talebi --->
					TO_INTERNALDEMAND_ID = #to_related_action_id#
				</cfif>
		</cfquery>
	</cfif>
	<cfif listfind('0,1',arguments.action_status) and not (isdefined('arguments.is_related_action_iptal') and arguments.is_related_action_iptal eq 1) > <!--- ekleme ve guncellemede kayıtlar ekleniyor --->
		<cfloop from="1" to="#attributes.rows_#" index="row_shp_ind">
			<cfif Len(Evaluate("attributes.stock_id#row_shp_ind#")) and Len(Evaluate("attributes.product_id#row_shp_ind#"))><!--- FBS 20120502 Bu kontrol action file ile olusan irsaliye kaydi icin eklenmistir --->
				<cfif (listlen(evaluate("attributes.row_ship_id#row_shp_ind#"),';') eq 2 and evaluate("listfirst(attributes.row_ship_id#row_shp_ind#,';')") ) or ( listlen(evaluate("attributes.row_ship_id#row_shp_ind#"),';') eq 1 and evaluate("attributes.row_ship_id#row_shp_ind#") neq 0)>
					<!--- row_ship_id 2 haneli ise interdemand_id;period_id bilgilerini tutar
					row_ship_id 0 olanlar alınmaz cunku bu satırlar manuel eklenmiş urunleri gosterir --->
					<cfquery name="ADD_INTERD_RELATION_ROW_" datasource="#arguments.process_db#">
						INSERT INTO
							#arguments.process_db_alias#INTERNALDEMAND_RELATION_ROW
						(
							INTERNALDEMAND_ID,
							INTERNALDEMAND_ROW_ID,
							PRODUCT_ID,
							STOCK_ID,
							SPECT_VAR_ID,
							SHELF_NUMBER,
							AMOUNT,
							<cfif to_related_action_type eq 0> <!--- satınalma siparisi --->
								TO_ORDER_ID,
							<cfelseif to_related_action_type eq 1>
								TO_SHIP_ID,
							<cfelseif to_related_action_type eq 2>
								TO_STOCK_FIS_ID,
							<cfelseif to_related_action_type eq 3><!--- Satinalma Teklifi --->
								TO_OFFER_ID,
							<cfelseif to_related_action_type eq 4><!--- iç talepten satınalma talebi oluşturma --->
								TO_INTERNALDEMAND_ID,
							</cfif>
							DEPARTMENT_ID,
							LOCATION_ID,
							PERIOD_ID
						)
						VALUES
						(
						#evaluate("listfirst(attributes.row_ship_id#row_shp_ind#,';')")#,
						<cfif listlen(evaluate("attributes.row_ship_id#row_shp_ind#"),';') eq 2 and len(listgetat(evaluate("attributes.row_ship_id#row_shp_ind#"),2,';'))>
							#listgetat(evaluate("attributes.row_ship_id#row_shp_ind#"),2,';')#
						<cfelse>
							NULL
						</cfif>,
							#evaluate('attributes.product_id#row_shp_ind#')#,
							#evaluate('attributes.stock_id#row_shp_ind#')#,
						<cfif isdefined('attributes.spect_id#row_shp_ind#') and len(evaluate('attributes.spect_id#row_shp_ind#'))>#evaluate('attributes.spect_id#row_shp_ind#')#,<cfelse>NULL,</cfif>
						<cfif isdefined('attributes.shelf_number#row_shp_ind#') and len(evaluate('attributes.shelf_number#row_shp_ind#'))>#evaluate('attributes.shelf_number#row_shp_ind#')#,<cfelse>NULL,</cfif>
							#evaluate('attributes.amount#row_shp_ind#')#,
							#to_related_action_id#,
						<cfif to_related_action_type eq 0><!--- satınalma siparisi--->
							<cfif isdefined("attributes.deliver_dept#i#") and len(trim(evaluate("attributes.deliver_dept#i#"))) and len(listfirst(evaluate("attributes.deliver_dept#i#"),"-"))>
								#listfirst(evaluate("attributes.deliver_dept#i#"),"-")#,
							<cfelseif isdefined("attributes.deliver_dept_id") and len(attributes.deliver_dept_id)>
								#attributes.deliver_dept_id#,						
							<cfelse>
								NULL,
							</cfif>
							<cfif isdefined("attributes.deliver_dept#i#") and listlen(trim(evaluate("attributes.deliver_dept#i#")),"-") eq 2 and len(listlast(evaluate("attributes.deliver_dept#i#"),"-"))>
								#listlast(evaluate("attributes.deliver_dept#i#"),"-")#,
							<cfelseif isdefined("attributes.deliver_loc_id") and len(attributes.deliver_loc_id)>
								#attributes.deliver_loc_id#,
							<cfelse>
								NULL,
							</cfif>
						<cfelseif to_related_action_type eq 1><!--- depolararası sevk--->
							<cfif isdefined('attributes.department_id') and len(attributes.department_id)>#attributes.department_id#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.location_id') and len(attributes.location_id)>#attributes.location_id#<cfelse>NULL</cfif>,
						<cfelse>
							NULL,
							NULL,
						</cfif>
							#session.ep.period_id#
						)
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<cfreturn true>
</cffunction>

</cfcomponent>
