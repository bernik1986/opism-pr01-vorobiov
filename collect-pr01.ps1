param([switch]$AssistantRun)
# Run this script personally in Windows PowerShell. It makes real requests.
# It never changes README.md and never publishes files.
$ErrorActionPreference = 'Stop'
$domains = @{
    1 = @('example.com','example.org','example.net','iana.org','rfc-editor.org','ietf.org','w3.org','ripe.net','isc.org','iso.org','nginx.org','openbsd.org','netbsd.org','freebsd.org','gnu.org','fsf.org','sqlite.org','postgresql.org','debian.org','archlinux.org','suckless.org','lwn.net','apache.org','torproject.org','duikt.edu.ua','kpi.ua','knu.ua','lnu.edu.ua','nure.ua','chnu.edu.ua')
    2 = @('icann.org','arin.net','apnic.net','lacnic.net','afrinic.net','unicode.org','ecma-international.org','nist.gov','itu.int','nro.net','openssl.org','openssh.com','gnupg.org','wireshark.org','tcpdump.org','netfilter.org','nlnetlabs.nl','openwrt.org','ntp.org','haproxy.org','nmap.org','dragonflybsd.org','alpinelinux.org','devuan.org','sumdu.edu.ua','vntu.edu.ua','nau.edu.ua','uzhnu.edu.ua','lpnu.ua','ukma.edu.ua')
    3 = @('perl.org','lua.org','tcl.tk','haskell.org','ocaml.org','erlang.org','r-project.org','freepascal.org','fortran-lang.org','swi-prolog.org','gentoo.org','slackware.com','voidlinux.org','opensuse.org','busybox.net','vim.org','neovim.io','mercurial-scm.org','cmake.org','videolan.org','ffmpeg.org','gimp.org','x.org','tug.org','mit.edu','ethz.ch','cern.ch','nasa.gov','nbuv.gov.ua','tnpu.edu.ua')
}

function Read-Number([string]$Prompt, [int]$Minimum, [int]$Maximum, [int]$Default) {
    while ($true) {
        $value = 0
        $answer = Read-Host $Prompt
        if ([string]::IsNullOrWhiteSpace($answer)) { return $Default }
        if ([int]::TryParse($answer, [ref]$value) -and $value -ge $Minimum -and $value -le $Maximum) { return $value }
        Write-Host "Enter a number from $Minimum to $Maximum."
    }
}

Get-Command curl.exe -ErrorAction Stop | Out-Null
Get-Command Resolve-DnsName -ErrorAction Stop | Out-Null
Write-Host 'Student: Vorobiov Dmytro; group ZKN-21. Variant 1 chosen with your permission.'
Write-Host 'Table 1 is PROVISIONAL: the PDF does not map ZKN-21 to a table.'
$table = if ($AssistantRun) { 1 } else { Read-Number 'Group TABLE in Appendix A (1, 2 or 3) [Enter = provisional 1]' 1 3 1 }
$variant = if ($AssistantRun) { 1 } else { Read-Number 'Variant (1-30) [Enter = chosen 1]' 1 30 1 }
$domain = $domains[$table][$variant - 1]
Write-Host "Table: $table. Variant: $variant. Assigned domain: $domain"
Write-Host 'The script records real requests, including expected certificate errors.'
Write-Host 'There is a 6-minute interval between the two DNS requests.'
if (-not $AssistantRun -and (Read-Host 'Type START to begin the measurements') -cne 'START') { exit }
$operator = if ($AssistantRun) { 'Команди фактично запущені асистентом на робочій станції користувача; особисте виконання студентом не підтверджено.' } else { 'Сценарій запущено користувачем; особисте виконання й перевірку підтверджує сам студент.' }

$session = Join-Path $PSScriptRoot ('runs\' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0,6))
$raw = Join-Path $session 'raw'
New-Item -ItemType Directory -Path $raw -Force | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding($false)
$records = New-Object System.Collections.Generic.List[object]
$sections = New-Object System.Collections.Generic.List[string]
$curlVersion = (& curl.exe --version | Select-Object -First 1)
[IO.File]::WriteAllText((Join-Path $raw 'curl-version.txt'), ($curlVersion + "`r`n"), $utf8)

function Add-Section([string]$Title, [string]$Command, [string]$OutputPath, [string]$Time) {
    $content = [IO.File]::ReadAllText($OutputPath, [Text.Encoding]::UTF8)
    $maxTicks = 2
    foreach ($m in [regex]::Matches($content, '`+')) { if ($m.Length -gt $maxTicks) { $maxTicks = $m.Length } }
    $fence = '`' * ($maxTicks + 1)
    $sections.Add("### $Title`r`n`r`nЧас: $Time`r`n`r`nКоманда:`r`n`r`n${fence}powershell`r`n$Command`r`n$fence`r`n`r`nПовний вивід:`r`n`r`n${fence}text`r`n$content`r`n$fence`r`n")
}

function Save-Curl([string]$Title, [string]$Url, [string]$FileName) {
    # URLs come only from the fixed domain lists above and the assignment.
    if ($Url -notmatch '^https?://[a-z0-9.-]+$') { throw 'Unexpected URL.' }
    $path = Join-Path $raw $FileName
    $command = "curl.exe -v $Url"
    $time = [DateTimeOffset]::Now.ToString('o')
    Write-Host "$Title : $command"
    # cmd redirects both native byte streams to one file without PowerShell reformatting.
    $info = New-Object System.Diagnostics.ProcessStartInfo
    $info.FileName = $env:ComSpec
    $info.Arguments = '/d /c ' + $command + ' > "' + $path + '" 2>&1'
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $process = [Diagnostics.Process]::Start($info)
    $process.WaitForExit()
    $exitCode = $process.ExitCode
    $process.Dispose()
    $records.Add([pscustomobject]@{task=$Title; command=$command; started=$time; exit_code=$exitCode; file=('raw/' + $FileName)})
    Add-Section $Title ($command + ' > raw/' + $FileName + ' 2>&1') $path $time
    Write-Host "Saved $FileName ; exit code $exitCode"
}

function Save-Dns([string]$Title, [string]$FileName) {
    $path = Join-Path $raw $FileName
    $time = [DateTimeOffset]::Now.ToString('o')
    $command = "Resolve-DnsName $domain"
    Write-Host "$Title : $command"
    # Capture errors as text too. The returned records are not filtered.
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $result = @(Resolve-DnsName $domain 2>&1)
    $ErrorActionPreference = $previous
    $content = $result | Out-String -Width 4096
    [IO.File]::WriteAllText($path, $content, $utf8)
    $addresses = @($result | Where-Object { $_.PSObject.Properties['IPAddress'] } | Select-Object Name,Type,IPAddress,TTL)
    $records.Add([pscustomobject]@{task=$Title; command=$command; started=$time; file=('raw/' + $FileName); addresses=$addresses})
    Add-Section $Title ($command + ' 2>&1 | Out-String -Width 4096') $path $time
}

Save-Curl 'A.1' "https://$domain" 'a1-curl-https.txt'
Save-Curl 'A.2' 'http://neverssl.com' 'a2-curl-http.txt'
$dnsClock = [Diagnostics.Stopwatch]::StartNew()
Save-Dns 'A.3, перше виконання' 'a3-dns-first.txt'
while ($dnsClock.Elapsed.TotalSeconds -lt 360) {
    $remaining = [int][Math]::Ceiling(360 - $dnsClock.Elapsed.TotalSeconds)
    Write-Progress -Activity 'Waiting for the second DNS request' -Status "$remaining seconds remaining" -PercentComplete ([Math]::Min(100, 100 * $dnsClock.Elapsed.TotalSeconds / 360))
    Start-Sleep -Seconds ([Math]::Min(5, $remaining))
}
Write-Progress -Activity 'Waiting for the second DNS request' -Completed
Save-Dns 'A.3, повторне виконання' 'a3-dns-second.txt'
$dnsClock.Stop()
Save-Curl 'A.4' 'https://google.com' 'a4-google.txt'
Save-Curl 'A.5, expired' 'https://expired.badssl.com' 'a5-expired.txt'
Save-Curl 'A.5, wrong.host' 'https://wrong.host.badssl.com' 'a5-wrong-host.txt'
Save-Curl 'A.5, self-signed' 'https://self-signed.badssl.com' 'a5-self-signed.txt'

$metadata = [ordered]@{operator=$operator; student='Воробйов Дмитро'; academic_group='ЗКН-21'; selection_note='Варіант 1 обраний за дозволом користувача; таблиця 1 умовна, якщо її не уточнено'; group_table=$table; variant=$variant; domain=$domain; curl_version=$curlVersion; environment='Windows'; measurements=$records}
[IO.File]::WriteAllText((Join-Path $session 'measurements.json'), ($metadata | ConvertTo-Json -Depth 8), $utf8)
$heading = "# Частина A. Реальні виводи команд`r`n`r`n$operator`r`n`r`nСтудент: Воробйов Дмитро. Таблиця групи: $table. Варіант: $variant. Домен: $domain.`r`n`r`nСередовище: Windows. Версія curl: $curlVersion.`r`n`r`nЧасові позначки містять фактичний часовий пояс комп'ютера. Первинні файли raw збережено без редагування; для Markdown прочитано їх текст як UTF-8. Якщо символи у відповіді відображаються неправильно, збережіть raw і повідомте про це перед оформленням звіту.`r`n`r`n"
[IO.File]::WriteAllText((Join-Path $session 'part-A.md'), ($heading + ($sections -join "`r`n")), $utf8)
Get-ChildItem -LiteralPath $raw -File | Get-FileHash -Algorithm SHA256 | Select-Object Hash,@{Name='File';Expression={Split-Path $_.Path -Leaf}} | Export-Csv -LiteralPath (Join-Path $session 'raw-sha256.csv') -NoTypeInformation -Encoding UTF8
Write-Host "Done. Results: $session"
Write-Host 'Read part-A.md and the original raw files. The report is not complete yet.'
Write-Host 'If a badssl request gives an unexpected result, retain it; do not replace it with an expected error.'
