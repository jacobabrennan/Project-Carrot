wanderer
	parent_type = /actor
	icon_state = "red"
	faction = FACTION_ENEMY
	bound_x = 0
	bound_y = 0
	bound_height = 32
	bound_width = 32
	New()
		. = ..()
		walk_rand(src,3)
	Move()
		. = ..()
		if(rand(0,16)>15)
			dir = pick(1,2,4,8)
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
			if(new_tile.target_check(src, new_target))
				action = new(new_tile, new_target, new_offset_x, new_offset_y)
				act_cycle()
				return TRUE
		act_cycle()
			if(acting) return
			acting = TRUE
			while(acting && action)
				sleep(action_cycle_delay)
				action.iterate(src)
			acting = FALSE

actor/action
	parent_type = /datum
	var
		atom/target
		offset_x
		offset_y
		tile/tile
	New(new_tile, new_target, new_offset_x, new_offset_y)
		. = ..()
		tile = new_tile
		target = new_target
		offset_x = new_offset_x
		offset_y = new_offset_y
	proc
		iterate(actor/user)
			if(offset_x != null && offset_y != null)
				var/max_delta_x = (world.icon_size*(target.x - user.x)) + offset_x - (user.step_x + user.bound_x + (user.bound_width /2))
				var/max_delta_y = (world.icon_size*(target.y - user.y)) + offset_y - (user.step_y + user.bound_y + (user.bound_height/2))
				var/theta = atan2(max_delta_x, max_delta_y)
				var/delta_x = user.step_size*cos(theta);
				var/delta_y = user.step_size*sin(theta);
				delta_x = (-round(-abs(delta_x)) * ((delta_x < 0)? -1 : 1))
				delta_y = (-round(-abs(delta_y)) * ((delta_y < 0)? -1 : 1))
				delta_x = min(abs(max_delta_x), max(-abs(max_delta_x), delta_x))
				delta_y = min(abs(max_delta_y), max(-abs(max_delta_y), delta_y))
				user.Move(user.loc, 0, user.step_x+delta_x, user.step_y+delta_y)
			else if(istype(target, /atom/movable))
				var/atom/movable/m_targ = target
				var/max_delta_x = (world.icon_size*(m_targ.x - user.x)) + (m_targ.step_x + m_targ.bound_x + (m_targ.bound_width /2)) - (user.step_x + user.bound_x + (user.bound_width /2))
				var/max_delta_y = (world.icon_size*(m_targ.y - user.y)) + (m_targ.step_y + m_targ.bound_y + (m_targ.bound_height/2)) - (user.step_y + user.bound_y + (user.bound_height/2))
				var/theta = atan2(max_delta_x, max_delta_y)
				var/delta_x = user.step_size*cos(theta);
				var/delta_y = user.step_size*sin(theta);
				delta_x = -(-round(abs(delta_x)) * ((delta_x < 0)? -1 : 1))
				delta_y = -(-round(abs(delta_y)) * ((delta_y < 0)? -1 : 1))
				delta_x = min(abs(max_delta_x), max(-abs(max_delta_x), delta_x))
				delta_y = min(abs(max_delta_y), max(-abs(max_delta_y), delta_y))
				user.Move(user.loc, 0, user.step_x+delta_x, user.step_y+delta_y)
			if(tile.range_check(user, target, offset_x, offset_y))
				var continuous = tile.use(user, target, offset_x, offset_y)
				if(!continuous) del src
