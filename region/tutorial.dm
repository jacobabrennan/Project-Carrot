var/tutorial_manager/tutorial_manager = new()
tutorial_manager
	var
		list/placements = new()
		tutorial_width = 25
		tutorial_height = 25
	proc
		create_tutorial(player/player)
			var/tutorial_manager/tutorial/tutorial = new()
			park_tutorial(tutorial)
			ASSERT(fexists("maps/tutorial.dmm"))
			map_handler.loaded = FALSE
			map_handler.load_map(file("maps/tutorial.dmm"), list(tutorial.x, tutorial.y, tutorial.z))
			map_handler.loaded = TRUE
			tutorial.setup(player)
			. = ..()
		destroy_tutorial(player/player)
			var/tutorial_manager/tutorial/tutorial = player.tutorial
			player.tutorial = null
			if(!tutorial) return
			unpark_tutorial(tutorial)
			for(var/y = tutorial.y to ((tutorial.y-1)+tutorial_height))
				for(var/x = tutorial.x to ((tutorial.x-1)+tutorial_width))
					sleep(3)
					var/turf/T = locate(x, y, tutorial.z)
					for(var/atom/A in T) del A
					var/area/A = T.loc
					A.contents.Remove(T)
					del T
			del tutorial
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
		unpark_tutorial(tutorial_manager/tutorial/tutorial)
			//var/grid_width  = round(world.maxx/tutorial_width )
			//var/grid_height = round(world.maxy/tutorial_height)
			var/parking_level = tutorial.z
			var/list/parking_area = placements[parking_level]
			var/parking_spot = parking_area.Find(tutorial)
			parking_area[parking_spot] = null

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
				player.tutorial = src
			begin()
			end()

		//
		region
			parent_type = /region
			start_tile
				parent_type = /turf
				icon = 'cave.dmi'
				icon_state = "dirt_1"
			end
				parent_type = /turf
				icon = 'cave.dmi'
				icon_state = "dirt_1"
				Entered(player/player)
					. = ..()
					if(!istype(player)) return
					var/obj/O = new()
					O.icon = 'rectangles.dmi'
					O.icon_state = "shade"
					O.alpha = 0
					O.layer = EFFECTS_LAYER
					O.screen_loc = "SOUTHWEST to NORTHEAST"
					O.mouse_opacity = 0
					player.client.screen.Add(O)
					animate(O, alpha = 255, 28)
					spawn(30)
						player.assign_loc(locate(TOWN_START))
						animate(O, alpha = 0, 28)
						spawn(30)
							tutorial_manager.destroy_tutorial(player)
							del O
					player.save(TRUE)
				Exit()
					return

			instruction
				parent_type = /obj
				layer = EFFECTS_LAYER
				mouse_opacity = 0
				color = "white"
				var
					_maptext
					_maptext_width = 128
					_maptext_height = 32
				New()
					. = ..()
					maptext = {"<b style="vertical-align:middle; text-align:center">[_maptext]</b>"}
					maptext_width = _maptext_width
					maptext_height = _maptext_height
player
	var
		tutorial_manager/tutorial/tutorial