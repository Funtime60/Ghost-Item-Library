local lib = require("__Ghost-Item-Library__.lib")

local selector = lib.generate_selector("giu-test-tool", lib.generate_icon_set(), lib.generate_select_mode({r = 0.5, g = 0.5, b = 0.5}))

data.extend({selector, lib.get_shortcut(selector), lib.get_key_sequence(selector, "ALT + P")})