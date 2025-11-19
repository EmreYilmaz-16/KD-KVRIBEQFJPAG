<cffile action="read" file="#ExpandPath('/pbs_dsn.txt')#" variable="configContent">
<cfset dsn="#trim(configContent)#">
<cfquery name="getparams" datasource="#dsn#">
    SELECT PBS_MODUL_COMPANY_ID FROM PBS_PARAMETERS
</cfquery>
<cfset dsn3="#dsn#_#getparams.PBS_MODUL_COMPANY_ID#">
<!--- Şablon Kaydetme API --->
<cfcontent type="application/json">

<cftry>
    <!--- POST verilerini al --->
    <cfset requestBody = GetHttpRequestData().content>
    <cfset templateData = DeserializeJSON(requestBody)>
    
    <!--- Şablonu güncelle --->
    <cfquery datasource="#dsn#">
        UPDATE etiket_templates_s 
        SET 
            label_width = <cfqueryparam value="#templateData.label_width#" cfsqltype="cf_sql_integer">,
            label_height = <cfqueryparam value="#templateData.label_height#" cfsqltype="cf_sql_integer">,
            font_size = <cfqueryparam value="#templateData.font_size#" cfsqltype="cf_sql_integer">,
            qr_size = <cfqueryparam value="#templateData.qr_size#" cfsqltype="cf_sql_integer">,
            show_qr = <cfqueryparam value="#templateData.show_qr#" cfsqltype="cf_sql_bit">,
            show_barcode = <cfqueryparam value="#templateData.show_barcode#" cfsqltype="cf_sql_bit">,
            updated_date = GETDATE()
        WHERE template_id = <cfqueryparam value="#templateData.template_id#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfset response = {
        "success" = true,
        "message" = "Şablon başarıyla güncellendi"
    }>
    
<cfcatch>
    <cfset response = {
        "success" = false,
        "message" = "Hata: " & cfcatch.message
    }>
</cfcatch>
</cftry>

<cfoutput>#SerializeJSON(response)#</cfoutput>
