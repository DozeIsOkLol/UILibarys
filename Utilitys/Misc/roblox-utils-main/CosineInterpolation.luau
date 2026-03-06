local function CosineInterpolation(a: number, b: number, x: number): number
	assert(type(a) == "number" and type(b) == "number" and type(x) == "number", "All parameters must be numbers")
	
	-- Clamp x between 0 and 1
	x = math.clamp(x, 0, 1)
	
	-- Calculate cosine interpolation factor
	local factor = (1 - math.cos(x * math.pi)) / 2
	return a * (1 - factor) + b * factor
end

return CosineInterpolation