tile/spell_book
	tile_type = TILE_OFFHAND
	icon_state = "spell_book"
	Exit()
		return FALSE
	Enter()
		return FALSE
	New()
		. = ..()
		contents.Add(
			new /tile/spell/fire(),
			new /tile/spell/heal()
		)
tile/spell
	fire
		icon_state = "scroll_fire"
		target_class = TARGET_ENEMY
		range = 6*32
		continuous_use = TRUE
		recharge_time = 100
		use(actor/user, actor/target, offset_x, offset_y)
			. = ..()
			target.hurt(5, user, src)
	heal
		icon_state = "scroll_heal"
		range = 6*32
		recharge_time = 100
		target_class = TARGET_FRIEND
		resource = "radish"
		use(actor/user, actor/target, offset_x, offset_y)
			. = ..()
			target.adjust_health(5)