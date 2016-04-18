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
			printf(item.name .. " : " .. item.count)
			dst.insert(item)
		else
			printf("Error moving items - dst is full or cannot accept")
		end
	end
end

script.on_event(defines.events.on_entity_died, function(event)
	if event.entity.name == "player" then
		local player = event.entity
		-- Create the corpse-chest
		local cChest = player.surface.create_entity({name = "corpse-chest", position = event.entity.position, force = game.forces.neutral})
		
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