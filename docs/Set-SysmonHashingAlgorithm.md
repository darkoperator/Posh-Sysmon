---
external help file: Posh-SysMon.psm1-Help.xml
online version: 
schema: 2.0.0
---

# Set-SysmonHashingAlgorithm

## SYNOPSIS
Set the hashing algorithms to use against process, library and driver images.

## SYNTAX

### Path (Default)
```
Set-SysmonHashingAlgorithm [-Path] <Object> [-HashingAlgorithm] <String[]>
```

### LiteralPath
```
Set-SysmonHashingAlgorithm [-LiteralPath] <Object> [-HashingAlgorithm] <String[]>
```

## DESCRIPTION
Set the hashing algorithms to use against process, library and driver images.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

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

### -HashingAlgorithm
Specify one or more hash algorithms used for image identification

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

