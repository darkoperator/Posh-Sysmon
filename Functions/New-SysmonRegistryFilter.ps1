<#
.SYNOPSIS
Create a new filter for the actions against the registry.
.DESCRIPTION
Create a new filter for actions against the registry. Supports filtering
by aby of the following event types:
* CreateKey
* DeleteKey
* RenameKey
* CreateValue
* DeleteValue
* RenameValue
* SetValue

Hives on Schema 3.2 in TargetObject are referenced as:
* \REGISTRY\MACHINE\HARDWARE
* \REGISTRY\USER\Security ID number
* \REGISTRY\MACHINE\SECURITY
* \REGISTRY\USER\.DEFAULT
* \REGISTRY\MACHINE\SYSTEM
* \REGISTRY\MACHINE\SOFTWARE
* \REGISTRY\MACHINE\SAM

Hives on Schema 3.3 and above in TargetObject are referenced as:
* HKLM
* HKCR
* HKEY_USER

.EXAMPLE
C:\PS> New-SysmonRegistryFilter -Path .\32config.xml -OnMatch include -Condition Contains -EventField TargetObject 'RunOnce'
Capture persistance attemp by creating a registry entry in the RunOnce keys.
#>
function New-SysmonRegistryFilter {
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonRegistryFilter.md')]
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
        [ValidateScript({ Test-Path -Path $_ })]
        [Alias('PSPath')]
        $LiteralPath,

        # Event type on match action.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=1)]
        [ValidateSet('include', 'exclude')]
        [string]
        $OnMatch,

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
        [ValidateSet('TargetObject', 'ProcessGuid', 'ProcessId',
            'Image', 'EventType')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=4)]
        [string[]]
        $Value,

        # Rule Name for the filter.
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string]
        $RuleName
    )

    Begin {
        # Event types used to validate right type and string case
        $EventTypeMap = @{
            CreateKey = 'CreateKey'
            DeleteKey = 'DeleteKey'
            RenameKey = 'RenameKey'
            CreateValue = 'CreateValue'
            DeleteValue = 'DeleteValue'
            RenameValue = 'RenameValue'
            SetValue = 'SetValue'
        }

        $Etypes = $EventTypeMap.Keys
    }
    Process {
        $FieldString = $MyInvocation.MyCommand.Module.PrivateData[$EventField]

        if ($EventField -in 'EventType') {
            if ($Value -in $Etypes) {
                $Value = $EventTypeMap[$Value]
            } else {
                Write-Error -Message "Not a supported EventType. Supported Event types $($Etypes -join ', ')"
                return
            }
        }
        $cmdoptions = @{
            'EventType' =  'RegistryEvent'
            'Condition' = $Condition
            'EventField' = $FieldString
            'Value' = $Value
            'OnMatch' = $OnMatch

        }

        if($RuleName) {
            $cmdoptions.Add('RuleName',$RuleName)
        }

        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                $cmdOptions.Add('Path',$Path)
                New-RuleFilter @cmdOptions
            }

            'LiteralPath' {
                $cmdOptions.Add('LiteralPath',$LiteralPath)
                New-RuleFilter @cmdOptions
            }
        }
    }
    End {}
}