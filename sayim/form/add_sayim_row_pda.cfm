<div class="form-group">
    <input type="text" class="form-control" id="rafNo" placeholder="Raf No" onkeyup="CheckRaf(this,event)">
</div>
<div style="display:none" id="barcodeSection">
<div class="form-group" style="margin-top: 24px; margin-left: 10px;">
			<select name="BarcodeParser" id="BarcodeParser">
				<option value="0">Barkod Parser</option>

			</select>
		</div>

<div class="form-group">
    <input type="text" class="form-control" id="barcode" placeholder="Barkod" onkeyup="checkBarcode(event,this)">
</div>
</div>
<cfform id="sayimForm" method="post" action="add_sayim_row_action_pda.cfm">
    <input type="hidden" name="sayimID" value="#sayimID#">        
<div id="activeShelf">
<span id="activeShelfLabel" class="badge badge-info">Raf Okutunuz</span>
<span id="rowCountLabel" class="badge badge-info">0</span>
<input type="hidden" name="activeShelfID" id="activeShelfID" value="">
<input type="hidden" name="activeShelfCode" id="activeShelfCode" value="">
<input type="hidden" name="rowCount" id="rowCount" value="0">
<style>
	:root {
		--sayim-bg-start: #0f172a;
		--sayim-bg-end: #1e293b;
		--sayim-card-bg: #ffffff;
		--sayim-border: rgba(148, 163, 184, 0.2);
		--sayim-primary: #2563eb;
		--sayim-primary-soft: rgba(37, 99, 235, 0.12);
		--sayim-accent: #f97316;
		--sayim-success: #16a34a;
		--sayim-text: #0f172a;
		--sayim-muted: #64748b;
		--sayim-shadow: 0 24px 60px -24px rgba(15, 23, 42, 0.72);
		--sayim-radius-lg: 20px;
		--sayim-radius-md: 14px;
		--sayim-radius-sm: 10px;
		--sayim-transition: all 0.24s ease;
	}

	.sayim-layout {
		min-height: 100vh;
		background: linear-gradient(140deg, var(--sayim-bg-start) 0%, var(--sayim-bg-end) 100%);
		padding: 32px 16px 48px;
		display: flex;
		align-items: center;
		justify-content: center;
		box-sizing: border-box;
	}

	.sayim-card {
		width: 100%;
		max-width: 760px;
		background: var(--sayim-card-bg);
		border-radius: var(--sayim-radius-lg);
		box-shadow: var(--sayim-shadow);
		border: 1px solid var(--sayim-border);
		overflow: hidden;
		display: flex;
		flex-direction: column;
	}

	.sayim-card__header {
		padding: 32px;
		background: linear-gradient(135deg, rgba(37, 99, 235, 0.08) 0%, rgba(14, 165, 233, 0.16) 100%);
		border-bottom: 1px solid rgba(148, 163, 184, 0.18);
		display: flex;
		flex-wrap: wrap;
		align-items: flex-start;
		gap: 16px 24px;
		justify-content: space-between;
	}

	.sayim-card__eyebrow {
		font-size: 13px;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.2em;
		color: var(--sayim-muted);
		display: block;
		margin-bottom: 12px;
	}

	.sayim-card__title {
		margin: 0;
		font-size: clamp(24px, 3vw, 32px);
		font-weight: 700;
		color: var(--sayim-text);
	}

	.sayim-card__subtitle {
		margin: 12px 0 0;
		max-width: 420px;
		font-size: 15px;
		line-height: 1.6;
		color: var(--sayim-muted);
	}

	.sayim-card__metrics {
		display: flex;
		gap: 12px;
		align-items: center;
	}

	.sayim-card__body {
		padding: 32px;
		display: flex;
		flex-direction: column;
		gap: 28px;
	}

	.sayim-fields {
		display: flex;
		flex-direction: column;
		gap: 20px;
	}

	.sayim-fields__group {
		background: rgba(148, 163, 184, 0.12);
		border-radius: var(--sayim-radius-md);
		padding: 18px 20px 20px;
		border: 1px solid rgba(148, 163, 184, 0.18);
	}

	.sayim-fields__group--barcode {
		background: rgba(37, 99, 235, 0.08);
		border-color: rgba(37, 99, 235, 0.24);
	}

	.sayim-fields__barcode-grid {
		display: grid;
		gap: 16px;
	}

	.sayim-label {
		display: block;
		font-weight: 600;
		font-size: 14px;
		color: var(--sayim-text);
		margin-bottom: 8px;
	}

	.sayim-input {
		display: flex;
		flex-direction: column;
		gap: 8px;
	}

	.sayim-input--compact {
		max-width: 220px;
	}

	.sayim-control {
		width: 100%;
		border-radius: var(--sayim-radius-sm);
		border: 1px solid rgba(148, 163, 184, 0.4);
		padding: 12px 14px;
		font-size: 15px;
		line-height: 1.4;
		color: var(--sayim-text);
		transition: var(--sayim-transition);
		background: #fff;
		box-sizing: border-box;
	}

	.sayim-control:focus {
		outline: none;
		border-color: var(--sayim-primary);
		box-shadow: 0 0 0 4px var(--sayim-primary-soft);
	}

	.sayim-control::placeholder {
		color: rgba(100, 116, 139, 0.7);
	}

	.sayim-hint {
		font-size: 12px;
		color: var(--sayim-muted);
	}

	.sayim-status {
		display: flex;
		flex-wrap: wrap;
		gap: 12px 16px;
		align-items: center;
		justify-content: space-between;
		padding: 20px 24px;
		border-radius: var(--sayim-radius-md);
		border: 1px dashed rgba(37, 99, 235, 0.3);
		background: rgba(37, 99, 235, 0.06);
	}

	.sayim-status__badges {
		display: flex;
		gap: 12px;
		flex-wrap: wrap;
		align-items: center;
	}

	.status-pill {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		border-radius: 999px;
		padding: 8px 14px;
		font-weight: 600;
		font-size: 13px;
		letter-spacing: 0.01em;
		text-transform: uppercase;
		color: var(--sayim-primary);
		background: rgba(37, 99, 235, 0.12);
		border: 1px solid rgba(37, 99, 235, 0.24);
	}

	.status-pill--primary {
		background: var(--sayim-primary);
		border-color: rgba(37, 99, 235, 0.4);
		color: #fff;
		box-shadow: 0 12px 24px -18px rgba(37, 99, 235, 0.65);
	}

	.status-pill--counter {
		color: var(--sayim-text);
		background: #f8fafc;
		border-color: rgba(148, 163, 184, 0.28);
		font-size: 28px;
		font-weight: 700;
		padding: 20px 24px;
		min-width: 150px;
		justify-content: center;
		position: relative;
	}

	.status-pill--counter::before {
		content: attr(data-label);
		position: absolute;
		top: 8px;
		left: 50%;
		transform: translateX(-50%);
		font-size: 12px;
		letter-spacing: 0.12em;
		font-weight: 600;
		color: var(--sayim-muted);
		text-transform: uppercase;
	}

	.sayim-grid {
		display: flex;
		flex-direction: column;
		gap: 16px;
	}

	.sayim-grid__header {
		display: flex;
		flex-direction: column;
		gap: 6px;
	}

	.sayim-grid__title {
		margin: 0;
		font-size: 18px;
		font-weight: 700;
		color: var(--sayim-text);
	}

	.sayim-grid__subtitle {
		margin: 0;
		font-size: 13px;
		color: var(--sayim-muted);
	}

	.sayim-grid__table {
		border: 1px solid rgba(148, 163, 184, 0.24);
		border-radius: var(--sayim-radius-md);
		overflow: hidden;
	}

	.sayim-grid__table table {
		width: 100%;
		border-collapse: collapse;
		background: #fff;
	}

	.sayim-grid__table thead {
		background: rgba(37, 99, 235, 0.08);
	}

	.sayim-grid__table th {
		font-size: 13px;
		text-transform: uppercase;
		letter-spacing: 0.08em;
		padding: 14px 16px;
		text-align: left;
		color: var(--sayim-muted);
	}

	.sayim-grid__table td {
		padding: 16px;
		border-top: 1px solid rgba(148, 163, 184, 0.16);
		font-size: 14px;
		color: var(--sayim-text);
	}

	.sayim-grid__cell-shelf {
		font-weight: 700;
		color: var(--sayim-primary);
		letter-spacing: 0.03em;
	}

	.sayim-grid__table tbody tr:nth-child(even) {
		background: rgba(248, 250, 252, 0.7);
	}

	.sayim-grid__table tbody tr:hover {
		background: rgba(37, 99, 235, 0.08);
	}

	.sayim-grid__row {
		animation: sayim-row-reveal 0.28s ease;
	}

	@keyframes sayim-row-reveal {
		from {
			transform: translateY(6px);
			opacity: 0;
		}
		to {
			transform: translateY(0);
			opacity: 1;
		}
	}

	.sayim-grid__empty {
		padding: 24px;
		text-align: center;
		color: var(--sayim-muted);
		font-size: 14px;
	}

	.is-hidden {
		display: none !important;
	}

	@media (min-width: 640px) {
		.sayim-fields__barcode-grid {
			grid-template-columns: minmax(160px, 220px) 1fr;
		}
	}

	@media (max-width: 540px) {
		.sayim-card__header,
		.sayim-card__body {
			padding: 24px;
		}

		.status-pill--counter {
			min-width: auto;
			width: 100%;
		}

		.sayim-input--compact {
			max-width: none;
		}
	}
</style>

<div class="sayim-layout">
	<div class="sayim-card">
		<div class="sayim-card__header">
			<div>
				<span class="sayim-card__eyebrow">Depo Sayımı</span>
				<h1 class="sayim-card__title">Sayım Satırı Ekle</h1>
				<p class="sayim-card__subtitle">Rafı doğrulayın, ardından ürün barkodlarını okutarak satırları hızlıca oluşturun.</p>
			</div>
			<div class="sayim-card__metrics">
				<span id="rowCountLabel" class="status-pill status-pill--counter" data-label="Toplam Satır">0</span>
			</div>
		</div>
		
			<input type="hidden" name="sayimID" value="#sayimID#">
			<div class="sayim-card__body">
				<section class="sayim-fields">
					<div class="sayim-fields__group">
						<label class="sayim-label" for="rafNo">Raf Numarası</label>
						<div class="sayim-input">
							<input type="text" class="sayim-control" id="rafNo" placeholder="örn. A-01" onkeyup="CheckRaf(this,event)">
							<small class="sayim-hint">Raf etiketini okutun veya yazıp Enter&apos;a basın.</small>
						</div>
					</div>
					<div class="sayim-fields__group sayim-fields__group--barcode is-hidden" id="barcodeSection">
						<div class="sayim-fields__barcode-grid">
							<div class="sayim-input sayim-input--compact">
								<label class="sayim-label" for="BarcodeParser">Barkod Parser</label>
								<select name="BarcodeParser" id="BarcodeParser" class="sayim-control">
									<option value="0">Barkod Parser</option>

								</select>
							</div>
							<div class="sayim-input">
								<label class="sayim-label" for="barcode">Ürün Barkodu</label>
								<input type="text" class="sayim-control" id="barcode" placeholder="Barkodu okutun" onkeyup="checkBarcode(event,this)">
								<small class="sayim-hint">Her barkod için Enter tuşuna basın.</small>
							</div>
						</div>
					</div>
				</section>
				<div id="activeShelf" class="sayim-status">
					<div class="sayim-status__badges">
						<span id="activeShelfLabel" class="status-pill status-pill--primary">Raf Okutunuz</span>
					</div>
					<input type="hidden" name="activeShelfID" id="activeShelfID" value="">
					<input type="hidden" name="activeShelfCode" id="activeShelfCode" value="">
					<input type="hidden" name="rowCount" id="rowCount" value="0">
				</div>
				<section class="sayim-grid">
					<div class="sayim-grid__header">
						<h2 class="sayim-grid__title">Okutulan Ürünler</h2>
						<p class="sayim-grid__subtitle">Yeni barkodlar listede anında görüntülenir.</p>
					</div>
					<div class="sayim-grid__table">
						<cf_grid_list>
							<thead>
								<tr>
									<th>Seri No</th>
									<th>Stok Kodu</th>
									<th>Raf</th>
								</tr>
							</thead>
							<tbody id="sayimRows">
								<!-- Sayım satırları buraya eklenecek -->
							</tbody>
						</cf_grid_list>
					</div>
					<div class="sayim-grid__empty" id="sayimEmptyState">Henüz ürün okutulmadı.</div>
				</section>
			</div>
		</cfform>
	</div>
</div>
<script>
var bm = null;
var O = {};
var AllShelves = [];
var ActiveShelf = null;

function ensureEmptyStateVisibility() {
	var emptyState = document.getElementById('sayimEmptyState');
	if (!emptyState) {
		return;
	}
	var hasRows = document.getElementById('sayimRows').children.length > 0;
	emptyState.classList.toggle('is-hidden', hasRows);
}

function checkBarcode(ev, el) {
	var barcode = el.value.trim();
	if (ev.key === 'Enter' && barcode.length >= 3) {
		if (!ActiveShelf) {
			alert('Önce raf okutunuz.');
			el.value = '';
			return;
		}
		var parserValue = parseInt(document.getElementById('BarcodeParser').value, 10);
		var SerialObject = bm.parseWith(barcode, parserValue);
		console.log(SerialObject);
		if (SerialObject && SerialObject.serial_no) {
			var shelfRecord = O.SHELVES.find(function (p) {
				return p.SHELF_ID == ActiveShelf.PRODUCT_PLACE_ID;
			});
			var ix = shelfRecord ? shelfRecord.STOCKS.findIndex(function (p) {
				return p.PRODUCT_CODE_2.toLowerCase().trim() == SerialObject.product_code_2.toLowerCase().trim();
			}) : -1;
			if (ix === -1) {
				alert('Bu ürün bu rafta değil! Raf: ' + ActiveShelf.SHELF_CODE + ' Stok Kodu: ' + SerialObject.product_code_2);
				el.value = '';
				return;
			}
			var tr = document.createElement('tr');
			tr.className = 'sayim-grid__row';
			tr.innerHTML = "<td>" + SerialObject.serial_no + "</td><td>" + SerialObject.product_code_2 + "</td><td class='sayim-grid__cell-shelf'>" + $('#activeShelfCode').val() + "</td>";
			document.getElementById('sayimRows').appendChild(tr);
			el.value = '';
			var rowCount = parseInt(document.getElementById('rowCount').value, 10) + 1;
			document.getElementById('rowCount').value = rowCount;
			document.getElementById('rowCountLabel').innerText = rowCount;
			ensureEmptyStateVisibility();
		}
	}
}

function CheckRaf(el, ev) {
	var rafNo = document.getElementById('rafNo').value.trim();
	if (ev.key === 'Enter' && rafNo.length >= 2) {
		console.log(rafNo);
		ActiveShelf = AllShelves.find(function (p) {
			return p.SHELF_CODE.toLowerCase() === rafNo.toLowerCase();
		});
		console.log(ActiveShelf);
		var $label = $('#activeShelfLabel');
		if (!ActiveShelf) {
			$label.text('Raf bulunamadı').removeClass('status-pill--primary');
			$('#activeShelfID, #activeShelfCode').val('');
			$('#barcodeSection').addClass('is-hidden');
			alert('Girilen raf kodu bulunamadı. Lütfen kontrol edin.');
			return;
		}
		$('#activeShelfID').val(ActiveShelf.PRODUCT_PLACE_ID);
		$('#activeShelfCode').val(ActiveShelf.SHELF_CODE);
		$label.text('Aktif Raf: ' + ActiveShelf.SHELF_CODE).addClass('status-pill--primary');
		$('#barcodeSection').removeClass('is-hidden');
		$('#barcode').focus();
	}
}

$(document).ready(function () {
	$('#rafNo').trigger('focus');
	ensureEmptyStateVisibility();

	var sh = wrk_query("SELECT PPR.STOCK_ID,PPR.PRODUCT_PLACE_ID,S.PRODUCT_CODE_2 FROM PRODUCT_PLACE_ROWS AS PPR LEFT JOIN STOCKS AS S ON S.STOCK_ID=PPR.STOCK_ID","DSN3");

	O.recordcount = sh.recordcount;
	O.SHELVES = [];
	for (let i = 0; i < sh.recordcount; i++) {
		console.log(sh);
		var ix = O.SHELVES.findIndex(function (p) {
			return p.SHELF_ID == sh.PRODUCT_PLACE_ID[i];
		});
		var SHELF_ID = sh.PRODUCT_PLACE_ID[i];
		var STOCK_ID = sh.STOCK_ID[i];
		var PRODUCT_CODE_2 = sh.PRODUCT_CODE_2[i];
		if (ix === -1) {
			O.SHELVES.push({
				SHELF_ID: SHELF_ID,
				STOCKS: [{ STOCK_ID: STOCK_ID, PRODUCT_CODE_2: PRODUCT_CODE_2 }]
			});
		} else {
			O.SHELVES[ix].STOCKS.push({ STOCK_ID: STOCK_ID, PRODUCT_CODE_2: PRODUCT_CODE_2 });
		}
	}
	console.log(O);
	var r = wrk_query("SELECT SHELF_CODE,PRODUCT_PLACE_ID FROM PRODUCT_PLACE","DSN3");

	for (let i = 0; i < r.recordcount; i++) {
		var SHELF_CODE = r.SHELF_CODE[i];
		var PRODUCT_PLACE_ID = r.PRODUCT_PLACE_ID[i];
		AllShelves.push({ SHELF_CODE: SHELF_CODE, PRODUCT_PLACE_ID: PRODUCT_PLACE_ID });
	}
	console.log(AllShelves);
	bm = new BarcodeManager();
	var parsers = bm.listParsers();
	for (var i = 0; i < parsers.length; i++) {
		$("#BarcodeParser").append('<option value="' + parsers[i].id + '">' + parsers[i].name + '</option>');
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