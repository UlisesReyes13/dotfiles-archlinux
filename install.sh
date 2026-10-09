#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Arch Linux + Hyprland + Noctalia dotfiles installer
# ============================================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

info() {
    echo -e "${GREEN}==>${NC} $*"
}

warn() {
    echo -e "${YELLOW}==> ADVERTENCIA:${NC} $*"
}

fail() {
    echo -e "${RED}==> ERROR:${NC} $*"
    exit 1
}

# ============================================================
# Validaciones
# ============================================================

[[ -f /etc/arch-release ]] || fail "Este instalador está pensado para Arch Linux."

if [[ $EUID -eq 0 ]]; then
    fail "Ejecuta este script como usuario normal, no como root."
fi

info "Repositorio: $REPO_DIR"
info "Usuario: $USER"

# ============================================================
# Paquetes oficiales
# ============================================================

OFFICIAL_PACKAGES=(
    base-devel
    git
    less
    micro
    pciutils

    # Hyprland
    hyprland
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    hyprpolkitagent
    hyprlock
    hypridle

    # Shell
    noctalia

    # Sesión
    sddm

    # Terminal / aplicaciones
    kitty
    firefox
    fish
    thunar
    btop
    pavucontrol

    # Network
    networkmanager
    bluez
    bluez-utils
    blueman

    # Audio
    pipewire
    pipewire-audio
    pipewire-alsa
    pipewire-pulse
    wireplumber
    alsa-utils
    alsa-ucm-conf
    sof-firmware

    # Screenshots / Wayland
    grim
    slurp
    swappy
    wl-clipboard
    hyprpicker

    # Intel / Mesa
    mesa
    vulkan-intel
    intel-media-driver

    # Energía
    power-profiles-daemon
    thermald
    upower

    # Qt / Wayland
    qt6-wayland
    xcb-util-cursor

    # Fuentes
    ttf-dejavu
)

info "Actualizando sistema..."
sudo pacman -Syu --noconfirm

info "Instalando escritorio y herramientas..."

VALID_PACKAGES=()

for pkg in "${OFFICIAL_PACKAGES[@]}"; do
    if pacman -Si "$pkg" &>/dev/null; then
        VALID_PACKAGES+=("$pkg")
    else
        warn "Paquete no encontrado en repositorios: $pkg"
    fi
done

sudo pacman -S --needed --noconfirm "${VALID_PACKAGES[@]}"

# ============================================================
# NVIDIA
# ============================================================

if lspci 2>/dev/null | grep -qiE 'VGA|3D' | grep -qi NVIDIA; then
    info "GPU NVIDIA detectada."

    NVIDIA_PACKAGES=(
        nvidia-open
        nvidia-utils
    )

    # lib32 solo si multilib está habilitado
    if grep -Eq '^\[multilib\]' /etc/pacman.conf; then
        NVIDIA_PACKAGES+=(lib32-nvidia-utils)
    fi

    sudo pacman -S --needed --noconfirm "${NVIDIA_PACKAGES[@]}"
else
    info "No se detectó GPU NVIDIA; omitiendo drivers NVIDIA."
fi

# ============================================================
# yay
# ============================================================

if ! command -v yay >/dev/null 2>&1; then
    info "Instalando yay..."

    TMP_DIR="$(mktemp -d)"

    git clone https://aur.archlinux.org/yay-bin.git "$TMP_DIR/yay-bin"

    (
        cd "$TMP_DIR/yay-bin"
        makepkg -si --noconfirm
    )

    rm -rf "$TMP_DIR"
else
    info "yay ya está instalado."
fi

# ============================================================
# Paquetes AUR necesarios
# ============================================================

AUR_PACKAGES=(
    sddm-astronaut-theme
)

info "Instalando paquetes AUR..."

yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# ============================================================
# Backup
# ============================================================

info "Creando backup en:"
echo "    $BACKUP_DIR"

mkdir -p "$BACKUP_DIR"

backup_path() {
    local path="$1"

    if [[ -e "$path" || -L "$path" ]]; then
        local relative="${path#$HOME/}"
        mkdir -p "$BACKUP_DIR/$(dirname "$relative")"
        mv "$path" "$BACKUP_DIR/$relative"
    fi
}

# ============================================================
# Enlaces
# ============================================================

link_dir() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" ]]; then
        warn "No existe en el repo: $source"
        return
    fi

    mkdir -p "$(dirname "$target")"

    backup_path "$target"

    ln -s "$source" "$target"

    info "Enlace: $target"
}

link_file() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" ]]; then
        warn "No existe en el repo: $source"
        return
    fi

    mkdir -p "$(dirname "$target")"

    backup_path "$target"

    ln -s "$source" "$target"

    info "Enlace: $target"
}

# Configuraciones completas
link_dir "$REPO_DIR/.config/hypr"     "$HOME/.config/hypr"
link_dir "$REPO_DIR/.config/noctalia" "$HOME/.config/noctalia"
link_dir "$REPO_DIR/.config/kitty"    "$HOME/.config/kitty"

# Fish
if [[ -f "$REPO_DIR/.config/fish/config.fish" ]]; then
    mkdir -p "$HOME/.config/fish"
    link_file \
        "$REPO_DIR/.config/fish/config.fish" \
        "$HOME/.config/fish/config.fish"
fi

# Scripts propios
mkdir -p "$HOME/.local/bin"

if [[ -d "$REPO_DIR/.local/bin" ]]; then
    for script in "$REPO_DIR"/.local/bin/*; do
        [[ -f "$script" ]] || continue

        name="$(basename "$script")"

        link_file \
            "$script" \
            "$HOME/.local/bin/$name"
    done
fi

# Plugins Noctalia
if [[ -d "$REPO_DIR/.local/share/noctalia/plugins/dev-launcher" ]]; then
    mkdir -p "$HOME/.local/share/noctalia/plugins"

    link_dir \
        "$REPO_DIR/.local/share/noctalia/plugins/dev-launcher" \
        "$HOME/.local/share/noctalia/plugins/dev-launcher"
fi

# ============================================================
# SDDM Astronaut
# ============================================================

info "Configurando SDDM Astronaut..."

sudo mkdir -p /etc/sddm.conf.d

printf '%s\n' \
    '[Theme]' \
    'Current=sddm-astronaut-theme' \
    | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null

ASTRONAUT_METADATA="/usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop"

if [[ -f "$ASTRONAUT_METADATA" ]]; then
    sudo sed -i \
        's|^ConfigFile=.*|ConfigFile=Themes/japanese_aesthetic.conf|' \
        "$ASTRONAUT_METADATA"

    info "Preset SDDM: japanese_aesthetic"
else
    warn "No encontré metadata.desktop de SDDM Astronaut."
fi

# ============================================================
# Servicios
# ============================================================

info "Activando servicios..."

sudo systemctl enable NetworkManager
sudo systemctl enable sddm
sudo systemctl enable power-profiles-daemon

# thermald solo tiene sentido en Intel
if grep -qi GenuineIntel /proc/cpuinfo; then
    sudo systemctl enable thermald
fi

# Bluetooth puede no existir físicamente; habilitar el servicio no molesta
sudo systemctl enable bluetooth.service || true

# ============================================================
# Fish
# ============================================================

FISH_PATH="$(command -v fish || true)"

if [[ -n "$FISH_PATH" ]]; then
    CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

    if [[ "$CURRENT_SHELL" != "$FISH_PATH" ]]; then
        info "Cambiando shell predeterminado a Fish..."
        chsh -s "$FISH_PATH"
    fi
fi

# ============================================================
# Generados por Noctalia
# ============================================================

info "Preparando archivos generados..."

mkdir -p "$HOME/.config/hypr"

# Estos archivos son generados por Noctalia.
# Creamos placeholders para que hyprland.lua no falle antes
# de que Noctalia aplique sus plantillas.

if [[ ! -e "$HOME/.config/hypr/noctalia-colors.lua" ]]; then
    cat > "$HOME/.config/hypr/noctalia-colors.lua" <<'LUA'
-- Se genera automáticamente desde Noctalia.
LUA
fi

# ============================================================
# Permisos
# ============================================================

if [[ -d "$HOME/.local/bin" ]]; then
    chmod +x "$HOME"/.local/bin/* 2>/dev/null || true
fi

# ============================================================
# Resumen
# ============================================================

echo
echo "============================================================"
echo " Instalación terminada"
echo "============================================================"
echo
echo "Backup:"
echo "  $BACKUP_DIR"
echo
echo "Siguiente paso:"
echo
echo "  sudo reboot"
echo
echo "Después de entrar a Hyprland:"
echo
echo "  noctalia msg templates-apply"
echo
echo "  hyprctl reload"
echo "  hyprctl configerrors"
echo
echo "============================================================"
