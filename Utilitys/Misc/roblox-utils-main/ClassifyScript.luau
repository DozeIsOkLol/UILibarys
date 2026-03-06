return function(s: Script|LocalScript|ModuleScript): string?
	if not (s:IsA("LocalScript") or s:IsA("ModuleScript") or s:IsA("Script")) then
		return nil
	end

	local className = s.ClassName
	if className == "LocalScript" or className == "ModuleScript" then
		return className
	end
	
	-- At this point we know it's a regular Script
	return tostring(s.RunContext) or "Unknown"
end