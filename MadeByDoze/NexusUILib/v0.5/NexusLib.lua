--[[
╔══════════════════════════════════════════════════════════════╗
║                  NexusLib  v0.5                              ║
║  Themes · Sub-Tabs · Config Profiles · Resize Handle         ║
║  Context Menus · Scroll-to-Top · Image Elements              ║
║  Paragraph/Label · Polished Animations · Clean Code          ║
╚══════════════════════════════════════════════════════════════╝

    local Nexus = loadstring(game:HttpGet("RAW_URL"))()
    local Win   = Nexus:CreateWindow({ Title = "My Script", Theme = "Dark" })
    local Tab   = Win:AddTab({ Name = "Combat", Icon = "⚔" })
    Tab:AddToggle({ Name = "Aimbot", Callback = function(v) end })
]]

local NexusLib = {}
NexusLib.__index = NexusLib

-- ─── Services ────────────────────────────────────────────────────────────────
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local CoreGui      = game:GetService("CoreGui")
local HttpService  = game:GetService("HttpService")

local LP    = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ─── Theme Definitions ───────────────────────────────────────────────────────
local Themes = {
    Dark = {
        Bg          = Color3.fromRGB(12, 12, 16),
        Surface     = Color3.fromRGB(18, 18, 24),
        Elevated    = Color3.fromRGB(26, 26, 34),
        Card        = Color3.fromRGB(22, 22, 29),
        Border      = Color3.fromRGB(40, 40, 55),
        BorderLight = Color3.fromRGB(58, 58, 78),
        Accent      = Color3.fromRGB(99, 157, 255),
        AccentHover = Color3.fromRGB(128, 178, 255),
        AccentDim   = Color3.fromRGB(55, 95, 195),
        Text        = Color3.fromRGB(218, 218, 230),
        TextSub     = Color3.fromRGB(155, 155, 175),
        TextMuted   = Color3.fromRGB(95, 95, 120),
        Success     = Color3.fromRGB(68, 196, 110),
        Warning     = Color3.fromRGB(255, 182, 65),
        Danger      = Color3.fromRGB(255, 78, 78),
        ToggleOn    = Color3.fromRGB(99, 157, 255),
        ToggleOff   = Color3.fromRGB(42, 42, 58),
        ScrollBar   = Color3.fromRGB(55, 55, 75),
    },
    Light = {
        Bg          = Color3.fromRGB(242, 242, 248),
        Surface     = Color3.fromRGB(255, 255, 255),
        Elevated    = Color3.fromRGB(235, 235, 245),
        Card        = Color3.fromRGB(248, 248, 255),
        Border      = Color3.fromRGB(210, 210, 228),
        BorderLight = Color3.fromRGB(190, 190, 215),
        Accent      = Color3.fromRGB(79, 130, 230),
        AccentHover = Color3.fromRGB(55, 105, 210),
        AccentDim   = Color3.fromRGB(40, 80, 180),
        Text        = Color3.fromRGB(28, 28, 38),
        TextSub     = Color3.fromRGB(80, 80, 105),
        TextMuted   = Color3.fromRGB(140, 140, 165),
        Success     = Color3.fromRGB(38, 165, 80),
        Warning     = Color3.fromRGB(210, 145, 20),
        Danger      = Color3.fromRGB(220, 55, 55),
        ToggleOn    = Color3.fromRGB(79, 130, 230),
        ToggleOff   = Color3.fromRGB(195, 195, 215),
        ScrollBar   = Color3.fromRGB(180, 180, 205),
    },
    Midnight = {
        Bg          = Color3.fromRGB(8, 8, 18),
        Surface     = Color3.fromRGB(12, 12, 26),
        Elevated    = Color3.fromRGB(18, 18, 36),
        Card        = Color3.fromRGB(15, 15, 30),
        Border      = Color3.fromRGB(35, 35, 70),
        BorderLight = Color3.fromRGB(55, 55, 100),
        Accent      = Color3.fromRGB(150, 100, 255),
        AccentHover = Color3.fromRGB(175, 130, 255),
        AccentDim   = Color3.fromRGB(100, 60, 200),
        Text        = Color3.fromRGB(215, 210, 235),
        TextSub     = Color3.fromRGB(150, 145, 175),
        TextMuted   = Color3.fromRGB(88, 85, 118),
        Success     = Color3.fromRGB(68, 196, 130),
        Warning     = Color3.fromRGB(255, 190, 80),
        Danger      = Color3.fromRGB(255, 85, 100),
        ToggleOn    = Color3.fromRGB(150, 100, 255),
        ToggleOff   = Color3.fromRGB(38, 35, 62),
        ScrollBar   = Color3.fromRGB(55, 50, 90),
    },
    Rose = {
        Bg          = Color3.fromRGB(15, 10, 14),
        Surface     = Color3.fromRGB(22, 15, 20),
        Elevated    = Color3.fromRGB(30, 20, 28),
        Card        = Color3.fromRGB(26, 17, 24),
        Border      = Color3.fromRGB(58, 38, 52),
        BorderLight = Color3.fromRGB(82, 55, 72),
        Accent      = Color3.fromRGB(240, 100, 148),
        AccentHover = Color3.fromRGB(255, 130, 172),
        AccentDim   = Color3.fromRGB(185, 65, 108),
        Text        = Color3.fromRGB(235, 218, 228),
        TextSub     = Color3.fromRGB(168, 148, 160),
        TextMuted   = Color3.fromRGB(105, 85, 98),
        Success     = Color3.fromRGB(72, 196, 118),
        Warning     = Color3.fromRGB(255, 185, 68),
        Danger      = Color3.fromRGB(255, 80, 80),
        ToggleOn    = Color3.fromRGB(240, 100, 148),
        ToggleOff   = Color3.fromRGB(55, 32, 46),
        ScrollBar   = Color3.fromRGB(75, 48, 65),
    },
}
Themes.Dark.White  = Color3.new(1,1,1)
Themes.Dark.Black  = Color3.new(0,0,0)
for n, th in pairs(Themes) do th.White = Color3.new(1,1,1); th.Black = Color3.new(0,0,0) end

local T = Themes.Dark  -- active theme (replaced on window creation)

-- ─── Easing ──────────────────────────────────────────────────────────────────
local SPRING = TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local FAST   = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local MED    = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local LINEAR = TweenInfo.new(1,    Enum.EasingStyle.Linear)

-- ─── Core Utilities ──────────────────────────────────────────────────────────
local function Tw(obj, props, info)
    TweenService:Create(obj, info or FAST, props):Play()
end

local function New(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then pcall(function() o[k] = v end) end
    end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function Corner(r, p) return New("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = p }) end
local function Stroke(col, th, p)
    return New("UIStroke", { Color = col or T.Border, Thickness = th or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p })
end
local function Pad(l, r, t, b, p)
    return New("UIPadding", {
        PaddingLeft = UDim.new(0,l or 0), PaddingRight  = UDim.new(0,r or 0),
        PaddingTop  = UDim.new(0,t or 0), PaddingBottom = UDim.new(0,b or 0), Parent = p })
end
local function List(p, dir, gap)
    return New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = dir or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, gap or 5), Parent = p })
end

-- Hover tint helper
local function HoverBtn(btn, normal, hover)
    btn.MouseEnter:Connect(function() Tw(btn, { BackgroundColor3 = hover }, FAST) end)
    btn.MouseLeave:Connect(function() Tw(btn, { BackgroundColor3 = normal }, FAST) end)
end

-- Draggable
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

-- Safe file I/O
local function SafeWrite(p, d) return pcall(writefile, p, d) end
local function SafeRead(p)
    if not pcall(isfile, p) then return nil end
    local ok, d = pcall(readfile, p); return ok and d or nil
end

-- ─── Root ScreenGui ──────────────────────────────────────────────────────────
local function GetRoot()
    pcall(function()
        local e = CoreGui:FindFirstChild("NexusLibV3"); if e then e:Destroy() end
    end)
    return New("ScreenGui", {
        Name = "NexusLibV3", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999, Parent = CoreGui,
    })
end

-- ─── Tooltip ─────────────────────────────────────────────────────────────────
local function MakeTooltip(root)
    local tip = New("Frame", {
        Size = UDim2.new(0, 10, 0, 26), BackgroundColor3 = T.Elevated,
        BorderSizePixel = 0, ZIndex = 200, Visible = false, Parent = root,
    })
    Corner(5, tip); Stroke(T.BorderLight, 1, tip); Pad(10, 10, 0, 0, tip)
    local lbl = New("TextLabel", {
        Text = "", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.TextSub,
        BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), ZIndex = 201, Parent = tip,
    })
    local shown = false
    local function Show(text, x, y)
        lbl.Text = text
        tip.Size = UDim2.new(0, math.max(#text * 7 + 20, 60), 0, 26)
        tip.Position = UDim2.new(0, x + 14, 0, y - 34)
        if not shown then
            tip.Visible = true; tip.BackgroundTransparency = 1; lbl.TextTransparency = 1
            Tw(tip, { BackgroundTransparency = 0 }, FAST); Tw(lbl, { TextTransparency = 0 }, FAST)
            shown = true
        end
    end
    local function Hide()
        if not shown then return end
        shown = false
        Tw(tip, { BackgroundTransparency = 1 }, FAST); Tw(lbl, { TextTransparency = 1 }, FAST)
        task.delay(0.2, function() if not shown then tip.Visible = false end end)
    end
    return Show, Hide
end

-- ─── Context Menu ────────────────────────────────────────────────────────────
local function MakeContextMenu(root)
    local menu = New("Frame", {
        Size = UDim2.new(0, 160, 0, 10), BackgroundColor3 = T.Surface,
        BorderSizePixel = 0, ZIndex = 150, Visible = false, Parent = root,
    })
    Corner(7, menu); Stroke(T.BorderLight, 1, menu); Pad(4, 4, 4, 4, menu)
    local layout = List(menu, nil, 1)

    local function Show(items, x, y)
        -- Destroy old children except layout
        for _, c in ipairs(menu:GetChildren()) do
            if c ~= layout then c:Destroy() end
        end
        local h = #items * 28 + 8
        menu.Size = UDim2.new(0, 160, 0, h)
        menu.Position = UDim2.new(0, x, 0, y)
        for _, item in ipairs(items) do
            if item == "---" then
                local div = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Border,
                    BorderSizePixel = 0, LayoutOrder = #menu:GetChildren(), Parent = menu,
                })
            else
                local btn = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = T.Surface,
                    BackgroundTransparency = 1, Text = item.Label or item[1],
                    Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T.Text,
                    BorderSizePixel = 0, ZIndex = 151,
                    LayoutOrder = #menu:GetChildren(), Parent = menu,
                })
                Corner(4, btn); Pad(8, 8, 0, 0, btn)
                btn.TextXAlignment = Enum.TextXAlignment.Left
                if item.Color then btn.TextColor3 = item.Color end
                btn.MouseEnter:Connect(function() Tw(btn, { BackgroundTransparency = 0, BackgroundColor3 = T.Elevated }, FAST) end)
                btn.MouseLeave:Connect(function() Tw(btn, { BackgroundTransparency = 1 }, FAST) end)
                btn.MouseButton1Click:Connect(function()
                    menu.Visible = false
                    if item.Callback then item.Callback() end
                    if item[2] then item[2]() end
                end)
            end
        end
        menu.Visible = true
        Tw(menu, { Size = UDim2.new(0, 160, 0, h) }, FAST)
    end

    local function Hide() menu.Visible = false end

    -- Dismiss on click outside
    UIS.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            task.defer(function() if menu.Visible then menu.Visible = false end end)
        end
    end)

    return Show, Hide
end

-- ─── Notifications ───────────────────────────────────────────────────────────
local NotifHolder

local function InitNotifs(root)
    NotifHolder = New("Frame", {
        Size = UDim2.new(0, 295, 1, -20), Position = UDim2.new(1, -305, 0, 10),
        BackgroundTransparency = 1, Parent = root,
    })
    local L = List(NotifHolder); L.VerticalAlignment = Enum.VerticalAlignment.Bottom; L.Padding = UDim.new(0,6)
end

function NexusLib:Notify(opts)
    opts = opts or {}
    local accent = ({ Info = T.Accent, Success = T.Success, Warning = T.Warning, Error = T.Danger })[opts.Type or "Info"] or T.Accent
    local dur = opts.Duration or 4

    local card = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = T.Surface,
        ClipsDescendants = true, BorderSizePixel = 0, Parent = NotifHolder,
    })
    Corner(8, card); Stroke(accent, 1, card)

    -- Left bar
    New("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = accent, BorderSizePixel = 0, ZIndex = 2, Parent = card })

    New("TextLabel", {
        Text = opts.Title or "Notice", Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = T.Text, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8), Size = UDim2.new(1, -18, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
    })
    New("TextLabel", {
        Text = opts.Message or "", Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.TextMuted, BackgroundTransparency = 1, TextWrapped = true,
        Position = UDim2.new(0, 14, 0, 26), Size = UDim2.new(1, -18, 0, 28),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
    })

    -- Dismiss X
    local xbtn = New("TextButton", {
        Text = "✕", Font = Enum.Font.GothamBold, TextSize = 9,
        TextColor3 = T.TextMuted, BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -22, 0, 4),
        BorderSizePixel = 0, ZIndex = 3, Parent = card,
    })
    xbtn.MouseButton1Click:Connect(function()
        Tw(card, { Size = UDim2.new(1,0,0,0) }, SPRING)
        task.delay(0.4, function() pcall(function() card:Destroy() end) end)
    end)

    -- Progress bar
    local prog = New("Frame", {
        Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0,0,1,-2),
        BackgroundColor3 = accent, BorderSizePixel = 0, Parent = card,
    })

    Tw(card, { Size = UDim2.new(1, 0, 0, 64) }, SPRING)
    task.delay(0.05, function() Tw(prog, { Size = UDim2.new(0,0,0,2) }, TweenInfo.new(dur, Enum.EasingStyle.Linear)) end)
    task.delay(dur, function()
        Tw(card, { Size = UDim2.new(1,0,0,0) }, SPRING)
        task.delay(0.4, function() pcall(function() card:Destroy() end) end)
    end)
end

-- ─── Watermark ───────────────────────────────────────────────────────────────
local function BuildWatermark(root, text)
    local wm = New("Frame", {
        Size = UDim2.new(0, 10, 0, 30), Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = T.Surface, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, Parent = root,
    })
    Corner(7, wm); Stroke(T.Border, 1, wm); Pad(10, 12, 0, 0, wm)

    local pip = New("Frame", {
        Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 0, 0.5, -3),
        BackgroundColor3 = T.Accent, BorderSizePixel = 0, Parent = wm,
    })
    Corner(9, pip)

    local lbl = New("TextLabel", {
        Text = "  " .. text, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = T.Text, BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Parent = wm,
    })

    RunService.Heartbeat:Connect(function()
        lbl.Text = "  " .. text .. "  ·  " .. os.date("%H:%M:%S")
    end)

    return { SetText = function(_, t) text = t end, SetVisible = function(_, v) wm.Visible = v end }
end

-- ─── CreateWindow ─────────────────────────────────────────────────────────────
function NexusLib:CreateWindow(opts)
    opts = opts or {}
    local title      = opts.Title     or "Nexus"
    local subtitle   = opts.Subtitle  or "v3.0"
    local winSize    = opts.Size      or UDim2.new(0, 580, 0, 415)
    local toggleKey  = opts.ToggleKey or Enum.KeyCode.RightShift
    local configDir  = opts.ConfigDir or "NexusLib"
    local themeName  = opts.Theme     or "Dark"
    local minW, minH = 360, 240

    -- Apply theme
    T = Themes[themeName] or Themes.Dark

    local root = GetRoot()
    InitNotifs(root)
    local ShowTip, HideTip     = MakeTooltip(root)
    local ShowCtx, HideCtx     = MakeContextMenu(root)

    -- Config / element registry
    local elementRegistry = {}
    local currentProfile  = "Default"

    local function SaveProfile(name)
        name = name or currentProfile
        local data = {}
        for id, ctrl in pairs(elementRegistry) do
            local ok, v = pcall(ctrl.Get); if ok then data[id] = v end
        end
        local blob = {}
        local raw = SafeRead(configDir .. "/profiles.json")
        if raw then pcall(function() blob = HttpService:JSONDecode(raw) end) end
        blob[name] = data
        pcall(makefolder, configDir)
        SafeWrite(configDir .. "/profiles.json", HttpService:JSONEncode(blob))
        return blob
    end

    local function LoadProfile(name, silent)
        name = name or currentProfile
        local raw = SafeRead(configDir .. "/profiles.json")
        if not raw then return end
        local ok, blob = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok or not blob[name] then return end
        for id, val in pairs(blob[name]) do
            if elementRegistry[id] then pcall(elementRegistry[id].Set, elementRegistry[id], val) end
        end
        currentProfile = name
        if not silent then
            NexusLib.Notify(NexusLib, { Title = "Config", Message = "Loaded '"..name.."'", Type = "Info" })
        end
    end

    local function ListProfiles()
        local raw = SafeRead(configDir .. "/profiles.json")
        if not raw then return {"Default"} end
        local ok, blob = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok then return {"Default"} end
        local names = {}; for k in pairs(blob) do table.insert(names, k) end
        if #names == 0 then names = {"Default"} end
        return names
    end

    -- ── Window frame ─────────────────────────────────────────────────────────
    local win = New("Frame", {
        Name = "NexusWin",
        Size = UDim2.new(0, winSize.X.Offset, 0, 0),
        Position = UDim2.new(0.5, -winSize.X.Offset/2, 0.5, -winSize.Y.Offset/2),
        BackgroundColor3 = T.Bg, BorderSizePixel = 0, ClipsDescendants = true, Parent = root,
    })
    Corner(11, win); Stroke(T.Border, 1, win)

    -- Drop shadow
    New("ImageLabel", {
        Size = UDim2.new(1,70,1,70), Position = UDim2.new(0,-35,0,-35),
        BackgroundTransparency = 1, Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49,49,450,450),
        ZIndex = 0, Parent = win,
    })

    -- Animate open
    task.defer(function() Tw(win, { Size = winSize }, SPRING) end)

    -- ── Titlebar ─────────────────────────────────────────────────────────────
    local tbar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = T.Surface,
        BorderSizePixel = 0, ZIndex = 5, Parent = win,
    })
    Corner(11, tbar)
    New("Frame", { -- flatten bottom corners of tbar
        Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,1,-12),
        BackgroundColor3 = T.Surface, BorderSizePixel = 0, ZIndex = 5, Parent = tbar,
    })
    New("Frame", { -- bottom border line
        Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1),
        BackgroundColor3 = T.Border, BorderSizePixel = 0, ZIndex = 6, Parent = tbar,
    })

    -- Accent pip + title
    local pip = New("Frame", {
        Size = UDim2.new(0,7,0,7), Position = UDim2.new(0,14,0.5,-3),
        BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 6, Parent = tbar,
    }); Corner(9, pip)
    New("TextLabel", {
        Text = title, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.Text,
        BackgroundTransparency = 1, Position = UDim2.new(0,28,0,4),
        Size = UDim2.new(0,200,0,18), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = tbar,
    })
    New("TextLabel", {
        Text = subtitle, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = T.TextMuted,
        BackgroundTransparency = 1, Position = UDim2.new(0,28,0,24),
        Size = UDim2.new(0,200,0,14), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = tbar,
    })

    -- Win buttons
    local function WBtn(xOff, col, icon)
        local b = New("TextButton", {
            Size = UDim2.new(0,20,0,20), Position = UDim2.new(1,xOff,0.5,-10),
            BackgroundColor3 = col, Text = icon, Font = Enum.Font.GothamBold, TextSize = 9,
            TextColor3 = Color3.new(0,0,0), TextTransparency = 0.45,
            BorderSizePixel = 0, ZIndex = 7, Parent = tbar,
        }); Corner(9, b)
        b.MouseEnter:Connect(function() Tw(b, { Size = UDim2.new(0,22,0,22), Position = UDim2.new(1,xOff-1,0.5,-11) }, FAST) end)
        b.MouseLeave:Connect(function() Tw(b, { Size = UDim2.new(0,20,0,20), Position = UDim2.new(1,xOff,0.5,-10) }, FAST) end)
        return b
    end
    local closeBtn = WBtn(-28, T.Danger, "✕")
    local minBtn   = WBtn(-54, T.Warning, "−")

    MakeDraggable(win, tbar)

    local minimized, visible = false, true
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Tw(win, { Size = minimized and UDim2.new(0,winSize.X.Offset,0,46) or winSize }, SPRING)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Tw(win, { Size = UDim2.new(0,winSize.X.Offset,0,0) }, SPRING)
        task.delay(0.4, function() pcall(function() root:Destroy() end) end)
    end)
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == toggleKey then visible = not visible; win.Visible = visible end
    end)

    -- ── Resize handle ─────────────────────────────────────────────────────────
    local resizeHandle = New("TextButton", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1, Text = "", ZIndex = 10,
        Parent = win,
    })
    -- Resize grip dots
    for row = 1, 3 do for col = 1, 3 do
        if row + col >= 4 then
            New("Frame", {
                Size = UDim2.new(0, 2, 0, 2),
                Position = UDim2.new(0, (col-1)*5, 0, (row-1)*5),
                BackgroundColor3 = T.BorderLight, BorderSizePixel = 0, ZIndex = 11, Parent = resizeHandle,
            })
        end
    end end

    local resizing, rStart, rWinStart = false, nil, nil
    resizeHandle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true; rStart = i.Position
            rWinStart = { X = win.AbsoluteSize.X, Y = win.AbsoluteSize.Y }
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - rStart
            local nw = math.max(minW, rWinStart.X + d.X)
            local nh = math.max(minH, rWinStart.Y + d.Y)
            win.Size = UDim2.new(0, nw, 0, nh)
            winSize = UDim2.new(0, nw, 0, nh)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
    end)

    -- ── Sidebar ───────────────────────────────────────────────────────────────
    local sidebar = New("Frame", {
        Size = UDim2.new(0, 140, 1, -46), Position = UDim2.new(0,0,0,46),
        BackgroundColor3 = T.Surface, BorderSizePixel = 0, Parent = win,
    })
    New("Frame", {
        Size = UDim2.new(0,1,1,0), Position = UDim2.new(1,0,0,0),
        BackgroundColor3 = T.Border, BorderSizePixel = 0, Parent = sidebar,
    })

    local tabScroll = New("ScrollingFrame", {
        Size = UDim2.new(1,0,1,-10), Position = UDim2.new(0,0,0,8),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, Parent = sidebar,
    })
    Pad(6, 6, 0, 0, tabScroll); List(tabScroll, nil, 2)

    -- ── Content area ──────────────────────────────────────────────────────────
    local contentArea = New("Frame", {
        Size = UDim2.new(1,-140,1,-46), Position = UDim2.new(0,140,0,46),
        BackgroundTransparency = 1, BorderSizePixel = 0, Parent = win,
    })

    -- ── Tab system ────────────────────────────────────────────────────────────
    local allTabs = {}; local activeTab = nil

    local function ActivateTab(entry)
        if activeTab == entry then return end
        for _, t in ipairs(allTabs) do
            Tw(t.Btn,       { BackgroundTransparency = 1 }, FAST)
            Tw(t.BtnLbl,    { TextColor3 = T.TextMuted }, FAST)
            Tw(t.Indicator, { BackgroundTransparency = 1 }, FAST)
            t.Container.Visible = false
        end
        Tw(entry.Btn,       { BackgroundTransparency = 0, BackgroundColor3 = T.Elevated }, FAST)
        Tw(entry.BtnLbl,    { TextColor3 = T.Text }, FAST)
        Tw(entry.Indicator, { BackgroundTransparency = 0 }, FAST)
        entry.Container.Visible = true
        entry.Container.Position = UDim2.new(0.04, 0, 0, 0)
        Tw(entry.Container, { Position = UDim2.new(0,0,0,0) }, SPRING)
        activeTab = entry
    end

    -- ── WindowObj ─────────────────────────────────────────────────────────────
    local WindowObj = {}

    function WindowObj:AddWatermark(text)
        return BuildWatermark(root, text)
    end

    function WindowObj:SetTheme(name)
        -- runtime theme swap: update T and repaint all applicable instances
        T = Themes[name] or Themes.Dark
        win.BackgroundColor3 = T.Bg
        tbar.BackgroundColor3 = T.Surface
        pip.BackgroundColor3 = T.Accent
        sidebar.BackgroundColor3 = T.Surface
    end

    function WindowObj:SaveConfig(name) SaveProfile(name) end
    function WindowObj:LoadConfig(name) LoadProfile(name) end

    -- ── AddTab ────────────────────────────────────────────────────────────────
    function WindowObj:AddTab(tOpts)
        tOpts = tOpts or {}
        local tabName = tOpts.Name or "Tab"
        local tabIcon = tOpts.Icon or ""

        -- Sidebar button
        local btn = New("TextButton", {
            Size = UDim2.new(1,0,0,34), BackgroundColor3 = T.Elevated,
            BackgroundTransparency = 1, Text = "", BorderSizePixel = 0, Parent = tabScroll,
        }); Corner(6, btn)

        local indicator = New("Frame", {
            Size = UDim2.new(0,3,0.55,0), Position = UDim2.new(0,0,0.225,0),
            BackgroundColor3 = T.Accent, BackgroundTransparency = 1,
            BorderSizePixel = 0, Parent = btn,
        }); Corner(3, indicator)

        local btnLbl = New("TextLabel", {
            Text = (tabIcon ~= "" and tabIcon.."  " or "")..tabName,
            Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T.TextMuted,
            BackgroundTransparency = 1, Position = UDim2.new(0,12,0,0),
            Size = UDim2.new(1,-12,1,0), TextXAlignment = Enum.TextXAlignment.Left, Parent = btn,
        })

        -- Container owns ALL elements for this tab
        local container = New("Frame", {
            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
            BorderSizePixel = 0, Visible = false, Parent = contentArea,
        })

        -- Search bar
        local searchBox = New("TextBox", {
            PlaceholderText = "  🔍  Search elements...", PlaceholderColor3 = T.TextMuted,
            Text = "", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.Text,
            BackgroundColor3 = T.Elevated, Size = UDim2.new(1,-16,0,28),
            Position = UDim2.new(0,8,0,7), BorderSizePixel = 0, ClearTextOnFocus = false, Parent = container,
        })
        Corner(7, searchBox); Stroke(T.Border, 1, searchBox)
        searchBox.Focused:Connect(function()   Tw(searchBox, { BackgroundColor3 = T.Card }, FAST) end)
        searchBox.FocusLost:Connect(function() Tw(searchBox, { BackgroundColor3 = T.Elevated }, FAST) end)

        -- Main scroll frame
        local scrollFrame = New("ScrollingFrame", {
            Size = UDim2.new(1,0,1,-44), Position = UDim2.new(0,0,0,43),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollBarImageColor3 = T.ScrollBar,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = container,
        })
        Pad(10, 10, 6, 10, scrollFrame); List(scrollFrame, nil, 5)

        -- Scroll-to-top button
        local scrollTopBtn = New("TextButton", {
            Size = UDim2.new(0,28,0,28), Position = UDim2.new(1,-36,1,-36),
            BackgroundColor3 = T.Elevated, Text = "↑", Font = Enum.Font.GothamBold,
            TextSize = 13, TextColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 10,
            BackgroundTransparency = 1, Visible = false, Parent = container,
        })
        Corner(8, scrollTopBtn); Stroke(T.Border, 1, scrollTopBtn)
        scrollTopBtn.MouseButton1Click:Connect(function()
            Tw(scrollFrame, { CanvasPosition = Vector2.new(0,0) }, MED)
        end)
        scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            local show = scrollFrame.CanvasPosition.Y > 60
            if show ~= scrollTopBtn.Visible then
                scrollTopBtn.Visible = show
                Tw(scrollTopBtn, { BackgroundTransparency = show and 0 or 1 }, FAST)
            end
        end)

        local entry = { Btn = btn, BtnLbl = btnLbl, Indicator = indicator, Container = container, ScrollFrame = scrollFrame }
        table.insert(allTabs, entry)
        btn.MouseButton1Click:Connect(function() ActivateTab(entry) end)
        if #allTabs == 1 then ActivateTab(entry) end

        -- Search filter
        local allElements = {}
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = searchBox.Text:lower()
            for _, el in ipairs(allElements) do
                el.Visible = (q == "" or el.Name:lower():find(q, 1, true) ~= nil)
            end
        end)

        -- ── Sub-tabs ──────────────────────────────────────────────────────────
        local subBar, subContents, activeSub = nil, {}, nil
        local hasSubTabs = false

        local function InitSubTabs()
            if hasSubTabs then return end; hasSubTabs = true
            searchBox.Position = UDim2.new(0,8,0,41)
            scrollFrame.Visible = false; scrollFrame.Size = UDim2.new(1,0,0,0)

            subBar = New("Frame", {
                Size = UDim2.new(1,-16,0,26), Position = UDim2.new(0,8,0,73),
                BackgroundColor3 = T.Elevated, BorderSizePixel = 0, Parent = container,
            })
            Corner(7, subBar); List(subBar, Enum.FillDirection.Horizontal, 2); Pad(2,2,2,2,subBar)
        end

        -- ── Shared helpers ────────────────────────────────────────────────────
        local function MakeCard(tf, label, h)
            local c = New("Frame", {
                Name = label or "Element", Size = UDim2.new(1,0,0, h or 38),
                BackgroundColor3 = T.Card, BorderSizePixel = 0,
                LayoutOrder = #tf:GetChildren(), Parent = tf,
            })
            Corner(7, c); Stroke(T.Border, 1, c)
            if label then
                New("TextLabel", {
                    Text = label, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T.Text,
                    BackgroundTransparency = 1, Position = UDim2.new(0,10,0,0),
                    Size = UDim2.new(0.55,0,1,0), TextXAlignment = Enum.TextXAlignment.Left, Parent = c,
                })
            end
            return c
        end

        local function RegEl(id, ctrl)
            if id then elementRegistry[id] = ctrl end
        end

        local function AttachTip(frame, text)
            if not text or text == "" then return end
            frame.MouseEnter:Connect(function() ShowTip(text, Mouse.X, Mouse.Y) end)
            frame.MouseLeave:Connect(HideTip)
        end

        local function AttachCtx(frame, items)
            if not items or #items == 0 then return end
            frame.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton2 then
                    ShowCtx(items, Mouse.X, Mouse.Y)
                end
            end)
        end

        -- ═══════════════════════════════════════════════════════════════
        --  ELEMENT BUILDERS (all accept targetFrame + elementList args
        --  so sub-tabs can reuse the same functions)
        -- ═══════════════════════════════════════════════════════════════

        local TabObj = {}

        -- ── Section ───────────────────────────────────────────────────────
        function TabObj.AddSectionToFrame(_, name, tf)
            tf = tf or scrollFrame
            New("TextLabel", {
                Name = name or "Section", Text = string.upper(name or "SECTION"),
                Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = T.TextMuted,
                BackgroundTransparency = 1, Size = UDim2.new(1,0,0,18),
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = #tf:GetChildren(), Parent = tf,
            })
            New("Frame", {
                Size = UDim2.new(1,0,0,1), BackgroundColor3 = T.Border,
                BorderSizePixel = 0, LayoutOrder = #tf:GetChildren(), Parent = tf,
            })
        end
        function TabObj:AddSection(n) return TabObj.AddSectionToFrame(self, n, scrollFrame) end

        -- ── Label / Paragraph ─────────────────────────────────────────────
        function TabObj.AddLabelToFrame(_, opts, tf, elList)
            opts = opts or {}; tf = tf or scrollFrame; elList = elList or allElements
            local text = opts.Text or ""
            local isMultiLine = #text > 60 or text:find("\n")
            local h = isMultiLine and math.max(38, math.ceil(#text / 55) * 18 + 16) or 38

            local card = New("Frame", {
                Name = opts.Name or "Label", Size = UDim2.new(1,0,0,h),
                BackgroundColor3 = T.Card, BorderSizePixel = 0,
                LayoutOrder = #tf:GetChildren(), Parent = tf,
            })
            Corner(7, card); Stroke(T.Border, 1, card)
            table.insert(elList, card)

            New("TextLabel", {
                Text = text, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T.TextSub,
                BackgroundTransparency = 1, TextWrapped = true,
                Position = UDim2.new(0,10,0,0), Size = UDim2.new(1,-20,1,0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = isMultiLine and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
                Parent = card,
            })

            AttachTip(card, opts.Tooltip)
            local lbl = card:FindFirstChildWhichIsA("TextLabel")
            return {
                Set = function(_, v) lbl.Text = v end,
                Get = function() return lbl.Text end,
            }
        end
        function TabObj:AddLabel(o) return TabObj.AddLabelToFrame(self, o, scrollFrame, allElements) end

        -- ── Image ─────────────────────────────────────────────────────────
        function TabObj.AddImageToFrame(_, opts, tf, elList)
            opts = opts or {}; tf = tf or scrollFrame; elList = elList or allElements
            local imgH = opts.Height or 100
            local card = New("Frame", {
                Name = opts.Name or "Image", Size = UDim2.new(1,0,0,imgH),
                BackgroundColor3 = T.Card, BorderSizePixel = 0, ClipsDescendants = true,
                LayoutOrder = #tf:GetChildren(), Parent = tf,
            })
            Corner(7, card); Stroke(T.Border, 1, card)
            table.insert(elList, card)

            local img = New("ImageLabel", {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                Image = opts.Image or "", ScaleType = opts.ScaleType or Enum.ScaleType.Fit,
                Parent = card,
            })
            if opts.Caption then
                New("Frame", {
                    Size = UDim2.new(1,0,0,24), Position = UDim2.new(0,0,1,-24),
                    BackgroundColor3 = T.Bg, BackgroundTransparency = 0.3,
                    BorderSizePixel = 0, ZIndex = 2, Parent = card,
                })
                New("TextLabel", {
                    Text = opts.Caption, Font = Enum.Font.Gotham, TextSize = 11,
                    TextColor3 = T.Text, BackgroundTransparency = 1,
                    Size = UDim2.new(1,0,0,24), Position = UDim2.new(0,0,1,-24),
                    ZIndex = 3, Parent = card,
                })
            end
            AttachTip(card, opts.Tooltip)
            return {
                Set = function(_, id) img.Image = id end,
                Get = function() return img.Image end,
            }
        end
        function TabObj:AddImage(o) return TabObj.AddImageToFrame(self, o, scrollFrame, allElements) end

        -- ── Button ────────────────────────────────────────────────────────
        function TabObj.AddButtonToFrame(_, opts, tf, elList)
            opts = opts or {}; tf = tf or scrollFrame; elList = elList or allElements
            local card = MakeCard(tf, opts.Name, 38)
            table.insert(elList, card)

            local btn = New("TextButton", {
                Text = opts.ButtonText or "Run", Font = Enum.Font.GothamBold, TextSize = 11,
                TextColor3 = T.White, BackgroundColor3 = opts.Color or T.Accent,
                Size = UDim2.new(0,78,0,24), Position = UDim2.new(1,-86,0.5,-12),
                BorderSizePixel = 0, Parent = card,
            }); Corner(6, btn)

            local norm = opts.Color or T.Accent
            HoverBtn(btn, norm, T.AccentHover)
            btn.MouseButton1Click:Connect(function()
                Tw(btn, { BackgroundColor3 = T.AccentDim }, FAST)
                task.delay(0.12, function() Tw(btn, { BackgroundColor3 = norm }, FAST) end)
                if opts.Callback then opts.Callback() end
            end)
            AttachTip(card, opts.Tooltip)
            AttachCtx(card, opts.Context)
        end
        function TabObj:AddButton(o) return TabObj.AddButtonToFrame(self, o, scrollFrame, allElements) end

        -- ── Toggle ────────────────────────────────────────────────────────
        function TabObj.AddToggleToFrame(_, opts, tf, elList)
            opts = opts or {}; tf = tf or scrollFrame; elList = elList or allElements
            local state = opts.Default or false
            local card  = MakeCard(tf, opts.Name, 38)
            table.insert(elList, card)

            local track = New("Frame", {
                Size = UDim2.new(0,44,0,22), Position = UDim2.new(1,-52,0.5,-11),
                BackgroundColor3 = state and T.ToggleOn or T.ToggleOff,
                BorderSizePixel = 0, Parent = card,
            }); Corner(99, track)

            local knob = New("Frame", {
                Size = UDim2.new(0,16,0,16),
                Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
                BackgroundColor3 = T.White, BorderSizePixel = 0, ZIndex = 2, Parent = track,
            }); Corner(99, knob)

            New("TextButton", {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", ZIndex = 3, Parent = track,
            }).MouseButton1Click:Connect(function()
                state = not state
                Tw(track, { BackgroundColor3 = state and T.ToggleOn or T.ToggleOff }, MED)
                Tw(knob,  { Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8) }, MED)
                if opts.Callback then opts.Callback(state) end
            end)

            AttachTip(card, opts.Tooltip)
            AttachCtx(card, opts.Context)

            local ctrl = {
                Get = function() return state end,
                Set = function(_, v)
                    state = v
                    Tw(track, { BackgroundColor3 = state and T.ToggleOn or T.ToggleOff }, MED)
                    Tw(knob,  { Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8) }, MED)
                    if opts.Callback then opts.Callback(state) end
                end,
            }
            RegEl(opts.Id, ctrl); return ctrl
        end
        function TabObj:AddToggle(o) return TabObj.AddToggleToFrame(self, o, scrollFrame, allElements) end

        -- ── Slider ────────────────────────────────────────────────────────
        function TabObj.AddSliderToFrame(_, opts, tf, elList)
            opts = opts or {}; tf = tf or scrollFrame; elList = elList or allElements
            local mn, mx = opts.Min or 0, opts.Max or 100
            local step = opts.Step or 1
            local val  = math.clamp(opts.Default or mn, mn, mx)
            local card = MakeCard(tf, nil, 54)
            card.Name  = opts.Name or "Slider"
            table.insert(elList, card)

            New("TextLabel", {
                Text = opts.Name or "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T.Text,
                BackgroundTransparency = 1, Position = UDim2.new(0,10,0,7),
                Size = UDim2.new(0.65,0,0,16), TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
            })
            local valLbl = New("TextLabel", {
                Text = tostring(val), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T.Accent,
                BackgroundTransparency = 1, Position = UDim2.new(1,-52,0,7),
                Size = UDim2.new(0,46,0,16), TextXAlignment = Enum.TextXAlignment.Right, Parent = card,
            })

            local track = New("Frame", {
                Size = UDim2.new(1,-20,0,4), Position = UDim2.new(0,10,0,33),
                BackgroundColor3 = T.Border, BorderSizePixel = 0, Parent = card,
            }); Corner(99, track)

            local fill = New("Frame", {
                Size = UDim2.new((val-mn)/(mx-mn),0,1,0),
                BackgroundColor3 = T.Accent, BorderSizePixel = 0, Parent = track,
            }); Corner(99, fill)

            local knob = New("Frame", {
                Size = UDim2.new(0,13,0,13),
                Position = UDim2.new((val-mn)/(mx-mn),-6,0.5,-6),
                BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 2, Parent = track,
            }); Corner(99, knob); New("UIStroke", { Color = T.AccentDim, Thickness = 2, Parent = knob })

            local sliding = false
            track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
            UIS.InputChanged:Connect(function(i)
                if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    val = mn + math.floor((rel*(mx-mn))/step + 0.5)*step
                    local r2 = (val-mn)/(mx-mn)
                    valLbl.Text = tostring(val)
                    fill.Size = UDim2.new(r2,0,1,0); knob.Position = UDim2.new(r2,-6,0.5,-6)
                    if opts.Callback then opts.Callback(val) end
                end
            end)

            AttachTip(card, opts.Tooltip); AttachCtx(card, opts.Context)
            local ctrl = {
                Get = function() return val end,
                Set = function(_, v)
                    val = math.clamp(v, mn, mx); local r2 = (val-mn)/(mx-mn)
                    valLbl.Text = tostring(val)
                    fill.Size = UDim2.new(r2,0,1,0); knob.Position = UDim2.new(r2,-6,0.5,-6)
                    if opts.Callback then opts.Callback(val) end
                end,
            }
            RegEl(opts.Id, ctrl); return ctrl
        end
        function TabObj:AddSlider(o) return TabObj.AddSliderToFrame(self, o, scrollFrame, allElements) end

        -- ── Dropdown ──────────────────────────────────────────────────────
        function TabObj.AddDropdownToFrame(_, opts, tf, elList)
            opts = opts or {}; tf = tf or scrollFrame; elList = elList or allElements
            local items = opts.Items or {}; local sel = opts.Default or (items[1] or "")
            local isOpen = false
            local card = MakeCard(tf, opts.Name, 38); table.insert(elList, card); card.Name = opts.Name or "Dropdown"

            local dbtn = New("TextButton", {
                Text = sel.."  ▾", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.Text,
                BackgroundColor3 = T.Elevated, Size = UDim2.new(0,142,0,24),
                Position = UDim2.new(1,-150,0.5,-12), BorderSizePixel = 0, Parent = card,
            }); Corner(6, dbtn); Stroke(T.Border, 1, dbtn)

            local menuH = math.min(#items,5)*28+6
            -- Parent to root ScreenGui — fully escapes win/container/scroll clipping
            local menu = New("Frame", {
                Size = UDim2.new(0,142,0,menuH),
                BackgroundColor3 = T.Surface, BorderSizePixel = 0,
                ZIndex = 60, Visible = false, Parent = root,
            }); Corner(7, menu); Stroke(T.BorderLight, 1, menu); Pad(3,3,3,3,menu); List(menu, nil, 1)

            for _, item in ipairs(items) do
                local ib = New("TextButton", {
                    Text = item, Font = Enum.Font.Gotham, TextSize = 11,
                    TextColor3 = item == sel and T.Accent or T.Text,
                    BackgroundColor3 = T.Surface, BackgroundTransparency = 1,
                    Size = UDim2.new(1,0,0,27), BorderSizePixel = 0, ZIndex = 61, Parent = menu,
                }); Corner(4, ib)
                ib.MouseEnter:Connect(function() Tw(ib, { BackgroundTransparency = 0, BackgroundColor3 = T.Elevated }, FAST) end)
                ib.MouseLeave:Connect(function() Tw(ib, { BackgroundTransparency = 1 }, FAST) end)
                ib.MouseButton1Click:Connect(function()
                    sel = item; dbtn.Text = item.."  ▾"; menu.Visible = false; isOpen = false
                    if opts.Callback then opts.Callback(sel) end
                end)
            end

            local function OpenMenu()
                -- Position relative to root ScreenGui — fully escapes all clipping
                local abs = dbtn.AbsolutePosition
                menu.Position = UDim2.new(0, abs.X, 0, abs.Y + dbtn.AbsoluteSize.Y + 2)
                menu.Visible = true
            end

            dbtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then OpenMenu() else menu.Visible = false end
            end)
            -- Close on outside click
            UIS.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
                    task.defer(function()
                        if isOpen and not menu:IsDescendantOf(game) then return end
                        -- check if click was outside menu
                        local mp = UIS:GetMouseLocation()
                        local mabs = menu.AbsolutePosition
                        local msize = menu.AbsoluteSize
                        if mp.X < mabs.X or mp.X > mabs.X+msize.X or mp.Y < mabs.Y or mp.Y > mabs.Y+msize.Y then
                            menu.Visible = false; isOpen = false
                        end
                    end)
                end
            end)

            AttachTip(card, opts.Tooltip); AttachCtx(card, opts.Context)
            local ctrl = {
                Get = function() return sel end,
                Set = function(_, v) sel = v; dbtn.Text = v.."  ▾"; if opts.Callback then opts.Callback(v) end end,
            }
            RegEl(opts.Id, ctrl); return ctrl
        end
        function TabObj:AddDropdown(o) return TabObj.AddDropdownToFrame(self, o, scrollFrame, allElements) end

        -- ── Multi-select Dropdown ─────────────────────────────────────────
        function TabObj.AddMultiDropdownToFrame(_, opts, tf, elList)
            opts = opts or {}; tf = tf or scrollFrame; elList = elList or allElements
            local items = opts.Items or {}; local sel = {}
            if opts.Default then for _, v in ipairs(opts.Default) do sel[v] = true end end
            local isOpen = false

            local function SelText()
                local t = {}; for k,v in pairs(sel) do if v then table.insert(t,k) end end
                if #t == 0 then return "None  ▾" elseif #t == 1 then return t[1].."  ▾" else return #t.." selected  ▾" end
            end

            local card = MakeCard(tf, opts.Name, 38); table.insert(elList, card); card.Name = opts.Name or "MultiDrop"
            local dbtn = New("TextButton", {
                Text = SelText(), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.Text,
                BackgroundColor3 = T.Elevated, Size = UDim2.new(0,142,0,24),
                Position = UDim2.new(1,-150,0.5,-12), BorderSizePixel = 0, Parent = card,
            }); Corner(6, dbtn); Stroke(T.Border, 1, dbtn)

            local menuH = math.min(#items,5)*30+6
            local menu = New("Frame", {
                Size = UDim2.new(0,142,0,menuH),
                BackgroundColor3 = T.Surface, BorderSizePixel = 0,
                ZIndex = 60, Visible = false, Parent = root,
            }); Corner(7, menu); Stroke(T.BorderLight, 1, menu); Pad(3,3,3,3,menu); List(menu, nil, 1)

            for _, item in ipairs(items) do
                local row = New("Frame", {
                    Size = UDim2.new(1,0,0,29), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 31, Parent = menu,
                })
                local chk = New("Frame", {
                    Size = UDim2.new(0,14,0,14), Position = UDim2.new(0,6,0.5,-7),
                    BackgroundColor3 = sel[item] and T.Accent or T.Elevated,
                    BorderSizePixel = 0, ZIndex = 32, Parent = row,
                }); Corner(4, chk); Stroke(T.Border, 1, chk)
                New("TextLabel", {
                    Text = item, Font = Enum.Font.Gotham, TextSize = 11,
                    TextColor3 = sel[item] and T.Text or T.TextSub,
                    BackgroundTransparency = 1, Position = UDim2.new(0,26,0,0),
                    Size = UDim2.new(1,-28,1,0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32, Parent = row,
                })
                local hit = New("TextButton", {
                    Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", ZIndex = 33, Parent = row,
                })
                hit.MouseEnter:Connect(function() Tw(row, { BackgroundTransparency = 0, BackgroundColor3 = T.Elevated }, FAST) end)
                hit.MouseLeave:Connect(function() Tw(row, { BackgroundTransparency = 1 }, FAST) end)
                hit.MouseButton1Click:Connect(function()
                    sel[item] = not sel[item]
                    Tw(chk, { BackgroundColor3 = sel[item] and T.Accent or T.Elevated }, FAST)
                    row:FindFirstChildWhichIsA("TextLabel").TextColor3 = sel[item] and T.Text or T.TextSub
                    dbtn.Text = SelText()
                    if opts.Callback then
                        local arr={}; for k,v in pairs(sel) do if v then table.insert(arr,k) end end
                        opts.Callback(arr)
                    end
                end)
            end

            dbtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    local abs = dbtn.AbsolutePosition
                    menu.Position = UDim2.new(0, abs.X, 0, abs.Y + dbtn.AbsoluteSize.Y + 2)
                    menu.Visible = true
                else
                    menu.Visible = false
                end
            end)
            UIS.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
                    task.defer(function()
                        local mp = UIS:GetMouseLocation()
                        local mabs = menu.AbsolutePosition; local msize = menu.AbsoluteSize
                        if mp.X < mabs.X or mp.X > mabs.X+msize.X or mp.Y < mabs.Y or mp.Y > mabs.Y+msize.Y then
                            menu.Visible = false; isOpen = false
                        end
                    end)
                end
            end)
            AttachTip(card, opts.Tooltip); AttachCtx(card, opts.Context)
            local ctrl = {
                Get = function() local arr={}; for k,v in pairs(sel) do if v then table.insert(arr,k) end end; return arr end,
                Set = function(_, arr)
                    sel={}; for _,v in ipairs(arr) do sel[v]=true end; dbtn.Text=SelText()
                    if opts.Callback then opts.Callback(arr) end
                end,
            }
            RegEl(opts.Id, ctrl); return ctrl
        end
        function TabObj:AddMultiDropdown(o) return TabObj.AddMultiDropdownToFrame(self, o, scrollFrame, allElements) end

        -- ── Text Input ────────────────────────────────────────────────────
        function TabObj.AddTextInputToFrame(_, opts, tf, elList)
            opts = opts or {}; tf = tf or scrollFrame; elList = elList or allElements
            local card = MakeCard(tf, opts.Name, 38); table.insert(elList, card); card.Name = opts.Name or "Input"
            local box = New("TextBox", {
                Text = opts.Default or "", PlaceholderText = opts.Placeholder or "Enter text...",
                PlaceholderColor3 = T.TextMuted, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.Text,
                BackgroundColor3 = T.Elevated, Size = UDim2.new(0,152,0,24),
                Position = UDim2.new(1,-160,0.5,-12), BorderSizePixel = 0, ClearTextOnFocus = false, Parent = card,
            }); Corner(6, box); Stroke(T.Border, 1, box); Pad(7,7,0,0,box)
            box.Focused:Connect(function()   Tw(box, { BackgroundColor3 = T.Surface }, FAST) end)
            box.FocusLost:Connect(function(e)
                Tw(box, { BackgroundColor3 = T.Elevated }, FAST)
                if opts.Callback then opts.Callback(box.Text, e) end
            end)
            AttachTip(card, opts.Tooltip); AttachCtx(card, opts.Context)
            local ctrl = { Get = function() return box.Text end, Set = function(_, v) box.Text = v end }
            RegEl(opts.Id, ctrl); return ctrl
        end
        function TabObj:AddTextInput(o) return TabObj.AddTextInputToFrame(self, o, scrollFrame, allElements) end

        -- ── Keybind ───────────────────────────────────────────────────────
        function TabObj.AddKeybindToFrame(_, opts, tf, elList)
            opts = opts or {}; tf = tf or scrollFrame; elList = elList or allElements
            local cur = opts.Default or Enum.KeyCode.Unknown; local listening = false
            local card = MakeCard(tf, opts.Name, 38); table.insert(elList, card); card.Name = opts.Name or "Keybind"
            local kbtn = New("TextButton", {
                Text = cur.Name, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T.Accent,
                BackgroundColor3 = T.Elevated, Size = UDim2.new(0,92,0,24),
                Position = UDim2.new(1,-100,0.5,-12), BorderSizePixel = 0, Parent = card,
            }); Corner(6, kbtn); Stroke(T.Border, 1, kbtn)
            kbtn.MouseButton1Click:Connect(function()
                listening = true; kbtn.Text = "..."; kbtn.TextColor3 = T.Warning
            end)
            UIS.InputBegan:Connect(function(i, gp)
                if gp then return end
                if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                    cur = i.KeyCode; kbtn.Text = cur.Name; kbtn.TextColor3 = T.Accent; listening = false
                    if opts.Callback then opts.Callback(cur) end
                elseif not listening and i.KeyCode == cur and opts.OnPress then opts.OnPress() end
            end)
            AttachTip(card, opts.Tooltip); AttachCtx(card, opts.Context)
            local ctrl = {
                Get = function() return cur end,
                Set = function(_, v) cur = v; kbtn.Text = v.Name; if opts.Callback then opts.Callback(v) end end,
            }
            RegEl(opts.Id, ctrl); return ctrl
        end
        function TabObj:AddKeybind(o) return TabObj.AddKeybindToFrame(self, o, scrollFrame, allElements) end

        -- ── Color Picker ──────────────────────────────────────────────────
        function TabObj.AddColorPickerToFrame(_, opts, tf, elList)
            opts = opts or {}; tf = tf or scrollFrame; elList = elList or allElements
            local color = opts.Default or Color3.fromRGB(255,255,255)
            local h, s, v = color:ToHSV(); local isOpen = false
            local card = MakeCard(tf, opts.Name, 38); table.insert(elList, card); card.Name = opts.Name or "ColorPicker"

            local preview = New("Frame", {
                Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-32,0.5,-12),
                BackgroundColor3 = color, BorderSizePixel = 0, Parent = card,
            }); Corner(5, preview); Stroke(T.Border, 1, preview)
            local hit = New("TextButton", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = preview })

            -- Panel parented to root ScreenGui so it is never clipped by win/scroll/card
            local panel = New("Frame", {
                Size = UDim2.new(0,215,0,182),
                BackgroundColor3 = T.Surface, BorderSizePixel = 0, ZIndex = 60, Visible = false, Parent = root,
            }); Corner(9, panel); Stroke(T.BorderLight, 1, panel); Pad(10,10,10,10,panel)

            local canvas = New("ImageLabel", {
                Size = UDim2.new(1,0,0,112), Image = "rbxassetid://4155801252",
                BackgroundColor3 = Color3.fromHSV(h,1,1), BorderSizePixel = 0, ZIndex = 26, Parent = panel,
            }); Corner(5, canvas)

            local svKnob = New("Frame", {
                Size = UDim2.new(0,11,0,11), Position = UDim2.new(s,-5,1-v,-5),
                BackgroundColor3 = T.White, BorderSizePixel = 0, ZIndex = 27, Parent = canvas,
            }); Corner(99, svKnob); New("UIStroke", { Color = T.Black, Thickness = 1.5, Parent = svKnob })

            local hueBar = New("Frame", {
                Size = UDim2.new(1,0,0,14), Position = UDim2.new(0,0,0,120),
                BackgroundColor3 = T.White, BorderSizePixel = 0, ZIndex = 26, Parent = panel,
            }); Corner(5, hueBar)
            New("UIGradient", { Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)), ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6,1,1)),
                ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6,1,1)), ColorSequenceKeypoint.new(.5, Color3.fromHSV(.5,1,1)),
                ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6,1,1)), ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6,1,1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1)),
            }), Parent = hueBar })

            local hKnob = New("Frame", {
                Size = UDim2.new(0,8,1,2), Position = UDim2.new(h,-4,0,-1),
                BackgroundColor3 = T.White, BorderSizePixel = 0, ZIndex = 27, Parent = hueBar,
            }); Corner(3, hKnob); New("UIStroke", { Color = T.Black, Thickness = 1, Parent = hKnob })

            local hex = New("TextBox", {
                Text = string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)),
                Font = Enum.Font.Code, TextSize = 11, TextColor3 = T.Text, BackgroundColor3 = T.Elevated,
                Size = UDim2.new(1,0,0,22), Position = UDim2.new(0,0,0,142),
                BorderSizePixel = 0, ZIndex = 26, ClearTextOnFocus = false, Parent = panel,
            }); Corner(5, hex)

            local function Upd()
                color = Color3.fromHSV(h,s,v)
                preview.BackgroundColor3 = color
                canvas.BackgroundColor3 = Color3.fromHSV(h,1,1)
                hex.Text = string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
                -- Keep panel colors in sync with live theme
                panel.BackgroundColor3 = T.Surface
                if opts.Callback then opts.Callback(color) end
            end

            local svD, hD = false, false
            canvas.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then svD = true end end)
            hueBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hD = true end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then svD=false; hD=false end end)
            UIS.InputChanged:Connect(function(i)
                if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                if svD then
                    s = math.clamp((Mouse.X-canvas.AbsolutePosition.X)/canvas.AbsoluteSize.X,0,1)
                    v = 1-math.clamp((Mouse.Y-canvas.AbsolutePosition.Y)/canvas.AbsoluteSize.Y,0,1)
                    svKnob.Position = UDim2.new(s,-5,1-v,-5); Upd()
                elseif hD then
                    h = math.clamp((Mouse.X-hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1)
                    hKnob.Position = UDim2.new(h,-4,0,-1); Upd()
                end
            end)
            hex.FocusLost:Connect(function()
                local str = hex.Text:gsub("#","")
                if #str == 6 then
                    local r,g,b = tonumber(str:sub(1,2),16), tonumber(str:sub(3,4),16), tonumber(str:sub(5,6),16)
                    if r and g and b then
                        color = Color3.fromRGB(r,g,b); h,s,v = color:ToHSV()
                        svKnob.Position = UDim2.new(s,-5,1-v,-5); hKnob.Position = UDim2.new(h,-4,0,-1); Upd()
                    end
                end
            end)
            hit.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    local abs = preview.AbsolutePosition
                    local rx = abs.X - 215 + preview.AbsoluteSize.X
                    local ry = abs.Y + preview.AbsoluteSize.Y + 4
                    if rx < 0 then rx = abs.X end
                    panel.Position = UDim2.new(0, rx, 0, ry)
                    panel.Visible = true
                else
                    panel.Visible = false
                end
            end)
            -- Close on outside click
            UIS.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
                    task.defer(function()
                        local mp = UIS:GetMouseLocation()
                        local pabs = panel.AbsolutePosition; local psize = panel.AbsoluteSize
                        local prevAbs = preview.AbsolutePosition; local prevSize = preview.AbsoluteSize
                        local inPanel   = mp.X >= pabs.X and mp.X <= pabs.X+psize.X and mp.Y >= pabs.Y and mp.Y <= pabs.Y+psize.Y
                        local inPreview = mp.X >= prevAbs.X and mp.X <= prevAbs.X+prevSize.X and mp.Y >= prevAbs.Y and mp.Y <= prevAbs.Y+prevSize.Y
                        if not inPanel and not inPreview then
                            panel.Visible = false; isOpen = false
                        end
                    end)
                end
            end)
            AttachTip(card, opts.Tooltip); AttachCtx(card, opts.Context)
            local ctrl = {
                Get = function() return color end,
                Set = function(_, c)
                    color=c; h,s,v=c:ToHSV(); svKnob.Position=UDim2.new(s,-5,1-v,-5)
                    hKnob.Position=UDim2.new(h,-4,0,-1); Upd()
                end,
            }
            RegEl(opts.Id, ctrl); return ctrl
        end
        function TabObj:AddColorPicker(o) return TabObj.AddColorPickerToFrame(self, o, scrollFrame, allElements) end

        -- ── Config Profiles Panel (tabbed UI) ─────────────────────────────
        function TabObj.AddConfigPanelToFrame(_, tf, elList)
            tf = tf or scrollFrame; elList = elList or allElements
            TabObj.AddSectionToFrame(nil, "Config Profiles", tf)

            -- Tab strip: Manage / Import / Export
            local strip = New("Frame", {
                Size = UDim2.new(1,0,0,28), BackgroundColor3 = T.Elevated,
                BorderSizePixel = 0, LayoutOrder = #tf:GetChildren(), Parent = tf,
            }); Corner(7, strip); List(strip, Enum.FillDirection.Horizontal, 2); Pad(2,2,2,2,strip)

            local pages = {}
            local activePage = nil

            local function ShowPage(name)
                for pname, pg in pairs(pages) do
                    pg.Frame.Visible = (pname == name)
                    Tw(pg.Btn, { BackgroundTransparency = (pname == name) and 0 or 1, BackgroundColor3 = T.Surface, TextColor3 = (pname == name) and T.Text or T.TextMuted }, FAST)
                end
                activePage = name
            end

            local function MakePage(name)
                local btn = New("TextButton", {
                    Size = UDim2.new(0,1,1,0), AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = T.Surface, BackgroundTransparency = 1,
                    Text = name, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.TextMuted,
                    BorderSizePixel = 0, Parent = strip,
                }); Corner(5, btn); Pad(10,10,0,0,btn)
                local frame = New("Frame", {
                    Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
                    LayoutOrder = #tf:GetChildren(), Parent = tf,
                }); List(frame, nil, 4)
                pages[name] = { Btn = btn, Frame = frame }
                btn.MouseButton1Click:Connect(function() ShowPage(name) end)
                return frame
            end

            -- ── Page: Manage ──────────────────────────────────────────────
            local managePage = MakePage("Manage")

            -- Profile name input
            local nameCard = MakeCard(managePage, "Profile Name", 38)
            local nameBox = New("TextBox", {
                Text = currentProfile, PlaceholderText = "Default",
                PlaceholderColor3 = T.TextMuted, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.Text,
                BackgroundColor3 = T.Elevated, Size = UDim2.new(0,152,0,24),
                Position = UDim2.new(1,-160,0.5,-12), BorderSizePixel = 0, ClearTextOnFocus = false, Parent = nameCard,
            }); Corner(6, nameBox); Stroke(T.Border, 1, nameBox); Pad(7,7,0,0,nameBox)
            nameBox.FocusLost:Connect(function() currentProfile = nameBox.Text end)

            -- Save
            local saveCard = MakeCard(managePage, "Save Profile", 38)
            local saveBtn = New("TextButton", {
                Text = "Save", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T.White,
                BackgroundColor3 = T.Success, Size = UDim2.new(0,78,0,24),
                Position = UDim2.new(1,-86,0.5,-12), BorderSizePixel = 0, Parent = saveCard,
            }); Corner(6, saveBtn); HoverBtn(saveBtn, T.Success, Color3.fromRGB(90,220,130))
            saveBtn.MouseButton1Click:Connect(function()
                SaveProfile(currentProfile)
                NexusLib.Notify(NexusLib, { Title = "Saved", Message = "Profile '"..currentProfile.."' saved.", Type = "Success" })
            end)

            -- Load (dropdown of existing profiles)
            local loadCard = MakeCard(managePage, "Load Profile", 38)
            local loadDropper = nil
            local function RefreshProfiles()
                local profiles = ListProfiles()
                if loadDropper then
                    loadDropper.Set(loadDropper, profiles[1])
                end
            end

            local profiles = ListProfiles()
            local selProfile = profiles[1]
            local lpdbtn = New("TextButton", {
                Text = selProfile.."  ▾", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.Text,
                BackgroundColor3 = T.Elevated, Size = UDim2.new(0,100,0,24),
                Position = UDim2.new(1,-160,0.5,-12), BorderSizePixel = 0, Parent = loadCard,
            }); Corner(6, lpdbtn); Stroke(T.Border, 1, lpdbtn)
            local loadBtn2 = New("TextButton", {
                Text = "Load", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T.White,
                BackgroundColor3 = T.Accent, Size = UDim2.new(0,52,0,24),
                Position = UDim2.new(1,-54,0.5,-12), BorderSizePixel = 0, Parent = loadCard,
            }); Corner(6, loadBtn2); HoverBtn(loadBtn2, T.Accent, T.AccentHover)
            loadBtn2.MouseButton1Click:Connect(function() LoadProfile(selProfile) end)

            -- Profile picker mini-menu
            local lpMenu, lpOpen = nil, false
            lpdbtn.MouseButton1Click:Connect(function()
                lpOpen = not lpOpen
                if lpOpen then
                    if lpMenu then lpMenu:Destroy() end
                    local pList = ListProfiles()
                    local mh = math.min(#pList,5)*26+6
                    lpMenu = New("Frame", {
                        Size = UDim2.new(0,100,0,mh), Position = UDim2.new(1,-160,1,2),
                        BackgroundColor3 = T.Surface, BorderSizePixel = 0, ZIndex = 35, Parent = loadCard,
                    }); Corner(6, lpMenu); Stroke(T.BorderLight, 1, lpMenu); Pad(3,3,3,3,lpMenu); List(lpMenu, nil, 1)
                    for _, pname in ipairs(pList) do
                        local pb = New("TextButton", {
                            Text = pname, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.Text,
                            BackgroundColor3 = T.Surface, BackgroundTransparency = 1,
                            Size = UDim2.new(1,0,0,25), BorderSizePixel = 0, ZIndex = 36, Parent = lpMenu,
                        }); Corner(4, pb)
                        pb.MouseEnter:Connect(function() Tw(pb, { BackgroundTransparency = 0, BackgroundColor3 = T.Elevated }, FAST) end)
                        pb.MouseLeave:Connect(function() Tw(pb, { BackgroundTransparency = 1 }, FAST) end)
                        pb.MouseButton1Click:Connect(function()
                            selProfile = pname; lpdbtn.Text = pname.."  ▾"
                            lpMenu.Visible = false; lpOpen = false
                        end)
                    end
                else
                    if lpMenu then lpMenu.Visible = false end
                end
            end)

            -- Delete
            local delCard = MakeCard(managePage, "Delete Profile", 38)
            local delBtn = New("TextButton", {
                Text = "Delete", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T.White,
                BackgroundColor3 = T.Danger, Size = UDim2.new(0,78,0,24),
                Position = UDim2.new(1,-86,0.5,-12), BorderSizePixel = 0, Parent = delCard,
            }); Corner(6, delBtn); HoverBtn(delBtn, T.Danger, Color3.fromRGB(255,110,110))
            delBtn.MouseButton1Click:Connect(function()
                local raw = SafeRead(configDir.."/profiles.json"); if not raw then return end
                local ok, blob = pcall(HttpService.JSONDecode, HttpService, raw); if not ok then return end
                blob[selProfile] = nil
                SafeWrite(configDir.."/profiles.json", HttpService:JSONEncode(blob))
                NexusLib.Notify(NexusLib, { Title = "Deleted", Message = "Profile '"..selProfile.."' removed.", Type = "Warning" })
            end)

            -- ── Page: Export / Import ─────────────────────────────────────
            local exportPage = MakePage("Export")
            local expCard = MakeCard(exportPage, "Export to Clipboard", 38)
            local expBtn = New("TextButton", {
                Text = "Copy", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T.White,
                BackgroundColor3 = T.Accent, Size = UDim2.new(0,78,0,24),
                Position = UDim2.new(1,-86,0.5,-12), BorderSizePixel = 0, Parent = expCard,
            }); Corner(6, expBtn); HoverBtn(expBtn, T.Accent, T.AccentHover)
            expBtn.MouseButton1Click:Connect(function()
                local blob = SaveProfile(currentProfile)
                local encoded
                pcall(function() encoded = HttpService:JSONEncode(blob[currentProfile] or {}) end)
                if encoded then
                    pcall(setclipboard, encoded)
                    NexusLib.Notify(NexusLib, { Title = "Exported", Message = "Config copied to clipboard.", Type = "Success" })
                end
            end)

            local importPage = MakePage("Import")
            local impCard = MakeCard(importPage, "Paste Config JSON", 60)
            local impBox = New("TextBox", {
                Text = "", PlaceholderText = "Paste JSON here...", PlaceholderColor3 = T.TextMuted,
                Font = Enum.Font.Code, TextSize = 10, TextColor3 = T.Text, BackgroundColor3 = T.Elevated,
                MultiLine = true, TextWrapped = true, ClearTextOnFocus = false,
                Size = UDim2.new(1,-20,0,38), Position = UDim2.new(0,10,0,6),
                BorderSizePixel = 0, ZIndex = 2, Parent = impCard,
            }); Corner(5, impBox); Stroke(T.Border, 1, impBox); Pad(5,5,3,3,impBox)
            local impBtn = New("TextButton", {
                Text = "Import & Apply", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T.White,
                BackgroundColor3 = T.Success, Size = UDim2.new(1,-20,0,24),
                Position = UDim2.new(0,10,0,66), BorderSizePixel = 0, LayoutOrder = #importPage:GetChildren(), Parent = importPage,
            }); Corner(6, impBtn); HoverBtn(impBtn, T.Success, Color3.fromRGB(90,220,130))
            impBtn.MouseButton1Click:Connect(function()
                local ok, data = pcall(HttpService.JSONDecode, HttpService, impBox.Text)
                if not ok or type(data) ~= "table" then
                    NexusLib.Notify(NexusLib, { Title = "Error", Message = "Invalid JSON.", Type = "Error" }); return
                end
                for id, val in pairs(data) do
                    if elementRegistry[id] then pcall(elementRegistry[id].Set, elementRegistry[id], val) end
                end
                NexusLib.Notify(NexusLib, { Title = "Imported", Message = "Config applied.", Type = "Success" })
            end)

            ShowPage("Manage")
        end
        function TabObj:AddConfigPanel() return TabObj.AddConfigPanelToFrame(self, scrollFrame, allElements) end

        -- ── AddSubTab ─────────────────────────────────────────────────────
        function TabObj:AddSubTab(stOpts)
            stOpts = stOpts or {}
            local stName = stOpts.Name or "Sub"
            InitSubTabs()

            local stBtn = New("TextButton", {
                Size = UDim2.new(0,1,1,0), AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = T.Elevated, BackgroundTransparency = 1,
                Text = stName, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.TextMuted,
                BorderSizePixel = 0, Parent = subBar,
            }); Corner(5, stBtn); Pad(10,10,0,0,stBtn)

            local stFrame = New("ScrollingFrame", {
                Size = UDim2.new(1,0,1,-106), Position = UDim2.new(0,0,0,103),
                BackgroundTransparency = 1, BorderSizePixel = 0,
                ScrollBarThickness = 3, ScrollBarImageColor3 = T.ScrollBar,
                AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
                Parent = container, -- ← inside this tab's container
            })
            Pad(10,10,6,10,stFrame); List(stFrame, nil, 5)

            -- Scroll-to-top for sub frame too
            local stTopBtn = New("TextButton", {
                Size = UDim2.new(0,28,0,28), Position = UDim2.new(1,-36,1,-36),
                BackgroundColor3 = T.Elevated, Text = "↑", Font = Enum.Font.GothamBold,
                TextSize = 13, TextColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 10,
                BackgroundTransparency = 1, Visible = false, Parent = container,
            }); Corner(8, stTopBtn); Stroke(T.Border, 1, stTopBtn)
            stTopBtn.MouseButton1Click:Connect(function() Tw(stFrame, { CanvasPosition = Vector2.new(0,0) }, MED) end)
            stFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                local show = stFrame.CanvasPosition.Y > 60
                if show ~= stTopBtn.Visible then
                    stTopBtn.Visible = show
                    Tw(stTopBtn, { BackgroundTransparency = show and 0 or 1 }, FAST)
                end
            end)

            local stEntry = { Btn = stBtn, Frame = stFrame }
            table.insert(subContents, stEntry)

            local function ActivateSub(se)
                for _, s in ipairs(subContents) do
                    s.Frame.Visible = false
                    Tw(s.Btn, { BackgroundTransparency = 1, TextColor3 = T.TextMuted }, FAST)
                end
                se.Frame.Visible = true
                Tw(se.Btn, { BackgroundTransparency = 0, BackgroundColor3 = T.Surface, TextColor3 = T.Text }, FAST)
                activeSub = se
            end

            stBtn.MouseButton1Click:Connect(function() ActivateSub(stEntry) end)
            if #subContents == 1 then task.defer(function() ActivateSub(stEntry) end) end

            -- Build SubTabObj by delegating to TabObj methods with stFrame as target
            local SubTabObj = {}
            local subEls = {}
            function SubTabObj:AddSection(n)   return TabObj.AddSectionToFrame(nil, n, stFrame) end
            function SubTabObj:AddLabel(o)     return TabObj.AddLabelToFrame(nil, o, stFrame, subEls) end
            function SubTabObj:AddImage(o)     return TabObj.AddImageToFrame(nil, o, stFrame, subEls) end
            function SubTabObj:AddButton(o)    return TabObj.AddButtonToFrame(nil, o, stFrame, subEls) end
            function SubTabObj:AddToggle(o)    return TabObj.AddToggleToFrame(nil, o, stFrame, subEls) end
            function SubTabObj:AddSlider(o)    return TabObj.AddSliderToFrame(nil, o, stFrame, subEls) end
            function SubTabObj:AddDropdown(o)  return TabObj.AddDropdownToFrame(nil, o, stFrame, subEls) end
            function SubTabObj:AddMultiDropdown(o) return TabObj.AddMultiDropdownToFrame(nil, o, stFrame, subEls) end
            function SubTabObj:AddTextInput(o) return TabObj.AddTextInputToFrame(nil, o, stFrame, subEls) end
            function SubTabObj:AddKeybind(o)   return TabObj.AddKeybindToFrame(nil, o, stFrame, subEls) end
            function SubTabObj:AddColorPicker(o) return TabObj.AddColorPickerToFrame(nil, o, stFrame, subEls) end
            function SubTabObj:AddConfigPanel() return TabObj.AddConfigPanelToFrame(nil, stFrame, subEls) end
            return SubTabObj
        end

        return TabObj
    end -- AddTab

    return WindowObj
end -- CreateWindow

return NexusLib
