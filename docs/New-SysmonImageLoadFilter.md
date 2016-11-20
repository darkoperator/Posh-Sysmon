---
external help file: Posh-SysMon.psm1-Help.xml
online version: 
schema: 2.0.0
---

# New-SysmonImageLoadFilter

## SYNOPSIS
Create a new filter for the loading of loading of images (example: DLL, OCX) by processes.

## SYNTAX

### Path (Default)
```
New-SysmonImageLoadFilter [-Path] <Object> [-OnMatch] <String> [-Condition] <String> [-EventField] <String>
 [-Value] <String[]>
```

### LiteralPath
```
New-SysmonImageLoadFilter [-LiteralPath] <Object> [-OnMatch] <String> [-Condition] <String>
 [-EventField] <String> [-Value] <String[]>
```

## DESCRIPTION
Create a new filter for the loading of loading of images (example: DLL, OCX) by processes under the ImageLoad Rule in a SysMon configuration file.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-SysmonImageLoadFilter -Path .\sysmon.xml -OnMatch include -Condition Contains -EventField Image -Value wshom.ocx,scrrun.dll,vbscript.dll,mshtml.dll,System.Management.Automation.ni.dll,System.Management.Automation.dll
```

Create a rule to log the loading of scripting components that can be abused my a malicious process.

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
Rule filter action on a macth of any filter under the rule.

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

