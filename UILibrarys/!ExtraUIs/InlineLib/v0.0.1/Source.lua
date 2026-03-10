-- CLEAN INLINE UI LIBRARY (EXECUTOR SAFE)

-- SERVICES
local UIS = game:GetService("UserInputService")

-- PARENT
local parent = gethui and gethui() or game:GetService("CoreGui")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CleanInlineUI"
gui.ResetOnSpawn = false
gui.Parent = parent

if syn and syn.protect_gui then
	syn.protect_gui(gui)
elseif protectgui then
	protectgui(gui)
end

-- THEME
local Theme = {
	Background = Color3.fromRGB(18,18,18),
	Secondary = Color3.fromRGB(26,26,26),
	Accent = Color3.fromRGB(140,0,255),
	Text = Color3.fromRGB(235,235,235),
	Muted = Color3.fromRGB(160,160,160)
}

-- MAIN
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(520, 360)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Theme.Background
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

-- DRAG
do
	local dragging, dragStart, startPos
	main.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = i.Position
			startPos = main.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "CLEAN UI"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Theme.Text
title.TextXAlignment = Enum.TextXAlignment.Left

-- TAB BAR
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(0, 140, 1, -50)
tabBar.Position = UDim2.fromOffset(10, 45)
tabBar.BackgroundColor3 = Theme.Secondary
tabBar.BorderSizePixel = 0
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 10)

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.Padding = UDim.new(0, 6)

-- CONTENT
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -170, 1, -50)
content.Position = UDim2.fromOffset(160, 45)
content.BackgroundTransparency = 1

-- SYSTEM
local Tabs = {}

local function createTab(name)
	local button = Instance.new("TextButton", tabBar)
	button.Size = UDim2.new(1, -10, 0, 36)
	button.BackgroundColor3 = Theme.Background
	button.Text = name
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.TextColor3 = Theme.Muted
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

	local frame = Instance.new("Frame", content)
	frame.Size = UDim2.fromScale(1, 1)
	frame.Visible = false
	frame.BackgroundTransparency = 1

	local layout = Instance.new("UIListLayout", frame)
	layout.Padding = UDim.new(0, 8)

	button.MouseButton1Click:Connect(function()
		for _, t in pairs(Tabs) do
			t.Frame.Visible = false
			t.Button.TextColor3 = Theme.Muted
		end
		frame.Visible = true
		button.TextColor3 = Theme.Text
	end)

	local tab = { Button = button, Frame = frame }
	table.insert(Tabs, tab)

	if #Tabs == 1 then
		frame.Visible = true
		button.TextColor3 = Theme.Text
	end

	function tab:AddButton(text, callback)
		local btn = Instance.new("TextButton", frame)
		btn.Size = UDim2.new(1, 0, 0, 36)
		btn.BackgroundColor3 = Theme.Secondary
		btn.Text = text
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 14
		btn.TextColor3 = Theme.Text
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
		btn.MouseButton1Click:Connect(function()
			if callback then callback() end
		end)
	end

	function tab:AddToggle(text, default, callback)
		local state = default or false

		local holder = Instance.new("Frame", frame)
		holder.Size = UDim2.new(1, 0, 0, 36)
		holder.BackgroundColor3 = Theme.Secondary
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)

		local label = Instance.new("TextLabel", holder)
		label.Size = UDim2.new(1, -50, 1, 0)
		label.Position = UDim2.fromOffset(10, 0)
		label.BackgroundTransparency = 1
		label.Text = text
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.TextColor3 = Theme.Text
		label.TextXAlignment = Enum.TextXAlignment.Left

		local toggle = Instance.new("Frame", holder)
		toggle.Size = UDim2.fromOffset(28, 16)
		toggle.Position = UDim2.fromOffset(holder.AbsoluteSize.X - 38, 10)
		toggle.BackgroundColor3 = state and Theme.Accent or Theme.Background
		Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

		holder.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				state = not state
				toggle.BackgroundColor3 = state and Theme.Accent or Theme.Background
				if callback then callback(state) end
			end
		end)
	end

	return tab
end

-- EXAMPLE
local mainTab = createTab("Main")
mainTab:AddButton("Print Hello", function()
	print("Hello")
end)

mainTab:AddToggle("Example Toggle", false, function(v)
	print("Toggle:", v)
end)
