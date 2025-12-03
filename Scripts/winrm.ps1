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

$LogFile = Join-Path $LogFolder "WinRM_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-LogEntry {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Type] $Message"
    Add-Content -Path $LogFile -Value $logEntry -Encoding UTF8
}

try {
    Write-LogEntry "Iniciando configuración WinRM en $env:COMPUTERNAME" "INFO"
    
    Write-Host "`n[1/5] $(Get-String $Strings 'WINRM_STEP_1')" -ForegroundColor Yellow
    Enable-PSRemoting -Force -SkipNetworkProfileCheck
    Write-Host "      [OK] $(Get-String $Strings 'WINRM_STEP_1_OK')" -ForegroundColor Green
    Write-LogEntry "$(Get-String $Strings 'WINRM_STEP_1_OK')" "SUCCESS"
    
    Write-Host "`n[2/5] $(Get-String $Strings 'WINRM_STEP_2')" -ForegroundColor Yellow
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
    Write-Host "      [OK] $(Get-String $Strings 'WINRM_STEP_2_OK')" -ForegroundColor Green
    Write-LogEntry "$(Get-String $Strings 'WINRM_STEP_2_OK')" "SUCCESS"
    
    Write-Host "`n[3/5] $(Get-String $Strings 'WINRM_STEP_3')" -ForegroundColor Yellow
    Set-Service WinRM -StartupType Automatic
    Write-Host "      [OK] $(Get-String $Strings 'WINRM_STEP_3_OK')" -ForegroundColor Green
    Write-LogEntry "$(Get-String $Strings 'WINRM_STEP_3_OK')" "SUCCESS"
    
    Write-Host "`n[4/5] $(Get-String $Strings 'WINRM_STEP_4')" -ForegroundColor Yellow
    Restart-Service WinRM
    Write-Host "      [OK] $(Get-String $Strings 'WINRM_STEP_4_OK')" -ForegroundColor Green
    Write-LogEntry "$(Get-String $Strings 'WINRM_STEP_4_OK')" "SUCCESS"
    
    Write-Host "`n[5/5] $(Get-String $Strings 'WINRM_STEP_5')" -ForegroundColor Yellow
    Enable-NetFirewallRule -DisplayGroup "Administracion remota de Windows" -ErrorAction SilentlyContinue
    Write-Host "      [OK] $(Get-String $Strings 'WINRM_STEP_5_OK')" -ForegroundColor Green
    Write-LogEntry "$(Get-String $Strings 'WINRM_STEP_5_OK')" "SUCCESS"
    
    Write-Host "`n=================================================================================" -ForegroundColor Cyan
    Write-Host (Get-String $Strings 'WINRM_VERIFICATION') -ForegroundColor White
    Write-Host "=================================================================================" -ForegroundColor Cyan
    
    $winrmStatus = (Get-Service WinRM).Status
    $trustedHosts = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
    
    Write-Host "$(Get-String $Strings 'WINRM_STATE'): $winrmStatus" -ForegroundColor $(if($winrmStatus -eq "Running"){"Green"}else{"Red"})
    Write-Host "$(Get-String $Strings 'WINRM_TRUSTED_HOSTS'): $trustedHosts" -ForegroundColor Green
    Write-Host "`n[OK] $(Get-String $Strings 'WINRM_COMPLETE')" -ForegroundColor Green
    Write-Host "  $(Get-String $Strings 'WINRM_SUCCESS_MSG')`n" -ForegroundColor Yellow
    
    Write-LogEntry "$(Get-String $Strings 'WINRM_COMPLETE'). Estado: $winrmStatus, Hosts confianza: $trustedHosts" "SUCCESS"
    
    Write-Host "=================================================================================" -ForegroundColor Cyan
    Write-Host "      $(Get-String $Strings 'MSG_POWERED_BY')" -ForegroundColor White
    Write-Host "=================================================================================`n" -ForegroundColor Cyan
    
    # Mensaje para volver al menú
    Write-Host (Get-String $Strings 'MSG_PRESS_KEY') -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
} catch {
    Write-Host "`n[ERROR] $_" -ForegroundColor Red
    Write-LogEntry "ERROR: $_" "ERROR"
    Write-Host "`n$(Get-String $Strings 'MSG_PRESS_KEY')" -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
