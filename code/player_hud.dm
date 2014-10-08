character
	parent_type = /actor
	var
		character/hud/hud
	Del()
		del hud
	proc
		connect(player/new_player)
			if(!hud)
				hud = new()
			hud.loc = src
			hud.connect(new_player)
character/hud
	parent_type = /obj
	var
		player/player
		list/hotbars = list()
		character/hud/selection_display/selection_display
	New()
		. = ..()
		var/inventory_size = 4
		var/y_offset = (world.icon_size+TILE_SIZE)/2
		var/x_offset = (world.icon_size-TILE_SIZE)/2
		var/list/temp_inv    = new(); temp_inv.len    = inventory_size
		var/list/temp_equip  = new(); temp_equip.len  = inventory_size
		var/list/temp_skills = new(); temp_skills.len = inventory_size
		// Inventory Hot Bar
		var/character/hud/hotbar/slot = new(src)
		slot.setup(temp_inv, null, 1, inventory_size, "EAST", "CENTER", x_offset, y_offset, 'hud_1x5.dmi', "inventory")
		hotbars.Add(slot)
		// Equipment Hot Bar
		slot = new(src)
		var/list/equip_req = list(TILE_CHARM, TILE_ARMOR, TILE_OFFHAND, TILE_WEAPON)
		slot.setup(temp_equip, equip_req, 1, inventory_size, "WEST", "CENTER", x_offset, y_offset, 'hud_1x5.dmi', "equipment")
		hotbars.Add(slot)
		// Skills Hot Bar
		slot = new(src)
		y_offset *= -1
		y_offset -= 100
		var/list/skills_req = list(TILE_NONE,TILE_NONE,TILE_NONE,TILE_NONE)
		slot.setup(temp_skills, skills_req, 1, inventory_size, "WEST", "CENTER", x_offset, y_offset, 'hud_1x5.dmi', "skills")
		hotbars.Add(slot)
		// Selection Display
		selection_display = new(src)
		selection_display.setup()
	Del()
		for(var/character/hud/hotbar/_hotbar in hotbars)
			del _hotbar
		. = ..()
	proc
		connect(player/new_player)
			player = new_player
			selection_display.connect(new_player)
			for(var/character/hud/hotbar/_hotbar in hotbars)
				_hotbar.connect(new_player)
character/hud/selection_display
	parent_type = /obj
	mouse_drop_zone = TRUE
	layer = HOTBAR_LAYER
	bound_width = 3*HOTBAR_TILE_SIZE
	icon = 'hud_3x2.dmi'
	icon_state = "selection_display"
	var
		player/player
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
		connect(player/new_player)
			player = new_player
			if(player.client)
				player.client.screen.Add(src)
				player.client.screen.Add(primary)
				player.client.screen.Add(secondary)
			if(!player.primary)
				select(attack_tile, PRIMARY)
		select(tile/selected_tile, which=PRIMARY)
			switch(which)
				if(PRIMARY)
					player.primary = selected_tile
					primary.icon = selected_tile.icon
					primary.icon_state = selected_tile.icon_state
				if(SECONDARY)
					player.secondary = selected_tile
					secondary.icon = selected_tile.icon
					secondary.icon_state = selected_tile.icon_state
		deselect(tile/deselect_tile)
			if(deselect_tile == player.primary)
				player.primary = null
				primary.icon = null
			if(deselect_tile == player.secondary)
				player.secondary = null
				secondary.icon = null
character/hud/hotbar
	parent_type = /obj
	mouse_drop_zone = TRUE
	layer = HOTBAR_LAYER
	var
		player/player
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
		list/requirements
	proc
		setup(list/_reference, list/_requirements, _width, _height, _align_x, _align_y, _offset_x, _offset_y, _icon, _icon_state)
			width = _width
			height = _height
			reference = _reference
			requirements = _requirements
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
		connect(player/new_player)
			player = new_player
			if(player.client)
				player.client.screen.Add(src)
				for(var/atom/tile in reference)
					player.client.screen.Add(tile)
		add_tile(tile/drop_tile, pixel_x, pixel_y)
			// Determine Index where tile will be dropped, based on cursor posision
			var old_index = reference.Find(drop_tile)
			var/slot_x = round(pixel_x/HOTBAR_TILE_SIZE)+1
			var/slot_y = round(pixel_y/HOTBAR_TILE_SIZE)+1
			var compound_index = slot_x + ((slot_y-1)*width)
			if(compound_index <= 0 || compound_index > reference.len)
				return
			// Determine if this tile is the type of tile this position accepts
			if(requirements && compound_index <= requirements.len)
				var/required = requirements[compound_index]
				if(required != null)
					// Null means "no requirements", which is separate from 0 (TILE_NONE), which means "nothing can go here".
					if(!(required&drop_tile.tile_type))
						return
			if(reference[compound_index])
				return // TODO
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
		if(!istype(new_loc, /character/hud/hotbar))
			player.character.halt_action(drop_tile)
			if(drop_tile == player.primary || drop_tile == player.secondary)
				player.character.hud.selection_display.deselect(drop_tile)
				if(!player.primary)
					player.character.hud.selection_display.select(attack_tile, PRIMARY)
		drop_tile.layer = initial(drop_tile.layer)
		if(player.client)
			player.client.screen.Remove(drop_tile)
		. = ..()
	Entered(tile/drop_tile)
		drop_tile.layer = HUD_TILE_LAYER
		if(player.client)
			player.client.screen.Add(drop_tile)
		. = ..()