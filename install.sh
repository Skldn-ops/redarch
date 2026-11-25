#!/usr/bin/env bash
set -Eeuo pipefail

DOTFILES_REPO="https://github.com/Skldn-ops/redarch.git"
DOTFILES_SUBDIR="."

DOTFILES_PATHS=(.config .local .fonts .themes .icons .bashrc .bash_profile .profile .zshrc .zprofile .gitconfig .vimrc .gtkrc-2.0 .Xresources)

DISABLE_FAILLOCK=true
ENABLE_DOCKER=true
ENABLE_FSTRIM=true

TARGET_USER=$(id -un)
BACKUP_DIR="$HOME/.arch-setup-backups/$(date +%Y%m%d-%H%M%S)-$$"
WORK_DIR=""
trap 'printf "\nError on line %s. Copies: %s\n" "$LINENO" "$BACKUP_DIR" >&2' ERR
trap '[[ -z "$WORK_DIR" ]] || rm -rf -- "$WORK_DIR"' EXIT
step() { printf '\n=== %s ===\n' "$*"; }
fail() { printf '%s\n' "$*" >&2; exit 1; }

[[ $EUID -ne 0 ]] || fail 'Execute ./install.sh without sudo.'
[[ -n "$DOTFILES_REPO" ]] || fail 'DOTFILES_REPO NOT DEFINED'
[[ -f /etc/arch-release ]] || fail 'Only for Arch Linux.'
[[ -t 0 ]] || fail 'Launch script in interactive mode'

step 'Install Git'
sudo pacman -Syu --needed --noconfirm git

step 'Download repository'
git clone -- "$DOTFILES_REPO" "$WORK_DIR/dotfiles"

BASE_DIR="$WORK_DIR/dotfiles"
DOT_ROOT="$BASE_DIR/$DOTFILES_SUBDIR"

for file in packages.txt aur-packages.txt greetd/config.toml; do
    [[ -f "$BASE_DIR/$file" ]] || fail "No file $file"
done

[[ -d "$DOT_ROOT/.config" ]] || fail 'No .config directory'
sudo -v
mkdir -p -m 700 "$BACKUP_DIR" "$BACKUP_DIR/home" "$BACKUP_DIR/system"
WORK_DIR=$(mktemp -d)

backup_system() {
    local file=$1
    if sudo test -e "$file" || sudo test -L "$file"; then
        sudo mkdir -p "$BACKUP_DIR/system$(dirname "$file")"
        sudo cp -a -- "$file" "$BACKUP_DIR/system$file"
    fi
}
write_system() {
    local file=$1
    backup_system "$file"
    sudo install -d -m 755 "$(dirname "$file")"
    sudo tee "$file" >/dev/null
}

step 'Install official packages and fonts'
mapfile -t packages < <(awk 'NF && $1 !~ /^#/ {print $1}' "$BASE_DIR/packages.txt")
# rsync is an additional dependency for backup-aware dotfile deployment.
sudo pacman -Syu --needed --noconfirm "${packages[@]}" rsync

step 'Install yay'
if ! command -v yay >/dev/null; then
    git clone https://aur.archlinux.org/yay.git "$WORK_DIR/yay"
    (cd "$WORK_DIR/yay" && makepkg -si --noconfirm)
fi

step 'Install AUR packages'
mapfile -t aur_packages < <(awk 'NF && $1 !~ /^#/ && $1 != "yay" {print $1}' "$BASE_DIR/aur-packages.txt")
if ((${#aur_packages[@]})); then
    # Interactive by design: inspect PKGBUILDs and approve AUR builds.
    yay -S --needed "${aur_packages[@]}"
fi

step 'Rsync dotfiles to .config'
for path in "${DOTFILES_PATHS[@]}"; do
    [[ -e "$DOT_ROOT/$path" || -L "$DOT_ROOT/$path" ]] || continue
    mkdir -p "$HOME/$(dirname "$path")" "$BACKUP_DIR/home/$(dirname "$path")"
    # Copy directories into their parent; keep unrelated existing files.
    rsync -a --backup --backup-dir="$BACKUP_DIR/home/$(dirname "$path")" -- \
        "$DOT_ROOT/$path" "$HOME/$(dirname "$path")/"
done
# Restore executable bits through git/rsync; repair known session script if needed.
if [[ -f "$HOME/.config/hypr/scripts/session-menu.sh" ]]; then
    chmod +x "$HOME/.config/hypr/scripts/session-menu.sh"
fi

# step 'Dolphin: Foot as terminal'
# mkdir -p "$HOME/.config"
# if [[ -f "$HOME/.config/kdeglobals" ]]; then
#     cp -a "$HOME/.config/kdeglobals" "$BACKUP_DIR/home/kdeglobals-before-merge"
#     command -v kwriteconfig6 >/dev/null || fail 'Не найден kwriteconfig6 для изменения kdeglobals.'
#     kwriteconfig6 --file kdeglobals --group General --key TerminalApplication foot
#     kwriteconfig6 --file kdeglobals --group General --key TerminalService foot.desktop
# else
#     install -m 644 "$BASE_DIR/kdeglobals" "$HOME/.config/kdeglobals"
# fi

step 'Faillock configure'
if [[ "$DISABLE_FAILLOCK" == true ]]; then
    backup_system /etc/security/faillock.conf
    sudo sed -i -E '/^[[:space:]]*#?[[:space:]]*deny[[:space:]]*=/d' /etc/security/faillock.conf
    printf '\ndeny=0\n' | sudo tee -a /etc/security/faillock.conf >/dev/null
fi

step 'HandleLidSwitch=ignore'
write_system /etc/systemd/logind.conf.d/99-arch-setup-lid.conf <<'LID'
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
LID
# Do not restart logind in an active graphical session. Reboot later.

step 'Disable PC speaker'
printf 'blacklist pcspkr\n' | write_system /etc/modprobe.d/nobeep.conf
if [[ -d /sys/module/pcspkr ]]; then
    sudo modprobe -r pcspkr || printf 'pcspkr disabled.\n' >&2
fi

step 'NetworkManager + systemd-resolved + OpenVPN 3'
# Do not silently disable a different network backend.
for unit in systemd-networkd.service dhcpcd.service iwd.service; do
    if systemctl is-active --quiet "$unit"; then
        printf 'Warning: active %s\n' "$unit" >&2
    fi
done
printf '[main]\ndns=systemd-resolved\n' | write_system /etc/NetworkManager/conf.d/dns.conf
sudo systemctl enable --now systemd-resolved.service
sudo systemctl enable --now NetworkManager.service
if [[ $(readlink /etc/resolv.conf || true) != /run/systemd/resolve/stub-resolv.conf ]]; then
    backup_system /etc/resolv.conf
    if ! sudo test -e /etc/resolv.conf.backup && ! sudo test -L /etc/resolv.conf.backup; then
        if sudo test -e /etc/resolv.conf || sudo test -L /etc/resolv.conf; then
            sudo cp -a /etc/resolv.conf /etc/resolv.conf.backup
        fi
    fi
    sudo ln -sfn /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
fi
sudo openvpn3-admin netcfg-service --config-set systemd-resolved true
# Network restart can interrupt a connection. Ask before doing it immediately.
# read -r -p 'Restart NetworkManager now? [y/N] ' restart_nm
# if [[ "$restart_nm" =~ ^[yY]$ ]]; then
#     sudo systemctl restart NetworkManager.service
# else
#     printf 'New settings will be applied after reboot\n'
# fi

step 'greetd / tuigreet'
backup_system /etc/greetd/config.toml
sudo install -Dm644 "$BASE_DIR/greetd/config.toml" /etc/greetd/config.toml
# Do not start it now or forcibly replace an existing display manager.
sudo systemctl enable greetd.service

# if [[ -f "$BASE_DIR/vconsole.conf" ]]; then
#     step 'TTY font and keyboard'
#     backup_system /etc/vconsole.conf
#     sudo install -Dm644 "$BASE_DIR/vconsole.conf" /etc/vconsole.conf
# fi

step 'Docker и TRIM'
if [[ "$ENABLE_DOCKER" == true ]]; then
    sudo usermod -aG docker "$TARGET_USER"
    sudo systemctl disable docker.service docker.socket containerd
fi
if [[ "$ENABLE_FSTRIM" == true ]]; then
    sudo systemctl enable --now fstrim.timer
fi

step 'Fonts cache'
fc-cache -f
printf '\nDone. Backups: %s\n' "$BACKUP_DIR"
