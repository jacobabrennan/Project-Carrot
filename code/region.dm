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
		if(rand()*64 > 63)
			spawn_enemy(actor)
	proc
		spawn_enemy(actor/spawner)
			if(!(spawner.faction & FACTION_PLAYER)) return
			var/list/drange = DijkstraTurfInRange(
				spawner.loc,/turf/proc/AdjacentTurfs,/turf/proc/AbsDistance,/proc/RangeFinished, P_INCLUDE_FINISHED)
			drange -= view(spawner,2)
			for(var/turf/T in drange)
				if(T.dense()) drange.Remove(T)
			if(drange.len)
				new /wanderer(pick(drange))