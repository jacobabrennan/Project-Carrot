recipe
	ingredients = list("wood","wood")
	product = /tile/wooden_wall
tile/wooden_wall
	icon = 'wood_hut.dmi'
	icon_state = "tile_wall"
	var
		build_type = /block/wooden_wall
	Move(new_loc, new_dir, new_step_x, new_step_y)
		. = ..()
		if(istype(loc, /turf))
			var/turf/offset_turf = loc
			if(step_x+bound_x+(bound_width /2) >= world.icon_size)
				offset_turf = get_step(offset_turf, EAST)
			if(step_y+bound_y+(bound_height/2) >= world.icon_size)
				offset_turf = get_step(offset_turf, NORTH)
			new build_type(offset_turf)
			del src
block/wooden_wall
	opacity = TRUE
	icon = 'wood_hut.dmi'
	icon_state = "wall"
	resource = /tile/wood
	resource_amount = 1