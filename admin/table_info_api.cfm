<cfparam name="attributes.action" default="">
<cfparam name="attributes.schema" default="">
<cfparam name="attributes.tableName" default="">

<cfif attributes.action eq "getTableInfo" and len(attributes.schema) and len(attributes.tableName)>
    <!--- Tablo kolon bilgileri --->
    <cfquery name="getColumns" datasource="#dsn#">
        SELECT 
            COLUMN_NAME,
            DATA_TYPE,
            IS_NULLABLE,
            CHARACTER_MAXIMUM_LENGTH,
            NUMERIC_PRECISION,
            NUMERIC_SCALE,
            COLUMN_DEFAULT,
            ORDINAL_POSITION
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = <cfqueryparam value="#attributes.schema#" cfsqltype="cf_sql_varchar">
        AND TABLE_NAME = <cfqueryparam value="#attributes.tableName#" cfsqltype="cf_sql_varchar">
        ORDER BY ORDINAL_POSITION
    </cfquery>

    <!--- Tablo satır sayısı --->
    <cftry>
        <cfquery name="getRowCount" datasource="#dsn#">
            SELECT COUNT(*) as row_count 
            FROM [#attributes.schema#].[#attributes.tableName#]
        </cfquery>
        <cfcatch>
            <cfset getRowCount = queryNew("row_count")>
            <cfset queryAddRow(getRowCount, 1)>
            <cfset querySetCell(getRowCount, "row_count", "N/A", 1)>
        </cfcatch>
    </cftry>

    <!--- Primary Key bilgileri --->
    <cfquery name="getPrimaryKeys" datasource="#dsn#">
        SELECT 
            KCU.COLUMN_NAME
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
        INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU 
            ON TC.CONSTRAINT_NAME = KCU.CONSTRAINT_NAME
            AND TC.TABLE_SCHEMA = KCU.TABLE_SCHEMA
            AND TC.TABLE_NAME = KCU.TABLE_NAME
        WHERE TC.CONSTRAINT_TYPE = 'PRIMARY KEY'
        AND TC.TABLE_SCHEMA = <cfqueryparam value="#attributes.schema#" cfsqltype="cf_sql_varchar">
        AND TC.TABLE_NAME = <cfqueryparam value="#attributes.tableName#" cfsqltype="cf_sql_varchar">
        ORDER BY KCU.ORDINAL_POSITION
    </cfquery>

    <!--- Foreign Key bilgileri --->
    <cfquery name="getForeignKeys" datasource="#dsn#">
        SELECT 
            KCU.COLUMN_NAME,
            RC.UNIQUE_CONSTRAINT_SCHEMA AS REFERENCED_TABLE_SCHEMA,
            RC.UNIQUE_CONSTRAINT_NAME,
            KCU2.TABLE_NAME AS REFERENCED_TABLE_NAME,
            KCU2.COLUMN_NAME AS REFERENCED_COLUMN_NAME
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU
        INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC 
            ON KCU.CONSTRAINT_NAME = RC.CONSTRAINT_NAME
            AND KCU.CONSTRAINT_SCHEMA = RC.CONSTRAINT_SCHEMA
        INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU2 
            ON RC.UNIQUE_CONSTRAINT_NAME = KCU2.CONSTRAINT_NAME
            AND RC.UNIQUE_CONSTRAINT_SCHEMA = KCU2.CONSTRAINT_SCHEMA
        WHERE KCU.TABLE_SCHEMA = <cfqueryparam value="#attributes.schema#" cfsqltype="cf_sql_varchar">
        AND KCU.TABLE_NAME = <cfqueryparam value="#attributes.tableName#" cfsqltype="cf_sql_varchar">
        AND RC.CONSTRAINT_NAME IS NOT NULL
        ORDER BY KCU.ORDINAL_POSITION
    </cfquery>

    <cfoutput>
        <div class="row">
            <div class="col-md-12 mb-3">
                <h6><i class="bi bi-table"></i> #attributes.schema#.#attributes.tableName#</h6>
                <p class="text-muted">Toplam Satır: <strong>#getRowCount.row_count#</strong> | Kolon Sayısı: <strong>#getColumns.recordcount#</strong></p>
            </div>
        </div>

        <!--- Kolon Bilgileri --->
        <div class="row">
            <div class="col-md-12">
                <h6>Kolonlar</h6>
                <div style="max-height: 300px; overflow-y: auto;">
                    <table class="table table-sm table-striped">
                        <thead class="table-dark">
                            <tr>
                                <th>##</th>
                                <th>Kolon Adı</th>
                                <th>Veri Tipi</th>
                                <th>Null?</th>
                                <th>Uzunluk</th>
                                <th>Varsayılan</th>
                                <th>Özellik</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="getColumns">
                                <tr>
                                    <td>#ORDINAL_POSITION#</td>
                                    <td>
                                        <strong>#COLUMN_NAME#</strong>
                                        <!--- Primary Key kontrolü --->
                                        <cfloop query="getPrimaryKeys">
                                            <cfif getPrimaryKeys.COLUMN_NAME eq getColumns.COLUMN_NAME>
                                                <span class="badge bg-warning">PK</span>
                                            </cfif>
                                        </cfloop>
                                        <!--- Foreign Key kontrolü --->
                                        <cfloop query="getForeignKeys">
                                            <cfif getForeignKeys.COLUMN_NAME eq getColumns.COLUMN_NAME>
                                                <span class="badge bg-info">FK</span>
                                            </cfif>
                                        </cfloop>
                                    </td>
                                    <td>
                                        #DATA_TYPE#
                                        <cfif len(NUMERIC_PRECISION) and NUMERIC_PRECISION gt 0>
                                            (#NUMERIC_PRECISION#<cfif len(NUMERIC_SCALE) and NUMERIC_SCALE gt 0>,#NUMERIC_SCALE#</cfif>)
                                        <cfelseif len(CHARACTER_MAXIMUM_LENGTH) and CHARACTER_MAXIMUM_LENGTH gt 0>
                                            (#CHARACTER_MAXIMUM_LENGTH#)
                                        </cfif>
                                    </td>
                                    <td>
                                        <cfif IS_NULLABLE eq "YES">
                                            <span class="text-success">✓</span>
                                        <cfelse>
                                            <span class="text-danger">✗</span>
                                        </cfif>
                                    </td>
                                    <td>
                                        <cfif len(CHARACTER_MAXIMUM_LENGTH) and CHARACTER_MAXIMUM_LENGTH gt 0>
                                            #CHARACTER_MAXIMUM_LENGTH#
                                        <cfelseif len(NUMERIC_PRECISION) and NUMERIC_PRECISION gt 0>
                                            #NUMERIC_PRECISION#
                                        <cfelse>
                                            -
                                        </cfif>
                                    </td>
                                    <td>
                                        <cfif len(COLUMN_DEFAULT)>
                                            <code>#COLUMN_DEFAULT#</code>
                                        <cfelse>
                                            -
                                        </cfif>
                                    </td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-primary" 
                                                onclick="addColumnToQuery('#COLUMN_NAME#')" 
                                                title="Sorguya ekle">
                                            <i class="bi bi-plus"></i>
                                        </button>
                                    </td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!--- Hazır Sorgular --->
        <div class="row mt-3">
            <div class="col-md-12">
                <h6>Hazır Sorgular</h6>
                <div class="btn-group-vertical d-grid gap-2">
                    <button class="btn btn-outline-secondary btn-sm text-start" 
                            onclick="loadTableQuery('SELECT TOP 100 * FROM [#attributes.schema#].[#attributes.tableName#] ORDER BY 1 DESC')">
                        <i class="bi bi-list"></i> Son 100 kayıt
                    </button>
                    <button class="btn btn-outline-secondary btn-sm text-start" 
                            onclick="loadTableQuery('SELECT COUNT(*) as toplam_kayit FROM [#attributes.schema#].[#attributes.tableName#]')">
                        <i class="bi bi-calculator"></i> Toplam kayıt sayısı
                    </button>
                    <cfif getPrimaryKeys.recordcount gt 0>
                        <cfset pkColumns = "">
                        <cfloop query="getPrimaryKeys">
                            <cfset pkColumns = listAppend(pkColumns, COLUMN_NAME)>
                        </cfloop>
                        <button class="btn btn-outline-secondary btn-sm text-start" 
                                onclick="loadTableQuery('SELECT DISTINCT #pkColumns# FROM [#attributes.schema#].[#attributes.tableName#] ORDER BY #pkColumns#')">
                            <i class="bi bi-key"></i> Benzersiz Primary Key'ler
                        </button>
                    </cfif>
                    <button class="btn btn-outline-secondary btn-sm text-start" 
                            onclick="loadTableQuery('SELECT TOP 1 * FROM [#attributes.schema#].[#attributes.tableName#]')">
                        <i class="bi bi-eye"></i> Tablo yapısı (1 kayıt)
                    </button>
                </div>
            </div>
        </div>

        <!--- Foreign Key Bilgileri --->
        <cfif getForeignKeys.recordcount gt 0>
            <div class="row mt-3">
                <div class="col-md-12">
                    <h6>Foreign Key İlişkileri</h6>
                    <table class="table table-sm">
                        <thead>
                            <tr>
                                <th>Kolon</th>
                                <th>Referans Tablo</th>
                                <th>Referans Kolon</th>
                                <th>İşlem</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="getForeignKeys">
                                <tr>
                                    <td><strong>#COLUMN_NAME#</strong></td>
                                    <td>#REFERENCED_TABLE_SCHEMA#.#REFERENCED_TABLE_NAME#</td>
                                    <td>#REFERENCED_COLUMN_NAME#</td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-info" 
                                                onclick="loadTableQuery('SELECT * FROM [#REFERENCED_TABLE_SCHEMA#].[#REFERENCED_TABLE_NAME#] WHERE #REFERENCED_COLUMN_NAME# IN (SELECT DISTINCT #COLUMN_NAME# FROM [#attributes.schema#].[#attributes.tableName#] WHERE #COLUMN_NAME# IS NOT NULL)')">
                                            <i class="bi bi-link"></i> JOIN Görüntüle
                                        </button>
                                    </td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                </div>
            </div>
        </cfif>

        <script>
            function addColumnToQuery(columnName) {
                // Mevcut sorguya kolon ekle
                const currentQuery = parent.editor.getValue();
                if (currentQuery.trim() === '') {
                    parent.editor.setValue(`SELECT ${columnName} FROM [#attributes.schema#].[#attributes.tableName#]`);
                } else {
                    // SELECT kısmına ekle
                    if (currentQuery.toLowerCase().includes('select')) {
                        const lines = currentQuery.split('\n');
                        for (let i = 0; i < lines.length; i++) {
                            if (lines[i].toLowerCase().trim().startsWith('select')) {
                                lines[i] += `, ${columnName}`;
                                break;
                            }
                        }
                        parent.editor.setValue(lines.join('\n'));
                    }
                }
                parent.editor.focus();
            }

            function loadTableQuery(query) {
                parent.editor.setValue(query);
                parent.editor.focus();
                parent.$('##tableInfoModal').modal('hide');
            }
        </script>
    </cfoutput>

<cfelse>
    <div class="alert alert-warning">
        <i class="bi bi-exclamation-triangle"></i> Geçersiz istek.
    </div>
</cfif>

<!--- Insert için sütun bilgilerini JSON olarak döndür --->
<cfif attributes.action eq "getTableColumns" and len(attributes.schema) and len(attributes.tableName)>
    <cftry>
        <cfquery name="getColumnsForInsert" datasource="#dsn#">
            SELECT 
                c.COLUMN_NAME,
                c.DATA_TYPE,
                c.CHARACTER_MAXIMUM_LENGTH,
                c.NUMERIC_PRECISION,
                c.NUMERIC_SCALE,
                c.IS_NULLABLE,
                c.COLUMN_DEFAULT,
                c.ORDINAL_POSITION,
                COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') as IS_IDENTITY
            FROM INFORMATION_SCHEMA.COLUMNS c
            WHERE c.TABLE_SCHEMA = <cfqueryparam value="#attributes.schema#" cfsqltype="cf_sql_varchar">
                AND c.TABLE_NAME = <cfqueryparam value="#attributes.tableName#" cfsqltype="cf_sql_varchar">
            ORDER BY c.ORDINAL_POSITION
        </cfquery>

        <cfset columnsArray = []>
        <cfloop query="getColumnsForInsert">
            <cfset columnInfo = {
                "COLUMN_NAME" = COLUMN_NAME,
                "DATA_TYPE" = DATA_TYPE,
                "CHARACTER_MAXIMUM_LENGTH" = CHARACTER_MAXIMUM_LENGTH,
                "NUMERIC_PRECISION" = NUMERIC_PRECISION,
                "NUMERIC_SCALE" = NUMERIC_SCALE,
                "IS_NULLABLE" = IS_NULLABLE,
                "COLUMN_DEFAULT" = COLUMN_DEFAULT,
                "ORDINAL_POSITION" = ORDINAL_POSITION,
                "IS_IDENTITY" = IS_IDENTITY
            }>
            <cfset arrayAppend(columnsArray, columnInfo)>
        </cfloop>

        <cfcontent type="application/json"><cfoutput>#serializeJSON(columnsArray)#</cfoutput>

        <cfcatch type="any">
            <cfcontent type="application/json"><cfoutput>{"error": "#cfcatch.message#"}</cfoutput>
        </cfcatch>
    </cftry>
</cfif>
