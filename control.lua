require "defines"

script.on_event(defines.events.on_entity_died, function(event)
	if event.entity.name == "player" then
		event.entity.surface.create_entity{name = "corpse-chest", position = event.entity.position, force = game.forces.neutral}
		local theCorpse = event.entity.surface.find_entity('corpse-chest', event.entity.position)
		for index = 1, 2 do
			for itemName, itemCount in pairs(event.entity.get_inventory(index).get_contents()) do
				if theCorpse.can_insert{name = itemName, count = itemCount} then
					theCorpse.insert{name = itemName, count = itemCount}
				end
			end
		end
	end
end)