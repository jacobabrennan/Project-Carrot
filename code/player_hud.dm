player
	var
		player/hud/hud = new()
	Login(client/new_client)
		. = ..()
		hud.connect(client)
player/hud
	parent_type = /datum
	var
		client/client
		list/hotbars = list()
		player/hud/selection_display/selection_display = new()
	New()
		. = ..()
		var/inventory_size = 4
		var/y_offset = (world.icon_size+TILE_SIZE)/2
		var/x_offset = (world.icon_size-TILE_SIZE)/2
		var/list/temp_inv    = new(); temp_inv.len    = inventory_size
		var/list/temp_equip  = new(); temp_equip.len  = inventory_size
		var/list/temp_skills = new(); temp_skills.len = inventory_size
		// Inventory Hot Bar
		var/player/hud/hotbar/slot = new()
		slot.setup(temp_inv, 1, inventory_size, "EAST", "CENTER", x_offset, y_offset, 'hud_1x5.dmi', "inventory")
		hotbars.Add(slot)
		// Equipment Hot Bar
		slot = new()
		slot.setup(temp_equip, 1, inventory_size, "WEST", "CENTER", x_offset, y_offset, 'hud_1x5.dmi', "equipment")
		hotbars.Add(slot)
		// Skills Hot Bar
		slot = new()
		y_offset *= -1
		y_offset -= 100
		slot.setup(temp_skills, 1, inventory_size, "WEST", "CENTER", x_offset, y_offset, 'hud_1x5.dmi', "skills")
		hotbars.Add(slot)
		// Selection Display
		selection_display.setup()
	Del()
		for(var/player/hud/hotbar/_hotbar in hotbars)
			del _hotbar
		. = ..()
	proc
		connect(client/new_client)
			client = new_client
			selection_display.connect(new_client)
			for(var/player/hud/hotbar/_hotbar in hotbars)
				_hotbar.connect(new_client)
player/hud/selection_display
	parent_type = /obj
	mouse_drop_zone = TRUE
	layer = HOTBAR_LAYER
	bound_width = 3*HOTBAR_TILE_SIZE
	icon = 'hud_3x2.dmi'
	icon_state = "selection_display"
	var
		client/client
		obj/primary
		obj/secondary
	Del()
		del primary
		del secondary
	proc
		setup()
			primary = new()
			secondary = new()
			for(var/obj/O in list(primary,secondary))
				O.bound_width = TILE_SIZE
				O.bound_height = TILE_SIZE
				O.layer = HUD_TILE_LAYER
			primary.screen_loc = "CENTER:-[9],NORTH:7"
			secondary.screen_loc = "CENTER:[17],NORTH:7"
			screen_loc = "CENTER:-23,NORTH:6"
		connect(client/new_client)
			client = new_client
			client.screen.Add(src)
			client.screen.Add(primary)
			client.screen.Add(secondary)
			if(!client.player.primary)
				select(attack_tile, PRIMARY)
		select(tile/selected_tile, which=PRIMARY)
			switch(which)
				if(PRIMARY)
					client.player.primary = selected_tile
					primary.icon = selected_tile.icon
					primary.icon_state = selected_tile.icon_state
				if(SECONDARY)
					client.player.secondary = selected_tile
					secondary.icon = selected_tile.icon
					secondary.icon_state = selected_tile.icon_state
		deselect(tile/deselect_tile)
			if(deselect_tile == client.player.primary)
				client.player.primary = null
				primary.icon = null
			if(deselect_tile == client.player.secondary)
				client.player.secondary = null
				secondary.icon = null
player/hud/hotbar
	parent_type = /obj
	mouse_drop_zone = TRUE
	layer = HOTBAR_LAYER
	var
		client/client
		width
		height
		align_x
		align_y
		offset_x
		offset_y
		offset_x_atom
		offset_y_atom
		offset_x_px
		offset_y_px
		list/reference
	proc
		setup(list/_reference, _width, _height, _align_x, _align_y, _offset_x, _offset_y, _icon, _icon_state)
			width = _width
			height = _height
			reference = _reference
			icon = _icon
			icon_state = _icon_state
			align_x = _align_x
			align_y = _align_y
			offset_x = _offset_x
			offset_y = _offset_y
			offset_x_atom = 0
			offset_y_atom = 0
			offset_x_px = offset_x % world.icon_size
			offset_y_px = offset_y % world.icon_size
			if(offset_x)
				offset_x_atom = round(abs(offset_x)/world.icon_size) * ((offset_x > 0)? 1 : -1)
			if(offset_y)
				offset_y_atom = round(abs(offset_y)/world.icon_size) * ((offset_y > 0)? 1 : -1)
			// Calculate Screen Loc
			var/loc_text = align_x
			if(offset_x_atom)
				loc_text += (offset_x_atom > 0)? "+[offset_x_atom]" : "[offset_x_atom]"
			loc_text += (abs(offset_x) > 0)? ":[offset_x_px]" : ""
			loc_text += ",[align_y]"
			if(offset_y_atom)
				loc_text += (offset_y_atom > 0)? "+[offset_y_atom]" : "[offset_y_atom]"
			loc_text += (abs(offset_y) > 0)? ":[offset_y_px]" : ""
			screen_loc = loc_text
		connect(client/new_client)
			client = new_client
			client.screen.Add(src)
			for(var/atom/tile in reference)
				client.screen.Add(tile)
		add_tile(tile/drop_tile, pixel_x, pixel_y)
			var old_index = reference.Find(drop_tile)
			var/slot_x = round(pixel_x/HOTBAR_TILE_SIZE)+1
			var/slot_y = round(pixel_y/HOTBAR_TILE_SIZE)+1
			var compound_index = slot_x + ((slot_y-1)*width)
			if(compound_index <= 0 || compound_index > reference.len)
				return
			if(reference[compound_index])
				return // TODO
			else
				if(old_index)
					reference[old_index] = null
				reference[compound_index] = drop_tile
				var/slot_px_x = (slot_x-1)*HOTBAR_TILE_SIZE + 1
				var/slot_px_y = (slot_y-1)*HOTBAR_TILE_SIZE + 1
				var/loc_text = align_x
				loc_text += (abs(offset_x) > 0)? ":[offset_x+slot_px_x]" : ""
				loc_text += ",[align_y]"
				loc_text += (abs(offset_y) > 0)? ":[offset_y+slot_px_y]" : ""
				drop_tile.screen_loc = loc_text
				drop_tile.Move(src)
	Exited(tile/drop_tile, atom/new_loc)
		if(new_loc != src)
			reference[reference.Find(drop_tile)] = null
		if(!istype(new_loc, /player/hud/hotbar))
			if(drop_tile == client.player.primary || drop_tile == client.player.secondary)
				client.player.hud.selection_display.deselect(drop_tile)
				if(!client.player.primary)
					client.player.hud.selection_display.select(attack_tile, PRIMARY)
		drop_tile.layer = initial(drop_tile.layer)
		client.screen.Remove(drop_tile)
		. = ..()
	Entered(tile/drop_tile)
		drop_tile.layer = HUD_TILE_LAYER
		client.screen.Add(drop_tile)
		. = ..()