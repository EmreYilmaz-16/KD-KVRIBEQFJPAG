<cfcomponent displayname="SaleService" output="false" hint="Handles sale-related operations">
    
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

    <cffunction name="SaveSaleMarjToOffer" access="remote" returntype="struct" output="false" hint="Saves selected purchase offers" returnFormat="json" httpMethod="POST">
          <cfscript>
         if (!len(variables.dsn)) {
                setDatasources();
            }
              dsn  = variables.dsn;
                dsn2 = variables.dsn2;
                dsn3 = variables.dsn3;
                ourcmpny = variables.our_company_id;
    </cfscript>  
        <cfset arguments.payload = getHTTPRequestData().content>        
        <cfset arguments.payload = deserializeJSON(arguments.payload)>
        
        <cfsavecontent variable="test1">
            <cfdump var="#arguments.payload#">
          </cfsavecontent>
          <cffile action="write" file = "C:\w3Dosya\#dsn#\AddOns\Partner\ServisLogs\SaveSaleMarjToOffer.html" output="#test1#"></cffile>
        
        <cfloop array="#arguments.payload.MarjArray#" item="it">
            <cfquery name="Up" datasource="#dsn3#">
                UPDATE OFFER_ROW SET MARJ_ORAN_PBS =<cfif len(it.MARJ)>#it.MARJ#<cfelse>0</cfif>,PRICE_PBS=<cfif len(it.PRICE)>#it.PRICE#<cfelse>0</cfif>
                WHERE WRK_ROW_ID = '#it.WRK_ROW_ID#'
            </cfquery>
        </cfloop>
        <cfreturn arguments.payload>
    </cffunction>

    <cffunction name="saveMessage" access="remote" returntype="void" output="true" httpMethod="GET">
        <cfargument name="wrk_row_id" type="string" required="true">
        <cfargument name="id" type="string" required="false" default="0">
          <cfscript>
         if (!len(variables.dsn)) {
                setDatasources();
            }
              dsn  = variables.dsn;
                dsn2 = variables.dsn2;
                dsn3 = variables.dsn3;
                ourcmpny = variables.our_company_id;
    </cfscript>  

        <cfif id eq 1>
            <cfquery name="getMessage" datasource="#dsn3#">
                SELECT MARJ_ORAN_PBS MSG FROM OFFER_ROW WHERE WRK_ROW_ID = '#arguments.wrk_row_id#'
            </cfquery>                
        <cfelse>
            <cfquery name="getMessage" datasource="#dsn3#">
                SELECT PRICE_PBS MSG FROM OFFER_ROW WHERE WRK_ROW_ID = '#arguments.wrk_row_id#'
            </cfquery>
        </cfif>
        <cfcontent type="text/plain; charset=utf-8">
        <cfoutput>#getMessage.MSG#</cfoutput>
    </cffunction>
    
    <cffunction name="getOfferMarjs" access="remote" returntype="struct" output="false" hint="Saves selected purchase offers" returnFormat="json" httpMethod="POST">
        <cfargument name="offerId" type="numeric" required="true" default="">
          <cfscript>
         if (!len(variables.dsn)) {
                setDatasources();
            }
              dsn  = variables.dsn;
                dsn2 = variables.dsn2;
                dsn3 = variables.dsn3;
                ourcmpny = variables.our_company_id;
    </cfscript>  
        <cfsavecontent variable="test1">
            <cfdump var="#arguments#">
            <cfdump var="#getHTTPRequestData()#">
          </cfsavecontent>
          <cffile action="write" file = "C:\w3Dosya\#dsn#\AddOns\Partner\ServisLogs\getOfferMarjs.html" output="#test1#"></cffile>

        <cfquery name="getOfferMarjs" datasource="#dsn3#">
            select MARJ_ORAN_PBS,PRICE_PBS,WRK_ROW_ID from #dsn3#.OFFER_ROW where OFFER_ID=#arguments.OFFERID#
        </cfquery>

        <cfset var result = []>
        <cfset var row = {}>
        <cfset var i = 1>
        <cfloop query="getOfferMarjs">
            <cfset row = {}>
            <cfset row.MARJ_ORAN_PBS = getOfferMarjs.MARJ_ORAN_PBS>
            <cfset row.PRICE_PBS = getOfferMarjs.PRICE_PBS>
            <cfset row.WRK_ROW_ID = getOfferMarjs.WRK_ROW_ID>
            <cfset arrayAppend(result, row)>
        </cfloop>
        <cfset var response = {}>
        <cfset response.status = "success">
        <cfset response.data = result>
        <cfset response.message = "Data retrieved successfully.">
        <cfset response.code = 200> 
        <cfset response.total = getOfferMarjs.recordCount>
        <cfset response.page = 1>
        <cfset response.perPage = 10>
        <cfset response.lastPage = 1>
        <cfreturn response>
    </cffunction>
</cfcomponent>