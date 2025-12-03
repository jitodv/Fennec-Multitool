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

function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    switch ($Type) {
        "ERROR"   { Write-Host "[$timestamp] ERROR: $Message" -ForegroundColor Red }
        "SUCCESS" { Write-Host "[$timestamp] OK: $Message" -ForegroundColor Green }
        "WARNING" { Write-Host "[$timestamp] $(Get-String $Strings 'MSG_WARNING'): $Message" -ForegroundColor Yellow }
        default   { Write-Host "[$timestamp] INFO: $Message" -ForegroundColor Cyan }
    }
}

Write-Log "$(Get-String $Strings 'REMOTE_LOCAL_PC'): $env:COMPUTERNAME" "INFO"

# Solicitar hostname del equipo remoto
$formHostname = New-Object System.Windows.Forms.Form
$formHostname.Text = (Get-String $Strings 'REMOTE_DIALOG_HOSTNAME_TITLE')
$formHostname.Size = New-Object System.Drawing.Size(400,150)
$formHostname.StartPosition = "CenterScreen"
$formHostname.FormBorderStyle = "FixedDialog"
$formHostname.MaximizeBox = $false
$formHostname.MinimizeBox = $false

$labelHostname = New-Object System.Windows.Forms.Label
$labelHostname.Location = New-Object System.Drawing.Point(10,20)
$labelHostname.Size = New-Object System.Drawing.Size(380,20)
$labelHostname.Text = (Get-String $Strings 'REMOTE_DIALOG_HOSTNAME_LABEL')
$formHostname.Controls.Add($labelHostname)

$textBoxHostname = New-Object System.Windows.Forms.TextBox
$textBoxHostname.Location = New-Object System.Drawing.Point(10,45)
$textBoxHostname.Size = New-Object System.Drawing.Size(360,20)
$textBoxHostname.Text = "DESKTOP-#######"
$formHostname.Controls.Add($textBoxHostname)

$buttonHostnameOK = New-Object System.Windows.Forms.Button
$buttonHostnameOK.Location = New-Object System.Drawing.Point(100,80)
$buttonHostnameOK.Size = New-Object System.Drawing.Size(100,30)
$buttonHostnameOK.Text = (Get-String $Strings 'MSG_ACCEPT')
$buttonHostnameOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
$formHostname.AcceptButton = $buttonHostnameOK
$formHostname.Controls.Add($buttonHostnameOK)

$buttonHostnameCancel = New-Object System.Windows.Forms.Button
$buttonHostnameCancel.Location = New-Object System.Drawing.Point(210,80)
$buttonHostnameCancel.Size = New-Object System.Drawing.Size(100,30)
$buttonHostnameCancel.Text = (Get-String $Strings 'MSG_CANCEL')
$buttonHostnameCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$formHostname.CancelButton = $buttonHostnameCancel
$formHostname.Controls.Add($buttonHostnameCancel)

$resultHostname = $formHostname.ShowDialog()

if ($resultHostname -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrWhiteSpace($textBoxHostname.Text)) {
    Write-Log (Get-String $Strings 'MSG_CANCELLED') "WARNING"
    exit 1
}

$RemotePC = $textBoxHostname.Text.Trim()

# Solicitar nombre del archivo de fondo de escritorio
$formWallpaper = New-Object System.Windows.Forms.Form
$formWallpaper.Text = (Get-String $Strings 'REMOTE_DIALOG_WALLPAPER_TITLE')
$formWallpaper.Size = New-Object System.Drawing.Size(400,150)
$formWallpaper.StartPosition = "CenterScreen"
$formWallpaper.FormBorderStyle = "FixedDialog"
$formWallpaper.MaximizeBox = $false
$formWallpaper.MinimizeBox = $false

$labelWallpaper = New-Object System.Windows.Forms.Label
$labelWallpaper.Location = New-Object System.Drawing.Point(10,20)
$labelWallpaper.Size = New-Object System.Drawing.Size(380,20)
$labelWallpaper.Text = (Get-String $Strings 'REMOTE_DIALOG_WALLPAPER_LABEL')
$formWallpaper.Controls.Add($labelWallpaper)

$textBoxWallpaper = New-Object System.Windows.Forms.TextBox
$textBoxWallpaper.Location = New-Object System.Drawing.Point(10,45)
$textBoxWallpaper.Size = New-Object System.Drawing.Size(360,20)
$textBoxWallpaper.Text = "image.png"
$formWallpaper.Controls.Add($textBoxWallpaper)

$buttonWallpaperOK = New-Object System.Windows.Forms.Button
$buttonWallpaperOK.Location = New-Object System.Drawing.Point(100,80)
$buttonWallpaperOK.Size = New-Object System.Drawing.Size(100,30)
$buttonWallpaperOK.Text = (Get-String $Strings 'MSG_ACCEPT')
$buttonWallpaperOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
$formWallpaper.AcceptButton = $buttonWallpaperOK
$formWallpaper.Controls.Add($buttonWallpaperOK)

$buttonWallpaperCancel = New-Object System.Windows.Forms.Button
$buttonWallpaperCancel.Location = New-Object System.Drawing.Point(210,80)
$buttonWallpaperCancel.Size = New-Object System.Drawing.Size(100,30)
$buttonWallpaperCancel.Text = (Get-String $Strings 'MSG_CANCEL')
$buttonWallpaperCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$formWallpaper.CancelButton = $buttonWallpaperCancel
$formWallpaper.Controls.Add($buttonWallpaperCancel)

$resultWallpaper = $formWallpaper.ShowDialog()

if ($resultWallpaper -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrWhiteSpace($textBoxWallpaper.Text)) {
    Write-Log (Get-String $Strings 'MSG_CANCELLED') "WARNING"
    exit 1
}

$wallpaperFileName = $textBoxWallpaper.Text.Trim()

# Solicitar nombre del archivo de fondo de bloqueo
$formLockScreen = New-Object System.Windows.Forms.Form
$formLockScreen.Text = (Get-String $Strings 'REMOTE_DIALOG_LOCKSCREEN_TITLE')
$formLockScreen.Size = New-Object System.Drawing.Size(400,150)
$formLockScreen.StartPosition = "CenterScreen"
$formLockScreen.FormBorderStyle = "FixedDialog"
$formLockScreen.MaximizeBox = $false
$formLockScreen.MinimizeBox = $false

$labelLockScreen = New-Object System.Windows.Forms.Label
$labelLockScreen.Location = New-Object System.Drawing.Point(10,20)
$labelLockScreen.Size = New-Object System.Drawing.Size(380,20)
$labelLockScreen.Text = (Get-String $Strings 'REMOTE_DIALOG_LOCKSCREEN_LABEL')
$formLockScreen.Controls.Add($labelLockScreen)

$textBoxLockScreen = New-Object System.Windows.Forms.TextBox
$textBoxLockScreen.Location = New-Object System.Drawing.Point(10,45)
$textBoxLockScreen.Size = New-Object System.Drawing.Size(360,20)
$textBoxLockScreen.Text = "image.png"
$formLockScreen.Controls.Add($textBoxLockScreen)

$buttonLockScreenOK = New-Object System.Windows.Forms.Button
$buttonLockScreenOK.Location = New-Object System.Drawing.Point(100,80)
$buttonLockScreenOK.Size = New-Object System.Drawing.Size(100,30)
$buttonLockScreenOK.Text = (Get-String $Strings 'MSG_ACCEPT')
$buttonLockScreenOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
$formLockScreen.AcceptButton = $buttonLockScreenOK
$formLockScreen.Controls.Add($buttonLockScreenOK)

$buttonLockScreenCancel = New-Object System.Windows.Forms.Button
$buttonLockScreenCancel.Location = New-Object System.Drawing.Point(210,80)
$buttonLockScreenCancel.Size = New-Object System.Drawing.Size(100,30)
$buttonLockScreenCancel.Text = (Get-String $Strings 'MSG_CANCEL')
$buttonLockScreenCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$formLockScreen.CancelButton = $buttonLockScreenCancel
$formLockScreen.Controls.Add($buttonLockScreenCancel)

$resultLockScreen = $formLockScreen.ShowDialog()

if ($resultLockScreen -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrWhiteSpace($textBoxLockScreen.Text)) {
    Write-Log (Get-String $Strings 'MSG_CANCELLED') "WARNING"
    exit 1
}

$lockScreenFileName = $textBoxLockScreen.Text.Trim()

# Solicitar usuario administrador
$formUsuario = New-Object System.Windows.Forms.Form
$formUsuario.Text = (Get-String $Strings 'REMOTE_DIALOG_USER_TITLE')
$formUsuario.Size = New-Object System.Drawing.Size(400,150)
$formUsuario.StartPosition = "CenterScreen"
$formUsuario.FormBorderStyle = "FixedDialog"
$formUsuario.MaximizeBox = $false
$formUsuario.MinimizeBox = $false

$labelUsuario = New-Object System.Windows.Forms.Label
$labelUsuario.Location = New-Object System.Drawing.Point(10,20)
$labelUsuario.Size = New-Object System.Drawing.Size(380,20)
$labelUsuario.Text = (Get-String $Strings 'REMOTE_DIALOG_USER_LABEL')
$formUsuario.Controls.Add($labelUsuario)

$textBoxUsuario = New-Object System.Windows.Forms.TextBox
$textBoxUsuario.Location = New-Object System.Drawing.Point(10,45)
$textBoxUsuario.Size = New-Object System.Drawing.Size(360,20)
$textBoxUsuario.Text = "Arrels"
$formUsuario.Controls.Add($textBoxUsuario)

$buttonUsuarioOK = New-Object System.Windows.Forms.Button
$buttonUsuarioOK.Location = New-Object System.Drawing.Point(100,80)
$buttonUsuarioOK.Size = New-Object System.Drawing.Size(100,30)
$buttonUsuarioOK.Text = (Get-String $Strings 'MSG_ACCEPT')
$buttonUsuarioOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
$formUsuario.AcceptButton = $buttonUsuarioOK
$formUsuario.Controls.Add($buttonUsuarioOK)

$buttonUsuarioCancel = New-Object System.Windows.Forms.Button
$buttonUsuarioCancel.Location = New-Object System.Drawing.Point(210,80)
$buttonUsuarioCancel.Size = New-Object System.Drawing.Size(100,30)
$buttonUsuarioCancel.Text = (Get-String $Strings 'MSG_CANCEL')
$buttonUsuarioCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$formUsuario.CancelButton = $buttonUsuarioCancel
$formUsuario.Controls.Add($buttonUsuarioCancel)

$resultUsuario = $formUsuario.ShowDialog()

if ($resultUsuario -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrWhiteSpace($textBoxUsuario.Text)) {
    Write-Log (Get-String $Strings 'MSG_CANCELLED') "WARNING"
    exit 1
}

$Usuario = $textBoxUsuario.Text.Trim()

Write-Log "$(Get-String $Strings 'REMOTE_TARGET_PC'): $RemotePC" "INFO"

$scriptPath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
if (-not $scriptPath -or $scriptPath -eq "") { 
    $scriptPath = Get-Location 
}

Write-Log (Get-String $Strings 'REMOTE_VERIFY_FILES') "INFO"

$wallpaperSource = Join-Path (Join-Path $scriptPath "Images") $wallpaperFileName
$lockScreenSource = Join-Path (Join-Path $scriptPath "Images") $lockScreenFileName

if (-not (Test-Path $wallpaperSource)) {
    Write-Log "$(Get-String $Strings 'REMOTE_FILE_NOT_FOUND'): $wallpaperFileName" "ERROR"
    Write-Host "`n$(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

if (-not (Test-Path $lockScreenSource)) {
    Write-Log "$(Get-String $Strings 'REMOTE_FILE_NOT_FOUND'): $lockScreenFileName" "ERROR"
    Write-Host "`n$(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Log (Get-String $Strings 'REMOTE_FILES_VERIFIED') "SUCCESS"

Write-Log "$(Get-String $Strings 'REMOTE_CHECK_CONNECTION'): $RemotePC..." "INFO"

try {
    if (-not (Test-Connection -ComputerName $RemotePC -Count 2 -Quiet)) {
        Write-Log "$(Get-String $Strings 'REMOTE_NO_RESPONSE'): $RemotePC" "ERROR"
        Write-Host "`n$(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    Write-Log "$(Get-String $Strings 'REMOTE_PC_ACCESSIBLE'): $RemotePC" "SUCCESS"
}
catch {
    Write-Log "$(Get-String $Strings 'REMOTE_CONNECTION_ERROR'): $_" "ERROR"
    Write-Host "`n$(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Log (Get-String $Strings 'REMOTE_REQUEST_CREDENTIALS') "INFO"

try {
    $Cred = Get-Credential -UserName $Usuario -Message "$(Get-String $Strings 'REMOTE_CREDENTIAL_MESSAGE') $RemotePC"
    
    if (-not $Cred) {
        Write-Log (Get-String $Strings 'REMOTE_NO_CREDENTIALS') "ERROR"
        Write-Host "`n$(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    Write-Log (Get-String $Strings 'REMOTE_CREDENTIALS_OK') "SUCCESS"
}
catch {
    Write-Log "$(Get-String $Strings 'REMOTE_CREDENTIAL_ERROR'): $_" "ERROR"
    Write-Host "`n$(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Log "$(Get-String $Strings 'REMOTE_ESTABLISHING_SESSION'): $RemotePC..." "INFO"

try {
    $session = New-PSSession -ComputerName $RemotePC -Credential $Cred -ErrorAction Stop
    Write-Log (Get-String $Strings 'REMOTE_SESSION_OK') "SUCCESS"
}
catch {
    Write-Log "$(Get-String $Strings 'REMOTE_SESSION_ERROR'): $RemotePC" "ERROR"
    Write-Host "`n$(Get-String $Strings 'REMOTE_POSSIBLE_CAUSES'):" -ForegroundColor Yellow
    Write-Host "  - $(Get-String $Strings 'REMOTE_CAUSE_WINRM'): $RemotePC" -ForegroundColor White
    Write-Host "  - $(Get-String $Strings 'REMOTE_CAUSE_CREDENTIALS')" -ForegroundColor White
    Write-Host "  - $(Get-String $Strings 'REMOTE_CAUSE_FIREWALL')" -ForegroundColor White
    Write-Host "  - $(Get-String $Strings 'REMOTE_CAUSE_PERMISSIONS')" -ForegroundColor White
    Write-Host "`n$(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Log (Get-String $Strings 'REMOTE_PREPARE_TEMP') "INFO"

try {
    Invoke-Command -Session $session -ScriptBlock {
        if (-not (Test-Path "C:\temp")) {
            New-Item -Path "C:\temp" -ItemType Directory -Force | Out-Null
        }
    } -ErrorAction Stop
    Write-Log (Get-String $Strings 'REMOTE_TEMP_OK') "SUCCESS"
}
catch {
    Write-Log "$(Get-String $Strings 'REMOTE_TEMP_ERROR'): $_" "ERROR"
    Remove-PSSession -Session $session -ErrorAction SilentlyContinue
    Write-Host "`n$(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Log (Get-String $Strings 'REMOTE_COPY_FILES') "INFO"

try {
    Copy-Item -Path $wallpaperSource -Destination "C:\temp\$wallpaperFileName" -ToSession $session -Force -ErrorAction Stop
    Write-Log "  $wallpaperFileName $(Get-String $Strings 'REMOTE_FILE_COPIED')" "SUCCESS"
    
    Copy-Item -Path $lockScreenSource -Destination "C:\temp\$lockScreenFileName" -ToSession $session -Force -ErrorAction Stop
    Write-Log "  $lockScreenFileName $(Get-String $Strings 'REMOTE_FILE_COPIED')" "SUCCESS"
}
catch {
    Write-Log "$(Get-String $Strings 'REMOTE_COPY_ERROR'): $_" "ERROR"
    Remove-PSSession -Session $session -ErrorAction SilentlyContinue
    Write-Host "`n$(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Log "$(Get-String $Strings 'REMOTE_EXECUTING_CONFIG'): $RemotePC..." "INFO"
Write-Log (Get-String $Strings 'REMOTE_WAIT_MESSAGE') "WARNING"

try {
    $result = Invoke-Command -Session $session -ScriptBlock {
        param($WallpaperSource, $LockScreenSource, $WallpaperFileName, $LockScreenFileName)
        
        $FondosPath = "C:\Fondos"
        $WallpaperDest = "$FondosPath\$WallpaperFileName"
        $LockScreenDest = "$FondosPath\$LockScreenFileName"
        
        if (-not (Test-Path $FondosPath)) {
            New-Item -Path $FondosPath -ItemType Directory -Force | Out-Null
        } else {
            Remove-Item "$FondosPath\*" -Force -ErrorAction SilentlyContinue
        }
        
        Copy-Item -Path $WallpaperSource -Destination $WallpaperDest -Force
        Copy-Item -Path $LockScreenSource -Destination $LockScreenDest -Force
        
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        New-ItemProperty -Path $regPath -Name "Wallpaper" -Value $WallpaperDest -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $regPath -Name "WallpaperStyle" -Value "10" -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $regPath -Name "NoChangingWallPaper" -Value 1 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path $regPath -Name "LockScreenImage" -Value $LockScreenDest -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $regPath -Name "NoChangingLockScreen" -Value 1 -PropertyType DWord -Force | Out-Null
        
        $cloudContentPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
        if (-not (Test-Path $cloudContentPath)) {
            New-Item -Path $cloudContentPath -Force | Out-Null
        }
        New-ItemProperty -Path $cloudContentPath -Name "DisableWindowsSpotlightFeatures" -Value 1 -PropertyType DWord -Force | Out-Null
        
        $defaultUserPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        if (-not (Test-Path $defaultUserPath)) {
            New-Item -Path $defaultUserPath -Force | Out-Null
        }
        New-ItemProperty -Path $defaultUserPath -Name "Wallpaper" -Value $WallpaperDest -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $defaultUserPath -Name "WallpaperStyle" -Value "10" -PropertyType String -Force | Out-Null
        
        $explorerPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        if (-not (Test-Path $explorerPath)) {
            New-Item -Path $explorerPath -Force | Out-Null
        }
        New-ItemProperty -Path $explorerPath -Name "NoThemesTab" -Value 1 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path $explorerPath -Name "SettingsPageVisibility" -Value "hide:personalization-background;personalization-colors;personalization-themes" -PropertyType String -Force | Out-Null
        
        $activeSetupPath = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{Wallpaper-Policy}"
        if (-not (Test-Path $activeSetupPath)) {
            New-Item -Path $activeSetupPath -Force | Out-Null
        }
        New-ItemProperty -Path $activeSetupPath -Name "StubPath" -Value "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop /v NoChangingWallpaper /t REG_DWORD /d 1 /f" -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $activeSetupPath -Name "Version" -Value "1,0" -PropertyType String -Force | Out-Null
        
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
        
        $gpResult = cmd /c "gpupdate /force 2>&1"
        
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Start-Process explorer.exe
        
        return "Configuracion completada exitosamente"
        
    } -ArgumentList @("C:\temp\$wallpaperFileName", "C:\temp\$lockScreenFileName", $wallpaperFileName, $lockScreenFileName) -ErrorAction Stop
    
    Write-Log (Get-String $Strings 'REMOTE_CONFIG_OK') "SUCCESS"
}
catch {
    Write-Log "$(Get-String $Strings 'REMOTE_CONFIG_ERROR'): $_" "ERROR"
    Remove-PSSession -Session $session -ErrorAction SilentlyContinue
    Write-Host "`n$(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Log (Get-String $Strings 'REMOTE_CLEANUP') "INFO"

try {
    Invoke-Command -Session $session -ScriptBlock {
        param($WallpaperFileName, $LockScreenFileName)
        Remove-Item "C:\temp\$WallpaperFileName" -Force -ErrorAction SilentlyContinue
        Remove-Item "C:\temp\$LockScreenFileName" -Force -ErrorAction SilentlyContinue
    } -ArgumentList @($wallpaperFileName, $lockScreenFileName) -ErrorAction SilentlyContinue
    Write-Log (Get-String $Strings 'REMOTE_CLEANUP_OK') "SUCCESS"
}
catch {
    Write-Log (Get-String $Strings 'REMOTE_CLEANUP_WARNING') "WARNING"
}

Write-Log (Get-String $Strings 'REMOTE_CLOSING_SESSION') "INFO"
Remove-PSSession -Session $session -ErrorAction SilentlyContinue
Write-Log (Get-String $Strings 'REMOTE_SESSION_CLOSED') "SUCCESS"

Write-Host "`n=================================================================================" -ForegroundColor Cyan
Write-Host (Get-String $Strings 'REMOTE_SUCCESS_TITLE') -ForegroundColor Green
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host "[OK] $(Get-String $Strings 'REMOTE_SUCCESS_PC'): $RemotePC" -ForegroundColor Green
Write-Host "[OK] $(Get-String $Strings 'REMOTE_SUCCESS_MSG')" -ForegroundColor Green
Write-Host "`n$(Get-String $Strings 'MSG_IMPORTANT'):" -ForegroundColor Yellow
Write-Host "  - $(Get-String $Strings 'REMOTE_IMPORTANT_LOGOUT')" -ForegroundColor White
Write-Host "  - $(Get-String $Strings 'REMOTE_IMPORTANT_LOGIN')" -ForegroundColor White
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host "      $(Get-String $Strings 'MSG_POWERED_BY')" -ForegroundColor White
Write-Host "=================================================================================`n" -ForegroundColor Cyan

# Mensaje para volver al menú
Write-Host (Get-String $Strings 'MSG_PRESS_KEY') -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

exit 0
