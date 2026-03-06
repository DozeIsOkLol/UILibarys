local function CubicInterpolation(a: number, b: number, c: number, d: number, x: number): number
	-- Type checking
	assert(type(a) == "number" and type(b) == "number" and type(c) == "number" and type(d) == "number", "All points must be numbers")
	assert(type(x) == "number", "Interpolation parameter must be a number")
	
	-- Parameter validation
	assert(x >= 0 and x <= 1, "Interpolation parameter must be between 0 and 1")
	
	-- Optimized calculation using Horner's method
	local p1 = d - c - a + b
	local p2 = a - b - p1
	local p3 = c - a
	
	return ((p1 * x + p2) * x + p3) * x + b
	
	--return (d-c-a+b)*x^3 + (-d+c+2*a-2*b)*x^2 + (c-a)*x + b
end

return CubicInterpolation