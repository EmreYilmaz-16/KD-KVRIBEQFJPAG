

<cfset attributes.ref_member_name = trim(attributes.ref_member_name)>
<cfquery name="GET_COMP" datasource="#DSN#">
	SELECT 	
		C.COMPANY_ID,
		C.FULLNAME, 
		C.MEMBER_CODE,
        C.NICKNAME,
		CP.COMPANY_PARTNER_NAME, 
		CP.COMPANY_PARTNER_SURNAME, 
		CP.PARTNER_ID
	FROM 
		<cfif isdefined('attributes.is_my')>		
			WORKGROUP_EMP_PAR WEP,
		</cfif>
		COMPANY C,
		COMPANY_PARTNER CP
	WHERE 
		C.COMPANY_ID = CP.COMPANY_ID AND
		C.MANAGER_PARTNER_ID = CP.PARTNER_ID
		<cfif isdefined('attributes.is_my') and attributes.is_my is 1>
			AND C.COMPANY_ID=WEP.COMPANY_ID
			<cfif session.ep.admin eq 0 and session.ep.power_user eq 0><!---  and session.ep.member_view_control --->
				AND WEP.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.COMPANY_ID#"> 
				AND WEP.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> 
			</cfif>
		</cfif>
		<cfif len(attributes.ref_member_name)>
			AND 
			(
				C.FULLNAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#UrlDecode(attributes.ref_member_name)#%"> OR
				C.NICKNAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#UrlDecode(attributes.ref_member_name)#%"> OR
				CP.COMPANY_PARTNER_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#UrlDecode(attributes.ref_member_name)#%"> OR
				CP.COMPANY_PARTNER_SURNAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#UrlDecode(attributes.ref_member_name)#%"> 
			)
		</cfif>
        AND C.COMPANYCAT_ID IN (
                                    SELECT	
                                        COMPANYCAT_ID
                                    FROM
                                        GET_MY_COMPANYCAT
                                    WHERE
                                        EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"> AND
                                        OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.COMPANY_ID#">
                        		)
	ORDER BY
		C.FULLNAME,
		CP.COMPANY_PARTNER_NAME,
		CP.COMPANY_PARTNER_SURNAME
</cfquery>
<cfquery name="GET_CREDIT_LIMITS" datasource="#DSN#">
    SELECT 
        PRICE_CAT,
        COMPANY_ID
    FROM 
        COMPANY_CREDIT
    WHERE 
        OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
</cfquery>
<cfquery name="GET_PDA_MENU_ID" datasource="#DSN#">
	SELECT GENERAL_WIDTH, GENERAL_WIDTH_TYPE FROM MAIN_MENU_SETTINGS WHERE SITE_TYPE = 4 AND IS_ACTIVE = 1 AND SITE_DOMAIN = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.http_host#">
</cfquery>
<cf_box title="Kurumsal Üyeler" body_style="overflow-y:scroll;height:100px;" dragDrop="1" id="#attributes.div_name#">
<table cellspacing="0" cellpadding="0" border="0" align="center"  style="width:100%">
	<tr class="color-border">
		<td>
			<table cellspacing="1" cellpadding="2" border="0" style="width:100%">
				<tr class="color-header" style="height:22px;">		
					<td class="form-title" style="width:30px;">No</td>
					<td class="form-title">Şirket Unvanı</td>
				</tr>
				<cfif get_comp.recordcount>
					<cfoutput query="get_comp">
                    	<cfquery name="GET_CREDIT_LIMIT" dbtype="query">
                            SELECT * FROM GET_CREDIT_LIMITS WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#company_id#">
                        </cfquery>		
						<tr class="color-row" style="height:20px;">
							<td style="width:30px;">#member_code#</td>
							<td><a href="javascript://" class="tableyazi"  onclick="add_company_div('#attributes.div_name#','#company_id#','#fullname# - #company_partner_name#  #company_partner_surname#','#company_partner_name#  #company_partner_surname#','#partner_id#','partner'<cfif get_credit_limit.recordcount and len(get_credit_limit.price_cat)>,'#get_credit_limit.price_cat#'</cfif>);">#fullname#</a></td>
						</tr>		
					</cfoutput>
				<cfelse>
					<tr class="color-row" style="height:20px;">
						<td colspan="3">Kayıt Bulunamadı !</td>
					</tr>
				</cfif>
			</table>
		</td>
	</tr>
</table>
</cf_box>
