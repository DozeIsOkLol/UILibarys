-- CLEAN INLINE UI (ADVANCED EXECUTOR VERSION)

-- SERVICES
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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

local TweenInfoFast = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- MAIN
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(540, 380)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Theme.Background
main.BorderSizePixel = 0
main.Visible = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

-- TOGGLE UI (Insert / RightShift)
UIS.InputBegan:Connect(function(i, gpe)
	if gpe then return end
	if i.KeyCode == Enum.KeyCode.Insert or i.KeyCode == Enum.KeyCode.RightShift then
		main.Visible = not main.Visible
	end
end)

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
tabBar.Size = UDim2.new(0, 150, 1, -50)
tabBar.Position = UDim2.fromOffset(10, 45)
tabBar.BackgroundColor3 = Theme.Secondary
tabBar.BorderSizePixel = 0
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 10)

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.Padding = UDim.new(0, 6)

-- CONTENT
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -180, 1, -50)
content.Position = UDim2.fromOffset(170, 45)
content.BackgroundTransparency = 1

-- SYSTEM
local Tabs = {}

local function tween(obj, props)
	TweenService:Create(obj, TweenInfoFast, props):Play()
end

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
			tween(t.Button, {TextColor3 = Theme.Muted})
		end
		frame.Visible = true
		tween(button, {TextColor3 = Theme.Text})
	end)

	local tab = { Button = button, Frame = frame }
	table.insert(Tabs, tab)

	if #Tabs == 1 then
		frame.Visible = true
		button.TextColor3 = Theme.Text
	end

	-- BUTTON
	function tab:AddButton(text, callback)
		local btn = Instance.new("TextButton", frame)
		btn.Size = UDim2.new(1, 0, 0, 36)
		btn.BackgroundColor3 = Theme.Secondary
		btn.Text = text
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 14
		btn.TextColor3 = Theme.Text
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

		btn.MouseEnter:Connect(function()
			tween(btn, {BackgroundColor3 = Theme.Accent})
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, {BackgroundColor3 = Theme.Secondary})
		end)

		btn.MouseButton1Click:Connect(function()
			if callback then callback() end
		end)
	end

	-- TOGGLE
	function tab:AddToggle(text, default, callback)
		local state = default or false

		local holder = Instance.new("Frame", frame)
		holder.Size = UDim2.new(1, 0, 0, 36)
		holder.BackgroundColor3 = Theme.Secondary
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)

		local label = Instance.new("TextLabel", holder)
		label.Size = UDim2.new(1, -60, 1, 0)
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
				tween(toggle, {
					BackgroundColor3 = state and Theme.Accent or Theme.Background
				})
				if callback then callback(state) end
			end
		end)
	end

	-- SLIDER
	function tab:AddSlider(text, min, max, default, callback)
		local value = default or min

		local holder = Instance.new("Frame", frame)
		holder.Size = UDim2.new(1, 0, 0, 48)
		holder.BackgroundColor3 = Theme.Secondary
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)

		local label = Instance.new("TextLabel", holder)
		label.Size = UDim2.new(1, -20, 0, 20)
		label.Position = UDim2.fromOffset(10, 4)
		label.BackgroundTransparency = 1
		label.Text = text .. ": " .. value
		label.Font = Enum.Font.Gotham
		label.TextSize = 13
		label.TextColor3 = Theme.Text
		label.TextXAlignment = Enum.TextXAlignment.Left

		local bar = Instance.new("Frame", holder)
		bar.Size = UDim2.new(1, -20, 0, 6)
		bar.Position = UDim2.fromOffset(10, 32)
		bar.BackgroundColor3 = Theme.Background
		Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

		local fill = Instance.new("Frame", bar)
		fill.Size = UDim2.fromScale((value-min)/(max-min), 1)
		fill.BackgroundColor3 = Theme.Accent
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

		bar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				local move; move = UIS.InputChanged:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseMovement then
						local pct = math.clamp((inp.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
						value = math.floor(min + (max-min)*pct)
						tween(fill,{Size = UDim2.fromScale(pct,1)})
						label.Text = text .. ": " .. value
						if callback then callback(value) end
					end
				end)
				UIS.InputEnded:Once(function()
					if move then move:Disconnect() end
				end)
			end
		end)
	end

	-- DROPDOWN
	function tab:AddDropdown(text, options, callback)
		local open = false

		local holder = Instance.new("Frame", frame)
		holder.Size = UDim2.new(1, 0, 0, 36)
		holder.BackgroundColor3 = Theme.Secondary
		holder.ClipsDescendants = true
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)

		local label = Instance.new("TextLabel", holder)
		label.Size = UDim2.new(1, -30, 1, 0)
		label.Position = UDim2.fromOffset(10, 0)
		label.BackgroundTransparency = 1
		label.Text = text
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.TextColor3 = Theme.Text
		label.TextXAlignment = Enum.TextXAlignment.Left

		local list = Instance.new("Frame", holder)
		list.Size = UDim2.new(1, 0, 0, #options * 32)
		list.Position = UDim2.fromOffset(0, 36)
		list.BackgroundTransparency = 1

		for i, opt in ipairs(options) do
			local btn = Instance.new("TextButton", list)
			btn.Size = UDim2.new(1, -20, 0, 28)
			btn.Position = UDim2.fromOffset(10, (i-1)*32)
			btn.BackgroundColor3 = Theme.Background
			btn.Text = opt
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 13
			btn.TextColor3 = Theme.Text
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

			btn.MouseButton1Click:Connect(function()
				label.Text = text .. ": " .. opt
				open = false
				tween(holder, {Size = UDim2.new(1,0,0,36)})
				if callback then callback(opt) end
			end)
		end

		holder.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				open = not open
				tween(holder, {
					Size = open and UDim2.new(1,0,0,36 + #options*32) or UDim2.new(1,0,0,36)
				})
			end
		end)
	end

	return tab
end

-- EXAMPLE
local tab = createTab("Main")
tab:AddButton("Test Button", function() print("Clicked") end)
tab:AddToggle("God Mode", false, function(v) print("Toggle:",v) end)
tab:AddSlider("Speed", 10, 100, 50, function(v) print("Speed:",v) end)
tab:AddDropdown("Weapon", {"Sword","Gun","Magic"}, function(v) print("Selected:",v) end)
