<!--- Yeni Şablon Oluşturma --->
<cfparam name="url.name" default="Yeni Şablon">
<cfparam name="url.import_id" default="0">

<!--- Resolve datasource dynamically from configuration --->
<cffile action="read" file="#ExpandPath('/pbs_dsn.txt')#" variable="configContent">
<cfset dsn = trim(configContent)>
<cfquery name="getParams" datasource="#dsn#">
    SELECT PBS_MODUL_COMPANY_ID FROM PBS_PARAMETERS
</cfquery>
<cfset dsn3 = dsn & '_' & getParams.PBS_MODUL_COMPANY_ID>

<cftry>
    <!--- Yeni şablon ekle --->
    <cfquery datasource="#dsn#">
        INSERT INTO etiket_templates_s (
            template_name, 
            template_description, 
            label_width, 
            label_height, 
            qr_size, 
            font_size, 
            show_qr, 
            show_barcode, 
            fields_layout,
            created_date
        )
        VALUES (
            <cfqueryparam value="#url.name#" cfsqltype="cf_sql_varchar">,
            'Özel şablon - ' & <cfqueryparam value="#url.name#" cfsqltype="cf_sql_varchar">,
            300, 200, 100, 12, 1, 0, 'custom',
            GETDATE()
        )
    </cfquery>
    
    <!--- Yeni oluşturulan şablonun ID'sini al --->
    <cfquery name="getNewTemplate" datasource="#dsn#">
        SELECT template_id FROM etiket_templates_s 
        WHERE template_name = <cfqueryparam value="#url.name#" cfsqltype="cf_sql_varchar">
        ORDER BY created_date DESC
    </cfquery>
    
    <cflocation url="template_design.cfm?import_id=#url.import_id#&template_id=#getNewTemplate.template_id#" addtoken="false">
    
<cfcatch>
    <!--- Hata durumunda geri dön --->
    <cflocation url="template_design.cfm?import_id=#url.import_id#&error=#URLEncodedFormat(cfcatch.message)#" addtoken="false">
</cfcatch>
</cftry>
