# ==============================================================================
# Script: Language Loader
# Descripción: Carga las cadenas de texto del idioma seleccionado
# Versión: 1.0
# Autor: Rubén Guerrero López
# ==============================================================================

<#
.SYNOPSIS
    Carga las cadenas de texto del idioma seleccionado
.DESCRIPTION
    Este script carga un archivo de idioma y devuelve un hashtable con todas
    las cadenas de texto traducidas. Permite cambiar el idioma de la aplicación.
#>

# Ruta de la carpeta de idiomas
$LangFolder = Join-Path $PSScriptRoot "..\Lang"
$ConfigFile = Join-Path $PSScriptRoot "..\lang.config"

# Función para obtener el idioma del sistema
function Get-SystemLanguage {
    $culture = Get-Culture
    $langCode = $culture.Name
    
    # Verificar si existe el archivo de idioma para el código del sistema
    $langFile = Join-Path $LangFolder "$langCode.txt"
    
    if (Test-Path $langFile) {
        return $langCode
    }
    
    # Si no existe, intentar con el idioma base (ej: es en lugar de es-ES)
    $baseLang = $culture.TwoLetterISOLanguageName
    $baseLangFile = Join-Path $LangFolder "$baseLang-*.txt"
    $found = Get-ChildItem $baseLangFile -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($found) {
        return $found.BaseName
    }
    
    # Por defecto, español
    return "es-ES"
}

# Función para cargar el idioma configurado
function Get-ConfiguredLanguage {
    if (Test-Path $ConfigFile) {
        $lang = Get-Content $ConfigFile -Raw
        return $lang.Trim()
    }
    
    # Si no hay configuración, detectar idioma del sistema
    return Get-SystemLanguage
}

# Función para guardar la configuración de idioma
function Set-ConfiguredLanguage {
    param (
        [string]$Language
    )
    
    $Language | Out-File -FilePath $ConfigFile -Encoding UTF8 -NoNewline
}

# Función para cargar el archivo de idioma
function Load-LanguageStrings {
    param (
        [string]$Language
    )
    
    $langFile = Join-Path $LangFolder "$Language.txt"
    
    if (-not (Test-Path $langFile)) {
        Write-Warning "Archivo de idioma no encontrado: $langFile"
        Write-Warning "Usando idioma por defecto: es-ES"
        $Language = "es-ES"
        $langFile = Join-Path $LangFolder "$Language.txt"
    }
    
    $strings = @{}
    
    # Leer el archivo línea por línea
    Get-Content $langFile -Encoding UTF8 | ForEach-Object {
        $line = $_.Trim()
        
        # Ignorar líneas vacías y comentarios
        if ($line -and -not $line.StartsWith('#')) {
            # Dividir por el primer signo =
            $parts = $line -split '=', 2
            
            if ($parts.Length -eq 2) {
                $key = $parts[0].Trim()
                $value = $parts[1].Trim()
                $strings[$key] = $value
            }
        }
    }
    
    return $strings
}

# Función para obtener una cadena traducida
function Get-String {
    param (
        [hashtable]$Strings,
        [string]$Key,
        [string]$Default = ""
    )
    
    if ($Strings.ContainsKey($Key)) {
        return $Strings[$Key]
    }
    
    if ($Default) {
        return $Default
    }
    
    return "[$Key]"
}

# Función para listar idiomas disponibles
function Get-AvailableLanguages {
    $langFiles = Get-ChildItem -Path $LangFolder -Filter "*.txt"
    $languages = @()
    
    foreach ($file in $langFiles) {
        $langCode = $file.BaseName
        $languages += @{
            Code = $langCode
            File = $file.FullName
        }
    }
    
    return $languages
}

# Función para mostrar el selector de idioma
function Show-LanguageSelector {
    param (
        [hashtable]$Strings
    )
    
    Clear-Host
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Cyan
    
    # Centrar el título
    $title = Get-String $Strings 'LANG_SELECT'
    $titleLength = [int]$title.Length
    $totalWidth = 81
    $leftPad = [int][math]::Max(0, [math]::Floor(($totalWidth - $titleLength) / 2))
    $centeredTitle = (" " * $leftPad) + $title
    
    Write-Host $centeredTitle -ForegroundColor Yellow
    Write-Host "=================================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    $currentLang = Get-ConfiguredLanguage
    $currentLangName = Get-String $Strings "LANG_NAME_$($currentLang.Replace('-','_').ToUpper())"
    Write-Host "    $(Get-String $Strings 'LANG_CURRENT'): " -NoNewline -ForegroundColor Green
    Write-Host "$currentLangName" -ForegroundColor Cyan
    Write-Host ""
    
    # Mostrar opciones de idioma con nombres completos
    Write-Host "       [1] Español" -ForegroundColor White
    Write-Host "       [2] English" -ForegroundColor White
    Write-Host "       [3] Català" -ForegroundColor White
    Write-Host ""
    Write-Host "       [0] $(Get-String $Strings 'MENU_OPTION_0')" -ForegroundColor Gray
    Write-Host ""
    Write-Host "=================================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    $selection = Read-Host "    $(Get-String $Strings 'MENU_SELECT')"
    
    if ($selection -eq "0") {
        return $null
    }
    
    # Mapear selección a código de idioma
    $selectedLang = switch ($selection) {
        "1" { "es-ES" }
        "2" { "en-US" }
        "3" { "ca-ES" }
        default { $null }
    }
    
    if ($selectedLang) {
        Set-ConfiguredLanguage -Language $selectedLang
        
        Write-Host ""
        Write-Host "    $(Get-String $Strings 'LANG_CHANGED')" -ForegroundColor Green
        Write-Host "    $(Get-String $Strings 'LANG_RESTART_REQUIRED')" -ForegroundColor Yellow
        Write-Host ""
        Read-Host "    $(Get-String $Strings 'MSG_PRESS_KEY')"
        
        return $selectedLang
    }
    
    return $null
}


