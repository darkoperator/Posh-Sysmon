

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
    [OutputType([int])]
    Param
    (
        # Path to write XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Alias('Path')]
        [String]
        $ConfigFile,

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

        $ConfXML = ($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ConfigFile))
       
        # get an XMLTextWriter to create the XML
        
        $XmlWriter = New-Object System.XMl.XmlTextWriter($ConfXML,$Null)
 
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
        Write-Verbose -Message "Config file created as $($ConfXML)"
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
   Get-SysmonConfigOptions -ConfigFile .\pc_cofig.xml -Verbose
    Hashing      : SHA1,IMPHASH
    Network      : Enabled
    ImageLoading : Enabled
    Comment      : Config for helpdesk PCs.
#>
function Get-SysmonConfigOption
{
    [CmdletBinding()]
    Param
    (
        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        [Alias('Path')]
        $ConfigFile
    )

    Begin{}
    Process
    {
        [xml]$Config = Get-Content -Path $ConfigFile
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
    Get-SysmonConfigOptions -ConfigFile .\pc_cofig.xml -Verbose

    Hashing      : SHA1,IMPHASH
    Network      : Enabled
    ImageLoading : Enabled
    Comment      : Config for helpdesk PCs.
#>
function Get-SysmonRule
{
    [CmdletBinding()]
    Param
    (
        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        [Alias('Path')]
        [string]
        $ConfigFile,

        # Event type to parse rules for.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet('ALL', 'NetworkConnect', 'ProcessCreate', 'FileCreateTime', 
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad', IgnoreCase = $false)]
        [string[]]
        $EventType = @('ALL')
    )

    Begin{}
    Process
    {
        [xml]$Config = Get-Content -Path $ConfigFile

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
            $RuleData = $Rules.SelectNodes("//Rules/$($Type)")
            if($RuleData -ne $null)
            {
                Write-Verbose -Message "$($Type) Rule Found."
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
    Get-SysmonConfigOption -ConfigFile .\pc_cofig.xml 

    Hashing      : SHA1,IMPHASH
    Network      : Enabled
    ImageLoading : Enabled
    Comment      : 


    PS C:\> Set-SysmonConfigOption -ConfigFile .\pc_cofig.xml -ImageLoading Disable -Verbose
    VERBOSE: Disabling Image Loading logging.
    VERBOSE: Logging Image Loading has been disabled.
    VERBOSE: Options have been set on C:\Users\Carlos Perez\Documents\Posh-Sysmon\pc_cofig.xml

    PS C:\> Get-SysmonConfigOption -ConfigFile .\pc_cofig.xml 

    Hashing      : SHA1,IMPHASH
    Network      : Enabled
    ImageLoading : Disabled
    Comment      : 

    Disable image loading logging on the config file.

#>
function Set-SysmonConfigOption
{
    [CmdletBinding()]
    Param
    (

        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Alias('Path')]
        [String]
        $ConfigFile,

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
        $ConfXML = [xml](Get-Content -Path $ConfigFile)
        $FileLocation = (Resolve-Path -Path $ConfigFile).Path

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
            if($ConfXML.SelectSingleNode('//Sysmon/Configuration/Hashing') -ne $null)
            {
                $ConfXML.Sysmon.Configuration.Hashing = $Hash    
            }
            else
            {
                $HashElement = $ConfXML.CreateElement('Hashing')
                [void]$ConfXML.Sysmon.Configuration.AppendChild($HashElement)
                $ConfXML.Sysmon.Configuration.Hashing = $Hash 
            }
            Write-Verbose -Message 'Hashing option has been updated.'
        }

        # Update Image Loading monitoring option if selected.
        if($ImageLoading.Length -ne 0)
        {
            $Node = $ConfXML.SelectSingleNode('//Sysmon/Configuration/ImageLoading')

            if ($ImageLoading -eq 'Enable')
            {
                Write-Verbose -Message 'Enabling image loading logging option.'
                if ($Node -ne $null)
                {
                    Write-Verbose -Message 'ImageLoading login already enabled.'
                }
                else
                {
                    $ImageLoadingElement = $ConfXML.CreateElement('ImageLoading')
                    [void]$ConfXML.Sysmon.Configuration.AppendChild($ImageLoadingElement)
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
            $NetworkNode = $ConfXML.SelectSingleNode('//Sysmon/Configuration/Network')
            if ($Network -eq 'Enable')
            {
                Write-Verbose -Message 'Enabling network logging option.'
                if( $NetworkNode -ne $null)
                {
                    Write-Verbose -Message 'Network loggin already enabled.'
                }
                else
                {
                    $NetworkElement = $ConfXML.CreateElement('Network')
                    [void]$ConfXML.Sysmon.Configuration.AppendChild($NetworkElement)
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
            if($ConfXML.'#comment' -ne $null)
            {
                $ConfXML.'#comment' = $Comment    
            }
            else
            {
                $CommentXML = $ConfXML.CreateComment($Comment)
                [void]$ConfXML.PrependChild($CommentXML)
            }
            Write-Verbose -Message 'Comment for config file has been updated.'
        }

        Write-Verbose -Message "Options have been set on $($FileLocation)"
        $ConfXML.Save($FileLocation)
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
    Get-GetSysmonRule -ConfigFile .\pc_cofig.xml -EventType NetworkConnect
    
    
     EventType     : NetworkConnect
     Scope         : Filtered
     DefaultAction : Exclude
     Filters       : {@{EventField=image; Condition=Is; Value=iexplorer.exe}}

    PS C:\> Set-SysmonRulen -ConfigFile .\pc_cofig.xml -EventType NetworkConnect -Action Include -Verbose
    VERBOSE: Setting as default action for NetworkConnect the action of Include.
    VERBOSE: Action has been set.

    PS C:\> Get-GetSysmonRule -ConfigFile .\pc_cofig.xml -EventType NetworkConnect


    EventType     : NetworkConnect
    Scope         : Filtered
    DefaultAction : Include
    Filters       : {@{EventField=image; Condition=Is; Value=iexplorer.exe}}

   
   Change default rule action causing the filter to ignore all traffic from iexplorer.exe.
#>
function Set-SysmonRule
{
    [CmdletBinding()]
    Param
    (
        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        [Alias('Path')]
        $ConfigFile,

        # Event type to update.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet('NetworkConnect', 'ProcessCreate', 'FileCreateTime', 
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad', IgnoreCase = $false)]
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
        $ConfXML = [xml](Get-Content -Path $ConfigFile)
        $FileLocation = (Resolve-Path -Path $ConfigFile).Path
        $Rules = $ConfXML.SelectSingleNode('//Sysmon/Rules')

        foreach($Type in $EventType)
        {
            $RuleData = $Rules.SelectSingleNode("//Rules/$($Type)")
            if($RuleData -ne $null)
            {
                Write-Verbose -Message "Setting as default action for $($Type) the action of $($Action)."
                $RuleData.SetAttribute('default',($Action.ToLower()))
                Write-Verbose -Message 'Action has been set.'
            }
            else
            {
                Write-Verbose -Message "No rule for $($Type) was found."
                Write-Verbose -Message "Creating rule for event type with action of $($Action)"
                $TypeElement = $ConfXML.CreateElement($Type)
                [void]$Rules.AppendChild($TypeElement)
                $RuleData = $Rules.SelectSingleNode("//Rules/$($Type)")
                $RuleData.SetAttribute('default',($Action.ToLower()))
                Write-Verbose -Message 'Action has been set.'
            }

            Get-RuleWithFilter($RuleData)
        }
        $ConfXML.Save($FileLocation)
    }
    End{}
}


<#
.Synopsis
   Creates a filter for an event field for an event type in a Sysmon XML configuration file.
.DESCRIPTION
   Creates a filter for an event field for an event type in a Sysmon XML configuration file.
.EXAMPLE
   New-SysmonRuleFilter -ConfigFile .\pc_cofig.xml -EventType NetworkConnect -EventField image -Condition Is -Value 'iexplorer.exe' -Verbose
    
    VERBOSE: No rule for NetworkConnect was found.
    VERBOSE: Creating rule for event type with default action if Exclude
    VERBOSE: Rule created succesfully

    C:\PS>Get-GetSysmonRules -ConfigFile .\pc_cofig.xml -EventType NetworkConnect


    EventType     : NetworkConnect
    Scope         : Filtered
    DefaultAction : Exclude
    Filters       : {@{EventField=image; Condition=Is; Value=iexplorer.exe}}


    Create a filter to capture all network connections from iexplorer.exe.
#>
function New-SysmonRuleFilter
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        [Alias('Path')]
        $ConfigFile,

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
        # Open and read XML file.
        $ConfXML = [xml](Get-Content -Path $ConfigFile)
        $FileLocation = (Resolve-Path -Path $ConfigFile).Path
        $Rules = $ConfXML.SelectSingleNode('//Sysmon/Rules')

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
            $TypeElement = $ConfXML.CreateElement($EventType)
            [void]$Rules.AppendChild($TypeElement)
            $RuleData = $Rules.SelectSingleNode("//Rules/$($EventType)")
            Write-Verbose -Message 'Rule created succesfully'
        }

        Write-Verbose -Message "Creating filters for event type $($EventType)."
        # For each value for the event type create a filter.
        foreach($val in $value)
        {
            Write-Verbose -Message "Creating filter for event filed $($EventField) with condition $($Condition) for value $($val)."
            $FieldElement = $ConfXML.CreateElement($EventField)
            $Filter = $RuleData.AppendChild($FieldElement)
            $Filter.SetAttribute('condition',$Condition)
            $filter.InnerText = $val
        }
        Get-RuleWithFilter($RuleData)

        $ConfXML.Save($FileLocation)
    }
    End{}
}


<#
.Synopsis
   Removes on or more rules from a Sysmon XML configuration file.
.DESCRIPTION
   Removes on or more rules from a Sysmon XML configuration file.
.EXAMPLE
   PS C:\> Remove-SysmonRule -ConfigFile .\pc_marketing.xml -EventType ImageLoad,NetworkConnect -Verbose
   VERBOSE: Removed rule for ImageLoad.
   VERBOSE: Removed rule for NetworkConnect.
#>
function Remove-SysmonRule
{
    [CmdletBinding()]
    Param
    (
        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        [Alias('Path')]
        $ConfigFile,

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
        # Open and read XML file.
        $ConfXML = [xml](Get-Content -Path $ConfigFile)
        $FileLocation = (Resolve-Path -Path $ConfigFile).Path
        $Rules = $ConfXML.SelectSingleNode('//Sysmon/Rules')

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
        $ConfXML.Save($FileLocation)
    }
    End{}
}



<#
.Synopsis
   Remove on or more filter from a rule in a Sysmon XML configuration file.
.DESCRIPTION
   Remove on or more filter from a rule in a Sysmon XML configuration file.
.EXAMPLE
   Remove-SysmonRuleFilter -ConfigFile .\pc_marketing.xml -EventType NetworkConnect -Condition Image -EventField Image -Value $images -Verbose
   VERBOSE: Filter for field Image with confition Image and value of C:\Windows\System32\svchost.exe removed.
   VERBOSE: Filter for field Image with confition Image and value of C:\Program Files (x86)\Internet Explorer\iexplore.exe removed.
   VERBOSE: Filter for field Image with confition Image and value of C:\Program Files\Internet Explorer\iexplore.exe removed.
   VERBOSE: Filter for field Image with confition Image and value of C:\Program Files (x86)\Google\Chrome\Application\chrome.exe removed.
   VERBOSE: Filter for field Image with confition Image and value of C:\Program Files (x86)\PuTTY\putty.exe removed.
   VERBOSE: Filter for field Image with confition Image and value of C:\Program Files (x86)\PuTTY\plink.exe removed.
   VERBOSE: Filter for field Image with confition Image and value of C:\Program Files (x86)\PuTTY\pscp.exe removed.
   VERBOSE: Filter for field Image with confition Image and value of C:\Program Files (x86)\PuTTY\psftp.exe removed.

   EventType     : NetworkConnect
   Scope         : All Events
   DefaultAction : Exclude
   Filters       :

   Remove a series of filter where a list f values are saved in a array.
#>
function Remove-SysmonRuleFilter
{
    [CmdletBinding()]
    Param
    (
        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        [Alias('Path')]
        $ConfigFile,

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
        # Open and read XML file.
        $ConfXML = [xml](Get-Content -Path $ConfigFile)
        $FileLocation = (Resolve-Path -Path $ConfigFile).Path
        $Rules = $ConfXML.SelectSingleNode('//Sysmon/Rules')

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
                            Write-Verbose -Message "Filter for field $($EventField) with confition $($Condition) and value of $($val) removed."
                        }
                        elseif (($Filter.condition -eq $Condition) -and ($Filter.'#text' -eq $val))
                        {
                            [void]$Filter.ParentNode.RemoveChild($Filter)
                            Write-Verbose -Message "Filter for field $($EventField) with confition $($Condition) and value of $($val) removed."
                        }
                    }
                }
            }
            Get-RuleWithFilter($EventRule)
        }
        else
        {
            Write-Warning -Message "This event type has no filters configured."
            return
        }

        $ConfXML.Save($FileLocation)
    }
    End{}
}


###### Non-Public Functions ######
function Get-RuleWithFilter($Rules)
{
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
