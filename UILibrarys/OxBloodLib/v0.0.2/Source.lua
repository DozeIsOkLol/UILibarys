--[[
	OxBlood UI — v0.2.0
	Modern dark / oxblood UI toolkit for Roblox (Luau-friendly).

	Return value: table with:
	  VERSION, CHANGELOG, CreateWindow, GetThemes, etc.

	Compatible with:
	  local OxBlood = loadstring(...)()           — executors
	  local OxBlood = require(script.OxBlood)   — Studio ModuleScript

	See Example.lua for full API usage.
--]]

local OxBlood = {}

OxBlood.VERSION = "0.0.2"
OxBlood.CHANGELOG = {
	"0.0.2 — Full API (Window/Tab/Section), toast queue, themes, config, tooltips, color picker, search dropdown, progress, collapsible sections.",
	"0.0.1 — Initial UILibrary.Load-style API.",
}

-- ── Services ─────────────────────────────────────────────────
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local IS_STUDIO = RunService:IsStudio()

-- ── Defaults ─────────────────────────────────────────────────
local DROP_SHADOW_ID = "rbxassetid://297774371"
local SLICE_IMAGE_ID = "rbxassetid://3570695787"
local ICON_SHEET = "rbxassetid://3926305904"

local EASE_OUT = Enum.EasingStyle.Quint
local EASE_DIR = Enum.EasingDirection.Out

local function tweenInfo(dur, style, dir)
	return TweenInfo.new(dur, style or EASE_OUT, dir or EASE_DIR)
end

local function safeDestroy(inst)
	if inst and inst.Parent then
		inst:Destroy()
	end
end

-- ── Theme presets ───────────────────────────────────────────
local THEMES = {}

local function registerTheme(name, t)
	THEMES[name] = t
end

registerTheme("OxBlood", {
	Background = Color3.fromRGB(14, 10, 12),
	Surface = Color3.fromRGB(24, 18, 20),
	SurfaceElevated = Color3.fromRGB(32, 24, 28),
	Accent = Color3.fromRGB(160, 28, 48),
	AccentMuted = Color3.fromRGB(120, 40, 55),
	Text = Color3.fromRGB(245, 240, 242),
	TextMuted = Color3.fromRGB(160, 148, 154),
	Border = Color3.fromRGB(70, 50, 58),
	Success = Color3.fromRGB(52, 200, 110),
	Error = Color3.fromRGB(220, 55, 55),
	Warning = Color3.fromRGB(235, 175, 55),
	Info = Color3.fromRGB(90, 140, 220),
	TitleBar = Color3.fromRGB(30, 22, 26),
	TabInactive = Color3.fromRGB(28, 20, 24),
	TabActive = Color3.fromRGB(42, 30, 36),
	SliderFill = Color3.fromRGB(90, 45, 58),
	NotificationBg = Color3.fromRGB(30, 22, 26),
})

registerTheme("OxBloodLight", {
	Background = Color3.fromRGB(240, 232, 234),
	Surface = Color3.fromRGB(255, 248, 250),
	SurfaceElevated = Color3.fromRGB(255, 255, 255),
	Accent = Color3.fromRGB(140, 24, 42),
	AccentMuted = Color3.fromRGB(180, 90, 105),
	Text = Color3.fromRGB(35, 20, 28),
	TextMuted = Color3.fromRGB(100, 85, 92),
	Border = Color3.fromRGB(200, 180, 188),
	Success = Color3.fromRGB(34, 150, 80),
	Error = Color3.fromRGB(190, 45, 45),
	Warning = Color3.fromRGB(200, 140, 40),
	Info = Color3.fromRGB(60, 110, 200),
	TitleBar = Color3.fromRGB(250, 240, 244),
	TabInactive = Color3.fromRGB(235, 225, 230),
	TabActive = Color3.fromRGB(255, 235, 240),
	SliderFill = Color3.fromRGB(200, 120, 140),
	NotificationBg = Color3.fromRGB(255, 248, 250),
})

function OxBlood.GetThemes()
	local names = {}
	for k in pairs(THEMES) do
		table.insert(names, k)
	end
	table.sort(names)
	return names
end

function OxBlood.GetTheme(name)
	return THEMES[name]
end

function OxBlood.RegisterTheme(name, tokens)
	registerTheme(name, tokens)
end

-- ── Sound (optional) ──────────────────────────────────────────
local SOUND_IDS = {
	Click = "rbxassetid://6895079853",
	Toggle = "rbxassetid://6895079853",
	Notify = "rbxassetid://6518819542",
}

local function playSound(id, vol)
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = vol or 0.35
	s.Parent = (LocalPlayer and LocalPlayer:FindFirstChildWhichIsA("PlayerGui")) or workspace
	s:Play()
	s.Ended:Connect(function()
		s:Destroy()
	end)
end

-- ── Instance helpers (low footprint) ────────────────────────
local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = parent
	return c
end

local function stroke(parent, col, t, trans)
	local s = Instance.new("UIStroke")
	s.Color = col
	s.Thickness = t or 1
	s.Transparency = trans or 0.65
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function pad(parent, top, right, bottom, left)
	local p = Instance.new("UIPadding")
	local r = right or top
	local b = bottom or top
	local l = left or r
	p.PaddingTop = UDim.new(0, top)
	p.PaddingRight = UDim.new(0, r)
	p.PaddingBottom = UDim.new(0, b)
	p.PaddingLeft = UDim.new(0, l)
	p.Parent = parent
	return p
end

local function list(parent, padPx)
	local l = Instance.new("UIListLayout")
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, padPx or 6)
	l.Parent = parent
	return l
end

local function sliceFrame(radius, color)
	local f = Instance.new("ImageLabel")
	f.BackgroundTransparency = 1
	f.Image = SLICE_IMAGE_ID
	f.ScaleType = Enum.ScaleType.Slice
	f.SliceCenter = Rect.new(100, 100, 100, 100)
	f.SliceScale = math.clamp((radius or 6) * 0.01, 0.01, 1)
	f.ImageColor3 = color
	f.BorderSizePixel = 0
	return f
end

local function plainFrame(color, radius)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	if radius and radius > 0 then
		corner(f, radius)
	end
	return f
end

local function tween(obj, props, ti)
	local tw = TweenService:Create(obj, ti or tweenInfo(0.18), props)
	tw:Play()
	return tw
end

-- ── Blur / acrylic backdrop ─────────────────────────────────
local function tryBlurLighting(amount)
	local lighting = game:GetService("Lighting")
	local blur = lighting:FindFirstChild("OxBloodUIBlur")
	if not blur then
		blur = Instance.new("BlurEffect")
		blur.Name = "OxBloodUIBlur"
		blur.Parent = lighting
	end
	if blur:IsA("BlurEffect") then
		blur.Size = amount
	end
end

local function removeBlur()
	local lighting = game:GetService("Lighting")
	local blur = lighting:FindFirstChild("OxBloodUIBlur")
	if blur then
		blur:Destroy()
	end
end

-- ── Clipboard / file helpers (executor-safe pcall) ───────────
local function getExploitEnv()
	local env = {}
	local ok, result = pcall(function()
		return getfenv(0)
	end)
	if ok and type(result) == "table" then
		env = result
	end
	return env
end

local function getExploitFilesystem()
	local env = getExploitEnv()
	return env.writefile, env.readfile, env.isfile, env.makefolder, env.setclipboard, env.getclipboard
end

local function setClipboardSafe(text)
	local _, _, _, _, setclipboard = getExploitFilesystem()
	if type(setclipboard) == "function" then
		return pcall(setclipboard, text)
	end
	return false
end

local function writeFileSafe(path, data)
	local writefile = select(1, getExploitFilesystem())
	if type(writefile) == "function" then
		return pcall(writefile, path, data)
	end
	return false
end

local function readFileSafe(path)
	local readfile, _, isfile = getExploitFilesystem()
	if type(readfile) == "function" and type(isfile) == "function" and isfile(path) then
		return pcall(readfile, path)
	end
	return false, nil
end

-- ═══════════════════════════════════════════════════════════════
-- HSV helpers (color picker)
-- ═══════════════════════════════════════════════════════════════
local function hsvToRgb(h, s, v)
	h = (h % 360) / 60
	local c = v * s
	local x = c * (1 - math.abs((h % 2) - 1))
	local m = v - c
	local r, g, b = 0, 0, 0
	if h < 1 then
		r, g, b = c, x, 0
	elseif h < 2 then
		r, g, b = x, c, 0
	elseif h < 3 then
		r, g, b = 0, c, x
	elseif h < 4 then
		r, g, b = 0, x, c
	elseif h < 5 then
		r, g, b = x, 0, c
	else
		r, g, b = c, 0, x
	end
	return Color3.new(r + m, g + m, b + m)
end

local function rgbToHsv(c)
	local r, g, b = c.R, c.G, c.B
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local d = max - min
	local h = 0
	if d > 1e-6 then
		if max == r then
			h = 60 * (((g - b) / d) % 6)
		elseif max == g then
			h = 60 * (((b - r) / d) + 2)
		else
			h = 60 * (((r - g) / d) + 4)
		end
	end
	if h < 0 then
		h = h + 360
	end
	local s = (max > 1e-6) and (d / max) or 0
	return h, s, max
end

-- ═══════════════════════════════════════════════════════════════
-- Tooltip layer (shared)
-- ═══════════════════════════════════════════════════════════════
local TooltipGui
local TooltipLabel

local function ensureTooltipRoot(parentGui)
	if TooltipGui and TooltipGui.Parent then
		return
	end
	TooltipGui = Instance.new("Frame")
	TooltipGui.Name = "OxBloodTooltip"
	TooltipGui.BackgroundTransparency = 1
	TooltipGui.Size = UDim2.fromScale(1, 1)
	TooltipGui.ZIndex = 500
	TooltipGui.Visible = false
	TooltipGui.Parent = parentGui
	local tip = Instance.new("TextLabel")
	tip.Name = "Tip"
	tip.BackgroundColor3 = Color3.fromRGB(22, 18, 20)
	tip.TextColor3 = Color3.fromRGB(235, 230, 232)
	tip.TextSize = 12
	tip.Font = Enum.Font.GothamMedium
	tip.AutomaticSize = Enum.AutomaticSize.XY
	tip.TextWrapped = false
	tip.BorderSizePixel = 0
	tip.ZIndex = 501
	corner(tip, 5)
	stroke(tip, Color3.fromRGB(100, 50, 60), 1, 0.4)
	pad(tip, 6, 10)
	tip.Parent = TooltipGui
	TooltipLabel = tip
end

local tooltipHideToken = 0
local function showTooltip(screenGui, text, worldPos)
	if not text or text == "" then
		return
	end
	ensureTooltipRoot(screenGui)
	tooltipHideToken += 1
	local my = tooltipHideToken
	TooltipGui.Visible = true
	TooltipLabel.Text = text
	local inset = GuiService:GetGuiInset()
	local pos = Vector2.new(worldPos.X, worldPos.Y) + inset
	TooltipLabel.Position = UDim2.fromOffset(pos.X + 14, pos.Y + 14)
	task.delay(3, function()
		if my == tooltipHideToken then
			TooltipGui.Visible = false
		end
	end)
end

local function hideTooltip()
	tooltipHideToken += 1
	if TooltipGui then
		TooltipGui.Visible = false
	end
end

-- ═══════════════════════════════════════════════════════════════
-- Notification manager
-- ═══════════════════════════════════════════════════════════════
local function makeNotificationManager(stackParent, themeGetter, soundEnabledGetter)
	local self = {}
	self._queue = {}
	self._active = 0
	self._maxVisible = 4
	self._spacing = 8
	self._layoutOrder = 0

	local typeColors = {
		success = function()
			return themeGetter().Success
		end,
		error = function()
			return themeGetter().Error
		end,
		warning = function()
			return themeGetter().Warning
		end,
		warn = function()
			return themeGetter().Warning
		end,
		info = function()
			return themeGetter().Info
		end,
		custom = function()
			return themeGetter().Accent
		end,
	}

	local typeIcons = {
		success = "✓",
		error = "✕",
		warning = "⚠",
		warn = "⚠",
		info = "ℹ",
		custom = "◆",
	}

	function self:_reflow()
		local y = 0
		local rows = {}
		for _, child in ipairs(stackParent:GetChildren()) do
			if child:IsA("GuiObject") and child:GetAttribute("OxNotif") then
				table.insert(rows, child)
			end
		end
		table.sort(rows, function(a, b)
			return (a.LayoutOrder or 0) < (b.LayoutOrder or 0)
		end)
		for _, child in ipairs(rows) do
			tween(child, { Position = UDim2.new(0, 0, 0, y) }, tweenInfo(0.15))
			y += child.AbsoluteSize.Y + self._spacing
		end
	end

	local function stackYOffsetFor(inst)
		local y = 0
		local rows = {}
		for _, child in ipairs(stackParent:GetChildren()) do
			if child:IsA("GuiObject") and child:GetAttribute("OxNotif") then
				table.insert(rows, child)
			end
		end
		table.sort(rows, function(a, b)
			return (a.LayoutOrder or 0) < (b.LayoutOrder or 0)
		end)
		for _, child in ipairs(rows) do
			if child == inst then
				return y
			end
			y += child.AbsoluteSize.Y + self._spacing
		end
		return y
	end

	function self:Notify(opts)
		opts = opts or {}
		local title = opts.Title or "Notice"
		local desc = opts.Description or opts.Message or ""
		local ntype = string.lower(opts.Type or "info")
		local duration = opts.Duration or 4
		local persistent = opts.Persistent == true
		local onClick = opts.OnClick
		local customAccent = opts.CustomAccent
		local iconChar = opts.Icon
		local iconImage = opts.IconImage
		-- Corner controls horizontal slide only; stack is always top-right of anchor parent.
		local posCorner = string.lower(opts.Position or opts.Corner or "topright")
		local accent = customAccent or (typeColors[ntype] and typeColors[ntype]()) or themeGetter().Info
		local ic = iconChar or typeIcons[ntype] or "ℹ"

		self._layoutOrder += 1

		local card = plainFrame(themeGetter().NotificationBg, 8)
		card.Name = "NotifCard"
		card:SetAttribute("OxNotif", true)
		card.Size = UDim2.new(1, -10, 0, 0)
		card.AutomaticSize = Enum.AutomaticSize.Y
		card.ClipsDescendants = false
		card.LayoutOrder = self._layoutOrder
		stroke(card, accent, 1, 0.5)

		local grad = Instance.new("UIGradient")
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, accent:Lerp(themeGetter().NotificationBg, 0.85)),
			ColorSequenceKeypoint.new(1, themeGetter().NotificationBg),
		})
		grad.Rotation = 90
		grad.Parent = card

		local row = Instance.new("Frame")
		row.BackgroundTransparency = 1
		row.Size = UDim2.new(1, -16, 0, 0)
		row.AutomaticSize = Enum.AutomaticSize.Y
		row.Position = UDim2.fromOffset(8, 8)
		row.Parent = card

		local body = Instance.new("Frame")
		body.BackgroundTransparency = 1
		body.Position = UDim2.fromOffset(0, 0)
		body.Size = UDim2.new(1, 0, 0, 0)
		body.AutomaticSize = Enum.AutomaticSize.Y
		body.Parent = row

		local iconHolder = Instance.new("Frame")
		iconHolder.BackgroundTransparency = 1
		iconHolder.Size = UDim2.new(0, 28, 0, 28)
		iconHolder.Parent = body

		if iconImage then
			local img = Instance.new("ImageLabel")
			img.BackgroundTransparency = 1
			img.Size = UDim2.fromScale(1, 1)
			img.Image = iconImage
			img.Parent = iconHolder
		else
			local il = Instance.new("TextLabel")
			il.BackgroundTransparency = 1
			il.Font = Enum.Font.GothamBold
			il.TextSize = 18
			il.TextColor3 = accent
			il.Text = ic
			il.Size = UDim2.fromScale(1, 1)
			il.Parent = iconHolder
		end

		local textCol = Instance.new("Frame")
		textCol.BackgroundTransparency = 1
		textCol.Position = UDim2.fromOffset(34, 0)
		textCol.Size = UDim2.new(1, -34, 0, 0)
		textCol.AutomaticSize = Enum.AutomaticSize.Y
		textCol.Parent = body

		local titleL = Instance.new("TextLabel")
		titleL.BackgroundTransparency = 1
		titleL.Font = Enum.Font.GothamBold
		titleL.TextSize = 13
		titleL.TextColor3 = themeGetter().Text
		titleL.TextXAlignment = Enum.TextXAlignment.Left
		titleL.TextWrapped = true
		titleL.Size = UDim2.new(1, 0, 0, 0)
		titleL.AutomaticSize = Enum.AutomaticSize.Y
		titleL.Text = title
		titleL.Parent = textCol

		local descL = Instance.new("TextLabel")
		descL.BackgroundTransparency = 1
		descL.Font = Enum.Font.Gotham
		descL.TextSize = 11
		descL.TextTransparency = 0.15
		descL.TextColor3 = themeGetter().TextMuted
		descL.TextXAlignment = Enum.TextXAlignment.Left
		descL.TextWrapped = true
		descL.Size = UDim2.new(1, 0, 0, 0)
		descL.AutomaticSize = Enum.AutomaticSize.Y
		descL.Text = desc
		descL.Parent = textCol

		local padF = Instance.new("Frame")
		padF.Name = "PadBottom"
		padF.BackgroundTransparency = 1
		padF.Size = UDim2.new(1, 0, 0, 8)
		padF.Parent = card

		local btn = Instance.new("TextButton")
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Size = UDim2.fromScale(1, 1)
		btn.ZIndex = 5
		btn.Parent = card

		local startX = posCorner:find("left") and -320 or 320
		card.Parent = stackParent
		task.defer(function()
			if not card.Parent then
				return
			end
			local ySlot = stackYOffsetFor(card)
			card.Position = UDim2.new(0, startX, 0, ySlot)
			tween(card, { Position = UDim2.new(0, 0, 0, ySlot) }, tweenInfo(0.28, Enum.EasingStyle.Back))
		end)

		if soundEnabledGetter() then
			playSound(SOUND_IDS.Notify, 0.25)
		end

		local kill
		local dead = false
		function kill()
			if dead then
				return
			end
			dead = true
			tween(card, { Position = UDim2.new(0, startX, 0, card.Position.Y.Offset) }, tweenInfo(0.22))
			task.delay(0.28, function()
				safeDestroy(card)
				self:_reflow()
			end)
		end

		if not persistent and duration > 0 then
			task.delay(duration, kill)
		end

		btn.MouseButton1Click:Connect(function()
			if onClick then
				pcall(onClick)
			end
			if not persistent then
				kill()
			end
		end)

		return { Dismiss = kill }
	end

	return self
end

-- ═══════════════════════════════════════════════════════════════
-- Window factory: tabs, sections, controls
-- ═══════════════════════════════════════════════════════════════

local CoreGui = game:GetService("CoreGui")

local function mouseWorldPos()
	return UserInputService:GetMouseLocation()
end

function OxBlood.CreateWindow(a, b)
	-- Supports OxBlood.CreateWindow({...}) and OxBlood:CreateWindow({...})
	local config
	if b ~= nil then
		config = b
	elseif type(a) == "table" and rawget(a, "VERSION") == nil and rawget(a, "CreateWindow") == nil then
		config = a
	else
		config = {}
	end
	local player = Players.LocalPlayer
	if not player then
		warn("[OxBlood] LocalPlayer missing")
		return nil
	end

	local themeName = config.Theme or "OxBlood"
	local function getTheme()
		return THEMES[themeName] or THEMES["OxBlood"]
	end

	local winId = config.Name or config.Title or "OxBlood"
	local target = IS_STUDIO and player:WaitForChild("PlayerGui") or CoreGui
	safeDestroy(target:FindFirstChild(winId))
	safeDestroy(target:FindFirstChild(winId .. "_Notifs"))
	safeDestroy(target:FindFirstChild(winId .. "_TopBar"))

	local soundOn = config.SoundEnabled ~= false
	local win = {}
	win._destroyed = false
	win._themeName = themeName
	win._configRegistry = {}
	win._toggleKey = config.ToggleKey or config.Keybind
	win._blurAmount = config.Blur

	local gui = Instance.new("ScreenGui")
	gui.Name = winId
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = config.DisplayOrder or 8
	gui.Parent = target

	local scl = Instance.new("UIScale")
	scl.Scale = typeof(config.UIScale) == "number" and config.UIScale or 1
	scl.Parent = gui

	if type(config.Blur) == "number" and config.Blur > 0 then
		tryBlurLighting(config.Blur)
	end

	local acrylic = config.Acrylic
	if acrylic == nil then
		acrylic = false
	end
	if acrylic then
		local fog = Instance.new("TextButton")
		fog.Name = "Acrylic"
		fog.AutoButtonColor = false
		fog.Text = ""
		fog.Size = UDim2.fromScale(1, 1)
		fog.BackgroundColor3 = Color3.fromRGB(8, 4, 6)
		fog.BackgroundTransparency = 0.55
		fog.BorderSizePixel = 0
		fog.ZIndex = 0
		fog.Parent = gui
		local ug = Instance.new("UIGradient")
		ug.Rotation = 120
		ug.Color = ColorSequence.new(Color3.fromRGB(40, 10, 18), Color3.fromRGB(5, 2, 4))
		ug.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.75),
			NumberSequenceKeypoint.new(1, 0.9),
		})
		ug.Parent = fog
	end

	local root = Instance.new("Frame")
	root.Name = "Root"
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = config.Position or UDim2.fromScale(0.5, 0.52)
	root.Size = config.Size or UDim2.fromOffset(540, 400)
	root.BackgroundTransparency = 1
	root.ZIndex = 2
	root.Parent = gui

	local shadow = Instance.new("ImageLabel")
	shadow.BackgroundTransparency = 1
	shadow.Image = DROP_SHADOW_ID
	shadow.ImageTransparency = 0.4
	shadow.Size = UDim2.new(1, 48, 1, 48)
	shadow.Position = UDim2.fromScale(0.5, 0.52)
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.ZIndex = 0
	shadow.Parent = root

	local panel = plainFrame(getTheme().Background, 10)
	panel.Name = "Panel"
	panel.ClipsDescendants = true
	panel.Size = UDim2.fromScale(1, 1)
	panel.ZIndex = 1
	stroke(panel, getTheme().Accent, 1.2, 0.75)
	corner(panel, 10)
	local pg = Instance.new("UIGradient")
	pg.Rotation = 100
	pg.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, getTheme().Surface:Lerp(getTheme().Background, 0.4)),
		ColorSequenceKeypoint.new(1, getTheme().Background),
	})
	pg.Parent = panel
	panel.Parent = root

	local titleH = 34
	local titleBar = plainFrame(getTheme().TitleBar, 0)
	titleBar.Size = UDim2.new(1, 0, 0, titleH)
	titleBar.BackgroundTransparency = 0.05
	titleBar.ZIndex = 5
	titleBar.Parent = panel
	local tbB = Instance.new("UIGradient")
	tbB.Color = ColorSequence.new(getTheme().TitleBar, getTheme().SurfaceElevated)
	tbB.Rotation = 90
	tbB.Transparency = NumberSequence.new(0.15)
	tbB.Parent = titleBar
	stroke(titleBar, getTheme().Border, 1, 0.9)

	local hub = Instance.new("TextLabel")
	hub.BackgroundTransparency = 1
	hub.Font = Enum.Font.GothamBold
	hub.TextSize = 14
	hub.TextXAlignment = Enum.TextXAlignment.Left
	hub.TextColor3 = getTheme().Accent
	hub.Text = config.Title or "OxBlood"
	hub.Size = UDim2.new(0.35, 0, 1, 0)
	hub.Position = UDim2.fromOffset(12, 0)
	hub.ZIndex = 6
	hub.Parent = titleBar

	local mid = Instance.new("TextLabel")
	mid.BackgroundTransparency = 1
	mid.Font = Enum.Font.GothamMedium
	mid.TextSize = 12
	mid.TextTransparency = 0.2
	mid.TextColor3 = getTheme().Text
	mid.Text = config.Subtitle or ""
	mid.TextXAlignment = Enum.TextXAlignment.Center
	mid.Size = UDim2.new(0.35, 0, 1, 0)
	mid.Position = UDim2.new(0.325, 0, 0, 0)
	mid.ZIndex = 6
	mid.Parent = titleBar

	local ver = Instance.new("TextLabel")
	ver.BackgroundTransparency = 1
	ver.Font = Enum.Font.Gotham
	ver.TextSize = 11
	ver.TextTransparency = 0.35
	ver.TextColor3 = getTheme().TextMuted
	ver.Text = config.Version or ("v" .. OxBlood.VERSION)
	ver.TextXAlignment = Enum.TextXAlignment.Right
	ver.Size = UDim2.new(0.28, -60, 1, 0)
	ver.Position = UDim2.new(0.72, 0, 0, 0)
	ver.ZIndex = 6
	ver.Parent = titleBar

	local minBtn, closeBtn
	if config.Minimize ~= false then
		minBtn = Instance.new("ImageButton")
		minBtn.Size = UDim2.fromOffset(22, 22)
		minBtn.Position = UDim2.new(1, -56, 0.5, -11)
		minBtn.BackgroundTransparency = 1
		minBtn.Image = ICON_SHEET
		minBtn.ImageRectOffset = Vector2.new(564, 564)
		minBtn.ImageRectSize = Vector2.new(36, 36)
		minBtn.ZIndex = 8
		minBtn.Parent = titleBar
	end
	if config.Close ~= false then
		closeBtn = Instance.new("ImageButton")
		closeBtn.Size = UDim2.fromOffset(22, 22)
		closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
		closeBtn.BackgroundTransparency = 1
		closeBtn.Image = ICON_SHEET
		closeBtn.ImageRectOffset = Vector2.new(284, 4)
		closeBtn.ImageRectSize = Vector2.new(24, 24)
		closeBtn.ImageColor3 = getTheme().Error
		closeBtn.ZIndex = 8
		closeBtn.Parent = titleBar
	end

	local dragBtn = Instance.new("TextButton")
	dragBtn.Text = ""
	dragBtn.BackgroundTransparency = 1
	dragBtn.Size = UDim2.new(1, -90, 1, 0)
	dragBtn.ZIndex = 7
	dragBtn.Parent = titleBar

	dragBtn.MouseButton1Down:Connect(function()
		local start = mouseWorldPos()
		local pos0 = root.Position
		local sigMove, sigUp
		sigMove = UserInputService.InputChanged:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
				local m = mouseWorldPos()
				local delta = m - start
				root.Position = UDim2.new(pos0.X.Scale, pos0.X.Offset + delta.X, pos0.Y.Scale, pos0.Y.Offset + delta.Y)
			end
		end)
		sigUp = UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				sigMove:Disconnect()
				sigUp:Disconnect()
			end
		end)
	end)

	local body = Instance.new("Frame")
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(0, titleH)
	body.Size = UDim2.new(1, 0, 1, -titleH)
	body.ZIndex = 3
	body.Parent = panel

	local sidebarW = config.SidebarWidth or 118
	local sidebar = plainFrame(getTheme().TabInactive, 0)
	sidebar.BackgroundTransparency = 0.2
	sidebar.Size = UDim2.new(0, sidebarW, 1, -10)
	sidebar.Position = UDim2.fromOffset(6, 6)
	sidebar.ZIndex = 4
	sidebar.Parent = body
	corner(sidebar, 8)
	stroke(sidebar, getTheme().Border, 1, 0.88)

	local tabList = Instance.new("ScrollingFrame")
	tabList.Name = "Tabs"
	tabList.BackgroundTransparency = 1
	tabList.Size = UDim2.new(1, -8, 1, -48)
	tabList.Position = UDim2.fromOffset(4, 4)
	tabList.ScrollBarThickness = 2
	tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabList.ZIndex = 5
	tabList.Parent = sidebar
	local tabLayout = list(tabList, 6)
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabList.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 8)
	end)

	local userFoot = plainFrame(getTheme().SurfaceElevated, 8)
	userFoot.Size = UDim2.new(1, -8, 0, 42)
	userFoot.Position = UDim2.new(0.5, 0, 1, -46)
	userFoot.AnchorPoint = Vector2.new(0.5, 0)
	userFoot.ZIndex = 5
	userFoot.Parent = sidebar
	stroke(userFoot, getTheme().Accent, 1, 0.85)
	local av = Instance.new("ImageLabel")
	av.BackgroundColor3 = getTheme().Surface
	av.Size = UDim2.fromOffset(30, 30)
	av.Position = UDim2.fromOffset(8, 6)
	corner(av, 999)
	av.Parent = userFoot
	task.defer(function()
		local ok, url = pcall(function()
			return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
		if ok then
			av.Image = url
		end
	end)
	local welcome = Instance.new("TextLabel")
	welcome.BackgroundTransparency = 1
	welcome.Font = Enum.Font.GothamBold
	welcome.TextSize = 11
	welcome.TextColor3 = getTheme().Text
	welcome.TextXAlignment = Enum.TextXAlignment.Left
	welcome.TextTruncate = Enum.TextTruncate.AtEnd
	welcome.Text = player.DisplayName
	welcome.Size = UDim2.new(1, -48, 1, 0)
	welcome.Position = UDim2.fromOffset(44, 0)
	welcome.Parent = userFoot

	local contentShell = plainFrame(getTheme().Surface, 8)
	contentShell.Size = UDim2.new(1, -sidebarW - 18, 1, -12)
	contentShell.Position = UDim2.new(0, sidebarW + 12, 0, 6)
	contentShell.ZIndex = 4
	contentShell.BackgroundTransparency = 0.15
	contentShell.Parent = body
	stroke(contentShell, getTheme().Border, 1, 0.9)

	local searchRow
	if config.WindowSearch ~= false then
		searchRow = plainFrame(getTheme().SurfaceElevated, 6)
		searchRow.Name = "WindowSearch"
		searchRow.Size = UDim2.new(1, -12, 0, 28)
		searchRow.Position = UDim2.fromOffset(6, 6)
		searchRow.ZIndex = 6
		searchRow.Parent = contentShell
		local sb = Instance.new("TextBox")
		sb.BackgroundTransparency = 1
		sb.PlaceholderText = "Search controls…"
		sb.PlaceholderColor3 = getTheme().TextMuted
		sb.TextColor3 = getTheme().Text
		sb.Font = Enum.Font.Gotham
		sb.TextSize = 13
		sb.TextXAlignment = Enum.TextXAlignment.Left
		sb.Size = UDim2.new(1, -16, 1, 0)
		sb.Position = UDim2.fromOffset(10, 0)
		sb.ClearTextOnFocus = false
		sb.Parent = searchRow
		sb:GetPropertyChangedSignal("Text"):Connect(function()
			local q = string.lower(sb.Text)
			for _, reg in pairs(win._configRegistry) do
				local el = reg.instance
				if el and el.Parent then
					local hay = string.lower(reg.searchBlob or "")
					el.Visible = (q == "") or string.find(hay, q, 1, true) ~= nil
				end
			end
		end)
	end

	local contentHost = Instance.new("Frame")
	contentHost.Name = "ContentHost"
	contentHost.BackgroundTransparency = 1
	contentHost.Position = UDim2.fromOffset(6, searchRow and 40 or 6)
	contentHost.Size = UDim2.new(1, -12, 1, searchRow and -52 or -12)
	contentHost.ZIndex = 5
	contentHost.Parent = contentShell

	local notifGui = Instance.new("ScreenGui")
	notifGui.Name = winId .. "_Notifs"
	notifGui.ResetOnSpawn = false
	notifGui.IgnoreGuiInset = true
	notifGui.DisplayOrder = (gui.DisplayOrder or 8) + 50
	notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	notifGui.Parent = target

	local notifStack = Instance.new("Frame")
	notifStack.BackgroundTransparency = 1
	notifStack.Size = UDim2.new(0, 300, 1, -24)
	notifStack.Position = UDim2.new(1, -310, 0, 16)
	notifStack.ZIndex = 100
	notifStack.Parent = notifGui

	local notifMgr = makeNotificationManager(notifStack, getTheme, function()
		return soundOn
	end)

	ensureTooltipRoot(gui)

	local function registerSearch(inst, blob)
		table.insert(win._configRegistry, { instance = inst, searchBlob = blob })
	end

	local tabOrder = 0
	local tabs = {}

	local function applyTheme()
		local th = getTheme()
		tween(panel, { BackgroundColor3 = th.Background }, tweenInfo(0.2))
		hub.TextColor3 = th.Accent
		mid.TextColor3 = th.Text
		ver.TextColor3 = th.TextMuted
	end

	function win:SetTheme(name)
		if THEMES[name] then
			self._themeName = name
			themeName = name
			applyTheme()
		end
	end

	function win:Notify(opts)
		return notifMgr:Notify(opts)
	end

	function win:NotifyCompat(title, msg, typ, dur)
		return self:Notify({ Title = title, Description = msg, Type = typ or "info", Duration = dur or 4 })
	end

	function win:Show()
		gui.Enabled = true
		root.Visible = true
	end

	function win:Hide()
		gui.Enabled = false
	end

	function win:SetVisible(v)
		gui.Enabled = v and true or false
	end

	function win:Destroy()
		if self._destroyed then
			return
		end
		self._destroyed = true
		safeDestroy(gui)
		safeDestroy(notifGui)
		if type(self._blurAmount) == "number" and self._blurAmount > 0 then
			removeBlur()
		end
	end

	function win:GetPath()
		return config.ConfigPath or (winId .. "_config.json")
	end

	function win:ExportConfig()
		return HttpService:JSONEncode(self._configStore or {})
	end

	function win:ImportConfig(jsonStr)
		local ok, data = pcall(function()
			return HttpService:JSONDecode(jsonStr)
		end)
		if ok and type(data) == "table" then
			self._configStore = data
			for key, fn in pairs(self._configCallbacks or {}) do
				local v = data[key]
				if v ~= nil then
					pcall(fn, v)
				end
			end
			return true
		end
		return false
	end

	function win:SaveConfig(path)
		path = path or self:GetPath()
		self._configStore = self._configStore or {}
		local jsonStr = self:ExportConfig()
		if writeFileSafe(path, jsonStr) then
			return true
		end
		return setClipboardSafe(jsonStr)
	end

	function win:LoadConfig(path)
		path = path or self:GetPath()
		local ok, text = readFileSafe(path)
		if ok and text then
			return self:ImportConfig(text)
		end
		return false
	end

	win._configStore = {}
	win._configCallbacks = {}

	local function bindConfigKey(key, setVal)
		win._configCallbacks[key] = setVal
		task.defer(function()
			if win._configStore[key] ~= nil then
				pcall(setVal, win._configStore[key])
			end
		end)
	end

	-- ══ Section element builders ══
	local function sectionCreateButton(sec, text, callback, tooltipText)
		local row = plainFrame(getTheme().SurfaceElevated, 6)
		row.Size = UDim2.new(1, 0, 0, 32)
		row.ZIndex = 10
		row.Parent = sec._host
		registerSearch(row, text .. " button")
		local b = Instance.new("TextButton")
		b.Text = text
		b.Font = Enum.Font.GothamMedium
		b.TextSize = 13
		b.TextColor3 = getTheme().Text
		b.AutoButtonColor = false
		b.BackgroundColor3 = getTheme().TabActive
		b.BackgroundTransparency = 0.2
		b.Size = UDim2.fromScale(1, 1)
		b.ZIndex = 11
		corner(b, 6)
		stroke(b, getTheme().Accent, 1, 0.82)
		b.Parent = row
		b.MouseEnter:Connect(function()
			tween(b, { BackgroundTransparency = 0.05, TextColor3 = getTheme().Accent })
		end)
		b.MouseLeave:Connect(function()
			tween(b, { BackgroundTransparency = 0.2, TextColor3 = getTheme().Text })
		end)
		b.MouseButton1Click:Connect(function()
			if soundOn then
				playSound(SOUND_IDS.Click, 0.2)
			end
			if callback then
				pcall(callback)
			end
		end)
		if tooltipText and tooltipText ~= "" then
			b.MouseEnter:Connect(function()
				showTooltip(gui, tooltipText, mouseWorldPos())
			end)
			b.MouseLeave:Connect(hideTooltip)
		end
		return {
			Destroy = function()
				safeDestroy(row)
			end,
		}
	end

	local function sectionCreateToggle(sec, text, default, callback, configKey)
		local val = default == true
		local row = plainFrame(getTheme().SurfaceElevated, 6)
		row.Size = UDim2.new(1, 0, 0, 32)
		row.ZIndex = 10
		row.Parent = sec._host
		registerSearch(row, text .. " toggle")
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 13
		lbl.TextColor3 = getTheme().Text
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Size = UDim2.new(1, -54, 1, 0)
		lbl.Position = UDim2.fromOffset(10, 0)
		lbl.Parent = row
		local sw = Instance.new("Frame")
		sw.Size = UDim2.fromOffset(42, 22)
		sw.Position = UDim2.new(1, -48, 0.5, -11)
		sw.BackgroundColor3 = getTheme().TabInactive
		sw.Parent = row
		corner(sw, 999)
		stroke(sw, getTheme().Border, 1, 0.85)
		local knob = Instance.new("Frame")
		knob.Size = UDim2.fromOffset(18, 18)
		knob.Position = val and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
		knob.BackgroundColor3 = getTheme().Text
		knob.Parent = sw
		corner(knob, 999)
		local hit = Instance.new("TextButton")
		hit.BackgroundTransparency = 1
		hit.Text = ""
		hit.Size = UDim2.new(1, 20, 1, 20)
		hit.Position = UDim2.fromScale(0.5, 0.5)
		hit.AnchorPoint = Vector2.new(0.5, 0.5)
		hit.ZIndex = 5
		hit.Parent = row
		local function paint()
			tween(sw, { BackgroundColor3 = val and getTheme().Accent or getTheme().TabInactive }, tweenInfo(0.18))
			tween(knob, { Position = val and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9) }, tweenInfo(0.2, Enum.EasingStyle.Quad))
			if configKey then
				win._configStore[configKey] = val
			end
			if callback then
				pcall(callback, val)
			end
		end
		if val then
			sw.BackgroundColor3 = getTheme().Accent
		end
		if configKey then
			win._configStore[configKey] = val
			bindConfigKey(configKey, function(v)
				val = v == true or v == "true" or v == 1
				paint()
			end)
		end
		hit.MouseButton1Click:Connect(function()
			val = not val
			if soundOn then
				playSound(SOUND_IDS.Toggle, 0.15)
			end
			paint()
		end)
		return {
			Set = function(v)
				val = v and true or false
				paint()
			end,
			Get = function()
				return val
			end,
			Destroy = function()
				safeDestroy(row)
			end,
		}
	end

	local function getXY(fr, x, y)
		local ap = fr.AbsolutePosition
		local as = fr.AbsoluteSize
		local rx = math.clamp(x - ap.X, 0, as.X)
		return rx / math.max(1, as.X)
	end

	local function sectionCreateSlider(sec, text, opts, callback, configKey)
		opts = opts or {}
		local minV = opts.Min or opts.min or 0
		local maxV = opts.Max or opts.max or 100
		local step = opts.Step or opts.step or 1
		local val = math.clamp(opts.Default or opts.Def or minV, minV, maxV)
		local row = plainFrame(getTheme().SurfaceElevated, 6)
		row.Size = UDim2.new(1, 0, 0, 40)
		row.ZIndex = 10
		row.Parent = sec._host
		registerSearch(row, text .. " slider")
		local cap = Instance.new("TextLabel")
		cap.BackgroundTransparency = 1
		cap.Font = Enum.Font.GothamMedium
		cap.TextSize = 12
		cap.TextColor3 = getTheme().TextMuted
		cap.TextXAlignment = Enum.TextXAlignment.Left
		cap.Size = UDim2.new(1, -12, 0, 16)
		cap.Position = UDim2.fromOffset(10, 2)
		cap.Parent = row
		local track = plainFrame(getTheme().TabInactive, 4)
		track.Size = UDim2.new(1, -20, 0, 8)
		track.Position = UDim2.fromOffset(10, 22)
		track.Parent = row
		local fill = plainFrame(getTheme().Accent, 4)
		fill.BorderSizePixel = 0
		fill.Size = UDim2.new((val - minV) / math.max(1e-6, maxV - minV), 0, 1, 0)
		fill.Parent = track
		local function fmt(n)
			if step < 1 then
				return string.format("%.2f", n)
			end
			return tostring(math.floor(n + 0.5))
		end
		local function setFromAlpha(a)
			local raw = minV + a * (maxV - minV)
			if step >= 1 then
				val = math.floor((raw - minV) / step + 0.5) * step + minV
			else
				val = math.clamp(math.floor(raw * 100 + 0.5) / 100, minV, maxV)
			end
			val = math.clamp(val, minV, maxV)
			cap.Text = string.format("%s  ·  %s", text, fmt(val))
			fill.Size = UDim2.new((val - minV) / math.max(1e-6, maxV - minV), 0, 1, 0)
			if configKey then
				win._configStore[configKey] = val
			end
			if callback then
				pcall(callback, val)
			end
		end
		setFromAlpha((val - minV) / math.max(1e-6, maxV - minV))
		if configKey then
			win._configStore[configKey] = val
			bindConfigKey(configKey, function(v)
				val = tonumber(v) or val
				setFromAlpha((val - minV) / math.max(1e-6, maxV - minV))
			end)
		end
		local dragging = false
		local hit = Instance.new("TextButton")
		hit.Text = ""
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.new(1, 0, 1, 8)
		hit.Position = UDim2.fromOffset(0, -4)
		hit.Parent = track
		hit.MouseButton1Down:Connect(function()
			dragging = true
		end)
		UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(inp)
			if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
				local p = inp.Position
				setFromAlpha(getXY(track, p.X, p.Y))
			end
		end)
		return {
			Set = function(v)
				val = math.clamp(tonumber(v) or val, minV, maxV)
				setFromAlpha((val - minV) / math.max(1e-6, maxV - minV))
			end,
			Get = function()
				return val
			end,
			Destroy = function()
				safeDestroy(row)
			end,
		}
	end

	local function sectionCreateDropdown(sec, text, options, callback, ddOpts)
		ddOpts = ddOpts or {}
		local multi = ddOpts.Multi == true
		local searchable = ddOpts.Searchable ~= false
		local sel = multi and {} or nil
		local selText = ""
		if not multi then
			selText = options[1] or ""
		end
		local row = plainFrame(getTheme().SurfaceElevated, 6)
		row.ClipsDescendants = true
		row.Size = UDim2.new(1, 0, 0, 34)
		row.ZIndex = 20
		row.Parent = sec._host
		registerSearch(row, text .. " dropdown")
		local header = Instance.new("TextButton")
		header.AutoButtonColor = false
		header.TextXAlignment = Enum.TextXAlignment.Left
		header.Font = Enum.Font.GothamMedium
		header.TextSize = 13
		header.TextColor3 = getTheme().Text
		header.Text = text .. ": " .. (selText or "")
		header.BackgroundTransparency = 1
		header.Size = UDim2.new(1, 0, 0, 34)
		header.ZIndex = 21
		header.Parent = row
		pad(header, 10, 14)
		local drop = Instance.new("Frame")
		drop.BackgroundTransparency = 1
		drop.Position = UDim2.fromOffset(0, 34)
		drop.Size = UDim2.new(1, 0, 0, 0)
		drop.Visible = false
		drop.ZIndex = 30
		drop.Parent = row
		local listF = Instance.new("ScrollingFrame")
		listF.BackgroundColor3 = getTheme().Background
		listF.BackgroundTransparency = 0.1
		listF.BorderSizePixel = 0
		listF.Size = UDim2.fromScale(1, 1)
		listF.ScrollBarThickness = 3
		listF.Visible = true
		listF.ZIndex = 31
		corner(listF, 6)
		stroke(listF, getTheme().Border, 1, 0.8)
		listF.Position = UDim2.fromOffset(0, 0)
		listF.Parent = drop
		local layout = list(listF, 2)
		local searchB
		local searchH = 0
		local function rebuildFilter(filter)
			for _, c in ipairs(listF:GetChildren()) do
				if c.Name == "OptLine" then
					c:Destroy()
				end
			end
			local f = string.lower(filter or "")
			local h = 0
			for _, opt in ipairs(options) do
				if f == "" or string.find(string.lower(tostring(opt)), f, 1, true) then
					local line = Instance.new("TextButton")
					line.AutoButtonColor = false
					line.Text = "  " .. tostring(opt)
					line.Font = Enum.Font.Gotham
					line.TextSize = 12
					line.TextColor3 = getTheme().Text
					line.TextXAlignment = Enum.TextXAlignment.Left
					line.Size = UDim2.new(1, -4, 0, 26)
					line.BackgroundColor3 = getTheme().SurfaceElevated
					line.BackgroundTransparency = 0.3
					line.Name = "OptLine"
					line.ZIndex = 32
					line.Parent = listF
					corner(line, 4)
					line.MouseButton1Click:Connect(function()
						if multi then
							local k = tostring(opt)
							local on = false
							for i, v in ipairs(sel) do
								if v == opt then
									table.remove(sel, i)
									on = true
									break
								end
							end
							if not on then
								table.insert(sel, opt)
							end
							header.Text = text .. ": " .. table.concat(sel, ", ")
						else
							selText = tostring(opt)
							header.Text = text .. ": " .. selText
							if callback then
								pcall(callback, opt)
							end
							drop.Visible = false
							row.Size = UDim2.new(1, 0, 0, 34)
						end
					end)
					h += 26 + 2
				end
			end
			listF.CanvasSize = UDim2.new(0, 0, 0, h)
			return h
		end
		if searchable then
			searchB = Instance.new("TextBox")
			searchB.PlaceholderText = "Filter…"
			searchB.Size = UDim2.new(1, -8, 0, 26)
			searchB.Position = UDim2.fromOffset(4, 4)
			searchB.BackgroundColor3 = getTheme().Surface
			searchB.TextColor3 = getTheme().Text
			searchB.Font = Enum.Font.Gotham
			searchB.TextSize = 12
			searchB.ZIndex = 33
			searchB.Parent = drop
			corner(searchB, 4)
			searchH = 34
			listF.Position = UDim2.fromOffset(0, searchH)
			searchB:GetPropertyChangedSignal("Text"):Connect(function()
				rebuildFilter(searchB.Text)
			end)
		end
		rebuildFilter("")
		local open = false
		header.MouseButton1Click:Connect(function()
			open = not open
			if open then
				if searchable and searchB then
					rebuildFilter(searchB.Text)
				else
					rebuildFilter("")
				end
				local innerH = math.min(listF.CanvasSize.Y.Offset + 8, 160)
				listF.Size = UDim2.new(1, -8, 0, innerH)
				drop.Size = UDim2.new(1, 0, 0, innerH + searchH + 4)
				drop.Visible = true
				row.Size = UDim2.new(1, 0, 0, 34 + innerH + searchH + 4)
			else
				drop.Visible = false
				row.Size = UDim2.new(1, 0, 0, 34)
			end
		end)
		return {
			Set = function(v)
				if multi then
					sel = type(v) == "table" and v or {}
					header.Text = text .. ": " .. table.concat(sel, ", ")
				else
					selText = tostring(v)
					header.Text = text .. ": " .. selText
				end
			end,
			Get = function()
				return multi and sel or selText
			end,
			Destroy = function()
				safeDestroy(row)
			end,
		}
	end

	local function sectionCreateTextbox(sec, text, opts, callback)
		opts = opts or {}
		local row = plainFrame(getTheme().SurfaceElevated, 6)
		row.Size = UDim2.new(1, 0, 0, 36)
		row.ZIndex = 10
		row.Parent = sec._host
		registerSearch(row, text .. " textbox")
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 12
		lbl.TextColor3 = getTheme().TextMuted
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Size = UDim2.new(0.38, 0, 1, 0)
		lbl.Position = UDim2.fromOffset(10, 0)
		lbl.Parent = row
		local box = Instance.new("TextBox")
		box.BackgroundColor3 = getTheme().Surface
		box.BackgroundTransparency = 0.1
		box.Text = ""
		box.PlaceholderText = opts.Placeholder or ""
		box.PlaceholderColor3 = getTheme().TextMuted
		box.TextColor3 = getTheme().Text
		box.Font = Enum.Font.Gotham
		box.TextSize = 12
		box.Size = UDim2.new(0.58, -14, 0, 26)
		box.Position = UDim2.new(0.4, 0, 0.5, -13)
		box.ClearTextOnFocus = false
		box.Parent = row
		corner(box, 4)
		stroke(box, getTheme().Border, 1, 0.85)
		if opts.Numeric then
			box:GetPropertyChangedSignal("Text"):Connect(function()
				box.Text = box.Text:gsub("[^0-9%.%-]", "")
			end)
		end
		if opts.ClearButton then
			local clr = Instance.new("TextButton")
			clr.Text = "×"
			clr.Font = Enum.Font.GothamBold
			clr.TextSize = 14
			clr.TextColor3 = getTheme().TextMuted
			clr.BackgroundTransparency = 1
			clr.Size = UDim2.fromOffset(20, 26)
			clr.Position = UDim2.new(1, -26, 0.5, -13)
			clr.Parent = row
			clr.MouseButton1Click:Connect(function()
				box.Text = ""
			end)
		end
		box.FocusLost:Connect(function(enter)
			if callback then
				pcall(callback, box.Text, enter)
			end
		end)
		return {
			Set = function(s)
				box.Text = s
			end,
			Get = function()
				return box.Text
			end,
			Destroy = function()
				safeDestroy(row)
			end,
		}
	end

	local function sectionCreateLabel(sec, text, rich)
		local row = plainFrame(getTheme().SurfaceElevated, 6)
		row.Size = UDim2.new(1, 0, 0, 0)
		row.AutomaticSize = Enum.AutomaticSize.Y
		row.ZIndex = 10
		row.Parent = sec._host
		registerSearch(row, text .. " label")
		local lbl = Instance.new(rich and "TextLabel" or "TextLabel")
		lbl.RichText = rich and true or false
		lbl.TextWrapped = true
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 12
		lbl.TextColor3 = getTheme().TextMuted
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Text = text
		lbl.Size = UDim2.new(1, -20, 0, 0)
		lbl.AutomaticSize = Enum.AutomaticSize.Y
		lbl.Position = UDim2.fromOffset(10, 8)
		lbl.Parent = row
		pad(row, 4, 8, 8, 8)
		return {
			Set = function(t)
				lbl.Text = t
			end,
			Destroy = function()
				safeDestroy(row)
			end,
		}
	end

	local function sectionCreateParagraph(sec, text)
		return sectionCreateLabel(sec, text, false)
	end

	local function sectionCreateSeparator(sec)
		local row = Instance.new("Frame")
		row.BackgroundTransparency = 1
		row.Size = UDim2.new(1, 0, 0, 14)
		row.Parent = sec._host
		local line = Instance.new("Frame")
		line.BackgroundColor3 = getTheme().Border
		line.BackgroundTransparency = 0.35
		line.BorderSizePixel = 0
		line.Size = UDim2.new(1, -20, 0, 1)
		line.Position = UDim2.new(0.5, 0, 0.5, 0)
		line.AnchorPoint = Vector2.new(0.5, 0.5)
		line.Parent = row
	end

	local function sectionCreateProgress(sec, text, startVal)
		local row = plainFrame(getTheme().SurfaceElevated, 6)
		row.Size = UDim2.new(1, 0, 0, 36)
		row.Parent = sec._host
		registerSearch(row, text .. " progress")
		local cap = Instance.new("TextLabel")
		cap.BackgroundTransparency = 1
		cap.Font = Enum.Font.GothamMedium
		cap.TextSize = 12
		cap.TextColor3 = getTheme().Text
		cap.TextXAlignment = Enum.TextXAlignment.Left
		cap.Size = UDim2.new(1, -12, 0, 14)
		cap.Position = UDim2.fromOffset(10, 3)
		cap.Text = text .. "  0%"
		cap.Parent = row
		local track = plainFrame(getTheme().TabInactive, 4)
		track.Size = UDim2.new(1, -20, 0, 8)
		track.Position = UDim2.fromOffset(10, 20)
		track.Parent = row
		local fill = plainFrame(getTheme().Accent, 4)
		local a = math.clamp(tonumber(startVal) or 0, 0, 1)
		fill.Size = UDim2.new(a, 0, 1, 0)
		fill.Parent = track
		return {
			Set = function(p)
				p = math.clamp(tonumber(p) or 0, 0, 1)
				fill.Size = UDim2.new(p, 0, 1, 0)
				cap.Text = string.format("%s  %d%%", text, math.floor(p * 100 + 0.5))
			end,
			Destroy = function()
				safeDestroy(row)
			end,
		}
	end

	local function sectionCreateImage(sec, assetId, height)
		local row = Instance.new("ImageLabel")
		row.BackgroundColor3 = getTheme().Surface
		row.Size = UDim2.new(1, 0, 0, height or 120)
		row.BackgroundTransparency = 0.2
		row.Image = assetId or ""
		row.ScaleType = Enum.ScaleType.Fit
		row.Parent = sec._host
		corner(row, 8)
		stroke(row, getTheme().Border, 1, 0.85)
		return {
			SetImage = function(id)
				row.Image = id
			end,
			Destroy = function()
				safeDestroy(row)
			end,
		}
	end

	local function sectionCreateKeybind(sec, text, defaultKey, callback)
		local cur = defaultKey or Enum.KeyCode.Unknown
		local listen = false
		local row = plainFrame(getTheme().SurfaceElevated, 6)
		row.Size = UDim2.new(1, 0, 0, 34)
		row.Parent = sec._host
		registerSearch(row, text .. " keybind")
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 13
		lbl.TextColor3 = getTheme().Text
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Size = UDim2.new(1, -80, 1, 0)
		lbl.Position = UDim2.fromOffset(10, 0)
		lbl.Parent = row
		local badge = Instance.new("TextButton")
		badge.AutoButtonColor = false
		badge.Text = cur.Name or "None"
		badge.Font = Enum.Font.GothamBold
		badge.TextSize = 11
		badge.TextColor3 = getTheme().Text
		badge.BackgroundColor3 = getTheme().TabActive
		badge.Size = UDim2.fromOffset(68, 24)
		badge.Position = UDim2.new(1, -74, 0.5, -12)
		badge.Parent = row
		corner(badge, 4)
		stroke(badge, getTheme().Accent, 1, 0.88)
		local connPress
		badge.MouseButton1Click:Connect(function()
			if listen then
				return
			end
			listen = true
			badge.Text = "…"
			tween(badge, { BackgroundColor3 = getTheme().Accent }, tweenInfo(0.15))
			if connPress then
				connPress:Disconnect()
			end
			connPress = UserInputService.InputBegan:Connect(function(inp, gpe)
				if gpe then
					return
				end
				if inp.UserInputType == Enum.UserInputType.Keyboard then
					cur = inp.KeyCode
					badge.Text = cur.Name
					listen = false
					connPress:Disconnect()
					tween(badge, { BackgroundColor3 = getTheme().TabActive }, tweenInfo(0.15))
					if callback then
						pcall(callback, cur)
					end
				end
			end)
		end)
		UserInputService.InputBegan:Connect(function(inp, gpe)
			if gpe or listen then
				return
			end
			if inp.KeyCode == cur and callback then
				pcall(callback, cur)
			end
		end)
		return {
			Set = function(k)
				cur = k
				badge.Text = cur.Name
			end,
			Get = function()
				return cur
			end,
			Destroy = function()
				safeDestroy(row)
			end,
		}
	end

	local function sectionCreateColorPicker(sec, text, default, callback)
		local c = default or Color3.fromRGB(180, 40, 60)
		local h0, s0, v0 = rgbToHsv(c)
		local row = plainFrame(getTheme().SurfaceElevated, 6)
		row.ClipsDescendants = true
		row.Size = UDim2.new(1, 0, 0, 38)
		row.Parent = sec._host
		registerSearch(row, text .. " color")
		local prev = Instance.new("Frame")
		prev.Size = UDim2.fromOffset(28, 28)
		prev.Position = UDim2.new(1, -36, 0.5, -14)
		prev.BackgroundColor3 = c
		prev.Parent = row
		corner(prev, 6)
		stroke(prev, getTheme().Text, 1, 0.8)
		local title = Instance.new("TextButton")
		title.AutoButtonColor = false
		title.Text = text
		title.Font = Enum.Font.GothamMedium
		title.TextSize = 13
		title.TextColor3 = getTheme().Text
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.BackgroundTransparency = 1
		title.Size = UDim2.new(1, -48, 0, 38)
		title.Position = UDim2.fromOffset(10, 0)
		title.Parent = row
		local exp = Instance.new("Frame")
		exp.BackgroundTransparency = 1
		exp.Position = UDim2.fromOffset(10, 38)
		exp.Size = UDim2.new(1, -20, 0, 0)
		exp.Visible = false
		exp.Parent = row
		local function addSlider(label, min, max, def, mapFn)
			local fr = Instance.new("Frame")
			fr.BackgroundTransparency = 1
			fr.Size = UDim2.new(1, 0, 0, 28)
			fr.Parent = exp
			local cap = Instance.new("TextLabel")
			cap.BackgroundTransparency = 1
			cap.Text = label
			cap.Font = Enum.Font.Gotham
			cap.TextSize = 11
			cap.TextColor3 = getTheme().TextMuted
			cap.TextXAlignment = Enum.TextXAlignment.Left
			cap.Size = UDim2.new(1, -10, 0, 12)
			cap.Parent = fr
			local track = plainFrame(getTheme().TabInactive, 3)
			track.Size = UDim2.new(1, 0, 0, 6)
			track.Position = UDim2.fromOffset(0, 16)
			track.Parent = fr
			local fill = plainFrame(getTheme().Accent, 3)
			fill.Size = UDim2.new((def - min) / math.max(1e-6, max - min), 0, 1, 0)
			fill.Parent = track
			local val = def
			local dragging = false
			local hit = Instance.new("TextButton")
			hit.Text = ""
			hit.BackgroundTransparency = 1
			hit.Size = UDim2.fromScale(1, 2)
			hit.Position = UDim2.fromOffset(0, -4)
			hit.Parent = track
			local function apply(a)
				val = min + a * (max - min)
				fill.Size = UDim2.new(a, 0, 1, 0)
				mapFn(val)
				prev.BackgroundColor3 = c
				if callback then
					pcall(callback, c)
				end
			end
			apply((def - min) / math.max(1e-6, max - min))
			hit.MouseButton1Down:Connect(function()
				dragging = true
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			UserInputService.InputChanged:Connect(function(inp)
				if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
					local p = inp.Position
					apply(getXY(track, p.X, p.Y))
				end
			end)
		end
		local open = false
		title.MouseButton1Click:Connect(function()
			open = not open
			exp.Visible = open
			if open then
				exp.Size = UDim2.new(1, -20, 0, 92)
				row.Size = UDim2.new(1, 0, 0, 138)
				for _, ch in ipairs(exp:GetChildren()) do
					ch:Destroy()
				end
				c = prev.BackgroundColor3
				h0, s0, v0 = rgbToHsv(c)
				addSlider("Hue", 0, 360, h0, function(v)
					h0 = v
					c = hsvToRgb(h0, s0, v0)
				end)
				addSlider("Saturation", 0, 1, s0, function(v)
					s0 = v
					c = hsvToRgb(h0, s0, v0)
				end)
				addSlider("Value", 0, 1, v0, function(v)
					v0 = v
					c = hsvToRgb(h0, s0, v0)
				end)
			else
				row.Size = UDim2.new(1, 0, 0, 38)
			end
		end)
		return {
			Set = function(col)
				c = col
				prev.BackgroundColor3 = c
			end,
			Get = function()
				return prev.BackgroundColor3
			end,
			Destroy = function()
				safeDestroy(row)
			end,
		}
	end

	local function buildSection(host, title, collapsedDefault)
		local sec = {}
		sec._host = host
		local head = plainFrame(getTheme().SurfaceElevated, 6)
		head.Size = UDim2.new(1, 0, 0, 28)
		head.ZIndex = 8
		head.Parent = host
		local arrow = Instance.new("TextLabel")
		arrow.BackgroundTransparency = 1
		arrow.Text = collapsedDefault and "▸" or "▾"
		arrow.Size = UDim2.fromOffset(18, 28)
		arrow.Font = Enum.Font.GothamBold
		arrow.TextSize = 12
		arrow.TextColor3 = getTheme().Accent
		arrow.Parent = head
		local htxt = Instance.new("TextLabel")
		htxt.BackgroundTransparency = 1
		htxt.Text = title
		htxt.Font = Enum.Font.GothamBold
		htxt.TextSize = 12
		htxt.TextColor3 = getTheme().Text
		htxt.TextXAlignment = Enum.TextXAlignment.Left
		htxt.Size = UDim2.new(1, -24, 1, 0)
		htxt.Position = UDim2.fromOffset(20, 0)
		htxt.Parent = head
		registerSearch(head, title .. " section")
		local body = Instance.new("Frame")
		body.BackgroundTransparency = 1
		body.Size = UDim2.new(1, 0, 0, 0)
		body.AutomaticSize = Enum.AutomaticSize.Y
		body.Visible = collapsedDefault ~= true
		body.Parent = host
		local bl = list(body, 6)
		bl.Padding = UDim.new(0, 6)
		sec._body = body
		local collapsed = collapsedDefault == true
		local hit = Instance.new("TextButton")
		hit.Text = ""
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.fromScale(1, 1)
		hit.ZIndex = 3
		hit.Parent = head
		hit.MouseButton1Click:Connect(function()
			collapsed = not collapsed
			body.Visible = not collapsed
			arrow.Text = collapsed and "▸" or "▾"
		end)
		function sec:CreateButton(...)
			return sectionCreateButton(self, ...)
		end
		function sec:CreateToggle(text, default, cb, key)
			return sectionCreateToggle(self, text, default, cb, key)
		end
		function sec:CreateSlider(text, opts, cb, key)
			return sectionCreateSlider(self, text, opts, cb, key)
		end
		function sec:CreateDropdown(text, opts, cb, dopts)
			return sectionCreateDropdown(self, text, opts, cb, dopts)
		end
		function sec:CreateTextbox(text, opts, cb)
			return sectionCreateTextbox(self, text, opts, cb)
		end
		function sec:CreateLabel(text, rich)
			return sectionCreateLabel(self, text, rich)
		end
		function sec:CreateParagraph(text)
			return sectionCreateParagraph(self, text)
		end
		function sec:CreateSeparator()
			return sectionCreateSeparator(self)
		end
		function sec:CreateProgress(text, v)
			return sectionCreateProgress(self, text, v)
		end
		function sec:CreateImage(assetId, h)
			return sectionCreateImage(self, assetId, h)
		end
		function sec:CreateKeybind(text, def, cb)
			return sectionCreateKeybind(self, text, def, cb)
		end
		function sec:CreateColorPicker(text, def, cb)
			return sectionCreateColorPicker(self, text, def, cb)
		end
		return sec
	end

	function win:CreateTab(opts)
		opts = type(opts) == "string" and { Name = opts } or (opts or {})
		local title = opts.Name or "Tab"
		tabOrder += 1
		local btn = plainFrame(getTheme().TabInactive, 6)
		btn.Size = UDim2.new(1, -8, 0, 32)
		btn.ZIndex = 6
		btn.LayoutOrder = tabOrder
		btn.Parent = tabList
		stroke(btn, getTheme().Border, 1, 0.9)
		local strip = plainFrame(getTheme().Accent, 2)
		strip.Size = UDim2.new(0, 3, 0.55, 0)
		strip.Position = UDim2.new(0, 2, 0.225, 0)
		strip.Parent = btn
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Text = (opts.Icon and (opts.Icon .. "  ") or "") .. title
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 12
		lbl.TextColor3 = getTheme().Text
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.Size = UDim2.new(1, -12, 1, 0)
		lbl.Position = UDim2.fromOffset(10, 0)
		lbl.Parent = btn
		registerSearch(btn, title .. " tab")

		local page = Instance.new("ScrollingFrame")
		page.Name = title
		page.BackgroundTransparency = 1
		page.Size = UDim2.fromScale(1, 1)
		page.ScrollBarThickness = 3
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.Visible = tabOrder == 1
		page.ZIndex = 6
		page.Parent = contentHost
		local holder = Instance.new("Frame")
		holder.BackgroundTransparency = 1
		holder.Size = UDim2.new(1, 0, 0, 0)
		holder.AutomaticSize = Enum.AutomaticSize.Y
		holder.Parent = page
		pad(holder, 4, 8, 10, 8)
		local plist = list(holder, 8)
		plist:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.new(0, 0, 0, plist.AbsoluteContentSize.Y + 24)
		end)

		local tab = {}
		tab._page = page
		tab._btn = btn
		tab._strip = strip
		tab._lbl = lbl
		function tab:CreateSection(name, sopts)
			sopts = sopts or {}
			return buildSection(holder, name, sopts.Collapsed or sopts.collapsed)
		end

		local function selectThis()
			for _, t in ipairs(tabs) do
				t._page.Visible = false
				tween(t._btn, { BackgroundColor3 = getTheme().TabInactive })
				t._strip.BackgroundTransparency = 0.85
				t._lbl.TextTransparency = 0.25
			end
			tab._page.Visible = true
			tween(tab._btn, { BackgroundColor3 = getTheme().TabActive })
			tab._strip.BackgroundTransparency = 0
			tween(tab._lbl, { TextTransparency = 0 })
		end

		btn.MouseButton1Click:Connect(function()
			if soundOn then
				playSound(SOUND_IDS.Click, 0.12)
			end
			selectThis()
		end)

		table.insert(tabs, tab)
		if tabOrder == 1 then
			tween(btn, { BackgroundColor3 = getTheme().TabActive })
			strip.BackgroundTransparency = 0
			lbl.TextTransparency = 0
		else
			strip.BackgroundTransparency = 0.85
			lbl.TextTransparency = 0.25
		end

		function tab:Notify(opts)
			return win:Notify(opts)
		end
		return tab
	end

	win.ScreenGui = gui
	win.Root = root

	local minOpen = true
	if minBtn then
		minBtn.MouseButton1Click:Connect(function()
			minOpen = not minOpen
			body.Visible = minOpen
		end)
	end
	if closeBtn then
		closeBtn.MouseButton1Click:Connect(function()
			win:Hide()
		end)
	end

	if win._toggleKey then
		UserInputService.InputBegan:Connect(function(inp, gpe)
			if gpe then
				return
			end
			if inp.KeyCode == win._toggleKey then
				gui.Enabled = not gui.Enabled
			end
		end)
	end

	local tb = config.TopBarButton
	if tb and (tb.Letter or tb.Image) then
		local tbg = Instance.new("ScreenGui")
		tbg.Name = winId .. "_TopBar"
		tbg.ResetOnSpawn = false
		tbg.IgnoreGuiInset = true
		tbg.DisplayOrder = (gui.DisplayOrder or 8) + 5
		tbg.Parent = target
		local pill = Instance.new("ImageButton")
		pill.BackgroundColor3 = getTheme().Background
		pill.BackgroundTransparency = 0.15
		pill.Size = UDim2.fromOffset(36, 36)
		pill.Position = UDim2.new(0, 300, 0, 6)
		pill.AutoButtonColor = false
		pill.Image = ""
		pill.Parent = tbg
		corner(pill, 8)
		stroke(pill, getTheme().Accent, 1, 0.75)
		if tb.Image then
			local im = Instance.new("ImageLabel")
			im.BackgroundTransparency = 1
			im.Size = UDim2.fromOffset(22, 22)
			im.Position = UDim2.fromScale(0.5, 0.5)
			im.AnchorPoint = Vector2.new(0.5, 0.5)
			im.Image = tb.Image
			im.Parent = pill
		else
			local L = Instance.new("TextLabel")
			L.BackgroundTransparency = 1
			L.Font = Enum.Font.GothamBold
			L.TextSize = 15
			L.TextColor3 = getTheme().Accent
			L.Text = tostring(tb.Letter):sub(1, 2)
			L.Size = UDim2.fromScale(1, 1)
			L.Parent = pill
		end
		pill.MouseButton1Click:Connect(function()
			gui.Enabled = not gui.Enabled
		end)
	end

	return win
end

-- ═══════════════════════════════════════════════════════════════
-- Legacy UILibrary.Load (v0.0.1 style) — maps to CreateWindow + CreateTab
-- ═══════════════════════════════════════════════════════════════

local UILibrary = {}

function UILibrary.Load(hubName, gameName, version, topBar)
	local W = OxBlood.CreateWindow({
		Title = hubName or "OxBlood",
		Subtitle = gameName or "",
		Version = version or OxBlood.VERSION,
		Name = hubName or "OxBlood",
		TopBarButton = topBar,
		WindowSearch = true,
	})
	local API = {}
	function API.AddPage(pageTitle, searchInTab)
		local tab = W:CreateTab({ Name = pageTitle })
		local defaultSec = nil
		local function ensureSec()
			if not defaultSec then
				defaultSec = tab:CreateSection("General", {})
			end
			return defaultSec
		end
		local P = {}
		function P.AddSection(text)
			defaultSec = tab:CreateSection(text, {})
			return defaultSec
		end
		function P.AddButton(text, cb)
			return ensureSec():CreateButton(text, cb)
		end
		function P.AddToggle(text, def, cb)
			return ensureSec():CreateToggle(text, def, cb)
		end
		function P.AddSlider(text, cfg, cb)
			return ensureSec():CreateSlider(text, cfg, cb)
		end
		function P.AddDropdown(text, arr, cb)
			return ensureSec():CreateDropdown(text, arr, cb, { Searchable = searchInTab ~= false })
		end
		function P.AddInput(text, ph, cb)
			return ensureSec():CreateTextbox(text, { Placeholder = ph }, cb)
		end
		function P.AddKeybind(text, def, cb)
			return ensureSec():CreateKeybind(text, def, cb)
		end
		function P.AddTextInfo(text)
			local L = ensureSec():CreateLabel(text)
			return { Set = function(t) L.Set(t) end }
		end
		function P.AddColourPicker(text, def, cb)
			return ensureSec():CreateColorPicker(text, def, cb)
		end
		function P.AddLabel(t)
			return ensureSec():CreateLabel(t)
		end
		return P
	end
	function API.Notify(title, msg, typ, dur)
		return W:Notify({ Title = title, Description = msg or "", Type = typ or "info", Duration = dur or 4 })
	end
	function API.Destroy()
		W:Destroy()
	end
	function API.Hide()
		W:Hide()
	end
	function API.Show()
		W:Show()
	end
	API.Window = W
	return API
end

OxBlood.UILibrary = UILibrary

--- Backward-compatible global: `local Lib = loadstring(...)(); Lib.Load(...)`
function OxBlood.Load(...)
	return UILibrary.Load(...)
end

return OxBlood
