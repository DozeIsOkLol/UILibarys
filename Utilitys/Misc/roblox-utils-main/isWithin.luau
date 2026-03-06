return function(min: number, max: number, x: number): boolean
	assert(typeof(min) == "number", "min must be a number")
	assert(typeof(max) == "number", "max must be a number")
	assert(typeof(x) == "number", "x must be a number")
	
	-- Ensure min is actually less than max
	if min > max then
		min, max = max, min
	end
	
	return min <= x and x <= max
end