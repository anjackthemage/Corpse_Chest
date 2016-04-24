data:extend({
{
    type = "container",
    name = "corpse-chest",
    icon = "__base__/graphics/icons/wooden-chest.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 5, results = {}},
    max_health = 50,
    corpse = "small-remnants",
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fast_replaceable_group = "container",
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    inventory_size = 160,
    open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" },
    close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" },
    vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 },
    picture =
    {
      filename = "__corpse-chest__/graphics/entity/corpse-chest/corpse-chest.png",
      priority = "extra-high",
      width = 60,
      height = 58,
      shift = {0.40625, -0.4375}
    }
  }
  })