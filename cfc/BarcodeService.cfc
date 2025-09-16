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

    <!--- Yazıcı status (port erişilebilir mi) --->
    <cffunction name="checkPrinterStatus" access="public"  returntype="struct" hint="TCP bağlantısı kurulabiliyor mu bakar.">
        <cfset var socket = "">
        <cfset var returndata = structNew()>
        
        <cftry>
            <cfset var InetSocketAddress = createObject("java","java.net.InetSocketAddress")>
            <cfset var Socket            = createObject("java","java.net.Socket")>
            
            <!--- Timeout ayarlarını uygula --->
            <cfset Socket.setSoTimeout(javacast("int", variables.readTimeout))>
            
            <!--- Bağlantı kur --->
            <cfset var addr = InetSocketAddress.init( variables.printerIpAddress, javacast("int", variables.printerPort) )>
            <cfset Socket.connect( addr, javacast("int", variables.connectionTimeout) )>
            <cfset var connected = Socket.isConnected()>
            
            <cfset returndata.status = true>
            <cfset returndata.message = "Bağlantı başarılı - IP: #variables.printerIpAddress#:#variables.printerPort#">
            <cfset returndata.connectionTimeout = variables.connectionTimeout>
            <cfset returndata.readTimeout = variables.readTimeout>
            
            <cfif Socket><!--- CF versions vary --->
                <cfset Socket.close()>
            </cfif>
            
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
                    <cfif isDefined("Socket") AND isObject(Socket)>
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

            <!--- Kapat --->
            <cfif OutputStream>
                <cfset OutputStream.close()>
            </cfif>
            <cfif Socket>
                <cfset Socket.close()>
            </cfif>

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
                
                <!--- Socket'leri güvenli şekilde kapat --->
                <cftry>
                    <cfif isDefined("OutputStream") AND isObject(OutputStream)>
                        <cfset OutputStream.close()>
                    </cfif>
                    <cfcatch><!--- Kapatma hatası önemli değil ---></cfcatch>
                </cftry>
                <cftry>
                    <cfif isDefined("Socket") AND isObject(Socket)>
                        <cfset Socket.close()>
                    </cfif>
                    <cfcatch><!--- Kapatma hatası önemli değil ---></cfcatch>
                </cftry>
            </cfcatch>
        </cftry>
        <cfreturn returndata>
    </cffunction>

</cfcomponent>
