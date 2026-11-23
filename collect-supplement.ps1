param()
$ErrorActionPreference = 'Stop'
$taskRoot = Join-Path $PSScriptRoot 'supplement'
New-Item -ItemType Directory -Force -Path $taskRoot | Out-Null
$utf8 = New-Object Text.UTF8Encoding($false)
$dnsMetadata = New-Object Collections.Generic.List[object]
function Query-Dns([string]$Name) {
    $started = [DateTimeOffset]::Now.ToString('o')
    $result = @(Resolve-DnsName example.com -Server 1.1.1.1)
    [IO.File]::WriteAllText((Join-Path $taskRoot ($Name + '.txt')), ($result | Out-String -Width 4096), $utf8)
    $dnsMetadata.Add([pscustomobject]@{command='Resolve-DnsName example.com -Server 1.1.1.1'; started=$started; records=@($result | Select-Object Name,Type,IPAddress,TTL)})
    [IO.File]::WriteAllText((Join-Path $taskRoot 'dns-metadata.json'), ($dnsMetadata | ConvertTo-Json -Depth 7), $utf8)
}
$timer = [Diagnostics.Stopwatch]::StartNew()
Query-Dns 'dns-first'
$ip = $dnsMetadata[0].records | Where-Object Type -eq A | Select-Object -First 1 -ExpandProperty IPAddress
$command = 'curl.exe -v https://example.com --resolve example.com:443:' + $ip
$started = [DateTimeOffset]::Now.ToString('o')
$info = New-Object Diagnostics.ProcessStartInfo
$info.FileName = $env:ComSpec
$info.Arguments = '/d /c ' + $command + ' > "' + (Join-Path $taskRoot 'a1-resolve.txt') + '" 2>&1'
$info.UseShellExecute = $false
$info.CreateNoWindow = $true
$process = [Diagnostics.Process]::Start($info)
$process.WaitForExit()
$meta = [pscustomobject]@{command=$command; started=$started; exit_code=$process.ExitCode}
[IO.File]::WriteAllText((Join-Path $taskRoot 'curl-metadata.json'), ($meta | ConvertTo-Json), $utf8)
$process.Dispose()
Write-Output ('Additional A.1 saved: ' + $command)
while ($timer.Elapsed.TotalSeconds -lt 360) { Start-Sleep -Seconds 5 }
Query-Dns 'dns-second'
Write-Output 'Second DNS query saved.'
