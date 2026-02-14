#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- Prompt helper ----
confirm() {
    read -rp "$1 [Y/n]: " ans
    case "$ans" in
        [Nn]*) return 1 ;;
        *) return 0 ;;
    esac
}

sudo -v || { echo "Need sudo"; exit 1; }
[ "$EUID" -eq 0 ] && echo "Run as user, not root" && exit 1

LOGFILE="$HOME/setup.log"
exec > >(tee -i "$LOGFILE")
exec 2>&1

echo "=== Setup started at $(date) ==="

echo "Checking internet..."
ping -c 1 archlinux.org >/dev/null || { echo "No internet"; exit 1; }

# -------------------------

if confirm "Run system update?"; then
    sudo pacman -Syu --noconfirm git curl zsh
    sudo pacman -S --needed --noconfirm base-devel
fi

# -------------------------

if confirm "Install paru AUR helper?"; then
    mkdir -p "$HOME/.cache"
    cd "$HOME/.cache"

    if ! command -v paru >/dev/null; then
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd "$HOME"
    fi
fi

# -------------------------

if confirm "Install core AUR packages?"; then
    paru -S --noconfirm \
        zoxide exa fastfetch neovim fzf \
        ttf-jetbrains-mono-nerd cava \
        || echo "Some packages failed"
fi

# -------------------------

if confirm "Install extra applications?"; then
    paru -S --noconfirm \
        visual-studio-code-bin zen-browser-bin freedownloadmanager \
        btop powertop python-uv pycharm vlc \
        github-desktop-plus-bin parsec-bin obsidian-bin kdeconnect \
        bottles wine-staging obs-studio python portaudio \
        helium-browser-bin tailscale trayscale \
        python-setuptools-reproducible patool \
        python-pathvalidate python-fvs python-vkbasalt \
        srcrpy hollywood \
        || echo "Some packages failed"
fi

# -------------------------

if confirm "Clean paru cache?"; then
    paru -Scc --noconfirm
    cd "$HOME"
    rm -rf "$HOME/.cache/paru"
fi

# -------------------------

if confirm "Enable Bluetooth & KDE Connect services?"; then
    sudo systemctl enable bluetooth --now
    systemctl --user enable kdeconnect.service --now 2>/dev/null || true
fi

# -------------------------

if confirm "Install Oh My Zsh?"; then
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        RUNZSH=no CHSH=no sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# -------------------------

if confirm "Install Powerlevel10k theme?"; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k" 2>/dev/null || true
fi

# -------------------------

if confirm "Install Zsh plugins?"; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true

    git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true

    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" 2>/dev/null || true
fi

# -------------------------

if confirm "Install LazyVim?"; then
    if [ ! -d ~/.config/nvim ]; then
        git clone https://github.com/LazyVim/starter ~/.config/nvim
        rm -rf ~/.config/nvim/.git
    fi
fi

# -------------------------

if confirm "Copy configs, themes and .zshrc?"; then
    echo "Copying from $SCRIPT_DIR/.config"
    ls -R "$SCRIPT_DIR/.config" || echo "No config folder!"

    echo "Script dir: $SCRIPT_DIR"

    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local"

    # Copy .config safely
    if [ -d "$SCRIPT_DIR/.config" ]; then
        cp -rnv "$SCRIPT_DIR/.config/." "$HOME/.config/"
    else
        echo "No .config folder found in $SCRIPT_DIR"
    fi

    # Copy .local safely
    if [ -d "$SCRIPT_DIR/.local" ]; then
        cp -rnv "$SCRIPT_DIR/.local/." "$HOME/.local/"
    else
        echo "No .local folder found in $SCRIPT_DIR"
    fi

    # Copy .zshrc safely
    if [ -f "$SCRIPT_DIR/.zshrc" ]; then
        if [ "$SCRIPT_DIR/.zshrc" != "$HOME/.zshrc" ]; then
            cp -v "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
        else
            echo ".zshrc already in place, skipping"
        fi
    fi

    # Copy .p10k.zsh safely
    if [ -f "$SCRIPT_DIR/.p10k.zsh" ]; then
        if [ "$SCRIPT_DIR/.p10k.zsh" != "$HOME/.p10k.zsh" ]; then
            cp -v "$SCRIPT_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
        else
            echo ".p10k.zsh already in place, skipping"
        fi
    fi

fi

# -------------------------

echo "=== Done! ==="
echo "Log saved to $LOGFILE"

if confirm "Set Zsh as default shell?"; then
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s "$(which zsh)"
    fi
fi