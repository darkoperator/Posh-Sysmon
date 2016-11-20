---
external help file: Posh-SysMon.psm1-Help.xml
online version: 
schema: 2.0.0
---

# Remove-SysmonRule

## SYNOPSIS
Removes on or more rules from a Sysmon XML configuration file.

## SYNTAX

### Path (Default)
```
Remove-SysmonRule [-Path] <Object> [-EventType] <String[]> [-OnMatch] <String>
```

### LiteralPath
```
Remove-SysmonRule [-LiteralPath] <Object> [-EventType] <String[]> [-OnMatch] <String>
```

## DESCRIPTION
Removes on or more rules from a Sysmon XML configuration file.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Remove-SysmonRule -Path .\pc_marketing.xml -EventType ImageLoad,NetworkConnect -Verbose
VERBOSE: Removed rule for ImageLoad.
VERBOSE: Removed rule for NetworkConnect.
```

## PARAMETERS

### -Path
Path to XML config file.

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

### -EventType
Event type to remove.
It is case sensitive.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OnMatch
Rule filter action on a macth of any filter under the rule.

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

### -LiteralPath
Path to XML config file.

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

## INPUTS

### System.Object
### System.String[]
## OUTPUTS

## NOTES

## RELATED LINKS

