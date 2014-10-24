player
	Move()
		. = ..()
		if(.)
			var/region/R = aloc()
			if(R) R.notify(src)
area
	proc
		notify(actor)
region
	parent_type = /area
	notify(actor/actor)
		if(rand()*spawn_rate > spawn_rate-1)
			spawn_enemy(actor)
	var
		spawn_rate = 196
		list/enemy_groups
	proc
		spawn_enemy(actor/spawner)
			if(!enemy_groups) return
			if(!(spawner.faction & FACTION_PLAYER)) return
			var/list/group = pick(enemy_groups)
			var/list/drange = DijkstraTurfInRange(
				spawner.loc,/path_finder/proc/adjacent,/path_finder/proc/abs_distance,/proc/RangeFinished, P_INCLUDE_FINISHED)
			drange -= view(spawner,2)
			for(var/atom/A in drange)
				var/turf/T = A
				if(!istype(T))
					drange.Remove(T)
					continue
				if(T.dense())
					drange.Remove(T)
					continue
				if(locate(/block/bed) in range(TOTEM_RANGE, T)) drange.Remove(T)
			for(var/path in group)
				if(!drange.len) break
				var/turf/start = pick(drange)
				drange.Remove(start)
				new path(start)