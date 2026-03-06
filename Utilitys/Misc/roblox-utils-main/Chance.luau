local Chance = {}

local _Random = Random.new()

function Chance.Percentage(decimal: number): boolean
	assert(type(decimal) == "number", "Percentage expects a number")
	assert(decimal >= 0 and decimal <= 1, "Percentage must be between 0 and 1")
	
	return _Random:NextNumber() < decimal
end

function Chance.OneInX(x: number): boolean
	assert(type(x) == "number", "OneInX expects a number")
	assert(x > 0, "OneInX denominator must be positive")

	return _Random:NextNumber() < 1/x
end

function Chance.Random(min: number, max: number): number
	assert(type(min) == "number" and type(max) == "number", "Random expects two numbers")
	assert(max > min, "Maximum must be greater than minimum")

	return min + _Random:NextNumber() * (max - min)
end

return Chance