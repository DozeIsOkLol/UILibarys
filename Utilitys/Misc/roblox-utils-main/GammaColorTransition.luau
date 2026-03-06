local function PowColor3(color: Color3, power: number): Color3
	assert(typeof(color) == "Color3", "Expected Color3 for first argument")
	assert(type(power) == "number", "Expected number for second argument")
	
	return Color3.new(
		math.pow(color.R, power),
		math.pow(color.G, power),
		math.pow(color.B, power)
	)
end

local function LerpColor(c1: Color3, c2: Color3, frac: number, gamma: number?): Color3
	assert(typeof(c1) == "Color3", "Expected Color3 for first argument")
	assert(typeof(c2) == "Color3", "Expected Color3 for second argument")
	assert(type(frac) == "number", "Expected number for third argument")
	assert(frac >= 0 and frac <= 1, "Fraction must be between 0 and 1")
	
	gamma = gamma or 2
	assert(type(gamma) == "number" and gamma > 0, "Gamma must be a positive number")

	-- Convert to gamma space
	local c1Gamma = PowColor3(c1, gamma)
	local c2Gamma = PowColor3(c2, gamma)
	
	-- Perform linear interpolation in gamma space
	return PowColor3(c1Gamma:Lerp(c2Gamma, frac), 1/gamma)
end

return LerpColor