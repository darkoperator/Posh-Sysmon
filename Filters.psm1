<#
.Synopsis
   Adds a new Sysmon Image Load Filter.
.DESCRIPTION
   Adds a new Sysmon Image Load Filter to a an
   exiting Sysmon config file.
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
        $FieldString = Get-EvenFieldCasedString -EventField $EventField

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
   Adds a new Sysmon Driver Load Filter.
.DESCRIPTION
   Adds a new Sysmon Driver Load Filter to a an
   exiting Sysmon config file.
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
        $FieldString = Get-EvenFieldCasedString -EventField $EventField

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
   Adds a new Sysmon Network Connect Filter.
.DESCRIPTION
   Adds a new Sysmon Network Connect Filter to a an
   exiting Sysmon config file.
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
        $FieldString = Get-EvenFieldCasedString -EventField $EventField

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
   Adds a new Sysmon File Create Filter.
.DESCRIPTION
   Adds a new Sysmon File Create Filter to a an
   exiting Sysmon config file.
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
        $FieldString = Get-EvenFieldCasedString -EventField $EventField

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
   Adds a new Sysmon Process Create Filter.
.DESCRIPTION
   Adds a new Sysmon Process Create Filter to a an
   exiting Sysmon config file.
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
        $FieldString = Get-EvenFieldCasedString -EventField $EventField

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
   Adds a new Sysmon Process Termination Filter.
.DESCRIPTION
   Adds a new Sysmon Process Termination Filter to a an
   exiting Sysmon config file.
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
       $FieldString = Get-EvenFieldCasedString -EventField $EventField

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
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad')]
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
            $EvtType = Get-EvenTypeCasedString -EventType $EventType

            $EventRule = $Rules.SelectSingleNode("//Rules/$($EvtType)")
        }

        if($EventRule -eq $null)
        {
            Write-Warning -Message "No rule for $($EvtType) was found."
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


function Get-RuleWithFilter
{
    Param
    (
        [Parameter(Mandatory=$true)]
        $Rules
    )
    $RuleObjOptions = @{}

    $RuleObjOptions['EventType'] = $Rules.Name
    if ($Rules.default -eq $null -or $Rules.default -eq 'exclude')
    {
           $RuleObjOptions['DefaultAction'] = 'Exclude'
    }
    else
    {
        $RuleObjOptions['DefaultAction'] = 'Include'
    }

    # Process individual filters
    $Nodes = $Rules.selectnodes('*')
    if ($Nodes.count -eq 0)
    {
        $RuleObjOptions['Scope'] = 'All Events'
    }
    else
    {
        $RuleObjOptions['Scope'] = 'Filtered'
        $Filters = @()
        foreach ($Node in $Nodes)
        {
            $FilterObjProps = @{}
            $FilterObjProps['EventField'] = $Node.Name
            $FilterObjProps['Condition'] = &{if($Node.condition -eq $null){'is'}else{$Node.condition}}
            $FilterObjProps['Value'] =  $Node.'#text'
            $FilterObj = [pscustomobject]$FilterObjProps
            $FilterObj.pstypenames.insert(0,'Sysmon.Rule.Filter')
            $Filters += $FilterObj
        }
        $RuleObjOptions['Filters'] = $Filters
    }

    $RuleObj = [pscustomobject]$RuleObjOptions
    $RuleObj.pstypenames.insert(0,'Sysmon.Rule')
    $RuleObj
}

<#
.Synopsis
   Creates a filter for an event field for an event type in a Sysmon XML configuration file.
.DESCRIPTION
   Creates a filter for an event field for an event type in a Sysmon XML configuration file.
.EXAMPLE
   New-nRuleFilter -Path .\pc_cofig.xml -EventType NetworkConnect -EventField image -Condition Is -Value 'iexplorer.exe' -Verbose
    
    VERBOSE: No rule for NetworkConnect was found.
    VERBOSE: Creating rule for event type with default action if Exclude
    VERBOSE: Rule created succesfully

    C:\PS>Get-GetSysmonRules -Path .\pc_cofig.xml -EventType NetworkConnect


    EventType     : NetworkConnect
    Scope         : Filtered
    DefaultAction : Exclude
    Filters       : {@{EventField=image; Condition=Is; Value=iexplorer.exe}}


    Create a filter to capture all network connections from iexplorer.exe.
#>
function New-RuleFilter
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

        # Event type to create filter for.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet('NetworkConnect', 'ProcessCreate', 'FileCreateTime', 
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad', IgnoreCase = $false)]
        [string]
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
            $RuleData -eq $null
        }
        else
        {
            $RuleData = $Rules.SelectSingleNode("//Rules/$($EventType)")
        }

        if($RuleData -eq $null)
        {
            Write-Verbose -Message "No rule for $($EventType) was found."
            Write-Verbose -Message 'Creating rule for event type with default action if Exclude'
            $TypeElement = $Config.CreateElement($EventType)
            [void]$Rules.AppendChild($TypeElement)
            $RuleData = $Rules.SelectSingleNode("//Rules/$($EventType)")
            Write-Verbose -Message 'Rule created succesfully'
        }

        Write-Verbose -Message "Creating filters for event type $($EventType)."
        # For each value for the event type create a filter.
        foreach($val in $value)
        {
            Write-Verbose -Message "Creating filter for event filed $($EventField) with condition $($Condition) for value $($val)."
            $FieldElement = $Config.CreateElement($EventField)
            $Filter = $RuleData.AppendChild($FieldElement)
            $Filter.SetAttribute('condition',$Condition)
            $filter.InnerText = $val
        }
        Get-RuleWithFilter($RuleData)

        $Config.Save($FileLocation)
    }
    End{}
}

<#
.Synopsis
   Returns a properly cased EventType Name string for Sysmon.
.DESCRIPTION
   Returns a properly cased EventType Name string for Sysmon.
.EXAMPLE
   Get-EvenTypeCasedString -EventType driverload
   DriverLoad

#>
function Get-EvenTypeCasedString
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # EventType name that we will look the proper case for.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateSet('NetworkConnect', 'ProcessCreate', 'FileCreateTime', 
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad')]
        $EventType
    )

    Begin{}
    Process
    {
        switch ($EventType)
        {
            'NetworkConnect' {'NetworkConnect'}
            'ProcessCreate' {'ProcessCreate'}
            'FileCreateTime' {'FileCreateTime'}
            'ProcessTerminate' {'ProcessTerminate'}
            'ImageLoad' {'ImageLoad'}
            'DriverLoad' {'DriverLoad'}
        }
    }
    End{}
}


<#
.Synopsis
   Returns a properly cased Event Field Name string for Sysmon.
.DESCRIPTION
   Returns a properly cased Event Fielde Name string for Sysmon.
.EXAMPLE
    Get-EvenFieldCasedString -EventField commandline
CommandLine

#>
function Get-EvenFieldCasedString
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # EventType name that we will look the proper case for.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateSet('UtcTime', 'ProcessGuid', 'ProcessId', 'Image', 
                     'ImageLoaded', 'HashType', 'Hash', 'Signed', 
                     'Signature', 'User', 'Protocol', 'Initiated', 'SourceIsIpv6', 
                     'SourceIp', 'SourceHostname', 'SourcePort', 
                     'SourcePortName', 'DestinationIsIpv6', 
                     'DestinationIp', 'DestinationHostname', 
                     'DestinationPort', 'DestinationPortName',
                     'TargetFilename', 'CreationUtcTime', 
                     'PreviousCreationUtcTime', 'CommandLine', 
                     'LogonGuid', 'LogonId','TerminalSessionId', 
                     'IntegrityLevel', 'HashType', 'Hash', 
                     'ParentProcessGuid', 'ParentProcessId',
                     'ParentImage', 'ParentCommandLine')]
        $EventField
    )

    Begin{}
    Process
    {
        switch ($EventField)
        {
            'UtcTime' {'UtcTime'}
            'ProcessGuid' {'ProcessGuid'}
            'ProcessId' {'ProcessId'}
            'Image' {'Image'}
            'ImageLoaded' {'ImageLoaded'}
            'HashType' {'HashType'}
            'Hash' {'Hash'}
            'Signed' {'Signed'} 
            'Signature' {'Signature'}
            'User' {'User'}
            'Protocol' {'Protocol'}
            'Initiated' {'Initiated'} 
            'SourceIsIpv6'{'SourceIsIpv6'}
            'SourceIp' {'SourceIp'}
            'SourceHostname' {'SourceHostname'}
            'SourcePort' {'SourcePort'} 
            'SourcePortName' {'SourcePortName'}
            'DestinationIsIpv6' {'DestinationIsIpv6'}
            'DestinationIp' {'DestinationIp'}
            'DestinationHostname' {'DestinationHostname'}
            'DestinationPort' {'DestinationPort'} 
            'DestinationPortName' {'DestinationPortName'}
            'TargetFilename' {'TargetFilename'}
            'CreationUtcTime' {'CreationUtcTime'}
            'PreviousCreationUtcTime' {'PreviousCreationUtcTime'} 
            'CommandLine' {'CommandLine'}
            'LogonGuid' {'LogonGuid'}
            'LogonId' {'LogonId'}
            'TerminalSessionId' {'TerminalSessionId'} 
            'IntegrityLevel' {'IntegrityLevel'}
            'HashType' {'HashType'}
            'Hash' {'Hash'}
            'ParentProcessGuid' {'ParentProcessGuid'}
            'ParentProcessId' {'ParentProcessId'}
            'ParentImage' {'ParentImage'} 
            'ParentCommandLine' {'ParentCommandLine'}
        }
    }
    End{}
}

Export-ModuleMember -Function '*-sysmon*'