

<cf_box title="GTIP Kodu Import Sistemi">

    <meta charset="utf-8">
    <title>GTIP Kodu Import Sistemi</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        .upload-form { background: #f5f5f5; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
        .result-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .result-table th, .result-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        .result-table th { background-color: #4CAF50; color: white; }
        .error { color: red; background-color: #ffe6e6; padding: 5px; border-radius: 3px; }
        .warning { color: orange; background-color: #fff3cd; padding: 5px; border-radius: 3px; }
        .success { color: green; background-color: #d4edda; padding: 5px; border-radius: 3px; }
        .btn { background-color: #4CAF50; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }
        .btn:hover { background-color: #45a049; }
    </style>

    <div class="container">
        <h1></h1>
        
        <cfif isDefined("form.upload_file")>
            <cfset results = arrayNew(1)>
            <cfset totalProcessed = 0>
            <cfset successCount = 0>
            <cfset errorCount = 0>
            <cfset warningCount = 0>
            
            <cftry>
                <!--- Excel dosyasını okuma --->
                <cfspreadsheet action="read" src="#form.upload_file#" query="excelData" headerrow="1">
                
                <!--- Her satır için işlem yap --->
                <cfloop query="excelData">
                    <cfset totalProcessed = totalProcessed + 1>
                    <cfset currentResult = structNew()>
                    <cfset currentResult.etaKodu = trim(excelData.ETA_KODU)>
                    <cfset currentResult.gtipNumarasi = trim(excelData.GTIP_NUMARASI)>
                    
                    <!--- İsteğe bağlı sütunlar için güvenli okuma --->
                    <cftry>
                        <cfset currentResult.urunIsmiIngilizce = trim(excelData.URUN_ISMI_INGILIZCE)>
                        <cfcatch type="any">
                            <cfset currentResult.urunIsmiIngilizce = "">
                        </cfcatch>
                    </cftry>
                    
                    <cftry>
                        <cfset currentResult.urunAgirlik = trim(excelData.URUN_AGIRLIK)>
                        <cfcatch type="any">
                            <cfset currentResult.urunAgirlik = "">
                        </cfcatch>
                    </cftry>
                    
                    <cfset currentResult.status = "">
                    <cfset currentResult.message = "">
                    
                    <!--- ETA Kodu ve GTIP Numarası boş kontrolü --->
                    <cfif len(currentResult.etaKodu) eq 0 or len(currentResult.gtipNumarasi) eq 0>
                        <cfset currentResult.status = "error">
                        <cfset currentResult.message = "ETA Kodu veya GTIP Numarası boş olamaz">
                        <cfset errorCount = errorCount + 1>
                    <cfelse>
                        <!--- Ürünü veritabanında ara --->
                        <cftry>
                            <!--- Veritabanı bağlantısını tespit et --->
                           
                            
                            <cfquery name="checkProduct" datasource="#dsn1#">
                                SELECT CUSTOMS_RECIPE_CODE AS GTIP_NUMBER, PRODUCT_ID ,PRODUCT_NAME
                                FROM PRODUCT 
                                WHERE PRODUCT_CODE_2 = <cfqueryparam value="#currentResult.etaKodu#" cfsqltype="cf_sql_varchar">
                            </cfquery>
                            
                            <cfif checkProduct.recordCount eq 0>
                                <!--- Ürün bulunamadı --->
                                <cfset currentResult.status = "error">
                                <cfset currentResult.message = "Ürün bulunamadı">
                                <cfset errorCount = errorCount + 1>
                            <cfelse>
                                <!--- Ürün bulundu, GTIP numarası kontrolü --->
                                <cfif len(checkProduct.GTIP_NUMBER) gt 0 and checkProduct.GTIP_NUMBER neq currentResult.gtipNumarasi>
                                    <!--- Farklı GTIP numarası var, uyarı ver --->
                                    <cfset currentResult.status = "warning">
                                    <cfset currentResult.message = "Mevcut GTIP: #checkProduct.GTIP_NUMBER# - Yeni GTIP: #currentResult.gtipNumarasi# (Farklı GTIP numarası!)">
                                    <cfset currentResult.mevcutGtip = checkProduct.GTIP_NUMBER>
                                    <cfset warningCount = warningCount + 1>
                                <cfelse>
                                    <!--- GTIP numarasını güncelle --->
                                    <cftry>
                                        <cfquery name="updateGtip" datasource="#dsn1#">
                                            UPDATE PRODUCT 
                                            SET CUSTOMS_RECIPE_CODE = <cfqueryparam value="#currentResult.gtipNumarasi#" cfsqltype="cf_sql_varchar">
                                               
                                            WHERE PRODUCT_CODE_2 = <cfqueryparam value="#currentResult.etaKodu#" cfsqltype="cf_sql_varchar">
                                        </cfquery>

                                        <cfif len(currentResult.urunIsmiIngilizce) gt 0>
                                            <cftry>
                                                <cfquery name="getPns" datasource="#dsn#">
                                                    SELECT * FROM #dsn#.SETUP_LANGUAGE_INFO 
                                                    WHERE TABLE_NAME='PRODUCT' 
                                                    AND COLUMN_NAME='PRODUCT_NAME' 
                                                    AND UNIQUE_COLUMN_ID=#checkProduct.PRODUCT_ID# 
                                                    AND LANGUAGE='eng'
                                                </cfquery>
                                                
                                                <cfif getPns.recordCount>
                                                    <cfquery name="upd" datasource="#dsn#">
                                                        UPDATE #dsn#.SETUP_LANGUAGE_INFO 
                                                        SET ITEM = <cfqueryparam value="#currentResult.urunIsmiIngilizce#" cfsqltype="cf_sql_varchar">
                                                        WHERE TABLE_NAME='PRODUCT' AND COLUMN_NAME='PRODUCT_NAME' AND UNIQUE_COLUMN_ID=#checkProduct.PRODUCT_ID# AND LANGUAGE='eng'
                                                    </cfquery>
                                                <cfelse>
                                                    <cfquery name="ins" datasource="#dsn#">
                                                        INSERT INTO #dsn#.SETUP_LANGUAGE_INFO (TABLE_NAME, COLUMN_NAME, UNIQUE_COLUMN_ID, LANGUAGE, ITEM)
                                                        VALUES ('PRODUCT', 'PRODUCT_NAME', #checkProduct.PRODUCT_ID#, 'eng', <cfqueryparam value="#currentResult.urunIsmiIngilizce#" cfsqltype="cf_sql_varchar">)
                                                    </cfquery>
                                                    <cfquery name="insTr" datasource="#dsn#">
                                                        INSERT INTO #dsn#.SETUP_LANGUAGE_INFO (TABLE_NAME, COLUMN_NAME, UNIQUE_COLUMN_ID, LANGUAGE, ITEM)
                                                        VALUES ('PRODUCT', 'PRODUCT_NAME', #checkProduct.PRODUCT_ID#, 'tr', <cfqueryparam value="#checkProduct.PRODUCT_NAME#" cfsqltype="cf_sql_varchar">)
                                                    </cfquery>
                                                </cfif>
                                                
                                                <cfcatch type="any">
                                                    <!--- İngilizce isim güncelleme hatası, ama ana işlemi durdurmayalım --->
                                                    <cfset currentResult.message = currentResult.message & " (İngilizce isim güncellenemedi: #cfcatch.message#)">
                                                </cfcatch>
                                            </cftry>
                                        </cfif>
                                        <cfif len(currentResult.urunAgirlik) gt 0 and isNumeric(currentResult.urunAgirlik)>
                                            <cftry>
                                                <!--- Ürün birim tablosunda ağırlık kontrolü --->
                                                <cfquery name="checkWeight" datasource="#dsn1#">
                                                    SELECT WEIGHT FROM #dsn1#.PRODUCT_UNIT WHERE PRODUCT_ID=#checkProduct.PRODUCT_ID#
                                                </cfquery>
                                                
                                                <cfif checkWeight.recordCount gt 0>
                                                    <!--- Mevcut kayıt varsa güncelle --->
                                                    <cfquery name="updateWeight" datasource="#dsn1#">
                                                        UPDATE #dsn1#_product.PRODUCT_UNIT 
                                                        SET WEIGHT = #currentResult.urunAgirlik#
                                                        WHERE PRODUCT_ID = #checkProduct.PRODUCT_ID#
                                                    </cfquery>
                                                <cfelse>
                                                    <!--- Yeni kayıt ekle --->
                                                    
                                                </cfif>
                                                
                                                <cfcatch type="any">
                                                    <!--- Ağırlık güncelleme hatası, ama ana işlemi durdurmayalım --->
                                                    <cfset currentResult.message = currentResult.message & " (Ağırlık güncellenemedi: #cfcatch.message#)">
                                                </cfcatch>
                                            </cftry>
                                        </cfif>

                                        
                                        <cfset currentResult.status = "success">
                                        <cfif len(checkProduct.GTIP_NUMBER) eq 0>
                                            <cfset currentResult.message = "GTIP numarası başarıyla eklendi">
                                        <cfelse>
                                            <cfset currentResult.message = "GTIP numarası başarıyla güncellendi">
                                        </cfif>
                                        
                                        <!--- Ek alanlar için mesaj ekle --->
                                        <cfset updateDetails = "">
                                        <cfif len(currentResult.urunIsmiIngilizce) gt 0>
                                            <cfset updateDetails = updateDetails & ", İngilizce isim güncellendi">
                                        </cfif>
                                        <cfif len(currentResult.urunAgirlik) gt 0 and isNumeric(currentResult.urunAgirlik)>
                                            <cfset updateDetails = updateDetails & ", Ağırlık güncellendi">
                                        </cfif>
                                        <cfif len(updateDetails) gt 0>
                                            <cfset currentResult.message = currentResult.message & updateDetails>
                                        </cfif>
                                        
                                        <cfset successCount = successCount + 1>
                                        
                                        <cfcatch type="any">
                                            <cfdump var="#cfcatch#">
                                            <cfset currentResult.status = "error">
                                            <cfset currentResult.message = "Veritabanı güncelleme hatası: #cfcatch.message#">
                                            <cfset errorCount = errorCount + 1>
                                        </cfcatch>
                                    </cftry>
                                </cfif>
                            </cfif>
                            
                            <cfcatch type="any">

                                <cfset currentResult.status = "error">
                                <cfset currentResult.message = "Veritabanı sorgu hatası: #cfcatch.message#">
                                <cfset errorCount = errorCount + 1>
                            </cfcatch>
                        </cftry>
                    </cfif>
                    
                    <cfset arrayAppend(results, currentResult)>
                </cfloop>
                
                <cfcatch type="any">
                    <div class="error">
                        <strong>Excel dosyası okuma hatası:</strong> #cfcatch.message#<br>
                        Lütfen dosyanın Excel formatında olduğundan ve "ETA_KODU" ile "GTIP_NUMARASI" sütunlarını içerdiğinden emin olun.<br>
                        İsteğe bağlı sütunlar: "URUN_ISMI_INGILIZCE", "URUN_AGIRLIK"
                    </div>
                </cfcatch>
            </cftry>
        </cfif>
        
        <!--- Upload Formu --->
        <div class="upload-form">
            <h3>Excel Dosyası Yükle</h3>
            <p><strong>Gerekli Sütunlar:</strong> ETA_KODU, GTIP_NUMARASI</p>
            <p><strong>İsteğe Bağlı Sütunlar:</strong> URUN_ISMI_INGILIZCE, URUN_AGIRLIK</p>
            
            <cfform action="#request.self#?fuseaction=#attributes.fuseaction#" enctype="multipart/form-data" method="post">
                <cfinput type="file" name="upload_file" accept=".xlsx,.xls" required="yes">
                <br><br>
                <input type="submit" value="Import Et" class="btn">
            </cfform>
        </div>
            <cfoutput>
        <!--- Sonuçları Göster --->
        <cfif isDefined("results") and arrayLen(results) gt 0>
            <div style="margin-bottom: 20px;">
                <h3>Import Özeti</h3>
                <p><strong>Toplam İşlenen:</strong> #totalProcessed#</p>
                <p><strong>Başarılı:</strong> <span style="color: green;">#successCount#</span></p>
                <p><strong>Uyarı:</strong> <span style="color: orange;">#warningCount#</span></p>
                <p><strong>Hata:</strong> <span style="color: red;">#errorCount#</span></p>
            </div>
        
            <table class="result-table">
                <thead>
                    <tr>
                        <th>Sıra</th>
                        <th>ETA Kodu</th>
                        <th>GTIP Numarası</th>
                        <th>İngilizce İsim</th>
                        <th>Ağırlık</th>
                        <th>Mevcut GTIP</th>
                        <th>Durum</th>
                        <th>Mesaj</th>
                    </tr>
                </thead>
                <tbody>
                    <cfloop from="1" to="#arrayLen(results)#" index="i">
                        <cfset result = results[i]>
                        <tr>
                            <td>#i#</td>
                            <td>#result.etaKodu#</td>
                            <td>#result.gtipNumarasi#</td>
                            <td>
                                <cfif structKeyExists(result, "urunIsmiIngilizce") and len(result.urunIsmiIngilizce) gt 0>
                                    #result.urunIsmiIngilizce#
                                <cfelse>
                                    -
                                </cfif>
                            </td>
                            <td>
                                <cfif structKeyExists(result, "urunAgirlik") and len(result.urunAgirlik) gt 0>
                                    #result.urunAgirlik#
                                <cfelse>
                                    -
                                </cfif>
                            </td>
                            <td>
                                <cfif structKeyExists(result, "mevcutGtip")>
                                    #result.mevcutGtip#
                                <cfelse>
                                    -
                                </cfif>
                            </td>
                            <td>
                                <cfif result.status eq "success">
                                    <span class="success">Başarılı</span>
                                <cfelseif result.status eq "warning">
                                    <span class="warning">Uyarı</span>
                                <cfelse>
                                    <span class="error">Hata</span>
                                </cfif>
                            </td>
                            <td>#result.message#</td>
                        </tr>
                    </cfloop>
                </tbody>
            </table>
            
            <!--- Uyarı durumları için onay formu --->
            <cfif warningCount gt 0>
                <div style="margin-top: 20px; padding: 15px; background-color: ##fff3cd; border-radius: 5px;">
                    <h4>Uyarı: Farklı GTIP Numaraları Tespit Edildi</h4>
                    <p>Yukarıda listelenen ürünlerde mevcut GTIP numaralarından farklı değerler bulundu.</p>
                    <p>Bu değerleri güncellemek istiyorsanız aşağıdaki butona tıklayın:</p>
                    
                    <cfform method="post">
                        <cfloop from="1" to="#arrayLen(results)#" index="i">
                            <cfif results[i].status eq "warning">
                                <cfinput type="hidden" name="force_update_eta_#i#" value="#results[i].etaKodu#">
                                <cfinput type="hidden" name="force_update_gtip_#i#" value="#results[i].gtipNumarasi#">
                            </cfif>
                        </cfloop>
                        <cfinput type="hidden" name="force_update" value="true">
                        <input type="submit" value="Tüm Uyarıları Yok Say ve Güncelle" class="btn" style="background-color: ##ff9800;">
                    </cfform>
                </div>
            </cfif>
        </cfif>
        
        <!--- Zorla güncelleme işlemi --->
        <cfif isDefined("form.force_update") and form.force_update>
            <!--- Veritabanı bağlantısını tespit et --->
            
            
            <div class="success">
                <h4>Zorla Güncelleme Sonuçları:</h4>
                <cfset forceUpdateCount = 0>
                
                <cfloop collection="#form#" item="fieldName">
                    <cfif left(fieldName, 17) eq "force_update_eta_">
                        <cfset itemIndex = right(fieldName, len(fieldName) - 17)>
                        <cfset etaKodu = form["force_update_eta_#itemIndex#"]>
                        <cfset gtipNumarasi = form["force_update_gtip_#itemIndex#"]>
                        
                        <cftry>
                            <cfquery name="forceUpdate" datasource="#dsn1#">
                                UPDATE PRODUCT 
                                SET CUSTOMS_RECIPE_CODE = <cfqueryparam value="#gtipNumarasi#" cfsqltype="cf_sql_varchar">
                                WHERE PRODUCT_CODE_2 = <cfqueryparam value="#etaKodu#" cfsqltype="cf_sql_varchar">
                            </cfquery>
                            
                            <p>✓ #etaKodu# - GTIP numarası #gtipNumarasi# olarak güncellendi</p>
                            <cfset forceUpdateCount = forceUpdateCount + 1>
                            
                            <cfcatch type="any">
                                <p style="color: red;">✗ #etaKodu# - Güncelleme hatası: #cfcatch.message#</p>
                            </cfcatch>
                        </cftry>
                    </cfif>
                </cfloop>
                
                <p><strong>Toplam #forceUpdateCount# ürün zorla güncellendi.</strong></p>
            </div>
        </cfif>
        </cfoutput>
        <!--- Kullanım Talimatları --->
        <div style="margin-top: 30px; padding: 15px; background-color: #e7f3ff; border-radius: 5px;">
            <h4>Kullanım Talimatları:</h4>
            <ol>
                <li>Excel dosyanızda <strong>"ETA_KODU"</strong> ve <strong>"GTIP_NUMARASI"</strong> sütunları olmalıdır (zorunlu)</li>
                <li>İsteğe bağlı olarak <strong>"URUN_ISMI_INGILIZCE"</strong> ve <strong>"URUN_AGIRLIK"</strong> sütunları ekleyebilirsiniz</li>
                <li>İlk satır başlık satırı olarak kullanılacaktır</li>
                <li>Sistem her ETA kodu için veritabanında ürün arayacaktır</li>
                <li>Ürün bulunamazsa hata mesajı verecektir</li>
                <li>Mevcut GTIP numarası varsa ve farklıysa uyarı verecektir</li>
                <li>Diğer durumlarda GTIP numarası ve varsa diğer alanları güncelleyecektir</li>
            </ol>
        </div>
    </div>

</cf_box>