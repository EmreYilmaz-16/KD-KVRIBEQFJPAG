<cfscript>
component output="false" {
    remote struct function saveProductToShelf() {
        writeDump(arguments);
        writeDump(getHTTPRequestData())
    }
}
</cfscript>