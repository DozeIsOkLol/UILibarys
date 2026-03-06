local function Lerp(a: number, b: number, x: number): number
	-- Type validation
	assert(type(a) == "number", "Argument 'a' must be a number")
	assert(type(b) == "number", "Argument 'b' must be a number")
	assert(type(x) == "number", "Argument 'x' must be a number")
	
	-- Clamp x between 0 and 1 for safety
	x = math.clamp(x, 0, 1)
	
	return a + (b - a) * x  -- More numerically stable form
end

return Lerp