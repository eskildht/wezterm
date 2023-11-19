-- Pull in the wezterm API
local wezterm = require('wezterm')
local act = wezterm.action

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'

-- alt handling
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

-- leader
config.leader = {
  key = "a",
  mods = "CTRL",
  timeout_milliseconds = 3000,
}

-- background
local function scan_dir(directory)
  local i, list, popen = 0, {}, io.popen
  for name in popen([[find "]] ..directory.. [[" -type f]]):lines() do
    i = i + 1
    list[i] = name
  end
  return list
end

local wallpapers = scan_dir('/Users/eskildht/.config/wezterm/wallpapers')

config.window_background_image = wallpapers[math.random(1, #wallpapers)]
config.window_background_image_hsb = {
  -- Darken the background image by reducing it to 1/3rd
  brightness = 0.2,
  -- You can adjust the hue by scaling its value.
  -- a multiplier of 1.0 leaves the value unchanged.
  hue = 1.0,
  -- You can adjust the saturation also.
  saturation = 1.0,
}

-- pane navigation
config.keys = {
  {
    key = "h",
    mods = "LEADER|CTRL",
    action = act.ActivatePaneDirection("Left"),
  },
  {
    key = "j",
    mods = "LEADER|CTRL",
    action = act.ActivatePaneDirection("Down"),
  },
  {
    key = "k",
    mods = "LEADER|CTRL",
    action = act.ActivatePaneDirection("Up"),
  },
  {
    key = "l",
    mods = "LEADER|CTRL",
    action = act.ActivatePaneDirection("Right"),
  },
  {
    key = "s",
    mods = "LEADER|CTRL",
    action = act.SplitVertical({
      domain = "CurrentPaneDomain"
    }),
  },
  {
    key = "v",
    mods = "LEADER|CTRL",
    action = act.SplitHorizontal({
      domain = "CurrentPaneDomain"
    }),
  },
  {
    key = "x",
    mods = "LEADER|CTRL",
    action = act.CloseCurrentPane({
      confirm = false
    }),
  },
}

-- and finally, return the configuration to wezterm
return config
