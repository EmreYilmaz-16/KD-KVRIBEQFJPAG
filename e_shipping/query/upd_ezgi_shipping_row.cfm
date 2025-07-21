<cfdump var="#attributes#">
<cfset shipping_id_list_ =''>
<cfloop list="#attributes.shipping_id_list#" index="ii">
	<cfif listgetat(ii,1,'-') eq 1 and listgetat(ii,3,'-') eq 1>
		<cfset shipping_id_list_ = ListAppend(shipping_id_list_, listgetat(ii,2,'-'))>
   	</cfif>
</cfloop>
<cfoutput>#shipping_id_list_#</cfoutput>

<cfif len(shipping_id_list_)>
    <cfquery name="get_min_ship_result_id" datasource="#dsn3#">
        SELECT     
            ESR.COMPANY_ID, 
            ESR.SHIP_METHOD_TYPE, 
            ISNULL(O.CITY_ID,0) CITY_ID,
            ISNULL(O.COUNTY_ID,0) COUNTY_ID, 
            O.ORDER_ID,
           	ESR.DELIVER_EMP,
            MIN(ESR.SHIP_RESULT_ID) AS REF_SHIP_RESULT_ID,
            MIN(ESR.DELIVER_PAPER_NO) AS REF_DELIVER_PAPER_NO
        FROM         
            EZGI_SHIP_RESULT AS ESR INNER JOIN
        	EZGI_SHIP_RESULT_ROW AS ESSR ON ESR.SHIP_RESULT_ID = ESSR.SHIP_RESULT_ID INNER JOIN
     		ORDERS AS O ON ESSR.ORDER_ID = O.ORDER_ID
        WHERE     
            ESR.SHIP_RESULT_ID IN (#shipping_id_list_#)
        GROUP BY 
            ESR.COMPANY_ID, 
            ESR.DELIVER_EMP,
            ESR.SHIP_METHOD_TYPE, 
            O.CITY_ID,
            O.COUNTY_ID,
          	O.ORDER_ID
    </cfquery>
    <cftransaction>
        <cfloop query="get_min_ship_result_id">
        	<cfquery name="get_old_shipping_row" datasource="#dsn3#">
            	SELECT     
                	ESSR.SHIP_RESULT_ROW_ID,
                    ESSR.SHIP_RESULT_ID
              	FROM         
                 	EZGI_SHIP_RESULT AS ESR INNER JOIN
                   	EZGI_SHIP_RESULT_ROW AS ESSR ON ESR.SHIP_RESULT_ID = ESSR.SHIP_RESULT_ID INNER JOIN
                  	ORDERS AS O ON ESSR.ORDER_ID = O.ORDER_ID
             	WHERE     
                 	ESR.SHIP_RESULT_ID IN (#shipping_id_list_#) AND 
                  	ESR.COMPANY_ID = #get_min_ship_result_id.COMPANY_ID#
                  	<cfif len(get_min_ship_result_id.SHIP_METHOD_TYPE)>
                   		AND ESR.SHIP_METHOD_TYPE = #get_min_ship_result_id.SHIP_METHOD_TYPE#
                 	</cfif>
                  	<cfif len(get_min_ship_result_id.CITY_ID)>
                     	AND ISNULL(O.CITY_ID,0) = #get_min_ship_result_id.CITY_ID#
                  	</cfif>
					<cfif len(get_min_ship_result_id.COUNTY_ID)>
                     	AND ISNULL(O.COUNTY_ID,0) = #get_min_ship_result_id.COUNTY_ID#
                	</cfif>	
                    <cfif len(get_min_ship_result_id.COUNTY_ID)>
                     	AND ESR.DELIVER_EMP = #get_min_ship_result_id.DELIVER_EMP#
                	</cfif>
            </cfquery>
            <cfset new_shipping_id_list = ValueList(get_old_shipping_row.SHIP_RESULT_ROW_ID)>
            <cfset new_shipping_list = ValueList(get_old_shipping_row.SHIP_RESULT_ID)>
            <!---<cfdump var="#attributes#"><cfdump var="#get_min_ship_result_id#"><cfdump var="#get_old_shipping_row#"><cfabort>--->
            <cfquery name="upd_package_control" datasource="#dsn3#">
            	UPDATE 
                	EZGI_SHIPPING_PACKAGE_LIST
				SET                
                	SHIPPING_ID = #REF_SHIP_RESULT_ID#
				WHERE        
                	SHIPPING_ID IN (#new_shipping_list#)
            </cfquery>
            <cfquery name="upd_stock_fis" datasource="#dsn3#">
            	UPDATE       
                	#dsn2_alias#.STOCK_FIS
				SET                
                	REF_NO = '#REF_DELIVER_PAPER_NO#'
				FROM            
                	EZGI_SHIP_RESULT AS ESR INNER JOIN
                  	EZGI_SHIP_RESULT_ROW AS ESSR ON ESR.SHIP_RESULT_ID = ESSR.SHIP_RESULT_ID INNER JOIN
                  	#dsn2_alias#.STOCK_FIS ON ESR.DELIVER_PAPER_NO = #dsn2_alias#.STOCK_FIS.REF_NO
				WHERE        
                	ESSR.SHIP_RESULT_ROW_ID IN (#new_shipping_id_list#)
            </cfquery>
            <cfquery name="upd_shipping_row" datasource="#dsn3#">
                UPDATE    
                    EZGI_SHIP_RESULT_ROW
                SET              
                    SHIP_RESULT_ID = #get_min_ship_result_id.REF_SHIP_RESULT_ID#
                WHERE     
                    SHIP_RESULT_ROW_ID IN (#new_shipping_id_list#)
            </cfquery>
        </cfloop>
    </cftransaction>
<cfelse>
	<script language="javascript">
	   alert('<cf_get_lang_main no='3592.Birleşecek Kayıt Bulunamadı'>');
	</script>
    <cfabort>
</cfif>
<script language="javascript">
	wrk_opener_reload();
   	window.close();
</script>
