#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function Remove-SysmonRuleFilter {
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Remove-SysmonRuleFilter.md')]
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

        # Event type to update.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=1)]
        [ValidateSet('NetworkConnect', 'ProcessCreate', 'FileCreateTime',
            'ProcessTerminate', 'ImageLoad', 'DriverLoad',
            'CreateRemoteThread', 'RawAccessRead', 'ProcessAccess',
            'FileCreateStreamHash', 'RegistryEvent', 'FileCreate',
            'PipeEvent', 'WmiEvent')]
        [string]
        $EventType,

        # Event type on match action.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=2)]
        [ValidateSet('include', 'exclude')]
        [string]
        $OnMatch,

        # Condition for filtering against and event field.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=3)]
        [ValidateSet('Is', 'IsNot', 'Contains', 'Excludes', 'Image',
            'BeginWith', 'EndWith', 'LessThan', 'MoreThan')]
        [string]
        $Condition,

        # Event field to filter on.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=4)]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=5)]
        [string[]]
        $Value
    )

    Begin{}
    Process {
        $EvtType = $null
        # Check if the file is a valid XML file and if not raise and error.
        try {
            switch($psCmdlet.ParameterSetName) {
                'Path' {
                    [xml]$Config = Get-Content -Path $Path
                    $FileLocation = (Resolve-Path -Path $Path).Path
                }

                'LiteralPath' {
                    [xml]$Config = Get-Content -LiteralPath $LiteralPath
                    $FileLocation = (Resolve-Path -LiteralPath $LiteralPath).Path
                }
            }
        }
        catch [Management.Automation.PSInvalidCastException] {
            Write-Error -Message 'Specified file does not appear to be a XML file.'
            return
        }

        # Validate the XML file is a valid Sysmon file.
        if ($Config.SelectSingleNode('//Sysmon') -eq $null) {
            Write-Error -Message 'XML file is not a valid Sysmon config file.'
            return
        }

        $Rules = $Config.SelectSingleNode('//Sysmon/EventFiltering')

        # Select the proper condition string.
        switch ($Condition) {
            'Is' {$ConditionString = 'is'}
            'IsNot' {$ConditionString = 'is not'}
            'Contains' {$ConditionString = 'contains'}
            'Excludes' {$ConditionString = 'excludes'}
            'Image' {$ConditionString = 'image'}
            'BeginWith' {$ConditionString = 'begin with'}
            'EndWith' {$ConditionString = 'end with'}
            'LessThan' {$ConditionString = 'less than'}
            'MoreThan' {$ConditionString = 'more than'}
            Default {$ConditionString = 'is'}
        }

        # Check if the event type exists if not create it.
        if ($Rules -eq '') {
            Write-Error -Message 'Rule element does not exist. This appears to not be a valid config file'
            return
        } else {
            $EvtType = $MyInvocation.MyCommand.Module.PrivateData[$EventType]

            $EventRule = $Rules.SelectNodes("//EventFiltering/$($EvtType)")
        }

        if($EventRule -eq $null) {
            Write-Warning -Message "No rule for $($EvtType) was found."
            return
        }

        if($EventRule -eq $null) {
            Write-Error -Message "No rule for $($EvtType) was found."
            return
        } else {
            if ($EventRule.count -eq $null -or $EventRule.Count -eq 1) {
                if ($EventRule.onmatch -eq $OnMatch) {
                    $Filters = $EventRule.SelectNodes('*')
                    if ($Filters.count -gt 0) {
                        foreach($val in $Value) {
                            foreach($Filter in $Filters) {
                                if ($Filter.Name -eq $EventField) {
                                    if (($Filter.condition -eq $null) -and ($Condition -eq 'is') -and ($Filter.'#text' -eq $val)) {
                                        [void]$Filter.ParentNode.RemoveChild($Filter)
                                        Write-Verbose -Message "Filter for field $($EventField) with condition $($Condition) and value of $($val) removed."
                                    } elseif (($Filter.condition -eq $Condition) -and ($Filter.'#text' -eq $val)) {
                                        [void]$Filter.ParentNode.RemoveChild($Filter)
                                        Write-Verbose -Message "Filter for field $($EventField) with condition $($Condition) and value of $($val) removed."
                                    }
                                }
                            }
                        }
                        Get-RuleWithFilter($EventRule)
                    }
                }
            } else {
                Write-Verbose -Message 'Mutiple nodes.'
                foreach ($rule in $EventRule) {
                    if ($rule.onmatch -eq $OnMatch) {
                        $Filters = $rule.SelectNodes('*')
                        if ($Filters.count -gt 0) {
                            foreach($val in $Value) {
                                foreach($Filter in $Filters) {
                                    if ($Filter.Name -eq $EventField) {
                                        if (($Filter.condition -eq $null) -and ($Condition -eq 'is') -and ($Filter.'#text' -eq $val)) {
                                            [void]$Filter.ParentNode.RemoveChild($Filter)
                                            Write-Verbose -Message "Filter for field $($EventField) with condition $($Condition) and value of $($val) removed."
                                        } elseif (($Filter.condition -eq $Condition) -and ($Filter.'#text' -eq $val)) {
                                            [void]$Filter.ParentNode.RemoveChild($Filter)
                                            Write-Verbose -Message "Filter for field $($EventField) with condition $($Condition) and value of $($val) removed."
                                        }
                                    }
                                }
                            }
                            Get-RuleWithFilter($rule)
                        }
                    }
                }
            }
        }
        $config.Save($FileLocation)
    }
    End{}
}
