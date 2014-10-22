block
	parent_type = /obj
	density = TRUE
	layer = BLOCK_OVER_LAYER
	var
		resource = null
		resource_amount = null
		destroyable = TRUE
		resource_delay = 30
		interact
		bp_cost = 1
		exaustable = TRUE
	proc
		gather(player/gatherer)
			if(!istype(gatherer))
				return
			if(resource && resource_amount && destroyable)
				if(gatherer.build_points < bp_cost)
					// TODO: Display "can't gather" animation of some sort
					gatherer << "You don't have enough Building Points to gather this resource."
					return
				gatherer.adjust_bp(-bp_cost)
				density = FALSE
				var/angle_offset = rand(0,360)
				for(var/I = 1 to resource_amount)
					var/tile/T = new resource()
					T.center(src)
					var/angle = I*(360/resource_amount)+angle_offset
					T.Move(T.loc, 0, cos(angle)*10, sin(angle)*10)
				if(exaustable)
					del src
		interact(actor/user){}

