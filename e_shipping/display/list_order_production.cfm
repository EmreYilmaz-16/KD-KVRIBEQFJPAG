<cfquery name="get_order_det" datasource="#DSN3#">
	SELECT     
    	ORR.STOCK_ID, ORR.QUANTITY, ORR.ORDER_ROW_ID, ORD.ORDER_ID, ORD.ORDER_HEAD, ORD.ORDER_NUMBER, ORR.SPECT_VAR_ID, 
       	ORR.SPECT_VAR_NAME, S.PRODUCT_NAME, S.STOCK_CODE, S.STOCK_CODE_2, PO.FINISH_DATE, PO.QUANTITY AS P_QUANTITY, PO.LOT_NO, ISNULL
                          ((SELECT     TOP (1) IS_STAGE
                              FROM         PRODUCTION_ORDERS AS PRODUCTION_ORDERS_1
                              WHERE     (LOT_NO = PO.LOT_NO) AND (STATION_ID = 8 OR
                                                    STATION_ID = 129)), - 1) AS STATION_8, ISNULL
                          ((SELECT     TOP (1) IS_STAGE
                              FROM         PRODUCTION_ORDERS
                              WHERE     (LOT_NO = PO.LOT_NO) AND (STATION_ID = 7 OR
                                                    STATION_ID = 125)), - 1) AS STATION_7, ISNULL
                          ((SELECT     TOP (1) IS_STAGE
                              FROM         PRODUCTION_ORDERS AS PRODUCTION_ORDERS_1
                              WHERE     (LOT_NO = PO.LOT_NO) AND (STATION_ID = 6)), - 1) AS STATION_6, ISNULL
                          ((SELECT     TOP (1) IS_STAGE
                              FROM         PRODUCTION_ORDERS AS PRODUCTION_ORDERS_1
                              WHERE     (LOT_NO = PO.LOT_NO) AND (STATION_ID = 4 OR
                                                    STATION_ID = 127)), - 1) AS STATION_4, ISNULL
                          ((SELECT     TOP (1) IS_STAGE
                              FROM         PRODUCTION_ORDERS AS PRODUCTION_ORDERS_1
                              WHERE     (LOT_NO = PO.LOT_NO) AND (STATION_ID = 3 OR
                                                    STATION_ID = 141)), - 1) AS STATION_3
	FROM         
    	PRODUCTION_ORDERS AS PO INNER JOIN
     	PRODUCTION_ORDERS_ROW AS POR ON PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID RIGHT OUTER JOIN
      	ORDER_ROW AS ORR INNER JOIN
       	ORDERS AS ORD ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
      	STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID ON POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
	WHERE     
    	(PO.PRODUCTION_LEVEL = 0) AND 
        (S.PRODUCT_CODE NOT LIKE '01.152.01%') AND
        (ORD.ORDER_ID = #attributes.order_id#)
</cfquery>
<cfset order_row_id_list = Valuelist(get_order_det.ORDER_ROW_ID)>
<cfset amount_round = 2>	
<table class="dph">
	<tr> 
		<td class="dpht"><cf_get_lang_main no='199.Sipariş'> <cf_get_lang_main no='44.Üretim'> <cf_get_lang_main no='577.ve'> <cf_get_lang_main no='1948.Tedarik'> <cfoutput>#getLang('sales',114)#</cfoutput></td>
	</tr>
</table>
<cf_seperator id="iliskili_fatura" header="<cf_get_lang_main no='3564.İlişkili Koltuk Üretim Emirleri'>">
<table id="iliskili_fatura" width="100%">
	<tr>
		<td>
			<cf_medium_list>
				<thead>
					<tr> 
                    	<th><cf_get_lang_main no='106.Stok Kodu'></th>
						<th><cf_get_lang_main no='245.Ürün'></th>
						<th width="50" style="text-align:right;"><cf_get_lang_main no='199.Sipariş'></th>
						<th width="50" style="text-align:right;"><cf_get_lang_main no='44.Üretim '></th>
                        <th width="60"><cf_get_lang_main no='288.Bitiş Tarihi '></th>
                        <th width="70"><cfoutput>#getLang('prod',385)#</cfoutput></th>
                        <th width="20">OPT</th>
                        <th width="20">MLZ</th>
                        <th width="20">KSM</th>
                        <th width="20">KNF</th>
                        <th width="20">DŞM</th>
                        <th width="20">KK.</th>
                        <th width="20">AMB</th>
					</tr>
				</thead>
				<tbody>
					<cfif get_order_det.recordcount>
                        <cfform name="ship_internal" action="" method="post">
                            <cfoutput query="get_order_det">
                                <tr>
                                	<td>#get_order_det.STOCK_CODE#</td>
                                    <td>#get_order_det.PRODUCT_NAME#</td>
                                    <td style="text-align:right;">#TLFormat(get_order_det.QUANTITY,amount_round)#</td>
                                    <td style="text-align:right;">#TLFormat(get_order_det.P_QUANTITY,amount_round)#</td>
                                    <td style="text-align:center;">#DateFormat(get_order_det.FINISH_DATE,'dd/mm/yyyyY')#</td>
                                    <td style="text-align:center;">#get_order_det.LOT_NO#</td>
                                    <cfquery name="get_kontrol_0" datasource="#dsn3#"> <!---Optimizasyona ve Var-yok a giren emirler soruluyor--->
                                        SELECT DISTINCT 
                                            POS.STOCK_ID, 
                                            POS.AMOUNT,
                                            EMC.STATUS
                                        FROM         
                                            EZGI_METARIAL_CONTROL AS EMC INNER JOIN
                                            PRODUCTION_ORDERS_STOCKS AS POS ON EMC.POR_STOCK_ID = POS.POR_STOCK_ID
                                        WHERE     
                                            EMC.LOT_NO = N'#lot_no#' 
                                  	</cfquery>
                                  	<cfquery name="get_kontrol_1" dbtype="query"> <!---Var Denilenler Bulunuyor--->
                                    	SELECT
                                       		STOCK_ID, 
                                            AMOUNT
                                       	FROM         
                                        	get_kontrol_0
                                    	WHERE     
                                      		STATUS = 1
                                  	</cfquery>
                                 	<cfquery name="get_kontrol_2" dbtype="query"> <!---Yok Denilenler Bulunuyor--->
                                    	SELECT
                                         	STOCK_ID, 
                                           	AMOUNT
                                      	FROM         
                                        	get_kontrol_0
                                    	WHERE     
                                         	STATUS = 2
                                     	</cfquery>
                                      	<cfquery name="get_ezgi_metarial_control" dbtype="query"> <!---Yok Denilenler Guruplanıyor--->
                                        	SELECT
                                            	STOCK_ID, 
                                            	SUM(AMOUNT) AS AMOUNT
                                         	FROM         
                                            	get_kontrol_2
                                          	GROUP BY 
                                              	STOCK_ID
                                       	</cfquery>
                                     	<cfquery name="get_ezgi_metarial_control_0" dbtype="query"> <!---Optimizasyondan Geçen heşey guruplanıyor--->
                                         	SELECT
                                            	STOCK_ID, 
                                             	SUM(AMOUNT) AS AMOUNT
                                       		FROM         
                                           		get_kontrol_0
                                          	GROUP BY 
                                            	STOCK_ID
                                    	</cfquery>
                                       	<cfloop query="get_ezgi_metarial_control_0">
                                         	<cfset 'CONTROL_#get_order_det.lot_no#_#get_ezgi_metarial_control_0.STOCK_ID#'= get_ezgi_metarial_control_0.AMOUNT>
                                      	</cfloop>
                                     	<cfquery name="get_ic_talep" datasource="#dsn3#">
                                          		SELECT     
                                             		I.INTERNAL_NUMBER, 
                                                 	EMR.ACTION_ID, 
                                                  	IR.STOCK_ID
                                              	FROM         
                                                   	EZGI_METARIAL_RELATIONS AS EMR INNER JOIN
                                                   	INTERNALDEMAND AS I ON EMR.ACTION_ID = I.INTERNAL_ID INNER JOIN
                                                   	INTERNALDEMAND_ROW AS IR ON I.INTERNAL_ID = IR.I_ID
                                              	WHERE     
                                               		EMR.TYPE = 1 AND 
                                                   	EMR.LOT_NO = N'#lot_no#' AND
                                                    IR.STOCK_ID IN 
                                                    				(
                                                                	SELECT     
                                                                   		STOCK_ID
																	FROM         
                                                                     	STOCKS
																	WHERE     
                                                                     	STOCK_CODE LIKE N'01.150.07%'
                                                                  	)
                                    	</cfquery>
                                                
                                   		<cfquery name="get_period" datasource="#dsn3#">
                                                    SELECT     
                                                        PERIOD_ID
                                                    FROM         
                                                        EZGI_METARIAL_RELATIONS
                                                    WHERE     
                                                        TYPE = 2 AND 
                                                        LOT_NO = '#lot_no#'
                                     	</cfquery>
                                     	<cfset teslim = 0>
                                      	<cfset teslim_1 = 0>
                                      	<cfif get_period.recordcount>
                                       		<cfset period_list = ValueList(get_period.PERIOD_ID)>
                                           	<cfquery name="get_period_ship_dsns" datasource="#dsn3#">
                                         		SELECT PERIOD_YEAR,OUR_COMPANY_ID,PERIOD_ID FROM #dsn_alias#.SETUP_PERIOD WHERE PERIOD_ID IN (#period_list#)
                                           	</cfquery>
                                     	</cfif>
                                    	<cfif isdefined('period_list') and listlen(period_list) and period_list neq 0>
                                       		<cfquery name="get_control_ambar_fis" datasource="#DSN3#">
                                            	SELECT 
                                               		STOCK_ID,
                                                	SUM(AMOUNT) AMOUNT
                                               	FROM
                                                 	(
                                                            <cfloop query="get_period_ship_dsns">
                                                                SELECT     
                                                                    SFR.STOCK_ID, 
                                                                    SFR.AMOUNT
                                                                FROM         
                                                                    EZGI_METARIAL_RELATIONS INNER JOIN
                                                                    #dsn#_#get_period_ship_dsns.PERIOD_YEAR#_#get_period_ship_dsns.OUR_COMPANY_ID#.dbo.STOCK_FIS_ROW AS SFR ON EZGI_METARIAL_RELATIONS.ACTION_ID = SFR.FIS_ID
                                                                WHERE     
                                                                    EZGI_METARIAL_RELATIONS.TYPE = 2 AND 
                                                                    EZGI_METARIAL_RELATIONS.PERIOD_ID = #get_period_ship_dsns.period_id# AND 
                                                                    EZGI_METARIAL_RELATIONS.LOT_NO = N'#get_order_det.lot_no#' and
                                                                    SFR.STOCK_ID IN (
                                                                				SELECT     
                                                                                	STOCK_ID
																				FROM         
                                                                                	STOCKS
																				WHERE     
                                                                                	STOCK_CODE LIKE N'01.150.07%'
                                                                              	)
                                                                <cfif currentrow neq get_period_ship_dsns.recordcount> UNION ALL </cfif> 
                                                            </cfloop>
                                                            ) TBL
                                                        GROUP BY
                                                            STOCK_ID 			
                                   			</cfquery>
                                        	<cfif get_control_ambar_fis.recordcount>
                                             	<cfif get_control_ambar_fis.recordcount neq get_ezgi_metarial_control_0.recordcount>
                                                  	<cfset teslim = 2>		
                                              	<cfelse>
                                                  	<cfset teslim = 1>
                                              	</cfif>
                                         	<cfelse>
                                              	<cfset teslim = 0>
                                          	</cfif>
                                       	</cfif>
                                    	<td align="center">
                                         	<cfif get_kontrol_0.recordcount eq 0>
                                                        <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.emptypopup_add_ezgi_metarial_control&lot_no=#LOT_NO#','page');"> <img src="/images/offlineuser.gif" tittle="<cf_get_lang_main no='3319.Optimizasyon Onay Verilmedi'>" border="0">
                                                        </a>
                                                    <cfelse>
                                                        <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.emptypopup_add_ezgi_metarial_control&lot_no=#LOT_NO#','page');"> 
                                                         <img src="/images/onlineuser_1.gif" tittle="<cf_get_lang_main no='3320.Optimizasyon Onay Verildi'>">
                                                         </a>
                                                    </cfif> 
                                                </td>
                                                <td align="center">
                                                    <cfif get_kontrol_0.recordcount>
                                                        
                                                            <cfif get_kontrol_1.recordcount neq get_kontrol_0.recordcount>	
                                                                <cfif get_ic_talep.recordcount eq 0>
                                                                    <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.emptypopup_add_ezgi_metarial_control&lot_no=#LOT_NO#','page');"> <img src="/images/offlineuser.gif" tittle="<cf_get_lang_main no='3321.İç Talep Verilmedi'>">
                                                                    </a>
                                                                <cfelse>
                                                                    <cfif get_ic_talep.recordcount neq get_ezgi_metarial_control.recordcount>
                                                                        <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.emptypopup_add_ezgi_metarial_control&lot_no=#LOT_NO#','page');"> <img src="/images/onlineuser.gif" tittle="<cf_get_lang_main no='3322.İç Talep Eksik Verildi'>">
                                                                        </a>
                                                                    <cfelse>
                                                                        <cfif teslim eq 0>
                                                                            <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.emptypopup_add_ezgi_metarial_ambar_fisi&lot_no=#LOT_NO#','page');"> <img src="/images/onlineuser_2.gif" tittle="<cf_get_lang_main no='3323.İç Talep Tam Verildi'>">
                                                                            </a>
                                                                        <cfelseif teslim eq 1>
                                                                            <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.emptypopup_add_ezgi_metarial_ambar_fisi&lot_no=#LOT_NO#','page');">
                                                                            <img src="/images/onlineuser_1.gif" tittle="<cf_get_lang_main no='3324.Tam Ambar Fişi'>">
                                                                            </a>
                                                                        <cfelseif teslim eq 2>
                                                                            <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.emptypopup_add_ezgi_metarial_ambar_fisi&lot_no=#LOT_NO#','page');">
                                                                            <img src="/images/onlineuser_3.gif" tittle="<cf_get_lang_main no='3325.Eksik Ambar Fişi'>">
                                                                            </a>
                                                                        </cfif>      
                                                                    </cfif>
                                                                </cfif>
                                                            <cfelse>
                                                                <cfif teslim eq 0>
                                                                <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.emptypopup_add_ezgi_metarial_ambar_fisi&lot_no=#LOT_NO#','page');"> <img src="/images/onlineuser_2.gif" tittle="<cf_get_lang_main no='3326.Kumaşlar Mevcut'>">
                                                                </a>
                                                                <cfelseif teslim eq 1>
                                                                    <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.emptypopup_add_ezgi_metarial_ambar_fisi&lot_no=#LOT_NO#','page');">
                                                                    <img src="/images/onlineuser_1.gif" tittle="<cf_get_lang_main no='3324.Tam Ambar Fişi'>">
                                                                    </a>
                                                                <cfelseif teslim eq 2>
                                                                    <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.emptypopup_add_ezgi_metarial_ambar_fisi&lot_no=#LOT_NO#','page');">
                                                                    <img src="/images/onlineuser_3.gif" tittle="<cf_get_lang_main no='3325.Eksik Ambar Fişi'>">
                                                                    </a>
                                                                </cfif>
                                                            </cfif>
                                                    </cfif>              
                                                </td>
                                    
                                    <td style="text-align:center;">
                                    	<cfif STATION_8 eq 0>
                                        	<img src="/images/yellow_glob.gif" title="<cf_get_lang_main no='3279.Başlamadı'>">
                                        <cfelseif STATION_8 eq 1>
                                        	<img src="/images/green_glob.gif" title="<cfoutput>#getLang('project',230)#</cfoutput>">
                                       	<cfelseif STATION_8 eq 2>
                                        	<img src="/images/red_glob.gif" title="<cf_get_lang_main no='1374.Tamamlandı'>">
                                       	<cfelseif STATION_8 eq -1>
                                        	<img src="/images/grey_glob.gif" title="<cf_get_lang_main no='3327.Emir Bulunamadı'>">
                                       	<cfelse>
                                        	<img src="/images/blue_glob.gif" title="<cf_get_lang_main no='3502.Planlanıyor'>">
                                        </cfif>
                                     </td>
                                    <td style="text-align:center;">
                                    	<cfif STATION_3 eq 0>
                                        	<img src="/images/yellow_glob.gif" title="<cf_get_lang_main no='3279.Başlamadı'>">
                                        <cfelseif STATION_3 eq 1>
                                        	<img src="/images/green_glob.gif" title="<cfoutput>#getLang('project',230)#</cfoutput>">
                                       	<cfelseif STATION_3 eq 2>
                                        	<img src="/images/red_glob.gif" title="<cf_get_lang_main no='1374.Tamamlandı'>">
                                       	<cfelseif STATION_3 eq -1>
                                        	<img src="/images/grey_glob.gif" title="<cf_get_lang_main no='3327.Emir Bulunamadı'>">
                                       	<cfelse>
                                        	<img src="/images/blue_glob.gif" title="<cf_get_lang_main no='3502.Planlanıyor'>">
                                        </cfif>
                                    </td>
                                    <td style="text-align:center;">
                                    	<cfif STATION_4 eq 0>
                                        	<img src="/images/yellow_glob.gif" title="<cf_get_lang_main no='3279.Başlamadı'>">
                                        <cfelseif STATION_4 eq 1>
                                        	<img src="/images/green_glob.gif" title="<cfoutput>#getLang('project',230)#</cfoutput>">
                                       	<cfelseif STATION_4 eq 2>
                                        	<img src="/images/red_glob.gif" title="<cf_get_lang_main no='1374.Tamamlandı'>">
                                       	<cfelseif STATION_4 eq -1>
                                        	<img src="/images/grey_glob.gif" title="<cf_get_lang_main no='3327.Emir Bulunamadı'>">
                                       	<cfelse>
                                        	<img src="/images/blue_glob.gif" title="<cf_get_lang_main no='3502.Planlanıyor'>">
                                        </cfif>
                                    </td>
                                    <td style="text-align:center;">
                                    	<cfif STATION_6 eq 0>
                                        	<img src="/images/yellow_glob.gif" title="<cf_get_lang_main no='3279.Başlamadı'>">
                                        <cfelseif STATION_6 eq 1>
                                        	<img src="/images/green_glob.gif" title="<cfoutput>#getLang('project',230)#</cfoutput>">
                                       	<cfelseif STATION_6 eq 2>
                                        	<img src="/images/red_glob.gif" title="<cf_get_lang_main no='1374.Tamamlandı'>">
                                       	<cfelseif STATION_6 eq -1>
                                        	<img src="/images/grey_glob.gif" title="<cf_get_lang_main no='3327.Emir Bulunamadı'>">
                                       	<cfelse>
                                        	<img src="/images/blue_glob.gif" title="<cf_get_lang_main no='3502.Planlanıyor'>">
                                        </cfif>
                                    </td>
                                    <td style="text-align:center;">
                                    	<cfif STATION_7 eq 0>
                                        	<img src="/images/yellow_glob.gif" title="<cf_get_lang_main no='3279.Başlamadı'>">
                                        <cfelseif STATION_7 eq 1>
                                        	<img src="/images/green_glob.gif" title="<cfoutput>#getLang('project',230)#</cfoutput>">
                                       	<cfelseif STATION_7 eq 2>
                                        	<img src="/images/red_glob.gif" title="<cf_get_lang_main no='1374.Tamamlandı'>">
                                       	<cfelseif STATION_7 eq -1>
                                        	<img src="/images/grey_glob.gif" title="<cf_get_lang_main no='3327.Emir Bulunamadı'>">
                                       	<cfelse>
                                        	<img src="/images/blue_glob.gif" title="<cf_get_lang_main no='3502.Planlanıyor'>">
                                        </cfif>
                                    </td>
                                </tr>
                            </cfoutput>
                        </cfform>
					</cfif>
				</tbody>
                <tfoot>
                	<tr class="color-list" height="35">
                      	<td align="right" valign="middle" colspan="13">&nbsp;</td>
                   	</tr>
              	</tfoot>
			</cf_medium_list>
      	</td>      
	</tr>
</table>
