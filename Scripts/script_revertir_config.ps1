#Requires -RunAsAdministrator

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

# Crear carpeta de logs si no existe
$LogFolder = Join-Path $PSScriptRoot "..\logs"
if (-not (Test-Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$logFileName = "$(Get-String $Strings 'LOG_REVERT_CONFIG')_$timestamp.log"
$LogFile = Join-Path $LogFolder $logFileName

function Write-LogEntry {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Type] $Message"
    Add-Content -Path $LogFile -Value $logEntry -Encoding UTF8
}

Write-LogEntry "Iniciando reversión de configuración de fondos en $env:COMPUTERNAME" "INFO"

# Mostrar menú de opciones
Clear-Host
Write-Host "`n=================================================================================" -ForegroundColor Cyan
Write-Host "                    $(Get-String $Strings 'REVERT_MENU_TITLE')" -ForegroundColor Yellow
Write-Host "=================================================================================`n" -ForegroundColor Cyan

Write-Host "$(Get-String $Strings 'REVERT_MENU_WARNING1')" -ForegroundColor Yellow
Write-Host "$(Get-String $Strings 'REVERT_MENU_WARNING2')`n" -ForegroundColor Yellow

Write-Host "$(Get-String $Strings 'REVERT_MENU_QUESTION')" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. $(Get-String $Strings 'REVERT_MENU_OPTION_1')" -ForegroundColor Green
Write-Host "  2. $(Get-String $Strings 'REVERT_MENU_OPTION_2')" -ForegroundColor Green
Write-Host "  3. $(Get-String $Strings 'REVERT_MENU_OPTION_3')" -ForegroundColor Green
Write-Host ""
Write-Host "  0. $(Get-String $Strings 'REVERT_MENU_BACK')" -ForegroundColor Magenta
Write-Host ""
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host ""

$opcion = Read-Host (Get-String $Strings 'REVERT_MENU_SELECT')

# Validar opción
if ($opcion -eq "0") {
    Write-Host "`n$(Get-String $Strings 'MSG_CANCELLED').`n" -ForegroundColor Yellow
    Write-LogEntry "Reversión cancelada por el usuario - Opción 0" "WARNING"
    Write-Host (Get-String $Strings 'MSG_PRESS_KEY') -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

if ($opcion -ne "1" -and $opcion -ne "2" -and $opcion -ne "3") {
    Write-Host "`n$(Get-String $Strings 'RES_INVALID_OPTION')" -ForegroundColor Red
    Write-Host "$(Get-String $Strings 'MSG_CANCELLED').`n" -ForegroundColor Yellow
    Write-LogEntry "Reversión cancelada - Opción inválida: $opcion" "WARNING"
    Write-Host (Get-String $Strings 'MSG_PRESS_KEY') -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

# Variables para controlar qué se va a revertir
$revertWallpaper = $false
$revertResolution = $false

# Procesar según opción seleccionada
Write-Host ""
switch ($opcion) {
    "1" {
        # Solo fondos
        Write-Host "$(Get-String $Strings 'REVERT_CONFIRM_WALLPAPER_MSG')" -ForegroundColor Yellow
        $confirmacion = Read-Host (Get-String $Strings 'REVERT_CONFIRM')
        $confirmacion = $confirmacion.Trim().ToUpper()
        
        if ($confirmacion -eq "S" -or $confirmacion -eq "SI" -or $confirmacion -eq "Y" -or $confirmacion -eq "YES") {
            $revertWallpaper = $true
            Write-LogEntry "Usuario confirmó revertir configuración de fondos" "INFO"
        } else {
            Write-Host "`n$(Get-String $Strings 'MSG_CANCELLED').`n" -ForegroundColor Yellow
            Write-LogEntry "Reversión de fondos cancelada por el usuario" "WARNING"
            Write-Host (Get-String $Strings 'MSG_PRESS_KEY') -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 0
        }
    }
    "2" {
        # Solo resoluciones
        Write-Host "$(Get-String $Strings 'REVERT_CONFIRM_RESOLUTION_MSG')" -ForegroundColor Yellow
        $confirmacion = Read-Host (Get-String $Strings 'REVERT_CONFIRM')
        $confirmacion = $confirmacion.Trim().ToUpper()
        
        if ($confirmacion -eq "S" -or $confirmacion -eq "SI" -or $confirmacion -eq "Y" -or $confirmacion -eq "YES") {
            $revertResolution = $true
            Write-LogEntry "Usuario confirmó revertir configuración de resolución" "INFO"
        } else {
            Write-Host "`n$(Get-String $Strings 'MSG_CANCELLED').`n" -ForegroundColor Yellow
            Write-LogEntry "Reversión de resolución cancelada por el usuario" "WARNING"
            Write-Host (Get-String $Strings 'MSG_PRESS_KEY') -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 0
        }
    }
    "3" {
        # Ambas - Preguntar por fondos primero
        Write-Host "$(Get-String $Strings 'REVERT_CONFIRM_WALLPAPER_MSG')" -ForegroundColor Yellow
        $confirmacionFondos = Read-Host (Get-String $Strings 'REVERT_CONFIRM')
        $confirmacionFondos = $confirmacionFondos.Trim().ToUpper()
        
        if ($confirmacionFondos -eq "S" -or $confirmacionFondos -eq "SI" -or $confirmacionFondos -eq "Y" -or $confirmacionFondos -eq "YES") {
            $revertWallpaper = $true
            Write-LogEntry "Usuario confirmó revertir configuración de fondos" "INFO"
        } else {
            Write-LogEntry "Usuario rechazó revertir configuración de fondos" "INFO"
        }
        
        # Preguntar por resoluciones
        Write-Host ""
        Write-Host "$(Get-String $Strings 'REVERT_CONFIRM_RESOLUTION_MSG')" -ForegroundColor Yellow
        $confirmacionRes = Read-Host (Get-String $Strings 'REVERT_CONFIRM')
        $confirmacionRes = $confirmacionRes.Trim().ToUpper()
        
        if ($confirmacionRes -eq "S" -or $confirmacionRes -eq "SI" -or $confirmacionRes -eq "Y" -or $confirmacionRes -eq "YES") {
            $revertResolution = $true
            Write-LogEntry "Usuario confirmó revertir configuración de resolución" "INFO"
        } else {
            Write-LogEntry "Usuario rechazó revertir configuración de resolución" "INFO"
        }
        
        # Si no seleccionó ninguna de las dos, cancelar
        if (-not $revertWallpaper -and -not $revertResolution) {
            Write-Host "`n$(Get-String $Strings 'REVERT_NOTHING_SELECTED')" -ForegroundColor Yellow
            Write-Host "$(Get-String $Strings 'MSG_CANCELLED').`n" -ForegroundColor Yellow
            Write-LogEntry "Reversión cancelada - Usuario rechazó ambas opciones" "WARNING"
            Write-Host (Get-String $Strings 'MSG_PRESS_KEY') -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 0
        }
    }
}

$errores = 0
$exitosos = 0

# Solo ejecutar reversión de fondos si el usuario lo eligió
if ($revertWallpaper) {
    Write-Host "`n=================================================================================" -ForegroundColor Cyan
    Write-Host (Get-String $Strings 'REVERT_STARTING') -ForegroundColor White
    Write-Host "=================================================================================`n" -ForegroundColor Cyan

Write-Host "[1/15] $(Get-String $Strings 'REVERT_STEP_1')..." -ForegroundColor Yellow

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
    if (Test-Path $regPath) {
        Remove-Item -Path $regPath -Recurse -Force
        Write-Host "       [OK] $(Get-String $Strings 'REVERT_STEP_1_OK')" -ForegroundColor Green
        Write-LogEntry "Paso 1: $(Get-String $Strings \'REVERT_STEP_1_OK\')" "SUCCESS"
        Write-LogEntry "Paso 1: $(Get-String $Strings 'REVERT_STEP_1_OK')" "SUCCESS"
        $exitosos++
    } else {
        Write-Host "       [INFO] $(Get-String $Strings 'REVERT_STEP_1_INFO')" -ForegroundColor Gray
        Write-LogEntry "Paso 1: $(Get-String $Strings \'REVERT_STEP_1_INFO\')" "INFO"
        Write-LogEntry "Paso 1: $(Get-String $Strings 'REVERT_STEP_1_INFO')" "INFO"
    }
} catch {
    Write-Host "       [ERROR] $_" -ForegroundColor Red
    Write-LogEntry "Paso 1: ERROR - $_" "ERROR"
    $errores++
}

Write-Host "`n[2/15] $(Get-String $Strings 'REVERT_STEP_2')..." -ForegroundColor Yellow

try {
    $userPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
    if (Test-Path $userPath) {
        Remove-Item -Path $userPath -Recurse -Force
        Write-Host "       [OK] $(Get-String $Strings 'REVERT_STEP_2_OK')" -ForegroundColor Green
        Write-LogEntry "Paso 2: $(Get-String $Strings \'REVERT_STEP_2_OK\')" "SUCCESS"
        Write-LogEntry "Paso 2: $(Get-String $Strings 'REVERT_STEP_2_OK')" "SUCCESS"
        $exitosos++
    } else {
        Write-Host "       [INFO] $(Get-String $Strings 'REVERT_STEP_2_INFO')" -ForegroundColor Gray
        Write-LogEntry "Paso 2: $(Get-String $Strings \'REVERT_STEP_2_INFO\')" "INFO"
        Write-LogEntry "Paso 2: $(Get-String $Strings 'REVERT_STEP_2_INFO')" "INFO"
    }
} catch {
    Write-Host "       [ERROR] $_" -ForegroundColor Red
    Write-LogEntry "Paso 2: ERROR - $_" "ERROR"
    $errores++
}

Write-Host "`n[3/15] $(Get-String $Strings 'REVERT_STEP_3')..." -ForegroundColor Yellow

try {
    $explorerPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    if (Test-Path $explorerPath) {
        Remove-ItemProperty -Path $explorerPath -Name "SettingsPageVisibility" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $explorerPath -Name "NoThemesTab" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $explorerPath -Name "NoChangeStartMenu" -ErrorAction SilentlyContinue
        Write-Host "       [OK] $(Get-String $Strings 'REVERT_STEP_3_OK')" -ForegroundColor Green
        Write-LogEntry "Paso 3: $(Get-String $Strings \'REVERT_STEP_3_OK\')" "SUCCESS"
        Write-LogEntry "Paso 3: $(Get-String $Strings 'REVERT_STEP_3_OK')" "SUCCESS"
        $exitosos++
    }
} catch {
    Write-Host "       [ERROR] $_" -ForegroundColor Red
    Write-LogEntry "Paso 3: ERROR - $_" "ERROR"
    $errores++
}

Write-Host "`n[4/15] $(Get-String $Strings 'REVERT_STEP_4')..." -ForegroundColor Yellow

try {
    $userExplorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    if (Test-Path $userExplorerPath) {
        Remove-ItemProperty -Path $userExplorerPath -Name "NoThemesTab" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $userExplorerPath -Name "NoChangeStartMenu" -ErrorAction SilentlyContinue
        Write-Host "       [OK] $(Get-String $Strings 'REVERT_STEP_4_OK')" -ForegroundColor Green
        Write-LogEntry "Paso 4: $(Get-String $Strings \'REVERT_STEP_4_OK\')" "SUCCESS"
        $exitosos++
    }
} catch {
    Write-Host "       [ERROR] $_" -ForegroundColor Red
    Write-LogEntry "ERROR en paso de reversión: $_" "ERROR"
    $errores++
}

Write-Host "`n[5/15] $(Get-String $Strings 'REVERT_STEP_5')..." -ForegroundColor Yellow

try {
    $activeSetupPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{BlockWallpaper}",
        "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{Wallpaper-Policy}"
    )
    
    foreach ($path in $activeSetupPaths) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force
        }
    }
    Write-Host "       [OK] $(Get-String $Strings 'REVERT_STEP_5_OK')" -ForegroundColor Green
        Write-LogEntry "Paso 5: $(Get-String $Strings \'REVERT_STEP_5_OK\')" "SUCCESS"
    $exitosos++
} catch {
    Write-Host "       [ERROR] $_" -ForegroundColor Red
    Write-LogEntry "ERROR en paso de reversión: $_" "ERROR"
    $errores++
}

Write-Host "`n[6/15] $(Get-String $Strings 'REVERT_STEP_6')..." -ForegroundColor Yellow

try {
    $systemPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    if (Test-Path $systemPath) {
        Remove-ItemProperty -Path $systemPath -Name "Wallpaper" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $systemPath -Name "WallpaperStyle" -ErrorAction SilentlyContinue
        Write-Host "       [OK] $(Get-String $Strings 'REVERT_STEP_6_OK')" -ForegroundColor Green
        Write-LogEntry "Paso 6: $(Get-String $Strings \'REVERT_STEP_6_OK\')" "SUCCESS"
        $exitosos++
    }
} catch {
    Write-Host "       [ERROR] $_" -ForegroundColor Red
    Write-LogEntry "ERROR en paso de reversión: $_" "ERROR"
    $errores++
}

Write-Host "`n[7/15] $(Get-String $Strings 'REVERT_STEP_7')..." -ForegroundColor Yellow

try {
    $cloudPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    if (Test-Path $cloudPath) {
        Remove-ItemProperty -Path $cloudPath -Name "DisableWindowsSpotlightFeatures" -ErrorAction SilentlyContinue
        Write-Host "       [OK] $(Get-String $Strings 'REVERT_STEP_7_OK')" -ForegroundColor Green
        Write-LogEntry "Paso 7: $(Get-String $Strings \'REVERT_STEP_7_OK\')" "SUCCESS"
        $exitosos++
    }
} catch {
    Write-Host "       [ERROR] $_" -ForegroundColor Red
    Write-LogEntry "ERROR en paso de reversión: $_" "ERROR"
    $errores++
}

Write-Host "`n[8/15] $(Get-String $Strings 'REVERT_STEP_8')..." -ForegroundColor Yellow

try {
    Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -ErrorAction SilentlyContinue
    
    Write-Host "       [OK] $(Get-String $Strings 'REVERT_STEP_8_OK')" -ForegroundColor Green
        Write-LogEntry "Paso 8: $(Get-String $Strings \'REVERT_STEP_8_OK\')" "SUCCESS"
    $exitosos++
} catch {
    Write-Host "       [ERROR] $_" -ForegroundColor Red
    Write-LogEntry "ERROR en paso de reversión: $_" "ERROR"
    $errores++
}

Write-Host "`n[9/15] $(Get-String $Strings 'REVERT_STEP_9')..." -ForegroundColor Yellow

if (Test-Path "C:\Fondos") {
    $eliminarCarpeta = Read-Host (Get-String $Strings 'REVERT_DELETE_FOLDER')
    $eliminarCarpeta = $eliminarCarpeta.Trim().ToUpper()
    if ($eliminarCarpeta -eq "S" -or $eliminarCarpeta -eq "SI" -or $eliminarCarpeta -eq "Y" -or $eliminarCarpeta -eq "YES") {
        try {
            $folder = Get-Item "C:\Fondos" -Force
            $folder.Attributes = 'Normal'
            
            Get-ChildItem "C:\Fondos" -Force | ForEach-Object {
                $_.Attributes = 'Normal'
            }
            
            Remove-Item "C:\Fondos" -Recurse -Force
            Write-Host "       [OK] $(Get-String $Strings 'REVERT_FOLDER_DELETED')" -ForegroundColor Green
            $exitosos++
        } catch {
            Write-Host "       [ERROR] $(Get-String $Strings 'REVERT_FOLDER_ERROR'): $_" -ForegroundColor Red
            $errores++
        }
    } else {
        Write-Host "       [INFO] $(Get-String $Strings 'REVERT_FOLDER_KEPT')" -ForegroundColor Gray
    }
} else {
    Write-Host "       [INFO] $(Get-String $Strings 'REVERT_FOLDER_NOT_EXISTS')" -ForegroundColor Gray
}

Write-Host "`n[10/15] $(Get-String $Strings 'REVERT_STEP_10')..." -ForegroundColor Yellow

try {
    $lockFile = "C:\Windows\Web\Screen\img100.jpg"
    if (Test-Path $lockFile) {
        takeown /F $lockFile /A 2>$null | Out-Null
        icacls $lockFile /grant "Administradores:(F)" /T /C 2>$null | Out-Null
        
        $lockImg = Get-Item $lockFile -Force
        $lockImg.Attributes = 'Normal'
        
        Remove-Item $lockFile -Force
        Write-Host "       [OK] $(Get-String $Strings 'REVERT_STEP_10_OK')" -ForegroundColor Green
        Write-LogEntry "Paso 10: $(Get-String $Strings \'REVERT_STEP_10_OK\')" "SUCCESS"
        $exitosos++
    } else {
        Write-Host "       [INFO] $(Get-String $Strings 'REVERT_STEP_10_INFO')" -ForegroundColor Gray
        Write-LogEntry "Paso 10: $(Get-String $Strings \'REVERT_STEP_10_INFO\')" "INFO"
    }
} catch {
    Write-Host "       [$(Get-String $Strings 'MSG_WARNING')] $(Get-String $Strings 'REVERT_STEP_10_WARNING')" -ForegroundColor Yellow
}

Write-Host "`n[11/15] $(Get-String $Strings 'REVERT_STEP_11')..." -ForegroundColor Yellow

try {
    $regPath1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    if (Test-Path $regPath1) {
        Remove-ItemProperty -Path $regPath1 -Name "NoDispCPL" -Force -ErrorAction SilentlyContinue | Out-Null
        Remove-ItemProperty -Path $regPath1 -Name "NoViewContextMenu" -Force -ErrorAction SilentlyContinue | Out-Null
        Remove-ItemProperty -Path $regPath1 -Name "RestrictCpl" -Force -ErrorAction SilentlyContinue | Out-Null
        Remove-ItemProperty -Path $regPath1 -Name "DisallowCpl" -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    $regPath2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    if (Test-Path $regPath2) {
        Remove-ItemProperty -Path $regPath2 -Name "DisableDisplaySettings" -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    $regPath3 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Display"
    if (Test-Path $regPath3) {
        Remove-ItemProperty -Path $regPath3 -Name "NoDispCPL" -Force -ErrorAction SilentlyContinue | Out-Null
        Remove-ItemProperty -Path $regPath3 -Name "NoColorManagement" -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    $regPath4 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    if (Test-Path $regPath4) {
        Remove-ItemProperty -Path $regPath4 -Name "NoDispCPL" -Force -ErrorAction SilentlyContinue | Out-Null
        Remove-ItemProperty -Path $regPath4 -Name "ConfiguredResolution" -Force -ErrorAction SilentlyContinue | Out-Null
        Remove-ItemProperty -Path $regPath4 -Name "ResolutionName" -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    $regPath5 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel"
    if (Test-Path $regPath5) {
        Remove-ItemProperty -Path $regPath5 -Name "RestrictCpl" -Force -ErrorAction SilentlyContinue | Out-Null
        Remove-ItemProperty -Path $regPath5 -Name "DisallowCpl" -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    $regPath6 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Personalization"
    if (Test-Path $regPath6) {
        Remove-ItemProperty -Path $regPath6 -Name "NoChangeDisplaySettings" -Force -ErrorAction SilentlyContinue | Out-Null
        Remove-ItemProperty -Path $regPath6 -Name "NoScreenSaver" -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    $regPath7 = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
    if (Test-Path $regPath7) {
        Remove-ItemProperty -Path $regPath7 -Name "Restricted" -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    $regPathUser = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Display"
    if (Test-Path $regPathUser) {
        Remove-ItemProperty -Path $regPathUser -Name "NoDispCPL" -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Host "       [OK] $(Get-String $Strings 'REVERT_STEP_11_OK')" -ForegroundColor Green
        Write-LogEntry "Paso 11: $(Get-String $Strings \'REVERT_STEP_11_OK\')" "SUCCESS"
    $exitosos++
} catch {
    Write-Host "       [ERROR] $_" -ForegroundColor Red
    Write-LogEntry "ERROR en paso de reversión: $_" "ERROR"
    $errores++
}

Write-Host "`n[12/15] $(Get-String $Strings 'REVERT_STEP_12')..." -ForegroundColor Yellow

try {
    $displaySettingsPath = "C:\Windows\System32\DisplaySwitch.exe"
    if (Test-Path $displaySettingsPath) {
        icacls $displaySettingsPath /reset /T /C | Out-Null
        Write-Host "       [OK] $(Get-String $Strings 'REVERT_STEP_12_OK')" -ForegroundColor Green
        Write-LogEntry "Paso 12: $(Get-String $Strings \'REVERT_STEP_12_OK\')" "SUCCESS"
        $exitosos++
    } else {
        Write-Host "       [INFO] $(Get-String $Strings 'REVERT_FILE_NOT_FOUND')" -ForegroundColor Gray
    }
} catch {
    Write-Host "       [$(Get-String $Strings 'MSG_WARNING')] $(Get-String $Strings 'REVERT_STEP_12_WARNING')" -ForegroundColor Yellow
}

Write-Host "`n[13/15] $(Get-String $Strings 'REVERT_STEP_13')..." -ForegroundColor Yellow

try {
    $settingsApp = "C:\Windows\System32\SettingsHandlers_Display.dll"
    if (Test-Path $settingsApp) {
        icacls $settingsApp /reset /T /C | Out-Null
        Write-Host "       [OK] $(Get-String $Strings 'REVERT_STEP_13_OK')" -ForegroundColor Green
        Write-LogEntry "Paso 13: $(Get-String $Strings \'REVERT_STEP_13_OK\')" "SUCCESS"
        $exitosos++
    } else {
        Write-Host "       [INFO] $(Get-String $Strings 'REVERT_FILE_NOT_FOUND')" -ForegroundColor Gray
    }
} catch {
    Write-Host "       [$(Get-String $Strings 'MSG_WARNING')] $(Get-String $Strings 'REVERT_STEP_13_WARNING')" -ForegroundColor Yellow
}

Write-Host "`n[14/15] $(Get-String $Strings 'REVERT_STEP_14')..." -ForegroundColor Yellow

try {
    $gpResult = cmd /c "gpupdate /force 2>&1"
    Write-Host "       [OK] $(Get-String $Strings 'REVERT_STEP_14_OK')" -ForegroundColor Green
        Write-LogEntry "Paso 14: $(Get-String $Strings \'REVERT_STEP_14_OK\')" "SUCCESS"
    $exitosos++
} catch {
    Write-Host "       [$(Get-String $Strings 'MSG_WARNING')] $(Get-String $Strings 'REVERT_STEP_14_WARNING')" -ForegroundColor Yellow
}

Write-Host "`n[15/15] $(Get-String $Strings 'REVERT_STEP_15')..." -ForegroundColor Yellow

try {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process explorer.exe
    Write-Host "       [OK] $(Get-String $Strings 'REVERT_STEP_15_OK')" -ForegroundColor Green
        Write-LogEntry "Paso 15: $(Get-String $Strings \'REVERT_STEP_15_OK\')" "SUCCESS"
    $exitosos++
} catch {
    Write-Host "       [ERROR] $_" -ForegroundColor Red
    Write-LogEntry "ERROR en paso de reversión: $_" "ERROR"
    $errores++
}

} # Fin de if ($revertWallpaper)

# Paso adicional: Revertir configuración de resolución si el usuario lo eligió
if ($revertResolution) {
    Write-Host "`n=================================================================================" -ForegroundColor Yellow
    Write-Host "$(Get-String $Strings 'REVERT_RESOLUTION_SECTION_TITLE')" -ForegroundColor Yellow
    Write-Host "=================================================================================`n" -ForegroundColor Yellow
    
    $resExitosos = 0
    $resErrores = 0
    
    # Paso 1: Eliminar políticas de bloqueo de resolución - HKLM Policies Explorer
    Write-Host "[RES-1/10] $(Get-String $Strings 'REVERT_RES_STEP_1')..." -ForegroundColor Yellow
    try {
        $regPath1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        if (Test-Path $regPath1) {
            Remove-ItemProperty -Path $regPath1 -Name "NoDispCPL" -Force -ErrorAction SilentlyContinue
            Write-Host "           [OK] $(Get-String $Strings 'REVERT_RES_STEP_1_OK')" -ForegroundColor Green
            Write-LogEntry "Paso RES-1: Eliminada política NoDispCPL de Explorer" "SUCCESS"
            $resExitosos++
        } else {
            Write-Host "           [INFO] $(Get-String $Strings 'REVERT_RES_NOT_FOUND')" -ForegroundColor Gray
        }
    } catch {
        Write-Host "           [ERROR] $_" -ForegroundColor Red
        Write-LogEntry "Paso RES-1: ERROR - $_" "ERROR"
        $resErrores++
    }
    
    # Paso 2: Eliminar políticas Windows System
    Write-Host "`n[RES-2/10] $(Get-String $Strings 'REVERT_RES_STEP_2')..." -ForegroundColor Yellow
    try {
        $regPath2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
        if (Test-Path $regPath2) {
            Remove-ItemProperty -Path $regPath2 -Name "DisableDisplaySettings" -Force -ErrorAction SilentlyContinue
            Write-Host "           [OK] $(Get-String $Strings 'REVERT_RES_STEP_2_OK')" -ForegroundColor Green
            Write-LogEntry "Paso RES-2: Eliminada política DisableDisplaySettings" "SUCCESS"
            $resExitosos++
        } else {
            Write-Host "           [INFO] $(Get-String $Strings 'REVERT_RES_NOT_FOUND')" -ForegroundColor Gray
        }
    } catch {
        Write-Host "           [ERROR] $_" -ForegroundColor Red
        Write-LogEntry "Paso RES-2: ERROR - $_" "ERROR"
        $resErrores++
    }
    
    # Paso 3: Eliminar políticas Control Panel Display (COMPLETO)
    Write-Host "`n[RES-3/10] $(Get-String $Strings 'REVERT_RES_STEP_3')..." -ForegroundColor Yellow
    try {
        $regPath3 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Display"
        if (Test-Path $regPath3) {
            Remove-Item -Path $regPath3 -Recurse -Force
            Write-Host "           [OK] $(Get-String $Strings 'REVERT_RES_STEP_3_OK')" -ForegroundColor Green
            Write-LogEntry "Paso RES-3: Eliminada carpeta completa Control Panel Display" "SUCCESS"
            $resExitosos++
        } else {
            Write-Host "           [INFO] $(Get-String $Strings 'REVERT_RES_NOT_FOUND')" -ForegroundColor Gray
        }
    } catch {
        Write-Host "           [ERROR] $_" -ForegroundColor Red
        Write-LogEntry "Paso RES-3: ERROR - $_" "ERROR"
        $resErrores++
    }
    
    # Paso 4: Eliminar políticas System NoDispCPL
    Write-Host "`n[RES-4/10] $(Get-String $Strings 'REVERT_RES_STEP_4')..." -ForegroundColor Yellow
    try {
        $regPath4 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        if (Test-Path $regPath4) {
            Remove-ItemProperty -Path $regPath4 -Name "NoDispCPL" -Force -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $regPath4 -Name "ConfiguredResolution" -Force -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $regPath4 -Name "ResolutionName" -Force -ErrorAction SilentlyContinue
            Write-Host "           [OK] $(Get-String $Strings 'REVERT_RES_STEP_4_OK')" -ForegroundColor Green
            Write-LogEntry "Paso RES-4: Eliminadas políticas de System" "SUCCESS"
            $resExitosos++
        } else {
            Write-Host "           [INFO] $(Get-String $Strings 'REVERT_RES_NOT_FOUND')" -ForegroundColor Gray
        }
    } catch {
        Write-Host "           [ERROR] $_" -ForegroundColor Red
        Write-LogEntry "Paso RES-4: ERROR - $_" "ERROR"
        $resErrores++
    }
    
    # Paso 5: Eliminar políticas Personalization
    Write-Host "`n[RES-5/10] $(Get-String $Strings 'REVERT_RES_STEP_5')..." -ForegroundColor Yellow
    try {
        $regPath5 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Personalization"
        if (Test-Path $regPath5) {
            Remove-ItemProperty -Path $regPath5 -Name "NoChangeDisplaySettings" -Force -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $regPath5 -Name "NoScreenSaver" -Force -ErrorAction SilentlyContinue
            Write-Host "           [OK] $(Get-String $Strings 'REVERT_RES_STEP_5_OK')" -ForegroundColor Green
            Write-LogEntry "Paso RES-5: Eliminadas políticas de Personalization" "SUCCESS"
            $resExitosos++
        } else {
            Write-Host "           [INFO] $(Get-String $Strings 'REVERT_RES_NOT_FOUND')" -ForegroundColor Gray
        }
    } catch {
        Write-Host "           [ERROR] $_" -ForegroundColor Red
        Write-LogEntry "Paso RES-5: ERROR - $_" "ERROR"
        $resErrores++
    }
    
    # Paso 6: Eliminar políticas Control Panel RestrictCpl
    Write-Host "`n[RES-6/10] $(Get-String $Strings 'REVERT_RES_STEP_6')..." -ForegroundColor Yellow
    try {
        $regPath6 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel"
        if (Test-Path $regPath6) {
            Remove-ItemProperty -Path $regPath6 -Name "RestrictCpl" -Force -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $regPath6 -Name "DisallowCpl" -Force -ErrorAction SilentlyContinue
            Write-Host "           [OK] $(Get-String $Strings 'REVERT_RES_STEP_6_OK')" -ForegroundColor Green
            Write-LogEntry "Paso RES-6: Eliminadas políticas RestrictCpl" "SUCCESS"
            $resExitosos++
        } else {
            Write-Host "           [INFO] $(Get-String $Strings 'REVERT_RES_NOT_FOUND')" -ForegroundColor Gray
        }
    } catch {
        Write-Host "           [ERROR] $_" -ForegroundColor Red
        Write-LogEntry "Paso RES-6: ERROR - $_" "ERROR"
        $resErrores++
    }
    
    # Paso 7: Eliminar restricción de controlador de video
    Write-Host "`n[RES-7/10] $(Get-String $Strings 'REVERT_RES_STEP_7')..." -ForegroundColor Yellow
    try {
        $regPath7 = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
        if (Test-Path $regPath7) {
            Remove-ItemProperty -Path $regPath7 -Name "Restricted" -Force -ErrorAction SilentlyContinue
            Write-Host "           [OK] $(Get-String $Strings 'REVERT_RES_STEP_7_OK')" -ForegroundColor Green
            Write-LogEntry "Paso RES-7: Eliminada restricción de controlador de video" "SUCCESS"
            $resExitosos++
        } else {
            Write-Host "           [INFO] $(Get-String $Strings 'REVERT_RES_NOT_FOUND')" -ForegroundColor Gray
        }
    } catch {
        Write-Host "           [ERROR] $_" -ForegroundColor Red
        Write-LogEntry "Paso RES-7: ERROR - $_" "ERROR"
        $resErrores++
    }
    
    # Paso 8: Eliminar políticas de usuario (HKCU)
    Write-Host "`n[RES-8/10] $(Get-String $Strings 'REVERT_RES_STEP_8')..." -ForegroundColor Yellow
    try {
        $regPathUser = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Display"
        if (Test-Path $regPathUser) {
            Remove-Item -Path $regPathUser -Recurse -Force
            Write-Host "           [OK] $(Get-String $Strings 'REVERT_RES_STEP_8_OK')" -ForegroundColor Green
            Write-LogEntry "Paso RES-8: Eliminadas políticas de usuario" "SUCCESS"
            $resExitosos++
        } else {
            Write-Host "           [INFO] $(Get-String $Strings 'REVERT_RES_NOT_FOUND')" -ForegroundColor Gray
        }
    } catch {
        Write-Host "           [ERROR] $_" -ForegroundColor Red
        Write-LogEntry "Paso RES-8: ERROR - $_" "ERROR"
        $resErrores++
    }
    
    # Paso 9: Restaurar permisos de DisplaySwitch.exe
    Write-Host "`n[RES-9/10] $(Get-String $Strings 'REVERT_RES_STEP_9')..." -ForegroundColor Yellow
    try {
        $displaySwitch = "C:\Windows\System32\DisplaySwitch.exe"
        if (Test-Path $displaySwitch) {
            icacls $displaySwitch /reset /T /C | Out-Null
            Write-Host "           [OK] $(Get-String $Strings 'REVERT_RES_STEP_9_OK')" -ForegroundColor Green
            Write-LogEntry "Paso RES-9: Permisos de DisplaySwitch.exe restaurados" "SUCCESS"
            $resExitosos++
        } else {
            Write-Host "           [INFO] $(Get-String $Strings 'REVERT_RES_FILE_NOT_FOUND')" -ForegroundColor Gray
        }
    } catch {
        Write-Host "           [$(Get-String $Strings 'MSG_WARNING')] $(Get-String $Strings 'REVERT_RES_STEP_9_WARNING')" -ForegroundColor Yellow
        Write-LogEntry "Paso RES-9: WARNING - No se pudieron restaurar permisos de DisplaySwitch.exe" "WARNING"
    }
    
    # Paso 10: Restaurar permisos de SettingsHandlers_Display.dll
    Write-Host "`n[RES-10/10] $(Get-String $Strings 'REVERT_RES_STEP_10')..." -ForegroundColor Yellow
    try {
        $settingsHandler = "C:\Windows\System32\SettingsHandlers_Display.dll"
        if (Test-Path $settingsHandler) {
            icacls $settingsHandler /reset /T /C | Out-Null
            icacls $settingsHandler /grant "Users:(RX)" | Out-Null
            Write-Host "           [OK] $(Get-String $Strings 'REVERT_RES_STEP_10_OK')" -ForegroundColor Green
            Write-LogEntry "Paso RES-10: Permisos de SettingsHandlers_Display.dll restaurados" "SUCCESS"
            $resExitosos++
        } else {
            Write-Host "           [INFO] $(Get-String $Strings 'REVERT_RES_FILE_NOT_FOUND')" -ForegroundColor Gray
        }
    } catch {
        Write-Host "           [$(Get-String $Strings 'MSG_WARNING')] $(Get-String $Strings 'REVERT_RES_STEP_10_WARNING')" -ForegroundColor Yellow
        Write-LogEntry "Paso RES-10: WARNING - No se pudieron restaurar permisos de SettingsHandlers_Display.dll" "WARNING"
    }
    
    Write-Host "`n$(Get-String $Strings 'REVERT_RES_COMPLETE')" -ForegroundColor Green
    Write-Host "$(Get-String $Strings 'REVERT_RES_SUCCESS_COUNT'): $resExitosos" -ForegroundColor Green
    Write-Host "$(Get-String $Strings 'REVERT_RES_ERROR_COUNT'): $resErrores" -ForegroundColor $(if($resErrores -gt 0){"Red"}else{"Green"})
    Write-LogEntry "Reversión de resolución completada. Exitosos: $resExitosos, Errores: $resErrores" "INFO"
    
    $exitosos += $resExitosos
    $errores += $resErrores
}

Write-Host "`n=================================================================================" -ForegroundColor Cyan
Write-Host (Get-String $Strings 'REVERT_COMPLETE') -ForegroundColor Green
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host "$(Get-String $Strings 'REVERT_SUCCESS_COUNT'): $exitosos" -ForegroundColor Green
Write-Host "$(Get-String $Strings 'REVERT_ERROR_COUNT'): $errores" -ForegroundColor $(if($errores -gt 0){"Red"}else{"Green"})

Write-LogEntry "Reversión completada. Exitosos: $exitosos, Errores: $errores" "INFO"

Write-Host "`n$(Get-String $Strings 'MSG_IMPORTANT'):" -ForegroundColor Yellow
Write-Host "  1. $(Get-String $Strings 'REVERT_INST_1')" -ForegroundColor White
Write-Host "  2. $(Get-String $Strings 'REVERT_INST_2'):" -ForegroundColor White
Write-Host "     - $(Get-String $Strings 'REVERT_INST_2A')" -ForegroundColor White
Write-Host "     - $(Get-String $Strings 'REVERT_INST_2B')" -ForegroundColor White
Write-Host "  3. $(Get-String $Strings 'REVERT_INST_3'):" -ForegroundColor White
Write-Host "     - $(Get-String $Strings 'REVERT_INST_3A')" -ForegroundColor White
Write-Host "     - $(Get-String $Strings 'REVERT_INST_3B')" -ForegroundColor White
Write-Host "  4. $(Get-String $Strings 'REVERT_INST_4')" -ForegroundColor White

Write-Host "`n$(Get-String $Strings 'REVERT_QUICK_CHECK'):" -ForegroundColor Cyan
Write-Host "  - $(Get-String $Strings 'REVERT_CHECK_POLICIES'): " -NoNewline
if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization")) {
    Write-Host (Get-String $Strings 'MSG_YES') -ForegroundColor Green
} else {
    Write-Host "$(Get-String $Strings 'MSG_NO') ($(Get-String $Strings 'REVERT_RERUN'))" -ForegroundColor Red
}

Write-Host "  - $(Get-String $Strings 'REVERT_CHECK_RESOLUTION'): " -NoNewline
if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Display")) {
    Write-Host (Get-String $Strings 'MSG_YES') -ForegroundColor Green
} else {
    Write-Host "$(Get-String $Strings 'MSG_NO') ($(Get-String $Strings 'REVERT_RERUN'))" -ForegroundColor Red
}

Write-Host "`n=================================================================================" -ForegroundColor Cyan
Write-Host "      $(Get-String $Strings 'MSG_POWERED_BY')" -ForegroundColor White
Write-Host "=================================================================================`n" -ForegroundColor Cyan

# Mensaje para volver al menú
Write-Host (Get-String $Strings 'MSG_PRESS_KEY') -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

exit 0
