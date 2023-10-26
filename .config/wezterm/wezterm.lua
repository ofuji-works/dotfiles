local wezterm = require 'wezterm'
local config = {}

config.color_scheme = 'BlueBerryPie'
config.font_size = 16.0

config.disable_default_key_bindings = true

local act = wezterm.action
config.keys = {
	{
		key = 'c',
		mods = 'SUPER',
		action = act.CopyTo 'Clipboard',
	},
	{
		key = 'v',
		mods = 'SUPER',
		action = act.PasteFrom 'Clipboard',
	},
	{
		key = 'k',
		mods = 'SUPER',
		action = act.ClearScrollback 'ScrollbackOnly',
	},
} 

return config

