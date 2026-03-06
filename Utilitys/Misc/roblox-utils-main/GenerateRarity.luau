type Rarity = {
	Name: string,
	Chance: number,
	CumulativeChance: number
}

local Rarities: {[number]: Rarity} = {
	[1] = {
		Name = "COMMON",
		Chance = 63,
		CumulativeChance = 0
	},
	[2] = {
		Name = "UNCOMMON",
		Chance = 30,
		CumulativeChance = 0
	},
	[3] = {
		Name = "RARE",
		Chance = 5,
		CumulativeChance = 0
	},
	[4] = {
		Name = "EPIC",
		Chance = 1.9,
		CumulativeChance = 0
	},
	[5] = {
		Name = "LEGENDARY",
		Chance = 0.1,
		CumulativeChance = 0
	}
}

-- Validate total probability is 100%
local totalProbability = 0
for _, rarity in Rarities do
	totalProbability += rarity.Chance
end
assert(math.abs(totalProbability - 100) < 0.0001, "Rarity chances must sum to 100%")

-- Pre-calculate cumulative probabilities
local currentSum = 0
for i = #Rarities, 1, -1 do
	currentSum += Rarities[i].Chance
	Rarities[i].CumulativeChance = currentSum
end

return function(): string
	local randomValue = Random.new():NextNumber() * 100
	
	for _, rarity in Rarities do
		if randomValue <= rarity.CumulativeChance then
			return rarity.Name
		end
	end
	
	return Rarities[1].Name -- Fallback to COMMON in case of floating-point precision issues
end