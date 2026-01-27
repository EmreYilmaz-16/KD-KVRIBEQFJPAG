<cfcomponent displayname="ServiceGuaranty" output="false">

    <!--- Veriyi kaydeden fonksiyon --->
    <cffunction name="saveServiceGuaranty" access="public" returntype="boolean" >
        <cfargument name="data" type="struct" required="true" />
        <cfargument name="recordEmp" type="string" required="true" />
        <cfargument name="fromApp" type="string" required="false" default="Ambar" /> <!--- Hangi uygulamadan geldiği bilgisi Uygulamalar Sayim / Ambar (opsiyonel) --->
        <cfset var success = false />
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
        <!--- İş kuralları --->
        <cfset var isPurchase = (arguments.data.IN_OUT EQ 1 ? 1 : 0)>
        <cfset var isSale     = (arguments.data.IN_OUT EQ 0 ? 1 : 0)>
        <cfset var unitType   = (arguments.data.IN_OUT EQ 1 ? 1 : 0)>
        <cfset var nowDate    = now() />
        <cfif isdefined("arguments.data.IS_RETURN") EQ false>
            <cfset arguments.data.IS_RETURN = 0>
        </cfif>
        <cfif isdefined("arguments.data.IS_RMA") EQ false>
            <cfset arguments.data.IS_RMA = 0>
        </cfif>
        <cfif isdefined("arguments.data.IS_SERVICE") EQ false>
            <cfset arguments.data.IS_SERVICE = 0>
        </cfif>
         <cfif isdefined("arguments.data.SALE_COMPANY_ID") EQ false>
            <cfset arguments.data.SALE_COMPANY_ID = -1>
        </cfif>
          <cfif isdefined("arguments.data.UNIT_TYPE") EQ false>
            <cfset arguments.data.UNIT_TYPE = 1>
        </cfif>
        <!--- INSERT işlemi --->
        <cftry>
            <cfquery name="q1" datasource="#dsn3#" result="queryResult">
                INSERT INTO #dsn3#.SERVICE_GUARANTY_NEW
                (
                    STOCK_ID,
                    SERIAL_NO,
                    LOT_NO,
                    IN_OUT,
                    IS_PURCHASE,
                    IS_SALE,
                    PROCESS_CAT,
                    PROCESS_ID,
                    PROCESS_NO,
                    PERIOD_ID,
                    DEPARTMENT_ID,
                    LOCATION_ID,
                    IS_SARF,
                    IS_SERI_SONU,
                    WRK_ID,
                    RECORD_DATE,
                    RECORD_EMP,
                    WRK_ROW_ID,
                    UNIT_TYPE,
                    UNIT_ROW_QUANTITY,
                    SHELF_NUMBER,
                    IS_RETURN,
                    IS_RMA,
                    IS_SERVICE,
                    SALE_COMPANY_ID,
                    UNIT_TYPE
                )
                VALUES
                (
                    <cfqueryparam value="#arguments.data.STOCK_ID#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.data.SERIAL_NO#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#arguments.data.LOT_NO#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#arguments.data.IN_OUT#" cfsqltype="cf_sql_bit">,
                    <cfqueryparam value="#isPurchase#" cfsqltype="cf_sql_bit">,
                    <cfqueryparam value="#isSale#" cfsqltype="cf_sql_bit">,
                    <cfqueryparam value="#arguments.data.PROCESS_CAT#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.data.PROCESS_ID#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.data.PROCESS_NO#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#arguments.data.PERIOD_ID#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.data.DEPARTMENT_ID#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.data.LOCATION_ID#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.data.IS_SARF#" cfsqltype="cf_sql_bit">,
                    <cfqueryparam value="#arguments.data.IS_SERI_SONU#" cfsqltype="cf_sql_bit">,
                    <cfqueryparam value="#arguments.data.WRK_ID#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#nowDate#" cfsqltype="cf_sql_timestamp">,
                    <cfqueryparam value="#arguments.recordEmp#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#arguments.data.WRK_ROW_ID#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#unitType#" cfsqltype="cf_sql_bit">,
                    <cfqueryparam value="#arguments.data.UNIT_ROW_QUANTITY#" cfsqltype="cf_sql_decimal" scale="2">,
                    <cfif len(trim(arguments.data.SHELF_NUMBER)) AND isNumeric(arguments.data.SHELF_NUMBER) AND val(arguments.data.SHELF_NUMBER) NEQ 0>
                        <cfqueryparam value="#val(arguments.data.SHELF_NUMBER)#" cfsqltype="cf_sql_integer">
                    <cfelse>
                        <cfqueryparam null="true" cfsqltype="cf_sql_integer">
                    </cfif>
                    <cfqueryparam value="#arguments.data.IS_RETURN#" cfsqltype="cf_sql_bit">,
                    <cfqueryparam value="#arguments.data.IS_RMA#" cfsqltype="cf_sql_bit">,
                    <cfqueryparam value="#arguments.data.IS_SERVICE#" cfsqltype="cf_sql_bit">,
                    <cfqueryparam value="#arguments.data.SALE_COMPANY_ID#" cfsqltype="cf_sql_integer">
                    <cfqueryparam value="#arguments.data.UNIT_TYPE#" cfsqltype="cf_sql_integer">

                )
            </cfquery>
            <cfif arguments.fromApp eq "Sayim">
                <cfquery name="ishv" datasource="#dsn3#">
                    select * from #dsn3#.SERIAL_IN_OUT_PBS where SERIAL_NUMBER='#data.SERIAL_NO#'
                </cfquery>
                <cfif ishv.recordcount eq 0>
                    <cfquery name="insQ" datasource="#dsn3#">
                        INSERT INTO #dsn3#.SERIAL_IN_OUT_PBS
                        (
                             SERIAL_NUMBER, 
                             IS_ALIVE, 
                             IN_GUARANTY_ID, 
                             OUT_GUARANTY_ID, 
                             PURCHASE_DATE, 
                             SALE_DATE, 
                             STOCK_ID
                        )
                        VALUES
                        (
                                <cfqueryparam value="#data.SERIAL_NO#" cfsqltype="cf_sql_varchar">,
                                <cfqueryparam value="1" cfsqltype="cf_sql_bit">,
                                <cfqueryparam value="#(data.IN_OUT eq 1 ? queryResult.generatedKey : 0)#" cfsqltype="cf_sql_integer">,
                                <cfqueryparam value="#(data.IN_OUT eq 0 ? queryResult.generatedKey : 0)#" cfsqltype="cf_sql_integer">,
                                <cfqueryparam value="#nowDate#" cfsqltype="cf_sql_timestamp" null="#(data.IN_OUT neq 1)#">,
                                <cfqueryparam value="#nowDate#" cfsqltype="cf_sql_timestamp" null="#(data.IN_OUT neq 0)#">,
                                <cfqueryparam value="#data.STOCK_ID#" cfsqltype="cf_sql_integer">
                        )
                    </cfquery>
                </cfif>



            </cfif>

            

            <cfset success = true />
        <cfcatch>
            <cfset success = false />
            <cfset cfcatchError = cfcatch.message />
            <cfdump var="#cfcatch#">
            <!--- Hata loglamak için cfcatchError'u yazabilirsin --->
        </cfcatch>
        </cftry>

        <cfreturn success />
    </cffunction>

</cfcomponent>
