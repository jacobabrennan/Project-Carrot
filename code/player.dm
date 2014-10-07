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
			if(istype(object, /turf))
				player.target_location(location, pixel_x, pixel_y)
			else if(istype(object, /actor))
				player.target_actor(object)


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