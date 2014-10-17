actor
	var
		base_health = 20 // What your max HP would be with no other effects applied.
		base_speed = 3// What your speed (step_size) would be with no other effects applied.
		base_strength = 1 // Currently used to determine damage output.
			// Should probably be refactored into a proc which computes it based on class.
		health = 0 // You're current HP.
		innate_attack_time = 15 // Delay between attacks done without tiles.
	New()
		. = ..()
		health = max_health()
	get_step_size()
		// TODO: modify base_speed based on class, equipped tiles, enchantments.
		return base_speed*max(1,iteration_delay)
	proc
		max_health()
			// TODO: modify base_speed based on class, equipped tiles, enchantments.
			return base_health
		adjust_health(amount, actor/attacker)
			var/start_health = health
			// Calculate defense before this block.
			var/unbounded_health = health + amount
			health = max(0, min(max_health(), health + amount))
			//
			if(health == 0)
				die(attacker)
			var delta_health = unbounded_health - start_health
			new /actor/floater(src, delta_health)
			return delta_health
		die(actor/attacker)
			// TODO
		hurt(amount, actor/attacker, tile/proxy)
			. = 0
			if(amount < 0) return
			if(attacker.faction & faction) return
			. = adjust_health(-amount, attacker)
			// TODO: Better animation
			var/old_color = color
			color = "#ff0000"
			animate(src, color = old_color, 3)
		innate_attack(actor/target)
			// TODO: Randomize damage? Enchantments?
			return target.hurt(base_strength, src)
actor/floater
	parent_type = /obj
	layer = ACTOR_LAYER+1
	New(new_loc, new_text)
		. = ..()
		center(new_loc)
		var/n_color = "white"
		if(isnum(new_text))
			if(new_text > 0)
				n_color = "#00FF00"
		color = n_color
		maptext = {"<b style="font-family:press-start2p;font-size:14pt;text-align:center; v-align:middle; color:[n_color]">[abs(new_text)]</b>"}
		var/float_time = 5
		animate(src, pixel_y = world.icon_size, float_time)
		spawn(float_time)
			del src

tile/weapon
	icon = 'equipment.dmi'
	range = RANGE_TOUCH
	target_class = TARGET_ENEMY
	tile_type = TILE_WEAPON
	continuous_use = TRUE
	recharge_time = 15
	var
		potency = 1
	use(actor/user, actor/target)
		. = ..()
		var/damage = gauss(potency)
		damage = target.hurt(damage, user, src)
		return damage
tile/body
	icon = 'equipment.dmi'
	tile_type = TILE_BODY
	var
		potency = 1
	proc
		defend(actor/wearer, actor/attacker, damage)
			var og = damage
			var def = gauss(potency/2 + 0.5)
			damage = max(1,damage - def)
			world << "[damage] = [og] - [def]"
			return damage