hl.layer_rule({ match = { namespace = "waybar" }, blur = true, ignore_alpha = 0.15 })
hl.layer_rule({ match = { namespace = "rofi" }, blur = true, ignore_alpha = 0.18 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.15 })
-- Keep utility dialogs floating rather than awkwardly tiled.
hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true, center = true, size = { 850, 590 } })
hl.workspace_rule({
	workspace = "w[tv1]",
	border_size = 0,
})
