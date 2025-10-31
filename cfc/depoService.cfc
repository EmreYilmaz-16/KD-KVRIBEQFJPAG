
<cfscript>    
component output="false" {
    remote struct function saveProductToShelf(integer PRODUCT_ID, integer STOCK_ID, integer PRODUCT_PLACE_ID, string SHELF_CODE) {
        //writeDump(arguments);
        //writeDump(getHTTPRequestData())
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