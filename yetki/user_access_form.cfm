<cfparam name="brand_code" default="">    
<cfparam name="attributes.marks" default="">    
<cfquery name="get_mark_names" datasource="#dsn1#"><!--- Markalar --->
	SELECT
		PB.BRAND_ID,
        PB.BRAND_NAME
	FROM
		PRODUCT_BRANDS PB
		,PRODUCT_BRANDS_OUR_COMPANY PBO
	WHERE
		PB.BRAND_ID = PBO.BRAND_ID
		AND PBO.OUR_COMPANY_ID =  #session.ep.company_id# 
	ORDER BY BRAND_NAME
</cfquery>

<cfquery name="get_companies" datasource="#dsn#"><!--- Firmalar --->
	SELECT
		COMPANY_ID PAR_ID,
		NICKNAME PAR_NAME
	FROM
		COMPANY
	
		
		
	ORDER BY NICKNAME
</cfquery>

<title>Kullanıcı Erişim Yönetimi</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=Manrope:wght@400;500;600;700&display=swap');

        :root {
            --primary: #0ea5e9;
            --primary-strong: #0284c7;
            --accent: #f59e0b;
            --accent-strong: #d97706;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --info: #0ea5e9;
            --surface: #f7f8fb;
            --card: #ffffff;
            --ink: #0f172a;
            --muted: #64748b;
            --muted-strong: #475569;
            --border: #e2e8f0;
            --border-strong: #cbd5e1;
            --shadow-soft: 0 10px 40px rgba(15, 23, 42, 0.12);
            --shadow-hard: 0 20px 60px rgba(15, 23, 42, 0.16);
            --radius-sm: 10px;
            --radius: 14px;
            --radius-lg: 18px;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Space Grotesk', 'Manrope', 'Segoe UI', system-ui;
            background: radial-gradient(1200px at 15% 20%, rgba(14, 165, 233, 0.18), transparent),
                        radial-gradient(900px at 85% 10%, rgba(245, 158, 11, 0.18), transparent),
                        #eef2f7;
            color: var(--ink);
            min-height: 100vh;
            padding: 32px;
        }

        .container {
            max-width: 1320px;
            margin: 0 auto;
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        /* Header */
        .page-header {
            position: relative;
            overflow: hidden;
            text-align: left;
            padding: 32px;
            background: linear-gradient(135deg, #ffffffcc, #f8fafc);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
            box-shadow: var(--shadow-soft);
        }

        .page-header::before,
        .page-header::after {
            content: '';
            position: absolute;
            inset: 0;
            background: radial-gradient(500px at 15% 10%, rgba(14, 165, 233, 0.12), transparent),
                        radial-gradient(600px at 85% 0%, rgba(245, 158, 11, 0.12), transparent);
            z-index: 0;
        }

        .page-header > * { position: relative; z-index: 1; }

        .page-header h1 {
            font-size: 2.4rem;
            font-weight: 700;
            letter-spacing: -0.02em;
            background: linear-gradient(120deg, var(--primary-strong), var(--accent-strong));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 10px;
        }

        .page-header p {
            color: var(--muted);
            font-size: 1.05rem;
            max-width: 720px;
            line-height: 1.6;
        }

        /* Cards */
        .card {
            position: relative;
            background: var(--card);
            border-radius: var(--radius);
            box-shadow: var(--shadow-soft);
            padding: 22px;
            border: 1px solid var(--border);
            transition: transform 0.25s ease, box-shadow 0.25s ease, border-color 0.25s ease;
        }

        .card::after {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, rgba(14, 165, 233, 0.06), rgba(245, 158, 11, 0.06));
            opacity: 0;
            transition: opacity 0.3s ease;
            border-radius: var(--radius);
            pointer-events: none;
        }

        .card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-hard);
            border-color: var(--border-strong);
        }

        .card:hover::after { opacity: 1; }

        .card h2 {
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--ink);
            margin-bottom: 18px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: 10px;
            letter-spacing: -0.01em;
        }

        .card h2 .icon { font-size: 1.4rem; }

        /* Form Groups */
        .form-group { margin-bottom: 16px; }

        .form-group label {
            display: block;
            margin-bottom: 6px;
            color: var(--muted-strong);
            font-weight: 600;
            font-size: 0.9rem;
            letter-spacing: -0.01em;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            font-size: 0.95rem;
            transition: all 0.2s ease;
            background: #fff;
            color: var(--ink);
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            border-color: var(--primary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(14, 165, 233, 0.18);
        }

        .form-group input::placeholder { color: var(--muted); }

        .form-group input[readonly] {
            background: #f1f5f9;
            cursor: not-allowed;
        }

        /* Input Groups */
        .input-group { display: flex; align-items: stretch; }

        .input-group input { border-radius: var(--radius-sm) 0 0 var(--radius-sm); flex: 1; }

        .input-group .input-group-text {
            padding: 12px 14px;
            background: linear-gradient(120deg, var(--primary), var(--primary-strong));
            color: white;
            border: 1px solid var(--primary-strong);
            border-radius: 0 var(--radius-sm) var(--radius-sm) 0;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: transform 0.2s ease, filter 0.2s ease;
        }

        .input-group .input-group-text:hover { transform: translateY(-1px); filter: brightness(1.05); }

        /* Buttons */
        .btn {
            padding: 11px 20px;
            border: none;
            border-radius: var(--radius-sm);
            cursor: pointer;
            font-size: 0.95rem;
            font-weight: 700;
            margin-right: 10px;
            margin-bottom: 10px;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            letter-spacing: -0.01em;
            box-shadow: var(--shadow-soft);
        }

        .btn-primary {
            background: linear-gradient(120deg, var(--primary), var(--primary-strong));
            color: #fff;
        }

        .btn-success {
            background: linear-gradient(120deg, var(--success), #0f9d58);
            color: #fff;
        }

        .btn-danger {
            background: linear-gradient(120deg, var(--danger), #dc2626);
            color: #fff;
        }

        .btn-warning {
            background: linear-gradient(120deg, var(--accent), var(--accent-strong));
            color: #fff;
        }

        .btn:hover { transform: translateY(-2px); box-shadow: var(--shadow-hard); }
        .btn:active { transform: translateY(0); }

        .btn-sm { padding: 8px 14px; font-size: 0.85rem; margin-right: 6px; }
        .btn-icon { padding: 8px 10px; font-size: 0.9rem; }

        /* Multi Select */
        select[multiple] {
            min-height: 150px;
            padding: 10px;
            border-radius: var(--radius-sm);
            border: 1px solid var(--border);
        }

        select[multiple] option { padding: 8px 10px; border-radius: 6px; }

        select[multiple] option:checked {
            background: linear-gradient(120deg, rgba(14, 165, 233, 0.15), rgba(245, 158, 11, 0.15));
            color: var(--ink);
            font-weight: 700;
        }

        /* Tables */
        .table-container {
            overflow-x: auto;
            border-radius: var(--radius-sm);
            border: 1px solid var(--border);
            box-shadow: var(--shadow-soft);
            background: #fff;
        }

        table { width: 100%; border-collapse: collapse; }

        table th {
            background: linear-gradient(120deg, var(--primary), var(--accent));
            color: #fff;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 0.78rem;
            letter-spacing: 0.04em;
            padding: 14px 16px;
            text-align: left;
        }

        table td {
            padding: 14px 16px;
            border-bottom: 1px solid var(--border);
            color: var(--muted-strong);
            font-size: 0.95rem;
        }

        table tbody tr { transition: background 0.2s ease; }
        table tbody tr:hover { background: #f8fafc; }
        table tbody tr:last-child td { border-bottom: none; }

        /* Badges */
        .badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.02em;
        }

        .badge-primary { background: rgba(14, 165, 233, 0.12); color: var(--primary-strong); }
        .badge-success { background: rgba(16, 185, 129, 0.14); color: #0f9d58; }
        .badge-warning { background: rgba(245, 158, 11, 0.14); color: var(--accent-strong); }
        .badge-danger { background: rgba(239, 68, 68, 0.12); color: #dc2626; }
        .badge-info { background: rgba(14, 165, 233, 0.1); color: var(--primary-strong); }

        /* Tags */
        .tag-list { display: flex; flex-wrap: wrap; gap: 8px; }

        .tag {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 12px;
            background: #f8fafc;
            border: 1px solid var(--border);
            border-radius: 999px;
            font-size: 0.85rem;
            color: var(--muted-strong);
            transition: all 0.2s ease;
        }

        .tag:hover { background: #e2f3fb; border-color: rgba(14, 165, 233, 0.3); }

        .tag .tag-remove { cursor: pointer; color: var(--danger); font-weight: 700; transition: transform 0.2s ease; }
        .tag .tag-remove:hover { transform: scale(1.1); }

        .tag-brand { background: rgba(14, 165, 233, 0.12); color: var(--primary-strong); }
        .tag-company { background: rgba(16, 185, 129, 0.14); color: #0f9d58; }

        /* Alerts */
        .alert {
            padding: 14px 16px;
            border-radius: var(--radius-sm);
            margin-bottom: 18px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            border: 1px solid var(--border);
            box-shadow: var(--shadow-soft);
            background: #fff;
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .alert-success { border-color: rgba(16, 185, 129, 0.4); background: linear-gradient(120deg, rgba(16, 185, 129, 0.12), rgba(14, 165, 233, 0.08)); color: #0f9d58; }
        .alert-error { border-color: rgba(239, 68, 68, 0.4); background: linear-gradient(120deg, rgba(239, 68, 68, 0.12), rgba(245, 158, 11, 0.08)); color: #dc2626; }

        /* Result Box */
        .result-box {
            background: #f8fafc;
            border: 1px dashed var(--border-strong);
            border-radius: var(--radius-sm);
            padding: 20px;
            margin-top: 10px;
            max-height: 420px;
            overflow-y: auto;
        }

        .result-box pre {
            white-space: pre-wrap;
            word-wrap: break-word;
            font-family: 'IBM Plex Mono', 'Consolas', monospace;
            font-size: 0.86rem;
            color: var(--muted-strong);
        }

        .result-box:empty::after,
        .result-box .empty-state {
            content: 'Henüz sonuç yok';
            color: var(--muted);
            text-align: center;
            display: block;
            padding: 36px;
            font-style: italic;
        }

        /* Grid Layout */
        .row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(420px, 1fr));
            gap: 22px;
        }

        .col-6 { min-width: 0; }

        /* Scrollbar Styling */
        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: #e2e8f0; border-radius: 6px; }
        ::-webkit-scrollbar-thumb { background: #94a3b8; border-radius: 6px; }
        ::-webkit-scrollbar-thumb:hover { background: #64748b; }

        /* Hidden */
        .hidden { display: none !important; }

        /* Action Buttons in Table */
        .action-buttons { display: flex; gap: 6px; flex-wrap: wrap; }

        /* Responsive */
        @media (max-width: 860px) {
            body { padding: 18px; }
            .page-header h1 { font-size: 2rem; }
            .row { grid-template-columns: 1fr; }
            .btn { width: 100%; justify-content: center; }
        }

        /* Stats Cards */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 18px;
            margin-bottom: 16px;
        }

        .stat-card {
            background: #fff;
            border-radius: var(--radius);
            padding: 18px;
            text-align: center;
            box-shadow: var(--shadow-soft);
            border: 1px solid var(--border);
        }

        .stat-card .stat-icon { font-size: 2.2rem; margin-bottom: 8px; }
        .stat-card .stat-value { font-size: 1.8rem; font-weight: 700; color: var(--ink); }
        .stat-card .stat-label { color: var(--muted); font-size: 0.9rem; }

        /* Company Search */
        .search-input { position: relative; }
        .search-input input { padding-left: 40px; }
        .search-input::before {
            content: '🔍';
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 1rem;
        }

        /* Loading Animation */
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid #e2e8f0;
            border-radius: 50%;
            border-top-color: var(--primary);
            animation: spin 1s ease-in-out infinite;
        }

        @keyframes spin { to { transform: rotate(360deg); } }

        /* Popup Card Animation */
        .card[id$="Card"] { animation: fadeInUp 0.3s ease; }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Checkbox Items */
        .checkbox-group { display: flex; flex-wrap: wrap; gap: 10px; }

        .checkbox-item {
            display: flex;
            align-items: center;
            background: #f8fafc;
            padding: 10px 14px;
            border-radius: var(--radius-sm);
            border: 1px solid var(--border);
            transition: all 0.2s ease;
            cursor: pointer;
        }

        .checkbox-item:hover { border-color: var(--primary-strong); background: rgba(14, 165, 233, 0.08); }
        .checkbox-item input { width: auto; margin-right: 8px; accent-color: var(--primary); }

        /* UI Scroll */
        .ui-scroll {
            max-height: 300px;
            overflow-y: auto;
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            background: #fff;
        }

        .ui-scroll table { margin: 0; }

        /* Add Button Row */
        .add-btn-row {
            margin-top: 10px;
            padding-top: 10px;
            border-top: 1px dashed var(--border);
        }
    </style>

    <div class="container">
        <div class="page-header">
            <h1>🔐 Kullanıcı Erişim Yönetimi</h1>
            <p>Kullanıcı yetkilendirme ve erişim kontrol sistemi</p>
        </div>
        
        <div id="alertBox" class="alert hidden"></div>
        
        <div class="row">
            <div class="col-6">
                <!--- Yeni Erişim Oluştur --->
                <div class="card">
                    <h2>➕ Yeni Erişim Oluştur</h2>
                    <form id="createAccessForm" name="createAccessForm">
                      <div class="form-group" id="item-sales_emp">
						<label>👤 Kullanıcı Seç</label>
						<div class="input-group">
							<input type="hidden" name="sales_emp_id" id="sales_emp_id" value="">
							<input name="sales_emp" type="text" id="sales_emp" placeholder="Kullanıcı ara..." onfocus="AutoComplete_Create('sales_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','sales_emp_id','','3','120');" value="" autocomplete="off">
							<span class="input-group-text btnPointer icon-ellipsis" onclick="openBoxDraggable('index.cfm?fuseaction=objects.popup_list_positions&field_emp_id=createAccessForm.sales_emp_id&field_name=createAccessForm.sales_emp&select_list=1');">🔍</span>
						</div>
					</div>
                        <div class="form-group">
                            <label for="accessType">📝 Erişim Tipi</label>
                            <select id="accessType" name="accessType" required>
                                <option value="">Seçiniz...</option>
                                <option value="purchase">🛒 Satın Alma (Purchase)</option>
                                <option value="sales">💰 Satış (Sales)</option>                          
                            </select>
                        </div>
                       <div class="form-group">
                            <label>🏷️ Markalar <small style="color: var(--gray-400);">(Ctrl+Click ile çoklu seçim)</small></label>
                            <select name="marks" id="marks" multiple="multiple" style="width:100%; min-height:140px;">
                                <cfoutput query="get_mark_names">
                                    <option value="#BRAND_ID#"<cfif listfind(attributes.marks,BRAND_ID)>selected</cfif>>#BRAND_NAME#</option>
                                </cfoutput>
                            </select>
                        </div>
                       <div class="form-group" id="item-OFFER_ID">
                    <label style="display:none;">Teklif İstenenler </label>
                        
<input type="hidden" name="rows" id="rows" value="0">


        <div class="ui-scroll">
        	<table id="ajax_list_7522694" class="ajax_list ui-form tablesorter tablesorter-default tablesorter920aa3e92968f" sort="true" role="grid">
    
	<thead>
		
			<tr role="row" class="tablesorter-headerRow">
				<th width="20" data-column="0" class="tablesorter-header tablesorter-headerUnSorted" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="ajax_list_7522694" unselectable="on" aria-sort="none" aria-label=": No sort applied, activate to apply an ascending sort" style="user-select: none;"><div class="tablesorter-header-inner">
					<a href="javascript://" onclick="try{opener_control();}catch(e){};openBoxDraggable('index.cfm?fuseaction=objects.popup_list_pars_multiuser&field_emp_id=to_emp_ids&field_pos_id=to_pos_ids&field_pos_code=to_pos_codes&field_par_id=to_par_ids&field_company_id=to_comp_ids&field_cons_id=to_cons_ids&to_title=1&select_list=7,8&row_count=form_baskettbl_to_names_row_count&table_name=form_baskettbl_to_names&table_row_name=form_basketworkcube_to_row&field_grp_id=form_basketto_grp_ids&field_wgrp_id=form_basketto_wgrp_ids&function_row_name=form_basketworkcube_to_delRow&comp_id_list='+document.getElementById('comp_id_list').value);"><i class="fa fa-plus" title="Ekle " alt="Ekle "></i></a>
				</div></th>
				<th data-column="1" class="tablesorter-header tablesorter-headerUnSorted" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="ajax_list_7522694" unselectable="on" aria-sort="none" aria-label="Teklif İstenenler: No sort applied, activate to apply an ascending sort" style="user-select: none;"><div class="tablesorter-header-inner">Yetkili Olduğu Firmalar </div></th>
				<th data-column="2" class="tablesorter-header tablesorter-headerUnSorted" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="ajax_list_7522694" unselectable="on" aria-sort="none" aria-label=": No sort applied, activate to apply an ascending sort" style="user-select: none;"><div class="tablesorter-header-inner"></div></th>
				<th data-column="3" class="tablesorter-header tablesorter-headerUnSorted" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="ajax_list_7522694" unselectable="on" aria-sort="none" aria-label=": No sort applied, activate to apply an ascending sort" style="user-select: none;"><div class="tablesorter-header-inner"></div></th>
				<th data-column="4" class="tablesorter-header tablesorter-headerUnSorted" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="ajax_list_7522694" unselectable="on" aria-sort="none" aria-label=": No sort applied, activate to apply an ascending sort" style="user-select: none;"><div class="tablesorter-header-inner"></div></th>
				<input type="hidden" name="comp_id_list" id="comp_id_list" value="">
				<input type="hidden" name="form_baskettbl_to_names_row_count" id="form_baskettbl_to_names_row_count" value="0">
			</tr>
		
	</thead>
		
						
				<tbody id="form_baskettbl_to_names" width="100%" aria-live="polite" aria-relevant="all"></tbody>	
			 
        	</table>
        </div>
        
        <script>
            jQuery.moveColumn = function (table, from, to) {
                var rows = jQuery('tr', table);
                var cols;
                rows.each(function() {
                cols = jQuery(this).children('th, td');
                cols.eq(from).detach().insertBefore(cols.eq(to));
                });
            }
		
            if($('.controllerEvents').length){
                if($('.controllerEvents').attr("id") == "list"){
                    var th = $('table#ajax_list_7522694:not([is_child]) > thead tr th');
                        th.each(function(){
                            if($(this).attr("id") == undefined)
                            {
                                $(this).attr("id","th_"+$(this).index());
                            };
                    });
                }
            }

            	
        </script>
        
<script type="text/javascript">
	
		cus_tag_max_row_to=0;
		function form_basketworkcube_to_delRow(yer,int_row)
		{ 
			var ver = navigator.appVersion;
			
				flag_custag=document.all.to_par_ids.length;
			
			if(flag_custag > 0)
			{
				if (ver.indexOf("MSIE") != -1)
				{
					try{document.all.to_pos_ids[yer-1].value = '';}catch(e){}
					try{document.all.to_pos_codes[yer-1].value = '';}catch(e){}
					try{document.all.to_emp_ids[yer-1].value = '';}catch(e){}
					try{document.all.to_comp_ids[yer-1].value = '';}catch(e){}
					try{document.all.to_par_ids[yer-1].value = '';}catch(e){}
					try{document.all.to_cons_ids[yer-1].value = '';}catch(e){}
					try{document.all.form_basketto_wgrp_ids[yer-1].value = '';}catch(e){}
				}
				else
				{
					for(var i=0;i<document.all.to_emp_ids.lenght;i++)
					{
						if(document.all.to_emp_ids[i].value==int_row)
						{
							try{document.all.to_pos_ids[i].value = '';}catch(e){}
							try{document.all.to_pos_codes[i].value = '';}catch(e){}
							try{document.all.to_emp_ids[i].value = '';}catch(e){}
							try{document.all.to_comp_ids[i].value = '';}catch(e){}
							try{document.all.to_par_ids[i].value = '';}catch(e){}
							try{document.all.to_cons_ids[i].value = '';}catch(e){}
							try{document.all.form_basketto_wgrp_ids[i].value = '';}catch(e){}
							break;
						}	
					}
					try
					{
						for(var i=0;i<document.all.to_comp_ids.length;i++)
						{
							if(document.all.to_comp_ids[i].value==int_row)
							{
								try{document.all.to_comp_ids[i].value = '';}catch(e){}
								try{document.all.to_par_ids[i].value = '';}catch(e){}
								break;
							}
						}
					}catch(e){}
				}
			}
			else
			{
				try{document.all.to_pos_ids.value = '';}catch(e){}
				try{document.all.to_pos_codes.value = '';}catch(e){}
				try{document.all.to_emp_ids.value = '';}catch(e){}
				try{document.all.to_comp_ids.value = '';}catch(e){}
				try{document.all.to_par_ids.value = '';}catch(e){}
				try{document.all.to_cons_ids.value = '';}catch(e){}
				try{document.all.form_basketto_wgrp_ids.value = '';}catch(e){}
			}
			var my_element = document.getElementById('form_basketworkcube_to_row' + yer);
			my_element.parentNode.removeChild(my_element);
			document.getElementById('form_baskettbl_to_names_row_count').value = yer - 1;
		}

	
function control_related_offer(a,b)//cariden daha once teklif istenip istenmedigini kontrol eder
{
	
		if(a >= 1)
		{
			alert("Cariden Daha Önce Teklif İstenmiştir!");
			return false;
		}
		else
		{
			
		}
	
}
function hepsini_sil(option)
{
	if(option == 1)
	{
		for(i=1;i<=document.getElementById('form_baskettbl_to_names_row_count').value;i++)
		{
				var my_element = document.getElementById('form_basketworkcube_to_row' + i);
				my_element.parentNode.removeChild(my_element);
		}
		document.getElementById('hepsini_sil_id').style.display='none';
	}
	else if(option == 2)
	{
		for(i=0;i<=document.getElementById('tbl_cc_names_row_count').value;i++)
		{
				var my_element = document.getElementById('form_basketworkcube_cc_row' + i);
				my_element.parentNode.removeChild(my_element);
		}
		document.getElementById('hepsini_sil_id2').style.display='none';
	}
	else
	{
		for(i=0;i<=document.getElementById('tbl_cc2_names_row_count').value;i++)
		{
				var my_element = document.getElementById('form_basketworkcube_cc2_row' + i);
				my_element.parentNode.removeChild(my_element);
		}
		document.getElementById('hepsini_sil_id3').style.display='none';
	}
}
</script> 
                </div>
                        <button type="submit" class="btn btn-success">Erişim Oluştur</button>
                    </form>
                </div>
            </div>
            
            <div class="col-6">
                <!--- Kullanıcı Erişimlerini Sorgula --->
                <div class="card">
                    <h2>🔍 Erişim Sorgula</h2>
                    <div class="form-group">
                        <label for="searchUserId">🔢 Kullanıcı ID</label>
                        <input type="number" id="searchUserId" placeholder="Kullanıcı ID girin...">
                    </div>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <button class="btn btn-primary" onclick="getUserAccessDetails()">
                            <span>👤</span> Kullanıcı Erişimlerini Getir
                        </button>
                        <button class="btn btn-warning" onclick="getAllUserAccess()">
                            <span>📊</span> Tüm Erişimleri Getir
                        </button>
                    </div>
                </div>
                
                <!--- Erişim Güncelle/Sil --->
                <div class="card">
                    <h2>✏️ Erişim Güncelle/Sil</h2>
                    <div class="form-group">
                        <label for="updateAccessId">🔑 Erişim ID</label>
                        <input type="number" id="updateAccessId" readonly placeholder="Listeden bir kayıt seçin...">
                    </div>
                    <div class="form-group">
                        <label>👤 Kullanıcı</label>
                        <div class="input-group">
                            <input type="hidden" name="update_emp_id" id="update_emp_id" value="">
                            <input name="update_emp" type="text" id="update_emp" placeholder="Kullanıcı seç..." onfocus="AutoComplete_Create('update_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','update_emp_id','','3','120');" value="" autocomplete="off">
                            <span class="input-group-text btnPointer icon-ellipsis" onclick="openBoxDraggable('index.cfm?fuseaction=objects.popup_list_positions&field_emp_id=update_emp_id&field_name=update_emp&select_list=1');">🔍</span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="updateAccessType">📝 Yeni Erişim Tipi</label>
                        <select id="updateAccessType">
                            <option value="">Seçiniz...</option>
                            <option value="purchase">🛒 Satın Alma (Purchase)</option>
                            <option value="sales">💰 Satış (Sales)</option>
                        </select>
                    </div>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <button class="btn btn-primary" onclick="updateUserAccess()">
                            <span>✅</span> Güncelle
                        </button>
                        <button class="btn btn-danger" onclick="deleteUserAccess()">
                            <span>🗑️</span> Sil
                        </button>
                        <button class="btn btn-warning" onclick="clearUpdateForm()">
                            <span>🔄</span> Temizle
                        </button>
                    </div>
                </div>
            </div>
        </div>
        
        <!--- Sonuçlar --->
        <div class="card">
            <h2>📋 Detay Sonuçları</h2>
            <div class="result-box">
                <div id="resultContainer">
                    <div class="empty-state" style="text-align: center; padding: 40px; color: var(--gray-400);">
                        <div style="font-size: 3rem; margin-bottom: 10px;">📝</div>
                        <p>Henüz sonuç yok. Bir kayıt seçin veya sorgulama yapın.</p>
                    </div>
                </div>
            </div>
        </div>
        
        <!--- Marka/Firma Ekleme Bölümü --->
        <div class="row">
            <div class="col-6">
                <div class="card" id="addBrandCard" style="display:none;">
                    <h2>🏷️ Marka Ekle <span class="badge badge-primary">Erişim #<span id="brandAccessId"></span></span></h2>
                    <div class="form-group">
                        <label>Eklenecek Marka</label>
                        <select id="newBrandSelect">
                            <option value="">Seçiniz...</option>
                            <cfoutput query="get_mark_names">
                                <option value="#BRAND_ID#">#BRAND_NAME#</option>
                            </cfoutput>
                        </select>
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button class="btn btn-success" onclick="addBrandToAccess()">
                            <span>✅</span> Marka Ekle
                        </button>
                        <button class="btn btn-warning" onclick="hideAddBrandForm()">
                            <span>❌</span> İptal
                        </button>
                    </div>
                </div>
            </div>
            <div class="col-6">
                <div class="card" id="addCompanyCard" style="display:none;">
                    <h2>🏢 Firma Ekle <span class="badge badge-success">Erişim #<span id="companyAccessId"></span></span></h2>
                    <div class="form-group">
                        <label>🔍 Firma Ara</label>
                        <input type="text" id="companySearchInput" placeholder="Firma adı yazın..." onkeyup="filterCompanies()">
                    </div>
                    <div class="form-group">
                        <label>Eklenecek Firma <span id="companyCount" class="badge badge-info"></span></label>
                        <select id="newCompanySelect" size="8" style="width:100%;">
                            <cfoutput query="get_companies">
                                <option value="#PAR_ID#">#PAR_NAME#</option>
                            </cfoutput>
                        </select>
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button class="btn btn-success" onclick="addCompanyToAccess()">
                            <span>✅</span> Firma Ekle
                        </button>
                        <button class="btn btn-warning" onclick="hideAddCompanyForm()">
                            <span>❌</span> İptal
                        </button>
                    </div>
                </div>
            </div>
        </div>
        
        <!--- Erişim Listesi --->
        <div class="card">
            <h2>📊 Erişim Listesi</h2>
            <div class="table-container" id="accessListContainer">
                <table id="accessTable">
                    <thead>
                        <tr>
                            <th style="width: 80px;">🔑 ID</th>
                            <th>👤 Kullanıcı</th>
                            <th style="width: 150px;">📝 Erişim Tipi</th>
                            <th>🏷️ Markalar</th>
                            <th>🏢 Firmalar</th>
                            <th style="width: 200px;">⚙️ İşlemler</th>
                        </tr>
                    </thead>
                    <tbody id="accessTableBody">
                        <tr>
                            <td colspan="6" style="text-align: center; padding: 40px;">
                                <div style="font-size: 3rem; margin-bottom: 10px;">📋</div>
                                <p style="color: var(--gray-400);">Veri yüklemek için "Tüm Erişimleri Getir" butonuna tıklayın</p>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        const API_URL = '/addOns/Partner/yetki/user_access_api.cfm';
        
        // Alert göster
        function showAlert(message, isSuccess) {
            const alertBox = document.getElementById('alertBox');
            alertBox.className = isSuccess ? 'alert alert-success' : 'alert alert-error';
            alertBox.textContent = message;
            alertBox.classList.remove('hidden');
            
            setTimeout(() => {
                alertBox.classList.add('hidden');
            }, 5000);
        }
        
        // Sonuç göster
        function showResult(data) {
            const container = document.getElementById('resultContainer');
            container.innerHTML = '<pre>' + JSON.stringify(data, null, 2) + '</pre>';
        }
        
        // API çağrısı yap
        async function apiCall(action, data = {}) {
            console.log('API Call:', action, data);
            const formData = new FormData();
            formData.append('action', action);
            
            for (const key in data) {
                formData.append(key, data[key]);
            }
            
            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    body: formData
                });
                console.log('Response status:', response.status);
                const text = await response.text();
                console.log('Response text:', text);
                
                try {
                    const result = JSON.parse(text);
                    // ColdFusion büyük harfli key döndürüyor, küçük harfe çeviriyoruz
                    return {
                        success: result.SUCCESS,
                        message: result.MESSAGE,
                        data: result.DATA
                    };
                } catch (parseError) {
                    console.error('JSON Parse Error:', parseError);
                    return { success: false, message: 'JSON parse hatası: ' + text.substring(0, 200) };
                }
            } catch (error) {
                console.error('Fetch Error:', error);
                return { success: false, message: 'Bağlantı hatası: ' + error.message };
            }
        }
        
        // Seçili marka değerlerini al (multiple select için)
        function getSelectedMarks() {
            const select = document.getElementById('marks');
            const selectedOptions = Array.from(select.selectedOptions);
            return selectedOptions.map(option => option.value).join(',');
        }
        
        // Seçili şirket ID'lerini al (dinamik tablodan - PAR_ID kullanılıyor)
        function getSelectedCompanyIds() {
            const parInputs = document.querySelectorAll('input[name="to_par_ids"]');
            const companyIds = [];
            parInputs.forEach(input => {
                if (input.value && input.value.trim() !== '') {
                    companyIds.push(input.value);
                }
            });
            return companyIds.join(',');
        }
        
        // Yeni erişim oluştur
        document.getElementById('createAccessForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const userId = document.getElementById('sales_emp_id').value;
            const accessType = document.getElementById('accessType').value;
            const brandIds = getSelectedMarks();
            const companyIds = getSelectedCompanyIds();
            
            if (!userId || userId == '0') {
                showAlert('Lütfen bir kullanıcı seçin', false);
                return;
            }
            
            if (!accessType) {
                showAlert('Lütfen erişim tipi seçin', false);
                return;
            }
            
            const result = await apiCall('createUserAccess', {
                userId: userId,
                accessType: accessType,
                brandIds: brandIds,
                companyIds: companyIds
            });
            
            showAlert(result.message, result.success);
            showResult(result);
            
            if (result.success) {
                this.reset();
                getAllUserAccess();
            }
        });
        
        // Tüm erişimleri getir
        async function getAllUserAccess() {
            console.log('getAllUserAccess çağrıldı');
            showResult({ message: 'Yükleniyor...' });
            
            const result = await apiCall('getAllUserAccess');
            console.log('getAllUserAccess sonuç:', result);
            showResult(result);
            
            if (result.success && result.data) {
                renderAccessTable(result.data);
            } else {
                showAlert(result.message || 'Veri alınamadı', false);
            }
        }
        
        // Kullanıcı erişim detaylarını getir
        async function getUserAccessDetails() {
            const userId = document.getElementById('searchUserId').value;
            
            if (!userId) {
                showAlert('Lütfen kullanıcı ID girin', false);
                return;
            }
            
            const result = await apiCall('getUserAccessDetails', { userId: userId });
            showAlert(result.message, result.success);
            showResult(result);
        }
        
        // Erişimi güncelle
        async function updateUserAccess() {
            const accessId = document.getElementById('updateAccessId').value;
            const userId = document.getElementById('update_emp_id').value;
            const accessType = document.getElementById('updateAccessType').value;
            
            if (!accessId) {
                showAlert('Lütfen listeden bir erişim seçin', false);
                return;
            }
            
            if (!userId || userId == '0' || userId == '') {
                showAlert('Lütfen bir kullanıcı seçin', false);
                return;
            }
            
            if (!accessType) {
                showAlert('Lütfen erişim tipi seçin', false);
                return;
            }
            
            const result = await apiCall('updateUserAccess', {
                accessId: accessId,
                userId: userId,
                accessType: accessType
            });
            
            showAlert(result.message, result.success);
            showResult(result);
            
            if (result.success) {
                clearUpdateForm();
                getAllUserAccess();
            }
        }
        
        // Güncelleme formunu temizle
        function clearUpdateForm() {
            document.getElementById('updateAccessId').value = '';
            document.getElementById('update_emp_id').value = '';
            document.getElementById('update_emp').value = '';
            document.getElementById('updateAccessType').value = '';
        }
        
        // Erişimi sil
        async function deleteUserAccess() {
            const accessId = document.getElementById('updateAccessId').value;
            
            if (!accessId) {
                showAlert('Lütfen erişim ID girin', false);
                return;
            }
            
            if (!confirm('Bu erişimi silmek istediğinizden emin misiniz?')) {
                return;
            }
            
            const result = await apiCall('deleteUserAccess', { accessId: accessId });
            showAlert(result.message, result.success);
            showResult(result);
            
            if (result.success) {
                getAllUserAccess();
            }
        }
        
        // Erişim tablosunu render et
        function renderAccessTable(data) {
            const tbody = document.getElementById('accessTableBody');
            
            if (!data || data.length === 0) {
                tbody.innerHTML = `
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 40px;">
                            <div style="font-size: 3rem; margin-bottom: 10px;">🔍</div>
                            <p style="color: var(--gray-400);">Kayıt bulunamadı</p>
                        </td>
                    </tr>`;
                return;
            }
            
            tbody.innerHTML = data.map(item => `
                <tr>
                    <td><span class="badge badge-primary">#${item.ACCESS_ID}</span></td>
                    <td>
                        <div style="font-weight: 600;">${item.USER_NAME || 'Bilinmiyor'}</div>
                        <small style="color: var(--gray-400);">ID: ${item.USER_ID}</small>
                    </td>
                    <td>
                        <span class="badge ${item.ACCESS_TYPE === 'purchase' ? 'badge-warning' : 'badge-success'}">
                            ${item.ACCESS_TYPE === 'purchase' ? '🛒' : '💰'} ${getAccessTypeLabel(item.ACCESS_TYPE)}
                        </span>
                    </td>
                    <td>
                        <button class="btn btn-primary btn-sm" onclick="loadBrands(${item.ACCESS_ID})">
                            🏷️ Göster
                        </button>
                    </td>
                    <td>
                        <button class="btn btn-primary btn-sm" onclick="loadCompanies(${item.ACCESS_ID})">
                            🏢 Göster
                        </button>
                    </td>
                    <td>
                        <div class="action-buttons">
                            <button class="btn btn-warning btn-icon" onclick="editAccess(${item.ACCESS_ID}, ${item.USER_ID}, '${item.ACCESS_TYPE}', '${(item.USER_NAME || '').replace(/'/g, "\\'")}')">
                                ✏️
                            </button>
                            <button class="btn btn-danger btn-icon" onclick="quickDelete(${item.ACCESS_ID})">
                                🗑️
                            </button>
                        </div>
                    </td>
                </tr>
            `).join('');
        }
        
        // Erişim tipi etiketini getir
        function getAccessTypeLabel(type) {
            const labels = {
                'purchase': 'Satın Alma',
                'sales': 'Satış'
            };
            return labels[type] || type;
        }
        
        // Düzenleme formunu doldur
        function editAccess(accessId, userId, accessType, userName) {
            document.getElementById('updateAccessId').value = accessId;
            document.getElementById('update_emp_id').value = userId;
            document.getElementById('update_emp').value = userName || '';
            document.getElementById('updateAccessType').value = accessType;
            
            // Forma scroll yap
            document.getElementById('updateAccessId').scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
        
        // Hızlı silme
        async function quickDelete(accessId) {
            if (!confirm('Bu erişimi silmek istediğinizden emin misiniz?')) {
                return;
            }
            
            const result = await apiCall('deleteUserAccess', { accessId: accessId });
            showAlert(result.message, result.success);
            
            if (result.success) {
                getAllUserAccess();
            }
        }
        
        // Aktif erişim ID'sini sakla (marka/firma silme işlemleri için)
        let currentAccessId = null;
        
        // Markaları yükle ve göster (silme butonlarıyla)
        async function loadBrands(accessId) {
            currentAccessId = accessId;
            const result = await apiCall('getBrandsByAccessId', { accessId: accessId });
            
            let html = `
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h4 style="margin: 0; color: var(--gray-800);">
                        🏷️ Erişim <span class="badge badge-primary">#${accessId}</span> - Markalar
                    </h4>
                    <button class="btn btn-success btn-sm" onclick="showAddBrandForm(${accessId})">
                        ➕ Yeni Marka Ekle
                    </button>
                </div>
            `;
            
            if (result.success && result.data && result.data.length > 0) {
                html += '<div class="tag-list" style="margin-bottom: 20px;">';
                result.data.forEach(brand => {
                    html += `
                        <div class="tag tag-brand">
                            <span>🏷️ ${brand.BRAND_NAME || 'ID: ' + brand.BRAND_ID}</span>
                            <span class="tag-remove" onclick="removeBrand(${accessId}, ${brand.BRAND_ID})" title="Sil">✕</span>
                        </div>
                    `;
                });
                html += '</div>';
                html += `<p style="color: var(--gray-400); font-size: 0.85rem;">Toplam ${result.data.length} marka</p>`;
            } else {
                html += `
                    <div style="text-align: center; padding: 30px; color: var(--gray-400);">
                        <div style="font-size: 2rem; margin-bottom: 10px;">🏷️</div>
                        <p>Henüz marka eklenmemiş</p>
                    </div>
                `;
            }
            
            document.getElementById('resultContainer').innerHTML = html;
        }
        
        // Şirketleri yükle ve göster (silme butonlarıyla)
        async function loadCompanies(accessId) {
            currentAccessId = accessId;
            const result = await apiCall('getCompaniesByAccessId', { accessId: accessId });
            
            let html = `
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h4 style="margin: 0; color: var(--gray-800);">
                        🏢 Erişim <span class="badge badge-success">#${accessId}</span> - Firmalar
                    </h4>
                    <button class="btn btn-success btn-sm" onclick="showAddCompanyForm(${accessId})">
                        ➕ Yeni Firma Ekle
                    </button>
                </div>
            `;
            
            if (result.success && result.data && result.data.length > 0) {
                html += '<div class="tag-list" style="margin-bottom: 20px;">';
                result.data.forEach(company => {
                    html += `
                        <div class="tag tag-company">
                            <span>🏢 ${company.COMPANY_NAME || 'ID: ' + company.COMPANY_ID}</span>
                            <span class="tag-remove" onclick="removeCompany(${accessId}, ${company.COMPANY_ID})" title="Sil">✕</span>
                        </div>
                    `;
                });
                html += '</div>';
                html += `<p style="color: var(--gray-400); font-size: 0.85rem;">Toplam ${result.data.length} firma</p>`;
            } else {
                html += `
                    <div style="text-align: center; padding: 30px; color: var(--gray-400);">
                        <div style="font-size: 2rem; margin-bottom: 10px;">🏢</div>
                        <p>Henüz firma eklenmemiş</p>
                    </div>
                `;
            }
            
            document.getElementById('resultContainer').innerHTML = html;
        }
        
        // Marka sil
        async function removeBrand(accessId, brandId) {
            if (!confirm('Bu markayı erişimden kaldırmak istediğinizden emin misiniz?')) {
                return;
            }
            
            const result = await apiCall('removeBrandFromAccess', { 
                accessId: accessId, 
                brandId: brandId 
            });
            
            showAlert(result.message, result.success);
            
            if (result.success) {
                // Marka listesini yenile
                loadBrands(accessId);
            }
        }
        
        // Firma sil
        async function removeCompany(accessId, companyId) {
            if (!confirm('Bu firmayı erişimden kaldırmak istediğinizden emin misiniz?')) {
                return;
            }
            
            const result = await apiCall('removeCompanyFromAccess', { 
                accessId: accessId, 
                companyId: companyId 
            });
            
            showAlert(result.message, result.success);
            
            if (result.success) {
                // Firma listesini yenile
                loadCompanies(accessId);
            }
        }
        
        // ==================== MARKA EKLEME ====================
        
        // Marka ekleme formunu göster
        function showAddBrandForm(accessId) {
            currentAccessId = accessId;
            document.getElementById('brandAccessId').textContent = accessId;
            document.getElementById('newBrandSelect').value = '';
            document.getElementById('addBrandCard').style.display = 'block';
            document.getElementById('addBrandCard').scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
        
        // Marka ekleme formunu gizle
        function hideAddBrandForm() {
            document.getElementById('addBrandCard').style.display = 'none';
        }
        
        // Erişime marka ekle
        async function addBrandToAccess() {
            const brandId = document.getElementById('newBrandSelect').value;
            
            if (!brandId) {
                showAlert('Lütfen bir marka seçin', false);
                return;
            }
            
            if (!currentAccessId) {
                showAlert('Erişim ID bulunamadı', false);
                return;
            }
            
            const result = await apiCall('addBrandToAccess', {
                accessId: currentAccessId,
                brandId: brandId
            });
            
            showAlert(result.message, result.success);
            
            if (result.success) {
                hideAddBrandForm();
                loadBrands(currentAccessId);
            }
        }
        
        // ==================== FİRMA EKLEME ====================
        
        // Firma listesi için orijinal options'ları sakla
        let allCompanyOptions = [];
        
        // Sayfa yüklendiğinde firma options'larını sakla
        function initCompanyOptions() {
            const select = document.getElementById('newCompanySelect');
            if (select) {
                allCompanyOptions = Array.from(select.options).map(opt => ({
                    value: opt.value,
                    text: opt.text
                }));
                updateCompanyCount();
            }
        }
        
        // Firma sayısını güncelle
        function updateCompanyCount() {
            const select = document.getElementById('newCompanySelect');
            const countSpan = document.getElementById('companyCount');
            if (select && countSpan) {
                const visibleCount = select.options.length;
                countSpan.textContent = `(${visibleCount} firma)`;
            }
        }
        
        // Firma arama/filtreleme
        function filterCompanies() {
            const searchInput = document.getElementById('companySearchInput');
            const select = document.getElementById('newCompanySelect');
            const searchTerm = searchInput.value.toLowerCase().trim();
            
            // Select'i temizle
            select.innerHTML = '';
            
            // Filtrelenmiş options'ları ekle
            allCompanyOptions.forEach(opt => {
                if (opt.text.toLowerCase().includes(searchTerm)) {
                    const option = document.createElement('option');
                    option.value = opt.value;
                    option.text = opt.text;
                    select.add(option);
                }
            });
            
            updateCompanyCount();
        }
        
        // Firma ekleme formunu göster
        function showAddCompanyForm(accessId) {
            currentAccessId = accessId;
            document.getElementById('companyAccessId').textContent = accessId;
            document.getElementById('companySearchInput').value = '';
            document.getElementById('newCompanySelect').value = '';
            
            // Options'ları sıfırla
            filterCompanies();
            
            document.getElementById('addCompanyCard').style.display = 'block';
            document.getElementById('addCompanyCard').scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
        
        // Firma ekleme formunu gizle
        function hideAddCompanyForm() {
            document.getElementById('addCompanyCard').style.display = 'none';
        }
        
        // Erişime firma ekle
        async function addCompanyToAccess() {
            const companyId = document.getElementById('newCompanySelect').value;
            
            if (!companyId) {
                showAlert('Lütfen bir firma seçin', false);
                return;
            }
            
            if (!currentAccessId) {
                showAlert('Erişim ID bulunamadı', false);
                return;
            }
            
            const result = await apiCall('addCompanyToAccess', {
                accessId: currentAccessId,
                companyId: companyId
            });
            
            showAlert(result.message, result.success);
            
            if (result.success) {
                hideAddCompanyForm();
                loadCompanies(currentAccessId);
            }
        }
        
        // Sayfa yüklendiğinde tüm erişimleri getir ve firma listesini hazırla
        document.addEventListener('DOMContentLoaded', function() {
            initCompanyOptions();
            getAllUserAccess();
        });
    </script>

