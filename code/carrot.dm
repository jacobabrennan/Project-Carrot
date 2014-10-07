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

proc/atan2(x, y)
    if(!x && !y) return 0
    return y >= 0 ? arccos(x / sqrt(x * x + y * y)) : -arccos(x / sqrt(x * x + y * y))