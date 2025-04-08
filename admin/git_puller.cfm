<cfexecute name = "C:\PBS\gite.bat"  
timeout = "1000"
variable="local.out"
errorvariable="local.err"> 
</cfexecute>



<cf_box title="Gİt">
<cfoutput>
    
    <cfset local.out = replace(local.out, chr(13), "", "all")>
    <cfset local.out = replace(local.out, chr(10), "", "all")>
    <cfset local.out = replace(local.out, chr(9), "", "all")>
    <cfset local.out = replace(local.out, chr(0), "", "all")>
    <cfset local.out = replace(local.out, chr(1), "", "all")>
    <cfset local.out = replace(local.out, chr(2), "", "all")>
    <cfset local.out = replace(local.out, chr(3), "", "all")>
    <cfset local.out = replace(local.out, chr(4), "", "all")>
    <cfset local.out = replace(local.out, chr(5), "", "all")>
    <cfset local.out = replace(local.out, chr(6), "", "all")>       
    <cfdump var="##local.out##" label="Git Output" />
    <cfdump var="##local.err##" label="Git Error" />
    
    <cfset st=left(local.out,findNoCase("it_is_runing", local.out))>
 
<cfset git =findNoCase("pull",st)>
<cfset stlen =len(st)>
<cfset stgit=stlen-git >
<div class="alert alert-success">
<code>Git Durumu</code>
<cfset listem=mid(st,git+4,stgit)>
<cfloop list="#listem#" item="it" delimiters="|">
<code>#it#</code> <br>
</cfloop>

</div>
</cfoutput>

</cf_box>