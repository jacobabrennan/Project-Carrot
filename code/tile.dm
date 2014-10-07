#define TARGET_NONE 0
#define TARGET_ACTOR 1
#define TARGET_TILE 2
#define TARGET_RANGE 4
#define TARGET_ENEMY 8
#define TARGET_FRIEND 16
/*proc
	displacement(atom/atom1, atom/atom2, offset_x, offset_y)
		var/center1_x
		var/center2_x
		var/center1_y
		var/center2_y
		if(istype(atom1, /turf)
			center1_x =
		var/delta_x = (world.icon_size*(x - target.x)) + step_x + bound_x + (bound_width /2) - offset_x - (world.icon_size/2);
		var/delta_y = (world.icon_size*(y - target.y)) + step_y + bound_y + (bound_height/2) - offset_y - (world.icon_size/2);*/

tile
	parent_type = /obj
	var
		delay as num
		target_class = TARGET_ACTOR|TARGET_ENEMY
	proc
		range_check(actor/user, atom/target, offset_x, offset_y){}
		use(actor/user, atom/target, offset_x, offset_y){}

// Global Tile Types, used for global actions.
var/tile/move/move_tile = new()
tile/move
	delay = 0
	target_class = TARGET_NONE
	range_check(actor/user, atom/target, offset_x, offset_y)
		//   (x*world.icon_size) + step_x + bound_x + (bound_width/2)
		// - (target.x*world.icon_size) + offset_x + (world.icon_size/2)
		if(istype(target, /turf))
			var/delta_x = (world.icon_size*(target.x - user.x)) + offset_x - (user.step_x + user.bound_x + (user.bound_width /2))
			var/delta_y = (world.icon_size*(target.y - user.y)) + offset_y - (user.step_y + user.bound_y + (user.bound_height/2))
			if(delta_x == 0 && delta_y == 0)
				return TRUE
		else if(istype(target, /actor))
			if(bounds_dist(user, target) == 0)
				return TRUE
	use(actor/user, atom/target, offset_x, offset_y){}