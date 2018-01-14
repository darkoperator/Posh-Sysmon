<#
.SYNOPSIS

Recovers a Sysmon XML configuration from a binary configuration.

.DESCRIPTION

ConvertTo-SysmonXMLConfiguration takes the parsed output from Get-SysmonConfiguration and converts it to an XML configuration. This function is useful for recovering lost Sysmon configurations or for performing reconnaisance.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

Required Dependencies: Get-SysmonConfiguration
                       GeneratedCode.ps1

.PARAMETER Configuration

Specifies the parsed Sysmon configuration output from Get-SysmonConfiguration.

.EXAMPLE

Get-SysmonConfiguration | ConvertTo-SysmonXMLConfiguration

.EXAMPLE

$Configuration = Get-SysmonConfiguration
ConvertTo-SysmonXMLConfiguration -Configuration $Configuration

.INPUTS

Sysmon.Configuration

ConvertTo-SysmonXMLConfiguration accepts a single result from Get-SysmonConfiguration over the pipeline. Note: it will not accept input from Get-SysmonConfiguration when "-MatchExeOutput" is specified.

.OUTPUTS

System.String

Outputs a Sysmon XML configuration document.
#>
function ConvertTo-SysmonXMLConfiguration {
    [OutputType([String])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSTypeName('Sysmon.Configuration')]
        $Configuration
    )

    $SchemaVersion = $Configuration.SchemaVersion

    # Get the parsing code for the respective schema.
    # Code injection note: an attacker would be able to influence the schema version used. That would only influence what
    #  non-injectible source code was supplied to Add-Type, however. $ConfigurationSchemaSource variables should always be
    #  constant variables with script (i.e. module) scope.
    $SchemaSource = Get-Variable -Name "SysmonConfigSchemaSource_$($SchemaVersion.Replace('.', '_'))" -Scope Script -ValueOnly
    
    # Compile the parsing code
    Add-Type -TypeDefinition $SchemaSource -ReferencedAssemblies 'System.Xml' -ErrorAction Stop

    $NamespaceName = "Sysmon_$($SchemaVersion.Replace('.', '_'))"

    # Create a base "Sysmon" object. This serves as the root node that will eventually be serialized to XML.
    $Sysmon = New-Object -TypeName "$NamespaceName.Sysmon"

    $Sysmon.schemaversion = $Configuration.SchemaVersion

    if ($Configuration.CRLCheckingEnabled) { $Sysmon.CheckRevocation = New-Object -TypeName "$NamespaceName.SysmonCheckRevocation" }

    # The hashing algorithms need to be lower case in the XML config.
    $Sysmon.HashAlgorithms = ($Configuration.HashingAlgorithms | ForEach-Object { $_.ToLower() }) -join ','

    $ProcessAccessString = ($Configuration.ProcessAccess | ForEach-Object { "$($_.ProcessName):0x$($_.AccessMask.ToString('x'))" }) -join ','
    if ($ProcessAccessString) { $Sysmon.ProcessAccessConfig = $ProcessAccessString }

    # Do not consider redundant event types. A well-formed binary Sysmon rule blob will have
    # identical RegistryEvent, PipeEvent, and WmiEvent rule entries as of config schema version 3.4[0]
    $EventTypesToExclude = @(
        'RegistryEventSetValue',
        'RegistryEventDeleteKey',
        'PipeEventConnected',
        'WmiEventConsumer',
        'WmiEventConsumerToFilter'
    )

    # Group rules by their respective event types - a requirement for
    # setting properties properly in the SysmonEventFiltering instance.
    $EventGrouping = $Configuration.Rules |
        Where-Object { -not ($EventTypesToExclude -contains $_.EventType) } |
            Group-Object -Property EventType

    # A configuration can technically not have any EventFiltering rules.
    if ($EventGrouping) {
        $Sysmon.EventFiltering = New-Object -TypeName "$NamespaceName.SysmonEventFiltering"

        foreach ($Event in $EventGrouping) {
            # The name of the event - e.g. ProcessCreate, FileCreate, etc.
            $EventName = $Event.Name

            # Normalize these event names.
            # Have a mentioned that I hate that these aren't unique names in Sysmon?
            switch ($EventName) {
                'RegistryEventCreateKey' { $EventName = 'RegistryEvent' }
                'PipeEventCreated' { $EventName = 'PipeEvent' }
                'WmiEventFilter' { $EventName = 'WmiEvent' }
            }

            if ($Event.Count -gt 2) {
                Write-Error "There is more than two $EventName entries. This should not be possible."
                return
            }

            if (($Event.Count -eq 2) -and ($Event.Group[0].OnMatch -eq $Event.Group[1].OnMatch)) {
                Write-Error "The `"onmatch`" attribute values for the $EventName rules are not `"include`" and `"exclude`". This should not be possible."
                return
            }

            $Events = foreach ($RuleSet in $Event.Group) {
                # The dynamic typing that follows relies upon naming consistency in the schema serialization source code.
                $EventInstance = New-Object -TypeName "$NamespaceName.SysmonEventFiltering$EventName" -Property @{
                    onmatch = $RuleSet.OnMatch.ToLower()
                }

                $RuleDefs = @{}

                foreach ($Rule in $RuleSet.Rules) {
                    $PropertyName = $Rule.RuleType
                    # Since each property can be of a unique type, resolve it accordingly.
                    $PropertyTypeName = ("$NamespaceName.SysmonEventFiltering$EventName" -as [Type]).GetProperty($PropertyName).PropertyType.FullName.TrimEnd('[]')

                    if (-not $RuleDefs.ContainsKey($PropertyName)) {
                        $RuleDefs[$PropertyName] = New-Object -TypeName "Collections.ObjectModel.Collection``1[$PropertyTypeName]"
                    }

                    $RuleInstance = New-Object -TypeName $PropertyTypeName
                    # This needs to be lower case in the XML config.
                    $RuleInstance.condition = $Rule.Filter.ToLower()
                    # An exception is thrown here if the value has a space and it is being cast to an enum type.
                    # Currently, "Protected Process" is the only instance. I'll need to refactor this if more instances arise.
                    if ($Rule.RuleText -eq 'Protected Process') { $RuleInstance.Value = 'ProtectedProcess' } else { $RuleInstance.Value = $Rule.RuleText }

                    $RuleDefs[$PropertyName].Add($RuleInstance)
                }

                # Set the collected rule properties accordingly.
                foreach ($PropertyName in $RuleDefs.Keys) {
                    $EventInstance."$PropertyName" = $RuleDefs[$PropertyName]
                }

                $EventInstance
            }

            $EventPropertyName = $Events[0].GetType().Name.Substring('SysmonEventFiltering'.Length)
            $Sysmon.EventFiltering."$EventPropertyName" = $Events
        }
    }

    $XmlWriter = $null

    try {
        $XmlWriterSetting = New-Object -TypeName Xml.XmlWriterSettings
        # A Sysmon XML config is not expected to have an XML declaration line.
        $XmlWriterSetting.OmitXmlDeclaration = $True
        $XmlWriterSetting.Indent = $True
        # Use two spaces in place of a tab character.
        $XmlWriterSetting.IndentChars = '  '
        # Normalize newlines to CRLF.
        $XmlWriterSetting.NewLineHandling = [Xml.NewLineHandling]::Replace

        $XMlStringBuilder = New-Object -TypeName Text.StringBuilder

        $XmlWriter = [Xml.XmlWriter]::Create($XMlStringBuilder, $XmlWriterSetting)

        $XmlSerializer = New-Object -TypeName Xml.Serialization.XmlSerializer -ArgumentList ("$NamespaceName.Sysmon" -as [Type]), ''
        # This will strip any additional "xmlns" attributes from the root Sysmon element.
        $EmptyNamespaces = New-Object -TypeName Xml.Serialization.XmlSerializerNamespaces
        $EmptyNamespaces.Add('', '')

        $XmlSerializer.Serialize($XmlWriter, $Sysmon, $EmptyNamespaces)
    } catch {
        Write-Error $_
    } finally {
        if ($XmlWriter) { $XmlWriter.Close() }
    }

    $XMlStringBuilder.ToString()
}
