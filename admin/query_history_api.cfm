<cfparam name="attributes.action" default="">
<cfparam name="attributes.sql_sorgu" default="">
<cfparam name="attributes.query_name" default="">

<!--- Sorgu geçmişi tablosu oluştur (yoksa) --->
<cftry>
    <cfquery name="checkTable" datasource="#dsn#">
        SELECT COUNT(*) as table_exists 
        FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_NAME = 'SQL_QUERY_HISTORY'
    </cfquery>
    
    <cfif checkTable.table_exists eq 0>
        <cfquery name="createTable" datasource="#dsn#">
            CREATE TABLE SQL_QUERY_HISTORY (
                ID INT IDENTITY(1,1) PRIMARY KEY,
                QUERY_NAME NVARCHAR(255),
                SQL_QUERY NTEXT NOT NULL,
                CREATED_DATE DATETIME DEFAULT GETDATE(),
                EXECUTION_COUNT INT DEFAULT 1,
                LAST_EXECUTED DATETIME DEFAULT GETDATE(),
                IS_FAVORITE BIT DEFAULT 0,
                TAGS NVARCHAR(500),
                NOTES NTEXT
            )
        </cfquery>
    </cfif>
    <cfcatch>
        <!--- Tablo zaten var veya oluşturulamadı --->
    </cfcatch>
</cftry>

<cfswitch expression="#attributes.action#">
    <cfcase value="save_query">
        <cfif len(trim(attributes.sql_sorgu))>
            <!--- Aynı sorgu var mı kontrol et --->
            <cfquery name="checkQuery" datasource="#dsn#">
                SELECT ID FROM SQL_QUERY_HISTORY 
                WHERE SQL_QUERY = <cfqueryparam value="#attributes.sql_sorgu#" cfsqltype="cf_sql_longvarchar">
            </cfquery>
            
            <cfif checkQuery.recordcount gt 0>
                <!--- Mevcut sorguyu güncelle --->
                <cfquery name="updateQuery" datasource="#dsn#">
                    UPDATE SQL_QUERY_HISTORY 
                    SET EXECUTION_COUNT = EXECUTION_COUNT + 1,
                        LAST_EXECUTED = GETDATE()
                        <cfif len(trim(attributes.query_name))>
                            , QUERY_NAME = <cfqueryparam value="#attributes.query_name#" cfsqltype="cf_sql_varchar">
                        </cfif>
                    WHERE ID = <cfqueryparam value="#checkQuery.ID#" cfsqltype="cf_sql_integer">
                </cfquery>
            <cfelse>
                <!--- Yeni sorgu ekle --->
                <cfquery name="insertQuery" datasource="#dsn#">
                    INSERT INTO SQL_QUERY_HISTORY (QUERY_NAME, SQL_QUERY)
                    VALUES (
                        <cfqueryparam value="#attributes.query_name#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#attributes.sql_sorgu#" cfsqltype="cf_sql_longvarchar">
                    )
                </cfquery>
            </cfif>
            
            <cfoutput>{"success": true, "message": "Sorgu kaydedildi"}</cfoutput>
        <cfelse>
            <cfoutput>{"success": false, "message": "Sorgu boş olamaz"}</cfoutput>
        </cfif>
    </cfcase>

    <cfcase value="get_history">
        <cfquery name="getHistory" datasource="#dsn#">
            SELECT TOP 50 
                ID,
                QUERY_NAME,
                SQL_QUERY,
                CREATED_DATE,
                EXECUTION_COUNT,
                LAST_EXECUTED,
                IS_FAVORITE
            FROM SQL_QUERY_HISTORY 
            ORDER BY LAST_EXECUTED DESC
        </cfquery>
        
        <cfoutput>
            <div class="list-group">
                <cfloop query="getHistory">
                    <div class="list-group-item">
                        <div class="d-flex justify-content-between align-items-start">
                            <div class="flex-grow-1" style="cursor: pointer;" onclick="loadHistoryQuery('#JSStringFormat(SQL_QUERY)#')">
                                <h6 class="mb-1">
                                    <cfif len(trim(QUERY_NAME))>
                                        #QUERY_NAME#
                                    <cfelse>
                                        Adsız Sorgu
                                    </cfif>
                                    <cfif IS_FAVORITE>
                                        <i class="bi bi-star-fill text-warning"></i>
                                    </cfif>
                                </h6>
                                <p class="mb-1 text-muted small">
                                    #left(SQL_QUERY, 100)#<cfif len(SQL_QUERY) gt 100>...</cfif>
                                </p>
                                <small class="text-muted">
                                    Son çalıştırma: #dateFormat(LAST_EXECUTED, "dd/mm/yyyy")# #timeFormat(LAST_EXECUTED, "HH:mm")# 
                                    | #EXECUTION_COUNT# kez çalıştırıldı
                                </small>
                            </div>
                            <div class="ms-2">
                                <button class="btn btn-sm btn-outline-warning" onclick="toggleFavorite(#ID#)" title="Favorilere ekle/çıkar">
                                    <i class="bi bi-star<cfif IS_FAVORITE>-fill</cfif>"></i>
                                </button>
                                <button class="btn btn-sm btn-outline-danger" onclick="deleteQuery(#ID#)" title="Sil">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </cfloop>
                <cfif getHistory.recordcount eq 0>
                    <div class="alert alert-info">
                        <i class="bi bi-info-circle"></i> Henüz sorgu geçmişi bulunmuyor.
                    </div>
                </cfif>
            </div>
        </cfoutput>
    </cfcase>

    <cfcase value="toggle_favorite">
        <cfparam name="attributes.query_id" default="0">
        <cfquery name="toggleFav" datasource="#dsn#">
            UPDATE SQL_QUERY_HISTORY 
            SET IS_FAVORITE = CASE WHEN IS_FAVORITE = 1 THEN 0 ELSE 1 END
            WHERE ID = <cfqueryparam value="#attributes.query_id#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfoutput>{"success": true}</cfoutput>
    </cfcase>

    <cfcase value="delete_query">
        <cfparam name="attributes.query_id" default="0">
        <cfquery name="deleteQ" datasource="#dsn#">
            DELETE FROM SQL_QUERY_HISTORY 
            WHERE ID = <cfqueryparam value="#attributes.query_id#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfoutput>{"success": true}</cfoutput>
    </cfcase>

    <cfcase value="get_favorites">
        <cfquery name="getFavorites" datasource="#dsn#">
            SELECT 
                ID,
                QUERY_NAME,
                SQL_QUERY,
                EXECUTION_COUNT
            FROM SQL_QUERY_HISTORY 
            WHERE IS_FAVORITE = 1
            ORDER BY QUERY_NAME
        </cfquery>
        
        <cfoutput>
            <cfloop query="getFavorites">
                <a href="javascript:void(0)" class="list-group-item list-group-item-action py-2" 
                   onclick="loadHistoryQuery('#JSStringFormat(SQL_QUERY)#')">
                    <div class="d-flex justify-content-between">
                        <small>
                            <i class="bi bi-star-fill text-warning"></i>
                            <cfif len(trim(QUERY_NAME))>
                                #QUERY_NAME#
                            <cfelse>
                                Adsız Sorgu
                            </cfif>
                        </small>
                        <small class="text-muted">#EXECUTION_COUNT#x</small>
                    </div>
                </a>
            </cfloop>
            <cfif getFavorites.recordcount eq 0>
                <div class="alert alert-info">
                    <small><i class="bi bi-info-circle"></i> Favori sorgu bulunmuyor.</small>
                </div>
            </cfif>
        </cfoutput>
    </cfcase>
</cfswitch>
