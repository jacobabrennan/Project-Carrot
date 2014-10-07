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
	Del()
		for(var/player/hud/hotbar/_hotbar in hotbars)
			del _hotbar
		. = ..()
	proc
		connect(client/new_client)
			client = new_client
			for(var/player/hud/hotbar/_hotbar in hotbars)
				_hotbar.connect(new_client)
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
			// Calculate Screen Loc
			var/loc_text = align_x
			loc_text += (abs(offset_x) > 0)? ":[offset_x]" : ""
			loc_text += ",[align_y]"
			loc_text += (abs(offset_y) > 0)? ":[offset_y]" : ""
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
		drop_tile.layer = initial(drop_tile.layer)
		client.screen.Remove(drop_tile)
		. = ..()
	Entered(tile/drop_tile)
		drop_tile.layer = HUD_TILE_LAYER
		client.screen.Add(drop_tile)
		. = ..()