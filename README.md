# The Hub - CFAi Application Store

## 🎯 Project Objectives

The Hub is a **centralized, role-based application store** designed for internal CFA use. It serves as the primary distribution platform for applications and downloadable tools created by the CFAi (CFA Innovation) department.

### Primary Goals
- ✅ **Secure Application Distribution** - Provide controlled access to internal tools
- ✅ **Role-Based Access Control** - Implement user permissions and privileges
- ✅ **Real-Time System Monitoring** - Live server health and application status
- ✅ **Professional User Experience** - High-end, modern interface for daily use
- ✅ **Centralized Management** - Single point of control for all CFAi applications

## 🚀 Current Progress

### ✅ **Completed Features**

#### **Phase 1: Foundation & Design** (100% Complete)
- [x] **Modern UI/UX Design**
  - Futuristic chrome/steel aesthetic with mirror effects
  - Responsive design for all devices
  - Professional typography and animations
  - Glassmorphism and metallic visual effects

- [x] **Application Interface**
  - Card-based application layout
  - Interactive hover effects and animations
  - Launch buttons with loading states
  - Status indicators for each application

- [x] **PowerShell Terminal Interface**
  - Realistic terminal appearance
  - System health monitoring display
  - Animated command execution
  - Professional terminal styling

#### **Phase 2: Real-Time Monitoring** (100% Complete)
- [x] **IIS Server Statistics Connector**
  - PowerShell script for real server metrics
  - System performance monitoring (CPU, Memory, Disk)
  - IIS Application Pool status tracking
  - Web request statistics and connection monitoring

- [x] **JavaScript Integration**
  - Real-time data updates every 30 seconds
  - Automatic terminal interface updates
  - Fallback data handling
  - Manual refresh functionality

- [x] **Scheduled Task System**
  - Automated statistics collection
  - Logging and error handling
  - Batch file execution wrapper
  - Administrative privilege management

### 🔄 **In Progress**

#### **Phase 3: Authentication & Security** (0% Complete)
- [ ] **User Authentication System**
  - Role-based login system
  - User session management
  - Secure credential handling
  - Multi-factor authentication (future)

- [ ] **Access Control Implementation**
  - User role definitions
  - Application access permissions
  - Admin panel for user management
  - Audit logging system

### 📋 **Planned Features**

#### **Phase 4: Application Management** (0% Complete)
- [ ] **Application Deployment System**
  - Automated deployment pipeline
  - Version management and rollback
  - Application update notifications
  - Download tracking and analytics

- [ ] **Advanced Monitoring**
  - Application-specific metrics
  - Performance trend analysis
  - Alert system for issues
  - Historical data visualization

#### **Phase 5: Enhanced Features** (0% Complete)
- [ ] **User Dashboard**
  - Personalized application views
  - Usage statistics and preferences
  - Quick access to frequently used apps
  - Notification center

- [ ] **Administrative Tools**
  - User management interface
  - System configuration panel
  - Backup and restore functionality
  - Performance optimization tools

## 👥 Target Users & Roles

| Role | Access Level | Description |
|------|-------------|-------------|
| **Super Admin** | Full Access | Complete system control and management |
| **DIG Team** | Development | Development and maintenance access |
| **iFam Team** | Role-Based | Application access based on permissions |
| **Credit Team** | Role-Based | Application access based on permissions |
| **Finance & Accounting** | Role-Based | Application access based on permissions |
| **Operations Team** | Role-Based | Application access based on permissions |
| **Executive Leadership** | Strategic | Oversight and reporting access |
| **Security & Infrastructure** | System | Security and infrastructure management |

## 🛠️ Available Applications

| Application | Description | Status | Version |
|-------------|-------------|--------|---------|
| **CFAi** | LLM multi-modal, custom model web application | ✅ Online | v2.1.4 |
| **Condor** | Financial analysis and reporting platform | ✅ Online | v1.8.2 |
| **Textraction** | Intelligent document processing tool | ✅ Online | v3.0.1 |
| **CFAi APIHub** | Centralized API management platform | ✅ Online | v1.5.7 |
| **FFAi** | Fast Financial AI processing platform | ✅ Online | v2.0.3 |

## 🏗️ Technology Stack

### **Frontend**
- **HTML5** - Semantic markup and structure
- **CSS3** - Modern styling with gradients and animations
- **JavaScript (ES6+)** - Interactive functionality and real-time updates
- **Font Awesome** - Professional iconography

### **Backend Integration**
- **PowerShell** - Server statistics collection
- **Windows Performance Counters** - Real-time system metrics
- **IIS Management** - Application pool and site monitoring
- **JSON** - Data exchange format

### **Infrastructure**
- **IIS Server** - Web hosting and application serving
- **Windows Scheduled Tasks** - Automated data collection
- **File System** - Local data storage and logging

## 📁 Project Structure

```
LLM-Hub/
├── index.html              # Main application interface
├── scripts/
│   ├── server-stats.ps1    # IIS statistics collector
│   ├── server-connector.js # Real-time data connector
│   ├── update-stats.bat    # Scheduled task wrapper
│   └── README.md          # Script documentation
├── data/                   # Statistics output directory
├── logs/                   # System logs
└── README.md              # Project documentation
```

## 🚀 Quick Start

### **For Users**
1. Open `index.html` in a web browser
2. View real-time system statistics in the terminal interface
3. Click "Launch" buttons to access applications (when implemented)

### **For Administrators**
1. Configure application names in `scripts/server-stats.ps1`
2. Set up scheduled task for automatic statistics collection
3. Monitor logs in the `logs/` directory

### **For Developers**
1. Clone the repository
2. Run `scripts/server-stats.ps1 -Verbose` to test
3. Check `data/server-stats.json` for output
4. Modify `scripts/server-connector.js` for custom updates

## 🔧 Configuration

### **Server Statistics**
Edit `scripts/server-stats.ps1` to match your IIS setup:
```powershell
$cfaiApps = @{
    "CFAi" = @{
        AppPool = "YourCFAiAppPool"
        Site = "YourCFAiSite"
    }
}
```

### **Update Frequency**
Modify `scripts/server-connector.js`:
```javascript
this.updateInterval = 30000; // 30 seconds
```

## 📊 System Requirements

- **Windows Server** with IIS installed
- **PowerShell 5.1+** with execution policy enabled
- **Administrative privileges** for statistics collection
- **Modern web browser** for interface access

## 🔒 Security Considerations

- **Internal network access only**
- **Role-based access control** (planned)
- **Secure authentication system** (planned)
- **Audit logging** for application access
- **Administrative privilege management**

## 📈 Performance Metrics

The system monitors:
- **CPU Usage** - Real-time processor utilization
- **Memory Availability** - Available system memory
- **Disk Usage** - Storage utilization
- **IIS Connections** - Active web connections
- **Request Rate** - Requests per second
- **Application Status** - Individual app health

## 🤝 Contributing

This is an internal CFA project. For questions or issues:
- Contact the CFAi development team
- Review the `scripts/README.md` for technical details
- Check logs in the `logs/` directory for troubleshooting

## 📞 Support

**Project Lead:** Doug Richards  
**Department:** CFAi Projekts Team  
**Email:** drichards@cfafs.com

---

**© 2025 Cooperative Finance Association**  
*Internal use only. FORBIDDEN to share with external parties.* 