# Практична робота № 1

> **Особисте повторення 23.11.2026:** студент надав `Collect_PR01.ps1`, повний журнал і окремі файли результатів. Нижче першим наведено запуск асистента від 22.11.2026, а після частини A — надані студентом результати нового сеансу від 23.11.2026.

**Як я повторив роботу.** Я відкрив PowerShell, перевірив версію `curl.exe`, виконав HTTPS-запит і DNS-запит для свого домену. У виводі знайшов адресу, порт, рядки запиту та відповіді й повідомлення TLS. DNS-запит повторив через 5–7 хвилин і порівняв значення TTL. Для кожного результату я відокремив те, що побачив у виводі, від свого пояснення.


**Дисципліна:** Основи побудови інформаційних систем та мереж (ОК-13)

**Тема:** Спостереження за процесом звернення до вебресурсу. Побудова власної моделі рівнів взаємодії

| Поле | Значення |
|---|---|
| Прізвище, ім'я | Воробйов Дмитро |
| Курс, форма навчання | 2-й курс, заочна |
| Факультет | Інформаційних технологій та кібербезпеки |
| Спеціальність | F3 «Комп'ютерні науки» |
| Освітня програма | Комп'ютерні науки |
| Група | ЗКН-21 |
| Номер варіанта | 1, вибрано за дозволом користувача |
| Домен варіанта | example.com, умовно таблиця 1 |
| Середовище виконання | Windows, Windows PowerShell; curl.exe використовує Schannel |
| Версія curl | curl 8.22.0 (Windows) libcurl/8.22.0 Schannel zlib/1.3.2 WinIDN WinLDAP |
| Дата виконання | 22.11.2026 (перший запуск); 23.11.2026, 08:20–08:26 CET (повторний запуск) |

> Відповідність групи ЗКН-21 таблиці 1 не підтверджено матеріалами. Це умовно вибраний варіант, а не встановлений номер студента у списку. Перед поданням потрібно уточнити його призначення.

> Перший набір команд запустив асистент на робочій станції користувача. Студент повідомив про власний повторний запуск 23.11.2026 і надав сценарій, журнали та метадані. Походження двох наборів даних позначено окремо.

## Частина A. Збір експериментальних даних

Часові позначки нижче містять зсув `+01:00`, тобто місцевий час Europe/Brussels на дату роботи. Файли `raw/` кожної спроби збережені без редагування. У Markdown перенесено повний текст; службові символи повернення каретки у відображенні можуть давати додаткові порожні рядки. Невдалі спроби не підмінено успішними. Усі команди curl запускалися з об'єднанням стандартного виводу й потоку помилок (`2>&1`). DNS-вивід перетворено на текст командою `Out-String -Width 4096`, без відбору записів.

### A.1. Запит із діагностичним виводом

Час початку: `2026-11-22T22:54:28.3831525+01:00`.

**Команда:**

```powershell
curl.exe -v https://example.com
```

**Повний вивід:**

```text
* Could not resolve host: example.com
* Could not resolve host: example.com
* Could not resolve: example.com:443
* closing connection #0
curl: (6) Could not resolve host: example.com

```

**Результат початкової команди:** код завершення 6, адресу через системний пошук не отримано. HTTP-відповіді й тіла сторінки немає.

**Додаткова перевірка того самого домену.** Після успішного запиту `Resolve-DnsName example.com -Server 1.1.1.1` з A.3 адресу 104.20.23.154 передано curl явно. Параметр `--resolve` змінює спосіб вибору адреси, тому цей вивід не видається за результат початкової команди. Домен `example.com` і перевірку сертифіката збережено; `-k` не використано.

Час початку: `2026-11-22T22:56:33.5503255+01:00`.

**Команда:**

```powershell
curl.exe -v https://example.com --resolve example.com:443:104.20.23.154
```

**Повний вивід:**

```text
* [DNS] added example.com:443:104.20.23.154 to cache
* Hostname example.com was found in DNS cache
* Host example.com:443 was resolved.
* IPv6: (none)
* IPv4: 104.20.23.154
*   Trying 104.20.23.154:443...
* schannel: disabled automatic use of client certificate
* ALPN: curl offers http/1.1
* ALPN: server accepted http/1.1
* Established connection to example.com (104.20.23.154 port 443) from 192.168.129.83 port 50086 
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed

  0      0   0      0   0      0      0      0                              0* using HTTP/1.x
> GET / HTTP/1.1

> Host: example.com

> User-Agent: curl/8.22.0

> Accept: */*

> 

* Request completely sent off
* schannel: remote party requests renegotiation
* schannel: renegotiating SSL/TLS connection
* schannel: SSL/TLS connection renegotiated
< HTTP/1.1 200 OK

< Date: Sun, 22 Nov 2026 21:56:34 GMT

< Content-Type: text/html; charset=utf-8

< Transfer-Encoding: chunked

< Connection: keep-alive

< Server: cloudflare

< last-modified: Thu, 19 Nov 2026 22:10:26 GMT

< allow: GET, HEAD

< Accept-Ranges: bytes

< Age: 13831

< cf-cache-status: HIT

< CF-RAY: a5eb2f525b25bde4-BRU

< alt-svc: h3=":443"; ma=86400

< 

{ [589 bytes data]

100    577   0    577   0      0   1563      0                              0
100    577   0    577   0      0   1561      0                              0
100    577   0    577   0      0   1559      0                              0
* Connection #0 to host example.com:443 left intact
<!doctype html><html lang=en><head><meta charset=utf-8><link rel=icon href=data:,><meta name=viewport content="width=device-width,initial-scale=1"><title>Example Domain</title><style>html{color-scheme:light dark;background:light-dark(#eee,#222)}body{font:16px/1.6 system-ui,sans-serif;max-width:26em;margin:auto;padding:25vh 2em 2em;text-align:center}</style></head><body><p>This domain is for use in documentation examples without needing permission. This is not a service; avoid relying on it for testing and monitoring purposes.</p><script src=/s.js></script></body></html>

```

### A.2. Запит без захисту з’єднання

Час початку: `2026-11-22T22:54:28.9073154+01:00`.

**Команда:**

```powershell
curl.exe -v http://neverssl.com
```

**Повний вивід:**

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

У першій спробі отримано адресу, але з’єднання з портом 80 завершилося тайм-аутом. Тіло HTTP-відповіді тоді не отримано; повторна спроба нижче повернула `HTTP/1.1 200 OK` і повний HTML.

**Повторне виконання A.2 тією самою командою.** Початковий тайм-аут збережено вище. Час: `2026-11-22T23:02:52.9395901+01:00`.

**Команда:**

```powershell
curl.exe -v http://neverssl.com
```

**Повний вивід:**

```text
* Host neverssl.com:80 was resolved.
* IPv6: (none)
* IPv4: 34.223.124.45
*   Trying 34.223.124.45:80...
* Established connection to neverssl.com (34.223.124.45 port 80) from 192.168.129.83 port 51873 
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed

  0      0   0      0   0      0      0      0           00:15              0* using HTTP/1.x
> GET / HTTP/1.1

> Host: neverssl.com

> User-Agent: curl/8.22.0

> Accept: */*

> 

* Request completely sent off
< HTTP/1.1 200 OK

< Date: Sun, 22 Nov 2026 22:03:08 GMT

< Server: Apache/2.4.68 ()

< Upgrade: h2,h2c

< Connection: Upgrade

< Last-Modified: Wed, 29 Jun 2022 00:23:33 GMT

< ETag: "f79-5e28b29d38e93"

< Accept-Ranges: bytes

< Content-Length: 3961

< Vary: Accept-Encoding

< Content-Type: text/html; charset=UTF-8

< 

{ [3961 bytes data]

100   3961 100   3961   0      0    257      0   00:15   00:15              0
100   3961 100   3961   0      0    257      0   00:15   00:15              0
100   3961 100   3961   0      0    257      0   00:15   00:15              0
* Connection #0 to host neverssl.com:80 left intact
<html>
	<head>
		<title>NeverSSL - Connecting ... </title>
		<style>
		body {
			font-family: Montserrat, helvetica, arial, sans-serif;
			font-size: 16x;
			color: #444444;
			margin: 0;
		}
		h2 {
			font-weight: 700;
			font-size: 1.6em;
			margin-top: 30px;
		}
		p {
			line-height: 1.6em;
		}
		.container {
			max-width: 650px;
			margin: 20px auto 20px auto;
			padding-left: 15px;
			padding-right: 15px
		}
		.header {
			background-color: #42C0FD;
			color: #FFFFFF;
			padding: 10px 0 10px 0;
			font-size: 2.2em;
		}
		.notice {
			background-color: red;
			color: white;
			padding: 10px 0 10px 0;
			font-size: 1.25em;
			animation: flash 4s infinite;
		}
		@keyframes flash {
		0% {
			background-color: red;
		}
		50% {
			background-color: #AA0000;
		}
		0% {
			background-color: red;
		}
		}
		<!-- CSS from Mark Webster https://gist.github.com/markcwebster/9bdf30655cdd5279bad13993ac87c85d -->
		</style>

		<script>
			var adjectives = [ 'cool' , 'calm' , 'relaxed', 'soothing', 'serene', 'slow',
							'beautiful', 'wonderful', 'wonderous', 'fun', 'good',
							'glowing', 'inner', 'grand', 'majestic', 'astounding',
							'fine', 'splendid', 'transcendent', 'sublime', 'whole',
							'unique', 'old', 'young', 'fresh', 'clear', 'shiny',
							'shining', 'lush', 'quiet', 'bright', 'silver' ];

			var nouns =	  [ 'day', 'dawn', 'peace', 'smile', 'love', 'zen', 'laugh',
							'yawn', 'poem', 'song', 'joke', 'verse', 'kiss', 'sunrise',
							'sunset', 'eclipse', 'moon', 'rainbow', 'rain', 'plan',
							'play', 'chart', 'birds', 'stars', 'pathway', 'secret',
							'treasure', 'melody', 'magic', 'spell', 'light', 'morning'];

			var prefix =
					// Choose 3 zen adjectives
					adjectives.sort(function(){return 0.5-Math.random()}).slice(-3).join('')
					+
					// Coupled with a zen noun
					nouns.sort(function(){return 0.5-Math.random()}).slice(-1).join('');
			window.location.href = 'http://' + prefix + '.neverssl.com/online';
		</script>
	</head>
	<body>
	<noscript>
		<div class="notice">
			<div class="container">
				⚠️ JavaScript appears to be disabled. NeverSSL's cache-busting works better if you enable JavaScript for <code>neverssl.com</code>.
			</div>
		</div>
	</noscript>
	<div class="header">
		<div class="container">
		<h1>NeverSSL</h1>
		</div>
	</div>
	<div class="content">
	<div class="container">

	<h1 id="status"></h1>
	<script>document.querySelector("#status").textContent = "Connecting ...";</script>
	<noscript>

		<h2>What?</h2>
		<p>This website is for when you try to open Facebook, Google, Amazon, etc
		on a wifi network, and nothing happens. Type "http://neverssl.com"
		into your browser's url bar, and you'll be able to log on.</p>

		<h2>How?</h2>
		<p>neverssl.com will never use SSL (also known as TLS). No
		encryption, no strong authentication, no <a
		href="https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security">HSTS</a>,
		no HTTP/2.0, just plain old unencrypted HTTP and forever stuck in the dark
		ages of internet security.</p>

		<h2>Why?</h2>
		<p>Normally, that's a bad idea. You should always use SSL and secure
		encryption when possible. In fact, it's such a bad idea that most websites
		are now using https by default.</p>

		<p>And that's great, but it also means that if you're relying on
		poorly-behaved wifi networks, it can be hard to get online.  Secure
		browsers and websites using https make it impossible for those wifi
		networks to send you to a login or payment page. Basically, those networks
		can't tap into your connection just like attackers can't. Modern browsers
		are so good that they can remember when a website supports encryption and
		even if you type in the website name, they'll use https.</p>

		<p>And if the network never redirects you to this page, well as you can
		see, you're not missing much.</p>

        <a href="https://twitter.com/neverssl">Follow @neverssl</a>

	</noscript>

	</div>
	</div>

	</body>
</html>

```

### A.3. Запит до служби доменних імен

**Початковий спосіб, системний резолвер:**

Час початку: `2026-11-22T22:54:50.8269269+01:00`.

**Команда:**

```powershell
Resolve-DnsName example.com
```

**Повний вивід:**

```text
Resolve-DnsName : example.com : DNS name does not exist
At [local-user]\Documents\Study\Щерба\Виконані_роботи\pr01\collect-pr01.ps1:81 char:17
+     $result = @(Resolve-DnsName $domain 2>&1)
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (example.com:String) [Resolve-DnsName], Win32Exception
    + FullyQualifiedErrorId : DNS_ERROR_RCODE_NAME_ERROR,Microsoft.DnsClient.Commands.ResolveDnsName
 

```

Час початку: `2026-11-22T23:00:51.9029177+01:00`.

**Команда:**

```powershell
Resolve-DnsName example.com
```

**Повний вивід:**

```text
Resolve-DnsName : example.com : DNS name does not exist
At [local-user]\Documents\Study\Щерба\Виконані_роботи\pr01\collect-pr01.ps1:81 char:17
+     $result = @(Resolve-DnsName $domain 2>&1)
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (example.com:String) [Resolve-DnsName], Win32Exception
    + FullyQualifiedErrorId : DNS_ERROR_RCODE_NAME_ERROR,Microsoft.DnsClient.Commands.ResolveDnsName
 

```

В обох системних запитах немає успішної відповіді з адресою й TTL. Тому числове порівняння цих двох спроб неможливе.

**Додаткова пара вимірювань, явно вказаний DNS-сервер 1.1.1.1:**

Час початку: `2026-11-22T22:56:31.8921659+01:00`.

**Команда:**

```powershell
Resolve-DnsName example.com -Server 1.1.1.1
```

**Повний вивід:**

```text

Name                                           Type   TTL   Section    IPAddress                                
----                                           ----   ---   -------    ---------                                
example.com                                    AAAA   74    Answer     2606:4700:10::ac42:93f3                  
example.com                                    AAAA   74    Answer     2606:4700:10::6814:179a                  
example.com                                    A      147   Answer     104.20.23.154                            
example.com                                    A      147   Answer     172.66.147.243                           



```

Час початку: `2026-11-22T23:02:35.1026945+01:00`.

**Команда:**

```powershell
Resolve-DnsName example.com -Server 1.1.1.1
```

**Повний вивід:**

```text

Name                                           Type   TTL   Section    IPAddress                                
----                                           ----   ---   -------    ---------                                
example.com                                    AAAA   27    Answer     2606:4700:10::ac42:93f3                  
example.com                                    AAAA   27    Answer     2606:4700:10::6814:179a                  
example.com                                    A      85    Answer     172.66.147.243                           
example.com                                    A      85    Answer     104.20.23.154                            



```

Інтервал між додатковими запитами: **363.2 с** (приблизно 6 хвилин). Порівнюється той самий A-запис `example.com` з адресою 104.20.23.154.

| Параметр | Перше виконання | Повторне виконання |
|---|---|---|
| Час виконання | 22:56:31 | 23:02:35 |
| IP-адреса | 104.20.23.154 | 104.20.23.154 |
| Значення TTL, с | 147 | 85 |

Інші A- та AAAA-записи залишено в повних виводах вище. Для них не підставляються значення іншого запису.

### A.4. Контрольний ресурс

Час початку: `2026-11-22T23:00:52.1663911+01:00`.

**Команда:**

```powershell
curl.exe -v https://google.com
```

**Повний вивід:**

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

100    220 100    220   0      0   1703      0                              0
100    220 100    220   0      0   1698      0                              0
100    220 100    220   0      0   1693      0                              0
* Connection #0 to host google.com:443 left intact
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="https://www.google.com/">here</A>.
</BODY></HTML>

```

### A.5. Ресурси з некоректною конфігурацією сертифіката

**A.5, expired**

Час початку: `2026-11-22T23:00:52.5465667+01:00`.

**Команда:**

```powershell
curl.exe -v https://expired.badssl.com
```

**Повний вивід:**

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

**A.5, wrong.host**

Час початку: `2026-11-22T23:01:13.7888681+01:00`.

**Команда:**

```powershell
curl.exe -v https://wrong.host.badssl.com
```

**Повний вивід:**

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

**A.5, self-signed**

Час початку: `2026-11-22T23:01:22.2988777+01:00`.

**Команда:**

```powershell
curl.exe -v https://self-signed.badssl.com
```

**Повний вивід:**

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

**Повторне виконання A.5 expired тією самою командою.** Початковий тайм-аут збережено вище. Час: `2026-11-22T23:02:52.3112180+01:00`.

**Команда:**

```powershell
curl.exe -v https://expired.badssl.com
```

**Повний вивід:**

```text
* Host expired.badssl.com:443 was resolved.
* IPv6: (none)
* IPv4: 104.154.89.105
*   Trying 104.154.89.105:443...
* schannel: disabled automatic use of client certificate
* ALPN: curl offers http/1.1
* schannel: next InitializeSecurityContext failed: SEC_E_CERT_EXPIRED (0x80090328) - The received certificate has expired.
* closing connection #0
curl: (35) schannel: next InitializeSecurityContext failed: SEC_E_CERT_EXPIRED (0x80090328) - The received certificate has expired.

```

## Особисте повторення 23.11.2026: первинні журнали

Студент надав сценарій [`Collect_PR01.ps1`](raw/student-20261123-082050/Collect_PR01.ps1), повний [`terminal.txt`](raw/student-20261123-082050/terminal.txt), [`commands.txt`](raw/student-20261123-082050/commands.txt), метадані та окремі файли виводів. Нижче наведено саме ці нові дані. Для GitHub та ZIP абсолютний локальний шлях у копії транскрипту приховано; мережеві виводи не змінено. Зміни команд (`--resolve`, явний DNS-сервер) позначені у назвах проб.

| Проба | Початок (CET) | Результат |
|---|---|---|
| 00_curl_version | 2026-11-23T08:20:51.5098408+01:00 | curl exit 0 |
| A3_system_first | 2026-11-23T08:20:51.7390064+01:00 | системний DNS: помилка пошуку |
| A3_external_first | 2026-11-23T08:20:52.1234127+01:00 | DNS: отримано записи |
| A1_https | 2026-11-23T08:20:52.4824793+01:00 | curl exit 6 |
| A1_supplement_resolve | 2026-11-23T08:20:52.7232494+01:00 | curl exit 0 |
| A2_http | 2026-11-23T08:20:53.4138310+01:00 | curl exit 28 |
| A4_google | 2026-11-23T08:21:08.5694268+01:00 | curl exit 0 |
| A5_expired | 2026-11-23T08:21:09.0707266+01:00 | curl exit 35 |
| A5_wrong_host | 2026-11-23T08:21:10.4183822+01:00 | curl exit 60 |
| A5_self_signed | 2026-11-23T08:21:14.0630948+01:00 | curl exit 60 |
| A3_system_second | 2026-11-23T08:26:52.4437192+01:00 | системний DNS: помилка пошуку |
| A3_external_second | 2026-11-23T08:26:52.6179182+01:00 | DNS: отримано записи |
| A2_http_retry | 2026-11-23T08:26:52.8470868+01:00 | curl exit 0 |

Системний пошук двічі повернув `DNS name does not exist`. Через `1.1.1.1` в обох відповідях були однакові A-адреси; для них TTL змінився з 128 до 70 за інтервал 360,495 с. Це спостережувані значення, а не свідчення про причину оновлення кешу. Звичайний HTTPS-запит до `example.com` завершився кодом curl 6, додаткова команда з `--resolve` отримала `HTTP/1.1 200 OK`. Перший HTTP-запит до `neverssl.com` завершився тайм-аутом (код 28), повторний — `HTTP/1.1 200 OK`. Три перевірки badssl показали відповідно `SEC_E_CERT_EXPIRED`, `SEC_E_WRONG_PRINCIPAL` і `SEC_E_UNTRUSTED_ROOT`.

### 00_curl_version — Версія curl

Початок: `2026-11-23T08:20:51.5098408+01:00`. Кінець: `2026-11-23T08:20:51.6866691+01:00`. Код завершення: `0`.

**Команда:**

```powershell
curl.exe --version
```

**Повний вивід:**

```text
curl 8.22.0 (Windows) libcurl/8.22.0 Schannel zlib/1.3.2 WinIDN WinLDAP
Release-Date: 2026-09-03
Protocols: dict file ftp ftps gopher gophers http https imap imaps ipfs ipns ldap ldaps mqtt mqtts pop3 pop3s smtp smtps telnet tftp ws wss
Features: alt-svc AsynchDNS HSTS HTTPS-proxy IDN IPv6 Kerberos Largefile libz SPNEGO SSL SSPI threadsafe Unicode UnixSockets
```

Оригінальні файли: [`00_curl_version.output.txt`](raw/student-20261123-082050/raw/00_curl_version.output.txt), [`00_curl_version.metadata.json`](raw/student-20261123-082050/raw/00_curl_version.metadata.json).

### A3_system_first — Системний DNS, перший запит

Початок: `2026-11-23T08:20:51.7390064+01:00`. Кінець: `2026-11-23T08:20:52.0925138+01:00`. DNS-команда; код завершення curl не застосовується.

**Команда:**

```powershell
Resolve-DnsName example.com -ErrorAction Continue 2>&1 | Out-String -Width 4096
```

**Повний вивід:**

```text
Resolve-DnsName : example.com : DNS name does not exist
At line:118 char:28
+ ...    $items = @(Resolve-DnsName $pr01Domain -ErrorAction Continue 2>&1)
+                   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (example.com:String) [Resolve-DnsName], Win32Exception
    + FullyQualifiedErrorId : DNS_ERROR_RCODE_NAME_ERROR,Microsoft.DnsClient.Commands.ResolveDnsName
 
```

Оригінальні файли: [`A3_system_first.output.txt`](raw/student-20261123-082050/raw/A3_system_first.output.txt), [`A3_system_first.metadata.json`](raw/student-20261123-082050/raw/A3_system_first.metadata.json).

### A3_external_first — DNS 1.1.1.1, перший запит

Початок: `2026-11-23T08:20:52.1234127+01:00`. Кінець: `2026-11-23T08:20:52.4679478+01:00`. DNS-команда; код завершення curl не застосовується.

**Команда:**

```powershell
Resolve-DnsName example.com -Server 1.1.1.1 -ErrorAction Continue 2>&1 | Out-String -Width 4096
```

**Повний вивід:**

```text

Name                                           Type   TTL   Section    IPAddress                                
----                                           ----   ---   -------    ---------                                
example.com                                    AAAA   115   Answer     2606:4700:10::ac42:93f3                  
example.com                                    AAAA   115   Answer     2606:4700:10::6814:179a                  
example.com                                    A      128   Answer     172.66.147.243                           
example.com                                    A      128   Answer     104.20.23.154                            
```

Оригінальні файли: [`A3_external_first.output.txt`](raw/student-20261123-082050/raw/A3_external_first.output.txt), [`A3_external_first.metadata.json`](raw/student-20261123-082050/raw/A3_external_first.metadata.json).

### A1_https — HTTPS до example.com

Початок: `2026-11-23T08:20:52.4824793+01:00`. Кінець: `2026-11-23T08:20:52.6524562+01:00`. Код завершення: `6`.

**Команда:**

```powershell
curl.exe -v --connect-timeout 15 --max-time 45 --stderr - https://example.com
```

**Повний вивід:**

```text
* Could not resolve host: example.com
* Could not resolve host: example.com
* Could not resolve: example.com:443
* closing connection #0
curl: (6) Could not resolve host: example.com
```

Оригінальні файли: [`A1_https.output.txt`](raw/student-20261123-082050/raw/A1_https.output.txt), [`A1_https.metadata.json`](raw/student-20261123-082050/raw/A1_https.metadata.json).

### A1_supplement_resolve — HTTPS із --resolve

Початок: `2026-11-23T08:20:52.7232494+01:00`. Кінець: `2026-11-23T08:20:53.4088194+01:00`. Код завершення: `0`.

**Команда:**

```powershell
curl.exe -v --connect-timeout 15 --max-time 45 --stderr - https://example.com --resolve example.com:443:172.66.147.243
```

**Повний вивід:**

```text
* [DNS] added example.com:443:172.66.147.243 to cache
* Hostname example.com was found in DNS cache
* Host example.com:443 was resolved.
* IPv6: (none)
* IPv4: 172.66.147.243
*   Trying 172.66.147.243:443...
* schannel: disabled automatic use of client certificate
* ALPN: curl offers http/1.1
* ALPN: server accepted http/1.1
* Established connection to example.com (172.66.147.243 port 443) from 192.168.129.83 port 53536 
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed

  0      0   0      0   0      0      0      0                              0* using HTTP/1.x
> GET / HTTP/1.1
> Host: example.com
> User-Agent: curl/8.22.0
> Accept: */*
> 
* Request completely sent off
* schannel: remote party requests renegotiation
* schannel: renegotiating SSL/TLS connection
* schannel: SSL/TLS connection renegotiated
< HTTP/1.1 200 OK
< Date: Mon, 23 Nov 2026 07:20:52 GMT
< Content-Type: text/html; charset=utf-8
< Transfer-Encoding: chunked
< Connection: keep-alive
< Server: cloudflare
< last-modified: Thu, 19 Nov 2026 22:10:26 GMT
< allow: GET, HEAD
< Accept-Ranges: bytes
< Age: 1994
< cf-cache-status: HIT
< CF-RAY: a5ee69f1cab82211-BRU
< alt-svc: h3=":443"; ma=86400
< 
{ [589 bytes data]
<!doctype html><html lang=en><head><meta charset=utf-8><link rel=icon href=data:,><meta name=viewport content="width=device-width,initial-scale=1"><title>Example Domain</title><style>html{color-scheme:light dark;background:light-dark(#eee,#222)}body{font:16px/1.6 system-ui,sans-serif;max-width:26em;margin:auto;padding:25vh 2em 2em;text-align:center}</style></head><body><p>This domain is for use in documentation examples without needing permission. This is not a service; avoid relying on it for testing and monitoring purposes.</p><script src=/s.js></script></body></html>

100    577   0    577   0      0   1089      0                              0
100    577   0    577   0      0   1089      0                              0
100    577   0    577   0      0   1089      0                              0
* Connection #0 to host example.com:443 left intact
```

Оригінальні файли: [`A1_supplement_resolve.output.txt`](raw/student-20261123-082050/raw/A1_supplement_resolve.output.txt), [`A1_supplement_resolve.metadata.json`](raw/student-20261123-082050/raw/A1_supplement_resolve.metadata.json).

### A2_http — HTTP до neverssl.com, перша спроба

Початок: `2026-11-23T08:20:53.4138310+01:00`. Кінець: `2026-11-23T08:21:08.5583182+01:00`. Код завершення: `28`.

**Команда:**

```powershell
curl.exe -v --connect-timeout 15 --max-time 45 --stderr - http://neverssl.com
```

**Повний вивід:**

```text
* Host neverssl.com:80 was resolved.
* IPv6: (none)
* IPv4: 34.223.124.45
*   Trying 34.223.124.45:80...
* Connection timed out after 15002 milliseconds
* closing connection #0
curl: (28) Connection timed out after 15002 milliseconds
```

Оригінальні файли: [`A2_http.output.txt`](raw/student-20261123-082050/raw/A2_http.output.txt), [`A2_http.metadata.json`](raw/student-20261123-082050/raw/A2_http.metadata.json).

### A4_google — Контрольний запит до google.com

Початок: `2026-11-23T08:21:08.5694268+01:00`. Кінець: `2026-11-23T08:21:09.0595998+01:00`. Код завершення: `0`.

**Команда:**

```powershell
curl.exe -v --connect-timeout 15 --max-time 45 --stderr - https://google.com
```

**Повний вивід:**

```text
* Host google.com:443 was resolved.
* IPv6: (none)
* IPv4: 142.251.142.206
*   Trying 142.251.142.206:443...
* schannel: disabled automatic use of client certificate
* ALPN: curl offers http/1.1
* ALPN: server accepted http/1.1
* Established connection to google.com (142.251.142.206 port 443) from 192.168.129.83 port 53539 
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
< Content-Security-Policy-Report-Only: object-src 'none';base-uri 'self';script-src 'nonce-gloephJpBVblT46lrbxpVw' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
< Date: Mon, 23 Nov 2026 07:21:08 GMT
< Expires: Wed, 23 Dec 2026 07:21:08 GMT
< Cache-Control: public, max-age=2592000
< Server: gws
< Content-Length: 220
< X-XSS-Protection: 0
< X-Frame-Options: SAMEORIGIN
< Alt-Svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000
< 
{ [220 bytes data]
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="https://www.google.com/">here</A>.
</BODY></HTML>

100    220 100    220   0      0    813      0                              0
100    220 100    220   0      0    812      0                              0
100    220 100    220   0      0    812      0                              0
* Connection #0 to host google.com:443 left intact
```

Оригінальні файли: [`A4_google.output.txt`](raw/student-20261123-082050/raw/A4_google.output.txt), [`A4_google.metadata.json`](raw/student-20261123-082050/raw/A4_google.metadata.json).

### A5_expired — Прострочений сертифікат

Початок: `2026-11-23T08:21:09.0707266+01:00`. Кінець: `2026-11-23T08:21:10.4132579+01:00`. Код завершення: `35`.

**Команда:**

```powershell
curl.exe -v --connect-timeout 15 --max-time 45 --stderr - https://expired.badssl.com
```

**Повний вивід:**

```text
* Host expired.badssl.com:443 was resolved.
* IPv6: (none)
* IPv4: 104.154.89.105
*   Trying 104.154.89.105:443...
* schannel: disabled automatic use of client certificate
* ALPN: curl offers http/1.1
* schannel: next InitializeSecurityContext failed: SEC_E_CERT_EXPIRED (0x80090328) - The received certificate has expired.
* closing connection #0
curl: (35) schannel: next InitializeSecurityContext failed: SEC_E_CERT_EXPIRED (0x80090328) - The received certificate has expired.
```

Оригінальні файли: [`A5_expired.output.txt`](raw/student-20261123-082050/raw/A5_expired.output.txt), [`A5_expired.metadata.json`](raw/student-20261123-082050/raw/A5_expired.metadata.json).

### A5_wrong_host — Невідповідне ім’я сертифіката

Початок: `2026-11-23T08:21:10.4183822+01:00`. Кінець: `2026-11-23T08:21:14.0564526+01:00`. Код завершення: `60`.

**Команда:**

```powershell
curl.exe -v --connect-timeout 15 --max-time 45 --stderr - https://wrong.host.badssl.com
```

**Повний вивід:**

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

Оригінальні файли: [`A5_wrong_host.output.txt`](raw/student-20261123-082050/raw/A5_wrong_host.output.txt), [`A5_wrong_host.metadata.json`](raw/student-20261123-082050/raw/A5_wrong_host.metadata.json).

### A5_self_signed — Самопідписаний сертифікат

Початок: `2026-11-23T08:21:14.0630948+01:00`. Кінець: `2026-11-23T08:21:15.4241141+01:00`. Код завершення: `60`.

**Команда:**

```powershell
curl.exe -v --connect-timeout 15 --max-time 45 --stderr - https://self-signed.badssl.com
```

**Повний вивід:**

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

Оригінальні файли: [`A5_self_signed.output.txt`](raw/student-20261123-082050/raw/A5_self_signed.output.txt), [`A5_self_signed.metadata.json`](raw/student-20261123-082050/raw/A5_self_signed.metadata.json).

### A3_system_second — Системний DNS, другий запит

Початок: `2026-11-23T08:26:52.4437192+01:00`. Кінець: `2026-11-23T08:26:52.6038931+01:00`. DNS-команда; код завершення curl не застосовується.

**Команда:**

```powershell
Resolve-DnsName example.com -ErrorAction Continue 2>&1 | Out-String -Width 4096
```

**Повний вивід:**

```text
Resolve-DnsName : example.com : DNS name does not exist
At line:118 char:28
+ ...    $items = @(Resolve-DnsName $pr01Domain -ErrorAction Continue 2>&1)
+                   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (example.com:String) [Resolve-DnsName], Win32Exception
    + FullyQualifiedErrorId : DNS_ERROR_RCODE_NAME_ERROR,Microsoft.DnsClient.Commands.ResolveDnsName
 
```

Оригінальні файли: [`A3_system_second.output.txt`](raw/student-20261123-082050/raw/A3_system_second.output.txt), [`A3_system_second.metadata.json`](raw/student-20261123-082050/raw/A3_system_second.metadata.json).

### A3_external_second — DNS 1.1.1.1, другий запит

Початок: `2026-11-23T08:26:52.6179182+01:00`. Кінець: `2026-11-23T08:26:52.6629903+01:00`. DNS-команда; код завершення curl не застосовується.

**Команда:**

```powershell
Resolve-DnsName example.com -Server 1.1.1.1 -ErrorAction Continue 2>&1 | Out-String -Width 4096
```

**Повний вивід:**

```text

Name                                           Type   TTL   Section    IPAddress                                
----                                           ----   ---   -------    ---------                                
example.com                                    AAAA   54    Answer     2606:4700:10::ac42:93f3                  
example.com                                    AAAA   54    Answer     2606:4700:10::6814:179a                  
example.com                                    A      70    Answer     172.66.147.243                           
example.com                                    A      70    Answer     104.20.23.154                            
```

Оригінальні файли: [`A3_external_second.output.txt`](raw/student-20261123-082050/raw/A3_external_second.output.txt), [`A3_external_second.metadata.json`](raw/student-20261123-082050/raw/A3_external_second.metadata.json).

### A2_http_retry — HTTP до neverssl.com, повторна спроба

Початок: `2026-11-23T08:26:52.8470868+01:00`. Кінець: `2026-11-23T08:26:56.2693674+01:00`. Код завершення: `0`.

**Команда:**

```powershell
curl.exe -v --connect-timeout 15 --max-time 45 --stderr - http://neverssl.com
```

**Повний вивід:**

```text
* Host neverssl.com:80 was resolved.
* IPv6: (none)
* IPv4: 34.223.124.45
*   Trying 34.223.124.45:80...
* Established connection to neverssl.com (34.223.124.45 port 80) from 192.168.129.83 port 52156 
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed

  0      0   0      0   0      0      0      0           00:03              0* using HTTP/1.x
> GET / HTTP/1.1
> Host: neverssl.com
> User-Agent: curl/8.22.0
> Accept: */*
> 
* Request completely sent off
< HTTP/1.1 200 OK
< Date: Mon, 23 Nov 2026 07:26:55 GMT
< Server: Apache/2.4.68 ()
< Upgrade: h2,h2c
< Connection: Upgrade
< Last-Modified: Wed, 29 Jun 2022 00:23:33 GMT
< ETag: "f79-5e28b29d38e93"
< Accept-Ranges: bytes
< Content-Length: 3961
< Vary: Accept-Encoding
< Content-Type: text/html; charset=UTF-8
< 
{ [3961 bytes data]
<html>
	<head>
		<title>NeverSSL - Connecting ... </title>
		<style>
		body {
			font-family: Montserrat, helvetica, arial, sans-serif;
			font-size: 16x;
			color: #444444;
			margin: 0;
		}
		h2 {
			font-weight: 700;
			font-size: 1.6em;
			margin-top: 30px;
		}
		p {
			line-height: 1.6em;
		}
		.container {
			max-width: 650px;
			margin: 20px auto 20px auto;
			padding-left: 15px;
			padding-right: 15px
		}
		.header {
			background-color: #42C0FD;
			color: #FFFFFF;
			padding: 10px 0 10px 0;
			font-size: 2.2em;
		}
		.notice {
			background-color: red;
			color: white;
			padding: 10px 0 10px 0;
			font-size: 1.25em;
			animation: flash 4s infinite;
		}
		@keyframes flash {
		0% {
			background-color: red;
		}
		50% {
			background-color: #AA0000;
		}
		0% {
			background-color: red;
		}
		}
		<!-- CSS from Mark Webster https://gist.github.com/markcwebster/9bdf30655cdd5279bad13993ac87c85d -->
		</style>

		<script>
			var adjectives = [ 'cool' , 'calm' , 'relaxed', 'soothing', 'serene', 'slow',
							'beautiful', 'wonderful', 'wonderous', 'fun', 'good',
							'glowing', 'inner', 'grand', 'majestic', 'astounding',
							'fine', 'splendid', 'transcendent', 'sublime', 'whole',
							'unique', 'old', 'young', 'fresh', 'clear', 'shiny',
							'shining', 'lush', 'quiet', 'bright', 'silver' ];

			var nouns =	  [ 'day', 'dawn', 'peace', 'smile', 'love', 'zen', 'laugh',
							'yawn', 'poem', 'song', 'joke', 'verse', 'kiss', 'sunrise',
							'sunset', 'eclipse', 'moon', 'rainbow', 'rain', 'plan',
							'play', 'chart', 'birds', 'stars', 'pathway', 'secret',
							'treasure', 'melody', 'magic', 'spell', 'light', 'morning'];

			var prefix =
					// Choose 3 zen adjectives
					adjectives.sort(function(){return 0.5-Math.random()}).slice(-3).join('')
					+
					// Coupled with a zen noun
					nouns.sort(function(){return 0.5-Math.random()}).slice(-1).join('');
			window.location.href = 'http://' + prefix + '.neverssl.com/online';
		</script>
	</head>
	<body>
	<noscript>
		<div class="notice">
			<div class="container">
				⚠️ JavaScript appears to be disabled. NeverSSL's cache-busting works better if you enable JavaScript for <code>neverssl.com</code>.
			</div>
		</div>
	</noscript>
	<div class="header">
		<div class="container">
		<h1>NeverSSL</h1>
		</div>
	</div>
	<div class="content">
	<div class="container">

	<h1 id="status"></h1>
	<script>document.querySelector("#status").textContent = "Connecting ...";</script>
	<noscript>

		<h2>What?</h2>
		<p>This website is for when you try to open Facebook, Google, Amazon, etc
		on a wifi network, and nothing happens. Type "http://neverssl.com"
		into your browser's url bar, and you'll be able to log on.</p>

		<h2>How?</h2>
		<p>neverssl.com will never use SSL (also known as TLS). No
		encryption, no strong authentication, no <a
		href="https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security">HSTS</a>,
		no HTTP/2.0, just plain old unencrypted HTTP and forever stuck in the dark
		ages of internet security.</p>

		<h2>Why?</h2>
		<p>Normally, that's a bad idea. You should always use SSL and secure
		encryption when possible. In fact, it's such a bad idea that most websites
		are now using https by default.</p>

		<p>And that's great, but it also means that if you're relying on
		poorly-behaved wifi networks, it can be hard to get online.  Secure
		browsers and websites using https make it impossible for those wifi
		networks to send you to a login or payment page. Basically, those networks
		can't tap into your connection just like attackers can't. Modern browsers
		are so good that they can remember when a website supports encryption and
		even if you type in the website name, they'll use https.</p>

		<p>And if the network never redirects you to this page, well as you can
		see, you're not missing much.</p>

        <a href="https://twitter.com/neverssl">Follow @neverssl</a>

	</noscript>

	</div>
	</div>

	</body>
</html>

100   3961 100   3961   0      0   1187      0   00:03   00:03              0
100   3961 100   3961   0      0   1187      0   00:03   00:03              0
100   3961 100   3961   0      0   1187      0   00:03   00:03              0
* Connection #0 to host neverssl.com:80 left intact
```

Оригінальні файли: [`A2_http_retry.output.txt`](raw/student-20261123-082050/raw/A2_http_retry.output.txt), [`A2_http_retry.metadata.json`](raw/student-20261123-082050/raw/A2_http_retry.metadata.json).

### Порівняння TTL з наданого CSV

Оригінал: [`TTL_1_1_1_1.csv`](raw/student-20261123-082050/TTL_1_1_1_1.csv). Для системного DNS немає спільних записів: обидва запити завершилися помилкою.

| Запис | Адреса | Перший TTL, с | Другий TTL, с | Інтервал, с |
|---|---|---:|---:|---:|
| AAAA | `2606:4700:10::ac42:93f3` | 115 | 54 | 360.495 |
| AAAA | `2606:4700:10::6814:179a` | 115 | 54 | 360.495 |
| A | `172.66.147.243` | 128 | 70 | 360.495 |
| A | `104.20.23.154` | 128 | 70 | 360.495 |

## Частина B. Власна модель рівнів

Точні рядки та адреси в таблиці нижче взято з першого запуску 22.11.2026. Повторний запуск 23.11.2026 підтвердив ті самі етапи, але мав іншу IPv4-адресу й часові значення; його виводи наведено окремо вище.

**Кількість виділених груп:** 4.

Це поділ саме видимих повідомлень. Назви не запозичені з готової моделі OSI. Додаткова успішна перевірка A.1 використовується поряд із початковими невдалими спробами; вона позначена окремо, бо команда містить `--resolve`.

| № | Назва групи (власне формулювання) | Рядки виводу, віднесені до групи | Обґрунтування |
|---|---|---|---|
| 1 | Вміст, заради якого звертаємося | HTML із `<title>Example Domain</title>` у додатковій A.1 | Це вже сам текст сторінки, найближчий до того, що потрібне користувачеві. curl показує розмітку, а не малює сторінку. |
| 2 | Прохання до сервера та опис відповіді | `> GET / HTTP/1.1`; `> Host: example.com`; `< HTTP/1.1 200 OK`; `< Content-Type: text/html; charset=utf-8` | Запит указує, що отримати; статус і заголовки описують відповідь. Сюди ж належать інші поля запиту й відповіді з позначками `>` та `<`. |
| 3 | Перевірка й узгодження захищеного обміну | `* schannel: disabled automatic use of client certificate`; `* schannel: renegotiating SSL/TLS connection`; `* schannel: SSL/TLS connection renegotiated` | У цих повідомленнях ідеться про захищене з'єднання. Помилки сертифікатів A.5 теж належать сюди, якщо перевірка до них дійшла. |
| 4 | Пошук адреси та спроба дістатися вузла | `* Could not resolve host: example.com`; `* IPv4: 104.20.23.154`; `*   Trying 104.20.23.154:443...`; `* Established connection to example.com (104.20.23.154 port 443) from 192.168.129.83 port 50086 ` | Тут визначається адреса, робиться спроба підключення та фіксується, чи вдалася вона. Сюди ж віднесено відповіді Resolve-DnsName, TTL, помилку DNS та тайм-аут A.2. |

Порядок іде від змісту сторінки до умов, без яких обмін не почнеться. Це порядок близькості до користувача, а не часова послідовність: у часі пошук адреси передує отриманню HTML. У цих журналах немає прямих даних про сигнал у кабелі чи радіоефірі, тому окрему групу для них не додано.

**Рядки, які не вдалося віднести до жодної групи:**

| Рядок виводу | Причина утруднення |
|---|---|
| `* ALPN: curl offers http/1.1` | Рядок одночасно стосується узгодження з'єднання і назви протоколу обміну; за самим повідомленням межу між групами 2 та 3 не проведено. |
| `* ALPN: server accepted http/1.1` | Та сама межа між узгодженням захищеного обміну та способом передавання HTTP. |
| `* using HTTP/1.x` | Це службове повідомлення клієнта про вибраний режим, а не сам запит чи відповідь. |

Шкалу прогресу curl та `{ [589 bytes data]` розглянуто як службове відображення утиліти, а не як окремий рівень мережі. Рядок про залишене відкритим з'єднання віднесено до групи 4; `[DNS] added ... to cache` — теж до групи 4, із застереженням, що цей запис додано параметром `--resolve`, а не отримано curl від DNS-сервера.

---

## Контрольні питання

**1. Скільки рядків діагностичного виводу передує отриманню даних сторінки (завдання A.1)?**

У початковій A.1 сторінку взагалі не отримано: є 5 рядків повідомлень про невдалий пошук адреси. Тому для цієї спроби немає події «отримання даних сторінки», перед якою можна було б визначити шукане число.

У додатковій успішній A.1 до позначки `{ [589 bytes data]` є **34 службові повідомлення з позначками `*`, `>` або `<`**. Рахувалися також порожні завершальні рядки `>` і `<`, але не шкала прогресу, її заголовок і порожні рядки відображення. `* using HTTP/1.x` враховано як окреме повідомлення, хоча при перенаправленні потоків воно записалося після шкали прогресу в тому самому фізичному рядку. Повідомлення `* Connection #0 ... left intact` уже йде після позначки отриманих даних і не враховано. Таким чином, правило підрахунку явно відрізняє повідомлення від рядків, які бачить редактор.

**2. Які рядки наявні у виводі A.1 і відсутні у виводі A.2? Чим це зумовлено?**

Початкова A.1 містить `* Could not resolve host: example.com`, а A.2 — повідомлення про невдале підключення до вже знайденої адреси 34.223.124.45. Це різні етапи відмови.

У додатковій успішній A.1 є `* schannel: renegotiating SSL/TLS connection` і `* schannel: SSL/TLS connection renegotiated`, яких немає в обох спробах A.2. HTTPS використовує захищене з’єднання, HTTP — ні. Перша A.2 зупинилася на підключенні, тому відсутність HTTP-запиту й відповіді саме там не пояснюється лише відсутністю шифрування. Повторна A.2 успішна: у ній є `> GET / HTTP/1.1` та `< HTTP/1.1 200 OK`, але немає повідомлень Schannel/TLS. Саме цю успішну пробу можна порівнювати з додатковою успішною A.1.

**3. Звідки у виводі з'явилося значення `443`, якщо його не було вказано в адресі?**

Для схеми `https` порт 443 використовується за замовчуванням. У початковій команді його не було в URL, але є рядок `* Could not resolve: example.com:443`. У додатковій пробі порт також явно записаний у параметрі `--resolve`. Джерело пояснення — лекція 1, слайди про URI і порти.

**4. Як змінилося значення TTL між двома запитами (A.3)? Що означає це число?**

У системних запитах TTL не отримано. У додатковій парі для A-запису 104.20.23.154 він змінився з 147 до 85 с, тобто зменшився на 62 с. За методичкою це залишок часу зберігання запису в кеші резолвера. Між запитами минуло 363.2 с, більше за перший залишок 147 с; отже, просте віднімання всього інтервалу тут не підходить: перше значення вже встигло б вичерпатися. Можливе оновлення кешу; самі ці два запити не показують безперервного відліку одного незмінного запису й не встановлюють точного моменту оновлення.

**5. Чим відрізняються три причини помилок із завдання A.5?**

| Випадок | Причина недовіри, описана в лекції 1 |
|---|---|
| `expired` | Строк дії сертифіката завершився. |
| `wrong.host` | Ім'я сервера в адресі не відповідає імені, на яке видано сертифікат. |
| `self-signed` | Сертифікат підписаний самим власником і не утворює довіреного для клієнта ланцюжка. |

Ці пояснення потрібно співвідносити з фактичними повідомленнями A.5; мережевий тайм-аут не є доказом жодної із трьох причин. Аналіз конкретних повідомлень наведено у примітках нижче.

**6. Три рядки з власних виводів, про які не йшлося на лекції 1:**

| № | Рядок виводу | Джерело |
|---|---|---|
| 1 | `* ALPN: curl offers http/1.1` | A.1, додаткова перевірка |
| 2 | `* schannel: remote party requests renegotiation` | A.1, додаткова перевірка |
| 3 | `< Transfer-Encoding: chunked` | A.1, додаткова перевірка |

Рядки звірено з обома наданими файлами лекції 1; цих повідомлень і їхнього розбору там немає. Пояснення за умовою не додається.

## Висновки

**D.1. Що виявилося неочевидним або несподіваним**

Несподіваним було те, що звичайний запит до example.com не знайшов адресу, хоча додатковий запит до іншого DNS-сервера повернув адреси цього домену. У першій спробі є рядок `* Could not resolve host: example.com`. Після передавання реально отриманої адреси через `--resolve` той самий ресурс відповів `< HTTP/1.1 200 OK`. Отже, відсутність сторінки сама по собі не доводить, що вебсервер не працює. Для neverssl.com ситуація інша: адресу вже знайдено, але підключення до порту 80 закінчилося тайм-аутом. Повторна команда до neverssl.com уже повернула 200 OK. Отже, початковий тайм-аут не доводить постійної недоступності ресурсу; для порівняння використано успішний повтор. Новий сеанс 23.11.2026 показав таку саму послідовність: помилка системного DNS, успіх із `--resolve`, початковий тайм-аут HTTP та успішний повтор.

**D.2. Чому саме така кількість груп у частині B**

Обрано чотири групи, тому що у виводі окремо видно вміст сторінки, запит і опис відповіді, повідомлення про захищений обмін, а також пошук адреси та підключення. Це достатньо, щоб пояснити різницю між двома невдалими початковими пробами й успішною додатковою. Пошук адреси та підключення поки об'єднані, бо обидва готують доступ до вузла. Їх можна було б розділити, якби потрібне було докладніше порівняння саме цих етапів. Окремої групи сигналів немає: командні журнали їх не показують.

**D.3. Питання, яке залишилося без відповіді**

Не з'ясовано, чому системний пошук повернув відсутність example.com, а явно вказаний DNS-сервер дав адреси. Перевірено обидва способи, проте налаштування й внутрішній кеш системного резолвера докладно не досліджувалися. Тому конкретну причину цієї відмінності не стверджую.

## Використання штучного інтелекту

**Факт використання:** використано.

**Установлений рівень:** Р3 — ШІ як співвиконавець.

**Фактичний обсяг:** асистент підготував сценарії, запустив перші команди 22.11.2026, зберіг їхні результати й підготував групування, відповіді та висновки. Студент повідомив про власний повторний запуск 23.11.2026 та надав сценарій, журнали й метадані. Асистент звірив їх і додав до звіту. Усний захист ще не відбувся.

| Система | Модель | Період |
|---|---|---|
| OpenAI Codex | GPT-6; точний варіант моделі не підтверджено | 22–23.11.2026 |

### Промпти

### Дослівні звернення користувача

Період: 22.11.2026. Початкові звернення наведено нижче; [повний перелік звернень за 22–23.11.2026](ПРОМПТИ.md) охоплює також пізніші уточнення, надання студентом журналів і виправлення звітів. У повному переліку один локальний шлях приховано перед публікацією; це позначено у файлі.

#### 1. Початкове доручення

```text
\*\*Що потрібно зробити з цими формами та PDF?\*\*\
\
Ты ученик вотрого круса Факультет Інформаційних технологій та кібербезпеки Спеціальність F3 Комп'ютерні науки Назва освітньої програми Комп'ютерні науки  \
сделай и используй только знания из этих фалов, расширенных знатнйи и супер способностей у тебя нет, просто если что у тебя есть гугл или книги котрые есть в поисании этих фалов, выполни все как написно и сделай все ка просят в этих файлах. если нужно поклчай агентов, сверяйся, переключай с сол на астру и наоборот
```

#### 2. Підтвердження імені Воробйов Дмитро

```text
да
```

#### 3. Уточнення папки

```text
Выполняй задание из только из папки Щерба
```

#### 4. Посилання щодо Markdown

```text
[https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)
```

#### 5. Посилання на стенд TLS

```text
[https://github.com/sergeyscherba/opism-lab-TLS](https://github.com/sergeyscherba/opism-lab-TLS)
```

#### 6–7. Зображення

Користувач надіслав два зображення без власного супровідного тексту: повідомлення викладача про формат `se-<номер групи>-<номер за списком>` з прикладом `se-201-01` та фрагмент розкладу з групою `ЗКН-21`, другим курсом і заочною формою. Це опис вкладень, а не дослівний текст промпта. Приклад на першому зображенні не використано як персональний варіант.

#### 8. Дозвіл вибрати номер

```text
любой номер выбери сам
```

#### 9. Повторне уточнення джерел

```text
теперь у тебя есть все что надо сылки , файоы использй только в папке Щерба
```

#### 10. Підготовка до захисту

```text
как закончишь выдай теперь мне полное поисание как я делал, как мне защитьить мою работу и так далее, чтоб я смог защитить ирссказать преподателю.
```

#### 11–12. Економія ресурсів

Користувач двічі надіслав однаковий текст:

```text
ели можешь снизь потребление токенов, может полкючай не супре агента, а просто агента котрый справиться с этой задачей дешевле
```

#### Фактичні дії та межі підтвердження

Асистент прочитав матеріали, підготував і запустив перші команди на комп'ютері користувача та в локальних Docker-стендах, зберіг справжні журнали і підготував пояснення. Жоден мережевий результат не підмінено очікуваним. Користувач обрав область роботи, підтвердив ім'я, надав групу та дозволив довільний номер. Для ПР1 студент надав окремі матеріали повторного запуску 23.11.2026; асистент додав їх без підміни початкових вимірювань.

Політика дисципліни вимагає особистого отримання артефактів студентом. Матеріали наданого студентом повторного запуску містяться вище. Перед поданням слід перевірити пояснення, уточнити призначений варіант і правдиво доповнити декларацію власними перевірками та змінами.


### Дії з отриманим результатом

Асистент звірив домен з таблицею, зберіг початкові помилки, перевірив час між DNS-запитами, зіставив той самий A-запис, відокремив змінені команди та перевірив наведені цитати за журналами. Після надання студентом нового пакета перевірено команди, час повторних DNS-запитів, коди завершення й наведені виводи. Власні зміни студента до тексту звіту окремо не повідомлені.

### Підтвердження

Походження першого та повторного наборів даних наведено на початку звіту. Повторний набір підтверджено сценарієм, транскриптом і файлами результатів, які надав студент. Перед поданням потрібно уточнити призначений варіант і виконати вимоги викладача щодо власних артефактів.

## Примітки виконавця

1. Початковий запуск у середовищі з обмеженим доступом дав `Access is denied` для DNS. Його журнали збережено окремо, нижче. Після запуску з мережевим доступом системний DNS уже повернув `DNS name does not exist`; це інша помилка.
2. Основні завдання A.1–A.5 виконано з початковими доменами. Успішна A.1 та числові TTL отримані додатковими, явно зміненими командами. Вони не підміняють початкові невдалі спроби.
3. Виводи curl не скорочено: включено діагностику, заголовки, повідомлення про помилки, шкалу прогресу та тіло відповіді, якщо воно надійшло.

| Фактична проба | Підтвердження у виводі | Висновок |
|---|---|---|
| expired, перша | `curl: (28)` і `Timed out` | Перша спроба не дійшла до перевірки сертифіката. |
| expired, повторна | `SEC_E_CERT_EXPIRED (0x80090328)`; `The received certificate has expired.` | Підтверджено прострочений сертифікат. |
| wrong.host | `SEC_E_WRONG_PRINCIPAL (0x80090322)`; `The target principal name is incorrect.` | Підтверджено невідповідність імені. |
| self-signed | `SEC_E_UNTRUSTED_ROOT (0x80090325)`; `The certificate chain was issued by an authority that is not trusted.` | Підтверджено недовірений ланцюжок. |

Код завершення curl для повторної expired дорівнює 35, для wrong.host і self-signed — 60. Тому причину визначено за конкретним текстом Schannel, а не за припущенням, що всі три команди мають однаковий числовий код. Альтернативний спосіб A.5 з підміною імені не знадобився: усі три типові причини відтворено реальними командами.

## Додаткові збережені технічні спроби

Перший запуск до надання мережевого доступу припинено після першого DNS-запиту; другу DNS-пробу в ньому не виконано. Його три отримані журнали:

**Команда:**

```powershell
curl.exe -v https://example.com
```

**Повний вивід:**

```text
* Could not resolve host: example.com
* Could not resolve host: example.com
* Could not resolve: example.com:443
* closing connection #0
curl: (6) Could not resolve host: example.com

```

**Команда:**

```powershell
curl.exe -v http://neverssl.com
```

**Повний вивід:**

```text
* Could not resolve host: neverssl.com
* Could not resolve host: neverssl.com
* Could not resolve: neverssl.com:80
* closing connection #0
curl: (6) Could not resolve host: neverssl.com

```

**Команда:**

```powershell
Resolve-DnsName example.com
```

**Повний вивід:**

```text
Resolve-DnsName : example.com : Access is denied
At [local-user]\Documents\Study\Щерба\Виконані_роботи\pr01\collect-pr01.ps1:81 char:17
+     $result = @(Resolve-DnsName $domain 2>&1)
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (example.com:String) [Resolve-DnsName], Win32Exception
    + FullyQualifiedErrorId : 5,Microsoft.DnsClient.Commands.ResolveDnsName
 

```

Окрема повторна перевірка початкової A.1 до додавання `--resolve`:

**Команда:**

```powershell
curl.exe -v https://example.com
```

**Повний вивід:**

```text
* Could not resolve host: example.com
* Could not resolve host: example.com
* Could not resolve: example.com:443
* closing connection #0
curl: (6) Could not resolve host: example.com

```

## Використані матеріали

- «ОПІСМ_практична_01.pdf»: завдання, варіанти, формат звіту, пояснення TTL.
- «ОПІСМ_практична_01_бланк.md»: структура звіту.
- «ОПІСМ_ЛК1_Вступ_постановка_питання.pdf» і «ОПІСМ_ЛК1.pdf»: URI, порт 443, запит і відповідь, пошук імені, перевірка сертифіката; звірка питання 6.
- «ОПІСМ_політика_ШІ.pdf»: декларування допомоги та вимога особистого отримання артефактів.
- Власні фактичні журнали цієї сесії в `runs/` і `supplement/`.
