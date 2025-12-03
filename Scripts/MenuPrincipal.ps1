# ==============================================================================
# Script: Menú Principal con Soporte Multiidioma
# Descripción: Menú principal de Multiherramienta Fennec con sistema de idiomas
# Versión: beta-0.1.0
# Autor: Rubén Guerrero López
# ==============================================================================

<#
.SYNOPSIS
    Menú principal de la Multiherramienta Fennec con soporte multiidioma
.DESCRIPTION
    Este script muestra el menú principal y gestiona la navegación entre
    las diferentes opciones del programa, cargando los textos en el idioma
    seleccionado por el usuario.
#>

# ============================= CONFIGURACIÓN INICIAL =============================

# Configurar codificación UTF-8 (silenciar errores)
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch { }

# Configurar título de la ventana (silenciar errores)
try {
    $host.UI.RawUI.WindowTitle = "Multiherramienta Fennec beta-0.1.0"
} catch { }

# Configurar colores de la consola (silenciar errores)
try {
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "Green"
    Clear-Host
} catch { }

# Configurar tamaño de ventana (82 columnas x 35 líneas, silenciar errores)
try {
    $windowSize = $host.UI.RawUI.WindowSize
    $windowSize.Width = 82
    $windowSize.Height = 35
    $host.UI.RawUI.WindowSize = $windowSize
} catch { }

# Configurar tamaño del buffer IGUAL a la ventana para eliminar scroll (silenciar errores)
try {
    $bufferSize = $host.UI.RawUI.BufferSize
    $bufferSize.Width = 82
    $bufferSize.Height = 35
    $host.UI.RawUI.BufferSize = $bufferSize
} catch { }

# Importar el módulo de idiomas
. (Join-Path $PSScriptRoot "LanguageLoader.ps1")

# Cargar el idioma configurado
$currentLang = Get-ConfiguredLanguage
$strings = Load-LanguageStrings -Language $currentLang

# Definir versión del script
$ScriptVersion = "beta-0.1.0"

# Función para mostrar el menú principal
function Show-MainMenu {
    param (
        [hashtable]$Strings
    )
    
    Clear-Host
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Cyan
    
    # Obtener el título traducido y calcular espacios para centrarlo
    $menuTitle = "$(Get-String $Strings 'MENU_TITLE') v$ScriptVersion"
    $titleLength = $menuTitle.Length
    $totalWidth = 81
    $leftPadding = [int](($totalWidth - $titleLength) / 2)
    $centeredTitle = (" " * $leftPadding) + $menuTitle
    
    Write-Host $centeredTitle -ForegroundColor Yellow
    Write-Host "=================================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    $(Get-String $Strings 'MENU_SECTION_PREREQUISITES'):" -ForegroundColor Green
    Write-Host ""
    Write-Host "       [1] $(Get-String $Strings 'MENU_OPTION_1')" -ForegroundColor White
    Write-Host ""
    Write-Host "    $(Get-String $Strings 'MENU_SECTION_CONFIGURATION'):" -ForegroundColor Green
    Write-Host ""
    Write-Host "       [2] $(Get-String $Strings 'MENU_OPTION_2')" -ForegroundColor White
    Write-Host "       [3] $(Get-String $Strings 'MENU_OPTION_3')" -ForegroundColor White
    Write-Host "       [4] $(Get-String $Strings 'MENU_OPTION_4')" -ForegroundColor White
    Write-Host ""
    Write-Host "    $(Get-String $Strings 'MENU_SECTION_UTILITIES'):" -ForegroundColor Green
    Write-Host ""
    Write-Host "       [5] $(Get-String $Strings 'MENU_OPTION_5')" -ForegroundColor White
    Write-Host "       [6] $(Get-String $Strings 'MENU_OPTION_6')" -ForegroundColor White
    Write-Host "       [7] $(Get-String $Strings 'MENU_OPTION_7')" -ForegroundColor White
    Write-Host ""
    Write-Host "    $(Get-String $Strings 'MENU_SECTION_LANGUAGE'):" -ForegroundColor Green
    Write-Host ""
    Write-Host "       [8] $(Get-String $Strings 'MENU_OPTION_8')" -ForegroundColor White
    Write-Host ""
    Write-Host "    $(Get-String $Strings 'MENU_SECTION_EXIT'):" -ForegroundColor Green
    Write-Host ""
    Write-Host "       [0] $(Get-String $Strings 'MENU_OPTION_0')" -ForegroundColor White
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Cyan
    Write-Host "                              Powered by jitodv" -ForegroundColor DarkGray
    Write-Host "=================================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Mostrar idioma actual con nombre completo
    $langName = Get-String $Strings "LANG_NAME_$($currentLang.Replace('-','_').ToUpper())"
    Write-Host "    $(Get-String $Strings 'LANG_CURRENT'): " -NoNewline -ForegroundColor DarkGray
    Write-Host $langName -ForegroundColor Cyan
    Write-Host ""
}

# Función para habilitar scroll antes de ejecutar un script
function Enable-Scroll {
    try {
        $bufferSize = $host.UI.RawUI.BufferSize
        $bufferSize.Height = 3000
        $host.UI.RawUI.BufferSize = $bufferSize
    } catch { }
}

# Función para deshabilitar scroll al volver al menú
function Disable-Scroll {
    try {
        $bufferSize = $host.UI.RawUI.BufferSize
        $bufferSize.Height = 35
        $host.UI.RawUI.BufferSize = $bufferSize
    } catch { }
}

# Función para mostrar encabezado de script centrado
function Show-ScriptHeader {
    param([string]$Title)
    
    Clear-Host
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Cyan
    
    # Centrar el título
    $titleLength = [int]$Title.Length
    $totalWidth = 81
    $leftPad = [int][math]::Max(0, [math]::Floor(($totalWidth - $titleLength) / 2))
    $rightPad = [int][math]::Max(0, $totalWidth - $leftPad - $titleLength)
    
    Write-Host (" " * $leftPad) -NoNewline
    Write-Host $Title -NoNewline -ForegroundColor Yellow
    Write-Host (" " * $rightPad)
    
    Write-Host "=================================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Centrar "Powered by jitodv"
    $powered = "Powered by jitodv"
    $poweredLength = [int]$powered.Length
    $leftPad = [int][math]::Max(0, [math]::Floor(($totalWidth - $poweredLength) / 2))
    $rightPad = [int][math]::Max(0, $totalWidth - $leftPad - $poweredLength)
    
    Write-Host (" " * $leftPad) -NoNewline
    Write-Host $powered -NoNewline -ForegroundColor Magenta
    Write-Host (" " * $rightPad)
    
    Write-Host "=================================================================================" -ForegroundColor Cyan
    Write-Host ""
}

# Función para ejecutar la opción seleccionada
function Invoke-MenuOption {
    param (
        [string]$Option,
        [hashtable]$Strings
    )
    
    switch ($Option) {
        "1" {
            # Habilitar WinRM
            Enable-Scroll
            Show-ScriptHeader "MULTIHERRAMIENTA FENNEC"
            
            & (Join-Path $PSScriptRoot "winrm.ps1")
            
            Disable-Scroll
        }
        
        "2" {
            # Configurar fondos en este PC
            Enable-Scroll
            Show-ScriptHeader "MULTIHERRAMIENTA FENNEC"
            
            & (Join-Path $PSScriptRoot "ConfigurarFondosLocal.ps1") -Strings $Strings
            
            Disable-Scroll
        }
        
        "3" {
            # Configurar un equipo remoto
            Enable-Scroll
            Show-ScriptHeader "MULTIHERRAMIENTA FENNEC"
            Show-ScriptHeader "MULTIHERRAMIENTA FENNEC"
            
            & (Join-Path $PSScriptRoot "script_ejecutar_remoto.ps1") -Strings $Strings
            
            Disable-Scroll
        }
        
        "4" {
            # Despliegue masivo
            Enable-Scroll
            Show-ScriptHeader "MULTIHERRAMIENTA FENNEC"
            
            & (Join-Path $PSScriptRoot "script_despliegue_masivo.ps1") -Strings $Strings
            
            Disable-Scroll
        }
        
        "5" {
            # Verificar configuración
            Enable-Scroll
            Show-ScriptHeader "MULTIHERRAMIENTA FENNEC"
            
            & (Join-Path $PSScriptRoot "script_verificar_config.ps1") -Strings $Strings
            
            Disable-Scroll
        }
        
        "6" {
            # Revertir configuración
            Enable-Scroll
            Show-ScriptHeader "MULTIHERRAMIENTA FENNEC"
            Enable-Scroll
            Show-ScriptHeader "MULTIHERRAMIENTA FENNEC"
            
            & (Join-Path $PSScriptRoot "script_revertir_config.ps1") -Strings $Strings
            
            Disable-Scroll
        }
        
        "7" {
            # Configurar resoluciones
            Enable-Scroll
            Show-ScriptHeader "MULTIHERRAMIENTA FENNEC"
            
            & (Join-Path $PSScriptRoot "script_configurar_resoluciones.ps1") -Strings $Strings
            
            Disable-Scroll
        }
        
        "8" {
            # Cambiar idioma
            $newLang = Show-LanguageSelector -Strings $Strings
            
            if ($newLang) {
                # Recargar el menú con el nuevo idioma
                return "RELOAD"
            }
        }
        
        "0" {
            # Salir con mensaje traducido
            Clear-Host
            Write-Host ""
            Write-Host ""
            Write-Host "=================================================================================" -ForegroundColor Cyan
            
            # Centrar mensaje de despedida
            $goodbye = Get-String $Strings 'EXIT_GOODBYE'
            $goodbyeLength = [int]$goodbye.Length
            $leftPad = [int][math]::Max(0, [math]::Floor((81 - $goodbyeLength) / 2))
            $centeredGoodbye = (" " * $leftPad) + $goodbye
            
            Write-Host ""
            Write-Host $centeredGoodbye -ForegroundColor Green
            
            # Centrar mensaje de agradecimiento
            $thanks = Get-String $Strings 'EXIT_THANKS'
            $thanksLength = [int]$thanks.Length
            $leftPad = [int][math]::Max(0, [math]::Floor((81 - $thanksLength) / 2))
            $centeredThanks = (" " * $leftPad) + $thanks
            
            Write-Host $centeredThanks -ForegroundColor Yellow
            Write-Host ""
            
            # Centrar "Powered by jitodv"
            Write-Host "                              Powered by jitodv" -ForegroundColor Magenta
            Write-Host ""
            Write-Host "=================================================================================" -ForegroundColor Cyan
            Write-Host ""
            
            # Mensaje de cierre
            Write-Host "    $(Get-String $Strings 'EXIT_MESSAGE')" -ForegroundColor DarkGray
            Write-Host ""
            
            Start-Sleep -Seconds 2
            exit
        }
        
        default {
            Write-Host ""
            Write-Host "    [ERROR] $(Get-String $Strings 'MSG_ERROR')" -ForegroundColor Red
            Write-Host ""
            Start-Sleep -Seconds 2
        }
    }
    
    return "CONTINUE"
}

# Bucle principal del menú
do {
    # Recargar el idioma si es necesario
    $currentLang = Get-ConfiguredLanguage
    $strings = Load-LanguageStrings -Language $currentLang
    
    Show-MainMenu -Strings $strings
    
    $option = Read-Host "    $(Get-String $strings 'MENU_SELECT')"
    
    $result = Invoke-MenuOption -Option $option -Strings $strings
    
} while ($result -ne "EXIT")
