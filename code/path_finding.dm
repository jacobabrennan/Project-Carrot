turf
	proc
		dense()
			for(var/block/B in src)
				if(B.density) return B
		opaque()
			for(var/block/B in src)
				if(B.opacity) return B
path_finder
	proc
		equality(a,b)
			return (a == b)
		adjacent(var/atom/A)
			if(!istype(A, /turf)) return list()
			var/list/L = list()
			var/turf/n = get_step(A,NORTH)
			var/turf/s = get_step(A,SOUTH)
			var/turf/e = get_step(A,EAST)
			var/turf/w = get_step(A,WEST)
			L.Add(n,s,e,w)
			var/nd = n? n.dense() : TRUE
			var/sd = s? s.dense() : TRUE
			var/ed = e? e.dense() : TRUE
			var/wd = w? w.dense() : TRUE
			if(!nd && !ed) L.Add(get_step(A,NORTHEAST))
			if(!nd && !wd) L.Add(get_step(A,NORTHWEST))
			if(!sd && !ed) L.Add(get_step(A,SOUTHEAST))
			if(!sd && !wd) L.Add(get_step(A,SOUTHWEST))
			var/list/LB = new()
			for(var/block/B in A)
				LB.Add(B)
			for(var/I = L.len to 1 step -1)
				var/turf/T = L[I]
				for(var/block/B in T)
					LB.Add(B)
				for(var/actor/_actor in T)
					LB.Add(_actor)
				if(!T || T.dense()) L.Cut(I,I+1)
				else if(!L[I]) L.Cut(I,I+1)
			L.Add(LB)
			return L
		weight_distance(atom/A, atom/B)
			/*var/weight = 1
			if(locate(/actor) in t) weight += 5
			if(get_dist(src,t) == 1)
				if(x != t.x && y != t.y) weight += 1.4
				return weight
			else*/
			return get_dist(A, B)
		abs_distance(atom/A, atom/B)
			if(get_dist(A, B) == 1)
				/*if(locate(/actor) in B) return 5
				else */if(A.x != B.x && A.y != B.y) return 1.4
				return 1
			else
				return sqrt((A.x - B.x) * (A.x - B.x) + (A.y - B.y) * (A.y - B.y))
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
			var/path[] = AStar(player.loc,dest,/turf/proc/AdjacentTurfs,/turf/proc/Distance)
			for(var/turf/t in path)
				sleep(5)
				t.icon_state = "grid"
		dijkstratest()
			var/path[] = Dijkstra(player.loc,/turf/proc/AdjacentTurfs,/turf/proc/Distance,/proc/Finished)
			for(var/turf/t in path)
				t.icon_state = "grid"

		dijkstratestall()
			var/paths[] = Dijkstra(player.loc,/turf/proc/AdjacentTurfs,/turf/proc/Distance,/proc/FinishedAll, , 0)
			for(var/list/path in paths)
				for(var/turf/t in path)
					t.icon_state = "grid"

		dijkstratestrange()
			var/path[] = DijkstraTurfInRange(player.loc,/turf/proc/AdjacentTurfs,/turf/proc/Distance,/proc/RangeFinished, P_INCLUDE_INTERIOR)
			for(var/turf/t in path)
				t.icon_state = "grid"
*/