--[[
	EvolUI — Minimal UI Library
	By EvolEzod | v1.3.0

	Changelog (v1.3.0):
	  - Fixed: UI:Input() now returns a wrapper table with :GetValue() and :SetValue()
	    instead of a raw TextBox (prevents "GetValue is not a valid member" errors)
	  - Fixed: UI:Label() now always accepts a plain string (no table arg needed)
	  - Fixed: UI:Button() "Danger" style now properly colours red
	  - Fixed: Toggle SetError now properly resets after duration
	  - Fixed: Dropdown now supports :SetOptions() for dynamic option lists
	  - Fixed: Slider touch/mobile drag support added
	  - New:   UI:Keybind()  — shows current key, lets user rebind by clicking
	  - New:   UI:ColorRow() — compact hex colour display row with copy-on-click
	  - New:   UI:Separator(text) — labelled horizontal rule
	  - New:   UI:InfoRow(label, value) — left/right key-value display row
	  - New:   UI:SetTitle(text) / UI:SetSubtitle(text) — update header at runtime
	  - New:   UI:SetFooter(text) — update footer at runtime
	  - New:   UI:ClearContent() — destroys all scroll children (for dynamic UIs)
	  - New:   Notify now has a close (×) button
	  - New:   Grid:Button() returns handle with :SetText() and :Disable() / :Enable()
	  - New:   Badge preset "Admin" added (red)

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
EvolUI.Version = "1.3.0"

local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Players             = game:GetService("Players")
local CoreGui             = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local PAD       = 16
local HEADER_H  = 58
local FOOTER_H  = 30
local CONTENT_W = 268

local MODIFIER_KEYS = {
	[Enum.KeyCode.LeftShift]   = true,
	[Enum.KeyCode.RightShift]  = true,
	[Enum.KeyCode.LeftControl] = true,
	[Enum.KeyCode.RightControl]= true,
	[Enum.KeyCode.Insert]      = true,
	[Enum.KeyCode.Home]        = true,
	[Enum.KeyCode.End]         = true,
	[Enum.KeyCode.F1]          = true,
	[Enum.KeyCode.F2]          = true,
	[Enum.KeyCode.F3]          = true,
	[Enum.KeyCode.F4]          = true,
	[Enum.KeyCode.F5]          = true,
}

local DefaultTheme = {
	Background   = Color3.fromRGB(14,  14,  17),
	Surface      = Color3.fromRGB(24,  24,  29),
	SurfaceHover = Color3.fromRGB(34,  34,  40),
	Elevated     = Color3.fromRGB(30,  30,  36),
	HeaderTop    = Color3.fromRGB(18,  18,  22),
	Accent       = Color3.fromRGB(130, 114, 245),
	AccentLight  = Color3.fromRGB(148, 134, 255),
	AccentDim    = Color3.fromRGB(90,  78,  180),
	Text         = Color3.fromRGB(242, 242, 246),
	Muted        = Color3.fromRGB(118, 118, 130),
	Border       = Color3.fromRGB(46,  46,  54),
	Success      = Color3.fromRGB(68,  210, 148),
	Danger       = Color3.fromRGB(240, 90,  90),
	Warning      = Color3.fromRGB(248, 178, 60),
	ActiveRow    = Color3.fromRGB(28,  42,  36),
	Info         = Color3.fromRGB(96,  165, 250),
}

local BADGE_STYLES = {
	Dev = {
		Background = Color3.fromRGB(46, 36, 22),
		Color      = Color3.fromRGB(248, 178, 60),
		Stroke     = Color3.fromRGB(248, 178, 60),
	},
	Beta = {
		Background = Color3.fromRGB(30, 28, 50),
		Color      = Color3.fromRGB(148, 134, 255),
		Stroke     = Color3.fromRGB(130, 114, 245),
	},
	Tester = {
		Background = Color3.fromRGB(24, 42, 36),
		Color      = Color3.fromRGB(68, 210, 148),
		Stroke     = Color3.fromRGB(68, 210, 148),
	},
	Stable = {
		Background = Color3.fromRGB(26, 30, 26),
		Color      = Color3.fromRGB(130, 200, 160),
		Stroke     = Color3.fromRGB(72, 180, 120),
	},
	Premium = {
		Background = Color3.fromRGB(42, 30, 50),
		Color      = Color3.fromRGB(210, 170, 255),
		Stroke     = Color3.fromRGB(180, 130, 245),
	},
	Admin = {
		Background = Color3.fromRGB(50, 20, 20),
		Color      = Color3.fromRGB(255, 100, 100),
		Stroke     = Color3.fromRGB(220, 60, 60),
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
		text        = badgeConfig.Text or "Badge"
		customBg    = badgeConfig.Background
		customColor = badgeConfig.Color
		customStroke= badgeConfig.Stroke
	end

	local preset = BADGE_STYLES[text] or {}
	local bg     = customBg    or preset.Background or theme.Surface
	local color  = customColor or preset.Color      or theme.Muted
	local stroke = customStroke or preset.Stroke    or theme.Border

	if not preset.Background and text:match("^v[%d%.]") then
		bg     = theme.Elevated
		color  = theme.Muted
		stroke = theme.Border
	end

	local badge = Instance.new("TextLabel", parent)
	badge.Size                = UDim2.new(0, 0, 0, 20)
	badge.AutomaticSize       = Enum.AutomaticSize.X
	badge.BackgroundColor3    = bg
	badge.BackgroundTransparency = 0
	badge.Text                = text
	badge.TextColor3          = color
	badge.Font                = Enum.Font.GothamBold
	badge.TextSize            = 9
	badge.LayoutOrder         = layoutOrder

	Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)

	local strokeObj = Instance.new("UIStroke", badge)
	strokeObj.Color        = stroke
	strokeObj.Thickness    = 1
	strokeObj.Transparency = 0.55

	local pad = Instance.new("UIPadding", badge)
	pad.PaddingLeft  = UDim.new(0, 7)
	pad.PaddingRight = UDim.new(0, 7)

	return badge
end

-- ============================================================
function EvolUI.Load(config)
-- ============================================================
	config = config or {}

	local Theme           = MergeTheme(config.Theme)
	local width           = config.Width  or (CONTENT_W + PAD * 2)
	local height          = config.Height or 452
	local collapsed       = false
	local visible         = true
	local order           = 0
	local toggleActionName = "EvolUI_Toggle_" .. tostring(tick()):gsub("%.", "")

	local function nextOrder()
		order += 1
		return order
	end

	-- ── ScreenGui ──────────────────────────────────────────────
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name            = config.GuiName or "EvolUI_" .. (config.Name or "Window")
	ScreenGui.ResetOnSpawn    = false
	ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
	ScreenGui.IgnoreGuiInset  = true
	pcall(function() ScreenGui.Parent = CoreGui end)
	if not ScreenGui.Parent then
		ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	-- ── MainFrame ──────────────────────────────────────────────
	local MainFrame = Instance.new("Frame")
	MainFrame.Name                 = "Main"
	MainFrame.Size                 = UDim2.new(0, width, 0, height)
	MainFrame.Position             = config.Position or UDim2.new(0.5, -width/2, 0.5, -height/2)
	MainFrame.BackgroundColor3     = Theme.Background
	MainFrame.BackgroundTransparency = FRAME_TRANSPARENCY
	MainFrame.Active               = true
	MainFrame.ClipsDescendants     = true
	MainFrame.Parent               = ScreenGui

	local WindowScale = Instance.new("UIScale", MainFrame)
	WindowScale.Scale = 1

	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

	local MainStroke = Instance.new("UIStroke", MainFrame)
	MainStroke.Color        = Theme.Border
	MainStroke.Thickness    = 1
	MainStroke.Transparency = 0.2

	-- ── Header ─────────────────────────────────────────────────
	local HeaderBg = Instance.new("Frame", MainFrame)
	HeaderBg.Size                  = UDim2.new(1, 0, 0, HEADER_H)
	HeaderBg.BackgroundColor3      = Theme.HeaderTop
	HeaderBg.BackgroundTransparency = 0
	HeaderBg.BorderSizePixel       = 0
	HeaderBg.ZIndex                = 1

	local HeaderGradient = Instance.new("UIGradient", HeaderBg)
	HeaderGradient.Color    = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.HeaderTop),
		ColorSequenceKeypoint.new(1, Theme.Background),
	})
	HeaderGradient.Rotation = 90

	local HeaderFrame = Instance.new("Frame", HeaderBg)
	HeaderFrame.Size                 = UDim2.new(1, -(PAD*2), 1, 0)
	HeaderFrame.Position             = UDim2.new(0, PAD, 0, 0)
	HeaderFrame.BackgroundTransparency = 1
	HeaderFrame.ZIndex               = 2

	local TitleDot = Instance.new("Frame", HeaderFrame)
	TitleDot.Size             = UDim2.new(0, 6, 0, 6)
	TitleDot.Position         = UDim2.new(0, 0, 0, 15)
	TitleDot.BackgroundColor3 = Theme.Accent
	TitleDot.BackgroundTransparency = 0.15
	TitleDot.BorderSizePixel  = 0
	Instance.new("UICorner", TitleDot).CornerRadius = UDim.new(1, 0)

	local Title = Instance.new("TextLabel", HeaderFrame)
	Title.Size               = UDim2.new(0.58, 0, 0, 20)
	Title.Position           = UDim2.new(0, 10, 0, 8)
	Title.BackgroundTransparency = 1
	Title.Text               = config.Name or "EvolUI"
	Title.TextColor3         = Theme.Text
	Title.Font               = Enum.Font.GothamBold
	Title.TextSize           = 16
	Title.TextXAlignment     = Enum.TextXAlignment.Left

	local TitleUnderline = Instance.new("Frame", HeaderFrame)
	TitleUnderline.Size             = UDim2.new(0, 0, 0, 2)
	TitleUnderline.Position         = UDim2.new(0, 10, 0, 28)
	TitleUnderline.BackgroundColor3 = Theme.Accent
	TitleUnderline.BackgroundTransparency = 0.55
	TitleUnderline.BorderSizePixel  = 0
	Instance.new("UICorner", TitleUnderline).CornerRadius = UDim.new(1, 0)
	TweenPlay(TitleUnderline, { Size = UDim2.new(0, 46, 0, 2) }, 0.5, Enum.EasingStyle.Quint)

	local Subtitle = Instance.new("TextLabel", HeaderFrame)
	Subtitle.Size               = UDim2.new(0.58, 0, 0, 14)
	Subtitle.Position           = UDim2.new(0, 10, 0, 34)
	Subtitle.BackgroundTransparency = 1
	Subtitle.Text               = config.Subtitle or ""
	Subtitle.TextColor3         = Theme.Muted
	Subtitle.Font               = Enum.Font.Gotham
	Subtitle.TextSize           = 11
	Subtitle.TextXAlignment     = Enum.TextXAlignment.Left

	-- ── Header controls (badges + collapse) ───────────────────
	local HeaderControls = Instance.new("Frame", HeaderFrame)
	HeaderControls.AnchorPoint         = Vector2.new(1, 0.5)
	HeaderControls.Position            = UDim2.new(1, 0, 0.5, 0)
	HeaderControls.Size                = UDim2.new(0, 0, 0, 24)
	HeaderControls.AutomaticSize       = Enum.AutomaticSize.X
	HeaderControls.BackgroundTransparency = 1

	local controlsLayout = Instance.new("UIListLayout", HeaderControls)
	controlsLayout.FillDirection       = Enum.FillDirection.Horizontal
	controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	controlsLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
	controlsLayout.Padding             = UDim.new(0, 4)
	controlsLayout.SortOrder           = Enum.SortOrder.LayoutOrder

	local badgeOrder = 0
	local function nextBadgeOrder()
		badgeOrder += 1
		return badgeOrder
	end

	local CollapseBtn
	if config.Collapsible ~= false then
		CollapseBtn = Instance.new("TextButton", HeaderControls)
		CollapseBtn.Size                 = UDim2.new(0, 24, 0, 24)
		CollapseBtn.BackgroundColor3     = Theme.Surface
		CollapseBtn.BackgroundTransparency = 0
		CollapseBtn.Text                 = "−"
		CollapseBtn.TextColor3           = Theme.Muted
		CollapseBtn.Font                 = Enum.Font.GothamBold
		CollapseBtn.TextSize             = 14
		CollapseBtn.AutoButtonColor      = false
		CollapseBtn.LayoutOrder          = nextBadgeOrder()
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

	-- ── Divider ────────────────────────────────────────────────
	local HeaderDivider = Instance.new("Frame", MainFrame)
	HeaderDivider.Size                 = UDim2.new(1, -(PAD*2), 0, 1)
	HeaderDivider.Position             = UDim2.new(0, PAD, 0, HEADER_H)
	HeaderDivider.BackgroundColor3     = Theme.Border
	HeaderDivider.BackgroundTransparency = 0.5
	HeaderDivider.BorderSizePixel      = 0
	HeaderDivider.ZIndex               = 2

	-- ── ScrollFrame ────────────────────────────────────────────
	local ScrollTop   = HEADER_H + 6
	local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
	ScrollFrame.Name                  = "Content"
	ScrollFrame.Size                  = UDim2.new(1, 0, 1, -(ScrollTop + FOOTER_H))
	ScrollFrame.Position              = UDim2.new(0, 0, 0, ScrollTop)
	ScrollFrame.BackgroundTransparency = 1
	ScrollFrame.BorderSizePixel       = 0
	ScrollFrame.ScrollBarThickness    = 3
	ScrollFrame.ScrollBarImageColor3  = Theme.AccentDim
	ScrollFrame.AutomaticCanvasSize   = Enum.AutomaticSize.Y
	ScrollFrame.CanvasSize            = UDim2.new(0, 0, 0, 0)
	ScrollFrame.ZIndex                = 2

	local ListLayout = Instance.new("UIListLayout", ScrollFrame)
	ListLayout.SortOrder           = Enum.SortOrder.LayoutOrder
	ListLayout.Padding             = UDim.new(0, 8)
	ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local ScrollPadding = Instance.new("UIPadding", ScrollFrame)
	ScrollPadding.PaddingTop    = UDim.new(0, 6)
	ScrollPadding.PaddingBottom = UDim.new(0, 10)
	ScrollPadding.PaddingLeft   = UDim.new(0, PAD)
	ScrollPadding.PaddingRight  = UDim.new(0, PAD)

	-- ── Footer ─────────────────────────────────────────────────
	local FooterDivider = Instance.new("Frame", MainFrame)
	FooterDivider.Size                 = UDim2.new(1, -(PAD*2), 0, 1)
	FooterDivider.Position             = UDim2.new(0, PAD, 1, -FOOTER_H)
	FooterDivider.BackgroundColor3     = Theme.Border
	FooterDivider.BackgroundTransparency = 0.5
	FooterDivider.BorderSizePixel      = 0
	FooterDivider.ZIndex               = 2

	local Footer = Instance.new("TextLabel", MainFrame)
	Footer.Size               = UDim2.new(1, 0, 0, FOOTER_H)
	Footer.Position           = UDim2.new(0, 0, 1, -FOOTER_H)
	Footer.BackgroundTransparency = 1
	Footer.Text               = config.Footer or ""
	Footer.TextColor3         = Theme.Muted
	Footer.Font               = Enum.Font.Gotham
	Footer.TextSize           = 10
	Footer.TextTransparency   = 0.1
	Footer.ZIndex             = 2

	-- ── Notification holder ────────────────────────────────────
	local NotifyHolder = Instance.new("Frame", MainFrame)
	NotifyHolder.Name               = "Notifications"
	NotifyHolder.AnchorPoint        = Vector2.new(0.5, 1)
	NotifyHolder.Position           = UDim2.new(0.5, 0, 1, -(FOOTER_H + 8))
	NotifyHolder.Size               = UDim2.new(1, -24, 0, 0)
	NotifyHolder.AutomaticSize      = Enum.AutomaticSize.Y
	NotifyHolder.BackgroundTransparency = 1
	NotifyHolder.ZIndex             = 50

	local NotifyLayout = Instance.new("UIListLayout", NotifyHolder)
	NotifyLayout.SortOrder         = Enum.SortOrder.LayoutOrder
	NotifyLayout.Padding           = UDim.new(0, 6)
	NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

	-- ── Drag ──────────────────────────────────────────────────
	local fullHeight = height
	local dragging, dragStart, startPos
	local lastToggle  = 0
	local toggleLocked = false

	local function bindDrag(frame)
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
				dragging  = true
				dragStart = input.Position
				startPos  = MainFrame.Position
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
		if dragging and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	-- ── UI table ──────────────────────────────────────────────
	local UI = {
		Theme          = Theme,
		ScreenGui      = ScreenGui,
		Main           = MainFrame,
		Content        = ScrollFrame,
		Title          = Title,
		Subtitle       = Subtitle,
		Footer         = Footer,
		HeaderControls = HeaderControls,
	}

	-- ── Visibility animation ──────────────────────────────────
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

	-- ── Core methods ──────────────────────────────────────────
	function UI:SetTheme(overrides)
		Theme    = MergeTheme(overrides)
		UI.Theme = Theme
	end

	function UI:Show()  animateVisibility(true)  end
	function UI:Hide()  animateVisibility(false) end
	function UI:Toggle() animateVisibility(not visible) end

	function UI:Destroy()
		pcall(function() ContextActionService:UnbindAction(toggleActionName) end)
		ScreenGui:Destroy()
	end

	function UI:AddBadge(badgeConfig)
		badgeOrder += 1
		return CreateBadge(HeaderControls, badgeConfig, Theme, badgeOrder)
	end

	-- NEW: runtime header/footer updates
	function UI:SetTitle(text)
		Title.Text = text or ""
	end

	function UI:SetSubtitle(text)
		Subtitle.Text = text or ""
	end

	function UI:SetFooter(text)
		Footer.Text = text or ""
	end

	-- NEW: wipe all scroll content (useful for dynamic tab UIs)
	function UI:ClearContent()
		for _, child in ipairs(ScrollFrame:GetChildren()) do
			if child:IsA("GuiObject") and child ~= ListLayout and child ~= ScrollPadding then
				child:Destroy()
			end
		end
		order = 0
	end

	-- ── Toggle key ────────────────────────────────────────────
	local toggleKey = config.ToggleKey
	if toggleKey then
		local function handleToggle()
			if toggleLocked then return end
			local now = tick()
			if now - lastToggle < 0.2 then return end
			lastToggle  = now
			toggleLocked = true
			UI:Toggle()
			task.delay(0.2, function() toggleLocked = false end)
		end

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
			if input.KeyCode ~= toggleKey then return end
			if gameProcessed and not MODIFIER_KEYS[input.KeyCode] then return end
			handleToggle()
		end)

		pcall(function()
			ContextActionService:BindAction(toggleActionName, function(_, state)
				if state == Enum.UserInputState.Begin then handleToggle() end
				return Enum.ContextActionResult.Sink
			end, false, toggleKey)
		end)
	end

	-- ── Open animation ────────────────────────────────────────
	MainFrame.BackgroundTransparency = 1
	WindowScale.Scale = 0.94
	task.defer(function()
		TweenPlay(WindowScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Quint)
		TweenPlay(MainFrame, { BackgroundTransparency = FRAME_TRANSPARENCY }, 0.35, Enum.EasingStyle.Quint)
	end)

	-- ── Title dot pulse ───────────────────────────────────────
	task.spawn(function()
		while TitleDot.Parent do
			TweenPlay(TitleDot, { BackgroundTransparency = 0 }, 1.4, Enum.EasingStyle.Sine)
			task.wait(1.4)
			TweenPlay(TitleDot, { BackgroundTransparency = 0.35 }, 1.4, Enum.EasingStyle.Sine)
			task.wait(1.4)
		end
	end)

	-- ══════════════════════════════════════════════════════════
	-- WIDGET METHODS
	-- ══════════════════════════════════════════════════════════

	function UI:Spacer(spacerHeight)
		local spacer = Instance.new("Frame", ScrollFrame)
		spacer.Size                 = UDim2.new(1, 0, 0, spacerHeight or 10)
		spacer.BackgroundTransparency = 1
		spacer.LayoutOrder          = nextOrder()
		return spacer
	end

	function UI:Section(text)
		local holder = Instance.new("Frame", ScrollFrame)
		holder.Size                 = UDim2.new(1, 0, 0, 22)
		holder.BackgroundTransparency = 1
		holder.LayoutOrder          = nextOrder()

		local accent = Instance.new("Frame", holder)
		accent.Size             = UDim2.new(0, 2, 0, 10)
		accent.Position         = UDim2.new(0, 0, 1, -12)
		accent.BackgroundColor3 = Theme.Border
		accent.BackgroundTransparency = 0.3
		accent.BorderSizePixel  = 0
		Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

		local label = Instance.new("TextLabel", holder)
		label.Size               = UDim2.new(1, -8, 1, 0)
		label.Position           = UDim2.new(0, 8, 0, 0)
		label.BackgroundTransparency = 1
		label.Text               = string.upper(text or "")
		label.TextColor3         = Theme.Muted
		label.Font               = Enum.Font.GothamMedium
		label.TextSize           = 10
		label.TextXAlignment     = Enum.TextXAlignment.Left
		label.TextYAlignment     = Enum.TextYAlignment.Bottom

		return label
	end

	function UI:Divider()
		local line = Instance.new("Frame", ScrollFrame)
		line.Size                 = UDim2.new(1, 0, 0, 1)
		line.BackgroundColor3     = Theme.Border
		line.BackgroundTransparency = 0.45
		line.BorderSizePixel      = 0
		line.LayoutOrder          = nextOrder()
		return line
	end

	-- NEW: Separator with optional centred label
	function UI:Separator(text)
		local holder = Instance.new("Frame", ScrollFrame)
		holder.Size                 = UDim2.new(1, 0, 0, 18)
		holder.BackgroundTransparency = 1
		holder.LayoutOrder          = nextOrder()

		local lineL = Instance.new("Frame", holder)
		lineL.AnchorPoint         = Vector2.new(0, 0.5)
		lineL.BackgroundColor3    = Theme.Border
		lineL.BackgroundTransparency = 0.45
		lineL.BorderSizePixel     = 0
		lineL.Position            = UDim2.new(0, 0, 0.5, 0)

		if text and text ~= "" then
			local lbl = Instance.new("TextLabel", holder)
			lbl.AnchorPoint         = Vector2.new(0.5, 0.5)
			lbl.Position            = UDim2.new(0.5, 0, 0.5, 0)
			lbl.Size                = UDim2.new(0, 0, 1, 0)
			lbl.AutomaticSize       = Enum.AutomaticSize.X
			lbl.BackgroundTransparency = 1
			lbl.Text                = "  " .. text .. "  "
			lbl.TextColor3          = Theme.Muted
			lbl.Font                = Enum.Font.Gotham
			lbl.TextSize            = 10

			local lineR = Instance.new("Frame", holder)
			lineR.AnchorPoint         = Vector2.new(1, 0.5)
			lineR.BackgroundColor3    = Theme.Border
			lineR.BackgroundTransparency = 0.45
			lineR.BorderSizePixel     = 0
			lineR.Position            = UDim2.new(1, 0, 0.5, 0)

			-- We size the lines dynamically after the label renders
			task.defer(function()
				local lblW = lbl.AbsoluteSize.X
				local half = (holder.AbsoluteSize.X - lblW) / 2
				lineL.Size = UDim2.new(0, half - 4, 0, 1)
				lineR.Size = UDim2.new(0, half - 4, 0, 1)
			end)
		else
			lineL.Size = UDim2.new(1, 0, 0, 1)
			lineL.Position = UDim2.new(0, 0, 0.5, 0)
		end

		return holder
	end

	-- FIXED: always accepts a plain string; second arg = muted
	function UI:Label(text, muted)
		local label = Instance.new("TextLabel", ScrollFrame)
		label.Size                 = UDim2.new(1, 0, 0, 18)
		label.BackgroundTransparency = 1
		label.Text                 = tostring(text or "")
		label.TextColor3           = muted and Theme.Muted or Theme.Text
		label.Font                 = Enum.Font.Gotham
		label.TextSize             = 11
		label.TextXAlignment       = Enum.TextXAlignment.Left
		label.TextWrapped          = true
		label.AutomaticSize        = Enum.AutomaticSize.Y
		label.LayoutOrder          = nextOrder()
		return label
	end

	-- NEW: key / value display row (e.g. "Status  |  Active")
	function UI:InfoRow(labelText, valueText)
		local row = Instance.new("Frame", ScrollFrame)
		row.Size               = UDim2.new(1, 0, 0, 34)
		row.BackgroundColor3   = Theme.Surface
		row.LayoutOrder        = nextOrder()
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

		local lbl = Instance.new("TextLabel", row)
		lbl.Size               = UDim2.new(0.5, -8, 1, 0)
		lbl.Position           = UDim2.new(0, 14, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text               = tostring(labelText or "")
		lbl.TextColor3         = Theme.Muted
		lbl.Font               = Enum.Font.GothamMedium
		lbl.TextSize           = 11
		lbl.TextXAlignment     = Enum.TextXAlignment.Left
		lbl.TextYAlignment     = Enum.TextYAlignment.Center

		local val = Instance.new("TextLabel", row)
		val.AnchorPoint        = Vector2.new(1, 0.5)
		val.Size               = UDim2.new(0.5, -14, 0, 22)
		val.Position           = UDim2.new(1, -12, 0.5, 0)
		val.BackgroundColor3   = Theme.Elevated
		val.BackgroundTransparency = 0
		val.Text               = tostring(valueText or "")
		val.TextColor3         = Theme.Accent
		val.Font               = Enum.Font.GothamBold
		val.TextSize           = 11
		val.TextXAlignment     = Enum.TextXAlignment.Center
		val.TextYAlignment     = Enum.TextYAlignment.Center
		val.ClipsDescendants   = true
		Instance.new("UICorner", val).CornerRadius = UDim.new(0, 7)

		return {
			Row = row,
			SetValue = function(newVal)
				val.Text = tostring(newVal or "")
			end,
			SetLabel = function(newLabel)
				lbl.Text = tostring(newLabel or "")
			end,
		}
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

	-- FIXED: "Danger" style now properly renders red
	function UI:Button(options)
		options = options or {}
		local style     = options.Style or "Secondary"
		local isPrimary = style == "Primary"
		local isDanger  = style == "Danger"
		local btnHeight = options.Height or (isPrimary and 40 or 38)

		local bgColor
		if isPrimary then
			bgColor = Theme.Accent
		elseif isDanger then
			bgColor = Color3.fromRGB(60, 22, 22)
		else
			bgColor = Theme.Surface
		end

		local textColor
		if isPrimary or isDanger then
			textColor = Color3.fromRGB(255, 255, 255)
		else
			textColor = Theme.Text
		end

		local btn = Instance.new("TextButton", ScrollFrame)
		btn.Size               = UDim2.new(1, 0, 0, btnHeight)
		btn.BackgroundColor3   = bgColor
		btn.Text               = options.Text or "Button"
		btn.TextColor3         = textColor
		btn.Font               = (isPrimary or isDanger) and Enum.Font.GothamBold or Enum.Font.GothamMedium
		btn.TextSize           = 12
		btn.LayoutOrder        = nextOrder()
		btn.AutoButtonColor    = false
		btn.TextYAlignment     = Enum.TextYAlignment.Center
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

		local strokeColor = isPrimary and Theme.AccentLight or (isDanger and Theme.Danger or Theme.Border)
		local strokeTrans = (isPrimary or isDanger) and 0.45 or 0.55
		local btnStroke   = Instance.new("UIStroke", btn)
		btnStroke.Color        = strokeColor
		btnStroke.Thickness    = 1
		btnStroke.Transparency = strokeTrans

		local hoverColor
		if isPrimary then
			hoverColor = Theme.AccentLight
		elseif isDanger then
			hoverColor = Color3.fromRGB(80, 28, 28)
		else
			hoverColor = Theme.SurfaceHover
		end

		btn.MouseEnter:Connect(function()
			TweenPlay(btn, { BackgroundColor3 = hoverColor })
			TweenPlay(btnStroke, { Transparency = 0.2 })
		end)
		btn.MouseLeave:Connect(function()
			TweenPlay(btn, { BackgroundColor3 = bgColor })
			TweenPlay(btnStroke, { Transparency = strokeTrans })
		end)

		bindButtonPress(btn)

		if options.Callback then
			btn.MouseButton1Click:Connect(options.Callback)
		end

		return btn
	end

	-- ── Toggle ────────────────────────────────────────────────
	local function setSwitchVisual(track, knob, isOn, animate)
		local onColor  = Color3.fromRGB(48, 72, 58)
		local offColor = Theme.Elevated
		local knobOn   = UDim2.new(1, -21, 0.5, -9)
		local knobOff  = UDim2.new(0, 3,  0.5, -9)

		if animate then
			TweenPlay(track, { BackgroundColor3 = isOn and onColor or offColor }, 0.2, Enum.EasingStyle.Quint)
			TweenPlay(knob, {
				Position       = isOn and knobOn or knobOff,
				BackgroundColor3 = isOn and Theme.Success or Theme.Muted
			}, 0.22, Enum.EasingStyle.Quint)
		else
			track.BackgroundColor3 = isOn and onColor or offColor
			knob.Position          = isOn and knobOn or knobOff
			knob.BackgroundColor3  = isOn and Theme.Success or Theme.Muted
		end
	end

	function UI:Toggle(options)
		options = options or {}
		local state = options.Default or false

		local row = Instance.new("Frame", ScrollFrame)
		row.Size             = UDim2.new(1, 0, 0, 42)
		row.BackgroundColor3 = Theme.Surface
		row.LayoutOrder      = nextOrder()
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

		local label = Instance.new("TextLabel", row)
		label.Size               = UDim2.new(1, -68, 1, 0)
		label.Position           = UDim2.new(0, 14, 0, 0)
		label.BackgroundTransparency = 1
		label.Text               = options.Text or "Toggle"
		label.TextColor3         = Theme.Text
		label.Font               = Enum.Font.GothamMedium
		label.TextSize           = 12
		label.TextXAlignment     = Enum.TextXAlignment.Left
		label.TextYAlignment     = Enum.TextYAlignment.Center

		local track = Instance.new("Frame", row)
		track.AnchorPoint     = Vector2.new(1, 0.5)
		track.Size            = UDim2.new(0, 46, 0, 22)
		track.Position        = UDim2.new(1, -12, 0.5, 0)
		track.BackgroundColor3 = Theme.Elevated
		track.BorderSizePixel = 0
		Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

		local knob = Instance.new("Frame", track)
		knob.Size             = UDim2.new(0, 18, 0, 18)
		knob.Position         = UDim2.new(0, 3, 0.5, -9)
		knob.BackgroundColor3 = Theme.Muted
		knob.BorderSizePixel  = 0
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

		local hitbox = Instance.new("TextButton", row)
		hitbox.Size               = UDim2.new(1, 0, 1, 0)
		hitbox.BackgroundTransparency = 1
		hitbox.Text               = ""
		hitbox.ZIndex             = 2

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
			if options.Callback then options.Callback(state) end
		end)

		refresh(false)

		return {
			Row    = row,
			Track  = track,
			Knob   = knob,
			Hitbox = hitbox,
			Get    = function() return state end,
			Set    = function(value)
				state = value and true or false
				refresh(true)
			end,
			-- FIXED: properly resets after duration
			SetError = function(text, duration)
				TweenPlay(track, { BackgroundColor3 = Color3.fromRGB(58, 32, 32) }, 0.15)
				TweenPlay(knob,  { BackgroundColor3 = Theme.Danger }, 0.15)
				task.delay(duration or 1.2, function()
					refresh(true)
				end)
			end,
			Refresh = refresh,
		}
	end

	-- ── ValueRow ──────────────────────────────────────────────
	function UI:ValueRow(options)
		options = options or {}

		local row = Instance.new("Frame", ScrollFrame)
		row.Size             = UDim2.new(1, 0, 0, 42)
		row.BackgroundColor3 = Theme.Surface
		row.LayoutOrder      = nextOrder()
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

		local titleLabel = Instance.new("TextLabel", row)
		titleLabel.Size               = UDim2.new(1, -80, 0, 16)
		titleLabel.Position           = UDim2.new(0, 14, 0, 7)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text               = options.Title or "Value"
		titleLabel.TextColor3         = Theme.Text
		titleLabel.Font               = Enum.Font.GothamMedium
		titleLabel.TextSize           = 12
		titleLabel.TextXAlignment     = Enum.TextXAlignment.Left

		local hintLabel = Instance.new("TextLabel", row)
		hintLabel.Size               = UDim2.new(1, -80, 0, 12)
		hintLabel.Position           = UDim2.new(0, 14, 0, 23)
		hintLabel.BackgroundTransparency = 1
		hintLabel.Text               = options.Hint or ""
		hintLabel.TextColor3         = Theme.Muted
		hintLabel.Font               = Enum.Font.Gotham
		hintLabel.TextSize           = 10
		hintLabel.TextXAlignment     = Enum.TextXAlignment.Left

		local valueLabel = Instance.new("TextLabel", row)
		valueLabel.AnchorPoint       = Vector2.new(1, 0.5)
		valueLabel.Size              = UDim2.new(0, 52, 0, 26)
		valueLabel.Position          = UDim2.new(1, -12, 0.5, 0)
		valueLabel.BackgroundColor3  = Theme.Elevated
		valueLabel.Text              = tostring(options.Value or 0)
		valueLabel.TextColor3        = Theme.Accent
		valueLabel.Font              = Enum.Font.GothamBold
		valueLabel.TextSize          = 13
		valueLabel.TextYAlignment    = Enum.TextYAlignment.Center
		Instance.new("UICorner", valueLabel).CornerRadius = UDim.new(0, 8)

		local valueScale = Instance.new("UIScale", valueLabel)

		local hitbox = Instance.new("TextButton", row)
		hitbox.Size               = UDim2.new(1, 0, 1, 0)
		hitbox.BackgroundTransparency = 1
		hitbox.Text               = ""
		hitbox.ZIndex             = 2

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
			Row        = row,
			ValueLabel = valueLabel,
			SetValue   = function(value) valueLabel.Text = tostring(value) end,
			GetValue   = function() return tonumber(valueLabel.Text) or 0 end,
		}
	end

	-- ── Input — FIXED: returns wrapper table with GetValue/SetValue ──
	function UI:Input(options)
		options = options or {}

		local holder = Instance.new("Frame", ScrollFrame)
		holder.Size             = UDim2.new(1, 0, 0, 40)
		holder.BackgroundColor3 = Theme.Surface
		holder.LayoutOrder      = nextOrder()
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)

		-- Optional title label above the box
		if options.Title and options.Title ~= "" then
			holder.Size = UDim2.new(1, 0, 0, 56)
			local titleLbl = Instance.new("TextLabel", holder)
			titleLbl.Size               = UDim2.new(1, -24, 0, 14)
			titleLbl.Position           = UDim2.new(0, 12, 0, 5)
			titleLbl.BackgroundTransparency = 1
			titleLbl.Text               = options.Title
			titleLbl.TextColor3         = Theme.Muted
			titleLbl.Font               = Enum.Font.Gotham
			titleLbl.TextSize           = 10
			titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
		end

		local boxY = (options.Title and options.Title ~= "") and 18 or 6
		local box  = Instance.new("TextBox", holder)
		box.Size              = UDim2.new(1, -24, 0, 26)
		box.Position          = UDim2.new(0, 12, 0, boxY)
		box.BackgroundTransparency = 1
		box.Text              = options.Default or ""
		box.PlaceholderText   = options.Placeholder or "Enter text..."
		box.PlaceholderColor3 = Theme.Muted
		box.TextColor3        = Theme.Text
		box.Font              = Enum.Font.Gotham
		box.TextSize          = 12
		box.TextXAlignment    = Enum.TextXAlignment.Left
		box.ClearTextOnFocus  = false

		local inputStroke = Instance.new("UIStroke", holder)
		inputStroke.Color        = Theme.Border
		inputStroke.Thickness    = 1
		inputStroke.Transparency = 0.55

		box.Focused:Connect(function()
			TweenPlay(holder, { BackgroundColor3 = Theme.SurfaceHover }, 0.15, Enum.EasingStyle.Quint)
			TweenPlay(inputStroke, { Color = Theme.Accent, Transparency = 0.3 }, 0.15)
		end)
		box.FocusLost:Connect(function()
			TweenPlay(holder, { BackgroundColor3 = Theme.Surface }, 0.15, Enum.EasingStyle.Quint)
			TweenPlay(inputStroke, { Color = Theme.Border, Transparency = 0.55 }, 0.15)
			if options.Callback then options.Callback(box.Text) end
		end)

		-- Return wrapper so both .Text and :GetValue() work
		local wrapper = {
			_box   = box,
			Holder = holder,
			Text   = box.Text, -- kept in sync below
		}

		-- Proxy .Text reads to the real box via metatable
		setmetatable(wrapper, {
			__index = function(t, k)
				if k == "Text" then return box.Text end
				return rawget(t, k)
			end,
			__newindex = function(t, k, v)
				if k == "Text" then box.Text = v else rawset(t, k, v) end
			end,
		})

		function wrapper:GetValue()
			return box.Text
		end

		function wrapper:SetValue(value)
			box.Text = tostring(value or "")
		end

		function wrapper:Clear()
			box.Text = ""
		end

		function wrapper:Focus()
			box:CaptureFocus()
		end

		return wrapper
	end

	-- ── Slider ────────────────────────────────────────────────
	function UI:Slider(options)
		options = options or {}
		local min   = options.Min     or 0
		local max   = options.Max     or 100
		local step  = options.Step    or 1
		local value = options.Default or min

		local holder = Instance.new("Frame", ScrollFrame)
		holder.Size             = UDim2.new(1, 0, 0, 52)
		holder.BackgroundColor3 = Theme.Surface
		holder.LayoutOrder      = nextOrder()
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)

		local label = Instance.new("TextLabel", holder)
		label.Size               = UDim2.new(1, -60, 0, 18)
		label.Position           = UDim2.new(0, 14, 0, 8)
		label.BackgroundTransparency = 1
		label.Text               = options.Text or "Slider"
		label.TextColor3         = Theme.Text
		label.Font               = Enum.Font.GothamMedium
		label.TextSize           = 12
		label.TextXAlignment     = Enum.TextXAlignment.Left

		local valueLabel = Instance.new("TextLabel", holder)
		valueLabel.AnchorPoint   = Vector2.new(1, 0)
		valueLabel.Size          = UDim2.new(0, 40, 0, 18)
		valueLabel.Position      = UDim2.new(1, -12, 0, 8)
		valueLabel.BackgroundTransparency = 1
		valueLabel.Text          = tostring(value)
		valueLabel.TextColor3    = Theme.Accent
		valueLabel.Font          = Enum.Font.GothamBold
		valueLabel.TextSize      = 12

		local track = Instance.new("Frame", holder)
		track.Size            = UDim2.new(1, -28, 0, 6)
		track.Position        = UDim2.new(0, 14, 0, 34)
		track.BackgroundColor3 = Theme.Elevated
		track.BorderSizePixel = 0
		Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

		local fill = Instance.new("Frame", track)
		fill.Size             = UDim2.new((value - min) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = Theme.Accent
		fill.BorderSizePixel  = 0
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

		local knob = Instance.new("TextButton", track)
		knob.AnchorPoint      = Vector2.new(0.5, 0.5)
		knob.Size             = UDim2.new(0, 14, 0, 14)
		knob.Position         = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
		knob.BackgroundColor3 = Theme.Text
		knob.Text             = ""
		knob.AutoButtonColor  = false
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

		local function setValue(newValue, fire)
			value = math.clamp(math.floor((newValue - min) / step + 0.5) * step + min, min, max)
			local alpha = (value - min) / (max - min)
			TweenPlay(fill,  { Size     = UDim2.new(alpha, 0, 1, 0) }, 0.12, Enum.EasingStyle.Quint)
			TweenPlay(knob,  { Position = UDim2.new(alpha, 0, 0.5, 0) }, 0.12, Enum.EasingStyle.Quint)
			valueLabel.Text = tostring(value)
			if fire and options.Callback then options.Callback(value) end
		end

		local sliding = false
		knob.MouseButton1Down:Connect(function() sliding = true end)

		-- Touch support
		knob.TouchLongPress:Connect(function() sliding = true end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
				sliding = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if sliding and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			) then
				local rel = math.clamp(
					(input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1
				)
				setValue(min + (max - min) * rel, true)
			end
		end)
		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
				local rel = math.clamp(
					(input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1
				)
				setValue(min + (max - min) * rel, true)
			end
		end)

		return {
			Set = function(newValue, fire) setValue(newValue, fire) end,
			Get = function() return value end,
		}
	end

	-- ── Dropdown — FIXED: added SetOptions for dynamic lists ──
	function UI:Dropdown(options)
		options = options or {}
		local open       = false
		local selected   = options.Default or (options.Options and options.Options[1]) or ""
		local optionList = options.Options or {}
		local optionCount = #optionList

		local holder = Instance.new("Frame", ScrollFrame)
		holder.Size             = UDim2.new(1, 0, 0, 40)
		holder.BackgroundColor3 = Theme.Surface
		holder.LayoutOrder      = nextOrder()
		holder.ClipsDescendants = true
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)

		local topRow = Instance.new("Frame", holder)
		topRow.Size               = UDim2.new(1, 0, 0, 40)
		topRow.BackgroundTransparency = 1
		topRow.ZIndex             = 2

		local label = Instance.new("TextLabel", topRow)
		label.Size               = UDim2.new(0.45, 0, 1, 0)
		label.Position           = UDim2.new(0, 14, 0, 0)
		label.BackgroundTransparency = 1
		label.Text               = options.Text or "Select"
		label.TextColor3         = Theme.Text
		label.Font               = Enum.Font.GothamMedium
		label.TextSize           = 12
		label.TextXAlignment     = Enum.TextXAlignment.Left
		label.TextYAlignment     = Enum.TextYAlignment.Center

		local display = Instance.new("TextButton", topRow)
		display.AnchorPoint      = Vector2.new(1, 0.5)
		display.Size             = UDim2.new(0, 120, 0, 28)
		display.Position         = UDim2.new(1, -12, 0.5, 0)
		display.BackgroundColor3 = Theme.Elevated
		display.Text             = tostring(selected) .. "  ▾"
		display.TextColor3       = Theme.Text
		display.Font             = Enum.Font.GothamMedium
		display.TextSize         = 11
		display.AutoButtonColor  = false
		display.ZIndex           = 3
		Instance.new("UICorner", display).CornerRadius = UDim.new(0, 8)

		local displayStroke = Instance.new("UIStroke", display)
		displayStroke.Color        = Theme.Border
		displayStroke.Thickness    = 1
		displayStroke.Transparency = 0.45

		local divider = Instance.new("Frame", holder)
		divider.Size             = UDim2.new(1, -16, 0, 1)
		divider.Position         = UDim2.new(0, 8, 0, 40)
		divider.BackgroundColor3 = Theme.Border
		divider.BackgroundTransparency = 0.5
		divider.BorderSizePixel  = 0
		divider.Visible          = false
		divider.ZIndex           = 2

		local list = Instance.new("Frame", holder)
		list.Size             = UDim2.new(1, -16, 0, 0)
		list.Position         = UDim2.new(0, 8, 0, 41)
		list.BackgroundTransparency = 1
		list.Visible          = false
		list.ClipsDescendants = true
		list.ZIndex           = 2

		local listLayout = Instance.new("UIListLayout", list)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding   = UDim.new(0, 4)

		local listPad = Instance.new("UIPadding", list)
		listPad.PaddingTop    = UDim.new(0, 4)
		listPad.PaddingBottom = UDim.new(0, 6)

		local function getListHeight()
			if optionCount == 0 then return 0 end
			return optionCount * 32 + (optionCount - 1) * 4 + 10
		end

		local function setOpen(state)
			open = state
			local listHeight = open and getListHeight() or 0
			list.Visible    = open and listHeight > 0
			divider.Visible = list.Visible
			display.Text    = tostring(selected) .. (open and "  ▴" or "  ▾")
			TweenPlay(list,   { Size = UDim2.new(1, -16, 0, listHeight) }, 0.2, Enum.EasingStyle.Quint)
			TweenPlay(holder, { Size = UDim2.new(1, 0, 0, 40 + listHeight) }, 0.2, Enum.EasingStyle.Quint)
		end

		local function buildOptions()
			for _, child in ipairs(list:GetChildren()) do
				if child:IsA("GuiObject") then child:Destroy() end
			end
			optionCount = #optionList
			for i, option in ipairs(optionList) do
				local optBtn = Instance.new("TextButton", list)
				optBtn.Size             = UDim2.new(1, 0, 0, 32)
				optBtn.BackgroundColor3 = Theme.Elevated
				optBtn.Text             = tostring(option)
				optBtn.TextColor3       = Theme.Text
				optBtn.Font             = Enum.Font.GothamMedium
				optBtn.TextSize         = 11
				optBtn.AutoButtonColor  = false
				optBtn.LayoutOrder      = i
				Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 8)

				local optStroke = Instance.new("UIStroke", optBtn)
				optStroke.Color        = Theme.Border
				optStroke.Thickness    = 1
				optStroke.Transparency = 0.55

				optBtn.MouseEnter:Connect(function()
					TweenPlay(optBtn,   { BackgroundColor3 = Theme.SurfaceHover })
					TweenPlay(optStroke, { Color = Theme.Accent, Transparency = 0.25 })
				end)
				optBtn.MouseLeave:Connect(function()
					TweenPlay(optBtn,   { BackgroundColor3 = Theme.Elevated })
					TweenPlay(optStroke, { Color = Theme.Border, Transparency = 0.55 })
				end)
				optBtn.MouseButton1Click:Connect(function()
					selected     = option
					display.Text = tostring(selected) .. "  ▾"
					setOpen(false)
					if options.Callback then options.Callback(selected) end
				end)
			end
		end

		buildOptions()

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
			Get  = function() return selected end,
			Set  = function(value)
				selected     = value
				display.Text = tostring(selected) .. (open and "  ▴" or "  ▾")
			end,
			Close = function() setOpen(false) end,
			-- NEW: replace the option list at runtime
			SetOptions = function(newOptions, keepSelected)
				optionList = newOptions or {}
				if not keepSelected then
					selected     = optionList[1] or ""
					display.Text = tostring(selected) .. "  ▾"
				end
				setOpen(false)
				buildOptions()
			end,
		}
	end

	-- ── Grid ─────────────────────────────────────────────────
	function UI:Grid(options)
		options = options or {}
		local cellW   = options.CellW   or 130
		local cellH   = options.CellH   or 30
		local padding = options.Padding or 8

		local gridFrame = Instance.new("Frame", ScrollFrame)
		gridFrame.Size               = UDim2.new(1, 0, 0, 0)
		gridFrame.AutomaticSize      = Enum.AutomaticSize.Y
		gridFrame.BackgroundTransparency = 1
		gridFrame.LayoutOrder        = nextOrder()

		local grid = Instance.new("UIGridLayout", gridFrame)
		grid.CellSize             = UDim2.new(0, cellW, 0, cellH)
		grid.CellPadding          = UDim2.new(0, padding, 0, padding)
		grid.FillDirectionMaxCells = options.Columns or 2
		grid.HorizontalAlignment  = Enum.HorizontalAlignment.Center
		grid.SortOrder            = Enum.SortOrder.LayoutOrder

		local gridApi = {}

		-- IMPROVED: Button returns handle with SetText, Disable, Enable
		function gridApi:Button(text, callback)
			local pBtn = Instance.new("TextButton", gridFrame)
			pBtn.BackgroundColor3  = Theme.Surface
			pBtn.Text              = text
			pBtn.TextColor3        = Theme.Muted
			pBtn.Font              = Enum.Font.GothamMedium
			pBtn.TextSize          = 11
			pBtn.AutoButtonColor   = false
			pBtn.TextYAlignment    = Enum.TextYAlignment.Center
			pBtn.TextTruncate      = Enum.TextTruncate.AtEnd
			Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 8)

			local stroke = Instance.new("UIStroke", pBtn)
			stroke.Color        = Theme.Border
			stroke.Thickness    = 1
			stroke.Transparency = 0.4

			local btnScale  = Instance.new("UIScale", pBtn)
			local disabled  = false

			pBtn.MouseEnter:Connect(function()
				if disabled then return end
				TweenPlay(pBtn,   { BackgroundColor3 = Theme.SurfaceHover, TextColor3 = Theme.Text })
				TweenPlay(stroke, { Color = Theme.Accent, Transparency = 0.15 })
			end)
			pBtn.MouseLeave:Connect(function()
				if disabled then return end
				TweenPlay(pBtn,   { BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Muted })
				TweenPlay(stroke, { Color = Theme.Border, Transparency = 0.4 })
			end)
			pBtn.MouseButton1Down:Connect(function()
				if disabled then return end
				TweenPlay(btnScale, { Scale = 0.95 }, 0.08, Enum.EasingStyle.Quint)
			end)
			pBtn.MouseButton1Up:Connect(function()
				TweenPlay(btnScale, { Scale = 1 }, 0.12, Enum.EasingStyle.Quint)
			end)

			if callback then
				pBtn.MouseButton1Click:Connect(function()
					if disabled then return end
					callback()
					TweenPlay(pBtn,   { BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text })
					TweenPlay(stroke, { Color = Theme.Accent, Transparency = 0 })
					task.delay(0.35, function()
						if not disabled then
							TweenPlay(pBtn,   { BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Muted })
							TweenPlay(stroke, { Color = Theme.Border, Transparency = 0.4 })
						end
					end)
				end)
			end

			return {
				Button  = pBtn,
				SetText = function(newText)  pBtn.Text = tostring(newText or "") end,
				Disable = function()
					disabled = true
					TweenPlay(pBtn,   { BackgroundColor3 = Theme.Elevated, TextColor3 = Theme.Muted })
					TweenPlay(stroke, { Transparency = 0.7 })
					pBtn.TextTransparency = 0.5
				end,
				Enable  = function()
					disabled = false
					TweenPlay(pBtn,   { BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Muted })
					TweenPlay(stroke, { Transparency = 0.4 })
					pBtn.TextTransparency = 0
				end,
			}
		end

		return gridApi
	end

	-- ── Progress ──────────────────────────────────────────────
	function UI:Progress(options)
		options = options or {}
		local value = math.clamp(options.Value or 0, 0, 1)

		local holder = Instance.new("Frame", ScrollFrame)
		holder.Size               = UDim2.new(1, 0, 0, 34)
		holder.BackgroundTransparency = 1
		holder.LayoutOrder        = nextOrder()

		local label = Instance.new("TextLabel", holder)
		label.Size               = UDim2.new(1, 0, 0, 14)
		label.BackgroundTransparency = 1
		label.Text               = options.Text or "Progress"
		label.TextColor3         = Theme.Muted
		label.Font               = Enum.Font.Gotham
		label.TextSize           = 10
		label.TextXAlignment     = Enum.TextXAlignment.Left

		local track = Instance.new("Frame", holder)
		track.Size            = UDim2.new(1, 0, 0, 6)
		track.Position        = UDim2.new(0, 0, 0, 20)
		track.BackgroundColor3 = Theme.Elevated
		track.BorderSizePixel = 0
		Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

		local fill = Instance.new("Frame", track)
		fill.Size             = UDim2.new(value, 0, 1, 0)
		fill.BackgroundColor3 = Theme.Accent
		fill.BorderSizePixel  = 0
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

		return {
			Set = function(newValue)
				value = math.clamp(newValue, 0, 1)
				TweenPlay(fill, { Size = UDim2.new(value, 0, 1, 0) }, 0.25, Enum.EasingStyle.Quint)
			end,
			Get = function() return value end,
		}
	end

	-- ── NEW: Keybind ──────────────────────────────────────────
	-- Click to rebind; press a key; Escape cancels
	function UI:Keybind(options)
		options = options or {}
		local currentKey = options.Default or Enum.KeyCode.Unknown
		local listening  = false

		local row = Instance.new("Frame", ScrollFrame)
		row.Size             = UDim2.new(1, 0, 0, 42)
		row.BackgroundColor3 = Theme.Surface
		row.LayoutOrder      = nextOrder()
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

		local lbl = Instance.new("TextLabel", row)
		lbl.Size               = UDim2.new(1, -100, 1, 0)
		lbl.Position           = UDim2.new(0, 14, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text               = options.Text or "Keybind"
		lbl.TextColor3         = Theme.Text
		lbl.Font               = Enum.Font.GothamMedium
		lbl.TextSize           = 12
		lbl.TextXAlignment     = Enum.TextXAlignment.Left
		lbl.TextYAlignment     = Enum.TextYAlignment.Center

		local keyBtn = Instance.new("TextButton", row)
		keyBtn.AnchorPoint      = Vector2.new(1, 0.5)
		keyBtn.Size             = UDim2.new(0, 80, 0, 26)
		keyBtn.Position         = UDim2.new(1, -12, 0.5, 0)
		keyBtn.BackgroundColor3 = Theme.Elevated
		keyBtn.Font             = Enum.Font.GothamBold
		keyBtn.TextSize         = 11
		keyBtn.AutoButtonColor  = false
		keyBtn.TextColor3       = Theme.Accent
		Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 8)

		local keyStroke = Instance.new("UIStroke", keyBtn)
		keyStroke.Color        = Theme.Border
		keyStroke.Thickness    = 1
		keyStroke.Transparency = 0.45

		local function keyName(kc)
			if kc == Enum.KeyCode.Unknown then return "None" end
			return tostring(kc):gsub("Enum.KeyCode.", "")
		end

		keyBtn.Text = keyName(currentKey)

		local inputConn

		local function stopListening(cancelled)
			listening = false
			if inputConn then inputConn:Disconnect(); inputConn = nil end
			TweenPlay(keyBtn,   { BackgroundColor3 = Theme.Elevated, TextColor3 = Theme.Accent })
			TweenPlay(keyStroke, { Color = Theme.Border, Transparency = 0.45 })
			keyBtn.Text = cancelled and keyName(currentKey) or keyBtn.Text
		end

		local function startListening()
			listening   = true
			keyBtn.Text = "..."
			TweenPlay(keyBtn,   { BackgroundColor3 = Theme.AccentDim, TextColor3 = Theme.Text })
			TweenPlay(keyStroke, { Color = Theme.Accent, Transparency = 0.15 })

			inputConn = UserInputService.InputBegan:Connect(function(input, gp)
				if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
				if input.KeyCode == Enum.KeyCode.Escape then
					stopListening(true)
					return
				end
				currentKey  = input.KeyCode
				keyBtn.Text = keyName(currentKey)
				stopListening(false)
				if options.Callback then options.Callback(currentKey) end
			end)
		end

		keyBtn.MouseEnter:Connect(function()
			if listening then return end
			TweenPlay(keyBtn, { BackgroundColor3 = Theme.SurfaceHover })
		end)
		keyBtn.MouseLeave:Connect(function()
			if listening then return end
			TweenPlay(keyBtn, { BackgroundColor3 = Theme.Elevated })
		end)
		keyBtn.MouseButton1Click:Connect(function()
			if listening then stopListening(true) else startListening() end
		end)

		return {
			Get = function() return currentKey end,
			Set = function(kc)
				currentKey  = kc
				keyBtn.Text = keyName(kc)
			end,
		}
	end

	-- ── NEW: ColorRow — hex display with click-to-copy ────────
	function UI:ColorRow(options)
		options = options or {}
		local color = options.Color or Color3.fromRGB(130, 114, 245)

		local function toHex(c)
			return string.format(
				"#%02X%02X%02X",
				math.floor(c.R * 255),
				math.floor(c.G * 255),
				math.floor(c.B * 255)
			)
		end

		local row = Instance.new("Frame", ScrollFrame)
		row.Size             = UDim2.new(1, 0, 0, 42)
		row.BackgroundColor3 = Theme.Surface
		row.LayoutOrder      = nextOrder()
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

		local lbl = Instance.new("TextLabel", row)
		lbl.Size               = UDim2.new(1, -110, 1, 0)
		lbl.Position           = UDim2.new(0, 14, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text               = options.Text or "Color"
		lbl.TextColor3         = Theme.Text
		lbl.Font               = Enum.Font.GothamMedium
		lbl.TextSize           = 12
		lbl.TextXAlignment     = Enum.TextXAlignment.Left
		lbl.TextYAlignment     = Enum.TextYAlignment.Center

		local swatch = Instance.new("Frame", row)
		swatch.AnchorPoint      = Vector2.new(1, 0.5)
		swatch.Size             = UDim2.new(0, 22, 0, 22)
		swatch.Position         = UDim2.new(1, -82, 0.5, 0)
		swatch.BackgroundColor3 = color
		swatch.BorderSizePixel  = 0
		Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 6)

		local hexBtn = Instance.new("TextButton", row)
		hexBtn.AnchorPoint      = Vector2.new(1, 0.5)
		hexBtn.Size             = UDim2.new(0, 72, 0, 26)
		hexBtn.Position         = UDim2.new(1, -6, 0.5, 0)
		hexBtn.BackgroundColor3 = Theme.Elevated
		hexBtn.Text             = toHex(color)
		hexBtn.TextColor3       = Theme.Muted
		hexBtn.Font             = Enum.Font.GothamBold
		hexBtn.TextSize         = 10
		hexBtn.AutoButtonColor  = false
		Instance.new("UICorner", hexBtn).CornerRadius = UDim.new(0, 7)

		local copied = false
		hexBtn.MouseButton1Click:Connect(function()
			if copied then return end
			copied = true
			pcall(function() setclipboard(hexBtn.Text) end)
			local orig = hexBtn.Text
			hexBtn.Text      = "Copied!"
			hexBtn.TextColor3 = Theme.Success
			task.delay(1.2, function()
				hexBtn.Text       = orig
				hexBtn.TextColor3 = Theme.Muted
				copied            = false
			end)
		end)

		hexBtn.MouseEnter:Connect(function()
			TweenPlay(hexBtn, { BackgroundColor3 = Theme.SurfaceHover })
		end)
		hexBtn.MouseLeave:Connect(function()
			TweenPlay(hexBtn, { BackgroundColor3 = Theme.Elevated })
		end)

		return {
			SetColor = function(c)
				color             = c
				swatch.BackgroundColor3 = c
				hexBtn.Text       = toHex(c)
			end,
			GetColor = function() return color end,
			GetHex   = function() return toHex(color) end,
		}
	end

	-- ── Notify — FIXED: added × close button ─────────────────
	function UI:Notify(options)
		options = options or {}
		local notifyType = options.Type     or "Info"
		local duration   = options.Duration or 3

		local palette = {
			Success = { accent = Theme.Success, bg = Color3.fromRGB(22, 36, 30), icon = "✓", title = "Success" },
			Error   = { accent = Theme.Danger,  bg = Color3.fromRGB(38, 22, 24), icon = "✕", title = "Error"   },
			Warning = { accent = Theme.Warning, bg = Color3.fromRGB(38, 32, 20), icon = "!", title = "Warning" },
			Info    = { accent = Theme.Info,    bg = Color3.fromRGB(22, 28, 38), icon = "i", title = "Info"    },
		}
		local style     = palette[notifyType] or palette.Info
		local titleText = options.Title or style.title
		local bodyText  = options.Text  or options.Description or "Notification"

		local toast = Instance.new("Frame", NotifyHolder)
		toast.Size               = UDim2.new(1, 0, 0, 0)
		toast.AutomaticSize      = Enum.AutomaticSize.Y
		toast.BackgroundColor3   = style.bg
		toast.BackgroundTransparency = 1
		toast.LayoutOrder        = math.floor(tick() * 1000)
		Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 10)

		local toastStroke = Instance.new("UIStroke", toast)
		toastStroke.Color        = style.accent
		toastStroke.Thickness    = 1
		toastStroke.Transparency = 0.55

		local accent = Instance.new("Frame", toast)
		accent.Size             = UDim2.new(0, 4, 1, -8)
		accent.Position         = UDim2.new(0, 0, 0, 4)
		accent.BackgroundColor3 = style.accent
		accent.BorderSizePixel  = 0
		Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

		local icon = Instance.new("TextLabel", toast)
		icon.Size                 = UDim2.new(0, 22, 0, 22)
		icon.Position             = UDim2.new(0, 12, 0, 10)
		icon.BackgroundColor3     = style.accent
		icon.BackgroundTransparency = 0.82
		icon.Text                 = style.icon
		icon.TextColor3           = style.accent
		icon.Font                 = Enum.Font.GothamBold
		icon.TextSize             = 12
		Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)

		local title = Instance.new("TextLabel", toast)
		title.Size               = UDim2.new(1, -68, 0, 16)
		title.Position           = UDim2.new(0, 40, 0, 8)
		title.BackgroundTransparency = 1
		title.Text               = titleText
		title.TextColor3         = Theme.Text
		title.TextTransparency   = 1
		title.Font               = Enum.Font.GothamBold
		title.TextSize           = 12
		title.TextXAlignment     = Enum.TextXAlignment.Left

		local text = Instance.new("TextLabel", toast)
		text.Size                = UDim2.new(1, -68, 0, 0)
		text.Position            = UDim2.new(0, 40, 0, 24)
		text.AutomaticSize       = Enum.AutomaticSize.Y
		text.BackgroundTransparency = 1
		text.Text                = bodyText
		text.TextColor3          = Theme.Muted
		text.TextTransparency    = 1
		text.Font                = Enum.Font.Gotham
		text.TextSize            = 11
		text.TextWrapped         = true
		text.TextXAlignment      = Enum.TextXAlignment.Left

		-- NEW: close button
		local closeBtn = Instance.new("TextButton", toast)
		closeBtn.AnchorPoint         = Vector2.new(1, 0)
		closeBtn.Size                = UDim2.new(0, 18, 0, 18)
		closeBtn.Position            = UDim2.new(1, -8, 0, 6)
		closeBtn.BackgroundTransparency = 1
		closeBtn.Text                = "×"
		closeBtn.TextColor3          = Theme.Muted
		closeBtn.Font                = Enum.Font.GothamBold
		closeBtn.TextSize            = 14
		closeBtn.ZIndex              = 5

		local progressTrack = Instance.new("Frame", toast)
		progressTrack.AnchorPoint      = Vector2.new(0, 1)
		progressTrack.Size             = UDim2.new(1, -12, 0, 2)
		progressTrack.Position         = UDim2.new(0, 6, 1, -4)
		progressTrack.BackgroundColor3 = Theme.Elevated
		progressTrack.BackgroundTransparency = 0.35
		progressTrack.BorderSizePixel  = 0
		Instance.new("UICorner", progressTrack).CornerRadius = UDim.new(1, 0)

		local progressFill = Instance.new("Frame", progressTrack)
		progressFill.Size             = UDim2.new(1, 0, 1, 0)
		progressFill.BackgroundColor3 = style.accent
		progressFill.BorderSizePixel  = 0
		Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

		local pad = Instance.new("UIPadding", toast)
		pad.PaddingTop    = UDim.new(0, 8)
		pad.PaddingBottom = UDim.new(0, 12)
		pad.PaddingRight  = UDim.new(0, 10)

		local toastScale = Instance.new("UIScale", toast)
		toastScale.Scale = 0.92

		local dismissed = false
		local function dismiss()
			if dismissed then return end
			dismissed = true
			TweenPlay(toastScale, { Scale = 0.94 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			TweenPlay(toast,      { BackgroundTransparency = 1 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			TweenPlay(title,      { TextTransparency = 1 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			TweenPlay(text,       { TextTransparency = 1 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			task.wait(0.22)
			toast:Destroy()
		end

		closeBtn.MouseButton1Click:Connect(dismiss)

		TweenPlay(toastScale, { Scale = 1 }, 0.28, Enum.EasingStyle.Quint)
		TweenPlay(toast,      { BackgroundTransparency = 0 }, 0.28, Enum.EasingStyle.Quint)
		TweenPlay(title,      { TextTransparency = 0 }, 0.28, Enum.EasingStyle.Quint)
		TweenPlay(text,       { TextTransparency = 0 }, 0.28, Enum.EasingStyle.Quint)
		TweenPlay(progressFill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)

		task.delay(duration, dismiss)
	end

	-- ── Collapse button ───────────────────────────────────────
	if CollapseBtn then
		CollapseBtn.MouseButton1Click:Connect(function()
			collapsed = not collapsed
			CollapseBtn.Text = collapsed and "+" or "−"
			local targetHeight = collapsed and HEADER_H + 4 or fullHeight
			TweenPlay(MainFrame, { Size = UDim2.new(0, width, 0, targetHeight) }, 0.28, Enum.EasingStyle.Quint)
			task.delay(0.05, function()
				ScrollFrame.Visible  = not collapsed
				HeaderDivider.Visible = not collapsed
				Footer.Visible        = not collapsed and config.Footer ~= ""
				FooterDivider.Visible = not collapsed and config.Footer ~= ""
			end)
		end)
	end

	return UI
end

return EvolUI
