<cf_box title="slider Yönetimi">



<cfif structKeyExists(form, "submit")>
    <!-- Upload klasör yolu -->
    <cfset uploadDir = expandPath("/uploads/slider/")>
    <cfset imagePath = "">

    <!-- Klasör yoksa oluştur -->
    <cfif NOT directoryExists(uploadDir)>
        <cfdirectory action="create" directory="#uploadDir#">
    </cfif>

    <!-- Dosya yüklendiyse işleme al -->
    <cfif structKeyExists(form, "imageFile") AND len(form.imageFile)>
        <cffile action="upload"
                filefield="imageFile"
                destination="#uploadDir#"
                nameconflict="makeunique"
                result="uploadResult">

        <cfset imagePath = "/uploads/slider/#uploadResult.serverFile#">
    </cfif>

    <!-- Veritabanı kaydı -->
    <cfquery datasource="#dsn#">
        INSERT INTO erp_slider (image_url, title, description, is_active)
        VALUES (
            <cfqueryparam value="#imagePath#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#form.title#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#form.description#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#form.is_active#" cfsqltype="cf_sql_bit">
        )
    </cfquery>
    <cflocation url="#request.self#?fuseaction=#attributes.fuseaction#">
</cfif>


<!-- Silme işlemi -->
<cfif structKeyExists(url, "delete_id")>
    <cfquery datasource="#dsn#">
        DELETE FROM erp_slider WHERE id = <cfqueryparam value="#url.delete_id#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cflocation url="#request.self#?fuseaction=#attributes.fuseaction#">
</cfif>

<!-- Mevcut kayıtları getir -->
<cfquery name="qSliders" datasource="#dsn#">
    SELECT * FROM erp_slider ORDER BY created_at DESC
</cfquery>



    <div class="container mt-5">
        <h3>Slider Yönetimi</h3>
       <form method="post" enctype="multipart/form-data" class="row g-3 bg-white p-4 shadow-sm rounded mb-4">
    <div class="col-md-6">
        <div class="form-group">
        <label class="form-label">Görsel Yükle</label>
        <input type="file" name="imageFile" accept="image/*" class="form-control" required>
    </div>
    </div>
    <div class="col-md-6">
        <div class="form-group">
        <label class="form-label">Başlık</label>
        <input type="text" name="title" class="form-control" required>
        </div>
    </div>
    <div class="col-12">
        <div class="form-group">
        <label class="form-label">Açıklama</label>
        <textarea name="description" class="form-control" rows="2" required></textarea>
        </div>
    </div>
    <div class="col-md-4">
        <div class="form-group">
        <label class="form-label">Aktif Mi?</label>
        <select name="is_active" class="form-select">
            <option value="1" selected>Evet</option>
            <option value="0">Hayır</option>
        </select>
        </div>
    </div>
    <div class="col-md-8 d-flex align-items-end justify-content-end">
        <button type="submit" name="submit" class="btn btn-primary px-4">Ekle</button>
    </div>
</form>

        <h5>Mevcut Slider Kayıtları</h5>
        <cf_grid_list class="table table-striped table-hover bg-white shadow-sm">
            <thead class="table-primary">
                <tr>
                    <th>ID</th>
                    <th>Görsel</th>
                    <th>Başlık</th>
                    <th>Açıklama</th>
                    <th>Aktif</th>
                    <th>İşlem</th>
                </tr>
            </thead>
            <tbody>
                <cfoutput query="qSliders">
                    <tr>
                        <td>#id#</td>
                        <td><img src="#image_url#" width="100"></td>
                        <td>#title#</td>
                        <td>#description#</td>
                        <td><cfif is_active>✅<cfelse>❌</cfif></td>
                        <td>
                            <a href="#request.self#?fuseaction=#attributes.fuseaction#&delete_id=#id#" class="btn btn-sm btn-danger"
                                onclick="return confirm('Silmek istediğinize emin misiniz?')">Sil</a>
                        </td>
                    </tr>
                </cfoutput>
            </tbody>
        </cf_grid_list>

        
    </div>

</cf_box>