================================================================================
                      FENNEC MULTITOOL beta-0.1.0
================================================================================

                            Powered by jitodv
                Wallpaper Management & Windows Configuration
                         Professional IT Solution

================================================================================
DESCRIPTION
================================================================================

Fennec Multitool is a professional solution for centralized management of 
wallpapers and system configurations in Windows environments. It allows you to 
configure, verify, and revert settings on both local and remote computers with 
full multi-language support.

KEY FEATURES:
  ✓ Desktop and lock screen wallpaper configuration
  ✓ Remote management of multiple computers (WinRM)
  ✓ Mass deployment with per-PC credentials
  ✓ Configuration verification and auditing
  ✓ Screen resolution locking/unlocking
  ✓ Complete configuration revert system
  ✓ Multi-language interface (Español, English, Català)
  ✓ Detailed reports and logs generation

================================================================================
PROGRAM STRUCTURE
================================================================================

Fennec Multitool/
│
├── Multiherramienta Fennec.bat     ← RUN THIS FILE (as Administrator)
│
├── Images/                         ← Folder with background images
│   ├── image.png                  (Example: Desktop background)
│   └── image.png                     (Example: Lock screen background)
│
├── Lang/                           ← Translation files
│   ├── es-ES.txt                       (Español - Spain)
│   ├── en-US.txt                       (English - United States)
│   └── ca-ES.txt                       (Català - Spain)
│
├── logs/                           ← Reports and logs folder
│   └── (created automatically)         (Verifications, deployments, etc.)
│
├── Scripts/                        ← All PowerShell scripts
│   ├── MenuPrincipal.ps1               (Multi-language main menu)
│   ├── LanguageLoader.ps1              (Language management engine)
│   ├── ConfigurarFondosLocal.ps1       (Local wallpaper configuration)
│   ├── script_ejecutar_remoto.ps1      (Individual remote configuration)
│   ├── script_despliegue_masivo.ps1    (Mass deployment to multiple PCs)
│   ├── script_verificar_config.ps1     (Verification and auditing)
│   ├── script_revertir_config.ps1      (Configuration revert)
│   ├── script_configurar_resoluciones.ps1  (Resolution locking)
│   └── winrm.ps1                       (WinRM configuration)
│
├── lang.config                     ← Persistent language configuration
│
└── README_en-US.txt                ← This file

================================================================================
SYSTEM REQUIREMENTS
================================================================================

• Operating System: Windows 10/11 Pro or Enterprise / Education
• PowerShell: Version 5.1 or higher
• Permissions: Administrator rights
• For remote management: WinRM enabled on target computers
• Image format: PNG (recommended)
• Network: Network connectivity for remote computers

================================================================================
DETAILED USAGE GUIDE
================================================================================

┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. QUICK START                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

   a) Double-click on "Multiherramienta Fennec"
   b) Select "Run as administrator"
   c) The program will automatically detect your system language
   d) The main menu will appear with all available options

┌─────────────────────────────────────────────────────────────────────────────┐
│ 2. PREPARE IMAGES                                                           │
└─────────────────────────────────────────────────────────────────────────────┘

   a) Place your PNG images in the "Images/" folder
   b) Recommended names:
      • image.png (Desktop background)
      • image.png (Lock screen background)
   c) You can use multiple images with custom names
   d) When running scripts, you'll be asked for the exact filename

┌─────────────────────────────────────────────────────────────────────────────┐
│ 3. PREREQUISITES - Option [1]                                               │
└─────────────────────────────────────────────────────────────────────────────┘

   ENABLE WINRM ON THIS PC
   
   • Run BEFORE any remote operations
   • Configures WinRM to allow remote management
   • Adds computers to trusted hosts list
   • Only needs to run ONCE per computer
   • Requires Administrator permissions

┌─────────────────────────────────────────────────────────────────────────────┐
│ 4. LOCAL CONFIGURATION - Option [2]                                         │
└─────────────────────────────────────────────────────────────────────────────┘

   CONFIGURE WALLPAPERS ON THIS PC
   
   • Applies wallpapers on the local computer
   • You will be asked for:
     - Desktop background filename
     - Lock screen background filename
   • Wallpapers are locked via registry policies
   • Users will NOT be able to change them afterwards
   • Requires logging out to fully apply changes

┌─────────────────────────────────────────────────────────────────────────────┐
│ 5. REMOTE CONFIGURATION - Option [3]                                        │
└─────────────────────────────────────────────────────────────────────────────┘

   CONFIGURE A REMOTE COMPUTER
   
   • Manages wallpapers on a single network computer
   • You will be asked for:
     - Hostname or IP of remote computer
     - Administrator credentials for the computer
     - Image filenames
   • Images are automatically copied to remote computer
   • Locking policies are applied remotely
   • Generates operation result report

┌─────────────────────────────────────────────────────────────────────────────┐
│ 6. MASS DEPLOYMENT - Option [4]                                             │
└─────────────────────────────────────────────────────────────────────────────┘

   CONFIGURE MULTIPLE COMPUTERS
   
   • Deploys wallpapers to multiple PCs simultaneously
   • NEW: Requests individual credentials for each PC
   • For each computer, you'll be asked:
     - User with administrator permissions
     - Password (hidden during input)
   • Fully interactive and secure process
   • Generates detailed report in "logs/" folder
   • Shows summary of successes and errors upon completion
   
   NOTE: Manual script editing is NO longer necessary

┌─────────────────────────────────────────────────────────────────────────────┐
│ 7. VERIFY CONFIGURATION - Option [5]                                        │
└─────────────────────────────────────────────────────────────────────────────┘

   COMPUTER AUDITING
   
   • Verifies which computers have wallpapers configured
   • NEW: Requests individual credentials for each PC
   • Displays ASCII table with real-time results
   • Generates CSV report in "logs/" folder
   • Verifies:
     - Existence of image files
     - Registry policy status
     - Configuration lock status
   • Perfect for audits and monitoring

┌─────────────────────────────────────────────────────────────────────────────┐
│ 8. REVERT CONFIGURATION - Option [6]                                        │
└─────────────────────────────────────────────────────────────────────────────┘

   REVERT MENU
   
   Available options:
   
   [1] Revert wallpaper configuration only
       • Removes image files
       • Removes wallpaper locking policies
       • Restores folder permissions
       • Users can change wallpapers again
   
   [2] Revert resolution configuration only
       • Removes resolution locking policies
       • Restores system file permissions
       • Allows changing resolution again
   
   [3] Revert both configurations
       • Performs complete wallpaper revert
       • Performs complete resolution revert
       • Restores system to original state
   
   [0] Return to main menu
   
   WARNING: Revert is permanent and requires confirmation

┌─────────────────────────────────────────────────────────────────────────────┐
│ 9. CONFIGURE RESOLUTIONS - Option [7]                                       │
└─────────────────────────────────────────────────────────────────────────────┘

   LOCK SCREEN RESOLUTION
   
   • Locks the current screen resolution
   • Prevents users from changing resolution
   • Applies 10 protection layers:
     - Registry policies (CurrentUser and LocalMachine)
     - System file locking (desk.cpl, etc.)
     - ACL configuration (NTFS permissions)
     - Control panel option disabling
   • Useful for corporate environments and kiosks
   • Reversible via Option [6] → [2] or [3]

┌─────────────────────────────────────────────────────────────────────────────┐
│ 10. CHANGE LANGUAGE - Option [8]                                            │
└─────────────────────────────────────────────────────────────────────────────┘

   LANGUAGE SELECTOR
   
   • Changes the entire interface language
   • Available languages:
     [1] Español (es-ES)
     [2] English (en-US)
     [3] Català (ca-ES)
   • Change is immediate
   • Saved in "lang.config" for future sessions
   • ENTIRE program (menus, messages, reports) is translated

================================================================================
REPORTS AND LOGS
================================================================================

The "logs/" folder contains all generated reports:

• Despliegue_Masivo_YYYYMMDD_HHMMSS.txt (Mass_Deployment)
  → Mass deployment result with per-computer details

• Verificacion_YYYYMMDD_HHMMSS.csv (Verification)
  → Verification report in CSV format (Excel compatible)

• Other logs automatically generated by operations

Timestamp format: Year-Month-Day_Hour-Minute-Second

================================================================================
TROUBLESHOOTING
================================================================================

PROBLEM: "Cannot run script"
SOLUTION: Run as Administrator and verify execution policy:
          Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

PROBLEM: "Cannot connect to remote computer"
SOLUTION: 
  1. Verify WinRM is enabled (Option [1])
  2. Verify network connectivity (ping the computer)
  3. Verify administrator credentials
  4. Verify firewall on target computer

PROBLEM: "Wallpapers are not applied"
SOLUTION: 
  1. Log out completely
  2. Log in again
  3. Wait 30-60 seconds
  4. If it persists, verify PNG format of images

PROBLEM: "Cannot revert configuration"
SOLUTION: Run the program as Administrator

================================================================================
IMPORTANT NOTES
================================================================================

⚠ SECURITY:
  • ALWAYS run as Administrator
  • Credentials are NOT stored in any file
  • Passwords are requested securely (hidden)
  • Scripts do NOT contain hardcoded credentials

✓ COMPATIBILITY:
  • Images: PNG recommended, JPG supported
  • Windows 10 Pro/Enterprise or higher
  • PowerShell 5.1 or higher

⚠ REMOTE REQUIREMENTS:
  • WinRM enabled on target computers
  • Administrator credentials for each computer
  • Port 5985 (HTTP) or 5986 (HTTPS) open in firewall

✓ MULTI-LANGUAGE:
  • Automatic system language detection
  • Instant switching between languages
  • All messages, menus, and reports translated
  • Persistent configuration between sessions

⚠ CHANGES:
  • Require logging out to fully apply
  • Locking policies are permanent until reverted
  • Revert removes ALL applied configurations

================================================================================
SUPPORT AND CONTACT
================================================================================

Developer: Rubén Guerrero López | @jitodv
Github: https://github.com/jitodv
Version: beta-0.1.0
Date: December 2025

To report problems or suggestions, document:
  • Program version (beta-0.1.0)
  • Operating system and version
  • Detailed problem description
  • Error messages (if any)
  • Steps to reproduce the problem

================================================================================
                              Powered by jitodv
================================================================================
