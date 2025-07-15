# CFAi Hub - IIS Server Statistics Connector
# This script gathers real technical statistics from the IIS server

param(
    [string]$ServerName = "localhost",
    [string]$OutputPath = ".\data\server-stats.json",
    [switch]$Verbose
)

# Ensure output directory exists
$OutputDir = Split-Path $OutputPath -Parent
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Function to get IIS Application Pool status
function Get-IISAppPoolStatus {
    try {
        $appPools = Get-IISAppPool -ComputerName $ServerName | Select-Object Name, State, StartMode, ProcessModel
        $appPoolStatus = @{}
        
        foreach ($pool in $appPools) {
            $appPoolStatus[$pool.Name] = @{
                Name = $pool.Name
                State = $pool.State.ToString()
                StartMode = $pool.StartMode.ToString()
                ProcessModel = $pool.ProcessModel.IdentityType.ToString()
            }
        }
        
        return $appPoolStatus
    }
    catch {
        Write-Warning "Could not retrieve IIS Application Pool status: $($_.Exception.Message)"
        return @{}
    }
}

# Function to get IIS Site status
function Get-IISSiteStatus {
    try {
        $sites = Get-IISSite -ComputerName $ServerName | Select-Object Name, State, Id, Bindings
        $siteStatus = @{}
        
        foreach ($site in $sites) {
            $siteStatus[$site.Name] = @{
                Name = $site.Name
                State = $site.State.ToString()
                Id = $site.Id
                Bindings = $site.Bindings.Protocol + "://" + $site.Bindings.BindingInformation
            }
        }
        
        return $siteStatus
    }
    catch {
        Write-Warning "Could not retrieve IIS Site status: $($_.Exception.Message)"
        return @{}
    }
}

# Function to get system performance metrics
function Get-SystemPerformance {
    try {
        $cpu = Get-Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 1
        $memory = Get-Counter "\Memory\Available MBytes" -SampleInterval 1 -MaxSamples 1
        $disk = Get-Counter "\PhysicalDisk(_Total)\% Disk Time" -SampleInterval 1 -MaxSamples 1
        
        return @{
            CPU = [math]::Round($cpu.CounterSamples[0].CookedValue, 2)
            AvailableMemoryMB = [math]::Round($memory.CounterSamples[0].CookedValue, 2)
            DiskUsage = [math]::Round($disk.CounterSamples[0].CookedValue, 2)
            TotalMemoryGB = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
        }
    }
    catch {
        Write-Warning "Could not retrieve system performance metrics: $($_.Exception.Message)"
        return @{
            CPU = 0
            AvailableMemoryMB = 0
            DiskUsage = 0
            TotalMemoryGB = 0
        }
    }
}

# Function to get IIS request statistics
function Get-IISRequestStats {
    try {
        $requests = Get-Counter "\Web Service(_Total)\Current Connections" -SampleInterval 1 -MaxSamples 1
        $requestsPerSec = Get-Counter "\Web Service(_Total)\Requests/sec" -SampleInterval 1 -MaxSamples 1
        
        return @{
            CurrentConnections = [math]::Round($requests.CounterSamples[0].CookedValue, 0)
            RequestsPerSecond = [math]::Round($requestsPerSec.CounterSamples[0].CookedValue, 2)
        }
    }
    catch {
        Write-Warning "Could not retrieve IIS request statistics: $($_.Exception.Message)"
        return @{
            CurrentConnections = 0
            RequestsPerSecond = 0
        }
    }
}

# Function to get system uptime
function Get-SystemUptime {
    try {
        $uptime = (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
        return @{
            Days = $uptime.Days
            Hours = $uptime.Hours
            Minutes = $uptime.Minutes
            TotalSeconds = $uptime.TotalSeconds
        }
    }
    catch {
        Write-Warning "Could not retrieve system uptime: $($_.Exception.Message)"
        return @{
            Days = 0
            Hours = 0
            Minutes = 0
            TotalSeconds = 0
        }
    }
}

# Function to check specific CFAi applications
function Get-CFAiAppStatus {
    $cfaiApps = @{
        "CFAi" = @{
            AppPool = "CFAiAppPool"
            Site = "CFAi"
            ExpectedState = "Started"
        }
        "Condor" = @{
            AppPool = "CondorAppPool"
            Site = "Condor"
            ExpectedState = "Started"
        }
        "Textraction" = @{
            AppPool = "TextractionAppPool"
            Site = "Textraction"
            ExpectedState = "Started"
        }
        "APIHub" = @{
            AppPool = "APIHubAppPool"
            Site = "APIHub"
            ExpectedState = "Started"
        }
        "FFAi" = @{
            AppPool = "FFAiAppPool"
            Site = "FFAi"
            ExpectedState = "Started"
        }
    }
    
    $appStatus = @{}
    
    foreach ($app in $cfaiApps.Keys) {
        try {
            $appPool = Get-IISAppPool -Name $cfaiApps[$app].AppPool -ComputerName $ServerName -ErrorAction SilentlyContinue
            $site = Get-IISSite -Name $cfaiApps[$app].Site -ComputerName $ServerName -ErrorAction SilentlyContinue
            
            $appStatus[$app] = @{
                Name = $app
                AppPoolStatus = if ($appPool) { $appPool.State.ToString() } else { "Unknown" }
                SiteStatus = if ($site) { $site.State.ToString() } else { "Unknown" }
                OverallStatus = if ($appPool -and $site -and $appPool.State.ToString() -eq "Started" -and $site.State.ToString() -eq "Started") { "Online" } else { "Offline" }
                LastChecked = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }
        catch {
            $appStatus[$app] = @{
                Name = $app
                AppPoolStatus = "Error"
                SiteStatus = "Error"
                OverallStatus = "Error"
                LastChecked = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Error = $_.Exception.Message
            }
        }
    }
    
    return $appStatus
}

# Main execution
Write-Host "CFAi Hub - IIS Server Statistics Connector" -ForegroundColor Green
Write-Host "Server: $ServerName" -ForegroundColor Yellow
Write-Host "Output: $OutputPath" -ForegroundColor Yellow
Write-Host ""

# Gather all statistics
$stats = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    ServerName = $ServerName
    SystemUptime = Get-SystemUptime
    SystemPerformance = Get-SystemPerformance
    IISRequestStats = Get-IISRequestStats
    IISAppPools = Get-IISAppPoolStatus
    IISSites = Get-IISSiteStatus
    CFAiApplications = Get-CFAiAppStatus
}

# Calculate overall system health
$overallHealth = "Healthy"
$issues = @()

# Check critical metrics
if ($stats.SystemPerformance.CPU -gt 90) {
    $overallHealth = "Warning"
    $issues += "High CPU usage: $($stats.SystemPerformance.CPU)%"
}

if ($stats.SystemPerformance.AvailableMemoryMB -lt 1000) {
    $overallHealth = "Warning"
    $issues += "Low available memory: $($stats.SystemPerformance.AvailableMemoryMB) MB"
}

if ($stats.SystemPerformance.DiskUsage -gt 90) {
    $overallHealth = "Warning"
    $issues += "High disk usage: $($stats.SystemPerformance.DiskUsage)%"
}

# Check CFAi applications
$offlineApps = $stats.CFAiApplications.Values | Where-Object { $_.OverallStatus -ne "Online" }
if ($offlineApps.Count -gt 0) {
    $overallHealth = "Warning"
    $issues += "Offline applications: $($offlineApps.Name -join ', ')"
}

$stats.OverallHealth = @{
    Status = $overallHealth
    Issues = $issues
    LastChecked = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

# Output results
if ($Verbose) {
    Write-Host "System Uptime: $($stats.SystemUptime.Days) days, $($stats.SystemUptime.Hours) hours, $($stats.SystemUptime.Minutes) minutes" -ForegroundColor Cyan
    Write-Host "CPU Usage: $($stats.SystemPerformance.CPU)%" -ForegroundColor Cyan
    Write-Host "Available Memory: $($stats.SystemPerformance.AvailableMemoryMB) MB" -ForegroundColor Cyan
    Write-Host "Current Connections: $($stats.IISRequestStats.CurrentConnections)" -ForegroundColor Cyan
    Write-Host "Overall Health: $overallHealth" -ForegroundColor $(if ($overallHealth -eq "Healthy") { "Green" } else { "Yellow" })
    
    if ($issues.Count -gt 0) {
        Write-Host "Issues detected:" -ForegroundColor Red
        foreach ($issue in $issues) {
            Write-Host "  - $issue" -ForegroundColor Red
        }
    }
}

# Save to JSON file
try {
    $stats | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "Statistics saved to: $OutputPath" -ForegroundColor Green
}
catch {
    Write-Error "Failed to save statistics: $($_.Exception.Message)"
    exit 1
}

# Return exit code based on health
if ($overallHealth -eq "Healthy") {
    exit 0
} else {
    exit 1
} 