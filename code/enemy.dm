enemy
	parent_type = /actor
	faction = FACTION_ENEMY
	see_infrared = TRUE
	sight = SEE_MOBS
	base_health = 1
	base_speed = 3
	tile_gather = null
	var
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
	proc
		behavior()
			find_target:
				for(var/I = 1 to 5)
					var/target
					var/list/targets = list()
					for(var/actor/A in oview(src,10))
						if(A.faction != faction)
							targets.Add(A)
					while(targets.len)
						target = pick(targets)
						targets.Remove(target)
						act(tile_attack, target)
						if(action && action.path)
							break find_target
					sleep(30)
			spawn()
				behavior()