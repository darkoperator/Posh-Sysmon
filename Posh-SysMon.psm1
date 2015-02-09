# TODO:
# * Add help for the new filter functions.
# * Migrate help from comment based to XML based.
# * Add help and param block to Get-RuleWithFilter

<#
.Synopsis
   Creates a new Sysmon XML configuration file.
.DESCRIPTION
   Creates a new Sysmon XML configuration file. Configuration options
   and a descriptive comment can be given when generating the
   XML config file.
.EXAMPLE
    New-SysmonConfiguration -ConfigFile .\pc_cofig.xml -HashingAlgorithm SHA1,IMPHASH -Network -ImageLoading -Comment "Config for helpdesk PCs." -Verbose 
   VERBOSE: Enabling hashing algorithms : SHA1,IMPHASH
   VERBOSE: Enabling network connection logging.
   VERBOSE: Enabling image loading logging.
   VERBOSE: Config file created as C:\\pc_cofig.xml

   Create a configuration file that will log all network connction, image loading and sets a descriptive comment.
#>
function New-SysmonConfiguration
{
    [CmdletBinding()]
    Param
    (
        # Path to write XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]
        $Path,

        # Specify one or more hash algorithms used for image identification 
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet('ALL', 'MD5', 'SHA1', 'SHA256', 'IMPHASH')]
        [string[]]
        $HashingAlgorithm,

        

        # Log Network Connections
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [Switch]
        $Network,

        # Log process loading of modules.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [Switch]
        $ImageLoading,

        # Comment for purpose of the configuration file.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=4)]
        [String]
        $Comment
    )

    Begin{}
    Process
    {
        if ($HashingAlgorithm -contains 'ALL')
        {
            $Hash = '*'
        }
        else
        {
            $Hash = $HashingAlgorithm -join ','
        }

        $Config = ($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path))
       
        # get an XMLTextWriter to create the XML
        
        $XmlWriter = New-Object System.XMl.XmlTextWriter($Config,$Null)
 
        # choose a pretty formatting:
        $xmlWriter.Formatting = 'Indented'
        $xmlWriter.Indentation = 1
 
        # write the header
        if ($Comment)
        {
            $xmlWriter.WriteComment($Comment)
        }
        $xmlWriter.WriteStartElement('Sysmon')
        
        $XmlWriter.WriteAttributeString('schemaversion', '1.0')
        $xmlWriter.WriteStartElement('Configuration')

        Write-Verbose -Message "Enabling hashing algorithms : $($Hash)"
        $xmlWriter.WriteElementString('Hashing',$Hash)
        
        if ($Network)
        {
            Write-Verbose -Message 'Enabling network connection logging.'
            $xmlWriter.WriteStartElement('Network')
            $xmlWriter.WriteFullEndElement()
        }

        if ($ImageLoading)
        {
            Write-Verbose -Message 'Enabling image loading loggong.'
            $xmlWriter.WriteStartElement('ImageLoading ')
            $xmlWriter.WriteFullEndElement()
        }
        
        # Configuration
        $xmlWriter.WriteEndElement()

        # Create empty rule section.
        $xmlWriter.WriteStartElement('Rules')
        $xmlWriter.WriteFullEndElement()

        # Sysmon
        $xmlWriter.WriteEndElement()

        # finalize the document:
        #$xmlWriter.WriteEndDocument()
        $xmlWriter.Flush()
        $xmlWriter.Close()
        Write-Verbose -Message "Config file created as $($Config)"
    }
    End
    {
    }
}


<#
.Synopsis
   Gets the config options set on a Sysmon XML configuration file.
.DESCRIPTION
   Gets the config options set on a Sysmon XML configuration file
   and their default values.
.EXAMPLE
   Get-SysmonConfigOptions -Path .\pc_cofig.xml -Verbose
    Hashing      : SHA1,IMPHASH
    Network      : Enabled
    ImageLoading : Enabled
    Comment      : Config for helpdesk PCs.
#>
function Get-SysmonConfigOption
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
        $LiteralPath
    )

    Begin{}
    Process
    {
        # Check if the file is a valid XML file and if not raise and error. 
        try
        {
            switch($psCmdlet.ParameterSetName)
            {
                'Path'        {[xml]$Config = Get-Content -Path $Path}
                'LiteralPath' {[xml]$Config = Get-Content -LiteralPath $LiteralPath}
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

        $ObjOptions = @{}

        if ($Config.Sysmon.Configuration.SelectSingleNode('//Configuration/Hashing'))
        {
            $ObjOptions['Hashing'] = $config.Sysmon.Configuration.Hashing
        }
        else
        {
            $ObjOptions['Hashing'] = ''   
        }

        # Check if network traffic is being logged.
        if ($Config.Sysmon.Configuration.SelectSingleNode('//Configuration/Network'))
        {
            $ObjOptions['Network'] = 'Enabled'
        }
        else
        {
            $ObjOptions['Network'] = 'Disabled'   
        }

        # Check if image loading is being logged.
        if ($Config.Sysmon.Configuration.SelectSingleNode('//Configuration/ImageLoading'))
        {
            $ObjOptions['ImageLoading'] = 'Enabled'
        }
        else
        {
            $ObjOptions['ImageLoading'] = 'Disabled'   
        }

        $ObjOptions['Comment'] = $Config.'#comment'   
        $ConfigObj = [pscustomobject]$ObjOptions
        $ConfigObj.pstypenames.insert(0,'Sysmon.ConfigOption')
        $ConfigObj

    }
    End{}
}


<#
.Synopsis
   Gets configured rules and their filters on a Sysmon XML configuration file.
   config file.
.DESCRIPTION
   Gets configured rules and their filters on a Sysmon XML configuration file.
   config file for each event type.
.EXAMPLE
    Get-SysmonConfigOptions -Path .\pc_cofig.xml -Verbose

    Hashing      : SHA1,IMPHASH
    Network      : Enabled
    ImageLoading : Enabled
    Comment      : Config for helpdesk PCs.
#>
function Get-SysmonRule
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

        # Event type to parse rules for.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet('ALL', 'NetworkConnect', 'ProcessCreate', 'FileCreateTime', 
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad')]
        [string[]]
        $EventType = @('ALL')
    )

    Begin{}
    Process
    {
        # Check if the file is a valid XML file and if not raise and error. 
        try
        {
            switch($psCmdlet.ParameterSetName)
            {
                'Path'        {[xml]$Config = Get-Content -Path $Path}
                'LiteralPath' {[xml]$Config = Get-Content -LiteralPath $LiteralPath}
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


        # Collect all individual rules if they exist.
        $Rules = $Config.Sysmon.Rules

        if ($EventType -contains 'ALL')
        {
            $TypesToParse = @('NetworkConnect', 'ProcessCreate', 'FileCreateTime', 
                              'ProcessTerminate', 'ImageLoad', 'DriverLoad')
        }
        else
        {
            $TypesToParse = $EventType
        }

        foreach($Type in $TypesToParse)
        {
            $EvtType = Get-EvenTypeCasedString -EventType $Type
            $RuleData = $Rules.SelectNodes("//Rules/$($EvtType)")
            if($RuleData -ne $null)
            {
                Write-Verbose -Message "$($EvtType) Rule Found."
                Get-RuleWithFilter($RuleData)
            }

        }
    }
    End{}
}


<#
.Synopsis
   Adds or modifyies existing config options in a Sysmon XML configuration file.
   config file.
.DESCRIPTION
   Adds or modifyies existing config options in a Sysmon XML configuration file.
   config file.
.EXAMPLE
    Get-SysmonConfigOption -Path .\pc_cofig.xml 

    Hashing      : SHA1,IMPHASH
    Network      : Enabled
    ImageLoading : Enabled
    Comment      : 


    PS C:\> Set-SysmonConfigOption -Path .\pc_cofig.xml -ImageLoading Disable -Verbose
    VERBOSE: Disabling Image Loading logging.
    VERBOSE: Logging Image Loading has been disabled.
    VERBOSE: Options have been set on C:\Users\Carlos Perez\Documents\Posh-Sysmon\pc_cofig.xml

    PS C:\> Get-SysmonConfigOption -Path .\pc_cofig.xml 

    Hashing      : SHA1,IMPHASH
    Network      : Enabled
    ImageLoading : Disabled
    Comment      : 

    Disable image loading logging on the config file.

#>
function Set-SysmonConfigOption
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

        # Specify one or more hash algorithms used for image identification 
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet('ALL', 'MD5', 'SHA1', 'SHA256', 'IMPHASH')]
        [string[]]
        $HashingAlgorithm,

        # Log Network Connections
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet('Enable', 'Disable')]
        [string]
        $Network,

        # Log process loading of modules.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [ValidateSet('Enable', 'Disable')]
        [string]
        $ImageLoading,

        # Comment for purpose of the configuration file.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=4)]
        [String]
        $Comment = $null
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
        

        # Update hashing algorithm option if selected.
        if ($HashingAlgorithm -ne $null)
        {
            Write-Verbose -Message 'Updating Hashing option.'
            if ($HashingAlgorithm -contains 'ALL')
            {
                $Hash = '*'
            }
            else
            {
                $Hash = $HashingAlgorithm -join ','
            }

            # Check if Hashing Alorithm node exists.
            if($Config.SelectSingleNode('//Sysmon/Configuration/Hashing') -ne $null)
            {
                $Config.Sysmon.Configuration.Hashing = $Hash    
            }
            else
            {
                $HashElement = $Config.CreateElement('Hashing')
                [void]$Config.Sysmon.Configuration.AppendChild($HashElement)
                $Config.Sysmon.Configuration.Hashing = $Hash 
            }
            Write-Verbose -Message 'Hashing option has been updated.'
        }

        # Update Image Loading monitoring option if selected.
        if($ImageLoading.Length -ne 0)
        {
            $Node = $Config.SelectSingleNode('//Sysmon/Configuration/ImageLoading')

            if ($ImageLoading -eq 'Enable')
            {
                Write-Verbose -Message 'Enabling image loading logging option.'
                if ($Node -ne $null)
                {
                    Write-Verbose -Message 'ImageLoading login already enabled.'
                }
                else
                {
                    $ImageLoadingElement = $Config.CreateElement('ImageLoading')
                    [void]$Config.Sysmon.Configuration.AppendChild($ImageLoadingElement)
                    Write-Verbose -Message 'Image loading logging option has been enabled.'
                }
            }
            else
            {
                if ($Node -ne $null)
                {
                    Write-Verbose -Message 'Disabling Image Loading logging.'
                    [void]$Node.ParentNode.RemoveChild($Node)
                    Write-Verbose -Message 'Logging Image Loading has been disabled.'
                }
                else
                {
                    Write-Verbose -Message 'No action taken since image loading option was not enabled.'
                }
            
            }
        }

        # Update Network monitoring option if selected.
        if($Network.Length -ne 0)
        {
            $NetworkNode = $Config.SelectSingleNode('//Sysmon/Configuration/Network')
            if ($Network -eq 'Enable')
            {
                Write-Verbose -Message 'Enabling network logging option.'
                if( $NetworkNode -ne $null)
                {
                    Write-Verbose -Message 'Network loggin already enabled.'
                }
                else
                {
                    $NetworkElement = $Config.CreateElement('Network')
                    [void]$Config.Sysmon.Configuration.AppendChild($NetworkElement)
                    Write-Verbose -Message 'Network logging option has been enabled.'
                }
            }
            else
            {
                if ($NetworkNode -ne $null)
                {
                    Write-Verbose -Message 'Disabling network connection logging.'
                    [void]$NetworkNode.ParentNode.RemoveChild($NetworkNode)
                    Write-Verbose -Message 'Logging network connections has been disabled.'
                }
                else
                {
                    Write-Verbose -Message 'No action taken since Network option was not enabled.'
                }
            
            }
        }

        # Update comment or create a new one if present.
        if ($Comment.Length -ne 0)
        {
            Write-Verbose -Message 'Updating comment for config file.'
            if($Config.'#comment' -ne $null)
            {
                $Config.'#comment' = $Comment    
            }
            else
            {
                $CommentXML = $Config.CreateComment($Comment)
                [void]$Config.PrependChild($CommentXML)
            }
            Write-Verbose -Message 'Comment for config file has been updated.'
        }

        Write-Verbose -Message "Options have been set on $($FileLocation)"
        $Config.Save($FileLocation)
    }
    End{}
}


<#
.Synopsis
   Creates a Rule and sets its default action in a Sysmon configuration XML file.
.DESCRIPTION
   Creates a rules for a specified Event Type and sets the default action 
   for the rule and filters under it. Ir a rule alreade exists it udates 
   the default action taken by a event type rule if one aready 
   present. The default is exclude. This default is set for event type 
   and affects all filters under it.
.EXAMPLE
    Get-GetSysmonRule -Path .\pc_cofig.xml -EventType NetworkConnect
    
    
     EventType     : NetworkConnect
     Scope         : Filtered
     DefaultAction : Exclude
     Filters       : {@{EventField=image; Condition=Is; Value=iexplorer.exe}}

    PS C:\> Set-SysmonRulen -Path .\pc_cofig.xml -EventType NetworkConnect -Action Include -Verbose
    VERBOSE: Setting as default action for NetworkConnect the action of Include.
    VERBOSE: Action has been set.

    PS C:\> Get-GetSysmonRule -Path .\pc_cofig.xml -EventType NetworkConnect


    EventType     : NetworkConnect
    Scope         : Filtered
    DefaultAction : Include
    Filters       : {@{EventField=image; Condition=Is; Value=iexplorer.exe}}

   
   Change default rule action causing the filter to ignore all traffic from iexplorer.exe.
#>
function Set-SysmonRule
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

        # Action for event type rule and filters.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet('Include', 'Exclude')]
        [String]
        $Action = 'Exclude'
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

        $Rules = $config.SelectSingleNode('//Sysmon/Rules')

        foreach($Type in $EventType)
        {
            $EvtType = Get-EvenTypeCasedString -EventType $Type
            $RuleData = $Rules.SelectSingleNode("//Rules/$($EvtType)")
            if($RuleData -ne $null)
            {
                Write-Verbose -Message "Setting as default action for $($EvtType) the action of $($Action)."
                $RuleData.SetAttribute('default',($Action.ToLower()))
                Write-Verbose -Message 'Action has been set.'
            }
            else
            {
                Write-Verbose -Message "No rule for $($EvtType) was found."
                Write-Verbose -Message "Creating rule for event type with action of $($Action)"
                $TypeElement = $config.CreateElement($EvtType)
                [void]$Rules.AppendChild($TypeElement)
                $RuleData = $Rules.SelectSingleNode("//Rules/$($EvtType)")
                $RuleData.SetAttribute('default',($Action.ToLower()))
                Write-Verbose -Message 'Action has been set.'
            }

            Get-RuleWithFilter($RuleData)
        }
        $config.Save($FileLocation)
    }
    End{}
}


<#
.Synopsis
   Removes on or more rules from a Sysmon XML configuration file.
.DESCRIPTION
   Removes on or more rules from a Sysmon XML configuration file.
.EXAMPLE
   PS C:\> Remove-SysmonRule -Path .\pc_marketing.xml -EventType ImageLoad,NetworkConnect -Verbose
   VERBOSE: Removed rule for ImageLoad.
   VERBOSE: Removed rule for NetworkConnect.
#>
function Remove-SysmonRule
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

        # Event type to remove. It is case sensitive.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet('NetworkConnect', 'ProcessCreate', 'FileCreateTime', 
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad',  IgnoreCase = $false)]
        [string[]]
        $EventType
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

        $Rules = $config.SelectSingleNode('//Sysmon/Rules')

        foreach($Type in $EventType)
        {
            $Rule = $Rules.SelectSingleNode("//Rules/$($Type)")
            if ($Rule -ne $null)
            {
                [void]$Rule.ParentNode.RemoveChild($Rule)
                Write-Verbose -Message "Removed rule for $($Type)."
            }
            else
            {
                Write-Warning -Message "Did not found a rule for $($Type)"
            }
        }
        $config.Save($FileLocation)
    }
    End{}
}

