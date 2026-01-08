
<script>
    // Sabitler
    const CONFIG = {
        selectors: {
            detailHeadButton: 'detailHeadButton',
            isGiftCard: 'is_gift_card'
        },
        urls: {
            karmaProducts: 'index.cfm?fuseaction=product.emptypopup_karma_products_pbs&action=KARMA_EMIR&pid='
        },
        styles: {
            trackButtonColor: '#e303fc'
        }
    };

    // Yardımcı Fonksiyonlar
    function getParameterByName(name, url = window.location.href) {
        const escapedName = name.replace(/[\[\]]/g, '\\$&');
        const regex = new RegExp('[?&]' + escapedName + '(=([^&#]*)|&|#|$)');
        const results = regex.exec(url);
        
        if (!results) return null;
        if (!results[2]) return '';
        
        return decodeURIComponent(results[2].replace(/\+/g, ' '));
    }

    function paketlemeButonu(){
        const productId = getParameterByName('pid');
        var html=`<div style="display: flex;align-items: center;"">
            <div style="width: 34%;">&nbsp;</div>
            <div style="width: 40%;">
                <div class="form-group">                    
                    <input type="number" id="karma_emir_amount" style="font-size: 30pt !important;text-align: center;padding: 0;" placeholder="Paketleme Miktarı" />
                    <div>
                        <a class="ui-btn ui-btn-blue" type="button">Paketleme Emri Ver</a>
                    </div>
                </div>
            </div>
            <div style="width: 25%;display: flex;flex-direction: column;">
                <a onclick="pencereac(1,${productId})" class="ui-btn ui-btn-gray" type="button" style="height: auto;">Paket İçeriği</a>
                <a onclick="pencereac(2,${productId})" class="ui-btn ui-btn-green" type="button" style="height: auto;margin-top: 2px;">Verilmiş Emirler</a>
                </div>
                </div>`
              var ii= document.getElementById("item-product_code_2").parentElement
                ii.innerHTML+=html
    }

    function createPackageProductHTML(isChecked) {
        const checkedAttr = isChecked ? ' checked' : '';
        return `
            <div class="form-group" id="item-pbs_karma">
                <label class="col col-4 col-md-4 col-sm-4 col-xs-12">Paket Ürünü</label>
                <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                    <input type="checkbox" name="is_package_product" id="is_package_product" value="1"${checkedAttr}>
                    Evet/Hayır
                </div>
            </div>
        `;
    }

    function addTrackingButton(productId) {
        const detailButtons = document.getElementsByClassName(CONFIG.selectors.detailHeadButton);
        
        if (!detailButtons.length || !detailButtons[0].children) {
            console.warn('Detail button container not found');
            return;
        }

        const buttonHTML = `
            <li class='dropdown' id='transformation'>
                <a style='color:${CONFIG.styles.trackButtonColor}' 
                   title='Takip' 
                   onclick='pencereac(1,${productId})'>
                    <i class='icon-bell'></i>
                </a>
            </li>
        `;
        
        $(detailButtons[0].children).append(buttonHTML);
    }

    function addPackageProductToggle() {
        const productId = getParameterByName('pid');
        
        if (!productId) {
            console.warn('Product ID not found');
            return;
        }

        try {
            const query = `SELECT IS_PACKAGE_PRODUCT FROM PRODUCT WHERE PRODUCT_ID=${productId}`;
            const productInfo = wrk_query(query, "DSN1", 1);
            console.log('Product Info:', productInfo);
            
            if (!productInfo || !productInfo.IS_PACKAGE_PRODUCT) {
                console.warn('Product info not available');
                return;
            }
            paketlemeButonu();
            const giftCardElement = document.getElementById(CONFIG.selectors.isGiftCard);
            
            if (!giftCardElement) {
                console.warn('Gift card element not found');
                return;
            }

            // 3 seviye yukarı çık (güvenli şekilde)
            let container = giftCardElement.parentElement;
            for (let i = 0; i < 2 && container; i++) {
                container = container.parentElement;
            }

            if (!container) {
                console.warn('Container element not found');
                return;
            }

            const isPackage = productInfo.IS_PACKAGE_PRODUCT[0] === '1';
            container.innerHTML += createPackageProductHTML(isPackage);
            
        } catch (error) {
            console.error('Error adding package product toggle:', error);
        }
    }

    function pencereac(tip, idd) {
        if (tip === 1) {
            windowopen(CONFIG.urls.karmaProducts + idd, 'wide');
        }
    }

    // Sayfa yüklendiğinde çalıştır
    $(document).on('ready', function() {
        const productId = getParameterByName('pid');
        
        if (productId) {
            addTrackingButton(productId);
            addPackageProductToggle();
        }
    });
</script>

<script>

    function wrk_query(str_query, data_source, maxrows) {
        /* 
        By Workcube
        Created 20060315
        Modified 20060324
        Modernized for better maintainability
        
        Usage:
            my_query = wrk_query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1');
            my_query = wrk_query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1', 'dsn2');
            my_query = wrk_query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1', 'dsn2', 1);
        
        Params:
            data_source: optional, default 'dsn'
            maxrows: optional, default 0 (0 = tüm kayıtlar)
        */

        const dataSource = data_source || 'dsn';
        const maxRows = maxrows || 0;
        let queryResult = {};

        function createXHR() {
            if (window.XMLHttpRequest) {
                try {
                    return new XMLHttpRequest();
                } catch (e) {
                    return null;
                }
            } else if (window.ActiveXObject) {
                try {
                    return new ActiveXObject('Msxml2.XMLHTTP');
                } catch (e) {
                    try {
                        return new ActiveXObject('Microsoft.XMLHTTP');
                    } catch (innerError) {
                        return null;
                    }
                }
            }
            return null;
        }

        function executeQuery(url) {
            const req = createXHR();
            
            if (!req) {
                console.error('XMLHttpRequest not supported');
                return;
            }

            req.open('post', url + '&xmlhttp=1', false);
            req.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setRequestHeader('pragma', 'nocache');

            const encodedQuery = encodeURI(str_query).indexOf('+') === -1
                ? encodeURI(str_query)
                : encodeURIComponent(str_query);

            const payload = `str_sql=${encodedQuery}&data_source=${dataSource}&maxrows=${maxRows}`;

            try {
                req.send(payload);

                if (req.readyState === 4 && req.status === 200) {
                    try {
                        // Remove zero-width spaces and evaluate response
                        eval(req.responseText.replace(/\u200B/g, ''));
                        queryResult = get_js_query;
                    } catch (e) {
                        console.error('Error parsing query response:', e);
                        queryResult = false;
                    }
                }
            } catch (error) {
                console.error('Error executing query:', error);
            }
        }

        // TolgaS 20070124: objects yetkisi olmayan partnerlar var diye fuseaction objects2 yapildi
        executeQuery('/index.cfm?fuseaction=objects2.emptypopup_get_js_query&isAjax=1');

        return queryResult;
    }
	</script>
