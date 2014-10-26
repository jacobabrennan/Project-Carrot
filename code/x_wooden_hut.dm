recipe/bed
	ingredients = list("wood", "wood", "wood", "wood")
	product = /tile/bed
tile/bed
	icon = 'wood_hut.dmi'
	icon_state = "tile_bed"
	construct = /block/bed
block/bed // Hazordhu Totem
	icon = 'wood_hut.dmi'
	icon_state = "bed"
	// 9x9, range(4)
	density = TRUE
	layer = BLOCK_OVER_LAYER
	resource = /tile/wood
	resource_amount = 1
	resource_delay = 100
	bound_x = 6
	bound_y = 4
	bound_width = 20
	bound_height = 26
	interact = TRUE
	New()
		. = ..()
		if(usr)
			set_owner(usr)
	var
		owner_ckey
	interact(actor/user)
		user.adjust_health(user.max_health())
	proc
		set_owner(player/new_owner)
			owner_ckey = new_owner.ckey
			var/bed_tag = "[owner_ckey]_start"
			var/block/bed/old_bed = locate(bed_tag)
			del old_bed
			tag = bed_tag

recipe/wooden_floor
	ingredients = list("wood")
	product = /tile/wooden_floor
tile/wooden_floor
	icon = 'wood_hut.dmi'
	icon_state = "tile_floor"
	construct = /block/wooden_floor
block/wooden_floor
	icon = 'wood_hut.dmi'
	icon_state = "floor"
	density = FALSE
	layer = BLOCK_UNDER_LAYER
	resource = /tile/wood
	resource_amount = 1
	resource_delay = 100

recipe/wooden_wall
	ingredients = list("wood","wood")
	product = /tile/wooden_wall
tile/wooden_wall
	icon = 'wood_hut.dmi'
	icon_state = "tile_wall"
	construct = /block/wooden_wall
block/wooden_wall
	opacity = TRUE
	icon = 'wood_hut.dmi'
	icon_state = "wall"
	resource = /tile/wood
	resource_amount = 1
	resource_delay = 100

recipe/wooden_door
	ingredients = list("wood","wood","wood")
	product = /tile/wooden_door
tile/wooden_door
	icon = 'wood_hut.dmi'
	icon_state = "tile_door"
	construct = /block/wooden_door
block/wooden_door
	opacity = TRUE
	icon = 'wood_hut.dmi'
	icon_state = "door"
	resource = /tile/wood
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


recipe/wooden_window
	ingredients = list("wood","wood","radish")
	product = /tile/wooden_window
tile/wooden_window
	icon = 'wood_hut.dmi'
	icon_state = "tile_window"
	construct = /block/wooden_window
block/wooden_window
	opacity = TRUE
	icon = 'wood_hut.dmi'
	icon_state = "window"
	resource = /tile/wood
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