#  .ExternalHelp Posh-SysMon.psm1-Help.xml
function Get-SysmonHashingAlgorithm
{
    [CmdletBinding(DefaultParameterSetName = 'Path',
                   HelpUri = 'https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Get-SysmonHashingAlgorithm.md')]
    Param
    (
        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='Path',
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        [string]$Path,

        # Path to XML config file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='LiteralPath',
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        [Alias('PSPath')]
        [string]$LiteralPath
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

        if ($Config.Sysmon.schemaversion -notin $SysMonSupportedVersions)
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