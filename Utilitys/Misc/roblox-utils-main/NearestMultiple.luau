-- Rounds `x` to the nearest multiple of `n`
-- If n is nil or 0, defaults to 1
-- Negative multiples are converted to positive
local function Nearest(x: number, n: number?): number
	n = (n and n ~= 0) and n or 1
	n = math.abs(n)
	return math.round(x/n) * n
end

return Nearest