tile
	parent_type = /obj
	bound_width = TILE_SIZE
	bound_height = TILE_SIZE
	density = FALSE
	var
		delay = 0
		target_class = TARGET_ENEMY
		range = RANGE_TOUCH
	New()
		. = ..()
		mouse_drag_pointer = icon_state
	Enter()
		return FALSE
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
		range_check(actor/user, atom/target, offset_x, offset_y)
			if(range == RANGE_CENTER)
				if(istype(target, /turf))
					var/delta_x = (world.icon_size*(target.x - user.x)) + offset_x - (user.step_x + user.bound_x + (user.bound_width /2))
					var/delta_y = (world.icon_size*(target.y - user.y)) + offset_y - (user.step_y + user.bound_y + (user.bound_height/2))
					if(delta_x == 0 && delta_y == 0)
						return TRUE
				else if(istype(target, /actor))
					if(bounds_dist(user, target) == 0)
						return TRUE
			else
				if(bounds_dist(user, target) <= range)
					return TRUE
		use(actor/user, atom/target, offset_x, offset_y){}

// Global Tile Types, used for global actions.
var/tile/move/move_tile = new()
tile/move
	range = RANGE_CENTER
	target_class = TARGET_TURF|TARGET_ACTOR
	use(actor/user, atom/target, offset_x, offset_y){}
var/tile/melee/melee_tile = new()
tile/melee
	target_class = TARGET_ENEMY
	use(actor/user, atom/target, offset_x, offset_y){}





tile/test_item
	range = RANGE_TOUCH
	target_class = TARGET_ACTOR
	use(actor/user, atom/target, offset_x, offset_y)
		target.icon_state = "orange"
		del src