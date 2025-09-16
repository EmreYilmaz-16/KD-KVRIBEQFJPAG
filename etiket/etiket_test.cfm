<!--- zpl_sender.cfm --->
<cfsetting showdebugoutput="false">
<cfparam name="form.printerIp"   default="192.168.2.9">
<cfparam name="form.printerPort" default="9100">
<cfparam name="form.charset"     default="US-ASCII"> <!--- ZPL için tipik --->
<cfparam name="form.normalize"   default="1">
<cfparam name="form.sample"      default="1">
<cfparam name="form.zpl"         default="
^XA
^PW406
^LH0,0
^FO20,20^A0N,30,30^FDHello ZPL!^FS
^FO20,80^BCN,80,Y,N,N^FD123456789012^FS
^XZ
">

<html>
<head>
  <meta charset="utf-8">
  <title>ZPL Gönder (Raw 9100)</title>
  <style>
    body{font-family:system-ui, -apple-system, Segoe UI, Roboto, Arial; margin:20px;}
    label{display:block; margin:.3rem 0 .2rem;}
    input, select, textarea{width:100%; padding:.5rem; font-family:monospace;}
    .row{display:grid; grid-template-columns: 1fr 1fr; gap:12px;}
    .btn{display:inline-block; padding:.6rem 1rem; background:#111; color:#fff; border:none; cursor:pointer; margin-top:.6rem;}
    .ok{color:#0a7a0a}
    .err{color:#b00020}
    pre{background:#f6f6f6; padding:10px; overflow:auto;}
  </style>
</head>
<body>

<h2>ZPL Gönder (Raw TCP 9100)</h2>

<form method="post">
  <div class="row">
    <div>
      <label>Yazıcı IP</label>
      <input type="text" name="printerIp" value="<CFOUTPUT>#htmlEditFormat(form.printerIp)#</CFOUTPUT>" required>
    </div>
    <div>
      <label>Port</label>
      <input type="number" name="printerPort" value="<CFOUTPUT>#htmlEditFormat(form.printerPort)#</CFOUTPUT>" required>
    </div>
  </div>

  <div class="row">
    <div>
      <label>Karakter Seti</label>
      <select name="charset">
        <option value="US-ASCII"  <cfif form.charset EQ "US-ASCII">selected</cfif>>US-ASCII (önerilen)</option>
        <option value="UTF-8"     <cfif form.charset EQ "UTF-8">selected</cfif>>UTF-8 (^CI28 gerekiyorsa)</option>
        <option value="ISO-8859-9"<cfif form.charset EQ "ISO-8859-9">selected</cfif>>ISO-8859-9 (Türkçe Latin-5)</option>
      </select>
    </div>
    <div>
      <label>
        <input type="checkbox" name="normalize" value="1" <cfif val(form.normalize)>checked</cfif>>
        Satır Sonlarını CRLF (^M^J) yap
      </label>
      <label>
        <input type="checkbox" name="sample" value="1" <cfif val(form.sample)>checked</cfif>>
        Örnek ZPL’yi yükle
      </label>
    </div>
  </div>

  <label>ZPL İçeriği</label>
  <textarea name="zpl" rows="12"><CFOUTPUT>#htmlEditFormat(trim(form.zpl))#</CFOUTPUT></textarea>

  <button class="btn" type="submit" name="send" value="1">Gönder</button>
</form>

<cfif structKeyExists(form,"send")>
  <hr>
  <h3>Sonuç</h3>
  <cftry>
    <!--- ZPL hazırlığı --->
    <cfset zplData = trim(form.zpl)>
    <cfif val(form.normalize)>
      <!--- Tüm satır sonlarını CRLF yap (ZPL yazıcıları genelde sever) --->
      <cfset zplData = replace(zplData, chr(13), "", "all")>
      <cfset zplData = replace(zplData, chr(10), chr(13)&chr(10), "all")>
    </cfif>

    <!--- Boşsa hata --->
    <cfif len(zplData) EQ 0>
      <cfthrow message="ZPL boş olamaz. ^XA ... ^XZ komutlarını ekleyin.">
    </cfif>

    <!--- Java Socket ile gönder --->
    <cfset InetSocketAddress = createObject("java","java.net.InetSocketAddress")>
    <cfset Socket            = createObject("java","java.net.Socket")>
    <cfset addr = InetSocketAddress.init( trim(form.printerIp), javacast("int", val(form.printerPort)) )>

    <!--- 5 sn bağlanma timeout --->
    <cfset Socket.connect( addr, javacast("int", 5000 ) )>
    <cfset Socket.setSoTimeout( javacast("int", 5000 ) )>

    <cfset os    = Socket.getOutputStream()>
    <cfset bytes = createObject("java","java.lang.String").init( zplData ).getBytes( javacast("string", form.charset ) )>

    <cfset os.write( bytes )>
    <cfset os.flush()>
    <cfset os.close()>
    <cfset Socket.close()>

    <p class="ok">✅ Gönderildi.</p>
    <details open>
      <summary>Gönderilen ZPL (önizleme)</summary>
      <pre>#htmlEditFormat(zplData)#</pre>
    </details>

    <cfcatch type="any">
      <p class="err">❌ Hata: #htmlEditFormat(cfcatch.message)#</p>
      <cfif structKeyExists(cfcatch,"detail") AND len(cfcatch.detail)>
        <pre class="err">#htmlEditFormat(cfcatch.detail)#</pre>
      </cfif>
    </cfcatch>
  </cftry>
</cfif>

<hr>
<h4>İpuçları</h4>
<ul>
  <li>ZPL mutlaka <code>^XA</code> ile başlasın ve <code>^XZ</code> ile bitsin.</li>
  <li>Türkçe karakter gerekirse ZPL içine <code>^CI28</code> ekleyip formdan <strong>UTF-8</strong> seç.</li>
  <li>203 dpi’de 2 inç genişlik ≈ <code>^PW406</code>.</li>
</ul>

</body>
</html>
