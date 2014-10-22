actor
	parent_type = /mob
	icon_state = "diamond"
	bound_height = 24
	bound_width = 24
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
				action = new(src, new_tile, new_target, new_offset_x, new_offset_y)
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
		turf/next_step
		offset_x
		offset_y
		tile/tile
		list/path
		timer
	New(actor/actor, new_tile, atom/new_target, new_offset_x, new_offset_y)
		. = ..()
		tile = new_tile
		target = new_target
		offset_x = new_offset_x
		offset_y = new_offset_y
		var/turf/start_turf = locate(actor.x,actor.y,actor.z)
		if(actor.step_x + actor.bound_x + (actor.bound_width /2) > 32) start_turf = get_step(start_turf, EAST )
		if(actor.step_y + actor.bound_y + (actor.bound_height/2) > 32) start_turf = get_step(start_turf, NORTH)
		var/pursue_range = 0
		var/atom/target_proxy = target
		if(!istype(target, /turf) && !istype(target, /block))
			target_proxy = locate(new_target.x, new_target.y, new_target.z)
		path = AStar(
			start_turf,
			target_proxy,
			/path_finder/proc/adjacent,
			/path_finder/proc/weight_distance,
			/path_finder/proc/equality,
			20,
			20,
			pursue_range,
			/path_finder/proc/abs_distance
		)
			//           start,        end,                adjacent,                     dist,maxnodes,maxnodedepth,mintargetdist,           minnodedist)
		if(path && path.len)
			path.Remove(path[1])
			if(istype(new_target, /block) && path.len)
				path.Remove(path[path.len])
		for(var/turf/T in path)
			var/dense = FALSE
			for(var/atom/movable/M in range(1,T))
				if(!(istype(M,/turf) || istype(M,/block))) continue
				if(M.density)
					dense = TRUE
					break
			if(!dense)
				path.Remove(T)
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
			if(!next_step)
				if(path && path.len)
					next_step = path[1]
					path.Remove(next_step)
				else
					next_step = target
			var/step_mid_x = offset_x
			var/step_mid_y = offset_y
			if(next_step != target)
				step_mid_x = 16
				step_mid_y = 16
			// If target is an interactive block && bounds_dist <= 0, Interact(), cease action
			var/touching = (bounds_dist(user, next_step) <= 0)
			var/block/interactor = next_step
			if(touching && istype(interactor) && interactor.interact && (tile != user.tile_gather))
				var/allowed = TRUE
				for(var/block/bed/B in range(TOTEM_RANGE, interactor))
					if(B == interactor) continue
					if(B.owner_ckey)
						if(B.owner_ckey == user.ckey)
							break
						else
							allowed = FALSE
				if(allowed)
					interactor.interact(user)
				del src
				return
			// Determine Distance
			var/delta_x
			var/delta_y
			if(istype(next_step, /actor))
				var/atom/movable/m_targ = next_step
				delta_x = (world.icon_size*(m_targ.x - user.x)) + (m_targ.step_x + m_targ.bound_x + (m_targ.bound_width /2)) - (user.step_x + user.bound_x + (user.bound_width /2))
				delta_y = (world.icon_size*(m_targ.y - user.y)) + (m_targ.step_y + m_targ.bound_y + (m_targ.bound_height/2)) - (user.step_y + user.bound_y + (user.bound_height/2))
			else if(istype(next_step, /atom/movable))
				var/atom/movable/m_targ = next_step
				delta_x = (world.icon_size*(m_targ.x - user.x)) + (m_targ.step_x + m_targ.bound_x + step_mid_x) - (user.step_x + user.bound_x + (user.bound_width /2))
				delta_y = (world.icon_size*(m_targ.y - user.y)) + (m_targ.step_y + m_targ.bound_y + step_mid_y) - (user.step_y + user.bound_y + (user.bound_height/2))
			else
				delta_x = (world.icon_size*(next_step.x - user.x)) + step_mid_x - (user.step_x + user.bound_x + (user.bound_width /2))
				delta_y = (world.icon_size*(next_step.y - user.y)) + step_mid_y - (user.step_y + user.bound_y + (user.bound_height/2))
			// If target is within tile range, use tile or wait.
			var/tile_range = tile.get_range(user)
			var/within_range = FALSE
			var/within_view = (next_step in view(user))
			if(
				// delta_x/y == 0   <--- Could not possibly be any closer. Satisfies all below.
				(delta_x == 0 && delta_y == 0) || \
				// delta_x/y <= Tile.range   <--- Does not need to get closer. Satisfies all below.
				(within_view && max(abs(delta_x), abs(delta_y)) <= tile_range) || \
				// Target is solid, and bounds_dist <= 0  <--- Cannot get to center. Touching is close enough.
				(next_step.density && touching)
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
						if(     nudge_y && user.Move(user.loc, 0, user.step_x, user.step_y+nudge_y)) // if blocked, try vertical move first
							user.Move(user.loc, 0, user.step_x+nudge_x, user.step_y) // then try horizontal move again
						else if(nudge_x && user.Move(user.loc, 0, user.step_x+nudge_x, user.step_y)) // otherwise try horizontal move first
							user.Move(user.loc, 0, user.step_x, user.step_y+nudge_y) // then try vertical move again
				if(old_loc != user.loc || user.step_x != old_step_x || user.step_y != old_step_y)
					moved = TRUE
			if(!moved && (within_range || touching))
				if(next_step != target)
					next_step = null
					return iterate(user)
				if(!tile.ready(user)) return
				var continuous = tile.use(user, next_step, step_mid_x, step_mid_y)
				if(!continuous) del src
				return
			if(!moved)
				user.blocked()