# Omarchy 4 Setup: Storage, Apps, Cloud & Backup Runbook

Runbook de aprovisionamiento rapido para Omarchy 4. Cubre montajes NTFS en /mnt, sincronizacion multicuenta de Google Drive con Rclone/FUSE3 y systemd, stack de aplicaciones, estrategia de backups y optimizaciones del sistema.

---

## 1. Ecosistema de Aplicaciones

### 1.1. Ofimatica y Documentos
Objetivo: compatibilidad nativa y fidelidad con el ecosistema Microsoft 365.
* **OnlyOffice Desktop Editors:** Asociado predeterminado para docx, xlsx, pptx.
* **Tipografias MS:** Evita deformaciones de maquetado en documentos compartidos.

```bash
yay -S --needed onlyoffice-bin ttf-ms-fonts ttf-vista-fonts ttf-aptos-fonts
fc-cache -fv
```

### 1.2. Almacenamiento, FUSE y Navegacion
Objetivo: integracion de discos fisicos, nubes y respuesta instantanea en Nautilus.
* **Rclone & FUSE3:** Sincronizacion y montaje en tiempo real de Google Drive.
* **NTFS-3G:** Driver con soporte completo de lectura y escritura para discos Windows.
* **Python-GObject:** Resuelve dependencias de extensiones de Nautilus evitando cuelgues.

```bash
sudo pacman -S --needed rclone fuse3 ntfs-3g python-gobject
```

### 1.3. Desarrollo, Terminal y Utilitarios
Objetivo: monitoreo preciso de hardware, busqueda ultra rapida y virtualizacion ligera.
* **Btop:** Monitoreo moderno de CPU, GPU, RAM y procesos en tiempo real.
* **Fd & Ripgrep:** Reemplazos optimizados en Rust para find y grep.
* **Bat:** Visualizador de archivos con resaltado de sintaxis e integracion Git.
* **Docker & Docker Compose:** Contenedorizacion local para desarrollo.

```bash
sudo pacman -S --needed btop fd ripgrep bat docker docker-compose
sudo usermod -aG docker $USER
```

---

## 2. Discos Locales NTFS (Automount fijo en /mnt)

Comportamiento: Montaje permanente en /mnt con UID/GID de usuario (1000), umask 022 y flag nofail para evitar bloqueos durante el arranque.

```bash
# 1. Crear directorios
sudo mkdir -p /mnt/DATOS-2TB /mnt/BACKUP-1TB /mnt/BACKUP-4TB

# 2. Agregar entradas a /etc/fstab (validar UUIDs con 'lsblk -f')
sudo tee -a /etc/fstab << 'FSTAB_EOF'
UUID=TU_UUID_DATOS-2TB    /mnt/DATOS-2TB    ntfs-3g  defaults,uid=1000,gid=1000,umask=022,nofail  0  0
UUID=F2BA16E0BA16A161     /mnt/BACKUP-1TB   ntfs-3g  defaults,uid=1000,gid=1000,umask=022,nofail  0  0
UUID=B8A0029FA002646A     /mnt/BACKUP-4TB   ntfs-3g  defaults,uid=1000,gid=1000,umask=022,nofail  0  0
FSTAB_EOF

# 3. Recargar y montar
sudo systemctl daemon-reload
sudo mount -a

# 4. Marcadores persistentes en Nautilus (panel lateral)
cat << 'GTK_EOF' >> ~/.config/gtk-3.0/bookmarks
file:///mnt/DATOS-2TB DATOS-2TB
file:///mnt/BACKUP-1TB BACKUP-1TB
file:///mnt/BACKUP-4TB BACKUP-4TB
GTK_EOF
```

---

## 3. Google Drive con Rclone (Systemd User Services)

Plantilla de servicio guardada en ~/.config/systemd/user/rclone-mount@.service:

```ini
[Unit]
Description=Rclone Mount for %i
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStartPre=-/usr/bin/fusermount3 -uz %h/Drive/%i
ExecStart=/usr/bin/rclone mount drive-%i: %h/Drive/%i   --config=%h/.config/rclone/rclone.conf   --vfs-cache-mode full   --vfs-cache-max-age 48h   --vfs-cache-max-size 20G   --dir-cache-time 168h   --poll-interval 1m   --attr-timeout 10m   --drive-export-formats link.html   --drive-pacer-min-sleep 10ms   --drive-chunk-size 64M   --vfs-read-ahead 64M   --buffer-size 32M   --vfs-fast-fingerprint   --transfers 8   --checkers 16   --no-modtime   --no-checksum
ExecStop=/usr/bin/fusermount3 -uz %h/Drive/%i
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
```

Activacion de las 4 cuentas:
```bash
mkdir -p ~/Drive/{lumusika,abc,carludev,lumusitech}
systemctl --user daemon-reload
systemctl --user enable --now rclone-mount@lumusika rclone-mount@abc rclone-mount@carludev rclone-mount@lumusitech
```

---

## 4. Estrategia de Copias de Seguridad (Backups)

Estrategia 3-2-1 distribuida entre almacenamiento rapido, resguardo secundario y archivo historico:
* **Nivel 1 (Produccion/Activo):** DATOS-2TB para proyectos en curso, repositorios y uso diario.
* **Nivel 2 (Respaldo en caliente):** BACKUP-1TB para sincronizacion rapida incremental de DATOS-2TB.
* **Nivel 3 (Almacenamiento masivo/Frio):** BACKUP-4TB para imagenes ISO, instaladores, proyectos cerrados y archivos multimedia pesados.
* **Nivel 4 (Nube off-site):** Sincronizacion directa Rclone hacia cuentas seleccionadas (carludev / lumusitech).

### 4.1. Respaldo Local Incremental con Rsync
```bash
# Sincronizar DATOS a BACKUP-1TB excluyendo temporales de desarrollo
rsync -avhP --delete --exclude='node_modules/' --exclude='.venv/' --exclude='.git/' /mnt/DATOS-2TB/Proyectos/ /mnt/BACKUP-1TB/Sync-Proyectos/

# Mover o sincronizar archivos historicos pesados hacia BACKUP-4TB
rsync -avhP /mnt/DATOS-2TB/Historico/ /mnt/BACKUP-4TB/Archivo/
```

### 4.2. Respaldo Local hacia Google Drive (Rclone Sync directo)
```bash
# Sincronizar carpeta local con la nube sin necesidad de pasar por el montaje FUSE
rclone sync /mnt/DATOS-2TB/Proyectos drive-carludev:BackupProyectos --transfers 8 --checkers 16 --fast-list -P
```

---

## 5. Optimizaciones de Rendimiento y Correcciones de Sistema

* **Nautilus / Tracker (Eliminar demoras de 40s en red):**
```bash
touch ~/Drive/.trackerignore
gsettings set org.gnome.nautilus.preferences show-directory-item-counts 'local-only'
gsettings set org.gnome.nautilus.preferences show-image-thumbnails 'local-only'
```

* **Fontconfig (Resolver warnings xsi:nil y constantes invalidas):**
```bash
sudo rm -f /etc/fonts/conf.d/48-guessfamily.conf /etc/fonts/conf.d/48-spacing.conf /etc/fonts/conf.d/49-sansserif.conf
sudo pacman -S --needed fontconfig
fc-cache -r -v
```

* **Omarchy 4 - Windows VM (Permisos 700 y eliminación de bit setgid):**
Omarchy 4 implementa aislamiento de monturas en `/var/lib/omarchy/windows/mounts/users/<uid>/` y valida estrictamente que `~/.windows` y `~/Windows` tengan permisos `700`. Si `~/Windows` posee el bit `setgid` activo (`2700`, común en carpetas compartidas/Samba), el pre-vuelo de monturas falla silenciosamente y bloquea tanto el inicio (`launch`) como la desinstalación (`remove`).
```bash
# Limpiar el bit setgid (00700) y forzar permisos 700
chmod 00700 ~/Windows ~/.windows
```

* **Suspensión Profunda / Prevención de Despertar Instantáneo (Instant Wake):**
Evita que eventos espurios en buses PCIe (dispositivos NVMe, interfaces de red) o periféricos USB (sensores de ratón óptico) despierten el equipo de inmediato tras suspender. Se configura una unidad systemd oneshot antes de `sleep.target` para deshabilitar los triggers en sysfs, permitiendo que la máquina solo se reactive presionando el botón físico de encendido (*Power*):
```bash
sudo tee /etc/systemd/system/disable-wakeup-triggers.service << 'EOF'
[Unit]
Description=Disable PCIe/USB wakeup triggers to prevent instant resume
Before=sleep.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'for dev in /sys/bus/pci/devices/*/power/wakeup; do [ -f "$dev" ] && echo disabled > "$dev" 2>/dev/null || true; done; for dev in /sys/bus/usb/devices/*/power/wakeup; do [ -f "$dev" ] && echo disabled > "$dev" 2>/dev/null || true; done'

[Install]
WantedBy=sleep.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable disable-wakeup-triggers.service
```
