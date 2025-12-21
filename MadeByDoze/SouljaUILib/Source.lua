--[[
	Aura UI Library
	Version: 1.0
	Created with inspiration from Visual, Vape V4, and Orion.
	This is a single-script, self-contained library.
--]]

local Aura = {}
local Aura_MT = { __index = Aura }

-- Roblox Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Forward declarations for our classes
local Window, Tab, Button, Label, Toggle, Slider, Keybind

--[[------------------------------------------------------------------------------------------
	[1] THEME CONFIGURATION
	The heart of the library's design. All visual properties are stored here for
	easy customization and consistency.
------------------------------------------------------------------------------------------]]
local Theme = {
	Accent = Color3.fromRGB(0, 175, 255),
	AccentDark = Color3.fromRGB(0, 140, 215),
	
	Background = Color3.fromRGB(30, 30, 30),
	Secondary = Color3.fromRGB(45, 45, 45),
	Tertiary = Color3.fromRGB(60, 60, 60),
	
	Text = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
	
	Font = Enum.Font.GothamSemibold,
	TitleSize = 16,
	TextSize = 14,
	
	Rounding = 6,
	Padding = 10,
	
	AnimationSpeed = 0.2,
}


--[[------------------------------------------------------------------------------------------
	[2] UTILITY FUNCTIONS
	Helper functions used throughout the library.
------------------------------------------------------------------------------------------]]
local Utils = {}

function Utils.Create(instanceType, properties)
	local inst = Instance.new(instanceType)
	for prop, value in pairs(properties or {}) do
		inst[prop] = value
	end
	return inst
end

function Utils.Animate(instance, goal, speedOverride)
	local speed = speedOverride or Theme.AnimationSpeed
	local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	return TweenService:Create(instance, tweenInfo, goal)
end


--[[------------------------------------------------------------------------------------------
	[3] CORE CLASSES (Window, Tab, Components)
	This section defines the behavior and creation of all UI elements.
------------------------------------------------------------------------------------------]]

-- // WINDOW CLASS
Window = {}
local Window_MT = { __index = Window }

function Aura:New(options)
	options = options or {}
	local title = options.Title or "Aura UI"
	local useBlur = options.Blur and true or false
	
	local self = setmetatable({}, Window_MT)
	
	self.ScreenGui = Utils.Create("ScreenGui", {
		Name = title,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		Parent = options.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
	})

	if useBlur then
		Utils.Create("BlurEffect", {
			Size = 12,
			Parent = game.Lighting
		})
	end
	
	self.Main = Utils.Create("Frame", {
		Name = "Main",
		Size = UDim2.new(0, 550, 0, 350),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Parent = self.ScreenGui
	})
	Utils.Create("UICorner", { CornerRadius = UDim.new(0, Theme.Rounding), Parent = self.Main })
	Utils.Create("UIStroke", { Color = Theme.Secondary, Thickness = 1, Parent = self.Main })
	
	self.Header = Utils.Create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		Parent = self.Main
	})
	
	self.Title = Utils.Create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		Text = title,
		Font = Theme.Font,
		TextSize = Theme.TitleSize,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Parent = self.Header
	})
	
	-- Structure Panels
	self.NavPanel = Utils.Create("Frame", {
		Name = "NavPanel",
		Size = UDim2.new(0, 130, 1, -40),
		Position = UDim2.fromOffset(0, 40),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Parent = self.Main
	})

	self.ContentPanel = Utils.Create("Frame", {
		Name = "ContentPanel",
		Size = UDim2.new(1, -130, 1, -40),
		Position = UDim2.fromOffset(130, 40),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Parent = self.Main
	})
	
	self.Tabs = {}
	self.CurrentTab = nil
	self.ComponentYOffset = Theme.Padding
	
	-- Drag functionality
	local dragging, dragStart, startPos
	self.Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = self.Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	
	return self
end

function Window:CreateTab(name)
	local newTab = Tab.new(self, name)
	self.Tabs[name] = newTab
	
	if not self.CurrentTab then
		newTab:Select()
	end
	
	return newTab
end

-- // TAB CLASS
Tab = {}
local Tab_MT = { __index = Tab }

function Tab.new(window, name)
	local self = setmetatable({}, Tab_MT)
	self.Window = window
	self.Name = name
	self.Components = {}
	self.YOffset = Theme.Padding
	
	-- Navigation Button
	self.Button = Utils.Create("TextButton", {
		Name = name,
		Size = UDim2.new(1, -10, 0, 30),
		Position = UDim2.new(0.5, 0, 0, #window.Tabs * 35 + 5),
		AnchorPoint = Vector2.new(0.5, 0),
		Text = "  " .. name,
		Font = Theme.Font,
		TextSize = Theme.TextSize,
		TextColor3 = Theme.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = Theme.Background,
		Parent = window.NavPanel
	})
	Utils.Create("UICorner", { CornerRadius = UDim.new(0, Theme.Rounding), Parent = self.Button })
	
	self.Indicator = Utils.Create("Frame", {
		Name = "Indicator",
		Size = UDim2.new(0, 3, 0.8, 0),
		Position = UDim2.fromScale(0, 0.1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Visible = false,
		Parent = self.Button
	})
	Utils.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Indicator })
	
	-- Content Frame
	self.Container = Utils.Create("ScrollingFrame", {
		Name = name .. "_Content",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarImageColor3 = Theme.Accent,
		ScrollBarThickness = 4,
		Parent = window.ContentPanel
	})
	
	self.Button.MouseButton1Click:Connect(function()
		self:Select()
	end)
	
	self.Button.MouseEnter:Connect(function()
		if window.CurrentTab ~= self then
			Utils.Animate(self.Button, { BackgroundColor3 = Theme.Secondary }):Play()
		end
	end)
	
	self.Button.MouseLeave:Connect(function()
		if window.CurrentTab ~= self then
			Utils.Animate(self.Button, { BackgroundColor3 = Theme.Background }):Play()
		end
	end)
	
	return self
end

function Tab:Select()
	if self.Window.CurrentTab == self then return end
	
	for _, otherTab in pairs(self.Window.Tabs) do
		otherTab.Container.Visible = false
		otherTab.Indicator.Visible = false
		Utils.Animate(otherTab.Button, {
			BackgroundColor3 = Theme.Background,
			TextColor3 = Theme.TextSecondary
		}):Play()
	end
	
	self.Container.Visible = true
	self.Indicator.Visible = true
	Utils.Animate(self.Button, {
		BackgroundColor3 = Theme.Secondary,
		TextColor3 = Theme.Text
	}):Play()
	
	self.Window.CurrentTab = self
end

function Tab:AddComponent(component, height)
	component.Position = UDim2.new(0.5, 0, 0, self.YOffset)
	component.AnchorPoint = Vector2.new(0.5, 0)
	component.Parent = self.Container
	
	self.YOffset = self.YOffset + height + 5
	self.Container.CanvasSize = UDim2.new(0, 0, 0, self.YOffset)
	
	return self.Components[#self.Components + 1]
end

-- // COMPONENT: LABEL
function Tab:AddLabel(text)
	local label = Utils.Create("TextLabel", {
		Size = UDim2.new(1, -Theme.Padding * 2, 0, 20),
		Text = text,
		Font = Theme.Font,
		TextSize = Theme.TextSize,
		TextColor3 = Theme.TextSecondary,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	self:AddComponent(label, 20)
end

-- // COMPONENT: BUTTON
function Tab:AddButton(text, callback)
	local button = Utils.Create("TextButton", {
		Size = UDim2.new(1, -Theme.Padding * 2, 0, 35),
		BackgroundColor3 = Theme.Secondary,
		Text = text,
		Font = Theme.Font,
		TextColor3 = Theme.Text,
		TextSize = Theme.TextSize,
	})
	Utils.Create("UICorner", { CornerRadius = UDim.new(0, Theme.Rounding), Parent = button })
	
	button.MouseButton1Click:Connect(function()
		if callback then callback() end
		Utils.Animate(button, { BackgroundColor3 = Theme.AccentDark }):Play()
		task.wait(Theme.AnimationSpeed)
		Utils.Animate(button, { BackgroundColor3 = Theme.Accent }):Play()
	end)
	
	button.MouseEnter:Connect(function() Utils.Animate(button, { BackgroundColor3 = Theme.Accent }):Play() end)
	button.MouseLeave:Connect(function() Utils.Animate(button, { BackgroundColor3 = Theme.Secondary }):Play() end)
	
	self:AddComponent(button, 35)
end

-- // COMPONENT: TOGGLE
function Tab:AddToggle(options, callback)
	options = options or {}
	local text = options.Text or "Toggle"
	local default = options.Default or false
	
	local toggled = default
	
	local frame = Utils.Create("Frame", {
		Size = UDim2.new(1, -Theme.Padding * 2, 0, 30),
		BackgroundTransparency = 1,
	})
	
	local label = Utils.Create("TextLabel", {
		Size = UDim2.new(0.8, 0, 1, 0),
		Text = text,
		Font = Theme.Font,
		TextSize = Theme.TextSize,
		TextColor3 = Theme.Text,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame
	})
	
	local switch = Utils.Create("TextButton", {
		Size = UDim2.new(0, 44, 0, 22),
		Position = UDim2.fromScale(1, 0.5),
		AnchorPoint = Vector2.new(1, 0.5),
		Text = "",
		BackgroundColor3 = toggled and Theme.Accent or Theme.Secondary,
		Parent = frame
	})
	Utils.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = switch })

	local nub = Utils.Create("Frame", {
		Size = UDim2.new(0, 18, 0, 18),
		Position = toggled and UDim2.fromScale(1, 0.5) or UDim2.fromScale(0, 0.5),
		AnchorPoint = toggled and Vector2.new(1.1, 0.5) or Vector2.new(-0.1, 0.5),
		BackgroundColor3 = Theme.Text,
		Parent = switch
	})
	Utils.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = nub })
	
	local function setToggleState(state)
		toggled = state
		local bgGoal = { BackgroundColor3 = toggled and Theme.Accent or Theme.Secondary }
		local nubGoal = { Position = toggled and UDim2.fromScale(1, 0.5) or UDim2.fromScale(0, 0.5) }
		Utils.Animate(switch, bgGoal):Play()
		Utils.Animate(nub, nubGoal):Play()
		if callback then callback(toggled) end
	end
	
	switch.MouseButton1Click:Connect(function()
		setToggleState(not toggled)
	end)
	
	self:AddComponent(frame, 30)
	
	return {
		Set = setToggleState,
		Get = function() return toggled end
	}
end

-- // COMPONENT: SLIDER
function Tab:AddSlider(options, callback)
	options = options or {}
	local text = options.Text or "Slider"
	local min = options.Min or 0
	local max = options.Max or 100
	local default = options.Default or min
	
	local currentValue = math.clamp(default, min, max)
	
	local frame = Utils.Create("Frame", {
		Size = UDim2.new(1, -Theme.Padding * 2, 0, 40),
		BackgroundTransparency = 1,
	})
	
	local label = Utils.Create("TextLabel", {
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.new(0.5, 0, 0, 20),
		Text = text, Font = Theme.Font, TextSize = Theme.TextSize,
		TextColor3 = Theme.Text, BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = frame
	})
	
	local valueLabel = Utils.Create("TextLabel", {
		Position = UDim2.fromScale(1, 0), AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.new(0.5, 0, 0, 20),
		Text = tostring(math.floor(currentValue)), Font = Theme.Font, TextSize = Theme.TextSize,
		TextColor3 = Theme.TextSecondary, BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right, Parent = frame
	})
	
	local track = Utils.Create("Frame", {
		Position = UDim2.new(0, 0, 1, 0), AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = Theme.Secondary, Parent = frame
	})
	Utils.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
	
	local progress = Utils.Create("Frame", {
		Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = Theme.Accent, Parent = track
	})
	Utils.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progress })
	
	local dragger = Utils.Create("TextButton", {
		Size = UDim2.new(1, 0, 1, 14), Text = "", BackgroundTransparency = 1, ZIndex = 2,
		Parent = track
	})
	
	local function updateSlider(input)
		local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		currentValue = min + (max - min) * percent
		progress.Size = UDim2.fromScale(percent, 1)
		valueLabel.Text = tostring(math.floor(currentValue))
		if callback then callback(currentValue) end
	end
	
	local dragging = false
	dragger.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateSlider(input)
		end
	end)
	dragger.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(input)
		end
	end)
	
	self:AddComponent(frame, 40)
	
	return {
		Set = function(val)
			currentValue = math.clamp(val, min, max)
			local percent = (currentValue - min) / (max - min)
			progress.Size = UDim2.fromScale(percent, 1)
			valueLabel.Text = tostring(math.floor(currentValue))
			if callback then callback(currentValue) end
		end,
		Get = function() return currentValue end
	}
end

-- // COMPONENT: KEYBIND
function Tab:AddKeybind(options, callback)
	options = options or {}
	local text = options.Text or "Keybind"
	local default = options.Default or "None"
	
	local currentKey = default
	local isBinding = false
	
	local frame = Utils.Create("Frame", {
		Size = UDim2.new(1, -Theme.Padding * 2, 0, 30),
		BackgroundTransparency = 1,
	})

	local label = Utils.Create("TextLabel", {
		Size = UDim2.new(0.8, 0, 1, 0),
		Text = text, Font = Theme.Font, TextSize = Theme.TextSize,
		TextColor3 = Theme.Text, BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = frame
	})
	
	local keyButton = Utils.Create("TextButton", {
		Size = UDim2.new(0, 80, 1, 0),
		Position = UDim2.fromScale(1, 0.5), AnchorPoint = Vector2.new(1, 0.5),
		Text = tostring(currentKey), Font = Theme.Font, TextSize = Theme.TextSize,
		TextColor3 = Theme.Text, BackgroundColor3 = Theme.Secondary,
		Parent = frame
	})
	Utils.Create("UICorner", { CornerRadius = UDim.new(0, Theme.Rounding), Parent = keyButton })
	
	local inputConn
	keyButton.MouseButton1Click:Connect(function()
		isBinding = true
		keyButton.Text = "..."
		
		inputConn = UserInputService.InputBegan:Connect(function(input, gp)
			if gp then return end
			
			if isBinding then
				if input.KeyCode == Enum.KeyCode.Escape then
					currentKey = "None"
				else
					currentKey = input.KeyCode.Name
				end
				
				isBinding = false
				keyButton.Text = tostring(currentKey)
				if callback then callback(currentKey) end
				if inputConn then inputConn:Disconnect() end
			end
		end)
	end)
	
	self:AddComponent(frame, 30)
	
	return {
		Get = function() return currentKey end
	}
end

return Aura
