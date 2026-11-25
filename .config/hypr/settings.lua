-- Original palette: #10100e, #c40233, #9d00ff, #ff1493.
-- Gentle modern treatment: thinner borders + soft lavender instead of full neon.
hl.config({
  general = {
    gaps_in = 1,
    gaps_out = 1,
    border_size = 1,
    layout = "dwindle",
    col = {
      active_border = { colors = { "rgba(c40233ee)", "rgba(b891f5ee)" }, angle = 40 },
      inactive_border = "rgba(5b4b6d66)",
    },
    resize_on_border = true,
  },
  decoration = {
    rounding = 15,
    rounding_power = 2.2,
    active_opacity = 1,
    inactive_opacity = 1,
    fullscreen_opacity = 1.0,
    dim_inactive = true,
    dim_strength = 0.055,
    shadow = {
      enabled = true,
      range = 18,
      render_power = 2,
      color = "rgba(08060bbb)",
    },
    blur = {
      enabled = true,
      size = 5,
      passes = 2,
      new_optimizations = true,
      ignore_opacity = true,
      xray = false,
    },
  },
  animations = { enabled = true },
  input = {
    kb_layout = "us,ru",
    kb_options = "",
    follow_mouse = 1,
    accel_profile = "adaptive",
    sensitivity = 0.5,
    left_handed = false,
    repeat_rate = 50,
    repeat_delay = 200,
    touchpad = {
      disable_while_typing = true,
      natural_scroll = true,
      scroll_factor = 2.5,
      middle_button_emulation = false,
      tap_button_map = "lrm",
      clickfinger_behavior = true,
      tap_to_click = true,
      tap_and_drag = true,
      drag_lock = 0,
    },
  },
  dwindle = {
    preserve_split = true,
    smart_resizing = true,
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },
})
