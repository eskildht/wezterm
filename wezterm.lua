-- Pull in the wezterm API
local wezterm = require('wezterm')
local action = wezterm.action

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

local wallpapers = scan_dir('$HOME/.config/wezterm/wallpapers')
local wallpaper_index = math.random(1, #wallpapers);

config.window_background_image = wallpapers[wallpaper_index]
local default_hsb = {
  -- Darken the background image by reducing it 
  brightness = 0.2,
  -- You can adjust the hue by scaling its value.
  -- a multiplier of 1.0 leaves the value unchanged.
  hue = 1.0,
  -- You can adjust the saturation also.
  saturation = 1.0,
}
config.window_background_image_hsb = default_hsb

-- brightness decrement
wezterm.on('brightness-decrement', function(window, _)
  local overrides = window:get_config_overrides() or {}

  if not overrides.window_background_image_hsb then
    overrides.window_background_image_hsb = default_hsb
  end

  local brightness = overrides.window_background_image_hsb.brightness
  if (brightness - 0.1) < 0 then
    overrides.window_background_image_hsb.brightness = 1.0
  else
    overrides.window_background_image_hsb.brightness = brightness - 0.1
  end

  window:set_config_overrides(overrides)
end)

wezterm.on('wallpaper-next', function(window, _)
  local overrides = window:get_config_overrides() or {}

  if (wallpaper_index + 1) > #wallpapers then
    wallpaper_index = 1
  else
    wallpaper_index = wallpaper_index + 1
  end

  overrides.window_background_image = wallpapers[wallpaper_index]

  window:set_config_overrides(overrides)
end)

-- key mappings
config.keys = {
  -- pane navigation
  {
    key = "h",
    mods = "LEADER|CTRL",
    action = action.ActivatePaneDirection("Left"),
  },
  {
    key = "j",
    mods = "LEADER|CTRL",
    action = action.ActivatePaneDirection("Down"),
  },
  {
    key = "k",
    mods = "LEADER|CTRL",
    action = action.ActivatePaneDirection("Up"),
  },
  {
    key = "l",
    mods = "LEADER|CTRL",
    action = action.ActivatePaneDirection("Right"),
  },
  -- window split
  {
    key = "s",
    mods = "LEADER|CTRL",
    action = action.SplitVertical({
      domain = "CurrentPaneDomain"
    }),
  },
  {
    key = "v",
    mods = "LEADER|CTRL",
    action = action.SplitHorizontal({
      domain = "CurrentPaneDomain"
    }),
  },
  -- close pane
  {
    key = "x",
    mods = "LEADER|CTRL",
    action = action.CloseCurrentPane({
      confirm = false
    }),
  },
  -- brightness decrement loop around
  {
    key = 'b',
    mods = 'SUPER',
    action = action.EmitEvent('brightness-decrement'),
  },
  -- next wallpaper
  {
    key = 'l',
    mods = 'SUPER',
    action = action.EmitEvent('wallpaper-next'),
  },
  -- jump words
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = action.SendString('\x1bb'),
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = action.SendString('\x1bf'),
  },
}

-- and finally, return the configuration to wezterm
return config
