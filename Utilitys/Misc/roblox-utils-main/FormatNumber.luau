local function format(n: number): string
	-- Handle edge cases
	if type(n) ~= "number" then
		return tostring(n)
	end
	
	if n < 1000 then 
		return tostring(n)
	end

	-- Split into whole and decimal parts
	local whole = math.floor(math.abs(n))
	local decimal = n % 1
	local sign = n < 0 and "-" or ""
	
	-- Convert whole number to string and add commas
	local formatted = tostring(whole):reverse():gsub("(%d%d%d)", "%1,"):reverse()
	
	-- Remove leading comma if present
	if formatted:sub(1, 1) == "," then
		formatted = formatted:sub(2)
	end
	
	-- Add decimal part if it exists
	if decimal > 0 then
		formatted = formatted .. string.format("%.2f", decimal):sub(2)
	end

	return sign .. formatted
end

return format