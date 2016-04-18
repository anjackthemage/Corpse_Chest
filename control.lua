require "defines"
function printf (message)
	local pList = game.players;
	for i, p in ipairs(pList) do
		p.print(message)
	end
end

function movePlayerItems (src, dst) 
	local item
	for n, c in pairs(src.get_contents()) do
		item = { name = n, count = c }
		if dst.can_insert(item) == true then
			-- printf(item.name .. " : " .. item.count)
			dst.insert(item)
		else
			printf("Error moving items - dst is full or cannot accept")
		end
	end
end

-- Will scan a grid around player position looking for an open spot.
function findEmptySpaceNearPlayer(player)
	-- printf("Debug entity name: " .. player.name .. " at " .. player.position["x"] .. ", " .. player.position["y"])
	-- Why does this not work? Assigning these values to these variables fails silently.
	-- local px = player.position["x'"]
	-- local py = player.position["y"]
	for offsetX = -10, 10 do
		for offsetY = -10, 10 do
			-- Cycle through each space within ~10 units of player. Check for 0 sized array return from find_entities
			if #player.surface.find_entities({{player.position["x"] + offsetX, player.position["y"] + offsetY}, {player.position["x"] + offsetX, player.position["y"] + offsetY}}) == 0 then
				return {player.position["x"] + offsetX, player.position["y"] + offsetY}
			end
		end
	end
	return nil
end

script.on_event(defines.events.on_entity_died, function(event)
	if event.entity.name == "player" then
		local player = event.entity
		local targetPos = findEmptySpaceNearPlayer(player)
		
		if targetPos == nil then
			printf("Nowhere to spawn chest.")
			return
		end
		-- Create the corpse-chest
		local cChest = player.surface.create_entity({name = "corpse-chest", position = targetPos, force = game.forces.neutral})
		
		if cChest == nil then
			printf("Corpse spawn - Failed.")
			return
		end
		
		-- Move each of the player's inventories over to the corpse-chest
		movePlayerItems(player.get_inventory(defines.inventory.player_guns), cChest)
		movePlayerItems(player.get_inventory(defines.inventory.player_ammo), cChest)
		movePlayerItems(player.get_inventory(defines.inventory.player_armor), cChest)
		movePlayerItems(player.get_inventory(defines.inventory.player_tools), cChest)
		movePlayerItems(player.get_inventory(defines.inventory.player_quickbar), cChest)
		movePlayerItems(player.get_inventory(defines.inventory.player_main), cChest)
	end
end)