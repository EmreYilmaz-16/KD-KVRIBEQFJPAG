<cfscript>
component output="false" {
    public struct function isRegistered(required string serialNo) {
        var result = {exists = false};
        var q = queryExecute(
            "IF EXISTS (SELECT 1 FROM SERIAL_IN_OUT_PBS WITH (NOLOCK) WHERE SERIAL_NUMBER = :serial) SELECT 1 AS found",
            {serial = {value = arguments.serialNo, cfsqltype = "cf_sql_varchar"}},
            {datasource = "w3Qa_1", maxrows = 1}
        );
        result.exists = q.recordCount > 0;
        return result;
    }
}
</cfscript>