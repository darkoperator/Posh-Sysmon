<#
.SYNOPSIS

Parses a Sysmon driver configuration from the registry. Output is nearly identical to that of "sysmon.exe -c" but without the requirement to run sysmon.exe.

.DESCRIPTION

Get-SysmonConfiguration parses a Sysmon configuration from the registry without the need to run "sysmon.exe -c". This function is designed to enable Sysmon configuration auditing at scale as well as reconnaissance for red teamers. 

Get-SysmonConfiguration has been tested with the following Sysmon versions: 6.20

Due to the admin-only ACL set on the Sysmon driver registry key, Get-SysmonConfiguration will typically need to run in an elevated context. Because the user-mode service and driver names can be changed, Get-SysmonConfiguration will locate the service and driver regardless of their names.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

Required Dependencies: ConvertFrom-SysmonBinaryConfiguration

.PARAMETER MatchExeOutput

Mirrors the text output of "sysmon.exe -c". This parameter was implemented primarily to enable testing scenarios - i.e. to ensure that the output matches that of the version of Sysmon (or schema) being tested against.

.EXAMPLE

Get-SysmonConfiguration

.EXAMPLE

Get-SysmonConfiguration -MatchExeOutput

.OUTPUTS

Sysmon.Configuration

Outputs a fully parsed Sysmon configuration including the hash of the registry rule blob for auditing purposes.

System.String

Outputs mirrored output from "sysmon.exe -c".

.NOTES

Get-SysmonConfiguration will have to be manually validated for each new Sysmon and configuration schema version. Please report all bugs and indiscrepencies with new versions by supplying the following information:

1) The Sysmon config XML that's generating the error (only schema versions 3.30 and later).
2) The version of Sysmon being used (only 6.20 and later).
#>
function Get-SysmonConfiguration {


    [OutputType('Sysmon.Configuration', ParameterSetName = 'PSOutput')]
    [OutputType([String], ParameterSetName = 'ExeOutput')]
    [CmdletBinding(DefaultParameterSetName = 'PSOutput')]
    param (
        [Parameter(ParameterSetName = 'ExeOutput')]
        [Switch]
        $MatchExeOutput
    )

    # Find the Sysmon driver based solely off the presence of the "Rules" value.
    # This is being done because the user can optionally specify a driver name other than the default: SysmonDrv
    $ServiceParameters = Get-ChildItem -Path HKLM:\SYSTEM\CurrentControlSet\Services -Recurse -Include 'Parameters' -ErrorAction SilentlyContinue
    $DriverParameters = $ServiceParameters | Where-Object { $_.Property -contains 'Rules' }

    if (-not $DriverParameters) {
        Write-Error 'Unable to locate a Sysmon driver. Either it is not installed or you do not have permissions to read the driver configuration in the registry.'
        return
    }

    $FoundSysmonMatch = $False
    $SysmonDriverName = $null
    $SysmonServiceName = $null
    $SysmonDriverParams = $null

    # Just in case there is more than one instance where there is a "Rules" value, correlate it with the user-mode service to confirm.
    $DriverParameters | ForEach-Object {
        $CandidateDriverName = $_.PSParentPath.Split('\')[-1]
        $CandidateDriverParams = $_

        $CandidateUserModeServices = $ServiceParameters | Where-Object { $_.Property -contains 'DriverName' }

        if (-not $CandidateUserModeServices) {
            Write-Error 'Unable to locate a user-mode Sysmon service.'
            return
        }

        $CandidateUserModeServices | ForEach-Object {
            $CandidateServiceName = $_.PSParentPath.Split('\')[-1]
            $DriverName = ($_ | Get-ItemProperty).DriverName

            # We have a matching user-mode Sysmon service and Sysmon driver.
            if ($DriverName -eq $CandidateDriverName) {
                $FoundSysmonMatch = $True
                $SysmonDriverName = $CandidateDriverName
                $SysmonServiceName = $CandidateServiceName
                $SysmonDriverParams = $CandidateDriverParams | Get-ItemProperty
            }
        }
    }

    if ($FoundSysmonMatch) {
        # HKLM\SYSTEM\CurrentControlSet\Services\<SYSMON_DRIVER_NAME>\Parameters
        $RuleBytes = $SysmonDriverParams.Rules                        # REG_BINARY
        $Options = $SysmonDriverParams.Options                        # REG_DWORD
        $HashingAlgorithmValue = $SysmonDriverParams.HashingAlgorithm # REG_DWORD
        $ProcessAccessMasks = $SysmonDriverParams.ProcessAccessMasks  # REG_BINARY - No larger than size: 0x28 (0x28 / 4 == 10: unique masks to interpret alongside ProcessAccessNames)
        $ProcessAccessNames = $SysmonDriverParams.ProcessAccessNames  # REG_MULTI_SZ - Can have no more than 10 entries
        $CheckRevocation = $SysmonDriverParams.CheckRevocation        # REG_BINARY of size: 1 byte

        # The high-order bit of HashingAlgorithm must be set to 1 (i.e. 0x80000000)
        $HashingAlgorithms = if ($HashingAlgorithmValue) {
            if ($HashingAlgorithmValue -band 1) { 'SHA1' }
            if ($HashingAlgorithmValue -band 2) { 'MD5' }
            if ($HashingAlgorithmValue -band 4) { 'SHA256' }
            if ($HashingAlgorithmValue -band 8) { 'IMPHASH' }
        }

        $NetworkConnection = $False
        if ($Options -band 1) { $NetworkConnection = $True }

        $ImageLoading = $False
        if ($Options -band 2) { $ImageLoading = $True }

        $CRLChecking = $False
        if (($CheckRevocation.Count -gt 0) -and ($CheckRevocation[0] -eq 1)) { $CRLChecking = $True }

        # Parse the binary rules blob.
        $Rules = ConvertFrom-SysmonBinaryConfiguration -RuleBytes $RuleBytes

        $ProcessAccess = $False
        if ($Rules.Events.EventType -contains 'ProcessAccess') { $ProcessAccess = $True }

        # Process ProcessAccessNames and ProcessAccessMasks.
        # The code path to actually use these appears to be a dead one now.
        # I'm only parsing this to mirror Sysmon 6.20 supporting parsing.
        $ProcessAccessList = New-Object -TypeName PSObject[]($ProcessAccessNames.Count)
        for ($i = 0; $i -lt $ProcessAccessNames.Count; $i++) {
            $ProcessAccessList[$i] = [PSCustomObject] @{
                ProcessName = $ProcessAccessNames[$i]
                AccessMask = [BitConverter]::ToInt32($ProcessAccessMasks, $i * 4)
            }
        }

        $Properties = [Ordered] @{
            PSTypeName = 'Sysmon.Configuration'
            ServiceName = $SysmonServiceName
            DriverName = $SysmonDriverName
            HashingAlgorithms = $HashingAlgorithms
            NetworkConnectionEnabled = $NetworkConnection
            ImageLoadingEnabled = $ImageLoading
            CRLCheckingEnabled = $CRLChecking
            ProcessAccessEnabled = $ProcessAccess
            ProcessAccess = $ProcessAccessList
            SchemaVersion = $Rules.SchemaVersion.ToString(2)
            ConfigBlobSHA256Hash = $Rules.ConfigBlobSHA256Hash
            Rules = $Rules.Events
        }

        # Don't print the ProcessAccess property if it's not populated. With Sysmon 6.20, this
        # should never be present anyway unless there's a stale artifact from an older version.
        if ($ProcessAccessList.Count -eq 0) { $Properties.Remove('ProcessAccess') }

        if ($MatchExeOutput) {

            $NetworkConnectionString = if ($NetworkConnection) { 'enabled' } else { 'disabled' }
            $ImageLoadingString = if ($ImageLoading) { 'enabled' } else { 'disabled' }
            $CRLCheckingString = if ($CRLChecking) { 'enabled' } else { 'disabled' }
            $ProcessAccessString = if ($ProcessAccess) { 'enabled' } else { 'disabled' }
            if ($ProcessAccessList) {
                $ProcessAccessString = ($ProcessAccessList | ForEach-Object { "`"$($_.ProcessName)`":0x$($_.AccessMask.ToString('x'))" }) -join ','
            }

            $AllRuleText = $Rules.Events | ForEach-Object {
                # Dumb hacks to format output to the original "sysmon.exe -c" output
                $EventType = $_.EventType
                if ($EventType.StartsWith('RegistryEvent')) { $EventType = 'RegistryEvent' }
                if ($EventType.StartsWith('WmiEvent')) { $EventType = 'WmiEvent' }
                if ($EventType.StartsWith('PipeEvent')) { $EventType = 'PipeEvent' }

                $RuleText = $_.Rules | ForEach-Object {
                    $FilterText = switch ($_.Filter) {
                        'Is' { 'is' }
                        'IsNot' { 'is not' }
                        'Contains' { 'contains' }
                        'Excludes' { 'excludes' }
                        'BeginWith' { 'begin with' }
                        'EndWith' { 'end with' }
                        'LessThan' { 'less than' }
                        'MoreThan' { 'more than' }
                        'Image' { 'image' }
                    }

                    "`t{0,-30} filter: {1,-12} value: '{2}'" -f $_.RuleType, $FilterText, $_.RuleText
                }

                $RuleSet =  @"
 - {0,-34} onmatch: {1}
{2}
"@ -f $EventType,
      $_.OnMatch.ToLower(),
      ($RuleText | Out-String).TrimEnd("`r`n")

                $RuleSet.TrimEnd("`r`n")
            }


            $ConfigOutput = @"
Current configuration:
{0,-34}{1}
{2,-34}{3}
{4,-34}{5}
{6,-34}{7}
{8,-34}{9}
{10,-34}{11}
{12,-34}{13}

Rule configuration (version {14}):
{15}
"@ -f ' - Service name:',
      $SysmonServiceName,
      ' - Driver name:',
      $SysmonDriverName,
      ' - HashingAlgorithms:',
      ($HashingAlgorithms -join ','),
      ' - Network connection:',
      $NetworkConnectionString,
      ' - Image loading:',
      $ImageLoadingString,
      ' - CRL checking:',
      $CRLCheckingString,
      ' - Process Access:',
      $ProcessAccessString,
      "$($Rules.SchemaVersion.Major).$($Rules.SchemaVersion.Minor.ToString().PadRight(2, '0'))",
      ($AllRuleText | Out-String).TrimEnd("`r`n")

            $ConfigOutput
        } else {
            [PSCustomObject] $Properties
        }
    } else {
        Write-Error 'Unable to locate a Sysmon driver and user-mode service.'
    }
}
