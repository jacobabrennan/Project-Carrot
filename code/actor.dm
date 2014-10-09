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
		break_down()


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
			var delta_x
			var delta_y
			if(offset_x != null && offset_y != null)
				var/max_delta_x = (world.icon_size*(target.x - user.x)) + offset_x - (user.step_x + user.bound_x + (user.bound_width /2))
				var/max_delta_y = (world.icon_size*(target.y - user.y)) + offset_y - (user.step_y + user.bound_y + (user.bound_height/2))
				var/theta = atan2(max_delta_x, max_delta_y)
				delta_x = user.step_size*cos(theta);
				delta_y = user.step_size*sin(theta);
				delta_x = (-round(-abs(delta_x)) * ((delta_x < 0)? -1 : 1))
				delta_y = (-round(-abs(delta_y)) * ((delta_y < 0)? -1 : 1))
				delta_x = min(abs(max_delta_x), max(-abs(max_delta_x), delta_x))
				delta_y = min(abs(max_delta_y), max(-abs(max_delta_y), delta_y))
			else if(istype(target, /atom/movable))
				var/atom/movable/m_targ = target
				var/max_delta_x = (world.icon_size*(m_targ.x - user.x)) + (m_targ.step_x + m_targ.bound_x + (m_targ.bound_width /2)) - (user.step_x + user.bound_x + (user.bound_width /2))
				var/max_delta_y = (world.icon_size*(m_targ.y - user.y)) + (m_targ.step_y + m_targ.bound_y + (m_targ.bound_height/2)) - (user.step_y + user.bound_y + (user.bound_height/2))
				var/theta = atan2(max_delta_x, max_delta_y)
				delta_x = user.step_size*cos(theta);
				delta_y = user.step_size*sin(theta);
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
