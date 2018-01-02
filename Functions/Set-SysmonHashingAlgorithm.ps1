#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function Set-SysmonHashingAlgorithm
{
    [CmdletBinding(DefaultParameterSetName = 'Path',
                   HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Set-SysmonHashingAlgorithm.md')]
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

         if ($Config.Sysmon.schemaversion -notin $SysMonSupportedVersions)
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