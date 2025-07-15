// CFAi Hub - Server Statistics Connector
// This script reads real server statistics and updates the terminal interface

class ServerStatsConnector {
    constructor() {
        this.statsFile = './data/server-stats.json';
        this.updateInterval = 30000; // 30 seconds
        this.lastUpdate = null;
        this.isUpdating = false;
    }

    // Fetch server statistics from JSON file
    async fetchServerStats() {
        try {
            const response = await fetch(this.statsFile + '?t=' + Date.now()); // Cache busting
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            const data = await response.json();
            return data;
        } catch (error) {
            console.warn('Failed to fetch server stats:', error);
            return this.getFallbackStats();
        }
    }

    // Fallback statistics when server data is unavailable
    getFallbackStats() {
        return {
            Timestamp: new Date().toISOString(),
            ServerName: 'localhost',
            SystemUptime: { Days: 0, Hours: 0, Minutes: 0 },
            SystemPerformance: { CPU: 0, AvailableMemoryMB: 0, DiskUsage: 0, TotalMemoryGB: 0 },
            IISRequestStats: { CurrentConnections: 0, RequestsPerSecond: 0 },
            CFAiApplications: {
                CFAi: { OverallStatus: 'Unknown', LastChecked: new Date().toISOString() },
                Condor: { OverallStatus: 'Unknown', LastChecked: new Date().toISOString() },
                Textraction: { OverallStatus: 'Unknown', LastChecked: new Date().toISOString() },
                APIHub: { OverallStatus: 'Unknown', LastChecked: new Date().toISOString() },
                FFAi: { OverallStatus: 'Unknown', LastChecked: new Date().toISOString() }
            },
            OverallHealth: { Status: 'Unknown', Issues: ['Server statistics unavailable'] }
        };
    }

    // Update the terminal interface with real data
    updateTerminalInterface(stats) {
        const terminalContainer = document.querySelector('.terminal-container');
        if (!terminalContainer) return;

        // Update system uptime
        const uptimeLine = terminalContainer.querySelector('.terminal-info');
        if (uptimeLine && uptimeLine.textContent.includes('System Uptime')) {
            uptimeLine.textContent = `System Uptime: ${stats.SystemUptime.Days} days, ${stats.SystemUptime.Hours} hours, ${stats.SystemUptime.Minutes} minutes`;
        }

        // Update server status
        const serverStatusLine = terminalContainer.querySelector('.terminal-success');
        if (serverStatusLine && serverStatusLine.textContent.includes('Server Status')) {
            const healthStatus = stats.OverallHealth.Status === 'Healthy' ? 'ONLINE' : 'WARNING';
            serverStatusLine.textContent = `✓ Server Status: ${healthStatus}`;
            serverStatusLine.className = stats.OverallHealth.Status === 'Healthy' ? 'terminal-line terminal-success' : 'terminal-line terminal-warning';
        }

        // Update database connection status
        const dbStatusLine = Array.from(terminalContainer.querySelectorAll('.terminal-success')).find(el => 
            el.textContent.includes('Database Connection')
        );
        if (dbStatusLine) {
            dbStatusLine.textContent = `✓ Database Connection: ${stats.OverallHealth.Status === 'Healthy' ? 'ACTIVE' : 'DEGRADED'}`;
        }

        // Update authentication service status
        const authStatusLine = Array.from(terminalContainer.querySelectorAll('.terminal-success')).find(el => 
            el.textContent.includes('Authentication Service')
        );
        if (authStatusLine) {
            authStatusLine.textContent = `✓ Authentication Service: ${stats.OverallHealth.Status === 'Healthy' ? 'RUNNING' : 'DEGRADED'}`;
        }

        // Update application status
        this.updateApplicationStatus(terminalContainer, stats.CFAiApplications);

        // Add performance metrics if they don't exist
        this.addPerformanceMetrics(terminalContainer, stats);

        // Update timestamp
        this.updateLastChecked(terminalContainer, stats.Timestamp);
    }

    // Update individual application status
    updateApplicationStatus(terminalContainer, applications) {
        const appLines = terminalContainer.querySelectorAll('.terminal-success');
        
        appLines.forEach(line => {
            const appName = this.extractAppName(line.textContent);
            if (appName && applications[appName]) {
                const app = applications[appName];
                const status = app.OverallStatus === 'Online' ? 'ONLINE' : 'OFFLINE';
                const version = app.Version || 'v1.0.0';
                
                line.textContent = `✓ ${appName}: ${status} (${version})`;
                line.className = app.OverallStatus === 'Online' ? 'terminal-line terminal-success' : 'terminal-line terminal-error';
            }
        });
    }

    // Extract application name from terminal line
    extractAppName(text) {
        const match = text.match(/✓\s*(\w+):/);
        return match ? match[1] : null;
    }

    // Add performance metrics to terminal
    addPerformanceMetrics(terminalContainer, stats) {
        // Check if performance metrics already exist
        if (terminalContainer.querySelector('.performance-metrics')) return;

        const perfDiv = document.createElement('div');
        perfDiv.className = 'performance-metrics';
        perfDiv.innerHTML = `
            <div class="terminal-line terminal-info">
                CPU Usage: ${stats.SystemPerformance.CPU}% | Memory: ${stats.SystemPerformance.AvailableMemoryMB} MB Available
            </div>
            <div class="terminal-line terminal-info">
                Active Connections: ${stats.IISRequestStats.CurrentConnections} | Requests/sec: ${stats.IISRequestStats.RequestsPerSecond}
            </div>
        `;

        // Insert before the last prompt line
        const lastPrompt = terminalContainer.querySelector('.terminal-prompt:last-of-type');
        if (lastPrompt) {
            lastPrompt.parentNode.insertBefore(perfDiv, lastPrompt.parentNode);
        }
    }

    // Update last checked timestamp
    updateLastChecked(terminalContainer, timestamp) {
        let timestampLine = terminalContainer.querySelector('.timestamp-info');
        if (!timestampLine) {
            timestampLine = document.createElement('div');
            timestampLine.className = 'timestamp-info terminal-line terminal-info';
            terminalContainer.appendChild(timestampLine);
        }
        
        const date = new Date(timestamp);
        timestampLine.textContent = `Last Updated: ${date.toLocaleString()}`;
    }

    // Start periodic updates
    startUpdates() {
        this.updateStats();
        setInterval(() => this.updateStats(), this.updateInterval);
    }

    // Update statistics
    async updateStats() {
        if (this.isUpdating) return;
        
        this.isUpdating = true;
        try {
            const stats = await this.fetchServerStats();
            this.updateTerminalInterface(stats);
            this.lastUpdate = new Date();
        } catch (error) {
            console.error('Error updating server stats:', error);
        } finally {
            this.isUpdating = false;
        }
    }

    // Manual refresh
    async refresh() {
        await this.updateStats();
    }
}

// Initialize the connector when the page loads
document.addEventListener('DOMContentLoaded', function() {
    window.serverConnector = new ServerStatsConnector();
    window.serverConnector.startUpdates();
    
    // Add refresh button functionality
    const refreshButton = document.createElement('button');
    refreshButton.textContent = '🔄 Refresh';
    refreshButton.className = 'refresh-btn';
    refreshButton.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: linear-gradient(135deg, #c0c0c0, #a0a0a0);
        color: #1a1a2e;
        border: none;
        padding: 0.5rem 1rem;
        border-radius: 8px;
        cursor: pointer;
        font-weight: 600;
        z-index: 1000;
        box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    `;
    
    refreshButton.addEventListener('click', () => {
        window.serverConnector.refresh();
        refreshButton.textContent = '⏳ Updating...';
        setTimeout(() => {
            refreshButton.textContent = '🔄 Refresh';
        }, 2000);
    });
    
    document.body.appendChild(refreshButton);
});

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ServerStatsConnector;
} 