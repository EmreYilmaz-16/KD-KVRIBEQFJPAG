<cfset dsn3="w3Qa_1">
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PBS Parameters Yönetimi</title>
    <style>
        :root {
            --primary: #667eea;
            --primary-dark: #5a67d8;
            --primary-deep: #764ba2;
            --primary-light: #eef2ff;
            --accent: #38b2ac;
            --surface: rgba(255, 255, 255, 0.92);
            --surface-muted: rgba(255, 255, 255, 0.72);
            --text-dark: #1f2937;
            --text-muted: #6b7280;
            --success: #28a745;
            --danger: #dc3545;
            --warning: #f59e0b;
            --border: rgba(103, 126, 234, 0.18);
            --shadow: 0 18px 45px rgba(102, 126, 234, 0.25);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: radial-gradient(circle at 15% 25%, rgba(76, 106, 255, 0.35), transparent 60%),
                        radial-gradient(circle at 85% 20%, rgba(124, 58, 237, 0.35), transparent 55%),
                        linear-gradient(135deg, #5a67d8 0%, #764ba2 55%, #512b81 100%);
            min-height: 100vh;
            padding: 30px;
            color: var(--text-dark);
            position: relative;
            overflow-x: hidden;
        }

        body::before {
            content: "";
            position: fixed;
            inset: 0;
            background-image: linear-gradient(90deg, rgba(255,255,255,0.1) 1px, transparent 1px),
                              linear-gradient(180deg, rgba(255,255,255,0.08) 1px, transparent 1px);
            background-size: 80px 80px;
            opacity: 0.4;
            pointer-events: none;
            z-index: -1;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: var(--surface);
            border-radius: 18px;
            box-shadow: var(--shadow);
            backdrop-filter: blur(18px);
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.45);
        }

        .header {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.95) 0%, rgba(118, 75, 162, 0.95) 100%);
            color: white;
            padding: 48px 40px 44px;
            text-align: center;
            position: relative;
        }

        .header::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(120deg, rgba(255, 255, 255, 0.18), transparent 55%);
            opacity: 0.6;
            pointer-events: none;
        }

        .header h1 {
            font-size: 2.3rem;
            margin-bottom: 12px;
            letter-spacing: 0.4px;
        }

        .header p {
            font-size: 1rem;
            opacity: 0.92;
        }

        .content {
            padding: 40px;
        }

        .message-stack {
            display: flex;
            flex-direction: column;
            gap: 14px;
            margin-bottom: 28px;
        }

        .alert {
            padding: 16px 20px;
            border-radius: 12px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 12px;
            box-shadow: 0 12px 28px rgba(15, 23, 42, 0.08);
        }

        .alert-success {
            background: rgba(212, 237, 218, 0.95);
            color: #155724;
            border: 1px solid rgba(40, 167, 69, 0.25);
        }

        .alert-error {
            background: rgba(248, 215, 218, 0.95);
            color: #721c24;
            border: 1px solid rgba(220, 53, 69, 0.25);
        }

        .alert-info {
            background: rgba(209, 236, 241, 0.95);
            color: #0c5460;
            border: 1px solid rgba(23, 162, 184, 0.25);
        }

        .stat-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
            gap: 18px;
            margin-bottom: 32px;
        }

        .stat-card {
            background: var(--surface-muted);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 22px 24px;
            box-shadow: 0 14px 32px rgba(102, 126, 234, 0.18);
            position: relative;
            overflow: hidden;
        }

        .stat-card::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.18), transparent 60%);
            pointer-events: none;
        }

        .stat-label {
            font-size: 0.85rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 1.5px;
            margin-bottom: 6px;
            display: block;
        }

        .stat-value {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--primary-dark);
        }

        .stat-helper {
            font-size: 0.85rem;
            color: var(--text-muted);
            margin-top: 6px;
        }

        .stat-card.is-warning {
            background: rgba(255, 247, 226, 0.92);
            border-color: rgba(245, 158, 11, 0.28);
        }

        .stat-card.is-warning .stat-value {
            color: var(--warning);
        }

        .layout {
            display: grid;
            grid-template-columns: minmax(0, 1.2fr) minmax(0, 0.8fr);
            gap: 28px;
            margin-bottom: 36px;
        }

        .form-section {
            background: var(--surface-muted);
            padding: 28px 30px;
            border-radius: 16px;
            border: 1px solid var(--border);
            position: relative;
            overflow: hidden;
            box-shadow: 0 12px 32px rgba(102, 126, 234, 0.12);
        }

        .form-section::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(140deg, rgba(102, 126, 234, 0.12), transparent 65%);
            pointer-events: none;
        }

        .form-section h2 {
            color: var(--primary-dark);
            margin-bottom: 22px;
            font-size: 1.35rem;
            position: relative;
            font-weight: 700;
        }

        .form-grid {
            display: grid;
            gap: 20px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        label {
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--text-dark);
        }

        .input-with-icon {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--primary-dark);
            font-size: 1rem;
            pointer-events: none;
            opacity: 0.7;
        }

        input[type="text"],
        input[type="number"],
        textarea {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid rgba(107, 114, 128, 0.2);
            border-radius: 10px;
            font-size: 0.95rem;
            transition: all 0.25s ease;
            background: rgba(255, 255, 255, 0.92);
            color: var(--text-dark);
        }

        .input-with-icon input {
            padding-left: 42px;
        }

        input[type="text"]:focus,
        input[type="number"]:focus,
        textarea:focus {
            border-color: rgba(102, 126, 234, 0.8);
            outline: none;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.15);
            background: white;
        }

        .field-hint {
            color: var(--text-muted);
            font-size: 0.8rem;
        }

        .action-row {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 22px;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 11px 26px;
            border-radius: 10px;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            border: none;
            transition: transform 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
            text-decoration: none;
        }

        .btn:hover {
            transform: translateY(-2px);
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-deep) 100%);
            color: white;
            box-shadow: 0 12px 24px rgba(102, 126, 234, 0.35);
        }

        .btn-success {
            background: linear-gradient(135deg, #34d399 0%, #059669 100%);
            color: white;
            box-shadow: 0 12px 24px rgba(16, 185, 129, 0.35);
        }

        .btn-danger {
            background: linear-gradient(135deg, #f87171 0%, #dc2626 100%);
            color: white;
            box-shadow: 0 12px 24px rgba(239, 68, 68, 0.35);
        }

        .btn-outline {
            background: rgba(255, 255, 255, 0.95);
            color: var(--primary-dark);
            border: 1px solid rgba(102, 126, 234, 0.35);
            box-shadow: none;
        }

        .btn-small {
            padding: 8px 16px;
            font-size: 0.85rem;
            border-radius: 8px;
        }

        .btn-icon {
            font-size: 1.1rem;
        }

        .helper-panel {
            background: var(--surface-muted);
            border-radius: 16px;
            border: 1px solid var(--border);
            padding: 28px 26px;
            box-shadow: 0 12px 32px rgba(15, 23, 42, 0.15);
            position: relative;
        }

        .helper-panel::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, rgba(56, 178, 172, 0.15), transparent 60%);
            pointer-events: none;
        }

        .helper-panel h3 {
            font-size: 1.1rem;
            margin-bottom: 16px;
            color: var(--primary-dark);
        }

        .helper-panel p {
            color: var(--text-muted);
            line-height: 1.6;
            margin-bottom: 12px;
        }

        .helper-list {
            list-style: none;
            display: grid;
            gap: 10px;
            margin-bottom: 18px;
        }

        .helper-list li {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 12px;
            border-radius: 10px;
            background: rgba(255, 255, 255, 0.85);
            border: 1px solid rgba(102, 126, 234, 0.18);
            color: var(--text-dark);
        }

        .helper-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 6px 12px;
            border-radius: 999px;
            font-size: 0.78rem;
            font-weight: 600;
            letter-spacing: 0.5px;
            background: rgba(102, 126, 234, 0.15);
            color: var(--primary-dark);
            border: 1px solid rgba(102, 126, 234, 0.35);
        }

        .badge.is-warning {
            background: rgba(245, 158, 11, 0.16);
            color: var(--warning);
            border-color: rgba(245, 158, 11, 0.35);
        }

        .badge.is-muted {
            background: rgba(107, 114, 128, 0.12);
            color: #4b5563;
            border-color: rgba(107, 114, 128, 0.28);
        }

        .badge.is-empty {
            background: rgba(226, 232, 240, 0.8);
            color: #475569;
            border-color: rgba(148, 163, 184, 0.35);
        }

        .info-banner {
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid rgba(245, 158, 11, 0.3);
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 18px;
            box-shadow: 0 12px 28px rgba(245, 158, 11, 0.15);
        }

        .info-banner p {
            margin-top: 10px;
            color: var(--text-dark);
        }

        .table-section {
            margin-top: 16px;
        }

        .table-section h2 {
            margin-bottom: 18px;
            color: var(--text-dark);
            font-size: 1.2rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .table-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 16px;
            border: 1px solid rgba(148, 163, 184, 0.2);
            box-shadow: 0 18px 45px rgba(15, 23, 42, 0.12);
            overflow: hidden;
        }

        table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
        }

        thead {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.95) 0%, rgba(118, 75, 162, 0.95) 100%);
            color: white;
        }

        th, td {
            padding: 16px 20px;
            text-align: left;
        }

        th {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 1.4px;
        }

        tbody tr {
            background: rgba(255, 255, 255, 0.96);
            transition: background 0.2s ease, transform 0.2s ease;
        }

        tbody tr:nth-child(even) {
            background: rgba(248, 250, 255, 0.85);
        }

        tbody tr:hover {
            background: rgba(235, 244, 255, 0.95);
            transform: translateY(-2px);
        }

        tbody td {
            border-bottom: 1px solid rgba(226, 232, 240, 0.9);
            vertical-align: middle;
        }

        tbody tr:last-child td {
            border-bottom: none;
        }

        .badge-group {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
        }

        .actions {
            display: flex;
            gap: 8px;
            justify-content: center;
        }

        .action-row .btn-danger,
        .actions .btn-danger {
            box-shadow: 0 12px 24px rgba(239, 68, 68, 0.2);
        }

        .empty-state {
            background: rgba(255, 255, 255, 0.9);
            border-radius: 16px;
            border: 1px dashed rgba(102, 126, 234, 0.35);
            padding: 24px;
            text-align: center;
            color: var(--text-muted);
            box-shadow: 0 16px 35px rgba(102, 126, 234, 0.12);
        }

        a.btn {
            text-decoration: none;
        }

        .empty-state h3 {
            font-size: 1.2rem;
            margin-bottom: 8px;
            color: var(--text-dark);
        }

        .empty-state p {
            font-size: 0.95rem;
            color: var(--text-muted);
        }

        .table-summary {
            margin-top: 22px;
        }

        @media (max-width: 1024px) {
            body {
                padding: 24px;
            }

            .layout {
                grid-template-columns: 1fr;
            }

            .helper-panel {
                order: -1;
            }
        }

        @media (max-width: 720px) {
            body {
                padding: 16px;
            }

            .container {
                border-radius: 14px;
            }

            .content {
                padding: 28px 22px;
            }

            .action-row {
                flex-direction: column;
                align-items: stretch;
            }

            .action-row .btn,
            .actions .btn {
                width: 100%;
                justify-content: center;
            }

            table thead {
                display: none;
            }

            table,
            tbody,
            tr,
            td {
                display: block;
                width: 100%;
            }

            tbody tr {
                margin-bottom: 18px;
                border-radius: 12px;
                overflow: hidden;
                background: rgba(255, 255, 255, 0.92);
            }

            td {
                padding: 12px 18px;
                border-bottom: 1px solid rgba(226, 232, 240, 0.85);
                position: relative;
                padding-left: 130px;
            }

            td::before {
                content: attr(data-label);
                position: absolute;
                left: 18px;
                top: 50%;
                transform: translateY(-50%);
                font-weight: 600;
                color: var(--text-muted);
                text-transform: uppercase;
                letter-spacing: 1.2px;
                font-size: 0.68rem;
            }

            td:last-child {
                border-bottom: none;
                padding-top: 16px;
            }
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

<cfset totalRecords = getAllData.recordCount>
<cfset renderTimestamp = DateFormat(Now(), "dd.MM.yyyy") & " " & TimeFormat(Now(), "HH:mm")>
<cfset isEditing = len(trim(url.edit_id))>
<cfset editDisplayValue = "">
<cfif isEditing>
    <cfif len(trim(form.offer_product_id))>
        <cfset editDisplayValue = form.offer_product_id>
    <cfelse>
        <cfset editDisplayValue = url.edit_id>
    </cfif>
</cfif>

<div class="container">
    <div class="header">
        <h1>📊 PBS Parameters Yönetimi</h1>
        <p>Parametre ekleme, güncelleme ve silme işlemleri</p>
    </div>
    
    <div class="content">
        <cfif len(trim(message))>
            <div class="message-stack">
                <div class="alert alert-#messageType#">
                    #message#
                </div>
            </div>
        </cfif>

        <cfoutput>
            <div class="stat-cards">
                <div class="stat-card">
                    <span class="stat-label">Toplam Kayıt</span>
                    <span class="stat-value">#totalRecords#</span>
                    <span class="stat-helper">Liste anlık olarak günceldir.</span>
                </div>
                <div class="stat-card">
                    <span class="stat-label">Sayfa Yenileme</span>
                    <span class="stat-value">#renderTimestamp#</span>
                    <span class="stat-helper">Sunucu saatine göre</span>
                </div>
                <cfif isEditing>
                    <div class="stat-card is-warning">
                        <span class="stat-label">Düzenleme Modu</span>
                        <span class="stat-value">#editDisplayValue#</span>
                        <span class="stat-helper">Seçili kayıt güncellenecek.</span>
                    </div>
                </cfif>
            </div>
        </cfoutput>

        <div class="layout">
            <div class="form-section">
                <h2><cfif isEditing>🔄 Kayıt Güncelle<cfelse>➕ Yeni Kayıt Ekle</cfif></h2>

                <form method="post" action="#cgi.script_name#<cfif isEditing>?edit_id=#url.edit_id#</cfif>">
                    <input type="hidden" name="action" value="<cfif isEditing>update<cfelse>insert</cfif>">

                    <div class="form-grid">
                        <div class="form-group">
                            <label for="offer_product_id">Offer Product ID</label>
                            <div class="input-with-icon">
                                <span class="input-icon">&#35;</span>
                                <input 
                                    type="number" 
                                    id="offer_product_id" 
                                    name="offer_product_id" 
                                    value="<cfoutput>#form.offer_product_id#</cfoutput>"
                                    placeholder="Örn: 12345"
                                >
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="purchase_demand_accept_process_row_id_list">Purchase Demand Accept Process Row ID List</label>
                            <div class="input-with-icon">
                                <span class="input-icon">📝</span>
                                <input 
                                    type="text" 
                                    id="purchase_demand_accept_process_row_id_list" 
                                    name="purchase_demand_accept_process_row_id_list" 
                                    value="<cfoutput>#form.purchase_demand_accept_process_row_id_list#</cfoutput>"
                                    placeholder="Örn: 1,2,3,4"
                                    maxlength="50"
                                >
                            </div>
                            <span class="field-hint">Maksimum 50 karakter, değerleri virgülle ayırın.</span>
                        </div>
                    </div>

                    <div class="action-row">
                        <button type="submit" class="btn <cfif isEditing>btn-primary<cfelse>btn-success</cfif>">
                            <span class="btn-icon"><cfif isEditing>🔄<cfelse>➕</cfif></span>
                            <cfif isEditing>Güncelle<cfelse>Ekle</cfif>
                        </button>
                        <cfif isEditing>
                            <a href="#cgi.script_name#" class="btn btn-outline">
                                <span class="btn-icon">❌</span>
                                İptal
                            </a>
                        </cfif>
                    </div>
                </form>
            </div>

            <aside class="helper-panel">
                <cfif isEditing>
                    <div class="info-banner">
                        <span class="badge is-warning">Düzenleme Aktif</span>
                        <p>Seçili kayıt: <strong><cfoutput>#editDisplayValue#</cfoutput></strong></p>
                    </div>
                </cfif>
                <h3>Nasıl Kullanılır?</h3>
                <ul class="helper-list">
                    <li>✅ Offer Product ID benzersiz ve sayısal olmalıdır.</li>
                    <li>✅ Satır ID listesini virgülle ayırarak girin (örn: 1,2,3).</li>
                    <li>✅ Boş bıraktığınız alanlar veri tabanında NULL olarak kaydedilir.</li>
                    <li>✅ Silme işlemi geri alınamaz, dikkatli olun.</li>
                </ul>
                <p>Değişiklikler kaydedildiğinde aşağıdaki tablo otomatik olarak güncellenir.</p>
                <div class="helper-meta">
                    <span class="badge is-muted">DSN: <cfoutput>#dsn3#</cfoutput></span>
                    <span class="badge is-muted">Tablo: PBS_PARAMETERS</span>
                </div>
            </aside>
        </div>

        <div class="table-section">
            <h2>📋 Kayıtlı Parametreler</h2>
            
            <cfif totalRecords gt 0>
                <div class="table-card">
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
                                    <td data-label="Offer Product ID">#OFFER_PRODUCT_ID#</td>
                                    <td data-label="Purchase Demand Accept Process Row ID List">
                                        <cfif len(trim(PURCHASE_DEMAND_ACCEPT_PROCESS_ROW_ID_LIST))>
                                            <div class="badge-group">
                                                <cfloop list="#PURCHASE_DEMAND_ACCEPT_PROCESS_ROW_ID_LIST#" index="rowId">
                                                    <span class="badge">#trim(rowId)#</span>
                                                </cfloop>
                                            </div>
                                        <cfelse>
                                            <span class="badge is-empty">Belirtilmemiş</span>
                                        </cfif>
                                    </td>
                                    <td data-label="İşlemler" style="text-align: center;">
                                        <div class="actions">
                                            <a href="#cgi.script_name#?edit_id=#OFFER_PRODUCT_ID#" class="btn btn-primary btn-small" title="Düzenle">
                                                ✏️ Düzenle
                                            </a>
                                            <a href="#cgi.script_name#?delete_id=#OFFER_PRODUCT_ID#"
                                               class="btn btn-danger btn-small"
                                               onclick="return confirm('Bu kaydı silmek istediğinizden emin misiniz?');"
                                               title="Sil">
                                                🗑️ Sil
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>

                <div class="alert alert-info table-summary">
                    <strong>ℹ️ Toplam Kayıt:</strong> <cfoutput>#totalRecords#</cfoutput>
                </div>
            <cfelse>
                <div class="empty-state">
                    <h3>Henüz kayıt eklenmedi</h3>
                    <p>Sağ taraftaki formu kullanarak ilk parametre kaydınızı oluşturabilirsiniz.</p>
                </div>
            </cfif>
        </div>
    </div>
</div>

</body>
</html>
