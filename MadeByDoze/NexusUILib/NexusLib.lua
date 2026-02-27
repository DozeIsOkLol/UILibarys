--[[
╔═══════════════════════════════════════════════════════╗
║           NexusLib v2.0 - Roblox UI Library           ║
║  Features: Tabs, Sub-Tabs, Toggles, Sliders,          ║
║  Dropdowns (multi), ColorPicker, Keybinds,            ║
║  TextInput, Config Save/Load, Search, Tooltips,       ║
║  Watermark, Animated open/close, Smooth transitions   ║
╚═══════════════════════════════════════════════════════╝

    Usage:
        local Nexus = loadstring(game:HttpGet("RAW_URL"))()
        local Win   = Nexus:CreateWindow({ Title = "My Script" })
        local Tab   = Win:AddTab({ Name = "Combat", Icon = "⚔" })
        Tab:AddToggle({ Name = "God Mode", Callback = function(v) end })
]]

-- ─── Strict mode & Services ──────────────────────────────────────────────────
local NexusLib = {}
NexusLib.__index = NexusLib

local Players          = game:GetService("Players")
local UIS              = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")

local LP    = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ─── Theme ───────────────────────────────────────────────────────────────────
local T = {
    Bg          = Color3.fromRGB(13, 13, 17),
    Surface     = Color3.fromRGB(20, 20, 26),
    Elevated    = Color3.fromRGB(28, 28, 36),
    Card        = Color3.fromRGB(24, 24, 31),
    Border      = Color3.fromRGB(42, 42, 56),
    BorderLight = Color3.fromRGB(60, 60, 80),
    Accent      = Color3.fromRGB(99, 157, 255),
    AccentHover = Color3.fromRGB(130, 180, 255),
    AccentDim   = Color3.fromRGB(60, 100, 200),
    AccentGlow  = Color3.fromRGB(40, 70, 160),
    Text        = Color3.fromRGB(220, 220, 232),
    TextSub     = Color3.fromRGB(160, 160, 180),
    TextMuted   = Color3.fromRGB(100, 100, 125),
    Success     = Color3.fromRGB(72, 199, 116),
    Warning     = Color3.fromRGB(255, 185, 70),
    Danger      = Color3.fromRGB(255, 80, 80),
    Info        = Color3.fromRGB(99, 157, 255),
    ToggleOn    = Color3.fromRGB(99, 157, 255),
    ToggleOff   = Color3.fromRGB(44, 44, 60),
    ScrollBar   = Color3.fromRGB(60, 60, 80),
    White       = Color3.new(1, 1, 1),
    Black       = Color3.new(0, 0, 0),
}

-- ─── Easing presets ──────────────────────────────────────────────────────────
local SPRING  = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local FAST    = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local SLOW    = TweenInfo.new(0.5,  Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local LINEAR  = TweenInfo.new(1,    Enum.EasingStyle.Linear)

-- ─── Utilities ───────────────────────────────────────────────────────────────
local function Tween(obj, props, info)
    TweenService:Create(obj, info or FAST, props):Play()
end

local function New(cls, props, children)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            pcall(function() o[k] = v end)
        end
    end
    for _, c in ipairs(children or {}) do
        c.Parent = o
    end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function Corner(r, parent)
    return New("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = parent })
end

local function Stroke(color, thickness, parent)
    return New("UIStroke", {
        Color = color or T.Border,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function Pad(l, r, t, b, parent)
    return New("UIPadding", {
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        Parent = parent,
    })
end

local function MakeDraggable(frame, handle)
    local drag, ds, fs = false, nil, nil
    ;(handle or frame).InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; ds = i.Position; fs = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            frame.Position = UDim2.new(fs.X.Scale, fs.X.Offset + d.X, fs.Y.Scale, fs.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

-- pcall-safe writefile / readfile / isfile
local function SafeWrite(path, data)
    local ok, err = pcall(writefile, path, data)
    return ok, err
end
local function SafeRead(path)
    if not pcall(isfile, path) then return nil end
    local ok, data = pcall(readfile, path)
    return ok and data or nil
end

-- ─── Root GUI ────────────────────────────────────────────────────────────────
local function GetRoot()
    local existing = CoreGui:FindFirstChild("NexusLibV2")
    if existing then existing:Destroy() end
    return New("ScreenGui", {
        Name            = "NexusLibV2",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        DisplayOrder    = 999,
        Parent          = CoreGui,
    })
end

-- ─── Tooltip System ──────────────────────────────────────────────────────────
local function MakeTooltip(root)
    local tip = New("Frame", {
        Size              = UDim2.new(0, 10, 0, 24),
        BackgroundColor3  = T.Elevated,
        BorderSizePixel   = 0,
        ZIndex            = 100,
        Visible           = false,
        Parent            = root,
    })
    Corner(5, tip)
    Stroke(T.BorderLight, 1, tip)
    Pad(8, 8, 0, 0, tip)

    local lbl = New("TextLabel", {
        Text              = "",
        Font              = Enum.Font.Gotham,
        TextSize          = 11,
        TextColor3        = T.TextSub,
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, 0, 1, 0),
        ZIndex            = 101,
        Parent            = tip,
    })

    local function Show(text, x, y)
        lbl.Text = text
        local tw = math.max(text:len() * 7 + 16, 60)
        tip.Size = UDim2.new(0, tw, 0, 24)
        tip.Position = UDim2.new(0, x + 12, 0, y - 30)
        tip.Visible = true
        tip.BackgroundTransparency = 1
        lbl.TextTransparency = 1
        Tween(tip,  { BackgroundTransparency = 0 }, FAST)
        Tween(lbl,  { TextTransparency = 0 }, FAST)
    end
    local function Hide()
        Tween(tip, { BackgroundTransparency = 1 }, FAST)
        Tween(lbl, { TextTransparency = 1 }, FAST)
        task.delay(0.2, function() tip.Visible = false end)
    end

    return Show, Hide
end

-- ─── Notification System ─────────────────────────────────────────────────────
local NotifContainer

local function InitNotifContainer(root)
    NotifContainer = New("Frame", {
        Name                = "Notifications",
        Size                = UDim2.new(0, 290, 1, -20),
        Position            = UDim2.new(1, -300, 0, 10),
        BackgroundTransparency = 1,
        Parent              = root,
    })
    local layout = New("UIListLayout", {
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Bottom,
        Padding             = UDim.new(0, 6),
        Parent              = NotifContainer,
    })
end

function NexusLib:Notify(opts)
    opts = opts or {}
    local title    = opts.Title   or "Notice"
    local message  = opts.Message or ""
    local ntype    = opts.Type    or "Info"
    local duration = opts.Duration or 4

    local accent = ({ Info=T.Info, Success=T.Success, Warning=T.Warning, Error=T.Danger })[ntype] or T.Info

    local card = New("Frame", {
        Size              = UDim2.new(1, 0, 0, 0),
        BackgroundColor3  = T.Surface,
        ClipsDescendants  = true,
        BorderSizePixel   = 0,
        Parent            = NotifContainer,
    })
    Corner(8, card)
    Stroke(accent, 1, card)

    New("Frame", { -- left accent bar
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = card,
    })

    New("TextLabel", {
        Text              = title,
        Font              = Enum.Font.GothamBold,
        TextSize          = 12,
        TextColor3        = T.Text,
        BackgroundTransparency = 1,
        Position          = UDim2.new(0, 14, 0, 8),
        Size              = UDim2.new(1, -18, 0, 16),
        TextXAlignment    = Enum.TextXAlignment.Left,
        Parent            = card,
    })
    New("TextLabel", {
        Text              = message,
        Font              = Enum.Font.Gotham,
        TextSize          = 11,
        TextColor3        = T.TextMuted,
        BackgroundTransparency = 1,
        Position          = UDim2.new(0, 14, 0, 26),
        Size              = UDim2.new(1, -18, 0, 28),
        TextXAlignment    = Enum.TextXAlignment.Left,
        TextWrapped       = true,
        Parent            = card,
    })

    local bar = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Parent           = card,
    })

    -- Slide in
    Tween(card, { Size = UDim2.new(1, 0, 0, 64) }, SPRING)
    task.delay(0.05, function()
        Tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, TweenInfo.new(duration, Enum.EasingStyle.Linear))
    end)

    task.delay(duration, function()
        Tween(card, { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1 }, SPRING)
        task.delay(0.4, function() pcall(function() card:Destroy() end) end)
    end)
end

-- ─── Watermark ───────────────────────────────────────────────────────────────
local function CreateWatermark(root, opts)
    opts = opts or {}
    local text = opts.Text or "NexusLib"
    local wm = New("Frame", {
        Size             = UDim2.new(0, 0, 0, 28),
        Position         = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        AutomaticSize    = Enum.AutomaticSize.X,
        Parent           = root,
    })
    Corner(6, wm)
    Stroke(T.Border, 1, wm)
    Pad(10, 10, 0, 0, wm)

    New("Frame", { -- accent pip
        Size             = UDim2.new(0, 5, 0, 5),
        Position         = UDim2.new(0, 0, 0.5, -2),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Parent           = wm,
        [1]              = Corner(9),
    })

    local lbl = New("TextLabel", {
        Text              = "  " .. text,
        Font              = Enum.Font.GothamBold,
        TextSize          = 12,
        TextColor3        = T.Text,
        BackgroundTransparency = 1,
        Size              = UDim2.new(0, 0, 1, 0),
        AutomaticSize     = Enum.AutomaticSize.X,
        Parent            = wm,
    })
    Corner(9, wm:FindFirstChildOfClass("Frame"))

    -- Clock update
    RunService.Heartbeat:Connect(function()
        lbl.Text = "  " .. text .. "  |  " .. os.date("%H:%M:%S")
    end)

    return {
        SetText = function(_, t) text = t end,
        SetVisible = function(_, v) wm.Visible = v end,
    }
end

-- ─── Main Window ─────────────────────────────────────────────────────────────
function NexusLib:CreateWindow(opts)
    opts = opts or {}
    local title     = opts.Title      or "Nexus"
    local subtitle  = opts.Subtitle   or "v2.0"
    local winSize   = opts.Size       or UDim2.new(0, 560, 0, 400)
    local toggleKey = opts.ToggleKey  or Enum.KeyCode.RightShift
    local configDir = opts.ConfigDir  or "NexusLib"
    local watermarkText = opts.Watermark

    local root = GetRoot()
    InitNotifContainer(root)

    local ShowTooltip, HideTooltip = MakeTooltip(root)

    -- Config store: { profileName = { elementId = value } }
    local configStore = {}
    local currentProfile = "Default"
    local elementRegistry = {} -- id -> { Get, Set }

    local function SaveProfile(name)
        name = name or currentProfile
        local data = {}
        for id, ctrl in pairs(elementRegistry) do
            local ok, v = pcall(ctrl.Get)
            if ok then data[id] = v end
        end
        configStore[name] = data
        local path = configDir .. "/" .. name .. ".json"
        local encoded
        local ok, err = pcall(function() encoded = HttpService:JSONEncode(configStore) end)
        if ok then SafeWrite(path, encoded) end
    end

    local function LoadProfile(name)
        name = name or currentProfile
        local path = configDir .. "/" .. name .. ".json"
        local raw = SafeRead(path)
        if not raw then return end
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok or not decoded[name] then return end
        local data = decoded[name]
        for id, value in pairs(data) do
            if elementRegistry[id] then
                pcall(elementRegistry[id].Set, elementRegistry[id], value)
            end
        end
        currentProfile = name
    end

    -- ── Window Frame ─────────────────────────────────────────────────────────
    local win = New("Frame", {
        Name             = "NexusWindow",
        Size             = UDim2.new(0, winSize.X.Offset, 0, 0), -- starts at 0 height for open anim
        Position         = UDim2.new(0.5, -winSize.X.Offset/2, 0.5, -winSize.Y.Offset/2),
        BackgroundColor3 = T.Bg,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Parent           = root,
    })
    Corner(10, win)
    Stroke(T.Border, 1, win)

    -- Shadow
    New("ImageLabel", {
        Size              = UDim2.new(1, 60, 1, 60),
        Position          = UDim2.new(0, -30, 0, -30),
        BackgroundTransparency = 1,
        Image             = "rbxassetid://6014261993",
        ImageColor3       = T.Black,
        ImageTransparency = 0.45,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(49, 49, 450, 450),
        ZIndex            = 0,
        Parent            = win,
    })

    -- Animate open
    task.defer(function()
        Tween(win, { Size = winSize }, SPRING)
    end)

    -- ── Titlebar ─────────────────────────────────────────────────────────────
    local tbar = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = win,
    })
    Corner(10, tbar)
    New("Frame", { -- cover bottom corners
        Size             = UDim2.new(1, 0, 0, 10),
        Position         = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = tbar,
    })

    -- Title pip
    local pip = New("Frame", {
        Size             = UDim2.new(0, 7, 0, 7),
        Position         = UDim2.new(0, 14, 0.5, -3),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = tbar,
    })
    Corner(9, pip)

    New("TextLabel", {
        Text             = title,
        Font             = Enum.Font.GothamBold,
        TextSize         = 14,
        TextColor3       = T.Text,
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, 28, 0, 4),
        Size             = UDim2.new(0, 200, 0, 18),
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 6,
        Parent           = tbar,
    })
    New("TextLabel", {
        Text             = subtitle,
        Font             = Enum.Font.Gotham,
        TextSize         = 10,
        TextColor3       = T.TextMuted,
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, 28, 0, 24),
        Size             = UDim2.new(0, 200, 0, 14),
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 6,
        Parent           = tbar,
    })

    -- Window control buttons
    local function WinBtn(xOffset, bg, icon)
        local btn = New("TextButton", {
            Size             = UDim2.new(0, 20, 0, 20),
            Position         = UDim2.new(1, xOffset, 0.5, -10),
            BackgroundColor3 = bg,
            Text             = icon,
            Font             = Enum.Font.GothamBold,
            TextSize         = 9,
            TextColor3       = Color3.new(0,0,0),
            TextTransparency = 0.5,
            BorderSizePixel  = 0,
            ZIndex           = 7,
            Parent           = tbar,
        })
        Corner(9, btn)
        btn.MouseEnter:Connect(function() Tween(btn, { Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, xOffset - 1, 0.5, -11) }, FAST) end)
        btn.MouseLeave:Connect(function() Tween(btn, { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, xOffset, 0.5, -10) }, FAST) end)
        return btn
    end

    local closeBtn = WinBtn(-28, T.Danger,  "✕")
    local minBtn   = WinBtn(-54, T.Warning, "−")

    MakeDraggable(win, tbar)

    local minimized = false
    local visible   = true

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Tween(win, { Size = minimized and UDim2.new(0, winSize.X.Offset, 0, 46) or winSize }, SPRING)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        Tween(win, { Size = UDim2.new(0, winSize.X.Offset, 0, 0), BackgroundTransparency = 1 }, SPRING)
        task.delay(0.4, function() root:Destroy() end)
    end)

    UIS.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == toggleKey then
            visible = not visible
            win.Visible = visible
        end
    end)

    -- ── Sidebar ───────────────────────────────────────────────────────────────
    local sidebar = New("Frame", {
        Size             = UDim2.new(0, 136, 1, -46),
        Position         = UDim2.new(0, 0, 0, 46),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        Parent           = win,
    })

    New("Frame", { -- right border
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        Parent           = sidebar,
    })

    local tabScroll = New("ScrollingFrame", {
        Size                = UDim2.new(1, 0, 1, -10),
        Position            = UDim2.new(0, 0, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        ScrollBarThickness  = 0,
        ScrollingDirection  = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent              = sidebar,
    })
    Pad(6, 6, 0, 0, tabScroll)
    New("UIListLayout", {
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, 2),
        Parent              = tabScroll,
    })

    -- ── Content Area ──────────────────────────────────────────────────────────
    local contentArea = New("Frame", {
        Size             = UDim2.new(1, -136, 1, -46),
        Position         = UDim2.new(0, 136, 0, 46),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Parent           = win,
    })

    -- ── Tab system ────────────────────────────────────────────────────────────
    local allTabs    = {}
    local activeTab  = nil

    local function ActivateTab(entry)
        if activeTab == entry then return end
        -- Hide all
        for _, t in ipairs(allTabs) do
            if t ~= entry then
                Tween(t.Btn, { BackgroundTransparency = 1, BackgroundColor3 = T.Surface }, FAST)
                Tween(t.BtnLabel, { TextColor3 = T.TextMuted }, FAST)
                Tween(t.Indicator, { BackgroundTransparency = 1 }, FAST)
                t.Frame.Visible = false
            end
        end
        -- Show selected
        Tween(entry.Btn, { BackgroundTransparency = 0, BackgroundColor3 = T.Elevated }, FAST)
        Tween(entry.BtnLabel, { TextColor3 = T.Text }, FAST)
        Tween(entry.Indicator, { BackgroundTransparency = 0 }, FAST)
        entry.Frame.Visible = true
        -- Slide in from right
        entry.Frame.Position = UDim2.new(0.05, 0, 0, 0)
        entry.Frame.BackgroundTransparency = 1
        Tween(entry.Frame, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, SPRING)
        activeTab = entry
    end

    -- ── Window Object ─────────────────────────────────────────────────────────
    local WindowObj = { _root = root }

    -- Watermark
    if watermarkText then
        WindowObj.Watermark = CreateWatermark(root, { Text = watermarkText })
    end

    function WindowObj:AddWatermark(text)
        self.Watermark = CreateWatermark(root, { Text = text })
        return self.Watermark
    end

    -- ── Config Profiles ───────────────────────────────────────────────────────
    function WindowObj:SaveConfig(name)
        SaveProfile(name or currentProfile)
        NexusLib.Notify(NexusLib, {
            Title   = "Config Saved",
            Message = "Profile '" .. (name or currentProfile) .. "' saved.",
            Type    = "Success",
        })
    end

    function WindowObj:LoadConfig(name)
        LoadProfile(name or currentProfile)
        NexusLib.Notify(NexusLib, {
            Title   = "Config Loaded",
            Message = "Profile '" .. (name or currentProfile) .. "' loaded.",
            Type    = "Info",
        })
    end

    function WindowObj:SetProfile(name)
        currentProfile = name
    end

    -- ── AddTab ────────────────────────────────────────────────────────────────
    function WindowObj:AddTab(tabOpts)
        tabOpts = tabOpts or {}
        local tabName = tabOpts.Name or "Tab"
        local tabIcon = tabOpts.Icon or ""

        -- Sidebar button
        local btn = New("TextButton", {
            Size             = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = T.Surface,
            BackgroundTransparency = 1,
            Text             = "",
            BorderSizePixel  = 0,
            Parent           = tabScroll,
        })
        Corner(6, btn)

        local indicator = New("Frame", {
            Size             = UDim2.new(0, 3, 0.55, 0),
            Position         = UDim2.new(0, 0, 0.225, 0),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            Parent           = btn,
        })
        Corner(3, indicator)

        local btnLabel = New("TextLabel", {
            Text             = (tabIcon ~= "" and tabIcon .. "  " or "") .. tabName,
            Font             = Enum.Font.Gotham,
            TextSize         = 12,
            TextColor3       = T.TextMuted,
            BackgroundTransparency = 1,
            Position         = UDim2.new(0, 12, 0, 0),
            Size             = UDim2.new(1, -12, 1, 0),
            TextXAlignment   = Enum.TextXAlignment.Left,
            Parent           = btn,
        })

        -- Search bar
        local searchBox = New("TextBox", {
            PlaceholderText  = "🔍  Search...",
            PlaceholderColor3 = T.TextMuted,
            Text             = "",
            Font             = Enum.Font.Gotham,
            TextSize         = 11,
            TextColor3       = T.Text,
            BackgroundColor3 = T.Elevated,
            Size             = UDim2.new(1, -16, 0, 26),
            Position         = UDim2.new(0, 8, 0, 6),
            BorderSizePixel  = 0,
            ClearTextOnFocus = false,
            Parent           = contentArea, -- temp, will reparent
        })
        Corner(6, searchBox)
        Stroke(T.Border, 1, searchBox)
        Pad(8, 8, 0, 0, searchBox)
        searchBox.Focused:Connect(function()   Tween(searchBox, { BackgroundColor3 = T.Card }, FAST) end)
        searchBox.FocusLost:Connect(function() Tween(searchBox, { BackgroundColor3 = T.Elevated }, FAST) end)

        -- Tab content frame
        local frame = New("ScrollingFrame", {
            Size                = UDim2.new(1, 0, 1, -40),
            Position            = UDim2.new(0, 0, 0, 38),
            BackgroundTransparency = 1,
            BorderSizePixel     = 0,
            ScrollBarThickness  = 3,
            ScrollBarImageColor3 = T.ScrollBar,
            ScrollingDirection  = Enum.ScrollingDirection.Y,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible             = false,
            Parent              = contentArea,
        })
        Pad(10, 10, 6, 10, frame)
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 5),
            Parent    = frame,
        })

        searchBox.Parent = contentArea
        searchBox.Visible = false

        local entry = { Btn = btn, BtnLabel = btnLabel, Indicator = indicator, Frame = frame, SearchBox = searchBox }
        table.insert(allTabs, entry)

        btn.MouseButton1Click:Connect(function()
            -- Hide all searchboxes, show ours
            for _, t in ipairs(allTabs) do t.SearchBox.Visible = false end
            searchBox.Visible = true
            ActivateTab(entry)
        end)

        if #allTabs == 1 then
            searchBox.Visible = true
            ActivateTab(entry)
        end

        -- Search filter
        local allElements = {}
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = searchBox.Text:lower()
            for _, el in ipairs(allElements) do
                if q == "" then
                    el.Visible = true
                else
                    el.Visible = (el.Name:lower():find(q, 1, true) ~= nil)
                end
            end
        end)

        -- ── Sub-Tab system ────────────────────────────────────────────────────
        local subTabBar   = nil
        local subContents = {}
        local activeSub   = nil
        local hasSubTabs  = false

        local function InitSubTabs()
            if hasSubTabs then return end
            hasSubTabs = true

            -- Adjust main frame
            frame.Position = UDim2.new(0, 0, 0, 72)
            frame.Size     = UDim2.new(1, 0, 1, -74)
            searchBox.Position = UDim2.new(0, 8, 0, 40)

            subTabBar = New("Frame", {
                Size             = UDim2.new(1, -16, 0, 26),
                Position         = UDim2.new(0, 8, 0, 68),
                BackgroundColor3 = T.Elevated,
                BorderSizePixel  = 0,
                Parent           = contentArea,
                Visible          = false,
            })
            Corner(6, subTabBar)
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder     = Enum.SortOrder.LayoutOrder,
                Padding       = UDim.new(0, 2),
                Parent        = subTabBar,
            })
            Pad(2, 2, 2, 2, subTabBar)

            entry.SubTabBar = subTabBar

            -- Make frame use sub-content instead
            frame.Visible = false
            frame.Size    = UDim2.new(1, 0, 0, 0) -- hidden; sub tabs take over

            -- Override ActivateTab to show subTabBar
            local origAct = entry
            btn.MouseButton1Click:Connect(function()
                if subTabBar then subTabBar.Visible = activeTab == entry end
            end)
        end

        local TabObj = {}

        -- ── AddSubTab ─────────────────────────────────────────────────────────
        function TabObj:AddSubTab(stOpts)
            stOpts = stOpts or {}
            local stName = stOpts.Name or "Sub"
            InitSubTabs()

            local stBtn = New("TextButton", {
                Size             = UDim2.new(0, 1, 1, 0), -- auto-sized via layout
                AutomaticSize    = Enum.AutomaticSize.X,
                BackgroundColor3 = T.Elevated,
                BackgroundTransparency = 1,
                Text             = stName,
                Font             = Enum.Font.Gotham,
                TextSize         = 11,
                TextColor3       = T.TextMuted,
                BorderSizePixel  = 0,
                Parent           = subTabBar,
            })
            Corner(5, stBtn)
            Pad(10, 10, 0, 0, stBtn)

            local stFrame = New("ScrollingFrame", {
                Size                = UDim2.new(1, 0, 1, -104),
                Position            = UDim2.new(0, 0, 0, 100),
                BackgroundTransparency = 1,
                BorderSizePixel     = 0,
                ScrollBarThickness  = 3,
                ScrollBarImageColor3 = T.ScrollBar,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Visible             = false,
                Parent              = contentArea,
            })
            Pad(10, 10, 6, 10, stFrame)
            New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 5),
                Parent    = stFrame,
            })

            local stEntry = { Btn = stBtn, Frame = stFrame, Name = stName }
            table.insert(subContents, stEntry)

            local function ActivateSub(se)
                for _, s in ipairs(subContents) do
                    s.Frame.Visible = false
                    Tween(s.Btn, { BackgroundTransparency = 1, TextColor3 = T.TextMuted }, FAST)
                end
                se.Frame.Visible = true
                Tween(se.Btn, { BackgroundTransparency = 0, BackgroundColor3 = T.Surface, TextColor3 = T.Text }, FAST)
                activeSub = se
            end

            stBtn.MouseButton1Click:Connect(function() ActivateSub(stEntry) end)
            if #subContents == 1 then
                task.defer(function()
                    subTabBar.Visible = true
                    ActivateSub(stEntry)
                end)
            end

            -- ── SubTab Element Builder ─────────────────────────────────────────
            local SubTabObj = {}
            local subAllElements = {}

            -- Section
            function SubTabObj:AddSection(name)
                return TabObj.AddSectionToFrame(nil, name, stFrame)
            end
            function SubTabObj:AddButton(o)    return TabObj.AddButtonToFrame(nil, o, stFrame, subAllElements) end
            function SubTabObj:AddToggle(o)    return TabObj.AddToggleToFrame(nil, o, stFrame, subAllElements) end
            function SubTabObj:AddSlider(o)    return TabObj.AddSliderToFrame(nil, o, stFrame, subAllElements) end
            function SubTabObj:AddDropdown(o)  return TabObj.AddDropdownToFrame(nil, o, stFrame, subAllElements) end
            function SubTabObj:AddMultiDropdown(o) return TabObj.AddMultiDropdownToFrame(nil, o, stFrame, subAllElements) end
            function SubTabObj:AddTextInput(o) return TabObj.AddTextInputToFrame(nil, o, stFrame, subAllElements) end
            function SubTabObj:AddKeybind(o)   return TabObj.AddKeybindToFrame(nil, o, stFrame, subAllElements) end
            function SubTabObj:AddColorPicker(o) return TabObj.AddColorPickerToFrame(nil, o, stFrame, subAllElements) end
            function SubTabObj:AddConfigPanel() return TabObj.AddConfigPanelToFrame(nil, stFrame, subAllElements) end

            return SubTabObj
        end

        -- ── Shared element frame builder ──────────────────────────────────────
        local function MakeCard(targetFrame, labelText, height)
            local card = New("Frame", {
                Name             = labelText or "Element",
                Size             = UDim2.new(1, 0, 0, height or 38),
                BackgroundColor3 = T.Card,
                BorderSizePixel  = 0,
                LayoutOrder      = #targetFrame:GetChildren(),
                Parent           = targetFrame,
            })
            Corner(7, card)
            Stroke(T.Border, 1, card)
            if labelText then
                New("TextLabel", {
                    Text             = labelText,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    TextColor3       = T.Text,
                    BackgroundTransparency = 1,
                    Position         = UDim2.new(0, 10, 0, 0),
                    Size             = UDim2.new(0.55, 0, 1, 0),
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = card,
                })
            end
            return card
        end

        local function RegisterElement(id, ctrl)
            if id then elementRegistry[id] = ctrl end
        end

        -- ── Tooltip helper ────────────────────────────────────────────────────
        local function AttachTooltip(frame, text)
            if not text or text == "" then return end
            frame.MouseEnter:Connect(function()
                ShowTooltip(text, Mouse.X, Mouse.Y)
            end)
            frame.MouseLeave:Connect(function()
                HideTooltip()
            end)
        end

        -- ── Section ───────────────────────────────────────────────────────────
        function TabObj.AddSectionToFrame(_, name, targetFrame)
            targetFrame = targetFrame or frame
            local lbl = New("TextLabel", {
                Name             = name or "Section",
                Text             = string.upper(name or "SECTION"),
                Font             = Enum.Font.GothamBold,
                TextSize         = 10,
                TextColor3       = T.TextMuted,
                BackgroundTransparency = 1,
                Size             = UDim2.new(1, 0, 0, 18),
                TextXAlignment   = Enum.TextXAlignment.Left,
                LayoutOrder      = #targetFrame:GetChildren(),
                Parent           = targetFrame,
            })
            New("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = T.Border,
                BorderSizePixel  = 0,
                LayoutOrder      = #targetFrame:GetChildren(),
                Parent           = targetFrame,
            })
        end

        function TabObj:AddSection(name) return TabObj.AddSectionToFrame(self, name, frame) end

        -- ── Button ────────────────────────────────────────────────────────────
        function TabObj.AddButtonToFrame(_, opts, targetFrame, elList)
            opts = opts or {}
            local card = MakeCard(targetFrame, opts.Name, 38)
            table.insert(elList or allElements, card)

            local btn = New("TextButton", {
                Text             = opts.ButtonText or "Run",
                Font             = Enum.Font.GothamBold,
                TextSize         = 11,
                TextColor3       = T.Text,
                BackgroundColor3 = T.Accent,
                Size             = UDim2.new(0, 76, 0, 22),
                Position         = UDim2.new(1, -84, 0.5, -11),
                BorderSizePixel  = 0,
                Parent           = card,
            })
            Corner(5, btn)

            btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = T.AccentHover }, FAST) end)
            btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = T.Accent }, FAST) end)
            btn.MouseButton1Click:Connect(function()
                Tween(btn, { BackgroundColor3 = T.AccentDim }, FAST)
                task.delay(0.15, function() Tween(btn, { BackgroundColor3 = T.Accent }, FAST) end)
                if opts.Callback then opts.Callback() end
            end)

            AttachTooltip(card, opts.Tooltip)
        end

        function TabObj:AddButton(o) return TabObj.AddButtonToFrame(self, o, frame, allElements) end

        -- ── Toggle ────────────────────────────────────────────────────────────
        function TabObj.AddToggleToFrame(_, opts, targetFrame, elList)
            opts = opts or {}
            local state = opts.Default or false
            local card  = MakeCard(targetFrame, opts.Name, 38)
            table.insert(elList or allElements, card)

            local track = New("Frame", {
                Size             = UDim2.new(0, 42, 0, 22),
                Position         = UDim2.new(1, -52, 0.5, -11),
                BackgroundColor3 = state and T.ToggleOn or T.ToggleOff,
                BorderSizePixel  = 0,
                Parent           = card,
            })
            Corner(99, track)

            local knob = New("Frame", {
                Size             = UDim2.new(0, 16, 0, 16),
                Position         = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = T.White,
                BorderSizePixel  = 0,
                ZIndex           = 2,
                Parent           = track,
            })
            Corner(99, knob)

            local hitbox = New("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 3,
                Parent           = track,
            })

            hitbox.MouseButton1Click:Connect(function()
                state = not state
                Tween(track, { BackgroundColor3 = state and T.ToggleOn or T.ToggleOff }, FAST)
                Tween(knob,  { Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8) }, FAST)
                if opts.Callback then opts.Callback(state) end
            end)

            AttachTooltip(card, opts.Tooltip)

            local ctrl = {
                Get = function() return state end,
                Set = function(_, v)
                    state = v
                    Tween(track, { BackgroundColor3 = state and T.ToggleOn or T.ToggleOff }, FAST)
                    Tween(knob,  { Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8) }, FAST)
                    if opts.Callback then opts.Callback(state) end
                end,
            }
            RegisterElement(opts.Id, ctrl)
            return ctrl
        end

        function TabObj:AddToggle(o) return TabObj.AddToggleToFrame(self, o, frame, allElements) end

        -- ── Slider ────────────────────────────────────────────────────────────
        function TabObj.AddSliderToFrame(_, opts, targetFrame, elList)
            opts = opts or {}
            local mn  = opts.Min     or 0
            local mx  = opts.Max     or 100
            local val = math.clamp(opts.Default or mn, mn, mx)
            local step = opts.Step or 1
            local card = MakeCard(targetFrame, nil, 52)
            table.insert(elList or allElements, card)
            card.Name = opts.Name or "Slider"

            New("TextLabel", {
                Text             = opts.Name or "",
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextColor3       = T.Text,
                BackgroundTransparency = 1,
                Position         = UDim2.new(0, 10, 0, 7),
                Size             = UDim2.new(0.65, 0, 0, 16),
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = card,
            })

            local valLbl = New("TextLabel", {
                Text             = tostring(val),
                Font             = Enum.Font.GothamBold,
                TextSize         = 11,
                TextColor3       = T.Accent,
                BackgroundTransparency = 1,
                Position         = UDim2.new(1, -50, 0, 7),
                Size             = UDim2.new(0, 44, 0, 16),
                TextXAlignment   = Enum.TextXAlignment.Right,
                Parent           = card,
            })

            local track = New("Frame", {
                Size             = UDim2.new(1, -20, 0, 4),
                Position         = UDim2.new(0, 10, 0, 32),
                BackgroundColor3 = T.Border,
                BorderSizePixel  = 0,
                Parent           = card,
            })
            Corner(99, track)

            local fill = New("Frame", {
                Size             = UDim2.new((val - mn) / (mx - mn), 0, 1, 0),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                Parent           = track,
            })
            Corner(99, fill)

            local knob = New("Frame", {
                Size             = UDim2.new(0, 13, 0, 13),
                Position         = UDim2.new((val - mn) / (mx - mn), -6, 0.5, -6),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                ZIndex           = 2,
                Parent           = track,
            })
            Corner(99, knob)
            New("UIStroke", { Color = T.AccentGlow, Thickness = 2, Parent = knob })

            local sliding = false
            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)
            UIS.InputChanged:Connect(function(i)
                if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    val = mn + math.floor((rel * (mx - mn)) / step + 0.5) * step
                    local r2 = (val - mn) / (mx - mn)
                    valLbl.Text = tostring(val)
                    fill.Size = UDim2.new(r2, 0, 1, 0)
                    knob.Position = UDim2.new(r2, -6, 0.5, -6)
                    if opts.Callback then opts.Callback(val) end
                end
            end)

            AttachTooltip(card, opts.Tooltip)

            local ctrl = {
                Get = function() return val end,
                Set = function(_, v)
                    val = math.clamp(v, mn, mx)
                    local r2 = (val - mn) / (mx - mn)
                    valLbl.Text = tostring(val)
                    fill.Size = UDim2.new(r2, 0, 1, 0)
                    knob.Position = UDim2.new(r2, -6, 0.5, -6)
                    if opts.Callback then opts.Callback(val) end
                end,
            }
            RegisterElement(opts.Id, ctrl)
            return ctrl
        end

        function TabObj:AddSlider(o) return TabObj.AddSliderToFrame(self, o, frame, allElements) end

        -- ── Dropdown ──────────────────────────────────────────────────────────
        function TabObj.AddDropdownToFrame(_, opts, targetFrame, elList)
            opts = opts or {}
            local items    = opts.Items   or {}
            local selected = opts.Default or (items[1] or "")
            local isOpen   = false
            local card     = MakeCard(targetFrame, opts.Name, 38)
            table.insert(elList or allElements, card)
            card.Name = opts.Name or "Dropdown"

            local dbtn = New("TextButton", {
                Text             = selected .. "  ▾",
                Font             = Enum.Font.Gotham,
                TextSize         = 11,
                TextColor3       = T.Text,
                BackgroundColor3 = T.Elevated,
                Size             = UDim2.new(0, 140, 0, 24),
                Position         = UDim2.new(1, -148, 0.5, -12),
                BorderSizePixel  = 0,
                ClipsDescendants = false,
                Parent           = card,
            })
            Corner(5, dbtn)
            Stroke(T.Border, 1, dbtn)

            local menuH = math.min(#items, 5) * 28 + 6
            local menu = New("Frame", {
                Size             = UDim2.new(0, 140, 0, menuH),
                Position         = UDim2.new(1, -148, 1, 4),
                BackgroundColor3 = T.Surface,
                BorderSizePixel  = 0,
                ZIndex           = 20,
                ClipsDescendants = true,
                Visible          = false,
                Parent           = card,
            })
            Corner(6, menu)
            Stroke(T.BorderLight, 1, menu)
            Pad(3, 3, 3, 3, menu)
            New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,1), Parent = menu })

            for _, item in ipairs(items) do
                local ib = New("TextButton", {
                    Text             = item,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 11,
                    TextColor3       = item == selected and T.Accent or T.Text,
                    BackgroundColor3 = T.Surface,
                    BackgroundTransparency = 1,
                    Size             = UDim2.new(1, 0, 0, 27),
                    BorderSizePixel  = 0,
                    ZIndex           = 21,
                    Parent           = menu,
                })
                Corner(4, ib)
                ib.MouseEnter:Connect(function() Tween(ib, { BackgroundTransparency = 0, BackgroundColor3 = T.Elevated }, FAST) end)
                ib.MouseLeave:Connect(function()
                    Tween(ib, { BackgroundTransparency = 1 }, FAST)
                    ib.TextColor3 = item == selected and T.Accent or T.Text
                end)
                ib.MouseButton1Click:Connect(function()
                    selected = item
                    dbtn.Text = item .. "  ▾"
                    menu.Visible = false; isOpen = false
                    if opts.Callback then opts.Callback(selected) end
                end)
            end

            dbtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                menu.Visible = isOpen
            end)
            AttachTooltip(card, opts.Tooltip)

            local ctrl = {
                Get = function() return selected end,
                Set = function(_, v)
                    selected = v; dbtn.Text = v .. "  ▾"
                    if opts.Callback then opts.Callback(v) end
                end,
            }
            RegisterElement(opts.Id, ctrl)
            return ctrl
        end

        function TabObj:AddDropdown(o) return TabObj.AddDropdownToFrame(self, o, frame, allElements) end

        -- ── Multi-Select Dropdown ─────────────────────────────────────────────
        function TabObj.AddMultiDropdownToFrame(_, opts, targetFrame, elList)
            opts = opts or {}
            local items   = opts.Items   or {}
            local selected = {}
            if opts.Default then for _, v in ipairs(opts.Default) do selected[v] = true end end
            local isOpen  = false
            local card    = MakeCard(targetFrame, opts.Name, 38)
            table.insert(elList or allElements, card)
            card.Name = opts.Name or "MultiDropdown"

            local function GetSelectedText()
                local t = {}
                for k, v in pairs(selected) do if v then table.insert(t, k) end end
                if #t == 0 then return "None  ▾"
                elseif #t == 1 then return t[1] .. "  ▾"
                else return #t .. " selected  ▾" end
            end

            local dbtn = New("TextButton", {
                Text             = GetSelectedText(),
                Font             = Enum.Font.Gotham,
                TextSize         = 11,
                TextColor3       = T.Text,
                BackgroundColor3 = T.Elevated,
                Size             = UDim2.new(0, 140, 0, 24),
                Position         = UDim2.new(1, -148, 0.5, -12),
                BorderSizePixel  = 0,
                Parent           = card,
            })
            Corner(5, dbtn)
            Stroke(T.Border, 1, dbtn)

            local menuH = math.min(#items, 5) * 30 + 6
            local menu  = New("Frame", {
                Size             = UDim2.new(0, 140, 0, menuH),
                Position         = UDim2.new(1, -148, 1, 4),
                BackgroundColor3 = T.Surface,
                BorderSizePixel  = 0,
                ZIndex           = 20,
                ClipsDescendants = true,
                Visible          = false,
                Parent           = card,
            })
            Corner(6, menu)
            Stroke(T.BorderLight, 1, menu)
            Pad(3, 3, 3, 3, menu)
            New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,1), Parent = menu })

            for _, item in ipairs(items) do
                local row = New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 29),
                    BackgroundTransparency = 1,
                    BorderSizePixel  = 0,
                    ZIndex           = 21,
                    Parent           = menu,
                })

                local check = New("Frame", {
                    Size             = UDim2.new(0, 14, 0, 14),
                    Position         = UDim2.new(0, 6, 0.5, -7),
                    BackgroundColor3 = selected[item] and T.Accent or T.Elevated,
                    BorderSizePixel  = 0,
                    ZIndex           = 22,
                    Parent           = row,
                })
                Corner(4, check)
                Stroke(T.Border, 1, check)

                New("TextLabel", {
                    Text             = item,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 11,
                    TextColor3       = selected[item] and T.Text or T.TextSub,
                    BackgroundTransparency = 1,
                    Position         = UDim2.new(0, 26, 0, 0),
                    Size             = UDim2.new(1, -28, 1, 0),
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 22,
                    Parent           = row,
                })

                local hit = New("TextButton", {
                    Size             = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = "",
                    ZIndex           = 23,
                    Parent           = row,
                })
                hit.MouseEnter:Connect(function() Tween(row, { BackgroundTransparency = 0, BackgroundColor3 = T.Elevated }, FAST) end)
                hit.MouseLeave:Connect(function() Tween(row, { BackgroundTransparency = 1 }, FAST) end)
                hit.MouseButton1Click:Connect(function()
                    selected[item] = not selected[item]
                    Tween(check, { BackgroundColor3 = selected[item] and T.Accent or T.Elevated }, FAST)
                    row:FindFirstChildWhichIsA("TextLabel").TextColor3 = selected[item] and T.Text or T.TextSub
                    dbtn.Text = GetSelectedText()
                    if opts.Callback then
                        local arr = {}
                        for k, v in pairs(selected) do if v then table.insert(arr, k) end end
                        opts.Callback(arr)
                    end
                end)
            end

            dbtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen; menu.Visible = isOpen
            end)
            AttachTooltip(card, opts.Tooltip)

            local ctrl = {
                Get = function()
                    local arr = {}
                    for k, v in pairs(selected) do if v then table.insert(arr, k) end end
                    return arr
                end,
                Set = function(_, arr)
                    selected = {}
                    for _, v in ipairs(arr) do selected[v] = true end
                    dbtn.Text = GetSelectedText()
                    if opts.Callback then opts.Callback(arr) end
                end,
            }
            RegisterElement(opts.Id, ctrl)
            return ctrl
        end

        function TabObj:AddMultiDropdown(o) return TabObj.AddMultiDropdownToFrame(self, o, frame, allElements) end

        -- ── TextInput ─────────────────────────────────────────────────────────
        function TabObj.AddTextInputToFrame(_, opts, targetFrame, elList)
            opts = opts or {}
            local card = MakeCard(targetFrame, opts.Name, 38)
            table.insert(elList or allElements, card)
            card.Name = opts.Name or "TextInput"

            local box = New("TextBox", {
                Text             = opts.Default or "",
                PlaceholderText  = opts.Placeholder or "Enter text...",
                PlaceholderColor3 = T.TextMuted,
                Font             = Enum.Font.Gotham,
                TextSize         = 11,
                TextColor3       = T.Text,
                BackgroundColor3 = T.Elevated,
                Size             = UDim2.new(0, 150, 0, 24),
                Position         = UDim2.new(1, -158, 0.5, -12),
                BorderSizePixel  = 0,
                ClearTextOnFocus = false,
                Parent           = card,
            })
            Corner(5, box)
            Stroke(T.Border, 1, box)
            Pad(7, 7, 0, 0, box)

            box.Focused:Connect(function()   Tween(box, { BackgroundColor3 = T.Surface }, FAST) end)
            box.FocusLost:Connect(function(enter)
                Tween(box, { BackgroundColor3 = T.Elevated }, FAST)
                if opts.Callback then opts.Callback(box.Text, enter) end
            end)

            AttachTooltip(card, opts.Tooltip)

            local ctrl = {
                Get = function() return box.Text end,
                Set = function(_, v) box.Text = v end,
            }
            RegisterElement(opts.Id, ctrl)
            return ctrl
        end

        function TabObj:AddTextInput(o) return TabObj.AddTextInputToFrame(self, o, frame, allElements) end

        -- ── Keybind ───────────────────────────────────────────────────────────
        function TabObj.AddKeybindToFrame(_, opts, targetFrame, elList)
            opts = opts or {}
            local current  = opts.Default or Enum.KeyCode.Unknown
            local listening = false
            local card     = MakeCard(targetFrame, opts.Name, 38)
            table.insert(elList or allElements, card)
            card.Name = opts.Name or "Keybind"

            local kbtn = New("TextButton", {
                Text             = current.Name,
                Font             = Enum.Font.GothamBold,
                TextSize         = 11,
                TextColor3       = T.Accent,
                BackgroundColor3 = T.Elevated,
                Size             = UDim2.new(0, 90, 0, 24),
                Position         = UDim2.new(1, -98, 0.5, -12),
                BorderSizePixel  = 0,
                Parent           = card,
            })
            Corner(5, kbtn)
            Stroke(T.Border, 1, kbtn)

            kbtn.MouseButton1Click:Connect(function()
                listening = true
                kbtn.Text = "..."
                kbtn.TextColor3 = T.Warning
            end)

            UIS.InputBegan:Connect(function(i, gp)
                if gp then return end
                if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                    current = i.KeyCode
                    kbtn.Text = current.Name
                    kbtn.TextColor3 = T.Accent
                    listening = false
                    if opts.Callback then opts.Callback(current) end
                elseif not listening and i.KeyCode == current and opts.OnPress then
                    opts.OnPress()
                end
            end)

            AttachTooltip(card, opts.Tooltip)

            local ctrl = {
                Get = function() return current end,
                Set = function(_, v)
                    current = v
                    kbtn.Text = v.Name
                    if opts.Callback then opts.Callback(v) end
                end,
            }
            RegisterElement(opts.Id, ctrl)
            return ctrl
        end

        function TabObj:AddKeybind(o) return TabObj.AddKeybindToFrame(self, o, frame, allElements) end

        -- ── Color Picker ──────────────────────────────────────────────────────
        function TabObj.AddColorPickerToFrame(_, opts, targetFrame, elList)
            opts = opts or {}
            local color = opts.Default or Color3.fromRGB(255, 255, 255)
            local h, s, v = color:ToHSV()
            local isOpen = false
            local card   = MakeCard(targetFrame, opts.Name, 38)
            table.insert(elList or allElements, card)
            card.Name = opts.Name or "ColorPicker"

            local preview = New("Frame", {
                Size             = UDim2.new(0, 24, 0, 24),
                Position         = UDim2.new(1, -32, 0.5, -12),
                BackgroundColor3 = color,
                BorderSizePixel  = 0,
                Parent           = card,
            })
            Corner(5, preview)
            Stroke(T.Border, 1, preview)

            local hit = New("TextButton", {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Parent=preview
            })

            -- Picker panel
            local panel = New("Frame", {
                Size             = UDim2.new(0, 210, 0, 178),
                Position         = UDim2.new(1, -220, 1, 5),
                BackgroundColor3 = T.Surface,
                BorderSizePixel  = 0,
                ZIndex           = 20,
                Visible          = false,
                Parent           = card,
            })
            Corner(8, panel)
            Stroke(T.BorderLight, 1, panel)
            Pad(10, 10, 10, 10, panel)

            -- SV canvas
            local canvas = New("ImageLabel", {
                Size             = UDim2.new(1, 0, 0, 110),
                Image            = "rbxassetid://4155801252",
                BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                BorderSizePixel  = 0,
                ZIndex           = 21,
                Parent           = panel,
            })
            Corner(5, canvas)

            local svKnob = New("Frame", {
                Size             = UDim2.new(0, 11, 0, 11),
                Position         = UDim2.new(s, -5, 1-v, -5),
                BackgroundColor3 = T.White,
                BorderSizePixel  = 0,
                ZIndex           = 22,
                Parent           = canvas,
            })
            Corner(99, svKnob)
            New("UIStroke", { Color = T.Black, Thickness = 1.5, Parent = svKnob })

            -- Hue bar
            local hueBar = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 14),
                Position         = UDim2.new(0, 0, 0, 118),
                BackgroundColor3 = T.White,
                BorderSizePixel  = 0,
                ZIndex           = 21,
                Parent           = panel,
            })
            Corner(5, hueBar)
            New("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,   1, 1)),
                    ColorSequenceKeypoint.new(1/6,  Color3.fromHSV(1/6, 1, 1)),
                    ColorSequenceKeypoint.new(2/6,  Color3.fromHSV(2/6, 1, 1)),
                    ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5, 1, 1)),
                    ColorSequenceKeypoint.new(4/6,  Color3.fromHSV(4/6, 1, 1)),
                    ColorSequenceKeypoint.new(5/6,  Color3.fromHSV(5/6, 1, 1)),
                    ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,   1, 1)),
                }),
                Parent = hueBar,
            })

            local hKnob = New("Frame", {
                Size             = UDim2.new(0, 8, 1, 2),
                Position         = UDim2.new(h, -4, 0, -1),
                BackgroundColor3 = T.White,
                BorderSizePixel  = 0,
                ZIndex           = 22,
                Parent           = hueBar,
            })
            Corner(3, hKnob)
            New("UIStroke", { Color = T.Black, Thickness = 1, Parent = hKnob })

            -- Hex input
            local hex = New("TextBox", {
                Text             = string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)),
                Font             = Enum.Font.Code,
                TextSize         = 11,
                TextColor3       = T.Text,
                BackgroundColor3 = T.Elevated,
                Size             = UDim2.new(1, 0, 0, 22),
                Position         = UDim2.new(0, 0, 0, 140),
                BorderSizePixel  = 0,
                ZIndex           = 21,
                ClearTextOnFocus = false,
                Parent           = panel,
            })
            Corner(5, hex)

            local function UpdateColor()
                color = Color3.fromHSV(h, s, v)
                preview.BackgroundColor3 = color
                canvas.BackgroundColor3  = Color3.fromHSV(h, 1, 1)
                hex.Text = string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
                if opts.Callback then opts.Callback(color) end
            end

            local svDrag, hDrag = false, false
            canvas.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = true end end)
            hueBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hDrag = true end end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = false; hDrag = false end
            end)
            UIS.InputChanged:Connect(function(i)
                if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                if svDrag then
                    s = math.clamp((Mouse.X - canvas.AbsolutePosition.X) / canvas.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((Mouse.Y - canvas.AbsolutePosition.Y) / canvas.AbsoluteSize.Y, 0, 1)
                    svKnob.Position = UDim2.new(s, -5, 1-v, -5)
                    UpdateColor()
                elseif hDrag then
                    h = math.clamp((Mouse.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    hKnob.Position = UDim2.new(h, -4, 0, -1)
                    UpdateColor()
                end
            end)

            hex.FocusLost:Connect(function()
                local str = hex.Text:gsub("#", "")
                if #str == 6 then
                    local r = tonumber(str:sub(1,2), 16)
                    local g = tonumber(str:sub(3,4), 16)
                    local b = tonumber(str:sub(5,6), 16)
                    if r and g and b then
                        color = Color3.fromRGB(r, g, b)
                        h, s, v = color:ToHSV()
                        svKnob.Position = UDim2.new(s, -5, 1-v, -5)
                        hKnob.Position  = UDim2.new(h, -4, 0, -1)
                        UpdateColor()
                    end
                end
            end)

            hit.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                panel.Visible = isOpen
            end)

            AttachTooltip(card, opts.Tooltip)

            local ctrl = {
                Get = function() return color end,
                Set = function(_, c)
                    color = c; h, s, v = c:ToHSV()
                    svKnob.Position = UDim2.new(s, -5, 1-v, -5)
                    hKnob.Position  = UDim2.new(h, -4, 0, -1)
                    UpdateColor()
                end,
            }
            RegisterElement(opts.Id, ctrl)
            return ctrl
        end

        function TabObj:AddColorPicker(o) return TabObj.AddColorPickerToFrame(self, o, frame, allElements) end

        -- ── Config Panel ──────────────────────────────────────────────────────
        function TabObj.AddConfigPanelToFrame(_, targetFrame, elList)
            targetFrame = targetFrame or frame
            elList      = elList or allElements

            TabObj.AddSectionToFrame(nil, "Config Profiles", targetFrame)

            -- Profile name input
            local nameCard = MakeCard(targetFrame, "Profile Name", 38)
            table.insert(elList, nameCard)
            local nameBox = New("TextBox", {
                Text             = currentProfile,
                PlaceholderText  = "Default",
                PlaceholderColor3 = T.TextMuted,
                Font             = Enum.Font.Gotham,
                TextSize         = 11,
                TextColor3       = T.Text,
                BackgroundColor3 = T.Elevated,
                Size             = UDim2.new(0, 150, 0, 24),
                Position         = UDim2.new(1, -158, 0.5, -12),
                BorderSizePixel  = 0,
                ClearTextOnFocus = false,
                Parent           = nameCard,
            })
            Corner(5, nameBox)
            Stroke(T.Border, 1, nameBox)
            Pad(7, 7, 0, 0, nameBox)
            nameBox.FocusLost:Connect(function() currentProfile = nameBox.Text end)

            -- Save button
            local saveCard = MakeCard(targetFrame, "Save Config", 38)
            table.insert(elList, saveCard)
            local saveBtn = New("TextButton", {
                Text             = "Save",
                Font             = Enum.Font.GothamBold,
                TextSize         = 11,
                TextColor3       = T.Text,
                BackgroundColor3 = T.Success,
                Size             = UDim2.new(0, 76, 0, 22),
                Position         = UDim2.new(1, -84, 0.5, -11),
                BorderSizePixel  = 0,
                Parent           = saveCard,
            })
            Corner(5, saveBtn)
            saveBtn.MouseButton1Click:Connect(function()
                SaveProfile(currentProfile)
                NexusLib.Notify(NexusLib, { Title = "Saved", Message = "Profile '" .. currentProfile .. "' saved.", Type = "Success" })
            end)

            -- Load button
            local loadCard = MakeCard(targetFrame, "Load Config", 38)
            table.insert(elList, loadCard)
            local loadBtn = New("TextButton", {
                Text             = "Load",
                Font             = Enum.Font.GothamBold,
                TextSize         = 11,
                TextColor3       = T.Text,
                BackgroundColor3 = T.Accent,
                Size             = UDim2.new(0, 76, 0, 22),
                Position         = UDim2.new(1, -84, 0.5, -11),
                BorderSizePixel  = 0,
                Parent           = loadCard,
            })
            Corner(5, loadBtn)
            loadBtn.MouseButton1Click:Connect(function()
                LoadProfile(currentProfile)
            end)
        end

        function TabObj:AddConfigPanel() return TabObj.AddConfigPanelToFrame(self, frame, allElements) end

        return TabObj
    end -- AddTab

    return WindowObj
end -- CreateWindow

return NexusLib
