--[[
    ███████╗███████╗███╗   ██╗    ██╗    ██╗ █████╗ ██████╗ ███████╗
    ╚══███╔╝██╔════╝████╗  ██║    ██║    ██║██╔══██╗██╔══██╗██╔════╝
      ███╔╝ █████╗  ██╔██╗ ██║    ██║ █╗ ██║███████║██████╔╝█████╗  
     ███╔╝  ██╔══╝  ██║╚██╗██║    ██║███╗██║██╔══██║██╔══██╗██╔══╝  
    ███████╗███████╗██║ ╚████║    ╚███╔███╔╝██║  ██║██║  ██║███████╗
    ╚══════╝╚══════╝╚═╝  ╚═══╝     ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝

    Zen-Ware UI Library  v1.0.0
    ─────────────────────────────────────────────────────────
    Built for peace of mind, precision, and power.
    
    Features:
      • Multi-theme support           — Switch between Zen, Ocean, Forest, Sunset
      • Flag system                   — Automatic config saving/loading
      • Notification system           — Toast popups, top-right
      • Active tab indicator          — Accent bar on selected tab
      • AddSection(Text)              — Visual divider with label
      • AddInput(Text, Placeholder)   — Text input field
      • AddTextArea(Text, Height)     — Multi-line text input
      • AddKeybind(Text, Default, CB) — Click-to-rebind keybind
      • AddTextInfo(Text)             — Live-updatable read-only label
      • AddDivider()                  — Thin separator line
      • AddParagraph(Title, Text)     — Info block with title and body
      • Multi-toggle support          — Multiple options selection
      • TopBar toggle button          — Roblox topbar button
      • Ghost mode                    — Anti-detection GUI randomization
      • Smooth animations             — Polished transitions

    ─────────────────────────────────────────────────────────
    Usage:

        local UI = UILibrary.Load("Zen-Ware", "Game Name", "v1.0", {
            Letter = "Z",           -- shown in Roblox topbar (or use Image = "rbxassetid://...")
            Theme = "Zen",          -- "Zen" (default), "Ocean", "Forest", "Sunset"
            SaveConfig = true,      -- Enable automatic config saving
            GhostMode = false,      -- Randomize GUI names for anti-detection
        })

        UI.Notify("Title", "Something happened!", "success", 4)
        -- types: "success"  "error"  "info"  "warn"

        local Page = UI.AddPage("Home")
        Page.AddSection("Combat")
        Page.AddToggle("Aimbot", false, function(v) end)
        Page.AddSlider("FOV", {Min = 10, Max = 360, Def = 90}, function(v) end)
        Page.AddDropdown("Target Part", {"Head", "Torso"}, function(v) end)
        Page.AddKeybind("Toggle UI", Enum.KeyCode.RightShift, function(key) end)
        Page.AddDivider()
        Page.AddParagraph("Info", "This is a helpful description")
        
        -- Change theme dynamically
        UI.SetTheme("Ocean")
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

local TweenTime = 0.15
local Level     = 1

local GlobalTweenInfo  = TweenInfo.new(TweenTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local SlowTweenInfo    = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local FastTweenInfo    = TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local DropShadowID           = "rbxassetid://297774371"
local DropShadowTransparency = 0.3
local IconLibraryID          = "rbxassetid://3926305904"
local IconLibraryID2         = "rbxassetid://3926307971"
local MainFont               = Enum.Font.Gotham

-- ================================================================
--  THEME SYSTEM
-- ================================================================
local Themes = {
    Zen = {
        Name = "Zen",
        Accent       = Color3.fromRGB(85, 190, 165),    -- Teal/Cyan
        AccentDark   = Color3.fromRGB(60, 150, 130),
        AccentLight  = Color3.fromRGB(110, 220, 190),
        
        Background   = Color3.fromRGB(12, 14, 16),
        BackgroundLight = Color3.fromRGB(18, 21, 24),
        BackgroundDark  = Color3.fromRGB(8, 10, 12),
        
        Card         = Color3.fromRGB(20, 24, 28),
        CardHover    = Color3.fromRGB(28, 32, 36),
        
        Text         = Color3.fromRGB(240, 242, 245),
        TextSecondary = Color3.fromRGB(170, 175, 185),
        TextDim      = Color3.fromRGB(120, 125, 135),
        
        Success      = Color3.fromRGB(72, 199, 142),
        Error        = Color3.fromRGB(244, 67, 84),
        Info         = Color3.fromRGB(100, 180, 255),
        Warn         = Color3.fromRGB(255, 193, 80),
        
        Border       = Color3.fromRGB(35, 40, 45),
        Divider      = Color3.fromRGB(30, 35, 40),
    },
    
    Ocean = {
        Name = "Ocean",
        Accent       = Color3.fromRGB(70, 150, 240),
        AccentDark   = Color3.fromRGB(50, 120, 200),
        AccentLight  = Color3.fromRGB(100, 180, 255),
        
        Background   = Color3.fromRGB(10, 12, 18),
        BackgroundLight = Color3.fromRGB(16, 20, 28),
        BackgroundDark  = Color3.fromRGB(6, 8, 12),
        
        Card         = Color3.fromRGB(18, 22, 32),
        CardHover    = Color3.fromRGB(24, 30, 42),
        
        Text         = Color3.fromRGB(235, 240, 250),
        TextSecondary = Color3.fromRGB(160, 170, 190),
        TextDim      = Color3.fromRGB(110, 120, 140),
        
        Success      = Color3.fromRGB(72, 199, 142),
        Error        = Color3.fromRGB(244, 67, 84),
        Info         = Color3.fromRGB(100, 180, 255),
        Warn         = Color3.fromRGB(255, 193, 80),
        
        Border       = Color3.fromRGB(30, 40, 55),
        Divider      = Color3.fromRGB(25, 35, 50),
    },
    
    Forest = {
        Name = "Forest",
        Accent       = Color3.fromRGB(110, 200, 130),
        AccentDark   = Color3.fromRGB(80, 160, 100),
        AccentLight  = Color3.fromRGB(140, 230, 160),
        
        Background   = Color3.fromRGB(12, 15, 13),
        BackgroundLight = Color3.fromRGB(18, 23, 20),
        BackgroundDark  = Color3.fromRGB(8, 10, 9),
        
        Card         = Color3.fromRGB(20, 26, 23),
        CardHover    = Color3.fromRGB(28, 35, 30),
        
        Text         = Color3.fromRGB(240, 245, 242),
        TextSecondary = Color3.fromRGB(170, 185, 175),
        TextDim      = Color3.fromRGB(120, 135, 125),
        
        Success      = Color3.fromRGB(72, 199, 142),
        Error        = Color3.fromRGB(244, 67, 84),
        Info         = Color3.fromRGB(100, 180, 255),
        Warn         = Color3.fromRGB(255, 193, 80),
        
        Border       = Color3.fromRGB(35, 45, 40),
        Divider      = Color3.fromRGB(30, 40, 35),
    },
    
    Sunset = {
        Name = "Sunset",
        Accent       = Color3.fromRGB(255, 130, 100),
        AccentDark   = Color3.fromRGB(220, 100, 70),
        AccentLight  = Color3.fromRGB(255, 160, 130),
        
        Background   = Color3.fromRGB(15, 12, 14),
        BackgroundLight = Color3.fromRGB(22, 18, 21),
        BackgroundDark  = Color3.fromRGB(10, 8, 10),
        
        Card         = Color3.fromRGB(26, 21, 24),
        CardHover    = Color3.fromRGB(34, 28, 32),
        
        Text         = Color3.fromRGB(245, 240, 242),
        TextSecondary = Color3.fromRGB(185, 170, 175),
        TextDim      = Color3.fromRGB(135, 120, 125),
        
        Success      = Color3.fromRGB(72, 199, 142),
        Error        = Color3.fromRGB(244, 67, 84),
        Info         = Color3.fromRGB(100, 180, 255),
        Warn         = Color3.fromRGB(255, 193, 80),
        
        Border       = Color3.fromRGB(45, 35, 40),
        Divider      = Color3.fromRGB(40, 30, 35),
    },
}

local CurrentTheme = Themes.Zen
local ZenWareFlags = {}  -- Storage for all flags
local ZenWareConfig = {
    SaveConfig = false,
    ConfigName = "ZenWareConfig",
    GhostMode = false,
}

-- ================================================================
--  UTILITY FUNCTIONS
-- ================================================================
local function GenerateRandomName()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local name = ""
    for i = 1, 16 do
        local rand = math.random(1, #chars)
        name = name .. chars:sub(rand, rand)
    end
    return name
end

local function GetGUIName(baseName)
    return ZenWareConfig.GhostMode and GenerateRandomName() or baseName
end

local function SaveConfig()
    if not ZenWareConfig.SaveConfig then return end
    local success, err = pcall(function()
        writefile(ZenWareConfig.ConfigName .. ".json", HttpService:JSONEncode(ZenWareFlags))
    end)
    if not success then
        warn("[Zen-Ware] Config save failed:", err)
    end
end

local function LoadConfig()
    if not ZenWareConfig.SaveConfig then return end
    local success, result = pcall(function()
        return readfile(ZenWareConfig.ConfigName .. ".json")
    end)
    if success and result then
        local decoded = HttpService:JSONDecode(result)
        for flag, value in pairs(decoded) do
            ZenWareFlags[flag] = value
        end
    end
end

local function SetFlag(flag, value)
    ZenWareFlags[flag] = value
    SaveConfig()
end

local function GetFlag(flag, default)
    return ZenWareFlags[flag] ~= nil and ZenWareFlags[flag] or default
end

-- ================================================================
--  CONSTRUCTOR HELPERS
-- ================================================================
local function GetXY(obj)
    local X = math.clamp(Mouse.X - obj.AbsolutePosition.X, 0, obj.AbsoluteSize.X)
    local Y = math.clamp(Mouse.Y - obj.AbsolutePosition.Y, 0, obj.AbsoluteSize.Y)
    return X, Y, X/obj.AbsoluteSize.X, Y/obj.AbsoluteSize.Y
end

local function TitleIcon(btn)
    local i = Instance.new(btn and "ImageButton" or "ImageLabel")
    i.Name="TitleIcon"; i.BackgroundTransparency=1; i.Image=IconLibraryID
    i.ImageRectOffset=Vector2.new(524,764); i.ImageRectSize=Vector2.new(36,36)
    i.Size=UDim2.new(0,14,0,14); i.Position=UDim2.new(1,-17,0.5,-7)
    i.Rotation=180; i.ZIndex=Level; return i
end

local function TickIcon(btn)
    local i = Instance.new(btn and "ImageButton" or "ImageLabel")
    i.Name="TickIcon"; i.BackgroundTransparency=1; i.Image="rbxassetid://3926305904"
    i.ImageRectOffset=Vector2.new(312,4); i.ImageRectSize=Vector2.new(24,24)
    i.Size=UDim2.new(1,-6,1,-6); i.Position=UDim2.new(0,3,0,3); i.ZIndex=Level; return i
end

local function DropdownIcon(btn)
    local i = Instance.new(btn and "ImageButton" or "ImageLabel")
    i.Name="DropdownIcon"; i.BackgroundTransparency=1; i.Image=IconLibraryID2
    i.ImageRectOffset=Vector2.new(324,364); i.ImageRectSize=Vector2.new(36,36)
    i.Size=UDim2.new(0,16,0,16); i.Position=UDim2.new(1,-18,0,2); i.ZIndex=Level; return i
end

local function SearchIcon()
    local i = Instance.new("ImageLabel")
    i.Name="SearchIcon"; i.BackgroundTransparency=1; i.Image=IconLibraryID
    i.ImageRectOffset=Vector2.new(964,324); i.ImageRectSize=Vector2.new(36,36)
    i.Size=UDim2.new(0,16,0,16); i.Position=UDim2.new(0,2,0,2); i.ZIndex=Level; return i
end

local function RoundBox(r, btn)
    local i = Instance.new(btn and "ImageButton" or "ImageLabel")
    i.BackgroundTransparency=1; i.Image="rbxassetid://3570695787"
    i.SliceCenter=Rect.new(100,100,100,100)
    i.SliceScale=math.clamp((r or 5)*0.01,0.01,1)
    i.ScaleType=Enum.ScaleType.Slice; i.ZIndex=Level; return i
end

local function MakeDropShadow()
    local i = Instance.new("ImageLabel")
    i.Name="DropShadow"; i.BackgroundTransparency=1; i.Image=DropShadowID
    i.ImageTransparency=DropShadowTransparency; i.Size=UDim2.new(1,0,1,0); i.ZIndex=Level; return i
end

local function Frame()
    local i = Instance.new("Frame"); i.BorderSizePixel=0; i.ZIndex=Level; return i
end

local function ScrollingFrame()
    local i = Instance.new("ScrollingFrame")
    i.BackgroundTransparency=1; i.BorderSizePixel=0; i.ScrollBarThickness=0; i.ZIndex=Level; return i
end

local function TextButton(txt, sz)
    local i = Instance.new("TextButton"); i.Text=txt; i.AutoButtonColor=false
    i.Font=MainFont; i.TextColor3=CurrentTheme.Text
    i.BackgroundTransparency=1; i.TextSize=sz or 12
    i.Size=UDim2.new(1,0,1,0); i.ZIndex=Level; return i
end

local function TextBox(txt, sz)
    local i = Instance.new("TextBox"); i.Text=txt; i.Font=MainFont
    i.TextColor3=CurrentTheme.Text; i.BackgroundTransparency=1
    i.TextSize=sz or 12; i.Size=UDim2.new(1,0,1,0); i.ZIndex=Level
    i.PlaceholderColor3=CurrentTheme.TextDim; return i
end

local function TextLabel(txt, sz)
    local i = Instance.new("TextLabel"); i.Text=txt; i.Font=MainFont
    i.TextColor3=CurrentTheme.Text; i.BackgroundTransparency=1
    i.TextSize=sz or 12; i.Size=UDim2.new(1,0,1,0); i.ZIndex=Level; return i
end

local function Tween(obj, props, info)
    local t = TweenService:Create(obj, info or GlobalTweenInfo, props); t:Play(); return t
end

local function Corner(parent, radius)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or 5); c.Parent = parent; return c
end

-- ================================================================
--  NOTIFICATION SYSTEM
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
    if not NotificationContainer then CreateNotificationSystem() end
    
    Type = Type or "info"
    Duration = Duration or 3
    
    local ColorMap = {
        success = CurrentTheme.Success,
        error = CurrentTheme.Error,
        info = CurrentTheme.Info,
        warn = CurrentTheme.Warn,
    }
    
    local NotifColor = ColorMap[Type:lower()] or CurrentTheme.Info
    
    local NF = Frame()
    NF.Size = UDim2.new(1, 0, 0, 0)
    NF.BackgroundColor3 = CurrentTheme.Card
    NF.ClipsDescendants = true
    NF.ZIndex = 1500
    NF.Parent = NotificationContainer
    Corner(NF, 6)
    
    -- Accent bar on left
    local AccentBar = Frame()
    AccentBar.Size = UDim2.new(0, 3, 1, 0)
    AccentBar.Position = UDim2.new(0, 0, 0, 0)
    AccentBar.BackgroundColor3 = NotifColor
    AccentBar.BorderSizePixel = 0
    AccentBar.ZIndex = 1501
    AccentBar.Parent = NF
    
    -- Title
    local TitleLabel = TextLabel(Title, 13)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Position = UDim2.new(0, 12, 0, 6)
    TitleLabel.Size = UDim2.new(1, -24, 0, 16)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextColor3 = CurrentTheme.Text
    TitleLabel.ZIndex = 1501
    TitleLabel.Parent = NF
    
    -- Text
    local TextLabel2 = TextLabel(Text, 11)
    TextLabel2.Position = UDim2.new(0, 12, 0, 24)
    TextLabel2.Size = UDim2.new(1, -24, 1, -30)
    TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
    TextLabel2.TextWrapped = true
    TextLabel2.TextColor3 = CurrentTheme.TextSecondary
    TextLabel2.ZIndex = 1501
    TextLabel2.Parent = NF
    
    -- Calculate height based on text
    local textBounds = TextService:GetTextSize(Text, 11, MainFont, Vector2.new(296, 1000))
    local totalHeight = math.max(50, 36 + textBounds.Y)
    
    -- Slide in animation
    Tween(NF, {Size = UDim2.new(1, 0, 0, totalHeight)}, SlowTweenInfo)
    
    -- Auto-dismiss
    task.delay(Duration, function()
        Tween(NF, {Size = UDim2.new(1, 0, 0, 0)}, SlowTweenInfo)
        task.wait(0.35)
        NF:Destroy()
    end)
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
    
    -- Apply theme
    CurrentTheme = Themes[ThemeName] or Themes.Zen
    
    -- Apply config options
    ZenWareConfig.SaveConfig = Options.SaveConfig == true
    ZenWareConfig.ConfigName = Options.ConfigName or "ZenWareConfig_" .. GameName:gsub("%s+", "")
    ZenWareConfig.GhostMode = Options.GhostMode == true
    
    -- Load saved config if enabled
    if ZenWareConfig.SaveConfig then
        LoadConfig()
    end
    
    local TabLibrary = {}
    TabLibrary.Pages = {}
    
    -- ── MAIN GUI CONTAINER ────────────────────────────────────
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = GetGUIName("ZenWareUI")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main container
    local MainFrame = RoundBox(8)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
    MainFrame.ImageColor3 = CurrentTheme.Background
    MainFrame.ZIndex = 1
    MainFrame.Parent = ScreenGui
    
    local Shadow = MakeDropShadow()
    Shadow.Parent = MainFrame
    
    -- ── TOP BAR ────────────────────────────────────────────────
    local TopBar = Frame()
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 28)
    TopBar.BackgroundColor3 = CurrentTheme.BackgroundDark
    TopBar.ZIndex = 2
    TopBar.Parent = MainFrame
    Corner(TopBar, 8)
    
    -- Logo/Title
    local TitleLabel = TextLabel(Title, 13)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.Size = UDim2.new(0, 150, 1, 0)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextColor3 = CurrentTheme.Accent
    TitleLabel.ZIndex = 3
    TitleLabel.Parent = TopBar
    
    -- Game name
    local GameLabel = TextLabel(GameName, 11)
    GameLabel.Position = UDim2.new(0, 165, 0, 0)
    GameLabel.Size = UDim2.new(0, 200, 1, 0)
    GameLabel.TextXAlignment = Enum.TextXAlignment.Left
    GameLabel.TextColor3 = CurrentTheme.TextSecondary
    GameLabel.ZIndex = 3
    GameLabel.Parent = TopBar
    
    -- Version
    local VersionLabel = TextLabel(Version, 10)
    VersionLabel.Position = UDim2.new(1, -80, 0, 0)
    VersionLabel.Size = UDim2.new(0, 70, 1, 0)
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
    VersionLabel.TextColor3 = CurrentTheme.TextDim
    VersionLabel.ZIndex = 3
    VersionLabel.Parent = TopBar
    
    -- Bottom section to hide rounded corners
    local TopBarBottom = Frame()
    TopBarBottom.Size = UDim2.new(1, 0, 0, 8)
    TopBarBottom.Position = UDim2.new(0, 0, 1, -8)
    TopBarBottom.BackgroundColor3 = CurrentTheme.BackgroundDark
    TopBarBottom.BorderSizePixel = 0
    TopBarBottom.ZIndex = 2
    TopBarBottom.Parent = TopBar
    
    -- ── SIDEBAR ────────────────────────────────────────────────
    local Sidebar = Frame()
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 110, 1, -28)
    Sidebar.Position = UDim2.new(0, 0, 0, 28)
    Sidebar.BackgroundColor3 = CurrentTheme.BackgroundLight
    Sidebar.ZIndex = 2
    Sidebar.Parent = MainFrame
    
    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Padding = UDim.new(0, 2)
    SidebarList.Parent = Sidebar
    
    -- ── CONTENT AREA ───────────────────────────────────────────
    local ContentArea = Frame()
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -110, 1, -28)
    ContentArea.Position = UDim2.new(0, 110, 0, 28)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ZIndex = 2
    ContentArea.Parent = MainFrame
    
    -- ── DRAGGING ────────────────────────────────────────────────
    local Dragging, DragStart, StartPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - DragStart
            Tween(MainFrame, {
                Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
            }, FastTweenInfo)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    ScreenGui.Parent = CoreGuiService
    
    -- ── TOPBAR BUTTON ───────────────────────────────────────────
    if Letter or Image then
        pcall(function()
            local TopBarApp = CoreGuiService:WaitForChild("TopBarApp", 2)
            if TopBarApp then
                local TopBarFrame = TopBarApp:WaitForChild("TopBarFrame", 2)
                if TopBarFrame then
                    local LeftFrame = TopBarFrame:WaitForChild("LeftFrame", 2)
                    if LeftFrame then
                        local TopBarButton = Instance.new("ImageButton")
                        TopBarButton.Name = GetGUIName("ZenWareToggle")
                        TopBarButton.Size = UDim2.new(0, 32, 0, 32)
                        TopBarButton.BackgroundColor3 = CurrentTheme.Accent
                        TopBarButton.BorderSizePixel = 0
                        TopBarButton.ZIndex = 5
                        
                        if Image then
                            TopBarButton.Image = Image
                            TopBarButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
                        else
                            TopBarButton.Image = ""
                            local LetterLabel = TextLabel(Letter or "Z", 18)
                            LetterLabel.Font = Enum.Font.GothamBold
                            LetterLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            LetterLabel.Parent = TopBarButton
                        end
                        
                        Corner(TopBarButton, 6)
                        TopBarButton.Parent = LeftFrame
                        
                        TopBarButton.MouseButton1Click:Connect(function()
                            MainFrame.Visible = not MainFrame.Visible
                        end)
                    end
                end
            end
        end)
    end
    
    -- ── TOGGLE KEY ──────────────────────────────────────────────
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    -- ── NOTIFY FUNCTION ─────────────────────────────────────────
    TabLibrary.Notify = Notify
    UILibrary.Notify = Notify
    
    -- ── SET THEME FUNCTION ──────────────────────────────────────
    function TabLibrary.SetTheme(themeName)
        local newTheme = Themes[themeName]
        if not newTheme then
            warn("[Zen-Ware] Theme '" .. themeName .. "' not found")
            return
        end
        
        CurrentTheme = newTheme
        
        -- Update all UI elements with new theme
        MainFrame.ImageColor3 = CurrentTheme.Background
        TopBar.BackgroundColor3 = CurrentTheme.BackgroundDark
        TopBarBottom.BackgroundColor3 = CurrentTheme.BackgroundDark
        Sidebar.BackgroundColor3 = CurrentTheme.BackgroundLight
        TitleLabel.TextColor3 = CurrentTheme.Accent
        GameLabel.TextColor3 = CurrentTheme.TextSecondary
        VersionLabel.TextColor3 = CurrentTheme.TextDim
        
        Notify("Theme Changed", "Now using " .. newTheme.Name .. " theme", "info", 2)
    end
    
    UILibrary.SetTheme = TabLibrary.SetTheme
    
    -- ── ADD PAGE ────────────────────────────────────────────────
    function TabLibrary.AddPage(PageName, HasSearch)
        HasSearch = HasSearch == nil and true or HasSearch
        
        local PageLibrary = {}
        local IsPageActive = #TabLibrary.Pages == 0
        
        -- ── TAB BUTTON ──────────────────────────────────────────
        local TabButton = Frame()
        TabButton.Name = PageName .. "Tab"
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
        
        -- Active indicator strip
        local ActiveStrip = Frame()
        ActiveStrip.Size = UDim2.new(0, 2, 0.7, 0)
        ActiveStrip.Position = UDim2.new(0, 0, 0.15, 0)
        ActiveStrip.BackgroundColor3 = CurrentTheme.Accent
        ActiveStrip.BorderSizePixel = 0
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
        TabBtn.Parent = TabButton
        TabBtn.ZIndex = 4
        
        -- ── PAGE CONTENT ────────────────────────────────────────
        local PageFrame = ScrollingFrame()
        PageFrame.Name = PageName .. "Page"
        PageFrame.Size = UDim2.new(1, -12, 1, HasSearch and -38 or -6)
        PageFrame.Position = UDim2.new(0, 6, 0, HasSearch and 32 or 0)
        PageFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        PageFrame.Visible = IsPageActive
        PageFrame.ZIndex = 3
        PageFrame.Parent = ContentArea
		local PageSearchFrame = nil
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 4)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = PageFrame
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageFrame.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 4)
        end)
        
        -- ── SEARCH BAR ──────────────────────────────────────────
        if HasSearch then
            local SearchFrame = Frame()
            SearchFrame.Size = UDim2.new(1, -12, 0, 26)
            SearchFrame.Position = UDim2.new(0, 6, 0, 0)
            SearchFrame.BackgroundColor3 = CurrentTheme.Card
            SearchFrame.ZIndex = 3
            SearchFrame.Visible = IsPageActive
            SearchFrame.Parent = ContentArea
            Corner(SearchFrame, 5)
            
            local SearchIconImg = SearchIcon()
            SearchIconImg.ZIndex = 4
            SearchIconImg.Parent = SearchFrame
            
            local SearchBox = TextBox("", 11)
            SearchBox.PlaceholderText = "Search..."
            SearchBox.Position = UDim2.new(0, 22, 0, 0)
            SearchBox.Size = UDim2.new(1, -26, 1, 0)
            SearchBox.TextXAlignment = Enum.TextXAlignment.Left
            SearchBox.ZIndex = 4
            SearchBox.Parent = SearchFrame
            
            SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                local query = SearchBox.Text:lower()
                for _, child in ipairs(PageFrame:GetChildren()) do
                    if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then
                        child.Visible = query == "" or child.Name:lower():find(query)
                    end
                end
            end)
            
            -- Store search frame reference
            PageSearchFrame = SearchFrame
        end
        
        -- ── TAB SWITCHING ───────────────────────────────────────
        TabBtn.MouseButton1Click:Connect(function()
            -- Hide all pages
            for _, page in ipairs(TabLibrary.Pages) do
                PageFrame.Visible = true
if PageSearchFrame then
    PageSearchFrame.Visible = true
end
                
                -- Reset tab appearance
                Tween(page.TabBG, {ImageTransparency = 1}, FastTweenInfo)
                Tween(page.TabLabel, {TextColor3 = CurrentTheme.TextDim}, FastTweenInfo)
                Tween(page.ActiveStrip, {BackgroundTransparency = 1}, FastTweenInfo)
            end
            
            -- Show this page
            PageFrame.Visible = true
            if PageFrame.SearchFrame then
                PageFrame.SearchFrame.Visible = true
            end
            
            Tween(TabBG, {ImageTransparency = 0, ImageColor3 = CurrentTheme.Card}, GlobalTweenInfo)
            Tween(TabLabel, {TextColor3 = CurrentTheme.Text}, GlobalTweenInfo)
            Tween(ActiveStrip, {BackgroundTransparency = 0}, GlobalTweenInfo)
        end)
        
        -- Store page data
        table.insert(TabLibrary.Pages, {
            Frame = PageFrame,
            SearchFrame = PageSearchFrame,
            TabBG = TabBG,
            TabLabel = TabLabel,
            ActiveStrip = ActiveStrip,
        })
        
        local DisplayPage = PageFrame
        
        -- ══════════════════════════════════════════════════════
        --  PAGE ELEMENT FUNCTIONS
        -- ══════════════════════════════════════════════════════
        
        -- ── LABEL ───────────────────────────────────────────────
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
        
        -- ── SECTION ─────────────────────────────────────────────
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
            
            -- Underline
            local Underline = Frame()
            Underline.Size = UDim2.new(1, -6, 0, 1)
            Underline.Position = UDim2.new(0, 3, 1, -2)
            Underline.BackgroundColor3 = CurrentTheme.Divider
            Underline.BorderSizePixel = 0
            Underline.Parent = SC
        end
        
        -- ── DIVIDER ─────────────────────────────────────────────
        function PageLibrary.AddDivider()
            local Div = Frame()
            Div.Name = "DIVIDER"
            Div.Size = UDim2.new(1, -12, 0, 1)
            Div.Position = UDim2.new(0, 6, 0, 0)
            Div.BackgroundColor3 = CurrentTheme.Divider
            Div.BorderSizePixel = 0
            Div.Parent = DisplayPage
            
            local DivSpacer = Frame()
            DivSpacer.Size = UDim2.new(1, 0, 0, 6)
            DivSpacer.BackgroundTransparency = 1
            DivSpacer.Parent = DisplayPage
        end
        
        -- ── PARAGRAPH ───────────────────────────────────────────
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
            
            -- Calculate height
            local textBounds = TextService:GetTextSize(Text, 11, MainFont, Vector2.new(DisplayPage.AbsoluteSize.X - 12, 1000))
            local totalHeight = 22 + textBounds.Y
            PC.Size = UDim2.new(1, 0, 0, totalHeight)
            PText.Size = UDim2.new(1, -12, 0, textBounds.Y + 4)
        end
        
        -- ── BUTTON ──────────────────────────────────────────────
        function PageLibrary.AddButton(Text, Callback, Parent, NoDivider)
            Parent = Parent or DisplayPage
            local BC = Frame()
            BC.Name = Text .. "BUTTON"
            BC.Size = UDim2.new(1, 0, 0, 28)
            BC.BackgroundTransparency = 1
            BC.Parent = Parent
            
            local BF = RoundBox(5)
            BF.Size = UDim2.new(1, 0, 1, 0)
            BF.ImageColor3 = CurrentTheme.Card
            BF.Parent = BC
            
            local BL = TextLabel(Text, 12)
            BL.Size = UDim2.new(1, 0, 1, 0)
            BL.Parent = BF
            
            local BB = TextButton("", 12)
            BB.ZIndex = Level + 1
            BB.Parent = BF
            
            BB.MouseEnter:Connect(function()
                Tween(BF, {ImageColor3 = CurrentTheme.CardHover}, FastTweenInfo)
            end)
            
            BB.MouseLeave:Connect(function()
                Tween(BF, {ImageColor3 = CurrentTheme.Card}, FastTweenInfo)
            end)
            
            BB.MouseButton1Click:Connect(function()
                Tween(BF, {ImageColor3 = CurrentTheme.BackgroundDark}, FastTweenInfo)
                task.wait(0.1)
                Tween(BF, {ImageColor3 = CurrentTheme.Card}, FastTweenInfo)
                
                if Callback then
                    pcall(Callback)
                end
            end)
            
            if not NoDivider and Parent == DisplayPage then
                local Spacer = Frame()
                Spacer.Size = UDim2.new(1, 0, 0, 2)
                Spacer.BackgroundTransparency = 1
                Spacer.Parent = Parent
            end
        end
        
        -- ── INPUT ───────────────────────────────────────────────
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
            
            -- Load saved value
            if FlagName then
                local savedValue = GetFlag(FlagName, "")
                if savedValue ~= "" then
                    IB.Text = savedValue
                end
            end
            
            IB.Focused:Connect(function()
                Tween(IF, {ImageColor3 = CurrentTheme.CardHover}, FastTweenInfo)
            end)
            
            IB.FocusLost:Connect(function(enterPressed)
                Tween(IF, {ImageColor3 = CurrentTheme.Card}, FastTweenInfo)
                
                if FlagName then
                    SetFlag(FlagName, IB.Text)
                end
                
                if Callback then
                    pcall(Callback, IB.Text, enterPressed)
                end
            end)
        end
        
        -- ── TEXT AREA ───────────────────────────────────────────
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
            
            -- Load saved value
            if FlagName then
                local savedValue = GetFlag(FlagName, "")
                if savedValue ~= "" then
                    TAB.Text = savedValue
                end
            end
            
            TAB.Focused:Connect(function()
                Tween(TAF, {ImageColor3 = CurrentTheme.CardHover}, FastTweenInfo)
            end)
            
            TAB.FocusLost:Connect(function()
                Tween(TAF, {ImageColor3 = CurrentTheme.Card}, FastTweenInfo)
                
                if FlagName then
                    SetFlag(FlagName, TAB.Text)
                end
                
                if Callback then
                    pcall(Callback, TAB.Text)
                end
            end)
        end
        
        -- ── KEYBIND ─────────────────────────────────────────────
        function PageLibrary.AddKeybind(Text, Default, Callback, FlagName)
            Default = Default or Enum.KeyCode.None
            
            -- Load saved keybind
            if FlagName then
                local savedKey = GetFlag(FlagName, Default.Name)
                Default = Enum.KeyCode[savedKey] or Default
            end
            
            local CurrentKey = Default
            local Binding = false
            
            local KC = Frame()
            KC.Name = Text .. "KEYBIND"
            KC.Size = UDim2.new(1, 0, 0, 28)
            KC.BackgroundTransparency = 1
            KC.Parent = DisplayPage
            
            local KF = RoundBox(5)
            KF.Size = UDim2.new(1, 0, 1, 0)
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
            
            KB.MouseButton1Click:Connect(function()
                Binding = true
                KeyLabel.Text = "..."
                Tween(KF, {ImageColor3 = CurrentTheme.CardHover}, FastTweenInfo)
            end)
            
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
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
                elseif not gameProcessed and input.KeyCode == CurrentKey and not Binding then
                    if Callback then
                        pcall(Callback, CurrentKey)
                    end
                end
            end)
        end
        
        -- ── TEXT INFO ───────────────────────────────────────────
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
            
            -- Info icon strip on left
            local InfoStrip = Frame()
            InfoStrip.BackgroundColor3 = CurrentTheme.Info
            InfoStrip.BackgroundTransparency = 0.3
            InfoStrip.Size = UDim2.new(0, 2, 0.6, 0)
            InfoStrip.Position = UDim2.new(0, 0, 0.2, 0)
            InfoStrip.BorderSizePixel = 0
            InfoStrip.ZIndex = Level
            InfoStrip.Parent = TIC
            Corner(InfoStrip, 2)
            
            local TILabel = TextLabel(Text, 11)
            TILabel.TextXAlignment = Enum.TextXAlignment.Left
            TILabel.Position = UDim2.new(0, 8, 0, 0)
            TILabel.Size = UDim2.new(1, -16, 1, 0)
            TILabel.TextColor3 = CurrentTheme.TextSecondary
            TILabel.ZIndex = Level + 1
            TILabel.Parent = TIC
            
            -- Return object with Set method
            local InfoObject = {}
            function InfoObject.Set(NewText)
                TILabel.Text = NewText or ""
            end
            return InfoObject
        end
        
        -- ── DROPDOWN ────────────────────────────────────────────
        function PageLibrary.AddDropdown(Text, ConfigArray, Callback, FlagName)
            local Arr = ConfigArray or {}
            local Toggle = false
            
            -- Load saved selection
            local DefaultSelection = nil
            if FlagName then
                DefaultSelection = GetFlag(FlagName, nil)
            end
            
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
            
            for idx, opt in ipairs(Arr) do
                local optBtn = Frame()
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                optBtn.BackgroundColor3 = CurrentTheme.BackgroundLight
                optBtn.BorderSizePixel = 0
                optBtn.Parent = DFrame
                
                local optLabel = TextLabel(opt, 11)
                optLabel.TextColor3 = CurrentTheme.Text
                optLabel.Parent = optBtn
                
                local optClickBtn = TextButton("", 11)
                optClickBtn.ZIndex = Level + 2
                optClickBtn.Parent = optBtn
                
                optClickBtn.MouseEnter:Connect(function()
                    Tween(optBtn, {BackgroundColor3 = CurrentTheme.CardHover}, FastTweenInfo)
                end)
                
                optClickBtn.MouseLeave:Connect(function()
                    Tween(optBtn, {BackgroundColor3 = CurrentTheme.BackgroundLight}, FastTweenInfo)
                end)
                
                optClickBtn.MouseButton1Click:Connect(function()
                    DL.Text = Text .. ": " .. opt
                    
                    if FlagName then
                        SetFlag(FlagName, opt)
                    end
                    
                    if Callback then
                        pcall(Callback, opt)
                    end
                end)
            end
            
            DE.MouseButton1Down:Connect(function()
                Toggle = not Toggle
                Tween(DC, {Size = Toggle and UDim2.new(1, 0, 0, 28 + (#Arr * 26)) or UDim2.new(1, 0, 0, 28)}, GlobalTweenInfo)
                Tween(DE, {Rotation = Toggle and 180 or 0}, GlobalTweenInfo)
            end)
        end
        
        -- ── COLOUR PICKER ───────────────────────────────────────
        function PageLibrary.AddColourPicker(Text, DefaultColour, Callback, FlagName)
            DefaultColour = DefaultColour or Color3.fromRGB(255, 255, 255)
            
            -- Load saved color
            if FlagName then
                local savedColor = GetFlag(FlagName, nil)
                if savedColor then
                    DefaultColour = Color3.fromRGB(savedColor[1], savedColor[2], savedColor[3])
                end
            end
            
            local cd = {
                white = Color3.fromRGB(255, 255, 255),
                black = Color3.fromRGB(0, 0, 0),
                red = Color3.fromRGB(255, 0, 0),
                green = Color3.fromRGB(0, 255, 0),
                blue = Color3.fromRGB(0, 0, 255)
            }
            
            if typeof(DefaultColour) == "table" then
                DefaultColour = Color3.fromRGB(DefaultColour[1] or 255, DefaultColour[2] or 255, DefaultColour[3] or 255)
            elseif typeof(DefaultColour) == "string" then
                DefaultColour = cd[DefaultColour:lower()] or cd["white"]
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
            
            local PL, PR, PF = RoundBox(5), RoundBox(5), RoundBox(5)
            PL.Size = UDim2.new(1, -30, 1, 0)
            PL.ImageColor3 = CurrentTheme.Card
            PL.Parent = PC
            
            PR.Size = UDim2.new(0, 28, 1, 0)
            PR.Position = UDim2.new(1, -28, 0, 0)
            PR.ImageColor3 = DefaultColour
            PR.Parent = PC
            
            PF.ImageColor3 = CurrentTheme.Card
            PF.Size = UDim2.new(1, -30, 0, 80)
            PF.Position = UDim2.new(0, 0, 0, 28)
            PF.Parent = PC
            
            local Plist = Instance.new("UIListLayout")
            Plist.Padding = UDim.new(0, 2)
            Plist.SortOrder = Enum.SortOrder.LayoutOrder
            Plist.Parent = PF
            
            local function SaveColor(color)
                if FlagName then
                    SetFlag(FlagName, {
                        math.floor(color.R * 255),
                        math.floor(color.G * 255),
                        math.floor(color.B * 255)
                    })
                end
            end
            
            PageLibrary.AddSlider("R", {Min = 0, Max = 255, Def = CT.Value.R * 255}, function(v)
                CT.Value = Color3.fromRGB(v, CT.Value.G * 255, CT.Value.B * 255)
                SaveColor(CT.Value)
                if Callback then pcall(Callback, CT.Value) end
            end, PF)
            
            PageLibrary.AddSlider("G", {Min = 0, Max = 255, Def = CT.Value.G * 255}, function(v)
                CT.Value = Color3.fromRGB(CT.Value.R * 255, v, CT.Value.B * 255)
                SaveColor(CT.Value)
                if Callback then pcall(Callback, CT.Value) end
            end, PF)
            
            PageLibrary.AddSlider("B", {Min = 0, Max = 255, Def = CT.Value.B * 255}, function(v)
                CT.Value = Color3.fromRGB(CT.Value.R * 255, CT.Value.G * 255, v)
                SaveColor(CT.Value)
                if Callback then pcall(Callback, CT.Value) end
            end, PF)
            
            local EL, ER = Frame(), Frame()
            EL.BackgroundColor3 = CurrentTheme.Card
            EL.Position = UDim2.new(1, -3, 0, 0)
            EL.Size = UDim2.new(0, 3, 1, 0)
            EL.BorderSizePixel = 0
            EL.Parent = PL
            
            ER.BackgroundColor3 = DefaultColour
            ER.Size = UDim2.new(0, 3, 1, 0)
            ER.BorderSizePixel = 0
            ER.Parent = PR
            
            local Plabel = TextLabel(Text, 12)
            Plabel.Size = UDim2.new(1, -6, 0, 28)
            Plabel.Parent = PL
            
            CT:GetPropertyChangedSignal("Value"):Connect(function()
                ER.BackgroundColor3 = CT.Value
                PR.ImageColor3 = CT.Value
            end)
            
            local pt = false
            local pb = TextButton("", 12)
            pb.ZIndex = Level + 1
            pb.Parent = PR
            
            pb.MouseButton1Down:Connect(function()
                pt = not pt
                Tween(PC, {Size = pt and UDim2.new(1, 0, 0, 108) or UDim2.new(1, 0, 0, 28)}, GlobalTweenInfo)
            end)
        end
        
        -- ── SLIDER ──────────────────────────────────────────────
        function PageLibrary.AddSlider(Text, Config, Callback, Parent, FlagName)
            local Min = Config.Minimum or Config.minimum or Config.Min or Config.min
            local Max = Config.Maximum or Config.maximum or Config.Max or Config.max
            local Def = Config.Default or Config.default or Config.Def or Config.def
            
            if Min > Max then
                Min, Max = Max, Min
            end
            
            -- Load saved value
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
            SF.Name = "SliderForeground"
            SF.ImageColor3 = CurrentTheme.Card
            SF.Size = UDim2.new(1, 0, 1, 0)
            SF.Parent = SC
            
            local SB = TextButton(Text .. ": " .. Def, 11)
            SB.Size = UDim2.new(1, 0, 1, 0)
            SB.ZIndex = 6
            SB.Parent = SF
            
            local Fill = RoundBox(5)
            Fill.Size = UDim2.new(DS, 0, 1, 0)
            Fill.ImageColor3 = CurrentTheme.Accent
            Fill.ZIndex = 5
            Fill.ImageTransparency = 0.3
            Fill.Parent = SB
            
            SB.MouseButton1Down:Connect(function()
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
                
                local smv, skl
                smv = Mouse.Move:Connect(function()
                    Tween(Fill, {ImageTransparency = 0.2}, FastTweenInfo)
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
                end)
                
                skl = UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        Tween(Fill, {ImageTransparency = 0.3}, FastTweenInfo)
                        smv:Disconnect()
                        skl:Disconnect()
                    end
                end)
            end)
        end
        
        -- ── TOGGLE ──────────────────────────────────────────────
        function PageLibrary.AddToggle(Text, Default, Callback, FlagName)
            -- Load saved state
            if FlagName then
                Default = GetFlag(FlagName, Default or false)
            end
            
            local State = Default or false
            
            local TC = Frame()
            TC.Name = Text .. "TOGGLE"
            TC.Size = UDim2.new(1, 0, 0, 28)
            TC.BackgroundTransparency = 1
            TC.Parent = DisplayPage
            
            local TL, TR = RoundBox(5), RoundBox(5)
            local EF, RT = Frame(), TickIcon()
            local FL, FR = Frame(), Frame()
            
            TL.Size = UDim2.new(1, -30, 1, 0)
            TL.ImageColor3 = CurrentTheme.Card
            TL.Parent = TC
            
            TR.Position = UDim2.new(1, -28, 0, 0)
            TR.Size = UDim2.new(0, 28, 1, 0)
            TR.ImageColor3 = State and CurrentTheme.Accent or CurrentTheme.CardHover
            TR.Parent = TC
            
            FL.BackgroundColor3 = CurrentTheme.Card
            FL.Size = UDim2.new(0, 3, 1, 0)
            FL.Position = UDim2.new(1, -3, 0, 0)
            FL.BorderSizePixel = 0
            FL.Parent = TL
            
            FR.BackgroundColor3 = State and CurrentTheme.Accent or CurrentTheme.CardHover
            FR.Size = UDim2.new(0, 3, 1, 0)
            FR.BorderSizePixel = 0
            FR.Parent = TR
            
            EF.BackgroundColor3 = State and CurrentTheme.Accent or CurrentTheme.TextDim
            EF.Position = UDim2.new(1, -30, 0.2, 0)
            EF.Size = UDim2.new(0, 2, 0.6, 0)
            EF.BorderSizePixel = 0
            EF.Parent = TC
            Corner(EF, 2)
            
            RT.ImageTransparency = State and 0 or 1
            RT.Parent = TR
            
            local TB = TextButton(Text, 12)
            TB.Name = "ToggleButton"
            TB.TextXAlignment = Enum.TextXAlignment.Left
            TB.Position = UDim2.new(0, 8, 0, 0)
            TB.Parent = TL
            
            TB.MouseButton1Down:Connect(function()
                State = not State
                
                if FlagName then
                    SetFlag(FlagName, State)
                end
                
                Tween(EF, {BackgroundColor3 = State and CurrentTheme.Accent or CurrentTheme.TextDim}, GlobalTweenInfo)
                Tween(TR, {ImageColor3 = State and CurrentTheme.Accent or CurrentTheme.CardHover}, GlobalTweenInfo)
                Tween(FR, {BackgroundColor3 = State and CurrentTheme.Accent or CurrentTheme.CardHover}, GlobalTweenInfo)
                Tween(RT, {ImageTransparency = State and 0 or 1}, GlobalTweenInfo)
                
                if Callback then
                    pcall(Callback, State)
                end
            end)
        end
        
        return PageLibrary
    end
    
    -- Expose Notify on the TabLibrary too
    TabLibrary.Notify = Notify
    
    return TabLibrary
end

return UILibrary
