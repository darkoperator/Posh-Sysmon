<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function New-SysmonImageLoadFilter
{
    [CmdletBinding(DefaultParameterSetName = 'Path')]
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

        # Condition for filtering against and event field.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet('Is', 'IsNot', 'Contains', 'Excludes', 'Image',
                     'BeginWith', 'EndWith', 'LessThan', 'MoreThan')]
        [string]
        $Condition,

        # Event field to filter on.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [ValidateSet('UtcTime', 'ProcessGuid', 'ProcessId', 'Image', 
                     'ImageLoaded', 'HashType', 'Hash', 'Signed', 
                     'Signature')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=4)]
        [string[]]
        $Value
     )

    Begin
    {
    }
    Process
    {
        # Select the proper cased sting for the event field.
        switch ($EventField)
        {
            'UtcTime' {$FieldString = 'UtcTime'}
            'ProcessGuid'{$FieldString = 'ProcessGuid'} 
            'ProcessId' {$FieldString = 'ProcessId'}
            'Image' {$FieldString = 'Image'} 
            'ImageLoaded' {$FieldString = 'ImageLoaded'} 
            'HashType' {$FieldString = 'HashType'}
            'Hash' {$FieldString = 'Hash'}
            'Signed' {$FieldString = 'Signed'} 
            'Signature' {$FieldString = 'Signature'}
        }

        switch($psCmdlet.ParameterSetName)
        {
            'Path'
            {
                New-RuleFilter -Path $Path -EventType ImageLoad -Condition $Condition -EventField $FieldString -Value $Value
            }

            'LiteralPath' 
            {
                New-RuleFilter -LiteralPath $LiteralPath -EventType ImageLoad -Condition $Condition -EventField $FieldString -Value $Value
            }
        }

    }
    End
    {
    }
}


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function New-SysmonDriverLoadFilter
{
    [CmdletBinding(DefaultParameterSetName = 'Path')]
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

        # Condition for filtering against and event field.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet('Is', 'IsNot', 'Contains', 'Excludes', 'Image',
                     'BeginWith', 'EndWith', 'LessThan', 'MoreThan')]
        [string]
        $Condition,

        # Event field to filter on.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [ValidateSet('UtcTime', 'ImageLoaded', 'HashType', 
                     'Hash', 'Signed', 'Signature')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=4)]
        [string[]]
        $Value
     )

    Begin
    {
    }
    Process
    {
        # Select the proper cased sting for the event field.
        switch ($EventField)
        {
            'UtcTime' {$FieldString = 'UtcTime'}
            'ImageLoaded'{$FieldString = 'ImageLoaded'} 
            'HashType' {$FieldString = 'HashType'}
            'Hash' {$FieldString = 'Hash'} 
            'Signed' {$FieldString = 'Signed'} 
            'Signature' {$FieldString = 'Signature'}
        }

        switch($psCmdlet.ParameterSetName)
        {
            'Path'
            {
                New-RuleFilter -Path $Path -EventType DriverLoad -Condition $Condition -EventField $FieldString -Value $Value
            }

            'LiteralPath' 
            {
                New-RuleFilter -LiteralPath $LiteralPath -EventType DriverLoad -Condition $Condition -EventField $FieldString -Value $Value
            }
        }

    }
    End
    {
    }
}


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function New-SysmonNetworkConnectFilter
{
    [CmdletBinding(DefaultParameterSetName = 'Path')]
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

        # Condition for filtering against and event field.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet('Is', 'IsNot', 'Contains', 'Excludes', 'Image',
                     'BeginWith', 'EndWith', 'LessThan', 'MoreThan')]
        [string]
        $Condition,

        # Event field to filter on.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [ValidateSet('UtcTime', 'ProcessGuid', 'ProcessId', 'Image', 
                     'User', 'Protocol', 'Initiated', 'SourceIsIpv6', 
                     'SourceIp', 'SourceHostname', 'SourcePort', 
                     'SourcePortName', 'DestinationIsIpv6', 
                     'DestinationIp', 'DestinationHostname', 
                     'DestinationPort', 'DestinationPortName')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=4)]
        [string[]]
        $Value
     )

    Begin
    {
    }
    Process
    {
        # Select the proper cased sting for the event field.
        switch ($EventField)
        {
            'UtcTime' {$FieldString = 'UtcTime'}
            'ProcessGuid'{$FieldString = 'ProcessGuid'} 
            'ProcessId' {$FieldString = 'ProcessId'}
            'Image' {$FieldString = 'Image'} 
            'User' {$FieldString = 'User'} 
            'Protocol' {$FieldString = 'Protocol'}
            'Initiated' {$FieldString = 'Initiated'}
            'SourceIsIpv6'{$FieldString = 'SourceIsIpv6'} 
            'SourceIp' {$FieldString = 'SourceIp'}
            'SourceHostname' {$FieldString = 'SourceHostname'} 
            'SourcePort' {$FieldString = 'SourcePort'} 
            'SourcePortName' {$FieldString = 'SourcePortName'}
            'DestinationIsIpv6' {$FieldString = 'DestinationIsIpv6'}
            'DestinationIp'{$FieldString = 'DestinationIp'} 
            'DestinationHostname' {$FieldString = 'DestinationHostname'}
            'DestinationPort' {$FieldString = 'DestinationPortName'} 
            'DestinationPortName' {$FieldString = 'Signed'} 
        }

        switch($psCmdlet.ParameterSetName)
        {
            'Path'
            {
                New-RuleFilter -Path $Path -EventType NetworkConnect -Condition $Condition -EventField $FieldString -Value $Value
            }

            'LiteralPath' 
            {
                New-RuleFilter -LiteralPath $LiteralPath -EventType NetworkConnect -Condition $Condition -EventField $FieldString -Value $Value
            }
        }

    }
    End
    {
    }
}


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function New-SysmonFileCreateFilter
{
    [CmdletBinding(DefaultParameterSetName = 'Path')]
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

        # Condition for filtering against and event field.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet('Is', 'IsNot', 'Contains', 'Excludes', 'Image',
                     'BeginWith', 'EndWith', 'LessThan', 'MoreThan')]
        [string]
        $Condition,

        # Event field to filter on.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [ValidateSet('UtcTime', 'ProcessGuid', 'ProcessId', 'Image', 
                     'TargetFilename', 'CreationUtcTime', 
                     'PreviousCreationUtcTime')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=4)]
        [string[]]
        $Value
     )

    Begin
    {
    }
    Process
    {
        # Select the proper cased sting for the event field.
        switch ($EventField)
        {
            'UtcTime' {$FieldString = 'UtcTime'}
            'ProcessGuid'{$FieldString = 'ProcessGuid'} 
            'ProcessId' {$FieldString = 'ProcessId'}
            'TargetFilename' {$FieldString = 'TargetFilename'} 
            'CreationUtcTime' {$FieldString = 'CreationUtcTime'} 
            'PreviousCreationUtcTime' {$FieldString = 'PreviousCreationUtcTime'}
        }

        switch($psCmdlet.ParameterSetName)
        {
            'Path'
            {
                New-RuleFilter -Path $Path -EventType FileCreateTime -Condition $Condition -EventField $FieldString -Value $Value
            }

            'LiteralPath' 
            {
                New-RuleFilter -LiteralPath $LiteralPath -EventType FileCreateTime -Condition $Condition -EventField $FieldString -Value $Value
            }
        }

    }
    End
    {
    }
}


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function New-SysmonProcessCreateFilter
{
    [CmdletBinding(DefaultParameterSetName = 'Path')]
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

        # Condition for filtering against and event field.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet('Is', 'IsNot', 'Contains', 'Excludes', 'Image',
                     'BeginWith', 'EndWith', 'LessThan', 'MoreThan')]
        [string]
        $Condition,

        # Event field to filter on.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [ValidateSet('UtcTime', 'ProcessGuid', 'ProcessId', 'Image', 
                     'CommandLine', 'User', 'LogonGuid', 'LogonId',
                     'TerminalSessionId', 'IntegrityLevel', 'HashType',
                     'Hash', 'ParentProcessGuid', 'ParentProcessId',
                     'ParentImage', 'ParentCommandLine')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=4)]
        [string[]]
        $Value
     )

    Begin
    {
    }
    Process
    {
        # Select the proper cased sting for the event field.
        switch ($EventField)
        {
            'UtcTime' {$FieldString = 'UtcTime'}
            'ProcessGuid'{$FieldString = 'ProcessGuid'} 
            'ProcessId' {$FieldString = 'ProcessId'}
            'Image' {$FieldString = 'Image'} 
            'CommandLine' {$FieldString = 'CommandLine'} 
            'LogonGuid' {$FieldString = 'LogonGuid'}
            'LogonId' {$FieldString = 'LogonId'}
            'TerminalSessionId'{$FieldString = 'TerminalSessionId'} 
            'IntegrityLevel' {$FieldString = 'IntegrityLevel'}
            'HashType' {$FieldString = 'HashType'} 
            'Hash' {$FieldString = 'Hash'} 
            'ParentProcessGuid' {$FieldString = 'ParentProcessGuid'}
            'ParentProcessId' {$FieldString = 'ParentProcessId'} 
            'ParentImage' {$FieldString = 'ParentImage'} 
            'ParentCommandLine' {$FieldString = 'ParentCommandLine'}
        }

        switch($psCmdlet.ParameterSetName)
        {
            'Path'
            {
                New-RuleFilter -Path $Path -EventType ProcessCreate -Condition $Condition -EventField $FieldString -Value $Value
            }

            'LiteralPath' 
            {
                New-RuleFilter -LiteralPath $LiteralPath -EventType ProcessCreate -Condition $Condition -EventField $FieldString -Value $Value
            }
        }

    }
    End
    {
    }
}


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function New-SysmonProcessTerminateFilter
{
    [CmdletBinding(DefaultParameterSetName = 'Path')]
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

        # Condition for filtering against and event field.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet('Is', 'IsNot', 'Contains', 'Excludes', 'Image',
                     'BeginWith', 'EndWith', 'LessThan', 'MoreThan')]
        [string]
        $Condition,

        # Event field to filter on.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [ValidateSet('UtcTime', 'ProcessGuid', 'ProcessId')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=4)]
        [string[]]
        $Value
     )

    Begin
    {
    }
    Process
    {
        # Select the proper cased sting for the event field.
        switch ($EventField)
        {
            'UtcTime' {$FieldString = 'UtcTime'}
            'ProcessGuid'{$FieldString = 'ProcessGuid'} 
            'ProcessId' {$FieldString = 'ProcessId'}
        }

        switch($psCmdlet.ParameterSetName)
        {
            'Path'
            {
                New-RuleFilter -Path $Path -EventType ProcessTerminate -Condition $Condition -EventField $FieldString -Value $Value
            }

            'LiteralPath' 
            {
                New-RuleFilter -LiteralPath $LiteralPath -EventType ProcessTerminate -Condition $Condition -EventField $FieldString -Value $Value
            }
        }

    }
    End
    {
    }
}

<#
.Synopsis
   Remove on or more filter from a rule in a Sysmon XML configuration file.
.DESCRIPTION
   Remove on or more filter from a rule in a Sysmon XML configuration file.
.EXAMPLE
   Remove-SysmonRuleFilter -Path .\pc_marketing.xml -EventType NetworkConnect -Condition Image -EventField Image -Value $images -Verbose
   VERBOSE: Filter for field Image with condition Image and value of C:\Windows\System32\svchost.exe removed.
   VERBOSE: Filter for field Image with condition Image and value of C:\Program Files (x86)\Internet Explorer\iexplore.exe removed.
   VERBOSE: Filter for field Image with condition Image and value of C:\Program Files\Internet Explorer\iexplore.exe removed.
   VERBOSE: Filter for field Image with condition Image and value of C:\Program Files (x86)\Google\Chrome\Application\chrome.exe removed.
   VERBOSE: Filter for field Image with condition Image and value of C:\Program Files (x86)\PuTTY\putty.exe removed.
   VERBOSE: Filter for field Image with condition Image and value of C:\Program Files (x86)\PuTTY\plink.exe removed.
   VERBOSE: Filter for field Image with condition Image and value of C:\Program Files (x86)\PuTTY\pscp.exe removed.
   VERBOSE: Filter for field Image with condition Image and value of C:\Program Files (x86)\PuTTY\psftp.exe removed.

   EventType     : NetworkConnect
   Scope         : All Events
   DefaultAction : Exclude
   Filters       :

   Remove a series of filter where a list f values are saved in a array.
#>
function Remove-SysmonRuleFilter
{
    [CmdletBinding(DefaultParameterSetName = 'Path')]
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
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad', IgnoreCase = $false)]
        [string[]]
        $EventType,

        # Condition for filtering against and event field.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet('Is', 'IsNot', 'Contains', 'Excludes', 'Image',
                     'BeginWith', 'EndWith', 'LessThan', 'MoreThan')]
        [string]
        $Condition,

        # Event field to filter on.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=4)]
        [string[]]
        $Value
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

        $Rules = $Config.SelectSingleNode('//Sysmon/Rules')

        # Select the proper condition string.
        switch ($Condition)
        {
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
        if ($Rules -eq '')
        {
            Write-Error -Message 'Rule element does not exist. This appears to not be a valid config file'
            return
        }
        else
        {
            $EventRule = $Rules.SelectSingleNode("//Rules/$($EventType)")
        }

        if($EventRule -eq $null)
        {
            Write-Warning -Message "No rule for $($EventType) was found."
            return
        }
        $Filters = $EventRule.SelectNodes('*')
        if ($Filters.count -gt 0)
        {
            foreach($val in $Value)
            {
                foreach($Filter in $Filters)
                {
                    if ($Filter.Name -eq $EventField)
                    {
                        if (($Filter.condition -eq $null) -and ($Condition -eq 'is') -and ($Filter.'#text' -eq $val))
                        {
                            [void]$Filter.ParentNode.RemoveChild($Filter)
                            Write-Verbose -Message "Filter for field $($EventField) with condition $($Condition) and value of $($val) removed."
                        }
                        elseif (($Filter.condition -eq $Condition) -and ($Filter.'#text' -eq $val))
                        {
                            [void]$Filter.ParentNode.RemoveChild($Filter)
                            Write-Verbose -Message "Filter for field $($EventField) with condition $($Condition) and value of $($val) removed."
                        }
                    }
                }
            }
            Get-RuleWithFilter($EventRule)
        }
        else
        {
            Write-Warning -Message 'This event type has no filters configured.'
            return
        }

        $config.Save($FileLocation)
    }
    End{}
}