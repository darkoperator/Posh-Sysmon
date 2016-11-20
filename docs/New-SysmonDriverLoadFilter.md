---
external help file: Posh-SysMon.psm1-Help.xml
online version: 
schema: 2.0.0
---

# New-SysmonDriverLoadFilter

## SYNOPSIS
Create a new filter for the logging of loading of a driver by the system.

## SYNTAX

### Path (Default)
```
New-SysmonDriverLoadFilter [-Path] <Object> [-OnMatch] <String> [-Condition] <String> [-EventField] <String>
 [-Value] <String[]>
```

### LiteralPath
```
New-SysmonDriverLoadFilter [-LiteralPath] <Object> [-OnMatch] <String> [-Condition] <String>
 [-EventField] <String> [-Value] <String[]>
```

## DESCRIPTION
Create a new filter for the logging of loading of a driver by the system.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
Path to SysMon rule XML file.

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

### -OnMatch
@{Text=}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Condition
Condition to use for matching the value of an eventfield.

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

### -EventField
Event Field to be evaluated.

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

### -Value
Value of field that will be evaluated.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -LiteralPath
Literal path to SysMon rule XML file.

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
### System.String
### System.String[]
## OUTPUTS

## NOTES

## RELATED LINKS

