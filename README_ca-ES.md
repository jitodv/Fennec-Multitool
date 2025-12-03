================================================================================
                      MULTIEINA FENNEC beta-0.1.0
================================================================================

                        Desenvolupat per jitodv
                   Gestió de Fons de Pantalla i Configuracions
                          Solució Professional per a IT

================================================================================
DESCRIPCIÓ
================================================================================

Multieina Fennec és una solució professional per a la gestió centralitzada 
de fons de pantalla i configuracions de sistema en entorns Windows. Permet 
configurar, verificar i revertir configuracions tant en equips locals com 
remots amb suport multiidioma complet.

CARACTERÍSTIQUES PRINCIPALS:
  ✓ Configuració de fons d'escriptori i pantalla de bloqueig
  ✓ Gestió remota de múltiples equips (WinRM)
  ✓ Desplegament massiu amb credencials per PC
  ✓ Verificació i auditoria de configuracions
  ✓ Bloqueig/desbloqueig de resolucions de pantalla
  ✓ Sistema de reversió completa de configuracions
  ✓ Interfície multiidioma (Español, English, Català)
  ✓ Generació d'informes i registres detallats

================================================================================
ESTRUCTURA DEL PROGRAMA
================================================================================

Multieina Fennec/
│
├── Multiherramienta Fennec.bat     ← EXECUTAR AQUEST ARXIU (com a Administrador)
│
├── Images/                         ← Carpeta amb les imatges de fons
│   ├── image.png                  (Exemple: Fons d'escriptori)
│   └── image.png                     (Exemple: Fons de pantalla de bloqueig)
│
├── Lang/                           ← Arxius de traducció
│   ├── es-ES.txt                       (Español - Espanya)
│   ├── en-US.txt                       (English - Estats Units)
│   └── ca-ES.txt                       (Català - Catalunya)
│
├── logs/                           ← Carpeta d'informes i registres
│   └── (es creen automàticament)       (Verificacions, desplegaments, etc.)
│
├── Scripts/                        ← Tots els scripts de PowerShell
│   ├── MenuPrincipal.ps1               (Menú principal multiidioma)
│   ├── LanguageLoader.ps1              (Motor de gestió d'idiomes)
│   ├── ConfigurarFondosLocal.ps1       (Configuració local de fons)
│   ├── script_ejecutar_remoto.ps1      (Configuració remota individual)
│   ├── script_despliegue_masivo.ps1    (Desplegament massiu a múltiples PCs)
│   ├── script_verificar_config.ps1     (Verificació i auditoria)
│   ├── script_revertir_config.ps1      (Reversió de configuracions)
│   ├── script_configurar_resoluciones.ps1  (Bloqueig de resolucions)
│   └── winrm.ps1                       (Configuració de WinRM)
│
├── lang.config                     ← Configuració d'idioma persistent
│
└── README_ca-ES.txt                ← Aquest arxiu

================================================================================
REQUISITS DEL SISTEMA
================================================================================

• Sistema Operatiu: Windows 10/11 Pro or Enterprise / Education
• PowerShell: Versió 5.1 o superior
• Permisos: Drets d'Administrador
• Per a gestió remota: WinRM habilitat en equips destinació
• Format d'imatges: PNG (recomanat)
• Xarxa: Connectivitat de xarxa per a equips remots

================================================================================
GUIA D'ÚS DETALLADA
================================================================================

┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. INICI RÀPID                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

   a) Fes clic dret a "Multiherramienta Fennec"
   b) Selecciona "Executa com a administrador"
   c) El programa detectarà automàticament l'idioma del teu sistema
   d) Apareixerà el menú principal amb totes les opcions disponibles

┌─────────────────────────────────────────────────────────────────────────────┐
│ 2. PREPARAR IMATGES                                                         │
└─────────────────────────────────────────────────────────────────────────────┘

   a) Col·loca les teves imatges PNG a la carpeta "Images/"
   b) Noms recomanats:
      • image.png (Fons d'escriptori)
      • image.png (Fons de pantalla de bloqueig)
   c) Pots utilitzar múltiples imatges amb noms personalitzats
   d) En executar els scripts, se't demanarà el nom exacte de l'arxiu

┌─────────────────────────────────────────────────────────────────────────────┐
│ 3. PREREQUISITS - Opció [1]                                                 │
└─────────────────────────────────────────────────────────────────────────────┘

   HABILITAR WINRM EN AQUEST PC
   
   • Executar ABANS de qualsevol operació remota
   • Configura WinRM per permetre la gestió remota
   • Afegeix equips a la llista de hosts de confiança
   • Només cal executar UNA VEGADA per equip
   • Requereix permisos d'Administrador

┌─────────────────────────────────────────────────────────────────────────────┐
│ 4. CONFIGURACIÓ LOCAL - Opció [2]                                           │
└─────────────────────────────────────────────────────────────────────────────┘

   CONFIGURAR FONS EN AQUEST PC
   
   • Aplica fons de pantalla en l'equip local
   • Se sol·licitarà:
     - Nom de l'arxiu per al fons d'escriptori
     - Nom de l'arxiu per a la pantalla de bloqueig
   • Els fons es bloquegen mitjançant polítiques de registre
   • Els usuaris NO podran canviar-los després
   • Requereix tancar la sessió per aplicar-se completament

┌─────────────────────────────────────────────────────────────────────────────┐
│ 5. CONFIGURACIÓ REMOTA - Opció [3]                                          │
└─────────────────────────────────────────────────────────────────────────────┘

   CONFIGURAR UN EQUIP REMOT
   
   • Gestiona fons en un sol equip de la xarxa
   • Se sol·licitarà:
     - Hostname o IP de l'equip remot
     - Credencials d'administrador de l'equip
     - Noms dels arxius d'imatge
   • Les imatges es copien automàticament a l'equip remot
   • S'apliquen les polítiques de bloqueig remotament
   • Genera informe del resultat de l'operació

┌─────────────────────────────────────────────────────────────────────────────┐
│ 6. DESPLEGAMENT MASSIU - Opció [4]                                          │
└─────────────────────────────────────────────────────────────────────────────┘

   CONFIGURAR MÚLTIPLES EQUIPS
   
   • Desplega fons a múltiples PCs simultàniament
   • NOU: Sol·licita credencials individuals per cada PC
   • Se sol·licitarà per cada equip:
     - Usuari amb permisos d'administrador
     - Contrasenya (oculta durant l'entrada)
   • Procés totalment interactiu i segur
   • Genera informe detallat a la carpeta "logs/"
   • Mostra resum d'èxits i errors en finalitzar
   
   NOTA: Ja NO cal editar l'script manualment

┌─────────────────────────────────────────────────────────────────────────────┐
│ 7. VERIFICAR CONFIGURACIÓ - Opció [5]                                       │
└─────────────────────────────────────────────────────────────────────────────┘

   AUDITORIA D'EQUIPS
   
   • Verifica quins equips tenen els fons configurats
   • NOU: Sol·licita credencials individuals per cada PC
   • Mostra taula ASCII amb resultats en temps real
   • Genera informe CSV a la carpeta "logs/"
   • Verifica:
     - Existència d'arxius d'imatge
     - Estat de polítiques de registre
     - Bloqueig de configuració
   • Perfecte per a auditories i seguiment

┌─────────────────────────────────────────────────────────────────────────────┐
│ 8. REVERTIR CONFIGURACIÓ - Opció [6]                                        │
└─────────────────────────────────────────────────────────────────────────────┘

   MENÚ DE REVERSIÓ
   
   Opcions disponibles:
   
   [1] Revertir només configuració de fons
       • Elimina arxius d'imatge
       • Elimina polítiques de bloqueig de fons
       • Restaura permisos de carpetes
       • Els usuaris poden tornar a canviar fons
   
   [2] Revertir només configuració de resolucions
       • Elimina polítiques de bloqueig de resolució
       • Restaura permisos d'arxius de sistema
       • Permet canviar resolució novament
   
   [3] Revertir ambdues configuracions
       • Executa reversió completa de fons
       • Executa reversió completa de resolucions
       • Restaura el sistema a estat original
   
   [0] Tornar al menú principal
   
   ADVERTÈNCIA: La reversió és permanent i requereix confirmació

┌─────────────────────────────────────────────────────────────────────────────┐
│ 9. CONFIGURAR RESOLUCIONS - Opció [7]                                       │
└─────────────────────────────────────────────────────────────────────────────┘

   BLOQUEJAR RESOLUCIÓ DE PANTALLA
   
   • Bloqueja la resolució de pantalla actual
   • Impedeix que usuaris canviïn la resolució
   • Aplica 10 capes de protecció:
     - Polítiques de registre (CurrentUser i LocalMachine)
     - Bloqueig d'arxius de sistema (desk.cpl, etc.)
     - Configuració d'ACLs (permisos NTFS)
     - Deshabilitació d'opcions al panell de control
   • Útil per a entorns corporatius i quioscos
   • Reversible mitjançant Opció [6] → [2] o [3]

┌─────────────────────────────────────────────────────────────────────────────┐
│ 10. CANVIAR IDIOMA - Opció [8]                                              │
└─────────────────────────────────────────────────────────────────────────────┘

   SELECTOR D'IDIOMA
   
   • Canvia l'idioma de tota la interfície
   • Idiomes disponibles:
     [1] Español (es-ES)
     [2] English (en-US)
     [3] Català (ca-ES)
   • El canvi és immediat
   • Es guarda a "lang.config" per a futures sessions
   • TOT el programa (menús, missatges, informes) es tradueix

================================================================================
INFORMES I REGISTRES
================================================================================

La carpeta "logs/" conté tots els informes generats:

• Despliegue_Masivo_YYYYMMDD_HHMMSS.txt (Desplegament_Massiu)
  → Resultat del desplegament massiu amb detalls per equip

• Verificacion_YYYYMMDD_HHMMSS.csv (Verificació)
  → Informe de verificació en format CSV (Excel compatible)

• Altres registres generats automàticament per les operacions

Format de timestamp: Any-Mes-Dia_Hora-Minut-Segon

================================================================================
SOLUCIÓ DE PROBLEMES
================================================================================

PROBLEMA: "No es pot executar l'script"
SOLUCIÓ: Executar com a Administrador i verificar política d'execució:
         Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

PROBLEMA: "No es pot connectar a l'equip remot"
SOLUCIÓ: 
  1. Verificar que WinRM està habilitat (Opció [1])
  2. Verificar connectivitat de xarxa (ping a l'equip)
  3. Verificar credencials d'administrador
  4. Verificar firewall a l'equip destinació

PROBLEMA: "Els fons no s'apliquen"
SOLUCIÓ: 
  1. Tancar la sessió completament
  2. Iniciar la sessió novament
  3. Esperar 30-60 segons
  4. Si persisteix, verificar format PNG de les imatges

PROBLEMA: "No es pot revertir la configuració"
SOLUCIÓ: Executar el programa com a Administrador

================================================================================
NOTES IMPORTANTS
================================================================================

⚠ SEGURETAT:
  • SEMPRE executar com a Administrador
  • Les credencials NO s'emmagatzemen en cap arxiu
  • Les contrasenyes se sol·liciten de forma segura (ocultes)
  • Els scripts NO contenen credencials hardcodejades

✓ COMPATIBILITAT:
  • Imatges: PNG recomanat, JPG suportat
  • Windows 10 Pro/Enterprise o superior
  • PowerShell 5.1 o superior

⚠ REQUISITS REMOTS:
  • WinRM habilitat en equips destinació
  • Credencials d'administrador per a cada equip
  • Port 5985 (HTTP) o 5986 (HTTPS) obert al firewall

✓ MULTIIDIOMA:
  • Detecció automàtica de l'idioma del sistema
  • Canvi instantani entre idiomes
  • Tots els missatges, menús i informes traduïts
  • Configuració persistent entre sessions

⚠ CANVIS:
  • Requereixen tancar la sessió per aplicar-se completament
  • Les polítiques de bloqueig són permanents fins a revertir
  • La reversió elimina TOTES les configuracions aplicades

================================================================================
SUPORT I CONTACTE
================================================================================

Desenvolupador: Rubén Guerrero López | @jitodv
Github: https://github.com/jitodv
Versió: beta-0.1.0
Data: Desembre 2025

Per reportar problemes o suggeriments, documenta:
  • Versió del programa (beta-0.1.0)
  • Sistema operatiu i versió
  • Descripció detallada del problema
  • Missatges d'error (si n'hi ha)
  • Passos per reproduir el problema

================================================================================
                              Powered by jitodv
================================================================================
