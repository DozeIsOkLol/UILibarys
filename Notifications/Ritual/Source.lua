local Utilities = {}

local Objects = {}

local function randomletters(len)
	local returnedstr = ""
	for i = 1, len do
		returnedstr = returnedstr .. string.char(math.random(65,90)).. "-" .. string.char(math.random(5, 8))
	end
	return returnedstr
end

function Utilities.CreateInstance(class, properties)
	local obj = Instance.new(class)
	if properties.Parent then
		obj.Parent = properties.Parent
	end
	
	for i,v in next, properties do
		obj[i] = v
	end
	
	table.insert(Objects, obj)
	return obj
end

TweenService = game:GetService("TweenService")

local Notifications = {}

local GUI = Instance.new("ScreenGui", game.CoreGui)

GUI.Name = randomletters(10)
GUI.ResetOnSpawn = false

function Notifications.Create(Title,Desc,Time,TitleColor)
	assert(typeof(Title) == "string", "Title isn't a string!")
	assert(typeof(Time) == "number", "Time isn't a number!")
	local Frame = Utilities.CreateInstance("Frame", {
		BackgroundColor3 = Color3.fromRGB(24, 25, 26),
		BorderSizePixel = 0,
		Name = randomletters(10),
		Parent = GUI,
		AnchorPoint = Vector2.new(1,1),
		Position = UDim2.new(1.27, 0,1, 0),
		Rotation = 0,
		Size = UDim2.new(0, 240, 0, 60),
		ZIndex = 1,
		Visible = true
	})
	Frame:TweenPosition(UDim2.new(1,0,1,0), "In", "Quad", 1)
	local UICorner = Utilities.CreateInstance("UICorner", {
		CornerRadius = UDim.new(0,2),
		Parent = Frame
	})
	local TitleFrame = Utilities.CreateInstance("Frame", {
		BackgroundColor3 = Color3.fromRGB(25, 26, 27),
		BorderSizePixel = 0,
		Name = "TitleFrame",
		Parent = Frame,
		AnchorPoint = Vector2.new(0,0),
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 240, 0, 16),
		ZIndex = 1,
		Visible = true
	})
	local Description = Utilities.CreateInstance("TextLabel", {
		BackgroundTransparency = 1,
		Name = "Desc",
		Parent = Frame,
		Position = UDim2.new(0,0,0.267,0),
		Size = UDim2.new(0,239,0,42),
		Visible = true,
		ZIndex = 1,
		TextTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = tostring(Desc),
		TextColor3 = Color3.fromRGB(213, 213, 213),
		TextSize = 12,
		TextWrapped = true
	})
	local UICorner = Utilities.CreateInstance("UICorner", {
		CornerRadius = UDim.new(0,2),
		Parent = TitleFrame
	})
	local TitleLabel = Utilities.CreateInstance("TextLabel", {
		BackgroundTransparency = 1,
		Name = "TextLabel",
		Parent = TitleFrame,
		Position = UDim2.new(0.025, 0, -0.051, 0),
		TextTransparency = 1,
		Size = UDim2.new(0, 233, 0,17),
		Visible = true,
		ZIndex = 1,
		Font = Enum.Font.Gotham,
		Text = Title,
		TextColor3 = TitleColor,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local ShadowHolder = Utilities.CreateInstance("Frame", {
		BackgroundTransparency = 1,
		Parent = Frame,
		Name = "DropShadowHolder",
		Position = UDim2.new(0,0,0,0),
		Size = UDim2.new(1,0,1,0),
		Visible = true,
		ZIndex = 1
	})
	local Shadow = Utilities.CreateInstance("ImageLabel", {
		BackgroundTransparency = 1,
		Name = "DropShadow",
		Parent = ShadowHolder,
		Position = UDim2.new(0.5,0,0.5,0),
		Size = UDim2.new(1,47,1,47),
		Visible = true,
		ZIndex = 0,
		Image = "rbxassetid://6014261993",
		ImageColor3 = Color3.fromRGB(0,0,0),
		ImageTransparency = 0.5,
		ResampleMode = Enum.ResamplerMode.Default,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		SliceScale = 1
	})
	task.wait(0.8)
	for _,v in next, Frame:GetDescendants() do
		if v:IsA("TextLabel") then
			TweenService:Create(v, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
		end
	end
	task.wait(1.5)
	for _,v in next, Frame:GetDescendants() do
		if v:IsA("TextLabel") then
			TweenService:Create(v, TweenInfo.new(1.5), {TextTransparency = 1}):Play()
		end
	end
	task.wait(Time - 0.5)
	Frame:TweenPosition(UDim2.new(1.27, 0,1, 0), "In", "Quad", 1)
end

function Notifications.Clear()
  GUI:Destroy()
end
return Notifications
