#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function New-SysmonConfiguration
{
    [CmdletBinding(HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonConfiguration.md')]
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

        # Log create remote thread actions.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=5)]
        [Switch]
        $CreateRemoteThread,

        # Log file creation time modifications.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=6)]
        [Switch]
        $FileCreateTime,

        # Log process creation.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=7)]
        [Switch]
        $ProcessCreate,

        # Log process termination.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=8)]
        [Switch]
        $ProcessTerminate,

        # Log when a running process opens another process.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=9)]
        [Switch]
        $ProcessAccess,

        # Log raw access reads of files.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=10)]
        [Switch]
        $RawAccessRead,

        # Check for signature certificate revocation.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=11 )]
        [Switch]
        $CheckRevocation,

        # Log Registry events.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=12 )]
        [Switch]
        $RegistryEvent,

        # Log File Creation events.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=13 )]
        [Switch]
        $FileCreate,

        # Log File Stream creations events.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=14 )]
        [Switch]
        $FileCreateStreamHash,

        # Log NamedPipes connection and creations events.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=15 )]
        [Switch]
        $PipeEvent,

        # WMI Permanent Event component events.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=16 )]
        [Switch]
        $WmiEvent,

        # Comment for purpose of the configuration file.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true)]
        [String]
        $Comment,

        # Schema Vesion for the configuration file, default is 4.1.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true)]
                   [ValidateSet('4.0','4.1')]
        [string]
        $SchemaVersion = '4.1'
    )

    Begin{}
    Process {
        if ($HashingAlgorithm -contains 'ALL') {
            $Hash = '*'
        } else {
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

        # Enable checking revocation.
        if ($CheckRevocation) {
            Write-Verbose -message 'Enabling CheckRevocation.'
            $xmlWriter.WriteElementString('CheckRevocation','')
        }

        # Create empty EventFiltering section.
        $xmlWriter.WriteStartElement('EventFiltering')

        if ($NetworkConnect) {
            Write-Verbose -Message 'Enabling network connection logging for all connections by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('NetworkConnect')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        if ($DriverLoad) {
            Write-Verbose -Message 'Enabling logging all driver loading by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('DriverLoad ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        if ($ImageLoad) {
            Write-Verbose -Message 'Enabling logging all image loading by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('ImageLoad ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        if ($CreateRemoteThread) {
            Write-Verbose -Message 'Enabling logging all  CreateRemoteThread API actions by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('CreateRemoteThread ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        if ($ProcessCreate) {
            Write-Verbose -Message 'Enabling logging all  process creation by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('ProcessCreate ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        if ($ProcessTerminate) {
            Write-Verbose -Message 'Enabling logging all  process termination by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('ProcessTerminate ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        if ($FileCreateTime) {
            Write-Verbose -Message 'Enabling logging all  process creation by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('FileCreateTime ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        if ($ProcessAccess) {
            Write-Verbose -Message 'Enabling logging all  process access by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('ProcessAccess ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        if ($RawAccessRead) {
            Write-Verbose -Message 'Enabling logging all  process access by setting no filter and onmatch to exclude.'
            $xmlWriter.WriteStartElement('RawAccessRead ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        # Log registry events.
        if ($RegistryEvent) {
            Write-Verbose -message 'Enabling RegistryEvent.'
            $xmlWriter.WriteStartElement('RegistryEvent ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        # Log file create events.
        if ($FileCreate) {
            Write-Verbose -message 'Enabling FileCreate.'
            $xmlWriter.WriteStartElement('FileCreate ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        # Log file create events.
        if ($FileCreateStreamHash) {
            Write-Verbose -message 'Enabling FileCreateStreamHash.'
            $xmlWriter.WriteStartElement('FileCreateStreamHash ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        # NamedPipes create and connect events.
        if ($PipeEvent) {
            Write-Verbose -message 'Enabling PipeEvent.'
            $xmlWriter.WriteStartElement('PipeEvent ')
            $XmlWriter.WriteAttributeString('onmatch', 'exclude')
            $xmlWriter.WriteFullEndElement()
        }

        # NamedPipes create and connect events.
        if ($WmiEvent) {
            Write-Verbose -message 'Enabling WmiEvent.'
            $xmlWriter.WriteStartElement('WmiEvent ')
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
        write-verbose -Message "Configuration is for Sysmon $($sysmonVerMap[$SchemaVersion])"
    }
    End {}
}