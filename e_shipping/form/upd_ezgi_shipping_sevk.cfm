<cfquery name="get_shippng_plan" datasource="#dsn3#">
	<cfif attributes.is_type eq 1>
        SELECT     
            ESR.SHIP_RESULT_ID, 
            ESR.DELIVER_EMP, 
            ESR.NOTE, 
            ESR.DELIVER_PAPER_NO, 
            ESR.REFERENCE_NO, 
            ESR.OUT_DATE, 
            SM.SHIP_METHOD,
            SM.SHIP_METHOD SHIP_METHOD_TYPE,
            ESR.DELIVERY_DATE, 
            ESR.DEPARTMENT_ID,
            ESR.LOCATION_ID, 
            ESR.SHIP_STAGE, 
            ESR.COMPANY_ID, 
            ESR.PARTNER_ID, 
            ESR.CONSUMER_ID ,
            ISNULL(ESR.IS_SEVK_EMIR,0) AS IS_SEVK_EMIR
        FROM         
            EZGI_SHIP_RESULT AS ESR INNER JOIN
            #dsn_alias#.SHIP_METHOD AS SM ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID
        WHERE     
            ESR.SHIP_RESULT_ID = #attributes.iid#
  	<cfelse>
    	SELECT     
        	SI.DISPATCH_SHIP_ID, 
            SI.DELIVER_EMP,  
            SI.DETAIL NOTE,
            SI.DISPATCH_SHIP_ID DELIVER_PAPER_NO,
            '' as REFERENCE_NO,
            SI.DELIVER_DATE OUT_DATE,
            SM.SHIP_METHOD,
            SM.SHIP_METHOD SHIP_METHOD_TYPE,
            DateAdd(d,1,SI.DELIVER_DATE) DELIVERY_DATE,
            SI.LOCATION_OUT LOCATION_ID, 
            SI.DEPARTMENT_OUT DEPARTMENT_ID ,
            SI.PROCESS_STAGE SHIP_STAGE, 
         	SI.DEPARTMENT_IN, 
            SI.LOCATION_IN,
            ISNULL(SI.IS_SEVK_EMIR,0) AS IS_SEVK_EMIR
		FROM         
        	#dsn2_alias#.SHIP_INTERNAL AS SI LEFT OUTER JOIN
       		#dsn_alias#.SHIP_METHOD AS SM ON SI.SHIP_METHOD = SM.SHIP_METHOD_ID
		WHERE     
        	SI.DISPATCH_SHIP_ID = #attributes.iid#
    </cfif>
</cfquery>
<cfif get_shippng_plan.recordcount>
	<cfparam name="attributes.reference_no" default="#get_shippng_plan.REFERENCE_NO#">
    <cfparam name="attributes.ship_method_id" default="#get_shippng_plan.SHIP_METHOD_TYPE#">
    <cfparam name="attributes.ship_method_name" default="#get_shippng_plan.SHIP_METHOD#">
  	<cfquery name="get_default_department" datasource="#dsn#">
    	SELECT DEFAULT_MK_TO_RF_DEP, DEFAULT_MK_TO_RF_LOC FROM EZGI_PDA_DEPARTMENT_DEFAULTS WHERE EPLOYEE_ID = #session.ep.userid#
    </cfquery>
    <cfif get_default_department.recordcount>
    	<cfset default_dep = ListGetAt(get_default_department.DEFAULT_MK_TO_RF_DEP,2)>
        <cfset default_loc = ListGetAt(get_default_department.DEFAULT_MK_TO_RF_LOC,2)>
    <cfelse>
    	<cfset default_dep =''>
        <cfset default_loc =''>
    </cfif>
    <cfquery name="get_department" datasource="#dsn#">
		SELECT     
        	DEPARTMENT.DEPARTMENT_HEAD, 
            DEPARTMENT.BRANCH_ID, 
            DEPARTMENT.DEPARTMENT_ID, 
            STOCKS_LOCATION.LOCATION_ID, 
            STOCKS_LOCATION.COMMENT
		FROM         
    		DEPARTMENT INNER JOIN
        	STOCKS_LOCATION ON DEPARTMENT.DEPARTMENT_ID = STOCKS_LOCATION.DEPARTMENT_ID
  	  	WHERE     
        	DEPARTMENT.DEPARTMENT_ID = #get_shippng_plan.DEPARTMENT_ID# AND 
            STOCKS_LOCATION.LOCATION_ID = #get_shippng_plan.LOCATION_ID#    
	</cfquery>
    <cfif attributes.is_type eq 2>
        <cfquery name="get_department_in" datasource="#dsn#">
            SELECT     
                DEPARTMENT.DEPARTMENT_HEAD, 
                DEPARTMENT.BRANCH_ID, 
                DEPARTMENT.DEPARTMENT_ID, 
                STOCKS_LOCATION.LOCATION_ID, 
                STOCKS_LOCATION.COMMENT
            FROM         
                DEPARTMENT INNER JOIN
                STOCKS_LOCATION ON DEPARTMENT.DEPARTMENT_ID = STOCKS_LOCATION.DEPARTMENT_ID
            WHERE     
                DEPARTMENT.DEPARTMENT_ID = #get_shippng_plan.DEPARTMENT_IN# AND 
                STOCKS_LOCATION.LOCATION_ID = #get_shippng_plan.LOCATION_IN#    
        </cfquery>
   	</cfif>
    <cfparam name="attributes.branch_id" default="#get_department.BRANCH_ID#">
    <cfparam name="attributes.department_id" default="#get_department.DEPARTMENT_ID#">
    <cfparam name="attributes.location_id" default="#get_department.LOCATION_ID#">
    <cfparam name="attributes.department_name" default="#get_department.DEPARTMENT_HEAD#-#get_department.COMMENT#">
    <cfquery name="get_order_det" datasource="#DSN3#">
    	SELECT     
            TBL2.TYPE, 
            TBL2.ORDER_ROW_ID, 
            TBL2.DELIVER_DATE, 
            TBL2.ORDER_DATE AS SV_ORDER_DATE, 
            TBL2.COMPANY_ID AS SV_COMPANY_ID, 
            TBL2.ORDER_NUMBER AS SV_ORDER_NUMBER, 
            TBL2.ORDER_ID AS SV_ORDER_ID, 
            TBL2.DURUM, 
            TBL.ORDER_ROW_AMOUNT,
            TBL.IS_TYPE, 
            TBL.SHIP_RESULT_ID, 
            TBL.OUT_DATE, 
            TBL.SHIP_METHOD_TYPE, 
            TBL.DELIVER_PAPER_NO, 
            TBL.LOCATION_ID, 
            TBL.DEPARTMENT_ID, 
            TBL.DEPARTMENT_IN, 
            ORR4.SPECT_VAR_ID,
            ORR4.STOCK_ID, 
            ORR4.PRODUCT_ID,
            ORR4.QUANTITY, 
            ORR4.PRODUCT_NAME2,
            ORR4.ORDER_ROW_CURRENCY,
            ORR4.UNIT BIRIM, 
            ORR4.ORDER_ROW_ID AS SA_ORDER_ROW_ID,
            ORR4.WRK_ROW_ID,
            O4.ORDER_ID AS SA_ORDER_ID, 
            O4.COMPANY_ID AS SA_COMPANY_ID, 
            O4.EMPLOYEE_ID AS SA_EMPLOYEE_ID, 
            O4.CONSUMER_ID AS SA_CONSUMER_ID, 
            O4.ORDER_DETAIL AS SA_ORDER_DETAIL, 
            O4.ORDER_NUMBER AS SA_ORDER_NUMBER, 
            O4.ORDER_DATE AS SA_ORDER_DATE, 
            O4.REF_NO,
            O4.IS_INSTALMENT,
            (
        	SELECT     
          		STOCK_CODE
			FROM         
            	STOCKS
			WHERE     
          		 STOCK_ID=ORR4.STOCK_ID
       		) AS STOCK_CODE,
            (
        	SELECT     
          		STOCK_CODE_2
			FROM         
            	STOCKS
			WHERE     
          		 STOCK_ID=ORR4.STOCK_ID
       		) AS STOCK_CODE_2,
            (
        	SELECT     
          		PRODUCT_NAME
			FROM         
            	STOCKS
			WHERE     
          		 STOCK_ID=ORR4.STOCK_ID
       		) AS PRODUCT_NAME,
            (
        	SELECT     
          		IS_KARMA
			FROM         
            	STOCKS
			WHERE     
          		 STOCK_ID=ORR4.STOCK_ID
       		) AS IS_KARMA,
            (
            SELECT     
            	SPECT_MAIN_ID
			FROM         
            	SPECTS
			WHERE     
            	SPECT_VAR_ID = ORR4.SPECT_VAR_ID
            ) AS SPECT_MAIN_ID,
            (
            	SELECT
                	SUM(REAL_STOCK) AS REAL_STOCK
              	FROM
                	(
                    SELECT   
                        MIN(TOPLAM) AS REAL_STOCK
                    FROM            
                        (
                            SELECT        
                                ISNULL(SUM(TBL.REAL_STOCK), 0) AS TOPLAM, 
                                KP.KARMA_PRODUCT_ID, 
                                KP.PRODUCT_ID
                            FROM            
                                (
                                    SELECT        
                                        STOCK_IN - STOCK_OUT AS REAL_STOCK, 
                                        PRODUCT_ID
                                    FROM            
                                        #dsn2_alias#.STOCKS_ROW
                                    WHERE        
                                        (STORE IS NOT NULL) AND (STORE_LOCATION IS NOT NULL)
                                    UNION ALL
                                    SELECT        
                                        STOCK_IN - STOCK_OUT AS REAL_STOCK, 
                                        PRODUCT_ID
                                    FROM            
                                        #dsn2_alias#.STOCKS_ROW AS SR
                                    WHERE        
                                        (UPD_ID IS NULL) AND (STOCK_IN - STOCK_OUT > 0)
                                ) AS TBL RIGHT OUTER JOIN
                                #dsn1_alias#.KARMA_PRODUCTS AS KP ON TBL.PRODUCT_ID = KP.PRODUCT_ID
                            GROUP BY 
                                KP.KARMA_PRODUCT_ID, 
                                KP.PRODUCT_ID
                        ) AS TBL2
                    GROUP BY 
                        KARMA_PRODUCT_ID
                    HAVING        
                        KARMA_PRODUCT_ID = ORR4.PRODUCT_ID
                    UNION ALL
                    SELECT        
                        ISNULL(SUM(TBL.REAL_STOCK), 0) AS REAL_STOCK
                    FROM            
                        (
                            SELECT        
                                STOCK_IN - STOCK_OUT AS REAL_STOCK, 
                                PRODUCT_ID
                            FROM            
                                #dsn2_alias#.STOCKS_ROW
                            WHERE        
                                (STORE IS NOT NULL) AND (STORE_LOCATION IS NOT NULL)
                            UNION ALL
                            SELECT        
                                STOCK_IN - STOCK_OUT AS REAL_STOCK, 
                                PRODUCT_ID
                            FROM            
                                #dsn2_alias#.STOCKS_ROW AS SR
                            WHERE        
                                (UPD_ID IS NULL) AND (STOCK_IN - STOCK_OUT > 0)
                        ) AS TBL LEFT OUTER JOIN
                        #dsn1_alias#.KARMA_PRODUCTS AS KP ON TBL.PRODUCT_ID = KP.PRODUCT_ID
                    GROUP BY 
                        KP.KARMA_PRODUCT_ID, 
                        TBL.PRODUCT_ID
                    HAVING        
                        KP.KARMA_PRODUCT_ID IS NULL AND 
                        TBL.PRODUCT_ID = ORR4.PRODUCT_ID
             	) AS DPL
           	) AS DEPO
        FROM         
            (
            SELECT     
                1 AS TYPE, 
                EORR.ORDER_ROW_ID, 
                ORR1.STOCK_ID, 
                ORR1.DELIVER_DATE, 
                O1.ORDER_DATE, 
                O1.COMPANY_ID, 
                O1.ORDER_NUMBER, 
                O1.ORDER_ID, 
                EORR.O_DURUM1 AS DURUM
            FROM          
                EZGI_ORDER_REL_RESULT AS EORR INNER JOIN
                ORDER_ROW AS ORR1 ON EORR.ORDER_ROW_ID1 = ORR1.ORDER_ROW_ID INNER JOIN
                ORDERS AS O1 ON ORR1.ORDER_ID = O1.ORDER_ID
            UNION ALL
            SELECT     
                2 AS TYPE, 
                EORR.ORDER_ROW_ID, 
                ORR2.STOCK_ID, 
                ORR2.DELIVER_DATE, 
                O2.ORDER_DATE, 
                O2.COMPANY_ID, 
                O2.ORDER_NUMBER, 
                O2.ORDER_ID, 
                EORR.O_DURUM2 AS DURUM
            FROM         
                ORDERS AS O2 INNER JOIN
                ORDER_ROW AS ORR2 ON O2.ORDER_ID = ORR2.ORDER_ID INNER JOIN
                EZGI_ORDER_REL_RESULT AS EORR ON ORR2.ORDER_ROW_ID = EORR.ORDER_ROW_ID2
            UNION ALL
            SELECT     
                3 AS TYPE, 
                EORR.ORDER_ROW_ID, 
                PO.STOCK_ID, 
                PO.FINISH_DATE AS DELIVER_DATE, 
                PO.START_DATE AS ORDER_DATE, 
                PO.STATION_ID AS COMPANY_ID, 
                PO.LOT_NO AS ORDER_NUMBER, 
                PO.P_ORDER_ID AS ORDER_ID, 
                EORR.P_DURUM AS DURUM
            FROM         
                PRODUCTION_ORDERS AS PO INNER JOIN
                EZGI_ORDER_REL_RESULT AS EORR ON PO.P_ORDER_ID = EORR.P_ORDER_ID
            ) AS TBL2 RIGHT OUTER JOIN
            (
            <cfif is_type eq 1>
                SELECT     
                    ESR.IS_TYPE, 
                    ESRR.ORDER_ROW_AMOUNT,
                    ESR.SHIP_RESULT_ID, 
                    ESR.OUT_DATE, 
                    ESR.SHIP_METHOD_TYPE, 
                    ESR.DELIVER_PAPER_NO, 
                    ESR.LOCATION_ID, 
                    ESR.DEPARTMENT_ID, 
                    ESR.DEPARTMENT_ID AS DEPARTMENT_IN, 
                    ESRR.ORDER_ROW_ID,
                    ESR.IS_SEVK_EMIR
                FROM         
                    EZGI_SHIP_RESULT AS ESR INNER JOIN
                    EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID
                WHERE      
                    ESR.SHIP_RESULT_ID = #attributes.iid#
            <cfelse>
                SELECT     
                    2 AS IS_TYPE, 
                    SIR.AMOUNT AS ORDER_ROW_AMOUNT,
                    SI.DISPATCH_SHIP_ID AS SHIP_RESULT_ID, 
                    SI.DELIVER_DATE AS OUT_DATE, 
                    SI.SHIP_METHOD AS SHIP_METHOD_TYPE, 
                    CAST(SI.DISPATCH_SHIP_ID AS VARCHAR(50)) AS DELIVER_PAPER_NO, 
                    SI.LOCATION_OUT AS LOCATION_ID, 
                    SI.DEPARTMENT_OUT AS DEPARTMENT_ID, 
                    SI.DEPARTMENT_IN, 
                    SIR.ROW_ORDER_ID AS ORDER_ROW_ID,
                    0 AS IS_SEVK_EMIR
                FROM         
                    #dsn2_alias#.SHIP_INTERNAL AS SI INNER JOIN
                    #dsn2_alias#.SHIP_INTERNAL_ROW AS SIR ON SI.DISPATCH_SHIP_ID = SIR.DISPATCH_SHIP_ID
                WHERE     
                    SI.DISPATCH_SHIP_ID = #attributes.iid#
          	</cfif>
            ) AS TBL ON TBL2.ORDER_ROW_ID = TBL.ORDER_ROW_ID INNER JOIN
            ORDER_ROW AS ORR4 ON TBL.ORDER_ROW_ID = ORR4.ORDER_ROW_ID INNER JOIN
            ORDERS AS O4 ON ORR4.ORDER_ID = O4.ORDER_ID
      	WHERE
        	SHIP_RESULT_ID =  #attributes.iid# 
	</cfquery>
    <!---<cfdump expand="yes" var="#get_order_det#">
    <CFABORT>--->
    <cfset order_row_id_list = Valuelist(get_order_det.ORDER_ROW_ID)>
</cfif>
<cfif isdefined('attributes.type') and attributes.type eq 1>
	<cfset ezgi_header = "<cf_get_lang_main no='3537.Detay Göster'>">
<cfelse>
	<cfset ezgi_header = "<cf_get_lang_main no='3566.Sevkiyat Planı Ekle'>">
</cfif>
<cf_popup_box title="<cfoutput>#ezgi_header#</cfoutput>">
	<cfform name="add_packet_ship" id="add_packet_ship" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_ezgi_shipping&iid=#attributes.iid#">
    	<cfoutput>
		<table>
			<tr>
				<td width="130"></td>
				<td width="210"></td>
				<td width="130"><strong><cfoutput>#getLang('report',1163)#</cfoutput> :<strong> </td>
				<td>#get_shippng_plan.DELIVER_PAPER_NO#</td>
			</tr>
			<tr>
            	<cfif attributes.is_type eq 1>
                    <td><strong><cf_get_lang_main no='107.Cari Hesap'> :<strong> </td>
                    <td>#get_par_info(get_shippng_plan.company_id,1,0,0)# #get_cons_info(get_shippng_plan.consumer_id,1,0,0)#</td>
               	<cfelse>
                	<td><strong><cfoutput>#getLang('objects',715)# #getLang('main',41)#</cfoutput> :<strong> </td>
                    <td>#get_department_in.DEPARTMENT_HEAD#</td>
                </cfif>
                <td><strong><cf_get_lang_main no='1382.Referans No'> :<strong> </td>
				<td>#attributes.reference_no#</td>
			</tr>
			<tr>
				<td><strong><cf_get_lang_main no='166.Yetkili'> :<strong> </td>
				<td>
                	<cfif attributes.is_type eq 1>
						#get_par_info(get_shippng_plan.partner_id,0,-1,0)#
                  	</cfif>
				</td>
                <td><strong><cf_get_lang_main no='1631.Çıkış Depo'> :<strong> </td>
				<td>#attributes.department_name#</td>
			</tr>
			<tr>
				<td><strong><cf_get_lang_main no='1703.Sevk Yöntemi'> :<strong> </td>
				<td>#attributes.ship_method_name#</td>
				<td><strong><cfoutput>#getLang('stock',286)#</cfoutput> :<strong> </td>
				<td>#dateformat(get_shippng_plan.OUT_DATE,'dd/mm/yyyy')#</td>
			</tr>
			<tr>
				<td rowspan="2" valign="top"><strong><cf_get_lang_main no='217.Açıklama'> :<strong> </td>
				<td rowspan="2" valign="top">#get_shippng_plan.NOTE#</td>
				<td><strong><cf_get_lang_main no='233.Teslim Tarih'> :<strong> </td>
				<td>#dateformat(get_shippng_plan.DELIVERY_DATE,'dd/mm/yyyy')#</td>
			</tr>
			<tr>
				<td><strong><cfoutput>#getLang('main',1349)# #getLang('stock',606)#</cfoutput> :<strong> </td>
				<td>#get_emp_info(get_shippng_plan.DELIVER_EMP,0,0)#</td>
			</tr>
            
		</table>
       	</cfoutput>
		<cf_form_list>
			<thead>
				<tr> 
                	<th style="width:80px"><cfoutput>#getLang('main',799)#</cfoutput></th>
                	<th style="width:100px"><cfoutput>#getLang('main',222)#</cfoutput></th>
					<th style="width:390px"><cf_get_lang_main no='245.Ürün'></th>
					<th style="width:80px"><cfoutput>#getLang('main',1351)#</cfoutput></th>
                    <th style="width:80px"><cfoutput>#getLang('myhome',38)#</cfoutput></th>
                    <th style="width:90px"><cfoutput>#getLang('objects2',1669)#</cfoutput></th>
                    <th style="text-align:center; width:15px">
						<cfif isdefined('attributes.type') and attributes.type eq 1>
                        	<cf_get_lang_main no='3341.DRM'>
                        <cfelse>
                        	<input type="checkbox" alt="<cf_get_lang_main no='3009.Hepsini Seç'>" onClick="grupla(-1);">
                 		</cfif>
                    </th>
				</tr>
			</thead>
			<tbody id="table2">
            	<cfset irs_top=0>
            	<cfif get_order_det.recordcount>
                    <cfoutput query="get_order_det">
                        <cfset stock_id=get_order_det.STOCK_ID>
                        <tr>
                        	<td>
                            	<cfif attributes.is_type eq 1>
                                    <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.list_order&event=upd&order_id=#get_order_det.sa_order_id#','longpage');" class="tableyazi" title="<cf_get_lang_main no='3532.Satış Siparişine Git'>">
                                    	#get_order_det.SA_ORDER_NUMBER#
                                    </a>
                                <cfelse>
                                	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.upd_fast_sale&order_id=#get_order_det.sa_order_id#','wide');" class="tableyazi" title="<cf_get_lang_main no='3532.Satış Siparişine Git'>">
                                    	#get_order_det.SA_ORDER_NUMBER#
                                    </a>
                                </cfif>
                           	</td>
                        	<td>#get_order_det.STOCK_CODE_2#</td>
                            <td>#get_order_det.PRODUCT_NAME#</td>
                            <td style="text-align:right;">
                            	<cfif IS_KARMA eq 1>
                            	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_dsp_karma_koli&pid=#product_id#','small');">#AmountFormat(get_order_det.DEPO)#</a>
                                <cfelse>
                                	#AmountFormat(get_order_det.DEPO)#
                                </cfif>
                                
                            </td>
                            <td style="text-align:right;">#AmountFormat(get_order_det.ORDER_ROW_AMOUNT)#</td>
                            <td style="text-align:center; font-weight:bold">
                            	<cfif TYPE eq 3>
                                	<font color="<cfif durum eq 1>green<cfelseif durum eq 2>red<cfelseif durum eq 0>orange<cfelse>blue</cfif>">
                                		#SV_ORDER_NUMBER#
                                    </font>
                                <cfelse>
                                	#SV_ORDER_NUMBER#
                                </cfif>
                            </td>
                            <td style="text-align:center;">
                                	<cfif order_row_currency eq -8 or order_row_currency eq -9 or order_row_currency eq -10 or order_row_currency eq -3>
                                    	<img src="/images/b_ok.gif" border="0" title="<cf_get_lang_main no='3570.İşlem Yapılamaz'>" />
                                  	<cfelseif order_row_currency eq -6>
                                    	<img src="/images/c_ok.gif" border="0" title="<cf_get_lang_main no='3538.Sevk Emri Verildi.'>" />
                                	<cfelse>
                                	<input type="checkbox" name="select_production" value="#WRK_ROW_ID#">
                                	</cfif>
                            </td>
                        </tr>
                    </cfoutput>
				</cfif>
                <tfoot>
                	<tr>
                    	<cfif isdefined('attributes.type') and attributes.type eq 1>
                        	<td colspan="8"></td>
                        <cfelse>
                        	<td colspan="5" align="right">
                            	<select name="select_name" id="select_name" onchange="degisim();">
                                	<option value="1" <cfif get_shippng_plan.IS_SEVK_EMIR eq 1>selected</cfif>><cf_get_lang_main no='3579.Sevkiyata Emir Verildi	'></option>
                                    <option value="0" <cfif get_shippng_plan.IS_SEVK_EMIR eq 0>selected</cfif>><cf_get_lang_main no='3580.Sevkiyata Emir Verilmedi'></option>
                            	</select>
                            </td>
            				<td colspan="3" align="right"><input type="button" value="<cf_get_lang_main no='2598.Sevk Et'>" onClick="grupla();"></td>
                        </cfif>
            		</tr>
                </tfoot>
            </tbody>
		</cf_form_list>
		
	</cfform>  
</cf_popup_box>      
<script language="javascript">
	function grupla(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
			order_row_id_list = '';
			chck_leng = document.getElementsByName('select_production').length;
			for(ci=0;ci<chck_leng;ci++)
			{
				var my_objets = document.all.select_production[ci];
				if(chck_leng == 1)
					var my_objets =document.all.select_production;
				if(type == -1)
				{//hepsini seç denilmişse	
					if(my_objets.checked == true)
						my_objets.checked = false;
					else
						my_objets.checked = true;
				}
				else
				{
					if(my_objets.checked == true)

						order_row_id_list +=my_objets.value+',';
				}
			}
			order_row_id_list = order_row_id_list.substr(0,order_row_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(order_row_id_list!='')
			{
			window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_upd_ezgi_order_row&order_row_id_list='+order_row_id_list);
			}
	}
	function degisim()
	{
		sevk_emir = document.getElementById('select_name').value;
		window.open('<cfoutput>#request.self#?fuseaction=sales.emptypopup_upd_ezgi_sevk_emir&upd_id=#attributes.iid#&is_type=#attributes.is_type#</cfoutput>&sevk_emir='+sevk_emir);
	}
</script>