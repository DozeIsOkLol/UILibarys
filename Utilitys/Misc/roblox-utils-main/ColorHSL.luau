local ColorHSL = {}

function ColorHSL.toHSL(color: Color3, degrees: boolean?): {H: number, S: number, L: number}
	local degrees = degrees or false
	
	local r,g,b = color.R, color.G, color.B
	local max, min = math.max(r,g,b), math.min(r,g,b)
	local h,s,l
	
	l = (max + min) / 2  -- Simplified sum calculation
	local diff = max - min

	if diff < 1e-10 then  -- Use small epsilon value instead of exact comparison
		h,s = 0,0 -- Achromatic
	else
		s = if l > 0.5 then diff / (2 - max - min) else diff / (max + min)
		
		if max == r then
			h = (g-b) / diff + (g < b and 6 or 0)
		elseif max == g then
			h = (b-r) / diff + 2
		else -- max == b
			h = (r-g) / diff + 4
		end
		
		h /= 6
	end
	
	if degrees then h *= 360 end
	return {H = h, S = s, L = l}
end

local function h2rgb(p: number, q: number, t: number): number
	if t < 0 then t += 1 end
	if t > 1 then t -= 1 end

	if t < 1/6 then return p + (q-p) * 6 * t end
	if t < 0.5 then return q end
	if t < 2/3 then return p + (q-p) * (2/3 - t) * 6 end

	return p
end

function ColorHSL.fromHSL(h: number, s: number, l: number, degrees: boolean?): Color3
	local degrees = degrees or h > 1
	if degrees then h /= 360 end
	
	local r,g,b
	
	if s == 0 then
		r,g,b = l,l,l -- Achromatic
	else
		local q = l < 0.5 and l * (1+s) or l+s - l*s
		local p = 2*l - q

		r = h2rgb(p,q,h + 1/3)
		g = h2rgb(p,q,h)
		b = h2rgb(p,q,h - 1/3)
	end
	
	return Color3.new(r,g,b)
end

function ColorHSL.LerpHSL(start: Color3, finish: Color3, alpha: number): Color3
	local c1 = ColorHSL.toHSL(start)
	local c2 = ColorHSL.toHSL(finish)
	
	local h1,s1,l1 = c1.H, c1.S, c1.L
	local h2,s2,l2 = c2.H, c2.S, c2.L
	
	-- Ensure we take the shortest path around the color wheel
	local hDiff = h2 - h1
	if math.abs(hDiff) > 0.5 then
		h2 += hDiff > 0 and -1 or 1
	end
	
	local h = (h1 + (h2 - h1) * alpha + 1) % 1
	
	return ColorHSL.fromHSL(
		h,
		s1 + (s2 - s1) * alpha,
		l1 + (l2 - l1) * alpha
	)
end

return ColorHSL