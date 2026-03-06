local function Levenshtein(compare: string, source: string): number
	-- Early returns for common cases
	if compare == source then
		return 0
	end
	
	local len1, len2 = #compare, #source
	if len1 == 0 then
		return len2
	elseif len2 == 0 then
		return len1
	end

	-- Ensure len1 is the shorter string for better performance
	if len1 > len2 then
		compare, source = source, compare
		len1, len2 = len2, len1
	end

	-- Pre-allocate column with initial values
	local column = table.create(len2 + 1)
	for i = 0, len2 do
		column[i + 1] = i
	end

	-- Cache byte values for strings to avoid repeated calls
	local compareBytes = table.create(len1)
	local sourceBytes = table.create(len2)
	for i = 1, len1 do compareBytes[i] = compare:byte(i) end
	for i = 1, len2 do sourceBytes[i] = source:byte(i) end

	for i = 1, len1 do
		local lastdiag = column[1]
		column[1] = i
		
		local compareByte = compareBytes[i]
		for j = 1, len2 do
			local olddiag = column[j + 1]
			local cost = (compareByte == sourceBytes[j]) and 0 or 1
			
			column[j + 1] = math.min(
				column[j + 1] + 1, -- deletion
				column[j] + 1,     -- insertion
				lastdiag + cost    -- substitution
			)
			lastdiag = olddiag
		end
	end

	return column[len2 + 1]
end

return Levenshtein