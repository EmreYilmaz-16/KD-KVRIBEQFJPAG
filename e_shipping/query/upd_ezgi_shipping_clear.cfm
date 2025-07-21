<cfif isdefined('attributes.change')> <!---Sevkiyat Köntrolü Satır Bazına Çevir--->
	<cftransaction>
        <cfquery name="del_shipping_row" datasource="#dsn3#"><!---Kontrol satırı siliniyor--->
            DELETE FROM EZGI_SHIPPING_PACKAGE_LIST WHERE SHIPPING_ID = #attributes.ship_id#                          
        </cfquery>
        <cfquery name="add_shipping_row_control" datasource="#dsn3#">
            INSERT INTO 
                EZGI_SHIPPING_PACKAGE_LIST
                (
                    SHIPPING_ID, 
                    SHIPPING_ROW_ID, 
                    STOCK_ID, 
                    AMOUNT, 
                    CONTROL_AMOUNT, 
                    REF_STOCK_ID, 
                    CONTROL_STATUS, 
                    TYPE, 
                    RECORD_EMP, 
                    RECORD_DATE
                )
            SELECT        
                ESR.SHIP_RESULT_ID, 
                ESR.SHIP_RESULT_ROW_ID, 
                EPS.PAKET_ID, 
                ORR.QUANTITY * EPS.PAKET_SAYISI AS Expr1, 
                ORR.QUANTITY * EPS.PAKET_SAYISI AS Expr2, 
                ORR.STOCK_ID, 
                1 AS Expr3, 
                1 AS Expr4,
                #session.ep.userid#,
                #now()#
            FROM            
                EZGI_SHIP_RESULT_ROW AS ESR INNER JOIN
                ORDER_ROW AS ORR ON ESR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID
            WHERE        
                ESR.SHIP_RESULT_ID = #attributes.ship_id#
        </cfquery>
    </cftransaction>
    <cflocation url="#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_term_control&ship_id=#attributes.ship_id#&is_type=1" addtoken="No">
<cfelse> <!---Temizleme İşlemi--->
	<cfif len(attributes.row_id_list)>
        <cftransaction>
            <cfloop list="#attributes.row_id_list#" index="i">
                <cfif isdefined('input_#i#')> <!---Checkbox işaretli ise--->
                    <cfif isdefined('quantity_#i#') and isdefined('rate_#i#')> <!---Sipariş miktarı ve işlem miktarı tanımlı ise--->
                        <cfset old_rate = FilterNum(Evaluate('rate_#i#'),3)/FilterNum(Evaluate('quantity_#i#'),3)>
                        <cfset new_rate = 1-old_rate> 
                        <cfset new_amount = FilterNum(Evaluate('quantity_#i#'),3) - FilterNum(Evaluate('rate_#i#'),3)>
                        <cfset old_amount = FilterNum(Evaluate('rate_#i#'),3)>
                        <cfif attributes.is_type eq 1> <!---Sevk Planıysa--->
                            <cfif FilterNum(Evaluate('rate_#i#'),0) eq 0><!--- Kontrol Yapılmamış yani sevkten çıkarılacaksa--->
                                <cfquery name="del_shipping_row" datasource="#dsn3#"><!---Sevk Planı satırı siliniyor--->
                                    DELETE FROM EZGI_SHIP_RESULT_ROW WHERE SHIP_RESULT_ROW_ID = #i#
                                </cfquery>
                            <cfelse> <!---Sipariş Düzeltilecekse--->
                                <cfif isdefined('attributes.order_row_id_#i#')>
                                    <cfquery name="upd_shipping_row" datasource="#dsn3#"> <!---Sevk Planı satırı düzeltiliyor--->
                                        UPDATE EZGI_SHIP_RESULT_ROW SET ORDER_ROW_AMOUNT =#FilterNum(Evaluate('rate_#i#'),0)# WHERE SHIP_RESULT_ROW_ID = #i#
                                    </cfquery>
                                </cfif>
                                <cfinclude template="upd_ezgi_shipping_clear_order_row.cfm"><!---Sipariş Satırları Güncelleniyor--->
                            </cfif>
                        <cfelse> <!---Sevk Talebiyse--->
                            <cfif FilterNum(Evaluate('rate_#i#'),0) eq 0><!--- Kontrol Yapılmamış yani sevkten çıkarılacaksa--->
                                <cfquery name="del_shipping_row" datasource="#dsn3#"><!---Sevk Talebi satırı siliniyor--->
                                    DELETE FROM #dsn2_alias#.SHIP_INTERNAL_ROW WHERE SHIP_ROW_ID = #i#
                                </cfquery>
                            <cfelse> <!---Sipariş Düzeltilecekse--->
                                <cfif isdefined('attributes.order_row_id_#i#')>
                                    <cfquery name="upd_shipping_row" datasource="#dsn3#"> <!---Sevk Talebi satırı düzeltiliyor--->
                                        UPDATE #dsn2_alias#.SHIP_INTERNAL_ROW SET AMOUNT = #FilterNum(Evaluate('rate_#i#'),0)# WHERE SHIP_ROW_ID = #i#
                                    </cfquery>
                                </cfif>
                                <cfinclude template="upd_ezgi_shipping_clear_order_row.cfm"><!---Sipariş Satırları Güncelleniyor--->
                            </cfif>
                        </cfif>
                        <!---<cfoutput>#old_rate# - #new_rate# - #old_amount# - #new_amount# #temp_wrk_row_id#</cfoutput><br />--->
                    </cfif>
                </cfif>
            </cfloop>
        </cftransaction>
        <script type="text/javascript">
            alert("<cf_get_lang_main no='3590.Sevk Edilemeyen Satırlar Plandan Çıkarılacaktır'>!");
            wrk_opener_reload();
            window.close()
        </script>
        <cfabort>
    </cfif>
</cfif>