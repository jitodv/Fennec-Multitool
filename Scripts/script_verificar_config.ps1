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

$timestamp_log = Get-Date -Format 'yyyyMMdd_HHmmss'
$logFileName = "$(Get-String $Strings 'LOG_VERIFY_CONFIG')_$timestamp_log.log"
$LogFile = Join-Path $LogFolder $logFileName

function Write-LogEntry {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Type] $Message"
    Add-Content -Path $LogFile -Value $logEntry -Encoding UTF8
}

# Cargar Windows Forms para diálogos
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Write-LogEntry "Iniciando verificación de configuración de fondos" "INFO"

# Solicitar equipos mediante diálogo interactivo
Write-Host ""
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host "           $(Get-String $Strings 'VERIFY_TITLE')" -ForegroundColor Yellow
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host ""

# Crear formulario para entrada de equipos
$form = New-Object System.Windows.Forms.Form
$form.Text = Get-String $Strings 'VERIFY_TITLE'
$form.Size = New-Object System.Drawing.Size(500,400)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

# Etiqueta de instrucciones
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,10)
$label.Size = New-Object System.Drawing.Size(470,40)
$label.Text = (Get-String $Strings 'VERIFY_DIALOG_LABEL')
$form.Controls.Add($label)

# Cuadro de texto multilínea
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,55)
$textBox.Size = New-Object System.Drawing.Size(470,250)
$textBox.Multiline = $true
$textBox.ScrollBars = 'Vertical'
$textBox.Font = New-Object System.Drawing.Font("Consolas",10)
$form.Controls.Add($textBox)

# Botón OK
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(300,315)
$okButton.Size = New-Object System.Drawing.Size(80,30)
$okButton.Text = (Get-String $Strings 'MSG_ACCEPT')
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

# Botón Cancelar
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(390,315)
$cancelButton.Size = New-Object System.Drawing.Size(80,30)
$cancelButton.Text = (Get-String $Strings 'MSG_CANCEL')
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$form.Topmost = $true
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::Cancel -or [string]::IsNullOrWhiteSpace($textBox.Text)) {
    Write-Host "$(Get-String $Strings 'MSG_CANCELLED')" -ForegroundColor Yellow
    Write-LogEntry "Verificación cancelada por el usuario" "WARNING"
    Write-Host ""
    exit 0
}

# Procesar la lista de equipos
$Equipos = $textBox.Text -split "`r`n|`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Trim() }

if ($Equipos.Count -eq 0) {
    Write-Host "[ERROR] $(Get-String $Strings 'REMOTE_NO_COMPUTER')" -ForegroundColor Red
    Write-LogEntry "ERROR: No se especificaron equipos" "ERROR"
    Write-Host ""
    exit 1
}

Write-Host "$(Get-String $Strings 'VERIFY_PC_COUNT'): $($Equipos.Count)" -ForegroundColor Cyan
Write-LogEntry "Verificación iniciada para $($Equipos.Count) equipo(s): $($Equipos -join ', ')" "INFO"
Write-Host ""

$Resultados = @()

foreach ($PC in $Equipos) {
    Write-Host "$(Get-String $Strings 'VERIFY_CHECKING'): $PC..." -ForegroundColor Cyan
    
    try {
        if (-not (Test-Connection -ComputerName $PC -Count 1 -Quiet)) {
            Write-Host "  [ERROR] $(Get-String $Strings 'VERIFY_NOT_AVAILABLE')`n" -ForegroundColor Red
            Write-LogEntry "Equipo $PC no disponible (offline)" "WARNING"
            
            $Resultados += [PSCustomObject]@{
                Equipo = $PC
                Estado = (Get-String $Strings 'VERIFY_STATUS_OFFLINE')
                FondoExiste = "-"
                BloqueoExiste = "-"
                RegistroOK = "-"
                CarpetaOculta = "-"
                BloqueoCambios = "-"
                ResolucionBloqueada = "-"
            }
            continue
        }
        
        # Solicitar credenciales para este PC
        Write-Host "  $(Get-String $Strings 'REMOTE_REQUEST_CREDENTIALS')" -ForegroundColor Yellow
        
        try {
            $Cred = Get-Credential -Message "$(Get-String $Strings 'VERIFY_CREDENTIAL_MESSAGE') $PC"
            
            if (-not $Cred) {
                Write-Host "  [ERROR] $(Get-String $Strings 'MASS_CREDENTIALS_CANCELLED')" -ForegroundColor Red
                Write-LogEntry "Credenciales canceladas para $PC" "WARNING"
                
                $Resultados += [PSCustomObject]@{
                    Equipo = $PC
                    Estado = (Get-String $Strings 'MASS_CREDENTIALS_CANCELLED')
                    FondoExiste = "-"
                    BloqueoExiste = "-"
                    RegistroOK = "-"
                    CarpetaOculta = "-"
                    BloqueoCambios = "-"
                    ResolucionBloqueada = "-"
                }
                continue
            }
            
            Write-Host "  $(Get-String $Strings 'REMOTE_CREDENTIALS_OK')" -ForegroundColor Green
        }
        catch {
            Write-Host "  [ERROR] $(Get-String $Strings 'REMOTE_CREDENTIAL_ERROR'): $_" -ForegroundColor Red
            Write-LogEntry "Error al solicitar credenciales para $PC : $_" "ERROR"
            
            $Resultados += [PSCustomObject]@{
                Equipo = $PC
                Estado = (Get-String $Strings 'REMOTE_CREDENTIAL_ERROR')
                FondoExiste = "-"
                BloqueoExiste = "-"
                RegistroOK = "-"
                CarpetaOculta = "-"
                BloqueoCambios = "-"
                ResolucionBloqueada = "-"
            }
            continue
        }
        
        $info = Invoke-Command -ComputerName $PC -Credential $Cred -ScriptBlock {
            $fondoExiste = Test-Path "C:\Fondos\EIX2526.png"
            $bloqueoExiste = Test-Path "C:\Fondos\valors2526.png"
            $registroOK = Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
            
            $carpetaOculta = $false
            if (Test-Path "C:\Fondos") {
                $folder = Get-Item "C:\Fondos" -Force
                $carpetaOculta = $folder.Attributes -match "Hidden"
            }
            
            $bloqueoCambios = $false
            if ($registroOK) {
                $noCambio = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" `
                    -Name "NoChangingWallPaper" -ErrorAction SilentlyContinue
                $bloqueoCambios = $noCambio.NoChangingWallPaper -eq 1
            }
            
            # Verificar si la resolución está bloqueada
            $resolucionBloqueada = $false
            $resPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Display"
            if (Test-Path $resPath) {
                $resolucionBloqueada = $true
            }
            
            [PSCustomObject]@{
                FondoExiste = $fondoExiste
                BloqueoExiste = $bloqueoExiste
                RegistroOK = $registroOK
                CarpetaOculta = $carpetaOculta
                BloqueoCambios = $bloqueoCambios
                ResolucionBloqueada = $resolucionBloqueada
            }
        }
        
        $todoOK = $info.FondoExiste -and $info.BloqueoExiste -and $info.RegistroOK -and 
                  $info.CarpetaOculta -and $info.BloqueoCambios -and $info.ResolucionBloqueada
        
        $estado = if ($todoOK) { (Get-String $Strings 'VERIFY_STATUS_OK') } else { (Get-String $Strings 'VERIFY_STATUS_PARTIAL') }
        
        Write-LogEntry "Equipo $PC verificado. Estado: $estado, Fondo: $($info.FondoExiste), Bloqueo: $($info.BloqueoExiste), Registro: $($info.RegistroOK), Resolución: $($info.ResolucionBloqueada)" "INFO"
        
        $Resultados += [PSCustomObject]@{
            Equipo = $PC
            Estado = $estado
            FondoExiste = if($info.FondoExiste){(Get-String $Strings 'MSG_YES')}else{(Get-String $Strings 'MSG_NO')}
            BloqueoExiste = if($info.BloqueoExiste){(Get-String $Strings 'MSG_YES')}else{(Get-String $Strings 'MSG_NO')}
            RegistroOK = if($info.RegistroOK){(Get-String $Strings 'MSG_YES')}else{(Get-String $Strings 'MSG_NO')}
            CarpetaOculta = if($info.CarpetaOculta){(Get-String $Strings 'MSG_YES')}else{(Get-String $Strings 'MSG_NO')}
            BloqueoCambios = if($info.BloqueoCambios){(Get-String $Strings 'MSG_YES')}else{(Get-String $Strings 'MSG_NO')}
            ResolucionBloqueada = if($info.ResolucionBloqueada){(Get-String $Strings 'MSG_YES')}else{(Get-String $Strings 'MSG_NO')}
        }
        
        Write-Host "  $estado`n" -ForegroundColor $(if($todoOK){"Green"}else{"Yellow"})
        
    } catch {
        Write-Host "  [ERROR] $(Get-String $Strings 'MSG_ERROR'): $($_.Exception.Message)`n" -ForegroundColor Red
        Write-LogEntry "Error al verificar equipo $PC - $($_.Exception.Message)" "ERROR"
        
        $Resultados += [PSCustomObject]@{
            Equipo = $PC
            Estado = (Get-String $Strings 'VERIFY_STATUS_ERROR')
            FondoExiste = "?"
            BloqueoExiste = "?"
            RegistroOK = "?"
            CarpetaOculta = "?"
            BloqueoCambios = "?"
            ResolucionBloqueada = "?"
        }
    }
}

Write-Host "`n=================================================================================" -ForegroundColor Cyan
Write-Host (Get-String $Strings 'VERIFY_RESULTS') -ForegroundColor White
Write-Host "=================================================================================`n" -ForegroundColor Cyan

# Preparar encabezados traducidos
$h1 = (Get-String $Strings 'VERIFY_TABLE_COMPUTER').PadRight(16).Substring(0,16)
$h2 = (Get-String $Strings 'VERIFY_TABLE_STATUS').PadRight(8).Substring(0,8)
$h3 = (Get-String $Strings 'VERIFY_TABLE_WALLPAPER').PadRight(5).Substring(0,5)
$h4 = (Get-String $Strings 'VERIFY_TABLE_LOCKSCREEN').PadRight(6).Substring(0,6)
$h5 = (Get-String $Strings 'VERIFY_TABLE_REGISTRY').PadRight(4).Substring(0,4)
$h6 = (Get-String $Strings 'VERIFY_TABLE_HIDDEN').PadRight(6).Substring(0,6)
$h7 = (Get-String $Strings 'VERIFY_TABLE_LOCKED').PadRight(6).Substring(0,6)
$h8 = (Get-String $Strings 'VERIFY_TABLE_RESOLUTION').PadRight(8).Substring(0,8)

$h1b = "".PadRight(16)
$h2b = "".PadRight(8)
$h3b = (Get-String $Strings 'VERIFY_TABLE_WALLPAPER2').PadRight(5).Substring(0,5)
$h4b = (Get-String $Strings 'VERIFY_TABLE_LOCKSCREEN2').PadRight(6).Substring(0,6)
$h5b = (Get-String $Strings 'VERIFY_TABLE_REGISTRY2').PadRight(4).Substring(0,4)
$h6b = (Get-String $Strings 'VERIFY_TABLE_HIDDEN2').PadRight(6).Substring(0,6)
$h7b = (Get-String $Strings 'VERIFY_TABLE_LOCKED2').PadRight(6).Substring(0,6)
$h8b = (Get-String $Strings 'VERIFY_TABLE_RESOLUTION2').PadRight(8).Substring(0,8)

# Encabezados de la tabla
Write-Host "+------------------+----------+-------+--------+------+--------+--------+----------+" -ForegroundColor DarkGray
Write-Host "| $h1 | $h2 | $h3 | $h4 | $h5 | $h6 | $h7 | $h8 |" -ForegroundColor White
Write-Host "| $h1b | $h2b | $h3b | $h4b | $h5b | $h6b | $h7b | $h8b |" -ForegroundColor White
Write-Host "+------------------+----------+-------+--------+------+--------+--------+----------+" -ForegroundColor DarkGray

# Mostrar cada resultado
foreach ($resultado in $Resultados) {
    $equipoFormatted = $resultado.Equipo.PadRight(16).Substring(0,16)
    $estadoFormatted = $resultado.Estado.PadRight(8).Substring(0,8)
    $fondoFormatted = $resultado.FondoExiste.ToString().PadRight(5).Substring(0,5)
    $bloqueoFormatted = $resultado.BloqueoExiste.ToString().PadRight(6).Substring(0,6)
    $registroFormatted = $resultado.RegistroOK.ToString().PadRight(4).Substring(0,4)
    $ocultaFormatted = $resultado.CarpetaOculta.ToString().PadRight(6).Substring(0,6)
    $bloqCambiosFormatted = $resultado.BloqueoCambios.ToString().PadRight(6).Substring(0,6)
    $resolFormatted = $resultado.ResolucionBloqueada.ToString().PadRight(8).Substring(0,8)
    
    # Color según el estado
    $color = "White"
    if ($resultado.Estado -eq (Get-String $Strings 'VERIFY_STATUS_OK')) {
        $color = "Green"
    } elseif ($resultado.Estado -eq (Get-String $Strings 'VERIFY_STATUS_PARTIAL')) {
        $color = "Yellow"
    } elseif ($resultado.Estado -eq (Get-String $Strings 'VERIFY_STATUS_OFFLINE')) {
        $color = "DarkGray"
    } else {
        $color = "Red"
    }
    
    Write-Host "| $equipoFormatted | $estadoFormatted | $fondoFormatted | $bloqueoFormatted | $registroFormatted | $ocultaFormatted | $bloqCambiosFormatted | $resolFormatted |" -ForegroundColor $color
}

Write-Host "+------------------+----------+-------+--------+------+--------+--------+----------+" -ForegroundColor DarkGray

$correctos = 0
$parciales = 0
$errores = 0

foreach ($resultado in $Resultados) {
    if ($resultado.Estado -eq (Get-String $Strings 'VERIFY_STATUS_OK')) {
        $correctos++
    }
    elseif ($resultado.Estado -eq (Get-String $Strings 'VERIFY_STATUS_PARTIAL')) {
        $parciales++
    }
    elseif ($resultado.Estado -eq (Get-String $Strings 'VERIFY_STATUS_ERROR') -or $resultado.Estado -eq (Get-String $Strings 'VERIFY_STATUS_OFFLINE')) {
        $errores++
    }
}

Write-Host "`n$(Get-String $Strings 'VERIFY_SUMMARY'):" -ForegroundColor White
Write-Host "  $(Get-String $Strings 'VERIFY_CORRECT'): $correctos" -ForegroundColor Green
Write-Host "  $(Get-String $Strings 'VERIFY_PARTIAL'): $parciales" -ForegroundColor Yellow
Write-Host "  $(Get-String $Strings 'VERIFY_WITH_ERRORS'): $errores" -ForegroundColor Red

Write-LogEntry "Resumen de verificación: Correctos=$correctos, Parciales=$parciales, Errores=$errores" "INFO"

Write-Host "`n$(Get-String $Strings 'VERIFY_LEGEND'):" -ForegroundColor White
Write-Host "  $(Get-String $Strings 'VERIFY_LEGEND_WALLPAPER')" -ForegroundColor Gray
Write-Host "  $(Get-String $Strings 'VERIFY_LEGEND_LOCKSCREEN')" -ForegroundColor Gray
Write-Host "  $(Get-String $Strings 'VERIFY_LEGEND_REGISTRY')" -ForegroundColor Gray
Write-Host "  $(Get-String $Strings 'VERIFY_LEGEND_HIDDEN')" -ForegroundColor Gray
Write-Host "  $(Get-String $Strings 'VERIFY_LEGEND_LOCKED')" -ForegroundColor Gray
Write-Host "  $(Get-String $Strings 'VERIFY_LEGEND_RESOLUTION')`n" -ForegroundColor Gray

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFolder = Join-Path $PSScriptRoot "..\logs"
$logFileName = "$(Get-String $Strings 'LOG_VERIFICATION')_$timestamp.csv"
$reportPath = Join-Path $reportFolder $logFileName

$Resultados | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8
Write-Host "$(Get-String $Strings 'VERIFY_REPORT_SAVED'): $reportPath`n" -ForegroundColor Cyan
Write-LogEntry "Informe CSV guardado en: $reportPath" "SUCCESS"

Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host "      $(Get-String $Strings 'MSG_POWERED_BY')" -ForegroundColor White
Write-Host "=================================================================================`n" -ForegroundColor Cyan

# Mensaje para volver al menú
Write-Host (Get-String $Strings 'MSG_PRESS_KEY') -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
