# Posh-Sysmon
PowerShell 3.0 or above module for creating and managing Sysinternals Sysmon v2.0 config files. System Monitor ([Sysmon](https://technet.microsoft.com/en-us/sysinternals/dn798348)) is a Windows system service and device driver that is part of the SysInternal tools from Microsoft. It is written by Mark Russinovich and Thomas Garnier to monitor a Windows system actions and log such actions in to the Windows Event Log. When the tool is installed on a system it can be given a XML configuration file so as to control what is logged and the same file can be used to update the configuration of a previously installed instance of the tool. 

All functions in the PowerShell module include help information and example of usage that can be view using the Get-Help cmdlet. 

# Installation

To install the module from a PowerShell v3 session run:
<pre>
iex (New-Object Net.WebClient).DownloadString("https://gist.githubusercontent.com/darkoperator/3f9da4b780b5a0206bca/raw/d5b798cac5fbdae7885c546c9efcc5cb48fbe04d/posh-sysmoninstall.ps1")
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
## Version 0.4
* Added Get-SysmonEventData to get the Event Data information as custom object for selected Event Types.
## Version 0.4
Version 3.0 is a full re-write om how rules work and new event types. This update is SysMon 3.0 only. If you wish to work on SysMon 2.0 rules I recommend you use version 0.3 version of the module.
* When creating a new sysmon rule it will allow you to enable logging of event types supported.
* Checks that it is only working with the proper XML schema for the rules.
* Can now create specific filter for CreateRemoteThread event type.
* Since Rules and Config got merger config functions (Get-SysmonConfigOptio, Set-SysmonConfigOption) where removed and replaced with Get-SysmonHashingAlgorithm and Set-SysmonHashingAlgorithm
## Version 0.3
* Tons of fixes do to a bad re-facor.
* Filter creation is now done by specific funtions per event type.
* Filter creation functions are now in their own sub-module.
## Version 0.2
* Validate that the file is an XML file and a valid Sysmon configuration file.
* Change option ConfigFile to Path and LiteralPath so as to match other cmdlets that work with files.
* Fixed typos on verbose messages and examples.
* Functions should work better now when passing files through the pipeline using Get-ChildItem.

## Version 0.1
* Initial version for Sysmon 2.0 with XML Schema 1.0

# Examples

## Create a XML Configuration File

<pre>
PS C:\> New-SysmonConfiguration -Path .\pc_marketing.xml -HashingAlgorithm IMPHASH,SHA1 -Network -Comment "Sysmon config for deployment in the Marketing PC OU" -Verbose
VERBOSE: Enabling hashing algorithms : IMPHASH,SHA1
VERBOSE: Enabling network connection logging.
VERBOSE: Config file created as C:\pc_marketing.xml
</pre>


## Get configured Rules and Filters

<pre>
PS C:\> Get-SysmonRule -Path .\pc_marketing.xml


EventType     : NetworkConnect
Scope         : Filtered
DefaultAction : Exclude
Filters       : {@{EventField=Image; Condition=Image; Value=C:\Windows\System32\svchost.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files (x86)\Internet Explorer\iexplore.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files\Internet Explorer\iexplore.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe}...}



PS C:\> Get-SysmonRules -Path .\pc_marketing.xml | select -ExpandProperty Filters

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

PS C:\> Set-SysmonRule -Path .\pc_marketing.xml -EventType ImageLoad -Verbose
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
PS C:\> Get-SysmonRule -Path .\pc_marketing.xml -EventType NetworkConnect

EventType     : NetworkConnect
Scope         : Filtered
DefaultAction : Exclude
Filters       : {@{EventField=Image; Condition=Image; Value=C:\Windows\System32\svchost.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files (x86)\Internet Explorer\iexplore.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files\Internet Explorer\iexplore.exe}, 
                @{EventField=Image; Condition=Image; Value=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe}...}


PS C:\> Remove-SysmonRuleFilter -Path .\pc_marketing.xml -EventType NetworkConnect -Condition Image -EventField Image -Value $images -Verbose
VERBOSE: Filter for field Image with condition Image and value of C:\Windows\System32\svchost.exe removed.
VERBOSE: Filter for field Image with condition Image and value of C:\Program Files (x86)\Internet Explorer\iexplore.exe removed.
VERBOSE: Filter for field Image with condition Image and value of C:\Program Files\Internet Explorer\iexplore.exe removed.
VERBOSE: Filter for field Image with condition Image and value of C:\Program Files (x86)\Google\Chrome\Application\chrome.exe removed.
VERBOSE: Filter for field Image with condition Image and value of C:\Program Files (x86)\PuTTY\putty.exe removed.
VERBOSE: Filter for field Image with condition Image and value of C:\Program Files (x86)\PuTTY\plink.exe removed.
VERBOSE: Filter for field Image with condition Image and value of C:\Program Files (x86)\PuTTY\pscp.exe removed.
VERBOSE: Filter for field Image with condition Image and value of C:\Program Files (x86)\PuTTY\psftp.exe removed.


EventType     : NetworkConnect
Scope         : All Events
DefaultAction : Exclude
Filters       :
</pre>

## Remove Rule

<pre>
PS C:\> Remove-SysmonRule -Path .\pc_marketing.xml -EventType ImageLoad,NetworkConnect -Verbose
VERBOSE: Removed rule for ImageLoad.
VERBOSE: Removed rule for NetworkConnect.
</pre>
