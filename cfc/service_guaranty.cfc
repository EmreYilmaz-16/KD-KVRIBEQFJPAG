<cfcomponent displayname="ServiceGuaranty" output="false">

    <!--- Veriyi kaydeden fonksiyon --->
    <cffunction name="saveServiceGuaranty" access="public" returntype="boolean" >
        <cfargument name="data" type="struct" required="true" />
        <cfargument name="recordEmp" type="string" required="true" />
        <cfargument name="fromApp" type="string" required="false" default="Ambar" /> <!--- Hangi uygulamadan geldiği bilgisi Uygulamalar Sayim / Ambar (opsiyonel) --->
        <cfset var success = false />
<cfset dsn3="w3Qa_1">
        <!--- İş kuralları --->
        <cfset var isPurchase = (arguments.data.IN_OUT EQ 1 ? 1 : 0)>
        <cfset var isSale     = (arguments.data.IN_OUT EQ 0 ? 1 : 0)>
        <cfset var unitType   = (arguments.data.IN_OUT EQ 1 ? 1 : 0)>
        <cfset var nowDate    = now() />

        <!--- INSERT işlemi --->
        <cftry>
            <cfquery name="q1" datasource="#dsn3#" result="queryResult">
                INSERT INTO w3Qa_1.SERVICE_GUARANTY_NEW
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
                    SHELF_NUMBER
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
                    <cfqueryparam value="#arguments.data.SHELF_NUMBER#" cfsqltype="cf_sql_integer" null="#(arguments.data.SHELF_NUMBER eq 0 OR arguments.data.SHELF_NUMBER eq '')#">
                )
            </cfquery>
            <cfif arguments.fromApp eq "Sayim">
                <cfquery name="ishv" datasource="#dsn3#">
                    select * from w3Qa_1.SERIAL_IN_OUT_PBS where SERIAL_NUMBER='#data.SERIAL_NO#'
                </cfquery>
                <cfif ishv.recordcount eq 0>
                    <cfquery name="insQ" datasource="#dsn3#">
                        INSERT INTO w3Qa_1.SERIAL_IN_OUT_PBS
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
                                <cfqueryparam value="#(data.IN_OUT eq 1 ? nowDate : null)#" cfsqltype="cf_sql_timestamp" null="true">,
                                <cfqueryparam value="#(data.IN_OUT eq 0 ? nowDate : null)#" cfsqltype="cf_sql_timestamp" null="true">,
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
