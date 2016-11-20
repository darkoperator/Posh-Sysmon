---
external help file: Posh-SysMon.psm1-Help.xml
online version: 
schema: 2.0.0
---

# New-SysmonConfiguration

## SYNOPSIS
Creates a new Sysmon XML configuration file.

## SYNTAX

```
New-SysmonConfiguration [-Path] <String> [-HashingAlgorithm] <String[]> [-NetworkConnect] [-DriverLoad]
 [-ImageLoad] [-CreateRemoteThread] [-FileCreateTime] [-ProcessCreate] [-ProcessTerminate] [-ProcessAccess]
 [-RawAccessRead] [-CheckRevocation] [-RegistryEvent] [-FileCreate] [-FileCreateStreamHash] [-Comment <String>]
 [-SchemaVersion <String>]
```

## DESCRIPTION
Creates a new Sysmon XML configuration file.
Configuration options and a descriptive comment can be given when generating the XML config file.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-SysmonConfiguration -ConfigFile .\pc_cofig.xml -HashingAlgorithm SHA1,IMPHASH -Network -ImageLoading -Comment "Config for helpdesk PCs." -Verbose

VERBOSE: Enabling hashing algorithms : SHA1,IMPHASH
VERBOSE: Enabling network connection logging.
VERBOSE: Enabling image loading logging.
VERBOSE: Config file created as C:\\pc_cofig.xml
```

Create a configuration file that will log all network connction, image loading and sets a descriptive comment.

## PARAMETERS

### -Path
Path to write XML config file.

```yaml
Type: String
Parameter Sets: (All)
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

### -NetworkConnect
Enable all NetworkConnect events.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DriverLoad
Enable all DrierLoad events.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ImageLoad
Enable all ImageLoad events.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CreateRemoteThread
Enable all CreateRemoteThread events.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: 5
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FileCreateTime
Enable all FileCreateTimeEvents.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: 6
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ProcessCreate
Enable all ProcessCreate events

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: 7
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ProcessTerminate
Enable all ProcessTerminate events.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: 8
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Comment
Comment for purpose of the configuration file.

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

### -SchemaVersion
Schema version for the configuration file.
- SysMon 3.0 uses 2.0

- SysMon 4.0 uses 3.0

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 3.0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CheckRevocation
{{Fill CheckRevocation Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FileCreate
{{Fill FileCreate Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FileCreateStreamHash
{{Fill FileCreateStreamHash Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ProcessAccess
{{Fill ProcessAccess Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RawAccessRead
{{Fill RawAccessRead Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RegistryEvent
{{Fill RegistryEvent Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

### System.String

### System.String[]

### System.Management.Automation.SwitchParameter

## OUTPUTS

## NOTES

## RELATED LINKS

