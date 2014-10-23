proc/atan2(x, y)
    if(!(x || y)) return 0
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

	sign(n)
		// sign returns 0, -1, or 1
		// it's not even being used
		return n && n / abs(n)

	hsv2rgb(hue, saturation, value)
		if(!isnum(hue)) return
		var/list/rgb_prime
		// When 0 ? H < 360, 0 ? S ? 1 and 0 ? V ? 1:
		var/C = value * saturation
		var/X = C * (1 - abs((hue/60)%2 - 1))
		var/m = value - C
		hue = round(hue)
		while(hue < 0) hue += 360
		while(hue >= 360) hue -= 360
		switch(hue)
			if(  0 to  59) rgb_prime = list(C,X,0)
			if( 60 to 119) rgb_prime = list(X,C,0)
			if(120 to 179) rgb_prime = list(0,C,X)
			if(180 to 239) rgb_prime = list(0,X,C)
			if(240 to 299) rgb_prime = list(X,0,C)
			if(300 to 360) rgb_prime = list(C,0,X)
		var/list/rgb = list()
		rgb["red"  ] = (rgb_prime[1]+m)
		rgb["green"] = (rgb_prime[2]+m)
		rgb["blue" ] = (rgb_prime[3]+m)
		return rgb