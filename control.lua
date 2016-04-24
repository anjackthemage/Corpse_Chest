require "defines"
-- This is for debug. Should probably remove this in the release version.
function printf (message)
	local pList = game.players;
	for i, p in ipairs(pList) do
		p.print(message)
	end
end

function copyPlayerItems(player, dest)
	local currStackIndex = 1
	local currStackContent
	local cursorStackContent = nil
	for inv = 1, 6 do
		for index = 1, #player.get_inventory(inv) do
			if player.get_inventory(inv)[index].valid_for_read then
				currStackContent = player.get_inventory(inv)[index]
				if dest.get_inventory(1)[currStackIndex].can_set_stack(currStackContent) then
					dest.get_inventory(1)[currStackIndex].set_stack(currStackContent)
					currStackIndex = currStackIndex + 1
				end
			end
		end
	end
	cursorStackContent = player.cursor_stack
	if dest.get_inventory(1)[currStackIndex].can_set_stack(cursorStackContent) then
		dest.get_inventory(1)[currStackIndex].set_stack(cursorStackContent)
	end
end

-- function movePlayerItems (src, dst) 
	-- local item
	-- for n, c in pairs(src.get_contents()) do
		-- item = { name = n, count = c }
		-- if dst.can_insert(item) == true then
			 -- printf(item.name .. " : " .. item.count)
			-- dst.insert(item)
		-- else
			-- printf("Error moving items - dst is full or cannot accept")
		-- end
	-- end
-- end

-- To track all the corpse chests in the world.
local corpseArray = {}

script.on_event(defines.events.on_entity_died, function(event)
	if event.entity.name == "player" then
		local player = event.entity
		local targetPos = player.surface.find_non_colliding_position("corpse-chest", player.position, 10, 1)
		
		if targetPos == nil then
			printf("Nowhere to spawn chest.")
			return
		end
		-- Create the corpse-chest
		local cChest = player.surface.create_entity({
			name = "corpse-chest", 
			position = targetPos, 
			force = game.forces.neutral
		})
		
		if cChest == nil then
			printf("Corpse spawn - Failed.")
			return
		end
		
		-- Move each of the player's inventories over to the corpse-chest
		-- movePlayerItems(player.get_inventory(defines.inventory.player_guns), cChest)
		-- movePlayerItems(player.get_inventory(defines.inventory.player_ammo), cChest)
		-- movePlayerItems(player.get_inventory(defines.inventory.player_armor), cChest)
		-- movePlayerItems(player.get_inventory(defines.inventory.player_tools), cChest)
		-- movePlayerItems(player.get_inventory(defines.inventory.player_quickbar), cChest)
		-- movePlayerItems(player.get_inventory(defines.inventory.player_main), cChest)
		copyPlayerItems(player, cChest)
		
		-- Start time, so we know when to destroy the chest.
		local expireTick = game.tick + 3600
		printf("Corpse created at " .. expireTick)
		
		table.insert(corpseArray, { dies=startTick, corpse=cChest })
		
		
	end
end)

-- Hook into the on_tick to check if chest should decay.
script.on_event(defines.events.on_tick, function(event)
	local corpseArray = remote.call("CorpseChest", "get_corpses")
	for index, object in pairs(corpseArray) do
			object["corpse"].destroy()
			printf("Corpse destroyed at " .. game.tick)
			table.remove(corpseArray, index)
		end
	end
end)

interface = {
	get_corpses = function() return corpseArray end
}

remote.add_interface("CorpseChest", interface)