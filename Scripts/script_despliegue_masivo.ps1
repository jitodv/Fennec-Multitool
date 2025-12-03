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
    param([string]$Message, [string]$Type = "INFO", [hashtable]$Str)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    switch ($Type) {
        "ERROR"   { Write-Host "[$timestamp] ERROR: $Message" -ForegroundColor Red }
        "SUCCESS" { Write-Host "[$timestamp] OK: $Message" -ForegroundColor Green }
        "WARNING" { Write-Host "[$timestamp] $(Get-String $Str 'MSG_WARNING'): $Message" -ForegroundColor Yellow }
        default   { Write-Host "[$timestamp] INFO: $Message" -ForegroundColor Cyan }
    }
}

# Solicitar IPs/Hostnames de los equipos a configurar
$formEquipos = New-Object System.Windows.Forms.Form
$formEquipos.Text = (Get-String $Strings 'MASS_DIALOG_TITLE')
$formEquipos.Size = New-Object System.Drawing.Size(500,400)
$formEquipos.StartPosition = "CenterScreen"
$formEquipos.FormBorderStyle = "FixedDialog"
$formEquipos.MaximizeBox = $false
$formEquipos.MinimizeBox = $false

$labelEquipos = New-Object System.Windows.Forms.Label
$labelEquipos.Location = New-Object System.Drawing.Point(10,10)
$labelEquipos.Size = New-Object System.Drawing.Size(470,40)
$labelEquipos.Text = (Get-String $Strings 'MASS_DIALOG_LABEL')
$formEquipos.Controls.Add($labelEquipos)

$textBoxEquipos = New-Object System.Windows.Forms.TextBox
$textBoxEquipos.Location = New-Object System.Drawing.Point(10,55)
$textBoxEquipos.Size = New-Object System.Drawing.Size(470,250)
$textBoxEquipos.Multiline = $true
$textBoxEquipos.ScrollBars = "Vertical"
$textBoxEquipos.Text = "PC-AULA01`r`nPC-AULA02`r`nPC-AULA03`r`nPC-AULA04`r`nPC-AULA05"
$formEquipos.Controls.Add($textBoxEquipos)

$buttonEquiposOK = New-Object System.Windows.Forms.Button
$buttonEquiposOK.Location = New-Object System.Drawing.Point(150,320)
$buttonEquiposOK.Size = New-Object System.Drawing.Size(100,30)
$buttonEquiposOK.Text = (Get-String $Strings 'MSG_ACCEPT')
$buttonEquiposOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
$formEquipos.AcceptButton = $buttonEquiposOK
$formEquipos.Controls.Add($buttonEquiposOK)

$buttonEquiposCancel = New-Object System.Windows.Forms.Button
$buttonEquiposCancel.Location = New-Object System.Drawing.Point(260,320)
$buttonEquiposCancel.Size = New-Object System.Drawing.Size(100,30)
$buttonEquiposCancel.Text = (Get-String $Strings 'MSG_CANCEL')
$buttonEquiposCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$formEquipos.CancelButton = $buttonEquiposCancel
$formEquipos.Controls.Add($buttonEquiposCancel)

$resultEquipos = $formEquipos.ShowDialog()

if ($resultEquipos -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrWhiteSpace($textBoxEquipos.Text)) {
    Write-Log (Get-String $Strings 'MSG_CANCELLED') "WARNING" -Str $Strings
    exit 1
}

# Procesar la lista de equipos (dividir por líneas y eliminar espacios)
$Equipos = $textBoxEquipos.Text -split "`r`n|`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

if ($Equipos.Count -eq 0) {
    Write-Host "`n$(Get-String $Strings 'MASS_NO_COMPUTERS')" -ForegroundColor Red
    exit 1
}

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
$buttonWallpaperOK.Location = New-Object System.Drawing.Point(150,80)
$buttonWallpaperOK.Size = New-Object System.Drawing.Size(100,30)
$buttonWallpaperOK.Text = (Get-String $Strings 'MSG_ACCEPT')
$buttonWallpaperOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
$formWallpaper.AcceptButton = $buttonWallpaperOK
$formWallpaper.Controls.Add($buttonWallpaperOK)

$resultWallpaper = $formWallpaper.ShowDialog()

if ($resultWallpaper -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrWhiteSpace($textBoxWallpaper.Text)) {
    Write-Log (Get-String $Strings 'MSG_CANCELLED') "WARNING" -Str $Strings
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
$buttonLockScreenOK.Location = New-Object System.Drawing.Point(150,80)
$buttonLockScreenOK.Size = New-Object System.Drawing.Size(100,30)
$buttonLockScreenOK.Text = (Get-String $Strings 'MSG_ACCEPT')
$buttonLockScreenOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
$formLockScreen.AcceptButton = $buttonLockScreenOK
$formLockScreen.Controls.Add($buttonLockScreenOK)

$resultLockScreen = $formLockScreen.ShowDialog()

if ($resultLockScreen -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrWhiteSpace($textBoxLockScreen.Text)) {
    Write-Log (Get-String $Strings 'MSG_CANCELLED') "WARNING" -Str $Strings
    exit 1
}

$lockScreenFileName = $textBoxLockScreen.Text.Trim()

Write-Host "`n$(Get-String $Strings 'MASS_TOTAL_PCS'): $($Equipos.Count)" -ForegroundColor White

$scriptPath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
if (-not $scriptPath -or $scriptPath -eq "") { 
    $scriptPath = Get-Location 
}

Write-Log (Get-String $Strings 'REMOTE_VERIFY_FILES') "INFO" -Str $Strings

$wallpaperSource = Join-Path (Join-Path $scriptPath "Images") $wallpaperFileName
$lockScreenSource = Join-Path (Join-Path $scriptPath "Images") $lockScreenFileName

$archivosOK = $true

if (-not (Test-Path $wallpaperSource)) {
    Write-Log "$(Get-String $Strings 'REMOTE_FILE_NOT_FOUND'): $wallpaperFileName" "ERROR" -Str $Strings
    $archivosOK = $false
}

if (-not (Test-Path $lockScreenSource)) {
    Write-Log "$(Get-String $Strings 'REMOTE_FILE_NOT_FOUND'): $lockScreenFileName" "ERROR" -Str $Strings
    $archivosOK = $false
}

if (-not $archivosOK) {
    Write-Host "`n$(Get-String $Strings 'MASS_ENSURE_IMAGES')`n" -ForegroundColor Yellow
    Write-Host (Get-String $Strings 'MSG_PRESS_KEY') -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Log (Get-String $Strings 'REMOTE_FILES_VERIFIED') "SUCCESS" -Str $Strings

$Exitosos = 0
$Fallidos = 0
$NoDisponibles = 0
$ResultadosDetallados = @()

foreach ($PC in $Equipos) {
    Write-Host "`n=================================================================================" -ForegroundColor Cyan
    Write-Host "$(Get-String $Strings 'MASS_PROCESSING'): $PC" -ForegroundColor White
    Write-Host "=================================================================================" -ForegroundColor Cyan
    
    $resultado = [PSCustomObject]@{
        Equipo = $PC
        Estado = ""
        Detalles = ""
        Duracion = ""
    }
    
    $tiempoInicio = Get-Date
    
    # Solicitar credenciales para este PC
    Write-Host "`n$(Get-String $Strings 'MASS_REQUEST_CREDENTIALS_FOR'): $PC" -ForegroundColor Yellow
    
    try {
        $Cred = Get-Credential -Message "$(Get-String $Strings 'MASS_CREDENTIAL_MSG') $PC"
        
        if (-not $Cred) {
            Write-Log "$(Get-String $Strings 'REMOTE_NO_CREDENTIALS') - $PC" "WARNING" -Str $Strings
            $resultado.Estado = (Get-String $Strings 'MSG_CANCELLED')
            $resultado.Detalles = (Get-String $Strings 'MASS_CREDENTIALS_CANCELLED')
            $resultado.Duracion = "0s"
            $Fallidos++
            $ResultadosDetallados += $resultado
            continue
        }
    }
    catch {
        Write-Log "$(Get-String $Strings 'REMOTE_CREDENTIAL_ERROR'): $_" "ERROR" -Str $Strings
        $resultado.Estado = "ERROR"
        $resultado.Detalles = (Get-String $Strings 'MASS_CREDENTIALS_ERROR')
        $resultado.Duracion = "0s"
        $Fallidos++
        $ResultadosDetallados += $resultado
        continue
    }
    
    try {
        Write-Log (Get-String $Strings 'REMOTE_CHECK_CONNECTION') "INFO" -Str $Strings
        if (-not (Test-Connection -ComputerName $PC -Count 1 -Quiet)) {
            Write-Log (Get-String $Strings 'MASS_NO_RESPONSE') "ERROR" -Str $Strings
            $resultado.Estado = (Get-String $Strings 'VERIFY_STATUS_OFFLINE')
            $resultado.Detalles = (Get-String $Strings 'MASS_PC_OFF_OR_NO_NET')
            $resultado.Duracion = "0s"
            $NoDisponibles++
            $ResultadosDetallados += $resultado
            continue
        }
        Write-Log (Get-String $Strings 'MASS_PC_OK') "SUCCESS" -Str $Strings
        
        Write-Log (Get-String $Strings 'MASS_CONNECTING') "INFO" -Str $Strings
        $session = New-PSSession -ComputerName $PC -Credential $Cred -ErrorAction Stop
        Write-Log (Get-String $Strings 'REMOTE_SESSION_OK') "SUCCESS" -Str $Strings
        
        Write-Log (Get-String $Strings 'REMOTE_PREPARE_TEMP') "INFO" -Str $Strings
        Invoke-Command -Session $session -ScriptBlock {
            if (-not (Test-Path "C:\temp")) {
                New-Item -Path "C:\temp" -ItemType Directory -Force | Out-Null
            }
        } -ErrorAction Stop
        
        Write-Log (Get-String $Strings 'REMOTE_COPY_FILES') "INFO" -Str $Strings
        Copy-Item -Path $wallpaperSource -Destination "C:\temp\$wallpaperFileName" -ToSession $session -Force -ErrorAction Stop
        Copy-Item -Path $lockScreenSource -Destination "C:\temp\$lockScreenFileName" -ToSession $session -Force -ErrorAction Stop
        Write-Log (Get-String $Strings 'MASS_FILES_COPIED') "SUCCESS" -Str $Strings
        
        Write-Log (Get-String $Strings 'MASS_APPLYING_CONFIG') "WARNING" -Str $Strings
        
        $configResult = Invoke-Command -Session $session -ScriptBlock {
            param($WallpaperSource, $LockScreenSource, $WallpaperFileName, $LockScreenFileName)
            
            try {
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
                
                $userProfiles = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" | 
                                Where-Object { $_.PSChildName -match '^S-1-5-21-' }
                
                foreach ($profile in $userProfiles) {
                    try {
                        $sid = $profile.PSChildName
                        $testPath = "Registry::HKEY_USERS\$sid\Control Panel\Desktop"
                        if (Test-Path $testPath) {
                            Set-ItemProperty -Path $testPath -Name "Wallpaper" -Value $WallpaperDest -Force -ErrorAction SilentlyContinue
                            Set-ItemProperty -Path $testPath -Name "WallpaperStyle" -Value "10" -Force -ErrorAction SilentlyContinue
                        }
                    } catch {}
                }
                
                $explorerPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
                if (-not (Test-Path $explorerPath)) {
                    New-Item -Path $explorerPath -Force | Out-Null
                }
                New-ItemProperty -Path $explorerPath -Name "NoThemesTab" -Value 1 -PropertyType DWord -Force | Out-Null
                New-ItemProperty -Path $explorerPath -Name "NoDesktop" -Value 0 -PropertyType DWord -Force | Out-Null
                New-ItemProperty -Path $explorerPath -Name "SettingsPageVisibility" -Value "hide:personalization-background;personalization-colors;personalization-themes" -PropertyType String -Force | Out-Null
                
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
                
                return "OK"
                
            } catch {
                return "ERROR: $_"
            }
            
        } -ArgumentList @("C:\temp\$wallpaperFileName", "C:\temp\$lockScreenFileName", $wallpaperFileName, $lockScreenFileName) -ErrorAction Stop
        
        Invoke-Command -Session $session -ScriptBlock {
            param($WallpaperFileName, $LockScreenFileName)
            Remove-Item "C:\temp\$WallpaperFileName" -Force -ErrorAction SilentlyContinue
            Remove-Item "C:\temp\$LockScreenFileName" -Force -ErrorAction SilentlyContinue
        } -ArgumentList @($wallpaperFileName, $lockScreenFileName) -ErrorAction SilentlyContinue
        
        Remove-PSSession -Session $session
        
        $tiempoFin = Get-Date
        $duracion = [math]::Round(($tiempoFin - $tiempoInicio).TotalSeconds, 1)
        
        if ($configResult -eq "OK") {
            Write-Log (Get-String $Strings 'REMOTE_CONFIG_OK') "SUCCESS" -Str $Strings
            $resultado.Estado = (Get-String $Strings 'MASS_STATUS_SUCCESS')
            $resultado.Detalles = (Get-String $Strings 'MASS_DETAILS_SUCCESS')
            $resultado.Duracion = "${duracion}s"
            $Exitosos++
        } else {
            Write-Log "$(Get-String $Strings 'MASS_CONFIG_ERROR'): $configResult" "ERROR" -Str $Strings
            $resultado.Estado = (Get-String $Strings 'MASS_STATUS_FAILED')
            $resultado.Detalles = $configResult
            $resultado.Duracion = "${duracion}s"
            $Fallidos++
        }
        
    } catch {
        $tiempoFin = Get-Date
        $duracion = [math]::Round(($tiempoFin - $tiempoInicio).TotalSeconds, 1)
        
        Write-Log "$(Get-String $Strings 'MSG_ERROR'): $($_.Exception.Message)" "ERROR" -Str $Strings
        
        $resultado.Estado = (Get-String $Strings 'MASS_STATUS_FAILED')
        $resultado.Detalles = $_.Exception.Message
        $resultado.Duracion = "${duracion}s"
        $Fallidos++
        
        if ($session) {
            Remove-PSSession -Session $session -ErrorAction SilentlyContinue
        }
    }
    
    $ResultadosDetallados += $resultado
    Start-Sleep -Seconds 1
}

Write-Host "`n`n=================================================================================" -ForegroundColor Cyan
Write-Host (Get-String $Strings 'MASS_SUMMARY') -ForegroundColor White
Write-Host "=================================================================================" -ForegroundColor Cyan

Write-Host "`n$(Get-String $Strings 'MASS_STATS'):" -ForegroundColor White
Write-Host "  $(Get-String $Strings 'MASS_TOTAL_PCS'): $($Equipos.Count)" -ForegroundColor White
Write-Host "  $(Get-String $Strings 'MASS_SUCCESS_COUNT'): $Exitosos" -ForegroundColor Green
Write-Host "  $(Get-String $Strings 'MASS_FAILED_COUNT'): $Fallidos" -ForegroundColor Red
Write-Host "  $(Get-String $Strings 'MASS_UNAVAILABLE_COUNT'): $NoDisponibles" -ForegroundColor Yellow

Write-Host "`n$(Get-String $Strings 'MASS_DETAIL_PER_PC'):" -ForegroundColor White
$ResultadosDetallados | Format-Table -AutoSize

if ($Fallidos -gt 0) {
    Write-Host "`n$(Get-String $Strings 'MASS_PCS_WITH_ERRORS'):" -ForegroundColor Red
    $ResultadosDetallados | Where-Object { $_.Estado -eq (Get-String $Strings 'MASS_STATUS_FAILED') } | Format-Table -AutoSize
    
    Write-Host "$(Get-String $Strings 'MASS_CHECK_MANUALLY')`n" -ForegroundColor Yellow
}

if ($NoDisponibles -gt 0) {
    Write-Host "$(Get-String $Strings 'MASS_PCS_UNAVAILABLE'):" -ForegroundColor Yellow
    $ResultadosDetallados | Where-Object { $_.Estado -eq (Get-String $Strings 'VERIFY_STATUS_OFFLINE') } | 
        Select-Object Equipo | Format-Table -AutoSize
    
    Write-Host "$(Get-String $Strings 'MASS_TURN_ON_AND_RETRY')`n" -ForegroundColor Yellow
}

if ($Exitosos -eq $Equipos.Count) {
    Write-Host "`n$(Get-String $Strings 'MASS_100_SUCCESS')" -ForegroundColor Green
} elseif ($Exitosos -gt 0) {
    Write-Host "`n$(Get-String $Strings 'MASS_PARTIAL_SUCCESS')" -ForegroundColor Yellow
} else {
    Write-Host "`n$(Get-String $Strings 'MASS_NO_SUCCESS')" -ForegroundColor Red
}

Write-Host "`n$(Get-String $Strings 'MSG_IMPORTANT'):" -ForegroundColor Yellow
Write-Host "  - $(Get-String $Strings 'REMOTE_IMPORTANT_LOGOUT')" -ForegroundColor White
Write-Host "  - $(Get-String $Strings 'REMOTE_IMPORTANT_LOGIN')`n" -ForegroundColor White

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFileName = "$(Get-String $Strings 'LOG_MASS_DEPLOYMENT')_$timestamp.txt"
$reportPath = ".\logs\$logFileName"

$ResultadosDetallados | Out-File -FilePath $reportPath
Write-Host "$(Get-String $Strings 'MASS_REPORT_SAVED'): $reportPath" -ForegroundColor Cyan

Write-Host "`n=================================================================================" -ForegroundColor Cyan
Write-Host "      $(Get-String $Strings 'MSG_POWERED_BY')" -ForegroundColor White
Write-Host "=================================================================================`n" -ForegroundColor Cyan

# Mensaje para volver al menú
Write-Host (Get-String $Strings 'MSG_PRESS_KEY') -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

exit 0
