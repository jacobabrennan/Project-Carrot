/*
	These are simple defaults for your project.
 */

world
	fps = 15		// 25 frames per second
	icon_size = 32	// 32x32 icon size by default
	view = 6		// show up to 6 tiles outward from center (13x13 view)
	hub_password = "tD69MKdrVX2qBjpu"
	hub = "iainperegrine.carrot"

client/Center()
	world.Reboot()

// Make objects move 8 pixels per tick when walking

atom
	icon = 'rectangles.dmi'

mob
	step_size = 8
	icon_state = "red"

obj
	step_size = 8

turf
	icon_state = "green"

tile
	icon_state = "carrot"

client/verb/say(what as text)
	world << "<b>[key]</b>: [what]"

proc/atan2(x, y)
    if(!x && !y) return 0
    return y >= 0 ? arccos(x / sqrt(x * x + y * y)) : -arccos(x / sqrt(x * x + y * y))

atom/movable/proc/center(atom/movable/reference)
	var/offset_x = reference.step_x + (reference.bound_width -bound_width )/2
	var/offset_y = reference.step_y + (reference.bound_height-bound_height)/2
	Move(reference.loc, 0, offset_x, offset_y)


/*
coord
	var
		x
		y
	New(_x,_y)
		x = _x
		y = _y
atom/movable
	proc
		center_offset()
			var/coord/center = New()
			center.x = step_x + bound_x + (bound_width /2)
			center.y = step_y + bound_y + (bound_height/2)
			return center
*/


//================================ TRASH ==============================//
tile/test/carrot
	range = RANGE_TOUCH
	target_class = TARGET_ACTOR
	resource = "carrot"
	use(actor/user, atom/movable/target, offset_x, offset_y)
		if(target.bound_width == 16)
			target.icon_state = "orange_small"
		else
			target.icon_state = "orange"
		Del()
tile/test/radish
	icon_state = "radish"
	range = 48
	target_class = TARGET_ACTOR
	resource = "radish"
	use(actor/user, atom/movable/target, offset_x, offset_y)
		target.icon_state = "purple"
		target.bound_x = 8
		target.bound_y = 8
		target.bound_width = 16
		target.bound_height = 16
		Del()
tile/test/carrot_sword
	icon_state = "carrot_sword"
	target_class = TARGET_ENEMY
	tile_type = TILE_WEAPON
	resource = "carrot"
	value = 100
	use(actor/user, atom/movable/target, offset_x, offset_y)
		if(target.bound_width == 16)
			target.icon_state = "orange_small"
		else
			target.icon_state = "orange"
wanderer
	parent_type = /actor
	icon_state = "red"
	faction = FACTION_ENEMY
	bound_x = 0
	bound_y = 0
	bound_height = 32
	bound_width = 32
	New()
		. = ..()
		walk_rand(src,3)
	Move()
		. = ..()
		if(rand(0,16)>15)
			dir = pick(1,2,4,8)
recipe
	carrot_sword
		ingredients = list("carrot")
		product = /tile/test/carrot_sword
//================================ TRASH ==============================//