--[[
    ███████╗███████╗███╗   ██╗    ██╗    ██╗ █████╗ ██████╗ ███████╗
    ╚══███╔╝██╔════╝████╗  ██║    ██║    ██║██╔══██╗██╔══██╗██╔════╝
      ███╔╝ █████╗  ██╔██╗ ██║    ██║ █╗ ██║███████║██████╔╝█████╗  
     ███╔╝  ██╔══╝  ██║╚██╗██║    ██║███╗██║██╔══██║██╔══██╗██╔══╝  
    ███████╗███████╗██║ ╚████║    ╚███╔███╔╝██║  ██║██║  ██║███████╗
    ╚══════╝╚══════╝╚═╝  ╚═══╝     ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝

    Zen-Ware UI Library  v0.0.3 (Updated from v1.0.0)
    ─────────────────────────────────────────────────────────
    All original features preserved + v0.0.3 upgrades added
--]]
-- ================================================================
--  SERVICES & GLOBALS
-- ================================================================
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGuiService = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local TweenTime = 0.15
local Level = 1

local GlobalTweenInfo = TweenInfo.new(TweenTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local SlowTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local FastTweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local DropShadowID = "rbxassetid://297774371"
local DropShadowTransparency = 0.3
local IconLibraryID = "rbxassetid://3926305904"
local IconLibraryID2 = "rbxassetid://3926307971"
local MainFont = Enum.Font.Gotham

-- ================================================================
--  THEME SYSTEM
-- ================================================================
local Themes = {
    Zen = {
        Name = "Zen",
        Accent = Color3.fromRGB(85, 190, 165),
        AccentDark = Color3.fromRGB(60, 150, 130),
        AccentLight = Color3.fromRGB(110, 220, 190),
        Background = Color3.fromRGB(12, 14, 16),
        BackgroundLight = Color3.fromRGB(18, 21, 24),
        BackgroundDark = Color3.fromRGB(8, 10, 12),
        Card = Color3.fromRGB(20, 24, 28),
        CardHover = Color3.fromRGB(28, 32, 36),
        Text = Color3.fromRGB(240, 242, 245),
        TextSecondary = Color3.fromRGB(170, 175, 185),
        TextDim = Color3.fromRGB(120, 125, 135),
        Success = Color3.fromRGB(72, 199, 142),
        Error = Color3.fromRGB(244, 67, 84),
        Info = Color3.fromRGB(100, 180, 255),
        Warn = Color3.fromRGB(255, 193, 80),
        Border = Color3.fromRGB(35, 40, 45),
        Divider = Color3.fromRGB(30, 35, 40)
    },
    Ocean = {
        Name = "Ocean",
        Accent = Color3.fromRGB(70, 150, 240),
        AccentDark = Color3.fromRGB(50, 120, 200),
        AccentLight = Color3.fromRGB(100, 180, 255),
        Background = Color3.fromRGB(10, 12, 18),
        BackgroundLight = Color3.fromRGB(16, 20, 28),
        BackgroundDark = Color3.fromRGB(6, 8, 12),
        Card = Color3.fromRGB(18, 22, 32),
        CardHover = Color3.fromRGB(24, 30, 42),
        Text = Color3.fromRGB(235, 240, 250),
        TextSecondary = Color3.fromRGB(160, 170, 190),
        TextDim = Color3.fromRGB(110, 120, 140),
        Success = Color3.fromRGB(72, 199, 142),
        Error = Color3.fromRGB(244, 67, 84),
        Info = Color3.fromRGB(100, 180, 255),
        Warn = Color3.fromRGB(255, 193, 80),
        Border = Color3.fromRGB(30, 40, 55),
        Divider = Color3.fromRGB(25, 35, 50)
    },
    Forest = {
        Name = "Forest",
        Accent = Color3.fromRGB(110, 200, 130),
        AccentDark = Color3.fromRGB(80, 160, 100),
        AccentLight = Color3.fromRGB(140, 230, 160),
        Background = Color3.fromRGB(12, 15, 13),
        BackgroundLight = Color3.fromRGB(18, 23, 20),
        BackgroundDark = Color3.fromRGB(8, 10, 9),
        Card = Color3.fromRGB(20, 26, 23),
        CardHover = Color3.fromRGB(28, 35, 30),
        Text = Color3.fromRGB(240, 245, 242),
        TextSecondary = Color3.fromRGB(170, 185, 175),
        TextDim = Color3.fromRGB(120, 135, 125),
        Success = Color3.fromRGB(72, 199, 142),
        Error = Color3.fromRGB(244, 67, 84),
        Info = Color3.fromRGB(100, 180, 255),
        Warn = Color3.fromRGB(255, 193, 80),
        Border = Color3.fromRGB(35, 45, 40),
        Divider = Color3.fromRGB(30, 40, 35)
    },
    Sunset = {
        Name = "Sunset",
        Accent = Color3.fromRGB(255, 130, 100),
        AccentDark = Color3.fromRGB(220, 100, 70),
        AccentLight = Color3.fromRGB(255, 160, 130),
        Background = Color3.fromRGB(15, 12, 14),
        BackgroundLight = Color3.fromRGB(22, 18, 21),
        BackgroundDark = Color3.fromRGB(10, 8, 10),
        Card = Color3.fromRGB(26, 21, 24),
        CardHover = Color3.fromRGB(34, 28, 32),
        Text = Color3.fromRGB(245, 240, 242),
        TextSecondary = Color3.fromRGB(185, 170, 175),
        TextDim = Color3.fromRGB(135, 120, 125),
        Success = Color3.fromRGB(72, 199, 142),
        Error = Color3.fromRGB(244, 67, 84),
        Info = Color3.fromRGB(100, 180, 255),
        Warn = Color3.fromRGB(255, 193, 80),
        Border = Color3.fromRGB(45, 35, 40),
        Divider = Color3.fromRGB(40, 30, 35)
    },
    -- New in v0.0.3
    Midnight = {
        Name = "Midnight",
        Accent = Color3.fromRGB(138, 99, 255),
        AccentDark = Color3.fromRGB(108, 69, 225),
        AccentLight = Color3.fromRGB(168, 129, 255),
        Background = Color3.fromRGB(8, 8, 12),
        BackgroundLight = Color3.fromRGB(14, 14, 20),
        BackgroundDark = Color3.fromRGB(4, 4, 8),
        Card = Color3.fromRGB(16, 16, 24),
        CardHover = Color3.fromRGB(22, 22, 32),
        Text = Color3.fromRGB(240, 240, 250),
        TextSecondary = Color3.fromRGB(165, 165, 185),
        TextDim = Color3.fromRGB(115, 115, 135),
        Success = Color3.fromRGB(72, 199, 142),
        Error = Color3.fromRGB(244, 67, 84),
        Info = Color3.fromRGB(100, 180, 255),
        Warn = Color3.fromRGB(255, 193, 80),
        Border = Color3.fromRGB(30, 30, 45),
        Divider = Color3.fromRGB(25, 25, 40)
    }
}

local CurrentTheme = Themes.Zen
local ZenWareFlags = {}

local ZenWareConfig = {
    SaveConfig = false,
    ConfigName = "ZenWareConfig",
    GhostMode = false,
    PerformanceMode = false, -- v0.0.3
    CompactMode = false -- v0.0.3
}

-- ================================================================
--  UTILITY FUNCTIONS
-- ================================================================
local function GenerateRandomName()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local name = ""
    for i = 1, 16 do
        name = name .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return name
end

local function GetGUIName(baseName)
    return ZenWareConfig.GhostMode and GenerateRandomName() or baseName
end

local function SaveConfig()
    if not ZenWareConfig.SaveConfig then
        return
    end
    pcall(
        function()
            writefile(ZenWareConfig.ConfigName .. ".json", HttpService:JSONEncode(ZenWareFlags))
        end
    )
end

local function LoadConfig()
    if not ZenWareConfig.SaveConfig then
        return
    end
    pcall(
        function()
            local content = readfile(ZenWareConfig.ConfigName .. ".json")
            local decoded = HttpService:JSONDecode(content)
            for flag, value in pairs(decoded) do
                ZenWareFlags[flag] = value
            end
        end
    )
end

local function SetFlag(flag, value)
    ZenWareFlags[flag] = value
    SaveConfig()
end

local function GetFlag(flag, default)
    return ZenWareFlags[flag] ~= nil and ZenWareFlags[flag] or default
end

-- v0.0.3 Config Import/Export
local function ExportConfigString()
    return HttpService:EncodeBase64(HttpService:JSONEncode(ZenWareFlags))
end

local function ImportConfigString(configString)
    return pcall(
        function()
            local decoded = HttpService:DecodeBase64(configString)
            local config = HttpService:JSONDecode(decoded)
            for flag, value in pairs(config) do
                ZenWareFlags[flag] = value
            end
            SaveConfig()
        end
    )
end

-- v0.0.3 Performance-aware Tween
local function Tween(obj, props, info)
    if ZenWareConfig.PerformanceMode and info == SlowTweenInfo then
        info = FastTweenInfo
    end
    local t = TweenService:Create(obj, info or GlobalTweenInfo, props)
    t:Play()
    return t
end

-- ================================================================
--  CONSTRUCTOR HELPERS (unchanged from original)
-- ================================================================
local function GetXY(obj)
    local X = math.clamp(Mouse.X - obj.AbsolutePosition.X, 0, obj.AbsoluteSize.X)
    local Y = math.clamp(Mouse.Y - obj.AbsolutePosition.Y, 0, obj.AbsoluteSize.Y)
    return X, Y, X / obj.AbsoluteSize.X, Y / obj.AbsoluteSize.Y
end

local function TickIcon(btn)
    local i = Instance.new(btn and "ImageButton" or "ImageLabel")
    i.Name = "TickIcon"
    i.BackgroundTransparency = 1
    i.Image = "rbxassetid://3926305904"
    i.ImageRectOffset = Vector2.new(312, 4)
    i.ImageRectSize = Vector2.new(24, 24)
    i.Size = UDim2.new(1, -6, 1, -6)
    i.Position = UDim2.new(0, 3, 0, 3)
    i.ZIndex = Level
    return i
end

local function DropdownIcon(btn)
    local i = Instance.new(btn and "ImageButton" or "ImageLabel")
    i.Name = "DropdownIcon"
    i.BackgroundTransparency = 1
    i.Image = IconLibraryID2
    i.ImageRectOffset = Vector2.new(324, 364)
    i.ImageRectSize = Vector2.new(36, 36)
    i.Size = UDim2.new(0, 16, 0, 16)
    i.Position = UDim2.new(1, -18, 0, 2)
    i.ZIndex = Level
    return i
end

local function SearchIcon()
    local i = Instance.new("ImageLabel")
    i.Name = "SearchIcon"
    i.BackgroundTransparency = 1
    i.Image = IconLibraryID
    i.ImageRectOffset = Vector2.new(964, 324)
    i.ImageRectSize = Vector2.new(36, 36)
    i.Size = UDim2.new(0, 16, 0, 16)
    i.Position = UDim2.new(0, 2, 0, 2)
    i.ZIndex = Level
    return i
end

local function RoundBox(r, btn)
    local i = Instance.new(btn and "ImageButton" or "ImageLabel")
    i.BackgroundTransparency = 1
    i.Image = "rbxassetid://3570695787"
    i.SliceCenter = Rect.new(100, 100, 100, 100)
    i.SliceScale = math.clamp((r or 5) * 0.01, 0.01, 1)
    i.ScaleType = Enum.ScaleType.Slice
    i.ZIndex = Level
    return i
end

local function MakeDropShadow()
    local i = Instance.new("ImageLabel")
    i.Name = "DropShadow"
    i.BackgroundTransparency = 1
    i.Image = DropShadowID
    i.ImageTransparency = DropShadowTransparency
    i.Size = UDim2.new(1, 0, 1, 0)
    i.ZIndex = Level
    return i
end

local function Frame()
    local i = Instance.new("Frame")
    i.BorderSizePixel = 0
    i.ZIndex = Level
    return i
end
local function ScrollingFrame()
    local i = Instance.new("ScrollingFrame")
    i.BackgroundTransparency = 1
    i.BorderSizePixel = 0
    i.ScrollBarThickness = 0
    i.ZIndex = Level
    return i
end

local function TextButton(txt, sz)
    local i = Instance.new("TextButton")
    i.Text = txt
    i.AutoButtonColor = false
    i.Font = MainFont
    i.TextColor3 = CurrentTheme.Text
    i.BackgroundTransparency = 1
    i.TextSize = sz or 12
    i.Size = UDim2.new(1, 0, 1, 0)
    i.ZIndex = Level
    return i
end

local function TextBox(txt, sz)
    local i = Instance.new("TextBox")
    i.Text = txt
    i.Font = MainFont
    i.TextColor3 = CurrentTheme.Text
    i.BackgroundTransparency = 1
    i.TextSize = sz or 12
    i.Size = UDim2.new(1, 0, 1, 0)
    i.ZIndex = Level
    i.PlaceholderColor3 = CurrentTheme.TextDim
    return i
end

local function TextLabel(txt, sz)
    local i = Instance.new("TextLabel")
    i.Text = txt
    i.Font = MainFont
    i.TextColor3 = CurrentTheme.Text
    i.BackgroundTransparency = 1
    i.TextSize = sz or 12
    i.Size = UDim2.new(1, 0, 1, 0)
    i.ZIndex = Level
    return i
end

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 5)
    c.Parent = parent
    return c
end

-- ================================================================
--  NOTIFICATION SYSTEM (unchanged)
-- ================================================================
local NotificationContainer
local function CreateNotificationSystem()
    local NG = Instance.new("ScreenGui")
    NG.Name = GetGUIName("ZenWareNotifications")
    NG.ResetOnSpawn = false
    NG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local NC = Frame()
    NC.Name = "NotificationContainer"
    NC.Size = UDim2.new(0, 320, 1, -20)
    NC.Position = UDim2.new(1, -330, 0, 10)
    NC.BackgroundTransparency = 1
    NC.Parent = NG

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.VerticalAlignment = Enum.VerticalAlignment.Top
    Layout.Parent = NC

    NG.Parent = CoreGuiService
    NotificationContainer = NC
    return NG
end

local function Notify(Title, Text, Type, Duration)
    if not NotificationContainer then
        CreateNotificationSystem()
    end
    Type = Type or "info"
    Duration = Duration or 3

    local ColorMap = {
        success = CurrentTheme.Success,
        error = CurrentTheme.Error,
        info = CurrentTheme.Info,
        warn = CurrentTheme.Warn
    }
    local NotifColor = ColorMap[Type:lower()] or CurrentTheme.Info

    local NF = Frame()
    NF.Size = UDim2.new(1, 0, 0, 0)
    NF.BackgroundColor3 = CurrentTheme.Card
    NF.ClipsDescendants = true
    NF.ZIndex = 1500
    NF.Parent = NotificationContainer
    Corner(NF, 6)

    local AccentBar = Frame()
    AccentBar.Size = UDim2.new(0, 3, 1, 0)
    AccentBar.BackgroundColor3 = NotifColor
    AccentBar.ZIndex = 1501
    AccentBar.Parent = NF

    local TitleLabel = TextLabel(Title, 13)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Position = UDim2.new(0, 12, 0, 6)
    TitleLabel.Size = UDim2.new(1, -24, 0, 16)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextColor3 = CurrentTheme.Text
    TitleLabel.ZIndex = 1501
    TitleLabel.Parent = NF

    local TextLabel2 = TextLabel(Text, 11)
    TextLabel2.Position = UDim2.new(0, 12, 0, 24)
    TextLabel2.Size = UDim2.new(1, -24, 1, -30)
    TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
    TextLabel2.TextWrapped = true
    TextLabel2.TextColor3 = CurrentTheme.TextSecondary
    TextLabel2.ZIndex = 1501
    TextLabel2.Parent = NF

    local textBounds = TextService:GetTextSize(Text, 11, MainFont, Vector2.new(296, 1000))
    local totalHeight = math.max(50, 36 + textBounds.Y)

    Tween(NF, {Size = UDim2.new(1, 0, 0, totalHeight)}, SlowTweenInfo)

    task.delay(
        Duration,
        function()
            Tween(NF, {Size = UDim2.new(1, 0, 0, 0)}, SlowTweenInfo)
            task.wait(0.35)
            NF:Destroy()
        end
    )
end

-- ================================================================
--  MAIN UI LIBRARY
-- ================================================================
local UILibrary = {}

function UILibrary.Load(Title, GameName, Version, Options)
    Options = Options or {}
    local Letter = Options.Letter
    local Image = Options.Image
    local ThemeName = Options.Theme or "Zen"

    CurrentTheme = Themes[ThemeName] or Themes.Zen

    ZenWareConfig.SaveConfig = Options.SaveConfig == true
    ZenWareConfig.ConfigName = Options.ConfigName or "ZenWareConfig_" .. GameName:gsub("%s+", "")
    ZenWareConfig.GhostMode = Options.GhostMode == true
    ZenWareConfig.PerformanceMode = Options.PerformanceMode == true
    ZenWareConfig.CompactMode = Options.CompactMode == true

    if ZenWareConfig.SaveConfig then
        LoadConfig()
    end

    local TabLibrary = {Pages = {}}

    -- Main GUI Container
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = GetGUIName("ZenWareUI")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = RoundBox(8)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
    MainFrame.ImageColor3 = CurrentTheme.Background
    MainFrame.ZIndex = 1
    MainFrame.Parent = ScreenGui

    MakeDropShadow().Parent = MainFrame

    -- Top Bar
    local TopBar = Frame()
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 28)
    TopBar.BackgroundColor3 = CurrentTheme.BackgroundDark
    TopBar.ZIndex = 2
    TopBar.Parent = MainFrame
    Corner(TopBar, 8)

    local TitleLabel = TextLabel(Title, 13)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.Size = UDim2.new(0, 150, 1, 0)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextColor3 = CurrentTheme.Accent
    TitleLabel.ZIndex = 3
    TitleLabel.Parent = TopBar

    local GameLabel = TextLabel(GameName, 11)
    GameLabel.Position = UDim2.new(0, 165, 0, 0)
    GameLabel.Size = UDim2.new(0, 200, 1, 0)
    GameLabel.TextXAlignment = Enum.TextXAlignment.Left
    GameLabel.TextColor3 = CurrentTheme.TextSecondary
    GameLabel.ZIndex = 3
    GameLabel.Parent = TopBar

    local VersionLabel = TextLabel(Version, 10)
    VersionLabel.Position = UDim2.new(1, -80, 0, 0)
    VersionLabel.Size = UDim2.new(0, 70, 1, 0)
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
    VersionLabel.TextColor3 = CurrentTheme.TextDim
    VersionLabel.ZIndex = 3
    VersionLabel.Parent = TopBar

    -- v0.0.3 Minimize Button
    local MinimizeBtn = TextButton("−", 18)
    MinimizeBtn.Position = UDim2.new(1, -35, 0, 0)
    MinimizeBtn.Size = UDim2.new(0, 30, 1, 0)
    MinimizeBtn.TextColor3 = CurrentTheme.TextSecondary
    MinimizeBtn.ZIndex = 3
    MinimizeBtn.Parent = TopBar

    local TopBarBottom = Frame()
    TopBarBottom.Size = UDim2.new(1, 0, 0, 8)
    TopBarBottom.Position = UDim2.new(0, 0, 1, -8)
    TopBarBottom.BackgroundColor3 = CurrentTheme.BackgroundDark
    TopBarBottom.ZIndex = 2
    TopBarBottom.Parent = TopBar

    -- v0.0.3 Compact Widget
    local CompactWidget = RoundBox(50)
    CompactWidget.Name = "CompactWidget"
    CompactWidget.Size = UDim2.new(0, 50, 0, 50)
    CompactWidget.Position = UDim2.new(1, -60, 1, -60)
    CompactWidget.ImageColor3 = CurrentTheme.Accent
    CompactWidget.Visible = ZenWareConfig.CompactMode
    CompactWidget.ZIndex = 1000
    CompactWidget.Parent = ScreenGui

    local CompactText = TextLabel(Letter or "Z", 20)
    CompactText.Font = Enum.Font.GothamBold
    CompactText.TextColor3 = Color3.fromRGB(255, 255, 255)
    CompactText.Parent = CompactWidget

    local CompactBtn = TextButton("", 20)
    CompactBtn.ZIndex = 1001
    CompactBtn.Parent = CompactWidget

    CompactBtn.MouseButton1Click:Connect(
        function()
            CompactWidget.Visible = false
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 550, 0, 380)}, SlowTweenInfo)
        end
    )

    if ZenWareConfig.CompactMode then
        MainFrame.Visible = false
    end

    -- Sidebar & Content Area
    local Sidebar = Frame()
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 110, 1, -28)
    Sidebar.Position = UDim2.new(0, 0, 0, 28)
    Sidebar.BackgroundColor3 = CurrentTheme.BackgroundLight
    Sidebar.ZIndex = 2
    Sidebar.Parent = MainFrame
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 2)

    local ContentArea = Frame()
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -110, 1, -28)
    ContentArea.Position = UDim2.new(0, 110, 0, 28)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ZIndex = 2
    ContentArea.Parent = MainFrame

    -- Dragging
    local Dragging, DragStart, StartPos
    TopBar.InputBegan:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                DragStart = input.Position
                StartPos = MainFrame.Position
            end
        end
    )
    UserInputService.InputChanged:Connect(
        function(input)
            if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - DragStart
                MainFrame.Position =
                    UDim2.new(
                    StartPos.X.Scale,
                    StartPos.X.Offset + delta.X,
                    StartPos.Y.Scale,
                    StartPos.Y.Offset + delta.Y
                )
            end
        end
    )
    UserInputService.InputEnded:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = false
            end
        end
    )

    ScreenGui.Parent = CoreGuiService

    -- Roblox TopBar Button
    if Letter or Image then
        pcall(
            function()
                local tb = CoreGuiService:WaitForChild("TopBarApp", 2)
                if tb then
                    local left = tb:WaitForChild("TopBarFrame", 2):WaitForChild("LeftFrame", 2)
                    if left then
                        local btn = Instance.new("ImageButton")
                        btn.Name = GetGUIName("ZenWareToggle")
                        btn.Size = UDim2.new(0, 32, 0, 32)
                        btn.BackgroundColor3 = CurrentTheme.Accent
                        btn.ZIndex = 5
                        Corner(btn, 6)
                        btn.Parent = left
                        if Image then
                            btn.Image = Image
                        else
                            local lbl = TextLabel(Letter or "Z", 18)
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextColor3 = Color3.new(1, 1, 1)
                            lbl.Parent = btn
                        end
                        btn.MouseButton1Click:Connect(
                            function()
                                MainFrame.Visible = not MainFrame.Visible
                            end
                        )
                    end
                end
            end
        )
    end

    -- RightShift Toggle
    UserInputService.InputBegan:Connect(
        function(input, gp)
            if not gp and input.KeyCode == Enum.KeyCode.RightShift then
                MainFrame.Visible = not MainFrame.Visible
            end
        end
    )

    -- Minimize Button
    MinimizeBtn.MouseButton1Click:Connect(
        function()
            Tween(MainFrame, {Size = UDim2.new(0, 550, 0, 0)}, SlowTweenInfo)
            task.wait(0.35)
            MainFrame.Visible = false
            CompactWidget.Visible = true
        end
    )

    TabLibrary.Notify = Notify
    UILibrary.Notify = Notify

    function TabLibrary.SetTheme(themeName)
        local nt = Themes[themeName]
        if not nt then
            return
        end
        CurrentTheme = nt
        MainFrame.ImageColor3 = nt.Background
        TopBar.BackgroundColor3 = nt.BackgroundDark
        TopBarBottom.BackgroundColor3 = nt.BackgroundDark
        Sidebar.BackgroundColor3 = nt.BackgroundLight
        TitleLabel.TextColor3 = nt.Accent
        GameLabel.TextColor3 = nt.TextSecondary
        VersionLabel.TextColor3 = nt.TextDim
        CompactWidget.ImageColor3 = nt.Accent
        Notify("Theme Changed", "Now using " .. nt.Name .. " theme", "info", 2)
    end
    UILibrary.SetTheme = TabLibrary.SetTheme

    -- v0.0.3 Compact Mode
    function TabLibrary.SetCompactMode(enabled)
        if enabled then
            Tween(MainFrame, {Size = UDim2.new(0, 550, 0, 0)}, SlowTweenInfo)
            task.wait(0.35)
            MainFrame.Visible = false
            CompactWidget.Visible = true
        else
            CompactWidget.Visible = false
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 550, 0, 380)}, SlowTweenInfo)
        end
    end
    UILibrary.SetCompactMode = TabLibrary.SetCompactMode

    function TabLibrary.ExportConfig()
        return ExportConfigString()
    end
    UILibrary.ExportConfig = TabLibrary.ExportConfig

    function TabLibrary.ImportConfig(str)
        local s = ImportConfigString(str)
        if s then
            Notify("Config Imported", "Configuration loaded successfully!", "success", 3)
        else
            Notify("Import Failed", "Invalid configuration string", "error", 3)
        end
        return s
    end
    UILibrary.ImportConfig = TabLibrary.ImportConfig

    -- AddPage
    function TabLibrary.AddPage(PageName, HasSearch)
        HasSearch = HasSearch == nil and true or HasSearch
        local PageLibrary = {}
        local IsPageActive = #TabLibrary.Pages == 0

        -- Tab Button
        local TabButton = Frame()
        TabButton.Size = UDim2.new(1, 0, 0, 34)
        TabButton.BackgroundTransparency = 1
        TabButton.ZIndex = 3
        TabButton.Parent = Sidebar

        local TabBG = RoundBox(5)
        TabBG.Size = UDim2.new(1, -6, 1, 0)
        TabBG.Position = UDim2.new(0, 3, 0, 0)
        TabBG.ImageColor3 = IsPageActive and CurrentTheme.Card or Color3.fromRGB(0, 0, 0)
        TabBG.ImageTransparency = IsPageActive and 0 or 1
        TabBG.ZIndex = 3
        TabBG.Parent = TabButton

        local ActiveStrip = Frame()
        ActiveStrip.Size = UDim2.new(0, 2, 0.7, 0)
        ActiveStrip.Position = UDim2.new(0, 0, 0.15, 0)
        ActiveStrip.BackgroundColor3 = CurrentTheme.Accent
        ActiveStrip.BackgroundTransparency = IsPageActive and 0 or 1
        ActiveStrip.ZIndex = 4
        ActiveStrip.Parent = TabButton
        Corner(ActiveStrip, 2)

        local TabLabel = TextLabel(PageName, 12)
        TabLabel.Size = UDim2.new(1, -10, 1, 0)
        TabLabel.Position = UDim2.new(0, 10, 0, 0)
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.TextColor3 = IsPageActive and CurrentTheme.Text or CurrentTheme.TextDim
        TabLabel.ZIndex = 4
        TabLabel.Parent = TabButton

        local TabBtn = TextButton("", 12)
        TabBtn.ZIndex = 4
        TabBtn.Parent = TabButton

        -- Page Frame
        local PageFrame = ScrollingFrame()
        PageFrame.Name = PageName .. "Page"
        PageFrame.Size = UDim2.new(1, -12, 1, HasSearch and -38 or -6)
        PageFrame.Position = UDim2.new(0, 6, 0, HasSearch and 32 or 0)
        PageFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        PageFrame.Visible = IsPageActive
        PageFrame.ZIndex = 3
        PageFrame.Parent = ContentArea

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 4)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = PageFrame

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
            function()
                PageFrame.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 4)
            end
        )

        local PageSearchFrame = nil
        if HasSearch then
            local SearchFrame = Frame()
            SearchFrame.Size = UDim2.new(1, -12, 0, 26)
            SearchFrame.Position = UDim2.new(0, 6, 0, 0)
            SearchFrame.BackgroundColor3 = CurrentTheme.Card
            SearchFrame.ZIndex = 3
            SearchFrame.Visible = IsPageActive
            SearchFrame.Parent = ContentArea
            Corner(SearchFrame, 5)

            SearchIcon().Parent = SearchFrame

            local SearchBox = TextBox("", 11)
            SearchBox.PlaceholderText = "Search..."
            SearchBox.Position = UDim2.new(0, 22, 0, 0)
            SearchBox.Size = UDim2.new(1, -26, 1, 0)
            SearchBox.ZIndex = 4
            SearchBox.Parent = SearchFrame

            SearchBox:GetPropertyChangedSignal("Text"):Connect(
                function()
                    local q = SearchBox.Text:lower()
                    for _, c in ipairs(PageFrame:GetChildren()) do
                        if c:IsA("GuiObject") and c.Name ~= "UIListLayout" then
                            c.Visible = q == "" or c.Name:lower():find(q)
                        end
                    end
                end
            )
            PageSearchFrame = SearchFrame
        end

        -- Tab Switching
        TabBtn.MouseButton1Click:Connect(
            function()
                for _, p in ipairs(TabLibrary.Pages) do
                    p.Frame.Visible = false
                    if p.SearchFrame then
                        p.SearchFrame.Visible = false
                    end
                    Tween(p.TabBG, {ImageTransparency = 1}, FastTweenInfo)
                    Tween(p.TabLabel, {TextColor3 = CurrentTheme.TextDim}, FastTweenInfo)
                    Tween(p.ActiveStrip, {BackgroundTransparency = 1}, FastTweenInfo)
                end
                PageFrame.Visible = true
                if PageSearchFrame then
                    PageSearchFrame.Visible = true
                end
                Tween(TabBG, {ImageTransparency = 0, ImageColor3 = CurrentTheme.Card}, GlobalTweenInfo)
                Tween(TabLabel, {TextColor3 = CurrentTheme.Text}, GlobalTweenInfo)
                Tween(ActiveStrip, {BackgroundTransparency = 0}, GlobalTweenInfo)
            end
        )

        table.insert(
            TabLibrary.Pages,
            {
                Frame = PageFrame,
                SearchFrame = PageSearchFrame,
                TabBG = TabBG,
                TabLabel = TabLabel,
                ActiveStrip = ActiveStrip
            }
        )

        local DisplayPage = PageFrame

        -- ==================== ORIGINAL ELEMENTS (fully preserved) ====================

        function PageLibrary.AddLabel(Text)
            local LC = Frame()
            LC.Name = Text .. "LABEL"
            LC.Size = UDim2.new(1, 0, 0, 18)
            LC.BackgroundTransparency = 1
            LC.Parent = DisplayPage
            local LL = TextLabel(Text, 12)
            LL.TextXAlignment = Enum.TextXAlignment.Left
            LL.Position = UDim2.new(0, 6, 0, 0)
            LL.TextColor3 = CurrentTheme.TextSecondary
            LL.Parent = LC
        end

        function PageLibrary.AddSection(Text)
            local SC = Frame()
            SC.Name = Text .. "SECTION"
            SC.Size = UDim2.new(1, 0, 0, 24)
            SC.BackgroundTransparency = 1
            SC.Parent = DisplayPage
            local SL = TextLabel(Text, 13)
            SL.Font = Enum.Font.GothamBold
            SL.TextXAlignment = Enum.TextXAlignment.Left
            SL.Position = UDim2.new(0, 6, 0, 4)
            SL.TextColor3 = CurrentTheme.Accent
            SL.Parent = SC
            local Underline = Frame()
            Underline.Size = UDim2.new(1, -6, 0, 1)
            Underline.Position = UDim2.new(0, 3, 1, -2)
            Underline.BackgroundColor3 = CurrentTheme.Divider
            Underline.Parent = SC
        end

        function PageLibrary.AddDivider()
            local Div = Frame()
            Div.Name = "DIVIDER"
            Div.Size = UDim2.new(1, -12, 0, 1)
            Div.Position = UDim2.new(0, 6, 0, 0)
            Div.BackgroundColor3 = CurrentTheme.Divider
            Div.Parent = DisplayPage
            local Spacer = Frame()
            Spacer.Size = UDim2.new(1, 0, 0, 6)
            Spacer.BackgroundTransparency = 1
            Spacer.Parent = DisplayPage
        end

        function PageLibrary.AddParagraph(Title, Text)
            local PC = Frame()
            PC.Name = Title .. "PARAGRAPH"
            PC.BackgroundTransparency = 1
            PC.Parent = DisplayPage
            local PTitle = TextLabel(Title, 12)
            PTitle.Font = Enum.Font.GothamBold
            PTitle.TextXAlignment = Enum.TextXAlignment.Left
            PTitle.Position = UDim2.new(0, 6, 0, 0)
            PTitle.Size = UDim2.new(1, -12, 0, 16)
            PTitle.TextColor3 = CurrentTheme.Text
            PTitle.Parent = PC
            local PText = TextLabel(Text, 11)
            PText.TextXAlignment = Enum.TextXAlignment.Left
            PText.TextYAlignment = Enum.TextYAlignment.Top
            PText.TextWrapped = true
            PText.Position = UDim2.new(0, 6, 0, 18)
            PText.TextColor3 = CurrentTheme.TextSecondary
            PText.Parent = PC
            local tb = TextService:GetTextSize(Text, 11, MainFont, Vector2.new(DisplayPage.AbsoluteSize.X - 12, 1000))
            local h = 22 + tb.Y
            PC.Size = UDim2.new(1, 0, 0, h)
            PText.Size = UDim2.new(1, -12, 0, tb.Y + 4)
        end

        function PageLibrary.AddButton(Text, Callback, Parent, NoDivider)
            Parent = Parent or DisplayPage
            local BC = Frame()
            BC.Name = Text .. "BUTTON"
            BC.Size = UDim2.new(1, 0, 0, 28)
            BC.BackgroundTransparency = 1
            BC.Parent = Parent
            local BF = RoundBox(5)
            BF.ImageColor3 = CurrentTheme.Card
            BF.Parent = BC
            local BL = TextLabel(Text, 12)
            BL.Parent = BF
            local BB = TextButton("", 12)
            BB.ZIndex = Level + 1
            BB.Parent = BF
            BB.MouseEnter:Connect(
                function()
                    Tween(BF, {ImageColor3 = CurrentTheme.CardHover}, FastTweenInfo)
                end
            )
            BB.MouseLeave:Connect(
                function()
                    Tween(BF, {ImageColor3 = CurrentTheme.Card}, FastTweenInfo)
                end
            )
            BB.MouseButton1Click:Connect(
                function()
                    Tween(BF, {ImageColor3 = CurrentTheme.BackgroundDark}, FastTweenInfo)
                    task.wait(0.1)
                    Tween(BF, {ImageColor3 = CurrentTheme.Card}, FastTweenInfo)
                    if Callback then
                        pcall(Callback)
                    end
                end
            )
            if not NoDivider and Parent == DisplayPage then
                local sp = Frame()
                sp.Size = UDim2.new(1, 0, 0, 2)
                sp.BackgroundTransparency = 1
                sp.Parent = Parent
            end
        end

        function PageLibrary.AddInput(Text, Placeholder, Callback, FlagName)
            local IC = Frame()
            IC.Name = Text .. "INPUT"
            IC.Size = UDim2.new(1, 0, 0, 40)
            IC.BackgroundTransparency = 1
            IC.Parent = DisplayPage
            local ILabel = TextLabel(Text, 11)
            ILabel.TextXAlignment = Enum.TextXAlignment.Left
            ILabel.Position = UDim2.new(0, 6, 0, 0)
            ILabel.Size = UDim2.new(1, -12, 0, 14)
            ILabel.TextColor3 = CurrentTheme.TextSecondary
            ILabel.Parent = IC
            local IF = RoundBox(5)
            IF.Size = UDim2.new(1, 0, 0, 24)
            IF.Position = UDim2.new(0, 0, 0, 16)
            IF.ImageColor3 = CurrentTheme.Card
            IF.Parent = IC
            local IB = TextBox("", 11)
            IB.PlaceholderText = Placeholder or ""
            IB.TextXAlignment = Enum.TextXAlignment.Left
            IB.Position = UDim2.new(0, 8, 0, 0)
            IB.Size = UDim2.new(1, -16, 1, 0)
            IB.ZIndex = Level + 1
            IB.Parent = IF
            if FlagName then
                local sv = GetFlag(FlagName, "")
                if sv ~= "" then
                    IB.Text = sv
                end
            end
            IB.Focused:Connect(
                function()
                    Tween(IF, {ImageColor3 = CurrentTheme.CardHover}, FastTweenInfo)
                end
            )
            IB.FocusLost:Connect(
                function(enter)
                    Tween(IF, {ImageColor3 = CurrentTheme.Card}, FastTweenInfo)
                    if FlagName then
                        SetFlag(FlagName, IB.Text)
                    end
                    if Callback then
                        pcall(Callback, IB.Text, enter)
                    end
                end
            )
        end

        function PageLibrary.AddTextArea(Text, Height, Callback, FlagName)
            Height = Height or 80
            local TAC = Frame()
            TAC.Name = Text .. "TEXTAREA"
            TAC.Size = UDim2.new(1, 0, 0, Height + 16)
            TAC.BackgroundTransparency = 1
            TAC.Parent = DisplayPage
            local TALabel = TextLabel(Text, 11)
            TALabel.TextXAlignment = Enum.TextXAlignment.Left
            TALabel.Position = UDim2.new(0, 6, 0, 0)
            TALabel.Size = UDim2.new(1, -12, 0, 14)
            TALabel.TextColor3 = CurrentTheme.TextSecondary
            TALabel.Parent = TAC
            local TAF = RoundBox(5)
            TAF.Size = UDim2.new(1, 0, 0, Height)
            TAF.Position = UDim2.new(0, 0, 0, 16)
            TAF.ImageColor3 = CurrentTheme.Card
            TAF.Parent = TAC
            local TAB = TextBox("", 11)
            TAB.PlaceholderText = "Enter text here..."
            TAB.TextXAlignment = Enum.TextXAlignment.Left
            TAB.TextYAlignment = Enum.TextYAlignment.Top
            TAB.TextWrapped = true
            TAB.MultiLine = true
            TAB.ClearTextOnFocus = false
            TAB.Position = UDim2.new(0, 8, 0, 6)
            TAB.Size = UDim2.new(1, -16, 1, -12)
            TAB.ZIndex = Level + 1
            TAB.Parent = TAF
            if FlagName then
                local sv = GetFlag(FlagName, "")
                if sv ~= "" then
                    TAB.Text = sv
                end
            end
            TAB.Focused:Connect(
                function()
                    Tween(TAF, {ImageColor3 = CurrentTheme.CardHover}, FastTweenInfo)
                end
            )
            TAB.FocusLost:Connect(
                function()
                    Tween(TAF, {ImageColor3 = CurrentTheme.Card}, FastTweenInfo)
                    if FlagName then
                        SetFlag(FlagName, TAB.Text)
                    end
                    if Callback then
                        pcall(Callback, TAB.Text)
                    end
                end
            )
        end

        function PageLibrary.AddKeybind(Text, Default, Callback, FlagName)
            Default = Default or Enum.KeyCode.None
            if FlagName then
                local sk = GetFlag(FlagName, Default.Name)
                Default = Enum.KeyCode[sk] or Default
            end
            local CurrentKey = Default
            local Binding = false
            local KC = Frame()
            KC.Name = Text .. "KEYBIND"
            KC.Size = UDim2.new(1, 0, 0, 28)
            KC.BackgroundTransparency = 1
            KC.Parent = DisplayPage
            local KF = RoundBox(5)
            KF.ImageColor3 = CurrentTheme.Card
            KF.Parent = KC
            local KL = TextLabel(Text, 12)
            KL.TextXAlignment = Enum.TextXAlignment.Left
            KL.Position = UDim2.new(0, 8, 0, 0)
            KL.Size = UDim2.new(1, -100, 1, 0)
            KL.Parent = KF
            local KeyLabel = TextLabel(CurrentKey.Name, 11)
            KeyLabel.Position = UDim2.new(1, -90, 0, 0)
            KeyLabel.Size = UDim2.new(0, 80, 1, 0)
            KeyLabel.TextColor3 = CurrentTheme.Accent
            KeyLabel.Font = Enum.Font.GothamBold
            KeyLabel.Parent = KF
            local KB = TextButton("", 12)
            KB.ZIndex = Level + 1
            KB.Parent = KF
            KB.MouseButton1Click:Connect(
                function()
                    Binding = true
                    KeyLabel.Text = "..."
                    Tween(KF, {ImageColor3 = CurrentTheme.CardHover}, FastTweenInfo)
                end
            )
            UserInputService.InputBegan:Connect(
                function(input, gp)
                    if Binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        Binding = false
                        CurrentKey = input.KeyCode
                        KeyLabel.Text = CurrentKey.Name
                        Tween(KF, {ImageColor3 = CurrentTheme.Card}, FastTweenInfo)
                        if FlagName then
                            SetFlag(FlagName, CurrentKey.Name)
                        end
                        if Callback then
                            pcall(Callback, CurrentKey)
                        end
                    elseif not gp and input.KeyCode == CurrentKey and not Binding then
                        if Callback then
                            pcall(Callback, CurrentKey)
                        end
                    end
                end
            )
        end

        function PageLibrary.AddTextInfo(Text)
            local TIC = Frame()
            TIC.Name = Text .. "TEXTINFO"
            TIC.Size = UDim2.new(1, 0, 0, 24)
            TIC.BackgroundTransparency = 1
            TIC.Parent = DisplayPage
            local TIF = RoundBox(5)
            TIF.ImageColor3 = CurrentTheme.Card
            TIF.Size = UDim2.new(1, 0, 1, 0)
            TIF.Parent = TIC
            local InfoStrip = Frame()
            InfoStrip.BackgroundColor3 = CurrentTheme.Info
            InfoStrip.BackgroundTransparency = 0.3
            InfoStrip.Size = UDim2.new(0, 2, 0.6, 0)
            InfoStrip.Position = UDim2.new(0, 0, 0.2, 0)
            InfoStrip.BorderSizePixel = 0
            InfoStrip.Parent = TIC
            Corner(InfoStrip, 2)
            local TILabel = TextLabel(Text, 11)
            TILabel.TextXAlignment = Enum.TextXAlignment.Left
            TILabel.Position = UDim2.new(0, 8, 0, 0)
            TILabel.Size = UDim2.new(1, -16, 1, 0)
            TILabel.TextColor3 = CurrentTheme.TextSecondary
            TILabel.ZIndex = Level + 1
            TILabel.Parent = TIC
            local InfoObject = {}
            function InfoObject.Set(NewText)
                TILabel.Text = NewText or ""
            end
            return InfoObject
        end

        function PageLibrary.AddDropdown(Text, ConfigArray, Callback, FlagName)
            local Arr = ConfigArray or {}
            local Toggle = false
            local DefaultSelection = FlagName and GetFlag(FlagName, nil) or nil
            local DC = Frame()
            DC.Size = UDim2.new(1, 0, 0, 28)
            DC.Name = Text .. "DROPDOWN"
            DC.BackgroundTransparency = 1
            DC.Parent = DisplayPage
            local DF = RoundBox(5)
            DF.ClipsDescendants = true
            DF.ImageColor3 = CurrentTheme.Card
            DF.Size = UDim2.new(1, 0, 1, 0)
            DF.Parent = DC
            local DE = DropdownIcon(true)
            DE.Parent = DF
            local DL = TextLabel(DefaultSelection and (Text .. ": " .. DefaultSelection) or Text, 12)
            DL.Size = UDim2.new(1, -24, 0, 28)
            DL.Parent = DF
            local DFrame = Frame()
            DFrame.Position = UDim2.new(0, 0, 0, 28)
            DFrame.BackgroundTransparency = 1
            DFrame.Size = UDim2.new(1, 0, 0, #Arr * 26)
            DFrame.Parent = DF
            Instance.new("UIListLayout").Parent = DFrame
            for _, opt in ipairs(Arr) do
                local optBtn = Frame()
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                optBtn.BackgroundColor3 = CurrentTheme.BackgroundLight
                optBtn.Parent = DFrame
                local optLabel = TextLabel(opt, 11)
                optLabel.TextColor3 = CurrentTheme.Text
                optLabel.Parent = optBtn
                local optClickBtn = TextButton("", 11)
                optClickBtn.ZIndex = Level + 2
                optClickBtn.Parent = optBtn
                optClickBtn.MouseEnter:Connect(
                    function()
                        Tween(optBtn, {BackgroundColor3 = CurrentTheme.CardHover}, FastTweenInfo)
                    end
                )
                optClickBtn.MouseLeave:Connect(
                    function()
                        Tween(optBtn, {BackgroundColor3 = CurrentTheme.BackgroundLight}, FastTweenInfo)
                    end
                )
                optClickBtn.MouseButton1Click:Connect(
                    function()
                        DL.Text = Text .. ": " .. opt
                        if FlagName then
                            SetFlag(FlagName, opt)
                        end
                        if Callback then
                            pcall(Callback, opt)
                        end
                    end
                )
            end
            DE.MouseButton1Down:Connect(
                function()
                    Toggle = not Toggle
                    Tween(
                        DC,
                        {Size = Toggle and UDim2.new(1, 0, 0, 28 + #Arr * 26) or UDim2.new(1, 0, 0, 28)},
                        GlobalTweenInfo
                    )
                    Tween(DE, {Rotation = Toggle and 180 or 0}, GlobalTweenInfo)
                end
            )
        end

        function PageLibrary.AddColourPicker(Text, DefaultColour, Callback, FlagName)
            DefaultColour = DefaultColour or Color3.fromRGB(255, 255, 255)
            if FlagName then
                local saved = GetFlag(FlagName, nil)
                if saved then
                    DefaultColour = Color3.fromRGB(saved[1], saved[2], saved[3])
                end
            end
            local PC = Frame()
            PC.ClipsDescendants = true
            PC.Size = UDim2.new(1, 0, 0, 28)
            PC.Name = Text .. "COLOURPICKER"
            PC.BackgroundTransparency = 1
            PC.Parent = DisplayPage
            local CT = Instance.new("Color3Value")
            CT.Value = DefaultColour
            CT.Parent = PC
            local PL = RoundBox(5)
            PL.Size = UDim2.new(1, -30, 1, 0)
            PL.ImageColor3 = CurrentTheme.Card
            PL.Parent = PC
            local PR = RoundBox(5)
            PR.Size = UDim2.new(0, 28, 1, 0)
            PR.Position = UDim2.new(1, -28, 0, 0)
            PR.ImageColor3 = DefaultColour
            PR.Parent = PC
            local PF = RoundBox(5)
            PF.ImageColor3 = CurrentTheme.Card
            PF.Size = UDim2.new(1, -30, 0, 80)
            PF.Position = UDim2.new(0, 0, 0, 28)
            PF.Parent = PC
            Instance.new("UIListLayout", PF).Padding = UDim.new(0, 2)
            local function SaveColor(c)
                if FlagName then
                    SetFlag(FlagName, {math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255)})
                end
            end
            PageLibrary.AddSlider(
                "R",
                {Min = 0, Max = 255, Def = CT.Value.R * 255},
                function(v)
                    CT.Value = Color3.fromRGB(v, CT.Value.G * 255, CT.Value.B * 255)
                    SaveColor(CT.Value)
                    if Callback then
                        pcall(Callback, CT.Value)
                    end
                end,
                PF
            )
            PageLibrary.AddSlider(
                "G",
                {Min = 0, Max = 255, Def = CT.Value.G * 255},
                function(v)
                    CT.Value = Color3.fromRGB(CT.Value.R * 255, v, CT.Value.B * 255)
                    SaveColor(CT.Value)
                    if Callback then
                        pcall(Callback, CT.Value)
                    end
                end,
                PF
            )
            PageLibrary.AddSlider(
                "B",
                {Min = 0, Max = 255, Def = CT.Value.B * 255},
                function(v)
                    CT.Value = Color3.fromRGB(CT.Value.R * 255, CT.Value.G * 255, v)
                    SaveColor(CT.Value)
                    if Callback then
                        pcall(Callback, CT.Value)
                    end
                end,
                PF
            )
            local Plabel = TextLabel(Text, 12)
            Plabel.Size = UDim2.new(1, -6, 0, 28)
            Plabel.Parent = PL
            CT:GetPropertyChangedSignal("Value"):Connect(
                function()
                    PR.ImageColor3 = CT.Value
                end
            )
            local pt = false
            local pb = TextButton("", 12)
            pb.ZIndex = Level + 1
            pb.Parent = PR
            pb.MouseButton1Down:Connect(
                function()
                    pt = not pt
                    Tween(PC, {Size = pt and UDim2.new(1, 0, 0, 108) or UDim2.new(1, 0, 0, 28)}, GlobalTweenInfo)
                end
            )
        end

        function PageLibrary.AddSlider(Text, Config, Callback, Parent, FlagName)
            local Min = Config.Min or Config.min or 0
            local Max = Config.Max or Config.max or 100
            local Def = Config.Def or Config.default or Config.Default or Min
            if FlagName then
                Def = GetFlag(FlagName, Def)
            end
            Def = math.clamp(Def, Min, Max)
            local DS = (Def - Min) / (Max - Min)
            local SC = Frame()
            SC.Name = Text .. "SLIDER"
            SC.Size = UDim2.new(1, 0, 0, 24)
            SC.BackgroundTransparency = 1
            SC.Parent = Parent or DisplayPage
            local SF = RoundBox(5)
            SF.ImageColor3 = CurrentTheme.Card
            SF.Parent = SC
            local SB = TextButton(Text .. ": " .. Def, 11)
            SB.Size = UDim2.new(1, 0, 1, 0)
            SB.ZIndex = 6
            SB.Parent = SF
            local Fill = RoundBox(5)
            Fill.Size = UDim2.new(DS, 0, 1, 0)
            Fill.ImageColor3 = CurrentTheme.Accent
            Fill.ImageTransparency = 0.3
            Fill.ZIndex = 5
            Fill.Parent = SB
            SB.MouseButton1Down:Connect(
                function()
                    Tween(Fill, {ImageTransparency = 0.2}, FastTweenInfo)
                    local _, _, xs = GetXY(SB)
                    local val = math.floor(Min + (Max - Min) * xs)
                    if FlagName then
                        SetFlag(FlagName, val)
                    end
                    if Callback then
                        pcall(Callback, val)
                    end
                    SB.Text = Text .. ": " .. val
                    Tween(Fill, {Size = UDim2.new(xs, 0, 1, 0)}, FastTweenInfo)
                    local smv =
                        Mouse.Move:Connect(
                        function()
                            local _, _, xs2 = GetXY(SB)
                            local v2 = math.floor(Min + (Max - Min) * xs2)
                            if FlagName then
                                SetFlag(FlagName, v2)
                            end
                            if Callback then
                                pcall(Callback, v2)
                            end
                            SB.Text = Text .. ": " .. v2
                            Tween(Fill, {Size = UDim2.new(xs2, 0, 1, 0)}, FastTweenInfo)
                        end
                    )
                    local skl =
                        UserInputService.InputEnded:Connect(
                        function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                                Tween(Fill, {ImageTransparency = 0.3}, FastTweenInfo)
                                smv:Disconnect()
                                skl:Disconnect()
                            end
                        end
                    )
                end
            )
        end

        function PageLibrary.AddToggle(Text, Default, Callback, FlagName)
            if FlagName then
                Default = GetFlag(FlagName, Default or false)
            end
            local State = Default or false
            local TC = Frame()
            TC.Name = Text .. "TOGGLE"
            TC.Size = UDim2.new(1, 0, 0, 28)
            TC.BackgroundTransparency = 1
            TC.Parent = DisplayPage
            local TL = RoundBox(5)
            TL.Size = UDim2.new(1, -30, 1, 0)
            TL.ImageColor3 = CurrentTheme.Card
            TL.Parent = TC
            local TR = RoundBox(5)
            TR.Position = UDim2.new(1, -28, 0, 0)
            TR.Size = UDim2.new(0, 28, 1, 0)
            TR.ImageColor3 = State and CurrentTheme.Accent or CurrentTheme.CardHover
            TR.Parent = TC
            local EF = Frame()
            EF.BackgroundColor3 = State and CurrentTheme.Accent or CurrentTheme.TextDim
            EF.Position = UDim2.new(1, -30, 0.2, 0)
            EF.Size = UDim2.new(0, 2, 0.6, 0)
            EF.BorderSizePixel = 0
            EF.Parent = TC
            Corner(EF, 2)
            local RT = TickIcon()
            RT.ImageTransparency = State and 0 or 1
            RT.Parent = TR
            local TB = TextButton(Text, 12)
            TB.TextXAlignment = Enum.TextXAlignment.Left
            TB.Position = UDim2.new(0, 8, 0, 0)
            TB.Parent = TL
            TB.MouseButton1Down:Connect(
                function()
                    State = not State
                    if FlagName then
                        SetFlag(FlagName, State)
                    end
                    Tween(
                        EF,
                        {BackgroundColor3 = State and CurrentTheme.Accent or CurrentTheme.TextDim},
                        GlobalTweenInfo
                    )
                    Tween(TR, {ImageColor3 = State and CurrentTheme.Accent or CurrentTheme.CardHover}, GlobalTweenInfo)
                    Tween(RT, {ImageTransparency = State and 0 or 1}, GlobalTweenInfo)
                    if Callback then
                        pcall(Callback, State)
                    end
                end
            )
        end

        -- ==================== NEW v0.0.3 ELEMENTS ====================

        function PageLibrary.AddMultiDropdown(Text, ConfigArray, Callback, FlagName)
            local Arr = ConfigArray or {}
            local Toggle = false
            local Selected = FlagName and GetFlag(FlagName, {}) or {}
            if type(Selected) ~= "table" then
                Selected = {}
            end

            local DC = Frame()
            DC.Size = UDim2.new(1, 0, 0, 28)
            DC.Name = Text .. "MULTIDROPDOWN"
            DC.BackgroundTransparency = 1
            DC.Parent = DisplayPage
            local DF = RoundBox(5)
            DF.ClipsDescendants = true
            DF.ImageColor3 = CurrentTheme.Card
            DF.Parent = DC
            local DE = DropdownIcon(true)
            DE.Parent = DF

            local function UpdateLabel()
                if #Selected == 0 then
                    return Text
                elseif #Selected == 1 then
                    return Text .. ": " .. Selected[1]
                else
                    return Text .. ": " .. #Selected .. " selected"
                end
            end
            local DL = TextLabel(UpdateLabel(), 12)
            DL.Size = UDim2.new(1, -24, 0, 28)
            DL.Parent = DF

            local DFrame = Frame()
            DFrame.Position = UDim2.new(0, 0, 0, 28)
            DFrame.BackgroundTransparency = 1
            DFrame.Size = UDim2.new(1, 0, 0, #Arr * 26)
            DFrame.Parent = DF
            Instance.new("UIListLayout").Parent = DFrame

            local function IsSelected(opt)
                for _, v in ipairs(Selected) do
                    if v == opt then
                        return true
                    end
                end
                return false
            end

            local function ToggleSelection(opt)
                for i, v in ipairs(Selected) do
                    if v == opt then
                        table.remove(Selected, i)
                        goto done
                    end
                end
                table.insert(Selected, opt)
                ::done::
                DL.Text = UpdateLabel()
                if FlagName then
                    SetFlag(FlagName, Selected)
                end
                if Callback then
                    pcall(Callback, Selected)
                end
            end

            for _, opt in ipairs(Arr) do
                local optBtn = Frame()
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                optBtn.BackgroundColor3 = CurrentTheme.BackgroundLight
                optBtn.Parent = DFrame
                local checkbox = RoundBox(3)
                checkbox.Size = UDim2.new(0, 16, 0, 16)
                checkbox.Position = UDim2.new(0, 8, 0, 5)
                checkbox.ImageColor3 = IsSelected(opt) and CurrentTheme.Accent or CurrentTheme.Card
                checkbox.Parent = optBtn
                if IsSelected(opt) then
                    TickIcon().Parent = checkbox
                end
                local optLabel = TextLabel(opt, 11)
                optLabel.Position = UDim2.new(0, 30, 0, 0)
                optLabel.Parent = optBtn
                local optClick = TextButton("", 11)
                optClick.ZIndex = Level + 2
                optClick.Parent = optBtn
                optClick.MouseButton1Click:Connect(
                    function()
                        ToggleSelection(opt)
                        if IsSelected(opt) then
                            Tween(checkbox, {ImageColor3 = CurrentTheme.Accent}, FastTweenInfo)
                            if not checkbox:FindFirstChild("TickIcon") then
                                local cm = TickIcon()
                                cm.ImageTransparency = 1
                                cm.Parent = checkbox
                                Tween(cm, {ImageTransparency = 0}, FastTweenInfo)
                            end
                        else
                            Tween(checkbox, {ImageColor3 = CurrentTheme.Card}, FastTweenInfo)
                            local tick = checkbox:FindFirstChild("TickIcon")
                            if tick then
                                Tween(tick, {ImageTransparency = 1}, FastTweenInfo)
                                task.wait(0.1)
                                tick:Destroy()
                            end
                        end
                    end
                )
            end

            DE.MouseButton1Down:Connect(
                function()
                    Toggle = not Toggle
                    Tween(
                        DC,
                        {Size = Toggle and UDim2.new(1, 0, 0, 28 + #Arr * 26) or UDim2.new(1, 0, 0, 28)},
                        GlobalTweenInfo
                    )
                    Tween(DE, {Rotation = Toggle and 180 or 0}, GlobalTweenInfo)
                end
            )
        end

        function PageLibrary.AddProgressBar(Text, InitialProgress)
            InitialProgress = math.clamp(InitialProgress or 0, 0, 100)
            local PBC = Frame()
            PBC.Name = Text .. "PROGRESSBAR"
            PBC.Size = UDim2.new(1, 0, 0, 40)
            PBC.BackgroundTransparency = 1
            PBC.Parent = DisplayPage
            local PBLabel = TextLabel(Text, 11)
            PBLabel.Position = UDim2.new(0, 6, 0, 0)
            PBLabel.TextColor3 = CurrentTheme.TextSecondary
            PBLabel.Parent = PBC
            local PBFrame = RoundBox(5)
            PBFrame.Size = UDim2.new(1, 0, 0, 22)
            PBFrame.Position = UDim2.new(0, 0, 0, 18)
            PBFrame.ImageColor3 = CurrentTheme.Card
            PBFrame.Parent = PBC
            local PBFill = RoundBox(5)
            PBFill.Size = UDim2.new(InitialProgress / 100, 0, 1, 0)
            PBFill.ImageColor3 = CurrentTheme.Accent
            PBFill.ZIndex = Level + 1
            PBFill.Parent = PBFrame
            local PBText = TextLabel(InitialProgress .. "%", 11)
            PBText.Font = Enum.Font.GothamBold
            PBText.TextColor3 = CurrentTheme.Text
            PBText.ZIndex = Level + 2
            PBText.Parent = PBFrame

            local Controller = {}
            function Controller.SetProgress(p)
                p = math.clamp(p, 0, 100)
                Tween(PBFill, {Size = UDim2.new(p / 100, 0, 1, 0)}, GlobalTweenInfo)
                PBText.Text = math.floor(p) .. "%"
            end
            function Controller.SetText(t)
                PBLabel.Text = t
            end
            function Controller.SetColor(c)
                Tween(PBFill, {ImageColor3 = c}, GlobalTweenInfo)
            end
            return Controller
        end

        function PageLibrary.AddColorPreset(Text, Presets, Callback, FlagName)
            Presets =
                Presets or
                {
                    {Name = "Red", Color = Color3.fromRGB(255, 80, 80)},
                    {Name = "Green", Color = Color3.fromRGB(80, 255, 120)},
                    {Name = "Blue", Color = Color3.fromRGB(80, 150, 255)},
                    {Name = "Yellow", Color = Color3.fromRGB(255, 220, 80)},
                    {Name = "Purple", Color = Color3.fromRGB(180, 100, 255)},
                    {Name = "Orange", Color = Color3.fromRGB(255, 150, 80)}
                }
            local CurrentColor = Color3.fromRGB(255, 255, 255)
            if FlagName then
                local s = GetFlag(FlagName)
                if s and type(s) == "table" then
                    CurrentColor = Color3.fromRGB(s[1], s[2], s[3])
                end
            end
            local CPC = Frame()
            CPC.Name = Text .. "COLORPRESET"
            CPC.Size = UDim2.new(1, 0, 0, 60)
            CPC.BackgroundTransparency = 1
            CPC.Parent = DisplayPage
            local CPLabel = TextLabel(Text, 11)
            CPLabel.Position = UDim2.new(0, 6, 0, 0)
            CPLabel.TextColor3 = CurrentTheme.TextSecondary
            CPLabel.Parent = CPC
            local ColorPreview = RoundBox(5)
            ColorPreview.Size = UDim2.new(0, 40, 0, 40)
            ColorPreview.Position = UDim2.new(0, 0, 0, 18)
            ColorPreview.ImageColor3 = CurrentColor
            ColorPreview.Parent = CPC
            local PresetGrid = Frame()
            PresetGrid.Size = UDim2.new(1, -48, 0, 40)
            PresetGrid.Position = UDim2.new(0, 48, 0, 18)
            PresetGrid.BackgroundTransparency = 1
            PresetGrid.Parent = CPC
            local gl = Instance.new("UIGridLayout")
            gl.CellSize = UDim2.new(0, 32, 0, 32)
            gl.CellPadding = UDim2.new(0, 4, 0, 4)
            gl.Parent = PresetGrid
            for _, preset in ipairs(Presets) do
                local btn = RoundBox(5)
                btn.ImageColor3 = preset.Color
                btn.Parent = PresetGrid
                local cl = TextButton("", 11)
                cl.ZIndex = Level + 1
                cl.Parent = btn
                cl.MouseButton1Click:Connect(
                    function()
                        CurrentColor = preset.Color
                        Tween(ColorPreview, {ImageColor3 = CurrentColor}, GlobalTweenInfo)
                        if FlagName then
                            SetFlag(
                                FlagName,
                                {
                                    math.floor(CurrentColor.R * 255),
                                    math.floor(CurrentColor.G * 255),
                                    math.floor(CurrentColor.B * 255)
                                }
                            )
                        end
                        if Callback then
                            pcall(Callback, CurrentColor)
                        end
                    end
                )
            end
        end

        return PageLibrary
    end

    return TabLibrary
end

return UILibrary
