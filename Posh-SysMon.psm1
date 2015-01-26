

<#
.Synopsis
   Creates a new Sysmon XML config file.
.DESCRIPTION
   Creates a new Sysmon XML config file. Configuration options
   and a descriptive comment can be given when generating the
   XML config file.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function New-SysmonConfiguration
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Specify one or more hash algorithms used for image identification 
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateSet('ALL', 'MD5', 'SHA1', 'SHA256', 'IMPHASH')]
        [string[]]
        $HashingAlgorithm,

        # Path to write XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [String]
        $ConfigFile,

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
            $xmlWriter.WriteEndElement()
        }

        if ($ImageLoading)
        {
            Write-Verbose -Message 'Enabling image loading loggong.'
            $xmlWriter.WriteStartElement('ImageLoading ')
            $xmlWriter.WriteEndElement()
        }
        
        # Configuration
        $xmlWriter.WriteEndElement()

        # Create empty rule section.
        $xmlWriter.WriteStartElement('Rules')
        $xmlWriter.WriteEndElement()

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
   Gets the config options set on a Sysmon XML config file.
.DESCRIPTION
   Gets the config options set on a Sysmon XML config file
   and their default values.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-SysmonConfigOptions
{
    [CmdletBinding()]
    Param
    (
        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        $ConfigFile
    )

    Begin{}
    Process
    {
        [xml]$Config = Get-Content -Path $ConfigFile
        $ObjOptions = @{}

        # Check if network traffic is being logged.
        if ($Config.Sysmon.Configuration.SelectNodes('//Configuration/Network'))
        {
            $ObjOptions['Network'] = 'Enabled'
        }
        else
        {
            $ObjOptions['Network'] = 'Disabled'   
        }

        # Check if image loading is being logged.
        if ($Config.Sysmon.Configuration.SelectNodes('//Configuration/ImageLoading'))
        {
            $ObjOptions['ImageLoading'] = 'Enabled'
        }
        else
        {
            $ObjOptions['ImageLoading'] = 'Disabled'   
        }

        $ObjOptions['Comment'] = $Config.'#comment'   
        [pscustomobject]$ObjOptions

    }
    End{}
}


<#
.Synopsis
   Gets configured rules and their filters on a Sysmon XML 
   config file.
.DESCRIPTION
   Gets configured rules and their filters on a Sysmon XML 
   config file for each event type.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-GetSysmonConfigRules
{
    [CmdletBinding()]
    Param
    (
        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        $ConfigFile,

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
                process_rules($RuleData)
    
            }

        }
    }
    End{}
}


<#
.Synopsis
   Adds or modifyies existing config options on a Sysmon XML
   config file.
.DESCRIPTION
   Adds or modifyies existing config options on a Sysmon XML
   config file.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Set-SysmonConfigOption
{
    [CmdletBinding()]
    Param
    (
        # Specify one or more hash algorithms used for image identification 
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateSet('ALL', 'MD5', 'SHA1', 'SHA256', 'IMPHASH')]
        [string[]]
        $HashingAlgorithm,

        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [String]
        $ConfigFile,

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
        if($ImageLoading)
        {
            Write-Verbose -Message 'Enabling image loading logging option.'
            if($ConfXML.SelectSingleNode('//Sysmon/Configuration/ImageLoading') -ne $null)
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

        # Update Network monitoring option if selected.
        if($Network)
        {
            Write-Verbose -Message 'Enabling network logging option.'
            if($ConfXML.SelectSingleNode('//Sysmon/Configuration/Network') -ne $null)
            {
                Write-Verbose -Message 'Network loggin already enabled.'
            }
            else
            {
                $NetworkElement = $ConfXML.CreateElement('Network')
                [void]$ConfXML.Sysmon.Configuration.AppendChild($NetworkElement)
                Write-Verbose -Message 'Image loading logging option has been enabled.'
            }
        }

        # Update comment or create a new one if present.
        if ($Comment -ne $null)
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
   Updates the default action of a event type rule.
.DESCRIPTION
   Updates the default action taken by a event type rule. The
   default is exclude. This default is set for event type and affects
   all filters under it.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Set-SysmonRuleAction
{
    [CmdletBinding()]
    Param
    (
        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        $ConfigFile,

        # Event type to update.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet('NetworkConnect', 'ProcessCreate', 'FileCreateTime', 
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad')]
        [string[]]
        $EventType,

        # Action for event type rule and filters.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet('Include', 'Exclude')]
        [String]
        $Action
    )

    Begin{}
    Process
    {
        $ConfXML = [xml](Get-Content -Path $ConfigFile)
        $FileLocation = (Resolve-Path -Path $ConfigFile).Path
        $Rules = $ConfXML.Sysmon.Rules
        foreach($Type in $EventType)
        {
            $RuleData = $Rules.SelectSingleNode("//Rules/$($Type)")
            if($RuleData -ne $null)
            {
                $RuleData.SetAttribute('default',($Action.ToLower()))
            }
            else
            {
                Write-Verbose -Message "No rule for $($Type) was found."
                Write-Verbose -Message "Creating rule for event type with action of $($Action)"
                $TypeElement = $ConfXML.CreateElement($Type)
                [void]$ConfXML.Sysmon.Rules.AppendChild($TypeElement)
                $RuleData = $Rules.SelectSingleNode("//Rules/$($Type)")
                $RuleData.SetAttribute('default',($Action.ToLower()))
            }
        }
        $ConfXML.Save($FileLocation)
    }
    End{}
}

###### Non-Public Functions ######
function process_rules($Rules)
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
