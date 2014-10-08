proc
	craft(crafter, list/ingredients)
		for(var/tile/T in ingredients)
			del T
		var/tile/test/carrot_sword/result = new()
		return result