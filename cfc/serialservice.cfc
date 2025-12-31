<cfscript>
component output="false" {
    /**
     * Lazily resolves the company-specific datasource by reading the shared DSN
     * configuration and looking up the active company id.
     */
    private string function resolveDatasource() {
        var configContent = fileRead(expandPath('/pbs_dsn.txt'));
        var baseDsn = trim(configContent);
        var companyQuery = queryExecute(
            "SELECT PBS_MODUL_COMPANY_ID FROM PBS_PARAMETERS",
            [],
            {datasource = baseDsn, maxrows = 1}
        );
        if (companyQuery.recordCount eq 0) {
            throw(type = "DatasourceResolution", message = "PBS_MODUL_COMPANY_ID could not be determined.");
        }
        return baseDsn & '_' & companyQuery.PBS_MODUL_COMPANY_ID;
    }

    remote struct function isRegistered(required string serialNo) {
        var result = {exists = false};
        var datasourceName = resolveDatasource();
        var q = queryExecute(
            "IF EXISTS (SELECT 1 FROM SERIAL_IN_OUT_PBS WITH (NOLOCK) WHERE SERIAL_NUMBER = :serial) SELECT 1 AS found",
            {serial = {value = arguments.serialNo, cfsqltype = "cf_sql_varchar"}},
            {datasource = datasourceName, maxrows = 1}
        );
        try {
           result.exists = q.recordCount gt 0;
        return result; 
        } catch (any exName) {
           // result.exists = q.recordCount gt 0;
        return result;
        }
        
    }
    remote struct function deleteSerial(required string serialNo) {
        var result = {deleted = false};
        var datasourceName = resolveDatasource();
        writeDump(arguments);
        try {
            var delQ = queryExecute(
                "DELETE FROM SERIAL_IN_OUT_PBS WHERE SERIAL_NUMBER = :serial",
                {serial = {value = arguments.serialNo, cfsqltype = "cf_sql_varchar"}},
                {datasource = datasourceName}
            );
            var delQ2 = queryExecute(
                "DELETE FROM SERVICE_GUARANTY_NEW WHERE SERIAL_NO = :serial",
                {serial = {value = arguments.serialNo, cfsqltype = "cf_sql_varchar"}},
                {datasource = datasourceName}
            );
            result.deleted = true;
        } catch (any exName) {
            result.deleted = false;
        }
        return result;
}
}
</cfscript>