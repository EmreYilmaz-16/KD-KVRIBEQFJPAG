<!-- Custom CSS for improved styling -->
<style>
    .sayim-container {
        max-width: 800px;
        margin: 0 auto;
        padding: 20px;
        background: #f8f9fa;
        border-radius: 10px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }
    
    .form-section {
        background: white;
        padding: 20px;
        margin-bottom: 20px;
        border-radius: 8px;
        border: 1px solid #e9ecef;
    }
    
    .section-title {
        font-weight: bold;
        color: #495057;
        margin-bottom: 15px;
        padding-bottom: 10px;
        border-bottom: 2px solid #007bff;
        font-size: 1.1rem;
    }
    
    .input-group-addon {
        background: #007bff;
        color: white;
        border: none;
        min-width: 45px;
        justify-content: center;
    }
    
    .status-badges {
        display: flex;
        gap: 10px;
        margin-bottom: 15px;
        flex-wrap: wrap;
    }
    
    .status-badge {
        padding: 8px 16px;
        border-radius: 20px;
        font-weight: 500;
        display: inline-block;
        font-size: 0.9rem;
    }
    
    .badge-info {
        background: #17a2b8;
        color: white;
    }
    
    .badge-success {
        background: #28a745;
        color: white;
    }
    
    .scanner-input {
        font-family: 'Courier New', monospace;
        font-weight: bold;
        font-size: 1.1rem;
    }
    
    .form-control:focus {
        border-color: #007bff;
        box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
    }
    
    .form-control.is-valid {
        border-color: #28a745;
    }
    
    .form-control.is-invalid {
        border-color: #dc3545;
    }
    
    .table-container {
        background: white;
        border-radius: 8px;
        overflow: hidden;
        border: 1px solid #e9ecef;
        max-height: 400px;
        overflow-y: auto;
    }
    
    .table thead th {
        background: #007bff;
        color: white;
        border: none;
        font-weight: 600;
        position: sticky;
        top: 0;
        z-index: 10;
    }
    
    .table tbody tr:hover {
        background: #f8f9fa;
    }
    
    .table tbody tr:nth-child(even) {
        background: #f8f9fa;
    }
    
    .loading-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
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
    
    /* Focus improvements for accessibility */
    input:focus, select:focus {
        outline: 2px solid #007bff;
        outline-offset: 2px;
    }
    
    /* High contrast support */
    @media (prefers-contrast: high) {
        .form-section {
            border: 2px solid #000;
        }
        
        .section-title {
            border-bottom-color: #000;
        }
    }
    
    /* Reduced motion support */
    @media (prefers-reduced-motion: reduce) {
        .loading-spinner .spinner-border {
            animation: none;
        }
        
        .toast {
            animation: none !important;
        }
    }
    
    /* Mobile-first responsive design */
    @media (max-width: 576px) {
        .sayim-container {
            margin: 5px;
            padding: 10px;
        }
        
        .form-section {
            padding: 15px;
        }
        
        .section-title {
            font-size: 1rem;
        }
        
        .status-badges {
            flex-direction: column;
        }
        
        .status-badge {
            text-align: center;
            font-size: 0.8rem;
        }
        
        .scanner-input {
            font-size: 1rem;
        }
        
        .table-container {
            font-size: 0.85rem;
        }
        
        .input-group-addon {
            min-width: 40px;
        }
    }
    
    @media (max-width: 768px) {
        .sayim-container {
            margin: 10px;
            padding: 15px;
        }
        
        .table-container {
            max-height: 300px;
        }
        
        .form-text {
            font-size: 0.8rem;
        }
    }
    
    @media (min-width: 992px) {
        .sayim-container {
            max-width: 900px;
        }
        
        .table-container {
            max-height: 500px;
        }
    }
    
    /* Print styles */
    @media print {
        .sayim-container {
            box-shadow: none;
            background: white;
        }
        
        .form-section {
            border: 1px solid #000;
            break-inside: avoid;
        }
        
        .loading-overlay,
        .toast-container {
            display: none !important;
        }
    }
    
    /* Dark mode support */
    @media (prefers-color-scheme: dark) {
        .sayim-container {
            background: #2d3748;
            color: #e2e8f0;
        }
        
        .form-section {
            background: #4a5568;
            border-color: #6b7280;
        }
        
        .form-control {
            background: #374151;
            border-color: #6b7280;
            color: #e2e8f0;
        }
        
        .form-control:focus {
            background: #374151;
            border-color: #3b82f6;
            color: #e2e8f0;
        }
        
        .table-container {
            background: #374151;
        }
        
        .table tbody tr:hover {
            background: #4b5563;
        }
        
        .table tbody tr:nth-child(even) {
            background: #374151;
        }
    }
</style>

<div class="sayim-container" role="main" aria-label="Sayım Uygulaması">
    <!-- Raf Okuma Bölümü -->
    <div class="form-section" role="region" aria-labelledby="shelf-section-title">
        <h5 class="section-title" id="shelf-section-title">📦 Raf Okuma</h5>
        <div class="form-group">
            <label for="rafNo" class="sr-only">Raf Kodu</label>
            <div class="input-group">
                <div class="input-group-prepend">
                    <span class="input-group-text input-group-addon" aria-hidden="true">📋</span>
                </div>
                <input type="text" 
                       class="form-control scanner-input" 
                       id="rafNo" 
                       placeholder="Raf Kodunu Okutun veya Yazın..." 
                       onkeyup="SayimManager.checkShelf(this, event)"
                       autocomplete="off"
                       aria-describedby="shelf-help"
                       aria-required="true">
            </div>
            <small id="shelf-help" class="form-text text-muted">Raf kodunu okutun ve Enter'a basın</small>
        </div>
    </div>

    <!-- Barkod Okuma Bölümü -->
    <div id="barcodeSection" class="form-section" style="display:none" role="region" aria-labelledby="barcode-section-title">
        <h5 class="section-title" id="barcode-section-title">🔍 Barkod Okuma</h5>
        
        <div class="form-group">
            <label for="BarcodeParser">Barkod Parser Seçimi:</label>
            <select name="BarcodeParser" 
                    id="BarcodeParser" 
                    class="form-control"
                    aria-describedby="parser-help">
                <option value="0">Varsayılan Parser</option>
            </select>
            <small id="parser-help" class="form-text text-muted">Kullanılacak barkod parser'ını seçin</small>
        </div>

        <div class="form-group">
            <label for="barcode" class="sr-only">Ürün Barkodu</label>
            <div class="input-group">
                <div class="input-group-prepend">
                    <span class="input-group-text input-group-addon" aria-hidden="true">📱</span>
                </div>
                <input type="text" 
                       class="form-control scanner-input" 
                       id="barcode" 
                       placeholder="Ürün Barkodunu Okutun..."
                       onkeyup="SayimManager.checkBarcode(event, this)"
                       autocomplete="off"
                       aria-describedby="barcode-help"
                       aria-required="true">
            </div>
            <small id="barcode-help" class="form-text text-muted">Ürün barkodunu okutun ve Enter'a basın</small>
        </div>
    </div>
    <!-- Durum Bilgileri -->
    <div class="form-section" role="region" aria-labelledby="status-section-title">
        <h5 class="section-title" id="status-section-title">📊 Sayım Durumu</h5>
        <div class="status-badges" role="status" aria-live="polite">
            <span id="activeShelfLabel" class="status-badge badge-info" aria-label="Aktif raf durumu">Raf Okutunuz</span>
            <span id="rowCountLabel" class="status-badge badge-success" aria-label="Sayılan ürün adedi">Sayılan: 0</span>
        </div>
    </div>

    <!-- Sayım Formu -->
    <cfform id="sayimForm" method="post" action="add_sayim_row_action_pda.cfm" role="form" aria-label="Sayım formu">
        <input type="hidden" name="sayimID" value="#sayimID#">        
        <input type="hidden" name="activeShelfID" id="activeShelfID" value="">
        <input type="hidden" name="activeShelfCode" id="activeShelfCode" value="">
        <input type="hidden" name="rowCount" id="rowCount" value="0">

        <!-- Sayım Sonuçları Tablosu -->
        <div class="form-section" role="region" aria-labelledby="results-section-title">
            <h5 class="section-title" id="results-section-title">📋 Sayım Sonuçları</h5>
            <div class="table-container">
                <cf_grid_list>
                    <caption class="sr-only">Sayım yapılan ürünlerin listesi</caption>
                    <thead>
                        <tr>
                            <th scope="col" width="35%" id="serial-header">🏷️ Seri No</th>
                            <th scope="col" width="35%" id="product-header">📦 Stok Kodu</th>
                            <th scope="col" width="30%" id="shelf-header">📍 Raf</th>
                        </tr>
                    </thead>
                    <tbody id="sayimRows" aria-live="polite" aria-label="Sayım sonuçları">
                        <!-- Sayım satırları buraya eklenecek -->
                        <tr id="noDataRow">
                            <td colspan="3" class="text-center text-muted">
                                <em>Henüz ürün sayımı yapılmamış</em>
                            </td>
                        </tr>
                    </tbody>
                </cf_grid_list>
            </div>
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
        PRODUCT_NOT_IN_SHELF: 'Bu ürün bu rafta değil! Raf: {shelf} Stok Kodu: {product}',
        ENTER_SHELF_CODE: 'Raf Okutunuz',
        ACTIVE_SHELF: 'Aktif Raf: {shelf}',
        COUNTED_ITEMS: 'Sayılan: {count}',
        LOADING: 'Veriler yükleniyor...',
        NO_DATA: 'Henüz ürün sayımı yapılmamış'
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
        // You can implement toast notifications here
        console.log(`[${type.toUpperCase()}] ${message}`);
        if (type === 'error') {
            alert(message);
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
        }

        if (barcodeInput) {
            barcodeInput.addEventListener('input', (e) => {
                this.validateBarcodeInput(e.target);
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
                NotificationManager.showToast(`Raf bulunamadı: ${shelfCode}`, 'error');
                element.value = '';
                return;
            }

            instance.shelfManager.setActiveShelf(shelf);
            document.getElementById('barcodeSection').style.display = 'block';
            document.getElementById('barcode').focus();
            
            NotificationManager.showToast(`Raf aktif: ${shelf.SHELF_CODE}`, 'success');
            console.log('Active shelf set:', shelf);
        } finally {
            instance.isProcessing = false;
        }
    }

    static checkBarcode(event, element) {
        if (event.key !== SayimConfig.ENTER_KEY) return;
        
        const instance = window.sayimManagerInstance;
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
                NotificationManager.showToast('Barkod okunamadı veya geçersiz', 'error');
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
                NotificationManager.showToast('Bu seri numarası zaten sayılmış', 'warning');
                element.value = '';
                return;
            }

            instance.addSayimRow(serialObject);
            element.value = '';
            NotificationManager.showToast('Ürün başarıyla eklendi', 'success', 1500);
            
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

// Initialize when document is ready
$(document).ready(async function() {
    try {
        sayimManagerInstance = new SayimManager();
        window.sayimManagerInstance = sayimManagerInstance;
        await sayimManagerInstance.initialize();
    } catch (error) {
        console.error('Failed to initialize application:', error);
        SayimUtils.showMessage('Uygulama başlatılamadı', 'error');
    }
});
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