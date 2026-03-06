local function AngleBetween(v1: Vector3, v2: Vector3): number?
	-- Type checking
	if not v1 or not v2 then
		warn("AngleBetween: Both vectors must be non-nil", 2)
		return nil
	end
	
	-- Normalize vectors to ensure consistent results regardless of magnitude
	local normalized1 = v1.Unit
	local normalized2 = v2.Unit
	
	-- Calculate angle using dot product and cross product
	return math.atan2(normalized1:Cross(normalized2).Magnitude, normalized1:Dot(normalized2))
end

return AngleBetween