# Windows PowerShell 5.1 / PowerShell 7 on Windows.
# Performs PR01 requests and saves their actual output. No administrator rights needed.
# Select the entire script in PowerShell ISE and press F8, or run this saved .ps1.
& {
    $ErrorActionPreference = 'Stop'
    $pr01Domain = 'example.com'
    $pr01DnsIntervalSeconds = 360
    $pr01Encoding = New-Object System.Text.UTF8Encoding($false)
    $pr01Clock = [Diagnostics.Stopwatch]::StartNew()
    $pr01RunName = 'PR01_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '_' + [Guid]::NewGuid().ToString('N').Substring(0, 6)
    $pr01Directory = Join-Path ([Environment]::GetFolderPath('MyDocuments')) $pr01RunName
    $null = New-Item -ItemType Directory -Path $pr01Directory
    $pr01Raw = Join-Path $pr01Directory 'raw'
    $null = New-Item -ItemType Directory -Path $pr01Raw
    $pr01Journal = Join-Path $pr01Directory 'terminal.txt'
    $pr01AllCommands = Join-Path $pr01Directory 'commands.txt'
    $pr01Metadata = New-Object 'System.Collections.Generic.List[object]'

    function Save-Pr01Text([string]$Path, [string]$Text) {
        [IO.File]::WriteAllText($Path, $Text, $pr01Encoding)
    }

    function Write-Pr01Journal([string]$Text) {
        Write-Host $Text
        [IO.File]::AppendAllText($pr01Journal, $Text + [Environment]::NewLine, $pr01Encoding)
    }

    function Start-Pr01Entry([string]$Name, [string]$Command) {
        $entry = [ordered]@{
            experiment = $Name
            command = $Command
            started = [DateTimeOffset]::Now.ToString('o')
            started_elapsed_seconds = $pr01Clock.Elapsed.TotalSeconds
            finished = $null
            exit_code = $null
            error = $null
        }
        Write-Pr01Journal ("`r`n=== " + $Name + ' | ' + $entry.started + ' ===')
        Write-Pr01Journal ('COMMAND: ' + $Command)
        [IO.File]::AppendAllText($pr01AllCommands, $Name + "`r`n" + $Command + "`r`n`r`n", $pr01Encoding)
        Save-Pr01Text (Join-Path $pr01Raw ($Name + '.command.txt')) $Command
        return $entry
    }

    function Complete-Pr01Entry($Entry) {
        $Entry.finished = [DateTimeOffset]::Now.ToString('o')
        Save-Pr01Text (Join-Path $pr01Raw ($Entry.experiment + '.metadata.json')) ($Entry | ConvertTo-Json -Depth 5)
        $pr01Metadata.Add([pscustomobject]$Entry)
        Write-Pr01Journal ('FINISHED: ' + $Entry.finished + ' | EXIT CODE: ' + $Entry.exit_code)
        if ($Entry.error) { Write-Pr01Journal ('ERROR: ' + $Entry.error) }
    }

    function Invoke-Pr01Curl([string]$Name, [string]$CurlArguments) {
        $entry = Start-Pr01Entry $Name ('curl.exe ' + $CurlArguments)
        $info = New-Object Diagnostics.ProcessStartInfo
        $info.FileName = $pr01CurlPath
        $info.Arguments = $CurlArguments
        $info.UseShellExecute = $false
        $info.CreateNoWindow = $true
        $info.RedirectStandardOutput = $true
        $info.RedirectStandardError = $true
        $process = New-Object Diagnostics.Process
        $process.StartInfo = $info
        $stdoutBytes = New-Object IO.MemoryStream
        $stderrBytes = New-Object IO.MemoryStream
        $stdoutCopy = $null
        $stderrCopy = $null
        $started = $false
        try {
            $started = $process.Start()
            if (-not $started) { throw 'Unable to start curl.exe.' }
            $stdoutCopy = $process.StandardOutput.BaseStream.CopyToAsync($stdoutBytes)
            $stderrCopy = $process.StandardError.BaseStream.CopyToAsync($stderrBytes)
            if (-not $process.WaitForExit(60000)) {
                $entry.error = 'curl.exe exceeded the 60-second process limit.'
                $process.Kill()
                $process.WaitForExit()
            }
            $entry.exit_code = $process.ExitCode
        } catch {
            $entry.error = $_.ToString()
            if ($started) {
                try { if (-not $process.HasExited) { $process.Kill(); $process.WaitForExit() } } catch {}
            }
        } finally {
            try {
                if ($null -ne $stdoutCopy) { $stdoutCopy.GetAwaiter().GetResult() }
                if ($null -ne $stderrCopy) { $stderrCopy.GetAwaiter().GetResult() }
                $stdout = $stdoutBytes.ToArray()
                $stderr = $stderrBytes.ToArray()
                [IO.File]::WriteAllBytes((Join-Path $pr01Raw ($Name + '.output.txt')), $stdout)
                [IO.File]::WriteAllBytes((Join-Path $pr01Raw ($Name + '.stderr.txt')), $stderr)
                Write-Pr01Journal ([Text.Encoding]::UTF8.GetString($stdout))
                if ($stderr.Length -gt 0) {
                    Write-Pr01Journal 'PROCESS STDERR:'
                    Write-Pr01Journal ([Text.Encoding]::UTF8.GetString($stderr))
                }
            } finally {
                $stdoutBytes.Dispose()
                $stderrBytes.Dispose()
                $process.Dispose()
            }
        }
        Complete-Pr01Entry $entry
        return [pscustomobject]$entry
    }

    function Invoke-Pr01Dns([string]$Name, [string]$Server) {
        $command = 'Resolve-DnsName ' + $pr01Domain
        if ($Server) { $command += ' -Server ' + $Server }
        $command += ' -ErrorAction Continue 2>&1 | Out-String -Width 4096'
        $entry = Start-Pr01Entry $Name $command
        $items = @()
        try {
            if ($Server) {
                $items = @(Resolve-DnsName $pr01Domain -Server $Server -ErrorAction Continue 2>&1)
            } else {
                $items = @(Resolve-DnsName $pr01Domain -ErrorAction Continue 2>&1)
            }
            $errors = @($items | Where-Object { $_ -is [Management.Automation.ErrorRecord] })
            $entry.error = ($errors | Out-String -Width 4096).Trim()
            $entry.exit_code = $null # A PowerShell cmdlet has no native process exit code.
            $text = $items | Out-String -Width 4096
        } catch {
            $entry.error = $_.ToString()
            $text = $_ | Out-String -Width 4096
        }
        Save-Pr01Text (Join-Path $pr01Raw ($Name + '.output.txt')) $text
        Write-Pr01Journal $text
        $records = @($items | Where-Object {
            ($_ -isnot [Management.Automation.ErrorRecord]) -and $_.IPAddress
        } | Select-Object Name, Type, TTL, Section, IPAddress)
        Save-Pr01Text (Join-Path $pr01Raw ($Name + '.addresses.json')) (ConvertTo-Json -InputObject $records -Depth 5)
        Complete-Pr01Entry $entry
        return [pscustomobject]@{ Entry = [pscustomobject]$entry; Records = $records }
    }

    function Wait-Pr01Until([double]$DueSeconds, [string]$Label) {
        $nextMessage = 0.0
        while ($pr01Clock.Elapsed.TotalSeconds -lt $DueSeconds) {
            $remaining = [int][Math]::Ceiling($DueSeconds - $pr01Clock.Elapsed.TotalSeconds)
            if ($pr01Clock.Elapsed.TotalSeconds -ge $nextMessage) {
                Write-Pr01Journal ('Waiting for ' + $Label + ': ' + $remaining + ' seconds remaining.')
                $nextMessage = $pr01Clock.Elapsed.TotalSeconds + 30
            }
            Write-Progress -Activity 'PR01: DNS repeat after approximately 6 minutes' -Status ($remaining.ToString() + ' seconds remaining')
            Start-Sleep -Seconds ([Math]::Min(5, $remaining))
        }
        Write-Progress -Activity 'PR01: DNS repeat after approximately 6 minutes' -Completed
    }

    function Compare-Pr01Dns([string]$Resolver, $First, $Second) {
        $interval = [Math]::Round($Second.Entry.started_elapsed_seconds - $First.Entry.started_elapsed_seconds, 3)
        $rows = @(
            foreach ($record in $First.Records) {
                foreach ($other in $Second.Records) {
                    if (($record.Name -eq $other.Name) -and ($record.Type -eq $other.Type) -and ($record.IPAddress -eq $other.IPAddress)) {
                        [pscustomobject]@{
                            resolver = $Resolver; name = $record.Name; type = [string]$record.Type
                            ip_address = $record.IPAddress; ttl_first = $record.TTL; ttl_second = $other.TTL
                            ttl_change = [int64]$other.TTL - [int64]$record.TTL; interval_seconds = $interval
                        }
                    }
                }
            }
        )
        Write-Pr01Journal ("`r`nDNS COMPARISON: " + $Resolver + ' | actual interval: ' + $interval + ' seconds')
        if ($rows.Count -gt 0) {
            Write-Pr01Journal ($rows | Format-Table -AutoSize | Out-String -Width 4096)
            $rows | Export-Csv -LiteralPath (Join-Path $pr01Directory ('TTL_' + $Resolver + '.csv')) -NoTypeInformation -Encoding UTF8
        } else {
            Write-Pr01Journal 'No matching address records in both responses; no TTL values were compared.'
        }
        Save-Pr01Text (Join-Path $pr01Directory ('TTL_' + $Resolver + '.json')) (ConvertTo-Json -InputObject $rows -Depth 5)
    }

    try {
        Write-Pr01Journal 'PR01: HTTP, HTTPS, DNS and TLS checks'
        Write-Pr01Journal ('POWERSHELL: ' + $PSVersionTable.PSVersion.ToString())
        Write-Pr01Journal ('RESULTS: ' + $pr01Directory)
        Write-Pr01Journal 'Each command and its actual timestamps are saved. DNS is repeated after approximately 6 minutes.'

        # Preserve the source even when the script is executed as a selection in ISE.
        $pr01SourceSaved = $false
        if ($PSCommandPath -and (Test-Path -LiteralPath $PSCommandPath)) {
            Copy-Item -LiteralPath $PSCommandPath -Destination (Join-Path $pr01Directory 'Collect_PR01.ps1')
            $pr01SourceSaved = $true
        } elseif ((Get-Variable psISE -ErrorAction SilentlyContinue) -and $psISE.CurrentFile) {
            if ($psISE.CurrentFile.Editor.Text) {
                [IO.File]::WriteAllText((Join-Path $pr01Directory 'Collect_PR01.ps1'), $psISE.CurrentFile.Editor.Text, (New-Object Text.UTF8Encoding($true)))
                $pr01SourceSaved = $true
            }
        }
        if (-not $pr01SourceSaved) { Write-Pr01Journal 'Source snapshot unavailable: keep the original Collect_PR01.ps1 beside these results.' }

        $pr01Curl = Get-Command curl.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $pr01Curl) { throw 'curl.exe was not found. This script requires Windows curl.exe.' }
        if (-not (Get-Command Resolve-DnsName -ErrorAction SilentlyContinue)) { throw 'Resolve-DnsName was not found. Run the script in Windows PowerShell.' }
        $pr01CurlPath = $pr01Curl.Source
        Write-Pr01Journal ('CURL EXECUTABLE: ' + $pr01CurlPath)
        $null = Invoke-Pr01Curl '00_curl_version' '--version'

        $pr01DnsSystemFirst = Invoke-Pr01Dns 'A3_system_first' ''
        $pr01DnsExternalFirst = Invoke-Pr01Dns 'A3_external_first' '1.1.1.1'

        # Time limits bound waiting. --stderr - combines curl diagnostics and body in stdout.
        # These capture options are included in the logged command, not hidden.
        $pr01CurlOptions = '-v --connect-timeout 15 --max-time 45 --stderr - '
        $pr01A1 = Invoke-Pr01Curl 'A1_https' ($pr01CurlOptions + 'https://' + $pr01Domain)
        if ($pr01A1.exit_code -eq 6) {
            $pr01Address = $pr01DnsExternalFirst.Records | Where-Object { [string]$_.Type -eq 'A' } | Select-Object -First 1 -ExpandProperty IPAddress
            if ($pr01Address -and ($pr01Address -match '^\d{1,3}(\.\d{1,3}){3}$')) {
                Write-Pr01Journal 'Supplemental A1 request: --resolve uses an address obtained in A3_external_first.'
                $null = Invoke-Pr01Curl 'A1_supplement_resolve' ($pr01CurlOptions + 'https://' + $pr01Domain + ' --resolve ' + $pr01Domain + ':443:' + $pr01Address)
            } else {
                Write-Pr01Journal 'Supplemental --resolve request skipped: no IPv4 address was obtained from the external DNS response.'
            }
        }
        $pr01A2 = Invoke-Pr01Curl 'A2_http' ($pr01CurlOptions + 'http://neverssl.com')
        $null = Invoke-Pr01Curl 'A4_google' ($pr01CurlOptions + 'https://google.com')
        $pr01Expired = Invoke-Pr01Curl 'A5_expired' ($pr01CurlOptions + 'https://expired.badssl.com')
        $null = Invoke-Pr01Curl 'A5_wrong_host' ($pr01CurlOptions + 'https://wrong.host.badssl.com')
        $null = Invoke-Pr01Curl 'A5_self_signed' ($pr01CurlOptions + 'https://self-signed.badssl.com')

        Wait-Pr01Until ($pr01DnsSystemFirst.Entry.started_elapsed_seconds + $pr01DnsIntervalSeconds) 'system DNS repeat'
        $pr01DnsSystemSecond = Invoke-Pr01Dns 'A3_system_second' ''
        Wait-Pr01Until ($pr01DnsExternalFirst.Entry.started_elapsed_seconds + $pr01DnsIntervalSeconds) 'external DNS repeat'
        $pr01DnsExternalSecond = Invoke-Pr01Dns 'A3_external_second' '1.1.1.1'
        Compare-Pr01Dns 'system' $pr01DnsSystemFirst $pr01DnsSystemSecond
        Compare-Pr01Dns '1_1_1_1' $pr01DnsExternalFirst $pr01DnsExternalSecond

        # Retries are separate measurements; original failures remain in the journal.
        if (@(6, 7, 28) -contains $pr01A2.exit_code) {
            $null = Invoke-Pr01Curl 'A2_http_retry' ($pr01CurlOptions + 'http://neverssl.com')
        }
        if (@(6, 7, 28) -contains $pr01Expired.exit_code) {
            $null = Invoke-Pr01Curl 'A5_expired_retry' ($pr01CurlOptions + 'https://expired.badssl.com')
        }
        Write-Pr01Journal "`r`nDONE: scheduled checks completed. Review the recorded responses and any errors."
    } catch {
        Write-Pr01Journal ('STOPPED: ' + $_.ToString())
        Save-Pr01Text (Join-Path $pr01Directory 'run_error.txt') ($_ | Out-String -Width 4096)
    } finally {
        Write-Progress -Activity 'PR01: DNS repeat after approximately 6 minutes' -Completed
        Save-Pr01Text (Join-Path $pr01Directory 'measurements.json') (ConvertTo-Json -InputObject @($pr01Metadata.ToArray()) -Depth 6)
        $pr01Clock.Stop()
        Write-Pr01Journal ('RESULTS: ' + $pr01Directory)
        Write-Host 'Open terminal.txt for the full log, commands.txt for commands, and Collect_PR01.ps1 for the source.'
    }
}
