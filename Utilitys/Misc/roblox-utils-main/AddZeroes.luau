-- Turn `n` into a number with `x` digits/characters

--[[
Examples (all with `x` being 4):
  12 -> 0012
 -12 -> -012
 1.2 -> 0001.2
-1.2 -> -001.2

Decimals are not capped by `x`:
 0.0001 = 0000.0001
-0.0001 = -001.0001
 8.6221 = 0008.6221
-8.6221 = -008.6221
--]]
local function AddZeroes(n: number, x: number): string
	-- Handle invalid inputs
	assert(type(n) == "number", "First argument must be a number")
	assert(type(x) == "number" and x > 0, "Second argument must be a positive number")
	
	local str = tostring(n)
	local parts = str:split(".")
	local intPart = parts[1]
	local decPart = parts[2]
	
	-- Format the integer part with leading zeros
	local formatted = string.format(`%0${x}d`, math.abs(tonumber(intPart)))
	
	-- Add back the decimal part if it exists
	if decPart then
		formatted ..= "." .. decPart
	end
	
	-- Add back the negative sign if needed
	if n < 0 then
		formatted = "-" .. formatted
	end
	
	return formatted
end

return AddZeroes