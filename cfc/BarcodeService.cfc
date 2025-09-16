<cfcomponent displayname="BarcodeService"  hint="TCP üzerinden PPL komutları gönderir.">

    <!--- Yapılandırma --->
    <cfset variables.printerIpAddress = "127.0.0.1">
    <cfset variables.printerPort      = 9100>
    <cfset variables.connectionTimeout = 5000>  <!--- 5 saniye connection timeout --->
    <cfset variables.readTimeout      = 10000>  <!--- 10 saniye read timeout --->
    <!--- CRLF: bir çok termal yazıcı CRLF sever --->
    <cfset variables.EOL = chr(13) & chr(10)>

    <!--- Ctor --->
    <cffunction name="init" access="public"  returntype="any" hint="IP ve Port ile başlat">
        <cfargument name="printerIpAddress"    type="string"  required="true">
        <cfargument name="printerPort"         type="numeric" required="false" default="9100">
        <cfargument name="connectionTimeout"   type="numeric" required="false" default="5000">
        <cfargument name="readTimeout"         type="numeric" required="false" default="10000">

        <cfset variables.printerIpAddress = arguments.printerIpAddress>
        <cfset variables.printerPort      = arguments.printerPort>
        <cfset variables.connectionTimeout = arguments.connectionTimeout>
        <cfset variables.readTimeout      = arguments.readTimeout>

        <cfreturn this>
    </cffunction>

    <!--- Barkod yazdır --->
    <cffunction name="printBarcode" access="public"  returntype="struct" hint="PPL ile barkod yazdırır.">
        <cfargument name="barcodeData" type="string"  required="true">
        <cfargument name="barcodeType" type="string"  required="false" default="Code128">
        <cfargument name="x"           type="numeric" required="false" default="10">
        <cfargument name="y"           type="numeric" required="false" default="10">
        <cfargument name="width"       type="numeric" required="false" default="2">
        <cfargument name="height"      type="numeric" required="false" default="80">
        <cfargument name="copies"      type="numeric" required="false" default="1">
        
        <cfset var returndata = structNew()>
        <cftry>
            <cfset var cmd = generatePPLBarcodeCommand(
                arguments.barcodeData, arguments.barcodeType,
                arguments.x, arguments.y, arguments.width, arguments.height, arguments.copies
            )>
            <cfset returndata = sendToPrinter(cmd)>
            <cfset returndata.operation = "printBarcode">
            <cfset returndata.barcodeData = arguments.barcodeData>
            <cfset returndata.barcodeType = arguments.barcodeType>

            <cfcatch type="any">
                <cfset returndata.success = false>
                <cfset returndata.message = "Barkod yazdırma hatası: #cfcatch.message#">
                <cfset returndata.operation = "printBarcode">
                <cfset returndata.barcodeData = arguments.barcodeData>
                <cfset returndata.errorType = cfcatch.type>
                <cfset returndata.errorDetail = cfcatch.detail>
            </cfcatch>
        </cftry>
        <cfreturn returndata>
    </cffunction>

    <!--- Metin yazdır --->
    <cffunction name="printText" access="public"  returntype="struct" hint="PPL ile metin yazdırır.">
        <cfargument name="text"     type="string"  required="true">
        <cfargument name="x"        type="numeric" required="false" default="10">
        <cfargument name="y"        type="numeric" required="false" default="100">
        <cfargument name="fontSize" type="numeric" required="false" default="3">
        <cfargument name="copies"   type="numeric" required="false" default="1">
        
        <cfset var returndata = structNew()>
        <cftry>
            <cfset var cmd = generatePPLTextCommand(arguments.text, arguments.x, arguments.y, arguments.fontSize, arguments.copies)>
            <cfset returndata = sendToPrinter(cmd)>
            <cfset returndata.operation = "printText">
            <cfset returndata.text = arguments.text>

            <cfcatch type="any">
                <cfset returndata.success = false>
                <cfset returndata.message = "Metin yazdırma hatası: #cfcatch.message#">
                <cfset returndata.operation = "printText">
                <cfset returndata.text = arguments.text>
                <cfset returndata.errorType = cfcatch.type>
                <cfset returndata.errorDetail = cfcatch.detail>
            </cfcatch>
        </cftry>
        <cfreturn returndata>
    </cffunction>

    <!--- ZPL Barkod yazdır --->
    <cffunction name="printBarcodeZPL" access="public" returntype="struct" hint="ZPL ile barkod yazdırır.">
        <cfargument name="barcodeData" type="string"  required="true">
        <cfargument name="barcodeType" type="string"  required="false" default="Code128">
        <cfargument name="x"           type="numeric" required="false" default="50">
        <cfargument name="y"           type="numeric" required="false" default="50">
        <cfargument name="width"       type="numeric" required="false" default="2">
        <cfargument name="height"      type="numeric" required="false" default="80">
        <cfargument name="copies"      type="numeric" required="false" default="1">
        
        <cfset var returndata = structNew()>
        <cftry>
            <cfset var cmd = generateZPLBarcodeCommand(
                arguments.barcodeData, arguments.barcodeType,
                arguments.x, arguments.y, arguments.width, arguments.height, arguments.copies
            )>
            <cfset returndata = sendToPrinter(cmd)>
            <cfset returndata.operation = "printBarcodeZPL">
            <cfset returndata.barcodeData = arguments.barcodeData>
            <cfset returndata.barcodeType = arguments.barcodeType>
            <cfset returndata.language = "ZPL">

            <cfcatch type="any">
                <cfset returndata.success = false>
                <cfset returndata.message = "ZPL Barkod yazdırma hatası: #cfcatch.message#">
                <cfset returndata.operation = "printBarcodeZPL">
                <cfset returndata.barcodeData = arguments.barcodeData>
                <cfset returndata.language = "ZPL">
                <cfset returndata.errorType = cfcatch.type>
                <cfset returndata.errorDetail = cfcatch.detail>
            </cfcatch>
        </cftry>
        <cfreturn returndata>
    </cffunction>

    <!--- ZPL Metin yazdır --->
    <cffunction name="printTextZPL" access="public" returntype="struct" hint="ZPL ile metin yazdırır.">
        <cfargument name="text"     type="string"  required="true">
        <cfargument name="x"        type="numeric" required="false" default="50">
        <cfargument name="y"        type="numeric" required="false" default="100">
        <cfargument name="fontSize" type="string"  required="false" default="0">
        <cfargument name="copies"   type="numeric" required="false" default="1">
        
        <cfset var returndata = structNew()>
        <cftry>
            <cfset var cmd = generateZPLTextCommand(arguments.text, arguments.x, arguments.y, arguments.fontSize, arguments.copies)>
            <cfset returndata = sendToPrinter(cmd)>
            <cfset returndata.operation = "printTextZPL">
            <cfset returndata.text = arguments.text>
            <cfset returndata.language = "ZPL">

            <cfcatch type="any">
                <cfset returndata.success = false>
                <cfset returndata.message = "ZPL Metin yazdırma hatası: #cfcatch.message#">
                <cfset returndata.operation = "printTextZPL">
                <cfset returndata.text = arguments.text>
                <cfset returndata.language = "ZPL">
                <cfset returndata.errorType = cfcatch.type>
                <cfset returndata.errorDetail = cfcatch.detail>
            </cfcatch>
        </cftry>
        <cfreturn returndata>
    </cffunction>

    <!--- Ham ZPL komutu gönder --->
    <cffunction name="sendRawZPL" access="public" returntype="struct" hint="Ham ZPL kodunu doğrudan gönderir.">
        <cfargument name="zplCommand" type="string" required="true" hint="Ham ZPL komutu">
        
        <cfset var returndata = structNew()>
        <cftry>
            <cfset returndata = sendToPrinter(arguments.zplCommand)>
            <cfset returndata.operation = "sendRawZPL">
            <cfset returndata.commandLength = len(arguments.zplCommand)>
            <cfset returndata.language = "ZPL">

            <cfcatch type="any">
                <cfset returndata.success = false>
                <cfset returndata.message = "Ham ZPL gönderim hatası: #cfcatch.message#">
                <cfset returndata.operation = "sendRawZPL">
                <cfset returndata.language = "ZPL">
                <cfset returndata.commandLength = len(arguments.zplCommand)>
                <cfset returndata.errorType = cfcatch.type>
                <cfset returndata.errorDetail = cfcatch.detail>
            </cfcatch>
        </cftry>
        <cfreturn returndata>
    </cffunction>

    <!--- Ağ ping testi --->
    <cffunction name="pingHost" access="public" returntype="struct" hint="Basit ping testi yapar">
        <cfset var returndata = structNew()>
        
        <cftry>
            <cfset var InetAddress = createObject("java","java.net.InetAddress")>
            <cfset var host = InetAddress.getByName(variables.printerIpAddress)>
            <!--- 3 saniye timeout ile ping --->
            <cfset var reachable = host.isReachable(javacast("int", 3000))>
            
            <cfif reachable>
                <cfset returndata.status = true>
                <cfset returndata.message = "Host erişilebilir: #variables.printerIpAddress#">
            <cfelse>
                <cfset returndata.status = false>
                <cfset returndata.message = "Host erişilemez: #variables.printerIpAddress#">
            </cfif>
            
            <cfset returndata.hostIP = variables.printerIpAddress>
            
            <cfcatch type="any">
                <cfset returndata.status = false>
                <cfset returndata.message = "Ping hatası: #cfcatch.message#">
                <cfset returndata.errorType = cfcatch.type>
                <cfset returndata.hostIP = variables.printerIpAddress>
            </cfcatch>
        </cftry>
        
        <cfreturn returndata>
    </cffunction>

    <!--- Yazıcı status (port erişilebilir mi) --->
    <cffunction name="checkPrinterStatus" access="public"  returntype="struct" hint="TCP bağlantısı kurulabiliyor mu bakar.">
        <cfset var returndata = structNew()>
        
        <cftry>
            <!--- Basit socket testi - bağlantı kurup hemen kapat --->
            <cfset var Socket = createObject("java","java.net.Socket")>
            
            <!--- Timeout ayarlarını uygula --->
            <cfset Socket.setSoTimeout(javacast("int", variables.readTimeout))>
            
            <!--- Direkt IP ve port ile bağlan --->
            <cfset Socket.connect(
                createObject("java","java.net.InetSocketAddress").init(
                    variables.printerIpAddress, 
                    javacast("int", variables.printerPort)
                ), 
                javacast("int", variables.connectionTimeout)
            )>
            
            <!--- Bağlantı başarılı --->
            <cfset returndata.status = true>
            <cfset returndata.message = "Bağlantı başarılı - IP: #variables.printerIpAddress#:#variables.printerPort#">
            <cfset returndata.connectionTimeout = variables.connectionTimeout>
            <cfset returndata.readTimeout = variables.readTimeout>
            <cfset returndata.targetIP = variables.printerIpAddress>
            <cfset returndata.targetPort = variables.printerPort>
            
            <!--- Socket'i güvenli şekilde kapat --->
            <cftry>
                <cfset Socket.close()>
                <cfcatch>
                    <!--- Socket kapatma hatası önemli değil --->
                </cfcatch>
            </cftry>
            
            <cfcatch type="any">
                <cfset returndata.status = false>
                <cfset returndata.message = "Bağlantı hatası: #cfcatch.message#">
                <cfset returndata.errorType = cfcatch.type>
                <cfset returndata.errorDetail = cfcatch.detail>
                <cfset returndata.targetIP = variables.printerIpAddress>
                <cfset returndata.targetPort = variables.printerPort>
                <cfset returndata.connectionTimeout = variables.connectionTimeout>
                
                <!--- Socket kapatmayı dene --->
                <cftry>
                    <cfif isDefined("Socket")>
                        <cfset Socket.close()>
                    </cfif>
                    <cfcatch>
                        <!--- Socket kapatma hatası önemli değil --->
                    </cfcatch>
                </cftry>
            </cfcatch>
        </cftry>
        <cfreturn returndata>
    </cffunction>

    <!--- PRIVATE: PPL Barkod Komutu --->
    <cffunction name="generatePPLBarcodeCommand" access="private"  returntype="string">
        <cfargument name="barcodeData" type="string"  required="true">
        <cfargument name="barcodeType" type="string"  required="true">
        <cfargument name="x"           type="numeric" required="true">
        <cfargument name="y"           type="numeric" required="true">
        <cfargument name="width"       type="numeric" required="true">
        <cfargument name="height"      type="numeric" required="true">
        <cfargument name="copies"      type="numeric" required="true">

        <cfset var STX = chr(2)>
        <cfset var ETX = chr(3)>
        <cfset var sb  = "">

        <!--- Başlangıç --->
        <cfset sb &= STX & variables.EOL>
        <cfset sb &= "Q1" & variables.EOL>
        <cfset sb &= "q831" & variables.EOL>
        <cfset sb &= "D#arguments.copies#" & variables.EOL>

        <!--- Barkod tipi harfi: PPLB/PPLA varyasyonlarına göre harfler değişebilir. --->
        <cfset var t = uCase(arguments.barcodeType)>
        <cfif t EQ "CODE128">
            <cfset sb &= "B#arguments.x#,#arguments.y#,I,#arguments.width#,#arguments.height#,r,m2,s#arguments.barcodeData#;" & variables.EOL>
        <cfelseif t EQ "CODE39">
            <cfset sb &= "B#arguments.x#,#arguments.y#,H,#arguments.width#,#arguments.height#,r,m2,s#arguments.barcodeData#;" & variables.EOL>
        <cfelseif t EQ "EAN13">
            <cfset sb &= "B#arguments.x#,#arguments.y#,E,#arguments.width#,#arguments.height#,r,m2,s#arguments.barcodeData#;" & variables.EOL>
        <cfelseif t EQ "EAN8">
            <cfset sb &= "B#arguments.x#,#arguments.y#,F,#arguments.width#,#arguments.height#,r,m2,s#arguments.barcodeData#;" & variables.EOL>
        <cfelseif t EQ "UPCA">
            <cfset sb &= "B#arguments.x#,#arguments.y#,A,#arguments.width#,#arguments.height#,r,m2,s#arguments.barcodeData#;" & variables.EOL>
        <cfelse>
            <!--- Varsayılan Code128 --->
            <cfset sb &= "B#arguments.x#,#arguments.y#,I,#arguments.width#,#arguments.height#,r,m2,s#arguments.barcodeData#;" & variables.EOL>
        </cfif>

        <!--- Yazdır & Bitiş --->
        <cfset sb &= "P1" & variables.EOL>
        <cfset sb &= ETX & variables.EOL>

        <cfreturn sb>
    </cffunction>

    <!--- PRIVATE: PPL Metin Komutu --->
    <cffunction name="generatePPLTextCommand" access="private"  returntype="string">
        <cfargument name="text"     type="string"  required="true">
        <cfargument name="x"        type="numeric" required="true">
        <cfargument name="y"        type="numeric" required="true">
        <cfargument name="fontSize" type="numeric" required="true">
        <cfargument name="copies"   type="numeric" required="true">

        <cfset var STX = chr(2)>
        <cfset var ETX = chr(3)>
        <cfset var sb  = "">

        <!--- Başlangıç --->
        <cfset sb &= STX & variables.EOL>
        <cfset sb &= "Q1" & variables.EOL>
        <cfset sb &= "q831" & variables.EOL>
        <cfset sb &= "D#arguments.copies#" & variables.EOL>

        <!--- Not: PPL’de T komutu yazıcı/versiyona göre değişebilir. Bu örnekte T x,y,font,rot,bold,italic,reverse,N,text; varsayıldı. --->
        <!--- Metinde virgül/noktalı virgül sorun çıkarırsa temizleyin --->
        <cfset var safeText = replace(replace(arguments.text,";"," ","all"), chr(10), " ", "all")>
        <cfset safeText = replace(safeText, chr(13), " ", "all")>

        <cfset sb &= "T#arguments.x#,#arguments.y#,#arguments.fontSize#,0,0,0,N,#safeText#;" & variables.EOL>

        <!--- Yazdır & Bitiş --->
        <cfset sb &= "P1" & variables.EOL>
        <cfset sb &= ETX & variables.EOL>

        <cfreturn sb>
    </cffunction>

    <!--- PRIVATE: ZPL Barkod Komutu --->
    <cffunction name="generateZPLBarcodeCommand" access="private" returntype="string">
        <cfargument name="barcodeData" type="string"  required="true">
        <cfargument name="barcodeType" type="string"  required="true">
        <cfargument name="x"           type="numeric" required="true">
        <cfargument name="y"           type="numeric" required="true">
        <cfargument name="width"       type="numeric" required="true">
        <cfargument name="height"      type="numeric" required="true">
        <cfargument name="copies"      type="numeric" required="true">

        <cfset var sb = "">

        <!--- ZPL Başlangıç --->
        <cfset sb &= "^XA" & variables.EOL>  <!--- Start Format --->
        <cfset sb &= "^PQ#arguments.copies#" & variables.EOL>  <!--- Print Quantity --->

        <!--- ZPL Barkod komutları --->
        <cfset var t = uCase(arguments.barcodeType)>
        <cfif t EQ "CODE128">
            <!--- ^BC = Code 128, o=orientation, h=height, f=print interpretation line, g=print interpretation line above --->
            <cfset sb &= "^FO#arguments.x#,#arguments.y#" & variables.EOL>  <!--- Field Origin --->
            <cfset sb &= "^BCN,#arguments.height#,Y,N,N" & variables.EOL>  <!--- Code 128 Barcode --->
            <cfset sb &= "^FD#arguments.barcodeData#^FS" & variables.EOL>  <!--- Field Data --->
        <cfelseif t EQ "CODE39">
            <cfset sb &= "^FO#arguments.x#,#arguments.y#" & variables.EOL>
            <cfset sb &= "^B3N,N,#arguments.height#,Y,N" & variables.EOL>  <!--- Code 39 Barcode --->
            <cfset sb &= "^FD#arguments.barcodeData#^FS" & variables.EOL>
        <cfelseif t EQ "EAN13">
            <cfset sb &= "^FO#arguments.x#,#arguments.y#" & variables.EOL>
            <cfset sb &= "^BEN,#arguments.height#,Y,N" & variables.EOL>  <!--- EAN-13 Barcode --->
            <cfset sb &= "^FD#arguments.barcodeData#^FS" & variables.EOL>
        <cfelseif t EQ "EAN8">
            <cfset sb &= "^FO#arguments.x#,#arguments.y#" & variables.EOL>
            <cfset sb &= "^B8N,#arguments.height#,Y,N" & variables.EOL>  <!--- EAN-8 Barcode --->
            <cfset sb &= "^FD#arguments.barcodeData#^FS" & variables.EOL>
        <cfelseif t EQ "UPCA">
            <cfset sb &= "^FO#arguments.x#,#arguments.y#" & variables.EOL>
            <cfset sb &= "^BUN,#arguments.height#,Y,N,Y" & variables.EOL>  <!--- UPC-A Barcode --->
            <cfset sb &= "^FD#arguments.barcodeData#^FS" & variables.EOL>
        <cfelseif t EQ "QR" OR t EQ "QRCODE">
            <!--- QR Code için özel işlem --->
            <cfset sb &= "^FO#arguments.x#,#arguments.y#" & variables.EOL>
            <cfset sb &= "^BQN,2,#arguments.width#" & variables.EOL>  <!--- QR Code, quality=2, magnification --->
            <cfset sb &= "^FDQA,#arguments.barcodeData#^FS" & variables.EOL>
        <cfelse>
            <!--- Varsayılan Code128 --->
            <cfset sb &= "^FO#arguments.x#,#arguments.y#" & variables.EOL>
            <cfset sb &= "^BCN,#arguments.height#,Y,N,N" & variables.EOL>
            <cfset sb &= "^FD#arguments.barcodeData#^FS" & variables.EOL>
        </cfif>

        <!--- ZPL Bitiş --->
        <cfset sb &= "^XZ" & variables.EOL>  <!--- End Format --->

        <cfreturn sb>
    </cffunction>

    <!--- PRIVATE: ZPL Metin Komutu --->
    <cffunction name="generateZPLTextCommand" access="private" returntype="string">
        <cfargument name="text"     type="string"  required="true">
        <cfargument name="x"        type="numeric" required="true">
        <cfargument name="y"        type="numeric" required="true">
        <cfargument name="fontSize" type="string"  required="true">
        <cfargument name="copies"   type="numeric" required="true">

        <cfset var sb = "">

        <!--- ZPL Başlangıç --->
        <cfset sb &= "^XA" & variables.EOL>  <!--- Start Format --->
        <cfset sb &= "^PQ#arguments.copies#" & variables.EOL>  <!--- Print Quantity --->

        <!--- Metin alanı --->
        <cfset sb &= "^FO#arguments.x#,#arguments.y#" & variables.EOL>  <!--- Field Origin --->
        <cfset sb &= "^A#arguments.fontSize#N,30,20" & variables.EOL>  <!--- Font: 0=default, N=normal, height=30, width=20 --->
        <cfset sb &= "^FD#arguments.text#^FS" & variables.EOL>  <!--- Field Data --->

        <!--- ZPL Bitiş --->
        <cfset sb &= "^XZ" & variables.EOL>  <!--- End Format --->

        <cfreturn sb>
    </cffunction>

    <!--- PRIVATE: TCP gönder --->
    <cffunction name="sendToPrinter" access="private"  returntype="struct" hint="Komutu TCP ile yazar.">
        <cfargument name="command" type="string" required="true">
        <cfset var Socket        = "">
        <cfset var OutputStream  = "">
        <cfset var bytes         = "">
        <cfset var returndata    = structNew()>
        
        <cftry>
            <!--- Java Socket aç ve timeout ayarla --->
            <cfset Socket = createObject("java","java.net.Socket")>
            <cfset Socket.setSoTimeout(javacast("int", variables.readTimeout))>
            
            <!--- Bağlantı kur --->
            <cfset var InetSocketAddress = createObject("java","java.net.InetSocketAddress")>
            <cfset var addr = InetSocketAddress.init( variables.printerIpAddress, javacast("int", variables.printerPort) )>
            <cfset Socket.connect( addr, javacast("int", variables.connectionTimeout) )>
            
            <!--- OutputStream al --->
            <cfset OutputStream = Socket.getOutputStream()>

            <!--- US-ASCII byte dizisi oluştur --->
            <cfset var StringClass = createObject("java","java.lang.String").init( arguments.command )>
            <cfset bytes = StringClass.getBytes( javacast("string","US-ASCII") )>

            <!--- Yaz & flush --->
            <cfset OutputStream.write( bytes )>
            <cfset OutputStream.flush()>

            <!--- Başarı mesajı --->
            <cfset returndata.success = true>
            <cfset returndata.message = "Komut başarıyla gönderildi">
            <cfset returndata.commandLength = len(arguments.command)>
            <cfset returndata.targetIP = variables.printerIpAddress>
            <cfset returndata.targetPort = variables.printerPort>

            <!--- Kapat - isDefined ve isObject kontrollerini kaldır --->
            <cftry>
                <cfset OutputStream.close()>
                <cfcatch><!--- Stream kapatma hatası önemli değil ---></cfcatch>
            </cftry>
            <cftry>
                <cfset Socket.close()>
                <cfcatch><!--- Socket kapatma hatası önemli değil ---></cfcatch>
            </cftry>

            <cfcatch type="any">
                <!--- Detaylı hata bilgisi --->
                <cfset returndata.success = false>
                <cfset returndata.message = "Gönderim hatası: #cfcatch.message#">
                <cfset returndata.errorType = cfcatch.type>
                <cfset returndata.errorDetail = cfcatch.detail>
                <cfset returndata.targetIP = variables.printerIpAddress>
                <cfset returndata.targetPort = variables.printerPort>
                <cfset returndata.connectionTimeout = variables.connectionTimeout>
                <cfset returndata.readTimeout = variables.readTimeout>
                <cfset returndata.commandLength = len(arguments.command)>
                
                <!--- Socket'leri güvenli şekilde kapat - boolean kontrolleri kaldır --->
                <cftry>
                    <cfset OutputStream.close()>
                    <cfcatch><!--- Kapatma hatası önemli değil ---></cfcatch>
                </cftry>
                <cftry>
                    <cfset Socket.close()>
                    <cfcatch><!--- Kapatma hatası önemli değil ---></cfcatch>
                </cftry>
            </cfcatch>
        </cftry>
        <cfreturn returndata>
    </cffunction>

</cfcomponent>
