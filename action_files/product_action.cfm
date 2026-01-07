<cffile action="read" file="#ExpandPath('/pbs_dsn.txt')#" variable="configContent">
<cfset dsn="#trim(configContent)#">

<cfdump var="#caller#">
<cfif isDefined("attributes.is_package_product")>
    <cfquery name="updatep" datasource="#dsn#_product">
        UPDATE PRODUCT SET IS_PACKAGE_PRODUCT=<cfqueryparam value="#attributes.is_package_product#" cfsqltype="cf_sql_integer">
        WHERE PRODUCT_ID=<cfqueryparam value="#attributes.product_id#" cfsqltype="cf_sql_integer">
    </cfquery>
</cfif>

