--[[
    ████████╗██╗    ██╗██╗███╗   ██╗██╗  ██╗    ██╗   ██╗██╗
       ██╔══╝██║    ██║██║████╗  ██║██║ ██╔╝    ██║   ██║██║
       ██║   ██║ █╗ ██║██║██╔██╗ ██║█████╔╝     ██║   ██║██║
       ██║   ██║███╗██║██║██║╚██╗██║██╔═██╗     ██║   ██║██║
       ██║   ╚███╔███╔╝██║██║ ╚████║██║  ██╗    ╚██████╔╝██║
       ╚═╝    ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝    ╚═════╝ ╚═╝

    TwinkLib  v0.0.4
    ──────────────────────────────────────────────────────────────
    NEW in v0.0.4  (QoL + Components):

    Quality of Life
      • Config save / load     UI.SaveConfig(name) / UI.LoadConfig(name)
      • Live accent colour     UI.SetAccentColor(Color3)
      • Watermark overlay      UI.SetWatermark(true/false)  — FPS + ping bar
      • Fixed notifications    Proper slide-in, max-cap 5, no gaps on dismiss
      • Open / close anim      Scale + fade tween on first load
      • Hover scrollbar        Thin bar appears when hovering sidebar/content

    New Components
      • AddMultiToggle         Grouped checkbox list
      • AddProgressBar         Read-only progress/health bar  returns :Set(0-100)
      • AddStepper             < Option > arrow cycler

    ──────────────────────────────────────────────────────────────
    Usage:

        local UI = UILibrary.Load("Twink UI", "Adopt Me", "v5.0", {
            Letter = "T",
        })

        UI.SetAccentColor(Color3.fromRGB(0, 180, 255))
        UI.SetWatermark(true)

        local Page = UI.AddPage("Home")
        Page.AddSection("Bars")
        local Bar = Page.AddProgressBar("Health", 100)
        Bar.Set(65)

        Page.AddStepper("Aim Part", {"Head","Torso","HumanoidRootPart"}, function(opt,idx)
            print(opt, idx)
        end)

        Page.AddMultiToggle("Options", {
            { Text = "Silent Aim",  Default = false },
            { Text = "No Recoil",   Default = true  },
            { Text = "Infinite Ammo", Default = false },
        }, function(states) print(states) end)

        UI.SaveConfig("profile1")
        UI.LoadConfig("profile1")
--]]

-- ================================================================
--  SERVICES & GLOBALS
-- ================================================================
local Player           = game.Players.LocalPlayer
local Mouse            = Player:GetMouse()
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGuiService   = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")
local TextService      = game:GetService("TextService")
local PlayersService   = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local StatsService     = game:GetService("Stats")

local TweenTime = 0.1
local Level     = 1

local GlobalTweenInfo = TweenInfo.new(TweenTime)
local SlowTweenInfo   = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local OpenTweenInfo   = TweenInfo.new(0.35, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)

local DropShadowID           = "rbxassetid://297774371"
local DropShadowTransparency = 0.3
local IconLibraryID          = "rbxassetid://3926305904"
local IconLibraryID2         = "rbxassetid://3926307971"
local MainFont               = Enum.Font.Gotham

-- Global accent (mutable via SetAccentColor)
local AccentColor  = Color3.fromRGB(100, 80, 200)
local SuccessColor = Color3.fromRGB(0,   210, 100)
local ErrorColor   = Color3.fromRGB(255,  70,  70)
local InfoColor    = Color3.fromRGB(80,  160, 255)
local WarnColor    = Color3.fromRGB(255, 190,  50)

-- Registry for config save/load: { id -> { type, getter, setter } }
local ConfigRegistry = {}

-- ================================================================
--  CONSTRUCTOR HELPERS
-- ================================================================
local function GetXY(obj)
    local X = math.clamp(Mouse.X - obj.AbsolutePosition.X, 0, obj.AbsoluteSize.X)
    local Y = math.clamp(Mouse.Y - obj.AbsolutePosition.Y, 0, obj.AbsoluteSize.Y)
    return X, Y, X / obj.AbsoluteSize.X, Y / obj.AbsoluteSize.Y
end

local function TitleIcon(btn)
    local i = Instance.new(btn and "ImageButton" or "ImageLabel")
    i.Name = "TitleIcon"; i.BackgroundTransparency = 1; i.Image = IconLibraryID
    i.ImageRectOffset = Vector2.new(524, 764); i.ImageRectSize = Vector2.new(36, 36)
    i.Size = UDim2.new(0, 14, 0, 14); i.Position = UDim2.new(1, -17, 0.5, -7)
    i.Rotation = 180; i.ZIndex = Level; return i
end

local function TickIcon(btn)
    local i = Instance.new(btn and "ImageButton" or "ImageLabel")
    i.Name = "TickIcon"; i.BackgroundTransparency = 1; i.Image = "rbxassetid://3926305904"
    i.ImageRectOffset = Vector2.new(312, 4); i.ImageRectSize = Vector2.new(24, 24)
    i.Size = UDim2.new(1, -6, 1, -6); i.Position = UDim2.new(0, 3, 0, 3)
    i.ZIndex = Level; return i
end

local function DropdownIcon(btn)
    local i = Instance.new(btn and "ImageButton" or "ImageLabel")
    i.Name = "DropdownIcon"; i.BackgroundTransparency = 1; i.Image = IconLibraryID2
    i.ImageRectOffset = Vector2.new(324, 364); i.ImageRectSize = Vector2.new(36, 36)
    i.Size = UDim2.new(0, 16, 0, 16); i.Position = UDim2.new(1, -18, 0, 2)
    i.ZIndex = Level; return i
end

local function SearchIcon()
    local i = Instance.new("ImageLabel")
    i.Name = "SearchIcon"; i.BackgroundTransparency = 1; i.Image = IconLibraryID
    i.ImageRectOffset = Vector2.new(964, 324); i.ImageRectSize = Vector2.new(36, 36)
    i.Size = UDim2.new(0, 16, 0, 16); i.Position = UDim2.new(0, 2, 0, 2)
    i.ZIndex = Level; return i
end

local function RoundBox(r, btn)
    local i = Instance.new(btn and "ImageButton" or "ImageLabel")
    i.BackgroundTransparency = 1; i.Image = "rbxassetid://3570695787"
    i.SliceCenter = Rect.new(100, 100, 100, 100)
    i.SliceScale  = math.clamp((r or 5) * 0.01, 0.01, 1)
    i.ScaleType   = Enum.ScaleType.Slice; i.ZIndex = Level; return i
end

local function MakeDropShadow()
    local i = Instance.new("ImageLabel")
    i.Name = "DropShadow"; i.BackgroundTransparency = 1; i.Image = DropShadowID
    i.ImageTransparency = DropShadowTransparency; i.Size = UDim2.new(1, 0, 1, 0)
    i.ZIndex = Level; return i
end

local function Frame()
    local i = Instance.new("Frame"); i.BorderSizePixel = 0; i.ZIndex = Level; return i
end

local function ScrollingFrame()
    local i = Instance.new("ScrollingFrame")
    i.BackgroundTransparency = 1; i.BorderSizePixel = 0
    i.ScrollBarThickness = 0; i.ZIndex = Level; return i
end

local function TextButton(txt, sz)
    local i = Instance.new("TextButton"); i.Text = txt; i.AutoButtonColor = false
    i.Font = MainFont; i.TextColor3 = Color3.fromRGB(255, 255, 255)
    i.BackgroundTransparency = 1; i.TextSize = sz or 12
    i.Size = UDim2.new(1, 0, 1, 0); i.ZIndex = Level; return i
end

local function TextBox(txt, sz)
    local i = Instance.new("TextBox"); i.Text = txt; i.Font = MainFont
    i.TextColor3 = Color3.fromRGB(255, 255, 255); i.BackgroundTransparency = 1
    i.TextSize = sz or 12; i.Size = UDim2.new(1, 0, 1, 0); i.ZIndex = Level; return i
end

local function TextLabel(txt, sz)
    local i = Instance.new("TextLabel"); i.Text = txt; i.Font = MainFont
    i.TextColor3 = Color3.fromRGB(255, 255, 255); i.BackgroundTransparency = 1
    i.TextSize = sz or 12; i.Size = UDim2.new(1, 0, 1, 0); i.ZIndex = Level; return i
end

local function Tween(obj, props, info)
    local t = TweenService:Create(obj, info or GlobalTweenInfo, props); t:Play(); return t
end

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6); c.Parent = parent; return c
end

-- Hover-scrollbar helper: shows a thin bar while mouse is over a ScrollingFrame
local function HoverScrollbar(sf, barColor)
    barColor = barColor or Color3.fromRGB(80, 80, 90)
    local bar = Frame()
    bar.Name = "HoverBar"; bar.BackgroundColor3 = barColor
    bar.BackgroundTransparency = 1; bar.Size = UDim2.new(0, 3, 0, 0)
    bar.Position = UDim2.new(1, -3, 0, 0); bar.ZIndex = sf.ZIndex + 5
    bar.Parent = sf; Corner(bar, 2)

    local function update()
        local canvas = sf.CanvasSize.Y.Offset
        local window = sf.AbsoluteSize.Y
        if canvas <= window then bar.Size = UDim2.new(0, 3, 0, 0); return end
        local ratio   = window / canvas
        local barH    = math.max(20, ratio * window)
        local scrollT = sf.CanvasPosition.Y / (canvas - window)
        local barY    = scrollT * (window - barH)
        bar.Size     = UDim2.new(0, 3, 0, barH)
        bar.Position = UDim2.new(1, -4, 0, barY)
    end

    sf:GetPropertyChangedSignal("CanvasPosition"):Connect(update)
    sf:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)

    sf.MouseEnter:Connect(function()
        Tween(bar, {BackgroundTransparency = 0.35}, SlowTweenInfo)
    end)
    sf.MouseLeave:Connect(function()
        Tween(bar, {BackgroundTransparency = 1}, SlowTweenInfo)
    end)
end

-- ================================================================
--  UILibrary
-- ================================================================
local UILibrary = {}

function UILibrary.Load(HubName, GameName, Version, TopBarConfig)
    HubName      = HubName      or "Twink UI"
    GameName     = GameName     or "Unknown Game"
    Version      = Version      or "v1.0"
    TopBarConfig = TopBarConfig or {}

    local TargetedParent = RunService:IsStudio()
        and Player:WaitForChild("PlayerGui") or CoreGuiService

    local old = TargetedParent:FindFirstChild(HubName)
    if old then old:Destroy() end

    -- ── Root ScreenGui ───────────────────────────────────────────
    local NewInstance = Instance.new("ScreenGui")
    NewInstance.Name          = HubName
    NewInstance.ResetOnSpawn  = false
    NewInstance.Parent        = TargetedParent

    -- ============================================================
    --  TOPBAR TOGGLE BUTTON
    -- ============================================================
    local UIVisible = true

    if TopBarConfig.Letter or TopBarConfig.Image then
        local TopBarGui = Instance.new("ScreenGui")
        TopBarGui.Name           = HubName .. "_TopBar"
        TopBarGui.DisplayOrder   = 10
        TopBarGui.ResetOnSpawn   = false
        TopBarGui.IgnoreGuiInset = true
        TopBarGui.Parent         = TargetedParent

        local TopBarButton = Instance.new("ImageButton")
        TopBarButton.Name                 = "TwinkTopBarBtn"
        TopBarButton.BackgroundColor3     = Color3.fromRGB(30, 30, 30)
        TopBarButton.BackgroundTransparency = 0.2
        TopBarButton.Size                 = UDim2.new(0, 36, 0, 36)
        TopBarButton.Position             = UDim2.new(0, 290, 0, 0)
        TopBarButton.AutoButtonColor      = false
        TopBarButton.Image                = ""
        TopBarButton.ZIndex               = 100
        TopBarButton.Parent               = TopBarGui
        Corner(TopBarButton, 8)

        TopBarButton.MouseEnter:Connect(function()
            Tween(TopBarButton, {BackgroundTransparency = 0})
        end)
        TopBarButton.MouseLeave:Connect(function()
            Tween(TopBarButton, {BackgroundTransparency = 0.2})
        end)

        if TopBarConfig.Image then
            local Img = Instance.new("ImageLabel")
            Img.BackgroundTransparency = 1; Img.Image = TopBarConfig.Image
            Img.Size = UDim2.new(0, 22, 0, 22); Img.Position = UDim2.new(0.5, -11, 0.5, -11)
            Img.ZIndex = 101; Img.Parent = TopBarButton
        else
            local Lbl = Instance.new("TextLabel")
            Lbl.BackgroundTransparency = 1
            Lbl.Text = tostring(TopBarConfig.Letter):sub(1, 2)
            Lbl.Font = Enum.Font.GothamBold; Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            Lbl.TextSize = 16; Lbl.Size = UDim2.new(1, 0, 1, 0); Lbl.ZIndex = 101
            Lbl.Parent = TopBarButton
        end

        -- Toggle: fade + disable input
        TopBarButton.MouseButton1Click:Connect(function()
            UIVisible = not UIVisible
            NewInstance.Enabled = UIVisible
            Tween(TopBarButton, {
                BackgroundColor3 = UIVisible and Color3.fromRGB(30, 30, 30) or AccentColor
            })
        end)
    end

    -- ============================================================
    --  NOTIFICATION SYSTEM  (fixed v5)
    --  • Spawns fully off-screen, slides in
    --  • Max 5 visible at once — oldest auto-dismissed
    --  • Gaps collapse cleanly via UIListLayout
    -- ============================================================
    local NotifGui = Instance.new("ScreenGui")
    NotifGui.Name           = HubName .. "_Notifs"
    NotifGui.DisplayOrder   = 50
    NotifGui.ResetOnSpawn   = false
    NotifGui.IgnoreGuiInset = false
    NotifGui.Parent         = TargetedParent

    local NotifHolder = Instance.new("Frame")
    NotifHolder.Name                 = "NotifHolder"
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.AnchorPoint          = Vector2.new(1, 0)
    NotifHolder.Size                 = UDim2.new(0, 240, 1, -20)
    NotifHolder.Position             = UDim2.new(1, -10, 0, 10)
    NotifHolder.ClipsDescendants     = false
    NotifHolder.ZIndex               = 300
    NotifHolder.Parent               = NotifGui

    local NotifList = Instance.new("UIListLayout")
    NotifList.SortOrder         = Enum.SortOrder.LayoutOrder
    NotifList.VerticalAlignment = Enum.VerticalAlignment.Top
    NotifList.Padding           = UDim.new(0, 6)
    NotifList.FillDirection     = Enum.FillDirection.Vertical
    NotifList.Parent            = NotifHolder

    local NotifCount    = 0
    local ActiveNotifs  = {}
    local MAX_NOTIFS    = 5

    local TypeColours = { success=SuccessColor, error=ErrorColor, info=InfoColor, warn=WarnColor }
    local TypeIcons   = { success="✓", error="✕", info="ℹ", warn="⚠" }

    function UILibrary.Notify(Title, Message, NotifType, Duration)
        NotifType = (NotifType or "info"):lower()
        Duration  = Duration or 4
        local Colour = TypeColours[NotifType] or InfoColor
        local Icon   = TypeIcons[NotifType]   or "ℹ"

        -- Dismiss oldest if at cap
        if #ActiveNotifs >= MAX_NOTIFS then
            local oldest = table.remove(ActiveNotifs, 1)
            if oldest and oldest.Dismiss then oldest.Dismiss() end
        end

        NotifCount += 1

        -- Card  (starts fully transparent and offset right)
        local NCard = RoundBox(6)
        NCard.Name            = "Notif" .. NotifCount
        NCard.LayoutOrder     = NotifCount
        NCard.ImageColor3     = Color3.fromRGB(36, 36, 40)
        NCard.Size            = UDim2.new(1, 0, 0, 58)
        NCard.BackgroundTransparency = 1  -- used for card fade (image handles bg)
        NCard.ZIndex          = 300
        NCard.Parent          = NotifHolder

        -- Slide in: start offset to the right, tween back to 0
        NCard.Position = UDim2.new(0, 260, 0, 0)   -- off-screen right

        -- Left accent strip
        local NAcc = Frame()
        NAcc.BackgroundColor3 = Colour; NAcc.Size = UDim2.new(0, 3, 0.7, 0)
        NAcc.Position = UDim2.new(0, 0, 0.15, 0); NAcc.ZIndex = 301; NAcc.Parent = NCard
        Corner(NAcc, 3)

        -- Icon
        local NIco = Instance.new("TextLabel")
        NIco.BackgroundTransparency = 1; NIco.Font = Enum.Font.GothamBold
        NIco.TextColor3 = Colour; NIco.TextSize = 16; NIco.Text = Icon
        NIco.Size = UDim2.new(0, 22, 0, 22); NIco.Position = UDim2.new(0, 8, 0, 8)
        NIco.ZIndex = 302; NIco.Parent = NCard

        -- Title
        local NTit = Instance.new("TextLabel")
        NTit.BackgroundTransparency = 1; NTit.Font = Enum.Font.GothamBold
        NTit.TextColor3 = Color3.fromRGB(255, 255, 255); NTit.TextSize = 12
        NTit.Text = Title or ""; NTit.TextXAlignment = Enum.TextXAlignment.Left
        NTit.TextTruncate = Enum.TextTruncate.AtEnd
        NTit.Size = UDim2.new(1, -40, 0, 14); NTit.Position = UDim2.new(0, 34, 0, 8)
        NTit.ZIndex = 302; NTit.Parent = NCard

        -- Message
        local NMsg = Instance.new("TextLabel")
        NMsg.BackgroundTransparency = 1; NMsg.Font = MainFont
        NMsg.TextColor3 = Color3.fromRGB(185, 185, 195); NMsg.TextSize = 10
        NMsg.Text = Message or ""; NMsg.TextXAlignment = Enum.TextXAlignment.Left
        NMsg.TextTruncate = Enum.TextTruncate.AtEnd
        NMsg.Size = UDim2.new(1, -40, 0, 12); NMsg.Position = UDim2.new(0, 34, 0, 25)
        NMsg.ZIndex = 302; NMsg.Parent = NCard

        -- Timer track + fill
        local NTrack = Frame()
        NTrack.BackgroundColor3 = Color3.fromRGB(55, 55, 62)
        NTrack.Size = UDim2.new(1, -10, 0, 2); NTrack.Position = UDim2.new(0, 5, 1, -5)
        NTrack.ZIndex = 302; NTrack.Parent = NCard; Corner(NTrack, 2)

        local NFill = Frame()
        NFill.BackgroundColor3 = Colour; NFill.Size = UDim2.new(1, 0, 1, 0)
        NFill.ZIndex = 303; NFill.Parent = NTrack; Corner(NFill, 2)

        -- Dismiss function
        local dismissed = false
        local notifObj  = {}
        function notifObj.Dismiss()
            if dismissed then return end
            dismissed = true
            -- remove from active list
            for i, v in ipairs(ActiveNotifs) do
                if v == notifObj then table.remove(ActiveNotifs, i); break end
            end
            Tween(NCard, {Position = UDim2.new(0, 260, 0, 0), ImageTransparency = 1}, SlowTweenInfo)
            task.delay(0.35, function()
                -- Shrink height to collapse gap in layout
                Tween(NCard, {Size = UDim2.new(1, 0, 0, 0)}, GlobalTweenInfo)
                task.delay(0.15, function() NCard:Destroy() end)
            end)
        end
        table.insert(ActiveNotifs, notifObj)

        -- Slide in
        task.delay(0.02, function()
            Tween(NCard, {Position = UDim2.new(0, 0, 0, 0)}, SlowTweenInfo)
        end)

        -- Drain timer bar
        TweenService:Create(NFill,
            TweenInfo.new(Duration, Enum.EasingStyle.Linear),
            {Size = UDim2.new(0, 0, 1, 0)}
        ):Play()

        -- Auto-dismiss
        task.delay(Duration, function() notifObj.Dismiss() end)

        -- Click to dismiss
        local CB = Instance.new("TextButton")
        CB.BackgroundTransparency = 1; CB.Text = ""; CB.Size = UDim2.new(1, 0, 1, 0)
        CB.ZIndex = 305; CB.Parent = NCard
        CB.MouseButton1Click:Connect(function() notifObj.Dismiss() end)
    end

    -- ============================================================
    --  WATERMARK  (draggable overlay, top-left by default)
    --  UI.SetWatermark(true/false)
    -- ============================================================
    local WatermarkGui = Instance.new("ScreenGui")
    WatermarkGui.Name          = HubName .. "_WM"
    WatermarkGui.DisplayOrder  = 5
    WatermarkGui.ResetOnSpawn  = false
    WatermarkGui.Enabled       = false      -- off by default
    WatermarkGui.Parent        = TargetedParent

    local WMFrame = RoundBox(5)
    WMFrame.Name = "Watermark"; WMFrame.ImageColor3 = Color3.fromRGB(30, 30, 35)
    WMFrame.Size = UDim2.new(0, 220, 0, 22); WMFrame.Position = UDim2.new(0, 8, 0, 8)
    WMFrame.Parent = WatermarkGui; Level += 1

    -- Left accent strip
    local WMAcc = Frame()
    WMAcc.BackgroundColor3 = AccentColor; WMAcc.BackgroundTransparency = 0.3
    WMAcc.Size = UDim2.new(0, 3, 1, 0); WMAcc.ZIndex = Level; WMAcc.Parent = WMFrame
    Corner(WMAcc, 3)

    local WMLabel = Instance.new("TextLabel")
    WMLabel.BackgroundTransparency = 1; WMLabel.Font = Enum.Font.GothamBold
    WMLabel.TextColor3 = Color3.fromRGB(220, 220, 230); WMLabel.TextSize = 11
    WMLabel.TextXAlignment = Enum.TextXAlignment.Left
    WMLabel.Size = UDim2.new(1, -8, 1, 0); WMLabel.Position = UDim2.new(0, 8, 0, 0)
    WMLabel.ZIndex = Level; WMLabel.Parent = WMFrame

    -- Update label every heartbeat
    RunService.Heartbeat:Connect(function()
        if not WatermarkGui.Enabled then return end
        local fps  = math.floor(1 / RunService.Heartbeat:Wait())
        local ping = StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
        WMLabel.Text = string.format("%s  |  %s  |  %d FPS  |  %d ms",
            HubName, Version, fps, math.floor(ping))
    end)

    -- Draggable
    local WMDrag = TextButton("", 12)
    WMDrag.ZIndex = Level + 1; WMDrag.Parent = WMFrame
    WMDrag.MouseButton1Down:Connect(function()
        local lx, ly = Mouse.X, Mouse.Y
        local mv, kl
        mv = Mouse.Move:Connect(function()
            local nx, ny = Mouse.X, Mouse.Y
            WMFrame.Position += UDim2.new(0, nx - lx, 0, ny - ly)
            lx, ly = nx, ny
        end)
        kl = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                mv:Disconnect(); kl:Disconnect()
            end
        end)
    end)

    function UILibrary.SetWatermark(enabled)
        WatermarkGui.Enabled = enabled == true
    end

    -- ============================================================
    --  ACCENT COLOR  (updates live accent strip registry)
    -- ============================================================
    local AccentObjects = {}   -- { obj, prop } pairs registered for live update

    local function RegisterAccent(obj, prop)
        table.insert(AccentObjects, {obj = obj, prop = prop})
        obj[prop] = AccentColor
    end

    function UILibrary.SetAccentColor(newColor)
        AccentColor = newColor
        for _, entry in ipairs(AccentObjects) do
            pcall(function() entry.obj[entry.prop] = newColor end)
        end
        -- Also update watermark accent
        WMAcc.BackgroundColor3 = newColor
    end

    -- ============================================================
    --  CONFIG SAVE / LOAD
    --  Serialises all registered elements to a JSON file.
    --  Requires writefile / readfile (executor environment).
    -- ============================================================
    function UILibrary.SaveConfig(profileName)
        local data = {}
        for id, entry in pairs(ConfigRegistry) do
            local ok, val = pcall(entry.getter)
            if ok then data[id] = val end
        end
        local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not ok then warn("[TwinkUI] SaveConfig encode failed:", encoded); return end
        local filename = HubName .. "_" .. (profileName or "default") .. ".json"
        local sOk, sErr = pcall(writefile, filename, encoded)
        if not sOk then warn("[TwinkUI] SaveConfig writefile failed:", sErr) end
    end

    function UILibrary.LoadConfig(profileName)
        local filename = HubName .. "_" .. (profileName or "default") .. ".json"
        local ok, raw = pcall(readfile, filename)
        if not ok then warn("[TwinkUI] LoadConfig: file not found:", filename); return end
        local dOk, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if not dOk then warn("[TwinkUI] LoadConfig decode failed:", data); return end
        for id, val in pairs(data) do
            if ConfigRegistry[id] then
                pcall(ConfigRegistry[id].setter, val)
            end
        end
    end

    -- ============================================================
    --  MAIN FRAME
    -- ============================================================
    local ContainerFrame = Frame()
    ContainerFrame.Name = "ContainerFrame"; ContainerFrame.Size = UDim2.new(0, 500, 0, 300)
    ContainerFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
    ContainerFrame.BackgroundTransparency = 1; ContainerFrame.Parent = NewInstance

    local ContainerShadow = MakeDropShadow()
    ContainerShadow.Name = "Shadow"; ContainerShadow.Parent = ContainerFrame

    Level += 1

    local MainFrame = RoundBox(5)
    MainFrame.ClipsDescendants = true; MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(1, -50, 1, -30); MainFrame.Position = UDim2.new(0, 25, 0, 15)
    MainFrame.ImageColor3 = Color3.fromRGB(30, 30, 30); MainFrame.Parent = ContainerFrame

    -- ── OPEN ANIMATION  (scale from 0.92 → 1.0, fade in) ────────
    MainFrame.ImageTransparency = 1
    ContainerFrame.Size = UDim2.new(0, 500 * 0.92, 0, 300 * 0.92)
    ContainerFrame.Position = UDim2.new(0.5, -(500 * 0.92) / 2, 0.5, -(300 * 0.92) / 2)
    task.defer(function()
        Tween(MainFrame,      {ImageTransparency = 0},               OpenTweenInfo)
        Tween(ContainerShadow,{ImageTransparency = DropShadowTransparency}, OpenTweenInfo)
        Tween(ContainerFrame, {
            Size     = UDim2.new(0, 500, 0, 300),
            Position = UDim2.new(0.5, -250, 0.5, -150),
        }, OpenTweenInfo)
    end)

    -- ============================================================
    --  TITLE BAR
    -- ============================================================
    local TitleBar = RoundBox(5)
    TitleBar.Name = "TitleBar"; TitleBar.ImageColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.Size = UDim2.new(1, -10, 0, 24); TitleBar.Position = UDim2.new(0, 5, 0, 5)
    TitleBar.Parent = MainFrame

    Level += 1

    -- Hub name (left, bold)
    local HubLabel = TextLabel(HubName, 12)
    HubLabel.Font = Enum.Font.GothamBold; HubLabel.TextXAlignment = Enum.TextXAlignment.Left
    HubLabel.Size = UDim2.new(0.33, 0, 1, 0); HubLabel.Position = UDim2.new(0, 8, 0, 0)
    HubLabel.ZIndex = Level; HubLabel.Parent = TitleBar

    local D1 = Frame(); D1.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    D1.Size = UDim2.new(0, 1, 0.45, 0); D1.Position = UDim2.new(0.35, 0, 0.275, 0)
    D1.ZIndex = Level; D1.Parent = TitleBar

    local GameLabel = TextLabel(GameName, 11)
    GameLabel.TextXAlignment = Enum.TextXAlignment.Center; GameLabel.TextTransparency = 0.25
    GameLabel.Size = UDim2.new(0.3, 0, 1, 0); GameLabel.Position = UDim2.new(0.35, 4, 0, 0)
    GameLabel.ZIndex = Level; GameLabel.Parent = TitleBar

    local D2 = Frame(); D2.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    D2.Size = UDim2.new(0, 1, 0.45, 0); D2.Position = UDim2.new(0.65, 4, 0.275, 0)
    D2.ZIndex = Level; D2.Parent = TitleBar

    local VersionLabel = TextLabel(Version, 10)
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Right; VersionLabel.TextTransparency = 0.4
    VersionLabel.Size = UDim2.new(0.28, -20, 1, 0); VersionLabel.Position = UDim2.new(0.67, 6, 0, 0)
    VersionLabel.ZIndex = Level; VersionLabel.Parent = TitleBar

    -- Minimise
    local MinimiseToggle = true
    local MinimiseButton = TitleIcon(true)
    MinimiseButton.Name = "Minimise"; MinimiseButton.Parent = TitleBar

    MinimiseButton.MouseButton1Down:Connect(function()
        MinimiseToggle = not MinimiseToggle
        if not MinimiseToggle then
            Tween(MainFrame, {Size = UDim2.new(1, -50, 0, 30)})
            Tween(MinimiseButton, {Rotation = 0})
            Tween(ContainerShadow, {ImageTransparency = 1})
        else
            Tween(MainFrame, {Size = UDim2.new(1, -50, 1, -30)})
            Tween(MinimiseButton, {Rotation = 180})
            Tween(ContainerShadow, {ImageTransparency = DropShadowTransparency})
        end
    end)

    -- Drag
    local TitleDrag = TextButton("", 14)
    TitleDrag.Name = "TitleDrag"; TitleDrag.Size = UDim2.new(1, -20, 1, 0)
    TitleDrag.ZIndex = Level; TitleDrag.Parent = TitleBar

    TitleDrag.MouseButton1Down:Connect(function()
        local lx, ly = Mouse.X, Mouse.Y
        local mv, kl
        mv = Mouse.Move:Connect(function()
            local nx, ny = Mouse.X, Mouse.Y
            ContainerFrame.Position += UDim2.new(0, nx - lx, 0, ny - ly)
            lx, ly = nx, ny
        end)
        kl = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                mv:Disconnect(); kl:Disconnect()
            end
        end)
    end)

    Level += 1

    -- ============================================================
    --  SIDEBAR + CONTENT
    -- ============================================================
    local MenuBar = ScrollingFrame()
    MenuBar.Name = "MenuBar"; MenuBar.BackgroundTransparency = 0.7
    MenuBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MenuBar.Size = UDim2.new(0, 100, 0, 181); MenuBar.Position = UDim2.new(0, 5, 0, 33)
    MenuBar.CanvasSize = UDim2.new(0, 0, 0, 0); MenuBar.Parent = MainFrame
    HoverScrollbar(MenuBar)

    local DisplayFrame = RoundBox(5)
    DisplayFrame.Name = "Display"; DisplayFrame.ImageColor3 = Color3.fromRGB(20, 20, 20)
    DisplayFrame.Size = UDim2.new(1, -115, 0, 232); DisplayFrame.Position = UDim2.new(0, 110, 0, 33)
    DisplayFrame.Parent = MainFrame

    -- ============================================================
    --  PLAYER INFO  (bottom of sidebar)
    -- ============================================================
    local UserInfoPanel = RoundBox(5)
    UserInfoPanel.Name = "UserInfo"; UserInfoPanel.ImageColor3 = Color3.fromRGB(35, 35, 35)
    UserInfoPanel.Size = UDim2.new(0, 100, 0, 46); UserInfoPanel.Position = UDim2.new(0, 5, 0, 219)
    UserInfoPanel.ClipsDescendants = true; UserInfoPanel.Parent = MainFrame

    local InfoAccent = Frame()
    InfoAccent.BackgroundColor3 = AccentColor; InfoAccent.BackgroundTransparency = 0.55
    InfoAccent.Size = UDim2.new(1, 0, 0, 2); InfoAccent.ZIndex = Level; InfoAccent.Parent = UserInfoPanel
    RegisterAccent(InfoAccent, "BackgroundColor3")

    local AvatarHolder = Frame()
    AvatarHolder.Name = "AvatarHolder"; AvatarHolder.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    AvatarHolder.Size = UDim2.new(0, 30, 0, 30); AvatarHolder.Position = UDim2.new(0, 7, 0.5, -15)
    AvatarHolder.ZIndex = Level; AvatarHolder.Parent = UserInfoPanel; Corner(AvatarHolder, 999)

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name = "AvatarImage"; AvatarImage.BackgroundTransparency = 1
    AvatarImage.Size = UDim2.new(1, 0, 1, 0); AvatarImage.ZIndex = Level + 1
    AvatarImage.Parent = AvatarHolder; Corner(AvatarImage, 999)

    local StatusDot = Frame()
    StatusDot.BackgroundColor3 = Color3.fromRGB(0, 200, 90)
    StatusDot.Size = UDim2.new(0, 7, 0, 7); StatusDot.Position = UDim2.new(1, -7, 1, -7)
    StatusDot.ZIndex = Level + 2; StatusDot.Parent = AvatarHolder; Corner(StatusDot, 999)

    local WelcomeLine = TextLabel("Welcome,", 9)
    WelcomeLine.TextXAlignment = Enum.TextXAlignment.Left; WelcomeLine.TextTransparency = 0.4
    WelcomeLine.TextTruncate = Enum.TextTruncate.AtEnd
    WelcomeLine.Size = UDim2.new(1, -44, 0, 12); WelcomeLine.Position = UDim2.new(0, 42, 0, 9)
    WelcomeLine.ZIndex = Level; WelcomeLine.Parent = UserInfoPanel

    local NameLine = TextLabel(Player.DisplayName .. "!", 11)
    NameLine.Font = Enum.Font.GothamBold; NameLine.TextXAlignment = Enum.TextXAlignment.Left
    NameLine.TextTruncate = Enum.TextTruncate.AtEnd
    NameLine.Size = UDim2.new(1, -44, 0, 13); NameLine.Position = UDim2.new(0, 42, 0, 23)
    NameLine.ZIndex = Level; NameLine.Parent = UserInfoPanel

    task.spawn(function()
        local ok, thumb = pcall(function()
            return PlayersService:GetUserThumbnailAsync(
                Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        if ok and thumb then AvatarImage.Image = thumb end
    end)

    -- ============================================================
    --  TAB SYSTEM
    -- ============================================================
    Level += 1

    local MenuList = Instance.new("UIListLayout")
    MenuList.SortOrder = Enum.SortOrder.LayoutOrder; MenuList.Padding = UDim.new(0, 5)
    MenuList.Parent = MenuBar
    MenuList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        MenuBar.CanvasSize = UDim2.new(0, 0, 0, MenuList.AbsoluteContentSize.Y + 5)
    end)

    local TabCount   = 0
    local TabLibrary = {}

    function TabLibrary.AddPage(PageTitle, SearchBarIncluded)
        SearchBarIncluded = (SearchBarIncluded == nil) and true or SearchBarIncluded

        -- Tab pill
        local PageContainer = RoundBox(5)
        PageContainer.Name = PageTitle; PageContainer.Size = UDim2.new(1, 0, 0, 20)
        PageContainer.LayoutOrder = TabCount
        PageContainer.ImageColor3 = (TabCount == 0) and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(40, 40, 40)
        PageContainer.Parent = MenuBar

        -- Active indicator strip
        local ActiveStrip = Frame()
        ActiveStrip.Name = "ActiveStrip"
        ActiveStrip.BackgroundColor3 = AccentColor
        ActiveStrip.Size = UDim2.new(0, 2, 0.6, 0); ActiveStrip.Position = UDim2.new(0, 0, 0.2, 0)
        ActiveStrip.BackgroundTransparency = (TabCount == 0) and 0 or 1
        ActiveStrip.ZIndex = Level + 2; ActiveStrip.Parent = PageContainer; Corner(ActiveStrip, 2)
        RegisterAccent(ActiveStrip, "BackgroundColor3")

        local PageButton = TextButton(PageTitle, 12)
        PageButton.Name = PageTitle .. "Button"
        PageButton.TextXAlignment = Enum.TextXAlignment.Center
        PageButton.TextTransparency = (TabCount == 0) and 0 or 0.45
        PageButton.Parent = PageContainer

        -- Display page (scrollable, with hover scrollbar)
        local DisplayPage = ScrollingFrame()
        DisplayPage.Visible = (TabCount == 0); DisplayPage.Name = PageTitle
        DisplayPage.Size = UDim2.new(1, 0, 1, 0); DisplayPage.Parent = DisplayFrame
        HoverScrollbar(DisplayPage)

        TabCount += 1

        PageButton.MouseButton1Down:Connect(function()
            task.spawn(function()
                for _, btn in next, MenuBar:GetChildren() do
                    if btn:IsA("GuiObject") then
                        local match = string.find(btn.Name:lower(), PageContainer.Name:lower())
                        local inner = btn:FindFirstChild(btn.Name .. "Button")
                        local strip = btn:FindFirstChild("ActiveStrip")
                        Tween(btn, {ImageColor3 = match and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(40, 40, 40)})
                        if inner then Tween(inner, {TextTransparency = match and 0 or 0.45}) end
                        if strip then Tween(strip, {BackgroundTransparency = match and 0 or 1}) end
                    end
                end
            end)
            task.spawn(function()
                for _, disp in next, DisplayFrame:GetChildren() do
                    if disp:IsA("GuiObject") then
                        disp.Visible = string.find(disp.Name:lower(), PageContainer.Name:lower()) and true or false
                    end
                end
            end)
        end)

        local DisplayList = Instance.new("UIListLayout")
        DisplayList.SortOrder = Enum.SortOrder.LayoutOrder; DisplayList.Padding = UDim.new(0, 5)
        DisplayList.Parent = DisplayPage
        DisplayList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            DisplayPage.CanvasSize = UDim2.new(0, 0,
                (DisplayList.AbsoluteContentSize.Y / math.max(1, DisplayPage.AbsoluteWindowSize.Y)) + 0.05, 0)
        end)

        local Pad = Instance.new("UIPadding")
        Pad.PaddingBottom = UDim.new(0, 5); Pad.PaddingTop = UDim.new(0, 5)
        Pad.PaddingLeft = UDim.new(0, 5); Pad.PaddingRight = UDim.new(0, 5)
        Pad.Parent = DisplayPage

        if SearchBarIncluded then
            local SBC = RoundBox(5); SBC.Name = "SearchBar"; SBC.ImageColor3 = Color3.fromRGB(35, 35, 35)
            SBC.Size = UDim2.new(1, 0, 0, 20); SBC.Parent = DisplayPage
            local SBox = TextBox("Search..."); SBox.Name = "SearchInput"
            SBox.Position = UDim2.new(0, 20, 0, 0); SBox.Size = UDim2.new(1, -20, 1, 0)
            SBox.TextTransparency = 0.5; SBox.TextXAlignment = Enum.TextXAlignment.Left
            SBox.ClearTextOnFocus = false; SBox.Parent = SBC
            SearchIcon().Parent = SBC
            SBox:GetPropertyChangedSignal("Text"):Connect(function()
                local v = SBox.Text:lower()
                for _, el in next, DisplayPage:GetChildren() do
                    if el:IsA("Frame") and not el.Name:lower():find("section") then
                        el.Visible = el.Name:lower():find(v) and true or false
                    end
                end
            end)
        end

        -- ============================================================
        --  PAGE LIBRARY
        -- ============================================================
        local PageLibrary = {}

        -- ── BUTTON ───────────────────────────────────────────────────
        function PageLibrary.AddButton(Text, Callback, Parent, Underline)
            local BC = Frame(); BC.Name = Text .. "BUTTON"; BC.Size = UDim2.new(1, 0, 0, 20)
            BC.BackgroundTransparency = 1; BC.Parent = Parent or DisplayPage
            local BF = RoundBox(5); BF.Name = "ButtonForeground"; BF.Size = UDim2.new(1, 0, 1, 0)
            BF.ImageColor3 = Color3.fromRGB(35, 35, 35); BF.Parent = BC
            if Underline then
                local ts = TextService:GetTextSize(Text, 12, Enum.Font.Gotham, Vector2.new(0, 0))
                local be = Frame(); be.Size = UDim2.new(0, ts.X, 0, 1)
                be.Position = UDim2.new(0.5, (-ts.X / 2) - 1, 1, -1)
                be.BackgroundColor3 = Color3.fromRGB(255, 255, 255); be.BackgroundTransparency = 0.5; be.Parent = BF
            end
            local HB = TextButton(Text, 12); HB.Parent = BF
            HB.MouseButton1Down:Connect(function()
                Callback()
                Tween(BF, {ImageColor3 = Color3.fromRGB(45, 45, 45)}); Tween(HB, {TextTransparency = 0.5})
                wait(TweenTime)
                Tween(BF, {ImageColor3 = Color3.fromRGB(35, 35, 35)}); Tween(HB, {TextTransparency = 0})
            end)
        end

        -- ── LABEL ────────────────────────────────────────────────────
        function PageLibrary.AddLabel(Text)
            local LC = Frame(); LC.Name = Text .. "LABEL"; LC.Size = UDim2.new(1, 0, 0, 20)
            LC.BackgroundTransparency = 1; LC.Parent = DisplayPage
            local LF = RoundBox(5); LF.ImageColor3 = Color3.fromRGB(45, 45, 45)
            LF.Size = UDim2.new(1, 0, 1, 0); LF.Parent = LC
            TextLabel(Text, 12).Parent = LF
        end

        -- ── SECTION ──────────────────────────────────────────────────
        function PageLibrary.AddSection(Text)
            local SC = Frame(); SC.Name = Text .. "SECTION"; SC.Size = UDim2.new(1, 0, 0, 18)
            SC.BackgroundTransparency = 1; SC.Parent = DisplayPage
            local LL = Frame(); LL.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            LL.Size = UDim2.new(0.5, -4, 0, 1); LL.Position = UDim2.new(0, 0, 0.5, 0)
            LL.ZIndex = Level; LL.Parent = SC
            local RL = Frame(); RL.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            RL.Size = UDim2.new(0.5, -4, 0, 1); RL.Position = UDim2.new(0.5, 4, 0.5, 0)
            RL.ZIndex = Level; RL.Parent = SC
            local SL = Instance.new("TextLabel")
            SL.BackgroundTransparency = 1; SL.Font = Enum.Font.GothamBold
            SL.TextColor3 = Color3.fromRGB(170, 170, 170); SL.TextSize = 10; SL.Text = Text
            SL.AutomaticSize = Enum.AutomaticSize.X; SL.Size = UDim2.new(0, 0, 1, 0)
            SL.AnchorPoint = Vector2.new(0.5, 0); SL.Position = UDim2.new(0.5, 0, 0, 0)
            SL.ZIndex = Level; SL.Parent = SC
            SL:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                local half = SL.AbsoluteSize.X / 2 + 4
                LL.Size = UDim2.new(0.5, -half, 0, 1)
                RL.Size = UDim2.new(0.5, -half, 0, 1)
                RL.Position = UDim2.new(0.5, half, 0.5, 0)
            end)
        end

        -- ── TOGGLE ───────────────────────────────────────────────────
        function PageLibrary.AddToggle(Text, Default, Callback)
            local State = Default or false
            local TC = Frame(); TC.Name = Text .. "TOGGLE"; TC.Size = UDim2.new(1, 0, 0, 20)
            TC.BackgroundTransparency = 1; TC.Parent = DisplayPage
            local TL, TR = RoundBox(5), RoundBox(5)
            local EF, RT = Frame(), TickIcon()
            local FL, FR = Frame(), Frame()
            TL.Size = UDim2.new(1, -22, 1, 0); TL.ImageColor3 = Color3.fromRGB(35, 35, 35); TL.Parent = TC
            TR.Position = UDim2.new(1, -20, 0, 0); TR.Size = UDim2.new(0, 20, 1, 0)
            TR.ImageColor3 = Color3.fromRGB(45, 45, 45); TR.Parent = TC
            FL.BackgroundColor3 = Color3.fromRGB(35, 35, 35); FL.Size = UDim2.new(0, 5, 1, 0)
            FL.Position = UDim2.new(1, -5, 0, 0); FL.Parent = TL
            FR.BackgroundColor3 = Color3.fromRGB(45, 45, 45); FR.Size = UDim2.new(0, 5, 1, 0); FR.Parent = TR
            EF.BackgroundColor3 = State and SuccessColor or Color3.fromRGB(255, 160, 160)
            EF.Position = UDim2.new(1, -22, 0.2, 0); EF.Size = UDim2.new(0, 2, 0.6, 0); EF.Parent = TC
            RT.ImageTransparency = State and 0 or 1; RT.Parent = TR
            local TB = TextButton(Text, 12); TB.Name = "ToggleButton"; TB.Parent = TL

            -- Config registration
            local configId = PageTitle .. "_" .. Text .. "_toggle"
            ConfigRegistry[configId] = {
                getter = function() return State end,
                setter = function(v)
                    State = v == true
                    EF.BackgroundColor3 = State and SuccessColor or Color3.fromRGB(255, 160, 160)
                    RT.ImageTransparency = State and 0 or 1
                    Callback(State)
                end
            }

            TB.MouseButton1Down:Connect(function()
                State = not State
                Tween(EF, {BackgroundColor3 = State and SuccessColor or Color3.fromRGB(255, 160, 160)})
                Tween(RT, {ImageTransparency = State and 0 or 1})
                Callback(State)
            end)
        end

        -- ── SLIDER ───────────────────────────────────────────────────
        function PageLibrary.AddSlider(Text, Config, Callback, Parent)
            local Min = Config.Minimum or Config.minimum or Config.Min or Config.min
            local Max = Config.Maximum or Config.maximum or Config.Max or Config.max
            local Def = Config.Default or Config.default or Config.Def or Config.def
            if Min > Max then Min, Max = Max, Min end
            Def = math.clamp(Def, Min, Max)
            local DS = Def / Max
            local CurrentVal = Def

            local SC = Frame(); SC.Name = Text .. "SLIDER"; SC.Size = UDim2.new(1, 0, 0, 20)
            SC.BackgroundTransparency = 1; SC.Parent = Parent or DisplayPage
            local SF = RoundBox(5); SF.ImageColor3 = Color3.fromRGB(35, 35, 35)
            SF.Size = UDim2.new(1, 0, 1, 0); SF.Parent = SC
            local SB = TextButton(Text .. ": " .. Def); SB.ZIndex = 6; SB.Parent = SF
            local Fill = RoundBox(5); Fill.Size = UDim2.new(DS, 0, 1, 0); Fill.ImageColor3 = Color3.fromRGB(70, 70, 70)
            Fill.ZIndex = 5; Fill.ImageTransparency = 0.7; Fill.Parent = SB

            -- Config registration
            local configId = PageTitle .. "_" .. Text .. "_slider"
            ConfigRegistry[configId] = {
                getter = function() return CurrentVal end,
                setter = function(v)
                    v = math.clamp(v, Min, Max)
                    CurrentVal = v
                    SB.Text = Text .. ": " .. v
                    Tween(Fill, {Size = UDim2.new((v - Min) / (Max - Min), 0, 1, 0)})
                    Callback(v)
                end
            }

            SB.MouseButton1Down:Connect(function()
                Tween(Fill, {ImageTransparency = 0.5})
                local _, _, xs = GetXY(SB)
                local val = math.floor(Min + (Max - Min) * xs)
                CurrentVal = val; Callback(val); SB.Text = Text .. ": " .. val
                Tween(Fill, {Size = UDim2.new(xs, 0, 1, 0)})
                local smv, skl
                smv = Mouse.Move:Connect(function()
                    Tween(Fill, {ImageTransparency = 0.5})
                    local _, _, xs2 = GetXY(SB)
                    local v2 = math.floor(Min + (Max - Min) * xs2)
                    CurrentVal = v2; Callback(v2); SB.Text = Text .. ": " .. v2
                    Tween(Fill, {Size = UDim2.new(xs2, 0, 1, 0)})
                end)
                skl = UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        Tween(Fill, {ImageTransparency = 0.7}); smv:Disconnect(); skl:Disconnect()
                    end
                end)
            end)
        end

        -- ── INPUT ────────────────────────────────────────────────────
        function PageLibrary.AddInput(Text, Placeholder, Callback)
            local IC = Frame(); IC.Name = Text .. "INPUT"; IC.Size = UDim2.new(1, 0, 0, 20)
            IC.BackgroundTransparency = 1; IC.Parent = DisplayPage
            local IF = RoundBox(5); IF.ImageColor3 = Color3.fromRGB(35, 35, 35)
            IF.Size = UDim2.new(1, 0, 1, 0); IF.Parent = IC
            local LP = RoundBox(5); LP.ImageColor3 = Color3.fromRGB(40, 40, 40)
            LP.Size = UDim2.new(0.42, 0, 1, 0); LP.Parent = IC
            local LF2 = Frame(); LF2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            LF2.Size = UDim2.new(0, 5, 1, 0); LF2.Position = UDim2.new(1, -5, 0, 0)
            LF2.ZIndex = Level; LF2.Parent = LP
            local LT = TextLabel(Text, 12); LT.ZIndex = Level + 1; LT.Parent = LP
            local IBox = TextBox("", 12); IBox.PlaceholderText = Placeholder or "Type here..."
            IBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130); IBox.ClearTextOnFocus = false
            IBox.TextXAlignment = Enum.TextXAlignment.Left
            IBox.Position = UDim2.new(0.42, 4, 0, 0); IBox.Size = UDim2.new(0.58, -6, 1, 0)
            IBox.ZIndex = Level + 1; IBox.Parent = IC
            local FLine = Frame(); FLine.BackgroundColor3 = AccentColor
            FLine.BackgroundTransparency = 1; FLine.Size = UDim2.new(0, 0, 0, 1)
            FLine.Position = UDim2.new(0, 0, 1, -1); FLine.ZIndex = Level + 2; FLine.Parent = IF
            RegisterAccent(FLine, "BackgroundColor3")
            IBox.Focused:Connect(function()
                Tween(IF, {ImageColor3 = Color3.fromRGB(42, 42, 42)})
                Tween(FLine, {BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, 1)}, SlowTweenInfo)
            end)
            IBox.FocusLost:Connect(function(enter)
                Tween(IF, {ImageColor3 = Color3.fromRGB(35, 35, 35)})
                Tween(FLine, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 1)}, SlowTweenInfo)
                if Callback then Callback(IBox.Text, enter) end
            end)
        end

        -- ── KEYBIND ──────────────────────────────────────────────────
        function PageLibrary.AddKeybind(Text, Default, Callback)
            local CurrentKey = Default or Enum.KeyCode.Unknown
            local Listening  = false

            local KB = Frame(); KB.Name = Text .. "KEYBIND"; KB.Size = UDim2.new(1, 0, 0, 20)
            KB.BackgroundTransparency = 1; KB.Parent = DisplayPage
            local KF = RoundBox(5); KF.ImageColor3 = Color3.fromRGB(35, 35, 35)
            KF.Size = UDim2.new(1, 0, 1, 0); KF.Parent = KB
            local KL = RoundBox(5); KL.ImageColor3 = Color3.fromRGB(40, 40, 40)
            KL.Size = UDim2.new(1, -52, 1, 0); KL.Parent = KB
            local KLF = Frame(); KLF.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            KLF.Size = UDim2.new(0, 5, 1, 0); KLF.Position = UDim2.new(1, -5, 0, 0)
            KLF.ZIndex = Level; KLF.Parent = KL
            TextLabel(Text, 12).Parent = KL
            local KBadge = RoundBox(5); KBadge.ImageColor3 = Color3.fromRGB(50, 50, 50)
            KBadge.Size = UDim2.new(0, 50, 1, 0); KBadge.Position = UDim2.new(1, -50, 0, 0)
            KBadge.ZIndex = Level; KBadge.Parent = KB
            local KBFL = Frame(); KBFL.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            KBFL.Size = UDim2.new(0, 5, 1, 0); KBFL.ZIndex = Level; KBFL.Parent = KBadge
            local function KName(kc)
                if kc == Enum.KeyCode.Unknown then return "[None]" end
                return tostring(kc):gsub("Enum.KeyCode.", "")
            end
            local KBL = TextLabel(KName(CurrentKey), 10); KBL.ZIndex = Level + 1; KBL.Parent = KBadge
            local KBtn = TextButton("", 12); KBtn.ZIndex = Level + 2; KBtn.Parent = KB
            KBtn.MouseButton1Down:Connect(function()
                if Listening then return end
                Listening = true; Tween(KBadge, {ImageColor3 = AccentColor}); KBL.Text = "..."
                local conn
                conn = UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if inp.UserInputType == Enum.UserInputType.Keyboard then
                        CurrentKey = inp.KeyCode; KBL.Text = KName(CurrentKey)
                        Tween(KBadge, {ImageColor3 = Color3.fromRGB(50, 50, 50)})
                        Listening = false; conn:Disconnect()
                        if Callback then Callback(CurrentKey) end
                    end
                end)
            end)
            UserInputService.InputBegan:Connect(function(inp, gpe)
                if gpe then return end
                if not Listening and inp.KeyCode == CurrentKey then
                    if Callback then Callback(CurrentKey) end
                end
            end)
        end

        -- ── TEXTINFO ─────────────────────────────────────────────────
        function PageLibrary.AddTextInfo(Text)
            local TIC = Frame(); TIC.Name = Text .. "TEXTINFO"; TIC.Size = UDim2.new(1, 0, 0, 20)
            TIC.BackgroundTransparency = 1; TIC.Parent = DisplayPage
            local TIF = RoundBox(5); TIF.ImageColor3 = Color3.fromRGB(28, 28, 32)
            TIF.Size = UDim2.new(1, 0, 1, 0); TIF.Parent = TIC
            local IS = Frame(); IS.BackgroundColor3 = InfoColor; IS.BackgroundTransparency = 0.5
            IS.Size = UDim2.new(0, 2, 0.6, 0); IS.Position = UDim2.new(0, 0, 0.2, 0)
            IS.ZIndex = Level; IS.Parent = TIC; Corner(IS, 2)
            local TIL = TextLabel(Text, 12); TIL.TextXAlignment = Enum.TextXAlignment.Left
            TIL.Position = UDim2.new(0, 8, 0, 0); TIL.Size = UDim2.new(1, -8, 1, 0)
            TIL.TextColor3 = Color3.fromRGB(190, 190, 200); TIL.ZIndex = Level + 1; TIL.Parent = TIC
            local Obj = {}
            function Obj.Set(t) TIL.Text = t or "" end
            return Obj
        end

        -- ── DROPDOWN ─────────────────────────────────────────────────
        function PageLibrary.AddDropdown(Text, ConfigArray, Callback)
            local Arr = ConfigArray or {}; local Toggle = false
            local DC = Frame(); DC.Size = UDim2.new(1, 0, 0, 20); DC.Name = Text .. "DROPDOWN"
            DC.BackgroundTransparency = 1; DC.Parent = DisplayPage
            local DF = RoundBox(5); DF.ClipsDescendants = true; DF.ImageColor3 = Color3.fromRGB(35, 35, 35)
            DF.Size = UDim2.new(1, 0, 1, 0); DF.Parent = DC
            local DE = DropdownIcon(true); DE.Parent = DF
            local DL = TextLabel(Text, 12); DL.Size = UDim2.new(1, 0, 0, 20); DL.Parent = DF
            local DFrame = Frame(); DFrame.Position = UDim2.new(0, 0, 0, 20)
            DFrame.BackgroundTransparency = 1; DFrame.Size = UDim2.new(1, 0, 0, #Arr * 20); DFrame.Parent = DF
            Instance.new("UIListLayout").Parent = DFrame
            for idx, opt in next, Arr do
                PageLibrary.AddButton(opt, function()
                    Callback(opt); DL.Text = Text .. ": " .. opt
                end, DFrame, idx < #Arr)
            end
            DE.MouseButton1Down:Connect(function()
                Toggle = not Toggle
                Tween(DC, {Size = Toggle and UDim2.new(1, 0, 0, 20 + (#Arr * 20)) or UDim2.new(1, 0, 0, 20)})
                Tween(DE, {Rotation = Toggle and 135 or 0})
            end)
        end

        -- ── COLOUR PICKER ────────────────────────────────────────────
        function PageLibrary.AddColourPicker(Text, DefaultColour, Callback)
            DefaultColour = DefaultColour or Color3.fromRGB(255, 255, 255)
            local cd = {white=Color3.fromRGB(255,255,255),black=Color3.fromRGB(0,0,0),
                        red=Color3.fromRGB(255,0,0),green=Color3.fromRGB(0,255,0),blue=Color3.fromRGB(0,0,255)}
            if typeof(DefaultColour) == "table" then
                DefaultColour = Color3.fromRGB(DefaultColour[1] or 255, DefaultColour[2] or 255, DefaultColour[3] or 255)
            elseif typeof(DefaultColour) == "string" then
                DefaultColour = cd[DefaultColour:lower()] or cd["white"]
            end
            local PC = Frame(); PC.ClipsDescendants = true; PC.Size = UDim2.new(1, 0, 0, 20)
            PC.Name = Text .. "COLOURPICKER"; PC.BackgroundTransparency = 1; PC.Parent = DisplayPage
            local CT = Instance.new("Color3Value"); CT.Value = DefaultColour; CT.Parent = PC
            local PL, PR, PF = RoundBox(5), RoundBox(5), RoundBox(5)
            PL.Size = UDim2.new(1,-22,1,0); PL.ImageColor3 = Color3.fromRGB(35,35,35); PL.Parent = PC
            PR.Size = UDim2.new(0,20,1,0); PR.Position = UDim2.new(1,-20,0,0); PR.ImageColor3 = DefaultColour; PR.Parent = PC
            PF.ImageColor3 = Color3.fromRGB(35,35,35); PF.Size = UDim2.new(1,-22,0,60)
            PF.Position = UDim2.new(0,0,0,20); PF.Parent = PC
            local Plist = Instance.new("UIListLayout"); Plist.SortOrder = Enum.SortOrder.LayoutOrder; Plist.Parent = PF
            PageLibrary.AddSlider("R",{Min=0,Max=255,Def=CT.Value.R*255},function(v) CT.Value=Color3.fromRGB(v,CT.Value.G*255,CT.Value.B*255); Callback(CT.Value) end,PF)
            PageLibrary.AddSlider("G",{Min=0,Max=255,Def=CT.Value.G*255},function(v) CT.Value=Color3.fromRGB(CT.Value.R*255,v,CT.Value.B*255); Callback(CT.Value) end,PF)
            PageLibrary.AddSlider("B",{Min=0,Max=255,Def=CT.Value.B*255},function(v) CT.Value=Color3.fromRGB(CT.Value.R*255,CT.Value.G*255,v); Callback(CT.Value) end,PF)
            local EL, ER = Frame(), Frame()
            EL.BackgroundColor3=Color3.fromRGB(35,35,35); EL.Position=UDim2.new(1,-5,0,0); EL.Size=UDim2.new(0,5,1,0); EL.Parent=PL
            ER.BackgroundColor3=DefaultColour; ER.Size=UDim2.new(0,5,1,0); ER.Parent=PR
            TextLabel(Text,12).Parent=PL
            CT:GetPropertyChangedSignal("Value"):Connect(function() ER.BackgroundColor3=CT.Value; PR.ImageColor3=CT.Value end)
            local pt=false; local pb=TextButton(""); pb.Parent=PR
            pb.MouseButton1Down:Connect(function()
                pt = not pt
                Tween(PC, {Size = pt and UDim2.new(1,0,0,80) or UDim2.new(1,0,0,20)})
            end)
        end

        -- ── MULTI-TOGGLE ─────────────────────────────────────────────
        --  Grouped checkbox list under a shared header.
        --  Options = { {Text="Name", Default=false}, ... }
        --  Callback(statesTable) fires whenever any checkbox changes.
        --  statesTable = { Name = true/false, ... }
        function PageLibrary.AddMultiToggle(HeaderText, Options, Callback)
            local States = {}
            local RowHeight = 20
            local TotalHeight = RowHeight + (#Options * RowHeight) + 4

            local MTC = Frame(); MTC.Name = HeaderText .. "MULTITOGGLE"
            MTC.Size = UDim2.new(1, 0, 0, TotalHeight)
            MTC.BackgroundTransparency = 1; MTC.Parent = DisplayPage

            -- Header bar
            local MH = RoundBox(5); MH.ImageColor3 = Color3.fromRGB(40, 40, 40)
            MH.Size = UDim2.new(1, 0, 0, RowHeight); MH.Parent = MTC
            local MHL = TextLabel(HeaderText, 12); MHL.ZIndex = Level + 1; MHL.Parent = MH

            -- Option rows
            for i, opt in ipairs(Options) do
                States[opt.Text] = opt.Default or false
                local Row = Frame(); Row.Name = opt.Text .. "ROW"
                Row.Size = UDim2.new(1, 0, 0, RowHeight)
                Row.Position = UDim2.new(0, 0, 0, RowHeight * i + 4)
                Row.BackgroundTransparency = 1; Row.Parent = MTC

                local RowBG = RoundBox(5); RowBG.ImageColor3 = Color3.fromRGB(35, 35, 35)
                RowBG.Size = UDim2.new(1, 0, 1, 0); RowBG.Parent = Row

                -- Tick box (right side)
                local TickBox = RoundBox(5); TickBox.ImageColor3 = Color3.fromRGB(50, 50, 50)
                TickBox.Size = UDim2.new(0, 16, 0, 16); TickBox.Position = UDim2.new(1, -18, 0.5, -8)
                TickBox.ZIndex = Level + 1; TickBox.Parent = Row
                local Tick = TickIcon(); Tick.ImageTransparency = States[opt.Text] and 0 or 1
                Tick.Parent = TickBox

                -- Colour indicator strip
                local Strip = Frame(); Strip.BackgroundColor3 = States[opt.Text] and SuccessColor or Color3.fromRGB(255, 160, 160)
                Strip.Size = UDim2.new(0, 2, 0.6, 0); Strip.Position = UDim2.new(1, -19, 0.2, 0)
                Strip.ZIndex = Level + 1; Strip.Parent = Row; Corner(Strip, 2)

                local RowLabel = TextLabel(opt.Text, 11); RowLabel.ZIndex = Level + 1; RowLabel.Parent = Row

                -- Config
                local configId = PageTitle .. "_" .. HeaderText .. "_" .. opt.Text .. "_mt"
                ConfigRegistry[configId] = {
                    getter = function() return States[opt.Text] end,
                    setter = function(v)
                        States[opt.Text] = v == true
                        Tick.ImageTransparency = States[opt.Text] and 0 or 1
                        Strip.BackgroundColor3 = States[opt.Text] and SuccessColor or Color3.fromRGB(255, 160, 160)
                        Callback(States)
                    end
                }

                local RBtn = TextButton("", 12); RBtn.ZIndex = Level + 2; RBtn.Parent = Row
                RBtn.MouseButton1Down:Connect(function()
                    States[opt.Text] = not States[opt.Text]
                    Tween(Tick, {ImageTransparency = States[opt.Text] and 0 or 1})
                    Tween(Strip, {BackgroundColor3 = States[opt.Text] and SuccessColor or Color3.fromRGB(255, 160, 160)})
                    Tween(RowBG, {ImageColor3 = Color3.fromRGB(40, 40, 40)})
                    wait(TweenTime)
                    Tween(RowBG, {ImageColor3 = Color3.fromRGB(35, 35, 35)})
                    Callback(States)
                end)
            end
        end

        -- ── PROGRESS BAR ─────────────────────────────────────────────
        --  Read-only visual bar. Returns object with :Set(0-100) and :SetColor(Color3).
        function PageLibrary.AddProgressBar(Text, InitialValue)
            local Val = math.clamp(InitialValue or 0, 0, 100)

            local PBC = Frame(); PBC.Name = Text .. "PROGRESSBAR"; PBC.Size = UDim2.new(1, 0, 0, 20)
            PBC.BackgroundTransparency = 1; PBC.Parent = DisplayPage

            local PBBack = RoundBox(5); PBBack.ImageColor3 = Color3.fromRGB(35, 35, 35)
            PBBack.Size = UDim2.new(1, 0, 1, 0); PBBack.Parent = PBC

            -- Label (left half)
            local PBLabel = TextLabel(Text, 12); PBLabel.ZIndex = Level + 1
            PBLabel.Size = UDim2.new(0.42, 0, 1, 0); PBLabel.Parent = PBC

            -- Track
            local PBTrack = Frame(); PBTrack.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
            PBTrack.Size = UDim2.new(0.55, 0, 0.45, 0); PBTrack.Position = UDim2.new(0.43, 0, 0.275, 0)
            PBTrack.ZIndex = Level + 1; PBTrack.Parent = PBC; Corner(PBTrack, 3)

            -- Fill
            local PBFill = Frame()
            PBFill.BackgroundColor3 = AccentColor
            PBFill.Size = UDim2.new(Val / 100, 0, 1, 0)
            PBFill.ZIndex = Level + 2; PBFill.Parent = PBTrack; Corner(PBFill, 3)
            RegisterAccent(PBFill, "BackgroundColor3")

            -- Percentage label
            local PBPct = Instance.new("TextLabel")
            PBPct.BackgroundTransparency = 1; PBPct.Font = Enum.Font.GothamBold
            PBPct.TextColor3 = Color3.fromRGB(220, 220, 220); PBPct.TextSize = 9
            PBPct.Text = Val .. "%"; PBPct.Size = UDim2.new(1, 0, 1, 0); PBPct.ZIndex = Level + 3
            PBPct.Parent = PBTrack

            local PBObj = {}
            function PBObj.Set(newVal)
                newVal = math.clamp(newVal or 0, 0, 100)
                Val = newVal
                Tween(PBFill, {Size = UDim2.new(Val / 100, 0, 1, 0)}, SlowTweenInfo)
                PBPct.Text = Val .. "%"
            end
            function PBObj.SetColor(col)
                PBFill.BackgroundColor3 = col
            end
            return PBObj
        end

        -- ── STEPPER ──────────────────────────────────────────────────
        --  < Option > arrow-based cycler.
        --  Options = {"Head","Torso","HumanoidRootPart"}
        --  Callback(selectedOption, selectedIndex)
        function PageLibrary.AddStepper(Text, Options, Callback)
            Options = Options or {"None"}
            local Idx = 1

            local STC = Frame(); STC.Name = Text .. "STEPPER"; STC.Size = UDim2.new(1, 0, 0, 20)
            STC.BackgroundTransparency = 1; STC.Parent = DisplayPage

            local STBack = RoundBox(5); STBack.ImageColor3 = Color3.fromRGB(35, 35, 35)
            STBack.Size = UDim2.new(1, 0, 1, 0); STBack.Parent = STC

            -- Label (left ~40%)
            local STLabel = TextLabel(Text, 12); STLabel.ZIndex = Level + 1
            STLabel.Size = UDim2.new(0.4, 0, 1, 0); STLabel.Parent = STC

            -- Left arrow  <
            local LeftBtn = Instance.new("TextButton")
            LeftBtn.BackgroundTransparency = 1; LeftBtn.Font = Enum.Font.GothamBold
            LeftBtn.Text = "<"; LeftBtn.TextColor3 = Color3.fromRGB(180, 180, 180); LeftBtn.TextSize = 14
            LeftBtn.Size = UDim2.new(0, 18, 1, 0); LeftBtn.Position = UDim2.new(0.41, 0, 0, 0)
            LeftBtn.ZIndex = Level + 2; LeftBtn.Parent = STC

            -- Value label (centre of right portion)
            local ValLabel = Instance.new("TextLabel")
            ValLabel.BackgroundTransparency = 1; ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextColor3 = Color3.fromRGB(255, 255, 255); ValLabel.TextSize = 11
            ValLabel.Text = Options[Idx]; ValLabel.TextTruncate = Enum.TextTruncate.AtEnd
            ValLabel.Size = UDim2.new(0.36, 0, 1, 0); ValLabel.Position = UDim2.new(0.44, 18, 0, 0)
            ValLabel.ZIndex = Level + 2; ValLabel.Parent = STC

            -- Right arrow  >
            local RightBtn = Instance.new("TextButton")
            RightBtn.BackgroundTransparency = 1; RightBtn.Font = Enum.Font.GothamBold
            RightBtn.Text = ">"; RightBtn.TextColor3 = Color3.fromRGB(180, 180, 180); RightBtn.TextSize = 14
            RightBtn.Size = UDim2.new(0, 18, 1, 0); RightBtn.Position = UDim2.new(1, -18, 0, 0)
            RightBtn.ZIndex = Level + 2; RightBtn.Parent = STC

            -- Config
            local configId = PageTitle .. "_" .. Text .. "_stepper"
            ConfigRegistry[configId] = {
                getter = function() return Idx end,
                setter = function(v)
                    Idx = math.clamp(v, 1, #Options)
                    ValLabel.Text = Options[Idx]
                    Callback(Options[Idx], Idx)
                end
            }

            local function Step(dir)
                Idx = ((Idx - 1 + dir) % #Options) + 1
                -- Fade label during transition
                Tween(ValLabel, {TextTransparency = 1}, GlobalTweenInfo)
                task.delay(TweenTime, function()
                    ValLabel.Text = Options[Idx]
                    Tween(ValLabel, {TextTransparency = 0}, GlobalTweenInfo)
                end)
                Tween(STBack, {ImageColor3 = Color3.fromRGB(42, 42, 42)})
                wait(TweenTime)
                Tween(STBack, {ImageColor3 = Color3.fromRGB(35, 35, 35)})
                Callback(Options[Idx], Idx)
            end

            LeftBtn.MouseButton1Click:Connect(function() Step(-1) end)
            RightBtn.MouseButton1Click:Connect(function() Step(1) end)

            -- Arrow hover tints
            LeftBtn.MouseEnter:Connect(function()
                Tween(LeftBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)})
            end)
            LeftBtn.MouseLeave:Connect(function()
                Tween(LeftBtn, {TextColor3 = Color3.fromRGB(180, 180, 180)})
            end)
            RightBtn.MouseEnter:Connect(function()
                Tween(RightBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)})
            end)
            RightBtn.MouseLeave:Connect(function()
                Tween(RightBtn, {TextColor3 = Color3.fromRGB(180, 180, 180)})
            end)
        end

        return PageLibrary
    end

    TabLibrary.Notify         = UILibrary.Notify
    TabLibrary.SaveConfig     = UILibrary.SaveConfig
    TabLibrary.LoadConfig     = UILibrary.LoadConfig
    TabLibrary.SetAccentColor = UILibrary.SetAccentColor
    TabLibrary.SetWatermark   = UILibrary.SetWatermark

    return TabLibrary
end

return UILibrary
