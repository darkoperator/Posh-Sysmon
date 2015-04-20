
#  .ExternalHelp Config.psm1-Help.xml
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
        $NetworkConnect,

        # Log process loading of modules.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [Switch]
        $DriverLoad,

        # Log process loading of modules.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=4)]
        [Switch]
        $ImageLoad,

        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=5)]
        [Switch]
        $CreateRemoteThread,


        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=6)]
        [Switch]
        $FileCreateTime,

        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=7)]
        [Switch]
        $ProcessCreate,

        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=8)]
        [Switch]
        $ProcessTerminate,

        # Comment for purpose of the configuration file.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true)]
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
        
        $XmlWriter.WriteAttributeString('schemaversion', '2.0')

        Write-Verbose -Message "Enabling hashing algorithms : $($Hash)"
        $xmlWriter.WriteElementString('HashAlgorithms',$Hash)
        
        # Create empty EventFiltering section.
        $xmlWriter.WriteStartElement('EventFiltering')

        if ($NetworkConnect)
        {
            Write-Verbose -Message 'Enabling network connection logging for all connections by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('NetworkConnect')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        if ($DriverLoad)
        {
            Write-Verbose -Message 'Enabling logging all driver loading by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('DriverLoad ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        if ($ImageLoad)
        {
            Write-Verbose -Message 'Enabling logging all image loading by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('ImageLoad ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        if ($CreateRemoteThread)
        {
            Write-Verbose -Message 'Enabling logging all  CreateRemoteThread API actions by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('CreateRemoteThread ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        if ($ProcessCreate)
        {
            Write-Verbose -Message 'Enabling logging all  process creation by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('ProcessCreate ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        if ($ProcessTerminate)
        {
            Write-Verbose -Message 'Enabling logging all  process termination by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('ProcessTerminate ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        if ($FileCreateTime)
        {
            Write-Verbose -Message 'Enabling logging all  process creation by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('FileCreateTime ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        # End Element of EventFiltering
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

#  .ExternalHelp Config.psm1-Help.xml
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

        if ($Config.Sysmon.Configuration.SelectSingleNode('//HashAlgorithms'))
        {
            $ObjOptions['Hashing'] = $config.Sysmon.HashAlgorithms
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


#  .ExternalHelp Config.psm1-Help.xml
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
            $EvtType = $MyInvocation.MyCommand.Module.PrivateData[$Type]
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


#  .ExternalHelp Config.psm1-Help.xml
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


#  .ExternalHelp Config.psm1-Help.xml
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
            $EvtType = $MyInvocation.MyCommand.Module.PrivateData[$Type]
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


#  .ExternalHelp Config.psm1-Help.xml
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
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad')]
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
            $EvtType = $MyInvocation.MyCommand.Module.PrivateData[$Type]
            $Rule = $Rules.SelectSingleNode("//Rules/$($EvtType)")
            if ($Rule -ne $null)
            {
                [void]$Rule.ParentNode.RemoveChild($Rule)
                Write-Verbose -Message "Removed rule for $($EvtType)."
            }
            else
            {
                Write-Warning -Message "Did not found a rule for $($EvtType)"
            }
        }
        $config.Save($FileLocation)
    }
    End{}
}

