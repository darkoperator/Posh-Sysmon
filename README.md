# Posh-Sysmon
PowerShell 3.0 or above module for creating and managing Sysinternals Sysmon config files. System Monitor ([Sysmon](https://technet.microsoft.com/en-us/sysinternals/dn798348)) is a Windows system service and device driver that is part of the SysInternal tools from Microsoft. It is written by Mark Russinovich and Thomas Garnier to monitor a Windows system actions and log such actions in to the Windows Event Log. When the tool is installed on a system it can be given a XML configuration file so as to control what is logged and the same file can be used to update the configuration of a previously installed instance of the tool. 

All functions in the PowerShell module include help information and example of usage that can be view using the Get-Help cmdlet. 

# Installation

To install the module from a PowerShell v3 session run:
<pre>
iex (New-Object Net.WebClient).DownloadString("https://gist.githubusercontent.com/darkoperator/3f9da4b780b5a0206bca/raw/f9d15c4f95675f71bf6be21dcbee6b0fa9c8ac4c/posh-sysmoninstall.ps1")
</pre>

The script that is being ran is the following during installation:

```PowerShell
# Make sure the module is not loaded
Remove-Module posh-sysmon -ErrorAction SilentlyContinue
# Download latest version
$webclient = New-Object System.Net.WebClient
$url = "https://github.com/darkoperator/Posh-Sysmon/archive/master.zip"
Write-Host "Downloading latest version of Posh-Sysmon from $url" -ForegroundColor Cyan
$file = "$($env:TEMP)\Posh-Sysmon.zip"
$webclient.DownloadFile($url,$file)
Write-Host "File saved to $file" -ForegroundColor Green
# Unblock and Decompress
Unblock-File -Path $file
$targetondisk = "$($env:USERPROFILE)\Documents\WindowsPowerShell\Modules"
New-Item -ItemType Directory -Force -Path $targetondisk | out-null
$shell_app=new-object -com shell.application
$zip_file = $shell_app.namespace($file)
Write-Host "Uncompressing the Zip file to $($targetondisk)" -ForegroundColor Cyan
$destination = $shell_app.namespace($targetondisk)
$destination.Copyhere($zip_file.items(), 0x10)
# Rename and import
Write-Host "Renaming folder" -ForegroundColor Cyan
Rename-Item -Path ($targetondisk+"\Posh-Sysmon-master") -NewName "Posh-Sysmon" -Force
Write-Host "Module has been installed" -ForegroundColor Green
Import-Module -Name Posh-Sysmon
Get-Command -Module Posh-Sysmon
```
# Change Log

## Version 0.1
* Initial version for Sysmon 2.0 with XML Schema 1.0

# Examples

## Create a XML Configuration File

<pre>
PS C:\> New-SysmonConfiguration -ConfigFile .\pc_marketing.xml -HashingAlgorithm IMPHASH,SHA1 -Network -Comment "Sysmon config for deployment in the Marketing PC OU" -Verbose
VERBOSE: Enabling hashing algorithms : IMPHASH,SHA1
VERBOSE: Enabling network connection logging.
VERBOSE: Config file created as C:\pc_marketing.xml
</pre>

## Modify Configuration Option

<pre>
PS C:\> Set-SysmonConfigOption -ConfigFile .\pc_marketing.xml -ImageLoading Enable -Verbose
VERBOSE: Enabling image loading logging option.
VERBOSE: Image loading logging option has been enabled.
VERBOSE: Options have been set on C:\pc_marketing.xml
</pre>

## List configuration Options

<pre>
PS C:\> Get-SysmonConfigOption -ConfigFile .\pc_marketing.xml 


Hashing      : IMPHASH,SHA1
Network      : Enabled
ImageLoading : Enabled
Comment      : Sysmon config for deployment in the Marketing PC OU

</pre>


## Create a Rule Filter

In this example we create a filter for several program for the Network Connection event type. Sysmon rules work by filtering out and not logging any action by default. The default action of a Rules is to exclude from filtering out all event that match. In the following example the applications in the list will not have their network connections logged.

<pre>
PS C:\> $images = 'C:\Windows\System32\svchost.exe',
>>> 'C:\Program Files (x86)\Internet Explorer\iexplore.exe',
>>> 'C:\Program Files\Internet Explorer\iexplore.exe',
>>> 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
>>> 'C:\Program Files (x86)\PuTTY\putty.exe',
>>> 'C:\Program Files (x86)\PuTTY\plink.exe',
>>> 'C:\Program Files (x86)\PuTTY\pscp.exe',
>>> 'C:\Program Files (x86)\PuTTY\psftp.exe'
>
PS C:\> New-SysmonRuleFilter -ConfigFile .\pc_marketing.xml -EventType NetworkConnect -Condition Image -EventField Image -Value $images -Verbose
VERBOSE: No rule for NetworkConnect was found.
VERBOSE: Creating rule for event type with default action if Exclude
VERBOSE: Rule created successfully
VERBOSE: Creating filters for event type NetworkConnect.
VERBOSE: Creating filter for event filed Image with condition Image for value C:\Windows\System32\svchost.exe.
VERBOSE: Creating filter for event filed Image with condition Image for value C:\Program Files (x86)\Internet Explorer\iexplore.exe.
VERBOSE: Creating filter for event filed Image with condition Image for value C:\Program Files\Internet Explorer\iexplore.exe.
VERBOSE: Creating filter for event filed Image with condition Image for value C:\Program Files (x86)\Google\Chrome\Application\chrome.exe.
VERBOSE: Creating filter for event filed Image with condition Image for value C:\Program Files (x86)\PuTTY\putty.exe.
VERBOSE: Creating filter for event filed Image with condition Image for value C:\Program Files (x86)\PuTTY\plink.exe.
VERBOSE: Creating filter for event filed Image with condition Image for value C:\Program Files (x86)\PuTTY\pscp.exe.
VERBOSE: Creating filter for event filed Image with condition Image for value C:\Program Files (x86)\PuTTY\psftp.exe.

EventType     : NetworkConnect
Scope         : Filtered
DefaultAction : Exclude
Filters       : {@{EventField=Image; Condition=Image; Value=C:\Windows\System32\svchost.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files (x86)\Internet Explorer\iexplore.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files\Internet Explorer\iexplore.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe}...}
</pre>

## Get configured Rules and Filters

<pre>
PS C:\> Get-SysmonRule -ConfigFile .\pc_marketing.xml


EventType     : NetworkConnect
Scope         : Filtered
DefaultAction : Exclude
Filters       : {@{EventField=Image; Condition=Image; Value=C:\Windows\System32\svchost.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files (x86)\Internet Explorer\iexplore.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files\Internet Explorer\iexplore.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe}...}



PS C:\> Get-SysmonRules -ConfigFile .\pc_marketing.xml | select -ExpandProperty Filters

EventField   Condition    Value
----------   ---------    -----
Image        Image        C:\Windows\System32\svchost.exe
Image        Image        C:\Program Files (x86)\Internet Explorer\iexplo...
Image        Image        C:\Program Files\Internet Explorer\iexplore.exe
Image        Image        C:\Program Files (x86)\Google\Chrome\Applicatio...
Image        Image        C:\Program Files (x86)\PuTTY\putty.exe
Image        Image        C:\Program Files (x86)\PuTTY\plink.exe
Image        Image        C:\Program Files (x86)\PuTTY\pscp.exe
Image        Image        C:\Program Files (x86)\PuTTY\psftp.exe


</pre>

## Create or Update a Rule and its Default Action

<pre>

PS C:\> Set-SysmonRule -ConfigFile .\pc_marketing.xml -EventType ImageLoad -Verbose
VERBOSE: No rule for ImageLoad was found.
VERBOSE: Creating rule for event type with action of Exclude
VERBOSE: Action has been set.

EventType     : ImageLoad
Scope         : All Events
DefaultAction : Exclude
Filters       :

</pre>

## Remove One or More Filters

<pre>
PS C:\> Get-SysmonRule -ConfigFile .\pc_marketing.xml -EventType NetworkConnect

EventType     : NetworkConnect
Scope         : Filtered
DefaultAction : Exclude
Filters       : {@{EventField=Image; Condition=Image; Value=C:\Windows\System32\svchost.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files (x86)\Internet Explorer\iexplore.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files\Internet Explorer\iexplore.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe}...}


PS C:\> Remove-SysmonRuleFilter -ConfigFile .\pc_marketing.xml -EventType NetworkConnect -Condition Image -EventField Image -Value $images -Verbose
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
</pre>

## Remove Rule

<pre>
PS C:\> Remove-SysmonRule -ConfigFile .\pc_marketing.xml -EventType ImageLoad,NetworkConnect -Verbose
VERBOSE: Removed rule for ImageLoad.
VERBOSE: Removed rule for NetworkConnect.
</pre>