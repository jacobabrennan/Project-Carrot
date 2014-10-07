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
		list/inventory_slots = new()
	New()
		. = ..()
		var/total_slots = 4
		for(var/I = 1; I <= total_slots; I++)
			var/player/hud/drop_area/slot = new()
			slot.icon = 'hud_1x1.dmi'
			slot.icon_state = "drop_space"
			slot.screen_loc = "EAST,CENTER+[round(total_slots/2)-I]"
			slot.bound_height = 26
			slot.bound_width = 26
			inventory_slots.Add(slot)
	proc
		connect(new_client)
			client = new_client
			for(var/atom/slot in inventory_slots)
				client.screen.Add(slot)
player/hud/drop_area
	parent_type = /obj
	mouse_drop_zone = TRUE
	Entered(tile/new_tile)
		new_tile.screen_loc = screen_loc
		usr.client.screen.Add(new_tile)

