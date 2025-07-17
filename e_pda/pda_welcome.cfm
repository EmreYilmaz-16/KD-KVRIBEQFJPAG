<style>
td{
    border-bottom:solid 0.5px black;
    padding-top:5px;
    padding-bottom:5px;
}
h5{
    font-weight:bold;
    display:inline; 
    margin-left:15px;
    
}
    .btncls{
        display: block;
        width: 100%;
    }
    .btncls:hover{
        background-color: #E6E6E6;
    }
    .header{
        display:none;
    }
</style>
<table style="width:100%">
    <tr>
        <td colspan="2">
        <h3>E-PDA</h3>
        </td>
    </tr>
    <tr>


    <td>
    <a href="<cfoutput>#request.self#?fuseaction=pda.list_shipping_ambar</cfoutput>"class="tableyazi btncls" style="display:block;width:100% "><img src="../../images/e-pd/up30.png"> <h5>Ambardan Sevkiyata</h5></a>
    </td>
    </tr>
        <tr>
    <td>
     <a href="<cfoutput>#request.self#?fuseaction=pda.form_add_ambar_fis</cfoutput>" class="tableyazi btncls"><img src="../../images/e-pd/down30.png"><h5>Mal Kabulden Ambara</h5>&nbsp;<span style="color:green;font-weight:bold">Yapıldı !</span></a>
    </td>
    </tr>
        <tr>
    <td>
     <a href="<cfoutput>#request.self#?fuseaction=pda.form_add_ambar_fis_2</cfoutput>" class="tableyazi btncls"><img src="../../images/e-pd/exit30.png"><h5>Ambardan Mal Kabule</h5> &nbsp;<span style="color:green;font-weight:bold">Yapıldı !</span></a>
    </td>
    </tr>
        <tr>
    <td>
    <a  class="tableyazi btncls" href="<cfoutput>#request.self#?fuseaction=pda.list_shipping</cfoutput>"><img style="width:30px;height:30px" src="../../images/e-pd/tickmav30.png"> <h5>Sevkiyat Kontrol</h5></a>
    </td>
    </tr>
        <tr>

    <td>    

     <a class="tableyazi btncls" href="<cfoutput>#request.self#?fuseaction=pda.list_pda_print_spool</cfoutput>"><img src="../../images/e-pd/barcode30.png"><h5>Etiket Havuzu</h5></a>
    </td>
    </tr>
        <tr>

    <td>  

     <a class="tableyazi btncls" href="<cfoutput>#request.self#?fuseaction=pda.form_add_ambar_fis_3</cfoutput>">  <img src="../../images/e-pd/shelf30.png"><h5>Raf Değiştir</h5>  &nbsp;<span style="color:green;font-weight:bold">Yapıldı !</span></a>
    </td>
    </tr>
        <tr>

    <td>    

    <a class="tableyazi btncls" href="<cfoutput>#request.self#?fuseaction=pda.form_add_ambar_fis_1</cfoutput>"><img src="../../images/e-pd/ticket30.png"><h5>Ambar Fişi</h5></a>
    </td>
    </tr>
        <tr>

    <td>
     <a class="tableyazi btncls" href="<cfoutput>#request.self#?fuseaction=pda.form_shelf_query</cfoutput>"><img src="../../images/e-pd/pro30.png"><h5>Ürün Raf Tanımla</h5></a>
    </td>
    </tr>
        <tr>

    <td>    

     <a class="tableyazi btncls" href="<cfoutput>#request.self#?fuseaction=pda.form_add_stock_count_loc</cfoutput>"><img src="../../images/e-pd/say30.png"><h5>Depo Sayım Belgesi</h5></a>
    </td>
    </tr>
        <tr>


    <td>
     <a class="tableyazi btncls" href="<cfoutput>#request.self#?fuseaction=pda.form_add_stock_count</cfoutput>"><img src="../../images/e-pd/say30.png"><h5>Raf Sayım Belgesi</h5></a>
    </td>
    </tr>
            <tr>


    <td>
     <a class="tableyazi btncls" href="<cfoutput>#request.self#?fuseaction=pda.stock_location_partner</cfoutput>"><img style="width:30" width="30" src="../../images/e-pd/box48.png"><h5>Lokasyona Göre Stok</h5></a>
    </td>
    </tr>
                <tr>


    <td>
     <a class="tableyazi btncls" href="<cfoutput>#request.self#?fuseaction=pda.form_add_stock_update</cfoutput>"><img style="width:30" width="30" src="../../images/e-pd/trolle64.png"><h5>Raf Düzeltme Belgesi</h5></a>
    </td>
    </tr>
   <!---                 <tr>


    <td>
     <a class="tableyazi btncls" href="<cfoutput>#request.self#?fuseaction=pda.add_ezgi_live_sale</cfoutput>"><img  src="../../images/e-pd/sale30.png"><h5>Sıcak Satış</h5></a>
    </td>
    </tr>--->
</table>