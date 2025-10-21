<cfscript>
component output="false" {
    remote struct function isRegistered(required string serialNo) {
        var result = {exists = false};
        var q = queryExecute(
            "IF EXISTS (SELECT 1 FROM SERIAL_IN_OUT_PBS WITH (NOLOCK) WHERE SERIAL_NUMBER = :serial) SELECT 1 AS found",
            {serial = {value = arguments.serialNo, cfsqltype = "cf_sql_varchar"}},
            {datasource = "w3Qa_1", maxrows = 1}
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
        try {
            var delQ = queryExecute(
                "DELETE FROM SERIAL_IN_OUT_PBS WHERE SERIAL_NUMBER = :serial",
                {serial = {value = arguments.serialNo, cfsqltype = "cf_sql_varchar"}},
                {datasource = "w3Qa_1"}
            );
            var delQ2 = queryExecute(
                "DELETE FROM SERVICE_GUARANTY_NEW WHERE SERIAL_NO = :serial",
                {serial = {value = arguments.serialNo, cfsqltype = "cf_sql_varchar"}},
                {datasource = "w3Qa_1"}
            );
            result.deleted = true;
        } catch (any exName) {
            result.deleted = false;
        }
        return result;
}
}
</cfscript>