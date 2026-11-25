#!/usr/bin/env bash
set -euo pipefail
choice=$(printf '  Заблокировать\n  Спящий режим\n󰗽 Выйти из Hyprland\n󰜉  Перезагрузить\n󰐥  Выключить\n' | rofi -dmenu -i -p 'Сеанс' || true)
case "$choice" in
  *Заблокировать*) hyprlock ;;
  *'Спящий режим'*) systemctl suspend ;;
  *'Выйти из Hyprland'*) hyprctl dispatch 'hl.dsp.exit()' ;;
  *Перезагрузить*) systemctl reboot ;;
  *Выключить*) systemctl poweroff ;;
esac
