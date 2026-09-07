# ⚡ CachyOS Workstation: Storage, Apps, Cloud & Hyprland Runbook

Guía completa de aprovisionamiento, migración y configuración de workstation sobre **CachyOS** (Arch Linux con kernel optimizado BORE, repositorios x86-64-v3/v4 y seguridad estándar del sistema).

---

## 🏛️ ¿Por qué CachyOS?

1. **Rendimiento de Hardware:** Kernels personalizados compilados para microarquitecturas modernas (`x86-64-v3` / `v4`), planificador BORE y optimizaciones de latencia ideales para desarrollo y workstation.
2. **Seguridad Robusta:** Mantiene el modelo de seguridad estándar de Arch Linux / systemd (sudo con autenticación requerida, polkit no comprometido, sin abstracciones inseguras).
3. **Compatibilidad Arch pura:** Acceso total al ecosistema de Arch Linux, repositorios oficiales y AUR mediante `paru`.

---

## 📦 Fase 1: Paquetes y Herramientas Esenciales

Todos los comandos son **100% idempotentes** gracias a la bandera `--needed`.

### 1. Sistema, Terminal y Utilidades (Pacman)
```bash
sudo pacman -S --needed \
  rclone fuse3 ntfs-3g \
  btop fd ripgrep bat \
  docker docker-compose \
  mpv imv lazygit fastfetch eza socat freerdp libnotify foot jq
```

### 2. Paquetes AUR & Productividad (Paru)
```bash
paru -S --needed \
  mise-bin \
  voxtype-bin \
  onlyoffice-bin \
  ttf-ms-fonts ttf-vista-fonts ttf-aptos-fonts \
  galculator \
  translate-shell

# Actualizar caché de fuentes del sistema
fc-cache -fv
```

---

## 🔒 Fase 2: Configuración Segura de Docker

En CachyOS, Docker se ejecuta bajo el daemon estándar de sistema y el usuario se incorpora al grupo `docker` sin recurrir a elevaciones inseguras de sudoers:

```bash
# Habilitar e iniciar servicio Docker
sudo systemctl enable --now docker

# Agregar tu usuario al grupo docker (cerrar sesión y volver a entrar o 'newgrp docker')
sudo usermod -aG docker $USER
```

---

## 💽 Fase 3: Almacenamiento Local (Discos NTFS en `/etc/fstab`)

Montaje con permisos limpios para tu usuario (`uid=1000,gid=1000`):

```ini
# /etc/fstab
UUID=<UUID_DISCO_PERSONAL>  /mnt/Personal  ntfs-3g  defaults,uid=1000,gid=1000,umask=022,nofail,windows_names  0  0
UUID=<UUID_DISCO_TRABAJO>   /mnt/Trabajo   ntfs-3g  defaults,uid=1000,gid=1000,umask=022,nofail,windows_names  0  0
```

Crear puntos de montaje:
```bash
sudo mkdir -p /mnt/Personal /mnt/Trabajo
sudo mount -a
```

---

## ☁️ Fase 4: Cloud Storage (Rclone + Google Drive + OneDrive)

1. Restaurar `~/.config/rclone/rclone.conf` con las credenciales de tus cuentas remotas.
2. Chezmoi activará automáticamente los servicios systemd de usuario:
   * `rclone-mount@lumusika`
   * `rclone-mount@abc`
   * `rclone-mount@carludev`
   * `rclone-mount@lumusitech`
   * `onedrive-mount@lumusitec`
   * `onedrive-mount@carludev`
3. Monitorear los montajes:
```bash
systemctl --user status rclone-mount@* onedrive-mount@*
```

---

## 🚀 Fase 5: Despliegue de Dotfiles con Chezmoi

En una instalación limpia de CachyOS:

```bash
# 1. Instalar chezmoi
sudo pacman -S --needed chezmoi git

# 2. Inicializar y aplicar dotfiles
chezmoi init --apply https://github.com/lumusitech/dotfiles.git

# 3. Recargar entorno Hyprland
hyprctl reload
```

---

## 🪟 Fase 6: Virtualización Windows 11 VM en CachyOS

1. **Estructura limpia en el espacio de usuario:**
   Los archivos de configuración de la VM residen en `~/.config/windows/docker-compose.yml` y las credenciales en `~/.config/windows/credentials`.
2. **Lanzador unificado:**
   Invoca directamente `launch-windows-vm` (o desde el menú de aplicaciones).
   El script detecta automáticamente el entorno de CachyOS y gestiona el ciclo de vida del contenedor Docker sin dependencias externas.
3. **Diagnósticos en tiempo real:**
   `tail -f ~/.local/state/windows-vm-rdp.log`
