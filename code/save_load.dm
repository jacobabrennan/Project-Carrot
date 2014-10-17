world
	New()
		. = ..()
		map_handler.load()
var/map_handler/map_handler = new()
map_handler
	parent_type = /dmm_suite
	var
		loaded = FALSE
	proc
		save(var/map_name as text)
			/*
				The save() verb saves a map with name "[map_name].dmm".
				*/
			if((ckey(map_name) != lowertext(map_name)) || (!ckey(map_name)))
				usr << "The file name you supplied includes invalid characters, or is empty. Please supply a valid file name."
				return
			var/dmm_suite/D = new()
			var/turf/south_west_deep = locate(1,1,1)
			var/turf/north_east_shallow = locate(world.maxx,world.maxy,world.maxz)
			D.save_map(south_west_deep, north_east_shallow, map_name, flags = DMM_IGNORE_PLAYERS)
			usr << {"The file [map_name].dmm has been saved. It can be found in the same directly in which this library resides.\n\
		 (Usually: C:\\Documents and Settings\\Your Name\\Application Data\\BYOND\\lib\\iainperegrine\\dmm_suite)"}


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
			load_map(file("maps/kells.dmm"))
			loaded = TRUE
			world << "Finished Loading"