block
	parent_type = /obj
	density = TRUE
	var
		resource = null
		resource_amount = null
		destroyable = TRUE
		resource_delay = 30
		interact
		bp_cost = 1
	proc
		gather(character/gatherer)
			if(!istype(gatherer) || !gatherer.player) return
			if(resource && resource_amount && destroyable)
				if(gatherer.player.build_points < bp_cost)
					// TODO: Display "can't gather" animation of some sort
					world << "You don't have enough Building Points to gather this resource."
					return
				gatherer.player.adjust_bp(-bp_cost)
				density = FALSE
				var/angle_offset = rand(0,360)
				for(var/I = 1 to resource_amount)
					var/tile/T = new resource()
					T.center(src)
					var/angle = I*(360/resource_amount)+angle_offset
					T.Move(T.loc, 0, cos(angle)*10, sin(angle)*10)
				del src
		interact(actor/user){}



block/bush
	icon = 'rectangles.dmi'
	icon_state = "bush"
	opacity = TRUE
	resource = /tile/wood
	resource_amount = 3
	resource_delay = 50
tile/wood
	icon_state = "wood"
	resource = "wood"

