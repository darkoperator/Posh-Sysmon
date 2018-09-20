<#
.SYNOPSIS
Get the configured filters for a specified Event Type Rule in a Sysmon configuration file.
.DESCRIPTION
Get the configured filters for a specified Event Type Rule in a Sysmon configuration file.
.EXAMPLE
C:\PS>  Get-SysmonRuleFilter -Path C:\sysmon.xml -EventType ProcessCreate
Get the filter under the ProcessCreate Rule.
#>
function Get-SysmonRuleFilter {
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Get-SysmonRuleFilter.md')]
    Param (
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

        # Event type rule to get filter for.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName='Path',
            Position=1)]
        [ValidateSet('NetworkConnect', 'ProcessCreate', 'FileCreateTime',
            'ProcessTerminate', 'ImageLoad', 'DriverLoad',
            'CreateRemoteThread','RawAccessRead', 'ProcessAccess',
            'FileCreateStreamHash', 'RegistryEvent', 'FileCreate',
            'PipeEvent', 'WmiEvent','RuleName')]
        [string]
        $EventType,

        # Event type on match action.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=2)]
        [ValidateSet('include', 'exclude')]
        [string]
        $OnMatch
    )

    Begin{}
    Process {
        $EvtType = $null
        # Check if the file is a valid XML file and if not raise and error.
        try {
            switch($psCmdlet.ParameterSetName){
                'Path'{
                    [xml]$Config = Get-Content -Path $Path
                    $FileLocation = (Resolve-Path -Path $Path).Path
                }
                'LiteralPath' {
                    [xml]$Config = Get-Content -LiteralPath $LiteralPath
                    $FileLocation = (Resolve-Path -LiteralPath $LiteralPath).Path
                }
            }
        }
        catch [System.Management.Automation.PSInvalidCastException] {
            Write-Error -Message 'Specified file does not appear to be a XML file.'
            return
        }

        # Validate the XML file is a valid Sysmon file.
        if ($Config.SelectSingleNode('//Sysmon') -eq $null){
            Write-Error -Message 'XML file is not a valid Sysmon config file.'
            return
        }

        $Rules = $Config.SelectSingleNode('//Sysmon/EventFiltering')

        if ($Rules -eq '') {
            Write-Error -Message 'Rule element does not exist. This appears to not be a valid config file'
            return
        } else {
            $EvtType = $MyInvocation.MyCommand.Module.PrivateData[$EventType]

            $EventRule = $Rules.SelectNodes("//EventFiltering/$($EvtType)")
        }

        if($EventRule -eq $null) {
            Write-Error -Message "No rule for $($EvtType) was found."
            return
        } else {
            if ($EventRule.count -eq $null -or $EventRule.Count -eq 1) {
                Write-Verbose -Message 'Single Node'
                if ($EventRule.onmatch -eq $OnMatch) {
                    $Filters = $EventRule.SelectNodes('*')
                    if ($Filters.ChildNodes.Count -gt 0) {
                        foreach($Filter in $Filters) {
                            $FilterObjProps = @{}
                            $FilterObjProps['EventField'] = $Filter.Name
                            $FilterObjProps['Condition'] = &{if($Filter.condition -eq $null){'is'}else{$Filter.condition}}
                            $FilterObjProps['Value'] =  $Filter.'#text'
                            $FilterObjProps['EventType'] =  $EvtType
                            $FilterObjProps['OnMatch'] =  $OnMatch
                            $FilterObj = [pscustomobject]$FilterObjProps
                            $FilterObj.pstypenames.insert(0,'Sysmon.Rule.Filter')
                            $FilterObj
                        }

                    }
                }
            }
            else
            {
                Write-Verbose -Message 'Mutiple nodes.'
                foreach ($rule in $EventRule)
                {
                    if ($rule.onmatch -eq $OnMatch)
                    {
                        $Filters = $rule.SelectNodes('*')
                        if ($Filters.ChildNodes.Count -gt 0)
                        {
                            foreach($Filter in $Filters)
                            {
                                $FilterObjProps = @{}
                                $FilterObjProps['EventField'] = $Filter.Name
                                $FilterObjProps['Condition'] = &{if($Filter.condition -eq $null){'is'}else{$Filter.condition}}
                                $FilterObjProps['Value'] =  $Filter.'#text'
                                $FilterObjProps['EventType'] =  $EvtType
                                $FilterObjProps['OnMatch'] =  $OnMatch
                                $FilterObj = [pscustomobject]$FilterObjProps
                                $FilterObj.pstypenames.insert(0,'Sysmon.Rule.Filter')
                                $FilterObj
                            }

                        }
                    }
                }
            }
        }
    }
    End{}
}