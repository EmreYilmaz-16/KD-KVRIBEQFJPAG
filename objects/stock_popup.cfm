<cfquery name="getDepoBakiye" datasource="#dsn2#">
    SELECT SUM(STOCK_IN-STOCK_OUT) AS BAKIYE FROM STOCKS_ROW WHERE STOCK_ID=#attributes.STOCK_ID#
</cfquery>

<cfquery name="getRezerv" datasource="#dsn3#">
    SELECT SUM(VERILEN_SIPARIS_REZERVI),SUM(ALINAN_SIPARIS_REZERVI) FROM (
select RESERVE_STOCK_IN-STOCK_IN VERILEN_SIPARIS_REZERVI,RESERVE_STOCK_OUT-STOCK_OUT ALINAN_SIPARIS_REZERVI ,(
SELECT SPECIAL_DEFINITION_PBS FROM ORDERS WHERE ORDER_ID=GOR.ORDER_ID) OZEL_DURUM from GET_ORDER_ROW_RESERVED_ALL GOR
where STOCK_ID=#attributes.STOCK_ID# 
AND (RESERVE_STOCK_IN-STOCK_IN)>=0 AND (RESERVE_STOCK_OUT-STOCK_OUT)>=0
) AS T WHERE ISNULL(OZEL_DURUM ,0)<>1

</cfquery>
<cf_box title="Stok Depo Bilgileri" closable="1" draggable="1">
    
<table>
    <tr>
        <td>
            Depo Bakiyesi:
        </td>
        <td></td>
            <strong>#getDepoBakiye.BAKIYE#</strong>
        </td>
    </tr>
    <tr>
        <td>
            Verilen Sipariş Rezervi:
        </td>
        <td></td>
            <strong>#getRezerv.COLUMN1#</strong>
        </td>
    </tr>
    <tr>
        <td>
            Alınan Sipariş Rezervi:
        </td>
        <td></td>
            <strong>#getRezerv.COLUMN2#</strong>
        </td>
    </tr>
    <tr>
        <td>
            Kullanılabilir Bakiye:
        </td>
        <td></td>
            <strong>#getDepoBakiye.BAKIYE - getRezerv.COLUMN1 + getRezerv.COLUMN2#</strong>
        </td>
    </tr>
</table>
</cf_box>