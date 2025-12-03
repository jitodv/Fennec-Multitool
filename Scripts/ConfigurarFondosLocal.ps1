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

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$FondosPath = "C:\Fondos"

# Crear carpeta de logs si no existe
$LogFolder = Join-Path $PSScriptRoot "..\logs"
if (-not (Test-Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
}

$LogFile = Join-Path $LogFolder "ConfigurarFondosLocal_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Type] $Message"
    
    # Guardar en archivo
    Add-Content -Path $LogFile -Value $logEntry -Encoding UTF8
    
    # Mostrar en consola
    switch ($Type) {
        "ERROR"   { Write-Host "[$timestamp] ERROR: $Message" -ForegroundColor Red }
        "SUCCESS" { Write-Host "[$timestamp] OK: $Message" -ForegroundColor Green }
        "WARNING" { Write-Host "[$timestamp] $(Get-String $Strings 'MSG_WARNING' 'AVISO'): $Message" -ForegroundColor Yellow }
        default   { Write-Host "[$timestamp] INFO: $Message" -ForegroundColor Cyan }
    }
}

Write-Log "$(Get-String $Strings 'LOCAL_COMPUTER'): $env:COMPUTERNAME" "INFO"

# Solicitar nombre del archivo de fondo de escritorio
$formWallpaper = New-Object System.Windows.Forms.Form
$formWallpaper.Text = Get-String $Strings 'LOCAL_DESKTOP_TITLE'
$formWallpaper.Size = New-Object System.Drawing.Size(400,150)
$formWallpaper.StartPosition = "CenterScreen"
$formWallpaper.FormBorderStyle = "FixedDialog"
$formWallpaper.MaximizeBox = $false
$formWallpaper.MinimizeBox = $false

$labelWallpaper = New-Object System.Windows.Forms.Label
$labelWallpaper.Location = New-Object System.Drawing.Point(10,20)
$labelWallpaper.Size = New-Object System.Drawing.Size(380,20)
$labelWallpaper.Text = Get-String $Strings 'LOCAL_DESKTOP_PROMPT'
$formWallpaper.Controls.Add($labelWallpaper)

$textBoxWallpaper = New-Object System.Windows.Forms.TextBox
$textBoxWallpaper.Location = New-Object System.Drawing.Point(10,45)
$textBoxWallpaper.Size = New-Object System.Drawing.Size(360,20)
$textBoxWallpaper.Text = "image.png"
$formWallpaper.Controls.Add($textBoxWallpaper)

$buttonWallpaperOK = New-Object System.Windows.Forms.Button
$buttonWallpaperOK.Location = New-Object System.Drawing.Point(150,80)
$buttonWallpaperOK.Size = New-Object System.Drawing.Size(100,30)
$buttonWallpaperOK.Text = Get-String $Strings 'LOCAL_BUTTON_OK'
$buttonWallpaperOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
$formWallpaper.AcceptButton = $buttonWallpaperOK
$formWallpaper.Controls.Add($buttonWallpaperOK)

$resultWallpaper = $formWallpaper.ShowDialog()

if ($resultWallpaper -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrWhiteSpace($textBoxWallpaper.Text)) {
    Write-Log (Get-String $Strings 'MSG_CANCELLED') "WARNING"
    exit 1
}

$wallpaperFileName = $textBoxWallpaper.Text.Trim()

# Solicitar nombre del archivo de fondo de bloqueo
$formLockScreen = New-Object System.Windows.Forms.Form
$formLockScreen.Text = Get-String $Strings 'LOCAL_LOCK_TITLE'
$formLockScreen.Size = New-Object System.Drawing.Size(400,150)
$formLockScreen.StartPosition = "CenterScreen"
$formLockScreen.FormBorderStyle = "FixedDialog"
$formLockScreen.MaximizeBox = $false
$formLockScreen.MinimizeBox = $false

$labelLockScreen = New-Object System.Windows.Forms.Label
$labelLockScreen.Location = New-Object System.Drawing.Point(10,20)
$labelLockScreen.Size = New-Object System.Drawing.Size(380,20)
$labelLockScreen.Text = Get-String $Strings 'LOCAL_LOCK_PROMPT'
$formLockScreen.Controls.Add($labelLockScreen)

$textBoxLockScreen = New-Object System.Windows.Forms.TextBox
$textBoxLockScreen.Location = New-Object System.Drawing.Point(10,45)
$textBoxLockScreen.Size = New-Object System.Drawing.Size(360,20)
$textBoxLockScreen.Text = "image.png"
$formLockScreen.Controls.Add($textBoxLockScreen)

$buttonLockScreenOK = New-Object System.Windows.Forms.Button
$buttonLockScreenOK.Location = New-Object System.Drawing.Point(150,80)
$buttonLockScreenOK.Size = New-Object System.Drawing.Size(100,30)
$buttonLockScreenOK.Text = Get-String $Strings 'LOCAL_BUTTON_OK'
$buttonLockScreenOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
$formLockScreen.AcceptButton = $buttonLockScreenOK
$formLockScreen.Controls.Add($buttonLockScreenOK)

$resultLockScreen = $formLockScreen.ShowDialog()

if ($resultLockScreen -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrWhiteSpace($textBoxLockScreen.Text)) {
    Write-Log (Get-String $Strings 'MSG_CANCELLED') "WARNING"
    exit 1
}

$lockScreenFileName = $textBoxLockScreen.Text.Trim()

# Configurar rutas
$scriptPath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
if (-not $scriptPath -or $scriptPath -eq "") { 
    $scriptPath = Get-Location 
}

Write-Log "Buscando imagenes en: $scriptPath" "INFO"

$WallpaperSource = Join-Path (Join-Path $scriptPath "Images") $wallpaperFileName
$LockScreenSource = Join-Path (Join-Path $scriptPath "Images") $lockScreenFileName
$WallpaperDest = "$FondosPath\$wallpaperFileName"
$LockScreenDest = "$FondosPath\$lockScreenFileName"

Write-Log "Verificando imagenes de origen..." "INFO"

if (-not (Test-Path $WallpaperSource)) {
    Write-Log "$(Get-String $Strings 'LOCAL_ERROR_IMAGE'): $WallpaperSource" "ERROR"
    Write-Log "$(Get-String $Strings 'WALLPAPER_NOTFOUND') '$wallpaperFileName'" "ERROR"
    Write-Host "`n$(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

if (-not (Test-Path $LockScreenSource)) {
    Write-Log "$(Get-String $Strings 'LOCAL_ERROR_IMAGE'): $LockScreenSource" "ERROR"
    Write-Log "$(Get-String $Strings 'WALLPAPER_NOTFOUND') '$lockScreenFileName'" "ERROR"
    Write-Host "`n$(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Log (Get-String $Strings 'MSG_SUCCESS') "SUCCESS"

Write-Log (Get-String $Strings 'LOCAL_CREATING_FOLDER')... "INFO"

try {
    if (-not (Test-Path $FondosPath)) {
        New-Item -Path $FondosPath -ItemType Directory -Force | Out-Null
        Write-Log (Get-String $Strings 'LOCAL_FOLDER_CREATED') ": $FondosPath" "SUCCESS"
    } else {
        Write-Log (Get-String $Strings 'LOCAL_FOLDER_CREATED') ", $(Get-String $Strings 'MSG_WARNING')..." "WARNING"
        Remove-Item "$FondosPath\*" -Force -ErrorAction SilentlyContinue
    }
    
    Write-Log (Get-String $Strings 'LOCAL_COPYING_DESKTOP') "INFO"
    Copy-Item -Path $WallpaperSource -Destination $WallpaperDest -Force
    Write-Log (Get-String $Strings 'LOCAL_COPYING_LOCK') "INFO"
    Copy-Item -Path $LockScreenSource -Destination $LockScreenDest -Force
    
    if ((Test-Path $WallpaperDest) -and (Test-Path $LockScreenDest)) {
        Write-Log (Get-String $Strings 'LOCAL_FILES_COPIED') "SUCCESS"
        
        $wallSize = [math]::Round((Get-Item $WallpaperDest).Length / 1KB, 2)
        $lockSize = [math]::Round((Get-Item $LockScreenDest).Length / 1KB, 2)
        Write-Log "  $(Get-String $Strings 'VERIFY_DESKTOP'): $wallSize KB" "INFO"
        Write-Log "  $(Get-String $Strings 'VERIFY_LOCK'): $lockSize KB" "INFO"
    } else {
        Write-Log (Get-String $Strings 'LOCAL_ERROR_COPY') "ERROR"
        exit 1
    }
}
catch {
    Write-Log "$(Get-String $Strings 'LOCAL_ERROR_COPY'): $_" "ERROR"
    Write-Host "`n$(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Log (Get-String $Strings 'LOCAL_CONFIGURING_DESKTOP')... "INFO"

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $regPath -Name "Wallpaper" -Value $WallpaperDest -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $regPath -Name "WallpaperStyle" -Value "10" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $regPath -Name "NoChangingWallPaper" -Value 1 -PropertyType DWord -Force | Out-Null
    
    Write-Log (Get-String $Strings 'VERIFY_CONFIGURED') "SUCCESS"
}
catch {
    Write-Log "$(Get-String $Strings 'LOCAL_ERROR_CONFIG'): $_" "ERROR"
}

Write-Log (Get-String $Strings 'LOCAL_CONFIGURING_LOCK')... "INFO"

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
    New-ItemProperty -Path $regPath -Name "LockScreenImage" -Value $LockScreenDest -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $regPath -Name "NoChangingLockScreen" -Value 1 -PropertyType DWord -Force | Out-Null
    
    try {
        $lockScreenPath = "C:\Windows\Web\Screen"
        if (-not (Test-Path $lockScreenPath)) {
            New-Item -Path $lockScreenPath -ItemType Directory -Force | Out-Null
        }
        
        $destFile = "$lockScreenPath\img100.jpg"
        if (Test-Path $destFile) {
            takeown /F $destFile /A 2>$null | Out-Null
            icacls $destFile /grant "Administradores:(F)" /T /C 2>$null | Out-Null
        }
        
        Copy-Item -Path $LockScreenDest -Destination $destFile -Force -ErrorAction Stop
        
        $lockImg = Get-Item $destFile -Force
        $lockImg.Attributes = 'Hidden, System, ReadOnly'
        
        Write-Log "Imagen de bloqueo copiada a Windows\Web\Screen" "SUCCESS"
    }
    catch {
        Write-Log "No se pudo copiar a Windows\Web\Screen (no critico): $($_.Exception.Message)" "WARNING"
    }
    
    $cloudContentPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    if (-not (Test-Path $cloudContentPath)) {
        New-Item -Path $cloudContentPath -Force | Out-Null
    }
    New-ItemProperty -Path $cloudContentPath -Name "DisableWindowsSpotlightFeatures" -Value 1 -PropertyType DWord -Force | Out-Null
    
    Write-Log (Get-String $Strings 'VERIFY_CONFIGURED') "SUCCESS"
}
catch {
    Write-Log "$(Get-String $Strings 'LOCAL_ERROR_CONFIG'): $_" "ERROR"
}

Write-Log (Get-String $Strings 'LOCAL_APPLYING_POLICIES')... "INFO"

try {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    
    [Wallpaper]::SystemParametersInfo(0x0014, 0, $WallpaperDest, 0x0001 -bor 0x0002) | Out-Null
    
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $WallpaperDest -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value "10" -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Value "0" -Force
    
    Write-Log "Fondo aplicado al usuario actual" "SUCCESS"
}
catch {
    Write-Log "Aviso: No se pudo aplicar inmediatamente (requiere reinicio de sesion): $_" "WARNING"
}

Write-Log "Aplicando configuracion a todos los usuarios..." "INFO"

try {
    $defaultUserPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    if (-not (Test-Path $defaultUserPath)) {
        New-Item -Path $defaultUserPath -Force | Out-Null
    }
    New-ItemProperty -Path $defaultUserPath -Name "Wallpaper" -Value $WallpaperDest -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $defaultUserPath -Name "WallpaperStyle" -Value "10" -PropertyType String -Force | Out-Null
    
    $userProfiles = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" | 
                    Where-Object { $_.PSChildName -match '^S-1-5-21-' }
    
    $userCount = 0
    foreach ($profile in $userProfiles) {
        try {
            $sid = $profile.PSChildName
            
            $testPath = "Registry::HKEY_USERS\$sid\Control Panel\Desktop"
            if (Test-Path $testPath) {
                Set-ItemProperty -Path $testPath -Name "Wallpaper" -Value $WallpaperDest -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $testPath -Name "WallpaperStyle" -Value "10" -Force -ErrorAction SilentlyContinue
                $userCount++
            }
        } catch {
        }
    }
    
    Write-Log "Configuracion aplicada a $userCount perfiles de usuario" "SUCCESS"
}
catch {
    Write-Log "Aviso al configurar usuarios: $_" "WARNING"
}

Write-Log "Bloqueando configuracion de personalizacion..." "INFO"

try {
    $explorerPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    if (-not (Test-Path $explorerPath)) {
        New-Item -Path $explorerPath -Force | Out-Null
    }
    New-ItemProperty -Path $explorerPath -Name "NoThemesTab" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $explorerPath -Name "NoDesktop" -Value 0 -PropertyType DWord -Force | Out-Null
    
    $settingsPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    New-ItemProperty -Path $settingsPath -Name "SettingsPageVisibility" -Value "hide:personalization-background;personalization-colors;personalization-themes" -PropertyType String -Force | Out-Null
    
    $activeSetupPath = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{Wallpaper-Policy}"
    if (-not (Test-Path $activeSetupPath)) {
        New-Item -Path $activeSetupPath -Force | Out-Null
    }
    New-ItemProperty -Path $activeSetupPath -Name "StubPath" -Value "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop /v NoChangingWallpaper /t REG_DWORD /d 1 /f" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $activeSetupPath -Name "Version" -Value "1,0" -PropertyType String -Force | Out-Null
    
    $userPolicyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
    if (-not (Test-Path $userPolicyPath)) {
        New-Item -Path $userPolicyPath -Force | Out-Null
    }
    New-ItemProperty -Path $userPolicyPath -Name "NoChangingWallpaper" -Value 1 -PropertyType DWord -Force | Out-Null
    
    $userExplorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    if (-not (Test-Path $userExplorerPath)) {
        New-Item -Path $userExplorerPath -Force | Out-Null
    }
    New-ItemProperty -Path $userExplorerPath -Name "NoThemesTab" -Value 1 -PropertyType DWord -Force | Out-Null
    
    Write-Log "Personalizacion bloqueada completamente" "SUCCESS"
}
catch {
    Write-Log "Error al bloquear personalizacion: $_" "ERROR"
}

Write-Log "Protegiendo y ocultando directorio..." "INFO"

try {
    $folder = Get-Item $FondosPath -Force
    $folder.Attributes = 'Hidden, System'
    
    Get-ChildItem -Path $FondosPath -File | ForEach-Object {
        $_.Attributes = 'Hidden, System, ReadOnly'
    }
    
    $acl = Get-Acl $FondosPath
    $acl.SetAccessRuleProtection($true, $false)
    
    $adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "Administradores", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
    )
    $acl.AddAccessRule($adminRule)
    
    $systemRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "SYSTEM", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
    )
    $acl.AddAccessRule($systemRule)
    
    $userRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "Usuarios", "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow"
    )
    $acl.AddAccessRule($userRule)
    
    Set-Acl $FondosPath $acl
    Write-Log (Get-String $Strings 'LOCAL_POLICIES_APPLIED') "SUCCESS"
}
catch {
    Write-Log "$(Get-String $Strings 'LOCAL_ERROR_CONFIG'): $_" "ERROR"
}

Write-Log (Get-String $Strings 'LOCAL_REFRESHING')... "INFO"

try {
    Start-Process -FilePath "gpupdate.exe" -ArgumentList "/force" -Wait -NoNewWindow -ErrorAction SilentlyContinue
    
    rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True
    
    $regPaths = @(
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop",
        "HKCU:\Control Panel\Desktop"
    )
    
    foreach ($path in $regPaths) {
        if (Test-Path $path) {
            [Microsoft.Win32.Registry]::LocalMachine.Flush()
            [Microsoft.Win32.Registry]::CurrentUser.Flush()
        }
    }
    
    Write-Log (Get-String $Strings 'LOCAL_POLICIES_APPLIED') "SUCCESS"
}
catch {
    Write-Log "$(Get-String $Strings 'MSG_WARNING'): $_" "WARNING"
}

Write-Log (Get-String $Strings 'LOCAL_REFRESHING')... "INFO"

try {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process explorer.exe
    Write-Log "Explorer $(Get-String $Strings 'LOCAL_COMPLETED')" "SUCCESS"
}
catch {
    Write-Log "$(Get-String $Strings 'MSG_WARNING'): $_" "WARNING"
}

Write-Host "`n=================================================================================" -ForegroundColor Cyan
Write-Host (Get-String $Strings 'LOCAL_COMPLETED').ToUpper() -ForegroundColor Green
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host "[OK] $(Get-String $Strings 'LOCAL_FOLDER_CREATED')" -ForegroundColor Green
Write-Host "[OK] $(Get-String $Strings 'LOCAL_FILES_COPIED')" -ForegroundColor Green
Write-Host "[OK] $(Get-String $Strings 'VERIFY_DESKTOP') $(Get-String $Strings 'VERIFY_CONFIGURED')" -ForegroundColor Green
Write-Host "[OK] $(Get-String $Strings 'VERIFY_LOCK') $(Get-String $Strings 'VERIFY_CONFIGURED')" -ForegroundColor Green
Write-Host "[OK] $(Get-String $Strings 'LOCAL_POLICIES_APPLIED')" -ForegroundColor Green
Write-Host "`n$(Get-String $Strings 'MSG_WARNING'):" -ForegroundColor Yellow
Write-Host "  - $(Get-String $Strings 'WALLPAPER_RESTART')" -ForegroundColor Yellow
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host "                              Powered by jitodv" -ForegroundColor DarkGray
Write-Host "=================================================================================`n" -ForegroundColor Cyan

# Mensaje para volver al menú
Write-Host (Get-String $Strings 'MSG_PRESS_KEY') -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

exit 0