var/recipe_manager/recipe_manager = new()
recipe_manager
	var
		list/recipes
	New()
		. = ..()
		spawn()
			recipes = new()
			for(var/recipe_type in typesof(/recipe))
				var/recipe/recipe = new recipe_type()
				if(!recipe) continue
				recipes[recipe.ingredients_signature] = recipe
	proc
		order_ingredients(list/ingredients)
			var/list/ing = ingredients.Copy()
			var/list/swap = list()
			while(ing.len)
				var/ingredient = ing[ing.len]
				ing.len--
				if(ingredient == "value" || !ingredient)
					continue
				var/inserted = FALSE
				for(var/I = 1; I <= swap.len; I++)
					if(ingredient < swap[I])
						swap.Insert(I,ingredient)
						inserted = TRUE
						break;
				if(!inserted)
					swap.Add(ingredient)
			return swap
		resource_signature(list/ingredients)
			ingredients = order_ingredients(ingredients)
			var/signature = ""
			for(var/I = 1; I <= ingredients.len; I++)
				if(!ingredients[I] || ingredients[I] == "value")
					continue
				signature += ingredients[I]
				if(I != ingredients.len)
					signature += ","
			return signature
		craft(crafter, list/ingredients)
			var/list/resource_types = list()
			for(var/tile/T in ingredients)
				if(T.resource)
					resource_types.Add(T.resource)
			var/recipe/recipe = find_recipe(resource_types)
			if(recipe)
				var/tile/result = recipe.craft(ingredients)
				return result
			else
				return compound(ingredients)
		compound(list/ingredients, crafter)
			var/avg_value = 0
			for(var/tile/T in ingredients)
				avg_value += T.value
				del T
			avg_value /= ingredients.len
			var/tile/value/value = new()
			value.value = avg_value
			return value;


		find_recipe(list/resource_types)
			// Look for exact match
			var/exact_signature = resource_signature(resource_types)
			var/recipe = recipes[exact_signature]
			if(recipe)
				return recipe
			// Try to find duplicates. This method only works with recipes of 4 ingredients or less.
				/* Only these four dubplication patterns exist:
					aaaa
					aaab
					aabb
					aabc
				*/
			var/list/res_count = list()
			for(var/I = 1 to resource_types.len)
				var/resource = resource_types[I]
				if(resource in res_count)
					res_count[resource]++
				else
					res_count[resource] = 1
			if(res_count.len < 4)
				var/list/swap = list()
				while(res_count.len)
					var/largest
					var/large_amount
					for(var/I = 1 to res_count.len)
						var/test_res = res_count[I]
						var/amount = res_count[test_res]
						if(!largest || amount > large_amount)
							largest = test_res
							large_amount = amount
					swap.Add(largest)
					swap[largest] = large_amount
					res_count.Remove(largest)
				res_count = swap
			if(res_count[res_count[1]] == 1) // abcd
				return
			// Test Duplicate Groups, compile possible signatures.
			var/list/test_sigs = list()
			if(res_count[res_count[1]] == 4) // aaaa
				test_sigs.Add(resource_signature(list(res_count[1], res_count[1], res_count[1]))) // aab
				test_sigs.Add(resource_signature(list(res_count[1], res_count[1]))) // ab
			else if(res_count[res_count[1]] == 3) // aaab
				test_sigs.Add(resource_signature(list(res_count[1], res_count[1], res_count[2]))) // aab
				test_sigs.Add(resource_signature(list(res_count[1], res_count[2]))) // ab
			else if(res_count.len == 2) // aabb
				test_sigs.Add(resource_signature(list(res_count[1], res_count[1], res_count[2]))) // aab
				test_sigs.Add(resource_signature(list(res_count[1], res_count[2], res_count[2]))) // abb
				test_sigs.Add(resource_signature(list(res_count[1], res_count[2]))) // ab
			else // aabc
				test_sigs.Add(resource_signature(list(res_count[1], res_count[2]))) // ab
			// Test each signature, return recipe as soon as one is found.
			for(var/sig in test_sigs)
				recipe = recipes[sig]
				if(recipe)
					return recipe


tile/value
	icon_state = "value_0"
	resource = "value"
recipe
	var
		list/ingredients
		ingredients_signature
		tile/product
	New()
		. = ..()
		if(!ingredients)
			del src
			return
		ingredients = recipe_manager.order_ingredients(ingredients)
		ingredients_signature = recipe_manager.resource_signature(ingredients)
	proc
		craft(ingredients, value)
			for(var/tile/T in ingredients)
				del T
			if(product)
				return new product()



/*
stone
wood
value
weapon
armor
book
shield
charm*/