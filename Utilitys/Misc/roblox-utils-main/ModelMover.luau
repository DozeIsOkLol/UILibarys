-- Basically `SetPivot`
--[[
Example:
	local moveMyModel = ModelMover(workspace.Model)
	moveMyModel(CFrame.new(69,37,420))
--]]

type BasePartMap = { [BasePart]: CFrame }

local function ModelMover(instance: Model | BasePart): (new: CFrame) -> ()
	assert(typeof(instance) == "Instance", "Expected Instance, got " .. typeof(instance))
	assert(instance:IsA("Model") or instance:IsA("BasePart"), "Expected Model or BasePart, got " .. instance.ClassName)
	
	-- Handle single BasePart case
	if instance:IsA("BasePart") then
		return function(newCF: CFrame)
			instance.CFrame = newCF
		end
	end
	
	local primary = instance.PrimaryPart
	assert(primary, "Model requires PrimaryPart to be set")
	
	local primaryCF = primary.CFrame
	local descendants = instance:GetDescendants()
	local cache: BasePartMap = table.create(#descendants)
	
	for _, v in descendants do
		if v:IsA("BasePart") and v ~= primary then
			cache[v] = primaryCF:ToObjectSpace(v.CFrame)
		end
	end
	
	return function(newCF: CFrame)
		primary.CFrame = newCF
		for part, offset in cache do
			part.CFrame = newCF * offset
		end
	end
end

return ModelMover