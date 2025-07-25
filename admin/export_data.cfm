<cfparam name="attributes.sql_sorgu" default="">
<cfparam name="attributes.export_format" default="">
<cfparam name="attributes.filename" default="query_export">

<cfif len(trim(attributes.sql_sorgu)) and len(attributes.export_format)>
    <cftry>
        <!--- Sorguyu çalıştır --->
        <cfquery name="exportData" datasource="#dsn#" result="res">
            #preserveSingleQuotes(attributes.sql_sorgu)#
        </cfquery>

        <cfset fileName = attributes.filename & "_" & dateFormat(now(), "yyyymmdd") & "_" & timeFormat(now(), "HHmmss")>

        <cfswitch expression="#attributes.export_format#">
            <!--- Excel Export --->
            <cfcase value="excel">
                <cfheader name="Content-Disposition" value="attachment; filename=#fileName#.xlsx">
                <cfheader name="Content-Type" value="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">
                
                <cfspreadsheet action="write" query="exportData" filename="#expandPath('./exports/')##fileName#.xlsx" overwrite="true">
                
                <cfcontent type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" 
                          file="#expandPath('./exports/')##fileName#.xlsx" deletefile="true">
            </cfcase>

            <!--- CSV Export --->
            <cfcase value="csv">
                <cfheader name="Content-Disposition" value="attachment; filename=#fileName#.csv">
                <cfheader name="Content-Type" value="text/csv">
                
                <cfset csvContent = "">
                <!--- Header --->
                <cfset csvContent = csvContent & '"' & replace(res.COLUMNLIST, ',', '","', 'ALL') & '"' & chr(13) & chr(10)>
                
                <!--- Data rows --->
                <cfoutput query="exportData">
                    <cfset rowData = "">
                    <cfloop list="#res.COLUMNLIST#" item="col">
                        <cfset cellValue = replace(evaluate(col), '"', '""', 'ALL')>
                        <cfset rowData = listAppend(rowData, '"' & cellValue & '"')>
                    </cfloop>
                    <cfset csvContent = csvContent & rowData & chr(13) & chr(10)>
                </cfoutput>
                
                <cfcontent type="text/csv" variable="#toBinary(toBase64(csvContent))#">
            </cfcase>

            <!--- JSON Export --->
            <cfcase value="json">
                <cfheader name="Content-Disposition" value="attachment; filename=#fileName#.json">
                <cfheader name="Content-Type" value="application/json">
                
                <cfset jsonData = []>
                <cfoutput query="exportData">
                    <cfset rowData = {}>
                    <cfloop list="#res.COLUMNLIST#" item="col">
                        <cfset rowData[col] = evaluate(col)>
                    </cfloop>
                    <cfset arrayAppend(jsonData, rowData)>
                </cfoutput>
                
                <cfcontent type="application/json" variable="#toBinary(toBase64(serializeJSON(jsonData)))#">
            </cfcase>
        </cfswitch>

        <cfcatch type="any">
            <cfoutput>
                <div class="alert alert-danger">
                    <h6>Export Hatası!</h6>
                    <p><strong>Mesaj:</strong> #cfcatch.message#</p>
                    <cfif len(cfcatch.detail)>
                        <p><strong>Detay:</strong> #cfcatch.detail#</p>
                    </cfif>
                </div>
            </cfoutput>
        </cfcatch>
    </cftry>
<cfelse>
    <div class="alert alert-warning">
        <i class="bi bi-exclamation-triangle"></i> Export için SQL sorgusu ve format gerekli.
    </div>
</cfif>
