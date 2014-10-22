var/tutorial_manager/tutorial_manager = new()
tutorial_manager
	var
		list/placements = new()
		tutorial_width = 25
		tutorial_height = 25
	proc
		create_tutorial(player)
			var/tutorial_manager/tutorial/tutorial = new()
			park_tutorial(tutorial)
			ASSERT(fexists("maps/tutorial.dmm"))
			map_handler.load_map(file("maps/tutorial.dmm"), list(tutorial.x, tutorial.y, tutorial.z))
			tutorial.setup(player)
			. = ..()
		park_tutorial(tutorial_manager/tutorial/tutorial)
			var/grid_width  = round(world.maxx/tutorial_width )
			var/grid_height = round(world.maxy/tutorial_height)
			var/parking_level
			var/parking_spot
			for(var/z = 1 to placements.len)
				var/list/possible_level = placements[z]
				if(!possible_level) continue
				for(var/spot_index = 1 to possible_level.len)
					var/spot = possible_level[spot_index]
					if(spot) continue // Occupied
					parking_level = z
					parking_spot = spot_index
					break
				if(parking_spot) break
			if(!parking_level)
				var/list/parking_area = list()
				parking_area.len = grid_width * grid_height
				placements.len = (++world.maxz)
				placements[placements.len] = parking_area
				parking_level = placements.len
				parking_spot = 1
			var/parking_area = placements[parking_level]
			parking_area[parking_spot] = tutorial
			tutorial.x = ( (parking_spot-1)%grid_width        ) * tutorial_width  +1
			tutorial.y = ( round((parking_spot-1)/grid_width) ) * tutorial_height +1
			tutorial.z = parking_level
	tutorial
		parent_type = /datum
		var
			x
			y
			z
			player/player
		proc
			setup(_player)
				player = _player
				var/turf/low = locate(x,y,z)
				var/turf/high = locate(x-1+tutorial_manager.tutorial_width, y-1+tutorial_manager.tutorial_height, z)
				player.loc = locate(/tutorial_manager/tutorial/region/start_tile) in block(low,high)
			begin()
		//
		region
			parent_type = /region
			start_tile
				parent_type = /turf
				icon = 'cave.dmi'
				icon_state = "dirt_1"