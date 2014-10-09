turf
	Click(location, control, params)
		var/list/params_list = params2list(params)
		var/pixel_x = text2num(params_list["icon-x"])
		var/pixel_y = text2num(params_list["icon-y"])
		usr.client.player.target_location(location, pixel_x, pixel_y)
actor
	Click(location, control, params)
		if(istype(location, /turf))
			var/list/params_list = params2list(params)
			var/left = params_list["left"]
			var/right = params_list["right"]
			if(left)
				usr.client.player.target_actor(src, PRIMARY)
			else if(right)
				usr.client.player.target_actor(src, SECONDARY)
block
	Click(location, control, params)
		var/list/params_list = params2list(params)
		var/left = params_list["left"]
		var/right = params_list["right"]
		if(left)
			usr.client.player.target_block(src, PRIMARY)
		else if(right)
			usr.client.player.target_block(src, SECONDARY)


tile
	Click(location, control, params)
		var/list/params_list = params2list(params)
		var/pixel_x = text2num(params_list["icon-x"])
		var/pixel_y = text2num(params_list["icon-y"])
		if(istype(loc, /turf))
			// Move to tile's location
			var/offset_x = step_x + pixel_x
			var/offset_y = step_y + pixel_y
			usr.client.player.target_location(loc, offset_x, offset_y)
		if(istype(loc, /character/hud/hotbar))
			var/left = params_list["left"]
			var/right = params_list["right"]
			if(left)
				usr.client.player.character.hud.selection_display.select(src, PRIMARY)
			if(right)
				usr.client.player.character.hud.selection_display.select(src, SECONDARY)
	MouseDrop(atom/over_obj, src_loc, over_loc, src_control, over_control, params)
		var/list/params_list = params2list(params)
		var/pixel_x = text2num(params_list["icon-x"])
		var/pixel_y = text2num(params_list["icon-y"])
		var/offset_x// = drag_obj.step_x + pixel_x
		var/offset_y// = drag_obj.step_y + pixel_y
		if(istype(over_obj, /turf))
			offset_x = pixel_x - HOTSPOT_OFFSET
			offset_y = pixel_y - HOTSPOT_OFFSET
			Move(over_obj, 0, offset_x, offset_y)
		else if(istype(over_obj, /character/hud/hotbar))
			var/character/hud/hotbar/over_bar = over_obj
			offset_x = pixel_x - HOTSPOT_OFFSET
			offset_y = pixel_y - HOTSPOT_OFFSET

			// strangeness with the icon offset in the web client
			// further testing would be nice in order to file a bug report
			// 130 = height of the HUD object
			// 32 = tile height, presumably
			if(usr.client.connection == "web")
				pixel_y += 130 - 32 // TODO

			over_bar.add_tile(src, pixel_x, pixel_y)
		/*else if(istype(over_obj, /atom/movable))
			var/atom/movable/amoo = over_obj
			offset_x = amoo.step_x + pixel_x - HOTSPOT_OFFSET
			offset_y = amoo.step_y + pixel_y - HOTSPOT_OFFSET*/
tile/shared
	MouseDrop(atom/over_obj, src_loc, over_loc, src_control, over_control, params){}
	Click(location, control, params)
		var/list/params_list = params2list(params)
		var/left = params_list["left"]
		var/right = params_list["right"]
		if(left)
			usr.client.player.character.hud.selection_display.select(src, PRIMARY)
		if(right)
			usr.client.player.character.hud.selection_display.select(src, SECONDARY)