--[[ 
    Grammar utility that applies basic grammar rules to a string:
    - Capitalizes first letter
    - Replaces " i " with " I "
    - Adds appropriate ending punctuation based on uppercase ratio
]]

-- Pattern matching any of these ending characters
local VALID_ENDINGS = {
	["!"] = true, ["?"] = true, ["."] = true,
	[","] = true, [";"] = true, [":"] = true,
	["["] = true, ["]"] = true, ["{"] = true,
	["}"] = true, ["("] = true, [")"] = true,
	["'"] = true, ['"'] = true, ["~"] = true,
	["`"] = true, ["*"] = true, ["+"] = true,
	["#"] = true, ["$"] = true, ["%"] = true,
	["&"] = true, ["\\"] = true
}

local UPPERCASE_RATIO_THRESHOLD = 0.8

local function lastLetter(s: string): string
	return s and s:sub(-1) or ""
end

local function firstLetter(s: string): string
	return s and s:sub(1, 1) or ""
end

local function replaceFirst(s: string, w: string): string
	return s and (w .. s:sub(2)) or ""
end

-- Calculate ratio of uppercase characters in a string
local function getUppercaseRatio(s: string): number
	if #s == 0 then return 0 end
	
	local upperCount = 0
	for i = 1, #s do
		local char = s:sub(i, i)
		if char:match("%u") then
			upperCount += 1
		end
	end
	return upperCount / #s
end

local function validEnding(e: string): boolean
	return VALID_ENDINGS[e] == true
end

local function Grammar(s: string): string
	-- Type checking
	if type(s) ~= "string" then
		return ""
	end
	
	if s == "" then return "" end
	
	-- Capitalize first letter
	s = replaceFirst(s, string.upper(firstLetter(s)))
	
	-- Replace standalone "i" with "I"
	s = string.gsub(s, " i ", " I ")
	
	-- Add appropriate ending if missing
	if not validEnding(lastLetter(s)) then
		if getUppercaseRatio(s) > UPPERCASE_RATIO_THRESHOLD then
			s ..= "!"
		else
			s ..= "."
		end
	end
	
	return s
end

return Grammar