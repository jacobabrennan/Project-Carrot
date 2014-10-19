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
			if(light_source && !istype(new_loc))
				light_source.Move(src)
		change_opacity(new_value)
			if(new_value == opacity) return
			opacity = new_value
			var/light_reach = view(LIGHT_REACH, loc)
			for(var/turf/T in light_reach)
				T.lighting.recalculate()

light_source
	parent_type = /obj
	ignore = TRUE
	var
		hue // [0,360)
		saturation // [0,1]
		value // [0,1]
		spread = 12
		reach = LIGHT_REACH
	New(new_loc, _hue, _sat, _val, _reach)
		. = ..()
		hue = _hue
		saturation = _sat
		value = _val
		if(_reach) reach = _reach
		spawn()
			while(!map_handler.loaded)
				sleep(10)
			for(var/turf/lighting/L in view(LIGHT_REACH, src))
				L.recalculate()
	Del()
		for(var/turf/lighting/L in view(LIGHT_REACH, src))
			L.recalculate()
		. = ..()
	Move(new_loc)
		var/old_view = view(LIGHT_REACH, src)
		. = ..()
		for(var/turf/T in (view(LIGHT_REACH, src)+old_view))
			T.lighting.recalculate()
		return
	assign_loc(new_loc)
		var/old_view = view(LIGHT_REACH, src)
		. = ..()
		for(var/turf/T in view(LIGHT_REACH, src)+old_view)
			T.lighting.recalculate()
		return
turf
	var
		tmp/turf/lighting/lighting
	New()
		. = ..()
		lighting = new(src)
	lighting
		parent_type = /obj
		//blend_mode = BLEND_SUBTRACT
		mouse_opacity = 0
		ignore = TRUE
		var
			image/red
			image/green
			image/blue
			red_value = 0
			green_value = 0
			blue_value = 0
		Move(){}
		New(loc)
			. = ..()
			red   = image('rectangles.dmi',src,"light",lighting_LAYER)
			green = image('rectangles.dmi',src,"light",lighting_LAYER)
			blue  = image('rectangles.dmi',src,"light",lighting_LAYER)
			red.blend_mode = BLEND_SUBTRACT
			green.blend_mode = BLEND_SUBTRACT
			blue.blend_mode = BLEND_SUBTRACT
			red.color   = "#f00"
			green.color = "#0f0"
			blue.color  = "#00f"
			adjust_light(0,0,0)
		proc
			adjust_light(amo_r, amo_g, amo_b)
				red_value   += amo_r
				green_value += amo_g
				blue_value  += amo_b
				overlays.Cut()
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
				//green.alpha = max(0, min(255, ((1 - green_value)*255)))
				//blue.alpha  = max(0, min(255, ((1 - blue_value )*255)))
				overlays.Add(red, green, blue)
			add_light_source(light_source/source, flag)
				if(!istype(source.loc, /turf)) return
				var/angular_dist = sqrt((source.loc.x - loc.x)**2 + (source.loc.y - loc.y)**2)
				var/fall_off = source.value * min(1, max(0, (1 - angular_dist/(source.reach))))
				fall_off = sqrt(1-(1-fall_off)**2)
				var/list/rgb = hsv2rgb(source.hue, source.saturation, fall_off)
				adjust_light(rgb["red"],rgb["green"],rgb["blue"])
			/*remove_light_source(light_source/source, old_loc)
				if(!old_loc) old_loc = source.loc
				var/fall_off = source.value * min(1, max(0, (1 - get_dist(loc, source.loc)/LIGHT_REACH)))
				fall_off = sqrt(1-(1-fall_off)**2)
				var/list/rgb = hsv2rgb(source.hue, source.saturation, fall_off)
				adjust_light(-rgb["red"],-rgb["green"],-rgb["blue"])*/
			recalculate(flag)
				red_value = 0
				green_value = 0
				blue_value = 0
				var/lighted = FALSE
				for(var/light_source/L in view(LIGHT_REACH, src))
					lighted = TRUE
					add_light_source(L, flag)
				if(!lighted)
					adjust_light(0,0,0)
			hsv2rgb(hue, saturation, value)
				if(!isnum(hue)) return
				var/list/rgb_prime
				// When 0 ? H < 360, 0 ? S ? 1 and 0 ? V ? 1:
				var/C = value * saturation
				var/X = C * (1 - abs((hue/60)%2 - 1))
				var/m = value - C
				hue = round(hue)
				while(hue < 0) hue += 360
				while(hue >= 360) hue -= 360
				switch(hue)
					if(  0 to  59) rgb_prime = list(C,X,0)
					if( 60 to 119) rgb_prime = list(X,C,0)
					if(120 to 179) rgb_prime = list(0,C,X)
					if(180 to 239) rgb_prime = list(0,X,C)
					if(240 to 299) rgb_prime = list(X,0,C)
					if(300 to 360) rgb_prime = list(C,0,X)
				var/list/rgb = list()
				rgb["red"  ] = (rgb_prime[1]+m)
				rgb["green"] = (rgb_prime[2]+m)
				rgb["blue" ] = (rgb_prime[3]+m)
				return rgb