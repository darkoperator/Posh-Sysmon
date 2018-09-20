---
external help file: Posh-SysMon-help.xml
Module Name: Posh-SysMon
online version: https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Get-SysmonRule.md
schema: 2.0.0
---

# Get-SysmonRule

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

### Path (Default)
```
Get-SysmonRule [-Path] <String> [[-EventType] <String[]>] [<CommonParameters>]
```

### LiteralPath
```
Get-SysmonRule [-LiteralPath] <String> [[-EventType] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -EventType
{{Fill EventType Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: ALL, NetworkConnect, ProcessCreate, FileCreateTime, ProcessTerminate, ImageLoad, DriverLoad, ProcessAccess, RawAccessRead, ProcessAccess, FileCreateStreamHash, RegistryEvent, FileCreate, PipeEvent, WmiEvent

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -LiteralPath
{{Fill LiteralPath Description}}

```yaml
Type: String
Parameter Sets: LiteralPath
Aliases: PSPath

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path
{{Fill Path Description}}

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.String[]

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Get-SysmonRule.md](https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Get-SysmonRule.md)

