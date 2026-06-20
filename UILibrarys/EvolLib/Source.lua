--[[
	EvolUI — Minimal UI Library
	By EvolEzod | v1.3.0

	Usage (GitHub):
		local EVOLUI_URL = "https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/EvolLib/Source.lua"
		local EvolUI = loadstring(game:HttpGet(EVOLUI_URL))()

	NEW IN v1.3.0:
		• Tab system with sidebar navigation
		• True HSV Color Picker (hue bar + SV square + hex input + alpha)
		• Multi-select Dropdown
		• Paragraph / rich text widget
		• Console / Log widget
		• Watermark overlay
		• Dependency system (SetVisible / Depends)
		• Interactive Notifications with buttons
		• Config system (Save / Load / Delete via writefile)
		• Modifier keybind support (Ctrl+F, Shift+P, etc.)
		• Maid cleanup on :Destroy()
		• Theme live-refresh helpers
		• Resizable window (ResizeHandle corner)

	Basic Usage:
		local UI = EvolUI.Load({
			Name        = "My Script",
			Version     = "v1.3.0",
			Badges      = { "Dev", "Beta" },
			ToggleKey   = Enum.KeyCode.RightShift,
			TabSidebar  = true,   -- enable left-sidebar tab layout
			Resizable   = true,   -- allow corner drag to resize
			Footer      = "EvolUI v1.3.0",
		})

		local Combat = UI:Tab("⚔  Combat")
		Combat:Toggle({ Text = "Aimbot", Default = false, Callback = function(v) end })
		Combat:Slider({ Text = "FOV", Min = 1, Max = 360, Default = 90, Callback = function(v) end })

		UI:Watermark({ Text = "EvolUI | v1.3.0" })
		UI:Notify({ Title = "Loaded", Text = "Script ready!", Type = "Success" })
]]

local EvolUI = {}
EvolUI.Version = "1.3.0"

-- ─── Services ────────────────────────────────────────────────────────────────
local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Players             = game:GetService("Players")
local CoreGui             = game:GetService("CoreGui")
local RunService          = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ─── Layout constants ────────────────────────────────────────────────────────
local PAD       = 16
local HEADER_H  = 58
local FOOTER_H  = 30
local CONTENT_W = 268
local SIDEBAR_W = 110   -- tab sidebar width

-- ─── Modifier key set ────────────────────────────────────────────────────────
local MODIFIER_KEYS = {
	[Enum.KeyCode.LeftShift]   = true, [Enum.KeyCode.RightShift]   = true,
	[Enum.KeyCode.LeftControl] = true, [Enum.KeyCode.RightControl] = true,
	[Enum.KeyCode.LeftAlt]     = true, [Enum.KeyCode.RightAlt]     = true,
	[Enum.KeyCode.Insert] = true, [Enum.KeyCode.Home] = true,
	[Enum.KeyCode.End]    = true,
	[Enum.KeyCode.F1] = true, [Enum.KeyCode.F2] = true, [Enum.KeyCode.F3] = true,
	[Enum.KeyCode.F4] = true, [Enum.KeyCode.F5] = true,
}

-- ─── Default theme ───────────────────────────────────────────────────────────
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
	Sidebar      = Color3.fromRGB(18,  18,  22),
	SidebarItem  = Color3.fromRGB(26,  26,  32),
	SidebarActive= Color3.fromRGB(34,  32,  54),
}

local BADGE_STYLES = {
	Dev     = { Background = Color3.fromRGB(46,36,22),  Color = Color3.fromRGB(248,178,60),  Stroke = Color3.fromRGB(248,178,60) },
	Beta    = { Background = Color3.fromRGB(30,28,50),  Color = Color3.fromRGB(148,134,255), Stroke = Color3.fromRGB(130,114,245) },
	Tester  = { Background = Color3.fromRGB(24,42,36),  Color = Color3.fromRGB(68,210,148),  Stroke = Color3.fromRGB(68,210,148) },
	Stable  = { Background = Color3.fromRGB(26,30,26),  Color = Color3.fromRGB(130,200,160), Stroke = Color3.fromRGB(72,180,120) },
	Premium = { Background = Color3.fromRGB(42,30,50),  Color = Color3.fromRGB(210,170,255), Stroke = Color3.fromRGB(180,130,245) },
}

local FRAME_TRANSPARENCY = 0

-- ─── Maid ────────────────────────────────────────────────────────────────────
local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({ _tasks = {} }, Maid)
end

function Maid:Add(task_)
	table.insert(self._tasks, task_)
	return task_
end

function Maid:Clean()
	for _, t in ipairs(self._tasks) do
		if typeof(t) == "RBXScriptConnection" then
			pcall(function() t:Disconnect() end)
		elseif typeof(t) == "Instance" then
			pcall(function() t:Destroy() end)
		elseif type(t) == "function" then
			pcall(t)
		end
	end
	self._tasks = {}
end

-- ─── Helpers ─────────────────────────────────────────────────────────────────
local function Tween(obj, props, dur, style, dir)
	return TweenService:Create(obj,
		TweenInfo.new(dur or 0.22, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		props)
end

local function TweenPlay(obj, props, dur, style, dir)
	Tween(obj, props, dur, style, dir):Play()
end

local function MergeTheme(overrides)
	local t = {}
	for k, v in pairs(DefaultTheme) do t[k] = v end
	if overrides then
		for k, v in pairs(overrides) do t[k] = v end
	end
	return t
end

local function CreateBadge(parent, badgeConfig, theme, layoutOrder)
	local text, customBg, customColor, customStroke
	if typeof(badgeConfig) == "string" then
		text = badgeConfig
	else
		text = badgeConfig.Text or "Badge"
		customBg    = badgeConfig.Background
		customColor = badgeConfig.Color
		customStroke = badgeConfig.Stroke
	end
	local preset = BADGE_STYLES[text] or {}
	local bg     = customBg    or preset.Background or theme.Surface
	local color  = customColor or preset.Color      or theme.Muted
	local stroke = customStroke or preset.Stroke    or theme.Border
	if not preset.Background and text:match("^v[%d%.]") then
		bg = theme.Elevated; color = theme.Muted; stroke = theme.Border
	end
	local badge = Instance.new("TextLabel", parent)
	badge.Size = UDim2.new(0,0,0,20)
	badge.AutomaticSize = Enum.AutomaticSize.X
	badge.BackgroundColor3 = bg
	badge.Text = text
	badge.TextColor3 = color
	badge.Font = Enum.Font.GothamBold
	badge.TextSize = 9
	badge.LayoutOrder = layoutOrder
	Instance.new("UICorner", badge).CornerRadius = UDim.new(0,6)
	local s = Instance.new("UIStroke", badge)
	s.Color = stroke; s.Thickness = 1; s.Transparency = 0.55
	local p = Instance.new("UIPadding", badge)
	p.PaddingLeft = UDim.new(0,7); p.PaddingRight = UDim.new(0,7)
	return badge
end

-- HSV <-> Color3 helpers
local function Color3ToHSV(c)
	return Color3.toHSV(c)
end
local function HSVToColor3(h, s, v)
	return Color3.fromHSV(h, s, v)
end

local function RGBToHex(c)
	return string.format("%02X%02X%02X",
		math.floor(c.R * 255 + 0.5),
		math.floor(c.G * 255 + 0.5),
		math.floor(c.B * 255 + 0.5))
end

local function HexToColor3(hex)
	hex = hex:gsub("#","")
	if #hex ~= 6 then return nil end
	local r = tonumber(hex:sub(1,2), 16)
	local g = tonumber(hex:sub(3,4), 16)
	local b = tonumber(hex:sub(5,6), 16)
	if not (r and g and b) then return nil end
	return Color3.fromRGB(r, g, b)
end

-- pcall-safe file IO (only works in exploits that expose writefile/readfile)
local function SafeWrite(path, data)
	pcall(function()
		if writefile then writefile(path, data) end
	end)
end
local function SafeRead(path)
	local ok, result = pcall(function()
		if readfile then return readfile(path) end
		return nil
	end)
	return ok and result or nil
end
local function SafeDelete(path)
	pcall(function()
		if delfile then delfile(path) end
	end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- EvolUI.Load
-- ─────────────────────────────────────────────────────────────────────────────
function EvolUI.Load(config)
	config = config or {}

	local Theme   = MergeTheme(config.Theme)
	local useSidebar = config.TabSidebar ~= false  -- default true when tabs used
	local width  = config.Width  or (CONTENT_W + PAD * 2)
	local height = config.Height or 452
	local collapsed = false
	local visible   = true
	local globalOrder = 0
	local toggleActionName = "EvolUI_Toggle_" .. tostring(tick()):gsub("%.", "")
	local maid = Maid.new()

	-- registered controls for config save/load
	local configRegistry = {}   -- { id, widget, type }
	-- registered controls for dependency links
	-- global search index: { label=string, frame=Instance }
	local searchIndex = {}

	local function nextOrder()
		globalOrder += 1
		return globalOrder
	end

	-- ── Screen Gui ──────────────────────────────────────────────────────────
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = config.GuiName or "EvolUI_" .. (config.Name or "Window")
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.IgnoreGuiInset = true
	pcall(function() ScreenGui.Parent = CoreGui end)
	if not ScreenGui.Parent then
		ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
	maid:Add(ScreenGui)

	-- ── Main frame ──────────────────────────────────────────────────────────
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "Main"
	MainFrame.Size = UDim2.new(0, width, 0, height)
	MainFrame.Position = config.Position or UDim2.new(0.5, -width/2, 0.5, -height/2)
	MainFrame.BackgroundColor3 = Theme.Background
	MainFrame.BackgroundTransparency = FRAME_TRANSPARENCY
	MainFrame.Active = true
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

	local WindowScale = Instance.new("UIScale", MainFrame)
	WindowScale.Scale = 1

	local MainStroke = Instance.new("UIStroke", MainFrame)
	MainStroke.Color = Theme.Border; MainStroke.Thickness = 1; MainStroke.Transparency = 0.2

	-- ── Header ──────────────────────────────────────────────────────────────
	local HeaderBg = Instance.new("Frame", MainFrame)
	HeaderBg.Size = UDim2.new(1,0,0,HEADER_H)
	HeaderBg.BackgroundColor3 = Theme.HeaderTop
	HeaderBg.BorderSizePixel = 0
	HeaderBg.ZIndex = 3

	local HeaderGradient = Instance.new("UIGradient", HeaderBg)
	HeaderGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.HeaderTop),
		ColorSequenceKeypoint.new(1, Theme.Background),
	})
	HeaderGradient.Rotation = 90

	local HeaderFrame = Instance.new("Frame", HeaderBg)
	HeaderFrame.Size = UDim2.new(1, -(PAD*2), 1, 0)
	HeaderFrame.Position = UDim2.new(0, PAD, 0, 0)
	HeaderFrame.BackgroundTransparency = 1
	HeaderFrame.ZIndex = 4

	local TitleDot = Instance.new("Frame", HeaderFrame)
	TitleDot.Size = UDim2.new(0,6,0,6)
	TitleDot.Position = UDim2.new(0,0,0,15)
	TitleDot.BackgroundColor3 = Theme.Accent
	TitleDot.BackgroundTransparency = 0.15
	TitleDot.BorderSizePixel = 0
	Instance.new("UICorner", TitleDot).CornerRadius = UDim.new(1,0)

	local Title = Instance.new("TextLabel", HeaderFrame)
	Title.Size = UDim2.new(0.58,0,0,20)
	Title.Position = UDim2.new(0,10,0,8)
	Title.BackgroundTransparency = 1
	Title.Text = config.Name or "EvolUI"
	Title.TextColor3 = Theme.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local TitleUnderline = Instance.new("Frame", HeaderFrame)
	TitleUnderline.Size = UDim2.new(0,0,0,2)
	TitleUnderline.Position = UDim2.new(0,10,0,28)
	TitleUnderline.BackgroundColor3 = Theme.Accent
	TitleUnderline.BackgroundTransparency = 0.55
	TitleUnderline.BorderSizePixel = 0
	Instance.new("UICorner", TitleUnderline).CornerRadius = UDim.new(1,0)
	TweenPlay(TitleUnderline, { Size = UDim2.new(0,46,0,2) }, 0.5, Enum.EasingStyle.Quint)

	local Subtitle = Instance.new("TextLabel", HeaderFrame)
	Subtitle.Size = UDim2.new(0.58,0,0,14)
	Subtitle.Position = UDim2.new(0,10,0,34)
	Subtitle.BackgroundTransparency = 1
	Subtitle.Text = config.Subtitle or ""
	Subtitle.TextColor3 = Theme.Muted
	Subtitle.Font = Enum.Font.Gotham
	Subtitle.TextSize = 11
	Subtitle.TextXAlignment = Enum.TextXAlignment.Left

	local HeaderControls = Instance.new("Frame", HeaderFrame)
	HeaderControls.AnchorPoint = Vector2.new(1,0.5)
	HeaderControls.Position = UDim2.new(1,0,0.5,0)
	HeaderControls.Size = UDim2.new(0,0,0,24)
	HeaderControls.AutomaticSize = Enum.AutomaticSize.X
	HeaderControls.BackgroundTransparency = 1
	local ctrlLayout = Instance.new("UIListLayout", HeaderControls)
	ctrlLayout.FillDirection = Enum.FillDirection.Horizontal
	ctrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	ctrlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ctrlLayout.Padding = UDim.new(0,4)
	ctrlLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local badgeOrder = 0
	local function nextBadgeOrder() badgeOrder += 1 return badgeOrder end

	local CollapseBtn
	if config.Collapsible ~= false then
		CollapseBtn = Instance.new("TextButton", HeaderControls)
		CollapseBtn.Size = UDim2.new(0,24,0,24)
		CollapseBtn.BackgroundColor3 = Theme.Surface
		CollapseBtn.Text = "−"
		CollapseBtn.TextColor3 = Theme.Muted
		CollapseBtn.Font = Enum.Font.GothamBold
		CollapseBtn.TextSize = 14
		CollapseBtn.AutoButtonColor = false
		CollapseBtn.LayoutOrder = nextBadgeOrder()
		Instance.new("UICorner", CollapseBtn).CornerRadius = UDim.new(0,6)
		maid:Add(CollapseBtn.MouseEnter:Connect(function()
			TweenPlay(CollapseBtn, { BackgroundColor3 = Theme.SurfaceHover, TextColor3 = Theme.Text })
		end))
		maid:Add(CollapseBtn.MouseLeave:Connect(function()
			TweenPlay(CollapseBtn, { BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Muted })
		end))
	end

	if config.Version then
		CreateBadge(HeaderControls, config.Version, Theme, nextBadgeOrder())
	end
	for _, badge in ipairs(config.Badges or {}) do
		CreateBadge(HeaderControls, badge, Theme, nextBadgeOrder())
	end

	local HeaderDivider = Instance.new("Frame", MainFrame)
	HeaderDivider.Size = UDim2.new(1, -(PAD*2), 0, 1)
	HeaderDivider.Position = UDim2.new(0, PAD, 0, HEADER_H)
	HeaderDivider.BackgroundColor3 = Theme.Border
	HeaderDivider.BackgroundTransparency = 0.5
	HeaderDivider.BorderSizePixel = 0
	HeaderDivider.ZIndex = 3

	-- ── Content area (split: optional sidebar + main scroll) ─────────────
	local ContentTop = HEADER_H + 6

	-- Left sidebar for tabs
	local SidebarFrame = Instance.new("Frame", MainFrame)
	SidebarFrame.Name = "Sidebar"
	SidebarFrame.Size = UDim2.new(0, SIDEBAR_W, 1, -(ContentTop + FOOTER_H))
	SidebarFrame.Position = UDim2.new(0, 0, 0, ContentTop)
	SidebarFrame.BackgroundColor3 = Theme.Sidebar
	SidebarFrame.BorderSizePixel = 0
	SidebarFrame.ZIndex = 2
	SidebarFrame.Visible = false  -- shown when tabs are added

	local SidebarPad = Instance.new("UIPadding", SidebarFrame)
	SidebarPad.PaddingTop = UDim.new(0,8)
	SidebarPad.PaddingLeft = UDim.new(0,6)
	SidebarPad.PaddingRight = UDim.new(0,6)
	SidebarPad.PaddingBottom = UDim.new(0,8)

	local SidebarLayout = Instance.new("UIListLayout", SidebarFrame)
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Padding = UDim.new(0,4)

	local SidebarDivider = Instance.new("Frame", MainFrame)
	SidebarDivider.Size = UDim2.new(0, 1, 1, -(ContentTop + FOOTER_H))
	SidebarDivider.Position = UDim2.new(0, SIDEBAR_W, 0, ContentTop)
	SidebarDivider.BackgroundColor3 = Theme.Border
	SidebarDivider.BackgroundTransparency = 0.45
	SidebarDivider.BorderSizePixel = 0
	SidebarDivider.ZIndex = 2
	SidebarDivider.Visible = false

	-- Content host (tabs render here as child ScrollingFrames)
	local ContentHost = Instance.new("Frame", MainFrame)
	ContentHost.Name = "ContentHost"
	ContentHost.Size = UDim2.new(1, 0, 1, -(ContentTop + FOOTER_H))
	ContentHost.Position = UDim2.new(0, 0, 0, ContentTop)
	ContentHost.BackgroundTransparency = 1
	ContentHost.ClipsDescendants = true
	ContentHost.ZIndex = 2

	-- Default (no-tab) scroll frame
	local DefaultScroll = Instance.new("ScrollingFrame", ContentHost)
	DefaultScroll.Name = "DefaultContent"
	DefaultScroll.Size = UDim2.new(1,0,1,0)
	DefaultScroll.Position = UDim2.new(0,0,0,0)
	DefaultScroll.BackgroundTransparency = 1
	DefaultScroll.BorderSizePixel = 0
	DefaultScroll.ScrollBarThickness = 3
	DefaultScroll.ScrollBarImageColor3 = Theme.AccentDim
	DefaultScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	DefaultScroll.CanvasSize = UDim2.new(0,0,0,0)
	DefaultScroll.ZIndex = 2

	local DefaultLayout = Instance.new("UIListLayout", DefaultScroll)
	DefaultLayout.SortOrder = Enum.SortOrder.LayoutOrder
	DefaultLayout.Padding = UDim.new(0,8)
	DefaultLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local DefaultPad = Instance.new("UIPadding", DefaultScroll)
	DefaultPad.PaddingTop = UDim.new(0,6)
	DefaultPad.PaddingBottom = UDim.new(0,10)
	DefaultPad.PaddingLeft = UDim.new(0,PAD)
	DefaultPad.PaddingRight = UDim.new(0,PAD)

	-- Active scroll frame pointer (used by widget builders)
	local ActiveScroll = DefaultScroll

	-- ── Footer ───────────────────────────────────────────────────────────────
	local FooterDivider = Instance.new("Frame", MainFrame)
	FooterDivider.Size = UDim2.new(1, -(PAD*2), 0, 1)
	FooterDivider.Position = UDim2.new(0, PAD, 1, -FOOTER_H)
	FooterDivider.BackgroundColor3 = Theme.Border
	FooterDivider.BackgroundTransparency = 0.5
	FooterDivider.BorderSizePixel = 0
	FooterDivider.ZIndex = 2

	local Footer = Instance.new("TextLabel", MainFrame)
	Footer.Size = UDim2.new(1,0,0,FOOTER_H)
	Footer.Position = UDim2.new(0,0,1,-FOOTER_H)
	Footer.BackgroundTransparency = 1
	Footer.Text = config.Footer or ""
	Footer.TextColor3 = Theme.Muted
	Footer.Font = Enum.Font.Gotham
	Footer.TextSize = 10
	Footer.TextTransparency = 0.1
	Footer.ZIndex = 2

	-- ── Notification holder ──────────────────────────────────────────────────
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
	NotifyLayout.Padding = UDim.new(0,6)
	NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

	-- ── Resize handle ────────────────────────────────────────────────────────
	if config.Resizable then
		local ResizeHandle = Instance.new("TextButton", MainFrame)
		ResizeHandle.Size = UDim2.new(0, 18, 0, 18)
		ResizeHandle.AnchorPoint = Vector2.new(1, 1)
		ResizeHandle.Position = UDim2.new(1, 0, 1, 0)
		ResizeHandle.BackgroundColor3 = Theme.Border
		ResizeHandle.BackgroundTransparency = 0.5
		ResizeHandle.Text = ""
		ResizeHandle.AutoButtonColor = false
		ResizeHandle.ZIndex = 10
		Instance.new("UICorner", ResizeHandle).CornerRadius = UDim.new(0,4)

		-- small grip lines
		local grip = Instance.new("TextLabel", ResizeHandle)
		grip.Size = UDim2.new(1,0,1,0)
		grip.BackgroundTransparency = 1
		grip.Text = "⋱"
		grip.TextColor3 = Theme.Muted
		grip.TextSize = 12
		grip.Font = Enum.Font.GothamBold
		grip.ZIndex = 11

		local resizing, resizeStart, startSize = false, nil, nil
		maid:Add(ResizeHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = true
				resizeStart = input.Position
				startSize = Vector2.new(MainFrame.AbsoluteSize.X, MainFrame.AbsoluteSize.Y)
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then resizing = false end
				end)
			end
		end))
		maid:Add(UserInputService.InputChanged:Connect(function(input)
			if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - resizeStart
				local newW = math.clamp(startSize.X + delta.X, 260, 600)
				local newH = math.clamp(startSize.Y + delta.Y, 200, 700)
				MainFrame.Size = UDim2.new(0, newW, 0, newH)
			end
		end))
	end

	-- ── Drag ─────────────────────────────────────────────────────────────────
	local fullHeight = height
	local dragging, dragStart, startPos

	local function bindDrag(frame)
		maid:Add(frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = MainFrame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end))
	end
	bindDrag(HeaderFrame)
	bindDrag(HeaderBg)

	maid:Add(UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end))

	-- ── Title dot pulse ──────────────────────────────────────────────────────
	task.spawn(function()
		while TitleDot.Parent do
			TweenPlay(TitleDot, { BackgroundTransparency = 0 }, 1.4, Enum.EasingStyle.Sine)
			task.wait(1.4)
			TweenPlay(TitleDot, { BackgroundTransparency = 0.35 }, 1.4, Enum.EasingStyle.Sine)
			task.wait(1.4)
		end
	end)

	-- ── Tab system ────────────────────────────────────────────────────────────
	local tabs = {}
	local activeTab = nil

	local function switchTab(tabData)
		if activeTab == tabData then return end
		-- hide old
		if activeTab then
			activeTab.ScrollFrame.Visible = false
			TweenPlay(activeTab.SidebarBtn, {
				BackgroundColor3 = Theme.SidebarItem,
				TextColor3 = Theme.Muted,
			}, 0.15, Enum.EasingStyle.Quint)
			if activeTab.Indicator then
				TweenPlay(activeTab.Indicator, { BackgroundTransparency = 1 }, 0.15)
			end
		end
		activeTab = tabData
		tabData.ScrollFrame.Visible = true
		ActiveScroll = tabData.ScrollFrame
		TweenPlay(tabData.SidebarBtn, {
			BackgroundColor3 = Theme.SidebarActive,
			TextColor3 = Theme.AccentLight,
		}, 0.18, Enum.EasingStyle.Quint)
		if tabData.Indicator then
			TweenPlay(tabData.Indicator, { BackgroundTransparency = 0 }, 0.18)
		end
	end

	-- ── Main UI object ────────────────────────────────────────────────────────
	local UI = {
		Theme        = Theme,
		ScreenGui    = ScreenGui,
		Main         = MainFrame,
		Content      = DefaultScroll,
		Title        = Title,
		Subtitle     = Subtitle,
		Footer       = Footer,
		HeaderControls = HeaderControls,
		_maid        = maid,
		_configReg   = configRegistry,
		_searchIndex = searchIndex,
	}

	-- ── Visibility helpers ───────────────────────────────────────────────────
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

	function UI:Show()  animateVisibility(true)  end
	function UI:Hide()  animateVisibility(false) end
	function UI:Toggle() animateVisibility(not visible) end
	function UI:IsVisible() return visible end

	function UI:Destroy()
		pcall(function() ContextActionService:UnbindAction(toggleActionName) end)
		maid:Clean()
	end

	function UI:SetTheme(overrides)
		Theme = MergeTheme(overrides)
		UI.Theme = Theme
		-- live-refresh a few key surfaces
		MainFrame.BackgroundColor3 = Theme.Background
		HeaderBg.BackgroundColor3  = Theme.HeaderTop
		SidebarFrame.BackgroundColor3 = Theme.Sidebar
	end

	function UI:AddBadge(badgeConfig)
		badgeOrder += 1
		return CreateBadge(HeaderControls, badgeConfig, Theme, badgeOrder)
	end

	-- ── Toggle key (with modifier support) ───────────────────────────────────
	local toggleKey = config.ToggleKey
	local toggleModifier = config.ToggleModifier  -- optional e.g. Enum.KeyCode.LeftControl
	local lastToggle = 0
	local toggleLocked = false

	if toggleKey then
		local function handleToggle()
			if toggleLocked then return end
			local now = tick()
			if now - lastToggle < 0.2 then return end
			lastToggle = now
			toggleLocked = true
			UI:Toggle()
			task.delay(0.2, function() toggleLocked = false end)
		end

		maid:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
			if input.KeyCode ~= toggleKey then return end
			if toggleModifier then
				if not UserInputService:IsKeyDown(toggleModifier) then return end
			end
			if gameProcessed and not MODIFIER_KEYS[input.KeyCode] then return end
			handleToggle()
		end))

		pcall(function()
			ContextActionService:BindAction(toggleActionName, function(_, state)
				if state == Enum.UserInputState.Begin then handleToggle() end
				return Enum.ContextActionResult.Sink
			end, false, toggleKey)
		end)
	end

	-- ── Open animation ────────────────────────────────────────────────────────
	MainFrame.BackgroundTransparency = 1
	WindowScale.Scale = 0.94
	task.defer(function()
		TweenPlay(WindowScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Quint)
		TweenPlay(MainFrame, { BackgroundTransparency = FRAME_TRANSPARENCY }, 0.35, Enum.EasingStyle.Quint)
	end)

	-- ── Collapse ──────────────────────────────────────────────────────────────
	if CollapseBtn then
		maid:Add(CollapseBtn.MouseButton1Click:Connect(function()
			collapsed = not collapsed
			CollapseBtn.Text = collapsed and "+" or "−"
			local targetH = collapsed and HEADER_H + 4 or fullHeight
			TweenPlay(MainFrame, { Size = UDim2.new(0, width, 0, targetH) }, 0.28, Enum.EasingStyle.Quint)
			task.delay(0.05, function()
				ContentHost.Visible   = not collapsed
				HeaderDivider.Visible = not collapsed
				SidebarFrame.Visible  = not collapsed and #tabs > 0
				SidebarDivider.Visible = SidebarFrame.Visible
				Footer.Visible       = not collapsed
				FooterDivider.Visible = not collapsed
			end)
		end))
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- Shared widget builder helpers (bound to ActiveScroll dynamically)
	-- ─────────────────────────────────────────────────────────────────────────
	local function bindButtonPress(btn)
		local scale = Instance.new("UIScale", btn)
		maid:Add(btn.MouseButton1Down:Connect(function()
			TweenPlay(scale, { Scale = 0.96 }, 0.1, Enum.EasingStyle.Quint)
		end))
		local function release() TweenPlay(scale, { Scale = 1 }, 0.15, Enum.EasingStyle.Quint) end
		maid:Add(btn.MouseButton1Up:Connect(release))
		maid:Add(btn.MouseLeave:Connect(release))
	end

	local function setSwitchVisual(track, knob, isOn, animate)
		local onColor  = Color3.fromRGB(48,72,58)
		local offColor = Theme.Elevated
		local knobOn   = UDim2.new(1,-21,0.5,-9)
		local knobOff  = UDim2.new(0,3,0.5,-9)
		if animate then
			TweenPlay(track, { BackgroundColor3 = isOn and onColor or offColor }, 0.2, Enum.EasingStyle.Quint)
			TweenPlay(knob, { Position = isOn and knobOn or knobOff, BackgroundColor3 = isOn and Theme.Success or Theme.Muted }, 0.22, Enum.EasingStyle.Quint)
		else
			track.BackgroundColor3 = isOn and onColor or offColor
			knob.Position = isOn and knobOn or knobOff
			knob.BackgroundColor3 = isOn and Theme.Success or Theme.Muted
		end
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- TAB
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Tab(name)
		-- Show sidebar on first tab
		if #tabs == 0 then
			SidebarFrame.Visible = true
			SidebarDivider.Visible = true
			DefaultScroll.Visible = false
		end

		-- Sidebar button
		local sideBtn = Instance.new("TextButton", SidebarFrame)
		sideBtn.Size = UDim2.new(1,0,0,34)
		sideBtn.BackgroundColor3 = Theme.SidebarItem
		sideBtn.Text = name
		sideBtn.TextColor3 = Theme.Muted
		sideBtn.Font = Enum.Font.GothamMedium
		sideBtn.TextSize = 11
		sideBtn.AutoButtonColor = false
		sideBtn.TextXAlignment = Enum.TextXAlignment.Left
		sideBtn.LayoutOrder = #tabs + 1
		Instance.new("UICorner", sideBtn).CornerRadius = UDim.new(0,8)

		local sidePad = Instance.new("UIPadding", sideBtn)
		sidePad.PaddingLeft = UDim.new(0,10)
		sidePad.PaddingRight = UDim.new(0,8)

		-- accent indicator strip
		local indicator = Instance.new("Frame", sideBtn)
		indicator.Size = UDim2.new(0,3,0.6,0)
		indicator.AnchorPoint = Vector2.new(1,0.5)
		indicator.Position = UDim2.new(1,0,0.5,0)
		indicator.BackgroundColor3 = Theme.Accent
		indicator.BackgroundTransparency = 1
		indicator.BorderSizePixel = 0
		Instance.new("UICorner", indicator).CornerRadius = UDim.new(1,0)

		-- Tab scroll frame
		local tabScroll = Instance.new("ScrollingFrame", ContentHost)
		tabScroll.Name = "Tab_" .. name
		tabScroll.Size = UDim2.new(1, -SIDEBAR_W, 1, 0)
		tabScroll.Position = UDim2.new(0, SIDEBAR_W, 0, 0)
		tabScroll.BackgroundTransparency = 1
		tabScroll.BorderSizePixel = 0
		tabScroll.ScrollBarThickness = 3
		tabScroll.ScrollBarImageColor3 = Theme.AccentDim
		tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		tabScroll.CanvasSize = UDim2.new(0,0,0,0)
		tabScroll.Visible = false
		tabScroll.ZIndex = 2

		local tabLayout = Instance.new("UIListLayout", tabScroll)
		tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabLayout.Padding = UDim.new(0,8)
		tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

		local tabPad = Instance.new("UIPadding", tabScroll)
		tabPad.PaddingTop = UDim.new(0,6)
		tabPad.PaddingBottom = UDim.new(0,10)
		tabPad.PaddingLeft = UDim.new(0,PAD)
		tabPad.PaddingRight = UDim.new(0,PAD)

		local tabOrder = 0
		local function nextTabOrder() tabOrder += 1 return tabOrder end

		local tabData = {
			Name        = name,
			ScrollFrame = tabScroll,
			SidebarBtn  = sideBtn,
			Indicator   = indicator,
		}
		table.insert(tabs, tabData)

		maid:Add(sideBtn.MouseButton1Click:Connect(function()
			switchTab(tabData)
		end))
		maid:Add(sideBtn.MouseEnter:Connect(function()
			if activeTab ~= tabData then
				TweenPlay(sideBtn, { BackgroundColor3 = Theme.SurfaceHover })
			end
		end))
		maid:Add(sideBtn.MouseLeave:Connect(function()
			if activeTab ~= tabData then
				TweenPlay(sideBtn, { BackgroundColor3 = Theme.SidebarItem })
			end
		end))

		-- Auto-select first tab
		if #tabs == 1 then
			switchTab(tabData)
		end

		-- Tab API — mirrors main UI widget API but writes into tabScroll
		local Tab = {}

		local function tabNextOrder() return nextTabOrder() end
		local function getScroll() return tabScroll end

		-- forward all shared widget methods onto tab
		local function makeTabMethod(methodName)
			Tab[methodName] = function(self, ...)
				local prev = ActiveScroll
				ActiveScroll = tabScroll
				local result = UI[methodName](UI, ...)
				ActiveScroll = prev
				return result
			end
		end

		for _, m in ipairs({
			"Spacer","Section","Divider","Label","Button","Toggle",
			"ValueRow","Input","Slider","Dropdown","MultiDropdown",
			"Grid","Progress","Paragraph","Console","ColorPicker",
		}) do
			makeTabMethod(m)
		end

		return Tab
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- SPACER / SECTION / DIVIDER / LABEL
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Spacer(h)
		local s = Instance.new("Frame", ActiveScroll)
		s.Size = UDim2.new(1,0,0,h or 10)
		s.BackgroundTransparency = 1
		s.LayoutOrder = nextOrder()
		return s
	end

	function UI:Section(text)
		local holder = Instance.new("Frame", ActiveScroll)
		holder.Size = UDim2.new(1,0,0,22)
		holder.BackgroundTransparency = 1
		holder.LayoutOrder = nextOrder()
		local accent = Instance.new("Frame", holder)
		accent.Size = UDim2.new(0,2,0,10)
		accent.Position = UDim2.new(0,0,1,-12)
		accent.BackgroundColor3 = Theme.Border
		accent.BackgroundTransparency = 0.3
		accent.BorderSizePixel = 0
		Instance.new("UICorner", accent).CornerRadius = UDim.new(1,0)
		local label = Instance.new("TextLabel", holder)
		label.Size = UDim2.new(1,-8,1,0)
		label.Position = UDim2.new(0,8,0,0)
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
		local line = Instance.new("Frame", ActiveScroll)
		line.Size = UDim2.new(1,0,0,1)
		line.BackgroundColor3 = Theme.Border
		line.BackgroundTransparency = 0.45
		line.BorderSizePixel = 0
		line.LayoutOrder = nextOrder()
		return line
	end

	function UI:Label(text, muted)
		local label = Instance.new("TextLabel", ActiveScroll)
		label.Size = UDim2.new(1,0,0,18)
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

	-- ─────────────────────────────────────────────────────────────────────────
	-- PARAGRAPH
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Paragraph(options)
		options = options or {}
		local holder = Instance.new("Frame", ActiveScroll)
		holder.Size = UDim2.new(1,0,0,0)
		holder.AutomaticSize = Enum.AutomaticSize.Y
		holder.BackgroundColor3 = Theme.Surface
		holder.LayoutOrder = nextOrder()
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0,10)

		local pad = Instance.new("UIPadding", holder)
		pad.PaddingTop = UDim.new(0,10); pad.PaddingBottom = UDim.new(0,10)
		pad.PaddingLeft = UDim.new(0,14); pad.PaddingRight = UDim.new(0,14)

		local innerLayout = Instance.new("UIListLayout", holder)
		innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
		innerLayout.Padding = UDim.new(0,4)

		if options.Title and options.Title ~= "" then
			local titleLbl = Instance.new("TextLabel", holder)
			titleLbl.Size = UDim2.new(1,0,0,16)
			titleLbl.BackgroundTransparency = 1
			titleLbl.Text = options.Title
			titleLbl.TextColor3 = Theme.Text
			titleLbl.Font = Enum.Font.GothamBold
			titleLbl.TextSize = 12
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.LayoutOrder = 1
		end

		local contentLbl = Instance.new("TextLabel", holder)
		contentLbl.Size = UDim2.new(1,0,0,0)
		contentLbl.AutomaticSize = Enum.AutomaticSize.Y
		contentLbl.BackgroundTransparency = 1
		contentLbl.Text = options.Content or ""
		contentLbl.TextColor3 = Theme.Muted
		contentLbl.Font = Enum.Font.Gotham
		contentLbl.TextSize = 11
		contentLbl.TextXAlignment = Enum.TextXAlignment.Left
		contentLbl.TextWrapped = true
		contentLbl.LayoutOrder = 2

		return {
			Frame = holder,
			SetContent = function(text) contentLbl.Text = text end,
		}
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- CONSOLE / LOG
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Console(options)
		options = options or {}
		local maxLines = options.MaxLines or 80
		local lines = {}

		local outer = Instance.new("Frame", ActiveScroll)
		outer.Size = UDim2.new(1,0,0,options.Height or 120)
		outer.BackgroundColor3 = Color3.fromRGB(10,10,13)
		outer.LayoutOrder = nextOrder()
		Instance.new("UICorner", outer).CornerRadius = UDim.new(0,10)

		local outerStroke = Instance.new("UIStroke", outer)
		outerStroke.Color = Theme.Border; outerStroke.Thickness = 1; outerStroke.Transparency = 0.35

		-- title bar
		local titleBar = Instance.new("Frame", outer)
		titleBar.Size = UDim2.new(1,0,0,24)
		titleBar.BackgroundColor3 = Color3.fromRGB(18,18,22)
		titleBar.BorderSizePixel = 0
		Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,10)
		local titleLbl = Instance.new("TextLabel", titleBar)
		titleLbl.Size = UDim2.new(1,-8,1,0)
		titleLbl.Position = UDim2.new(0,8,0,0)
		titleLbl.BackgroundTransparency = 1
		titleLbl.Text = options.Title or "Console"
		titleLbl.TextColor3 = Theme.Muted
		titleLbl.Font = Enum.Font.GothamMedium
		titleLbl.TextSize = 10
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left

		-- clear button
		local clearBtn = Instance.new("TextButton", titleBar)
		clearBtn.Size = UDim2.new(0,40,0,16)
		clearBtn.AnchorPoint = Vector2.new(1,0.5)
		clearBtn.Position = UDim2.new(1,-4,0.5,0)
		clearBtn.BackgroundColor3 = Theme.Elevated
		clearBtn.Text = "Clear"
		clearBtn.TextColor3 = Theme.Muted
		clearBtn.Font = Enum.Font.GothamMedium
		clearBtn.TextSize = 9
		clearBtn.AutoButtonColor = false
		Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0,4)

		local scroll = Instance.new("ScrollingFrame", outer)
		scroll.Size = UDim2.new(1,0,1,-24)
		scroll.Position = UDim2.new(0,0,0,24)
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 2
		scroll.ScrollBarImageColor3 = Theme.AccentDim
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.CanvasSize = UDim2.new(0,0,0,0)

		local logLayout = Instance.new("UIListLayout", scroll)
		logLayout.SortOrder = Enum.SortOrder.LayoutOrder
		logLayout.Padding = UDim.new(0,1)
		local logPad = Instance.new("UIPadding", scroll)
		logPad.PaddingLeft = UDim.new(0,8); logPad.PaddingRight = UDim.new(0,8)
		logPad.PaddingTop = UDim.new(0,4); logPad.PaddingBottom = UDim.new(0,4)

		local typeColors = {
			print   = Theme.Text,
			warn    = Theme.Warning,
			error   = Theme.Danger,
			success = Theme.Success,
			info    = Theme.Info,
		}

		local lineOrder = 0
		local function addLine(text, lineType)
			lineOrder += 1
			local color = typeColors[lineType or "print"] or Theme.Text
			local lbl = Instance.new("TextLabel", scroll)
			lbl.Size = UDim2.new(1,0,0,0)
			lbl.AutomaticSize = Enum.AutomaticSize.Y
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.TextColor3 = color
			lbl.Font = Enum.Font.Code
			lbl.TextSize = 10
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.TextWrapped = true
			lbl.LayoutOrder = lineOrder
			table.insert(lines, lbl)
			-- trim
			if #lines > maxLines then
				local old = table.remove(lines, 1)
				pcall(function() old:Destroy() end)
			end
			-- scroll to bottom
			task.defer(function()
				scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
			end)
		end

		clearBtn.MouseButton1Click:Connect(function()
			for _, lbl in ipairs(lines) do pcall(function() lbl:Destroy() end) end
			lines = {}
		end)

		local consoleApi = {}
		function consoleApi:Print(text)   addLine(tostring(text), "print")   end
		function consoleApi:Warn(text)    addLine("⚠ " .. tostring(text), "warn")   end
		function consoleApi:Error(text)   addLine("✕ " .. tostring(text), "error")  end
		function consoleApi:Success(text) addLine("✓ " .. tostring(text), "success") end
		function consoleApi:Info(text)    addLine("i " .. tostring(text), "info")   end
		function consoleApi:Clear()
			for _, lbl in ipairs(lines) do pcall(function() lbl:Destroy() end) end
			lines = {}
		end
		return consoleApi
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- BUTTON
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Button(options)
		options = options or {}
		local style = options.Style or "Secondary"
		local btnH = options.Height or (style == "Primary" and 40 or 38)
		local isPrimary = style == "Primary"

		local btn = Instance.new("TextButton", ActiveScroll)
		btn.Size = UDim2.new(1,0,0,btnH)
		btn.BackgroundColor3 = isPrimary and Theme.Accent or Theme.Surface
		btn.Text = options.Text or "Button"
		btn.TextColor3 = isPrimary and Color3.fromRGB(255,255,255) or Theme.Text
		btn.Font = isPrimary and Enum.Font.GothamBold or Enum.Font.GothamMedium
		btn.TextSize = 12
		btn.LayoutOrder = nextOrder()
		btn.AutoButtonColor = false
		btn.TextYAlignment = Enum.TextYAlignment.Center
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

		local btnStroke = Instance.new("UIStroke", btn)
		btnStroke.Color = isPrimary and Theme.AccentLight or Theme.Border
		btnStroke.Thickness = 1
		btnStroke.Transparency = isPrimary and 0.45 or 0.55

		local defaultColor = btn.BackgroundColor3
		maid:Add(btn.MouseEnter:Connect(function()
			if isPrimary then
				TweenPlay(btn, { BackgroundColor3 = Theme.AccentLight })
				TweenPlay(btnStroke, { Transparency = 0.2 })
			else
				TweenPlay(btn, { BackgroundColor3 = Theme.SurfaceHover })
			end
		end))
		maid:Add(btn.MouseLeave:Connect(function()
			if isPrimary then
				TweenPlay(btn, { BackgroundColor3 = defaultColor })
				TweenPlay(btnStroke, { Transparency = 0.45 })
			else
				TweenPlay(btn, { BackgroundColor3 = Theme.Surface })
			end
		end))

		bindButtonPress(btn)
		if options.Callback then
			maid:Add(btn.MouseButton1Click:Connect(options.Callback))
		end
		table.insert(searchIndex, { label = options.Text or "Button", frame = btn })
		return btn
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- TOGGLE
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Toggle(options)
		options = options or {}
		local state = options.Default or false

		local row = Instance.new("Frame", ActiveScroll)
		row.Size = UDim2.new(1,0,0,42)
		row.BackgroundColor3 = Theme.Surface
		row.LayoutOrder = nextOrder()
		Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)

		local label = Instance.new("TextLabel", row)
		label.Size = UDim2.new(1,-68,1,0)
		label.Position = UDim2.new(0,14,0,0)
		label.BackgroundTransparency = 1
		label.Text = options.Text or "Toggle"
		label.TextColor3 = Theme.Text
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center

		local track = Instance.new("Frame", row)
		track.AnchorPoint = Vector2.new(1,0.5)
		track.Size = UDim2.new(0,46,0,22)
		track.Position = UDim2.new(1,-12,0.5,0)
		track.BackgroundColor3 = Theme.Elevated
		track.BorderSizePixel = 0
		Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

		local knob = Instance.new("Frame", track)
		knob.Size = UDim2.new(0,18,0,18)
		knob.Position = UDim2.new(0,3,0.5,-9)
		knob.BackgroundColor3 = Theme.Muted
		knob.BorderSizePixel = 0
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

		local hitbox = Instance.new("TextButton", row)
		hitbox.Size = UDim2.new(1,0,1,0)
		hitbox.BackgroundTransparency = 1
		hitbox.Text = ""; hitbox.ZIndex = 2

		local function getRowColor()
			if options.GetActiveColor then return options.GetActiveColor(state) end
			return state and Theme.ActiveRow or Theme.Surface
		end
		local function refresh(animate)
			setSwitchVisual(track, knob, state, animate ~= false)
			TweenPlay(row, { BackgroundColor3 = getRowColor() }, 0.2, Enum.EasingStyle.Quint)
		end

		maid:Add(hitbox.MouseEnter:Connect(function()
			TweenPlay(row, { BackgroundColor3 = Theme.SurfaceHover }, 0.15, Enum.EasingStyle.Quint)
		end))
		maid:Add(hitbox.MouseLeave:Connect(function()
			TweenPlay(row, { BackgroundColor3 = getRowColor() }, 0.15, Enum.EasingStyle.Quint)
		end))
		maid:Add(hitbox.MouseButton1Click:Connect(function()
			state = not state; refresh(true)
			if options.Callback then options.Callback(state) end
		end))
		refresh(false)

		local widget = {
			Row = row, Track = track, Knob = knob, Hitbox = hitbox,
			Get = function() return state end,
			Set = function(v) state = v and true or false; refresh(true) end,
			SetError = function(text_, dur)
				TweenPlay(track, { BackgroundColor3 = Color3.fromRGB(58,32,32) }, 0.15)
				TweenPlay(knob,  { BackgroundColor3 = Theme.Danger }, 0.15)
				task.delay(dur or 1.2, function() refresh(true) end)
			end,
			Refresh = refresh,
		}

		-- Dependency system
		function widget:SetVisible(visible_)
			row.Visible = visible_
		end
		function widget:Depends(otherWidget, invert)
			local function update(v)
				row.Visible = invert and not v or v
			end
			local origCb = options.Callback
			options.Callback = function(v)
				if origCb then origCb(v) end
				-- update any dependents bound to this
			end
			-- Watch otherWidget
			local origOtherCb = otherWidget.Hitbox and otherWidget.Hitbox.MouseButton1Click
			-- Simple polling approach to keep generic
			task.spawn(function()
				local last
				while row.Parent do
					local cur = otherWidget.Get()
					if cur ~= last then last = cur; update(cur) end
					task.wait(0.1)
				end
			end)
		end

		if options.Id then
			table.insert(configRegistry, { id = options.Id, type = "Toggle", widget = widget })
		end
		table.insert(searchIndex, { label = options.Text or "Toggle", frame = row })
		return widget
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- VALUE ROW
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:ValueRow(options)
		options = options or {}
		local row = Instance.new("Frame", ActiveScroll)
		row.Size = UDim2.new(1,0,0,42)
		row.BackgroundColor3 = Theme.Surface
		row.LayoutOrder = nextOrder()
		Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)

		local titleLabel = Instance.new("TextLabel", row)
		titleLabel.Size = UDim2.new(1,-80,0,16)
		titleLabel.Position = UDim2.new(0,14,0,7)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = options.Title or "Value"
		titleLabel.TextColor3 = Theme.Text
		titleLabel.Font = Enum.Font.GothamMedium
		titleLabel.TextSize = 12
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left

		local hintLabel = Instance.new("TextLabel", row)
		hintLabel.Size = UDim2.new(1,-80,0,12)
		hintLabel.Position = UDim2.new(0,14,0,23)
		hintLabel.BackgroundTransparency = 1
		hintLabel.Text = options.Hint or ""
		hintLabel.TextColor3 = Theme.Muted
		hintLabel.Font = Enum.Font.Gotham
		hintLabel.TextSize = 10
		hintLabel.TextXAlignment = Enum.TextXAlignment.Left

		local valueLabel = Instance.new("TextLabel", row)
		valueLabel.AnchorPoint = Vector2.new(1,0.5)
		valueLabel.Size = UDim2.new(0,52,0,26)
		valueLabel.Position = UDim2.new(1,-12,0.5,0)
		valueLabel.BackgroundColor3 = Theme.Elevated
		valueLabel.Text = tostring(options.Value or 0)
		valueLabel.TextColor3 = Theme.Accent
		valueLabel.Font = Enum.Font.GothamBold
		valueLabel.TextSize = 13
		valueLabel.TextYAlignment = Enum.TextYAlignment.Center
		Instance.new("UICorner", valueLabel).CornerRadius = UDim.new(0,8)

		local valueScale = Instance.new("UIScale", valueLabel)

		local hitbox = Instance.new("TextButton", row)
		hitbox.Size = UDim2.new(1,0,1,0)
		hitbox.BackgroundTransparency = 1
		hitbox.Text = ""; hitbox.ZIndex = 2

		maid:Add(hitbox.MouseEnter:Connect(function()
			TweenPlay(row, { BackgroundColor3 = Theme.SurfaceHover }, 0.15, Enum.EasingStyle.Quint)
		end))
		maid:Add(hitbox.MouseLeave:Connect(function()
			TweenPlay(row, { BackgroundColor3 = Theme.Surface }, 0.15, Enum.EasingStyle.Quint)
		end))
		if options.OnClick then
			maid:Add(hitbox.MouseButton1Click:Connect(function()
				local newValue = options.OnClick(tonumber(valueLabel.Text) or options.Value or 0)
				if newValue ~= nil then
					valueLabel.Text = tostring(newValue)
					TweenPlay(valueScale, { Scale = 1.12 }, 0.1, Enum.EasingStyle.Quint)
					task.delay(0.1, function() TweenPlay(valueScale, { Scale = 1 }, 0.15, Enum.EasingStyle.Quint) end)
				end
			end))
		end

		return {
			Row = row, ValueLabel = valueLabel,
			SetValue = function(v) valueLabel.Text = tostring(v) end,
			GetValue = function() return tonumber(valueLabel.Text) or 0 end,
		}
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- INPUT
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Input(options)
		options = options or {}
		local holder = Instance.new("Frame", ActiveScroll)
		holder.Size = UDim2.new(1,0,0,40)
		holder.BackgroundColor3 = Theme.Surface
		holder.LayoutOrder = nextOrder()
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0,10)

		local box = Instance.new("TextBox", holder)
		box.Size = UDim2.new(1,-24,1,-12)
		box.Position = UDim2.new(0,12,0,6)
		box.BackgroundTransparency = 1
		box.Text = ""
		box.PlaceholderText = options.Placeholder or "Enter text..."
		box.PlaceholderColor3 = Theme.Muted
		box.TextColor3 = Theme.Text
		box.Font = Enum.Font.Gotham
		box.TextSize = 12
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.ClearTextOnFocus = false

		maid:Add(box.Focused:Connect(function()
			TweenPlay(holder, { BackgroundColor3 = Theme.SurfaceHover }, 0.15, Enum.EasingStyle.Quint)
		end))
		maid:Add(box.FocusLost:Connect(function()
			TweenPlay(holder, { BackgroundColor3 = Theme.Surface }, 0.15, Enum.EasingStyle.Quint)
			if options.Callback then options.Callback(box.Text) end
		end))
		table.insert(searchIndex, { label = options.Placeholder or "Input", frame = holder })
		return box
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- SLIDER
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Slider(options)
		options = options or {}
		local min   = options.Min or 0
		local max   = options.Max or 100
		local step  = options.Step or 1
		local value = options.Default or min

		local holder = Instance.new("Frame", ActiveScroll)
		holder.Size = UDim2.new(1,0,0,52)
		holder.BackgroundColor3 = Theme.Surface
		holder.LayoutOrder = nextOrder()
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0,10)

		local label = Instance.new("TextLabel", holder)
		label.Size = UDim2.new(1,-60,0,18)
		label.Position = UDim2.new(0,14,0,8)
		label.BackgroundTransparency = 1
		label.Text = options.Text or "Slider"
		label.TextColor3 = Theme.Text
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left

		local valueLabel = Instance.new("TextLabel", holder)
		valueLabel.AnchorPoint = Vector2.new(1,0)
		valueLabel.Size = UDim2.new(0,40,0,18)
		valueLabel.Position = UDim2.new(1,-12,0,8)
		valueLabel.BackgroundTransparency = 1
		valueLabel.Text = tostring(value)
		valueLabel.TextColor3 = Theme.Accent
		valueLabel.Font = Enum.Font.GothamBold
		valueLabel.TextSize = 12

		local track = Instance.new("Frame", holder)
		track.Size = UDim2.new(1,-28,0,6)
		track.Position = UDim2.new(0,14,0,34)
		track.BackgroundColor3 = Theme.Elevated
		track.BorderSizePixel = 0
		Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

		local fill = Instance.new("Frame", track)
		fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
		fill.BackgroundColor3 = Theme.Accent
		fill.BorderSizePixel = 0
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

		local knob = Instance.new("TextButton", track)
		knob.AnchorPoint = Vector2.new(0.5,0.5)
		knob.Size = UDim2.new(0,14,0,14)
		knob.Position = UDim2.new((value-min)/(max-min),0,0.5,0)
		knob.BackgroundColor3 = Theme.Text
		knob.Text = ""; knob.AutoButtonColor = false
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

		local function setValue(newValue, fire)
			value = math.clamp(math.floor((newValue-min)/step+0.5)*step+min, min, max)
			local alpha = (value-min)/(max-min)
			TweenPlay(fill, { Size = UDim2.new(alpha,0,1,0) }, 0.12, Enum.EasingStyle.Quint)
			TweenPlay(knob, { Position = UDim2.new(alpha,0,0.5,0) }, 0.12, Enum.EasingStyle.Quint)
			valueLabel.Text = tostring(value)
			if fire and options.Callback then options.Callback(value) end
		end

		local sliding = false
		maid:Add(knob.MouseButton1Down:Connect(function() sliding = true end))
		maid:Add(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
		end))
		maid:Add(UserInputService.InputChanged:Connect(function(input)
			if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
				local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				setValue(min + (max-min)*rel, true)
			end
		end))
		maid:Add(track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				setValue(min + (max-min)*rel, true)
			end
		end))

		local widget = {
			Set = function(v, fire) setValue(v, fire) end,
			Get = function() return value end,
		}
		if options.Id then
			table.insert(configRegistry, { id = options.Id, type = "Slider", widget = widget })
		end
		table.insert(searchIndex, { label = options.Text or "Slider", frame = holder })
		return widget
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- DROPDOWN
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Dropdown(options)
		options = options or {}
		local open     = false
		local selected = options.Default or (options.Options and options.Options[1]) or ""
		local optionList = options.Options or {}
		local optionCount = #optionList

		local holder = Instance.new("Frame", ActiveScroll)
		holder.Size = UDim2.new(1,0,0,40)
		holder.BackgroundColor3 = Theme.Surface
		holder.LayoutOrder = nextOrder()
		holder.ClipsDescendants = true
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0,10)

		local topRow = Instance.new("Frame", holder)
		topRow.Size = UDim2.new(1,0,0,40)
		topRow.BackgroundTransparency = 1; topRow.ZIndex = 2

		local label = Instance.new("TextLabel", topRow)
		label.Size = UDim2.new(0.45,0,1,0)
		label.Position = UDim2.new(0,14,0,0)
		label.BackgroundTransparency = 1
		label.Text = options.Text or "Select"
		label.TextColor3 = Theme.Text
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center

		local display = Instance.new("TextButton", topRow)
		display.AnchorPoint = Vector2.new(1,0.5)
		display.Size = UDim2.new(0,120,0,28)
		display.Position = UDim2.new(1,-12,0.5,0)
		display.BackgroundColor3 = Theme.Elevated
		display.Text = tostring(selected) .. "  ▾"
		display.TextColor3 = Theme.Text
		display.Font = Enum.Font.GothamMedium
		display.TextSize = 11
		display.AutoButtonColor = false; display.ZIndex = 3
		Instance.new("UICorner", display).CornerRadius = UDim.new(0,8)
		local dispStroke = Instance.new("UIStroke", display)
		dispStroke.Color = Theme.Border; dispStroke.Thickness = 1; dispStroke.Transparency = 0.45

		local divider = Instance.new("Frame", holder)
		divider.Size = UDim2.new(1,-16,0,1)
		divider.Position = UDim2.new(0,8,0,40)
		divider.BackgroundColor3 = Theme.Border; divider.BackgroundTransparency = 0.5
		divider.BorderSizePixel = 0; divider.Visible = false; divider.ZIndex = 2

		local list = Instance.new("Frame", holder)
		list.Size = UDim2.new(1,-16,0,0)
		list.Position = UDim2.new(0,8,0,41)
		list.BackgroundTransparency = 1; list.Visible = false
		list.ClipsDescendants = true; list.ZIndex = 2

		local listLayout = Instance.new("UIListLayout", list)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding = UDim.new(0,4)
		local listPad = Instance.new("UIPadding", list)
		listPad.PaddingTop = UDim.new(0,4); listPad.PaddingBottom = UDim.new(0,6)

		local function getListHeight()
			if optionCount == 0 then return 0 end
			return optionCount * 32 + (optionCount-1)*4 + 10
		end
		local function setOpen(s)
			open = s
			local lh = open and getListHeight() or 0
			list.Visible = open and lh > 0
			divider.Visible = list.Visible
			display.Text = tostring(selected) .. (open and "  ▴" or "  ▾")
			TweenPlay(list, { Size = UDim2.new(1,-16,0,lh) }, 0.2, Enum.EasingStyle.Quint)
			TweenPlay(holder, { Size = UDim2.new(1,0,0,40+lh) }, 0.2, Enum.EasingStyle.Quint)
		end

		for i, option in ipairs(optionList) do
			local optBtn = Instance.new("TextButton", list)
			optBtn.Size = UDim2.new(1,0,0,32)
			optBtn.BackgroundColor3 = Theme.Elevated
			optBtn.Text = tostring(option)
			optBtn.TextColor3 = Theme.Text
			optBtn.Font = Enum.Font.GothamMedium
			optBtn.TextSize = 11; optBtn.AutoButtonColor = false
			optBtn.LayoutOrder = i
			Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0,8)
			local optStroke = Instance.new("UIStroke", optBtn)
			optStroke.Color = Theme.Border; optStroke.Thickness = 1; optStroke.Transparency = 0.55
			maid:Add(optBtn.MouseEnter:Connect(function()
				TweenPlay(optBtn, { BackgroundColor3 = Theme.SurfaceHover })
				TweenPlay(optStroke, { Color = Theme.Accent, Transparency = 0.25 })
			end))
			maid:Add(optBtn.MouseLeave:Connect(function()
				TweenPlay(optBtn, { BackgroundColor3 = Theme.Elevated })
				TweenPlay(optStroke, { Color = Theme.Border, Transparency = 0.55 })
			end))
			maid:Add(optBtn.MouseButton1Click:Connect(function()
				selected = option
				display.Text = tostring(selected) .. "  ▾"
				setOpen(false)
				if options.Callback then options.Callback(selected) end
			end))
		end

		maid:Add(display.MouseEnter:Connect(function()
			TweenPlay(display, { BackgroundColor3 = Theme.SurfaceHover })
		end))
		maid:Add(display.MouseLeave:Connect(function()
			TweenPlay(display, { BackgroundColor3 = Theme.Elevated })
		end))
		maid:Add(display.MouseButton1Click:Connect(function()
			if optionCount == 0 then return end
			setOpen(not open)
		end))

		local widget = {
			Get   = function() return selected end,
			Set   = function(v) selected = v; display.Text = tostring(selected) .. (open and "  ▴" or "  ▾") end,
			Close = function() setOpen(false) end,
		}
		if options.Id then
			table.insert(configRegistry, { id = options.Id, type = "Dropdown", widget = widget })
		end
		table.insert(searchIndex, { label = options.Text or "Dropdown", frame = holder })
		return widget
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- MULTI DROPDOWN
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:MultiDropdown(options)
		options = options or {}
		local open = false
		local optionList = options.Options or {}
		local optionCount = #optionList
		local selected = {}
		if options.Default then
			for _, v in ipairs(options.Default) do selected[v] = true end
		end

		local holder = Instance.new("Frame", ActiveScroll)
		holder.Size = UDim2.new(1,0,0,40)
		holder.BackgroundColor3 = Theme.Surface
		holder.LayoutOrder = nextOrder()
		holder.ClipsDescendants = true
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0,10)

		local topRow = Instance.new("Frame", holder)
		topRow.Size = UDim2.new(1,0,0,40); topRow.BackgroundTransparency = 1; topRow.ZIndex = 2

		local label = Instance.new("TextLabel", topRow)
		label.Size = UDim2.new(0.45,0,1,0)
		label.Position = UDim2.new(0,14,0,0)
		label.BackgroundTransparency = 1
		label.Text = options.Text or "Multi-Select"
		label.TextColor3 = Theme.Text
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center

		local function selectedText()
			local keys = {}
			for k, v in pairs(selected) do if v then table.insert(keys, k) end end
			if #keys == 0 then return "None  ▾" end
			if #keys == 1 then return keys[1] .. "  ▾" end
			return tostring(#keys) .. " selected  ▾"
		end

		local display = Instance.new("TextButton", topRow)
		display.AnchorPoint = Vector2.new(1,0.5)
		display.Size = UDim2.new(0,120,0,28)
		display.Position = UDim2.new(1,-12,0.5,0)
		display.BackgroundColor3 = Theme.Elevated
		display.Text = selectedText()
		display.TextColor3 = Theme.Text
		display.Font = Enum.Font.GothamMedium
		display.TextSize = 11; display.AutoButtonColor = false; display.ZIndex = 3
		Instance.new("UICorner", display).CornerRadius = UDim.new(0,8)

		local list = Instance.new("Frame", holder)
		list.Size = UDim2.new(1,-16,0,0)
		list.Position = UDim2.new(0,8,0,41)
		list.BackgroundTransparency = 1; list.Visible = false
		list.ClipsDescendants = true; list.ZIndex = 2
		local listLayout = Instance.new("UIListLayout", list)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding = UDim.new(0,4)
		local listPad = Instance.new("UIPadding", list)
		listPad.PaddingTop = UDim.new(0,4); listPad.PaddingBottom = UDim.new(0,6)

		local optionBtns = {}
		local function getListHeight()
			if optionCount == 0 then return 0 end
			return optionCount * 32 + (optionCount-1)*4 + 10
		end
		local function setOpen(s)
			open = s
			local lh = open and getListHeight() or 0
			list.Visible = open and lh > 0
			display.Text = selectedText():gsub("▾", open and "▴" or "▾")
			TweenPlay(list, { Size = UDim2.new(1,-16,0,lh) }, 0.2, Enum.EasingStyle.Quint)
			TweenPlay(holder, { Size = UDim2.new(1,0,0,40+lh) }, 0.2, Enum.EasingStyle.Quint)
		end
		local function refreshBtn(optBtn, option)
			local isOn = selected[option]
			TweenPlay(optBtn, { BackgroundColor3 = isOn and Color3.fromRGB(28,42,36) or Theme.Elevated })
			optBtn.TextColor3 = isOn and Theme.Success or Theme.Text
		end

		for i, option in ipairs(optionList) do
			local optBtn = Instance.new("TextButton", list)
			optBtn.Size = UDim2.new(1,0,0,32)
			optBtn.BackgroundColor3 = Theme.Elevated
			optBtn.Text = "  " .. tostring(option)
			optBtn.TextColor3 = Theme.Text
			optBtn.Font = Enum.Font.GothamMedium
			optBtn.TextSize = 11; optBtn.AutoButtonColor = false
			optBtn.TextXAlignment = Enum.TextXAlignment.Left
			optBtn.LayoutOrder = i
			Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0,8)
			table.insert(optionBtns, { btn = optBtn, option = option })
			refreshBtn(optBtn, option)

			maid:Add(optBtn.MouseButton1Click:Connect(function()
				selected[option] = not selected[option]
				refreshBtn(optBtn, option)
				display.Text = selectedText():gsub("▾", open and "▴" or "▾")
				if options.Callback then
					local out = {}
					for k, v in pairs(selected) do if v then out[k] = true end end
					options.Callback(out)
				end
			end))
		end

		maid:Add(display.MouseButton1Click:Connect(function()
			if optionCount == 0 then return end
			setOpen(not open)
		end))

		return {
			Get = function()
				local out = {}
				for k, v in pairs(selected) do if v then out[k] = true end end
				return out
			end,
			Set = function(tbl)
				selected = tbl or {}
				for _, pair in ipairs(optionBtns) do refreshBtn(pair.btn, pair.option) end
				display.Text = selectedText()
			end,
			Close = function() setOpen(false) end,
		}
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- COLOR PICKER (HSV square + hue bar + alpha + hex input)
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:ColorPicker(options)
		options = options or {}
		local currentColor = options.Default or Color3.fromRGB(255,100,100)
		local h, s, v = Color3ToHSV(currentColor)
		local alpha = options.DefaultAlpha or 1
		local open = false

		local holder = Instance.new("Frame", ActiveScroll)
		holder.Size = UDim2.new(1,0,0,40)
		holder.BackgroundColor3 = Theme.Surface
		holder.LayoutOrder = nextOrder()
		holder.ClipsDescendants = true
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0,10)

		-- Top row
		local topRow = Instance.new("Frame", holder)
		topRow.Size = UDim2.new(1,0,0,40); topRow.BackgroundTransparency = 1; topRow.ZIndex = 2

		local rowLabel = Instance.new("TextLabel", topRow)
		rowLabel.Size = UDim2.new(0.55,0,1,0)
		rowLabel.Position = UDim2.new(0,14,0,0)
		rowLabel.BackgroundTransparency = 1
		rowLabel.Text = options.Text or "Color"
		rowLabel.TextColor3 = Theme.Text
		rowLabel.Font = Enum.Font.GothamMedium
		rowLabel.TextSize = 12
		rowLabel.TextXAlignment = Enum.TextXAlignment.Left
		rowLabel.TextYAlignment = Enum.TextYAlignment.Center

		local swatch = Instance.new("TextButton", topRow)
		swatch.AnchorPoint = Vector2.new(1,0.5)
		swatch.Size = UDim2.new(0,60,0,24)
		swatch.Position = UDim2.new(1,-12,0.5,0)
		swatch.BackgroundColor3 = currentColor
		swatch.Text = ""
		swatch.AutoButtonColor = false; swatch.ZIndex = 3
		Instance.new("UICorner", swatch).CornerRadius = UDim.new(0,8)
		local swatchStroke = Instance.new("UIStroke", swatch)
		swatchStroke.Color = Theme.Border; swatchStroke.Thickness = 1; swatchStroke.Transparency = 0.45

		-- Picker panel
		local PANEL_H = 188
		local panel = Instance.new("Frame", holder)
		panel.Size = UDim2.new(1,-16,0,0)
		panel.Position = UDim2.new(0,8,0,44)
		panel.BackgroundTransparency = 1
		panel.Visible = false; panel.ClipsDescendants = false; panel.ZIndex = 2

		-- SV Square (saturation/value)
		local SQ = 140
		local svFrame = Instance.new("Frame", panel)
		svFrame.Size = UDim2.new(0,SQ,0,SQ)
		svFrame.Position = UDim2.new(0,0,0,0)
		svFrame.BackgroundColor3 = HSVToColor3(h,1,1)
		svFrame.BorderSizePixel = 0
		Instance.new("UICorner", svFrame).CornerRadius = UDim.new(0,6)

		-- white->transparent gradient (left saturation axis)
		local satGrad = Instance.new("UIGradient", svFrame)
		satGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
		})
		satGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		})

		-- black overlay for value axis
		local valOverlay = Instance.new("Frame", svFrame)
		valOverlay.Size = UDim2.new(1,0,1,0)
		valOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
		valOverlay.BackgroundTransparency = 0
		valOverlay.BorderSizePixel = 0
		Instance.new("UICorner", valOverlay).CornerRadius = UDim.new(0,6)
		local valGrad = Instance.new("UIGradient", valOverlay)
		valGrad.Rotation = 270
		valGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
		})
		valGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		})

		-- SV cursor
		local svCursor = Instance.new("Frame", svFrame)
		svCursor.Size = UDim2.new(0,10,0,10)
		svCursor.AnchorPoint = Vector2.new(0.5,0.5)
		svCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
		svCursor.BorderSizePixel = 0
		svCursor.ZIndex = 5
		Instance.new("UICorner", svCursor).CornerRadius = UDim.new(1,0)
		local svCursorStroke = Instance.new("UIStroke", svCursor)
		svCursorStroke.Color = Color3.fromRGB(30,30,30); svCursorStroke.Thickness = 1.5

		-- Hue bar (right of SV)
		local hueBar = Instance.new("Frame", panel)
		hueBar.Size = UDim2.new(0,14,0,SQ)
		hueBar.Position = UDim2.new(0,SQ+6,0,0)
		hueBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
		hueBar.BorderSizePixel = 0
		Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0,4)

		local hueGrad = Instance.new("UIGradient", hueBar)
		hueGrad.Rotation = 270
		hueGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0,   Color3.fromHSV(0,1,1)),
			ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6,1,1)),
			ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6,1,1)),
			ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6,1,1)),
			ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6,1,1)),
			ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6,1,1)),
			ColorSequenceKeypoint.new(1,   Color3.fromHSV(1,1,1)),
		})

		local hueCursor = Instance.new("Frame", hueBar)
		hueCursor.Size = UDim2.new(1,4,0,4)
		hueCursor.AnchorPoint = Vector2.new(0.5,0.5)
		hueCursor.Position = UDim2.new(0.5,0,1-h,0)
		hueCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
		hueCursor.BorderSizePixel = 0; hueCursor.ZIndex = 5
		Instance.new("UICorner", hueCursor).CornerRadius = UDim.new(0,2)
		local hueCursorStroke = Instance.new("UIStroke", hueCursor)
		hueCursorStroke.Color = Color3.fromRGB(30,30,30); hueCursorStroke.Thickness = 1.5

		-- Alpha bar
		local alphaBar = Instance.new("Frame", panel)
		alphaBar.Size = UDim2.new(0,14,0,SQ)
		alphaBar.Position = UDim2.new(0,SQ+6+14+4,0,0)
		alphaBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
		alphaBar.BorderSizePixel = 0
		Instance.new("UICorner", alphaBar).CornerRadius = UDim.new(0,4)

		local alphaGrad = Instance.new("UIGradient", alphaBar)
		alphaGrad.Rotation = 270
		alphaGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
		})
		alphaGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		})

		local alphaCursor = Instance.new("Frame", alphaBar)
		alphaCursor.Size = UDim2.new(1,4,0,4)
		alphaCursor.AnchorPoint = Vector2.new(0.5,0.5)
		alphaCursor.Position = UDim2.new(0.5,0,1-alpha,0)
		alphaCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
		alphaCursor.BorderSizePixel = 0; alphaCursor.ZIndex = 5
		Instance.new("UICorner", alphaCursor).CornerRadius = UDim.new(0,2)
		local alphaCursorStroke = Instance.new("UIStroke", alphaCursor)
		alphaCursorStroke.Color = Color3.fromRGB(30,30,30); alphaCursorStroke.Thickness = 1.5

		-- Hex input
		local hexBox = Instance.new("TextBox", panel)
		hexBox.Size = UDim2.new(0,SQ,0,26)
		hexBox.Position = UDim2.new(0,0,0,SQ+6)
		hexBox.BackgroundColor3 = Theme.Elevated
		hexBox.Text = RGBToHex(currentColor)
		hexBox.PlaceholderText = "RRGGBB"
		hexBox.PlaceholderColor3 = Theme.Muted
		hexBox.TextColor3 = Theme.Text
		hexBox.Font = Enum.Font.Code; hexBox.TextSize = 11
		hexBox.ClearTextOnFocus = false
		Instance.new("UICorner", hexBox).CornerRadius = UDim.new(0,6)
		local hexPad = Instance.new("UIPadding", hexBox)
		hexPad.PaddingLeft = UDim.new(0,8)

		-- Preview swatch (small, in panel)
		local previewSwatch = Instance.new("Frame", panel)
		previewSwatch.Size = UDim2.new(0,26,0,26)
		previewSwatch.Position = UDim2.new(0,SQ+6,0,SQ+6)
		previewSwatch.BackgroundColor3 = currentColor
		previewSwatch.BorderSizePixel = 0
		Instance.new("UICorner", previewSwatch).CornerRadius = UDim.new(0,6)

		local function computeColor()
			return HSVToColor3(h, s, v)
		end

		local function notifyChange()
			currentColor = computeColor()
			swatch.BackgroundColor3 = currentColor
			previewSwatch.BackgroundColor3 = currentColor
			hexBox.Text = RGBToHex(currentColor)
			if options.Callback then options.Callback(currentColor, alpha) end
		end

		local function updateSVCursor()
			svCursor.Position = UDim2.new(s, 0, 1-v, 0)
		end
		local function updateHueCursor()
			hueCursor.Position = UDim2.new(0.5,0,1-h,0)
			svFrame.BackgroundColor3 = HSVToColor3(h,1,1)
		end
		local function updateAlphaCursor()
			alphaCursor.Position = UDim2.new(0.5,0,1-alpha,0)
		end
		updateSVCursor(); updateHueCursor(); updateAlphaCursor()

		-- SV drag
		local svDragging = false
		maid:Add(svFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				svDragging = true
				local rx = math.clamp((input.Position.X - svFrame.AbsolutePosition.X)/svFrame.AbsoluteSize.X,0,1)
				local ry = math.clamp((input.Position.Y - svFrame.AbsolutePosition.Y)/svFrame.AbsoluteSize.Y,0,1)
				s = rx; v = 1-ry
				updateSVCursor(); notifyChange()
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then svDragging = false end
				end)
			end
		end))
		maid:Add(UserInputService.InputChanged:Connect(function(input)
			if svDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local rx = math.clamp((input.Position.X - svFrame.AbsolutePosition.X)/svFrame.AbsoluteSize.X,0,1)
				local ry = math.clamp((input.Position.Y - svFrame.AbsolutePosition.Y)/svFrame.AbsoluteSize.Y,0,1)
				s = rx; v = 1-ry
				updateSVCursor(); notifyChange()
			end
		end))

		-- Hue drag
		local hueDragging = false
		maid:Add(hueBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				hueDragging = true
				h = 1 - math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y)/hueBar.AbsoluteSize.Y,0,1)
				updateHueCursor(); notifyChange()
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then hueDragging = false end
				end)
			end
		end))
		maid:Add(UserInputService.InputChanged:Connect(function(input)
			if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				h = 1 - math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y)/hueBar.AbsoluteSize.Y,0,1)
				updateHueCursor(); notifyChange()
			end
		end))

		-- Alpha drag
		local alphaDragging = false
		maid:Add(alphaBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				alphaDragging = true
				alpha = 1 - math.clamp((input.Position.Y - alphaBar.AbsolutePosition.Y)/alphaBar.AbsoluteSize.Y,0,1)
				updateAlphaCursor(); notifyChange()
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then alphaDragging = false end
				end)
			end
		end))
		maid:Add(UserInputService.InputChanged:Connect(function(input)
			if alphaDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				alpha = 1 - math.clamp((input.Position.Y - alphaBar.AbsolutePosition.Y)/alphaBar.AbsoluteSize.Y,0,1)
				updateAlphaCursor(); notifyChange()
			end
		end))

		-- Hex input
		maid:Add(hexBox.FocusLost:Connect(function()
			local c = HexToColor3(hexBox.Text)
			if c then
				currentColor = c
				h, s, v = Color3ToHSV(c)
				updateSVCursor(); updateHueCursor()
				swatch.BackgroundColor3 = c
				previewSwatch.BackgroundColor3 = c
				if options.Callback then options.Callback(c, alpha) end
			else
				hexBox.Text = RGBToHex(currentColor)
			end
		end))

		-- Open/close toggle
		local function setPickerOpen(state)
			open = state
			local pHeight = open and (PANEL_H) or 0
			panel.Visible = open
			TweenPlay(holder, { Size = UDim2.new(1,0,0,40 + pHeight) }, 0.22, Enum.EasingStyle.Quint)
		end

		maid:Add(swatch.MouseButton1Click:Connect(function()
			setPickerOpen(not open)
		end))

		local widget = {
			Get = function() return currentColor, alpha end,
			Set = function(color, a)
				currentColor = color; alpha = a or alpha
				h, s, v = Color3ToHSV(color)
				updateSVCursor(); updateHueCursor(); updateAlphaCursor()
				swatch.BackgroundColor3 = color
				previewSwatch.BackgroundColor3 = color
				hexBox.Text = RGBToHex(color)
			end,
			Close = function() setPickerOpen(false) end,
		}
		table.insert(searchIndex, { label = options.Text or "ColorPicker", frame = holder })
		return widget
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- GRID
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Grid(options)
		options = options or {}
		local gridFrame = Instance.new("Frame", ActiveScroll)
		gridFrame.Size = UDim2.new(1,0,0,0)
		gridFrame.AutomaticSize = Enum.AutomaticSize.Y
		gridFrame.BackgroundTransparency = 1
		gridFrame.LayoutOrder = nextOrder()

		local grid = Instance.new("UIGridLayout", gridFrame)
		grid.CellSize = UDim2.new(0, options.CellW or 130, 0, options.CellH or 30)
		grid.CellPadding = UDim2.new(0, options.Padding or 8, 0, options.Padding or 8)
		grid.FillDirectionMaxCells = options.Columns or 2
		grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
		grid.SortOrder = Enum.SortOrder.LayoutOrder

		local gridApi = {}
		function gridApi:Button(text, callback)
			local pBtn = Instance.new("TextButton", gridFrame)
			pBtn.BackgroundColor3 = Theme.Surface
			pBtn.Text = text; pBtn.TextColor3 = Theme.Muted
			pBtn.Font = Enum.Font.GothamMedium; pBtn.TextSize = 11
			pBtn.AutoButtonColor = false
			Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0,8)
			local stroke = Instance.new("UIStroke", pBtn)
			stroke.Color = Theme.Border; stroke.Thickness = 1; stroke.Transparency = 0.4
			local btnScale = Instance.new("UIScale", pBtn)

			maid:Add(pBtn.MouseEnter:Connect(function()
				TweenPlay(pBtn, { BackgroundColor3 = Theme.SurfaceHover, TextColor3 = Theme.Text })
				TweenPlay(stroke, { Color = Theme.Accent, Transparency = 0.15 })
			end))
			maid:Add(pBtn.MouseLeave:Connect(function()
				TweenPlay(pBtn, { BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Muted })
				TweenPlay(stroke, { Color = Theme.Border, Transparency = 0.4 })
			end))
			maid:Add(pBtn.MouseButton1Down:Connect(function()
				TweenPlay(btnScale, { Scale = 0.95 }, 0.08, Enum.EasingStyle.Quint)
			end))
			maid:Add(pBtn.MouseButton1Up:Connect(function()
				TweenPlay(btnScale, { Scale = 1 }, 0.12, Enum.EasingStyle.Quint)
			end))
			if callback then
				maid:Add(pBtn.MouseButton1Click:Connect(function()
					callback()
					TweenPlay(pBtn, { BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text })
					TweenPlay(stroke, { Color = Theme.Accent, Transparency = 0 })
					task.delay(0.35, function()
						TweenPlay(pBtn, { BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Muted })
						TweenPlay(stroke, { Color = Theme.Border, Transparency = 0.4 })
					end)
				end))
			end
			return pBtn
		end
		return gridApi
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- PROGRESS
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Progress(options)
		options = options or {}
		local value = math.clamp(options.Value or 0, 0, 1)
		local holder = Instance.new("Frame", ActiveScroll)
		holder.Size = UDim2.new(1,0,0,34)
		holder.BackgroundTransparency = 1; holder.LayoutOrder = nextOrder()
		local label = Instance.new("TextLabel", holder)
		label.Size = UDim2.new(1,0,0,14)
		label.BackgroundTransparency = 1; label.Text = options.Text or "Progress"
		label.TextColor3 = Theme.Muted; label.Font = Enum.Font.Gotham; label.TextSize = 10
		label.TextXAlignment = Enum.TextXAlignment.Left
		local track = Instance.new("Frame", holder)
		track.Size = UDim2.new(1,0,0,6); track.Position = UDim2.new(0,0,0,20)
		track.BackgroundColor3 = Theme.Elevated; track.BorderSizePixel = 0
		Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
		local fill = Instance.new("Frame", track)
		fill.Size = UDim2.new(value,0,1,0)
		fill.BackgroundColor3 = Theme.Accent; fill.BorderSizePixel = 0
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
		return {
			Set = function(newVal)
				value = math.clamp(newVal, 0, 1)
				TweenPlay(fill, { Size = UDim2.new(value,0,1,0) }, 0.25, Enum.EasingStyle.Quint)
			end,
			Get = function() return value end,
		}
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- NOTIFY (with optional action buttons)
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Notify(options)
		options = options or {}
		local notifyType = options.Type or "Info"
		local duration   = options.Duration or 3
		local buttons    = options.Buttons or {}

		local palette = {
			Success = { accent = Theme.Success, bg = Color3.fromRGB(22,36,30), icon = "✓", title = "Success" },
			Error   = { accent = Theme.Danger,  bg = Color3.fromRGB(38,22,24), icon = "✕", title = "Error" },
			Warning = { accent = Theme.Warning, bg = Color3.fromRGB(38,32,20), icon = "!",  title = "Warning" },
			Info    = { accent = Theme.Info,    bg = Color3.fromRGB(22,28,38), icon = "i",  title = "Info" },
		}
		local style    = palette[notifyType] or palette.Info
		local titleText = options.Title or style.title
		local bodyText  = options.Text or options.Description or "Notification"

		local toast = Instance.new("Frame", NotifyHolder)
		toast.Size = UDim2.new(1,0,0,0)
		toast.AutomaticSize = Enum.AutomaticSize.Y
		toast.BackgroundColor3 = style.bg
		toast.BackgroundTransparency = 1
		toast.LayoutOrder = math.floor(tick() * 1000)
		Instance.new("UICorner", toast).CornerRadius = UDim.new(0,10)
		local toastStroke = Instance.new("UIStroke", toast)
		toastStroke.Color = style.accent; toastStroke.Thickness = 1; toastStroke.Transparency = 0.55

		local accentBar = Instance.new("Frame", toast)
		accentBar.Size = UDim2.new(0,4,1,-8)
		accentBar.Position = UDim2.new(0,0,0,4)
		accentBar.BackgroundColor3 = style.accent; accentBar.BorderSizePixel = 0
		Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0,2)

		local icon = Instance.new("TextLabel", toast)
		icon.Size = UDim2.new(0,22,0,22)
		icon.Position = UDim2.new(0,12,0,10)
		icon.BackgroundColor3 = style.accent; icon.BackgroundTransparency = 0.82
		icon.Text = style.icon; icon.TextColor3 = style.accent
		icon.Font = Enum.Font.GothamBold; icon.TextSize = 12
		Instance.new("UICorner", icon).CornerRadius = UDim.new(1,0)

		local titleLbl = Instance.new("TextLabel", toast)
		titleLbl.Size = UDim2.new(1,-52,0,16)
		titleLbl.Position = UDim2.new(0,40,0,8)
		titleLbl.BackgroundTransparency = 1
		titleLbl.Text = titleText; titleLbl.TextColor3 = Theme.Text; titleLbl.TextTransparency = 1
		titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextSize = 12; titleLbl.TextXAlignment = Enum.TextXAlignment.Left

		local textLbl = Instance.new("TextLabel", toast)
		textLbl.Size = UDim2.new(1,-52,0,0)
		textLbl.Position = UDim2.new(0,40,0,24)
		textLbl.AutomaticSize = Enum.AutomaticSize.Y
		textLbl.BackgroundTransparency = 1
		textLbl.Text = bodyText; textLbl.TextColor3 = Theme.Muted; textLbl.TextTransparency = 1
		textLbl.Font = Enum.Font.Gotham; textLbl.TextSize = 11
		textLbl.TextWrapped = true; textLbl.TextXAlignment = Enum.TextXAlignment.Left

		-- Action buttons
		if #buttons > 0 then
			local btnHolder = Instance.new("Frame", toast)
			btnHolder.Size = UDim2.new(1,-52,0,28)
			btnHolder.Position = UDim2.new(0,40,0,44)
			btnHolder.BackgroundTransparency = 1
			local btnLayout = Instance.new("UIListLayout", btnHolder)
			btnLayout.FillDirection = Enum.FillDirection.Horizontal
			btnLayout.Padding = UDim.new(0,6)
			btnLayout.SortOrder = Enum.SortOrder.LayoutOrder

			for i, btnDef in ipairs(buttons) do
				local label_, cb = btnDef[1], btnDef[2]
				local actionBtn = Instance.new("TextButton", btnHolder)
				actionBtn.Size = UDim2.new(0,0,1,0)
				actionBtn.AutomaticSize = Enum.AutomaticSize.X
				actionBtn.BackgroundColor3 = i == 1 and style.accent or Theme.Elevated
				actionBtn.Text = label_
				actionBtn.TextColor3 = Color3.fromRGB(255,255,255)
				actionBtn.Font = Enum.Font.GothamMedium; actionBtn.TextSize = 11
				actionBtn.AutoButtonColor = false; actionBtn.LayoutOrder = i
				Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0,6)
				local aPad = Instance.new("UIPadding", actionBtn)
				aPad.PaddingLeft = UDim.new(0,8); aPad.PaddingRight = UDim.new(0,8)
				actionBtn.MouseButton1Click:Connect(function()
					if cb then pcall(cb) end
					pcall(function() toast:Destroy() end)
				end)
			end
		end

		-- Progress bar
		local progressTrack = Instance.new("Frame", toast)
		progressTrack.AnchorPoint = Vector2.new(0,1)
		progressTrack.Size = UDim2.new(1,-12,0,2)
		progressTrack.Position = UDim2.new(0,6,1,-4)
		progressTrack.BackgroundColor3 = Theme.Elevated; progressTrack.BackgroundTransparency = 0.35
		progressTrack.BorderSizePixel = 0
		Instance.new("UICorner", progressTrack).CornerRadius = UDim.new(1,0)
		local progressFill = Instance.new("Frame", progressTrack)
		progressFill.Size = UDim2.new(1,0,1,0); progressFill.BackgroundColor3 = style.accent; progressFill.BorderSizePixel = 0
		Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1,0)

		local pad = Instance.new("UIPadding", toast)
		pad.PaddingTop = UDim.new(0,8); pad.PaddingBottom = UDim.new(0,12); pad.PaddingRight = UDim.new(0,10)

		local toastScale = Instance.new("UIScale", toast); toastScale.Scale = 0.92

		TweenPlay(toastScale, { Scale = 1 }, 0.28, Enum.EasingStyle.Quint)
		TweenPlay(toast,    { BackgroundTransparency = 0 }, 0.28, Enum.EasingStyle.Quint)
		TweenPlay(titleLbl, { TextTransparency = 0 }, 0.28, Enum.EasingStyle.Quint)
		TweenPlay(textLbl,  { TextTransparency = 0 }, 0.28, Enum.EasingStyle.Quint)
		TweenPlay(progressFill, { Size = UDim2.new(0,0,1,0) }, duration, Enum.EasingStyle.Linear)

		task.delay(duration, function()
			if not toast.Parent then return end
			TweenPlay(toastScale, { Scale = 0.94 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			TweenPlay(toast,    { BackgroundTransparency = 1 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			TweenPlay(titleLbl, { TextTransparency = 1 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			TweenPlay(textLbl,  { TextTransparency = 1 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			task.wait(0.22)
			pcall(function() toast:Destroy() end)
		end)
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- WATERMARK
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Watermark(options)
		options = options or {}
		local wmGui = Instance.new("ScreenGui")
		wmGui.Name = "EvolUI_Watermark"
		wmGui.ResetOnSpawn = false
		wmGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		wmGui.IgnoreGuiInset = true
		pcall(function() wmGui.Parent = CoreGui end)
		if not wmGui.Parent then wmGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
		maid:Add(wmGui)

		local wmFrame = Instance.new("Frame", wmGui)
		wmFrame.Size = UDim2.new(0,0,0,28)
		wmFrame.AutomaticSize = Enum.AutomaticSize.X
		wmFrame.Position = options.Position or UDim2.new(0, 12, 0, 12)
		wmFrame.BackgroundColor3 = Theme.Surface
		wmFrame.BackgroundTransparency = 0.1
		Instance.new("UICorner", wmFrame).CornerRadius = UDim.new(0,8)
		local wmStroke = Instance.new("UIStroke", wmFrame)
		wmStroke.Color = Theme.Border; wmStroke.Thickness = 1; wmStroke.Transparency = 0.4
		local wmPad = Instance.new("UIPadding", wmFrame)
		wmPad.PaddingLeft = UDim.new(0,10); wmPad.PaddingRight = UDim.new(0,10)

		local wmDot = Instance.new("Frame", wmFrame)
		wmDot.Size = UDim2.new(0,5,0,5)
		wmDot.Position = UDim2.new(0,0,0.5,-2.5)
		wmDot.BackgroundColor3 = Theme.Accent
		wmDot.BorderSizePixel = 0
		Instance.new("UICorner", wmDot).CornerRadius = UDim.new(1,0)

		local wmLabel = Instance.new("TextLabel", wmFrame)
		wmLabel.Size = UDim2.new(0,0,1,0)
		wmLabel.AutomaticSize = Enum.AutomaticSize.X
		wmLabel.Position = UDim2.new(0,10,0,0)
		wmLabel.BackgroundTransparency = 1
		wmLabel.Text = options.Text or "EvolUI"
		wmLabel.TextColor3 = Theme.Text
		wmLabel.Font = Enum.Font.GothamMedium
		wmLabel.TextSize = 11

		-- Drag watermark
		local wmDragging, wmDragStart, wmStartPos = false, nil, nil
		wmFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				wmDragging = true; wmDragStart = input.Position; wmStartPos = wmFrame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then wmDragging = false end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if wmDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local d = input.Position - wmDragStart
				wmFrame.Position = UDim2.new(wmStartPos.X.Scale, wmStartPos.X.Offset+d.X, wmStartPos.Y.Scale, wmStartPos.Y.Offset+d.Y)
			end
		end)

		-- Dot pulse
		task.spawn(function()
			while wmDot.Parent do
				TweenPlay(wmDot, { BackgroundTransparency = 0 }, 1.2, Enum.EasingStyle.Sine)
				task.wait(1.2)
				TweenPlay(wmDot, { BackgroundTransparency = 0.4 }, 1.2, Enum.EasingStyle.Sine)
				task.wait(1.2)
			end
		end)

		return {
			SetText = function(text) wmLabel.Text = text end,
			SetVisible = function(v_) wmGui.Enabled = v_ end,
			Destroy = function() wmGui:Destroy() end,
		}
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- CONFIG SYSTEM (requires writefile / readfile in exploit env)
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Config()
		local configApi = {}
		local configDir = config.ConfigDir or "EvolUI_Configs"

		local function getPath(name)
			return configDir .. "/" .. (config.Name or "UI") .. "_" .. name .. ".json"
		end

		function configApi:Save(name)
			local data = {}
			for _, entry in ipairs(configRegistry) do
				local t = entry.type
				if t == "Toggle" then
					data[entry.id] = entry.widget.Get()
				elseif t == "Slider" then
					data[entry.id] = entry.widget.Get()
				elseif t == "Dropdown" then
					data[entry.id] = entry.widget.Get()
				end
			end
			-- naive JSON encode
			local parts = {}
			for k, v in pairs(data) do
				local val
				if type(v) == "boolean" then val = v and "true" or "false"
				elseif type(v) == "number" then val = tostring(v)
				else val = '"' .. tostring(v) .. '"' end
				table.insert(parts, '"' .. k .. '":' .. val)
			end
			SafeWrite(getPath(name), "{" .. table.concat(parts, ",") .. "}")
		end

		function configApi:Load(name)
			local raw = SafeRead(getPath(name))
			if not raw then return false end
			-- naive JSON decode
			for k, v in raw:gmatch('"([^"]+)":([^,}]+)') do
				for _, entry in ipairs(configRegistry) do
					if entry.id == k then
						local t = entry.type
						if t == "Toggle" then
							entry.widget.Set(v == "true")
						elseif t == "Slider" then
							entry.widget.Set(tonumber(v))
						elseif t == "Dropdown" then
							entry.widget.Set(v:gsub('^"', ''):gsub('"$', ''))
						end
					end
				end
			end
			return true
		end

		function configApi:Delete(name)
			SafeDelete(getPath(name))
		end

		function configApi:List()
			local result = {}
			pcall(function()
				if listfiles then
					for _, f in ipairs(listfiles(configDir)) do
						table.insert(result, f)
					end
				end
			end)
			return result
		end

		return configApi
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- SEARCH BAR
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:Search(options)
		options = options or {}
		local holder = Instance.new("Frame", ActiveScroll)
		holder.Size = UDim2.new(1,0,0,36)
		holder.BackgroundColor3 = Theme.Surface
		holder.LayoutOrder = nextOrder()
		Instance.new("UICorner", holder).CornerRadius = UDim.new(0,10)

		local icon = Instance.new("TextLabel", holder)
		icon.Size = UDim2.new(0,24,1,0)
		icon.Position = UDim2.new(0,8,0,0)
		icon.BackgroundTransparency = 1
		icon.Text = "🔍"; icon.TextSize = 12
		icon.Font = Enum.Font.GothamMedium
		icon.TextColor3 = Theme.Muted

		local box = Instance.new("TextBox", holder)
		box.Size = UDim2.new(1,-38,1,-10)
		box.Position = UDim2.new(0,32,0,5)
		box.BackgroundTransparency = 1
		box.Text = ""
		box.PlaceholderText = options.Placeholder or "Search..."
		box.PlaceholderColor3 = Theme.Muted
		box.TextColor3 = Theme.Text
		box.Font = Enum.Font.Gotham; box.TextSize = 12
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.ClearTextOnFocus = false

		maid:Add(box.Focused:Connect(function()
			TweenPlay(holder, { BackgroundColor3 = Theme.SurfaceHover }, 0.15, Enum.EasingStyle.Quint)
		end))
		maid:Add(box.FocusLost:Connect(function()
			TweenPlay(holder, { BackgroundColor3 = Theme.Surface }, 0.15, Enum.EasingStyle.Quint)
		end))

		maid:Add(box:GetPropertyChangedSignal("Text"):Connect(function()
			local query = box.Text:lower()
			for _, entry in ipairs(searchIndex) do
				if entry.frame and entry.frame.Parent then
					entry.frame.Visible = query == "" or entry.label:lower():find(query, 1, true) ~= nil
				end
			end
		end))

		return box
	end

	-- ─────────────────────────────────────────────────────────────────────────
	-- Utility button helpers (backward compat)
	-- ─────────────────────────────────────────────────────────────────────────
	function UI:SetButtonColor(button, color)
		if button and button:IsA("TextButton") then
			TweenPlay(button, { BackgroundColor3 = color })
		end
	end
	function UI:TweenButton(button, color) UI:SetButtonColor(button, color) end

	return UI
end

return EvolUI
