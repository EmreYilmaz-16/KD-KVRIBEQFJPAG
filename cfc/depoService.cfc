
<cfscript>    
component output="false" {
    remote struct function saveProductToShelf(integer PRODUCT_ID, integer STOCK_ID, integer PRODUCT_PLACE_ID, string SHELF_CODE) returnformat="json" {
        // Resolve company-specific datasource based on configuration.
        var configContent = fileRead(expandPath('/pbs_dsn.txt'));
        var dsn = trim(configContent);
        var getparams = queryExecute(
            "SELECT PBS_MODUL_COMPANY_ID FROM PBS_PARAMETERS",
            [],
            {datasource=dsn, maxrows=1}
        );
        if (getparams.recordCount eq 0) {
            throw(type="DatasourceResolution", message="PBS_MODUL_COMPANY_ID could not be determined.");
        }
        var dsn3 = dsn & '_' & getparams.PBS_MODUL_COMPANY_ID;

        var qm=queryExecute(
            "SELECT PRODUCT_PLACE_ID FROM PRODUCT_PLACE_ROWS WHERE PRODUCT_PLACE_ID = :productPlaceId AND STOCK_ID = :stockId",
            {
                productPlaceId={value=arguments.PRODUCT_PLACE_ID, cfsqltype="cf_sql_integer"},
                stockId={value=arguments.STOCK_ID, cfsqltype="cf_sql_integer"}
            },
            {datasource=dsn3, maxrows=1}
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
            {datasource=dsn3}
        );
        return {success=true, message="Product saved to shelf successfully."};

    }
}
</cfscript>