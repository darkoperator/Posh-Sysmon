#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function Get-SysmonRule
{
    [CmdletBinding(DefaultParameterSetName = 'Path',
                   HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Get-SysmonRule.md')]
    Param
    (
        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='Path',
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        [string]$Path,

        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='LiteralPath',
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        [Alias('PSPath')]
        [string]$LiteralPath,

        # Event type to parse rules for.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet('ALL', 'NetworkConnect', 'ProcessCreate', 'FileCreateTime',
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad', 'ProcessAccess',
                     'RawAccessRead','ProcessAccess', 'FileCreateStreamHash',
                     'RegistryEvent', 'FileCreate', 'PipeEvent', 'WmiEvent')]
        [string[]]
        $EventType = @('ALL')
    )

    Begin{}
    Process
    {
        # Check if the file is a valid XML file and if not raise and error.
        try
        {
            switch($psCmdlet.ParameterSetName)
            {
                'Path'        {[xml]$Config = Get-Content -Path $Path}
                'LiteralPath' {[xml]$Config = Get-Content -LiteralPath $LiteralPath}
            }
        }
        catch [System.Management.Automation.PSInvalidCastException]
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

        # Collect all individual rules if they exist.
        $Rules = $Config.Sysmon.EventFiltering

        if ($EventType -contains 'ALL')
        {
            $TypesToParse = @('NetworkConnect', 'ProcessCreate', 'FileCreateTime',
                              'ProcessTerminate', 'ImageLoad', 'DriverLoad','CreateRemoteThread',
                              'ProcessAccess', 'RawAccessRead', 'FileCreateStreamHash',
                              'RegistryEvent', 'FileCreate', 'PipeEvent', 'WmiEvent')
        }
        else
        {
            $TypesToParse = $EventType
        }

        foreach($Type in $TypesToParse)
        {
            $EvtType = $MyInvocation.MyCommand.Module.PrivateData[$Type]
            $RuleData = $Rules.SelectNodes("//EventFiltering/$($EvtType)")
            if($RuleData -ne $null)
            {
                Write-Verbose -Message "$($EvtType) Rule Found."
                Get-RuleWithFilter($RuleData)
            }

        }
    }
    End{}
}