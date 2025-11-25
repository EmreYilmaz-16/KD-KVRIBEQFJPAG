   <!-- Deserialize JSON payload if it's a string -->
            <cfif isJSON(arguments.payload)>
                <cfset arguments.payload = deserializeJSON(arguments.payload)>
            </cfif>

            <!-- Validate payload -->
            <cfif NOT isStruct(arguments.payload)>
                <cfthrow message="Payload is invalid or missing." type="ValidationError">
            </cfif>

            <!-- Extract offers from payload -->
            <cfset var offers = arguments.payload>
            <cfset session=offers.session_variables>
            <!-- Log the payload for debugging -->
            <cflog file="purchaseService" text="Received payload: #serializeJSON(offers)#" type="information">

            <cfquery name="DEL" datasource="#dsn3#">
                DELETE FROM PBS_SELECTED_ROWS WHERE OFFER_ID = '#offers.offer_id#' AND BASKET_EXTRA_INFO=#offers.BEI#
            </cfquery>
            <!-- Process each offer -->
            <cfset ix=0>
            <cfloop array="#offers.payload#" item="offer">
                <cfset var products = offer.products>

                <!-- Process each product -->
                <cfloop array="#products#" item="product">
                    <!-- Delete existing rows for the product -->
                   

                    <!-- Insert new rows for the product -->
                    <cfquery name="INS" datasource="#dsn3#">
                        INSERT INTO PBS_SELECTED_ROWS (
                            WRK_ROW_ID,
                            PRICE,
                            OFFER_ID,
                            PRODUCT_MARJ,
                            SALE_PRICE,
                            IS_OS,
                            BASKET_EXTRA_INFO,
                            OEM_NO,
                            OTHER_MONEY,
                            DSC1,
                            DSC2,
                            DSC3
                        )
                        VALUES (
                            '#product.wrkRowId#',
                            #product.netPrice#,
                            #offers.offer_id#,
                            #product.productMarj#,
                            #product.salePrice#,
                            1,
                            #product.selectInfoExtra#,
                            '#product.oemNo#',
                            '#product.demandMoney#',
                            #product.discount1#,
                            #product.discount2#,
                            #product.discount3#
                        )
                    </cfquery>
                    <cfquery name="getStockInfo" datasource="#dsn3#">
                        SELECT * FROM STOCKS WHERE STOCK_ID=#product.stockId#
                    </cfquery>
                      <cfquery name="getUnit" datasource="#dsn3#">
                        select PRODUCT_UNIT_ID,MAIN_UNIT from #dsn3#.PRODUCT_UNIT where PRODUCT_ID=#product.productId#
                    </cfquery>
                    <cfscript>
                        ix=ix+1;
                        attributes["price#ix#"] = product.salePrice;
                        attributes["price_other#ix#"] = product.convertedsalePriceOther;
                        attributes["tax#ix#"] = product.tax;
                        attributes["amount#ix#"] = product.quantity;
                        attributes["indirim1#ix#"] = product.discount1;
                        attributes["other_money_#ix#"] = product.otherMoney;
                        attributes["product_id#ix#"] = product.productId;
                        attributes["stock_id#ix#"] = product.stockId;
                        attributes["unit#ix#"] = getUnit.MAIN_UNIT;
                        attributes["unit_id#ix#"] = getUnit.PRODUCT_UNIT_ID;
                        attributes["product_name#ix#"] = product.productName;
                        attributes["other_money_value_#ix#"] = (product.convertedsalePriceOther * product.quantity) - ((product.convertedsalePriceOther * product.quantity) * product.discount1) / 100;
                        attributes["description#ix#"] = "";
                        attributes["wrk_row_id#ix#"] = "PBS#session.ep.userid##dateFormat(now(), 'yyyymmdd')##timeFormat(now(), 'hhmmnnl')#";
                        attributes["wrk_row_relation_id#ix#"] = product.wrkRowId;
                        attributes["is_virtual#ix#"] = 0;
                        attributes["SHELF_CODE#ix#"] = "";
                        attributes["OFFER_ROW_CURRENCY#ix#"] = "";
                        
                    </cfscript>
                </cfloop>
            </cfloop>
        


    



