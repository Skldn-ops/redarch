-- Springlike and smooth, without drawn-out transitions (~250-450ms).
hl.curve("soft_out", { type = "bezier", points = { {0.22, 1.0}, {0.36, 1.0} } })
hl.curve("soft_inout", { type = "bezier", points = { {0.76, 0.0}, {0.24, 1.0} } })
hl.animation({ leaf = "windows", enabled = true, speed = 1.5, bezier = "soft_out", style = "popin 89%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "soft_out", style = "popin 92%" })
hl.animation({ leaf = "fade", enabled = true, speed = 1.5, bezier = "soft_out" })
hl.animation({ leaf = "border", enabled = true, speed = 2.5, bezier = "soft_out" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.5, bezier = "soft_inout", style = "slidefade 18%" })
hl.animation({ leaf = "layers", enabled = true, speed = 1.5, bezier = "soft_out", style = "fade" })
