<#
.Synopsis
Searches for specified SysMon Events and retunrs the Event Data as a custom object.
.DESCRIPTION
Searches for specified SysMon Events and retunrs the Event Data as a custom object.
.EXAMPLE
Get-SysMonEventData -EventId 1 -MaxEvents 10 -EndTime (Get-Date) -StartTime (Get-Date).AddDays(-1)

All process creation events in the last 24hr
.EXAMPLE
Get-SysMonEventData -EventId 3 -MaxEvents 20 -Path .\export.evtx

last 20 network connection events from a exported SysMon log.
#>
function Get-SysmonEventData {
    [CmdletBinding(DefaultParameterSetName='ID',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Get-SysmonEventData.md')]
    Param (
        # Sysmon Event ID of records to show
        [Parameter(Mandatory=$true,
            ParameterSetName='ID',
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [ValidateSet(1,2,3,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,255)]
        [Int32[]]
        $EventId,

        # EventType that a Rule can be written against.
        [Parameter(Mandatory=$false,
            ParameterSetName='Type',
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string[]]
        [ValidateSet('NetworkConnect', 'ProcessCreate', 'FileCreateTime',
            'ProcessTerminate', 'ImageLoad', 'DriverLoad',
            'CreateRemoteThread', 'RawAccessRead', 'ProcessAccess', 'Error',
            'FileCreateStreamHash', 'RegistryValueSet', 'RegistryRename',
            'RegistryAddOrDelete', 'FileCreate','ConfigChange','PipeCreated',
            'PipeConnected', 'WmiFilter', 'WmiConsumer', 'WmiBinding')]
        $EventType,

        # Specifies the maximum number of events that Get-WinEvent returns. Enter an integer. The default is to return all the events in the logs or files.
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            Position=1)]
        [int]
        $MaxEvents,

        # Specifies a path to one or more exported SysMon events in evtx format.
        [Parameter(Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage='Path to one or more locations.')]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path,

        # Start Date to get all event going forward.
        [Parameter(Mandatory=$false)]
        [datetime]
        $StartTime,

        # End data for searching events.
        [Parameter(Mandatory=$false)]
        [datetime]
        $EndTime
    )

    Begin
    {
        $EventTypeMap = @{
            ProcessCreate = 1
            FileCreateTime = 2
            NetworkConnect = 3
            ProcessTerminate = 5
            DriverLoad = 6
            ImageLoad = 7
            CreateRemoteThread = 8
            RawAccessRead = 9
            ProcessAccess = 10
            FileCreate = 11
            RegistryAddOrDelete = 12
            RegistryValueSet = 13
            RegistryRename = 14
            FileCreateStreamHash = 15
            ConfigChange = 16
            PipeCreated = 17
            PipeConnected = 18
            WmiFilter = 19
            WmiConsumer = 20
            WmiBinding = 21
            Error = 255
        }

        $EventIdtoType = @{
            '1' = 'ProcessCreate'
            '2' = 'FileCreateTime'
            '3' = 'NetworkConnect'
            '5' = 'ProcessTerminate'
            '6' = 'DriverLoad'
            '7' = 'ImageLoad'
            '8' = 'CreateRemoteThread'
            '9' = 'RawAccessRead'
            '10' = 'ProcessAccess'
            '11' = 'FileCreate'
            '12' = 'RegistryAddOrDelete'
            '13' = 'RegistryValueSet'
            '14' = 'RegistryRename'
            '15' = 'FileCreateStreamHash'
            '16' = 'ConfigChange'
            '17' = 'PipeCreated'
            '18' = 'PipeConnected'
            '19' = 'WmiFilter'
            '20' = 'WmiConsumer'
            '21' = 'WmiBinding'
            '255' = 'Error'

        }
    }
    Process
    {
        # Hash for filtering
        $HashFilter = @{LogName='Microsoft-Windows-Sysmon/Operational'}

        # Hash for command paramteters
        $ParamHash = @{}

        if ($MaxEvents -gt 0)
        {
            $ParamHash.Add('MaxEvents', $MaxEvents)
        }

        if ($Path -gt 0)
        {
            $ParamHash.Add('Path', $Path)
        }

        switch ($PSCmdlet.ParameterSetName) {
            'ID' { $HashFilter.Add('Id', $EventId) }
            'Type' {
                $EventIds = @()
                foreach ($etype in $EventType)
                {
                    $EventIds += $EventTypeMap[$etype]
                }
                $HashFilter.Add('Id', $EventIds)
            }
        }

        if ($StartTime)
        {
            $HashFilter.Add('StartTime', $StartTime)
        }

        if ($EndTime)
        {
            $HashFilter.Add('EndTime', $EndTime)
        }

        $ParamHash.Add('FilterHashTable',$HashFilter)
        Get-WinEvent @ParamHash | ForEach-Object {
            [xml]$evtxml = $_.toxml()
            $ProcInfo = [ordered]@{}
            $ProcInfo['EventId'] = $evtxml.Event.System.EventID
            $ProcInfo['EventType'] = $EventIdtoType[$evtxml.Event.System.EventID]
            $ProcInfo['Computer'] = $evtxml.Event.System.Computer
            $evtxml.Event.EventData.Data | ForEach-Object {
                $ProcInfo[$_.name] = $_.'#text'
            }
            New-Object psobject -Property $ProcInfo
        }
    }
    End {}
}