<cfquery name="list_karma_emir" datasource="#dsn3#">
    SELECT KARMA_EMIR.*, P.PRODUCT_NAME, E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS EMPLOYEE_FULL_NAME
    FROM KARMA_EMIR
    LEFT JOIN #DSN1#.PRODUCT AS P ON P.PRODUCT_ID = KARMA_EMIR.PRODUCT_ID
    LEFT JOIN #DSN#.EMPLOYEES AS E ON E.EMPLOYEE_ID = KARMA_EMIR.RECORD_EMP
    WHERE 1=1
    <CFIF isDefined("URL.product_id") AND len(trim(URL.product_id)) GT 0>
        AND KARMA_EMIR.PRODUCT_ID = <cfqueryparam value="#URL.product_id#" cfsqltype="cf_sql_integer">    
    </CFIF>
    <CFIF isDefined("URL.emir_no") AND len(trim(URL.emir_no)) GT 0>
        AND KARMA_EMIR.EMIR_NO LIKE <cfqueryparam value="%#URL.emir_no#%" cfsqltype="cf_sql_varchar">
    </CFIF>
    <CFIF isDefined("URL.current_status") AND len(trim(URL.current_status)) GT 0>
        AND KARMA_EMIR.CURRENT_STATUS = <cfqueryparam value="#URL.current_status#" cfsqltype="cf_sql_integer">
    </CFIF>
    <CFIF isDefined("URL.start_date") AND len(trim(URL.start_date)) GT 0>
        AND KARMA_EMIR.RECORD_DATE >= <cfqueryparam value="#URL.start_date#" cfsqltype="cf_sql_date">
    </CFIF>
    <CFIF isDefined("URL.end_date") AND len(trim(URL.end_date)) GT 0>
        AND KARMA_EMIR.RECORD_DATE <= <cfqueryparam value="#URL.end_date# 23:59:59" cfsqltype="cf_sql_timestamp">
    </CFIF>
    ORDER BY KARMA_EMIR.KARMA_EMIR_ID DESC
</cfquery>

<cfquery name="get_products" datasource="#dsn1#">
    SELECT PRODUCT_ID, PRODUCT_NAME FROM PRODUCT WHERE PRODUCT_STATUS = 1 and ISNULL(IS_PACKAGE_PRODUCT,0) =1 ORDER BY PRODUCT_NAME
</cfquery>

<cfset boxTitle = "Paketleme Emirleri - " & (isDefined("URL.product_id") AND len(trim(URL.product_id)) GT 0 ? list_karma_emir.PRODUCT_NAME : "Tümü")>
<cf_box title="#boxTitle#" scroll="1" collapsable="1" resize="1" popup_box="1">
<cfif not isDefined("attributes.ajax")>
<div class="row mb-3">
    <div class="col-12">
        <cfoutput>
        <form method="get" action="#request.self#?fuseaction=#attributes.fuseaction#" class="form-inline">
            
            <cfif isDefined("attributes.fuseaction")>
                <input type="hidden" name="fuseaction" value="#attributes.fuseaction#">
            </cfif>
            
            <div class="form-group mr-2 mb-2">
                <label for="emir_no" class="mr-2">Emir No:</label>
                <input type="text" name="emir_no" id="emir_no" class="form-control" 
                       value="<cfif isDefined('URL.emir_no')>#URL.emir_no#</cfif>" placeholder="UPE-2026-01-08-1">
            </div>
            
            <div class="form-group mr-2 mb-2">
                <label for="product_id" class="mr-2">Ürün:</label>
                <select name="product_id" id="product_id" class="form-control">
                    <option value="">Tümü</option>
                    <cfloop query="get_products">
                        <option value="#PRODUCT_ID#" <cfif isDefined("URL.product_id") AND URL.product_id EQ PRODUCT_ID>selected</cfif>>
                            #PRODUCT_NAME#
                        </option>
                    </cfloop>
                </select>
            </div>
            
            <div class="form-group mr-2 mb-2">
                <label for="current_status" class="mr-2">Durum:</label>
                <select name="current_status" id="current_status" class="form-control">
                    <option value="">Tümü</option>
                    <option value="1" <cfif isDefined("URL.current_status") AND URL.current_status EQ 1>selected</cfif>>Oluşturuldu</option>
                    <option value="2" <cfif isDefined("URL.current_status") AND URL.current_status EQ 2>selected</cfif>>İşleniyor</option>
                    <option value="3" <cfif isDefined("URL.current_status") AND URL.current_status EQ 3>selected</cfif>>Tamamlandı</option>
                </select>
            </div>
            
            <div class="form-group mr-2 mb-2">
                <label for="start_date" class="mr-2">Başlangıç:</label>
                <input type="date" name="start_date" id="start_date" class="form-control" 
                       value="<cfif isDefined('URL.start_date')>#URL.start_date#</cfif>">
            </div>
            
            <div class="form-group mr-2 mb-2">
                <label for="end_date" class="mr-2">Bitiş:</label>
                <input type="date" name="end_date" id="end_date" class="form-control" 
                       value="<cfif isDefined('URL.end_date')>#URL.end_date#</cfif>">
            </div>
            
            <div class="form-group mr-2 mb-2">
                <button type="submit" class="btn btn-primary">Filtrele</button>
          <a href="#cgi.script_name#?<cfif isDefined('attributes.fuseaction')>fuseaction=#attributes.fuseaction#</cfif>" class="btn btn-secondary ml-2">Temizle</a>
            </div>
        </form>
        </cfoutput>
    </div>
</div>


<div class="row mb-2">
    <div class="col-12">
        <strong>Toplam Emir: <cfoutput>#list_karma_emir.recordCount#</cfoutput></strong>
    </div>
</div>
</cfif>
<!----
      KARMA_EMIR_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        PRODUCT_ID INT NOT NULL,
        AMOUNT INT NOT NULL,
        RECORD_DATE DATETIME NOT NULL,
        RECORD_EMP INT NOT NULL,
        CURRENT_STATUS INT NOT NULL,
        EMIR_NO VARCHAR(50) NOT NULL---->
<cf_grid_list class="table table-bordered table-striped">
    <thead>
        <tr>
            <th>Emir No</th>
            <th>Ürün Adı</th>
            <th>Miktar</th>
            <th>Kayıt Tarihi</th>
            <th>Kayıt Eden</th>
            <th>Durum</th>
        </tr>
    </thead>
    <tbody>
        <cfoutput query="list_karma_emir">
            <tr>
                <td>
                    <cfif not isDefined("attributes.ajax")>
                        <a href="javascript:openBoxDraggable('index.cfm?fuseaction=product.emptypopup_detail_karma_emir&EMIR_ID=#KARMA_EMIR_ID#','Paketleme Emri Detayı - #EMIR_NO#',600,400);">
                            #EMIR_NO#
                        </a>
                    <cfelse>
                        #EMIR_NO#
                    </cfif>
                </td>
                <td>#PRODUCT_NAME#</td>
                <td>#NumberFormat(AMOUNT, "9,999")#</td>
                <td>#DateFormat(RECORD_DATE, "dd.mm.yyyy")# #TimeFormat(RECORD_DATE, "HH:mm")#</td>
                <td>#EMPLOYEE_FULL_NAME#</td>
                <td>
                    <cfif CURRENT_STATUS EQ 1>
                        <span class="badge badge-info">Oluşturuldu</span>
                    <cfelseif CURRENT_STATUS EQ 2>
                        <span class="badge badge-warning">İşleniyor</span>
                    <cfelseif CURRENT_STATUS EQ 3>
                        <span class="badge badge-success">Tamamlandı</span>
                    <cfelse>
                        <span class="badge badge-secondary">Bilinmeyen</span>
                    </cfif>
                </td>
            </tr>
        </cfoutput>
    </tbody>
</cf_grid_list>

</cf_box>