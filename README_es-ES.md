================================================================================
                    MULTIHERRAMIENTA FENNEC beta-0.1.0
================================================================================

                           Desarrollado por jitodv
                          Gestión de Fondos de Pantalla
                          y Configuraciones de Windows

================================================================================
DESCRIPCIÓN
================================================================================

Multiherramienta Fennec es una solución profesional para la gestión 
centralizada de fondos de pantalla y configuraciones de sistema en entornos 
Windows. Permite configurar, verificar y revertir configuraciones tanto en 
equipos locales como remotos con soporte multiidioma completo.

CARACTERÍSTICAS PRINCIPALES:
  ✓ Configuración de fondos de escritorio y pantalla de bloqueo
  ✓ Gestión remota de múltiples equipos (WinRM)
  ✓ Despliegue masivo con credenciales por PC
  ✓ Verificación y auditoría de configuraciones
  ✓ Bloqueo/desbloqueo de resoluciones de pantalla
  ✓ Sistema de reversión completa de configuraciones
  ✓ Interfaz multiidioma (Español, English, Català)
  ✓ Generación de informes y logs detallados

================================================================================
ESTRUCTURA DEL PROGRAMA
================================================================================

Multiherramienta Fennec/
│
├── Multiherramienta Fennec.bat     ← EJECUTAR ESTE ARCHIVO (como Administrador)
│
├── Images/                         ← Carpeta con las imágenes de fondos
│   ├── image.png                  (Ejemplo: Fondo de escritorio)
│   └── image.png                     (Ejemplo: Fondo de pantalla de image)
│
├── Lang/                           ← Archivos de traducción
│   ├── es-ES.txt                       (Español - Spain)
│   ├── en-US.txt                       (English - United States)
│   └── ca-ES.txt                       (Català - Catalunya)
│
├── logs/                           ← Carpeta de informes y registros
│   └── (se crean automáticamente)      (Verificaciones, despliegues, etc.)
│
├── Scripts/                        ← Todos los scripts de PowerShell
│   ├── MenuPrincipal.ps1               (Menú principal multiidioma)
│   ├── LanguageLoader.ps1              (Motor de gestión de idiomas)
│   ├── ConfigurarFondosLocal.ps1       (Configuración local de fondos)
│   ├── script_ejecutar_remoto.ps1      (Configuración remota individual)
│   ├── script_despliegue_masivo.ps1    (Despliegue masivo a múltiples PCs)
│   ├── script_verificar_config.ps1     (Verificación y auditoría)
│   ├── script_revertir_config.ps1      (Reversión de configuraciones)
│   ├── script_configurar_resoluciones.ps1  (Bloqueo de resoluciones)
│   └── winrm.ps1                       (Configuración de WinRM)
│
├── lang.config                     ← Configuración de idioma persistente
│
└── README_es-ES.txt                ← Este archivo

================================================================================
REQUISITOS DEL SISTEMA
================================================================================

• Sistema Operativo: Windows 10/11 Pro or Enterprise / Education
• PowerShell: Versión 5.1 o superior
• Permisos: Derechos de Administrador
• Para gestión remota: WinRM habilitado en equipos destino
• Formato de imágenes: PNG (recomendado)
• Red: Conectividad de red para equipos remotos

================================================================================
GUÍA DE USO DETALLADA
================================================================================

┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. INICIO RÁPIDO                                                            │
└─────────────────────────────────────────────────────────────────────────────┘

   a) Haz clic derecho en "Multiherramienta Fennec"
   b) Selecciona "Ejecutar como administrador"
   c) El programa detectará automáticamente el idioma de tu sistema
   d) Aparecerá el menú principal con todas las opciones disponibles

┌─────────────────────────────────────────────────────────────────────────────┐
│ 2. PREPARAR IMÁGENES                                                        │
└─────────────────────────────────────────────────────────────────────────────┘

   a) Coloca tus imágenes PNG en la carpeta "Images/"
   b) Nombres recomendados:
      • image.png (Fondo de escritorio)
      • image.png (Fondo de pantalla de bloqueo)
   c) Puedes usar múltiples imágenes con nombres personalizados
   d) Al ejecutar los scripts, se te pedirá el nombre exacto del archivo

┌─────────────────────────────────────────────────────────────────────────────┐
│ 3. PRERREQUISITOS - Opción [1]                                              │
└─────────────────────────────────────────────────────────────────────────────┘

   HABILITAR WINRM EN ESTE PC
   
   • Ejecutar ANTES de cualquier operación remota
   • Configura WinRM para permitir la gestión remota
   • Añade equipos a la lista de hosts de confianza
   • Solo necesario ejecutar UNA VEZ por equipo
   • Requiere permisos de Administrador

┌─────────────────────────────────────────────────────────────────────────────┐
│ 4. CONFIGURACIÓN LOCAL - Opción [2]                                         │
└─────────────────────────────────────────────────────────────────────────────┘

   CONFIGURAR FONDOS EN ESTE PC
   
   • Aplica fondos de pantalla en el equipo local
   • Se solicitará:
     - Nombre del archivo para fondo de escritorio
     - Nombre del archivo para pantalla de bloqueo
   • Los fondos se bloquean mediante políticas de registro
   • Los usuarios NO podrán cambiarlos después
   • Requiere cerrar sesión para aplicarse completamente

┌─────────────────────────────────────────────────────────────────────────────┐
│ 5. CONFIGURACIÓN REMOTA - Opción [3]                                        │
└─────────────────────────────────────────────────────────────────────────────┘

   CONFIGURAR UN EQUIPO REMOTO
   
   • Gestiona fondos en un solo equipo de la red
   • Se solicitará:
     - Hostname o IP del equipo remoto
     - Credenciales de administrador del equipo
     - Nombres de los archivos de imagen
   • Las imágenes se copian automáticamente al equipo remoto
   • Se aplican las políticas de bloqueo remotamente
   • Genera informe del resultado de la operación

┌─────────────────────────────────────────────────────────────────────────────┐
│ 6. DESPLIEGUE MASIVO - Opción [4]                                           │
└─────────────────────────────────────────────────────────────────────────────┘

   CONFIGURAR MÚLTIPLES EQUIPOS
   
   • Despliega fondos a múltiples PCs simultáneamente
   • NUEVO: Solicita credenciales individuales por cada PC
   • Se solicitará para cada equipo:
     - Usuario con permisos de administrador
     - Contraseña (oculta durante la entrada)
   • Proceso totalmente interactivo y seguro
   • Genera informe detallado en carpeta "logs/"
   • Muestra resumen de éxitos y errores al finalizar
   
   NOTA: Ya NO es necesario editar el script manualmente

┌─────────────────────────────────────────────────────────────────────────────┐
│ 7. VERIFICAR CONFIGURACIÓN - Opción [5]                                     │
└─────────────────────────────────────────────────────────────────────────────┘

   AUDITORÍA DE EQUIPOS
   
   • Verifica qué equipos tienen los fondos configurados
   • NUEVO: Solicita credenciales individuales por cada PC
   • Muestra tabla ASCII con resultados en tiempo real
   • Genera informe CSV en carpeta "logs/"
   • Verifica:
     - Existencia de archivos de imagen
     - Estado de políticas de registro
     - Bloqueo de configuración
   • Perfecto para auditorías y seguimiento

┌─────────────────────────────────────────────────────────────────────────────┐
│ 8. REVERTIR CONFIGURACIÓN - Opción [6]                                      │
└─────────────────────────────────────────────────────────────────────────────┘

   MENÚ DE REVERSIÓN
   
   Opciones disponibles:
   
   [1] Revertir solo configuración de fondos
       • Elimina archivos de imagen
       • Elimina políticas de bloqueo de fondos
       • Restaura permisos de carpetas
       • Los usuarios pueden volver a cambiar fondos
   
   [2] Revertir solo configuración de resoluciones
       • Elimina políticas de bloqueo de resolución
       • Restaura permisos de archivos de sistema
       • Permite cambiar resolución nuevamente
   
   [3] Revertir ambas configuraciones
       • Ejecuta reversión completa de fondos
       • Ejecuta reversión completa de resoluciones
       • Restaura el sistema a estado original
   
   [0] Volver al menú principal
   
   ADVERTENCIA: La reversión es permanente y requiere confirmación

┌─────────────────────────────────────────────────────────────────────────────┐
│ 9. CONFIGURAR RESOLUCIONES - Opción [7]                                     │
└─────────────────────────────────────────────────────────────────────────────┘

   BLOQUEAR RESOLUCIÓN DE PANTALLA
   
   • Bloquea la resolución de pantalla actual
   • Impide que usuarios cambien la resolución
   • Aplica 10 capas de protección:
     - Políticas de registro (CurrentUser y LocalMachine)
     - Bloqueo de archivos de sistema (desk.cpl, etc.)
     - Configuración de ACLs (permisos NTFS)
     - Deshabilitación de opciones en panel de control
   • Útil para entornos corporativos y kioskos
   • Reversible mediante Opción [6] → [2] o [3]

┌─────────────────────────────────────────────────────────────────────────────┐
│ 10. CAMBIAR IDIOMA - Opción [8]                                             │
└─────────────────────────────────────────────────────────────────────────────┘

   SELECTOR DE IDIOMA
   
   • Cambia el idioma de toda la interfaz
   • Idiomas disponibles:
     [1] Español (es-ES)
     [2] English (en-US)
     [3] Català (ca-ES)
   • El cambio es inmediato
   • Se guarda en "lang.config" para futuras sesiones
   • TODO el programa (menús, mensajes, informes) se traduce

================================================================================
INFORMES Y LOGS
================================================================================

La carpeta "logs/" contiene todos los informes generados:

• Despliegue_Masivo_YYYYMMDD_HHMMSS.txt
  → Resultado del despliegue masivo con detalles por equipo

• Verificacion_YYYYMMDD_HHMMSS.csv
  → Informe de verificación en formato CSV (Excel compatible)

• Otros logs generados automáticamente por las operaciones

Formato de timestamp: Año-Mes-Día_Hora-Minuto-Segundo

================================================================================
SOLUCIÓN DE PROBLEMAS
================================================================================

PROBLEMA: "No se puede ejecutar el script"
SOLUCIÓN: Ejecutar como Administrador y verificar política de ejecución:
          Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

PROBLEMA: "No se puede conectar al equipo remoto"
SOLUCIÓN: 
  1. Verificar que WinRM está habilitado (Opción [1])
  2. Verificar conectividad de red (ping al equipo)
  3. Verificar credenciales de administrador
  4. Verificar firewall en equipo destino

PROBLEMA: "Los fondos no se aplican"
SOLUCIÓN: 
  1. Cerrar sesión completamente
  2. Iniciar sesión nuevamente
  3. Esperar 30-60 segundos
  4. Si persiste, verificar formato PNG de las imágenes

PROBLEMA: "No se puede revertir configuración"
SOLUCIÓN: Ejecutar el programa como Administrador

================================================================================
NOTAS IMPORTANTES
================================================================================

⚠ SEGURIDAD:
  • SIEMPRE ejecutar como Administrador
  • Las credenciales NO se almacenan en ningún archivo
  • Las contraseñas se solicitan de forma segura (ocultas)
  • Los scripts NO contienen credenciales hardcodeadas

✓ COMPATIBILIDAD:
  • Imágenes: PNG recomendado, JPG soportado
  • Windows 10 Pro/Enterprise o superior
  • PowerShell 5.1 o superior

⚠ REQUISITOS REMOTOS:
  • WinRM habilitado en equipos destino
  • Credenciales de administrador para cada equipo
  • Puerto 5985 (HTTP) o 5986 (HTTPS) abierto en firewall

✓ MULTIIDIOMA:
  • Detección automática del idioma del sistema
  • Cambio instantáneo entre idiomas
  • Todos los mensajes, menús e informes traducidos
  • Configuración persistente entre sesiones

⚠ CAMBIOS:
  • Requieren cerrar sesión para aplicarse completamente
  • Las políticas de bloqueo son permanentes hasta revertir
  • La reversión elimina TODAS las configuraciones aplicadas

================================================================================
SOPORTE Y CONTACTO
================================================================================

Desarrollador: Rubén Guerrero López | @jitodv
Github: https://github.com/jitodv
Versión: beta-0.1.0
Fecha: Diciembre 2025

Para reportar problemas o sugerencias, documenta:
  • Versión del programa (beta-0.1.0)
  • Sistema operativo y versión
  • Descripción detallada del problema
  • Mensajes de error (si los hay)
  • Pasos para reproducir el problema

================================================================================
                              Powered by jitodv
================================================================================
