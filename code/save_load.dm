player
	Login()
		. = ..()
		load()
	Logout()
		save()
		. = ..()
	proc
		save()
			var/savefile/S = new("player_saves/[ckey].sav")
			S["build_points"] << build_points
			S["weapon"] << hud.equipment.weapon
			S["offhand"] << hud.equipment.offhand
			S["body"] << hud.equipment.body
			S["charm"] << hud.equipment.charm
			S["inventory"] << hud.inventory.reference
			S["crafting"] << hud.crafting.reference
		load()
			if(!fexists("player_saves/[ckey].sav")) return
			var/savefile/S = new("player_saves/[ckey].sav")
			var/bp
			var/tile/weapon
			var/tile/offhand
			var/tile/body
			var/tile/charm
			var/list/inventory
			var/list/crafting
			S["build_points"] >> bp
			S["weapon"]       >> weapon
			S["offhand"]      >> offhand
			S["body"]         >> body
			S["charm"]        >> charm
			S["inventory"]    >> inventory
			S["crafting"]     >> crafting
			adjust_bp(bp)
			if(weapon ) hud.equipment.add_tile(weapon , 1)
			if(offhand) hud.equipment.add_tile(offhand, 2)
			if(body   ) hud.equipment.add_tile(body   , 3)
			if(charm  ) hud.equipment.add_tile(charm  , 4)
			for(var/tile/T in inventory)
				hud.inventory.add_tile(T)
			for(var/tile/T in crafting)
				hud.crafting.add_tile(T)
world
	New()
		. = ..()
		map_handler.load()
var/map_handler/map_handler = new()
map_handler
	parent_type = /dmm_suite
	var
		loaded = FALSE
		map_name = "maps/live_test.dmm"
	proc
		save()
			world << "Starting Save"
			var/turf/south_west_deep = locate(1,1,1)
			var/turf/north_east_shallow = locate(world.maxx,world.maxy,world.maxz)
			var/file_text = write_map(south_west_deep, north_east_shallow, flags = DMM_IGNORE_MOBS|DMM_IGNORE_TURF_VARS)
			if(fexists(map_name))
				fdel(map_name)
			var/saved_map = file(map_name)
			saved_map << file_text
			world << "Save Complete"


		write()
			/*
				The write() verb creates a text string of the map in dmm format
					and displays it in the client's browser.
				*/
			var/dmm_suite/D = new()
			var/turf/south_west_deep = locate(1,1,1)
			var/turf/north_east_shallow = locate(world.maxx,world.maxy,world.maxz)
			var/map_text = D.write_map(south_west_deep, north_east_shallow, flags = DMM_IGNORE_PLAYERS)
			usr << browse("<pre>[map_text]</pre>")


		load()
			world << "Loading"
			var/map
			if(!fexists(map_name))
				map = file("maps/kells.dmm")
			else
				map = file(map_name)
			load_map(map)
			loaded = TRUE
			world << "Finished Loading"