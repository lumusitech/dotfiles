# 🚀 Omarchy 4 Dotfiles & Workstation Configuration

Repositorio de configuración y gestión de dotfiles para **Omarchy 4** (Arch Linux con Hyprland y capa de configuración en Lua), gestionado con **[Chezmoi](https://www.chezmoi.io/)**.

---

## 📂 Arquitectura del Repositorio

El repositorio versiona exclusivamente la **capa de usuario y personalizaciones** sobre los defaults de Omarchy:

* **Hyprland & Omarchy Overrides:**
  * `~/.config/hypr/bindings.lua`: Atajos de teclado dedicados (`SUPER + ALT + C` para calculadora/omacalc, `SUPER + R` para cliamp, `SUPER + M` para YT Music, `SUPER + N` para notas, `SUPER + ALT + M` para WhatsApp, `F9/F10` para Voxtype).
  * `~/.config/hypr/looknfeel.lua`: Reglas de ventanas flotantes y scratchpads dedicados.
  * `~/.config/hypr/input.lua`, `monitors.lua`, `autostart.lua`, `hyprland.lua`, `hyprsunset.conf`, `xdph.conf`.
  * `~/.config/omarchy/shell.json`, `shell.toml`, y hooks en `hooks/theme-set.d/omazed`.

* **Scripts de Interacción (`~/.local/bin/`):**
  * `toggle-calc`, `toggle-cliamp`, `toggle-ytmusic`, `toggle-notes`, `toggle-whatsapp`.
  * `open-google-sheet`, `open-google-workspace`, `drive-compress`, `notify-video-editor`.

* **Almacenamiento y Servicios Systemd:**
  * `~/.config/systemd/user/rclone-mount@.service`: Plantilla de montaje multi-cuenta para Google Drive (`drive-lumusika`, `drive-abc`, `drive-lumusitech`, `drive-carludev`).
  * `~/.config/gtk-3.0/bookmarks`: Marcadores persistentes de Nautilus para discos locales NTFS (`DATOS-2TB`, `BACKUP-1TB`, `BACKUP-4TB`) y carpetas Cloud.

* **Desarrollo y Terminal:**
  * `~/.bashrc`, `~/.bash_aliases`, `~/.bash_profile`.
  * `~/.config/starship.toml`: Prompt moderno.
  * `~/.config/mise/config.toml`: Control centralizado de runtimes (Node, Java 25, Bun, Go, Python).
  * `~/.config/git/config`, `~/.config/btop/btop.conf`.

* **Hooks Automáticos del Ciclo de Vida (Chezmoi):**
  * `run_onchange_after_01_nautilus.sh.tmpl`: Aplica optimizaciones de Nautilus y trackerignore.
  * `run_onchange_after_02_services.sh.tmpl`: Recarga y activa los 4 servicios de Rclone en `systemd --user`.
  * `run_onchange_after_03_mise.sh.tmpl`: Corre `mise install` automáticamente al clonar o cambiar de versiones.

---

## 🔄 Protocolo de Restauración desde Cero (Disaster Recovery)

Si se reinstala el sistema operativo desde cero:

### 1. Sistema Base
Instalar Omarchy 4 desde la ISO oficial y reiniciar.

### 2. Discos Físicos (/etc/fstab)
Configurar los montajes de discos NTFS en `/etc/fstab` según el archivo `omarchy4-storage-workflow-runbook.md`:
```bash
sudo mkdir -p /mnt/DATOS-2TB /mnt/BACKUP-1TB /mnt/BACKUP-4TB
sudo mount -a
```

### 3. Paquetes del Sistema
Instalar los paquetes base con pacman y yay:
```bash
sudo pacman -S --needed rclone fuse3 ntfs-3g btop fd ripgrep bat docker docker-compose
yay -S --needed onlyoffice-bin ttf-ms-fonts ttf-vista-fonts ttf-aptos-fonts
```

### 4. Desplegar Dotfiles con Chezmoi
```bash
# Si mise está instalado:
mise use -g chezmoi
# O con pacman: sudo pacman -S chezmoi

# Inicializar y aplicar tu repo de GitHub:
chezmoi init --apply https://github.com/<tu-usuario>/dotfiles.git
```

### 5. Configurar Credenciales de Google Drive
Copiar tu archivo seguro `rclone.conf` hacia `~/.config/rclone/rclone.conf` (puedes guiarte con `docs/rclone.conf.example`), o ejecutar `rclone config` para cada cuenta.

---

## 🛠️ Flujo de Trabajo Diario

* **Modificaste un archivo en tu sistema y quieres sincronizarlo:**
  ```bash
  chezmoi re-add
  chezmoi diff
  chezmoi git commit -m "feat: descripción del cambio"
  chezmoi git push
  ```
* **Ver qué cambios están pendientes:**
  ```bash
  chezmoi status
  ```
* **En otra máquina (descargar y aplicar cambios de GitHub):**
  ```bash
  chezmoi update
  ```
