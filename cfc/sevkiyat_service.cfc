
<cfscript>    
component output="false" {
    remote struct function saveProductsToPallet() returnformat="json" {
   
        formdata=deserializeJSON(getHTTPRequestData().content);
   
        // Resolve company-specific datasource dynamically based on configuration.
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
        var palletId=formdata.pallet_id;
        var userid=formdata.userid;
        var products=formdata.products;
        var qdel=queryExecute(
            "DELETE FROM SHIPPING_PALLET_ROWS_PBS WHERE PALLET_ID = :palletId",
            {
                palletId={value=palletId, cfsqltype="cf_sql_integer"}
            },
            {datasource=dsn3}
        );
        for(var i=1;i LTE arrayLen(products);i=i+1){
            var q=queryExecute(
                "INSERT INTO SHIPPING_PALLET_ROWS_PBS (PALLET_ID, PRODUCT_ID, STOCK_ID, SERIAL_NUMBER,RECORD_DATE,RECORD_EMP,AMOUNT) 
                 VALUES (:palletId, :productId, :stockId, :serialNo, :recordDate, :recordEmp, :amount)",
                {
                    palletId={value=palletId, cfsqltype="cf_sql_integer"},
                    productId={value=products[i].PRODUCT_ID, cfsqltype="cf_sql_integer"},
                    stockId={value=products[i].STOCK_ID, cfsqltype="cf_sql_integer"},
                    serialNo={value=products[i].SERIAL_NO, cfsqltype="cf_sql_varchar"},
                    recordDate={value=now(), cfsqltype="cf_sql_timestamp"},
                    recordEmp={value=userid, cfsqltype="cf_sql_integer"},
                    amount={value=products[i].AMOUNT, cfsqltype="cf_sql_integer"}
                },
                {datasource=dsn3}
            );
        }
        return {success=true, message="Product saved to shelf successfully."};
        abort;
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