
#  .ExternalHelp Posh-SysMon.psm1-Help.xml
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
        $Comment,

        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true)]
                   [ValidateSet('2.0','3.0')]
        [String]
        $SchemaVersion = '3.0'
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
        
        $XmlWriter.WriteAttributeString('schemaversion', $SchemaVersion)

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

#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function Get-SysmonHashingAlgorithm
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

        if ($Config.Sysmon.schemaversion -ne '2.0' -and $Config.Sysmon.schemaversion -ne '3.0')
        {
            Write-Error -Message 'This version of Sysmon Rule file is not supported.'
            return
        }

        $ObjOptions = @{}

        if ($Config.Sysmon.SelectSingleNode('//HashAlgorithms'))
        {
            $ObjOptions['Hashing'] = $config.Sysmon.HashAlgorithms
        }
        else
        {
            $ObjOptions['Hashing'] = ''   
        }

        #$ObjOptions['Comment'] = $Config.'#comment'   
        $ConfigObj = [pscustomobject]$ObjOptions
        $ConfigObj.pstypenames.insert(0,'Sysmon.HashingAlgorithm')
        $ConfigObj

    }
    End{}
}


#  .ExternalHelp Posh-SysMon.psm1-Help.xml
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

         if ($Config.Sysmon.schemaversion -ne '2.0' -and $Config.Sysmon.schemaversion -ne '3.0')
        {
            Write-Error -Message 'This version of Sysmon Rule file is not supported.'
            return
        }

        # Collect all individual rules if they exist.
        $Rules = $Config.Sysmon.EventFiltering

        if ($EventType -contains 'ALL')
        {
            $TypesToParse = @('NetworkConnect', 'ProcessCreate', 'FileCreateTime', 
                              'ProcessTerminate', 'ImageLoad', 'DriverLoad','CreateRemoteThread')
        }
        else
        {
            $TypesToParse = $EventType
        }

        foreach($Type in $TypesToParse)
        {
            $EvtType = $MyInvocation.MyCommand.Module.PrivateData[$Type]
            $RuleData = $Rules.SelectNodes("//EventFiltering/$($EvtType)")
            if($RuleData -ne $null)
            {
                Write-Verbose -Message "$($EvtType) Rule Found."
                Get-RuleWithFilter($RuleData)
            }

        }
    }
    End{}
}


#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function Set-SysmonHashingAlgorithm
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
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet('ALL', 'MD5', 'SHA1', 'SHA256', 'IMPHASH')]
        [string[]]
        $HashingAlgorithm
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

         if ($Config.Sysmon.schemaversion -ne '2.0' -and $Config.Sysmon.schemaversion -ne '3.0')
        {
            Write-Error -Message 'This version of Sysmon Rule file is not supported.'
            return
        }
            
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
        if($Config.SelectSingleNode('//Sysmon/HashAlgorithms') -ne $null)
        {
            $Config.Sysmon.HashAlgorithms = $Hash    
        }
        else
        {
            $HashElement = $Config.CreateElement('HashAlgorithms')
            [void]$Config.Sysmon.Configuration.AppendChild($HashElement)
            $Config.Sysmon.Configuration.Hashing = $Hash 
        }
        Write-Verbose -Message 'Hashing option has been updated.'
        

        Write-Verbose -Message "Option have been set on $($FileLocation)"
        $Config.Save($FileLocation)
    }
    End{}
}


#  .ExternalHelp Posh-SysMon.psm1-Help.xml
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
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad', 'CreateRemoteThread')]
        [string[]]
        $EventType,

        # Action for event type rule and filters.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet('Include', 'Exclude')]
        [String]
        $OnMatch = 'Exclude',

        # Action to take for Schema 3.0 files.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('Modify', 'Add')]
        [String]
        $Action = 'Modify'
    )

    Begin{}
    Process
    {
        #if no elemrnt create one either if itis schema 2.0 or 3.0.
        # If one is present we modify that one if Schema 2.0 and if Schema 3.0 and action modify.
        # If Schema 3.0 and action add we check if only is present and that it is not the same OnMatch
        # as being specified if it is we do nothing if not we add. 


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

         if ($Config.Sysmon.schemaversion -ne '2.0' -and $Config.Sysmon.schemaversion -ne '3.0')
        {
            Write-Error -Message 'This version of Sysmon Rule file is not supported.'
            return
        }

        $Rules = $config.SelectSingleNode('//Sysmon/EventFiltering')

        foreach($Type in $EventType)
        {
            $EvtType = $MyInvocation.MyCommand.Module.PrivateData[$Type]
            $RuleData = $Rules.SelectSingleNode("//EventFiltering/$($EvtType)")
            $elements = $Rules."$($EvtType)" | Select-Object -property onmatch -Unique

            if($RuleData -ne $null)
            {
                if ($Rules."$($EvtType)".count -eq $null)
                {
                    if (($Config.Sysmon.schemaversion -eq '2.0') -or ($Config.Sysmon.schemaversion -eq '3.0' -and $Action -eq 'Modify'))
                    {
                        Write-Verbose -Message "Setting as default action for $($EvtType) the rule on match of $($OnMatch)."
                        $RuleData.SetAttribute('onmatch',($OnMatch.ToLower()))
                        Write-Verbose -Message 'Action has been set.'
                    }
                    elseif ($Config.Sysmon.schemaversion -eq '3.0' -and $Action -eq 'Add')
                    {
                        if ($RuleData.onmatch -ne $OnMatch)
                        {
                            Write-Verbose -Message "Creating rule for event type with action of $($OnMatch)"
                            $TypeElement = $config.CreateElement($EvtType)
                            $TypeElement.SetAttribute('onmatch',($OnMatch.ToLower()))
                             $RuleData = $Rules.AppendChild($TypeElement)
                            Write-Verbose -Message 'Action has been set.'
                        }
                        else
                        {
                            Write-Verbose -Message 'A rule with the specified onmatch action already exists.'
                        }
                    }
                }
                elseif ($Config.Sysmon.schemaversion -eq '3.0' -and $elements.count -eq 2)
                {
                    Write-Verbose -Message 'A rule with the specified onmatch action already exists.'
                }
                else
                {
                    Write-Error -Message 'This XML file does not conform to the schema.'
                    return
                }
            }
            else
            {
                Write-Verbose -Message "No rule for $($EvtType) was found."
                Write-Verbose -Message "Creating rule for event type with action of $($OnMatch)"
                $TypeElement = $config.CreateElement($EvtType)
                $TypeElement.SetAttribute('onmatch',($OnMatch.ToLower()))
                $RuleData = $Rules.AppendChild($TypeElement)
                Write-Verbose -Message 'Action has been set.'
            }

            Get-RuleWithFilter($RuleData)
        }
        $config.Save($FileLocation)
    }
    End{}
}


#  .ExternalHelp Posh-SysMon.psm1-Help.xml
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
                     'ProcessTerminate', 'ImageLoad', 'DriverLoad', 'CreateRemoteThread')]
        [string[]]
        $EventType,

        # Action for event type rule and filters.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet('Include', 'Exclude')]
        [String]
        $OnMatch = 'Exclude'
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

         if ($Config.Sysmon.schemaversion -ne '2.0' -and $Config.Sysmon.schemaversion -ne '3.0')
        {
            Write-Error -Message 'This version of Sysmon Rule file is not supported.'
            return
        }

        $Rules = $config.SelectSingleNode('//Sysmon/EventFiltering')
        foreach ($rule in $rules.ChildNodes)
        {
            if ($rule.name -in $EventType -and $rule.onmatch -eq $OnMatch)
            {
                [void]$rule.ParentNode.RemoveChild($rule)
                Write-Verbose -Message "Removed rule for $($EvtType)."
            }
        }
        
        $config.Save($FileLocation)
    }
    End{}
}

