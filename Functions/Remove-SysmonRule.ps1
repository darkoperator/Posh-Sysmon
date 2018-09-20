#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function Remove-SysmonRule
{
    [CmdletBinding(DefaultParameterSetName = 'Path',
                   HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Remove-SysmonRule.md')]
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

        # Event type to remove. It is case sensitive.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet('NetworkConnect', 'ProcessCreate', 'FileCreateTime',
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad', 'CreateRemoteThread',
                     'ProcessAccess', 'RawAccessRead', 'FileCreateStreamHash',
                     'RegistryEvent', 'FileCreate', 'PipeEvent', 'WmiEvent','RuleName')]
        [string[]]
        $EventType,

        # Action for event type rule and filters.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet('Include', 'Exclude')]
        [String]
        $OnMatch = 'Exclude'
    )

    Begin{}
    Process
    {
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
        foreach ($rule in $rules.ChildNodes)
        {
            if ($rule.name -in $EventType -and $rule.onmatch -eq $OnMatch)
            {
                [void]$rule.ParentNode.RemoveChild($rule)
                Write-Verbose -Message "Removed rule for $($EventType)."
            }
        }

        $config.Save($FileLocation)
    }
    End{}
}