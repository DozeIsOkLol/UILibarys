-- Pre-computed lookup tables as strings for better performance
local ENCODING_TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local DECODING_TABLE = {}
for i = 1, #ENCODING_TABLE do
	DECODING_TABLE[string.byte(ENCODING_TABLE, i)] = i - 1
end

local function Encode(input: string): string
	assert(type(input) == "string", "Base64.Encode: Expected string input")
	if input == "" then return "" end

	-- Use string.gsub for more efficient processing
	return (string.gsub(input, "..?.?", function(chunk)
		local byte1, byte2, byte3 = string.byte(chunk, 1, 3)
		
		local base64_1 = bit32.rshift(byte1, 2)
		local base64_2 = bit32.lshift(bit32.band(byte1, 3), 4) + bit32.rshift(byte2 or 0, 4)
		local base64_3 = byte2 and (bit32.lshift(bit32.band(byte2, 15), 2) + bit32.rshift(byte3 or 0, 6)) or 0
		local base64_4 = byte3 and bit32.band(byte3, 63) or 0

		if not byte2 then
			return string.sub(ENCODING_TABLE, base64_1 + 1, base64_1 + 1) ..
				   string.sub(ENCODING_TABLE, base64_2 + 1, base64_2 + 1) .. 
				   "=="
		elseif not byte3 then
			return string.sub(ENCODING_TABLE, base64_1 + 1, base64_1 + 1) ..
				   string.sub(ENCODING_TABLE, base64_2 + 1, base64_2 + 1) ..
				   string.sub(ENCODING_TABLE, base64_3 + 1, base64_3 + 1) .. 
				   "="
		else
			return string.sub(ENCODING_TABLE, base64_1 + 1, base64_1 + 1) ..
				   string.sub(ENCODING_TABLE, base64_2 + 1, base64_2 + 1) ..
				   string.sub(ENCODING_TABLE, base64_3 + 1, base64_3 + 1) ..
				   string.sub(ENCODING_TABLE, base64_4 + 1, base64_4 + 1)
		end
	end))
end

local function Decode(input: string): string
	assert(type(input) == "string", "Base64.Decode: Expected string input")
	assert(#input % 4 == 0, "Base64.Decode: Input length must be divisible by 4")
	if input == "" then return "" end

	-- Remove padding if present
	input = string.gsub(input, "=+$", "")

	return (string.gsub(input, "...?...?...?...?", function(chunk)
		local bytes = {}
		
		-- Convert Base64 characters to their index values
		for i = 1, #chunk do
			local char = string.byte(chunk, i)
			local value = DECODING_TABLE[char]
			assert(value ~= nil, "Base64.Decode: Invalid character in input")
			bytes[i] = value
		end

		-- Convert groups of 4 characters into 3 bytes
		local result = {}
		local byte1 = bit32.lshift(bytes[1], 2) + bit32.rshift(bytes[2], 4)
		result[1] = string.char(byte1)

		if bytes[3] then
			local byte2 = bit32.lshift(bit32.band(bytes[2], 15), 4) + bit32.rshift(bytes[3], 2)
			result[2] = string.char(byte2)
		end

		if bytes[4] then
			local byte3 = bit32.lshift(bit32.band(bytes[3], 3), 6) + bytes[4]
			result[3] = string.char(byte3)
		end

		return table.concat(result)
	end))
end

return {
	encode = Encode,
	decode = Decode,
}