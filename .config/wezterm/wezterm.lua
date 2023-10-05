local wezterm = require 'wezterm'
local config = {}

config.color_scheme = 'BlueBerryPie'
config.font_size = 16.0

config.disable_default_key_bindings = true

config.keys = {
	{
		key = 'c',
		mods = 'SUPER',
		action = wezterm.action.CopyTo 'Clipboard',
	},
	{
		key = 'v',
		mods = 'SUPER',
		action = wezterm.action.PasteFrom 'Clipboard'
	}
} 

return config

