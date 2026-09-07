# 🪟 Activación Recomendada para Windows 11 Pro en VM (MAS)

Guía de activación comunitaria de código abierto para entornos virtuales y contenedores (`dockurr/windows`, QEMU/KVM) en Omarchy 4 / Linux.

---

## 💡 Contexto y Justificación

En entornos de desarrollo, laboratorios y máquinas virtuales sobre Linux, la solución estándar adoptada por la comunidad es **Microsoft Activation Scripts (MAS)**, respaldada por repositorios públicos auditables en GitHub ([massgravel/Microsoft-Activation-Scripts](https://github.com/massgravel/Microsoft-Activation-Scripts)).

### Ventajas en Entornos Virtuales y Contenedores
* **Cero riesgo de invalidación:** Al destruir, recrear o actualizar contenedores Docker o discos virtuales (`data.img`), las licencias comerciales corren el riesgo de invalidarse o agotarse por cambios en la firma del hardware emulado.
* **Seguridad e integridad:** No requiere descargar ejecutables externos sospechosos (`.exe`), parches de memoria ni desactivar Windows Defender. El script se ejecuta directamente en memoria a través de PowerShell oficial y su código fuente es 100% auditable.
* **Activación oficial y genuina:** Se comunica con los servidores oficiales de activación de Microsoft generando una licencia digital genuina vinculada al Hardware ID.

---

## 🚀 Procedimiento de Activación

1. **Iniciar la máquina virtual** con Windows 11 Pro (por ejemplo, mediante el lanzador de Omarchy o el contenedor de Windows).
2. **Abrir PowerShell como Administrador:**
   * Presiona `Win + X` y selecciona **Terminal (Administrador)** o **Windows PowerShell (Administrador)**.
3. **Ejecutar el comando oficial en una sola línea:**
   ```powershell
   irm https://get.activated.win | iex
   ```
4. **Seleccionar el método de activación deseado:**
   * **`[1] HWID` (Hardware ID digital persistente - Recomendado):** Genera una licencia digital permanente asociada a la firma de hardware virtual de la máquina. Permanece activa de por vida e incluso sobrevive a reinstalaciones del sistema operativo dentro de la misma VM.
   * **`[2] KMS38`:** Proporciona licenciamiento de volumen offline válido hasta el año 2038 (útil para máquinas virtuales aisladas o con políticas estrictas de red sin salida directa a internet).

El proceso toma solo unos segundos y no instala servicios en segundo plano ni altera binarios del sistema operativo.

---

## 🔗 Referencias Oficiales
* **Repositorio en GitHub:** [https://github.com/massgravel/Microsoft-Activation-Scripts](https://github.com/massgravel/Microsoft-Activation-Scripts)
* **Sitio y documentación oficial:** [https://massgrave.dev](https://massgrave.dev)
