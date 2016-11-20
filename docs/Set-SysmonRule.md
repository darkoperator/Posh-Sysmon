---
external help file: Posh-SysMon.psm1-Help.xml
online version: 
schema: 2.0.0
---

# Set-SysmonRule

## SYNOPSIS
Creates a Rule and sets its default action in a Sysmon configuration XML file.

## SYNTAX

### Path (Default)
```
Set-SysmonRule [-Path] <Object> [-EventType] <String[]> [[-OnMatch] <String>] [-Action <String>]
```

### LiteralPath
```
Set-SysmonRule [-LiteralPath] <Object> [-EventType] <String[]> [[-OnMatch] <String>] [-Action <String>]
```

## DESCRIPTION
Creates a rules for a specified Event Type and sets the default action for the rule and filters under it.
Ir a rule alreade exists it udates the default action taken by a event type rule if one aready present.
The default is exclude.
This default is set for event type and affects all filters under it.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-GetSysmonRule -Path .\pc_cofig.xml -EventType NetworkConnect -OnMatch Exclude

EventType     : NetworkConnect
 Scope         : Filtered
 DefaultAction : Exclude
 Filters       : {@{EventField=image; Condition=Is; Value=iexplorer.exe}}

PS C:\> Set-SysmonRulen -Path .\pc_cofig.xml -EventType NetworkConnect -Action Include -Verbose
VERBOSE: Setting as default action for NetworkConnect the action of Include.
VERBOSE: Action has been set.

PS C:\> Get-GetSysmonRule -Path .\pc_cofig.xml -EventType NetworkConnect


EventType     : NetworkConnect
Scope         : Filtered
DefaultAction : Include
Filters       : {@{EventField=image; Condition=Is; Value=iexplorer.exe}}
```

Change default rule action causing the filter to ignore all traffic from iexplorer.exe.

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
Event type to update.

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

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Action
@{Text=}

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

### System.String

## OUTPUTS

## NOTES

## RELATED LINKS

