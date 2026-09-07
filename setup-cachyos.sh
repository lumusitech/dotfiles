#!/usr/bin/env bash
# ==============================================================================
# setup-cachyos.sh - Aprovisionamiento automatizado e idempotente para CachyOS
#
# Configura el sistema base, instala paru, dependencias de desarrollo,
# stack de voz Voxtype (Whisper + traducción), herramientas y Docker.
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}==>${NC} $1"; }
log_success() { echo -e "${GREEN}==>${NC} $1"; }
log_warn() { echo -e "${RED}==>${NC} $1"; }

echo "======================================================================"
echo "🚀 Iniciando aprovisionamiento de Workstation en CachyOS"
echo "======================================================================"

# 1. Asegurar Paru (CachyOS no lo incluye en las ISOs recientes por defecto)
log_info "1/5 Verificando gestor AUR (Paru)..."
if ! command -v paru >/dev/null 2>&1; then
  log_info "Instalando paru desde los repositorios oficiales de CachyOS..."
  sudo pacman -S --needed --noconfirm paru
else
  log_success "Paru ya se encuentra instalado."
fi

# 2. Paquetes del Sistema Base, Terminal y Neovim (Pacman)
log_info "2/5 Instalando paquetes base y herramientas de desarrollo..."
sudo pacman -S --needed --noconfirm \
  rclone fuse3 ntfs-3g \
  neovim gcc make tree-sitter-cli \
  ripgrep fd fzf bat btop \
  git lazygit \
  unzip tar curl wget jq \
  docker docker-compose \
  mpv imv fastfetch eza socat foot \
  ttf-jetbrains-mono-nerd chezmoi

# 3. Paquetes AUR & Productividad (Paru)
log_info "3/5 Instalando paquetes de AUR con Paru (Voxtype, Mise, OnlyOffice, Galculator)..."
paru -S --needed --noconfirm \
  voxtype-bin \
  translate-shell \
  mise-bin \
  onlyoffice-bin \
  galculator

# 4. Actualizar caché de fuentes
log_info "4/5 Actualizando caché de fuentes tipográficas..."
fc-cache -fv >/dev/null 2>&1 || true

# 5. Servicio Docker
log_info "5/5 Habilitando servicio Docker..."
sudo systemctl enable --now docker
if ! groups "$USER" | grep -q '\bdocker\b'; then
  log_info "Agregando al usuario $USER al grupo docker..."
  sudo usermod -aG docker "$USER"
  log_warn "Nota: Recuerda reiniciar o ejecutar 'newgrp docker' para usar Docker sin sudo."
else
  log_success "Usuario $USER ya pertenece al grupo docker."
fi

echo "======================================================================"
log_success "¡Aprovisionamiento de paquetes y servicios completado con éxito!"
echo "======================================================================"
