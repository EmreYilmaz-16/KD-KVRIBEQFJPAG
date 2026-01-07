<cfparam name="attributes.is_submit" default="">
<cfparam name="attributes.PID" default="">
<cfparam name="attributes.is_delete" default="">

<cfif isDefined("attributes.is_delete") and attributes.is_delete EQ "Y">
    <cfquery name="delete_karma_product" datasource="#dsn1#">
        DELETE FROM KARMA_PRODUCTS_PBS
        WHERE PRODUCT_ID=<cfqueryparam value="#form.delete_product_id#" cfsqltype="cf_sql_integer">
        AND MAIN_PRODUCT_ID=<cfqueryparam value="#form.MAIN_PRODUCT_ID#" cfsqltype="cf_sql_integer">
    </cfquery>
    <script>alert('Ürün başarıyla silindi!'); window.location.href='#request.self#?fuseaction=#attributes.fuseaction#&PID=#form.MAIN_PRODUCT_ID#';</script>
</cfif>

<cfif isDefined("attributes.is_submit") and attributes.is_submit EQ "Y">
   <cfquery name="add_history" datasource="#dsn1#">
        INSERT INTO KARMA_PRODUCTS_PBS_HISTORY (PRODUCT_ID,QUANTITY,MAIN_PRODUCT_ID,ADDED_DATE,RECORD_EMPLOYEE_ID,RECORD_DATE)
        SELECT PRODUCT_ID,QUANTITY,MAIN_PRODUCT_ID,GETDATE(),RECORD_EMPLOYEE_ID,RECORD_DATE FROM KARMA_PRODUCTS_PBS
        WHERE MAIN_PRODUCT_ID=<cfqueryparam value="#form.MAIN_PRODUCT_ID#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cfquery name="delete_existing" datasource="#dsn1#">
        DELETE FROM KARMA_PRODUCTS_PBS
        WHERE MAIN_PRODUCT_ID=<cfqueryparam value="#form.MAIN_PRODUCT_ID#" cfsqltype="cf_sql_integer">
    </cfquery>
   <cfquery name="insertKarmaProduct" datasource="#dsn1#">
        INSERT INTO KARMA_PRODUCTS_PBS (PRODUCT_ID,QUANTITY,MAIN_PRODUCT_ID,RECORD_DATE,RECORD_EMPLOYEE_ID)
        VALUES (
            <cfqueryparam value="#form.product_id#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#form.quantity#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#form.MAIN_PRODUCT_ID#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
            <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">
        )
    </cfquery>
</cfif>
<cfquery name="getProductInfo" datasource="#dsn1#">
    SELECT PRODUCT_NAME FROM PRODUCT WHERE PRODUCT_ID=<cfqueryparam value="#attributes.PID#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="getKarmaProducts" datasource="#dsn1#">
    SELECT KP.PRODUCT_ID,KP.QUANTITY,KP.MAIN_PRODUCT_ID,P.PRODUCT_NAME FROM KARMA_PRODUCTS_PBS AS KP
    LEFT JOIN PRODUCT AS P ON KP.PRODUCT_ID=P.PRODUCT_ID
      WHERE KP.MAIN_PRODUCT_ID=<cfqueryparam value="#attributes.PID#" cfsqltype="cf_sql_integer">
</cfquery>


<style>
    .karma-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 10px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.2);
    }
    .karma-card-title {
        color: white;
        font-size: 24px;
        font-weight: bold;
        margin-bottom: 20px;
        text-align: center;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    }
    .form-card {
        background: white;
        border-radius: 8px;
        padding: 25px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    .form-label {
        font-weight: 600;
        color: #333;
        margin-bottom: 8px;
        display: block;
        font-size: 14px;
    }
    .form-control-custom {
        width: 100%;
        padding: 10px 15px;
        border: 2px solid #e0e0e0;
        border-radius: 6px;
        font-size: 14px;
        transition: all 0.3s;
    }
    .form-control-custom:focus {
        border-color: #667eea;
        outline: none;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }
    .btn-add {
        background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
        color: white;
        padding: 12px 30px;
        border: none;
        border-radius: 6px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s;
        width: 100%;
        font-size: 16px;
        margin-top: 10px;
    }
    .btn-add:hover {
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(56, 239, 125, 0.4);
    }
    .table-card {
        background: white;
        border-radius: 8px;
        padding: 20px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    .table-custom {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
    }
    .table-custom thead th {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 15px;
        text-align: left;
        font-weight: 600;
        border: none;
    }
    .table-custom thead th:first-child {
        border-top-left-radius: 8px;
    }
    .table-custom thead th:last-child {
        border-top-right-radius: 8px;
    }
    .table-custom tbody td {
        padding: 15px;
        border-bottom: 1px solid #f0f0f0;
        color: #333;
    }
    .table-custom tbody tr:hover {
        background-color: #f8f9ff;
    }
    .btn-delete {
        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        color: white;
        padding: 8px 20px;
        border: none;
        border-radius: 5px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s;
        font-size: 13px;
    }
    .btn-delete:hover {
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(245, 87, 108, 0.4);
    }
    .empty-state {
        text-align: center;
        padding: 40px;
        color: #999;
        font-size: 16px;
    }
    .empty-state-icon {
        font-size: 48px;
        margin-bottom: 10px;
    }
    .row-form {
        display: flex;
        gap: 20px;
        margin-bottom: 20px;
    }
    .col-form {
        flex: 1;
    }
    @media (max-width: 768px) {
        .row-form {
            flex-direction: column;
        }
    }
</style>

<div class="karma-card">
    <div class="karma-card-title">
        🎯 Karma Ürün: #getProductInfo.PRODUCT_NAME#
    </div>
    <div class="form-card">
        <cfform method="post" action="#request.self#?fuseaction=#attributes.fuseaction#" name="list_offer">
            <div class="row-form">
                <div class="col-form">
                    <label class="form-label">📦 Ürün Seçin</label>
                    <div class="input-group">
                        <input type="hidden" name="product_id" id="product_id">
                        <input name="product_name" type="text" id="product_name" class="form-control-custom" 
                               onfocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME','get_product','0','PRODUCT_ID','product_id','','3','200');" 
                               value="" autocomplete="off" placeholder="Ürün adı yazın..." required>
                        <div id="product_name_div_2" name="product_name_div_2" class="completeListbox" autocomplete="on" 
                             style="width: 290px; max-height: 150px; overflow: auto; position: absolute; left: 948.5px; top: 146.333px; z-index: 159; display: none;"></div>
                        <span class="input-group-addon btnPointer icon-ellipsis" 
                              onclick="openBoxDraggable('index.cfm?fuseaction=objects.popup_product_names&product_id=list_offer.product_id&field_name=list_offer.product_name&keyword='+encodeURIComponent(document.list_offer.product_name.value));" 
                              style="cursor: pointer; padding: 10px; background: ##667eea; color: white; border-radius: 0 6px 6px 0; margin-left: -2px;"></span>
                    </div>
                </div>
                <div class="col-form">
                    <label class="form-label">🔢 Miktar</label>
                    <input type="number" name="quantity" id="quantity" class="form-control-custom" min="1" placeholder="Miktar giriniz" required>
                </div>
            </div>
            <cfinput type="hidden" name="MAIN_PRODUCT_ID" value="#attributes.PID#">
             <cfinput type="hidden" name="PID" value="#attributes.PID#">
            <cfinput type="hidden" name="is_submit" value="Y">
            <button type="submit" class="btn-add">✨ Ürün Ekle</button>
        </cfform>
    </div>
</div>

<div class="table-card">
    <h3 style="color: ##667eea; margin-bottom: 20px; font-size: 20px; font-weight: bold;">📋 Karma Ürün İçeriği</h3>
    <cfoutput>
        <cfif getKarmaProducts.recordcount GT 0>
            <table class="table-custom">
                <thead>
                    <tr>
                        <th style="width: 50%;">📦 Ürün Adı</th>
                        <th style="width: 25%;">🔢 Miktar</th>
                        <th style="width: 25%; text-align: center;">⚙️ İşlem</th>
                    </tr>
                </thead>
                <tbody>
                    <cfloop query="getKarmaProducts">
                        <tr>
                            <td><strong>#PRODUCT_NAME#</strong></td>                        
                            <td><span style="background: ##e3f2fd; padding: 5px 15px; border-radius: 20px; font-weight: 600; color: ##1976d2;">#QUANTITY#</span></td>
                            <td style="text-align: center;">
                                <cfform method="post" action="#request.self#?fuseaction=#attributes.fuseaction#&PID=#attributes.PID#" style="display:inline;">
                                    <cfinput type="hidden" name="delete_product_id" value="#PRODUCT_ID#">
                                    <cfinput type="hidden" name="MAIN_PRODUCT_ID" value="#MAIN_PRODUCT_ID#">
                                    <cfinput type="hidden" name="is_delete" value="Y">
                                    <button type="submit" class="btn-delete" onclick="return confirm('🗑️ Bu ürünü silmek istediğinizden emin misiniz?');">🗑️ Sil</button>
                                </cfform>
                            </td>
                        </tr>
                    </cfloop>
                </tbody>
            </table>
        <cfelse>
            <div class="empty-state">
                <div class="empty-state-icon">📦</div>
                <p>Bu ürüne ait karma ürün bulunmamaktadır.</p>
                <small style="color: ##bbb;">Yukarıdaki formu kullanarak ürün ekleyebilirsiniz.</small>
            </div>
        </cfif>
    </cfoutput> 
</div>
                