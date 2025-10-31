<cfscript>
component output="false" {
    remote struct function saveProductToShelf(integer PRODUCT_ID, integer STOCK_ID, integer PRODUCT_PLACE_ID, string SHELF_CODE) {
        writeDump(arguments);
        writeDump(getHTTPRequestData())
        
    }
}
</cfscript>