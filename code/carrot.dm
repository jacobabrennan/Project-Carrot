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

atom
	proc
		AreaOf()

turf
	AreaOf() return loc

area
	AreaOf() return src

atom/movable
	AreaOf()
		var area/area = loc.loc
		while(!isarea(area)) area = area.loc
		return area

	proc
		center(atom/movable/ref)
			SetCenter(ref)

		get_center()
			return locate(1 + Cx()/tile_width(), 1 + Cy()/tile_height(), z)

// Uncategorized
proc
	text_replace(haystack, needle, replacement)
		var position
		var needle_length = length(needle)
		do
			position = findtext(haystack, needle)
			if(position)
				haystack = \
					copytext(haystack, 1, position) \
					+ replacement \
					+ copytext(haystack, position + needle_length)
		while(position)
		return haystack

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