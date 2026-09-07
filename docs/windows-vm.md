# 🪟 Windows 11 VM en Omarchy 4: Arquitectura y Lanzador Robusto

Guía de arquitectura, resolución de problemas y uso del lanzador de máquina virtual Windows 11 sobre Omarchy 4 (Arch Linux / Hyprland).

---

## 🏛️ Arquitectura del Sistema

En Omarchy 4, la máquina virtual con Windows 11 opera mediante una arquitectura híbrida de contenedor y virtualización por hardware:

1. **Virtualización KVM/QEMU en Contenedor (`dockurr/windows`):**
   * El servicio Docker administra el ciclo de vida del contenedor `omarchy-windows`.
   * Utiliza aceleración de hardware mediante `/dev/kvm` y adaptadores de red virtual `/dev/net/tun`.
   * Los datos persistentes del sistema operativo residen en `~/.windows/data.img` (montado de forma segura en `/storage`) y la carpeta compartida en `~/Windows` (montada en `/shared`).
2. **Acceso Gráfico de Alto Rendimiento (FreeRDP 3):**
   * En lugar de VNC lento, se utiliza el cliente nativo `xfreerdp3` conectándose directamente al puerto RDP `127.0.0.1:3389`.
   * Integra aceleración gráfica, portapapeles bidireccional, audio/micrófono y escala HiDPI automática sincronizada con el monitor enfocado en Hyprland.

---

## ⚠️ Diagnóstico: ¿Por qué fallaba el lanzador por defecto?

El script upstream `/usr/share/omarchy/bin/omarchy-windows-vm` presentaba una condición de carrera crítica al invocarse desde el menú de aplicaciones:

1. **Falso positivo de arranque (`up_wait`):** El contenedor Docker emite el mensaje `❯ Windows started successfully...` a los 3 segundos de iniciar, pero en ese momento QEMU apenas está ejecutando la BIOS/UEFI. Windows 11 todavía no ha cargado ni iniciado su servicio de Escritorio Remoto (`TermService`).
2. **Fallo de conexión inmediato en FreeRDP:** Al intentar conectar prematuramente a `127.0.0.1:3389`, la conexión es rechazada (`Connection reset by peer` / `Connection refused [111]`). FreeRDP aborta inmediatamente con código de error.
3. **Apagado automático involuntario (`KEEP_ALIVE=false`):** Al detectar la salida inmediata de FreeRDP, el script asumía que el usuario había finalizado su sesión y ejecutaba automáticamente `priv down` (`docker-compose down`), destruyendo el contenedor a los pocos segundos.
4. **Falta de retroalimentación (`Terminal=false`):** Como el lanzador `.desktop` no tiene terminal asociada, todos los mensajes de error se perdían silenciosamente en segundo plano.

---

## 🚀 Solución: Lanzador Robusto `launch-windows-vm`

Se implementó el script wrapper [`launch-windows-vm`](file:///home/carludev/.local/bin/launch-windows-vm) en `~/.local/bin/` y se actualizó el lanzador [windows-vm.desktop](file:///home/carludev/.local/share/applications/windows-vm.desktop):

### Mejoras incorporadas:
* **Sondeo activo de protocolo RDP:** Envía peticiones de conexión X.224 estándar en un bucle con límite de 60 segundos. Solo invoca a `xfreerdp3` cuando Windows 11 realmente responde y está listo para recibir la sesión.
* **Notificaciones de escritorio nativas:** Informa en tiempo real al usuario mediante `omarchy-notification-send`:
  * *Iniciando máquina virtual en segundo plano...*
  * *Esperando a que Windows 11 complete el inicio del sistema...*
  * *Conectando sesión de escritorio remoto...*
* **Manejo resiliente de permisos:** Sincroniza con las rutinas de seguridad de `omarchy-windows-vm` para montar unidades y pedir autorización Polkit solo cuando sea estrictamente necesario tras un reinicio.
* **Configuración Kerberos protegida:** Exporta automáticamente la configuración de `krb5.conf` con `dns_lookup_kdc = false` para evitar bloqueos de 23 segundos al conectar.
* **Escalado HiDPI dinámico:** Lee la escala activa del monitor actual en Hyprland (`hyprctl monitors -j`) y ajusta `/scale:140` o `/scale:180` si corresponde.
* **Ciclo de vida limpio:** Si la sesión termina normalmente, detiene el contenedor para ahorrar recursos de CPU y RAM. Si se desea mantener la VM encendida en segundo plano, admite el parámetro `-k` o `--keep-alive`.

---

## 💻 Uso y Comandos

### Desde la Interfaz Gráfica:
* Presiona `Super + Espacio` (o abre el menú de aplicaciones de Omarchy).
* Escribe **Windows** y presiona `Enter`.
* Verás las notificaciones de estado mientras la máquina arranca y se abrirá la sesión en pantalla completa.
* Para salir, desconéctate o cierra la barra flotante de FreeRDP (`Ctrl + Alt + Enter` para alternar pantalla completa).

### Desde la Terminal:
```bash
# Iniciar y conectar (se apaga al cerrar FreeRDP)
launch-windows-vm

# Iniciar y conectar manteniendo la VM encendida al salir de FreeRDP
launch-windows-vm --keep-alive

# Consultar estado del contenedor
omarchy-windows-vm status

# Detener la VM manualmente
omarchy-windows-vm stop
```

---

## 🐛 Bug Report y Estado Actual (Pendiente de Resolución)

### Comportamiento observado:
Al invocar `launch-windows-vm` (tanto desde Walker/menú de apps como desde terminal):
1. Se emiten las notificaciones de inicio y preparación:
   * *"Iniciando máquina virtual en segundo plano..."*
   * *"Esperando a que Windows 11 complete el inicio del sistema..."*
2. A los pocos segundos, sin llegar a renderizarse la ventana interactiva de `xfreerdp3`, se dispara la notificación:
   * *"Sesión cerrada. Deteniendo máquina virtual..."*
3. Como `KEEP_ALIVE=false` por defecto, el script interpreta el cierre inmediato de FreeRDP como el fin de la sesión del usuario y ejecuta `stop_vm_container` (`priv down`), apagando la VM.

### Diagnóstico preliminar e hipótesis:
* **Cierre prematuro del proceso `xfreerdp3`:** El cliente RDP puede estar cerrándose inmediatamente debido a validación de certificados TLS (`/cert:ignore`), parámetros incompatibles en modo pantalla completa sobre Wayland/Hyprland, o credenciales rechazadas.
* **Falso positivo de disponibilidad RDP:** Es posible que el sondeo X.224 en el puerto `127.0.0.1:3389` reciba una respuesta a nivel de socket antes de que el servicio `TermService` de Windows esté listo para iniciar la sesión gráfica de usuario.

### Hoja de ruta para resolver (Mañana):
- [ ] Desviar salida estándar y errores de FreeRDP a log permanente: `~/.local/state/windows-vm-rdp.log`.
- [ ] Ejecutar la VM con persistencia (`launch-windows-vm --keep-alive`) y probar la invocación directa y aislada de `xfreerdp3` en una terminal con `/log-level:DEBUG`.
- [ ] Ajustar flags de compatibilidad en FreeRDP (`/network:lan`, `/gfx`, etc.) o forzar backend X11/Wayland según convenga.

---

## 🔗 Referencias Relacionadas
* [Activación con Microsoft Activation Scripts (MAS)](windows-vm-activation.md)
* [Repositorio oficial dockurr/windows](https://github.com/dockur/windows)

