
<cfscript>    
component output="false" {
    remote struct function saveProductsToPallet() returnformat="json" {
        writeDump(arguments);
        writeDump(getHTTPRequestData())
        formdata=deserializeJSON(getHTTPRequestData().content);
        writeDump(formdata);
        abort;
        var qm=queryExecute(
            "SELECT PRODUCT_PLACE_ID FROM PRODUCT_PLACE_ROWS WHERE PRODUCT_PLACE_ID = :productPlaceId AND STOCK_ID = :stockId",
            {
                productPlaceId={value=arguments.PRODUCT_PLACE_ID, cfsqltype="cf_sql_integer"},
                stockId={value=arguments.STOCK_ID, cfsqltype="cf_sql_integer"}
            },
            
            {datasource="w3Qa_1", maxrows=1}
        );
        if(qm.recordcount gt 0){
            return {success=false, message="This product is already assigned to the shelf."};
        }
        var q=queryExecute(
            "INSERT INTO PRODUCT_PLACE_ROWS (PRODUCT_PLACE_ID, PRODUCT_ID, STOCK_ID) 
             VALUES (:productPlaceId, :productId, :stockId )",
            {
                productPlaceId={value=arguments.PRODUCT_PLACE_ID, cfsqltype="cf_sql_integer"},
                productId={value=arguments.PRODUCT_ID, cfsqltype="cf_sql_integer"},
                stockId={value=arguments.STOCK_ID, cfsqltype="cf_sql_integer"}
            },
            {datasource="w3Qa_1"}
        );
        return {success=true, message="Product saved to shelf successfully."};

    }
}
</cfscript>