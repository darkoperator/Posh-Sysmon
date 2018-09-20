
# Load functions
 . "$($PSScriptRoot)\Functions\Get-SysmonEventData.ps1"
 . "$($PSScriptRoot)\Functions\Get-SysmonHashingAlgorithm.ps1"
 . "$($PSScriptRoot)\Functions\Get-SysmonRule.ps1"
 . "$($PSScriptRoot)\Functions\Get-SysmonRuleFilter.ps1"
 . "$($PSScriptRoot)\Functions\New-SysmonConfiguration.ps1"
 . "$($PSScriptRoot)\Functions\New-SysmonCreateRemoteThreadFilter.ps1"
 . "$($PSScriptRoot)\Functions\New-SysmonDriverLoadFilter.ps1"
 . "$($PSScriptRoot)\Functions\New-SysmonFileCreateFilter.ps1"
 . "$($PSScriptRoot)\Functions\New-SysmonFileCreateStreamHashFilter.ps1"
 . "$($PSScriptRoot)\Functions\New-SysmonImageLoadFilter.ps1"
 . "$($PSScriptRoot)\Functions\New-SysmonNetworkConnectFilter.ps1"
 . "$($PSScriptRoot)\Functions\New-SysmonPipeFilter.ps1"
 . "$($PSScriptRoot)\Functions\New-SysmonProcessAccessFilter.ps1"
 . "$($PSScriptRoot)\Functions\New-SysmonProcessCreateFilter.ps1"
 . "$($PSScriptRoot)\Functions\New-SysmonProcessTerminateFilter.ps1"
 . "$($PSScriptRoot)\Functions\New-SysmonRawAccessReadFilter.ps1"
 . "$($PSScriptRoot)\Functions\New-SysmonRegistryFilter.ps1"
 . "$($PSScriptRoot)\Functions\New-SysmonWmiFilter.ps1"
 . "$($PSScriptRoot)\Functions\Remove-SysmonRule.ps1"
 . "$($PSScriptRoot)\Functions\Remove-SysmonRuleFilter.ps1"
 . "$($PSScriptRoot)\Functions\Set-SysmonHashingAlgorithm.ps1"
 . "$($PSScriptRoot)\Functions\Set-SysmonRule.ps1"
 . "$($PSScriptRoot)\Functions\Get-SysmonConfiguration.ps1"
 . "$($PSScriptRoot)\Functions\ConvertTo-SysmonXMLConfiguration.ps1"
 . "$($PSScriptRoot)\Functions\ConvertFrom-SysmonBinaryConfiguration.ps1"

# Supporteted Sysmon schema versions.
$SysMonSupportedVersions = @(
    '4.0'
    '4.1'
 )

# Table that maps schema version to Sysmon version.
$sysmonVerMap = @{
     '2.0' = '3.0'
     '3.0' = '4.0'
     '3.1' = '4.11'
     '3.2' = '5.0'
     '3.3' = '6.0'
     '3.4' = '6.1, 6.2'
     '4.0' = '7.0'
     '4.1' = '8.0'
 }

function Get-RuleWithFilter
{
    Param
    (
        [Parameter(Mandatory=$true)]
        $Rules
    )
    foreach ($rule in $Rules)
    {
        $RuleObjOptions = [ordered]@{}
        $RuleObjOptions['EventType'] = $Rule.Name
        if ($Rule.onmatch -eq $null -or $Rule.onmatch -eq 'exclude')
        {
               $RuleObjOptions.Add('DefaultAction','Exclude')
        }
        else
        {
            $RuleObjOptions.Add('DefaultAction','Include')
        }

        # Process individual filters
        $Nodes = $Rule.selectnodes('*')
        if ($Nodes.count -eq 0)
        {
            $RuleObjOptions.add('Scope','All Events')
        }
        else
        {
            $RuleObjOptions.add('Scope','Filtered')
            $Filters = @()
            foreach ($Node in $Nodes)
            {
                $FilterObjProps = [ordered]@{}
                $FilterObjProps['EventField'] = $Node.LocalName
                $FilterObjProps['RuleName'] = $Node.Name
                $FilterObjProps['Condition'] = &{if($Node.condition -eq $null){'is'}else{$Node.condition}}
                $FilterObjProps['Value'] =  $Node.'#text'
                $FilterObj = New-Object -TypeName psobject -Property $FilterObjProps
                $FilterObj.pstypenames.insert(0,'Sysmon.Rule.Filter')
                $Filters += $FilterObj
            }
            $RuleObjOptions.add('Filters',$Filters)
        }

        $RuleObj = New-Object -TypeName psobject -Property $RuleObjOptions
        $RuleObj.pstypenames.insert(0,'Sysmon.Rule')
        $RuleObj
    }
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
        [string]$Path,

        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='LiteralPath',
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        [Alias('PSPath')]
        [string]$LiteralPath,

        # Event type to create filter for.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet('NetworkConnect', 'ProcessCreate', 'FileCreateTime',
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad',
                     'CreateRemoteThread', 'ProcessAccess','RawAccessRead',
                     'FileCreate', 'RegistryEvent', 'FileCreateStreamHash',
                     'PipeEvent', 'WmiEvent',IgnoreCase = $false)]
        [string]
        $EventType,

        # Event type to create filter for.
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
        $Value,

        # Rule Name for the filter.
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]
        $RuleName
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

        $Rules = $Config.SelectSingleNode('//Sysmon/EventFiltering')

        # Select the proper condition string and make sure it is the proper case.
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

        $RuleData = $Rules.SelectNodes("//EventFiltering/$($EventType)")

        if($RuleData -eq $null)
        {
            Write-Error -Message "No rule for $($EventType) was found."
            return
        } # If only one element this will return null, more than one this will provide a value.
        else
        {
            if ($RuleData.count -eq 1)
            {
                if ($RuleData.Attributes."#text" -eq $OnMatch)
                {
                    Write-Verbose -Message 'Single node.'
                    Write-Verbose -Message "Creating filters for event type $($EventType)."
                    # For each value for the event type create a filter.
                    foreach($val in $value)
                    {
                        Write-Verbose -Message "Creating filter for event filed $($EventField) with condition $($Condition) for value $($val)."
                        $FieldElement = $Config.CreateElement($EventField)
                        $Filter = $RuleData.AppendChild($FieldElement)
                        if ($RuleName) {
                            $Filter.SetAttribute('name',$RuleName)
                        }
                        $Filter.SetAttribute('condition',$ConditionString)
                        $filter.InnerText = $val
                        $Config.Save($FileLocation)
                    }
                }
                else
                {
                    write-error -Message "Event type $($EventType) with a on match condition of $($OnMatch) was not found."
                    return
                }
            }
            else
            {
                Write-Verbose -Message 'Mutiple nodes.'
                foreach ($rule in $RuleData)
                {
                    if ($rule.onmatch -eq $OnMatch)
                    {
                        Write-Verbose -Message "Found rule for event type $($EventType) with $($OnMatch)"
                        Write-Verbose -Message "Creating filters for event type $($EventType)."
                        # For each value for the event type create a filter.
                        foreach($val in $value)
                        {
                            Write-Verbose -Message "Creating filter for event filed $($EventField) with condition $($Condition) for value $($val)."
                            $FieldElement = $Config.CreateElement($EventField)
                            $Filter = $rule.AppendChild($FieldElement)
                            if ($RuleName) {
                                $Filter.SetAttribute('name',$RuleName)
                            }
                            $Filter.SetAttribute('condition',$ConditionString)
                            $filter.InnerText = $val
                            $Config.Save($FileLocation)
                        }
                        $RuleData = $rule
                    }
                }
            }

        }
        Get-RuleWithFilter($RuleData)
    }
    End{}
}
