<cfscript>
component output="false" {
    public struct function isRegistered(required string serialNo) {
        var result = {exists = false};
        var q = queryExecute(
            "IF EXISTS (SELECT 1 FROM PBS_SERIAL_SAYIM_ROW WITH (NOLOCK) WHERE SERIAL_NUMBER = :serial) SELECT 1 AS found",
            {serial = {value = arguments.serialNo, cfsqltype = "cf_sql_varchar"}},
            {datasource = application.defaultDatasource, maxrows = 1}
        );
        result.exists = q.recordCount > 0;
        return result;
    }
}
</cfscript>