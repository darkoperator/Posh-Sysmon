---
external help file: Posh-SysMon-help.xml
Module Name: Posh-SysMon
online version: https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Remove-SysmonRuleFilter.md
schema: 2.0.0
---

# Remove-SysmonRuleFilter

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

### Path (Default)
```
Remove-SysmonRuleFilter [-Path] <Object> [-EventType] <String> [-OnMatch] <String> [-Condition] <String>
 [-EventField] <String> [-Value] <String[]> [<CommonParameters>]
```

### LiteralPath
```
Remove-SysmonRuleFilter [-LiteralPath] <Object> [-EventType] <String> [-OnMatch] <String> [-Condition] <String>
 [-EventField] <String> [-Value] <String[]> [<CommonParameters>]
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

### -Condition
{{Fill Condition Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Is, IsNot, Contains, Excludes, Image, BeginWith, EndWith, LessThan, MoreThan

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -EventField
{{Fill EventField Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -EventType
{{Fill EventType Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: NetworkConnect, ProcessCreate, FileCreateTime, ProcessTerminate, ImageLoad, DriverLoad, CreateRemoteThread, RawAccessRead, ProcessAccess, FileCreateStreamHash, RegistryEvent, FileCreate, PipeEvent, WmiEvent

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -LiteralPath
{{Fill LiteralPath Description}}

```yaml
Type: Object
Parameter Sets: LiteralPath
Aliases: PSPath

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OnMatch
{{Fill OnMatch Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: include, exclude

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path
{{Fill Path Description}}

```yaml
Type: Object
Parameter Sets: Path
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Value
{{Fill Value Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Object

### System.String

### System.String[]

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Remove-SysmonRuleFilter.md](https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Remove-SysmonRuleFilter.md)

