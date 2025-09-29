<cfdump var="#attributes#" >
<cfset FormData=deserializeJson(attributes.DATA)>
<cfset paperData=deserializeJson(attributes.paperData)>
<cfdump var="#FormData#">
<cfloop from="1" to="#arrayLen(FormData)#" index="i">
    <cfset row=FormData[i]>
    <cfdump var="#row#">

</cfloop>
<cfabort>