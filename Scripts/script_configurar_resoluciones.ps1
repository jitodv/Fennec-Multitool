# Parámetro para recibir strings
param (
    [Parameter(Mandatory=$false)]
    [hashtable]$Strings
)

# Importar el módulo de idiomas
. (Join-Path $PSScriptRoot "LanguageLoader.ps1")

# Si no se pasan strings, cargarlos
if (-not $Strings) {
    $currentLang = Get-ConfiguredLanguage
    $Strings = Load-LanguageStrings -Language $currentLang
}

# Verificar privilegios de administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host (Get-String $Strings 'RES_REQUIRES_ADMIN') -ForegroundColor Red
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Función para mostrar el menú de resoluciones
function Show-ResolutionMenu {
    param([hashtable]$Str)
    
    Clear-Host
    Write-Host "=================================================================================" -ForegroundColor Cyan
    Write-Host "                         $(Get-String $Str 'RES_MENU_TITLE')                                       " -ForegroundColor Cyan
    Write-Host "                    $(Get-String $Str 'RES_MENU_SUBTITLE')                              " -ForegroundColor Cyan
    Write-Host "=================================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host (Get-String $Str 'RES_MENU_SELECT') -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1. UHD (4K)      | 3840 x 2160" -ForegroundColor Green
    Write-Host "  2. QHD (2K)      | 2560 x 1440" -ForegroundColor Green
    Write-Host "  3. FHD (Full HD) | 1920 x 1080" -ForegroundColor Green
    Write-Host "  4. HD            | 1280 x 720" -ForegroundColor Green
    Write-Host "  5. SXGA          | 1280 x 1024" -ForegroundColor Green
    Write-Host "  6. SVGA          | 800 x 600" -ForegroundColor Green
    Write-Host ""
    Write-Host "  0. $(Get-String $Str 'RES_MENU_BACK')" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Cyan
}

# Función para confirmar la aplicación de resolución
function Confirm-Resolution {
    param(
        [string]$ResolutionName,
        [int]$Width,
        [int]$Height,
        [hashtable]$Str
    )
    
    Clear-Host
    Write-Host "=================================================================================" -ForegroundColor Yellow
    Write-Host "                                $(Get-String $Str 'RES_CONFIRM_TITLE')                            " -ForegroundColor Yellow
    Write-Host "=================================================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host (Get-String $Str 'RES_CONFIRM_MSG') -ForegroundColor Red
    Write-Host ""
    Write-Host "  $(Get-String $Str 'RES_CONFIRM_RESOLUTION'): $ResolutionName ($Width x $Height)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  $(Get-String $Str 'RES_CONFIRM_LOCK')" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "$(Get-String $Str 'RES_WARNING_TITLE'): $(Get-String $Str 'RES_WARNING_MSG'):" -ForegroundColor Red
    Write-Host "   - $(Get-String $Str 'RES_WARNING_1')" -ForegroundColor Red
    Write-Host "   - $(Get-String $Str 'RES_WARNING_2')" -ForegroundColor Red
    Write-Host "   - $(Get-String $Str 'RES_WARNING_3')" -ForegroundColor Red
    Write-Host "   - $(Get-String $Str 'RES_WARNING_4')" -ForegroundColor Red
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Yellow
    Write-Host ""
    $confirmation = Read-Host (Get-String $Str 'RES_CONTINUE')
    
    return ($confirmation -eq (Get-String $Str 'MSG_YES_CAPS_S') -or $confirmation -eq (Get-String $Str 'MSG_YES_LOWER_S'))
}

# Función para establecer la resolución
function Set-ScreenResolution {
    param(
        [int]$Width,
        [int]$Height,
        [string]$ResolutionName,
        [hashtable]$Str
    )
    
    Write-Host ""
    Write-Host "$(Get-String $Str 'RES_APPLYING') $ResolutionName ($Width x $Height)..." -ForegroundColor Cyan
    
    try {
        $displayConfig = Get-CimInstance -ClassName Win32_VideoController
        
        if ($null -ne $displayConfig) {
            $monitors = Get-CimInstance -ClassName Win32_DesktopMonitor
            
            if ($monitors) {
                $videoConfig = Get-CimInstance -ClassName Win32_VideoController | Select-Object -First 1
                
                $setResolution = @"
[DllImport("user32.dll")]
public static extern int EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE devMode);

[DllImport("user32.dll")]
public static extern int ChangeDisplaySettings(ref DEVMODE devMode, int flags);

public struct DEVMODE
{
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
    public string dmDeviceName;
    public short dmSpecVersion;
    public short dmDriverVersion;
    public short dmSize;
    public short dmDriverExtra;
    public int dmFields;
    public int dmPositionX;
    public int dmPositionY;
    public int dmDisplayOrientation;
    public int dmDisplayFixedOutput;
    public short dmColor;
    public short dmDuplex;
    public short dmYResolution;
    public short dmTTOption;
    public short dmCollate;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
    public string dmFormName;
    public short dmLogPixels;
    public int dmBitsPerPel;
    public int dmPelsWidth;
    public int dmPelsHeight;
    public int dmDisplayFlags;
    public int dmDisplayFrequency;
    public int dmICMMethod;
    public int dmICMIntent;
    public int dmMediaType;
    public int dmDitherType;
    public int dmReserved1;
    public int dmReserved2;
    public int dmPanningWidth;
    public int dmPanningHeight;
}

public static bool SetResolution(int width, int height)
{
    DEVMODE devMode = new DEVMODE();
    devMode.dmSize = (short)Marshal.SizeOf(devMode);
    
    if (EnumDisplaySettings(null, -1, ref devMode) == 0)
        return false;
    
    devMode.dmPelsWidth = width;
    devMode.dmPelsHeight = height;
    devMode.dmFields = 0x80000 | 0x100000;
    
    return ChangeDisplaySettings(ref devMode, 0) == 0;
}
"@
                
                Add-Type -MemberDefinition $setResolution -Name Resolution -Namespace System.Display
                $result = [System.Display.Resolution]::SetResolution($Width, $Height)
                
                if ($result) {
                    Write-Host ""
                    Write-Host "[OK] $(Get-String $Str 'RES_SUCCESS')" -ForegroundColor Green
                    Write-Host "[OK] $(Get-String $Str 'RES_LOCKED')" -ForegroundColor Green
                } else {
                    Write-Host ""
                    Write-Host "[$(Get-String $Str 'MSG_WARNING')] $(Get-String $Str 'RES_REBOOT_NEEDED')" -ForegroundColor Yellow
                }
            }
            
            $settingsPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            
            if (-not (Test-Path $settingsPath)) {
                New-Item -Path $settingsPath -Force | Out-Null
            }
            
            $resolutionString = "$($Width)x$($Height)"
            New-ItemProperty -Path $settingsPath -Name "ConfiguredResolution" -Value $resolutionString -PropertyType String -Force | Out-Null
            New-ItemProperty -Path $settingsPath -Name "ResolutionName" -Value $ResolutionName -PropertyType String -Force | Out-Null
            
            Write-Host ""
            
            # Crear carpeta de logs si no existe
            $logFolder = Join-Path $PSScriptRoot "..\logs"
            if (-not (Test-Path $logFolder)) {
                New-Item -ItemType Directory -Path $logFolder -Force | Out-Null
            }
            
            $logPath = Join-Path $logFolder "registro_resoluciones.log"
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Add-Content -Path $logPath -Value "[$timestamp] $(Get-String $Str 'RES_LOG_APPLIED'): $ResolutionName ($Width x $Height) $(Get-String $Str 'RES_LOG_BY') $env:USERNAME" -Encoding UTF8
            
            Write-Host (Get-String $Str 'MSG_PRESS_KEY') -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            
            return $true
        }
    } catch {
        Write-Host ""
        Write-Host "[ERROR] $(Get-String $Str 'RES_ERROR'): $_" -ForegroundColor Red
        Write-Host ""
        Write-Host (Get-String $Str 'MSG_PRESS_KEY') -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return $false
    }
}

# Función para bloquear cambios de resolución
function Lock-ResolutionSettings {
    param([hashtable]$Str)
    
    Write-Host (Get-String $Str 'RES_LOCKING') -ForegroundColor Cyan
    
    try {
        $regPath1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        if (-not (Test-Path $regPath1)) {
            New-Item -Path $regPath1 -Force | Out-Null
        }
        New-ItemProperty -Path $regPath1 -Name "NoDispCPL" -Value 1 -PropertyType DWORD -Force | Out-Null
        
        $regPath2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
        if (-not (Test-Path $regPath2)) {
            New-Item -Path $regPath2 -Force | Out-Null
        }
        New-ItemProperty -Path $regPath2 -Name "DisableDisplaySettings" -Value 1 -PropertyType DWORD -Force | Out-Null
        
        $regPath3 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Display"
        if (-not (Test-Path $regPath3)) {
            New-Item -Path $regPath3 -Force | Out-Null
        }
        New-ItemProperty -Path $regPath3 -Name "NoDispCPL" -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $regPath3 -Name "NoColorManagement" -Value 1 -PropertyType DWORD -Force | Out-Null
        
        $regPath4 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        if (-not (Test-Path $regPath4)) {
            New-Item -Path $regPath4 -Force | Out-Null
        }
        New-ItemProperty -Path $regPath4 -Name "NoDispCPL" -Value 1 -PropertyType DWORD -Force | Out-Null
        
        $regPath5 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Personalization"
        if (-not (Test-Path $regPath5)) {
            New-Item -Path $regPath5 -Force | Out-Null
        }
        New-ItemProperty -Path $regPath5 -Name "NoChangeDisplaySettings" -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $regPath5 -Name "NoScreenSaver" -Value 1 -PropertyType DWORD -Force | Out-Null
        
        $regPath6 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel"
        if (-not (Test-Path $regPath6)) {
            New-Item -Path $regPath6 -Force | Out-Null
        }
        New-ItemProperty -Path $regPath6 -Name "RestrictCpl" -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $regPath6 -Name "DisallowCpl" -Value "Display" -PropertyType String -Force | Out-Null
        
        $regPath7 = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
        if (Test-Path $regPath7) {
            New-ItemProperty -Path $regPath7 -Name "Restricted" -Value 1 -PropertyType DWORD -Force | Out-Null
        }
        
        $regPathUser = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Display"
        if (-not (Test-Path $regPathUser)) {
            New-Item -Path $regPathUser -Force | Out-Null
        }
        New-ItemProperty -Path $regPathUser -Name "NoDispCPL" -Value 1 -PropertyType DWORD -Force | Out-Null
        
        $displaySettingsPath = "C:\Windows\System32\DisplaySwitch.exe"
        if (Test-Path $displaySettingsPath) {
            try {
                $acl = Get-Acl $displaySettingsPath
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
                $acl.SetAccessRule($rule)
                
                $denyRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users","Modify,Execute","Deny")
                $acl.AddAccessRule($denyRule)
                
                Set-Acl -Path $displaySettingsPath -AclObject $acl
            } catch {
                Write-Host "[$(Get-String $Str 'MSG_WARNING')] $(Get-String $Str 'RES_PERM_WARNING_1')" -ForegroundColor Yellow
            }
        }
        
        $settingsApp = "C:\Windows\System32\SettingsHandlers_Display.dll"
        if (Test-Path $settingsApp) {
            try {
                Takeown /F $settingsApp /A | Out-Null
                icacls $settingsApp /grant:r "SYSTEM:(F)" /inheritance:e | Out-Null
                icacls $settingsApp /remove "Users" | Out-Null
            } catch {
                Write-Host "[$(Get-String $Str 'MSG_WARNING')] $(Get-String $Str 'RES_PERM_WARNING_2')" -ForegroundColor Yellow
            }
        }
        
        Write-Host "[OK] $(Get-String $Str 'RES_LOCK_SUCCESS')" -ForegroundColor Green
        Write-Host "[OK] $(Get-String $Str 'RES_LOCK_USERS')" -ForegroundColor Green
        Write-Host "[OK] $(Get-String $Str 'RES_REBOOT_RECOMMEND')" -ForegroundColor Yellow
        
    } catch {
        Write-Host "[ERROR] $(Get-String $Str 'RES_LOCK_ERROR'): $_" -ForegroundColor Red
    }
}

# Función para volver al menú principal
function Return-ToMainMenu {
    param([hashtable]$Str)
    
    # Simplemente salir sin mensajes adicionales
    exit
}

# Bucle principal del menú
do {
    Show-ResolutionMenu -Str $Strings
    $option = Read-Host (Get-String $Strings 'RES_SELECT_OPTION')
    
    switch ($option) {
        "1" {
            if (Confirm-Resolution -ResolutionName "UHD (4K)" -Width 3840 -Height 2160 -Str $Strings) {
                Set-ScreenResolution -Width 3840 -Height 2160 -ResolutionName "UHD (4K)" -Str $Strings
                Lock-ResolutionSettings -Str $Strings
            }
        }
        "2" {
            if (Confirm-Resolution -ResolutionName "2K (QHD)" -Width 2560 -Height 1440 -Str $Strings) {
                Set-ScreenResolution -Width 2560 -Height 1440 -ResolutionName "2K (QHD)" -Str $Strings
                Lock-ResolutionSettings -Str $Strings
            }
        }
        "3" {
            if (Confirm-Resolution -ResolutionName "Full HD (FHD)" -Width 1920 -Height 1080 -Str $Strings) {
                Set-ScreenResolution -Width 1920 -Height 1080 -ResolutionName "Full HD (FHD)" -Str $Strings
                Lock-ResolutionSettings -Str $Strings
            }
        }
        "4" {
            if (Confirm-Resolution -ResolutionName "HD" -Width 1280 -Height 720 -Str $Strings) {
                Set-ScreenResolution -Width 1280 -Height 720 -ResolutionName "HD" -Str $Strings
                Lock-ResolutionSettings -Str $Strings
            }
        }
        "5" {
            if (Confirm-Resolution -ResolutionName "SXGA" -Width 1280 -Height 1024 -Str $Strings) {
                Set-ScreenResolution -Width 1280 -Height 1024 -ResolutionName "SXGA" -Str $Strings
                Lock-ResolutionSettings -Str $Strings
            }
        }
        "6" {
            if (Confirm-Resolution -ResolutionName "SVGA" -Width 800 -Height 600 -Str $Strings) {
                Set-ScreenResolution -Width 800 -Height 600 -ResolutionName "SVGA" -Str $Strings
                Lock-ResolutionSettings -Str $Strings
            }
        }
        "0" {
            Return-ToMainMenu -Str $Strings
        }
        default {
            Write-Host "$(Get-String $Strings 'RES_INVALID_OPTION') $(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Red
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
} while ($true)
