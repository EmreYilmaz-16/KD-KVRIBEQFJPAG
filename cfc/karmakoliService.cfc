<cfcomponent>
    <cffunction name="addKarmaKoliRows"> 
        <cfargument name="data" type="struct" required="true">
        <cfargument name="recordEmp" type="numeric" required="true">
        <cfset var success = false />
        <cfset var nowDate = now() />
           <cfset var configContent = "" />
        <cfset var dsn = "" />
        <cfset var dsn3 = "" />
        <cfset var getparams = queryNew("") />
        <cffile action="read" file="#ExpandPath('/pbs_dsn.txt')#" variable="configContent">
        <cfset dsn = trim(configContent)>
        <cfquery name="getparams" datasource="#dsn#" maxrows="1">
            SELECT PBS_MODUL_COMPANY_ID FROM PBS_PARAMETERS
        </cfquery>
        <cfif getparams.recordCount EQ 0>
            <cfthrow type="DatasourceResolution" message="PBS_MODUL_COMPANY_ID could not be determined." />
        </cfif>
        <cfset dsn3 = "#dsn#_#getparams.PBS_MODUL_COMPANY_ID#" />
        <cftry>
            <cfquery name="insertKarmaRow" datasource="#dsn3#">
                INSERT INTO KARMA_EMIR_ROWS
                (
                    EMIR_ID,
                    SERIAL_NO,                   
                    STOCK_ID,
                    QUANTITY,
                    FIS_ID,
                    FIS_PERIOD_ID,
                    RECORD_DATE,
                    RECORD_EMP,
                    FIS_WRK_ROW_ID,
                    SCN_WRK_ID
                )
                VALUES
                (
                    <cfqueryparam value="#arguments.data.EMIR_ID#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.data.SERIAL_NO#" cfsqltype="cf_sql_nvarchar">,                    
                    <cfqueryparam value="#arguments.data.STOCK_ID#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.data.UNIT_ROW_QUANTITY#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.data.FIS_ID#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.data.PERIOD_ID#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#nowDate#" cfsqltype="cf_sql_timestamp">,
                    <cfqueryparam value="#arguments.recordEmp#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.data.WRK_ROW_ID#" cfsqltype="cf_sql_nvarchar">,
                    <cfqueryparam value="#arguments.data.SCN_WRK_ID#" cfsqltype="cf_sql_nvarchar">
                )
            </cfquery>
            <cfset success = true />
        <cfcatch>
            <cfset success = false />
            <cfset cfcatchError = cfcatch.message />
            <cfdump var="#cfcatch#">
            <CFABORT>
            <!--- Hata loglamak için cfcatchError'u yazabilirsin --->
        </cfcatch>
        </cftry>

        <cfreturn success />
    </cffunction>

</cfcomponent>