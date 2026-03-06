--[[
Tension:
	 1 = high
	 0 = normal
	-1 = low

Bias:
	0 is even
	positive is towards first segment
	negative is towards other segment
--]]

local function HermiteInterpolation(a: number, b: number, c: number, d: number, x: number, tension: number, bias: number): number
	-- Type validation
	assert(type(a) == "number" and type(b) == "number" and type(c) == "number" and type(d) == "number", "Points must be numbers")
	assert(type(x) == "number" and x >= 0 and x <= 1, "x must be a number between 0 and 1")
	assert(type(tension) == "number" and tension >= -1 and tension <= 1, "Tension must be between -1 and 1")
	assert(type(bias) == "number", "Bias must be a number")

	-- Calculate tangents
	local x1 = (b - a) * (1 + bias) * (1 - tension) / 2
	x1 += (c - b) * (1 - bias) * (1 - tension) / 2
	
	local x2 = (c - b) * (1 + bias) * (1 - tension) / 2
	x2 += (d - c) * (1 - bias) * (1 - tension) / 2
	
	-- Pre-calculate powers of x
	local x2 = x * x
	local x3 = x2 * x
	
	-- Calculate basis polynomials
	local p1 = 2 * x3 - 3 * x2 + 1
	local p2 = x3 - 2 * x2 + x
	local p3 = x3 - x2
	local p4 = -2 * x3 + 3 * x2
	
	-- Combine for final result
	return p1 * b + p2 * x1 + p3 * x2 + p4 * c
end

return HermiteInterpolation