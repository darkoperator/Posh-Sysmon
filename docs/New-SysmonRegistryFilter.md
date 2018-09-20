---
external help file: Posh-SysMon-help.xml
Module Name: Posh-SysMon
online version: https://github.com/darkoperator/Posh-Sysmon/blob/master/docs/New-SysmonProcessTerminateFilter.md
schema: 2.0.0
---

# New-SysmonRegistryFilter

## SYNOPSIS
Create a new filter for the actions against the registry.

## SYNTAX

### Path (Default)
```
New-SysmonRegistryFilter [-Path] <Object> [-OnMatch] <String> [-Condition] <String> [-EventField] <String>
 [-Value] <String[]> [-RuleName <String>] [<CommonParameters>]
```

### LiteralPath
```
New-SysmonRegistryFilter [-LiteralPath] <Object> [-OnMatch] <String> [-Condition] <String>
 [-EventField] <String> [-Value] <String[]> [-RuleName <String>] [<CommonParameters>]
```

## DESCRIPTION
Create a new filter for actions against the registry.
Supports filtering
by aby of the following event types:
* CreateKey
* DeleteKey
* RenameKey
* CreateValue
* DeleteValue
* RenameValue
* SetValue

Hives on Schema 3.2 in TargetObject are referenced as:
* \REGISTRY\MACHINE\HARDWARE
* \REGISTRY\USER\Security ID number
* \REGISTRY\MACHINE\SECURITY
* \REGISTRY\USER\.DEFAULT
* \REGISTRY\MACHINE\SYSTEM
* \REGISTRY\MACHINE\SOFTWARE
* \REGISTRY\MACHINE\SAM

Hives on Schema 3.3 and above in TargetObject are referenced as:
* HKLM
* HKCR
* HKEY_USER

## EXAMPLES

### EXAMPLE 1
```
New-SysmonRegistryFilter -Path .\32config.xml -OnMatch include -Condition Contains -EventField TargetObject 'RunOnce'
```

Capture persistance attemp by creating a registry entry in the RunOnce keys.

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

### -OnMatch
Event type on match action.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Condition
Condition for filtering against and event field.

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

### -EventField
Event field to filter on.

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

### -Value
Value of Event Field to filter on.

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

### -RuleName
Rule Name for the filter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
