turf
	proc
		dense()
			for(var/block/B in src)
				if(B.density) return B
		opaque()
			for(var/block/B in src)
				if(B.opacity) return B
		AdjacentTurfs()
			var/list/L = list()
			var/turf/n = get_step(src,NORTH)
			var/turf/s = get_step(src,SOUTH)
			var/turf/e = get_step(src,EAST)
			var/turf/w = get_step(src,WEST)
			L.Add(n,s,e,w)
			var/nd = n? n.dense() : TRUE
			var/sd = s? s.dense() : TRUE
			var/ed = e? e.dense() : TRUE
			var/wd = w? w.dense() : TRUE
			if(!nd && !ed) L.Add(get_step(src,NORTHEAST))
			if(!nd && !wd) L.Add(get_step(src,NORTHWEST))
			if(!sd && !ed) L.Add(get_step(src,SOUTHEAST))
			if(!sd && !wd) L.Add(get_step(src,SOUTHWEST))
			for(var/I = L.len to 1 step -1)
				var/turf/T = L[I]
				if(!L[I] || T.dense()) L.Cut(I,I+1)
				else if(!L[I]) L.Cut(I,I+1)
			return L
		WeightDistance(turf/t)
			var/weight = 1
			if(locate(/actor) in t) weight += 5
			if(t.dense())
				if(t.opaque()) weight += 300
				else weight += 45
			if(get_dist(src,t) == 1)
				if(x != t.x && y != t.y) weight += 1.4
				return weight
			else
				return get_dist(src,t)
		AbsDistance(turf/t)
			if(get_dist(src,t) == 1)
				if(locate(/actor) in t) return 5
				else if(x != t.x && y != t.y) return 1.4
				return 1
			else
				return get_dist(src,t)
proc
	//Done after running into the first destination object
	Finished(turf/t)
		return (locate(/block/wooden_floor) in t) ? P_DIJKSTRA_FINISHED : P_DIJKSTRA_NOT_FOUND
	//Done after moving 8 units of range
	RangeFinished(turf/t,range)
		return range > 8
	//Find paths to all the destination objects
	FinishedAll(turf/t)
		return (locate(/block/wooden_floor) in t) ? P_DIJKSTRA_ADD_PATH : P_DIJKSTRA_NOT_FOUND


/* Examples. For cut/paste later
player
	verb
		astartest()
			var/turf/dest = locate(/block/wooden_floor)
			dest = dest.loc
			var/path[] = AStar(character.loc,dest,/turf/proc/AdjacentTurfs,/turf/proc/Distance)
			for(var/turf/t in path)
				sleep(5)
				t.icon_state = "grid"
		dijkstratest()
			var/path[] = Dijkstra(character.loc,/turf/proc/AdjacentTurfs,/turf/proc/Distance,/proc/Finished)
			for(var/turf/t in path)
				t.icon_state = "grid"

		dijkstratestall()
			var/paths[] = Dijkstra(character.loc,/turf/proc/AdjacentTurfs,/turf/proc/Distance,/proc/FinishedAll, , 0)
			for(var/list/path in paths)
				for(var/turf/t in path)
					t.icon_state = "grid"

		dijkstratestrange()
			var/path[] = DijkstraTurfInRange(character.loc,/turf/proc/AdjacentTurfs,/turf/proc/Distance,/proc/RangeFinished, P_INCLUDE_INTERIOR)
			for(var/turf/t in path)
				t.icon_state = "grid"
*/