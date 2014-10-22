client
	Move(){}
player/hud/hotbar/crafting
	Click(location, control, params)
		var/list/params_list = params2list(params)
		var/pixel_x = round(text2num(params_list["icon-x"]))
		var/pixel_y = round(text2num(params_list["icon-y"]))
		var/click_index = find_slot(pixel_x, pixel_y)
		if(click_index == 0)
			if(!(locate(/tile) in reference)) return
		//add_tile(new /player/hud/hotbar/crafting/tile_filler(), pixel_x, pixel_y)
			var result = recipe_manager.craft(player, reference.Copy())
			garbage.temp_storage(result)
			if(result)
				var/inv_space = FALSE
				for(var/I = 1 to player.hud.inventory.reference.len)
					if(!player.hud.inventory.reference[I])
						inv_space = I
						break
				if(inv_space)
					player.hud.inventory.add_tile(result, inv_space)
				else
					spawn(10)
						add_tile(result, 1)
player/hud/background
	Click(location, control, params)
		var/list/params_list = params2list(params)
		var/screen_loc = params_list["screen-loc"]
		var/sep_pos = findtext(screen_loc, ",")
		var/screen_x = copytext(screen_loc, 1, sep_pos)
		var/screen_y = copytext(screen_loc, sep_pos+1)
		sep_pos = findtext(screen_x, ":")
		var/screen_atom_x = text2num(copytext(screen_x, 1, sep_pos))
		var/screen_px_x   = text2num(copytext(screen_x, sep_pos+1))
		sep_pos = findtext(screen_y, ":")
		var/screen_atom_y = text2num(copytext(screen_y, 1, sep_pos))
		var/screen_px_y   = text2num(copytext(screen_y, sep_pos+1))
		var/map_size = ((world.view*2)+1)*world.icon_size
		var/offset_x = (screen_atom_x*world.icon_size)+screen_px_x - (map_size/2) - (world.icon_size)
		var/offset_y = (screen_atom_y*world.icon_size)+screen_px_y - (map_size/2) - (world.icon_size)
		var/center_x = (player.x*world.icon_size)+player.step_x+player.bound_x+player.bound_width /2
		var/center_y = (player.y*world.icon_size)+player.step_y+player.bound_y+player.bound_height/2
		var/target_x = center_x + offset_x
		var/target_y = center_y + offset_y
		var/target_atom_x = round(target_x/world.icon_size)
		var/target_atom_y = round(target_y/world.icon_size)
		var/target_px_x   = target_x%world.icon_size
		var/target_px_y   = target_y%world.icon_size
		player.target_location(locate(target_atom_x, target_atom_y, player.z), target_px_x, target_px_y)
turf
	Click(location, control, params)
		. = ..()
		var/player/P = usr
		if(!istype(P)) return
		var/list/params_list = params2list(params)
		var/pixel_x = text2num(params_list["icon-x"])
		var/pixel_y = text2num(params_list["icon-y"])
		P.target_location(location, pixel_x, pixel_y)
actor
	Click(location, control, params)
		var/player/P = usr
		if(!istype(P)) return
		if(istype(location, /turf))
			var/list/params_list = params2list(params)
			var/left = params_list["left"]
			var/right = params_list["right"]
			if(left)
				P.target_actor(src, PRIMARY)
			else if(right)
				P.target_actor(src, SECONDARY)
block
	Click(location, control, params)
		var/player/P = usr
		if(!istype(P)) return
		var/list/params_list = params2list(params)
		var/left = params_list["left"]
		var/right = params_list["right"]
		var/pixel_x = text2num(params_list["icon-x"])
		var/pixel_y = text2num(params_list["icon-y"])
		if(left)
			P.target_block(src, PRIMARY, pixel_x, pixel_y)
		else if(right)
			P.target_block(src, SECONDARY, pixel_x, pixel_y)
tile
	Click(location, control, params)
		var/player/P = usr
		if(!istype(P)) return
		var/list/params_list = params2list(params)
		var/pixel_x = text2num(params_list["icon-x"])
		var/pixel_y = text2num(params_list["icon-y"])
		if(istype(loc, /turf))
			// Move to tile's location
			var/offset_x = step_x + pixel_x
			var/offset_y = step_y + pixel_y
			P.target_location(loc, offset_x, offset_y)
		if(istype(loc, /player/hud/hotbar) || istype(loc, /tile/spell_book))
			var/left = params_list["left"]
			var/right = params_list["right"]
			if(left)
				P.hud.selection_display.select(src, PRIMARY)
			if(right)
				P.hud.selection_display.select(src, SECONDARY)
	MouseDrop(atom/over_obj, src_loc, over_loc, src_control, over_control, params)
		var/list/params_list = params2list(params)
		var/pixel_x = round(text2num(params_list["icon-x"]))
		var/pixel_y = round(text2num(params_list["icon-y"]))
		var/offset_x// = drag_obj.step_x + pixel_x
		var/offset_y// = drag_obj.step_y + pixel_y
		if(over_obj == usr)
			var/player/P = usr
			P.hud.inventory.add_tile(src)
		else if(istype(over_obj, /turf) || (istype(over_obj, /block) && !over_obj.density))
			offset_x = pixel_x - HOTSPOT_OFFSET
			offset_y = pixel_y - HOTSPOT_OFFSET
			var/turf/new_loc = locate(over_obj.x,over_obj.y,over_obj.z)
			if(!istype(loc, /turf))
				Move(usr.loc, 0, usr.step_x, usr.step_y, TRUE)
			Move(new_loc, 0, offset_x, offset_y)
		else if(istype(over_obj, /player/hud/hotbar))
			var/player/hud/hotbar/over_bar = over_obj
			offset_x = pixel_x - HOTSPOT_OFFSET
			offset_y = pixel_y - HOTSPOT_OFFSET
			over_bar.add_tile(src, pixel_x, pixel_y)
		/*else if(istype(over_obj, /atom/movable))
			var/atom/movable/amoo = over_obj
			offset_x = amoo.step_x + pixel_x - HOTSPOT_OFFSET
			offset_y = amoo.step_y + pixel_y - HOTSPOT_OFFSET*/
tile/default
	MouseDrop(atom/over_obj, src_loc, over_loc, src_control, over_control, params){}
	Click(location, control, params)
		var/player/P = usr
		if(!istype(P)) return
		var/list/params_list = params2list(params)
		var/left = params_list["left"]
		var/right = params_list["right"]
		if(left)
			P.hud.selection_display.select(src, PRIMARY)
		if(right)
			P.hud.selection_display.select(src, SECONDARY)
tile/move_animation
	mouse_opacity = 0
	New(tile/model, old_loc, old_x, old_y, new_loc, new_x, new_y)
		. = ..()
		translate(model, old_loc, old_x, old_y, new_loc, new_x, new_y)
	proc
		translate(tile/model, old_loc, old_x, old_y, new_loc, new_x, new_y)
			icon = model.icon
			icon_state = model.icon_state
			loc = old_loc
			step_x = old_x
			step_y = old_y
			Move(new_loc, 0, new_x, new_y)
			spawn(TILE_TRANSLATE_TIME)
				del src
