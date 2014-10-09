block
	parent_type = /obj
	density = TRUE
	var
		resource = null
		resource_amount = null
		destroyable = TRUE
		resource_delay = 0
	proc
		gather(actor/gatherer)
			if(resource && resource_amount && destroyable)
				density = FALSE
				var/angle_offset = rand(0,360)
				for(var/I = 1 to resource_amount)
					var/tile/T = new resource()
					T.center(src)
					var/angle = I*(360/resource_amount)+angle_offset
					T.Move(T.loc, 0, cos(angle)*10, sin(angle)*10)
				del src



block/bush
	icon = 'rectangles.dmi'
	icon_state = "bush"
	resource = /tile/wood
	resource_amount = 3
tile/wood
	icon_state = "wood"
	resource = "wood"