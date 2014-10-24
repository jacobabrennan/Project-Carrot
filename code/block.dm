block
	parent_type = /obj
	density = TRUE
	layer = BLOCK_OVER_LAYER
	var
		resource = null
		resource_amount = null
		destroyable = TRUE
		resource_delay = 30
		interact
		bp_cost = 1
		exaustable = TRUE
	proc
		gather(player/gatherer)
			if(!istype(gatherer))
				return
			if(resource && resource_amount && destroyable)
				if(gatherer.build_points < bp_cost)
					// TODO: Display "can't gather" animation of some sort
					gatherer << {"<span class="feedback">You don't have enough Building Points to gather this resource.</span>"}
					return
				gatherer.adjust_bp(-bp_cost)
				density = FALSE
				var/angle_offset = rand(0,360)
				for(var/I = 1 to resource_amount)
					var/tile/T = new resource()
					T.center(src)
					var/angle = I*(360/resource_amount)+angle_offset
					T.Move(T.loc, 0, cos(angle)*10, sin(angle)*10)
				if(exaustable)
					del src
		interact(actor/user)
			// Return SRC to lock user into interaction.
		close_interaction(actor/user)
			// Called when an actor ceases to interact with a block they've been locked into.
			// Use this to clean-up any interfaces created in interact.

block
	storage
		icon_state = "red"
		interact = TRUE
		var
			size
			player/hud/hotbar/hotbar
			player/locked
			owner_ckey
			list/saving_contents
		New()
			. = ..()
			if(usr)
				owner_ckey = usr.ckey
			size = 21
			hotbar = new()
			hotbar.reference = new(size)
			hotbar.align_x = "Center"
			hotbar.align_y = "SOUTH"
			hotbar.width = 7
			hotbar.height = 3
			hotbar.icon = 'hud_7x4.dmi'
			hotbar.icon_state = "drop_space"
			hotbar.bound_height = 104
			hotbar.bound_width = 182
			hotbar.offset_x = -53
			hotbar.position()
			spawn(20)
				if(saving_contents)
					var/current_index = 1
					while(current_index)
						var/comma = findtext(saving_contents, ",", current_index)
						var/current_type = copytext(saving_contents,current_index,comma)
						current_index = comma? comma+1 : 0
						var/tile/new_tile = new current_type()
						hotbar.add_tile(new_tile)
		interact(player/user)
			if(locked || !istype(user)) return
			if(user.ckey != owner_ckey)
				user << {"<span class="feedback">This storage chest doesn't belong to you.</span>"}
				return
			hotbar.connect(user)
			locked = user
			return src
		close_interaction()
			/*
			This saving strategy will duplicate items if things are taken from a chest but the chest is left open during a reboot.
				The alternative is to provide a hook for the dmm_suite to call on each object as it is being saved.
				I'd rather have the potential bug than the performance drop to the dmm_suite.
				Feel free to implement a solution I haven't though of.
			Also, this doesn't save modifications of tiles.
				This isn't a problem now, but may be in the future if we start modifying tiles.
			*/
			if(locked)
				saving_contents = ""
				for(var/tile/T in hotbar.reference)
					saving_contents += "[T.type],"
					locked.client.screen.Remove(T)
				if(length(saving_contents))
					saving_contents = copytext(saving_contents, 1, length(saving_contents))
				locked.client.screen.Remove(hotbar)
				locked = null
		gather(player/gatherer)
			if(locate(/tile) in hotbar.reference)
				world << {"<span class="feedback">This chest cannot be destroyed while it is full.<span>"}
				return
			else
				. = ..()
				return
