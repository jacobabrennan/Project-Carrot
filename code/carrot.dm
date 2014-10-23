/*
	These are simple defaults for your project.
 */

world
	fps = 15		// 25 frames per second
	icon_size = 32	// 32x32 icon size by default
	view = 6		// show up to 6 tiles outward from center (13x13 view)

// Make objects move 8 pixels per tick when walking

atom
	icon = 'rectangles.dmi'

mob
	step_size = 8

obj
	step_size = 8

tile
	icon_state = "carrot"

// Begin Math

proc/atan2(x, y)
    if(!x && !y) return 0
    return y >= 0 ? arccos(x / sqrt(x * x + y * y)) : -arccos(x / sqrt(x * x + y * y))


proc
	gauss(base)
		// Looking back, there's no way I wrote this function.
		if(base <= 1){ return base}
		var/x,y,rsq // Who defines multiple variables like this?
		do // do/while is always more complicated than it needs be. Just use a regular while.
			x=2*rand()-1
			y=2*rand()-1
			rsq=x*x+y*y // Spaces, anyone?
		while(rsq>1 || !rsq) // What is this magic rsq, anyway? Identifyable identifiers ftw.
		. = y*sqrt(-2*log(rsq)/rsq)
		var/standard_deviation = base/6 // Gotta love 6.
		. *= standard_deviation // Someone likes dots.
		. += base
		. = max(0,min(round(.),base*2))
		// Okay, perhaps I did write it. I must have been high on shoe pollish, or something.
	sign(_n)
		if(_n >= 0) return 1
		return -1
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

// End Math

atom/proc/aloc()
	var/atom/current = src
	while(current.loc)
		current = current.loc
		if(istype(current, /area))
			return current
atom/movable/proc/center(atom/movable/ref)
	var/offset_x = (ref.step_x+ref.bound_x+ref.bound_width /2) - (bound_x+bound_width /2)//reference.step_x + (reference.bound_width -bound_width )/2
	var/offset_y = (ref.step_y+ref.bound_y+ref.bound_height/2) - (bound_y+bound_height/2)//reference.step_y + (reference.bound_height-bound_height)/2
	if(!Move(ref.loc, 0, offset_x, offset_y))
		assign_loc(ref.loc)
		step_x = offset_x
		step_y = offset_y
atom/movable/proc/get_center()
	var/offset_x = round((step_x+bound_x+bound_width /2)/world.icon_size)
	var/offset_y = round((step_y+bound_y+bound_height/2)/world.icon_size)
	var/turf/center = locate(x+offset_x, y+offset_y,z)
	return center

//================================ TRASH ==============================//
tile/test/carrot
	range = RANGE_TOUCH
	target_class = TARGET_ACTOR
	resource = "carrot"
	use(actor/user, actor/target, offset_x, offset_y)
		if(!istype(target)) return
		target.adjust_health(1)
		if(target.bound_width == 16)
			target.icon_state = "orange_small"
		else if(target.bound_width == 32)
			target.icon_state = "orange"
		Del()
tile/test/radish
	icon_state = "radish"
	range = 48
	target_class = TARGET_ACTOR
	resource = "radish"
	use(actor/user, actor/target, offset_x, offset_y)
		if(!istype(target)) return
		target.adjust_health(user.max_health())
		Del()
tile/test/radish_bow
	parent_type = /tile/weapon
	icon_state = "radish_bow"
	resource = "radish"
	value = 100
	range = 4*32
tile/test/carrot_sword
	parent_type = /tile/weapon
	icon_state = "carrot_sword"
	resource = "carrot"
	value = 100
	potency = 4
	use(actor/user, actor/target, offset_x, offset_y)
		. = ..()
		if(target.bound_width == 32)
			target.icon_state = "orange"
recipe
	carrot_sword
		cost = 25
		ingredients = list("carrot")
		product = /tile/test/carrot_sword
	radish_bow
		ingredients = list("radish")
		product = /tile/test/radish_bow
tile/enemy_placer
	icon_state = "enemy_placer"
	construct = /cave/enemy/jel_1
//================================ TRASH ==============================//