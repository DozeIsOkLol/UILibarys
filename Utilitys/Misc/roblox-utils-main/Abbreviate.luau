-- Cache frequently used functions
local floor = math.floor
local format = string.format
local log10 = math.log10
local gsub = string.gsub

local abbreviations = {
	K = 4, M = 7, B = 10, T = 13, Qa = 16, Qi = 19, Sx = 22, Sp = 25, Oc = 28, No = 31,
	Dc = 34, UnDc = 37, DuoDc = 40, TreDc = 43, QtDc = 46, QiDc = 49, SxDc = 52, SpDc = 55, OcDc = 58, NvDc = 61,
	Vg = 64, UnVg = 67, DuoVg = 70, TreVg = 73, QtVg = 76, QiVg = 79, SxVg = 82, SpVg = 85, OcVg = 88, NvVg = 91,
	Trg = 94, UnTrg = 97, DuoTrg = 100, TreTrg = 103, QtTrg = 106, QiTrg = 109, SxTrg = 112, SpTrg = 115, OcTrg = 118, NvTrg = 121,
	Qdg = 124, UnQdg = 127, DuoQdg = 130, TreQdg = 133, QtQdg = 136, QiQdg = 139, SxQdg = 142, SpQdg = 145, OcQdg = 148, NvQdg = 151,
	Qig = 154, UnQig = 157, DuoQig = 160, TreQig = 163, QtQig = 166, QiQig = 169, SxQig = 172, SpQig = 175, OcQig = 178, NvQig = 181,
	Sxg = 184, UnSxg = 187, DuoSxg = 190, TreSxg = 193, QtSxg = 196, QiSxg = 199, SxSxg = 202, SpSxg = 205, OcSxg = 208, NvSxg = 211,
	Spg = 214, UnSpg = 217, DuoSpg = 220, TreSpg = 223, QtSpg = 226, QiSpg = 229, SxSpg = 231, SpSpg = 234, OcSpg = 237, NvSpg = 240,
	Ocg = 243, UnOcg = 246, DuoOcg = 249, TreOcg = 252, QtOcg = 255, QiOcg = 258, SxOcg = 261, SpOcg = 264, OcOcg = 267, NvOcg = 270,
	Nvg = 273, UnNvg = 276, DuoNvg = 279, TreNvg = 282, QtNvg = 285, QiNvg = 288, SxNvg = 291, SpNvg = 294, OcNvg = 297,
	Ct = 300, UnCt = 303, DuoCt = 306,
}

-- Pre-sort abbreviations by digits for faster lookup
local sortedAbbreviations = {}
for abbr, digits in pairs(abbreviations) do
	table.insert(sortedAbbreviations, {abbr = abbr, digits = digits})
end
table.sort(sortedAbbreviations, function(a, b) return a.digits < b.digits end)

local function formatWithDecimals(n: number, decimals: number): string
	return format("%." .. decimals .. "f", n)
end

local function Abbreviate(n: number, decimals: number?, forceDecimals: boolean?): (string, string)
	assert(type(n) == "number", "First argument must be a number")
	decimals = decimals and floor(decimals) or 2
	forceDecimals = forceDecimals or false

	if n < 100 then
		if forceDecimals then
			return formatWithDecimals(n, decimals), ""
		end
		local pow = 10^decimals
		return floor(n * pow) / pow, ""
	end

	local floored = floor(n)
	local numberLength = floor(log10(floored) + 1)
	
	-- Find the appropriate abbreviation using the sorted table
	local chosen = nil
	for _, entry in ipairs(sortedAbbreviations) do
		if numberLength >= entry.digits and numberLength < (entry.digits + 3) then
			chosen = entry.abbr
			break
		end
	end

	if chosen then
		local digits = abbreviations[chosen]
		local formatted = formatWithDecimals(n / 10^(digits-1), decimals)

		if decimals > 0 and decimals < 5 and not forceDecimals then
			-- Remove trailing zeros and decimal point if necessary
			formatted = gsub(formatted, "%.0+$", "")
			formatted = gsub(formatted, "(%..-)[0]+$", "%1")
		end

		return formatted .. chosen, chosen
	end

	return tostring(n), ""
end

return Abbreviate