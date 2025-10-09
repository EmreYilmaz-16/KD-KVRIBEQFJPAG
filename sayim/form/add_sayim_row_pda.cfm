<cfquery name="getSayimRows" datasource="#dsn3#">
    SELECT 
                        SAYIM_ROW_ID,
                        SAYIM_ID,
                        SERIAL_NUMBER,
                        IN_OUT,
                        SHELF_NUMBER,
                        PRODUCT_CODE_2
                    FROM PBS_SERIAL_SAYIM_ROW
                    WHERE SAYIM_ID = <cfqueryparam value="#attributes.sayim_id#" cfsqltype="cf_sql_integer">
                    ORDER BY SAYIM_ROW_ID DESC
</cfquery>
<!-- PDA Optimized CSS for Compact Design -->
<style>
    /* PDA-Optimized Compact Design */
    body {
        margin: 0;
        padding: 5px;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
        font-size: 14px;
        background: #f0f2f5;
    }
    
    .sayim-container {
        max-width: 100%;
        margin: 0;
        padding: 8px;
        background: #fff;
        border-radius: 6px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    }
    
    .form-section {
        background: white;
        padding: 12px;
        margin-bottom: 8px;
        border-radius: 6px;
        border: 1px solid #e1e5e9;
    }
    
    .section-title {
        font-weight: 600;
        color: #1a73e8;
        margin-bottom: 8px;
        padding-bottom: 4px;
        border-bottom: 1px solid #e1e5e9;
        font-size: 0.9rem;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    
    /* Compact Input Groups */
    .input-group {
        margin-bottom: 8px;
    }
    
    .input-group-addon {
        background: #1a73e8;
        color: white;
        border: none;
        min-width: 35px;
        font-size: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .form-control {
        font-size: 16px !important; /* Prevent zoom on iOS */
        padding: 12px;
        border: 1px solid #dadce0;
        border-radius: 4px;
        height: auto;
        min-height: 44px; /* Touch-friendly */
    }
    
    .scanner-input {
        font-family: 'Courier New', monospace;
        font-weight: bold;
        font-size: 16px !important;
        text-align: center;
        background: #f8f9fa;
    }
    
    .form-control:focus {
        border-color: #1a73e8;
        box-shadow: 0 0 0 2px rgba(26, 115, 232, 0.2);
        outline: none;
    }
    
    /* Compact Status Badges */
    .status-badges {
        display: flex;
        gap: 6px;
        margin-bottom: 8px;
        flex-wrap: wrap;
    }
    
    .status-badge {
        padding: 6px 12px;
        border-radius: 16px;
        font-weight: 500;
        font-size: 0.8rem;
        flex: 1;
        text-align: center;
        min-height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .badge-info {
        background: #e8f0fe;
        color: #1a73e8;
        border: 1px solid #1a73e8;
    }
    
    .badge-success {
        background: #e6f4ea;
        color: #137333;
        border: 1px solid #137333;
    }
    
    /* Compact Table */
    .table-container {
        background: white;
        border-radius: 4px;
        overflow: hidden;
        border: 1px solid #e1e5e9;
        max-height: 200px;
        overflow-y: auto;
        -webkit-overflow-scrolling: touch;
    }
    
    .table {
        margin: 0;
        font-size: 0.8rem;
    }
    
    .table thead th {
        background: #1a73e8;
        color: white;
        border: none;
        font-weight: 600;
        position: sticky;
        top: 0;
        z-index: 10;
        padding: 8px 4px;
        font-size: 0.75rem;
    }
    
    .table tbody td {
        padding: 6px 4px;
        border-bottom: 1px solid #e1e5e9;
        font-size: 0.75rem;
        word-break: break-all;
    }
    
    .table tbody tr:hover {
        background: #f8f9fa;
    }
    
    .table tbody tr:nth-child(even) {
        background: #fafbfc;
    }
    
    /* Compact Buttons */
    .btn {
        padding: 8px 12px;
        font-size: 0.8rem;
        border-radius: 4px;
        min-height: 36px;
        margin: 2px;
    }
    
    .btn-sm {
        padding: 6px 10px;
        font-size: 0.75rem;
        min-height: 32px;
    }
    
    /* Compact Debug Controls */
    #debugControls {
        margin-top: 8px;
        display: flex;
        gap: 4px;
        flex-wrap: wrap;
    }
    
    #debugControls .btn {
        flex: 1;
        min-width: 120px;
    }
    
    /* Loading Overlay */
    .loading-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.6);
        display: none;
        justify-content: center;
        align-items: center;
        z-index: 9999;
    }
    
    .loading-spinner {
        background: white;
        padding: 20px;
        border-radius: 8px;
        text-align: center;
        min-width: 200px;
    }
    
    /* Small text helpers */
    .form-text {
        font-size: 0.7rem;
        color: #5f6368;
        margin-top: 4px;
    }
    
    /* PDA specific optimizations */
    select.form-control {
        height: 44px;
        font-size: 16px !important;
    }
    
    /* Hide unnecessary elements on very small screens */
    @media (max-width: 320px) {
        .form-text {
            display: none;
        }
        
        .section-title {
            font-size: 0.8rem;
        }
        
        #debugControls {
            display: none;
        }
    }
    
    /* Compact mode for PDA */
    @media (max-height: 600px) {
        .sayim-container {
            padding: 4px;
        }
        
        .form-section {
            padding: 8px;
            margin-bottom: 4px;
        }
        
        .table-container {
            max-height: 150px;
        }
        
        .section-title {
            margin-bottom: 4px;
            font-size: 0.8rem;
        }
    }
    
    /* Touch-friendly interactive elements */
    input, select, button {
        -webkit-appearance: none;
        -webkit-tap-highlight-color: transparent;
    }
    
    /* High contrast for better visibility */
    .form-control.is-valid {
        border-color: #137333;
        background-color: #e6f4ea;
    }
    
    .form-control.is-invalid {
        border-color: #d93025;
        background-color: #fce8e6;
    }
    
    /* Toast notifications - more compact */
    .toast-container {
        position: fixed;
        top: 10px;
        right: 10px;
        left: 10px;
        z-index: 10000;
    }
    
    .toast {
        background: #1a73e8;
        color: white;
        padding: 8px 12px;
        margin-bottom: 4px;
        border-radius: 4px;
        font-size: 0.8rem;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
    }
    
    /* Accessibility improvements */
    .sr-only {
        position: absolute;
        width: 1px;
        height: 1px;
        padding: 0;
        margin: -1px;
        overflow: hidden;
        clip: rect(0, 0, 0, 0);
        white-space: nowrap;
        border: 0;
    }
    
    .btn-outline-primary {
        border-color: #1a73e8;
        color: #1a73e8;
    }
    
    .btn-outline-primary:hover {
        background: #1a73e8;
        color: white;
    }
    
    .btn-outline-info {
        border-color: #17a2b8;
        color: #17a2b8;
    }
    
    .btn-outline-info:hover {
        background: #17a2b8;
        color: white;
    }
    
    .btn-outline-success {
        border-color: #28a745;
        color: #28a745;
    }
    
    .btn-outline-success:hover {
        background: #28a745;
        color: white;
    }
</style>

<div class="sayim-container" role="main" aria-label="Sayım Uygulaması">
    <!-- Kompakt Raf Okuma -->
    <div class="form-section" role="region" aria-labelledby="shelf-section-title">
        <h6 class="section-title" id="shelf-section-title">📦 Raf</h6>
        <div class="input-group">
            <div class="input-group-prepend">
                <span class="input-group-text input-group-addon" aria-hidden="true">📋</span>
            </div>
            <input type="text" 
                   class="form-control scanner-input" 
                   id="rafNo" 
                   placeholder="Raf Kodu..." 
                   onkeyup="SayimManager.checkShelf(this, event)"
                   autocomplete="off"
                   aria-label="Raf Kodu">
        </div>
    </div>

    <!-- Kompakt Barkod Okuma -->
    <div id="barcodeSection" class="form-section" style="display:none" role="region">
        <h6 class="section-title">🔍 Barkod</h6>
        
        <select name="BarcodeParser" id="BarcodeParser" class="form-control" style="margin-bottom:8px;">
            <option value="0">Varsayılan Parser</option>
        </select>

        <div class="input-group">
            <div class="input-group-prepend">
                <span class="input-group-text input-group-addon" aria-hidden="true">📱</span>
            </div>
            <input type="text" 
                   class="form-control scanner-input" 
                   id="barcode" 
                   placeholder="Barkod..."
                   onkeyup="SayimManager.checkBarcode(event, this)"
                   autocomplete="off"
                   aria-label="Ürün Barkodu">
        </div>
    </div>
    <!-- Kompakt Durum -->
    <div class="form-section" role="region">
        <div class="status-badges" role="status" aria-live="polite">
            <span id="activeShelfLabel" class="status-badge badge-info">📍 Raf Okutun</span>
            <span id="rowCountLabel" class="status-badge badge-success">📊 <cfoutput>#getSayimRows.recordCount#</cfoutput></span>
        </div>
        
        <!-- Kompakt Debug -->
        <div id="debugControls">
            <button type="button" class="btn btn-sm btn-outline-success" onclick="openUserGuide()">
                📖 Kılavuz
            </button>
            <button type="button" class="btn btn-sm btn-outline-primary" onclick="window.manualInitialize()">
                🔄 Yenile
            </button>
            <button type="button" class="btn btn-sm btn-outline-info" onclick="console.log('Status:', window.checkSayimManagerReady())">
                ℹ️ Durum
            </button>
        </div>
    </div>

    <!-- Kompakt Form -->
    <cfform id="sayimForm" method="post" action="/index.cfm?fuseaction=stock.emptypopup_add_sayim_row_action_pda" role="form">
        <input type="hidden" name="sayimID" value="<cfoutput>#attributes.sayim_id#</cfoutput>">        
        <input type="hidden" name="activeShelfID" id="activeShelfID" value="">
        <input type="hidden" name="activeShelfCode" id="activeShelfCode" value="">
        <input type="hidden" name="rowCount" id="rowCount" value="<CFOUTPUT>#getSayimRows.recordCount#</CFOUTPUT>">
		<input type="hidden" name="formData" id="formData" value="">

        <!-- Kompakt Tablo -->
        <div class="form-section">
            <h6 class="section-title">📋 Sonuçlar</h6>
            <div class="table-container">
                <cf_grid_list>
                    <thead>
                        <tr>
                            <th scope="col">Seri</th>
                            <th scope="col">Stok</th>
                            <th scope="col">Raf</th>
                        </tr>
                    </thead>
                    <tbody id="sayimRows" aria-live="polite">
                        <cfif getSayimRowsgetSayimRows gt 0>
                        <cfloop query="getSayimRows">
                        <tr>
                            <td headers="serial-header"><cfoutput>#getSayimRows.SERIAL_NUMBER#</cfoutput></td>
                            <td headers="product-header"><cfoutput>#getSayimRows.PRODUCT_CODE_2#</cfoutput></td>
                            <td headers="shelf-header"><cfoutput>#getSayimRows.SHELF_NUMBER#</cfoutput></td>
                        </tr>
                        </cfloop>
                        <cfelse>
                            
                        <tr id="noDataRow">
                            <td colspan="3" class="text-center text-muted" style="padding:16px;">
                                <small><em>Henüz sayım yok</em></small>
                            </td>
                        </tr>
                        </cfif>
                    </tbody>
                </cf_grid_list>
            </div>
        </div>
        
        <!-- Kaydet Butonu -->
        <div class="form-section">
            <button type="button" class="btn btn-outline-success btn-block" onclick="kaydetSayim(this,event)">
                💾 Kaydet
            </button>
        </div>
    </cfform>
</div>

<!-- Loading Overlay -->
<div id="loadingOverlay" class="loading-overlay" role="dialog" aria-labelledby="loading-title" aria-modal="true">
    <div class="loading-spinner">
        <div class="spinner-border text-primary" role="status" aria-hidden="true">
            <span class="sr-only">Yükleniyor...</span>
        </div>
        <p id="loading-title" class="mt-2">Veriler yükleniyor...</p>
    </div>
</div>




<!-- JavaScript Modules for Better Maintainability -->
<script>
/**
 * Configuration object for the application
 */
const SayimConfig = {
    MIN_BARCODE_LENGTH: 3,
    MIN_SHELF_CODE_LENGTH: 2,
    ENTER_KEY: 'Enter',
    DATA_SOURCE: 'DSN3',
    MESSAGES: {
        PRODUCT_NOT_IN_SHELF: 'Ürün bu rafta değil!\nRaf: {shelf}\nStok: {product}',
        ENTER_SHELF_CODE: '📍 Raf Okutun',
        ACTIVE_SHELF: '📍 {shelf}',
        COUNTED_ITEMS: '📊 {count}',
        LOADING: 'Yükleniyor...',
        NO_DATA: 'Henüz sayım yok',
        SYSTEM_LOADING: 'Sistem yükleniyor...',
        BARCODE_ERROR: 'Barkod okunamadı',
        SHELF_NOT_FOUND: 'Raf bulunamadı: {shelf}',
        DUPLICATE_SERIAL: 'Bu seri zaten sayılmış',
        PRODUCT_ADDED: 'Ürün eklendi ✓'
    }
};

/**
 * Utility class for common operations
 */
class SayimUtils {
    static showLoading(show = true) {
        const overlay = document.getElementById('loadingOverlay');
        if (overlay) {
            overlay.style.display = show ? 'flex' : 'none';
        }
    }

    static showMessage(message, type = 'info') {
        // Fallback to NotificationManager if available, otherwise use alert
        if (typeof NotificationManager !== 'undefined' && NotificationManager.showToast) {
            NotificationManager.showToast(message, type);
        } else {
            console.log(`[${type.toUpperCase()}] ${message}`);
            if (type === 'error') {
                alert(message);
            }
        }
    }

    static formatMessage(template, variables) {
        return template.replace(/\{(\w+)\}/g, (match, key) => variables[key] || match);
    }

    static validateInput(value, minLength) {
        return value && value.trim().length >= minLength;
    }
}

/**
 * Data Access Layer for database operations with caching
 */
class SayimDataAccess {
    static cache = new Map();
    static cacheTimeout = 5 * 60 * 1000; // 5 minutes

    static executeQuery(query, dataSource = SayimConfig.DATA_SOURCE) {
        try {
            return wrk_query(query, dataSource);
        } catch (error) {
            console.error('Database query failed:', error);
            NotificationManager.showToast('Veritabanı hatası oluştu', 'error');
            return null;
        }
    }

    static getCacheKey(type, params = {}) {
        return `${type}_${JSON.stringify(params)}`;
    }

    static isCacheValid(cacheEntry) {
        return cacheEntry && (Date.now() - cacheEntry.timestamp) < this.cacheTimeout;
    }

    static setCache(key, data) {
        this.cache.set(key, {
            data: data,
            timestamp: Date.now()
        });
    }

    static getCache(key) {
        const cacheEntry = this.cache.get(key);
        if (this.isCacheValid(cacheEntry)) {
            return cacheEntry.data;
        }
        this.cache.delete(key);
        return null;
    }

    static async loadShelfStocks() {
        const cacheKey = this.getCacheKey('shelf_stocks');
        let cachedData = this.getCache(cacheKey);
        
        if (cachedData) {
            console.log('Using cached shelf stocks data');
            return cachedData;
        }

        const query = `
            SELECT PPR.STOCK_ID, PPR.PRODUCT_PLACE_ID, S.PRODUCT_CODE_2 
            FROM PRODUCT_PLACE_ROWS AS PPR 
            LEFT JOIN STOCKS AS S ON S.STOCK_ID = PPR.STOCK_ID
            ORDER BY PPR.PRODUCT_PLACE_ID, S.PRODUCT_CODE_2
        `;
        
        const result = this.executeQuery(query);
        if (result) {
            this.setCache(cacheKey, result);
            console.log('Shelf stocks data loaded and cached');
        }
        
        return result;
    }

    static async loadShelves() {
        const cacheKey = this.getCacheKey('shelves');
        let cachedData = this.getCache(cacheKey);
        
        if (cachedData) {
            console.log('Using cached shelves data');
            return cachedData;
        }

        const query = `SELECT SHELF_CODE, PRODUCT_PLACE_ID FROM PRODUCT_PLACE ORDER BY SHELF_CODE`;
        const result = this.executeQuery(query);
        
        if (result) {
            this.setCache(cacheKey, result);
            console.log('Shelves data loaded and cached');
        }
        
        return result;
    }

    // Synchronous versions (remove async/await)
    static loadShelfStocksSync() {
        const cacheKey = this.getCacheKey('shelf_stocks');
        let cachedData = this.getCache(cacheKey);
        
        if (cachedData) {
            console.log('Using cached shelf stocks data');
            return cachedData;
        }

        const query = `
            SELECT PPR.STOCK_ID, PPR.PRODUCT_PLACE_ID, S.PRODUCT_CODE_2 
            FROM PRODUCT_PLACE_ROWS AS PPR 
            LEFT JOIN STOCKS AS S ON S.STOCK_ID = PPR.STOCK_ID
            ORDER BY PPR.PRODUCT_PLACE_ID, S.PRODUCT_CODE_2
        `;
        
        const result = this.executeQuery(query);
        if (result) {
            this.setCache(cacheKey, result);
            console.log('Shelf stocks data loaded and cached');
        }
        
        return result;
    }

    static loadShelvesSync() {
        const cacheKey = this.getCacheKey('shelves');
        let cachedData = this.getCache(cacheKey);
        
        if (cachedData) {
            console.log('Using cached shelves data');
            return cachedData;
        }

        const query = `SELECT SHELF_CODE, PRODUCT_PLACE_ID FROM PRODUCT_PLACE ORDER BY SHELF_CODE`;
        const result = this.executeQuery(query);
        
        if (result) {
            this.setCache(cacheKey, result);
            console.log('Shelves data loaded and cached');
        }
        
        return result;
    }

    static clearCache() {
        this.cache.clear();
        console.log('Cache cleared');
    }
}

/**
 * Shelf Management Class with Performance Optimizations
 */
class ShelfManager {
    constructor() {
        this.shelves = [];
        this.shelfStocks = { SHELVES: [], recordcount: 0 };
        this.activeShelf = null;
        this.shelfLookup = new Map(); // For faster shelf lookups
        this.stockLookup = new Map(); // For faster stock lookups
    }

    async initialize() {
        SayimUtils.showLoading(true);
        try {
            // Load data in parallel for better performance
            const [shelfData, stockData] = await Promise.all([
                this.loadShelfData(),
                this.loadShelfStocks()
            ]);
            
            this.buildLookupTables();
            SayimUtils.showLoading(false);
            
            console.log(`Loaded ${this.shelves.length} shelves and ${this.shelfStocks.recordcount} stock records`);
        } catch (error) {
            console.error('Initialization failed:', error);
            NotificationManager.showToast('Sistem başlatılırken hata oluştu', 'error');
            SayimUtils.showLoading(false);
        }
    }

    // Synchronous version for better compatibility
    initializeSync() {
        return new Promise((resolve, reject) => {
            try {
                console.log('ShelfManager: Starting sync initialization...');
                
                // Load shelf data first
                const shelfResult = SayimDataAccess.loadShelvesSync();
                if (shelfResult && shelfResult.recordcount > 0) {
                    this.shelves = [];
                    for (let i = 0; i < shelfResult.recordcount; i++) {
                        this.shelves.push({
                            SHELF_CODE: shelfResult.SHELF_CODE[i],
                            PRODUCT_PLACE_ID: shelfResult.PRODUCT_PLACE_ID[i]
                        });
                    }
                    console.log(`Loaded ${this.shelves.length} shelves`);
                }
                
                // Load stock data
                const stockResult = SayimDataAccess.loadShelfStocksSync();
                if (stockResult && stockResult.recordcount > 0) {
                    this.shelfStocks.recordcount = stockResult.recordcount;
                    this.shelfStocks.SHELVES = [];

                    // Use Map for faster grouping
                    const shelfMap = new Map();

                    for (let i = 0; i < stockResult.recordcount; i++) {
                        const shelfId = stockResult.PRODUCT_PLACE_ID[i];
                        const stockId = stockResult.STOCK_ID[i];
                        const productCode = stockResult.PRODUCT_CODE_2[i];

                        if (!shelfMap.has(shelfId)) {
                            shelfMap.set(shelfId, {
                                SHELF_ID: shelfId,
                                STOCKS: []
                            });
                        }

                        shelfMap.get(shelfId).STOCKS.push({
                            STOCK_ID: stockId,
                            PRODUCT_CODE_2: productCode
                        });
                    }

                    this.shelfStocks.SHELVES = Array.from(shelfMap.values());
                    console.log(`Loaded ${this.shelfStocks.recordcount} stock records`);
                }
                
                // Build lookup tables
                this.buildLookupTables();
                console.log('ShelfManager: Lookup tables built');
                
                resolve();
                
            } catch (error) {
                console.error('ShelfManager sync initialization failed:', error);
                reject(error);
            }
        });
    }

    buildLookupTables() {
        // Build shelf lookup table for O(1) access
        this.shelfLookup.clear();
        this.shelves.forEach(shelf => {
            this.shelfLookup.set(shelf.SHELF_CODE.toLowerCase(), shelf);
        });

        // Build stock lookup table for faster product validation
        this.stockLookup.clear();
        this.shelfStocks.SHELVES.forEach(shelf => {
            const key = shelf.SHELF_ID;
            const productCodes = new Set(
                shelf.STOCKS.map(stock => stock.PRODUCT_CODE_2.toLowerCase().trim())
            );
            this.stockLookup.set(key, productCodes);
        });

        console.log('Lookup tables built for performance optimization');
    }

    async loadShelfData() {
        const result = await SayimDataAccess.loadShelves();
        if (result && result.recordcount > 0) {
            this.shelves = [];
            for (let i = 0; i < result.recordcount; i++) {
                this.shelves.push({
                    SHELF_CODE: result.SHELF_CODE[i],
                    PRODUCT_PLACE_ID: result.PRODUCT_PLACE_ID[i]
                });
            }
        }
    }

    async loadShelfStocks() {
        const result = await SayimDataAccess.loadShelfStocks();
        if (result && result.recordcount > 0) {
            this.shelfStocks.recordcount = result.recordcount;
            this.shelfStocks.SHELVES = [];

            // Use Map for faster grouping
            const shelfMap = new Map();

            for (let i = 0; i < result.recordcount; i++) {
                const shelfId = result.PRODUCT_PLACE_ID[i];
                const stockId = result.STOCK_ID[i];
                const productCode = result.PRODUCT_CODE_2[i];

                if (!shelfMap.has(shelfId)) {
                    shelfMap.set(shelfId, {
                        SHELF_ID: shelfId,
                        STOCKS: []
                    });
                }

                shelfMap.get(shelfId).STOCKS.push({
                    STOCK_ID: stockId,
                    PRODUCT_CODE_2: productCode
                });
            }

            this.shelfStocks.SHELVES = Array.from(shelfMap.values());
        }
    }

    findShelfByCode(shelfCode) {
        // Use lookup table for O(1) access instead of linear search
        return this.shelfLookup.get(shelfCode.toLowerCase());
    }

    setActiveShelf(shelf) {
        this.activeShelf = shelf;
        document.getElementById('activeShelfID').value = shelf.PRODUCT_PLACE_ID;
        document.getElementById('activeShelfCode').value = shelf.SHELF_CODE;
        
        const label = SayimUtils.formatMessage(
            SayimConfig.MESSAGES.ACTIVE_SHELF, 
            { shelf: shelf.SHELF_CODE }
        );
        document.getElementById('activeShelfLabel').textContent = label;
    }

    isProductInActiveShelf(productCode) {
        if (!this.activeShelf) return false;
        
        // Use lookup table for faster validation
        const productCodes = this.stockLookup.get(this.activeShelf.PRODUCT_PLACE_ID);
        return productCodes ? productCodes.has(productCode.toLowerCase().trim()) : false;
    }

    getShelfStats() {
        return {
            totalShelves: this.shelves.length,
            totalStockRecords: this.shelfStocks.recordcount,
            activeShelf: this.activeShelf ? this.activeShelf.SHELF_CODE : null
        };
    }
}

/**
 * Barcode Management Class
 */
class BarcodeProcessor {
    constructor() {
        this.barcodeManager = null;
    }

    async initialize() {
        try {
            this.barcodeManager = new BarcodeManager();
            await this.loadParsers();
        } catch (error) {
            console.error('Barcode manager initialization failed:', error);
        }
    }

    // Synchronous version for better compatibility
    initializeSync() {
        return new Promise((resolve, reject) => {
            try {
                console.log('BarcodeProcessor: Starting sync initialization...');
                
                this.barcodeManager = new BarcodeManager();
                console.log('BarcodeManager created');
                
                // Load parsers synchronously
                const parsers = this.barcodeManager.listParsers();
                const select = document.getElementById('BarcodeParser');
                
                if (select) {
                    parsers.forEach(parser => {
                        const option = document.createElement('option');
                        option.value = parser.id;
                        option.textContent = parser.name;
                        select.appendChild(option);
                    });
                    console.log(`Loaded ${parsers.length} barcode parsers`);
                }
                
                resolve();
                
            } catch (error) {
                console.error('BarcodeProcessor sync initialization failed:', error);
                // Don't reject here as barcode processor is not critical
                console.log('Continuing without barcode processor...');
                resolve();
            }
        });
    }

    async loadParsers() {
        if (!this.barcodeManager) return;
        
        try {
            const parsers = this.barcodeManager.listParsers();
            const select = document.getElementById('BarcodeParser');
            
            parsers.forEach(parser => {
                const option = document.createElement('option');
                option.value = parser.id;
                option.textContent = parser.name;
                select.appendChild(option);
            });
        } catch (error) {
            console.error('Failed to load barcode parsers:', error);
        }
    }

    parseBarcode(barcode, parserId) {
        if (!this.barcodeManager) return null;
        
        try {
            return this.barcodeManager.parseWith(barcode, parseInt(parserId));
        } catch (error) {
            console.error('Barcode parsing failed:', error);
            return null;
        }
    }
}
/**
 * Enhanced Error Handling and Validation
 */
class SayimValidator {
    static validateShelfCode(shelfCode) {
        const errors = [];
        
        if (!shelfCode || shelfCode.trim().length === 0) {
            errors.push('Raf kodu boş olamaz');
        } else if (shelfCode.trim().length < SayimConfig.MIN_SHELF_CODE_LENGTH) {
            errors.push(`Raf kodu en az ${SayimConfig.MIN_SHELF_CODE_LENGTH} karakter olmalıdır`);
        }
        
        return {
            isValid: errors.length === 0,
            errors: errors
        };
    }

    static validateBarcode(barcode) {
        const errors = [];
        
        if (!barcode || barcode.trim().length === 0) {
            errors.push('Barkod boş olamaz');
        } else if (barcode.trim().length < SayimConfig.MIN_BARCODE_LENGTH) {
            errors.push(`Barkod en az ${SayimConfig.MIN_BARCODE_LENGTH} karakter olmalıdır`);
        }
        
        return {
            isValid: errors.length === 0,
            errors: errors
        };
    }

    static validateActiveShelf(shelfManager) {
        if (!shelfManager.activeShelf) {
            return {
                isValid: false,
                errors: ['Önce bir raf seçmelisiniz']
            };
        }
        
        return {
            isValid: true,
            errors: []
        };
    }
}

/**
 * Enhanced Notification System
 */
class NotificationManager {
    static showToast(message, type = 'info', duration = 3000) {
        // Create toast container if it doesn't exist
        let container = document.getElementById('toast-container');
        if (!container) {
            container = document.createElement('div');
            container.id = 'toast-container';
            container.className = 'toast-container';
            container.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                z-index: 10000;
                max-width: 350px;
            `;
            document.body.appendChild(container);
        }

        // Create toast element
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.style.cssText = `
            background: ${this.getToastColor(type)};
            color: white;
            padding: 12px 20px;
            margin-bottom: 10px;
            border-radius: 6px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            animation: slideInRight 0.3s ease-out;
            cursor: pointer;
        `;
        
        const icon = this.getToastIcon(type);
        toast.innerHTML = `
            <div style="display: flex; align-items: center; gap: 10px;">
                <span style="font-size: 18px;">${icon}</span>
                <span>${message}</span>
                <span style="margin-left: auto; font-size: 16px;">×</span>
            </div>
        `;

        // Add click to close
        toast.addEventListener('click', () => this.removeToast(toast));

        container.appendChild(toast);

        // Auto remove after duration
        setTimeout(() => this.removeToast(toast), duration);
    }

    static getToastColor(type) {
        const colors = {
            'success': '#28a745',
            'error': '#dc3545',
            'warning': '#ffc107',
            'info': '#17a2b8'
        };
        return colors[type] || colors.info;
    }

    static getToastIcon(type) {
        const icons = {
            'success': '✅',
            'error': '❌',
            'warning': '⚠️',
            'info': 'ℹ️'
        };
        return icons[type] || icons.info;
    }

    static removeToast(toast) {
        if (toast && toast.parentNode) {
            toast.style.animation = 'slideOutRight 0.3s ease-in';
            setTimeout(() => {
                if (toast.parentNode) {
                    toast.parentNode.removeChild(toast);
                }
            }, 300);
        }
    }
}

// Add CSS animations for toasts
const toastStyles = document.createElement('style');
toastStyles.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
`;
document.head.appendChild(toastStyles);
/**
 * Main Counting (Sayim) Management Class
 */
class SayimManager {
    constructor() {
        this.shelfManager = new ShelfManager();
        this.barcodeProcessor = new BarcodeProcessor();
        this.rowCount = 0;
        this.isProcessing = false;
    }

    async initialize() {
        try {
            await Promise.all([
                this.shelfManager.initialize(),
                this.barcodeProcessor.initialize()
            ]);
            this.setupEventListeners();
            NotificationManager.showToast('Sistem başarıyla yüklendi', 'success');
            console.log('SayimManager initialized successfully');
        } catch (error) {
            console.error('SayimManager initialization failed:', error);
            NotificationManager.showToast('Sistem başlatılamadı', 'error');
        }
    }

    // Synchronous version for better compatibility
    initializeSync() {
        return new Promise((resolve, reject) => {
            try {
                console.log('Starting synchronous initialization...');
                
                // Initialize shelf manager first
                this.shelfManager.initializeSync()
                    .then(() => {
                        console.log('ShelfManager initialized');
                        // Initialize barcode processor
                        return this.barcodeProcessor.initializeSync();
                    })
                    .then(() => {
                        console.log('BarcodeProcessor initialized');
                        // Setup event listeners
                        this.setupEventListeners();
                        console.log('Event listeners setup complete');
                        resolve();
                    })
                    .catch((error) => {
                        console.error('Sync initialization failed:', error);
                        reject(error);
                    });
                    
            } catch (error) {
                console.error('Critical sync initialization error:', error);
                reject(error);
            }
        });
    }

    setupEventListeners() {
        // Focus on shelf input by default
        const shelfInput = document.getElementById('rafNo');
        if (shelfInput) {
            shelfInput.focus();
        }

        // Add input validation feedback
        this.addInputValidation();
    }

    addInputValidation() {
        const shelfInput = document.getElementById('rafNo');
        const barcodeInput = document.getElementById('barcode');

        if (shelfInput) {
            shelfInput.addEventListener('input', (e) => {
                this.validateShelfInput(e.target);
            });
            
            // Add a safety check for Enter key if static method fails
            shelfInput.addEventListener('keyup', (e) => {
                if (e.key === SayimConfig.ENTER_KEY && !window.sayimManagerInstance) {
                    SayimUtils.showMessage('Sistem henüz yükleniyor, lütfen bekleyin...', 'warning');
                }
            });
        }

        if (barcodeInput) {
            barcodeInput.addEventListener('input', (e) => {
                this.validateBarcodeInput(e.target);
            });
            
            // Add a safety check for Enter key if static method fails  
            barcodeInput.addEventListener('keyup', (e) => {
                if (e.key === SayimConfig.ENTER_KEY && !window.sayimManagerInstance) {
                    SayimUtils.showMessage('Sistem henüz yükleniyor, lütfen bekleyin...', 'warning');
                }
            });
        }
    }

    validateShelfInput(input) {
        const validation = SayimValidator.validateShelfCode(input.value);
        this.setInputValidationState(input, validation.isValid);
    }

    validateBarcodeInput(input) {
        const validation = SayimValidator.validateBarcode(input.value);
        this.setInputValidationState(input, validation.isValid);
    }

    setInputValidationState(input, isValid) {
        input.classList.remove('is-valid', 'is-invalid');
        if (input.value.length > 0) {
            input.classList.add(isValid ? 'is-valid' : 'is-invalid');
        }
    }

    static checkShelf(element, event) {
        if (event.key !== SayimConfig.ENTER_KEY) return;
        
        const instance = window.sayimManagerInstance;
        
        // Check if instance exists and is properly initialized
        if (!instance) {
            console.warn('SayimManager instance not yet initialized');
            NotificationManager.showToast(SayimConfig.MESSAGES.SYSTEM_LOADING, 'warning');
            return;
        }
        
        if (instance.isProcessing) return;

        const shelfCode = element.value.trim();
        const validation = SayimValidator.validateShelfCode(shelfCode);
        
        if (!validation.isValid) {
            NotificationManager.showToast(validation.errors.join(', '), 'error');
            return;
        }

        instance.isProcessing = true;
        
        try {
            const shelf = instance.shelfManager.findShelfByCode(shelfCode);
            if (!shelf) {
                const message = SayimUtils.formatMessage(
                    SayimConfig.MESSAGES.SHELF_NOT_FOUND,
                    { shelf: shelfCode }
                );
                NotificationManager.showToast(message, 'error');
                element.value = '';
                return;
            }

            instance.shelfManager.setActiveShelf(shelf);
            document.getElementById('barcodeSection').style.display = 'block';
            document.getElementById('barcode').focus();
            
            const successMessage = SayimUtils.formatMessage(
                SayimConfig.MESSAGES.ACTIVE_SHELF,
                { shelf: shelf.SHELF_CODE }
            );
            NotificationManager.showToast(successMessage, 'success', 1500);
            console.log('Active shelf set:', shelf);
        } catch (error) {
            console.error('Error in checkShelf:', error);
            NotificationManager.showToast('Raf kontrolünde hata oluştu', 'error');
        } finally {
            instance.isProcessing = false;
        }
    }

    static checkBarcode(event, element) {
        if (event.key !== SayimConfig.ENTER_KEY) return;
        
        const instance = window.sayimManagerInstance;
        
        // Check if instance exists and is properly initialized
        if (!instance) {
            console.warn('SayimManager instance not yet initialized');
            NotificationManager.showToast(SayimConfig.MESSAGES.SYSTEM_LOADING, 'warning');
            return;
        }
        
        if (instance.isProcessing) return;

        const barcode = element.value.trim();
        const validation = SayimValidator.validateBarcode(barcode);
        
        if (!validation.isValid) {
            NotificationManager.showToast(validation.errors.join(', '), 'error');
            return;
        }

        const shelfValidation = SayimValidator.validateActiveShelf(instance.shelfManager);
        if (!shelfValidation.isValid) {
            NotificationManager.showToast(shelfValidation.errors.join(', '), 'error');
            return;
        }

        instance.isProcessing = true;

        try {
            const parserId = document.getElementById('BarcodeParser').value;
            const serialObject = instance.barcodeProcessor.parseBarcode(barcode, parserId);
            
            if (!serialObject || !serialObject.serial_no) {
                NotificationManager.showToast(SayimConfig.MESSAGES.BARCODE_ERROR, 'error');
                element.value = '';
                return;
            }

            console.log('Parsed barcode:', serialObject);

            if (!instance.shelfManager.isProductInActiveShelf(serialObject.product_code_2)) {
                const message = SayimUtils.formatMessage(
                    SayimConfig.MESSAGES.PRODUCT_NOT_IN_SHELF,
                    {
                        shelf: instance.shelfManager.activeShelf.SHELF_CODE,
                        product: serialObject.product_code_2
                    }
                );
                NotificationManager.showToast(message, 'error');
                element.value = '';
                return;
            }

            // Check for duplicate entries
            if (instance.isDuplicateEntry(serialObject.serial_no)) {
                NotificationManager.showToast(SayimConfig.MESSAGES.DUPLICATE_SERIAL, 'warning');
                element.value = '';
                return;
            }

            instance.addSayimRow(serialObject);
            element.value = '';
            NotificationManager.showToast(SayimConfig.MESSAGES.PRODUCT_ADDED, 'success', 1000);
            
        } catch (error) {
            console.error('Barcode processing failed:', error);
            NotificationManager.showToast('Barkod işlenirken hata oluştu', 'error');
        } finally {
            instance.isProcessing = false;
        }
    }

    isDuplicateEntry(serialNo) {
        const rows = document.querySelectorAll('#sayimRows tr');
        for (let row of rows) {
            const firstCell = row.querySelector('td:first-child');
            if (firstCell && firstCell.textContent.trim() === serialNo) {
                return true;
            }
        }
        return false;
    }

    addSayimRow(serialObject) {
        // Remove "no data" row if exists
        const noDataRow = document.getElementById('noDataRow');
        if (noDataRow) {
            noDataRow.remove();
        }

        const tbody = document.getElementById('sayimRows');
        const row = document.createElement('tr');
        row.innerHTML = `
            <td headers="serial-header">${this.escapeHtml(serialObject.serial_no)}</td>
            <td headers="product-header">${this.escapeHtml(serialObject.product_code_2)}</td>
            <td headers="shelf-header">${this.escapeHtml(this.shelfManager.activeShelf.SHELF_CODE)}</td>
        `;
        
        tbody.appendChild(row);
        this.updateRowCount();
        
        // Add subtle animation
        row.style.backgroundColor = '#d4edda';
        setTimeout(() => {
            row.style.backgroundColor = '';
        }, 1000);

        // Announce to screen readers
        this.announceToScreenReader(`Ürün eklendi: ${serialObject.product_code_2}, Seri: ${serialObject.serial_no}`);
    }

    announceToScreenReader(message) {
        const announcement = document.createElement('div');
        announcement.setAttribute('aria-live', 'assertive');
        announcement.setAttribute('aria-atomic', 'true');
        announcement.className = 'sr-only';
        announcement.textContent = message;
        
        document.body.appendChild(announcement);
        
        // Remove after announcement
        setTimeout(() => {
            document.body.removeChild(announcement);
        }, 1000);
    }

    updateRowCount() {
        this.rowCount++;
        document.getElementById('rowCount').value = this.rowCount;
        
        const label = SayimUtils.formatMessage(
            SayimConfig.MESSAGES.COUNTED_ITEMS, 
            { count: this.rowCount }
        );
        document.getElementById('rowCountLabel').textContent = label;
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Global instance
let sayimManagerInstance = null;
let isInitializing = false;
let initializationComplete = false;

// Simple initialization function without async/await
function initializeSayimManager() {
    if (isInitializing || initializationComplete) {
        return;
    }
    
    isInitializing = true;
    console.log('Starting SayimManager initialization...');
    
    try {
        // Show loading immediately
        SayimUtils.showLoading(true);
        
        // Create instance
        sayimManagerInstance = new SayimManager();
        window.sayimManagerInstance = sayimManagerInstance;
        
        console.log('SayimManager instance created');
        
        // Initialize without async/await - use traditional callbacks
        sayimManagerInstance.initializeSync()
            .then(() => {
                initializationComplete = true;
                isInitializing = false;
                SayimUtils.showLoading(false);
                console.log('Application initialized successfully');
                NotificationManager.showToast('Sistem başarıyla yüklendi', 'success');
            })
            .catch((error) => {
                console.error('Failed to initialize application:', error);
                isInitializing = false;
                SayimUtils.showLoading(false);
                NotificationManager.showToast('Uygulama başlatılamadı: ' + error.message, 'error');
            });
            
    } catch (error) {
        console.error('Critical initialization error:', error);
        isInitializing = false;
        SayimUtils.showLoading(false);
        alert('Kritik hata: ' + error.message);
    }
}

// Multiple initialization triggers
if (typeof jQuery !== 'undefined') {
    $(document).ready(initializeSayimManager);
} else {
    // Fallback without jQuery
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initializeSayimManager);
    } else {
        initializeSayimManager();
    }
}

// Additional fallback with timeout
setTimeout(() => {
    if (!initializationComplete && !isInitializing) {
        console.log('Fallback initialization triggered');
        initializeSayimManager();
    }
}, 1000);

// Add a manual initialization function
window.manualInitialize = function() {
    initializationComplete = false;
    isInitializing = false;
    initializeSayimManager();
};

// Add a safety check for early access
window.checkSayimManagerReady = function() {
    return initializationComplete && window.sayimManagerInstance && window.sayimManagerInstance.shelfManager && window.sayimManagerInstance.shelfManager.shelves.length > 0;
};

// User Guide Function
window.openUserGuide = function() {
    // Kullanım kılavuzunu yeni pencerede aç
    const guideWindow = window.open(
        '/AddOns/Partner/sayim/form/kullanim_klavuzu.html',
        'userGuide',
        'width=900,height=700,scrollbars=yes,resizable=yes,location=no,menubar=no,toolbar=no,status=no'
    );
    
    // Eğer popup engellenmişse, yeni sekmede aç
    if (!guideWindow) {
        window.open('/AddOns/Partner/sayim/form/kullanim_klavuzu.html', '_blank');
    }
    
    // Focus kılavuz penceresine
    if (guideWindow) {
        guideWindow.focus();
    }
};

// Kaydet fonksiyonu - kullanıcı tarafından doldurulacak
function kaydetSayim(button, event) {
	event.preventDefault();
	var sepetim=[];
var sepet=document.getElementById("sayimRows")
var sepetSatirlari=sepet.children
for(let i=0;i<sepetSatirlari.length;i++){
    var sepetSatiri=sepetSatirlari[i]
    var Serial=sepetSatiri.children[0].innerText;
    var Stok=sepetSatiri.children[1].innerText;
    var Raf=sepetSatiri.children[2].innerText;
    var ix=sepetim.findIndex(p=>p.Stok==Stok && p.Raf==Raf);
    if(ix==-1){
        sepetim.push({"Stok":Stok,"Raf":Raf,"SerialNumbers":[Serial]});        
    }else{
        //console.log(sepetim[ix])
        sepetim[ix].SerialNumbers.push(Serial)
    }
   
   // console.log(filtered)
    
}
document.getElementById("formData").value=JSON.stringify(sepetim);
$("#sayimForm").submit();
    // Bu fonksiyonu kendiniz dolduracaksınız
    console.log('Kaydet fonksiyonu çağrıldı');
}
</script>



<script>
    function wrk_query(str_query,data_source,maxrows)
{
	/*console.log(str_query);
	alert('Bu sayfada wrk_query kullanılmıştır. İlgili kontrolü ajax yapısına çeviriniz.');
	return false;
	*/
	/*
	by  Workcube
	Created 20060315
	Modified 20060324
	Usage:
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1');
		veya
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1','dsn2');
		veya
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1 ORDER BY COL2 DESC','dsn2',1);
		ifadesi ile my_query degiskeni cfquery ile donen sonucun tamamen aynisi bir javascript query degeri alir
		data_source : optional , default olarak 'dsn' kullaniliyor
		maxrows : optional , default olarak 0 ataniyor, 0 olunca query sonucundaki tum kayitlar gelir
	*/
	
	var new_query=new Object();
	var req;
	if(!data_source) data_source='dsn';
	if(!maxrows) maxrows=0;
	function callpage(url) {
		req = false;
		if(window.XMLHttpRequest)
			try
				{req = new XMLHttpRequest();}
			catch(e)
				{req = false;}
		else if(window.ActiveXObject)
			try {
				req = new ActiveXObject("Msxml2.XMLHTTP");
				}
			catch(e)
				{
				try {req = new ActiveXObject("Microsoft.XMLHTTP");}
				catch(e)
					{req = false;}
				}
		if(req)
			{
				function return_function_()
				{

				if (req.readyState == 4 && req.status == 200)
					try
						{
							eval(req.responseText.replace(/\u200B/g,''));
							new_query = get_js_query; //alert('Cevap:\n\n'+req.responseText);//
						}
					catch(e)
						{new_query = false;}
				}
			req.open("post", url+'&xmlhttp=1', false);
			req.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
			req.setRequestHeader('pragma','nocache');
			if(encodeURI(str_query).indexOf('+') == -1) // + isareti encodeURI fonksiyonundan gecmedigi icin encodeURIComponent fonksiyonunu kullaniyoruz. EY 20120125
				req.send('str_sql='+encodeURI(str_query)+'&data_source='+data_source+'&maxrows='+maxrows);
			else
				req.send('str_sql='+encodeURIComponent(str_query)+'&data_source='+data_source+'&maxrows='+maxrows);
			return_function_();
			}
		
	}
	
	//TolgaS 20070124 objects yetkisi olmayan partnerlar var diye fuseaction objects2 yapildi
	callpage('/index.cfm?fuseaction=objects2.emptypopup_get_js_query&isAjax=1');
	//alert(new_query);
	
	return new_query;
}
</script>