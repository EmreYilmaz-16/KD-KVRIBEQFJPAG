
<style>
    :root {
        --pda-bg: linear-gradient(160deg, #e6eef8 0%, #f3f6fc 100%);
        --pda-text: #1a2533;
        --pda-muted: #64748b;
        --pda-accent: #0069d9;
        --pda-card-bg: #ffffff;
        --pda-border: #d8e2f1;
        --pda-success: #0f9d58;
        --pda-alert: #d93025;
        --pda-shadow: 0 10px 25px rgba(15, 23, 42, 0.12);
    }

    * {
        box-sizing: border-box;
    }

    body {
        margin: 0;
        padding: 0;
        background: var(--pda-bg);
        font-family: "Segoe UI", Roboto, sans-serif;
        color: var(--pda-text);
    }

    .header {
        display: none;
    }

    .pda-screen {
        min-height: 100vh;
        padding: 20px 22px 28px;
        display: flex;
        flex-direction: column;
        gap: 16px;
        background: var(--pda-bg);
    }

    .pda-header {
        background: var(--pda-card-bg);
        border-radius: 16px;
        box-shadow: var(--pda-shadow);
        padding: 18px 20px;
        display: flex;
        flex-direction: column;
        gap: 6px;
        position: sticky;
        top: 0;
        z-index: 1;
    }

    .pda-title {
        font-size: 24px;
        font-weight: 700;
        letter-spacing: 0.4px;
        margin: 0;
    }

    .pda-subtitle {
        font-size: 13px;
        color: var(--pda-muted);
        margin: 0;
    }

    .action-list {
        display: grid;
        gap: 12px;
    }

    .action-card {
        display: flex;
        align-items: center;
        gap: 14px;
        padding: 14px 16px;
        background: var(--pda-card-bg);
        border-radius: 14px;
        box-shadow: var(--pda-shadow);
        border: 1px solid transparent;
        text-decoration: none;
        color: inherit;
        transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease;
    }

    .action-card:focus,
    .action-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 12px 30px rgba(15, 23, 42, 0.18);
        border-color: rgba(0, 105, 217, 0.26);
        outline: none;
    }

    .action-card:active {
        transform: translateY(0);
        box-shadow: 0 6px 16px rgba(15, 23, 42, 0.12);
    }

    .action-card .icon {
        width: 46px;
        height: 46px;
        border-radius: 12px;
        background: rgba(0, 105, 217, 0.08);
        display: grid;
        place-items: center;
        flex-shrink: 0;
    }

    .action-card .icon img {
        max-width: 28px;
        max-height: 28px;
    }

    .action-card .details {
        display: flex;
        flex-direction: column;
        gap: 6px;
        flex: 1;
    }

    .action-card .title {
        font-size: 16px;
        font-weight: 600;
        line-height: 1.2;
        color: var(--pda-text);
    }

    .badge-row {
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
    }

    .status-badge {
        display: inline-flex;
        align-items: center;
        font-size: 11px;
        font-weight: 600;
        padding: 4px 8px;
        border-radius: 999px;
        letter-spacing: 0.2px;
        text-transform: uppercase;
    }

    .status-success {
        background: rgba(15, 157, 88, 0.12);
        color: var(--pda-success);
    }

    .status-alert {
        background: rgba(217, 48, 37, 0.12);
        color: var(--pda-alert);
    }

    .status-warning {
        background: rgba(255, 193, 7, 0.12);
        color: #d68500;
    }

    .quick-hint {
        font-size: 12px;
        color: var(--pda-muted);
        margin: 0;
    }

    @media (max-width: 420px) {
        .pda-screen {
            padding: 16px 14px 24px;
        }

        .pda-title {
            font-size: 22px;
        }

        .action-card {
            padding: 12px 13px;
        }

        .action-card .title {
            font-size: 15px;
        }
    }

    @media (prefers-color-scheme: dark) {
        body {
            background: #141c2b;
            color: #e2e8f0;
        }

        .pda-screen {
            background: #141c2b;
        }

        .pda-header,
        .action-card {
            background: #1f2940;
            border-color: rgba(148, 163, 184, 0.16);
            box-shadow: 0 12px 32px rgba(5, 12, 28, 0.45);
        }

        .pda-subtitle,
        .quick-hint {
            color: #94a3b8;
        }

        .action-card .icon {
            background: rgba(148, 163, 184, 0.18);
        }
    }
</style>
<cfoutput>
<div class="pda-screen">
    <header class="pda-header">
        <h1 class="pda-title">E-PDA</h1>
        <p class="pda-subtitle">Günlük operasyon adımlarınızı hızlıca başlatın.</p>
        <p class="quick-hint">Bir işlemi seçmek için kartlara dokunun. Sık kullanılan seçenekler en üstte listelenmiştir.</p>
    </header>

    <nav class="action-list" aria-label="PDA işlemleri">
        <a class="action-card tableyazi" href="#request.self#?fuseaction=pda.list_shipping_ambar">
            <span class="icon"><img src="../../images/e-pd/up30.png" alt="Ambardan sevkiyata"></span>
            <span class="details">
                <span class="title">Ambardan Sevkiyata</span>
                <span class="badge-row">
                    <span class="status-badge status-success">Yapıldı!</span>
                    <span class="status-badge status-alert">Barkod Parçalama Yapıldı!</span>
                    <span class="status-badge status-warning">Barkod Alanı Kaldırıldı !</span>
                </span>
                
            </span>
        </a>

        <a class="action-card tableyazi" href="#request.self#?fuseaction=purchase._emptypopup_list_purchase_despatches_pbs">
            <span class="icon"><img src="../../images/e-pd/malkabul.png" alt="Mal kabul"></span>
            <span class="details">
                <span class="title">Mal Kabul</span>
                <span class="badge-row">
                    <span class="status-badge status-success">Yapıldı!</span>
                    <span class="status-badge status-alert">Barkod Parçalama Yapıldı!</span>
                </span>
            </span>
        </a>
        <a class="action-card tableyazi" href="#request.self#?fuseaction=pda.form_add_ambar_fis">
            <span class="icon"><img src="../../images/e-pd/down30.png" alt="Mal kabulden ambara"></span>
            <span class="details">
                <span class="title">Mal Kabulden Ambara</span>
                <span class="badge-row">
                    <span class="status-badge status-success">Yapıldı!</span>
                    <span class="status-badge status-alert">Barkod Parçalama Yapıldı!</span>
                    <span class="status-badge status-warning">Barkod Alanı Kaldırıldı !</span>
                </span>
            </span>
        </a>

        <a class="action-card tableyazi" href="#request.self#?fuseaction=pda.form_add_ambar_fis_2">
            <span class="icon"><img src="../../images/e-pd/exit30.png" alt="Ambardan mal kabule"></span>
            <span class="details">
                <span class="title">Ambardan Mal Kabule</span>
                <span class="badge-row">
                    <span class="status-badge status-success">Yapıldı!</span>
                    <span class="status-badge status-alert">Barkod Parçalama Yapıldı!</span>
                </span>
            </span>
        </a>

        <a class="action-card tableyazi" href="#request.self#?fuseaction=pda.list_shipping">
            <span class="icon"><img src="../../images/e-pd/tickmav30.png" alt="Sevkiyat kontrol"></span>
            <span class="details">
                <span class="title">Sevkiyat Kontrol</span>
            </span>
        </a>

        <a class="action-card tableyazi" href="#request.self#?fuseaction=pda.list_pda_print_spool">
            <span class="icon"><img src="../../images/e-pd/barcode30.png" alt="Etiket havuzu"></span>
            <span class="details">
                <span class="title">Etiket Havuzu</span>
            </span>
        </a>

        <a class="action-card tableyazi" href="#request.self#?fuseaction=pda.form_add_ambar_fis_3">
            <span class="icon"><img src="../../images/e-pd/shelf30.png" alt="Raf değiştir"></span>
            <span class="details">
                <span class="title">Raf Değiştir</span>
                <span class="badge-row">
                    <span class="status-badge status-success">Yapıldı!</span>
                    <span class="status-badge status-alert">Barkod Parçalama Yapıldı!</span>
                </span>
            </span>
        </a>

        <a class="action-card tableyazi" href="#request.self#?fuseaction=pda.form_add_ambar_fis_1">
            <span class="icon"><img src="../../images/e-pd/ticket30.png" alt="Ambar fişi"></span>
            <span class="details">
                <span class="title">Ambar Fişi</span>
                <span class="badge-row">
                    <span class="status-badge status-success">Yapıldı!</span>
                </span>
            </span>
        </a>

        <a class="action-card tableyazi" href="#request.self#?fuseaction=pda.form_shelf_query">
            <span class="icon"><img src="../../images/e-pd/pro30.png" alt="Ürün raf tanımla"></span>
            <span class="details">
                <span class="title">Ürün Raf Tanımla</span>
            </span>
        </a>

        <a class="action-card tableyazi" href="#request.self#?fuseaction=pda.form_add_stock_count_loc">
            <span class="icon"><img src="../../images/e-pd/say30.png" alt="Depo sayım belgesi"></span>
            <span class="details">
                <span class="title">Depo Sayım Belgesi</span>
            </span>
        </a>

        <a class="action-card tableyazi" href="#request.self#?fuseaction=pda.form_add_stock_count">
            <span class="icon"><img src="../../images/e-pd/say30.png" alt="Raf sayım belgesi"></span>
            <span class="details">
                <span class="title">Raf Sayım Belgesi</span>
            </span>
        </a>

        <a class="action-card tableyazi" href="#request.self#?fuseaction=pda.stock_location_partner">
            <span class="icon"><img src="../../images/e-pd/box48.png" alt="Lokasyona göre stok"></span>
            <span class="details">
                <span class="title">Lokasyona Göre Stok</span>
            </span>
        </a>

        <a class="action-card tableyazi" href="#request.self#?fuseaction=pda.form_add_stock_update">
            <span class="icon"><img src="../../images/e-pd/trolle64.png" alt="Raf düzeltme belgesi"></span>
            <span class="details">
                <span class="title">Raf Düzeltme Belgesi</span>
            </span>
        </a>
    </nav>
</div>
</cfoutput>