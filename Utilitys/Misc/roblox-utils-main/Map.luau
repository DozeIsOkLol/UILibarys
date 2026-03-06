--[[
	Maps a number from one range to another using linear interpolation.

	Map(50, 0, 100, 0, 1) -- Maps 50 from range [0,100] to [0,1], returns 0.5
]]
local function Map(n: number, oldMin: number, oldMax: number, min: number, max: number): number
	--[[
	Traditional:
		(min + ((max - min) * ((n - oldMin) / (oldMax - oldMin))))
	--]]
	
	-- Validate inputs
	assert(type(n) == "number", "First argument must be a number")
	assert(type(oldMin) == "number", "Second argument must be a number")
	assert(type(oldMax) == "number", "Third argument must be a number")
	assert(type(min) == "number", "Fourth argument must be a number")
	assert(type(max) == "number", "Fifth argument must be a number")
	
	-- Prevent division by zero
	if oldMin == oldMax then
		return min
	end
	
	-- Mine:
	return ((n-oldMin) / (oldMax-oldMin) * (max-min)+min)
end

return Map