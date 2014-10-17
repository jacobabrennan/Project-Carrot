actor
	parent_type = /mob
	icon_state = "blue"
	bound_x = 8
	bound_y = 8
	bound_height = 16
	bound_width = 16
	step_size = 3
	layer = ACTOR_LAYER
	var
		actor/action/action
		acting = FALSE
		faction = FACTION_PLAYER
		iteration_delay = 3 // How many ticks between action iterations. CPU / Intelligence tradeoff.
		tile/default/move/tile_move = new()
		tile/default/attack/tile_attack = new()
		tile/default/gather/tile_gather = new()
	proc
		act(tile/new_tile, new_target, new_offset_x, new_offset_y)
			if(action)
				del action
			if(!new_tile)
				return
			if(new_tile.target_check(src, new_target))
				if(new_offset_x == null || new_offset_y == null && istype(new_target, /turf))
					new_offset_x = world.icon_size/2
					new_offset_y = world.icon_size/2
				action = new(new_tile, new_target, new_offset_x, new_offset_y)
				act_cycle()
				return TRUE
		act_cycle()
			if(acting) return
			acting = TRUE
			while(acting && action)
				sleep((get_iteration_delay()))
				if(action && acting) action.iterate(src)
				else halt_action()
			acting = FALSE
		halt_action(tile/halt_tile)
			if(action && (!halt_tile || action.tile == halt_tile))
				del action
		blocked()
			halt_action()
		get_step_size() // Overridden on combatant
			return step_size
		get_iteration_delay() // Just a hook. Maybe enemies get more intelligent
			return iteration_delay


actor/action
	parent_type = /datum
	var
		atom/target
		offset_x
		offset_y
		tile/tile
		timer
	New(new_tile, new_target, new_offset_x, new_offset_y)
		. = ..()
		tile = new_tile
		target = new_target
		offset_x = new_offset_x
		offset_y = new_offset_y
	proc
		iterate(actor/user)
			/*
				Check if action still valid (target still exists?)
				If target is an interactive block && bounds_dist <= 0, Interact(), cease action
				If target is within tile range, check if tile is ready, then use tile. Tile range means:
					delta_x/y == 0                                         <--- Could not possibly be any closer. Satisfies all below.
					delta_x/y <= Tile.range                                <--- Does not need to get closer. Satisfies all below.
					Target is solid, and bounds_dist <= 0                  <--- Cannot get to center. Touching is close enough.
					Target not solid, movement obstructed, bound_dist <= 0 <--- Cannot get to center, but close enough.
				Else
					Move user toward target
			*/
			// Check if action still valid (target still exists?)
			if(!target)
				del src
				return
			// If target is an interactive block && bounds_dist <= 0, Interact(), cease action
			var/touching = (bounds_dist(user, target) <= 0)
			var/block/interactor = target
			if(touching && istype(interactor) && interactor.interact && (tile != user.tile_gather))
				interactor.interact(user)
				del src
				return
			// Determine Distance
			var/delta_x
			var/delta_y
			if(istype(target, /actor))
				var/atom/movable/m_targ = target
				delta_x = (world.icon_size*(m_targ.x - user.x)) + (m_targ.step_x + m_targ.bound_x + (m_targ.bound_width /2)) - (user.step_x + user.bound_x + (user.bound_width /2))
				delta_y = (world.icon_size*(m_targ.y - user.y)) + (m_targ.step_y + m_targ.bound_y + (m_targ.bound_height/2)) - (user.step_y + user.bound_y + (user.bound_height/2))
			else if(istype(target, /atom/movable))
				var/atom/movable/m_targ = target
				delta_x = (world.icon_size*(m_targ.x - user.x)) + (m_targ.step_x + m_targ.bound_x + offset_x) - (user.step_x + user.bound_x + (user.bound_width /2))
				delta_y = (world.icon_size*(m_targ.y - user.y)) + (m_targ.step_y + m_targ.bound_y + offset_y) - (user.step_y + user.bound_y + (user.bound_height/2))
			else
				delta_x = (world.icon_size*(target.x - user.x)) + offset_x - (user.step_x + user.bound_x + (user.bound_width /2))
				delta_y = (world.icon_size*(target.y - user.y)) + offset_y - (user.step_y + user.bound_y + (user.bound_height/2))
			// If target is within tile range, use tile or wait.
			var/tile_range = tile.get_range(user)
			var/within_range = FALSE
			var/within_view = (target in view(user))
			if(
				// delta_x/y == 0   <--- Could not possibly be any closer. Satisfies all below.
				(delta_x == 0 && delta_y == 0) || \
				// delta_x/y <= Tile.range   <--- Does not need to get closer. Satisfies all below.
				(within_view && max(abs(delta_x), abs(delta_y)) <= tile_range) || \
				// Target is solid, and bounds_dist <= 0  <--- Cannot get to center. Touching is close enough.
				(target.density && touching)
			){
				within_range = TRUE
			}
			var/moved = FALSE
			if(!within_range)
			// Else, move user toward target
				var/speed = user.get_step_size()
				var/hypoteneus = sqrt(delta_x*delta_x + delta_y*delta_y)
				var/nudge_x = (!hypoteneus)? 0 : (delta_x / hypoteneus)*speed
				var/nudge_y = (!hypoteneus)? 0 : (delta_y / hypoteneus)*speed
				nudge_x = round(max(-abs(delta_x), min(abs(delta_x), nudge_x)),1)
				nudge_y = round(max(-abs(delta_y), min(abs(delta_y), nudge_y)),1)
				var/old_loc = user.loc
				var/old_step_x = user.step_x
				var/old_step_y = user.step_y
				if(nudge_x || nudge_y)
					if(!user.Move(user.loc, 0, user.step_x+nudge_x, user.step_y+nudge_y)) // Try full move
						if(user.Move(user.loc, 0, user.step_x, user.step_y+nudge_y)) // if blocked, try vertical move first
							user.Move(user.loc, 0, user.step_x+nudge_x, user.step_y) // then try horizontal move again
						else if(user.Move(user.loc, user.step_x, user.step_x+nudge_x, user.step_y)) // otherwise try horizontal move first
							user.Move(user.loc, 0, user.step_x, user.step_y+nudge_y) // then try vertical move again
				if(old_loc != user.loc || user.step_x != old_step_x || user.step_y != old_step_y)
					moved = TRUE
			if(!moved && (within_range || touching))
				if(!tile.ready(user)) return
				var continuous = tile.use(user, target, offset_x, offset_y)
				if(!continuous) del src
				return
			if(!moved)
				user.blocked()