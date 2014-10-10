enemy
	parent_type = /actor
	faction = FACTION_ENEMY
	base_health = 5
	base_speed = 3
	tile_gather = null
	var
		enemy/plan/plan
	die()
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
			plan.blocked(src)
	proc
		behavior()
			for(var/I = 1 to 5)
				if(!plan)
					var/target// = plan? plan.target : null
					var/list/targets = list()
					for(var/actor/A in orange(src,10))
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
		actor/target
		list/path
	New(actor/self, actor/_target)
		target = _target
		advance(self)
	proc
		advance(actor/self)
			if(rand()*4 >= 3) del path
			if(!path || !path.len)
				self.act(self.tile_attack, target)
			else
				var/turf/next_step = path[1]
				path.Remove(next_step)
				self.act(self.tile_move, next_step)
		blocked(actor/self)
			for(var/I = 1 to 5)
				var/turf/dest = locate(target.x,target.y,target.z)
				var/turf/start = locate(self.x,self.y,self.z)
				path = AStar(start,dest,/turf/proc/AdjacentTurfs,/turf/proc/Distance,       0,          30,         null,/turf/proc/Distance)
					//       start, end,                adjacent,               dist,maxnodes,maxnodedepth,mintargetdist,        minnodedist)
				if(path)
					return
				sleep(30)
			if(!path)
				del src