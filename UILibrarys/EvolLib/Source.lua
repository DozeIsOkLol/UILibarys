--[[
	EvolUI — Minimal UI Library
	By EvolEzod | v1.2.2

	Usage (GitHub):
		local EVOLUI_URL = "https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/EvolLib/Source.lua"
		local EvolUI = loadstring(game:HttpGet(EVOLUI_URL))()
		local UI = EvolUI.Load({
			Name = "My Script",
			Version = "v1.0",
			Badges = { "Dev", "Beta" },
			ToggleKey = Enum.KeyCode.RightShift,
		})
]]

local EvolUI = {}
EvolUI.Version = "1.2.2"

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local PAD = 16
local HEADER_H = 58
local FOOTER_H = 30
local CONTENT_W = 268

local MODIFIER_KEYS = {
	[Enum.KeyCode.LeftShift] = true,
	[Enum.KeyCode.RightShift] = true,
	[Enum.KeyCode.LeftControl] = true,
	[Enum.KeyCode.RightControl] = true,
	[Enum.KeyCode.Insert] = true,
	[Enum.KeyCode.Home] = true,
	[Enum.KeyCode.End] = true,
	[Enum.KeyCode.F1] = true,
	[Enum.KeyCode.F2] = true,
	[Enum.KeyCode.F3] = true,
	[Enum.KeyCode.F4] = true,
	[Enum.KeyCode.F5] = true,
}

local DefaultTheme = {
	Background = Color3.fromRGB(14, 14, 17),
	Surface = Color3.fromRGB(24, 24, 29),
	SurfaceHover = Color3.fromRGB(34, 34, 40),
	Elevated = Color3.fromRGB(30, 30, 36),
	HeaderTop = Color3.fromRGB(18, 18, 22),
	Accent = Color3.fromRGB(130, 114, 245),
	AccentLight = Color3.fromRGB(148, 134, 255),
	AccentDim = Color3.fromRGB(90, 78, 180),
	Text = Color3.fromRGB(242, 242, 246),
	Muted = Color3.fromRGB(118, 118, 130),
	Border = Color3.fromRGB(46, 46, 54),
	Success = Color3.fromRGB(68, 210, 148),
	Danger = Color3.fromRGB(240, 90, 90),
	Warning = Color3.fromRGB(248, 178, 60),
	ActiveRow = Color3.fromRGB(28, 42, 36),
	Info = Color3.fromRGB(96, 165, 250),
}

local BADGE_STYLES = {
	Dev = {
		Background = Color3.fromRGB(46, 36, 22),
		Color = Color3.fromRGB(248, 178, 60),
		Stroke = Color3.fromRGB(248, 178, 60),
	},
	Beta = {
		Background = Color3.fromRGB(30, 28, 50),
		Color = Color3.fromRGB(148, 134, 255),
		Stroke = Color3.fromRGB(130, 114, 245),
	},
	Tester = {
		Background = Color3.fromRGB(24, 42, 36),
		Color = Color3.fromRGB(68, 210, 148),
		Stroke = Color3.fromRGB(68, 210, 148),
	},
	Stable = {
		Background = Color3.fromRGB(26, 30, 26),
		Color = Color3.fromRGB(130, 200, 160),
		Stroke = Color3.fromRGB(72, 180, 120),
	},
	Premium = {
		Background = Color3.fromRGB(42, 30, 50),
		Color = Color3.fromRGB(210, 170, 255),
		Stroke = Color3.fromRGB(180, 130, 245),
	},
}

local FRAME_TRANSPARENCY = 0

local function Tween(obj, props, duration, style, direction)
	return TweenService:Create(
		obj,
		TweenInfo.new(duration or 0.22, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
		props
	)
end

local function TweenPlay(obj, props, duration, style, direction)
	Tween(obj, props, duration, style, direction):Play()
end

local function MergeTheme(overrides)
	local theme = {}
	for key, value in pairs(DefaultTheme) do
		theme[key] = value
	end
	if overrides then
		for key, value in pairs(overrides) do
			theme[key] = value
		end
	end
	return theme
end

local function CreateBadge(parent, badgeConfig, theme, layoutOrder)
	local text, customBg, customColor, customStroke

	if typeof(badgeConfig) == "string" then
		text = badgeConfig
	else
		text = badgeConfig.Text or "Badge"
		customBg = badgeConfig.Background
		customColor = badgeConfig.Color
		customStroke = badgeConfig.Stroke
	end

	local preset = BADGE_STYLES[text] or {}
	local bg = customBg or preset.Background or theme.Surface
	local color = customColor or preset.Color or theme.Muted
	local stroke = customStroke or preset.Stroke or theme.Border

	if not preset.Background and text:match("^v[%d%.]") then
		bg = theme.Elevated
		color = theme.Muted
		stroke = theme.Border
	end

	local badge = Instance.new("TextLabel", parent)
	badge.Size = UDim2.new(0, 0, 0, 20)
	badge.AutomaticSize = Enum.AutomaticSize.X
	badge.BackgroundColor3 = bg
	badge.BackgroundTransparency = 0
	badge.Text = text
	badge.TextColor3 = color
	badge.Font = Enum.Font.GothamBold
	badge.TextSize = 9
	badge.LayoutOrder = layoutOrder

	Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)

	local strokeObj = Instance.new("UIStroke", badge)
	strokeObj.Color = stroke
	strokeObj.Thickness = 1
	strokeObj.Transparency = 0.55

	local pad = Instance.new("UIPadding", badge)
	pad.PaddingLeft = UDim.new(0, 7)
	pad.PaddingRight = UDim.new(0, 7)

	return badge
end

function EvolUI.Load(config)
	config = config or {}

	local Theme = MergeTheme(config.Theme)
	local width = config.Width or (CONTENT_W + PAD * 2)
	local height = config.Height or 452
	local collapsed = false
	local visible = true
	local order = 0
	local toggleActionName = "EvolUI_Toggle_" .. tostring(tick()):gsub("%.", "")

	local function nextOrder()
		order += 1
		return order
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = config.GuiName or "EvolUI_" .. (config.Name or "Window")
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.IgnoreGuiInset = true
	pcall(function() ScreenGui.Parent = CoreGui end)
	if not ScreenGui.Parent then
		ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "Main"
	MainFrame.Size = UDim2.new(0, width, 0, height)
	MainFrame.Position = config.Position or UDim2.new(0.5, -width / 2, 0.5, -height / 2)
	MainFrame.BackgroundColor3 = Theme.Background
	MainFrame.BackgroundTransparency = FRAME_TRANSPARENCY
	MainFrame.Active = true
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui

	local WindowScale = Instance.new("UIScale", MainFrame)
	WindowScale.Scale = 1

	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

	local MainStroke = Instance.new("UIStroke", MainFrame)
	MainStroke.Color = Theme.Border
	MainStroke.Thickness = 1
	MainStroke.Transparency = 0.2

	local HeaderBg = Instance.new("Frame", MainFrame)
	HeaderBg.Size = UDim2.new(1, 0, 0, HEADER_H)
	HeaderBg.BackgroundColor3 = Theme.HeaderTop
	HeaderBg.BackgroundTransparency = 0
	HeaderBg.BorderSizePixel = 0
	HeaderBg.ZIndex = 1

	local HeaderGradient = Instance.new("UIGradient", HeaderBg)
	HeaderGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.HeaderTop),
		ColorSequenceKeypoint.new(1, Theme.Background),
	})
	HeaderGradient.Rotation = 90

	local HeaderFrame = Instance.new("Frame", HeaderBg)
	HeaderFrame.Size = UDim2.new(1, -(PAD * 2), 1, 0)
	HeaderFrame.Position = UDim2.new(0, PAD, 0, 0)
	HeaderFrame.BackgroundTransparency = 1
	HeaderFrame.ZIndex = 2

	local TitleDot = Instance.new("Frame", HeaderFrame)
	TitleDot.Size = UDim2.new(0, 6, 0, 6)
	TitleDot.Position = UDim2.new(0, 0, 0, 15)
	TitleDot.BackgroundColor3 = Theme.Accent
	TitleDot.BackgroundTransparency = 0.15
	TitleDot.BorderSizePixel = 0
	Instance.new("UICorner", TitleDot).CornerRadius = UDim.new(1, 0)

	local Title = Instance.new("TextLabel", HeaderFrame)
	Title.Size = UDim2.new(0.58, 0, 0, 20)
	Title.Position = UDim2.new(0, 10, 0, 8)
	Title.BackgroundTransparency = 1
	Title.Text = config.Name or "EvolUI"
	Title.TextColor3 = Theme.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local TitleUnderline = Instance.new("Frame", HeaderFrame)
	TitleUnderline.Size = UDim2.new(0, 0, 0, 2)
	TitleUnderline.Position = UDim2.new(0, 10, 0, 28)
	TitleUnderline.BackgroundColor3 = Theme.Accent
	TitleUnderline.BackgroundTransparency = 0.55
	TitleUnderline.BorderSizePixel = 0
	Instance.new("UICorner", TitleUnderline).CornerRadius = UDim.new(1, 0)

	TweenPlay(TitleUnderline, { Size = UDim2.new(0, 46, 0, 2) }, 0.5, Enum.EasingStyle.Quint)

	local Subtitle = Instance.new("TextLabel", HeaderFrame)
	Subtitle.Size = UDim2.new(0.58, 0, 0, 14)
	Subtitle.Position = UDim2.new(0, 10, 0, 34)
	Subtitle.BackgroundTransparency = 1
	Subtitle.Text = config.Subtitle or ""
	Subtitle.TextColor3 = Theme.Muted
	Subtitle.Font = Enum.Font.Gotham
	Subtitle.TextSize = 11
	Subtitle.TextXAlignment = Enum.TextXAlignment.Left

	local HeaderControls = Instance.new("Frame", HeaderFrame)
	HeaderControls.AnchorPoint = Vector2.new(1, 0.5)
	HeaderControls.Position = UDim2.new(1, 0, 0.5, 0)
	HeaderControls.Size = UDim2.new(0, 0, 0, 24)
	HeaderControls.AutomaticSize = Enum.AutomaticSize.X
	HeaderControls.BackgroundTransparency = 1

	local controlsLayout = Instance.new("UIListLayout", HeaderControls)
	controlsLayout.FillDirection = Enum.FillDirection.Horizontal
	controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	controlsLayout.Padding = UDim.new(0, 4)
	controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local badgeOrder = 0
	local function nextBadgeOrder()
		badgeOrder += 1
		return badgeOrder
	end

	local CollapseBtn
	if config.Collapsible ~= false then
		CollapseBtn = Instance.new("TextButton", HeaderControls)
		CollapseBtn.Size = UDim2.new(0, 24, 0, 24)
		CollapseBtn.BackgroundColor3 = Theme.Surface
		CollapseBtn.BackgroundTransparency = 0
		CollapseBtn.Text = "−"
		CollapseBtn.TextColor3 = Theme.Muted
		CollapseBtn.Font = Enum.Font.GothamBold
		CollapseBtn.TextSize = 14
		CollapseBtn.AutoButtonColor = false
		CollapseBtn.LayoutOrder = nextBadgeOrder()
		Instance.new("UICorner", CollapseBtn).CornerRadius = UDim.new(0, 6)

		CollapseBtn.MouseEnter:Connect(function()
			TweenPlay(CollapseBtn, { BackgroundColor3 = Theme.SurfaceHover, TextColor3 = Theme.Text })
		end)
		CollapseBtn.MouseLeave:Connect(function()
			TweenPlay(CollapseBtn, { BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Muted })
		end)
	end

	if config.Version then
		CreateBadge(HeaderControls, config.Version, Theme, nextBadgeOrder())
	end

	for _, badge in ipairs(config.Badges or {}) do
		CreateBadge(HeaderControls, badge, Theme, nextBadgeOrder())
	end

	local HeaderDivider = Instance.new("Frame", MainFrame)
	HeaderDivider.Size = UDim2.new(1, -(PAD * 2), 0, 1)
	HeaderDivider.Position = UDim2.new(0, PAD, 0, HEADER_H)
	HeaderDivider.BackgroundColor3 = Theme.Border
	HeaderDivider.BackgroundTransparency = 0.5
	HeaderDivider.BorderSizePixel = 0
	HeaderDivider.ZIndex = 2

	local ScrollTop = HEADER_H + 6
	local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
	ScrollFrame.Name = "Content"
	ScrollFrame.Size = UDim2.new(1, 0, 1, -(ScrollTop + FOOTER_H))
	ScrollFrame.Position = UDim2.new(0, 0, 0, ScrollTop)
	ScrollFrame.BackgroundTransparency = 1
	ScrollFrame.BorderSizePixel = 0
	ScrollFrame.ScrollBarThickness = 3
	ScrollFrame.ScrollBarImageColor3 = Theme.AccentDim
	ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollFrame.ZIndex = 2

	local ListLayout = Instance.new("UIListLayout", ScrollFrame)
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.Padding = UDim.new(0, 8)
	ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local ScrollPadding = Instance.new("UIPadding", ScrollFrame)
	ScrollPadding.PaddingTop = UDim.new(0, 6)
	ScrollPadding.PaddingBottom = UDim.new(0, 10)
	ScrollPadding.PaddingLeft = UDim.new(0, PAD)
	ScrollPadding.PaddingRight = UDim.new(0, PAD)

	local FooterDivider = Instance.new("Frame", MainFrame)
	FooterDivider.Size = UDim2.new(1, -(PAD * 2), 0, 1)
	FooterDivider.Position = UDim2.new(0, PAD, 1, -FOOTER_H)
	FooterDivider.BackgroundColor3 = Theme.Border
	FooterDivider.BackgroundTransparency = 0.5
	FooterDivider.BorderSizePixel = 0
	FooterDivider.ZIndex = 2

	local Footer = Instance.new("TextLabel", MainFrame)
	Footer.Size = UDim2.new(1, 0, 0, FOOTER_H)
	Footer.Position = UDim2.new(0, 0, 1, -FOOTER_H)
	Footer.BackgroundTransparency = 1
	Footer.Text = config.Footer or ""
	Footer.TextColor3 = Theme.Muted
	Footer.Font = Enum.Font.Gotham
	Footer.TextSize = 10
	Footer.TextTransparency = 0.1
	Footer.ZIndex = 2

	local NotifyHolder = Instance.new("Frame", MainFrame)
	NotifyHolder.Name = "Notifications"
	NotifyHolder.AnchorPoint = Vector2.new(0.5, 1)
	NotifyHolder.Position = UDim2.new(0.5, 0, 1, -(FOOTER_H + 8))
	NotifyHolder.Size = UDim2.new(1, -24, 0, 0)
	NotifyHolder.AutomaticSize = Enum.AutomaticSize.Y
	NotifyHolder.BackgroundTransparency = 1
	NotifyHolder.ZIndex = 50

	local NotifyLayout = Instance.new("UIListLayout", NotifyHolder)
	NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotifyLayout.Padding = UDim.new(0, 6)
	NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

	local fullHeight = height
	local dragging, dragStart, startPos
	local lastToggle = 0
	local toggleLocked = false

	local function bindDrag(frame)
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = MainFrame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
	end

	bindDrag(HeaderFrame)
	bindDrag(HeaderBg)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	local UI = {
		Theme = Theme,
		ScreenGui = ScreenGui,
		Main = MainFrame,
		Content = ScrollFrame,
		Title = Title,
		Subtitle = Subtitle,
		Footer = Footer,
		HeaderControls = HeaderControls,
	}

	local function animateVisibility(show)
		if show then
			visible = true
			MainFrame.Visible = true
			WindowScale.Scale = 0.94
			MainFrame.BackgroundTransparency = 1
			TweenPlay(WindowScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Quint)
			TweenPlay(MainFrame, { BackgroundTransparency = FRAME_TRANSPARENCY }, 0.3, Enum.EasingStyle.Quint)
		else
			visible = false
			TweenPlay(WindowScale, { Scale = 0.94 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			TweenPlay(MainFrame, { BackgroundTransparency = 1 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			task.delay(0.22, function()
				if not visible then
					MainFrame.Visible = false
					WindowScale.Scale = 1
				end
			end)
		end
	end

	function UI:SetTheme(overrides)
		Theme = MergeTheme(overrides)
		UI.Theme = Theme
	end

	function UI:Show()
		animateVisibility(true)
	end

	function UI:Hide()
		animateVisibility(false)
	end

	function UI:Toggle()
		animateVisibility(not visible)
	end

	function UI:Destroy()
		pcall(function() ContextActionService:UnbindAction(toggleActionName) end)
		ScreenGui:Destroy()
	end

	function UI:AddBadge(badgeConfig)
		badgeOrder += 1
		return CreateBadge(HeaderControls, badgeConfig, Theme, badgeOrder)
	end

	local toggleKey = config.ToggleKey
	if toggleKey then
		local function handleToggle()
			if toggleLocked then return end
			local now = tick()
			if now - lastToggle < 0.2 then return end
			lastToggle = now
			toggleLocked = true
			UI:Toggle()
			task.delay(0.2, function()
				toggleLocked = false
			end)
		end

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
			if input.KeyCode ~= toggleKey then return end
			if gameProcessed and not MODIFIER_KEYS[input.KeyCode] then return end
			handleToggle()
		end)

		pcall(function()
			ContextActionService:BindAction(toggleActionName, function(_, state)
				if state == Enum.UserInputState.Begin then
					handleToggle()
				end
				return Enum.ContextActionResult.Sink
			end, false, toggleKey)
		end)
	end

	-- Open animation
	MainFrame.BackgroundTransparency = 1
	WindowScale.Scale = 0.94
	task.defer(function()
		TweenPlay(WindowScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Quint)
		TweenPlay(MainFrame, { BackgroundTransparency = FRAME_TRANSPARENCY }, 0.35, Enum.EasingStyle.Quint)
	end)

	-- Title dot pulse
	task.spawn(function()
		while TitleDot.Parent do
			TweenPlay(TitleDot, { BackgroundTransparency = 0 }, 1.4, Enum.EasingStyle.Sine)
			task.wait(1.4)
			TweenPlay(TitleDot, { BackgroundTransparency = 0.35 }, 1.4, Enum.EasingStyle.Sine)
			task.wait(1.4)
		end
	end)

	function UI:Spacer(spacerHeight)
		local spacer = Instance.new("Frame", ScrollFrame)
		spacer.Size = UDim2.new(1, 0, 0, spacerHeight or 10)
		spacer.BackgroundTransparency = 1
		spacer.LayoutOrder = nextOrder()
		return spacer
	end

	function UI:Section(text)
		local holder = Instance.new("Frame", ScrollFrame)
		holder.Size = UDim2.new(1, 0, 0, 22)
		holder.BackgroundTransparency = 1
		holder.LayoutOrder = nextOrder()

		local accent = Instance.new("Frame", holder)
		accent.Size = UDim2.new(0, 2, 0, 10)
		accent.Position = UDim2.new(0, 0, 1, -12)
		accent.BackgroundColor3 = Theme.Border
		accent.BackgroundTransparency = 0.3
		accent.BorderSizePixel = 0
		Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

		local label = Instance.new("TextLabel", holder)
		label.Size = UDim2.new(1, -8, 1, 0)
		label.Position = UDim2.new(0, 8, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = string.upper(text or "")
		label.TextColor3 = Theme.Muted
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 10
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Bottom

		return label
	end

	function UI:Divider()
		local line = Instance.new("Frame", ScrollFrame)
		line.Size = UDim2.new(1, 0, 0, 1)
		line.BackgroundColor3 = Theme.Border
		line.BackgroundTransparency = 0.45
		line.BorderSizePixel = 0
		line.LayoutOrder = nextOrder()
		return line
	end

	function UI:Label(text, muted)
		local label = Instance.new("TextLabel", ScrollFrame)
		label.Size = UDim2.new(1, 0, 0, 18)
		label.BackgroundTransparency = 1
		label.Text = text or ""
		label.TextColor3 = muted and Theme.Muted or Theme.Text
		label.Font = Enum.Font.Gotham
		label.TextSize = 11
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextWrapped = true
		label.LayoutOrder = nextOrder()
		return label
	end

	function UI:SetButtonColor(button, color)
		if button and button:IsA("TextButton") then
			TweenPlay(button, { BackgroundColor3 = color })
		end
	end

	function UI:TweenButton(button, color)
		UI:SetButtonColor(button, color)
	end

	local function bindButtonPress(btn)
		local scale = Instance.new("UIScale", btn)
		btn.MouseButton1Down:Connect(function()
			TweenPlay(scale, { Scale = 0.96 }, 0.1, Enum.EasingStyle.Quint)
		end)
		local function release()
			TweenPlay(scale, { Scale = 1 }, 0.15, Enum.EasingStyle.Quint)
		end
		btn.MouseButton1Up:Connect(release)
		btn.MouseLeave:Connect(release)
	end

	function UI:Button(options)
		options = options or {}
		local style = options.Style or "Secondary"
		local btnHeight = options.Height or (style == "Primary" and 40 or 38)
		local isPrimary = style == "Primary"

		local btn = Instance.new("TextButton", ScrollFrame)
		btn.Size = UDim2.new(1, 0, 0, btnHeight)
		btn.BackgroundColor3 = isPrimary and Theme.Accent or Theme.Surface
		btn.Text = options.Text or "Button"
		btn.TextColor3 = isPrimary and Color3.fromRGB(255, 255, 255) or Theme.Text
		btn.Font = isPrimary and Enum.Font.GothamBold or Enum.Font.GothamMedium
		btn.TextSize = 12
		btn.LayoutOrder = nextOrder()
		btn.AutoButtonColor = false
		btn.TextYAlignment = Enum.TextYAlignment.Center
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

		local btnStroke
		if isPrimary then
			btnStroke = Instance.new("UIStroke", btn)
			btnStroke.Color = Theme.AccentLight
			btnStroke.Thickness = 1
			btnStroke.Transparency = 0.45
		else
			btnStroke = Instance.new("UIStroke", btn)
			btnStroke.Color = Theme.Border
			btnStroke.Thickness = 1
			btnStroke.Transparency = 0.55
		end

		local defaultColor = btn.BackgroundColor3
		btn.MouseEnter:Connect(function()
			if isPrimary then
				TweenPlay(btn, { BackgroundColor3 = Theme.AccentLight })
				TweenPlay(btnStroke, { Transparency = 0.2 })
			elseif btn.BackgroundColor3 == Theme.Surface then
				TweenPlay(btn, { BackgroundColor3 = Theme.SurfaceHover })
				TweenPlay(btnStroke, { Transparency = 0.35 })
			end
		end)
		btn.MouseLeave:Connect(function()
			if isPrimary then
				if btn.BackgroundColor3 ~= Theme.Success and btn.BackgroundColor3 ~= Theme.Warning and btn.BackgroundColor3 ~= Theme.Danger then
					TweenPlay(btn, { BackgroundColor3 = defaultColor })
					TweenPlay(btnStroke, { Transparency = 0.45 })
				end
			elseif btn.BackgroundColor3 == Theme.SurfaceHover then
				TweenPlay(btn, { BackgroundColor3 = Theme.Surface })
				TweenPlay(btnStroke, { Transparency = 0.55 })
			end
		end)

		bindButtonPress(btn)

		if options.Callback then
			btn.MouseButton1Click:Connect(options.Callback)
		end

		return btn
	end

	local function setSwitchVisual(track, knob, isOn, animate)
		local onColor = Color3.fromRGB(48, 72, 58)
		local offColor = Theme.Elevated
		local knobOn = UDim2.new(1, -21, 0.5, -9)
		local knobOff = UDim2.new(0, 3, 0.5, -9)

		if animate then
			TweenPlay(track, { BackgroundColor3 = isOn and onColor or offColor }, 0.2, Enum.EasingStyle.Quint)
			TweenPlay(knob, { Position = isOn and knobOn or knobOff, BackgroundColor3 = isOn and Theme.Success or Theme.Muted }, 0.22, Enum.EasingStyle.Quint)
		else
			track.BackgroundColor3 = isOn and onColor or offColor
			knob.Position = isOn and knobOn or knobOff
			knob.BackgroundColor3 = isOn and Theme.Success or Theme.Muted
		end
	end

	function UI:Toggle(options)
		options = options or {}
		local state = options.Default or false

		local row = Instance.new("Frame", ScrollFrame)
		row.Size = UDim2.new(1, 0, 0, 42)
		row.BackgroundColor3 = Theme.Surface
		row.LayoutOrder = nextOrder()
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

		local label = Instance.new("TextLabel", row)
		label.Size = UDim2.new(1, -68, 1, 0)
		label.Position = UDim2.new(0, 14, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = options.Text or "Toggle"
		label.TextColor3 = Theme.Text
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center

		local track = Instance.new("Frame", row)
		track.AnchorPoint = Vector2.new(1, 0.5)
		track.Size = UDim2.new(0, 46, 0, 22)
		track.Position = UDim2.new(1, -12, 0.5, 0)
		track.BackgroundColor3 = Theme.Elevated
		track.BorderSizePixel = 0
		Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

		local knob = Instance.new("Frame", track)
		knob.Size = UDim2.new(0, 18, 0, 18)
		knob.Position = UDim2.new(0, 3, 0.5, -9)
		knob.BackgroundColor3 = Theme.Muted
		knob.BorderSizePixel = 0
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

		local hitbox = Instance.new("TextButton", row)
		hitbox.Size = UDim2.new(1, 0, 1, 0)
		hitbox.BackgroundTransparency = 1
		hitbox.Text = ""
		hitbox.ZIndex = 2

		local function getRowColor()
			if options.GetActiveColor then
				return options.GetActiveColor(state)
			end
			return state and Theme.ActiveRow or Theme.Surface
		end

		local function refresh(animate)
			setSwitchVisual(track, knob, state, animate ~= false)
			TweenPlay(row, { BackgroundColor3 = getRowColor() }, 0.2, Enum.EasingStyle.Quint)
		end

		hitbox.MouseEnter:Connect(function()
			TweenPlay(row, { BackgroundColor3 = Theme.SurfaceHover }, 0.15, Enum.EasingStyle.Quint)
		end)
		hitbox.MouseLeave:Connect(function()
			TweenPlay(row, { BackgroundColor3 = getRowColor() }, 0.15, Enum.EasingStyle.Quint)
		end)

		hitbox.MouseButton1Click:Connect(function()
			state = not state
			refresh(true)
			if options.Callback then
				options.Callback(state)
			end
		end)

		refresh(false)

		return {
			Row = row,
			Track = track,
			Knob = knob,
			Hitbox = hitbox,
			Get = function()
				return state
			end,
			Set = function(value)
				state = value and true or false
				refresh(true)
			end,
			SetError = function(text, duration)
				TweenPlay(track, { BackgroundColor3 = Color3.fromRGB(58, 32, 32) }, 0.15)
				TweenPlay(knob, { BackgroundColor3 = Theme.Danger }, 0.15)
				task.delay(duration or 1.2, function()
					refresh(true)
				end)
			end,
			Refresh = refresh,
		}
	end

	function UI:ValueRow(options)
		options = options or {}

		local row = Instance.new("Frame", ScrollFrame)
		row.Size = UDim2.new(1, 0, 0, 42)
		row.BackgroundColor3 = Theme.Surface
		row.LayoutOrder = nextOrder()
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

		local titleLabel = Instance.new("TextLabel", row)
		titleLabel.Size = UDim2.new(1, -80, 0, 16)
		titleLabel.Position = UDim2.new(0, 14, 0, 7)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = options.Title or "Value"
		titleLabel.TextColor3 = Theme.Text
		titleLabel.Font = Enum.Font.GothamMedium
		titleLabel.TextSize = 12
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left

		local hintLabel = Instance.new("TextLabel", row)
		hintLabel.Size = UDim2.new(1, -80, 0, 12)
		hintLabel.Position = UDim2.new(0, 14, 0, 23)
		hintLabel.BackgroundTransparency = 1
		hintLabel.Text = options.Hint or ""
		hintLabel.TextColor3 = Theme.Muted
		hintLabel.Font = Enum.Font.Gotham
		hintLabel.TextSize = 10
		hintLabel.TextXAlignment = Enum.TextXAlignment.Left

		local valueLabel = Instance.new("TextLabel", row)
		valueLabel.AnchorPoint = Vector2.new(1, 0.5)
		valueLabel.Size = UDim2.new(0, 52, 0, 26)
		valueLabel.Position = UDim2.new(1, -12, 0.5, 0)
		valueLabel.BackgroundColor3 = Theme.Elevated
		valueLabel.Text = tostring(options.Value or 0)
		valueLabel.TextColor3 = Theme.Accent
		valueLabel.Font = Enum.Font.GothamBold
		valueLabel.TextSize = 13
		valueLabel.TextYAlignment = Enum.TextYAlignment.Center
		Instance.new("UICorner", valueLabel).CornerRadius = UDim.new(0, 8)

		local valueScale = Instance.new("UIScale", valueLabel)

		local hitbox = Instance.new("TextButton", row)
		hitbox.Size = UDim2.new(1, 0, 1, 0)
		hitbox.BackgroundTransparency = 1
		hitbox.Text = ""
		hitbox.ZIndex = 2

		hitbox.MouseEnter:Connect(function()
			TweenPlay(row, { BackgroundColor3 = Theme.SurfaceHover }, 0.15, Enum.EasingStyle.Quint)
		end)
		hitbox.MouseLeave:Connect(function()
			TweenPlay(row, { BackgroundColor3 = Theme.Surface }, 0.15, Enum.EasingStyle.Quint)
		end)

		if options.OnClick then
			hitbox.MouseButton1Click:Connect(function()
				local newValue = options.OnClick(tonumber(valueLabel.Text) or options.Value or 0)
				if newValue ~= nil then
					valueLabel.Text = tostring(newValue)
					TweenPlay(valueScale, { Scale = 1.12 }, 0.1, Enum.EasingStyle.Quint)
					task.delay(0.1, function()
						TweenPlay(valueScale, { Scale = 1 }, 0.15, Enum.EasingStyle.Quint)
					end)
				end
			end)
		end

		return {
			Row = row,
			ValueLabel = valueLabel,
			SetValue = function(value)
				valueLabel.Text = tostring(value)
			end,
			GetValue = function()
				return tonumber(valueLabel.Text) or 0
			end,
		}
	end

	function UI:Input(options)
		options = options or {}

		local holder = Instance.new("Frame", ScrollFrame)
		holder.Size = UDim2.new(1, 0, 0, 40)
		holder.BackgroundColor3 = Theme.Surface
		holder.LayoutOrder = nextOrder()
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)

		local box = Instance.new("TextBox", holder)
		box.Size = UDim2.new(1, -24, 1, -12)
		box.Position = UDim2.new(0, 12, 0, 6)
		box.BackgroundTransparency = 1
		box.Text = ""
		box.PlaceholderText = options.Placeholder or "Enter text..."
		box.PlaceholderColor3 = Theme.Muted
		box.TextColor3 = Theme.Text
		box.Font = Enum.Font.Gotham
		box.TextSize = 12
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.ClearTextOnFocus = false

		box.Focused:Connect(function()
			TweenPlay(holder, { BackgroundColor3 = Theme.SurfaceHover }, 0.15, Enum.EasingStyle.Quint)
		end)
		box.FocusLost:Connect(function()
			TweenPlay(holder, { BackgroundColor3 = Theme.Surface }, 0.15, Enum.EasingStyle.Quint)
			if options.Callback then
				options.Callback(box.Text)
			end
		end)

		return box
	end

	function UI:Slider(options)
		options = options or {}
		local min = options.Min or 0
		local max = options.Max or 100
		local step = options.Step or 1
		local value = options.Default or min

		local holder = Instance.new("Frame", ScrollFrame)
		holder.Size = UDim2.new(1, 0, 0, 52)
		holder.BackgroundColor3 = Theme.Surface
		holder.LayoutOrder = nextOrder()
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)

		local label = Instance.new("TextLabel", holder)
		label.Size = UDim2.new(1, -60, 0, 18)
		label.Position = UDim2.new(0, 14, 0, 8)
		label.BackgroundTransparency = 1
		label.Text = options.Text or "Slider"
		label.TextColor3 = Theme.Text
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left

		local valueLabel = Instance.new("TextLabel", holder)
		valueLabel.AnchorPoint = Vector2.new(1, 0)
		valueLabel.Size = UDim2.new(0, 40, 0, 18)
		valueLabel.Position = UDim2.new(1, -12, 0, 8)
		valueLabel.BackgroundTransparency = 1
		valueLabel.Text = tostring(value)
		valueLabel.TextColor3 = Theme.Accent
		valueLabel.Font = Enum.Font.GothamBold
		valueLabel.TextSize = 12

		local track = Instance.new("Frame", holder)
		track.Size = UDim2.new(1, -28, 0, 6)
		track.Position = UDim2.new(0, 14, 0, 34)
		track.BackgroundColor3 = Theme.Elevated
		track.BorderSizePixel = 0
		Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

		local fill = Instance.new("Frame", track)
		fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = Theme.Accent
		fill.BorderSizePixel = 0
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

		local knob = Instance.new("TextButton", track)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.Size = UDim2.new(0, 14, 0, 14)
		knob.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
		knob.BackgroundColor3 = Theme.Text
		knob.Text = ""
		knob.AutoButtonColor = false
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

		local function setValue(newValue, fire)
			value = math.clamp(math.floor((newValue - min) / step + 0.5) * step + min, min, max)
			local alpha = (value - min) / (max - min)
			TweenPlay(fill, { Size = UDim2.new(alpha, 0, 1, 0) }, 0.12, Enum.EasingStyle.Quint)
			TweenPlay(knob, { Position = UDim2.new(alpha, 0, 0.5, 0) }, 0.12, Enum.EasingStyle.Quint)
			valueLabel.Text = tostring(value)
			if fire and options.Callback then
				options.Callback(value)
			end
		end

		local sliding = false
		knob.MouseButton1Down:Connect(function() sliding = true end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				sliding = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
				local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				setValue(min + (max - min) * rel, true)
			end
		end)
		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				setValue(min + (max - min) * rel, true)
			end
		end)

		return {
			Set = function(newValue, fire)
				setValue(newValue, fire)
			end,
			Get = function()
				return value
			end,
		}
	end

	function UI:Dropdown(options)
		options = options or {}
		local open = false
		local selected = options.Default or (options.Options and options.Options[1]) or ""
		local optionList = options.Options or {}
		local optionCount = #optionList

		local holder = Instance.new("Frame", ScrollFrame)
		holder.Size = UDim2.new(1, 0, 0, 40)
		holder.BackgroundColor3 = Theme.Surface
		holder.LayoutOrder = nextOrder()
		holder.ClipsDescendants = true
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)

		local topRow = Instance.new("Frame", holder)
		topRow.Size = UDim2.new(1, 0, 0, 40)
		topRow.BackgroundTransparency = 1
		topRow.ZIndex = 2

		local label = Instance.new("TextLabel", topRow)
		label.Size = UDim2.new(0.45, 0, 1, 0)
		label.Position = UDim2.new(0, 14, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = options.Text or "Select"
		label.TextColor3 = Theme.Text
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center

		local display = Instance.new("TextButton", topRow)
		display.AnchorPoint = Vector2.new(1, 0.5)
		display.Size = UDim2.new(0, 120, 0, 28)
		display.Position = UDim2.new(1, -12, 0.5, 0)
		display.BackgroundColor3 = Theme.Elevated
		display.Text = tostring(selected) .. "  ▾"
		display.TextColor3 = Theme.Text
		display.Font = Enum.Font.GothamMedium
		display.TextSize = 11
		display.AutoButtonColor = false
		display.ZIndex = 3
		Instance.new("UICorner", display).CornerRadius = UDim.new(0, 8)

		local displayStroke = Instance.new("UIStroke", display)
		displayStroke.Color = Theme.Border
		displayStroke.Thickness = 1
		displayStroke.Transparency = 0.45

		local divider = Instance.new("Frame", holder)
		divider.Size = UDim2.new(1, -16, 0, 1)
		divider.Position = UDim2.new(0, 8, 0, 40)
		divider.BackgroundColor3 = Theme.Border
		divider.BackgroundTransparency = 0.5
		divider.BorderSizePixel = 0
		divider.Visible = false
		divider.ZIndex = 2

		local list = Instance.new("Frame", holder)
		list.Size = UDim2.new(1, -16, 0, 0)
		list.Position = UDim2.new(0, 8, 0, 41)
		list.BackgroundTransparency = 1
		list.Visible = false
		list.ClipsDescendants = true
		list.ZIndex = 2

		local listLayout = Instance.new("UIListLayout", list)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding = UDim.new(0, 4)

		local listPad = Instance.new("UIPadding", list)
		listPad.PaddingTop = UDim.new(0, 4)
		listPad.PaddingBottom = UDim.new(0, 6)

		local function getListHeight()
			if optionCount == 0 then return 0 end
			return optionCount * 32 + (optionCount - 1) * 4 + 10
		end

		local function setOpen(state)
			open = state
			local listHeight = open and getListHeight() or 0
			list.Visible = open and listHeight > 0
			divider.Visible = list.Visible
			display.Text = tostring(selected) .. (open and "  ▴" or "  ▾")
			TweenPlay(list, { Size = UDim2.new(1, -16, 0, listHeight) }, 0.2, Enum.EasingStyle.Quint)
			TweenPlay(holder, { Size = UDim2.new(1, 0, 0, 40 + listHeight) }, 0.2, Enum.EasingStyle.Quint)
		end

		for i, option in ipairs(optionList) do
			local optBtn = Instance.new("TextButton", list)
			optBtn.Size = UDim2.new(1, 0, 0, 32)
			optBtn.BackgroundColor3 = Theme.Elevated
			optBtn.Text = tostring(option)
			optBtn.TextColor3 = Theme.Text
			optBtn.Font = Enum.Font.GothamMedium
			optBtn.TextSize = 11
			optBtn.AutoButtonColor = false
			optBtn.LayoutOrder = i
			Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 8)

			local optStroke = Instance.new("UIStroke", optBtn)
			optStroke.Color = Theme.Border
			optStroke.Thickness = 1
			optStroke.Transparency = 0.55

			optBtn.MouseEnter:Connect(function()
				TweenPlay(optBtn, { BackgroundColor3 = Theme.SurfaceHover })
				TweenPlay(optStroke, { Color = Theme.Accent, Transparency = 0.25 })
			end)
			optBtn.MouseLeave:Connect(function()
				TweenPlay(optBtn, { BackgroundColor3 = Theme.Elevated })
				TweenPlay(optStroke, { Color = Theme.Border, Transparency = 0.55 })
			end)
			optBtn.MouseButton1Click:Connect(function()
				selected = option
				display.Text = tostring(selected) .. "  ▾"
				setOpen(false)
				if options.Callback then
					options.Callback(selected)
				end
			end)
		end

		display.MouseEnter:Connect(function()
			TweenPlay(display, { BackgroundColor3 = Theme.SurfaceHover })
		end)
		display.MouseLeave:Connect(function()
			TweenPlay(display, { BackgroundColor3 = Theme.Elevated })
		end)
		display.MouseButton1Click:Connect(function()
			if optionCount == 0 then return end
			setOpen(not open)
		end)

		return {
			Get = function()
				return selected
			end,
			Set = function(value)
				selected = value
				display.Text = tostring(selected) .. (open and "  ▴" or "  ▾")
			end,
			Close = function()
				setOpen(false)
			end,
		}
	end

	function UI:Grid(options)
		options = options or {}
		local cellW = options.CellW or 130
		local cellH = options.CellH or 30
		local padding = options.Padding or 8

		local gridFrame = Instance.new("Frame", ScrollFrame)
		gridFrame.Size = UDim2.new(1, 0, 0, 0)
		gridFrame.AutomaticSize = Enum.AutomaticSize.Y
		gridFrame.BackgroundTransparency = 1
		gridFrame.LayoutOrder = nextOrder()

		local grid = Instance.new("UIGridLayout", gridFrame)
		grid.CellSize = UDim2.new(0, cellW, 0, cellH)
		grid.CellPadding = UDim2.new(0, padding, 0, padding)
		grid.FillDirectionMaxCells = options.Columns or 2
		grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
		grid.SortOrder = Enum.SortOrder.LayoutOrder

		local gridApi = {}

		function gridApi:Button(text, callback)
			local pBtn = Instance.new("TextButton", gridFrame)
			pBtn.BackgroundColor3 = Theme.Surface
			pBtn.Text = text
			pBtn.TextColor3 = Theme.Muted
			pBtn.Font = Enum.Font.GothamMedium
			pBtn.TextSize = 11
			pBtn.AutoButtonColor = false
			pBtn.TextYAlignment = Enum.TextYAlignment.Center
			Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 8)

			local stroke = Instance.new("UIStroke", pBtn)
			stroke.Color = Theme.Border
			stroke.Thickness = 1
			stroke.Transparency = 0.4

			local btnScale = Instance.new("UIScale", pBtn)

			pBtn.MouseEnter:Connect(function()
				TweenPlay(pBtn, { BackgroundColor3 = Theme.SurfaceHover, TextColor3 = Theme.Text })
				TweenPlay(stroke, { Color = Theme.Accent, Transparency = 0.15 })
			end)
			pBtn.MouseLeave:Connect(function()
				TweenPlay(pBtn, { BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Muted })
				TweenPlay(stroke, { Color = Theme.Border, Transparency = 0.4 })
			end)

			pBtn.MouseButton1Down:Connect(function()
				TweenPlay(btnScale, { Scale = 0.95 }, 0.08, Enum.EasingStyle.Quint)
			end)
			pBtn.MouseButton1Up:Connect(function()
				TweenPlay(btnScale, { Scale = 1 }, 0.12, Enum.EasingStyle.Quint)
			end)

			if callback then
				pBtn.MouseButton1Click:Connect(function()
					callback()
					TweenPlay(pBtn, { BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text })
					TweenPlay(stroke, { Color = Theme.Accent, Transparency = 0 })
					task.delay(0.35, function()
						TweenPlay(pBtn, { BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Muted })
						TweenPlay(stroke, { Color = Theme.Border, Transparency = 0.4 })
					end)
				end)
			end

			return pBtn
		end

		return gridApi
	end

	function UI:Progress(options)
		options = options or {}
		local value = math.clamp(options.Value or 0, 0, 1)

		local holder = Instance.new("Frame", ScrollFrame)
		holder.Size = UDim2.new(1, 0, 0, 34)
		holder.BackgroundTransparency = 1
		holder.LayoutOrder = nextOrder()

		local label = Instance.new("TextLabel", holder)
		label.Size = UDim2.new(1, 0, 0, 14)
		label.BackgroundTransparency = 1
		label.Text = options.Text or "Progress"
		label.TextColor3 = Theme.Muted
		label.Font = Enum.Font.Gotham
		label.TextSize = 10
		label.TextXAlignment = Enum.TextXAlignment.Left

		local track = Instance.new("Frame", holder)
		track.Size = UDim2.new(1, 0, 0, 6)
		track.Position = UDim2.new(0, 0, 0, 20)
		track.BackgroundColor3 = Theme.Elevated
		track.BorderSizePixel = 0
		Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

		local fill = Instance.new("Frame", track)
		fill.Size = UDim2.new(value, 0, 1, 0)
		fill.BackgroundColor3 = Theme.Accent
		fill.BorderSizePixel = 0
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

		return {
			Set = function(newValue)
				value = math.clamp(newValue, 0, 1)
				TweenPlay(fill, { Size = UDim2.new(value, 0, 1, 0) }, 0.25, Enum.EasingStyle.Quint)
			end,
		}
	end

	function UI:Notify(options)
		options = options or {}
		local notifyType = options.Type or "Info"
		local duration = options.Duration or 3

		local palette = {
			Success = { accent = Theme.Success, bg = Color3.fromRGB(22, 36, 30), icon = "✓", title = "Success" },
			Error = { accent = Theme.Danger, bg = Color3.fromRGB(38, 22, 24), icon = "✕", title = "Error" },
			Warning = { accent = Theme.Warning, bg = Color3.fromRGB(38, 32, 20), icon = "!", title = "Warning" },
			Info = { accent = Theme.Info, bg = Color3.fromRGB(22, 28, 38), icon = "i", title = "Info" },
		}
		local style = palette[notifyType] or palette.Info
		local titleText = options.Title or style.title
		local bodyText = options.Text or options.Description or "Notification"

		local toast = Instance.new("Frame", NotifyHolder)
		toast.Size = UDim2.new(1, 0, 0, 0)
		toast.AutomaticSize = Enum.AutomaticSize.Y
		toast.BackgroundColor3 = style.bg
		toast.BackgroundTransparency = 1
		toast.LayoutOrder = math.floor(tick() * 1000)
		Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 10)

		local toastStroke = Instance.new("UIStroke", toast)
		toastStroke.Color = style.accent
		toastStroke.Thickness = 1
		toastStroke.Transparency = 0.55

		local accent = Instance.new("Frame", toast)
		accent.Size = UDim2.new(0, 4, 1, -8)
		accent.Position = UDim2.new(0, 0, 0, 4)
		accent.BackgroundColor3 = style.accent
		accent.BorderSizePixel = 0
		Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

		local icon = Instance.new("TextLabel", toast)
		icon.Size = UDim2.new(0, 22, 0, 22)
		icon.Position = UDim2.new(0, 12, 0, 10)
		icon.BackgroundColor3 = style.accent
		icon.BackgroundTransparency = 0.82
		icon.Text = style.icon
		icon.TextColor3 = style.accent
		icon.Font = Enum.Font.GothamBold
		icon.TextSize = 12
		Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)

		local title = Instance.new("TextLabel", toast)
		title.Size = UDim2.new(1, -52, 0, 16)
		title.Position = UDim2.new(0, 40, 0, 8)
		title.BackgroundTransparency = 1
		title.Text = titleText
		title.TextColor3 = Theme.Text
		title.TextTransparency = 1
		title.Font = Enum.Font.GothamBold
		title.TextSize = 12
		title.TextXAlignment = Enum.TextXAlignment.Left

		local text = Instance.new("TextLabel", toast)
		text.Size = UDim2.new(1, -52, 0, 0)
		text.Position = UDim2.new(0, 40, 0, 24)
		text.AutomaticSize = Enum.AutomaticSize.Y
		text.BackgroundTransparency = 1
		text.Text = bodyText
		text.TextColor3 = Theme.Muted
		text.TextTransparency = 1
		text.Font = Enum.Font.Gotham
		text.TextSize = 11
		text.TextWrapped = true
		text.TextXAlignment = Enum.TextXAlignment.Left

		local progressTrack = Instance.new("Frame", toast)
		progressTrack.AnchorPoint = Vector2.new(0, 1)
		progressTrack.Size = UDim2.new(1, -12, 0, 2)
		progressTrack.Position = UDim2.new(0, 6, 1, -4)
		progressTrack.BackgroundColor3 = Theme.Elevated
		progressTrack.BackgroundTransparency = 0.35
		progressTrack.BorderSizePixel = 0
		Instance.new("UICorner", progressTrack).CornerRadius = UDim.new(1, 0)

		local progressFill = Instance.new("Frame", progressTrack)
		progressFill.Size = UDim2.new(1, 0, 1, 0)
		progressFill.BackgroundColor3 = style.accent
		progressFill.BorderSizePixel = 0
		Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

		local pad = Instance.new("UIPadding", toast)
		pad.PaddingTop = UDim.new(0, 8)
		pad.PaddingBottom = UDim.new(0, 12)
		pad.PaddingRight = UDim.new(0, 10)

		local toastScale = Instance.new("UIScale", toast)
		toastScale.Scale = 0.92

		TweenPlay(toastScale, { Scale = 1 }, 0.28, Enum.EasingStyle.Quint)
		TweenPlay(toast, { BackgroundTransparency = 0 }, 0.28, Enum.EasingStyle.Quint)
		TweenPlay(title, { TextTransparency = 0 }, 0.28, Enum.EasingStyle.Quint)
		TweenPlay(text, { TextTransparency = 0 }, 0.28, Enum.EasingStyle.Quint)
		TweenPlay(progressFill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)

		task.delay(duration, function()
			TweenPlay(toastScale, { Scale = 0.94 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			TweenPlay(toast, { BackgroundTransparency = 1 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			TweenPlay(title, { TextTransparency = 1 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			TweenPlay(text, { TextTransparency = 1 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			task.wait(0.22)
			toast:Destroy()
		end)
	end

	if CollapseBtn then
		CollapseBtn.MouseButton1Click:Connect(function()
			collapsed = not collapsed
			CollapseBtn.Text = collapsed and "+" or "−"
			local targetHeight = collapsed and HEADER_H + 4 or fullHeight
			TweenPlay(MainFrame, { Size = UDim2.new(0, width, 0, targetHeight) }, 0.28, Enum.EasingStyle.Quint)
			task.delay(0.05, function()
				ScrollFrame.Visible = not collapsed
				HeaderDivider.Visible = not collapsed
				Footer.Visible = not collapsed and config.Footer ~= ""
				FooterDivider.Visible = not collapsed and config.Footer ~= ""
			end)
		end)
	end

	return UI
end

return EvolUI
