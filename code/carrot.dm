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
	world.Reboot()
// End Message of the Day

/*
	These are simple defaults for your project.
 */

world
	fps = 15		// 25 frames per second
	icon_size = 32	// 32x32 icon size by default
	view = 6		// show up to 6 tiles outward from center (13x13 view)
	hub_password = "tD69MKdrVX2qBjpu"
	hub = "iainperegrine.project_carrot"

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
	New()
		. = ..()
		icon_state = pick("green_1", "green_2")

tile
	icon_state = "carrot"

client/verb/say(what as text)
	world << "<b>[key]</b>: [what]"

proc/atan2(x, y)
    if(!x && !y) return 0
    return y >= 0 ? arccos(x / sqrt(x * x + y * y)) : -arccos(x / sqrt(x * x + y * y))

atom/proc/aloc()
	var/turf/turf_loc = locate(x,y,z)
	if(turf_loc)
		return turf_loc.loc
atom/movable/proc/center(atom/movable/ref)
	var/offset_x = (ref.step_x+ref.bound_x+ref.bound_width /2) - (bound_x+bound_width /2)//reference.step_x + (reference.bound_width -bound_width )/2
	var/offset_y = (ref.step_y+ref.bound_y+ref.bound_height/2) - (bound_y+bound_height/2)//reference.step_y + (reference.bound_height-bound_height)/2
	Move(ref.loc, 0, offset_x, offset_y)
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
	use(actor/user, actor/target, offset_x, offset_y)
		if(!istype(target)) return
		target.adjust_health(user.max_health())
		target.icon_state = "purple"
		target.bound_x = 8
		target.bound_y = 8
		target.bound_width = 16
		target.bound_height = 16
		Del()
tile/test/radish_bow
	icon_state = "radish_bow"
	target_class = TARGET_ENEMY
	tile_type = TILE_WEAPON
	range = 256
	resource = "radish"
	value = 100
	continuous_use = TRUE
	recharge_time = 15
	use(actor/user, actor/target, offset_x, offset_y)
		. = ..()
		target.hurt(1, user, src)
		/*if(target.bound_width == 16)
			flick("orange_small",target)
		else
			target.icon_state = "orange"
			spawn(2)
				target.icon_state = initial(target.icon_state)*/
tile/test/carrot_sword
	icon_state = "carrot_sword"
	target_class = TARGET_ENEMY
	tile_type = TILE_WEAPON
	resource = "carrot"
	value = 100
	continuous_use = TRUE
	recharge_time = 15
	use(actor/user, actor/target, offset_x, offset_y)
		. = ..()
		target.hurt(1, user, src)
		/*if(target.bound_width == 16)
			flick("orange_small",target)
		else
			target.icon_state = "orange"
			spawn(2)
				target.icon_state = initial(target.icon_state)*/
wanderer
	parent_type = /enemy
	icon_state = "red"
	bound_x = 0
	bound_y = 0
	bound_height = 32
	bound_width = 32
recipe
	carrot_sword
		ingredients = list("carrot")
		product = /tile/test/carrot_sword
	radish_bow
		ingredients = list("radish")
		product = /tile/test/radish_bow
tile/enemy_placer
	icon_state = "enemy_placer"
	construct = /wanderer
//================================ TRASH ==============================//