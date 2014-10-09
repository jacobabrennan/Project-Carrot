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
	ingredients = list("wood","wood","carrot")
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
			opacity = FALSE
			icon_state = "door_open"
		close()
			open = FALSE
			density = TRUE
			opacity = TRUE
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
	New()
		. = ..()
		open()
	interact(actor/user)
		if(open)
			close()
		else
			open()
	proc
		open()
			open = TRUE
			opacity = FALSE
			icon_state = "window_open"
		close()
			open = FALSE
			opacity = TRUE
			icon_state = "window"