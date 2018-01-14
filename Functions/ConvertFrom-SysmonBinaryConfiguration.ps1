<#
.SYNOPSIS

Parses a binary Sysmon configuration.

.DESCRIPTION

ConvertFrom-SysmonBinaryConfiguration parses a binary Sysmon configuration. The configuration is typically stored in the registry at the following path: HKLM\SYSTEM\CurrentControlSet\Services\SysmonDrv\Parameters\Rules

ConvertFrom-SysmonBinaryConfiguration currently only supports the following schema versions: 3.30, 3.40 and 4.0

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER RuleBytes

Specifies the raw bytes of a Sysmon configuration from the registry.

.EXAMPLE

[Byte[]] $RuleBytes = Get-ItemPropertyValue -Path HKLM:\SYSTEM\CurrentControlSet\Services\SysmonDrv\Parameters -Name Rules
ConvertFrom-SysmonBinaryConfiguration -RuleBytes $RuleBytes

.OUTPUTS

Sysmon.EventCollection

Output a fully-parsed rule object including the hash of the rules blob.

.NOTES

ConvertFrom-SysmonBinaryConfiguration is designed to serve as a helper function for Get-SysmonConfiguration.
#>

function ConvertFrom-SysmonBinaryConfiguration {
    [OutputType('Sysmon.EventCollection')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [Byte[]]
        [ValidateNotNullOrEmpty()]
        $RuleBytes
    )

    #region Define byte to string mappings. This may change across verions.
    $SupportedSchemaVersions = @(
        [Version] '3.30.0.0',
        [Version] '3.40.0.0',
        [Version] '4.00.0.0'
    )

    $EventConditionMapping = @{
        0 = 'Is'
        1 = 'IsNot'
        2 = 'Contains'
        3 = 'Excludes'
        4 = 'BeginWith'
        5 = 'EndWith'
        6 = 'LessThan'
        7 = 'MoreThan'
        8 = 'Image'
    }

    # The following value to string mappings were all pulled from
    # IDA and will require manual validation with with each new
    # Sysmon and schema version. Here's hoping they don't change often!
    $ProcessCreateMapping = @{
        0 = 'UtcTime'
        1 = 'ProcessGuid'
        2 = 'ProcessId'
        3 = 'Image'
        4 = 'CommandLine'
        5 = 'CurrentDirectory'
        6 = 'User'
        7 = 'LogonGuid'
        8 = 'LogonId'
        9 = 'TerminalSessionId'
        10 = 'IntegrityLevel'
        11 = 'Hashes'
        12 = 'ParentProcessGuid'
        13 = 'ParentProcessId'
        14 = 'ParentImage'
        15 = 'ParentCommandLine'
    }

    $ProcessCreateMapping_4_00 = @{
        0 = 'UtcTime'
        1 = 'ProcessGuid'
        2 = 'ProcessId'
        3 = 'Image'
        4 = 'FileVersion'
        5 = 'Description'
        6 = 'Product'
        7 = 'Company'
        8 = 'CommandLine'
        9 = 'CurrentDirectory'
        10 = 'User'
        11 = 'LogonGuid'
        12 = 'LogonId'
        13 = 'TerminalSessionId'
        14 = 'IntegrityLevel'
        15 = 'Hashes'
        16 = 'ParentProcessGuid'
        17 = 'ParentProcessId'
        18 = 'ParentImage'
        19 = 'ParentCommandLine'
    }

    $FileCreateTimeMapping = @{
        0 = 'UtcTime'
        1 = 'ProcessGuid'
        2 = 'ProcessId'
        3 = 'Image'
        4 = 'TargetFilename'
        5 = 'CreationUtcTime'
        6 = 'PreviousCreationUtcTime'
    }

    $NetworkConnectMapping = @{
        0 = 'UtcTime'
        1 = 'ProcessGuid'
        2 = 'ProcessId'
        3 = 'Image'
        4 = 'User'
        5 = 'Protocol'
        6 = 'Initiated'
        7 = 'SourceIsIpv6'
        8 = 'SourceIp'
        9 = 'SourceHostname'
        10 = 'SourcePort'
        11 = 'SourcePortName'
        12 = 'DestinationIsIpv6'
        13 = 'DestinationIp'
        14 = 'DestinationHostname'
        15 = 'DestinationPort'
        16 = 'DestinationPortName'
    }

    $SysmonServiceStateChangeMapping = @{
        0 = 'UtcTime'
        1 = 'State'
        2 = 'Version'
        3 = 'SchemaVersion'
    }

    $ProcessTerminateMapping = @{
        0 = 'UtcTime'
        1 = 'ProcessGuid'
        2 = 'ProcessId'
        3 = 'Image'
    }

    $DriverLoadMapping = @{
        0 = 'UtcTime'
        1 = 'ImageLoaded'
        2 = 'Hashes'
        3 = 'Signed'
        4 = 'Signature'
        5 = 'SignatureStatus'
    }

    $ImageLoadMapping = @{
        0 = 'UtcTime'
        1 = 'ProcessGuid'
        2 = 'ProcessId'
        3 = 'Image'
        4 = 'ImageLoaded'
        5 = 'Hashes'
        6 = 'Signed'
        7 = 'Signature'
        8 = 'SignatureStatus'
    }

    $ImageLoadMapping_4_00 = @{
        0 = 'UtcTime'
        1 = 'ProcessGuid'
        2 = 'ProcessId'
        3 = 'Image'
        4 = 'ImageLoaded'
        5 = 'FileVersion'
        6 = 'Description'
        7 = 'Product'
        8 = 'Company'
        9 = 'Hashes'
        10 = 'Signed'
        11 = 'Signature'
        12 = 'SignatureStatus'
    }

    $CreateRemoteThreadMapping = @{
        0 = 'UtcTime'
        1 = 'SourceProcessGuid'
        2 = 'SourceProcessId'
        3 = 'SourceImage'
        4 = 'TargetProcessGuid'
        5 = 'TargetProcessId'
        6 = 'TargetImage'
        7 = 'NewThreadId'
        8 = 'StartAddress'
        9 = 'StartModule'
        10 = 'StartFunction'
    }

    $RawAccessReadMapping = @{
        0 = 'UtcTime'
        1 = 'ProcessGuid'
        2 = 'ProcessId'
        3 = 'Image'
        4 = 'Device'
    }

    $ProcessAccessMapping = @{
        0 = 'UtcTime'
        1 = 'SourceProcessGUID'
        2 = 'SourceProcessId'
        3 = 'SourceThreadId'
        4 = 'SourceImage'
        5 = 'TargetProcessGUID'
        6 = 'TargetProcessId'
        7 = 'TargetImage'
        8 = 'GrantedAccess'
        9 = 'CallTrace'
    }

    $FileCreateMapping = @{
        0 = 'UtcTime'
        1 = 'ProcessGuid'
        2 = 'ProcessId'
        3 = 'Image'
        4 = 'TargetFilename'
        5 = 'CreationUtcTime'
    }

    $RegistryEventCreateKeyMapping = @{
        0 = 'EventType'
        1 = 'UtcTime'
        2 = 'ProcessGuid'
        3 = 'ProcessId'
        4 = 'Image'
        5 = 'TargetObject'
    }

    $RegistryEventSetValueMapping = @{
        0 = 'EventType'
        1 = 'UtcTime'
        2 = 'ProcessGuid'
        3 = 'ProcessId'
        4 = 'Image'
        5 = 'TargetObject'
        6 = 'Details'
    }

    $RegistryEventDeleteKeyMapping = @{
        0 = 'EventType'
        1 = 'UtcTime'
        2 = 'ProcessGuid'
        3 = 'ProcessId'
        4 = 'Image'
        5 = 'TargetObject'
        6 = 'NewName'
    }

    $FileCreateStreamHashMapping = @{
        0 = 'UtcTime'
        1 = 'ProcessGuid'
        2 = 'ProcessId'
        3 = 'Image'
        4 = 'TargetFilename'
        5 = 'CreationUtcTime'
        6 = 'Hash'
    }

    $SysmonConfigurationChangeMapping = @{
        0 = 'UtcTime'
        1 = 'Configuration'
        2 = 'ConfigurationFileHash'
    }

    $PipeEventCreatedMapping = @{
        0 = 'UtcTime'
        1 = 'ProcessGuid'
        2 = 'ProcessId'
        3 = 'PipeName'
        4 = 'Image'
    }

    $PipeEventConnectedMapping = @{
        0 = 'UtcTime'
        1 = 'ProcessGuid'
        2 = 'ProcessId'
        3 = 'PipeName'
        4 = 'Image'
    }

    $WmiEventFilterMapping = @{
        0 = 'EventType'
        1 = 'UtcTime'
        2 = 'Operation'
        3 = 'User'
        4 = 'EventNamespace'
        5 = 'Name'
        6 = 'Query'
    }

    $WmiEventConsumerMapping = @{
        0 = 'EventType'
        1 = 'UtcTime'
        2 = 'Operation'
        3 = 'User'
        4 = 'Name'
        5 = 'Type'
        6 = 'Destination'
    }

    $WmiEventConsumerToFilterMapping = @{
        0 = 'EventType'
        1 = 'UtcTime'
        2 = 'Operation'
        3 = 'User'
        4 = 'Consumer'
        5 = 'Filter'
    }

    $EventTypeMapping = @{
        1  = @('ProcessCreate', $ProcessCreateMapping)
        2  = @('FileCreateTime', $FileCreateTimeMapping)
        3  = @('NetworkConnect', $NetworkConnectMapping)
        # SysmonServiceStateChange is not actually present in the schema. It is here for the sake of completeness.
        4  = @('SysmonServiceStateChange', $SysmonServiceStateChangeMapping)
        5  = @('ProcessTerminate', $ProcessTerminateMapping)
        6  = @('DriverLoad', $DriverLoadMapping)
        7  = @('ImageLoad', $ImageLoadMapping)
        8  = @('CreateRemoteThread', $CreateRemoteThreadMapping)
        9  = @('RawAccessRead', $RawAccessReadMapping)
        10 = @('ProcessAccess', $ProcessAccessMapping)
        11 = @('FileCreate', $FileCreateMapping)
        12 = @('RegistryEventCreateKey', $RegistryEventCreateKeyMapping)
        13 = @('RegistryEventSetValue', $RegistryEventSetValueMapping)
        14 = @('RegistryEventDeleteKey', $RegistryEventDeleteKeyMapping)
        15 = @('FileCreateStreamHash', $FileCreateStreamHashMapping)
        # SysmonConfigurationChange is not actually present in the schema. It is here for the sake of completeness.
        16 = @('SysmonConfigurationChange', $SysmonConfigurationChangeMapping)
        17 = @('PipeEventCreated', $PipeEventCreatedMapping)
        18 = @('PipeEventConnected', $PipeEventConnectedMapping)
        19 = @('WmiEventFilter', $WmiEventFilterMapping)
        20 = @('WmiEventConsumer', $WmiEventConsumerMapping)
        21 = @('WmiEventConsumerToFilter', $WmiEventConsumerToFilterMapping)
    }
    #endregion

    $RuleMemoryStream = New-Object -TypeName System.IO.MemoryStream -ArgumentList @(,$RuleBytes)

    $RuleReader = New-Object -TypeName System.IO.BinaryReader -ArgumentList $RuleMemoryStream

    # I'm noting here for the record that parsing could be slightly more robust to account for malformed
    # rule blobs. I'm writing this in my spare time so I likely won't put too much work into increased
    # parsing robustness.

    if ($RuleBytes.Count -lt 16) {
        $RuleReader.Dispose()
        $RuleMemoryStream.Dispose()
        throw 'Insufficient length to contain a Sysmon rule header.'
    }

    # This value should be either 0 or 1. 1 should be expected for a current Sysmon config.
    # A value of 1 indicates that offset 8 will contain the file offset to the first rule grouping.
    # A value of 0 should indicate that offset 8 will be the start of the first rule grouping.
    # Currently, I am just going to check that the value is 1 and throw an exception if it's not.
    $HeaderValue0 = $RuleReader.ReadUInt16()

    if ($HeaderValue0 -ne 1) {
        $RuleReader.Dispose()
        $RuleMemoryStream.Dispose()
        throw "Incorrect header value at offset 0x00. Expected: 1. Actual: $HeaderValue0"
    }

    # This value is expected to be 1. Any other value will indicate the presence of a "registry rule version"
    # that is incompatible with the current Sysmon schema version. A value other than 1 likely indicates the
    # presence of an old version of Sysmon. Any value besides 1 will not be supported in this script.
    $HeaderValue1 = $RuleReader.ReadUInt16()

    if ($HeaderValue1 -ne 1) {
        $RuleReader.Dispose()
        $RuleMemoryStream.Dispose()
        throw "Incorrect header value at offset 0x02. Expected: 1. Actual: $HeaderValue1"
    }

    $RuleGroupCount = $RuleReader.ReadUInt32()
    $RuleGroupBeginOffset = $RuleReader.ReadUInt32()

    $SchemaVersionMinor = $RuleReader.ReadUInt16()
    $SchemaVersionMajor = $RuleReader.ReadUInt16()

    $SchemaVersion = New-Object -TypeName System.Version -ArgumentList $SchemaVersionMajor, $SchemaVersionMinor, 0, 0

    Write-Verbose "Obtained the following schema version: $($SchemaVersion.ToString(2))"

    if (-not ($SupportedSchemaVersions -contains $SchemaVersion)) {
        $RuleReader.Dispose()
        $RuleMemoryStream.Dispose()
        throw "Unsupported schema version: $($SchemaVersion.ToString(2)). Schema version must be at least $($MinimumSupportedSchemaVersion.ToString(2))"
    }

    #region Perform offset updates depending upon the schema version here
    # This logic should be the first candidate for refactoring should the schema change drastically in the future.
    switch ($SchemaVersion.ToString(2)) {
        '4.0' {
            Write-Verbose 'Using schema version 4.00 updated offsets.'
            # ProcessCreate and ImageLoad values changed
            $EventTypeMapping[1][1] = $ProcessCreateMapping_4_00
            $EventTypeMapping[7][1] = $ImageLoadMapping_4_00
        }
    }
    #endregion

    $null = $RuleReader.BaseStream.Seek($RuleGroupBeginOffset, 'Begin')

    $EventCollection = for ($i = 0; $i -lt $RuleGroupCount; $i++) {
        $EventTypeValue = $RuleReader.ReadInt32()
        $EventType = $EventTypeMapping[$EventTypeValue][0]
        $EventTypeRuleTypes = $EventTypeMapping[$EventTypeValue][1]
        $OnMatchValue = $RuleReader.ReadInt32()

        $OnMatch = $null

        switch ($OnMatchValue) {
            0 { $OnMatch = 'Exclude' }
            1 { $OnMatch = 'Include' }
            default { $OnMatch = '?' }
        }

        $NextEventTypeOffset = $RuleReader.ReadInt32()
        $RuleCount = $RuleReader.ReadInt32()
        [PSObject[]] $Rules = New-Object -TypeName PSObject[]($RuleCount)

        # Parse individual rules here
        for ($j = 0; $j -lt $RuleCount; $j++) {
            $RuleType = $EventTypeRuleTypes[$RuleReader.ReadInt32()]
            $Filter = $EventConditionMapping[$RuleReader.ReadInt32()]
            $NextRuleOffset = $RuleReader.ReadInt32()
            $RuleTextLength = $RuleReader.ReadInt32()
            $RuleTextBytes = $RuleReader.ReadBytes($RuleTextLength)
            $RuleText = [Text.Encoding]::Unicode.GetString($RuleTextBytes).TrimEnd("`0")

            $Rules[$j] = [PSCustomObject] @{
                PSTypeName = 'Sysmon.Rule'
                RuleType = $RuleType
                Filter = $Filter
                RuleText = $RuleText
            }

            $null = $RuleReader.BaseStream.Seek($NextRuleOffset, 'Begin')
        }

        [PSCustomObject] @{
            PSTypeName = 'Sysmon.EventGroup'
            EventType = $EventType
            OnMatch = $OnMatch
            Rules = $Rules
        }

        $null = $RuleReader.BaseStream.Seek($NextEventTypeOffset, 'Begin')
    }

    $RuleReader.Dispose()
    $RuleMemoryStream.Dispose()

    # Calculate the hash of the binary rule blob
    $SHA256Hasher = New-Object -TypeName System.Security.Cryptography.SHA256CryptoServiceProvider
    $ConfigBlobSHA256Hash = ($SHA256Hasher.ComputeHash($RuleBytes) | ForEach-Object { $_.ToString('X2') }) -join ''

    [PSCustomObject] @{
        PSTypeName = 'Sysmon.EventCollection'
        SchemaVersion = $SchemaVersion
        ConfigBlobSHA256Hash = $ConfigBlobSHA256Hash
        Events = $EventCollection
    }
}
