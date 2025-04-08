<cfquery name="gets" datasource="#dsn#">
    select * from w3Qa.PROCESS_TYPE_ROWS_CAUID where PROCESS_ROW_ID=253
</cfquery>
<cfif listFind(valueList(gets.CAU_POSITION_ID),session.ep.POSITION_CODE)>
<script>
    $(document).ready(function () {
        
        var btn=document.createElement("button")
btn.setAttribute("type","button")
btn.setAttribute("onclick",'windowopen("index.cfm?fuseaction=sales.emptypopup_add_offer_discount_pbs&offer_id=<cfoutput>#attributes.offer_id#</cfoutput>","page_display")')
btn.innerText="İskonto Gir"
btn.setAttribute("class"," ui-wrk-btn ui-wrk-btn-warning")
document.getElementById("workcube_button").appendChild(btn)

    })


    function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, '\\$&');
    var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
}
</script>
</cfif>