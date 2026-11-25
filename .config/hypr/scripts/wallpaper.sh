#!/usr/bin/env bash
set -euo pipefail
# Your old wallpaper is not in the supplied archive.
# Copy it to ~/.config/hypr/wallpaper.png or keep the original location.
if [[ -f "$HOME/.config/hypr/wallpaper.png" ]]; then
    exec swaybg -i "$HOME/.config/hypr/wallpaper.png" -m fill
elif [[ -f "$HOME/Pictures/wallpapers/neon-blow-up.png" ]]; then
    exec swaybg -i "$HOME/Pictures/wallpapers/neon-blow-up.png" -m fill
else
    exec swaybg -c '#10100e'
fi
