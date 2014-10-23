world
	mob = /player

client
	perspective = EYE_PERSPECTIVE
	show_popup_menus = FALSE
	//script = 'style.css'

player
	parent_type = /actor
	//sight = SEE_PIXELS // Causes problems with the HUD*
	see_in_dark = 3
	infra_luminosity = 12
	icon = 'shadow.dmi'
	icon_state = "rough"
	bound_x = 8
	bound_width = 16
	bound_height = 16
	var
		tile/primary
		tile/secondary
		build_points = 0
		player/logout_timer/logout_timer
		color_assigned = FALSE
	New()
		. = ..()
		spawn()
			while(!map_handler.loaded)
				sleep(10)
			respawn()
			light_source = new(loc, 0, 0, 0.2, 3)

	Login()
		. = ..()
		if(logout_timer)
			del logout_timer
		// Assign random but consistent color using md5(key)
		if(!color_assigned)
			var/hash_browns = md5(key)
			var/hue = 0
			for(var/II = 1 to length(hash_browns))
				hue += text2ascii(hash_browns, II)
			hue %= 360
			color_assigned = hsv2rgb(hue, 0.7, 0.2)
			color_assigned = rgb(
				color_assigned["red"  ] * 255,
				color_assigned["green"] * 255,
				color_assigned["blue" ] * 255
			)
			if(key == "Kaiochao") color_assigned = rgb(0, 0, 128)
			var/icon/I = icon(icon)
			I.SwapColor(rgb(0,51,51), color_assigned)
			icon = I
		//
		connect(src)
	Logout()
		. = ..()
		logout_timer = new(src)
	die()
		. = ..()
		spawn()
			action = null
			respawn()
	proc
		respawn(override)
			if(!fexists("player_saves/[ckey].sav"))
				tutorial_manager.create_tutorial(src)
				return
			var/block/bed/player_bed = locate("[ckey]_start")
			var/start_tile = player_bed? locate(player_bed.x, player_bed.y, player_bed.z) : (locate(TOWN_START) || locate(50,50,1))
			assign_loc(start_tile)
			if(light_source)
				light_source.Move(start_tile)
			if(player_bed)
				center(player_bed)
			else
				step_x = 0
				step_y = 0
			adjust_health(max_health())
		target_location(turf/target_turf, offset_x, offset_y)
			act(tile_move, target_turf, offset_x, offset_y)
		target_actor(actor/target_actor, which)
			var/tile/action_tile
			if(which == PRIMARY) action_tile = primary
			else if(which == SECONDARY) action_tile = secondary
			if(action_tile)
				act(action_tile, target_actor)
		target_block(block/target_block, which, offset_x, offset_y)
			var/tile/action_tile
			if(which == PRIMARY) action_tile = primary
			else if(which == SECONDARY) action_tile = secondary
			if(action_tile && action_tile.target_class & TARGET_BLOCK)
				act(action_tile, target_block, offset_x, offset_y)
			else
				act(tile_move, target_block, offset_x, offset_y)
		adjust_bp(amount)
			build_points = max(0, build_points + amount)
			hud.bp_display.adjust(build_points)

	hurt(amount, actor/attacker, tile/proxy)
		if(hud.equipment.body)
			amount = min(amount, hud.equipment.body.defend(src, attacker, amount))
		. = 0
		if(amount < 0) return
		if(attacker.faction & faction) return
		. = adjust_health(-amount, attacker)
		// TODO: Better animation
		var/old_color = color
		color = "#ff0000"
		animate(src, color = old_color, 3)
player/logout_timer
	parent_type = /datum
	New(player/player)
		. = ..()
		spawn(PINGOUT_TIME)
			del player