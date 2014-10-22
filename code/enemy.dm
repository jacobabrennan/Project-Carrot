enemy
	parent_type = /actor
	faction = FACTION_ENEMY
	see_infrared = TRUE
	sight = SEE_MOBS
	base_health = 1
	base_speed = 3
	tile_gather = null
	var
		enemy/plan/plan
		exp = 1 // currently, directly translates to CP
	die(player/killer)
		if(istype(killer))
			killer.adjust_bp(exp)
		spawn()
			Del()
	New()
		. = ..()
		spawn()
			behavior()
	Del()
		del plan
		. = ..()
	blocked()
		halt_action()
		if(plan)
			plan.reassess()
	proc
		behavior()
			for(var/I = 1 to 5)
				if(!plan)
					var/target// = plan? plan.target : null
					var/list/targets = list()
					for(var/actor/A in oview(src,10))
						if(A.faction != faction)
							targets.Add(A)
					while(targets.len)
						target = pick(targets)
						targets.Remove(target)
						var/enemy/plan/P = new(src, target)
						if(P)
							plan = P
							break
				if(plan)
					break
				sleep(30)
			if(!plan)
				del src
			plan.advance(src)
			spawn()
				behavior()

enemy/plan
	parent_type = /datum
	var
		enemy/user
		actor/target
		list/path
		max_int = 20
		intelligence // A number. A finite resource which is expended. CPU
		int_rate = 10 // A number. The rate at which intelligence is replenished.
	New(actor/_user, actor/_target, _max_int, _int_rate)
		user = _user
		target = _target
		max_int = _max_int || max_int
		intelligence = max_int
		int_rate = _int_rate || int_rate
		spawn()
			while(src)
				intelligence = min(intelligence+int_rate, max_int)
				sleep(30)
		user.act(user.tile_attack, target)
	proc
		advance()
			var within_view = (target in view(user))
			if(within_view && user.tile_attack.get_range() > bounds_dist(user,target)+64)
				user.act(user.tile_attack, target)
				return
			if(path && rand()*(path.len+4) < 1)
				del path
			if(!path || !path.len)
				if(within_view)
					user.act(user.tile_attack, target)
				else if(rand()*4<1)
					reassess()
				else
					user.act(user.tile_move, get_step_rand(user))
			else
				var/turf/next_step = path[1]
				path.Remove(next_step)
				user.act(user.tile_move, next_step)
		reassess()
			if(intelligence >= 20)
				if(!target) del src
				var/atom/dest_proxy = target
				if(!istype(target, /turf) && !istype(target, /block))
					dest_proxy = locate(target.x,target.y,target.z)
				var/turf/start = locate(user.x,user.y,user.z)
				var/within_view = (target in view(user))
				var/pursue_range = within_view? round(user.tile_attack.get_range() / world.icon_size) : 0
				path = AStar(
					start,
					dest_proxy,
					/path_finder/proc/adjacent,
					/path_finder/proc/weight_distance,
					/path_finder/proc/equality,
					0,
					20,
					pursue_range,
					/path_finder/proc/abs_distance
				)
					//       start, end,                adjacent,                     dist,maxnodes,maxnodedepth,mintargetdist,           minnodedist)
				intelligence -= 20
				if((!path || !path.len) && (rand()*4 >= 3) && !(user in view(target)))
					del src
			else if(intelligence <= 0)

			else
				del path