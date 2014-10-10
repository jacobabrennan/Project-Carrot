world
	mob = /player
client
	perspective = EYE_PERSPECTIVE
	show_popup_menus = FALSE
	//script = 'style.css'
	var
		player/player
player
	parent_type = /mob
	var
		character/character
		tile/primary
		tile/secondary
	Login()
		. = ..()
		loc = null
		client.player = src
		if(!character)
			character = new(locate(50,50,1));
		character.connect(src)
		client.eye = character
	proc
		target_location(turf/target_turf, offset_x, offset_y)
			character.act(character.tile_move, target_turf, offset_x, offset_y)
		target_actor(actor/target_actor, which)
			var/tile/action_tile
			if(which == PRIMARY) action_tile = primary
			else if(which == SECONDARY) action_tile = secondary
			if(action_tile)
				character.act(action_tile, target_actor)
		target_block(block/target_block, which, offset_x, offset_y)
			var/tile/action_tile
			if(which == PRIMARY) action_tile = primary
			else if(which == SECONDARY) action_tile = secondary
			if(action_tile && action_tile.target_class & TARGET_BLOCK)
				character.act(action_tile, target_block, offset_x, offset_y)
			else
				character.act(character.tile_move, target_block, offset_x, offset_y)