---
external help file: Posh-SysMon.psm1-Help.xml
online version: 
schema: 2.0.0
---

# Get-SysmonRule

## SYNOPSIS
Gets configured rules and their filters on a Sysmon XML configuration file.
config file.

## SYNTAX

### Path (Default)
```
Get-SysmonRule [-Path] <String> [[-EventType] <String[]>]
```

### LiteralPath
```
Get-SysmonRule [-LiteralPath] <String> [[-EventType] <String[]>]
```

## DESCRIPTION
Gets configured rules and their filters on a Sysmon XML configuration file.
config file for each event type.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-SysmonConfigOptions -Path .\pc_cofig.xml -Verbose

Hashing      : SHA1,IMPHASH
Network      : Enabled
ImageLoading : Enabled
Comment      : Config for helpdesk PCs.
```

## PARAMETERS

### -Path
Path to XML config file.

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

### -EventType
Event type to parse rules for.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -LiteralPath
Path to XML config file.

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

## INPUTS

### System.Object

### System.String[]

## OUTPUTS

## NOTES

## RELATED LINKS

