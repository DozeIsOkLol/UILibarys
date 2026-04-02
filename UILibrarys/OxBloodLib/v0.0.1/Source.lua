--[[
    ███████╗██╗  ██╗██████╗ ██╗      ██████╗  ██████╗ ██████╗ 
    ██╔═══██╗╚██╗██╔╝██╔══██╗██║     ██╔═══██╗██╔═══██╗██╔══██╗
    ██║   ██║ ╚███╔╝ ██████╔╝██║     ██║   ██║██║   ██║██║  ██║
    ██║   ██║ ██╔██╗ ██╔══██╗██║     ██║   ██║██║   ██║██║  ██║
    ╚██████╔╝██╔╝ ██╗██████╔╝███████╗╚██████╔╝╚██████╔╝██████╔╝
     ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝ 

    OxBlood UI  v0.0.1
    ─────────────────────────────────────────────────────────
    Features:
      • Notification system  (Notify)     — toast popups, top-right
      • Active tab indicator strip        — 2 px accent bar on selected tab
      • AddSection(Text)                  — visual divider with label
      • AddInput(Text, Placeholder, CB)   — text input field
      • AddKeybind(Text, Default, CB)     — click-to-rebind keybind
      • AddTextInfo(Text)                 — live-updatable read-only label
      • TopBar toggle button              — Roblox topbar button, letter or image

    ─────────────────────────────────────────────────────────
    Usage:

        local UI = UILibrary.Load("OxBlood", "Your Game", "v1.0", {
            Letter = "O",           -- shown in Roblox topbar (or use Image = "rbxassetid://...")
        })

        UI.Notify("Title", "Something happened!", "success", 4)
        -- types: "success"  "error"  "info"  "warn"

        local Page = UI.AddPage("Home")
        Page.AddSection("Combat")
        Page.AddToggle("Aimbot", false, function(v) end)
        Page.AddInput("Target Name", "Enter username...", function(v) end)
        Page.AddKeybind("Toggle UI", Enum.KeyCode.RightShift, function(key) end)
        local Info = Page.AddTextInfo("Status: Idle")
        task.delay(2, function() Info.Set("Status: Running") end)
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

local TweenTime = 0.1
local Level     = 1

local GlobalTweenInfo  = TweenInfo.new(TweenTime)
local SlowTweenInfo    = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local DropShadowID           = "rbxassetid://297774371"
local DropShadowTransparency = 0.3
local IconLibraryID          = "rbxassetid://3926305904"
local IconLibraryID2         = "rbxassetid://3926307971"
local MainFont               = Enum.Font.Gotham

-- OxBlood themed accent colours
local AccentColor    = Color3.fromRGB(160, 20, 40)    -- Deep blood red
local SuccessColor   = Color3.fromRGB(0,   210, 100)
local ErrorColor     = Color3.fromRGB(200,  30,  30)  -- Darker red for error
local InfoColor      = Color3.fromRGB(120,  40,  60)  -- Burgundy info
local WarnColor      = Color3.fromRGB(220, 100,  50)

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
    i.Font=MainFont; i.TextColor3=Color3.fromRGB(255,255,255)
    i.BackgroundTransparency=1; i.TextSize=sz or 12
    i.Size=UDim2.new(1,0,1,0); i.ZIndex=Level; return i
end

local function TextBox(txt, sz)
    local i = Instance.new("TextBox"); i.Text=txt; i.Font=MainFont
    i.TextColor3=Color3.fromRGB(255,255,255); i.BackgroundTransparency=1
    i.TextSize=sz or 12; i.Size=UDim2.new(1,0,1,0); i.ZIndex=Level; return i
end

local function TextLabel(txt, sz)
    local i = Instance.new("TextLabel"); i.Text=txt; i.Font=MainFont
    i.TextColor3=Color3.fromRGB(255,255,255); i.BackgroundTransparency=1
    i.TextSize=sz or 12; i.Size=UDim2.new(1,0,1,0); i.ZIndex=Level; return i
end

local function Tween(obj, props, info)
    local t = TweenService:Create(obj, info or GlobalTweenInfo, props); t:Play(); return t
end

local function Corner(parent, radius)
    local c = Instance.new("UICorner"); c.CornerRadius=UDim.new(0, radius or 6); c.Parent=parent; return c
end

-- ================================================================
--  UILibrary
-- ================================================================
local UILibrary = {}

--[[
    UILibrary.Load(HubName, GameName, Version, TopBarConfig)

    TopBarConfig (optional table):
        { Letter = "O" }                        — shows "O" in the topbar
        { Image  = "rbxassetid://12345678" }    — shows an image in the topbar
        nil / {}                                 — no topbar button
--]]
function UILibrary.Load(HubName, GameName, Version, TopBarConfig)
    HubName      = HubName      or "OxBlood"
    GameName     = GameName     or "Unknown Game"
    Version      = Version      or "v1.0"
    TopBarConfig = TopBarConfig or {}

    local TargetedParent = RunService:IsStudio()
        and Player:WaitForChild("PlayerGui") or CoreGuiService

    local old = TargetedParent:FindFirstChild(HubName)
    if old then old:Destroy() end

    -- ── Root ScreenGui ───────────────────────────────────────────
    local NewInstance = Instance.new("ScreenGui")
    NewInstance.Name = HubName
    NewInstance.ResetOnSpawn = false
    NewInstance.Parent = TargetedParent

    -- ============================================================
    --  TOPBAR TOGGLE BUTTON
    --  Mimics the style of the Roblox topbar buttons (36px, dark bg)
    --  Sits in the topbar area at the right of the default icons.
    --  Clicking toggles the main UI visibility.
    -- ============================================================
    local TopBarButton, UIVisible = nil, true

    if TopBarConfig.Letter or TopBarConfig.Image then
        local TopBarGui = Instance.new("ScreenGui")
        TopBarGui.Name = HubName.."_TopBar"
        TopBarGui.DisplayOrder = 10
        TopBarGui.ResetOnSpawn = false
        TopBarGui.IgnoreGuiInset = true
        TopBarGui.Parent = TargetedParent

        -- Pill-shaped button container, 36px tall to match Roblox topbar
        TopBarButton = Instance.new("ImageButton")
        TopBarButton.Name = "OxBloodTopBarBtn"
        TopBarButton.BackgroundColor3 = Color3.fromRGB(25,10,15)  -- Dark red tint
        TopBarButton.BackgroundTransparency = 0.2
        TopBarButton.Size = UDim2.new(0,36,0,36)
        -- Position after the default Roblox topbar icons (approx x=290)
        TopBarButton.Position = UDim2.new(0,290,0,0)
        TopBarButton.AutoButtonColor = false
        TopBarButton.Image = ""
        TopBarButton.ZIndex = 100
        TopBarButton.Parent = TopBarGui
        Corner(TopBarButton, 8)

        -- Hover tint with blood red accent
        TopBarButton.MouseEnter:Connect(function()
            Tween(TopBarButton, {BackgroundTransparency=0, BackgroundColor3=Color3.fromRGB(40,15,20)}, GlobalTweenInfo)
        end)
        TopBarButton.MouseLeave:Connect(function()
            Tween(TopBarButton, {BackgroundTransparency=0.2, BackgroundColor3=Color3.fromRGB(25,10,15)}, GlobalTweenInfo)
        end)

        if TopBarConfig.Image then
            -- Image mode
            local Img = Instance.new("ImageLabel")
            Img.BackgroundTransparency = 1
            Img.Image = TopBarConfig.Image
            Img.Size = UDim2.new(0,22,0,22)
            Img.Position = UDim2.new(0.5,-11,0.5,-11)
            Img.ZIndex = 101
            Img.Parent = TopBarButton
        else
            -- Letter mode
            local Lbl = Instance.new("TextLabel")
            Lbl.BackgroundTransparency = 1
            Lbl.Text = tostring(TopBarConfig.Letter):sub(1,2)
            Lbl.Font = Enum.Font.GothamBold
            Lbl.TextColor3 = AccentColor  -- Blood red text
            Lbl.TextSize = 16
            Lbl.Size = UDim2.new(1,0,1,0)
            Lbl.ZIndex = 101
            Lbl.Parent = TopBarButton
        end
    end

    -- ── Notification ScreenGui (separate layer, always on top) ───
    local NotifGui = Instance.new("ScreenGui")
    NotifGui.Name = HubName.."_Notifs"
    NotifGui.DisplayOrder = 20
    NotifGui.ResetOnSpawn = false
    NotifGui.IgnoreGuiInset = false
    NotifGui.Parent = TargetedParent

    -- Stack container — top-right, notifications push down
    local NotifStack = Frame()
    NotifStack.Name = "NotifStack"
    NotifStack.BackgroundTransparency = 1
    NotifStack.Size = UDim2.new(0,240,1,0)
    NotifStack.Position = UDim2.new(1,-250,0,10)
    NotifStack.ZIndex = 200
    NotifStack.Parent = NotifGui

    local NotifList = Instance.new("UIListLayout")
    NotifList.SortOrder = Enum.SortOrder.LayoutOrder
    NotifList.VerticalAlignment = Enum.VerticalAlignment.Top
    NotifList.Padding = UDim.new(0,6)
    NotifList.Parent = NotifStack

    local NotifCount = 0

    -- ── Outer container (shadow + main frame) ────────────────────
    local ContainerFrame = Frame()
    ContainerFrame.Name="ContainerFrame"; ContainerFrame.Size=UDim2.new(0,500,0,300)
    ContainerFrame.Position=UDim2.new(0.5,-250,0.5,-150)
    ContainerFrame.BackgroundTransparency=1; ContainerFrame.Parent=NewInstance

    local ContainerShadow = MakeDropShadow()
    ContainerShadow.Name="Shadow"; ContainerShadow.Parent=ContainerFrame

    Level += 1

    local MainFrame = RoundBox(5)
    MainFrame.ClipsDescendants=true; MainFrame.Name="MainFrame"
    MainFrame.Size=UDim2.new(1,-50,1,-30); MainFrame.Position=UDim2.new(0,25,0,15)
    MainFrame.ImageColor3=Color3.fromRGB(28,22,25); MainFrame.Parent=ContainerFrame  -- Dark red-tinted bg

    -- Wire up topbar button toggle now that MainFrame exists
    if TopBarButton then
        TopBarButton.MouseButton1Click:Connect(function()
            UIVisible = not UIVisible
            Tween(ContainerFrame, {
                GroupTransparency = UIVisible and 0 or 1
            }, SlowTweenInfo)
            ContainerFrame.Visible = true   -- keep true; use transparency
            -- Re-show instantly if toggling on
            if UIVisible then
                ContainerFrame.Visible = true
            end
        end)
    end

    -- ============================================================
    --  TITLE BAR  ─  HubName | GameName | Version ▼
    -- ============================================================
    local TitleBar = RoundBox(5)
    TitleBar.Name="TitleBar"; TitleBar.ImageColor3=Color3.fromRGB(35,25,28)  -- Slightly lighter red tint
    TitleBar.Size=UDim2.new(1,-10,0,24); TitleBar.Position=UDim2.new(0,5,0,5)
    TitleBar.Parent=MainFrame

    Level += 1

    -- Left — Hub Name (bold) with accent color
    local HubLabel = TextLabel(HubName, 12)
    HubLabel.Font=Enum.Font.GothamBold; HubLabel.TextXAlignment=Enum.TextXAlignment.Left
    HubLabel.TextColor3=AccentColor  -- Blood red
    HubLabel.Size=UDim2.new(0.33,0,1,0); HubLabel.Position=UDim2.new(0,8,0,0)
    HubLabel.ZIndex=Level; HubLabel.Parent=TitleBar

    -- Divider 1
    local D1=Frame(); D1.BackgroundColor3=Color3.fromRGB(70,50,55)  -- Red-tinted divider
    D1.Size=UDim2.new(0,1,0.45,0); D1.Position=UDim2.new(0.35,0,0.275,0)
    D1.ZIndex=Level; D1.Parent=TitleBar

    -- Centre — Game Name
    local GameLabel = TextLabel(GameName, 11)
    GameLabel.TextXAlignment=Enum.TextXAlignment.Center; GameLabel.TextTransparency=0.25
    GameLabel.Size=UDim2.new(0.3,0,1,0); GameLabel.Position=UDim2.new(0.35,4,0,0)
    GameLabel.ZIndex=Level; GameLabel.Parent=TitleBar

    -- Divider 2
    local D2=Frame(); D2.BackgroundColor3=Color3.fromRGB(70,50,55)  -- Red-tinted divider
    D2.Size=UDim2.new(0,1,0.45,0); D2.Position=UDim2.new(0.65,4,0.275,0)
    D2.ZIndex=Level; D2.Parent=TitleBar

    -- Right — Version
    local VersionLabel = TextLabel(Version, 10)
    VersionLabel.TextXAlignment=Enum.TextXAlignment.Right; VersionLabel.TextTransparency=0.4
    VersionLabel.Size=UDim2.new(0.28,-20,1,0); VersionLabel.Position=UDim2.new(0.67,6,0,0)
    VersionLabel.ZIndex=Level; VersionLabel.Parent=TitleBar

    -- Minimise ▼
    local MinimiseToggle = true
    local MinimiseButton = TitleIcon(true)
    MinimiseButton.Name="Minimise"; MinimiseButton.Parent=TitleBar

    MinimiseButton.MouseButton1Down:Connect(function()
        MinimiseToggle = not MinimiseToggle
        if not MinimiseToggle then
            Tween(MainFrame,{Size=UDim2.new(1,-50,0,30)})
            Tween(MinimiseButton,{Rotation=0})
            Tween(ContainerShadow,{ImageTransparency=1})
        else
            Tween(MainFrame,{Size=UDim2.new(1,-50,1,-30)})
            Tween(MinimiseButton,{Rotation=180})
            Tween(ContainerShadow,{ImageTransparency=DropShadowTransparency})
        end
    end)

    -- Drag zone
    local TitleDrag = TextButton("",14)
    TitleDrag.Name="TitleDrag"; TitleDrag.Size=UDim2.new(1,-20,1,0); TitleDrag.ZIndex=Level
    TitleDrag.Parent=TitleBar

    TitleDrag.MouseButton1Down:Connect(function()
        local lx,ly = Mouse.X,Mouse.Y
        local mv,kl
        mv=Mouse.Move:Connect(function()
            local nx,ny=Mouse.X,Mouse.Y
            ContainerFrame.Position+=UDim2.new(0,nx-lx,0,ny-ly)
            lx,ly=nx,ny
        end)
        kl=UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                mv:Disconnect(); kl:Disconnect()
            end
        end)
    end)

    Level += 1

    -- ============================================================
    --  LAYOUT
    --  TitleBar  y=5,  h=24 → bottom y=29
    --  Content   starts y=33
    --  UserInfo  h=46, y=219  (270-5-46)
    --  MenuBar   y=33, h=181
    --  Display   y=33, h=232
    -- ============================================================

    -- Tab sidebar
    local MenuBar = ScrollingFrame()
    MenuBar.Name="MenuBar"; MenuBar.BackgroundTransparency=0.7
    MenuBar.BackgroundColor3=Color3.fromRGB(18,12,15)  -- Darker red tint
    MenuBar.Size=UDim2.new(0,100,0,181); MenuBar.Position=UDim2.new(0,5,0,33)
    MenuBar.CanvasSize=UDim2.new(0,0,0,0); MenuBar.Parent=MainFrame

    -- Content area
    local DisplayFrame = RoundBox(5)
    DisplayFrame.Name="Display"; DisplayFrame.ImageColor3=Color3.fromRGB(18,12,15)  -- Match sidebar
    DisplayFrame.Size=UDim2.new(1,-115,0,232); DisplayFrame.Position=UDim2.new(0,110,0,33)
    DisplayFrame.Parent=MainFrame

    -- ============================================================
    --  PLAYER INFO PANEL  ─  bottom of sidebar
    -- ============================================================
    local UserInfoPanel = RoundBox(5)
    UserInfoPanel.Name="UserInfo"; UserInfoPanel.ImageColor3=Color3.fromRGB(32,22,26)
    UserInfoPanel.Size=UDim2.new(0,100,0,46); UserInfoPanel.Position=UDim2.new(0,5,0,219)
    UserInfoPanel.ClipsDescendants=true; UserInfoPanel.Parent=MainFrame

    local InfoAccent = Frame()
    InfoAccent.BackgroundColor3=AccentColor; InfoAccent.BackgroundTransparency=0.55
    InfoAccent.Size=UDim2.new(1,0,0,2); InfoAccent.ZIndex=Level; InfoAccent.Parent=UserInfoPanel

    local AvatarHolder = Frame()
    AvatarHolder.Name="AvatarHolder"; AvatarHolder.BackgroundColor3=Color3.fromRGB(45,30,35)
    AvatarHolder.Size=UDim2.new(0,30,0,30); AvatarHolder.Position=UDim2.new(0,7,0.5,-15)
    AvatarHolder.ZIndex=Level; AvatarHolder.Parent=UserInfoPanel
    Corner(AvatarHolder, 999)

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name="AvatarImage"; AvatarImage.BackgroundTransparency=1
    AvatarImage.Size=UDim2.new(1,0,1,0); AvatarImage.ZIndex=Level+1; AvatarImage.Parent=AvatarHolder
    Corner(AvatarImage, 999)

    local StatusDot = Frame()
    StatusDot.BackgroundColor3=AccentColor  -- Blood red status
    StatusDot.Size=UDim2.new(0,7,0,7); StatusDot.Position=UDim2.new(1,-7,1,-7)
    StatusDot.ZIndex=Level+2; StatusDot.Parent=AvatarHolder
    Corner(StatusDot, 999)

    local WelcomeLine = TextLabel("Welcome,", 9)
    WelcomeLine.TextXAlignment=Enum.TextXAlignment.Left; WelcomeLine.TextTransparency=0.4
    WelcomeLine.TextTruncate=Enum.TextTruncate.AtEnd
    WelcomeLine.Size=UDim2.new(1,-44,0,12); WelcomeLine.Position=UDim2.new(0,42,0,9)
    WelcomeLine.ZIndex=Level; WelcomeLine.Parent=UserInfoPanel

    local NameLine = TextLabel(Player.DisplayName.."!", 11)
    NameLine.Font=Enum.Font.GothamBold; NameLine.TextXAlignment=Enum.TextXAlignment.Left
    NameLine.TextTruncate=Enum.TextTruncate.AtEnd
    NameLine.Size=UDim2.new(1,-44,0,13); NameLine.Position=UDim2.new(0,42,0,23)
    NameLine.ZIndex=Level; NameLine.Parent=UserInfoPanel

    task.spawn(function()
        local ok,thumb=pcall(function()
            return PlayersService:GetUserThumbnailAsync(
                Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        if ok and thumb then AvatarImage.Image=thumb end
    end)

    -- ============================================================
    --  NOTIFICATION SYSTEM
    --  UILibrary.Notify(Title, Message, NotifType, Duration)
    --  NotifType : "success" | "error" | "info" | "warn"
    --  Duration  : seconds (default 4)
    -- ============================================================
    local TypeColours = {
        success = SuccessColor,
        error   = ErrorColor,
        info    = InfoColor,
        warn    = WarnColor,
    }
    local TypeIcons = {
        success = "✓",
        error   = "✕",
        info    = "ℹ",
        warn    = "⚠",
    }

    function UILibrary.Notify(Title, Message, NotifType, Duration)
        NotifType = (NotifType or "info"):lower()
        Duration  = Duration or 4
        local Colour = TypeColours[NotifType] or InfoColor
        local Icon   = TypeIcons[NotifType]   or "ℹ"

        NotifCount += 1

        -- Outer container (slides in from right)
        local NContainer = Frame()
        NContainer.Name = "Notif"..NotifCount
        NContainer.LayoutOrder = NotifCount
        NContainer.BackgroundTransparency = 1
        NContainer.Size = UDim2.new(1,0,0,56)
        NContainer.Position = UDim2.new(1,10,0,0)   -- starts off-screen right
        NContainer.ClipsDescendants = false
        NContainer.ZIndex = 200
        NContainer.Parent = NotifStack

        -- Card background with dark red tint
        local NCard = RoundBox(6)
        NCard.ImageColor3 = Color3.fromRGB(32,24,28)
        NCard.Size = UDim2.new(1,0,1,0)
        NCard.ZIndex = 200
        NCard.Parent = NContainer

        -- Left accent bar
        local NAccent = Frame()
        NAccent.BackgroundColor3 = Colour
        NAccent.Size = UDim2.new(0,3,1,-10)
        NAccent.Position = UDim2.new(0,0,0,5)
        NAccent.ZIndex = 201
        NAccent.Parent = NContainer
        Corner(NAccent, 3)

        -- Icon label
        local NIcon = Instance.new("TextLabel")
        NIcon.BackgroundTransparency = 1
        NIcon.Font = Enum.Font.GothamBold
        NIcon.TextColor3 = Colour
        NIcon.TextSize = 16
        NIcon.Text = Icon
        NIcon.Size = UDim2.new(0,24,0,24)
        NIcon.Position = UDim2.new(0,8,0,8)
        NIcon.ZIndex = 202
        NIcon.Parent = NContainer

        -- Title
        local NTitle = Instance.new("TextLabel")
        NTitle.BackgroundTransparency = 1
        NTitle.Font = Enum.Font.GothamBold
        NTitle.TextColor3 = Color3.fromRGB(255,255,255)
        NTitle.TextSize = 12
        NTitle.Text = Title or ""
        NTitle.TextXAlignment = Enum.TextXAlignment.Left
        NTitle.TextTruncate = Enum.TextTruncate.AtEnd
        NTitle.Size = UDim2.new(1,-40,0,14)
        NTitle.Position = UDim2.new(0,34,0,8)
        NTitle.ZIndex = 202
        NTitle.Parent = NContainer

        -- Message
        local NMsg = Instance.new("TextLabel")
        NMsg.BackgroundTransparency = 1
        NMsg.Font = MainFont
        NMsg.TextColor3 = Color3.fromRGB(200,200,200)
        NMsg.TextSize = 10
        NMsg.Text = Message or ""
        NMsg.TextXAlignment = Enum.TextXAlignment.Left
        NMsg.TextTruncate = Enum.TextTruncate.AtEnd
        NMsg.Size = UDim2.new(1,-40,0,12)
        NMsg.Position = UDim2.new(0,34,0,24)
        NMsg.ZIndex = 202
        NMsg.Parent = NContainer

        -- Timer bar background
        local NTimerBG = Frame()
        NTimerBG.BackgroundColor3 = Color3.fromRGB(50,38,42)
        NTimerBG.Size = UDim2.new(1,-8,0,2)
        NTimerBG.Position = UDim2.new(0,4,1,-5)
        NTimerBG.ZIndex = 202
        NTimerBG.Parent = NContainer
        Corner(NTimerBG, 2)

        -- Timer bar fill (shrinks left-to-right)
        local NTimerFill = Frame()
        NTimerFill.BackgroundColor3 = Colour
        NTimerFill.Size = UDim2.new(1,0,1,0)
        NTimerFill.ZIndex = 203
        NTimerFill.Parent = NTimerBG
        Corner(NTimerFill, 2)

        -- Slide IN
        task.delay(0.02, function()
            Tween(NContainer, {Position=UDim2.new(0,0,0,0)}, SlowTweenInfo)
        end)

        -- Shrink timer bar over Duration seconds
        TweenService:Create(NTimerFill,
            TweenInfo.new(Duration, Enum.EasingStyle.Linear),
            {Size=UDim2.new(0,0,1,0)}
        ):Play()

        -- Auto-dismiss
        task.delay(Duration, function()
            Tween(NContainer, {Position=UDim2.new(1,10,0,0)}, SlowTweenInfo)
            task.delay(0.4, function()
                Tween(NContainer, {Size=UDim2.new(1,0,0,0)}, GlobalTweenInfo)
                task.delay(0.15, function() NContainer:Destroy() end)
            end)
        end)

        -- Click to dismiss early
        local CloseBtn = Instance.new("TextButton")
        CloseBtn.BackgroundTransparency=1; CloseBtn.Text=""; CloseBtn.Size=UDim2.new(1,0,1,0)
        CloseBtn.ZIndex=205; CloseBtn.Parent=NContainer
        CloseBtn.MouseButton1Click:Connect(function()
            Tween(NContainer,{Position=UDim2.new(1,10,0,0)},SlowTweenInfo)
            task.delay(0.4, function() NContainer:Destroy() end)
        end)
    end

    -- ============================================================
    --  TAB / PAGE SYSTEM
    -- ============================================================
    Level += 1

    local MenuList = Instance.new("UIListLayout")
    MenuList.SortOrder=Enum.SortOrder.LayoutOrder; MenuList.Padding=UDim.new(0,5)
    MenuList.Parent=MenuBar

    MenuList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        MenuBar.CanvasSize=UDim2.new(0,0,0,MenuList.AbsoluteContentSize.Y+5)
    end)

    local TabCount   = 0
    local TabLibrary = {}

    function TabLibrary.AddPage(PageTitle, SearchBarIncluded)
        SearchBarIncluded = (SearchBarIncluded==nil) and true or SearchBarIncluded

        -- ── Tab button ───────────────────────────────────────────
        local PageContainer = RoundBox(5)
        PageContainer.Name=PageTitle; PageContainer.Size=UDim2.new(1,0,0,20)
        PageContainer.LayoutOrder=TabCount
        PageContainer.ImageColor3=(TabCount==0) and Color3.fromRGB(45,32,36) or Color3.fromRGB(35,25,28)
        PageContainer.Parent=MenuBar

        -- ── ACTIVE TAB INDICATOR STRIP (2px left border) ─────────
        local ActiveStrip = Frame()
        ActiveStrip.Name = "ActiveStrip"
        ActiveStrip.BackgroundColor3 = AccentColor
        ActiveStrip.Size = UDim2.new(0,2,0.6,0)
        ActiveStrip.Position = UDim2.new(0,0,0.2,0)
        ActiveStrip.ZIndex = Level + 2
        ActiveStrip.BackgroundTransparency = (TabCount==0) and 0 or 1
        ActiveStrip.Parent = PageContainer
        Corner(ActiveStrip, 2)

        local PageButton = TextButton(PageTitle, 12)
        PageButton.Name=PageTitle.."Button"
        PageButton.TextXAlignment = Enum.TextXAlignment.Center
        PageButton.TextTransparency=(TabCount==0) and 0 or 0.45
        PageButton.Parent=PageContainer

        -- ── Display page ─────────────────────────────────────────
        local DisplayPage = ScrollingFrame()
        DisplayPage.Visible=(TabCount==0); DisplayPage.Name=PageTitle
        DisplayPage.Size=UDim2.new(1,0,1,0); DisplayPage.Parent=DisplayFrame

        TabCount += 1

        PageButton.MouseButton1Down:Connect(function()
            task.spawn(function()
                for _,btn in next,MenuBar:GetChildren() do
                    if btn:IsA("GuiObject") then
                        local match = string.find(btn.Name:lower(), PageContainer.Name:lower())
                        local inner = btn:FindFirstChild(btn.Name.."Button")
                        local strip  = btn:FindFirstChild("ActiveStrip")
                        Tween(btn,{ImageColor3=match and Color3.fromRGB(45,32,36) or Color3.fromRGB(35,25,28)})
                        if inner then Tween(inner,{TextTransparency=match and 0 or 0.45}) end
                        if strip  then Tween(strip,{BackgroundTransparency=match and 0 or 1}) end
                    end
                end
            end)
            task.spawn(function()
                for _,disp in next,DisplayFrame:GetChildren() do
                    if disp:IsA("GuiObject") then
                        disp.Visible=string.find(disp.Name:lower(),PageContainer.Name:lower()) and true or false
                    end
                end
            end)
        end)

        -- ── List layout inside page ───────────────────────────────
        local DisplayList = Instance.new("UIListLayout")
        DisplayList.SortOrder=Enum.SortOrder.LayoutOrder; DisplayList.Padding=UDim.new(0,5)
        DisplayList.Parent=DisplayPage

        DisplayList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            DisplayPage.CanvasSize=UDim2.new(0,0,
                (DisplayList.AbsoluteContentSize.Y/math.max(1,DisplayPage.AbsoluteWindowSize.Y))+0.05,0)
        end)

        local Pad=Instance.new("UIPadding")
        Pad.PaddingBottom=UDim.new(0,5); Pad.PaddingTop=UDim.new(0,5)
        Pad.PaddingLeft=UDim.new(0,5); Pad.PaddingRight=UDim.new(0,5)
        Pad.Parent=DisplayPage

        -- Search bar
        if SearchBarIncluded then
            local SBC=RoundBox(5); SBC.Name="SearchBar"; SBC.ImageColor3=Color3.fromRGB(32,22,26)
            SBC.Size=UDim2.new(1,0,0,20); SBC.Parent=DisplayPage
            local SBox=TextBox("Search..."); SBox.Name="SearchInput"
            SBox.Position=UDim2.new(0,20,0,0); SBox.Size=UDim2.new(1,-20,1,0)
            SBox.TextTransparency=0.5; SBox.TextXAlignment=Enum.TextXAlignment.Left; SBox.Parent=SBC
            SearchIcon().Parent=SBC
            SBox:GetPropertyChangedSignal("Text"):Connect(function()
                local v=SBox.Text
                for _,el in next,DisplayPage:GetChildren() do
                    if el:IsA("Frame") and not string.find(el.Name:lower(),"label")
                                       and not string.find(el.Name:lower(),"section") then
                        el.Visible=string.find(el.Name:lower(),v:lower()) and true or false
                    end
                end
            end)
        end

        -- ============================================================
        --  PAGE ELEMENT LIBRARY
        -- ============================================================
        local PageLibrary = {}

        -- ── BUTTON ───────────────────────────────────────────────
        function PageLibrary.AddButton(Text, Callback, Parent, Underline)
            local BC=Frame(); BC.Name=Text.."BUTTON"; BC.Size=UDim2.new(1,0,0,20)
            BC.BackgroundTransparency=1; BC.Parent=Parent or DisplayPage
            local BF=RoundBox(5); BF.Name="ButtonForeground"; BF.Size=UDim2.new(1,0,1,0)
            BF.ImageColor3=Color3.fromRGB(32,22,26); BF.Parent=BC
            if Underline then
                local ts=TextService:GetTextSize(Text,12,Enum.Font.Gotham,Vector2.new(0,0))
                local be=Frame(); be.Size=UDim2.new(0,ts.X,0,1)
                be.Position=UDim2.new(0.5,(-ts.X/2)-1,1,-1)
                be.BackgroundColor3=Color3.fromRGB(255,255,255); be.BackgroundTransparency=0.5; be.Parent=BF
            end
            local HB=TextButton(Text,12); HB.Parent=BF
            HB.MouseButton1Down:Connect(function()
                Callback(); Tween(BF,{ImageColor3=Color3.fromRGB(42,30,34)}); Tween(HB,{TextTransparency=0.5})
                wait(TweenTime); Tween(BF,{ImageColor3=Color3.fromRGB(32,22,26)}); Tween(HB,{TextTransparency=0})
            end)
        end

        -- ── LABEL ────────────────────────────────────────────────
        function PageLibrary.AddLabel(Text)
            local LC=Frame(); LC.Name=Text.."LABEL"; LC.Size=UDim2.new(1,0,0,20)
            LC.BackgroundTransparency=1; LC.Parent=DisplayPage
            local LF=RoundBox(5); LF.Name="LabelForeground"; LF.ImageColor3=Color3.fromRGB(40,28,32)
            LF.Size=UDim2.new(1,0,1,0); LF.Parent=LC
            TextLabel(Text,12).Parent=LF
        end

        -- ── SECTION ──────────────────────────────────────────────
        --  Visual divider: ──── Section Title ────
        function PageLibrary.AddSection(Text)
            local SC=Frame(); SC.Name=Text.."SECTION"; SC.Size=UDim2.new(1,0,0,18)
            SC.BackgroundTransparency=1; SC.Parent=DisplayPage

            -- Left line
            local LL=Frame(); LL.BackgroundColor3=Color3.fromRGB(60,45,50)
            LL.Size=UDim2.new(0.5,-4,0,1); LL.Position=UDim2.new(0,0,0.5,0)
            LL.ZIndex=Level; LL.Parent=SC

            -- Right line
            local RL=Frame(); RL.BackgroundColor3=Color3.fromRGB(60,45,50)
            RL.Size=UDim2.new(0.5,-4,0,1); RL.Position=UDim2.new(0.5,4,0.5,0)
            RL.ZIndex=Level; RL.Parent=SC

            -- Label (auto-sized, centred)
            local SL=Instance.new("TextLabel")
            SL.BackgroundTransparency=1; SL.Font=Enum.Font.GothamBold
            SL.TextColor3=AccentColor  -- Blood red section headers
            SL.TextSize=10
            SL.Text=Text; SL.AutomaticSize=Enum.AutomaticSize.X
            SL.Size=UDim2.new(0,0,1,0); SL.AnchorPoint=Vector2.new(0.5,0)
            SL.Position=UDim2.new(0.5,0,0,0)
            SL.ZIndex=Level; SL.Parent=SC

            -- Trim the lines so they meet the label edges neatly
            SL:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                local half = SL.AbsoluteSize.X/2 + 4
                LL.Size = UDim2.new(0.5,-half,0,1)
                RL.Size = UDim2.new(0.5,-half,0,1)
                RL.Position = UDim2.new(0.5,half,0.5,0)
            end)
        end

        -- ── INPUT ────────────────────────────────────────────────
        --  Text input field; Callback fires on FocusLost
        function PageLibrary.AddInput(Text, Placeholder, Callback)
            local IC=Frame(); IC.Name=Text.."INPUT"; IC.Size=UDim2.new(1,0,0,20)
            IC.BackgroundTransparency=1; IC.Parent=DisplayPage

            local IF=RoundBox(5); IF.ImageColor3=Color3.fromRGB(32,22,26)
            IF.Size=UDim2.new(1,0,1,0); IF.Parent=IC

            -- Left label portion
            local LabelPart=RoundBox(5); LabelPart.ImageColor3=Color3.fromRGB(38,26,30)
            LabelPart.Size=UDim2.new(0.42,0,1,0); LabelPart.Parent=IC

            -- Flat right edge on label part
            local LFlat=Frame(); LFlat.BackgroundColor3=Color3.fromRGB(38,26,30)
            LFlat.Size=UDim2.new(0,5,1,0); LFlat.Position=UDim2.new(1,-5,0,0)
            LFlat.ZIndex=Level; LFlat.Parent=LabelPart

            local LText=TextLabel(Text,12); LText.ZIndex=Level+1; LText.Parent=LabelPart

            -- Input box
            local IBox=TextBox(""        , 12)
            IBox.PlaceholderText=Placeholder or "Type here..."
            IBox.PlaceholderColor3=Color3.fromRGB(130,100,110)
            IBox.ClearTextOnFocus=false
            IBox.TextXAlignment=Enum.TextXAlignment.Left
            IBox.Position=UDim2.new(0.42,4,0,0); IBox.Size=UDim2.new(0.58,-6,1,0)
            IBox.ZIndex=Level+1; IBox.Parent=IC

            -- Bottom focus indicator line
            local FocusLine=Frame()
            FocusLine.BackgroundColor3=AccentColor; FocusLine.BackgroundTransparency=1
            FocusLine.Size=UDim2.new(0,0,0,1); FocusLine.Position=UDim2.new(0,0,1,-1)
            FocusLine.ZIndex=Level+2; FocusLine.Parent=IF

            IBox.Focused:Connect(function()
                Tween(IF,{ImageColor3=Color3.fromRGB(40,28,32)})
                Tween(FocusLine,{BackgroundTransparency=0,Size=UDim2.new(1,0,0,1)},SlowTweenInfo)
            end)
            IBox.FocusLost:Connect(function(enter)
                Tween(IF,{ImageColor3=Color3.fromRGB(32,22,26)})
                Tween(FocusLine,{BackgroundTransparency=1,Size=UDim2.new(0,0,0,1)},SlowTweenInfo)
                if Callback then Callback(IBox.Text, enter) end
            end)
        end

        -- ── KEYBIND ──────────────────────────────────────────────
        --  Click to listen for a key, Callback(newKey) when bound
        function PageLibrary.AddKeybind(Text, Default, Callback)
            local CurrentKey = Default or Enum.KeyCode.Unknown
            local Listening  = false

            local KB=Frame(); KB.Name=Text.."KEYBIND"; KB.Size=UDim2.new(1,0,0,20)
            KB.BackgroundTransparency=1; KB.Parent=DisplayPage

            local KF=RoundBox(5); KF.ImageColor3=Color3.fromRGB(32,22,26)
            KF.Size=UDim2.new(1,0,1,0); KF.Parent=KB

            -- Left label
            local KLabel=RoundBox(5); KLabel.ImageColor3=Color3.fromRGB(38,26,30)
            KLabel.Size=UDim2.new(1,-52,1,0); KLabel.Parent=KB
            local KFlat=Frame(); KFlat.BackgroundColor3=Color3.fromRGB(38,26,30)
            KFlat.Size=UDim2.new(0,5,1,0); KFlat.Position=UDim2.new(1,-5,0,0)
            KFlat.ZIndex=Level; KFlat.Parent=KLabel
            local KText=TextLabel(Text,12); KText.ZIndex=Level+1; KText.Parent=KLabel

            -- Right key badge
            local KBadge=RoundBox(5); KBadge.ImageColor3=Color3.fromRGB(45,32,36)
            KBadge.Size=UDim2.new(0,50,1,0); KBadge.Position=UDim2.new(1,-50,0,0)
            KBadge.ZIndex=Level; KBadge.Parent=KB

            local KBadgeFlat=Frame(); KBadgeFlat.BackgroundColor3=Color3.fromRGB(45,32,36)
            KBadgeFlat.Size=UDim2.new(0,5,1,0); KBadgeFlat.ZIndex=Level; KBadgeFlat.Parent=KBadge

            local function KeyName(kc)
                if kc == Enum.KeyCode.Unknown then return "[None]" end
                return tostring(kc):gsub("Enum.KeyCode.","")
            end

            local KBadgeLabel=TextLabel(KeyName(CurrentKey),10)
            KBadgeLabel.ZIndex=Level+1; KBadgeLabel.Parent=KBadge

            -- Invisible click button
            local KBtn=TextButton("",12); KBtn.ZIndex=Level+2; KBtn.Parent=KB

            KBtn.MouseButton1Down:Connect(function()
                if Listening then return end
                Listening=true
                Tween(KBadge,{ImageColor3=AccentColor})
                KBadgeLabel.Text="..."

                local conn
                conn=UserInputService.InputBegan:Connect(function(inp,gpe)
                    if gpe then return end
                    if inp.UserInputType==Enum.UserInputType.Keyboard then
                        CurrentKey=inp.KeyCode
                        KBadgeLabel.Text=KeyName(CurrentKey)
                        Tween(KBadge,{ImageColor3=Color3.fromRGB(45,32,36)})
                        Listening=false
                        conn:Disconnect()
                        if Callback then Callback(CurrentKey) end
                    end
                end)
            end)

            -- Also fire callback when bound key is pressed during gameplay
            UserInputService.InputBegan:Connect(function(inp,gpe)
                if gpe then return end
                if not Listening and inp.KeyCode==CurrentKey then
                    if Callback then Callback(CurrentKey) end
                end
            end)
        end

        -- ── TEXTINFO ─────────────────────────────────────────────
        --  Read-only display label; returns object with :Set(newText)
        function PageLibrary.AddTextInfo(Text)
            local TIC=Frame(); TIC.Name=Text.."TEXTINFO"; TIC.Size=UDim2.new(1,0,0,20)
            TIC.BackgroundTransparency=1; TIC.Parent=DisplayPage

            local TIF=RoundBox(5); TIF.ImageColor3=Color3.fromRGB(26,18,22)
            TIF.Size=UDim2.new(1,0,1,0); TIF.Parent=TIC

            -- Info icon strip on left
            local InfoStrip=Frame()
            InfoStrip.BackgroundColor3=InfoColor; InfoStrip.BackgroundTransparency=0.5
            InfoStrip.Size=UDim2.new(0,2,0.6,0); InfoStrip.Position=UDim2.new(0,0,0.2,0)
            InfoStrip.ZIndex=Level; InfoStrip.Parent=TIC
            Corner(InfoStrip,2)

            local TILabel=TextLabel(Text,12)
            TILabel.TextXAlignment=Enum.TextXAlignment.Left
            TILabel.Position=UDim2.new(0,8,0,0)
            TILabel.Size=UDim2.new(1,-8,1,0)
            TILabel.TextColor3=Color3.fromRGB(190,180,185)
            TILabel.ZIndex=Level+1; TILabel.Parent=TIC

            -- Return object with Set method
            local InfoObject = {}
            function InfoObject.Set(NewText)
                TILabel.Text = NewText or ""
            end
            return InfoObject
        end

        -- ── DROPDOWN ─────────────────────────────────────────────
        function PageLibrary.AddDropdown(Text, ConfigArray, Callback)
            local Arr=ConfigArray or {}; local Toggle=false
            local DC=Frame(); DC.Size=UDim2.new(1,0,0,20); DC.Name=Text.."DROPDOWN"
            DC.BackgroundTransparency=1; DC.Parent=DisplayPage
            local DF=RoundBox(5); DF.ClipsDescendants=true; DF.ImageColor3=Color3.fromRGB(32,22,26)
            DF.Size=UDim2.new(1,0,1,0); DF.Parent=DC
            local DE=DropdownIcon(true); DE.Parent=DF
            local DL=TextLabel(Text,12); DL.Size=UDim2.new(1,0,0,20); DL.Parent=DF
            local DFrame=Frame(); DFrame.Position=UDim2.new(0,0,0,20)
            DFrame.BackgroundTransparency=1; DFrame.Size=UDim2.new(1,0,0,#Arr*20); DFrame.Parent=DF
            Instance.new("UIListLayout").Parent=DFrame
            for idx,opt in next,Arr do
                PageLibrary.AddButton(opt,function() Callback(opt); DL.Text=Text..": "..opt end,DFrame,idx<#Arr)
            end
            DE.MouseButton1Down:Connect(function()
                Toggle=not Toggle
                Tween(DC,{Size=Toggle and UDim2.new(1,0,0,20+(#Arr*20)) or UDim2.new(1,0,0,20)})
                Tween(DE,{Rotation=Toggle and 135 or 0})
            end)
        end

        -- ── COLOUR PICKER ────────────────────────────────────────
        function PageLibrary.AddColourPicker(Text, DefaultColour, Callback)
            DefaultColour=DefaultColour or Color3.fromRGB(255,255,255)
            local cd={white=Color3.fromRGB(255,255,255),black=Color3.fromRGB(0,0,0),
                      red=Color3.fromRGB(255,0,0),green=Color3.fromRGB(0,255,0),blue=Color3.fromRGB(0,0,255)}
            if typeof(DefaultColour)=="table" then
                DefaultColour=Color3.fromRGB(DefaultColour[1] or 255,DefaultColour[2] or 255,DefaultColour[3] or 255)
            elseif typeof(DefaultColour)=="string" then
                DefaultColour=cd[DefaultColour:lower()] or cd["white"]
            end
            local PC=Frame(); PC.ClipsDescendants=true; PC.Size=UDim2.new(1,0,0,20)
            PC.Name=Text.."COLOURPICKER"; PC.BackgroundTransparency=1; PC.Parent=DisplayPage
            local CT=Instance.new("Color3Value"); CT.Value=DefaultColour; CT.Parent=PC
            local PL,PR,PF=RoundBox(5),RoundBox(5),RoundBox(5)
            PL.Size=UDim2.new(1,-22,1,0); PL.ImageColor3=Color3.fromRGB(32,22,26); PL.Parent=PC
            PR.Size=UDim2.new(0,20,1,0); PR.Position=UDim2.new(1,-20,0,0); PR.ImageColor3=DefaultColour; PR.Parent=PC
            PF.ImageColor3=Color3.fromRGB(32,22,26); PF.Size=UDim2.new(1,-22,0,60)
            PF.Position=UDim2.new(0,0,0,20); PF.Parent=PC
            local Plist=Instance.new("UIListLayout"); Plist.SortOrder=Enum.SortOrder.LayoutOrder; Plist.Parent=PF
            PageLibrary.AddSlider("R",{Min=0,Max=255,Def=CT.Value.R*255},function(v) CT.Value=Color3.fromRGB(v,CT.Value.G*255,CT.Value.B*255); Callback(CT.Value) end,PF)
            PageLibrary.AddSlider("G",{Min=0,Max=255,Def=CT.Value.G*255},function(v) CT.Value=Color3.fromRGB(CT.Value.R*255,v,CT.Value.B*255); Callback(CT.Value) end,PF)
            PageLibrary.AddSlider("B",{Min=0,Max=255,Def=CT.Value.B*255},function(v) CT.Value=Color3.fromRGB(CT.Value.R*255,CT.Value.G*255,v); Callback(CT.Value) end,PF)
            local EL,ER=Frame(),Frame()
            EL.BackgroundColor3=Color3.fromRGB(32,22,26); EL.Position=UDim2.new(1,-5,0,0); EL.Size=UDim2.new(0,5,1,0); EL.Parent=PL
            ER.BackgroundColor3=DefaultColour; ER.Size=UDim2.new(0,5,1,0); ER.Parent=PR
            local Plabel=TextLabel(Text,12); Plabel.Size=UDim2.new(1,0,0,20); Plabel.Parent=PL
            CT:GetPropertyChangedSignal("Value"):Connect(function() ER.BackgroundColor3=CT.Value; PR.ImageColor3=CT.Value end)
            local pt=false; local pb=TextButton(""); pb.Parent=PR
            pb.MouseButton1Down:Connect(function()
                pt=not pt
                Tween(PC,{Size=pt and UDim2.new(1,0,0,80) or UDim2.new(1,0,0,20)})
            end)
        end

        -- ── SLIDER ───────────────────────────────────────────────
        function PageLibrary.AddSlider(Text, Config, Callback, Parent)
            local Min=Config.Minimum or Config.minimum or Config.Min or Config.min
            local Max=Config.Maximum or Config.maximum or Config.Max or Config.max
            local Def=Config.Default or Config.default or Config.Def or Config.def
            if Min>Max then Min,Max=Max,Min end
            Def=math.clamp(Def,Min,Max); local DS=Def/Max
            local SC=Frame(); SC.Name=Text.."SLIDER"; SC.Size=UDim2.new(1,0,0,20)
            SC.BackgroundTransparency=1; SC.Parent=Parent or DisplayPage
            local SF=RoundBox(5); SF.Name="SliderForeground"; SF.ImageColor3=Color3.fromRGB(32,22,26)
            SF.Size=UDim2.new(1,0,1,0); SF.Parent=SC
            local SB=TextButton(Text..": "..Def); SB.Size=UDim2.new(1,0,1,0); SB.ZIndex=6; SB.Parent=SF
            local Fill=RoundBox(5); Fill.Size=UDim2.new(DS,0,1,0); Fill.ImageColor3=Color3.fromRGB(65,45,52)
            Fill.ZIndex=5; Fill.ImageTransparency=0.7; Fill.Parent=SB
            SB.MouseButton1Down:Connect(function()
                Tween(Fill,{ImageTransparency=0.5})
                local _,_,xs=GetXY(SB); local val=math.floor(Min+(Max-Min)*xs)
                Callback(val); SB.Text=Text..": "..val; Tween(Fill,{Size=UDim2.new(xs,0,1,0)})
                local smv,skl
                smv=Mouse.Move:Connect(function()
                    Tween(Fill,{ImageTransparency=0.5})
                    local _,_,xs2=GetXY(SB); local v2=math.floor(Min+(Max-Min)*xs2)
                    Callback(v2); SB.Text=Text..": "..v2; Tween(Fill,{Size=UDim2.new(xs2,0,1,0)})
                end)
                skl=UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                        Tween(Fill,{ImageTransparency=0.7}); smv:Disconnect(); skl:Disconnect()
                    end
                end)
            end)
        end

        -- ── TOGGLE ───────────────────────────────────────────────
        function PageLibrary.AddToggle(Text, Default, Callback)
            local State=Default or false
            local TC=Frame(); TC.Name=Text.."TOGGLE"; TC.Size=UDim2.new(1,0,0,20)
            TC.BackgroundTransparency=1; TC.Parent=DisplayPage
            local TL,TR=RoundBox(5),RoundBox(5)
            local EF,RT=Frame(),TickIcon()
            local FL,FR=Frame(),Frame()
            TL.Size=UDim2.new(1,-22,1,0); TL.ImageColor3=Color3.fromRGB(32,22,26); TL.Parent=TC
            TR.Position=UDim2.new(1,-20,0,0); TR.Size=UDim2.new(0,20,1,0)
            TR.ImageColor3=Color3.fromRGB(42,30,34); TR.Parent=TC
            FL.BackgroundColor3=Color3.fromRGB(32,22,26); FL.Size=UDim2.new(0,5,1,0)
            FL.Position=UDim2.new(1,-5,0,0); FL.Parent=TL
            FR.BackgroundColor3=Color3.fromRGB(42,30,34); FR.Size=UDim2.new(0,5,1,0); FR.Parent=TR
            EF.BackgroundColor3=State and SuccessColor or ErrorColor
            EF.Position=UDim2.new(1,-22,0.2,0); EF.Size=UDim2.new(0,2,0.6,0); EF.Parent=TC
            RT.ImageTransparency=State and 0 or 1; RT.Parent=TR
            local TB=TextButton(Text,12); TB.Name="ToggleButton"; TB.Parent=TL
            TB.MouseButton1Down:Connect(function()
                State=not State
                Tween(EF,{BackgroundColor3=State and SuccessColor or ErrorColor})
                Tween(RT,{ImageTransparency=State and 0 or 1})
                Callback(State)
            end)
        end

        return PageLibrary
    end

    -- Expose Notify on the TabLibrary too so callers can use either reference
    TabLibrary.Notify = UILibrary.Notify

    return TabLibrary
end

return UILibrary
