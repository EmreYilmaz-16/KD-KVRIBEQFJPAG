<!--- =============================
     Export: Product Barcodes (Dynamic Pivot to Excel)
     File: export_product_barcodes.cfm
     Author: Emre için örnek
     ============================= --->

<!--- DSN ve isteğe bağlı sıralama parametreleri --->


<form method="POST" action="/AddOns/Partner/reports/query/oem_raporu_excell.cfm" name="search_product" id="search_product">
    <input type="hidden" name="is_submit" value="1">
    
    <cfquery name="getBrands" datasource="w3qa">
        SELECT BRAND_NAME,BRAND_ID FROM w3Qa_product.PRODUCT_BRANDS
    </cfquery>
    <table>
        <tr>
            <td>
                <div class="form-group">
                    <label for="brand">Marka Seçin:</label>
                    <select name="brand" id="brand" class="form-control">
                        <cfoutput query="getBrands">
                            <option value="#BRAND_ID#">#BRAND_NAME#</option>
                        </cfoutput>
                    </select>
                </div>
            </td>
            <td>
                <div class="form-group" id="item-cat_id">
                        <label>Kategori </label>
                        <div class="input-group">
                            <input type="hidden" name="cat_id" id="cat_id" value="">
                            <input type="hidden" name="cat" id="cat" value="">
                            <input name="category_name" type="text" id="category_name" onfocus="AutoComplete_Create('category_name','PRODUCT_CATID,PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','','PRODUCT_CATID,HIERARCHY','cat_id,cat','','3','200','','1');" value="" autocomplete="off"><div id="category_name_div_2" name="category_name_div_2" class="completeListbox" autocomplete="on" style="width: 599px; max-height: 150px; overflow: auto; position: absolute; left: 15px; top: 145px; z-index: 159; display: none;"></div>
                            <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('index.cfm?fuseaction=objects.popup_product_cat_names&is_sub_category=1&field_id=search_product.cat_id&field_code=search_product.cat&field_name=search_product.category_name');"></span>
                        </div>
                    </div>
            </td>
            <td>
                <input type="submit" class="btn btn-primary" value="Excel Olarak İndir">
            </td>
        </tr>
    </table>
</form>
<cfif isDefined("attributes.is_submit")>
<cfdump var="#attributes#">
</cfif>
<cfabort>


<cfset dsn = "w3qa"> <!--- kendi DSN'inizi girin --->
<!--- rn sıralaması için: created_at / barcode_id / barcode --->
<cfparam name="url.orderBy" default="barcode"> 
<!--- güvenli whitelist --->
<cfset allowedOrder = "created_at,barcode_id,barcode">
<cfif NOT listFindNoCase(allowedOrder, url.orderBy)>
    <cfset url.orderBy = "barcode">
</cfif>

<!--- İndirme başlıkları (Excel) --->
<cfset fileName = "product_barcodes_#dateFormat(now(),'yyyymmdd')#_#timeFormat(now(),'HHmmss')#.xls">
<cfheader name="Content-Disposition" value="attachment; filename=#fileName#">
<cfcontent type="application/vnd.ms-excel; charset=utf-8">

<!--- Dinamik pivot sorgusu:
      Not: Temp table (#B) aynı bağlantı ve batch içinde kaldığı sürece güvenlidir. --->
<cfquery name="qPivot" datasource="#dsn#">
SET NOCOUNT ON;

DECLARE @orderByCol sysname;
-- URL'den gelen orderBy'a göre kolon seçimi
SET @orderByCol = CASE LOWER(<cfqueryparam value="#url.orderBy#" cfsqltype="cf_sql_varchar">)
                    WHEN 'created_at' THEN 'SB.STOCK_BARCODE_ID'
                    WHEN 'barcode_id' THEN 'SB.STOCK_BARCODE_ID'
                    ELSE 'SB.BARCODE'
                  END;

-- 1) CTE ile RN ver, temp tabloya al
;WITH B AS (
    SELECT
        P.PRODUCT_ID,
        P.PRODUCT_CODE_2,
        P.PRODUCT_CODE,
        P.PRODUCT_NAME,
        SB.BARCODE,
        ROW_NUMBER() OVER (
            PARTITION BY P.PRODUCT_ID
            ORDER BY
                CASE WHEN @orderByCol = 'SB.STOCK_BARCODE_ID' THEN
                    SB.STOCK_BARCODE_ID
                END,
                CASE WHEN @orderByCol = 'SB.STOCK_BARCODE_ID' THEN
                    SB.STOCK_BARCODE_ID
                END,
                CASE WHEN @orderByCol = 'SB.BARCODE' THEN
                    SB.BARCODE
                END
        ) AS rn
    FROM w3Qa_product.STOCKS_BARCODES SB
    INNER JOIN w3Qa_product.STOCKS  AS S ON S.STOCK_ID   = SB.STOCK_ID
    INNER JOIN w3Qa_product.PRODUCT AS P ON P.PRODUCT_ID = S.PRODUCT_ID
)
SELECT *
INTO w3qa.##B
FROM B;

-- 2) Dinamik kolon listesini oluştur
DECLARE @cols nvarchar(max);
SELECT @cols =
    STRING_AGG(QUOTENAME(N'BARCODE' + CAST(rn AS nvarchar(10))), N',')
FROM (SELECT DISTINCT rn FROM w3qa.##B) d;



-- 3) Dinamik pivotu çalıştır
DECLARE @sql nvarchar(max) =
N'SELECT
      PRODUCT_CODE_2,
      PRODUCT_CODE,
      PRODUCT_NAME, ' + @cols + N'
  FROM (
      SELECT
          PRODUCT_CODE_2,
          PRODUCT_CODE,
          PRODUCT_NAME,
          ''BARCODE'' + CAST(rn AS nvarchar(10)) AS colname,
          BARCODE
      FROM w3qa.##B
  ) src
  PIVOT (
      MAX(BARCODE) FOR colname IN (' + @cols + N')
  ) p
  ORDER BY PRODUCT_CODE_2, PRODUCT_CODE;';

EXEC sys.sp_executesql @sql;

DROP TABLE w3qa.##B;
</cfquery>

<!--- HTML tabloyu yaz (Excel açar) --->
<style>
    table { border-collapse: collapse; font-family: Arial, sans-serif; font-size: 12px; }
    th, td { border: 1px solid #999; padding: 4px 6px; }
    th { background: #eee; }
</style>

<table>
    <thead>
        <tr>
            <cfloop list="#qPivot.columnList#" index="col">
                <th><cfoutput>#encodeForHtml(col)#</cfoutput></th>
            </cfloop>
        </tr>
    </thead>
    <tbody>
        <cfoutput query="qPivot">
            <tr>
                <cfloop list="#qPivot.columnList#" index="col">
                    <td>#encodeForHtml(qPivot[col][currentRow])#</td>
                </cfloop>
            </tr>
        </cfoutput>
    </tbody>
</table>
