# TODO:
# * Add help and param block to Get-RuleWithFilter

 . "$PSScriptRoot\Filters.ps1"
 . "$PSScriptRoot\Config.ps1"

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