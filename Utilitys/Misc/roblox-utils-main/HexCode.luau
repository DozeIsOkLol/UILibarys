local random = Random.new()

return function(n: number): string
	-- Validate input
	if type(n) ~= "number" or n <= 0 then
		error("HexCode requires a positive number input")
	end
	
	-- Cap maximum length to prevent excessive strings
	n = math.min(n, 32)
	
	-- Use bit manipulation to ensure we get exactly n digits
	local maxValue = (1 << (n * 4)) - 1
	local randomValue = math.floor(random:NextNumber() * maxValue)
	
	-- Use %0nx to ensure consistent length with leading zeros
	return string.format("%0" .. n .. "x", randomValue)
end