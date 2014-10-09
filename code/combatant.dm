actor
	var
		base_health = 20 // What your max HP would be with no other effects applied.
		base_speed = 3// What your speed (step_size) would be with no other effects applied.
			// Should probably be refactored into a proc which computes it based on class.
		health = 0 // You're current HP.
	New()
		. = ..()
		adjust_health(max_health())
	get_step_size()
		// TODO: modify base_speed based on class, equipped tiles, enchantments.
		return base_speed
	proc
		max_health()
			// TODO: modify base_speed based on class, equipped tiles, enchantments.
			return base_health
		adjust_health(amount, actor/attacker)
			var start_health = health
			health = max(0, min(max_health(), health + amount))
			if(health == 0)
				die(attacker)
			var delta_health = health - start_health
			return delta_health
		die(actor/attacker)
			set waitfor = FALSE
			. = TRUE // Set this before any deletion of this object, so adjust_health() can return properly
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