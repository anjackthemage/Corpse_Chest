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
	local sInv -- source inventory
	local dInv = dest.get_inventory(1) -- destination inventory
	for inv = 1, 6 do
		sInv = player.get_inventory(inv)
		for index = 1, #sInv do
			if sInv[index].valid_for_read then
				currStackContent = sInv[index]
				if dInv[currStackIndex].can_set_stack(currStackContent) then
					dInv[currStackIndex].set_stack(currStackContent)
					currStackIndex = currStackIndex + 1
				end
			end
		end
	end
	cursorStackContent = player.cursor_stack
	if dInv[currStackIndex].can_set_stack(cursorStackContent) then
		dInv[currStackIndex].set_stack(cursorStackContent)
	end
end

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
		copyPlayerItems(player, cChest)
		
		-- When will the chest decay?
		local expireTick = game.tick + 3600
		
		table.insert(corpseArray, { dies=expireTick, corpse=cChest })
		
		
	end
end)

-- Hook into the on_tick to check if chest should decay.
script.on_event(defines.events.on_tick, function(event)
	local corpseArray = remote.call("CorpseChest", "get_corpses")
	for index, object in pairs(corpseArray) do
		if game.tick > object["dies"] then
			object["corpse"].destroy()
			table.remove(corpseArray, index)
		end
	end
end)

interface = {
	get_corpses = function() return corpseArray end
}

remote.add_interface("CorpseChest", interface)