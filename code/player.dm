world
	mob = /player/connector
client
	perspective = EYE_PERSPECTIVE
	var
		player/player
	East()
		player.command(EAST)
	Northeast()
		player.command(NORTHEAST)
	North()
		player.command(NORTH)
	Northwest()
		player.command(NORTHWEST)
	West()
		player.command(WEST)
	Southwest()
		player.command(SOUTHWEST)
	South()
		player.command(SOUTH)
	Southeast()
		player.command(SOUTHEAST)
	Click(object, location, control, params)
		var/list/params_list = params2list(params)
		var/pixel_x = text2num(params_list["icon-x"])
		var/pixel_y = text2num(params_list["icon-y"])
		if(istype(location, /turf))
			if(istype(object, /actor))
				player.target_actor(object)
			else if(istype(object, /turf))
				player.target_location(location, pixel_x, pixel_y)
			else if(istype(object, /atom/movable))
				var/atom/movable/click_o = object
				var/offset_x = click_o.step_x + pixel_x
				var/offset_y = click_o.step_y + pixel_y
				player.target_location(location, offset_x, offset_y)
	MouseDrop(tile/drag_obj, atom/movable/over_obj, src_loc, over_loc, src_control, over_control, params)
		var/list/params_list = params2list(params)
		var/pixel_x = text2num(params_list["icon-x"])
		var/pixel_y = text2num(params_list["icon-y"])
		if(istype(drag_obj, /tile))
			var/offset_x// = drag_obj.step_x + pixel_x
			var/offset_y// = drag_obj.step_y + pixel_y
			if(istype(over_obj, /turf))
				offset_x = pixel_x - HOTSPOT_OFFSET
				offset_y = pixel_y - HOTSPOT_OFFSET
			else if(istype(over_obj, /atom/movable))
				offset_x = over_obj.step_x + pixel_x - HOTSPOT_OFFSET
				offset_y = over_obj.step_y + pixel_y - HOTSPOT_OFFSET
			player.move_tile(drag_obj, over_obj, offset_x, offset_y);


player
	parent_type = /driver
	connector
		parent_type = /mob
		var
			player/player
		Login()
			. = ..()
			loc = null
			if(!player)
				player = new(client)
			player.Login(client)
	New(client/new_client)
		. = ..()
		character = new
		focus(character)
		primary = melee_tile
		secondary = melee_tile
	var
		client/client
		actor/character
		tile/primary
		tile/secondary
	command(command)
		switch(command)
			if(EAST ) step(character, EAST )
			if(NORTH) step(character, NORTH)
			if(WEST ) step(character, WEST )
			if(SOUTH) step(character, SOUTH)
	proc
		Login(client/new_client)
			client = new_client
			client.player = src
			character = new(locate(50,50,1));
			client.eye = character
		target_location(turf/target_turf, offset_x, offset_y)
			character.act(move_tile, target_turf, offset_x, offset_y)
		target_actor(actor/target_actor)
			character.act(primary, target_actor)
		move_tile(tile/dragged, atom/over_obj, offset_x, offset_y)
			if(over_obj.Enter(dragged))
				dragged.screen_loc = null;
				client.screen.Remove(dragged)
			dragged.Move(over_obj, 0, offset_x, offset_y)