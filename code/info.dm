info
	background
		parent_type = /obj
		Click()
			var/player/user = usr
			if(istype(user) && user.lock && hascall(user.lock, "close_interaction"))
				call(user.lock, "close_interaction")(user)
	var
		info/background/background
		obj/banner
		obj/description
		background_image = 'info_bg_1.png'
		banner_image = 'info_top_cave.png'
		description_text = ""
	New(player, _description, _banner, _background)
		background_image = _background || background_image
		banner_image = _banner || banner_image
		description_text = _description || description_text
		display(player)
		. = ..()
	Del()
		del background
		del banner
		del description
		. = ..()
	proc
		display(player/player)
			// Background
			background = new()
			background.icon = background_image
			background.screen_loc = "Center-4:[8],Center-4:[8]"
			background.layer = HOTBAR_LAYER
			// Top Banner
			banner = new()
			banner.icon = banner_image
			banner.screen_loc = "CENTER-4:[16],Center+2:[16]"
			banner.layer = HOTBAR_LAYER+1
			banner.mouse_opacity = 0
			// Text
			description = new()
			description.maptext = {"<b style="font-family: georgia; vertical-align:top; text-align:justify;">[description_text]</b>"}
			description.screen_loc = "CENTER-4:[16],Center-4:[16-4]"
			description.layer = HOTBAR_LAYER+1
			description.maptext_width = 256
			description.maptext_height = 192-2
			description.mouse_opacity = 0
			//
			background.alpha = 0
			banner.alpha = 0
			description.alpha = 0
			player.client.screen.Add(background, banner, description)
			animate(background, alpha=255, 3)
			animate(banner, alpha=255, 3)
			animate(description, alpha=255, 3)
		close_interaction(player/user)
			if(user.lock == src)
				user.lock = null
			animate(background, alpha=0, 3)
			animate(banner, alpha=0, 3)
			animate(description, alpha=0, 3)
			spawn(10)
				Del()