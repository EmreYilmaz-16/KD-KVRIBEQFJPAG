<cfparam name="attributes.sql_sorgu" default="">
<cfparam name="attributes.action" default="">
<cfparam name="attributes.query_name" default="">
<cfparam name="attributes.export_format" default="">

<!--- Kayıtlı sorguları getir --->
<cfquery name="getSavedQueries" datasource="#dsn#">
    SELECT * FROM (
        SELECT 
            'saved_query_1' as query_id,
            'Tüm Tablolar' as query_name,
            'SELECT ST.name as table_name, ss.name as schema_name FROM sys.tables AS ST LEFT JOIN SYS.schemas AS SS ON SS.schema_id=ST.schema_id ORDER BY st.schema_id' as query_sql
        UNION ALL
        SELECT 
            'saved_query_2' as query_id,
            'Seri No Durumu' as query_name,
            'SELECT * FROM w3Qa_1.SERIAL_IN_OUT_PBS WHERE IS_ALIVE = 1' as query_sql
        UNION ALL
        SELECT 
            'saved_query_3' as query_id,
            'Stok Fişi Kontrol' as query_name,
            'SELECT TOP 100 * FROM w3Qa_2025_1.STOCK_FIS_ROW ORDER BY STOCK_FIS_ROW_ID DESC' as query_sql
    ) as saved_queries
</cfquery>

<!--- Tablo listesi --->
<cfquery name="getT" datasource="#dsn#">
    SELECT ST.name, ss.name as schema_name, 
           (SELECT COUNT(*) FROM sys.columns WHERE object_id = ST.object_id) as column_count
    FROM #dsn#.sys.tables AS ST 
    LEFT JOIN #dsn#.SYS.schemas AS SS ON SS.schema_id=ST.schema_id
    ORDER BY st.schema_id, ST.name
</cfquery>

<!DOCTYPE html>
<html>
<head>
    <title>SQL Sorgu Yöneticisi</title>
    <meta charset="utf-8">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/codemirror.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/theme/monokai.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/codemirror.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/sql/sql.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/addon/edit/matchbrackets.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/addon/hint/show-hint.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/addon/hint/sql-hint.min.js"></script>
    <style>
        .CodeMirror {
            border: 1px solid #ddd;
            height: 200px;
            font-size: 14px;
        }
        .table-container {
            max-height: 400px;
            overflow-y: auto;
        }
        .sidebar {
            background-color: #f8f9fa;
            min-height: 100vh;
            padding: 15px;
        }
        .query-history {
            max-height: 200px;
            overflow-y: auto;
        }
        .table-item {
            cursor: pointer;
            padding: 5px;
            border-radius: 3px;
        }
        .table-item:hover {
            background-color: #e9ecef;
        }
        .schema-header {
            font-weight: bold;
            color: #495057;
            margin-top: 10px;
        }
        .insert-form-label {
            font-size: 0.9rem;
            margin-bottom: 0.3rem;
        }
        .insert-form-field {
            margin-bottom: 1rem;
        }
        .insert-preview-sql {
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 0.375rem;
            padding: 0.75rem;
            font-family: 'Courier New', monospace;
            font-size: 0.85rem;
            white-space: pre-wrap;
            min-height: 200px;
            max-height: 400px;
            overflow-y: auto;
        }
        .field-required {
            color: #dc3545;
        }
        .field-identity {
            background-color: #e3f2fd;
            color: #1976d2;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sol Sidebar -->
            <div class="col-md-3 sidebar">
                <h5><i class="bi bi-database"></i> Veritabanı Tabloları</h5>
                <div class="mb-3">
                    <input type="text" class="form-control form-control-sm" id="tableSearch" placeholder="Tablo ara...">
                </div>
                <div id="tableList" style="max-height: 300px; overflow-y: auto;">
                    <cfset currentSchema = "">
                    <cfoutput query="getT">
                        <cfif currentSchema neq schema_name>
                            <cfset currentSchema = schema_name>
                            <div class="schema-header">#schema_name#</div>
                        </cfif>
                        <div class="table-item" onclick="loadTableInfo('#schema_name#', '#name#')" 
                             oncontextmenu="showTableContextMenu(event, '#schema_name#', '#name#')" 
                             title="#column_count# kolon">
                            <small><i class="bi bi-table"></i> #name# (#column_count#)</small>
                        </div>
                    </cfoutput>
                </div>

                <hr>
                <h6><i class="bi bi-bookmark"></i> Kayıtlı Sorgular</h6>
                <div class="list-group list-group-flush">
                    <cfoutput query="getSavedQueries">
                        <a href="javascript:void(0)" class="list-group-item list-group-item-action py-2" 
                           onclick="loadSavedQuery('#query_sql#')">
                            <small>#query_name#</small>
                        </a>
                    </cfoutput>
                </div>

                <hr>
                <h6><i class="bi bi-clock-history"></i> Sorgu Geçmişi</h6>
                <div class="mb-2">
                    <button class="btn btn-sm btn-outline-primary w-100" onclick="showQueryHistory()">
                        <i class="bi bi-list"></i> Geçmişi Görüntüle
                    </button>
                </div>
                <div id="favoriteQueries">
                    <!-- Favori sorgular buraya yüklenecek -->
                </div>
            </div>

            <!-- Ana İçerik -->
            <div class="col-md-9">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h3><i class="bi bi-terminal"></i> SQL Sorgu Yöneticisi</h3>
                    <div>
                        <button type="button" class="btn btn-success btn-sm" onclick="executeQuery()">
                            <i class="bi bi-play-fill"></i> Çalıştır (Ctrl+Enter)
                        </button>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="saveQuery()">
                            <i class="bi bi-save"></i> Kaydet
                        </button>
                        <button type="button" class="btn btn-warning btn-sm" onclick="formatQuery()">
                            <i class="bi bi-code"></i> Formatla
                        </button>
                        <button type="button" class="btn btn-info btn-sm" onclick="clearQuery()">
                            <i class="bi bi-trash"></i> Temizle
                        </button>
                    </div>
                </div>

                <cfform method="post" action="/AddOns/Partner/admin/sql_manager.cfm" id="queryForm">
                    <div class="mb-3">
                        <label for="sql_sorgu" class="form-label">SQL Sorgusu:</label>
                        <textarea name="sql_sorgu" id="sql_sorgu" class="form-control"><cfoutput>#attributes.sql_sorgu#</cfoutput></textarea>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <input type="text" name="query_name" class="form-control" placeholder="Sorgu adı (kaydetmek için)">
                        </div>
                        <div class="col-md-3">
                            <select name="export_format" class="form-control">
                                <option value="">Export Formatı</option>
                                <option value="excel">Excel</option>
                                <option value="csv">CSV</option>
                                <option value="json">JSON</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <button type="submit" name="action" value="execute" class="btn btn-primary w-100">
                                <i class="bi bi-play-fill"></i> Sorguyu Çalıştır
                            </button>
                        </div>
                    </div>
                    
                    <input type="hidden" name="is_submit" value="1">
                </cfform>

                <!-- Sonuçlar -->
                <cfif isDefined("attributes.is_submit") and len(trim(attributes.sql_sorgu))>
                    <div class="card">
                        <div class="card-header d-flex justify-content-between">
                            <h6><i class="bi bi-table"></i> Sorgu Sonuçları</h6>
                            <div>
                                <small class="text-muted">Çalıştırıldı: <cfoutput>#dateFormat(now(), "dd/mm/yyyy")# #timeFormat(now(), "HH:mm:ss")#</cfoutput></small>
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <cftry>
                                <cfquery name="getSorgu" datasource="#dsn#" result="res">
                                    #preserveSingleQuotes(attributes.sql_sorgu)#
                                </cfquery>

                                <cfif isDefined("res.COLUMNLIST") and res.recordcount gt 0>
                                    <div class="table-container">
                                        <table class="table table-striped table-hover table-sm mb-0">
                                            <thead class="table-dark sticky-top">
                                                <tr>
                                                    <th style="width: 50px;">#</th>
                                                    <cfloop list="#res.COLUMNLIST#" item="item">
                                                        <th><cfoutput>#item#</cfoutput></th>
                                                    </cfloop>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <cfoutput query="getSorgu">
                                                    <tr>
                                                        <td class="text-muted">#currentrow#</td>
                                                        <cfloop list="#res.COLUMNLIST#" item="item">
                                                            <td>
                                                                <cfset cellValue = evaluate(item)>
                                                                <cfif len(cellValue) gt 100>
                                                                    <span title="#cellValue#">#left(cellValue, 100)#...</span>
                                                                <cfelse>
                                                                    #cellValue#
                                                                </cfif>
                                                            </td>
                                                        </cfloop>
                                                    </tr>
                                                </cfoutput>
                                            </tbody>
                                        </table>
                                    </div>
                                    
                                    <div class="card-footer">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <small class="text-success">
                                                    <i class="bi bi-check-circle"></i> 
                                                    <strong><cfoutput>#res.recordcount#</cfoutput></strong> kayıt bulundu
                                                </small>
                                            </div>
                                            <div class="col-md-6 text-end">
                                                <small class="text-muted">
                                                    Süre: <cfoutput>#res.executionTime#</cfoutput> ms
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                <cfelse>
                                    <div class="alert alert-info m-3">
                                        <i class="bi bi-info-circle"></i> Sorgu başarıyla çalıştırıldı ancak sonuç bulunamadı.
                                        <cfif isDefined("res.recordcount")>
                                            <br><small>Etkilenen satır sayısı: <cfoutput>#res.recordcount#</cfoutput></small>
                                        </cfif>
                                    </div>
                                </cfif>

                                <cfcatch type="any">
                                    <div class="alert alert-danger m-3">
                                        <h6><i class="bi bi-exclamation-triangle"></i> Hata!</h6>
                                        <p><strong>Mesaj:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                                        <cfif len(cfcatch.detail)>
                                            <p><strong>Detay:</strong> <cfoutput>#cfcatch.detail#</cfoutput></p>
                                        </cfif>
                                        <cfif len(cfcatch.sql)>
                                            <p><strong>SQL:</strong> <code><cfoutput>#cfcatch.sql#</cfoutput></code></p>
                                        </cfif>
                                    </div>
                                </cfcatch>
                            </cftry>
                        </div>
                    </div>
                </cfif>

                <!-- Tablo Bilgi Modal -->
                <div class="modal fade" id="tableInfoModal" tabindex="-1">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">Tablo Bilgileri</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body" id="tableInfoContent">
                                <!-- Tablo bilgileri burada yüklenecek -->
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Kapat</button>
                                <button type="button" class="btn btn-success" onclick="openInsertModal()">
                                    <i class="bi bi-plus-circle"></i> Yeni Kayıt Ekle
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Insert Modal -->
                <div class="modal fade" id="insertModal" tabindex="-1">
                    <div class="modal-dialog modal-xl">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">
                                    <i class="bi bi-plus-circle"></i> 
                                    Yeni Kayıt Ekle - <span id="insertTableName"></span>
                                </h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <form id="insertForm">
                                <div class="modal-body">
                                    <div class="row">
                                        <div class="col-md-8">
                                            <div id="insertFormFields">
                                                <!-- Form alanları burada dinamik olarak oluşturulacak -->
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="card">
                                                <div class="card-header">
                                                    <h6><i class="bi bi-code-square"></i> Oluşturulan SQL</h6>
                                                </div>
                                                <div class="card-body">
                                                    <div class="bg-light p-2 rounded" style="min-height: 200px; max-height: 400px; overflow-y: auto;">
                                                        <code id="generatedInsertSQL" style="white-space: pre-wrap;"></code>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                                    <button type="button" class="btn btn-info" onclick="previewInsert()">
                                        <i class="bi bi-eye"></i> Önizle
                                    </button>
                                    <button type="button" class="btn btn-warning" onclick="copyInsertSQL()">
                                        <i class="bi bi-clipboard"></i> SQL'i Kopyala
                                    </button>
                                    <button type="button" class="btn btn-success" onclick="executeInsert()">
                                        <i class="bi bi-save"></i> Kaydet
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Sorgu Kaydetme Modal -->
                <div class="modal fade" id="saveQueryModal" tabindex="-1">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">Sorgu Kaydet</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label for="saveQueryName" class="form-label">Sorgu Adı:</label>
                                    <input type="text" class="form-control" id="saveQueryName" placeholder="Sorguya bir ad verin...">
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Önizleme:</label>
                                    <div class="bg-light p-2 rounded" style="max-height: 150px; overflow-y: auto;">
                                        <code id="saveQueryPreview"></code>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                                <button type="button" class="btn btn-primary" onclick="confirmSaveQuery()">Kaydet</button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Sorgu Geçmişi Modal -->
                <div class="modal fade" id="queryHistoryModal" tabindex="-1">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">Sorgu Geçmişi</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body" style="max-height: 500px; overflow-y: auto;">
                                <div id="queryHistoryContent">
                                    <!-- Sorgu geçmişi buraya yüklenecek -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Context Menu -->
    <div id="tableContextMenu" class="dropdown-menu" style="position: absolute; z-index: 1050; display: none;">
        <a class="dropdown-item" href="javascript:void(0)" onclick="contextSelectTable()">
            <i class="bi bi-eye"></i> Tabloyu Görüntüle
        </a>
        <a class="dropdown-item" href="javascript:void(0)" onclick="contextInsertRecord()">
            <i class="bi bi-plus-circle"></i> Yeni Kayıt Ekle
        </a>
        <div class="dropdown-divider"></div>
        <a class="dropdown-item" href="javascript:void(0)" onclick="generateSelectQuery()">
            <i class="bi bi-code"></i> SELECT Sorgusu Oluştur
        </a>
        <a class="dropdown-item" href="javascript:void(0)" onclick="generateInsertQuery()">
            <i class="bi bi-plus-square"></i> INSERT Şablonu Oluştur
        </a>
    </div>

    <script>
        let editor;
        
        $(document).ready(function() {
            // CodeMirror editörünü başlat
            editor = CodeMirror.fromTextArea(document.getElementById('sql_sorgu'), {
                mode: 'text/x-mssql',
                theme: 'default',
                lineNumbers: true,
                matchBrackets: true,
                indentWithTabs: true,
                smartIndent: true,
                autofocus: true,
                extraKeys: {
                    "Ctrl-Enter": executeQuery,
                    "Ctrl-Space": "autocomplete",
                    "Ctrl-S": function(cm) { 
                        saveQuery(); 
                        return false; 
                    }
                }
            });

            // Tablo arama
            $('#tableSearch').on('input', function() {
                const searchTerm = $(this).val().toLowerCase();
                $('.table-item').each(function() {
                    const tableName = $(this).text().toLowerCase();
                    $(this).toggle(tableName.includes(searchTerm));
                });
            });

            // Favori sorguları yükle
            loadFavoriteQueries();
        });

        function executeQuery() {
            const query = editor.getValue().trim();
            if (!query) {
                alert('Lütfen bir SQL sorgusu girin.');
                return;
            }
            
            // Form submit
            $('#queryForm').submit();
        }

        function formatQuery() {
            let query = editor.getValue();
            // Basit SQL formatlama
            query = query.replace(/\s+/g, ' ')
                        .replace(/SELECT/gi, 'SELECT\n    ')
                        .replace(/FROM/gi, '\nFROM')
                        .replace(/WHERE/gi, '\nWHERE')
                        .replace(/ORDER BY/gi, '\nORDER BY')
                        .replace(/GROUP BY/gi, '\nGROUP BY')
                        .replace(/HAVING/gi, '\nHAVING')
                        .replace(/JOIN/gi, '\nJOIN')
                        .replace(/LEFT JOIN/gi, '\nLEFT JOIN')
                        .replace(/RIGHT JOIN/gi, '\nRIGHT JOIN')
                        .replace(/INNER JOIN/gi, '\nINNER JOIN');
            
            editor.setValue(query);
        }

        function clearQuery() {
            if (confirm('Sorguyu temizlemek istediğinizden emin misiniz?')) {
                editor.setValue('');
                editor.focus();
            }
        }

        function loadSavedQuery(query) {
            editor.setValue(query);
            editor.focus();
        }

        function loadTableInfo(schema, tableName) {
            // Global değişkenleri güncelle
            currentTableSchema = schema;
            currentTableName = tableName;
            
            // AJAX ile tablo bilgilerini yükle
            $.post('table_info_api.cfm', {
                action: 'getTableInfo',
                schema: schema,
                tableName: tableName
            }, function(data) {
                $('#tableInfoContent').html(data);
                $('#tableInfoModal').modal('show');
            });

            // Basit SELECT sorgusu oluştur
            const query = `SELECT TOP 100 * FROM [${schema}].[${tableName}] ORDER BY 1 DESC`;
            editor.setValue(query);
        }

        // Klavye kısayolları
        $(document).keydown(function(e) {
            if (e.ctrlKey && e.keyCode === 13) { // Ctrl+Enter
                e.preventDefault();
                executeQuery();
            }
            if (e.ctrlKey && e.keyCode === 83) { // Ctrl+S
                e.preventDefault();
                saveQuery();
            }
        });

        function saveQuery() {
            const query = editor.getValue().trim();
            if (!query) {
                alert('Kaydetmek için bir SQL sorgusu girin.');
                return;
            }
            
            $('#saveQueryPreview').text(query.length > 200 ? query.substring(0, 200) + '...' : query);
            $('#saveQueryName').val('');
            $('#saveQueryModal').modal('show');
        }

        function confirmSaveQuery() {
            const queryName = $('#saveQueryName').val().trim();
            const query = editor.getValue().trim();
            
            $.post('query_history_api.cfm', {
                action: 'save_query',
                query_name: queryName,
                sql_sorgu: query
            }, function(response) {
                const result = JSON.parse(response);
                if (result.success) {
                    $('#saveQueryModal').modal('hide');
                    alert('Sorgu başarıyla kaydedildi!');
                    loadFavoriteQueries();
                } else {
                    alert('Hata: ' + result.message);
                }
            });
        }

        function showQueryHistory() {
            $.post('query_history_api.cfm', {
                action: 'get_history'
            }, function(data) {
                $('#queryHistoryContent').html(data);
                $('#queryHistoryModal').modal('show');
            });
        }

        function loadHistoryQuery(query) {
            editor.setValue(query);
            editor.focus();
            $('#queryHistoryModal').modal('hide');
        }

        function toggleFavorite(queryId) {
            $.post('query_history_api.cfm', {
                action: 'toggle_favorite',
                query_id: queryId
            }, function(response) {
                const result = JSON.parse(response);
                if (result.success) {
                    showQueryHistory(); // Refresh history
                    loadFavoriteQueries(); // Refresh favorites
                }
            });
        }

        function deleteQuery(queryId) {
            if (confirm('Bu sorguyu silmek istediğinizden emin misiniz?')) {
                $.post('query_history_api.cfm', {
                    action: 'delete_query',
                    query_id: queryId
                }, function(response) {
                    const result = JSON.parse(response);
                    if (result.success) {
                        showQueryHistory(); // Refresh history
                        loadFavoriteQueries(); // Refresh favorites
                    }
                });
            }
        }

        function loadFavoriteQueries() {
            $.post('query_history_api.cfm', {
                action: 'get_favorites'
            }, function(data) {
                $('#favoriteQueries').html(data);
            });
        }

        // Insert Modal Functions
        let currentTableSchema = '';
        let currentTableName = '';
        let tableColumns = [];

        function openInsertModal() {
            if (!currentTableSchema || !currentTableName) {
                alert('Lütfen önce bir tablo seçin.');
                return;
            }

            $('#insertTableName').text(`${currentTableSchema}.${currentTableName}`);
            
            // Tablo sütun bilgilerini al
            $.post('/AddOns/Partner/admin/table_info_api.cfm', {
                action: 'getTableColumns',
                schema: currentTableSchema,
                tableName: currentTableName
            }, function(data) {
                try {
                    tableColumns = JSON.parse(data);
                    buildInsertForm();
                    $('#tableInfoModal').modal('hide');
                    $('#insertModal').modal('show');
                } catch(e) {
                    console.error('Sütun bilgileri alınamadı:', e);
                    alert('Tablo sütun bilgileri alınamadı. Lütfen tekrar deneyin.');
                }
            });
        }

        function buildInsertForm() {
            let formHTML = '<div class="row">';
            
            tableColumns.forEach((column, index) => {
                const isRequired = column.IS_NULLABLE === 'NO' && !column.IS_IDENTITY;
                const isIdentity = column.IS_IDENTITY === 1;
                
                formHTML += `
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            ${column.COLUMN_NAME} 
                            <small class="text-muted">(${column.DATA_TYPE}${column.CHARACTER_MAXIMUM_LENGTH ? `(${column.CHARACTER_MAXIMUM_LENGTH})` : ''})</small>
                            ${isRequired ? '<span class="text-danger">*</span>' : ''}
                            ${isIdentity ? '<span class="badge bg-info">Identity</span>' : ''}
                        </label>
                        ${buildInputField(column)}
                        ${column.COLUMN_DEFAULT ? `<small class="text-muted">Varsayılan: ${column.COLUMN_DEFAULT}</small>` : ''}
                    </div>`;
            });
            
            formHTML += '</div>';
            $('#insertFormFields').html(formHTML);
            
            // Form değişikliklerini dinle
            $('#insertFormFields input, #insertFormFields select, #insertFormFields textarea').on('input change', function() {
                updateInsertSQL();
            });
            
            updateInsertSQL();
        }

        function buildInputField(column) {
            const fieldName = column.COLUMN_NAME;
            const dataType = column.DATA_TYPE.toLowerCase();
            const isIdentity = column.IS_IDENTITY === 1;
            
            if (isIdentity) {
                return `<input type="text" class="form-control" disabled value="Auto Generated" data-column="${fieldName}">`;
            }
            
            switch (dataType) {
                case 'bit':
                    return `
                        <select class="form-control" name="${fieldName}" data-column="${fieldName}">
                            <option value="">Seçin...</option>
                            <option value="1">True (1)</option>
                            <option value="0">False (0)</option>
                        </select>`;
                        
                case 'datetime':
                case 'datetime2':
                case 'date':
                    return `<input type="datetime-local" class="form-control" name="${fieldName}" data-column="${fieldName}">`;
                    
                case 'time':
                    return `<input type="time" class="form-control" name="${fieldName}" data-column="${fieldName}">`;
                    
                case 'int':
                case 'bigint':
                case 'smallint':
                case 'tinyint':
                    return `<input type="number" class="form-control" name="${fieldName}" data-column="${fieldName}">`;
                    
                case 'decimal':
                case 'numeric':
                case 'float':
                case 'real':
                case 'money':
                    return `<input type="number" step="0.01" class="form-control" name="${fieldName}" data-column="${fieldName}">`;
                    
                case 'text':
                case 'ntext':
                    return `<textarea class="form-control" rows="3" name="${fieldName}" data-column="${fieldName}"></textarea>`;
                    
                default:
                    const maxLength = column.CHARACTER_MAXIMUM_LENGTH ? `maxlength="${column.CHARACTER_MAXIMUM_LENGTH}"` : '';
                    return `<input type="text" class="form-control" name="${fieldName}" data-column="${fieldName}" ${maxLength}>`;
            }
        }

        function updateInsertSQL() {
            const columns = [];
            const values = [];
            
            $('#insertFormFields [data-column]').each(function() {
                const $field = $(this);
                const columnName = $field.data('column');
                const value = $field.val();
                
                if ($field.is(':disabled') || value === '') {
                    return; // Skip identity columns and empty values
                }
                
                columns.push(`[${columnName}]`);
                
                // Value formatting based on data type
                const column = tableColumns.find(c => c.COLUMN_NAME === columnName);
                if (column) {
                    const dataType = column.DATA_TYPE.toLowerCase();
                    
                    if (['varchar', 'nvarchar', 'char', 'nchar', 'text', 'ntext'].includes(dataType)) {
                        values.push(`'${value.replace(/'/g, "''")}'`);
                    } else if (['datetime', 'datetime2', 'date', 'time'].includes(dataType)) {
                        values.push(`'${value}'`);
                    } else if (dataType === 'bit') {
                        values.push(value);
                    } else {
                        values.push(value);
                    }
                }
            });
            
            let sql = '';
            if (columns.length > 0) {
                sql = `INSERT INTO [${currentTableSchema}].[${currentTableName}] 
(${columns.join(',\n ')}) 
VALUES 
(${values.join(',\n ')})`;
            } else {
                sql = '-- Lütfen en az bir alan doldurun';
            }
            
            $('#generatedInsertSQL').text(sql);
        }

        function previewInsert() {
            const sql = $('#generatedInsertSQL').text();
            if (sql.includes('-- Lütfen')) {
                alert('Lütfen en az bir alan doldurun.');
                return;
            }
            
            editor.setValue(sql);
            $('#insertModal').modal('hide');
        }

        function copyInsertSQL() {
            const sql = $('#generatedInsertSQL').text();
            if (sql.includes('-- Lütfen')) {
                alert('Lütfen en az bir alan doldurun.');
                return;
            }
            
            navigator.clipboard.writeText(sql).then(function() {
                alert('SQL kopyalandı!');
            }, function(err) {
                console.error('Kopyalama hatası: ', err);
                alert('SQL kopyalanamadı. Lütfen manuel olarak seçip kopyalayın.');
            });
        }

        function executeInsert() {
            const sql = $('#generatedInsertSQL').text();
            if (sql.includes('-- Lütfen')) {
                alert('Lütfen en az bir alan doldurun.');
                return;
            }
            
            if (!confirm('Bu INSERT sorgusunu çalıştırmak istediğinizden emin misiniz?')) {
                return;
            }
            
            // Form'a SQL'i set et ve submit et
            editor.setValue(sql);
            $('#insertModal').modal('hide');
            setTimeout(() => {
                executeQuery();
            }, 500);
        }

        // Context Menu Functions
        let contextMenuTableSchema = '';
        let contextMenuTableName = '';

        function showTableContextMenu(event, schema, tableName) {
            event.preventDefault();
            contextMenuTableSchema = schema;
            contextMenuTableName = tableName;
            
            const menu = $('#tableContextMenu');
            menu.css({
                display: 'block',
                left: event.pageX + 'px',
                top: event.pageY + 'px'
            });
            
            // Context menu dışına tıklanınca kapat
            $(document).one('click', function() {
                menu.hide();
            });
            
            return false;
        }

        function contextSelectTable() {
            loadTableInfo(contextMenuTableSchema, contextMenuTableName);
            $('#tableContextMenu').hide();
        }

        function contextInsertRecord() {
            currentTableSchema = contextMenuTableSchema;
            currentTableName = contextMenuTableName;
            openInsertModal();
            $('#tableContextMenu').hide();
        }

        function generateSelectQuery() {
            const query = `SELECT TOP 100 * FROM [${contextMenuTableSchema}].[${contextMenuTableName}] ORDER BY 1 DESC`;
            editor.setValue(query);
            $('#tableContextMenu').hide();
        }

        function generateInsertQuery() {
            // Sütun bilgilerini al ve INSERT şablonu oluştur
            $.post('table_info_api.cfm', {
                action: 'getTableColumns',
                schema: contextMenuTableSchema,
                tableName: contextMenuTableName
            }, function(data) {
                try {
                    const columns = JSON.parse(data);
                    const insertableColumns = columns.filter(col => col.IS_IDENTITY !== 1);
                    
                    const columnNames = insertableColumns.map(col => `[${col.COLUMN_NAME}]`).join(',\n    ');
                    const valueTemplates = insertableColumns.map(col => {
                        switch(col.DATA_TYPE.toLowerCase()) {
                            case 'varchar':
                            case 'nvarchar':
                            case 'char':
                            case 'nchar':
                            case 'text':
                            case 'ntext':
                                return `'değer_${col.COLUMN_NAME}'`;
                            case 'datetime':
                            case 'datetime2':
                            case 'date':
                                return `'2025-01-01 00:00:00'`;
                            case 'bit':
                                return '1';
                            default:
                                return `değer_${col.COLUMN_NAME}`;
                        }
                    }).join(',\n    ');
                    
                    const insertTemplate = `INSERT INTO [${contextMenuTableSchema}].[${contextMenuTableName}] 
(
    ${columnNames}
) 
VALUES 
(
    ${valueTemplates}
)`;
                    
                    editor.setValue(insertTemplate);
                } catch(e) {
                    console.error('Insert şablonu oluşturulamadı:', e);
                }
            });
            $('#tableContextMenu').hide();
        }
    </script>
</body>
</html>
