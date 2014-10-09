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
	var
		recharge_time = 0
		target_class = TARGET_ENEMY
		range = RANGE_TOUCH
		tile_type = TILE_NONE
		resource = "trash" // Text string, used when crafting
		continuous_use = FALSE
		value = 1
		construct
		last_use
	New()
		. = ..()
		mouse_drag_pointer = icon_state
	Del()
		Move(garbage) // Trigger deselection if player has this selected
		. = ..()
	Enter()
		return FALSE
	Move(turf/new_loc, new_dir, new_step_x, new_step_y)
		if(construct && istype(new_loc, /turf))
			if(new_loc.density || new_loc.contents.len)
				return
			. = ..()
			var/turf/offset_turf = loc
			if(step_x+bound_x+(bound_width /2) >= world.icon_size)
				offset_turf = get_step(offset_turf, EAST)
			if(step_y+bound_y+(bound_height/2) >= world.icon_size)
				offset_turf = get_step(offset_turf, NORTH)
			new construct(offset_turf)
			del src
		else
			. = ..()
	proc
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

// Global Tile Types, used for global actions.
tile/shared
	Move(){}
	New()
		. = ..()
		mouse_drag_pointer = null
var/tile/shared/move/tile_move = new()
tile/shared/move
	icon_state = "follow"
	range = RANGE_TOUCH
	target_class = TARGET_ACTOR|TARGET_TURF|TARGET_BLOCK
	use(actor/user, atom/target, offset_x, offset_y){}
var/tile/shared/attack/tile_attack = new()
tile/shared/attack
	icon_state = "attack"
	target_class = TARGET_ENEMY
	screen_loc = "CENTER:69,NORTH:7"
	layer = HUD_TILE_LAYER
	use(actor/user, atom/target, offset_x, offset_y)
		. = ..()
		var/character/C = user
		if(istype(C) && C.hud.equipment.weapon)
			return C.hud.equipment.weapon.use(user, target, offset_x, offset_y)
	target_check(actor/user, atom/target)
		var/character/C = user
		if(istype(C) && C.hud.equipment.weapon)
			return C.hud.equipment.weapon.target_check(user, target)
		else
			. = ..()
	/*range_check(actor/user, atom/target, offset_x, offset_y)
		var/character/C = user
		if(istype(C) && C.hud.equipment.weapon)
			return C.hud.equipment.weapon.range_check(user, target)
		else
			. = ..()*/
	ready(actor/user)
		var/character/C = user
		if(istype(C) && C.hud.equipment.weapon)
			return C.hud.equipment.weapon.ready(user)
		else
			. = ..()

var/tile/shared/follow/tile_follow = new()
tile/shared/follow
	icon_state = "follow"
	screen_loc = "CENTER:69,NORTH:7"
	range = RANGE_TOUCH
	target_class = TARGET_ACTOR
	layer = HUD_TILE_LAYER
	/*range_check(actor/user, atom/target, offset_x, offset_y)
		return FALSE*/
var/tile/shared/gather/tile_gather = new()
tile/shared/gather
	icon_state = "gather"
	screen_loc = "CENTER:95,NORTH:7"
	target_class = TARGET_BLOCK
	layer = HUD_TILE_LAYER
	use(actor/user, block/target, offset_x, offset_y)
		if(!istype(target)) return
		target.gather(user)


