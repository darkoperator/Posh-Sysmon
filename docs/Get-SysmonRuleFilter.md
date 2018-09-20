---
external help file: Posh-SysMon-help.xml
Module Name: Posh-SysMon
online version: https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/Get-SysmonRule.md
schema: 2.0.0
---

# Get-SysmonRuleFilter

## SYNOPSIS
Get the configured filters for a specified Event Type Rule in a Sysmon configuration file.

## SYNTAX

### Path (Default)
```
Get-SysmonRuleFilter [-Path] <Object> [-EventType] <String> [-OnMatch] <String> [<CommonParameters>]
```

### LiteralPath
```
Get-SysmonRuleFilter [-LiteralPath] <Object> [-OnMatch] <String> [<CommonParameters>]
```

## DESCRIPTION
Get the configured filters for a specified Event Type Rule in a Sysmon configuration file.

## EXAMPLES

### EXAMPLE 1
```
Get-SysmonRuleFilter -Path C:\sysmon.xml -EventType ProcessCreate
```

Get the filter under the ProcessCreate Rule.

## PARAMETERS

### -Path
Path to XML config file.

```yaml
Type: Object
Parameter Sets: Path
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -LiteralPath
Path to XML config file.

```yaml
Type: Object
Parameter Sets: LiteralPath
Aliases: PSPath

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -EventType
Event type rule to get filter for.

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OnMatch
Event type on match action.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
