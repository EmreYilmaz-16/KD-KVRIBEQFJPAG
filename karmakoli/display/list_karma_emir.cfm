<cfquery name="list_karma_emir" datasource="#dsn3#">
    SELECT * FROM KARMA_EMIR
    LEFT JOIN #DSN1#.PRODUCT AS P ON P.PRODUCT_ID = KARMA_EMIR.PRODUCT_ID
    <CFIF isDefined("URL.product_id") AND len(trim(URL.product_id)) GT 0>
        WHERE KARMA_EMIR.PRODUCT_ID = <cfqueryparam value="#URL.product_id#" cfsqltype="cf_sql_integer">    
    </CFIF>
</cfquery>
<cf_box title="Paketleme Emirleri -#iIf(isDefined("URL.product_id") AND len(trim(URL.product_id)) GT 0, list_karma_emir.PRODUCT_NAME, "Tümü")#" scroll="1" collapsable="1" resize="1" popup_box="1">

<!----
      KARMA_EMIR_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        PRODUCT_ID INT NOT NULL,
        AMOUNT INT NOT NULL,
        RECORD_DATE DATETIME NOT NULL,
        RECORD_EMP INT NOT NULL,
        CURRENT_STATUS INT NOT NULL,
        EMIR_NO VARCHAR(50) NOT NULL---->
<table class="table table-bordered table-striped">
    <thead>
        <tr>
            <th>Emir No</th>
            <th>Ürün ID</th>
            <th>Miktar</th>
            <th>Kayıt Tarihi</th>
            <th>Kayıt Eden</th>
            <th>Durum</th>
        </tr>
    </thead>
    <tbody>
        <cfoutput query="list_karma_emir">
            <tr>
                <td>#EMIR_NO#</td>
                <td>#PRODUCT_ID#</td>
                <td>#AMOUNT#</td>
                <td>#DateFormat(RECORD_DATE, "dd.mm.yyyy")# #TimeFormat(RECORD_DATE, "HH:mm:ss")#</td>
                <td>#RECORD_EMP#</td>
                <td>
                    <cfif CURRENT_STATUS EQ 1>
                        Oluşturuldu
                    <cfelseif CURRENT_STATUS EQ 2>
                        İşleniyor
                    <cfelseif CURRENT_STATUS EQ 3>
                        Tamamlandı
                    <cfelse>
                        Bilinmeyen Durum
                    </cfif>
                </td>
            </tr>
        </cfoutput>
    </tbody>
</table>

</cf_box>