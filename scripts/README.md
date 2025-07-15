# CFAi Hub - Server Statistics Connector

This directory contains scripts to gather real technical statistics from your IIS server and display them in the Hub interface.

## Files

### `server-stats.ps1`
PowerShell script that gathers real IIS server statistics including:
- System performance metrics (CPU, Memory, Disk)
- IIS Application Pool status
- IIS Site status
- CFAi application health
- System uptime
- Request statistics

### `server-connector.js`
JavaScript connector that reads the JSON statistics file and updates the terminal interface in real-time.

### `update-stats.bat`
Batch file wrapper for running the PowerShell script with proper logging.

## Setup Instructions

### 1. Configure Application Names
Edit `server-stats.ps1` and update the `$cfaiApps` hashtable with your actual IIS application pool and site names:

```powershell
$cfaiApps = @{
    "CFAi" = @{
        AppPool = "YourCFAiAppPoolName"
        Site = "YourCFAiSiteName"
        ExpectedState = "Started"
    }
    # ... other apps
}
```

### 2. Set Up Scheduled Task
Create a Windows Scheduled Task to run the statistics update every 30 seconds:

```powershell
# Run as Administrator
$action = New-ScheduledTaskAction -Execute "C:\path\to\your\Hub\scripts\update-stats.bat"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Seconds 30) -RepetitionDuration (New-TimeSpan -Days 365)
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "CFAi Hub Stats Update" -Action $action -Trigger $trigger -Principal $principal
```

### 3. Test the Script
Run the PowerShell script manually to test:

```powershell
.\scripts\server-stats.ps1 -Verbose
```

### 4. Verify Output
Check that the JSON file is created at `data/server-stats.json` and contains valid statistics.

## Configuration Options

### PowerShell Script Parameters
- `-ServerName`: Target server name (default: localhost)
- `-OutputPath`: Output JSON file path (default: .\data\server-stats.json)
- `-Verbose`: Enable verbose output

### JavaScript Connector Options
- `updateInterval`: How often to check for updates (default: 30 seconds)
- `statsFile`: Path to the JSON statistics file

## Troubleshooting

### Common Issues

1. **PowerShell Execution Policy**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **IIS Module Not Found**
   ```powershell
   Import-Module WebAdministration
   ```

3. **Permission Denied**
   - Run as Administrator
   - Check file permissions on output directory

4. **Performance Counters Not Available**
   - Ensure IIS is installed and running
   - Check Windows Performance Monitor

### Log Files
- Check `logs/stats-update.log` for batch file execution logs
- PowerShell errors are displayed in console when using `-Verbose`

## Security Considerations

- The scripts require administrative privileges to access IIS and system performance data
- Store the JSON file in a secure location
- Consider implementing authentication for the web interface
- Review and adjust the scheduled task permissions as needed

## Customization

### Adding New Metrics
1. Add new functions to `server-stats.ps1`
2. Include the data in the `$stats` hashtable
3. Update the JavaScript connector to display the new metrics

### Modifying Update Frequency
- Change the `updateInterval` in `server-connector.js`
- Adjust the scheduled task repetition interval
- Consider server load when setting update frequency

## Support

For issues or questions, contact the CFAi development team. 