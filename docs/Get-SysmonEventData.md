---
external help file: Posh-SysMon-help.xml
Module Name: Posh-SysMon
online version:
schema: 2.0.0
---

# Get-SysmonEventData

## SYNOPSIS
Searches for specified SysMon Events and retunrs the Event Data as a custom object.

## SYNTAX

### ID (Default)
```
Get-SysmonEventData [-EventId] <Int32[]> [[-MaxEvents] <Int32>] [-Path <String[]>] [-StartTime <DateTime>]
 [-EndTime <DateTime>] [<CommonParameters>]
```

### Type
```
Get-SysmonEventData [[-EventType] <String[]>] [[-MaxEvents] <Int32>] [-Path <String[]>] [-StartTime <DateTime>]
 [-EndTime <DateTime>] [<CommonParameters>]
```

## DESCRIPTION
Searches for specified SysMon Events and retunrs the Event Data as a custom object.

## EXAMPLES

### EXAMPLE 1
```
Get-SysMonEventData -EventId 1 -MaxEvents 10 -EndTime (Get-Date) -StartTime (Get-Date).AddDays(-1)
```

All process creation events in the last 24hr

### EXAMPLE 2
```
Get-SysMonEventData -EventId 3 -MaxEvents 20 -Path .\export.evtx
```

last 20 network connection events from a exported SysMon log.

## PARAMETERS

### -EventId
Sysmon Event ID of records to show

```yaml
Type: Int32[]
Parameter Sets: ID
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -EventType
EventType that a Rule can be written against.

```yaml
Type: String[]
Parameter Sets: Type
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MaxEvents
Specifies the maximum number of events that Get-WinEvent returns.
Enter an integer.
The default is to return all the events in the logs or files.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path
Specifies a path to one or more exported SysMon events in evtx format.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PSPath

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -StartTime
Start Date to get all event going forward.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndTime
End data for searching events.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
