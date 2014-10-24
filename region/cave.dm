cave
	parent_type = /region
	//luminosity = 1
	spawn_rate = 196
	ambient_hue = 0
	ambient_saturation = 0
	ambient_value = 0
	enemy_groups = list(
		list(/cave/enemy/jel_1,/cave/enemy/jel_1,/cave/enemy/jel_1),
		list(/cave/enemy/jel_2),
		list(/cave/enemy/jel_2,/cave/enemy/jel_1)
	)
	turf
		parent_type = /turf
		icon = 'cave.dmi'
		dirt
			icon_state = "dirt_1"
			New()
				. = ..()
				icon_state = pick("dirt_1", "dirt_2")
	block
		parent_type = /block
		icon = 'cave.dmi'
		var
			load_bearing = FALSE
		gather()
			if(load_bearing)
				for(var/turf/support in orange(3, src))
					// 1: Determine if roof weight can be carried by surrounding block.
					var/weight = 16
					for(var/turf/T in orange(3, support))
						var/supported = FALSE
						for(var/cave/block/B in T)
							if(B.load_bearing)
								supported = max(supported, B.load_bearing)
						if(supported)
							weight -= supported
						else
							weight += 1
					if(weight > 0)
						usr << {"<span class="feedback">You cannot gather from this, it is supporting too much weight. (Try building stone walls around it).</span>"}
						return FALSE
			. = ..()

		rock_face
			icon_state = "rock_face"
			load_bearing = 2
			opacity = TRUE
			resource = /tile/stone
			resource_amount = 2
			resource_delay = 50
			gather()
				. = ..()
				if(!.)
					icon_state = "dug_out"
		rock_solid
			icon_state = "rock_solid"
			load_bearing = 4
			opacity = TRUE
		iron
			icon_state = "rock_iron"
			load_bearing = 2
			opacity = TRUE
			resource = /tile/iron_ore
			resource_amount = 2
			resource_delay = 50
		coal
			icon_state = "rock_coal"
			load_bearing = 2
			opacity = TRUE
			resource = /tile/coal
			resource_amount = 6
			resource_delay = 50
		amethyst
			icon_state = "rock_amethyst"
			bp_cost = 10
			load_bearing = FALSE
			opacity = TRUE
			resource = /tile/amethyst
			resource_amount = 1
			resource_delay = 50
			New()
				. = ..()
				light_source = new(loc, 210, 1, 0.25,5)


recipe/cave_bed
	ingredients = list("stone","stone","stone","stone")
	product = /tile/cave_bed
tile/cave_bed
	icon = 'cave.dmi'
	icon_state = "tile_bed"
	construct = /cave/block/bed
cave/block/bed // Hazordu Totem
	parent_type = /block/bed
	resource = /tile/stone
	icon = 'cave.dmi'

recipe/stone_floor
	ingredients = list("stone")
	product = /tile/stone_floor
tile/stone_floor
	icon = 'cave.dmi'
	icon_state = "tile_floor"
	construct = /cave/block/stone_floor
cave/block/stone_floor
	icon = 'cave.dmi'
	icon_state = "floor"
	density = FALSE
	layer = BLOCK_UNDER_LAYER
	resource = /tile/stone
	resource_amount = 1
	resource_delay = 100

recipe/stone_wall
	ingredients = list("stone","stone")
	product = /tile/stone_wall
tile/stone_wall
	icon = 'cave.dmi'
	icon_state = "tile_wall"
	construct = /cave/block/stone_wall
cave/block/stone_wall
	opacity = TRUE
	icon = 'cave.dmi'
	icon_state = "wall"
	load_bearing = 8
	resource = /tile/stone
	resource_amount = 1
	resource_delay = 100

recipe/stone_door
	ingredients = list("stone","stone","stone")
	product = /tile/stone_door
tile/stone_door
	icon = 'cave.dmi'
	icon_state = "tile_door"
	construct = /cave/block/stone_door
cave/block/stone_door
	opacity = TRUE
	icon = 'cave.dmi'
	icon_state = "door"
	resource = /tile/stone
	resource_amount = 1
	resource_delay = 100
	interact = TRUE
	var
		open = FALSE
	interact(actor/user)
		if(open)
			close()
		else
			open()
	proc
		open()
			open = TRUE
			density = FALSE
			change_opacity(FALSE)
			icon_state = "door_open"
		close()
			open = FALSE
			density = TRUE
			change_opacity(TRUE)
			icon_state = "door"


recipe/stone_window
	ingredients = list("stone","stone","stone","glass")
	product = /tile/stone_window
tile/stone_window
	icon = 'cave.dmi'
	icon_state = "tile_window"
	construct = /cave/block/stone_window
cave/block/stone_window
	opacity = TRUE
	icon = 'cave.dmi'
	icon_state = "window"
	resource = /tile/stone
	resource_amount = 1
	resource_delay = 100
	interact = TRUE
	var
		open = FALSE
	interact(actor/user)
		if(open)
			close()
		else
			open()
	proc
		open()
			open = TRUE
			change_opacity(FALSE)
			icon_state = "window_open"
		close()
			open = FALSE
			change_opacity(TRUE)
			icon_state = "window"

recipe/stone_chest
	ingredients = list("stone","stone","iron","iron")
	product = /tile/stone_chest
tile/stone_chest
	icon = 'cave.dmi'
	icon_state = "tile_chest"
	construct = /cave/block/stone_chest
cave/block/stone_chest
	parent_type = /block/storage
	opacity = FALSE
	icon = 'cave.dmi'
	icon_state = "chest"
	resource = /tile/iron
	resource_amount = 1
	resource_delay = 100

recipe/amethyst_podium
	ingredients = list("stone","amethyst")
	product = /tile/amethyst_podium
tile/amethyst_podium
	icon = 'cave.dmi'
	icon_state = "tile_amethyst_podium"
	construct = /cave/block/amethyst_podium
cave/block/amethyst_podium
	opacity = FALSE
	icon = 'cave.dmi'
	icon_state = "amethyst_podium"
	resource = /tile/amethyst
	resource_amount = 1
	resource_delay = 100
//	luminosity = 6
	bound_width = 16
	bound_x = 8
	bound_height = 24
	interact = TRUE
	interact(player/player)
		return new /info(player, null, 'info_top_mountains.png', "This is a Podium. It is made of Amethyst crystal and stone, and gives off a clear light. It reminds you of home.")
	var
		light_intensity = 0.25
		light_radius = 256
		light_color = "#ffffff"
		hue = 210
	New()
		. = ..()
		light_source = new(loc, hue, 0.5, 0.25)
		return
		/*lighting = new(loc)
		lighting.mouse_opacity = 0
		lighting.layer = EFFECTS_LAYER
		lighting.bound_x = bound_x
		lighting.bound_y = bound_y
		lighting.bound_width = bound_width
		lighting.bound_height = bound_height
		lighting.center(src)
		lighting.icon = 'rectangles.dmi'
		lighting.icon_state = "lighting"
		lighting.alpha = light_intensity * 255
		lighting.color = light_color
		lighting.blend_mode = BLEND_MULTIPLY
		var/matrix/M = matrix()
		M.Scale(light_radius/16)
		lighting.transform = M*/



recipe/fire_1
	ingredients = list("coal")
	product = /tile/fire/_1
recipe/fire_2
	ingredients = list("coal","coal")
	product = /tile/fire/_2
recipe/fire_3
	ingredients = list("coal","coal","coal")
	product = /tile/fire/_3
recipe/fire_4
	ingredients = list("coal","coal","coal","coal")
	product = /tile/fire/_4
tile/fire
	icon = 'cave.dmi'
	icon_state = "tile_fire"
	construct = /cave/block/fire
	_1{ construct = /cave/block/fire{light_reach = 6; life_span = 1200}}
	_2{ construct = /cave/block/fire{light_reach = 8; life_span = 1800}}
	_3{ construct = /cave/block/fire{light_reach = 10; life_span = 2400}}
	_4{ construct = /cave/block/fire{light_reach = LIGHT_REACH; life_span = 3000}}
cave/block/fire
	opacity = FALSE
	density = FALSE
	icon = 'cave.dmi'
	icon_state = "fire"
	resource_delay = 100
	ignore = TRUE
	var
		life_span = 1800
		light_reach = LIGHT_REACH
	New()
		. = ..()
		light_source = new(loc, 30, 0.2, 0.7, light_reach)
		if(life_span >= 0)
			spawn()
				var/original_lifespan = life_span
				while(life_span > 0)
					sleep(300)
					life_span -= 300
					del light_source
					if(life_span <= 0) del src
					light_source = new(loc, 60, 0.2, 0.7*(life_span/original_lifespan), light_reach)

recipe/amethyst_ring
	ingredients = list("ring","amethyst")
	product = /tile/charm/amethyst_ring
tile/charm/amethyst_ring
	icon = 'equipment.dmi'
	icon_state = "amethyst_ring"
	resource = "ring"

cave/enemy
	parent_type = /enemy
	icon = 'enemies.dmi'
	jel_1
		icon_state = "jel_green"
		//tile_attack = new /tile/test/radish_bow()
		bound_x = 2
		bound_y = 2
		bound_height = 20
		bound_width = 20
		base_speed = 2
		/*New()
			. = ..()
			var/tile/weapon/weapon_tile = pick(/tile/test/radish_bow, /tile/test/carrot_sword)
			tile_attack = new weapon_tile()*/
	jel_2
		icon_state = "jel_red"
		//tile_attack = new /tile/test/radish_bow()
		base_health = 3
		bound_x = 2
		bound_y = 2
		bound_height = 20
		bound_width = 20
		base_speed = 3
		/*New()
			. = ..()
			var/tile/weapon/weapon_tile = pick(/tile/test/radish_bow, /tile/test/carrot_sword)
			tile_attack = new weapon_tile()*/