# TODO:
# * Add help and param block to Get-RuleWithFilter

 . "$PSScriptRoot\Filters.ps1"
 . "$PSScriptRoot\Config.ps1"

# Supporteted Sysmon schema versions.
$SysMonSupportedVersions = @(
    '2.0',
    '3.0',
    '3.1',
    '3.2'
 )

# Table that maps schema version to Sysmon version.
$sysmonVerMap = @{
     '2.0' = '3.0'
     '3.0' = '4.0'
     '3.1' = '4.11'
     '3.2' = '5.0'
 }

function Get-RuleWithFilter
{
    Param
    (
        [Parameter(Mandatory=$true)]
        $Rules
    )
    $RuleObjOptions = @{}
    foreach ($rule in $Rules)
    {
        $RuleObjOptions['EventType'] = $Rule.Name
        if ($Rule.onmatch -eq $null -or $Rule.onmatch -eq 'exclude')
        {
               $RuleObjOptions['DefaultAction'] = 'Exclude'
        }
        else
        {
            $RuleObjOptions['DefaultAction'] = 'Include'
        }

        # Process individual filters
        $Nodes = $Rule.selectnodes('*')
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
                $FilterObj = [psobject]$FilterObjProps
                $FilterObj.pstypenames.insert(0,'Sysmon.Rule.Filter')
                $Filters += $FilterObj
            }
            $RuleObjOptions['Filters'] = $Filters
        }

        $RuleObj = [psobject]$RuleObjOptions
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
                     IgnoreCase = $false)]
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
            if ($RuleData.count -eq $null)
            {
                if ($RuleData.onmatch -eq $OnMatch)
                {
                    Write-Verbose -Message 'Single node.'
                    Write-Verbose -Message "Creating filters for event type $($EventType)."
                    # For each value for the event type create a filter.
                    foreach($val in $value)
                    {
                        Write-Verbose -Message "Creating filter for event filed $($EventField) with condition $($Condition) for value $($val)."
                        $FieldElement = $Config.CreateElement($EventField)
                        $Filter = $RuleData.AppendChild($FieldElement)
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
