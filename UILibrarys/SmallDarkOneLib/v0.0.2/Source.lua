--[[
	================================================================================
	 SmallDarkOneLib                                                       v1.0.0
	================================================================================

	A dark, horrorcore-inspired Roblox UI library — a blood-red "Bloodmoon"
	theme by default, with an eerie violet "Voidspider" alt-theme. Dripping
	horror-poster display type and a distressed typewriter accent font, built
	around the visual world of horrorcore album art (cartoon-villain menace,
	not literal gore).

	Zero external image assets — every corner, border, and glow is drawn with
	UICorner / UIStroke / UIGradient, so it works instantly off a raw GitHub
	loadstring with nothing else to host.

	--------------------------------------------------------------------------
	 INSTALL
	--------------------------------------------------------------------------
	local SmallDarkOneLib = loadstring(game:HttpGet(
		"https://raw.githubusercontent.com/<you>/<repo>/main/source.lua"
	))()

	--------------------------------------------------------------------------
	 QUICK START
	--------------------------------------------------------------------------
	local Window = SmallDarkOneLib:CreateWindow({
		Title     = "SMALL DARK ONE",          -- big Creepster display title
		Subtitle  = "v1.0.0",                  -- small typewriter subtitle
		Theme     = "Bloodmoon",               -- "Bloodmoon" | "Voidspider" | custom theme table
		Size      = UDim2.new(0, 560, 0, 380),
		ToggleKey = Enum.KeyCode.RightShift,   -- show/hide the whole UI
		Watermark = true,                      -- persistent top-left tag
	})

	local Tab     = Window:CreateTab("Main")
	local Section = Tab:CreateSection("Settings")

	--------------------------------------------------------------------------
	 EVERY ELEMENT AT A GLANCE
	--------------------------------------------------------------------------
	Section:CreateButton({
		Name = "Click Me", Callback = function() print("clicked") end,
	})

	Section:CreateToggle({
		Name = "Auto Farm", Default = false, Flag = "AutoFarm",
		Callback = function(value) print("AutoFarm:", value) end,
	})

	Section:CreateSlider({
		Name = "Walk Speed", Min = 16, Max = 200, Default = 16, Decimals = 0,
		Flag = "WalkSpeed", Callback = function(value) end,
	})

	Section:CreateDropdown({
		Name = "Weapon", Options = { "Knife", "Pistol", "Rifle" },
		Default = "Knife", Multi = false, Searchable = true,
		Flag = "Weapon", Callback = function(value) end,
	})

	Section:CreateTextbox({
		Name = "Username", Placeholder = "Enter a name...",
		Flag = "Username", Callback = function(text, enterPressed) end,
	})

	Section:CreateLabel({ Text = "Just a line of info text." })

	Section:CreateParagraph({
		Title   = "About",
		Content = "Multi-line, word-wrapped text for longer explanations.",
	})

	Section:CreateKeybind({
		Name = "Toggle ESP", Default = Enum.KeyCode.E, Mode = "Toggle", -- or "Hold"
		Flag = "ESPKey", Callback = function(state) end,
	})

	Section:CreateColorPicker({
		Name = "ESP Color", Default = Color3.fromRGB(196, 24, 38),
		Flag = "ESPColor", Callback = function(color) end,
	})

	Section:CreateProgressBar({
		Name = "XP", Min = 0, Max = 100, Default = 40,
	})

	Section:CreateCheckbox({
		Name = "Enable Sound", Default = true, Flag = "SoundOn",
		Callback = function(value) end,
	})

	Section:CreateRadioGroup({
		Name = "Difficulty", Options = { "Easy", "Normal", "Hard" },
		Default = "Normal", Flag = "Difficulty",
		Callback = function(value) end,
	})

	Section:CreateButtonGroup({
		Buttons = {
			{ Text = "Save",  Callback = function() end },
			{ Text = "Reset", Callback = function() end },
		},
	})

	Section:CreateDivider({ Text = "MORE OPTIONS" }) -- omit Text for a plain line

	--------------------------------------------------------------------------
	 NOTIFICATIONS, FLAGS & CONFIG
	--------------------------------------------------------------------------
	Window:Notify({
		Title = "Saved", Content = "Your settings were saved.",
		Type = "Success", Duration = 4, -- "Info" | "Success" | "Warning" | "Error"
	})

	print(SmallDarkOneLib.Flags.WalkSpeed) -- every `Flag = "..."` above is readable here

	SmallDarkOneLib:SaveConfig("MyConfig") -- executor-only (writefile); no-ops safely elsewhere
	SmallDarkOneLib:LoadConfig("MyConfig")

	Window:Destroy() -- disconnects everything and removes the ScreenGui

	--------------------------------------------------------------------------
	 See example.lua for this same tour wired up end-to-end and running.
	--------------------------------------------------------------------------
]]

local SmallDarkOneLib = {}
SmallDarkOneLib.Version = "1.0.0"
SmallDarkOneLib.Flags = {}
SmallDarkOneLib.Windows = {}

-- ============================================================================
--  SERVICES
-- ============================================================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ============================================================================
--  THEMES
-- ============================================================================
local Themes = {}

Themes.Bloodmoon = {
	Name         = "Bloodmoon",
	Background   = Color3.fromRGB(12, 10, 11),
	Panel        = Color3.fromRGB(19, 16, 17),
	PanelLight   = Color3.fromRGB(28, 22, 24),
	Border       = Color3.fromRGB(50, 21, 25),
	Accent       = Color3.fromRGB(196, 24, 38),
	AccentDark   = Color3.fromRGB(110, 16, 24),
	AccentBright = Color3.fromRGB(232, 64, 72),
	Text         = Color3.fromRGB(236, 230, 228),
	SubText      = Color3.fromRGB(150, 138, 138),
	Success      = Color3.fromRGB(96, 200, 128),
	Warning      = Color3.fromRGB(232, 172, 64),
	Error        = Color3.fromRGB(224, 64, 64),
	Font         = Enum.Font.Gotham,
	FontMedium   = Enum.Font.GothamMedium,
	FontBold     = Enum.Font.GothamBold,
	FontDisplay  = Enum.Font.Creepster,
	FontMono     = Enum.Font.SpecialElite,
}

Themes.Voidspider = {
	Name         = "Voidspider",
	Background   = Color3.fromRGB(9, 8, 13),
	Panel        = Color3.fromRGB(16, 14, 22),
	PanelLight   = Color3.fromRGB(25, 20, 33),
	Border       = Color3.fromRGB(42, 27, 58),
	Accent       = Color3.fromRGB(142, 66, 212),
	AccentDark   = Color3.fromRGB(84, 34, 130),
	AccentBright = Color3.fromRGB(178, 110, 240),
	Text         = Color3.fromRGB(232, 228, 238),
	SubText      = Color3.fromRGB(146, 138, 158),
	Success      = Color3.fromRGB(96, 200, 128),
	Warning      = Color3.fromRGB(232, 172, 64),
	Error        = Color3.fromRGB(224, 64, 64),
	Font         = Enum.Font.Gotham,
	FontMedium   = Enum.Font.GothamMedium,
	FontBold     = Enum.Font.GothamBold,
	FontDisplay  = Enum.Font.Creepster,
	FontMono     = Enum.Font.SpecialElite,
}

SmallDarkOneLib.Themes = Themes

-- ============================================================================
--  UTILITIES
-- ============================================================================

local function Create(className, properties, children)
	local inst = Instance.new(className)
	if properties then
		for prop, value in pairs(properties) do
			inst[prop] = value
		end
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end
	return inst
end

local function Tween(instance, properties, duration, style, direction)
	duration = duration or 0.22
	style = style or Enum.EasingStyle.Quad
	direction = direction or Enum.EasingDirection.Out
	local info = TweenInfo.new(duration, style, direction)
	local tween = TweenService:Create(instance, info, properties)
	tween:Play()
	return tween
end

local function Round(number, decimals)
	local mult = 10 ^ (decimals or 0)
	return math.floor(number * mult + 0.5) / mult
end

local function Clamp(value, min, max)
	if value < min then return min end
	if value > max then return max end
	return value
end

-- Maid: tracks connections/instances so a whole Window can be cleaned up in one call
local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({ _tasks = {} }, Maid)
end

function Maid:Give(job)
	table.insert(self._tasks, job)
	return job
end

function Maid:Clean()
	for _, job in ipairs(self._tasks) do
		if typeof(job) == "RBXScriptConnection" then
			job:Disconnect()
		elseif typeof(job) == "Instance" then
			job:Destroy()
		elseif type(job) == "function" then
			job()
		end
	end
	self._tasks = {}
end

local function MakeDraggable(rootFrame, dragHandle)
	local dragging = false
	local dragInput
	local mousePos
	local framePos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			mousePos = input.Position
			framePos = rootFrame.Position

			local conn
			conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					conn:Disconnect()
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			rootFrame.Position = UDim2.new(
				framePos.X.Scale, framePos.X.Offset + delta.X,
				framePos.Y.Scale, framePos.Y.Offset + delta.Y
			)
		end
	end)
end

local function Ripple(button, theme)
	local circle = Create("Frame", {
		Name = "Ripple",
		BackgroundColor3 = theme.AccentBright,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		ZIndex = button.ZIndex + 1,
		Parent = button,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = circle })

	local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.6
	Tween(circle, { Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1 }, 0.45)
	task.delay(0.45, function()
		circle:Destroy()
	end)
end

-- Every row/card in the library is built from this one function, so corner
-- radius and the faint top "sheen" highlight (a classic glassy depth cue)
-- stay perfectly consistent everywhere instead of being repeated by hand in
-- every single element below. Pass `height` for a fixed-height row, or leave
-- it nil for a row that sizes itself to its content (AutomaticSize).
local function Panel(parent, theme, height, radius)
	local frame = Create("Frame", {
		BackgroundColor3 = theme.PanelLight,
		BorderSizePixel = 0,
		Size = height and UDim2.new(1, 0, 0, height) or UDim2.new(1, 0, 0, 0),
		AutomaticSize = height and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
		Parent = parent,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, radius or 5), Parent = frame })
	Create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.94),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = frame,
	})
	return frame
end

local function BindCanvas(scrollingFrame, listLayout, padding)
	padding = padding or 12
	local function Update()
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + padding)
	end
	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update)
	Update()
end

-- ============================================================================
--  NOTIFICATION SYSTEM
-- ============================================================================

local NotificationGui
local NotificationHolder

local function EnsureNotificationGui()
	if NotificationGui and NotificationGui.Parent then
		return
	end
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	NotificationGui = Create("ScreenGui", {
		Name = "SmallDarkOneLib_Notifications",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 1000,
		Parent = playerGui,
	})
	NotificationHolder = Create("Frame", {
		Name = "Holder",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.new(0, 300, 1, -32),
		Parent = NotificationGui,
	})
	Create("UIListLayout", {
		Name = "List",
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = NotificationHolder,
	})
end

function SmallDarkOneLib:Notify(config)
	config = config or {}
	EnsureNotificationGui()

	local theme = config.Theme or SmallDarkOneLib.ActiveTheme or Themes.Bloodmoon
	local kind = config.Type or "Info"
	local accent = theme.Accent
	if kind == "Success" then accent = theme.Success
	elseif kind == "Warning" then accent = theme.Warning
	elseif kind == "Error" then accent = theme.Error
	end

	local duration = config.Duration or 4

	local card = Create("Frame", {
		Name = "Notification",
		BackgroundColor3 = theme.Panel,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 60, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		Parent = NotificationHolder,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = card })
	Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = card })
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 12),
		Parent = card,
	})

	local bar = Create("Frame", {
		Name = "AccentBar",
		BackgroundColor3 = accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, 0),
		Parent = card,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })

	Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = card,
	})

	local titleLabel = Create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Font = theme.FontBold,
		Text = config.Title or "Notification",
		TextColor3 = theme.Text,
		TextTransparency = 1,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local contentLabel
	if config.Content then
		contentLabel = Create("TextLabel", {
			Name = "Content",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = theme.Font,
			Text = config.Content,
			TextColor3 = theme.SubText,
			TextTransparency = 1,
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = card,
		})
	end

	Tween(card, { BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0) }, 0.28)
	Tween(bar, { BackgroundTransparency = 0 }, 0.3)
	Tween(titleLabel, { TextTransparency = 0 }, 0.3)
	if contentLabel then
		Tween(contentLabel, { TextTransparency = 0 }, 0.3)
	end

	task.delay(duration, function()
		if not card.Parent then return end
		Tween(card, { BackgroundTransparency = 1, Position = UDim2.new(0, 60, 0, 0) }, 0.25)
		Tween(bar, { BackgroundTransparency = 1 }, 0.2)
		Tween(titleLabel, { TextTransparency = 1 }, 0.2)
		if contentLabel then
			Tween(contentLabel, { TextTransparency = 1 }, 0.2)
		end
		task.delay(0.3, function()
			card:Destroy()
		end)
	end)
end

-- ============================================================================
--  CLASS METATABLES (Window / Tab / Section)
-- ============================================================================

local WindowMethods = {}
WindowMethods.__index = WindowMethods

local TabMethods = {}
TabMethods.__index = TabMethods

local SectionMethods = {}
SectionMethods.__index = SectionMethods

-- ============================================================================
--  WINDOW
-- ============================================================================

function SmallDarkOneLib:CreateWindow(config)
	config = config or {}

	local theme = Themes[config.Theme] or (type(config.Theme) == "table" and config.Theme) or Themes.Bloodmoon
	SmallDarkOneLib.ActiveTheme = theme

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local maid = Maid.new()

	local screenGui = Create("ScreenGui", {
		Name = "SmallDarkOneLib",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		Parent = playerGui,
	})
	maid:Give(screenGui)

	-- responsive scaling: PC and mobile share one UIScale
	local uiScale = Create("UIScale", { Scale = 1, Parent = screenGui })
	local baseResolution = Vector2.new(1280, 832)
	local function UpdateScale()
		local camera = workspace.CurrentCamera
		if not camera then return end
		local viewport = camera.ViewportSize
		local scale = math.min(viewport.X / baseResolution.X, viewport.Y / baseResolution.Y)
		uiScale.Scale = Clamp(scale, 0.62, 1.05)
	end
	UpdateScale()
	if workspace.CurrentCamera then
		maid:Give(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale))
	end

	local size = config.Size or UDim2.new(0, 560, 0, 380)

	local main = Create("Frame", {
		Name = "Main",
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = size,
		Parent = screenGui,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = main })
	local mainStroke = Create("UIStroke", { Color = theme.Accent, Thickness = 1.3, Transparency = 0.3, Parent = main })

	-- subtle pulsing glow on the border ("heartbeat")
	task.spawn(function()
		while main.Parent do
			Tween(mainStroke, { Transparency = 0.6 }, 1.3, Enum.EasingStyle.Sine)
			task.wait(1.3)
			if not main.Parent then break end
			Tween(mainStroke, { Transparency = 0.15 }, 1.3, Enum.EasingStyle.Sine)
			task.wait(1.3)
		end
	end)

	-- top bar
	local topBar = Create("Frame", {
		Name = "TopBar",
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 46),
		Parent = main,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = topBar })
	Create("Frame", {
		Name = "Mask",
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -8),
		Size = UDim2.new(1, 0, 0, 8),
		Parent = topBar,
	})
	Create("Frame", {
		Name = "AccentLine",
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		Parent = topBar,
	})
	Create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 3),
		Size = UDim2.new(1, -100, 0, 24),
		Font = theme.FontDisplay,
		Text = config.Title or "SMALL DARK ONE",
		TextColor3 = theme.Accent,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topBar,
	})
	Create("TextLabel", {
		Name = "Subtitle",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 27),
		Size = UDim2.new(1, -100, 0, 14),
		Font = theme.FontMono,
		Text = config.Subtitle or ("v" .. SmallDarkOneLib.Version),
		TextColor3 = theme.SubText,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topBar,
	})

	local closeBtn = Create("TextButton", {
		Name = "Close",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, 24, 0, 24),
		Font = theme.FontBold,
		Text = "X",
		TextColor3 = theme.SubText,
		TextSize = 16,
		Parent = topBar,
	})
	local minimizeBtn = Create("TextButton", {
		Name = "Minimize",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -40, 0.5, 0),
		Size = UDim2.new(0, 24, 0, 24),
		Font = theme.FontBold,
		Text = "_",
		TextColor3 = theme.SubText,
		TextSize = 16,
		Parent = topBar,
	})

	closeBtn.MouseEnter:Connect(function() Tween(closeBtn, { TextColor3 = theme.Error }, 0.15) end)
	closeBtn.MouseLeave:Connect(function() Tween(closeBtn, { TextColor3 = theme.SubText }, 0.15) end)
	minimizeBtn.MouseEnter:Connect(function() Tween(minimizeBtn, { TextColor3 = theme.Accent }, 0.15) end)
	minimizeBtn.MouseLeave:Connect(function() Tween(minimizeBtn, { TextColor3 = theme.SubText }, 0.15) end)

	-- sidebar (tabs)
	local sidebar = Create("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 46),
		Size = UDim2.new(0, 128, 1, -46),
		Parent = main,
	})
	Create("Frame", {
		Name = "Divider",
		BackgroundColor3 = theme.Border,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -1, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		Parent = sidebar,
	})
	local tabList = Create("ScrollingFrame", {
		Name = "TabList",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 6, 0, 8),
		Size = UDim2.new(1, -12, 1, -16),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = sidebar,
	})
	local tabListLayout = Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabList,
	})
	BindCanvas(tabList, tabListLayout, 8)

	-- content area
	local contentArea = Create("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 128, 0, 46),
		Size = UDim2.new(1, -128, 1, -46),
		Parent = main,
	})

	MakeDraggable(main, topBar)

	-- watermark
	if config.Watermark ~= false then
		local watermark = Create("TextLabel", {
			Name = "Watermark",
			BackgroundColor3 = theme.Panel,
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 16, 0, 16),
			Size = UDim2.new(0, 220, 0, 22),
			Font = theme.FontMono,
			Text = string.format(" %s | v%s", config.WatermarkText or config.Title or "SmallDarkOneLib", SmallDarkOneLib.Version),
			TextColor3 = theme.Accent,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = screenGui,
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = watermark })
		Create("UIStroke", { Color = theme.Accent, Thickness = 1, Transparency = 0.5, Parent = watermark })
	end

	-- global show/hide keybind
	local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
	local uiVisible = true
	maid:Give(UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == toggleKey then
			uiVisible = not uiVisible
			main.Visible = uiVisible
		end
	end))

	local minimized = false
	local expandedSize = size
	minimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			expandedSize = main.Size
			Tween(main, { Size = UDim2.new(expandedSize.X.Scale, expandedSize.X.Offset, 0, 46) }, 0.25)
			sidebar.Visible = false
			contentArea.Visible = false
		else
			Tween(main, { Size = expandedSize }, 0.25)
			task.delay(0.1, function()
				sidebar.Visible = true
				contentArea.Visible = true
			end)
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		Tween(main, { Size = UDim2.new(main.Size.X.Scale, main.Size.X.Offset, 0, 0), BackgroundTransparency = 1 }, 0.2)
		task.delay(0.2, function()
			screenGui.Enabled = false
		end)
	end)

	local Window = setmetatable({
		Theme = theme,
		ScreenGui = screenGui,
		Main = main,
		ContentArea = contentArea,
		TabList = tabList,
		Maid = maid,
		Tabs = {},
		ActiveTab = nil,
	}, WindowMethods)

	table.insert(SmallDarkOneLib.Windows, Window)
	return Window
end

function WindowMethods:CreateTab(name, icon)
	local theme = self.Theme
	name = name or "Tab"

	local tabButton = Create("TextButton", {
		Name = name .. "Button",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 32),
		Font = theme.FontMedium,
		Text = "  " .. (icon and (icon .. "  ") or "") .. name,
		TextColor3 = theme.SubText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		Parent = self.TabList,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = tabButton })
	local indicator = Create("Frame", {
		Name = "Indicator",
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.2, 0),
		Size = UDim2.new(0, 3, 0.6, 0),
		Visible = false,
		Parent = tabButton,
	})

	local page = Create("ScrollingFrame", {
		Name = name .. "Page",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Visible = false,
		Parent = self.ContentArea,
	})
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		Parent = page,
	})
	local pageLayout = Create("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = page,
	})
	BindCanvas(page, pageLayout, 24)

	local Tab = setmetatable({
		Theme = theme,
		Page = page,
		Window = self,
		Button = tabButton,
		Indicator = indicator,
	}, TabMethods)

	tabButton.MouseButton1Click:Connect(function()
		self:SelectTab(Tab)
	end)
	tabButton.MouseEnter:Connect(function()
		if self.ActiveTab ~= Tab then
			Tween(tabButton, { TextColor3 = theme.Text }, 0.15)
		end
	end)
	tabButton.MouseLeave:Connect(function()
		if self.ActiveTab ~= Tab then
			Tween(tabButton, { TextColor3 = theme.SubText }, 0.15)
		end
	end)

	table.insert(self.Tabs, Tab)
	if not self.ActiveTab then
		self:SelectTab(Tab)
	end

	return Tab
end

function WindowMethods:SelectTab(tab)
	for _, t in ipairs(self.Tabs) do
		local active = (t == tab)
		t.Page.Visible = active
		t.Indicator.Visible = active
		Tween(t.Button, { TextColor3 = active and t.Theme.Text or t.Theme.SubText }, 0.15)
	end
	self.ActiveTab = tab
end

function WindowMethods:Notify(config)
	config = config or {}
	config.Theme = config.Theme or self.Theme
	SmallDarkOneLib:Notify(config)
end

function WindowMethods:SetTheme(themeNameOrTable)
	local theme = Themes[themeNameOrTable] or (type(themeNameOrTable) == "table" and themeNameOrTable) or self.Theme
	self.Theme = theme
	SmallDarkOneLib.ActiveTheme = theme
	-- NOTE: this only affects newly created elements / windows.
	-- Live re-theming of already-built elements isn't wired up — build
	-- the window with your chosen theme up front.
end

function WindowMethods:Destroy()
	self.Maid:Clean()
end

-- ============================================================================
--  TAB / SECTION
-- ============================================================================

function TabMethods:CreateSection(name)
	local theme = self.Theme

	local section = Create("Frame", {
		Name = "Section",
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self.Page,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = section })
	Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = section })

	local header = Create("TextButton", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 32),
		Text = "",
		AutoButtonColor = false,
		Parent = section,
	})
	Create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Font = theme.FontBold,
		Text = name or "Section",
		TextColor3 = theme.Accent,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	local chevron = Create("TextLabel", {
		Name = "Chevron",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		Font = theme.FontBold,
		Text = "\226\150\190", -- ▾
		TextColor3 = theme.SubText,
		TextSize = 14,
		Parent = header,
	})

	local body = Create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 32),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		Parent = section,
	})
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
		Parent = body,
	})
	local bodyLayout = Create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = body,
	})

	local collapsed = false
	header.MouseButton1Click:Connect(function()
		collapsed = not collapsed
		if collapsed then
			local fullHeight = body.AbsoluteSize.Y
			body.AutomaticSize = Enum.AutomaticSize.None
			body.Size = UDim2.new(1, 0, 0, fullHeight)
			Tween(body, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
			Tween(chevron, { Rotation = -90 }, 0.2)
		else
			local fullHeight = bodyLayout.AbsoluteContentSize.Y + 14
			Tween(body, { Size = UDim2.new(1, 0, 0, fullHeight) }, 0.2)
			Tween(chevron, { Rotation = 0 }, 0.2)
			task.delay(0.2, function()
				if not collapsed then
					body.AutomaticSize = Enum.AutomaticSize.Y
				end
			end)
		end
	end)

	local Section = setmetatable({
		Theme = theme,
		Body = body,
		Tab = self,
	}, SectionMethods)

	return Section
end

-- ============================================================================
--  ELEMENTS
-- ============================================================================

-- Button ---------------------------------------------------------------------

function SectionMethods:CreateButton(config)
	config = config or {}
	local theme = self.Theme

	local row = Panel(self.Body, theme, 34)
	row.Name = "Button"
	row.ClipsDescendants = true

	local btn = Create("TextButton", {
		Name = "Click",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = theme.FontMedium,
		Text = config.Name or "Button",
		TextColor3 = theme.Text,
		TextSize = 13,
		AutoButtonColor = false,
		Parent = row,
	})

	btn.MouseEnter:Connect(function() Tween(row, { BackgroundColor3 = theme.AccentDark }, 0.15) end)
	btn.MouseLeave:Connect(function() Tween(row, { BackgroundColor3 = theme.PanelLight }, 0.15) end)
	btn.MouseButton1Click:Connect(function()
		Ripple(btn, theme)
		if config.Callback then
			local ok, err = pcall(config.Callback)
			if not ok then
				warn("[SmallDarkOneLib] Button callback error: " .. tostring(err))
			end
		end
	end)

	local API = {}
	function API:SetText(text)
		btn.Text = text
	end
	return API
end

-- Toggle ---------------------------------------------------------------------

function SectionMethods:CreateToggle(config)
	config = config or {}
	local theme = self.Theme
	local value = config.Default or false

	local row = Panel(self.Body, theme, 34)
	row.Name = "Toggle"

	Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -60, 1, 0),
		Font = theme.FontMedium,
		Text = config.Name or "Toggle",
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local track = Create("TextButton", {
		Name = "Track",
		BackgroundColor3 = theme.Border,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 38, 0, 20),
		Text = "",
		AutoButtonColor = false,
		Parent = row,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

	local knob = Create("Frame", {
		Name = "Knob",
		BackgroundColor3 = theme.SubText,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		Parent = track,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

	local function Render(animated)
		local targetPos = value and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
		local targetTrackColor = value and theme.Accent or theme.Border
		local targetKnobColor = value and theme.Text or theme.SubText
		if animated then
			Tween(knob, { Position = targetPos, BackgroundColor3 = targetKnobColor }, 0.18)
			Tween(track, { BackgroundColor3 = targetTrackColor }, 0.18)
		else
			knob.Position = targetPos
			knob.BackgroundColor3 = targetKnobColor
			track.BackgroundColor3 = targetTrackColor
		end
	end
	Render(false)

	local function SetValue(newValue, fireCallback)
		value = newValue and true or false
		Render(true)
		if config.Flag then
			SmallDarkOneLib.Flags[config.Flag] = value
		end
		if fireCallback ~= false and config.Callback then
			local ok, err = pcall(config.Callback, value)
			if not ok then
				warn("[SmallDarkOneLib] Toggle callback error: " .. tostring(err))
			end
		end
	end

	track.MouseButton1Click:Connect(function()
		SetValue(not value, true)
	end)

	if config.Flag then
		SmallDarkOneLib.Flags[config.Flag] = value
	end

	local API = {}
	function API:Set(newValue) SetValue(newValue, true) end
	function API:Get() return value end
	return API
end

-- Slider ---------------------------------------------------------------------

function SectionMethods:CreateSlider(config)
	config = config or {}
	local theme = self.Theme
	local minVal = config.Min or 0
	local maxVal = config.Max or 100
	local decimals = config.Decimals or 0
	local value = Clamp(config.Default or minVal, minVal, maxVal)

	local row = Panel(self.Body, theme, 46)
	row.Name = "Slider"

	Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 6),
		Size = UDim2.new(1, -80, 0, 16),
		Font = theme.FontMedium,
		Text = config.Name or "Slider",
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	local valueLabel = Create("TextLabel", {
		Name = "Value",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 6),
		Size = UDim2.new(0, 60, 0, 16),
		Font = theme.FontMono,
		Text = tostring(value),
		TextColor3 = theme.Accent,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row,
	})

	local track = Create("Frame", {
		Name = "Track",
		BackgroundColor3 = theme.Border,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 1, -14),
		Size = UDim2.new(1, -20, 0, 6),
		Parent = row,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

	local fill = Create("Frame", {
		Name = "Fill",
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = track,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

	local knob = Create("Frame", {
		Name = "Knob",
		BackgroundColor3 = theme.Text,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 12, 0, 12),
		Parent = track,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

	local dragging = false

	local function Render()
		local ratio = 0
		if maxVal > minVal then
			ratio = Clamp((value - minVal) / (maxVal - minVal), 0, 1)
		end
		fill.Size = UDim2.new(ratio, 0, 1, 0)
		knob.Position = UDim2.new(ratio, 0, 0.5, 0)
		valueLabel.Text = tostring(Round(value, decimals))
	end
	Render()

	local function SetValue(newValue, fireCallback)
		newValue = Clamp(newValue, minVal, maxVal)
		if decimals <= 0 then
			newValue = math.floor(newValue + 0.5)
		else
			newValue = Round(newValue, decimals)
		end
		value = newValue
		Render()
		if config.Flag then
			SmallDarkOneLib.Flags[config.Flag] = value
		end
		if fireCallback ~= false and config.Callback then
			local ok, err = pcall(config.Callback, value)
			if not ok then
				warn("[SmallDarkOneLib] Slider callback error: " .. tostring(err))
			end
		end
	end

	local function UpdateFromInput(input)
		local relativeX = Clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
		local ratio = 0
		if track.AbsoluteSize.X > 0 then
			ratio = relativeX / track.AbsoluteSize.X
		end
		SetValue(minVal + (maxVal - minVal) * ratio, true)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			UpdateFromInput(input)
		end
	end)
	track.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			UpdateFromInput(input)
		end
	end)

	if config.Flag then
		SmallDarkOneLib.Flags[config.Flag] = value
	end

	local API = {}
	function API:Set(newValue) SetValue(newValue, true) end
	function API:Get() return value end
	return API
end

-- Dropdown (single or multi-select, optional search filter) ------------------

function SectionMethods:CreateDropdown(config)
	config = config or {}
	local theme = self.Theme
	local options = config.Options or {}
	local multi = config.Multi or false
	local selected = {}

	if multi then
		if config.Default then
			for _, v in ipairs(config.Default) do
				selected[v] = true
			end
		end
	else
		selected.value = config.Default
	end

	local container = Panel(self.Body, theme, 34)
	container.Name = "Dropdown"
	container.ClipsDescendants = true

	local head = Create("TextButton", {
		Name = "Head",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
		Text = "",
		AutoButtonColor = false,
		Parent = container,
	})
	Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -110, 1, 0),
		Font = theme.FontMedium,
		Text = config.Name or "Dropdown",
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = head,
	})
	local valueLabel = Create("TextLabel", {
		Name = "Value",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -30, 0, 0),
		Size = UDim2.new(0, 100, 1, 0),
		Font = theme.FontMono,
		Text = "",
		TextColor3 = theme.Accent,
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = head,
	})
	local chevron = Create("TextLabel", {
		Name = "Chevron",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		Font = theme.FontBold,
		Text = "v",
		TextColor3 = theme.SubText,
		TextSize = 12,
		Parent = head,
	})

	local list = Create("Frame", {
		Name = "List",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 34),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = container,
	})
	Create("UIPadding", {
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6),
		Parent = list,
	})
	local listLayout = Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = list,
	})

	local searchBox
	if config.Searchable then
		searchBox = Create("TextBox", {
			Name = "Search",
			BackgroundColor3 = theme.Panel,
			BorderSizePixel = 0,
			LayoutOrder = -1,
			Size = UDim2.new(1, 0, 0, 24),
			Font = theme.Font,
			PlaceholderText = "Search...",
			PlaceholderColor3 = theme.SubText,
			Text = "",
			TextColor3 = theme.Text,
			TextSize = 12,
			ClearTextOnFocus = false,
			Parent = list,
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = searchBox })
	end

	local optionButtons = {}
	local open = false
	local OpenList, CloseList, SelectOption, UpdateValueLabel, RefreshHighlights, FireCallback, BuildOptions

	UpdateValueLabel = function()
		if multi then
			local names = {}
			for _, opt in ipairs(options) do
				if selected[opt] then
					table.insert(names, opt)
				end
			end
			valueLabel.Text = (#names > 0) and table.concat(names, ", ") or "None"
		else
			valueLabel.Text = selected.value and tostring(selected.value) or "None"
		end
	end

	RefreshHighlights = function()
		for optName, optBtn in pairs(optionButtons) do
			local isSelected = multi and selected[optName] or (selected.value == optName)
			optBtn.BackgroundColor3 = isSelected and theme.AccentDark or theme.Panel
		end
	end

	FireCallback = function()
		if config.Flag then
			SmallDarkOneLib.Flags[config.Flag] = multi and selected or selected.value
		end
		if config.Callback then
			local ok, err = pcall(config.Callback, multi and selected or selected.value)
			if not ok then
				warn("[SmallDarkOneLib] Dropdown callback error: " .. tostring(err))
			end
		end
	end

	CloseList = function()
		open = false
		Tween(container, { Size = UDim2.new(1, 0, 0, 34) }, 0.2)
		Tween(chevron, { Rotation = 0 }, 0.2)
	end

	OpenList = function()
		open = true
		local fullHeight = 34 + listLayout.AbsoluteContentSize.Y + 10
		Tween(container, { Size = UDim2.new(1, 0, 0, fullHeight) }, 0.2)
		Tween(chevron, { Rotation = 180 }, 0.2)
	end

	SelectOption = function(optName)
		if multi then
			selected[optName] = not selected[optName]
		else
			selected.value = optName
		end
		UpdateValueLabel()
		RefreshHighlights()
		FireCallback()
		if not multi then
			CloseList()
		end
	end

	BuildOptions = function()
		for _, btn in pairs(optionButtons) do
			btn:Destroy()
		end
		optionButtons = {}
		for _, optName in ipairs(options) do
			local optBtn = Create("TextButton", {
				Name = "Option",
				BackgroundColor3 = theme.Panel,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 26),
				Font = theme.Font,
				Text = "  " .. tostring(optName),
				TextColor3 = theme.Text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false,
				Parent = list,
			})
			Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = optBtn })
			optBtn.MouseButton1Click:Connect(function()
				SelectOption(optName)
			end)
			optionButtons[optName] = optBtn
		end
		RefreshHighlights()
	end

	if searchBox then
		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			local query = string.lower(searchBox.Text)
			for optName, optBtn in pairs(optionButtons) do
				if query == "" then
					optBtn.Visible = true
				else
					optBtn.Visible = string.find(string.lower(tostring(optName)), query, 1, true) ~= nil
				end
			end
		end)
	end

	head.MouseButton1Click:Connect(function()
		if open then CloseList() else OpenList() end
	end)

	BuildOptions()
	UpdateValueLabel()
	if config.Flag then
		SmallDarkOneLib.Flags[config.Flag] = multi and selected or selected.value
	end

	local API = {}
	function API:Set(value)
		if multi then
			selected = {}
			for _, v in ipairs(value) do
				selected[v] = true
			end
		else
			selected.value = value
		end
		UpdateValueLabel()
		RefreshHighlights()
		FireCallback()
	end
	function API:Get()
		if multi then
			local out = {}
			for k, v in pairs(selected) do
				if v then table.insert(out, k) end
			end
			return out
		end
		return selected.value
	end
	function API:SetOptions(newOptions)
		options = newOptions
		BuildOptions()
		UpdateValueLabel()
	end
	return API
end

-- Textbox ----------------------------------------------------------------

function SectionMethods:CreateTextbox(config)
	config = config or {}
	local theme = self.Theme
	local hasLabel = (config.Name ~= nil and config.Name ~= "")

	local row = Panel(self.Body, theme, 34)
	row.Name = "Textbox"

	if hasLabel then
		Create("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 0),
			Size = UDim2.new(0, 90, 1, 0),
			Font = theme.FontMedium,
			Text = config.Name,
			TextColor3 = theme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
	end

	local inputHolder = Create("Frame", {
		Name = "InputHolder",
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Position = hasLabel and UDim2.new(0, 100, 0, 5) or UDim2.new(0, 10, 0, 5),
		Size = hasLabel and UDim2.new(1, -110, 1, -10) or UDim2.new(1, -20, 1, -10),
		Parent = row,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = inputHolder })

	local box = Create("TextBox", {
		Name = "Box",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -16, 1, 0),
		Font = theme.Font,
		PlaceholderText = config.Placeholder or "",
		PlaceholderColor3 = theme.SubText,
		Text = config.Default or "",
		TextColor3 = theme.Text,
		TextSize = 13,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = inputHolder,
	})

	if config.CharacterLimit then
		box:GetPropertyChangedSignal("Text"):Connect(function()
			if #box.Text > config.CharacterLimit then
				box.Text = string.sub(box.Text, 1, config.CharacterLimit)
			end
		end)
	end
	if config.NumbersOnly then
		box:GetPropertyChangedSignal("Text"):Connect(function()
			local filtered = string.gsub(box.Text, "[^%d%.%-]", "")
			if filtered ~= box.Text then
				box.Text = filtered
			end
		end)
	end

	box.FocusLost:Connect(function(enterPressed)
		if config.Flag then
			SmallDarkOneLib.Flags[config.Flag] = box.Text
		end
		if config.Callback then
			local ok, err = pcall(config.Callback, box.Text, enterPressed)
			if not ok then
				warn("[SmallDarkOneLib] Textbox callback error: " .. tostring(err))
			end
		end
	end)

	if config.Flag then
		SmallDarkOneLib.Flags[config.Flag] = box.Text
	end

	local API = {}
	function API:Set(text) box.Text = text end
	function API:Get() return box.Text end
	return API
end

-- Label ------------------------------------------------------------------

function SectionMethods:CreateLabel(config)
	config = config or {}
	local theme = self.Theme

	local label = Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Font = theme.Font,
		Text = config.Text or "",
		RichText = config.RichText or false,
		TextColor3 = theme.SubText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Body,
	})

	local API = {}
	function API:SetText(text) label.Text = text end
	return API
end

-- Paragraph ----------------------------------------------------------------

function SectionMethods:CreateParagraph(config)
	config = config or {}
	local theme = self.Theme

	local holder = Panel(self.Body, theme, nil, 5)
	holder.Name = "Paragraph"
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
		Parent = holder,
	})
	Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder })

	Create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Font = theme.FontBold,
		Text = config.Title or "",
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})
	local content = Create("TextLabel", {
		Name = "Content",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = theme.Font,
		Text = config.Content or "",
		TextColor3 = theme.SubText,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})

	local API = {}
	function API:SetContent(text) content.Text = text end
	return API
end

-- Keybind (Toggle or Hold capture mode) ---------------------------------------

function SectionMethods:CreateKeybind(config)
	config = config or {}
	local theme = self.Theme
	local mode = config.Mode or "Toggle" -- "Toggle" or "Hold"
	local currentKey = config.Default
	local state = false
	local listening = false

	local row = Panel(self.Body, theme, 34)
	row.Name = "Keybind"

	Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -110, 1, 0),
		Font = theme.FontMedium,
		Text = config.Name or "Keybind",
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local keyBtn = Create("TextButton", {
		Name = "Key",
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 90, 0, 22),
		Font = theme.FontMono,
		Text = currentKey and currentKey.Name or "None",
		TextColor3 = theme.Accent,
		TextSize = 12,
		AutoButtonColor = false,
		Parent = row,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = keyBtn })

	keyBtn.MouseButton1Click:Connect(function()
		listening = true
		keyBtn.Text = "..."
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				currentKey = input.KeyCode
				keyBtn.Text = currentKey.Name
				listening = false
				if config.Flag then
					SmallDarkOneLib.Flags[config.Flag] = currentKey
				end
			end
			return
		end
		if processed then return end
		if currentKey and input.KeyCode == currentKey then
			if mode == "Toggle" then
				state = not state
				if config.Callback then
					local ok, err = pcall(config.Callback, state)
					if not ok then warn("[SmallDarkOneLib] Keybind callback error: " .. tostring(err)) end
				end
			else
				state = true
				if config.Callback then
					local ok, err = pcall(config.Callback, true)
					if not ok then warn("[SmallDarkOneLib] Keybind callback error: " .. tostring(err)) end
				end
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if mode == "Hold" and currentKey and input.KeyCode == currentKey then
			state = false
			if config.Callback then
				local ok, err = pcall(config.Callback, false)
				if not ok then warn("[SmallDarkOneLib] Keybind callback error: " .. tostring(err)) end
			end
		end
	end)

	if config.Flag then
		SmallDarkOneLib.Flags[config.Flag] = currentKey
	end

	local API = {}
	function API:Set(keyCode)
		currentKey = keyCode
		keyBtn.Text = keyCode and keyCode.Name or "None"
	end
	function API:Get() return currentKey end
	return API
end

-- ColorPicker (hue bar + saturation/value box, no image assets) ---------------

function SectionMethods:CreateColorPicker(config)
	config = config or {}
	local theme = self.Theme
	local color = config.Default or theme.Accent
	local h, s, v = color:ToHSV()

	local container = Panel(self.Body, theme, 34)
	container.Name = "ColorPicker"
	container.ClipsDescendants = true

	local head = Create("TextButton", {
		Name = "Head",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
		Text = "",
		AutoButtonColor = false,
		Parent = container,
	})
	Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -60, 1, 0),
		Font = theme.FontMedium,
		Text = config.Name or "Color",
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = head,
	})
	local swatch = Create("Frame", {
		Name = "Swatch",
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -34, 0.5, 0),
		Size = UDim2.new(0, 26, 0, 18),
		Parent = head,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = swatch })
	Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = swatch })

	local chevron = Create("TextLabel", {
		Name = "Chevron",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		Font = theme.FontBold,
		Text = "v",
		TextColor3 = theme.SubText,
		TextSize = 12,
		Parent = head,
	})

	local panel = Create("Frame", {
		Name = "Panel",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 40),
		Size = UDim2.new(1, -20, 0, 130),
		Parent = container,
	})

	-- saturation/value box (saturation left->right, value top->bottom)
	local svBox = Create("Frame", {
		Name = "SVBox",
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.new(1, -30, 0, 90),
		Parent = panel,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = svBox })

	local whiteOverlay = Create("Frame", {
		Name = "WhiteOverlay",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = svBox,
	})
	Create("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)),
		Transparency = NumberSequence.new(0, 1),
		Parent = whiteOverlay,
	})

	local blackOverlay = Create("Frame", {
		Name = "BlackOverlay",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = svBox,
	})
	Create("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0)),
		Transparency = NumberSequence.new(1, 0),
		Rotation = 90,
		Parent = blackOverlay,
	})

	local svKnob = Create("Frame", {
		Name = "Knob",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 8, 0, 8),
		Position = UDim2.new(s, 0, 1 - v, 0),
		ZIndex = 5,
		Parent = svBox,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svKnob })
	Create("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1, Parent = svKnob })

	local hueBar = Create("Frame", {
		Name = "HueBar",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 18, 1, 0),
		Parent = panel,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = hueBar })
	Create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
		}),
		Parent = hueBar,
	})
	local hueKnob = Create("Frame", {
		Name = "Knob",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, 4, 0, 4),
		Position = UDim2.new(0.5, 0, h, 0),
		ZIndex = 5,
		Parent = hueBar,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = hueKnob })
	Create("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1, Parent = hueKnob })

	local hexLabel = Create("TextLabel", {
		Name = "Hex",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 96),
		Size = UDim2.new(1, -30, 0, 18),
		Font = theme.FontMono,
		Text = "#" .. color:ToHex(),
		TextColor3 = theme.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = panel,
	})

	local function Recompute()
		color = Color3.fromHSV(h, s, v)
		swatch.BackgroundColor3 = color
		svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		hexLabel.Text = "#" .. color:ToHex()
		if config.Flag then
			SmallDarkOneLib.Flags[config.Flag] = color
		end
		if config.Callback then
			local ok, err = pcall(config.Callback, color)
			if not ok then warn("[SmallDarkOneLib] ColorPicker callback error: " .. tostring(err)) end
		end
	end

	local draggingSV, draggingHue = false, false

	svBox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSV = true
		end
	end)
	svBox.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSV = false
		end
	end)
	hueBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = true
		end
	end)
	hueBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if draggingSV then
			local relX = Clamp(input.Position.X - svBox.AbsolutePosition.X, 0, svBox.AbsoluteSize.X)
			local relY = Clamp(input.Position.Y - svBox.AbsolutePosition.Y, 0, svBox.AbsoluteSize.Y)
			s = svBox.AbsoluteSize.X > 0 and (relX / svBox.AbsoluteSize.X) or 0
			v = svBox.AbsoluteSize.Y > 0 and (1 - relY / svBox.AbsoluteSize.Y) or 0
			svKnob.Position = UDim2.new(s, 0, 1 - v, 0)
			Recompute()
		elseif draggingHue then
			local relY = Clamp(input.Position.Y - hueBar.AbsolutePosition.Y, 0, hueBar.AbsoluteSize.Y)
			h = hueBar.AbsoluteSize.Y > 0 and (relY / hueBar.AbsoluteSize.Y) or 0
			hueKnob.Position = UDim2.new(0.5, 0, h, 0)
			Recompute()
		end
	end)

	local open = false
	head.MouseButton1Click:Connect(function()
		open = not open
		if open then
			Tween(container, { Size = UDim2.new(1, 0, 0, 180) }, 0.2)
			Tween(chevron, { Rotation = 180 }, 0.2)
		else
			Tween(container, { Size = UDim2.new(1, 0, 0, 34) }, 0.2)
			Tween(chevron, { Rotation = 0 }, 0.2)
		end
	end)

	if config.Flag then
		SmallDarkOneLib.Flags[config.Flag] = color
	end

	local API = {}
	function API:Set(newColor)
		h, s, v = newColor:ToHSV()
		svKnob.Position = UDim2.new(s, 0, 1 - v, 0)
		hueKnob.Position = UDim2.new(0.5, 0, h, 0)
		Recompute()
	end
	function API:Get() return color end
	return API
end

-- ProgressBar ----------------------------------------------------------------

function SectionMethods:CreateProgressBar(config)
	config = config or {}
	local theme = self.Theme
	local minVal = config.Min or 0
	local maxVal = config.Max or 100
	local value = Clamp(config.Default or minVal, minVal, maxVal)

	local row = Panel(self.Body, theme, 40)
	row.Name = "ProgressBar"

	Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 4),
		Size = UDim2.new(1, -80, 0, 16),
		Font = theme.FontMedium,
		Text = config.Name or "Progress",
		TextColor3 = theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	local percentLabel = Create("TextLabel", {
		Name = "Percent",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 4),
		Size = UDim2.new(0, 60, 0, 16),
		Font = theme.FontMono,
		Text = "0%",
		TextColor3 = theme.Accent,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row,
	})

	local track = Create("Frame", {
		Name = "Track",
		BackgroundColor3 = theme.Border,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 1, -12),
		Size = UDim2.new(1, -20, 0, 6),
		ClipsDescendants = true,
		Parent = row,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
	local fill = Create("Frame", {
		Name = "Fill",
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = track,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

	local function Render(animated)
		local ratio = 0
		if maxVal > minVal then
			ratio = Clamp((value - minVal) / (maxVal - minVal), 0, 1)
		end
		percentLabel.Text = tostring(math.floor(ratio * 100 + 0.5)) .. "%"
		if animated then
			Tween(fill, { Size = UDim2.new(ratio, 0, 1, 0) }, 0.25)
		else
			fill.Size = UDim2.new(ratio, 0, 1, 0)
		end
	end
	Render(false)

	local API = {}
	function API:Set(newValue, animated)
		value = Clamp(newValue, minVal, maxVal)
		Render(animated ~= false)
	end
	function API:Get() return value end
	return API
end

-- Checkbox ---------------------------------------------------------------

function SectionMethods:CreateCheckbox(config)
	config = config or {}
	local theme = self.Theme
	local value = config.Default or false

	local row = Panel(self.Body, theme, 34)
	row.Name = "Checkbox"

	Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -50, 1, 0),
		Font = theme.FontMedium,
		Text = config.Name or "Checkbox",
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local box = Create("TextButton", {
		Name = "Box",
		BackgroundColor3 = value and theme.AccentDark or theme.Panel,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 20, 0, 20),
		Text = "",
		AutoButtonColor = false,
		Parent = row,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = box })
	Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = box })

	local check = Create("TextLabel", {
		Name = "Check",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = theme.FontBold,
		Text = "\226\156\147", -- checkmark glyph
		TextColor3 = theme.Accent,
		TextSize = 14,
		TextTransparency = value and 0 or 1,
		Parent = box,
	})

	local function SetValue(newValue, fireCallback)
		value = newValue and true or false
		Tween(check, { TextTransparency = value and 0 or 1 }, 0.15)
		Tween(box, { BackgroundColor3 = value and theme.AccentDark or theme.Panel }, 0.15)
		if config.Flag then
			SmallDarkOneLib.Flags[config.Flag] = value
		end
		if fireCallback ~= false and config.Callback then
			local ok, err = pcall(config.Callback, value)
			if not ok then warn("[SmallDarkOneLib] Checkbox callback error: " .. tostring(err)) end
		end
	end

	box.MouseButton1Click:Connect(function()
		SetValue(not value, true)
	end)

	if config.Flag then
		SmallDarkOneLib.Flags[config.Flag] = value
	end

	local API = {}
	function API:Set(newValue) SetValue(newValue, true) end
	function API:Get() return value end
	return API
end

-- RadioGroup (single choice from a set of options) ----------------------------

function SectionMethods:CreateRadioGroup(config)
	config = config or {}
	local theme = self.Theme
	local options = config.Options or {}
	local selected = config.Default

	local holder = Panel(self.Body, theme, nil, 5)
	holder.Name = "RadioGroup"
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
		Parent = holder,
	})
	Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder })

	if config.Name then
		Create("TextLabel", {
			Name = "Title",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			Font = theme.FontBold,
			Text = config.Name,
			TextColor3 = theme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = holder,
		})
	end

	local buttons = {}

	local function Refresh()
		for optName, ring in pairs(buttons) do
			local isSelected = (optName == selected)
			Tween(ring.Dot, { BackgroundTransparency = isSelected and 0 or 1 }, 0.15)
			Tween(ring.Circle, { BackgroundColor3 = isSelected and theme.Accent or theme.Border }, 0.15)
		end
	end

	local function Select(optName)
		selected = optName
		Refresh()
		if config.Flag then
			SmallDarkOneLib.Flags[config.Flag] = selected
		end
		if config.Callback then
			local ok, err = pcall(config.Callback, selected)
			if not ok then warn("[SmallDarkOneLib] RadioGroup callback error: " .. tostring(err)) end
		end
	end

	for _, optName in ipairs(options) do
		local optRow = Create("TextButton", {
			Name = tostring(optName),
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 22),
			Text = "",
			AutoButtonColor = false,
			Parent = holder,
		})
		local circle = Create("Frame", {
			Name = "Circle",
			BackgroundColor3 = (optName == selected) and theme.Accent or theme.Border,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 16, 0, 16),
			Parent = optRow,
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = circle })
		local dot = Create("Frame", {
			Name = "Dot",
			BackgroundColor3 = theme.Text,
			BackgroundTransparency = (optName == selected) and 0 or 1,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 7, 0, 7),
			Parent = circle,
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
		Create("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 24, 0, 0),
			Size = UDim2.new(1, -24, 1, 0),
			Font = theme.Font,
			Text = tostring(optName),
			TextColor3 = theme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = optRow,
		})

		optRow.MouseButton1Click:Connect(function()
			Select(optName)
		end)

		buttons[optName] = { Circle = circle, Dot = dot }
	end

	if config.Flag then
		SmallDarkOneLib.Flags[config.Flag] = selected
	end

	local API = {}
	function API:Set(optName) Select(optName) end
	function API:Get() return selected end
	return API
end

-- ButtonGroup (a compact row of side-by-side buttons) -------------------------

function SectionMethods:CreateButtonGroup(config)
	config = config or {}
	local theme = self.Theme
	local buttonsConfig = config.Buttons or {}

	local row = Create("Frame", {
		Name = "ButtonGroup",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 32),
		Parent = self.Body,
	})
	Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = row,
	})

	local count = math.max(#buttonsConfig, 1)
	for _, btnConfig in ipairs(buttonsConfig) do
		local btn = Create("TextButton", {
			Name = btnConfig.Text or "Button",
			BackgroundColor3 = theme.PanelLight,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = UDim2.new(1 / count, -4, 1, 0),
			Font = theme.FontMedium,
			Text = btnConfig.Text or "Button",
			TextColor3 = theme.Text,
			TextSize = 12,
			AutoButtonColor = false,
			Parent = row,
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = btn })
		btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = theme.AccentDark }, 0.15) end)
		btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = theme.PanelLight }, 0.15) end)
		btn.MouseButton1Click:Connect(function()
			Ripple(btn, theme)
			if btnConfig.Callback then
				local ok, err = pcall(btnConfig.Callback)
				if not ok then warn("[SmallDarkOneLib] ButtonGroup callback error: " .. tostring(err)) end
			end
		end)
	end

	return row
end

-- Divider (plain rule, or a labeled section break) ----------------------------

function SectionMethods:CreateDivider(config)
	config = config or {}
	local theme = self.Theme

	local row = Create("Frame", {
		Name = "Divider",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, config.Text and 20 or 10),
		Parent = self.Body,
	})

	if config.Text then
		Create("TextLabel", {
			Name = "Text",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Font = theme.FontMono,
			Text = config.Text,
			TextColor3 = theme.SubText,
			TextSize = 11,
			Parent = row,
		})
	else
		Create("Frame", {
			Name = "Line",
			BackgroundColor3 = theme.Border,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 1),
			Parent = row,
		})
	end

	return row
end

-- ============================================================================
--  CONFIG PERSISTENCE (optional — executor-only, no-ops safely in-game)
-- ============================================================================

function SmallDarkOneLib:SaveConfig(name)
	name = name or "SmallDarkOneLib_Config"
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(SmallDarkOneLib.Flags)
	end)
	if not ok then
		warn("[SmallDarkOneLib] Failed to encode config: " .. tostring(encoded))
		return nil
	end
	if writefile then
		local fileOk, fileErr = pcall(writefile, name .. ".json", encoded)
		if not fileOk then
			warn("[SmallDarkOneLib] writefile failed: " .. tostring(fileErr))
		end
	else
		warn("[SmallDarkOneLib] writefile is unavailable in this environment (normal Roblox game scripts can't write files) — returning the encoded config instead.")
	end
	return encoded
end

function SmallDarkOneLib:LoadConfig(name)
	name = name or "SmallDarkOneLib_Config"
	if not (isfile and readfile) then
		warn("[SmallDarkOneLib] readfile/isfile unavailable in this environment.")
		return nil
	end
	if not isfile(name .. ".json") then
		return nil
	end
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(readfile(name .. ".json"))
	end)
	if not ok then
		warn("[SmallDarkOneLib] Failed to decode config: " .. tostring(decoded))
		return nil
	end
	for k, v in pairs(decoded) do
		SmallDarkOneLib.Flags[k] = v
	end
	return decoded
end

return SmallDarkOneLib
