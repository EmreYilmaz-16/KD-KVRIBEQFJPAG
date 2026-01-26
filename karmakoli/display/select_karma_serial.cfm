<cf_box title="Karma Seri No Seçimi" modal_id="#attributes.modal_id#" width="600" height="400">
     
    <cfdump var="#attributes#" label="Attributes">
    <cfif attributes.IS_SERIAL_NO eq 1>
        <cfquery name="getSerials" datasource="#dsn3#">
            SELECT * FROM (
SELECT STOCK_ID,SUM(CASE WHEN IN_OUT =1 THEN 1 ELSE -1 END) AS BKY,DEPARTMENT_ID,LOCATION_ID,SERIAL_NO  FROM w3Qa_1.SERVICE_GUARANTY_NEW WHERE STOCK_ID=(SELECT STOCK_ID FROM w3Qa_1.STOCKS WHERE PRODUCT_ID=#attributes.PRODUCT_ID#)
GROUP BY STOCK_ID,DEPARTMENT_ID,LOCATION_ID,SERIAL_NO
HAVING DEPARTMENT_ID=#listFirst(attributes.PACKAGING_STORE,"-")# AND LOCATION_ID=#listLast(attributes.PACKAGING_STORE,"-")# 
) AS TT WHERE TT.BKY>0
        </cfquery>
    </cfif>

<cfdump var="#getSerials#">


    <button class="btn btn-danger" onclick="closeBoxDraggable(<cfoutput>#attributes.modal_id#</cfoutput>)">Kapat</button>
</cf_box>