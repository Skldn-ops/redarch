local M = "SUPER"
local function bind(keys, dispatcher)
  hl.bind(keys, dispatcher)
end
local function cmd(keys, command)
  bind(keys, hl.dsp.exec_cmd(command))
end


bind(M .. " + Page_Down", hl.dsp.focus({ workspace = "r+1" }))
bind(M .. " + Page_Up", hl.dsp.focus({ workspace = "r-1" }))

cmd(M .. " + Q", "foot")
--cmd(M .. " + Q", "foot bash -ic 'q; exec bash'")
-- cmd(M .. " + P", "hyprlock")
cmd(M .. " + T", "Telegram")
cmd(M .. " + E", "dolphin")
--- cmd(M .. " + R", "ranger")
bind(M .. " + C", hl.dsp.window.close())
cmd(M .. " + D", "rofi -show drun")
bind(M .. " + SHIFT + C", hl.dsp.reload_config())
cmd(M .. " + SHIFT + E", "sh ~/.config/hypr/scripts/session-menu.sh")
-- Выделить область и скопировать в буфер обмена
cmd("SUPER + SHIFT + S", "sh -c 'grim -g \"$(slurp)\" - | wl-copy'")
-- Сохранить весь экран в буфер обмена
cmd("SHIFT + Print", "sh -c 'grim - | wl-copy'")

-- Movement: Vim-style + arrows, both with Shift for moving windows.
local directions = { H = "left", J = "down", K = "up", L = "right",
                     Left = "left", Down = "down", Up = "up", Right = "right" }
for key, direction in pairs(directions) do
  bind(M .. " + " .. key, hl.dsp.focus({ direction = direction }))
  bind(M .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end

-- Numbers: 1-0 -> 1-10, shifted sends focused window and STAYS on source workspace.
for index = 1, 10 do
  local key = index == 10 and "0" or tostring(index)
  bind(M .. " + " .. key, hl.dsp.focus({ workspace = tostring(index) }))
  bind(M .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(index) }))
end

bind(M .. " + B", hl.dsp.layout("preselect r"))  -- Next tile next to current
bind(M .. " + V", hl.dsp.layout("preselect d"))  -- Next tile below current
bind(M .. " + E", hl.dsp.layout("togglesplit")) -- Flip current split
bind(M .. " + F", hl.dsp.window.fullscreen())
bind(M .. " + SHIFT + SPACE", hl.dsp.window.float())
-- cmd(M .. " + SPACE", "hyprctl switchxkblayout all next")
hl.bind(
    "SUPER + SPACE",
    hl.dsp.exec_cmd("hyprctl switchxkblayout current next"),
    { locked = true }
)

bind(M .. " + S", hl.dsp.group.toggle())
bind(M .. " + W", hl.dsp.group.next())

bind(M .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:scratch" }))
bind(M .. " + minus", hl.dsp.workspace.toggle_special("scratch"))

bind(M .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
  local resizing = {
    H = {x=-10, y=0}, Left = {x=-10, y=0},
    J = {x=0, y=10}, Down = {x=0, y=10},
    K = {x=0, y=-10}, Up = {x=0, y=-10},
    L = {x=10, y=0}, Right = {x=10, y=0},
  }
  for key, delta in pairs(resizing) do
    hl.bind(key, hl.dsp.window.resize({ x = delta.x, y = delta.y, relative = true }), { repeating = true })
  end
  hl.bind("Return", hl.dsp.submap("reset"))
  hl.bind("Escape", hl.dsp.submap("reset"))
end)

-- Window drag/resize with SUPER + mouse
hl.bind(M .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(M .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media keybinds work at lockscreen
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.25 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true })
cmd("Print", "grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png")
