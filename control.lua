local lib = require("__Ghost-Item-Utilities__.lib")


lib.register_selector_all(function(event)
	local player = game.players[event.player_index or 1]
	player.print(serpent.block(event))
end)