<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PBS Parameters Yönetimi</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2em;
            margin-bottom: 10px;
        }
        
        .content {
            padding: 30px;
        }
        
        .form-section {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 8px;
            margin-bottom: 30px;
            border-left: 4px solid #667eea;
        }
        
        .form-section h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 1.3em;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: 600;
        }
        
        input[type="text"],
        input[type="number"],
        textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 6px;
            font-size: 14px;
            transition: all 0.3s;
        }
        
        input[type="text"]:focus,
        input[type="number"]:focus,
        textarea:focus {
            border-color: #667eea;
            outline: none;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s;
            font-weight: 600;
            margin-right: 10px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        
        .btn-success {
            background: #28a745;
            color: white;
        }
        
        .btn-success:hover {
            background: #218838;
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(40, 167, 69, 0.4);
        }
        
        .btn-danger {
            background: #dc3545;
            color: white;
        }
        
        .btn-danger:hover {
            background: #c82333;
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(220, 53, 69, 0.4);
        }
        
        .table-section {
            margin-top: 30px;
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
        }
        
        thead {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        th, td {
            padding: 15px;
            text-align: left;
        }
        
        th {
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.5px;
        }
        
        tbody tr {
            border-bottom: 1px solid #e0e0e0;
            transition: background 0.2s;
        }
        
        tbody tr:hover {
            background: #f8f9fa;
        }
        
        .actions {
            display: flex;
            gap: 5px;
        }
        
        .btn-small {
            padding: 6px 12px;
            font-size: 12px;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-weight: 500;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }
        
        .alert-info {
            background: #d1ecf1;
            color: #0c5460;
            border-left: 4px solid #17a2b8;
        }
    </style>
</head>
<body>

<cfparam name="form.action" default="">
<cfparam name="form.offer_product_id" default="">
<cfparam name="form.purchase_demand_accept_process_row_id_list" default="">
<cfparam name="url.edit_id" default="">
<cfparam name="url.delete_id" default="">

<cfset message = "">
<cfset messageType = "">

<!--- İşlemler --->
<cfif len(trim(form.action))>
    <cftry>
        <cfif form.action eq "insert">
            <!--- Yeni Kayıt Ekleme --->
            <cfquery datasource="#dsn3#">
                INSERT INTO w3Qa_1.PBS_PARAMETERS 
                (OFFER_PRODUCT_ID, PURCHASE_DEMAND_ACCEPT_PROCESS_ROW_ID_LIST)
                VALUES 
                (
                    <cfif len(trim(form.offer_product_id))>
                        #val(form.offer_product_id)#
                    <cfelse>
                        NULL
                    </cfif>,
                    <cfif len(trim(form.purchase_demand_accept_process_row_id_list))>
                        '#form.purchase_demand_accept_process_row_id_list#'
                    <cfelse>
                        NULL
                    </cfif>
                )
            </cfquery>
            <cfset message = "Kayıt başarıyla eklendi!">
            <cfset messageType = "success">
            
        <cfelseif form.action eq "update">
            <!--- Kayıt Güncelleme --->
            <cfquery datasource="#dsn3#">
                UPDATE w3Qa_1.PBS_PARAMETERS
                SET 
                    OFFER_PRODUCT_ID = <cfif len(trim(form.offer_product_id))>#val(form.offer_product_id)#<cfelse>NULL</cfif>,
                    PURCHASE_DEMAND_ACCEPT_PROCESS_ROW_ID_LIST = <cfif len(trim(form.purchase_demand_accept_process_row_id_list))>'#form.purchase_demand_accept_process_row_id_list#'<cfelse>NULL</cfif>
                WHERE OFFER_PRODUCT_ID = #val(url.edit_id)#
            </cfquery>
            <cfset message = "Kayıt başarıyla güncellendi!">
            <cfset messageType = "success">
            <cfset url.edit_id = "">
        </cfif>
        
        <cfcatch type="any">
            <cfset message = "Hata: " & cfcatch.message>
            <cfset messageType = "error">
        </cfcatch>
    </cftry>
</cfif>

<!--- Silme İşlemi --->
<cfif len(trim(url.delete_id))>
    <cftry>
        <cfquery datasource="#dsn3#">
            DELETE FROM w3Qa_1.PBS_PARAMETERS
            WHERE OFFER_PRODUCT_ID = #val(url.delete_id)#
        </cfquery>
        <cfset message = "Kayıt başarıyla silindi!">
        <cfset messageType = "success">
        
        <cfcatch type="any">
            <cfset message = "Silme hatası: " & cfcatch.message>
            <cfset messageType = "error">
        </cfcatch>
    </cftry>
</cfif>

<!--- Düzenleme için kayıt getir --->
<cfif len(trim(url.edit_id))>
    <cfquery name="getEditData" datasource="#dsn3#">
        SELECT * FROM w3Qa_1.PBS_PARAMETERS
        WHERE OFFER_PRODUCT_ID = #val(url.edit_id)#
    </cfquery>
    <cfif getEditData.recordCount>
        <cfset form.offer_product_id = getEditData.OFFER_PRODUCT_ID>
        <cfset form.purchase_demand_accept_process_row_id_list = getEditData.PURCHASE_DEMAND_ACCEPT_PROCESS_ROW_ID_LIST>
    </cfif>
</cfif>

<!--- Tüm kayıtları listele --->
<cfquery name="getAllData" datasource="#dsn3#">
    SELECT * FROM w3Qa_1.PBS_PARAMETERS
    ORDER BY OFFER_PRODUCT_ID DESC
</cfquery>

<div class="container">
    <div class="header">
        <h1>📊 PBS Parameters Yönetimi</h1>
        <p>Parametre ekleme, güncelleme ve silme işlemleri</p>
    </div>
    
    <div class="content">
        <!--- Mesaj Gösterimi --->
        <cfif len(trim(message))>
            <div class="alert alert-#messageType#">
                #message#
            </div>
        </cfif>
        
        <!--- Form Bölümü --->
        <div class="form-section">
            <h2><cfif len(trim(url.edit_id))>🔄 Kayıt Güncelle<cfelse>➕ Yeni Kayıt Ekle</cfif></h2>
            
            <form method="post" action="#cgi.script_name#<cfif len(trim(url.edit_id))>?edit_id=#url.edit_id#</cfif>">
                <input type="hidden" name="action" value="<cfif len(trim(url.edit_id))>update<cfelse>insert</cfif>">
                
                <div class="form-group">
                    <label for="offer_product_id">Offer Product ID:</label>
                    <input 
                        type="number" 
                        id="offer_product_id" 
                        name="offer_product_id" 
                        value="<cfoutput>#form.offer_product_id#</cfoutput>"
                        placeholder="Örn: 12345"
                    >
                </div>
                
                <div class="form-group">
                    <label for="purchase_demand_accept_process_row_id_list">Purchase Demand Accept Process Row ID List:</label>
                    <input 
                        type="text" 
                        id="purchase_demand_accept_process_row_id_list" 
                        name="purchase_demand_accept_process_row_id_list" 
                        value="<cfoutput>#form.purchase_demand_accept_process_row_id_list#</cfoutput>"
                        placeholder="Örn: 1,2,3,4"
                        maxlength="50"
                    >
                    <small style="color: #666;">Maksimum 50 karakter</small>
                </div>
                
                <div>
                    <button type="submit" class="btn <cfif len(trim(url.edit_id))>btn-primary<cfelse>btn-success</cfif>">
                        <cfif len(trim(url.edit_id))>🔄 Güncelle<cfelse>➕ Ekle</cfif>
                    </button>
                    <cfif len(trim(url.edit_id))>
                        <a href="#cgi.script_name#" class="btn btn-danger">❌ İptal</a>
                    </cfif>
                </div>
            </form>
        </div>
        
        <!--- Liste Bölümü --->
        <div class="table-section">
            <h2 style="margin-bottom: 20px; color: #333;">📋 Kayıtlı Parametreler</h2>
            
            <cfif getAllData.recordCount gt 0>
                <table>
                    <thead>
                        <tr>
                            <th>Offer Product ID</th>
                            <th>Purchase Demand Accept Process Row ID List</th>
                            <th style="text-align: center;">İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="getAllData">
                            <tr>
                                <td>#OFFER_PRODUCT_ID#</td>
                                <td>#PURCHASE_DEMAND_ACCEPT_PROCESS_ROW_ID_LIST#</td>
                                <td style="text-align: center;">
                                    <div class="actions" style="justify-content: center;">
                                        <a href="#cgi.script_name#?edit_id=#OFFER_PRODUCT_ID#" class="btn btn-primary btn-small">
                                            ✏️ Düzenle
                                        </a>
                                        <a href="#cgi.script_name#?delete_id=#OFFER_PRODUCT_ID#" 
                                           class="btn btn-danger btn-small"
                                           onclick="return confirm('Bu kaydı silmek istediğinizden emin misiniz?');">
                                            🗑️ Sil
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </cfoutput>
                    </tbody>
                </table>
                
                <div class="alert alert-info" style="margin-top: 20px;">
                    <strong>ℹ️ Toplam Kayıt:</strong> <cfoutput>#getAllData.recordCount#</cfoutput>
                </div>
            <cfelse>
                <div class="alert alert-info">
                    <strong>ℹ️ Bilgi:</strong> Henüz kayıtlı parametre bulunmamaktadır.
                </div>
            </cfif>
        </div>
    </div>
</div>

</body>
</html>
