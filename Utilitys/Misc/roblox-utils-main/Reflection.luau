--[[
    Calculates the reflection vector of an incident ray hitting a surface.
]]
local function Reflection(origin: Vector3, hitpos: Vector3, normal: Vector3): Vector3
	-- Type checking for performance
	if typeof(origin) ~= "Vector3" or typeof(hitpos) ~= "Vector3" or typeof(normal) ~= "Vector3" then
		error("Reflection: All parameters must be Vector3")
	end
	
	-- Ensure normal is normalized
	if math.abs(normal.Magnitude - 1) > 1e-6 then
		normal = normal.Unit
	end
	
	-- Calculate incident vector
	local incident = (hitpos - origin).Unit
	
	-- Calculate reflection using the formula: R = I - 2(I·N)N
	-- Where R is reflection vector, I is incident vector, and N is normal vector
	return incident - 2 * (incident:Dot(normal)) * normal
end

return Reflection