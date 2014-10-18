// Message of the Day //
var
	motd = {"
Want to help out? We need graphics, audio, and programming. We also need help from someone who knows how to use the new animate() feature. Contact JacobABrennan for more info, or check out the GitHub repo if that's how you roll.
	GitHub: <a href="https://github.com/jacobabrennan/carrot">https://github.com/jacobabrennan/carrot</a>
	BYOND Hub: <a href="http://www.byond.com/games/IainPeregrine/project_carrot">IainPeregrine.project_carrot</a>
	Email: <a href="email:jacobabrennan@gmail.com">JacobABrennan@gmail.com</a>
	BYOND Key: IainPeregrine
	"}
proc
	motd(client/client)
		client << "<b>Ahoy!:</b> [motd]"
client/New()
	. = ..()
	motd(src)
	world << {"<i style="color:grey">[key] has logged in</i>"}
	// TODO: Separate out traffic
client/Del()
	world << {"<i style="color:grey">[key] has logged out</i>"}
	// TODO: Separate out traffic
	. = ..()

client/Center()
	map_handler.save()
	world.Reboot()
// End Message of the Day

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
	icon_state = "red"

obj
	step_size = 8

tile
	icon_state = "carrot"

client/verb/say(what as text)
	world << "<b>[key]</b>: [what]"

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

atom/proc/aloc()
	var/turf/turf_loc = locate(x,y,z)
	if(turf_loc)
		return turf_loc.loc
atom/movable/proc/center(atom/movable/ref)
	var/offset_x = (ref.step_x+ref.bound_x+ref.bound_width /2) - (bound_x+bound_width /2)//reference.step_x + (reference.bound_width -bound_width )/2
	var/offset_y = (ref.step_y+ref.bound_y+ref.bound_height/2) - (bound_y+bound_height/2)//reference.step_y + (reference.bound_height-bound_height)/2
	if(!Move(ref.loc, 0, offset_x, offset_y))
		loc = ref.loc
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