actor
	parent_type = /mob
	icon_state = "blue"
	bound_x = 8
	bound_y = 8
	bound_height = 16
	bound_width = 16
	step_size = 3
	var
		actor/action/action
		acting = FALSE
		faction = FACTION_PLAYER
		action_cycle_delay = 1
	proc
		act(tile/new_tile, new_target, new_offset_x, new_offset_y)
			if(action)
				del action
			if(!new_tile)
				return
			if(new_tile.target_check(src, new_target))
				action = new(new_tile, new_target, new_offset_x, new_offset_y)
				act_cycle()
				return TRUE
		act_cycle()
			if(acting) return
			acting = TRUE
			while(acting && action)
				sleep(action_cycle_delay)
				if(action && acting) action.iterate(src)
			acting = FALSE
		halt_action(tile/halt_tile)
			if(action && (!halt_tile || action.tile == halt_tile))
				del action
		get_step_size() // Overridden on combatant
			return step_size


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
				Move user toward target
				If target is an interactive block && bounds_dist <= 0, Interact(), cease action
				Check if the tile is ready.
				If target is within tile range, use tile. Tile range means:
					delta_x/y == 0                                         <--- Could not possibly be any closer. Satisfies all below.
					delta_x/y <= Tile.range                                <--- Does not need to get closer. Satisfies all below.
					Target is solid, and bounds_dist <= 0                  <--- Cannot get to center. Touching is close enough.
					Target not solid, movement obstructed, bound_dist <= 0 <--- Cannot get to center, but close enough.
			*/
			// Check if action still valid (target still exists?)
			if(!target)
				del src
				return
			// If target is an interactive block && bounds_dist <= 0, Interact(), cease action
			var/touching = (bounds_dist(user, target) <= 0)
			var/block/interactor = target
			if(touching && istype(interactor) && interactor.interact)
				interactor.interact(user)
				del src
				return
			// Move user toward target
			var/speed = user.get_step_size()
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
			var/moved = FALSE
			if(old_loc != user.loc || user.step_x != old_step_x || user.step_y != old_step_y)
				moved = TRUE
			touching = (bounds_dist(user, target) <= 0)
			// If target is an interactive block && bounds_dist <= 0, Interact()
			if(touching && istype(interactor) && interactor.interact)
				interactor.interact(user)
				del src
				return
			// Check if the tile is ready
			if(!tile.ready(user))
				return
			// Recalculate delta_x/y
			if(istype(target, /atom/movable))
				var/atom/movable/m_targ = target
				delta_x = (world.icon_size*(m_targ.x - user.x)) + (m_targ.step_x + m_targ.bound_x + (m_targ.bound_width /2)) - (user.step_x + user.bound_x + (user.bound_width /2))
				delta_y = (world.icon_size*(m_targ.y - user.y)) + (m_targ.step_y + m_targ.bound_y + (m_targ.bound_height/2)) - (user.step_y + user.bound_y + (user.bound_height/2))
			else
				delta_x = (world.icon_size*(target.x - user.x)) + offset_x - (user.step_x + user.bound_x + (user.bound_width /2))
				delta_y = (world.icon_size*(target.y - user.y)) + offset_y - (user.step_y + user.bound_y + (user.bound_height/2))
			if(
				// delta_x/y == 0   <--- Could not possibly be any closer. Satisfies all below.
				(delta_x == 0 && delta_y == 0) || \
				// delta_x/y <= Tile.range   <--- Does not need to get closer. Satisfies all below.
				(max(abs(delta_x), abs(delta_y)) <= tile.range) || \
				// Target is solid, and bounds_dist <= 0  <--- Cannot get to center. Touching is close enough.
				(target.density && touching) || \
				// Target not solid, movement obstructed, bound_dist <= 0 <--- Cannot get to center, but close enough.
				(!moved && touching)
			){
				var continuous = tile.use(user, target, offset_x, offset_y)
				if(!continuous) del src
				return
			}
			/*var delta_x
			var delta_y
			var/step_size = user.get_step_size()
			// Go to actor
			if(istype(target, /actor))
				var/actor/m_targ = target
				var/max_delta_x = (world.icon_size*(m_targ.x - user.x)) + (m_targ.step_x + m_targ.bound_x + (m_targ.bound_width /2)) - (user.step_x + user.bound_x + (user.bound_width /2))
				var/max_delta_y = (world.icon_size*(m_targ.y - user.y)) + (m_targ.step_y + m_targ.bound_y + (m_targ.bound_height/2)) - (user.step_y + user.bound_y + (user.bound_height/2))
				var/theta = atan2(max_delta_x, max_delta_y)
				delta_x = step_size*cos(theta);
				delta_y = step_size*sin(theta);
				delta_x = -(-round(abs(delta_x)) * ((delta_x < 0)? -1 : 1))
				delta_y = -(-round(abs(delta_y)) * ((delta_y < 0)? -1 : 1))
				delta_x = min(abs(max_delta_x), max(-abs(max_delta_x), delta_x))
				delta_y = min(abs(max_delta_y), max(-abs(max_delta_y), delta_y))
				if(delta_x || delta_y)
					if(!user.Move(user.loc, 0, user.step_x+delta_x, user.step_y+delta_y)) // Try full move
						if(user.Move(user.loc, 0, user.step_x, user.step_y+delta_y)) // if blocked, try vertical move first
							user.Move(user.loc, 0, user.step_x+delta_x, user.step_y) // then try horizontal move again
						else if(user.Move(user.loc, user.step_x, user.step_x+delta_x, user.step_y)) // otherwise try horizontal move first
							user.Move(user.loc, 0, user.step_x, user.step_y+delta_y) // then try vertical move again
				if(!tile.ready(user))
					return
				if(tile.range_check(user, target, offset_x, offset_y))
					var continuous = tile.use(user, target, offset_x, offset_y)
					if(!continuous) del src
			// Go to location
			if(offset_x != null && offset_y != null)
				var/max_delta_x = (world.icon_size*(target.x - user.x)) + offset_x - (user.step_x + user.bound_x + (user.bound_width /2))
				var/max_delta_y = (world.icon_size*(target.y - user.y)) + offset_y - (user.step_y + user.bound_y + (user.bound_height/2))
				var/theta = atan2(max_delta_x, max_delta_y)
				delta_x = step_size*cos(theta)
				delta_y = step_size*sin(theta)
				delta_x = (-round(-abs(delta_x)) * ((delta_x < 0)? -1 : 1))
				delta_y = (-round(-abs(delta_y)) * ((delta_y < 0)? -1 : 1))
				delta_x = min(abs(max_delta_x), max(-abs(max_delta_x), delta_x))
				delta_y = min(abs(max_delta_y), max(-abs(max_delta_y), delta_y))
				var/moved = FALSE
				if(delta_x || delta_y)
					if(!user.Move(user.loc, 0, user.step_x+delta_x, user.step_y+delta_y)) // Try full move
						if(user.Move(user.loc, 0, user.step_x, user.step_y+delta_y)) // if blocked, try vertical move first
							moved = TRUE
							user.Move(user.loc, 0, user.step_x+delta_x, user.step_y) // then try horizontal move again
						else if(user.Move(user.loc, user.step_x, user.step_x+delta_x, user.step_y)) // otherwise try horizontal move first
							moved = TRUE
							user.Move(user.loc, 0, user.step_x, user.step_y+delta_y) // then try vertical move again
					else moved = TRUE
				if(!tile.ready(user))
					return
				if(!moved || delta_x == 0 && delta_y == 0)
					if(tile.range_check(user, target, offset_x, offset_y))
						if(!istype(target, /block))
							var continuous = tile.use(user, target, offset_x, offset_y)
							if(!continuous) del src
							return
						else
							var/block/target_block = target
							if(tile == tile_gather)
								if(timer == null)
									timer = target_block.resource_delay || 0
								if(timer <= 0)
									var continuous = tile.use(user, target_block, offset_x, offset_y)
									if(!continuous) del src
								else
									timer--
									// TODO: Play some kind of animation here.
							else if(target_block.interact)
								target_block.interact(user)
								del src
							else
								var continuous = tile.use(user, target, offset_x, offset_y)
								if(!continuous) del src
			/*
			else if(istype(target, /atom/movable))
				var/atom/movable/m_targ = target
				var/max_delta_x = (world.icon_size*(m_targ.x - user.x)) + (m_targ.step_x + m_targ.bound_x + (m_targ.bound_width /2)) - (user.step_x + user.bound_x + (user.bound_width /2))
				var/max_delta_y = (world.icon_size*(m_targ.y - user.y)) + (m_targ.step_y + m_targ.bound_y + (m_targ.bound_height/2)) - (user.step_y + user.bound_y + (user.bound_height/2))
				var/theta = atan2(max_delta_x, max_delta_y)
				delta_x = step_size*cos(theta);
				delta_y = step_size*sin(theta);
				delta_x = -(-round(abs(delta_x)) * ((delta_x < 0)? -1 : 1))
				delta_y = -(-round(abs(delta_y)) * ((delta_y < 0)? -1 : 1))
				delta_x = min(abs(max_delta_x), max(-abs(max_delta_x), delta_x))
				delta_y = min(abs(max_delta_y), max(-abs(max_delta_y), delta_y))
			if(delta_x || delta_y)
				if(!user.Move(user.loc, 0, user.step_x+delta_x, user.step_y+delta_y)) // Try full move
					if(user.Move(user.loc, 0, user.step_x, user.step_y+delta_y)) // if blocked, try vertical move first
						user.Move(user.loc, 0, user.step_x+delta_x, user.step_y) // then try horizontal move again
					else if(user.Move(user.loc, user.step_x, user.step_x+delta_x, user.step_y)) // otherwise try horizontal move first
						user.Move(user.loc, 0, user.step_x, user.step_y+delta_y) // then try vertical move again
			if(!tile.ready(user))
				return
			if(tile.range_check(user, target, offset_x, offset_y))
				if(istype(target, /block))
					var/block/target_block = target
					if(tile == tile_gather)
						if(timer == null)
							timer = target_block.resource_delay || 0
						if(timer <= 0)
							var continuous = tile.use(user, target_block, offset_x, offset_y)
							if(!continuous) del src
						else
							timer--
							// TODO: Play some kind of animation here.
					else if(target_block.interact)
						target_block.interact(user)
						del src
					else
						var continuous = tile.use(user, target, offset_x, offset_y)
						if(!continuous) del src
				else
					var continuous = tile.use(user, target, offset_x, offset_y)
					if(!continuous) del src
			*/
*/