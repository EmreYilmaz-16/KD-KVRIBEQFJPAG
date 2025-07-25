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
                        <div class="table-item" onclick="loadTableInfo('#schema_name#', '#name#')" title="#column_count# kolon">
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
    </script>
</body>
</html>
