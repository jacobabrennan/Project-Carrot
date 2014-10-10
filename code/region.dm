character
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
				spawner.loc,/turf/proc/AdjacentTurfs,/turf/proc/Distance,/proc/RangeFinished, P_INCLUDE_FINISHED)
			new /wanderer(pick(drange-range(spawner,2)))