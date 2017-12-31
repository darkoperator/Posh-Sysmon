#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function New-SysmonImageLoadFilter {
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonImageLoadFilter.md')]
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
        [ValidateSet('UtcTime', 'ProcessGuid', 'ProcessId', 'Image',
            'ImageLoaded', 'Hashes', 'Signed',
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

    Begin {}
    Process
    {
        $FieldString = $MyInvocation.MyCommand.Module.PrivateData[$EventField]
        $cmdoptions = @{
            'EventType' =  'ImageLoad'
            'Condition' = $Condition
            'EventField' = $FieldString
            'Value' = $Value
            'OnMatch' = $OnMatch

        }
        switch($psCmdlet.ParameterSetName)
        {
            'Path'
            {
                $cmdOptions.Add('Path',$Path)
                New-RuleFilter @cmdOptions
            }

            'LiteralPath'
            {
                $cmdOptions.Add('LiteralPath',$LiteralPath)
                New-RuleFilter @cmdOptions
            }
        }

    }
    End { }
}


#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function New-SysmonDriverLoadFilter {
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonDriverLoadFilter.md')]
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
        [ValidateSet('UtcTime', 'ImageLoaded',
            'Hashes', 'Signed', 'Signature')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=4)]
        [string[]]
        $Value
    )

    Begin {}
    Process {
        $FieldString = $MyInvocation.MyCommand.Module.PrivateData[$EventField]
        $cmdoptions = @{
            'EventType' =  'DriverLoad'
            'Condition' = $Condition
            'EventField' = $FieldString
            'Value' = $Value
            'OnMatch' = $OnMatch

        }

        switch($psCmdlet.ParameterSetName) {
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


#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function New-SysmonNetworkConnectFilter
{
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonNetworkConnectFilter.md')]
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

    Begin {}
    Process {
        $FieldString = $MyInvocation.MyCommand.Module.PrivateData[$EventField]
        $cmdoptions = @{
            'EventType' =  'NetworkConnect'
            'Condition' = $Condition
            'EventField' = $FieldString
            'Value' = $Value
            'OnMatch' = $OnMatch

        }

        switch($psCmdlet.ParameterSetName) {
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


#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function New-SysmonFileCreateFilter {
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonFileCreateFilter.md')]
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

    Begin {}
    Process {
        $FieldString = $MyInvocation.MyCommand.Module.PrivateData[$EventField]

        switch($psCmdlet.ParameterSetName) {
            'Path' {
                New-RuleFilter -Path $Path -EventType FileCreateTime -Condition $Condition -EventField $FieldString -Value $Value -OnMatch $OnMatch
            }

            'LiteralPath' {
                New-RuleFilter -LiteralPath $LiteralPath -EventType FileCreateTime -Condition $Condition -EventField $FieldString -Value $Value -OnMatch $OnMatch
            }
        }

    }
    End {}
}


#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function New-SysmonProcessCreateFilter
{
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonProcessCreateFilter.md')]
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
        [ValidateSet('UtcTime', 'ProcessGuid', 'ProcessId', 'Image',
            'CommandLine', 'User', 'LogonGuid', 'LogonId',
            'TerminalSessionId', 'IntegrityLevel',
            'Hashes', 'ParentProcessGuid', 'ParentProcessId',
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

    Begin {}
    Process {
        $FieldString = $MyInvocation.MyCommand.Module.PrivateData[$EventField]
        $cmdoptions = @{
            'EventType' =  'ProcessCreate'
            'Condition' = $Condition
            'EventField' = $FieldString
            'Value' = $Value
            'OnMatch' = $OnMatch

        }
        switch($psCmdlet.ParameterSetName) {
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
    End { }
}


#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function New-SysmonProcessTerminateFilter
{
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonProcessTerminateFilter.md')]
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

    Begin {}
    Process
    {
        $FieldString = $MyInvocation.MyCommand.Module.PrivateData[$EventField]
        $cmdoptions = @{
            'EventType' =  'ProcessTerminate'
            'Condition' = $Condition
            'EventField' = $FieldString
            'Value' = $Value
            'OnMatch' = $OnMatch

        }
        switch($psCmdlet.ParameterSetName)
        {
            'Path'
            {
                $cmdOptions.Add('Path',$Path)
                New-RuleFilter @cmdOptions
            }

            'LiteralPath'
            {
                $cmdOptions.Add('LiteralPath',$LiteralPath)
                New-RuleFilter @cmdOptions
            }
        }
    }
    End {}
}

#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function New-SysmonCreateRemoteThreadFilter
{
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonCreateRemoteThreadFilter.md')]
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
        [ValidateSet('SourceImage', 'TargetImage')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=4)]
        [string[]]
        $Value
    )

    Begin { }
    Process {
        $FieldString = $MyInvocation.MyCommand.Module.PrivateData[$EventField]
        $cmdoptions = @{
            'EventType' =  'CreateRemoteThread'
            'Condition' = $Condition
            'EventField' = $FieldString
            'Value' = $Value
            'OnMatch' = $OnMatch

        }
        switch($psCmdlet.ParameterSetName) {
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

<#
.SYNOPSIS
Create a new filter for the logging of when a running process opens another.
.DESCRIPTION
Create a new filter for the logging of when a running process opens another.
.EXAMPLE
C:\PS> New-SysmonProcessAccessFilter -Path .\testver31.xml -OnMatch include -Condition Contains -EventField TargetImage lsass.exe
Log any process trying to open lsass.exe.
#>
function New-SysmonProcessAccessFilter {
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonProcessAccessFilter.md')]
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
        [ValidateSet('UtcTime', 'SourceProcessGUID',
            'SourceProcessId', 'SourceThreadId', 'SourceImage',
            'TargetProcessGUID', 'TargetProcessId', 'TargetImage',
            'GrantedAccess','CallTrace')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=4)]
        [string[]]
        $Value
    )

    Begin {}
    Process {
        $FieldString = $MyInvocation.MyCommand.Module.PrivateData[$EventField]
        $cmdoptions = @{
            'EventType' =  'ProcessAccess'
            'Condition' = $Condition
            'EventField' = $FieldString
            'Value' = $Value
            'OnMatch' = $OnMatch

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

<#
.SYNOPSIS
Create a new filter for the logging of file raw access read actions.
.DESCRIPTION
Create a new filter for the logging of file raw access read actions.
.EXAMPLE
C:\PS> New-SysmonRawAccessReadFilter -Path .\testver31.xml -OnMatch include -Condition Contains -EventField Image NTDS.dit
Log any raw access read of the file NTDS.dit.
#>
function New-SysmonRawAccessReadFilter {
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonRawAccessReadFilter.md')]
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
        [ValidateSet('UtcTime', 'ProcessGuid', 'ProcessId',
            'Image', 'Device')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=4)]
        [string[]]
        $Value
    )

    Begin {}
    Process {
        $FieldString = $MyInvocation.MyCommand.Module.PrivateData[$EventField]
        $cmdoptions = @{
            'EventType' =  'RawAccessRead'
            'Condition' = $Condition
            'EventField' = $FieldString
            'Value' = $Value
            'OnMatch' = $OnMatch

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


<#
.SYNOPSIS
Create a new filter for the logging file creation.
.DESCRIPTION
Create a new filter for the logging file creation.
.EXAMPLE
#>
function New-SysmonFileCreateFilter {
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonFileCreateFilter.md')]
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
        [ValidateSet('TargetFilename', 'ProcessGuid', 'ProcessId',
            'Image')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=4)]
        [string[]]
        $Value
    )

    Begin {}
    Process {
        $FieldString = $MyInvocation.MyCommand.Module.PrivateData[$EventField]
        $cmdoptions = @{
            'EventType' =  'FileCreate'
            'Condition' = $Condition
            'EventField' = $FieldString
            'Value' = $Value
            'OnMatch' = $OnMatch
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


<#
.SYNOPSIS
Create a new filter for the logging of the saving of data on a file stream.
.DESCRIPTION
Create a new filter for the logging of the saving of data on a file stream.
#>
function New-SysmonFileCreateStreamHashFilter {
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonFileCreateStreamHashFilter.md')]
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
        [ValidateSet('TargetFilename', 'ProcessGuid', 'ProcessId',
            'Image')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=4)]
        [string[]]
        $Value
    )

    Begin {}
    Process {
        $FieldString = $MyInvocation.MyCommand.Module.PrivateData[$EventField]
        $cmdoptions = @{
            'EventType' =  'FileCreateStreamHash'
            'Condition' = $Condition
            'EventField' = $FieldString
            'Value' = $Value
            'OnMatch' = $OnMatch
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
        $Value
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

<#
.SYNOPSIS
Create a new filter for when a Named Pipe is created or connected.
.DESCRIPTION
Create a new filter for when a Named Pipe is created or connected.
Useful for watching malware inter process communication.
#>
function New-SysmonPipeFilter {
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonPipeFilter.md')]
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
        [ValidateSet('Pipe', 'ProcessGuid', 'ProcessId',
            'Image')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=4)]
        [string[]]
        $Value
    )

    Begin {}
    Process {
        $FieldString = $MyInvocation.MyCommand.Module.PrivateData[$EventField]
        $cmdoptions = @{
            'EventType' =  'PipeEvent'
            'Condition' = $Condition
            'EventField' = $FieldString
            'Value' = $Value
            'OnMatch' = $OnMatch

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

<#
.SYNOPSIS
Create a new filter for WMI Permamanent Event Classes.
.DESCRIPTION
Create a new filter for WMI permamanent event classes are created or connected.
Useful for monitoring for persistence actions.
#>
function New-SysmonWmiFilter {
    [CmdletBinding(DefaultParameterSetName = 'Path',
    HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonWmiFilter.md')]
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
        [ValidateSet('Name', 'EventNamespace', 'Destination',
            'Type', 'Query', 'Operation', 'Consumer', 'Filter')]
        [string]
        $EventField,

        # Value of Event Field to filter on.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=4)]
        [string[]]
        $Value
    )

    Begin {}
    Process {
        $FieldString = $MyInvocation.MyCommand.Module.PrivateData[$EventField]
        $cmdoptions = @{
            'EventType' =  'WmiEvent'
            'Condition' = $Condition
            'EventField' = $FieldString
            'Value' = $Value
            'OnMatch' = $OnMatch

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
            'PipeEvent', 'WmiEvent')]
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
