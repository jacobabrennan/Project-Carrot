var/tile/garbage/garbage = new()
tile/garbage
	parent_type = /obj
	Entered(entrant)
		. = ..()
		spawn(5)
			del entrant
	proc
		// TODO: This is a hack to keep references on newly crafted tiles.
		// Otherwise they keep disapearing when crafted on the web client. Who knows.
		temp_storage(atom/referenced)
			var/stored = referenced
			spawn(36000)
				if(stored) stored = null
tile
	parent_type = /obj
	bound_width = TILE_SIZE
	bound_height = TILE_SIZE
	density = FALSE
	layer = TILE_LAYER
	var
		recharge_time = 0
		target_class = TARGET_ENEMY
		range = RANGE_TOUCH
		tile_type = TILE_NONE
		resource = "trash" // Text string, used when crafting
		continuous_use = FALSE
		value = 0
		construct
		tmp/last_use
	New()
		. = ..()
		mouse_drag_pointer = icon_state
	Del()
		Move(garbage) // Trigger deselection if player has this selected
		. = ..()
	Enter()
		return FALSE
	Move(turf/new_loc, new_dir, new_step_x, new_step_y, construct_override)
		if(!construct_override && construct && istype(new_loc, /turf))
			if(new_loc.dense())
				return
			. = ..()
			var/turf/offset_turf = loc
			if(step_x+bound_x+(bound_width /2) >= world.icon_size)
				offset_turf = get_step(offset_turf, EAST)
			if(step_y+bound_y+(bound_height/2) >= world.icon_size)
				offset_turf = get_step(offset_turf, NORTH)
			var/player/user = usr
			for(var/block/bed/B in range(TOTEM_RANGE+1, offset_turf))
				if(!istype(user))
					return
				if(B.owner_ckey != user.ckey)
					user << "You can't build so close to others' property."
					return
			mouse_opacity = 0
			spawn(TILE_TRANSLATE_TIME)
				new construct(offset_turf)
				del src
		else
			. = ..()
	Move()
		var/turf/old_loc = loc
		var/old_px_x = step_x
		var/old_px_y = step_y
		. = ..()
		var/turf/new_loc = loc
		if(!.) return
		if(!istype(old_loc) || !istype(new_loc)) return
		var/offset_x = (old_loc.x - loc.x)*world.icon_size + (old_px_x - step_x)
		var/offset_y = (old_loc.y - loc.y)*world.icon_size + (old_px_y - step_y)
		pixel_x = offset_x
		pixel_y = offset_y
		animate(src, pixel_x = 0, pixel_y = 0, TILE_TRANSLATE_TIME, 0, SINE_EASING)

	proc
		/*translate(px_x, px_y)
			pixel_x = px_x
			pixel_y = px_y
			animate(src, pixel_x=0, pixel_y=0, 10, 0, EASE_IN)*/
		target_check(actor/user, atom/target)
			if((TARGET_NONE|TARGET_RANGE)&target_class)
				return TRUE
			if(istype(target, /actor))
				var/actor/a_target = target
				var same_faction = (a_target.faction & user.faction)
				if(same_faction && TARGET_FRIEND&target_class)
					return TRUE
				if(!same_faction && TARGET_ENEMY&target_class)
					return TRUE
			else if(istype(target, /turf))
				if(TARGET_TURF&target_class)
					return TRUE
			else if(istype(target, /block))
				if(TARGET_BLOCK&target_class)
					return TRUE
		use(actor/user, atom/target, offset_x, offset_y)
			last_use = world.time
			// TODO: Add an animation here
			if(recharge_time)
				color = "#000"
				animate(src, color=null, recharge_time)
			//
			return continuous_use
		ready(actor/user)
			. = TRUE
			if(recharge_time && (world.time - last_use < recharge_time))
				return FALSE
		get_range() // This exists mostly to be overridden by the attack tile.
			return range

// Global Tile Types, used for global actions.
tile/default
	Move(){}
	New()
		. = ..()
		mouse_drag_pointer = null
tile/default/move
	icon_state = "follow"
	range = RANGE_TOUCH
	target_class = TARGET_ACTOR|TARGET_TURF|TARGET_BLOCK
	use(actor/user, atom/target, offset_x, offset_y){}
tile/default/attack
	icon_state = "attack"
	target_class = TARGET_ENEMY
	screen_loc = "CENTER:69,NORTH:7"
	layer = HUD_TILE_LAYER
	range = RANGE_TOUCH
	use(actor/user, atom/target, offset_x, offset_y)
		. = ..()
		var/player/C = user
		if(istype(C) && C.hud.equipment.weapon)
			return C.hud.equipment.weapon.use(user, target, offset_x, offset_y)
		else
			last_use = world.time
			color = "#000"
			animate(src, color=null, user.innate_attack_time)
			user.innate_attack(target)
			return TRUE
	target_check(actor/user, atom/target)
		var/player/C = user
		if(istype(C) && C.hud.equipment.weapon)
			return C.hud.equipment.weapon.target_check(user, target)
		else
			. = ..()
	ready(actor/user)
		var/player/C = user
		if(istype(C) && C.hud.equipment.weapon)
			return C.hud.equipment.weapon.ready(user)
		else
			if(user.innate_attack_time && (world.time - last_use < user.innate_attack_time))
				return FALSE
			else
				return TRUE
			. = ..()
	get_range(user)
		var/player/C = user
		if(istype(C) && C.hud.equipment.weapon)
			return C.hud.equipment.weapon.get_range()
		else
			. = ..()
tile/default/gather
	icon_state = "gather"
	screen_loc = "CENTER:95,NORTH:7"
	target_class = TARGET_BLOCK
	layer = HUD_TILE_LAYER
	recharge_time = 30
	use(player/user, block/target, offset_x, offset_y)
		. = ..()
		if(!istype(target)) return
		for(var/block/bed/B in range(TOTEM_RANGE, target))
			if(!istype(user))
				return
			if(B.owner_ckey != user.ckey)
				user << "You can't gather so close to others' property."
				return
		target.gather(user)