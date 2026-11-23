# Частина A. Реальні виводи команд

Команди фактично запущені асистентом на робочій станції користувача; особисте виконання студентом не підтверджено.

Студент: Воробйов Дмитро. Таблиця групи: 1. Варіант: 1. Домен: example.com.

Середовище: Windows. Версія curl: curl 8.22.0 (Windows) libcurl/8.22.0 Schannel zlib/1.3.2 WinIDN WinLDAP.

Часові позначки містять фактичний часовий пояс комп'ютера. Первинні файли raw збережено без редагування; для Markdown прочитано їх текст як UTF-8. Якщо символи у відповіді відображаються неправильно, збережіть raw і повідомте про це перед оформленням звіту.

### A.1

Час: 2026-11-22T22:54:28.3831525+01:00

Команда:

```powershell
curl.exe -v https://example.com > raw/a1-curl-https.txt 2>&1
```

Повний вивід:

```text
* Could not resolve host: example.com
* Could not resolve host: example.com
* Could not resolve: example.com:443
* closing connection #0
curl: (6) Could not resolve host: example.com

```

### A.2

Час: 2026-11-22T22:54:28.9073154+01:00

Команда:

```powershell
curl.exe -v http://neverssl.com > raw/a2-curl-http.txt 2>&1
```

Повний вивід:

```text
*   Trying 34.223.124.45:80...
* Host neverssl.com:80 was resolved.
* IPv6: (none)
* IPv4: 34.223.124.45
* connect to 34.223.124.45 port 80 from 0.0.0.0 port 55511 failed: Timed out
* Failed to connect to neverssl.com:80 after 21131 ms: Could not connect to server
* closing connection #0
curl: (28) Failed to connect to neverssl.com:80 after 21131 ms: Could not connect to server

```

### A.3, перше виконання

Час: 2026-11-22T22:54:50.8269269+01:00

Команда:

```powershell
Resolve-DnsName example.com 2>&1 | Out-String -Width 4096
```

Повний вивід:

```text
Resolve-DnsName : example.com : DNS name does not exist
At [local-user]\Documents\Study\Щерба\Виконані_роботи\pr01\collect-pr01.ps1:81 char:17
+     $result = @(Resolve-DnsName $domain 2>&1)
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (example.com:String) [Resolve-DnsName], Win32Exception
    + FullyQualifiedErrorId : DNS_ERROR_RCODE_NAME_ERROR,Microsoft.DnsClient.Commands.ResolveDnsName
 

```

### A.3, повторне виконання

Час: 2026-11-22T23:00:51.9029177+01:00

Команда:

```powershell
Resolve-DnsName example.com 2>&1 | Out-String -Width 4096
```

Повний вивід:

```text
Resolve-DnsName : example.com : DNS name does not exist
At [local-user]\Documents\Study\Щерба\Виконані_роботи\pr01\collect-pr01.ps1:81 char:17
+     $result = @(Resolve-DnsName $domain 2>&1)
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (example.com:String) [Resolve-DnsName], Win32Exception
    + FullyQualifiedErrorId : DNS_ERROR_RCODE_NAME_ERROR,Microsoft.DnsClient.Commands.ResolveDnsName
 

```

### A.4

Час: 2026-11-22T23:00:52.1663911+01:00

Команда:

```powershell
curl.exe -v https://google.com > raw/a4-google.txt 2>&1
```

Повний вивід:

```text
* Host google.com:443 was resolved.
* IPv6: (none)
* IPv4: 172.217.171.110
*   Trying 172.217.171.110:443...
* schannel: disabled automatic use of client certificate
* ALPN: curl offers http/1.1
* ALPN: server accepted http/1.1
* Established connection to google.com (172.217.171.110 port 443) from 192.168.129.83 port 56714 
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
  0      0   0      0   0      0      0      0                              0* using HTTP/1.x
> GET / HTTP/1.1
> Host: google.com
> User-Agent: curl/8.22.0
> Accept: */*
> 
* Request completely sent off
* schannel: remote party requests renegotiation
* schannel: renegotiating SSL/TLS connection
* schannel: SSL/TLS connection renegotiated
< HTTP/1.1 301 Moved Permanently
< Location: https://www.google.com/
< Content-Type: text/html; charset=UTF-8
< Content-Security-Policy-Report-Only: object-src 'none';base-uri 'self';script-src 'nonce-YOfAIsdXa0luwQFGScoioA' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
< Date: Sun, 22 Nov 2026 22:00:52 GMT
< Expires: Tue, 22 Dec 2026 22:00:52 GMT
< Cache-Control: public, max-age=2592000
< Server: gws
< Content-Length: 220
< X-XSS-Protection: 0
< X-Frame-Options: SAMEORIGIN
< Alt-Svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000
< 
{ [220 bytes data]
100    220 100    220   0      0   1703      0                              0100    220 100    220   0      0   1698      0                              0100    220 100    220   0      0   1693      0                              0
* Connection #0 to host google.com:443 left intact
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="https://www.google.com/">here</A>.
</BODY></HTML>

```

### A.5, expired

Час: 2026-11-22T23:00:52.5465667+01:00

Команда:

```powershell
curl.exe -v https://expired.badssl.com > raw/a5-expired.txt 2>&1
```

Повний вивід:

```text
* Host expired.badssl.com:443 was resolved.
* IPv6: (none)
* IPv4: 104.154.89.105
*   Trying 104.154.89.105:443...
* connect to 104.154.89.105 port 443 from 0.0.0.0 port 56715 failed: Timed out
* Failed to connect to expired.badssl.com:443 after 21079 ms: Could not connect to server
* closing connection #0
curl: (28) Failed to connect to expired.badssl.com:443 after 21079 ms: Could not connect to server

```

### A.5, wrong.host

Час: 2026-11-22T23:01:13.7888681+01:00

Команда:

```powershell
curl.exe -v https://wrong.host.badssl.com > raw/a5-wrong-host.txt 2>&1
```

Повний вивід:

```text
* Host wrong.host.badssl.com:443 was resolved.
* IPv6: (none)
* IPv4: 104.154.89.105
*   Trying 104.154.89.105:443...
* schannel: disabled automatic use of client certificate
* ALPN: curl offers http/1.1
* schannel: SNI or certificate check failed: SEC_E_WRONG_PRINCIPAL (0x80090322) - The target principal name is incorrect.
* closing connection #0
curl: (60) schannel: SNI or certificate check failed: SEC_E_WRONG_PRINCIPAL (0x80090322) - The target principal name is incorrect.
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the webpage mentioned above.

```

### A.5, self-signed

Час: 2026-11-22T23:01:22.2988777+01:00

Команда:

```powershell
curl.exe -v https://self-signed.badssl.com > raw/a5-self-signed.txt 2>&1
```

Повний вивід:

```text
* Host self-signed.badssl.com:443 was resolved.
* IPv6: (none)
* IPv4: 104.154.89.105
*   Trying 104.154.89.105:443...
* schannel: disabled automatic use of client certificate
* ALPN: curl offers http/1.1
* schannel: SEC_E_UNTRUSTED_ROOT (0x80090325) - The certificate chain was issued by an authority that is not trusted.
* closing connection #0
curl: (60) schannel: SEC_E_UNTRUSTED_ROOT (0x80090325) - The certificate chain was issued by an authority that is not trusted.
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the webpage mentioned above.

```
