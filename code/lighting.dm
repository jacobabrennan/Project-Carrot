region
	var
		ambient_hue = 0
		ambient_saturation = 0
		ambient_value = 0
player/Login()
	. = ..()
	if(client.connection == "web")
		see_invisible = 0
	else
		see_invisible = 1

atom/movable
	var
		tmp/light_source/light_source
	Move(turf/new_loc, _dir, _step_x, _step_y)
		var/old_loc = loc
		. = ..()
		if(light_source && loc != old_loc)
			if(!istype(new_loc))
				. = light_source.Move(src)
				if(!.)
					light_source.assign_loc(src)
					. = TRUE
			else
				. = light_source.Move(new_loc, _dir, _step_x, _step_y)
	New()
		. = ..()
		if(opacity && map_handler.loaded)
			opacity = FALSE
			change_opacity(TRUE)
	Del()
		del light_source
		if(opacity)
			change_opacity(FALSE)
		. = ..()
	proc
		assign_loc(turf/new_loc)
			loc = new_loc
			if(light_source)
				if(!istype(new_loc))
					light_source.Move(src)
				else
					light_source.assign_loc(loc)
		change_opacity(new_value)
			if(new_value == opacity) return
			opacity = new_value
			var/light_reach = view(LIGHT_REACH, loc)
			for(var/turf/lighting/L in light_reach)
				L.recalculate()

light_source
	parent_type = /obj
	ignore = TRUE
	var
		hue // [0,360)
		saturation // [0,1]
		value // [0,1]
		spread = 12
		reach = LIGHT_REACH
	New(turf/new_loc, _hue, _sat, _val, _reach)
		. = ..()
		hue = _hue
		saturation = _sat
		value = _val
		if(_reach) reach = _reach
		spawn()
			while(!map_handler.loaded)
				sleep(10)
			for(var/turf/lighting/L in view(reach, src))
				L.add_light_source(src)
	Del()
		var/old_loc = loc
		loc = null
		for(var/turf/lighting/L in view(reach, old_loc))
			L.remove_light_source(src, old_loc)
		. = ..()
	Move(new_loc)
		var/old_loc = loc
		var/old_view = view(reach, src)
		. = ..()
		if(old_loc == loc) return
		var/new_view = view(reach, src)
		for(var/turf/lighting/L in old_view)
			L.remove_light_source(src, old_loc)
		for(var/turf/lighting/L in new_view)
			L.add_light_source(src)
		return
	assign_loc(new_loc)
		var/old_loc = loc
		var/old_view = view(reach, src)
		. = ..()
		for(var/turf/lighting/L in old_view)
			L.remove_light_source(src, old_loc)
		for(var/turf/lighting/L in view(reach, loc))
			L.add_light_source(src)
		/*for(var/turf/lighting/L in (view(reach, src)+old_view))
			L.recalculate()*/
		return
turf
	var
		tmp/turf/lighting/lighting
		tmp/turf/lighting_web/lighting_web
	New()
		. = ..()
		if(!lighting)
			lighting = locate() in src
		if(!lighting && istype(loc, /region))
			lighting = new(src)
	lighting
		parent_type = /obj
		//blend_mode = BLEND_SUBTRACT
		mouse_opacity = 0
		ignore = TRUE
		invisibility = 1
		var
			turf/lighting/web_shade/web_shade
			image/red
			image/green
			image/blue
			white_value = 0 // Web Client Only
			red_value = 0
			green_value = 0
			blue_value = 0
		Move(){}
		New(new_loc)
			. = ..()
			web_shade = new(new_loc)
			red   = image('rectangles.dmi',src,"light",LIGHTING_LAYER)
			green = image('rectangles.dmi',src,"light",LIGHTING_LAYER)
			blue  = image('rectangles.dmi',src,"light",LIGHTING_LAYER)
			red.blend_mode = BLEND_SUBTRACT
			green.blend_mode = BLEND_SUBTRACT
			blue.blend_mode = BLEND_SUBTRACT
			red.color   = "#f00"
			green.color = "#0f0"
			blue.color  = "#00f"
			var/region/aloc = aloc(new_loc)
			var/list/ambient = hsv2rgb(aloc.ambient_hue, aloc.ambient_saturation, aloc.ambient_value)
			adjust_light(ambient["red"],ambient["green"],ambient["blue"])
		proc
			adjust_light(amo_r, amo_g, amo_b)
				red_value   += amo_r
				green_value += amo_g
				blue_value  += amo_b
				white_value = (red_value+green_value+blue_value)/3
				overlays.Cut()
				web_shade.alpha = max(0, min(255, ((1 - white_value)*255)))
				if(red_value <= 1)
					red.alpha   = max(0, min(255, ((1 - red_value  )*255)))
					red.blend_mode = BLEND_SUBTRACT
				else
					red.alpha   = max(0, min(255, (red_value-1)*32))
					red.blend_mode = BLEND_ADD
				if(green_value <= 1)
					green.alpha   = max(0, min(255, ((1 - green_value  )*255)))
					green.blend_mode = BLEND_SUBTRACT
				else
					green.alpha   = max(0, min(255, (green_value-1)*32))
					green.blend_mode = BLEND_ADD
				if(blue_value <= 1)
					blue.alpha   = max(0, min(255, ((1 - blue_value  )*255)))
					blue.blend_mode = BLEND_SUBTRACT
				else
					blue.alpha   = max(0, min(255, (blue_value-1)*32))
					blue.blend_mode = BLEND_ADD
				overlays.Add(red, green, blue)
			add_light_source(light_source/source)
				if(!istype(source.loc, /turf)) return
				var/angular_dist = sqrt((source.loc.x - loc.x)**2 + (source.loc.y - loc.y)**2)
				var/fall_off = source.value * min(1, max(0, (1 - angular_dist/(source.reach))))
				fall_off = sqrt(1-(1-fall_off)**2)
				var/list/rgb = hsv2rgb(source.hue, source.saturation, fall_off)
				adjust_light(rgb["red"],rgb["green"],rgb["blue"])
			remove_light_source(light_source/source, turf/old_loc)
				if(!istype(old_loc, /turf)) return
				var/angular_dist = sqrt((old_loc.x - loc.x)**2 + (old_loc.y - loc.y)**2)
				var/fall_off = source.value * min(1, max(0, (1 - angular_dist/(source.reach))))
				fall_off = sqrt(1-(1-fall_off)**2)
				var/list/rgb = hsv2rgb(source.hue, source.saturation, fall_off)
				adjust_light(-rgb["red"],-rgb["green"],-rgb["blue"])
			recalculate()
				white_value = 0
				red_value = 0
				green_value = 0
				blue_value = 0
				var/region/aloc = aloc(src)
				var/list/ambient = hsv2rgb(aloc.ambient_hue, aloc.ambient_saturation, aloc.ambient_value)
				world << "Ambient: [ambient["red"]]"
				adjust_light(ambient["red"],ambient["green"],ambient["blue"])
				for(var/light_source/L in view(LIGHT_REACH, src))
					add_light_source(L)
		web_shade
			parent_type = /obj
			mouse_opacity = 0
			ignore = TRUE
			layer = LIGHTING_LAYER
			blend_mode = BLEND_SUBTRACT
			Move(){}
			icon = 'rectangles.dmi'
			icon_state = "shade"
			alpha = 255
	/*Shadow

	Invisible Icon

	RGB Subtraction Mask

	MAP (FULLY LIT)*/