character
	parent_type = /actor
	iteration_delay = 1
	var
		character/hud/hud
		player/player
	Del()
		del hud
	proc
		connect(player/new_player)
			player = new_player
			if(!hud)
				hud = new()
			hud.loc = src
			hud.connect(new_player)
	adjust_health(amount, actor/attacker)
		. = ..()
		hud.health_bar.adjust(health, max_health())
character/hud
	parent_type = /obj
	var
		player/player
		character/hud/selection_display/selection_display
		character/hud/health_bar/health_bar
		character/hud/bp_display/bp_display
		character/hud/hotbar/inventory/inventory
		character/hud/hotbar/equipment/equipment
		character/hud/hotbar/skills/skills
		character/hud/hotbar/crafting/crafting
	New()
		. = ..()
		inventory = new(src)
		equipment = new(src)
		skills    = new(src)
		crafting  = new(src)
		// Selection Display
		selection_display = new(src)
		selection_display.setup()
		// Health Bar
		health_bar = new(src)
		health_bar.setup()
		// CP Display
		bp_display = new(src)
	Del()
		del inventory
		del equipment
		del skills
		del crafting
		del selection_display
		del health_bar
		del bp_display
		. = ..()
	proc
		connect(player/new_player)
			player = new_player
			selection_display.connect(new_player)
			health_bar.connect(new_player)
			bp_display.connect(new_player)
			for(var/character/hud/hotbar/_hotbar in list(inventory,equipment,skills,crafting))
				_hotbar.connect(new_player)
character/hud/health_bar
	parent_type = /obj
	layer = HOTBAR_LAYER
	screen_loc = "CENTER-3:21,NORTH:14"
	var
		player/player
		obj/bar_exact
		obj/bar_moving
		obj/bar_cap
		obj/bar_foot
	Del()
		del bar_exact
		del bar_moving
		del bar_cap
		del bar_foot
	proc
		setup()
			bar_exact = new()
			bar_moving = new()
			bar_foot = new()
			bar_cap = new()
			for(var/obj/O in list(bar_exact, bar_cap, bar_foot, bar_moving))
				O.layer = HUD_TILE_LAYER+1
				O.icon = 'rectangles.dmi'
			bar_moving.layer = HUD_TILE_LAYER
			bar_exact.icon_state = "health_bar"
			bar_cap.icon_state = "health_cap"
			bar_foot.icon_state = "health_foot"
			bar_moving.icon_state = "red_bar"
			bar_exact.screen_loc = screen_loc
			bar_moving.screen_loc = screen_loc
			bar_foot.screen_loc = "CENTER-2:21,NORTH:14"
			bar_cap.screen_loc = screen_loc
		connect(player/new_player)
			player = new_player
			adjust(new_player.character.health, new_player.character.max_health())
			if(player.client)
				//player.client.screen.Add(src)
				for(var/obj/O in list(bar_exact, bar_cap, bar_foot, bar_moving))
					player.client.screen.Add(O)
	proc
		adjust(current, max)
			var/health_percent = current/max
			var/bar_width = 98
			var/icon_width = 32
			var/x_scale = health_percent*bar_width/icon_width
			var/x_offset = -(health_percent*bar_width)/2 + world.icon_size/2
			var/matrix/M = matrix()
			M.Scale(x_scale,1)
			M.Translate(x_offset,0)
			bar_exact.transform = M
			animate(bar_moving, transform = M, 5)
			M = matrix()
			M.Translate(2*x_offset-32,0)
			bar_cap.transform = M
			var C = rgb(
				round(256*cos(health_percent*90)),
				round(256*sin(health_percent*90)),
				0
			)
			animate(bar_cap, color = C, 5)
			animate(bar_exact, color = C, 5)
			animate(bar_foot, color = C, 5)

character/hud/bp_display
	parent_type = /obj
	layer = HUD_TILE_LAYER
	screen_loc = "WEST:8,NORTH:9"
	var
		player/player
	proc
		connect(player/new_player)
			player = new_player
			adjust(new_player.build_points)
			if(player.client)
				player.client.screen.Add(src)
	proc
		adjust(current)
			if(current >= 1)
				current = round(current)
				maptext = {"<b style="font-family:press-start2p;font-size:16px;text-align:center; v-align:middle; color:white">[current]</b>"}
			else
				maptext = ""

character/hud/selection_display
	parent_type = /obj
	layer = HOTBAR_LAYER
	bound_width = 6*HOTBAR_TILE_SIZE
	icon = 'selection_display.png'
	var
		player/player
		obj/primary
		obj/secondary
		tile/attack
		tile/gather
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
			screen_loc = "CENTER-5:-25,NORTH:6"
		connect(player/new_player)
			player = new_player
			attack = player.character.tile_attack
			gather = player.character.tile_gather
			if(player.client)
				player.client.screen.Add(src)
				player.client.screen.Add(primary)
				player.client.screen.Add(secondary)
				player.client.screen.Add(attack)
				player.client.screen.Add(gather)
			if(!player.primary)
				select(player.character.tile_attack, PRIMARY)
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
	icon = 'hud_1x5.dmi'
	bound_height = 130
	bound_width = 26
	var
		player/player
		width = 1
		height = 4
		align_x
		align_y
		offset_x
		offset_y
		offset_x_atom
		offset_y_atom
		offset_x_px
		offset_y_px
		list/reference = new(4)
		list/requirements
	New()
		. = ..()
		position()
	proc
		position()
			offset_x_atom = 0
			offset_y_atom = 0
			offset_x_px = offset_x % world.icon_size
			offset_y_px = offset_y % world.icon_size
			if(offset_x)
				offset_x_atom = round(abs(offset_x)/world.icon_size) * ((offset_x > 0)? 1 : -1)
			if(offset_y)
				offset_y_atom = round(abs(offset_y)/world.icon_size) * ((offset_y > 0)? 1 : -1)
			var/loc_text = align_x
			if(offset_x_atom)
				loc_text += (offset_x_atom > 0)? "+[offset_x_atom]" : "[offset_x_atom]"
			loc_text += (abs(offset_x) > 0)? ":[offset_x_px]" : ""
			loc_text += ",[align_y]"
			if(offset_y_atom)
				loc_text += (offset_y_atom > 0)? "+[offset_y_atom]" : "[offset_y_atom]"
			loc_text += (abs(offset_y) > 0)? ":[offset_y_px]" : ""
			screen_loc = loc_text
		/*setup(list/_reference, _width, _height, _align_x, _align_y, _offset_x, _offset_y, _icon, _icon_state)
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
			offset_x_atom = 0
			offset_y_atom = 0
			offset_x_px = offset_x % world.icon_size
			offset_y_px = offset_y % world.icon_size
			if(offset_x)
				offset_x_atom = round(abs(offset_x)/world.icon_size) * ((offset_x > 0)? 1 : -1)
			if(offset_y)
				offset_y_atom = round(abs(offset_y)/world.icon_size) * ((offset_y > 0)? 1 : -1)
			var/loc_text = align_x
			if(offset_x_atom)
				loc_text += (offset_x_atom > 0)? "+[offset_x_atom]" : "[offset_x_atom]"
			loc_text += (abs(offset_x) > 0)? ":[offset_x_px]" : ""
			loc_text += ",[align_y]"
			if(offset_y_atom)
				loc_text += (offset_y_atom > 0)? "+[offset_y_atom]" : "[offset_y_atom]"
			loc_text += (abs(offset_y) > 0)? ":[offset_y_px]" : ""
			screen_loc = loc_text*/
		connect(player/new_player)
			player = new_player
			if(player.client)
				player.client.screen.Add(src)
				for(var/atom/tile in reference)
					player.client.screen.Add(tile)
		find_slot(pixel_x, pixel_y)
			var/slot_x = round(pixel_x/HOTBAR_TILE_SIZE)+1
			var/slot_y = round(pixel_y/HOTBAR_TILE_SIZE)+1
			var/compound_index = slot_x + ((slot_y-1)*width)
			compound_index = (reference.len+1) - compound_index
			return compound_index
		find_screen_loc(compound_index)
			var/slot = (reference.len+1) - compound_index
			var/slot_x = 1+(slot % width)
			var/slot_y = 1+(round(max(0,slot-1)/width))
			var/slot_px_x = (slot_x-1)*HOTBAR_TILE_SIZE + 1
			var/slot_px_y = (slot_y-1)*HOTBAR_TILE_SIZE + 1
			var/loc_text = align_x
			loc_text += (abs(offset_x) > 0)? ":[offset_x+slot_px_x]" : ""
			loc_text += ",[align_y]"
			loc_text += (abs(offset_y) > 0)? ":[offset_y+slot_px_y]" : ""
			return loc_text
		add_tile(tile/drop_tile, compound_index, pixel_y)
			var old_index = reference.Find(drop_tile)
			if(!compound_index) // No coordinates supplied, find an empty slot.
				for(var/I = 1 to reference.len)
					if(!reference[I])
						compound_index = I
						break
			else if(pixel_y) // Mouse coordinates supplied instead of index
				compound_index = find_slot(compound_index, pixel_y)
			if(!compound_index || compound_index <= 0 || compound_index > reference.len)
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
			drop_tile.screen_loc = find_screen_loc(compound_index)
			return drop_tile.Move(src)
	Exited(tile/drop_tile, atom/new_loc)
		if(new_loc != src)
			reference[reference.Find(drop_tile)] = null
		if(!istype(new_loc, /character/hud/hotbar))
			player.character.halt_action(drop_tile)
			if(drop_tile == player.primary || drop_tile == player.secondary)
				player.character.hud.selection_display.deselect(drop_tile)
				if(!player.primary)
					player.character.hud.selection_display.select(player.character.tile_attack, PRIMARY)
		drop_tile.layer = initial(drop_tile.layer)
		if(player.client)
			player.client.screen.Remove(drop_tile)
		. = ..()
	Entered(tile/drop_tile, turf/old_loc)
		drop_tile.layer = HUD_TILE_LAYER
		if(player.client)
			player.client.screen.Add(drop_tile)
		. = ..()
		//if(istype(old_loc)) // TODO: Replace with "animate on pixel_x/y". Whatever that means.
		//	missile(drop_tile, old_loc, player.character)
character/hud/hotbar/inventory
	align_x = "EAST"
	align_y = "Center"
	icon_state = "inventory"
	offset_x = -TILE_SIZE+(32+TILE_SIZE)/2 //(world.icon_size+TILE_SIZE)/2 // LEGACY
	offset_y =  TILE_SIZE+(32-TILE_SIZE)/2 //(world.icon_size-TILE_SIZE)/2
character/hud/hotbar/crafting
	align_x = "EAST"
	align_y = "Center"
	icon_state = "crafting"
	offset_x = -TILE_SIZE+(32+TILE_SIZE)/2
	offset_y = -TILE_SIZE+(32-TILE_SIZE)/2 - 105
	Entered(tile/drop_tile)
		. = ..()
		for(var/I = 1; I <= reference.len; I++)
			if(!reference[I])
				return
		var result = recipe_manager.craft(player.character, reference.Copy())
		garbage.temp_storage(result)
		if(result)
			add_tile(result, 1)
	tile_filler
		parent_type = /tile/value
		icon_state = "filler"
		value = 0
		Move(character/hud/hotbar/crafting/new_loc)
			. = ..()
			if(!istype(new_loc) && new_loc != garbage)
				Move(garbage)
		Click()
			Move(garbage)
character/hud/hotbar/equipment
	align_x = "WEST"
	align_y = "Center"
	icon_state = "equipment"
	offset_x = -TILE_SIZE+(32+TILE_SIZE)/2
	offset_y =  TILE_SIZE+(32-TILE_SIZE)/2
	var
		tile/weapon
		tile/offhand
		tile/body
		tile/charm
	/* Create a global list in global scope, keep it out of the object tree, reuse for all equipment hotbars. */
	/var/list/requirements_equip = list(TILE_WEAPON,TILE_OFFHAND,TILE_BODY,TILE_CHARM)
	New()
		. = ..()
		requirements = requirements_equip
	Entered(tile/added_tile)
		. = ..()
		switch(reference.Find(added_tile))
			if(1) weapon = added_tile
			if(2) offhand = added_tile
			if(3) body = added_tile
			if(4) charm = added_tile
	Exited(tile/removed_tile)
		switch(reference.Find(removed_tile))
			if(1) weapon = null
			if(2) offhand = null
			if(3) body = null
			if(4) charm = null
		. = ..()
character/hud/hotbar/skills
	align_x = "WEST"
	align_y = "Center"
	icon_state = "skills"
	offset_x = -TILE_SIZE+(32+TILE_SIZE)/2
	offset_y = -TILE_SIZE+(32-TILE_SIZE)/2 - 105
	/* Create a global list in global scope, keep it out of the object tree, reuse for all skills hotbars. */
	/var/list/requirements_skills = list(TILE_NONE,TILE_NONE,TILE_NONE,TILE_NONE)
	New()
		. = ..()
		requirements = requirements_skills