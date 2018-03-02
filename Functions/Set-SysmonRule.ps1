#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function Set-SysmonRule
{
    [CmdletBinding(DefaultParameterSetName = 'Path',
                   HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Set-SysmonRule.md')]
    Param
    (
        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='Path',
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        $Path,

        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='LiteralPath',
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        [Alias('PSPath')]
        $LiteralPath,

        # Event type to update.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet('NetworkConnect', 'ProcessCreate', 'FileCreateTime',
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad', 'CreateRemoteThread',
                     'ProcessAccess', 'RawAccessRead', 'FileCreateStreamHash',
                     'RegistryEvent', 'FileCreate', 'PipeEvent', 'WmiEvent')]
        [string[]]
        $EventType,

        # Action for event type rule and filters.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet('Include', 'Exclude')]
        [String]
        $OnMatch = 'Exclude',

        # Action to take for Schema 3.0 files.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('Modify', 'Add')]
        [String]
        $Action = 'Modify'
    )

    Begin{}
    Process
    {
        # if no elemrnt create one either if it is schema 2.0 or 3.0.
        # If one is present we modify that one if Schema 2.0 and if Schema 3.0 and action modify.
        # If Schema 3.0 and action add we check if only is present and that it is not the same OnMatch
        # as being specified if it is we do nothing if not we add.


        # Check if the file is a valid XML file and if not raise and error.
        try
        {
            switch($psCmdlet.ParameterSetName)
            {
                'Path'
                {
                    [xml]$Config = Get-Content -Path $Path
                    $FileLocation = (Resolve-Path -Path $Path).Path
                }

                'LiteralPath'
                {
                    [xml]$Config = Get-Content -LiteralPath $LiteralPath
                    $FileLocation = (Resolve-Path -LiteralPath $LiteralPath).Path
                }
            }
        }
        catch [Management.Automation.PSInvalidCastException]
        {
            Write-Error -Message 'Specified file does not appear to be a XML file.'
            return
        }

        # Validate the XML file is a valid Sysmon file.
        if ($Config.SelectSingleNode('//Sysmon') -eq $null)
        {
            Write-Error -Message 'XML file is not a valid Sysmon config file.'
            return
        }

         if ($Config.Sysmon.schemaversion -notin $SysMonSupportedVersions)
        {
            Write-Error -Message 'This version of Sysmon Rule file is not supported.'
            return
        }

        $Rules = $config.SelectSingleNode('//Sysmon/EventFiltering')

        foreach($Type in $EventType)
        {
            $EvtType = $MyInvocation.MyCommand.Module.PrivateData[$Type]
            $RuleData = $Rules.SelectSingleNode("//EventFiltering/$($EvtType)")
            $elements = $Rules."$($EvtType)" | Select-Object -property onmatch -Unique

            if($RuleData -ne $null)
            {
                if ($Rules."$($EvtType)".count -eq $null)
                {
                    if (($Config.Sysmon.schemaversion -eq '2.0') -or ($Config.Sysmon.schemaversion -ge 3.0 -and $Action -eq 'Modify'))
                    {
                        Write-Verbose -Message "Setting as default action for $($EvtType) the rule on match of $($OnMatch)."
                        $RuleData.SetAttribute('onmatch',($OnMatch.ToLower()))
                        Write-Verbose -Message 'Action has been set.'
                    }
                    elseif ($Config.Sysmon.schemaversion -ge 3.0 -and $Action -eq 'Add')
                    {
                        if ($RuleData.onmatch -ne $OnMatch)
                        {
                            Write-Verbose -Message "Creating rule for event type with action of $($OnMatch)"
                            $TypeElement = $config.CreateElement($EvtType)
                            $TypeElement.SetAttribute('onmatch',($OnMatch.ToLower()))
                             $RuleData = $Rules.AppendChild($TypeElement)
                            Write-Verbose -Message 'Action has been set.'
                        }
                        else
                        {
                            Write-Verbose -Message 'A rule with the specified onmatch action already exists.'
                        }
                    }
                }
                elseif ($Config.Sysmon.schemaversion -ge 3.0 -and $elements.count -eq 2)
                {
                    Write-Verbose -Message 'A rule with the specified onmatch action already exists.'
                }
                else
                {
                    Write-Error -Message 'This XML file does not conform to the schema.'
                    return
                }
            }
            else
            {
                Write-Verbose -Message "No rule for $($EvtType) was found."
                Write-Verbose -Message "Creating rule for event type with action of $($OnMatch)"
                $TypeElement = $config.CreateElement($EvtType)
                $TypeElement.SetAttribute('onmatch',($OnMatch.ToLower()))
                $RuleData = $Rules.AppendChild($TypeElement)
                Write-Verbose -Message 'Action has been set.'
            }

            Get-RuleWithFilter($RuleData)
        }
        $config.Save($FileLocation)
    }
    End{}
}