<cffunction name="CreateProduct"  access="remote" httpMethod="Post" returntype="any" returnFormat="json">
    <cfargument name="PRODUCT_NAME">
    <cfargument name="PRODUCT_CATID">
    <cfargument name="BRAND_ID">
    <cfargument name="SHORT_CODE_ID">
    <cfargument name="SHORT_CODE">
    <cfargument name="BIRIM">
    <cfargument name="OEM_NO_ARR">
    <cfargument name="ALTERNATIVES">    
    <cfargument name="tax_purchase">
    <cfargument name="tax_sales">
<cftry>
    <cfquery name="GETPCAT" datasource="#DSN#_product">
        SELECT * FROM PRODUCT_CAT WHERE PRODUCT_CATID=#arguments.PRODUCT_CATID#
    </cfquery>
    <cfset barcode=getBarcode()>
    <cfset UrunAdi=arguments.PRODUCT_NAME>
    <cfscript>
        kategori_id=arguments.PRODUCT_CATID;   
        urun_adi=UrunAdi; 
        detail=''; 
        detail_2='';
        satis_kdv=arguments.tax_sales;
        ALIS_KDV=arguments.tax_purchase;
        is_inventory=1;
        is_production=0;
        is_sales=1;
        is_purchase=1;
        is_internet=0;
        is_extranet=0;
        birim = "#BIRIM#";
        dimention = "";
        volume = "";
        weight = "";
        surec_id=44;
        fiyat_yetkisi = 1;
        uretici_urun_kodu="";
        brand_id="";
        short_code = '';
        short_code_id = '';
        product_code_2='';
        is_limited_stock="";
        min_margin="";
        max_margin="";
        shelf_life="";
        segment_id="";
        bsmv="";
        oiv="";
        IS_ZERO_STOCK=0;
        IS_QUALITY=0;
        alis_fiyat_kdvsiz = 0
        satis_fiyat_kdvli = 0
        alis_fiyat_kdvli = 0
        sales_money = "TL"
        cesit_adi='';
        purchase_money = "TL"
    </cfscript>
    <cfset attributes.HIERARCHY =GETPCAT.HIERARCHY>
    
   
    <cfinclude template="../../Product/query/add_import_product.cfm">
    <cfset RECORDED_PRODUCT_ID=GET_PID.PRODUCT_ID>
    <cfset RECORDED_STOCK_ID=get_max_stck.max_stck>
    <cfset RECORDED_UNIT_ID=GET_MAX_UNIT.MAX_UNIT>
    
 <cfquery name="INSERT_ALTERNATIVES" datasource="#DSN3#">
    <cfloop list="#arguments.ALTERNATIVES#" item="it">
        
        INSERT INTO w3Qa_1.ALTERNATIVE_PRODUCTS(PRODUCT_ID,STOCK_ID,ALTERNATIVE_PRODUCT_ID) VALUES (#RECORDED_PRODUCT_ID#,#RECORDED_STOCK_ID#,#listGetAt(it,2,"-")#);
    </cfloop>
 </cfquery>
<cfquery name="INSER_OEM_NO" datasource="#DSN3#">
    <cfloop array="#arguments.OEM_NO_ARR#" item="it">
        
        INSERT INTO w3Qa_product.STOCKS_BARCODES(STOCK_ID,BARCODE,UNIT_ID) VALUES (#RECORDED_STOCK_ID#,'#it#',#RECORDED_UNIT_ID#);
        
    </cfloop>
</cfquery>

    <cfset ReturnData.STATUS=1>
    <cfset ReturnData.MESSAGE="Ürün Oluşturuldu">
    <cfset ReturnData.ErrorMessage="">
    <cfset ReturnData.PRODUCT_ID=RECORDED_PRODUCT_ID>
    <cfset ReturnData.STOCK_ID=RECORDED_STOCK_ID>
    <cfreturn replace(serializeJSON(ReturnData),"//","")>
    <cfcatch>
     
    <cfdump var="#cfcatch#">
    
    
<cfset ReturnData.STATUS=0>
<cfset ReturnData.MESSAGE="Ürün Oluşturulurken Bir Hata Oluştu">
<cfset ReturnData.ErrorMessage=cfcatch.message>
<cfset ReturnData.PRODUCT_ID="">
<cfset ReturnData.STOCK_ID="">
<cfreturn replace(serializeJSON(ReturnData),"//","")>
</cfcatch>
</cftry>
</cffunction>

<cffunction name="getBarcode">

    <cfif  1 eq 1>
    <cfquery name="get_barcode_no" datasource="#dsn1#">
    SELECT PRODUCT_NO AS BARCODE FROM PRODUCT_NO
    </cfquery>
    <cfset barcode_on_taki = '100000000000'>
    <cfset barcode = get_barcode_no.barcode>
    <cfset barcode_len = len(barcode)>
    <cfset barcode = left(barcode_on_taki,12-barcode_len)&barcode> 
    <cfelse>
    <cfquery name="get_barcode_no" datasource="#dsn1#">
    SELECT LEFT(BARCODE, 12) AS BARCODE FROM PRODUCT_NO
    </cfquery>
    <cfset barcode = (get_barcode_no.barcode*1)+1>
    <cfquery name="upd_barcode_no" datasource="#dsn1#">
    UPDATE PRODUCT_NO SET BARCODE = '#barcode#X'
    </cfquery>
    </cfif>
    
    <cfset barcode_tek = 0>
    <cfset barcode_cift =0>
    <cfif len(barcode) eq 12>
    <cfloop from="1" to="11" step="2" index="i">
    <cfset barcode_kontrol_1 = mid(barcode,i,1)>
    <cfset barcode_kontrol_2 = mid(barcode,i+1,1)>
    <cfset barcode_tek = (barcode_tek*1) + (barcode_kontrol_1*1)>
    <cfset barcode_cift = (barcode_cift*1) + (barcode_kontrol_2*1)>
    </cfloop>
    <cfset barcode_toplam = (barcode_cift*3)+(barcode_tek*1)>
    <cfset barcode_control_char = right(barcode_toplam,1)*1>
    <cfif barcode_control_char gt 0>
    <cfset barcode_control_char = 10-barcode_control_char>
    <cfelse>
    <cfset barcode_control_char = 0>
    </cfif>
    <cfset barcode_no = '#barcode##barcode_control_char#'>
    <cfelse>
    <cfset barcode_no = ''>
    </cfif>
    
    
    </cffunction>