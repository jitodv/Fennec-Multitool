# Logs / Registros / Registres

Este README explica qué contiene la carpeta `logs/`, cómo interpretar los
ficheros que genera la Multiherramienta Fennec y buenas prácticas para su
gestión y privacidad. La información está en Español, Català i English.

---

## Español

### ¿Para qué sirve esta carpeta?

La carpeta `logs/` almacena los informes y registros generados por las
operaciones del programa (despliegues masivos, verificaciones, errores,
etc.). Sirve para auditoría, resolución de incidencias y trazabilidad.

### Ficheros habituales

- `Despliegue_Masivo_YYYYMMDD_HHMMSS.txt`
  - Informe legible con el detalle por equipo del despliegue masivo.
  - Incluye resumen, lista de equipos procesados, éxito/fracaso y mensajes.

- `Verificacion_YYYYMMDD_HHMMSS.csv`
  - Informe de verificación en formato CSV (compatible con Excel/LibreOffice).
  - Encabezados típicos (ejemplo):
    `Hostname,Status,WallpaperExists,PoliciesApplied,LockedResolution,Notes,Timestamp`

- Otros logs generados automáticamente con prefijos explicativos.

### Formato de timestamps

Los nombres de fichero usan el formato `YYYYMMDD_HHMMSS` (p. ej. `20251203_153045`).
En el contenido humano puede aparecer el formato `YYYY-MM-DD_HH:MM:SS`.

### Privacidad y seguridad

- Los logs pueden contener hostnames, cuentas de usuario y resultados de
  operaciones, pero **no** deben contener contraseñas en claro.
- Mantén la carpeta `logs/` con permisos restringidos (solo Administradores).
- Si compartes un log para soporte, revisa y, si hace falta, anonimiza datos
  sensibles (hostnames, IPs) antes de enviarlos.

### Cómo abrir los informes

- Archivos `.txt`: abrir con cualquier editor de texto.
- Archivos `.csv`: abrir con Excel o usar PowerShell: `Import-Csv .\\Verificacion_....csv`.

---

## Català

### Per a què serveix aquesta carpeta?

La carpeta `logs/` emmagatzema els informes i registres generats per les
operacions de l'eina (desplegaments massius, verificacions, errors, etc.).
Serveix per a auditories, resolució d'incidències i traçabilitat.

### Fitxers habituals

- `Despliegue_Masivo_YYYYMMDD_HHMMSS.txt`
  - Informe llegible amb detall per equip del desplegament massiu.

- `Verificacion_YYYYMMDD_HHMMSS.csv`
  - Informe de verificació en format CSV (Excel/LibreOffice compatible).
  - Encapçalament d'exemple: `Hostname,Status,WallpaperExists,PoliciesApplied,LockedResolution,Notes,Timestamp`

### Format de timestamps

Els noms de fitxer fan servir `YYYYMMDD_HHMMSS` (p. ex. `20251203_153045`).

### Privacitat i seguretat

- Els logs poden contenir noms d'equip i noms d'usuari, però **no** contrasenyes en clar.
- Mantingueu permisos restringits a la carpeta `logs/` (Administradors només).
- Abans d'enviar un log per suport, anonimitzeu dades sensibles si cal.

### Com obrir els informes

- `.txt`: qualsevol editor de text.
- `.csv`: Excel/LibreOffice o `Import-Csv` a PowerShell.

---

## English

### What is this folder for?

The `logs/` folder stores reports and logs produced by the tool (mass
deployments, verifications, errors, etc.). It is used for auditing,
troubleshooting and traceability.

### Common files

- `Despliegue_Masivo_YYYYMMDD_HHMMSS.txt`
  - Human-readable report with per-host details for mass deployments.

- `Verificacion_YYYYMMDD_HHMMSS.csv`
  - Verification report in CSV format (Excel/LibreOffice compatible).
  - Typical header example:
    `Hostname,Status,WallpaperExists,PoliciesApplied,LockedResolution,Notes,Timestamp`

### Timestamps and filenames

Filenames use `YYYYMMDD_HHMMSS` (e.g. `20251203_153045`). Human-readable
timestamps in file content may use `YYYY-MM-DD_HH:MM:SS`.

### Privacy and security

- Logs may include hostnames and user accounts but **must not** contain plain
  text passwords.
- Restrict access to the `logs/` folder (Administrators only recommended).
- When sharing logs for support, sanitize or redact sensitive information.

### How to read the reports

- `.txt` files: open with any text editor.
- `.csv` files: open with Excel/LibreOffice or use PowerShell:
  `Import-Csv .\\Verificacion_YYYYMMDD_HHMMSS.csv`.

---

## Good practices

- Regularly rotate or archive old logs to save disk space.
- Do not commit logs to version control.
- Apply NTFS permissions so only authorized personnel can read logs.

## Need help?

If a log shows unexpected errors, please attach the relevant file (after
sanitizing sensitive data) when opening an issue or contacting the
maintainer.

Maintainer: jitodv — Version: beta-0.1.0 — Date: December 2025
logs
