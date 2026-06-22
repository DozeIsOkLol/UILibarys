-- MeisterUI Advanced Library v2.0
-- Sleek, Modern, Dark/Grey Theme with Animations and Notifications

local MeisterUI = {}

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Protect UI
local ParentGui = CoreGui
if gethui then
    ParentGui = gethui()
elseif set_thread_identity then
    set_thread_identity(8)
end

-- Create ScreenGui
local ScreenObject = Instance.new("ScreenGui")
ScreenObject.Name = "MeisterUI_Environment"
ScreenObject.IgnoreGuiInset = true
ScreenObject.ResetOnSpawn = false
ScreenObject.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenObject.Parent = ParentGui

-- Destroy old instances
if ParentGui:FindFirstChild("MeisterUI_Environment") then
    for _, v in pairs(ParentGui:GetChildren()) do
        if v.Name == "MeisterUI_Environment" and v ~= ScreenObject then
            v:Destroy()
        end
    end
end

-- Notification Container
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Parent = ScreenObject
NotifContainer.BackgroundTransparency = 1
NotifContainer.Position = UDim2.new(1, -320, 1, -20)
NotifContainer.Size = UDim2.new(0, 300, 1, 0)
NotifContainer.AnchorPoint = Vector2.new(0, 1)

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Parent = NotifContainer
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 10)

-- Core Functions
local Utility = {}
function Utility:Tween(object, info, properties)
    local t = TweenService:Create(object, TweenInfo.new(unpack(info)), properties)
    t:Play()
    return t
end

function Utility:MakeDraggable(topbar, object)
    local Dragging, DragInput, DragStart, StartPosition
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local delta = input.Position - DragStart
            Utility:Tween(object, {0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, {
                Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
            })
        end
    end)
end

-- Notification System
function MeisterUI:Notify(options)
    local title = options.Title or "Notification"
    local content = options.Content or "Notification content."
    local duration = options.Duration or 3

    local NotifFrame = Instance.new("Frame")
    NotifFrame.Name = "Notification"
    NotifFrame.Parent = NotifContainer
    NotifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Size = UDim2.new(1, 40, 0, 0) -- Starts off screen
    NotifFrame.Position = UDim2.new(1, 50, 0, 0)
    NotifFrame.ClipsDescendants = true
    NotifFrame.BackgroundTransparency = 1

    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 8)
    NotifCorner.Parent = NotifFrame

    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Parent = NotifFrame
    NotifStroke.Color = Color3.fromRGB(60, 60, 65)
    NotifStroke.Thickness = 1
    NotifStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    NotifStroke.Transparency = 1

    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Parent = NotifFrame
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Position = UDim2.new(0, 15, 0, 10)
    NotifTitle.Size = UDim2.new(1, -30, 0, 20)
    NotifTitle.Font = Enum.Font.Ubuntu
    NotifTitle.Text = title
    NotifTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
    NotifTitle.TextSize = 14
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.TextTransparency = 1

    local NotifText = Instance.new("TextLabel")
    NotifText.Parent = NotifFrame
    NotifText.BackgroundTransparency = 1
    NotifText.Position = UDim2.new(0, 15, 0, 32)
    NotifText.Size = UDim2.new(1, -30, 0, 40)
    NotifText.Font = Enum.Font.Ubuntu
    NotifText.Text = content
    NotifText.TextColor3 = Color3.fromRGB(180, 180, 180)
    NotifText.TextSize = 13
    NotifText.TextXAlignment = Enum.TextXAlignment.Left
    NotifText.TextYAlignment = Enum.TextYAlignment.Top
    NotifText.TextWrapped = true
    NotifText.TextTransparency = 1

    local ProgressBarBG = Instance.new("Frame")
    ProgressBarBG.Parent = NotifFrame
    ProgressBarBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ProgressBarBG.Position = UDim2.new(0, 15, 1, -8)
    ProgressBarBG.Size = UDim2.new(1, -30, 0, 3)
    ProgressBarBG.BorderSizePixel = 0
    ProgressBarBG.BackgroundTransparency = 1

    local ProgressBarBGCorner = Instance.new("UICorner")
    ProgressBarBGCorner.CornerRadius = UDim.new(1, 0)
    ProgressBarBGCorner.Parent = ProgressBarBG

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Parent = ProgressBarBG
    ProgressBar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    ProgressBar.Size = UDim2.new(1, 0, 1, 0)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.BackgroundTransparency = 1

    local ProgressBarCorner = Instance.new("UICorner")
    ProgressBarCorner.CornerRadius = UDim.new(1, 0)
    ProgressBarCorner.Parent = ProgressBar

    -- Calculate Height
    local bounds = TextService:GetTextSize(content, 13, Enum.Font.Ubuntu, Vector2.new(270, math.huge))
    local totalHeight = 55 + bounds.Y
    
    -- Animate In
    Utility:Tween(NotifFrame, {0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {Size = UDim2.new(1, 0, 0, totalHeight), BackgroundTransparency = 0})
    Utility:Tween(NotifStroke, {0.4}, {Transparency = 0})
    Utility:Tween(NotifTitle, {0.3}, {TextTransparency = 0})
    Utility:Tween(NotifText, {0.3}, {TextTransparency = 0})
    Utility:Tween(ProgressBarBG, {0.3}, {BackgroundTransparency = 0})
    Utility:Tween(ProgressBar, {0.3}, {BackgroundTransparency = 0})

    -- Progress
    Utility:Tween(ProgressBar, {duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In}, {Size = UDim2.new(0, 0, 1, 0)})

    -- Animate Out
    task.delay(duration, function()
        Utility:Tween(NotifTitle, {0.3}, {TextTransparency = 1})
        Utility:Tween(NotifText, {0.3}, {TextTransparency = 1})
        Utility:Tween(ProgressBarBG, {0.3}, {BackgroundTransparency = 1})
        Utility:Tween(ProgressBar, {0.3}, {BackgroundTransparency = 1})
        local hideTween = Utility:Tween(NotifFrame, {0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In}, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
        Utility:Tween(NotifStroke, {0.4}, {Transparency = 1})
        
        hideTween.Completed:Connect(function()
            NotifFrame:Destroy()
        end)
    end)
end

function MeisterUI:CreateWindow(options)
    local WindowName = options.Name or "MeisterUI"
    local HideKey = options.HideKey or Enum.KeyCode.Insert
    
    local WindowOpen = false

    -- Loading Screen Fullscreen
    local IntroOverlay = Instance.new("Frame")
    IntroOverlay.Name = "IntroOverlay"
    IntroOverlay.Parent = ScreenObject
    IntroOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    IntroOverlay.Position = UDim2.new(0, 0, 0, 0)
    IntroOverlay.Size = UDim2.new(1, 0, 1, 0)
    IntroOverlay.ZIndex = 100
    IntroOverlay.BackgroundTransparency = 1 -- Start transparent and fade to solid black

    local IntroTitle = Instance.new("TextLabel")
    IntroTitle.Parent = IntroOverlay
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.Position = UDim2.new(0.5, -200, 0.5, -40)
    IntroTitle.Size = UDim2.new(0, 400, 0, 80)
    IntroTitle.Font = Enum.Font.Code
    IntroTitle.Text = "SARHUB BY SARpastes"
    IntroTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
    IntroTitle.TextScaled = true
    IntroTitle.TextTransparency = 1


    -- Main UI Elements
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenObject
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -200)
    MainFrame.Size = UDim2.new(0, 650, 0, 400)
    MainFrame.Visible = false

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = MainFrame
    MainStroke.Color = Color3.fromRGB(50, 50, 55)
    MainStroke.Thickness = 1
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Drop Shadow (Fake)
    local ShadowFrame = Instance.new("Frame")
    ShadowFrame.Name = "Shadow"
    ShadowFrame.Parent = MainFrame
    ShadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ShadowFrame.Size = UDim2.new(1, 10, 1, 10)
    ShadowFrame.Position = UDim2.new(0, -5, 0, -5)
    ShadowFrame.BackgroundTransparency = 0.8
    ShadowFrame.ZIndex = -1
    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 14)
    ShadowCorner.Parent = ShadowFrame

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.Size = UDim2.new(0, 180, 1, -35)
    Sidebar.BorderSizePixel = 0
    Sidebar.ClipsDescendants = true
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = Sidebar
    
    local SidebarFix = Instance.new("Frame")
    SidebarFix.Parent = Sidebar
    SidebarFix.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    SidebarFix.Position = UDim2.new(1, -10, 0, 0)
    SidebarFix.Size = UDim2.new(0, 10, 1, 0)
    SidebarFix.BorderSizePixel = 0

    local SidebarFixTop = Instance.new("Frame")
    SidebarFixTop.Parent = Sidebar
    SidebarFixTop.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    SidebarFixTop.Position = UDim2.new(0, 0, 0, 0)
    SidebarFixTop.Size = UDim2.new(1, 0, 0, 10)
    SidebarFixTop.BorderSizePixel = 0

    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Parent = Sidebar
    SidebarDivider.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.BorderSizePixel = 0

    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Parent = MainFrame
    Topbar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Topbar.Size = UDim2.new(1, 0, 0, 35)
    Topbar.BorderSizePixel = 0
    Topbar.ZIndex = 5
    
    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 10)
    TopbarCorner.Parent = Topbar
    
    local TopbarFix = Instance.new("Frame")
    TopbarFix.Parent = Topbar
    TopbarFix.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    TopbarFix.Position = UDim2.new(0, 0, 1, -10)
    TopbarFix.Size = UDim2.new(1, 0, 0, 10)
    TopbarFix.BorderSizePixel = 0

    local TopbarDivider = Instance.new("Frame")
    TopbarDivider.Parent = Topbar
    TopbarDivider.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    TopbarDivider.Position = UDim2.new(0, 0, 1, -1)
    TopbarDivider.Size = UDim2.new(1, 0, 0, 1)
    TopbarDivider.BorderSizePixel = 0

    Utility:MakeDraggable(Topbar, MainFrame)
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Topbar
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -40, 0, 0)
    CloseBtn.Size = UDim2.new(0, 40, 1, 0)
    CloseBtn.Font = Enum.Font.Ubuntu
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    CloseBtn.TextSize = 14
    CloseBtn.AutoButtonColor = false

    CloseBtn.MouseEnter:Connect(function()
        Utility:Tween(CloseBtn, {0.2}, {TextColor3 = Color3.fromRGB(255, 100, 100)})
    end)
    CloseBtn.MouseLeave:Connect(function()
        Utility:Tween(CloseBtn, {0.2}, {TextColor3 = Color3.fromRGB(150, 150, 150)})
    end)

    local MainTitle = Instance.new("TextLabel")
    MainTitle.Parent = Topbar
    MainTitle.BackgroundTransparency = 1
    MainTitle.Position = UDim2.new(0, 15, 0, 0)
    MainTitle.Size = UDim2.new(1, -60, 1, 0)
    MainTitle.Font = Enum.Font.Ubuntu
    MainTitle.Text = WindowName
    MainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainTitle.TextSize = 14
    MainTitle.TextXAlignment = Enum.TextXAlignment.Left
    MainTitle.TextYAlignment = Enum.TextYAlignment.Center
    MainTitle.TextTruncate = Enum.TextTruncate.AtEnd

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Sidebar
    TabContainer.Active = true
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 0, 0, 10)
    TabContainer.Size = UDim2.new(1, 0, 1, -80)
    TabContainer.ScrollBarThickness = 2
    TabContainer.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 55)
    
    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)

    local TabPadding = Instance.new("UIPadding")
    TabPadding.Parent = TabContainer
    TabPadding.PaddingTop = UDim.new(0, 5)
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)

    -- BUG FIX: CanvasSize tablar eklendikce guncellenir, yoksa tablar gorunmez
    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 15)
    end)

    -- Player Profile
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local MarketplaceService = game:GetService("MarketplaceService")

    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Name = "ProfileFrame"
    ProfileFrame.Parent = Sidebar
    ProfileFrame.BackgroundTransparency = 1
    ProfileFrame.Position = UDim2.new(0, 10, 1, -60)
    ProfileFrame.Size = UDim2.new(1, -20, 0, 50)
    ProfileFrame.ClipsDescendants = true

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Parent = ProfileFrame
    AvatarImage.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    AvatarImage.Size = UDim2.new(0, 34, 0, 34)
    AvatarImage.Position = UDim2.new(0, 0, 0.5, -17)
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarImage
    
    local NameLab = Instance.new("TextLabel")
    NameLab.Parent = ProfileFrame
    NameLab.BackgroundTransparency = 1
    NameLab.Position = UDim2.new(0, 42, 0, 8)
    NameLab.Size = UDim2.new(1, -42, 0, 16)
    NameLab.Font = Enum.Font.Ubuntu
    NameLab.Text = LocalPlayer and LocalPlayer.Name or "Unknown"
    NameLab.TextColor3 = Color3.fromRGB(240, 240, 240)
    NameLab.TextSize = 13
    NameLab.TextXAlignment = Enum.TextXAlignment.Left
    NameLab.TextTruncate = Enum.TextTruncate.AtEnd

    local GameLab = Instance.new("TextLabel")
    GameLab.Parent = ProfileFrame
    GameLab.BackgroundTransparency = 1
    GameLab.Position = UDim2.new(0, 42, 0, 24)
    GameLab.Size = UDim2.new(1, -42, 0, 14)
    GameLab.Font = Enum.Font.Ubuntu
    GameLab.Text = "Loading..."
    GameLab.TextColor3 = Color3.fromRGB(150, 150, 150)
    GameLab.TextSize = 11
    GameLab.TextXAlignment = Enum.TextXAlignment.Left
    GameLab.TextTruncate = Enum.TextTruncate.AtEnd

    -- Fetch Avatar
    task.spawn(function()
        if LocalPlayer then
            local success, avatarUrl = pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            end)
            if success then
                AvatarImage.Image = avatarUrl
            end
        end
    end)

    -- Fetch Game Name
    task.spawn(function()
        local success, info = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId)
        end)
        if success and info and info.Name then
            GameLab.Text = info.Name
        else
            GameLab.Text = "Unknown Game"
        end
    end)

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 181, 0, 35)
    ContentArea.Size = UDim2.new(1, -181, 1, -35)

    task.spawn(function()
        -- 1. Full black screen fade in
        Utility:Tween(IntroOverlay, {0.5}, {BackgroundTransparency = 0})
        task.wait(0.6)
        
        -- 2. Fade in text smoothly
        Utility:Tween(IntroTitle, {1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {TextTransparency = 0})
        
        -- Pulse text size animation
        local glowTween = Utility:Tween(IntroTitle, {1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut}, {
            Size = UDim2.new(0, 480, 0, 96), 
            Position = UDim2.new(0.5, -240, 0.5, -48)
        })
        
        task.wait(1.5)
        
        -- 3. Fade out text
        Utility:Tween(IntroTitle, {0.6}, {
            TextTransparency = 1, 
            Size = UDim2.new(0, 600, 0, 120), 
            Position = UDim2.new(0.5, -300, 0.5, -60)
        })
        task.wait(0.7)
        
        -- 4. Setup Main Hub to start small and then grow as background fades
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 550, 0, 300)
        MainFrame.Position = UDim2.new(0.5, -275, 0.5, -150)
        
        -- Use a task.delay failsafe in case Tweens get hung
        task.delay(1.5, function()
            if IntroOverlay and IntroOverlay.Parent then
                IntroOverlay:Destroy()
            end
        end)
        
        local fadeBg = Utility:Tween(IntroOverlay, {0.8}, {BackgroundTransparency = 1})
        Utility:Tween(MainFrame, {0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {
            Size = UDim2.new(0, 650, 0, 400), 
            Position = UDim2.new(0.5, -325, 0.5, -200)
        })
        
        fadeBg.Completed:Connect(function()
            if IntroOverlay and IntroOverlay.Parent then IntroOverlay:Destroy() end
            WindowOpen = true
            MeisterUI:Notify({Title = "Loaded", Content = "meister module loaded successfully.", Duration = 4})
        end)
    end)
    
    local function ToggleUI(state)
        WindowOpen = state
        if WindowOpen then
            MainFrame.Visible = true
            Utility:Tween(MainFrame, {0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Size = UDim2.new(0, 650, 0, 400), Position = UDim2.new(0.5, -325, 0.5, -200)})
        else
            local closeTween = Utility:Tween(MainFrame, {0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In}, {Size = UDim2.new(0, 500, 0, 250), Position = UDim2.new(0.5, -250, 0.5, -125)})
            closeTween.Completed:Connect(function()
                if not WindowOpen then MainFrame.Visible = false end
            end)
            MeisterUI:Notify({Title = "UI Hidden", Content = "Press INSERT to open the menu again.", Duration = 4})
        end
    end

    CloseBtn.MouseButton1Click:Connect(function()
        if WindowOpen then
            ToggleUI(false)
        end
    end)

    -- Toggle Logic
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == HideKey and not ParentGui:FindFirstChild("IntroOverlay") then
            ToggleUI(not WindowOpen)
        end
    end)

    local Window = {}
    local Pages = {}
    local activeTabBtn = nil

    function Window:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName.."_Btn"
        TabBtn.Parent = TabContainer
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.Font = Enum.Font.Ubuntu
        TabBtn.Text = "   " .. tabName
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.TextSize = 14
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.AutoButtonColor = false

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabBtn

        local SelectedIndicator = Instance.new("Frame")
        SelectedIndicator.Parent = TabBtn
        SelectedIndicator.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        SelectedIndicator.Size = UDim2.new(0, 3, 0, 0)
        SelectedIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        SelectedIndicator.AnchorPoint = Vector2.new(0, 0.5)
        local IndCorner = Instance.new("UICorner")
        IndCorner.CornerRadius = UDim.new(1, 0)
        IndCorner.Parent = SelectedIndicator

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = tabName.."_Page"
        TabPage.Parent = ContentArea
        TabPage.Active = true
        TabPage.BackgroundTransparency = 1
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 55)
        TabPage.Visible = false
        TabPage.CanvasSize = UDim2.new(0,0,0,0)
        
        table.insert(Pages, TabPage)

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = TabPage
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 10)

        local PagePadding = Instance.new("UIPadding")
        PagePadding.Parent = TabPage
        PagePadding.PaddingTop = UDim.new(0, 10)
        PagePadding.PaddingBottom = UDim.new(0, 20)
        PagePadding.PaddingLeft = UDim.new(0, 20)
        PagePadding.PaddingRight = UDim.new(0, 20)

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 30)
        end)

        local function ActivateTab()
            for _, child in pairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    Utility:Tween(child, {0.3}, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)})
                    local ind = child:FindFirstChild("Frame")
                    if ind then Utility:Tween(ind, {0.3}, {Size = UDim2.new(0, 3, 0, 0)}) end
                end
            end
            for _, page in pairs(Pages) do
                if page.Visible then
                    page.Visible = false
                    page.Position = UDim2.new(0, 10, 0, 0)
                end
            end

            Utility:Tween(TabBtn, {0.3}, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(240, 240, 240)})
            Utility:Tween(SelectedIndicator, {0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {Size = UDim2.new(0, 3, 0, 18)})
            
            TabPage.Visible = true
            Utility:Tween(TabPage, {0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Position = UDim2.new(0, 0, 0, 0)})
        end

        TabBtn.MouseButton1Click:Connect(ActivateTab)

        if #Pages == 1 then
            ActivateTab()
        end

        local Elements = {}

        -- BUTTON
        function Elements:CreateButton(options)
            local name = options.Name or "Button"
            local callback = options.Callback or function() end

            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Parent = TabPage
            ButtonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            ButtonFrame.Size = UDim2.new(1, 0, 0, 42)
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = ButtonFrame
            
            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Parent = ButtonFrame
            BtnStroke.Color = Color3.fromRGB(45, 45, 50)
            BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local BtnButton = Instance.new("TextButton")
            BtnButton.Parent = ButtonFrame
            BtnButton.BackgroundTransparency = 1
            BtnButton.Size = UDim2.new(1, 0, 1, 0)
            BtnButton.Text = ""

            local BtnText = Instance.new("TextLabel")
            BtnText.Parent = ButtonFrame
            BtnText.BackgroundTransparency = 1
            BtnText.Position = UDim2.new(0, 15, 0, 0)
            BtnText.Size = UDim2.new(1, -30, 1, 0)
            BtnText.Font = Enum.Font.Ubuntu
            BtnText.Text = name
            BtnText.TextColor3 = Color3.fromRGB(220, 220, 220)
            BtnText.TextSize = 14
            BtnText.TextXAlignment = Enum.TextXAlignment.Left
            BtnText.TextTruncate = Enum.TextTruncate.AtEnd

            local BtnIcon = Instance.new("ImageLabel")
            BtnIcon.Parent = ButtonFrame
            BtnIcon.BackgroundTransparency = 1
            BtnIcon.Position = UDim2.new(1, -30, 0.5, -8)
            BtnIcon.Size = UDim2.new(0, 16, 0, 16)
            BtnIcon.Image = "rbxassetid://10888331510" -- Pointer icon
            BtnIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)

            BtnButton.MouseEnter:Connect(function()
                Utility:Tween(ButtonFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(40, 40, 45)})
                Utility:Tween(BtnIcon, {0.2}, {Position = UDim2.new(1, -25, 0.5, -8), ImageColor3 = Color3.fromRGB(255, 255, 255)})
            end)

            BtnButton.MouseLeave:Connect(function()
                Utility:Tween(ButtonFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)})
                Utility:Tween(BtnIcon, {0.2}, {Position = UDim2.new(1, -30, 0.5, -8), ImageColor3 = Color3.fromRGB(150, 150, 150)})
            end)

            BtnButton.MouseButton1Down:Connect(function()
                Utility:Tween(ButtonFrame, {0.1}, {Size = UDim2.new(1, -4, 0, 38)})
                Utility:Tween(BtnStroke, {0.1}, {Color = Color3.fromRGB(100, 100, 110)})
            end)

            BtnButton.MouseButton1Up:Connect(function()
                Utility:Tween(ButtonFrame, {0.1}, {Size = UDim2.new(1, 0, 0, 42)})
                Utility:Tween(BtnStroke, {0.1}, {Color = Color3.fromRGB(45, 45, 50)})
                callback()
            end)
        end

        -- TOGGLE
        function Elements:CreateToggle(options)
            local name = options.Name or "Toggle"
            local default = options.CurrentValue or false
            local callback = options.Callback or function() end

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Parent = TabPage
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            ToggleFrame.Size = UDim2.new(1, 0, 0, 42)
            
            local TglCorner = Instance.new("UICorner")
            TglCorner.CornerRadius = UDim.new(0, 6)
            TglCorner.Parent = ToggleFrame
            
            local TglStroke = Instance.new("UIStroke")
            TglStroke.Parent = ToggleFrame
            TglStroke.Color = Color3.fromRGB(45, 45, 50)
            TglStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local TglButton = Instance.new("TextButton")
            TglButton.Parent = ToggleFrame
            TglButton.BackgroundTransparency = 1
            TglButton.Size = UDim2.new(1, 0, 1, 0)
            TglButton.Text = ""

            local TglText = Instance.new("TextLabel")
            TglText.Parent = ToggleFrame
            TglText.BackgroundTransparency = 1
            TglText.Position = UDim2.new(0, 15, 0, 0)
            TglText.Size = UDim2.new(1, -60, 1, 0)
            TglText.Font = Enum.Font.Ubuntu
            TglText.Text = name
            TglText.TextColor3 = Color3.fromRGB(220, 220, 220)
            TglText.TextSize = 14
            TglText.TextXAlignment = Enum.TextXAlignment.Left
            TglText.TextTruncate = Enum.TextTruncate.AtEnd

            local SliderBG = Instance.new("Frame")
            SliderBG.Parent = ToggleFrame
            SliderBG.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
            SliderBG.Position = UDim2.new(1, -45, 0.5, -12)
            SliderBG.Size = UDim2.new(0, 36, 0, 24)
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(1, 0)
            SCorner.Parent = SliderBG

            local SStroke = Instance.new("UIStroke")
            SStroke.Parent = SliderBG
            SStroke.Color = Color3.fromRGB(50, 50, 55)

            local SliderCircle = Instance.new("Frame")
            SliderCircle.Parent = SliderBG
            SliderCircle.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
            SliderCircle.Position = UDim2.new(0, 4, 0.5, -8)
            SliderCircle.Size = UDim2.new(0, 16, 0, 16)
            local CCorner = Instance.new("UICorner")
            CCorner.CornerRadius = UDim.new(1, 0)
            CCorner.Parent = SliderCircle

            local toggled = default

            local function updateToggle(anim)
                local time = anim and 0.25 or 0
                if toggled then
                    Utility:Tween(SliderBG, {time}, {BackgroundColor3 = Color3.fromRGB(220, 220, 220)})
                    Utility:Tween(SliderCircle, {time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Position = UDim2.new(1, -20, 0.5, -8), BackgroundColor3 = Color3.fromRGB(30, 30, 35)})
                    Utility:Tween(SStroke, {time}, {Color = Color3.fromRGB(220, 220, 220)})
                else
                    Utility:Tween(SliderBG, {time}, {BackgroundColor3 = Color3.fromRGB(20, 20, 22)})
                    Utility:Tween(SliderCircle, {time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Position = UDim2.new(0, 4, 0.5, -8), BackgroundColor3 = Color3.fromRGB(150, 150, 150)})
                    Utility:Tween(SStroke, {time}, {Color = Color3.fromRGB(50, 50, 55)})
                end
            end

            updateToggle(false)

            TglButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                updateToggle(true)
                callback(toggled)
            end)

            TglButton.MouseEnter:Connect(function()
                Utility:Tween(ToggleFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(35, 35, 40)})
            end)
            TglButton.MouseLeave:Connect(function()
                Utility:Tween(ToggleFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)})
            end)
        end

        -- SLIDER
        function Elements:CreateSlider(options)
            local name     = options.Name or "Slider"
            local min      = options.Range[1] or 0
            local max      = options.Range[2] or 100
            local default  = options.CurrentValue or min
            local increment= options.Increment or 1
            local callback = options.Callback or function() end
            -- Detect float mode: increment < 1 or either bound is float
            local isFloat  = (increment < 1) or (math.floor(min) ~= min) or (math.floor(max) ~= max)
            local decimals = 0
            if isFloat then
                local s = tostring(increment)
                local dot = s:find("%.") 
                decimals = dot and (#s - dot) or 2
            end

            local function snap(v)
                if increment <= 0 then return v end
                local snapped = math.floor((v - min) / increment + 0.5) * increment + min
                snapped = math.clamp(snapped, min, max)
                if isFloat then
                    return tonumber(string.format("%%.%df" % decimals, snapped))
                end
                return math.floor(snapped + 0.5)
            end

            local function fmt(v)
                if isFloat then return string.format("%%.%df" % decimals, v) end
                return tostring(math.floor(v + 0.5))
            end

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Parent = TabPage
            SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            SliderFrame.Size = UDim2.new(1, 0, 0, 60)

            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(0, 6)
            SCorner.Parent = SliderFrame

            local SStroke = Instance.new("UIStroke")
            SStroke.Parent = SliderFrame
            SStroke.Color = Color3.fromRGB(45, 45, 50)
            SStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local TitleLab = Instance.new("TextLabel")
            TitleLab.Parent = SliderFrame
            TitleLab.BackgroundTransparency = 1
            TitleLab.Position = UDim2.new(0, 15, 0, 10)
            TitleLab.Size = UDim2.new(1, -30, 0, 20)
            TitleLab.Font = Enum.Font.Ubuntu
            TitleLab.Text = name
            TitleLab.TextColor3 = Color3.fromRGB(220, 220, 220)
            TitleLab.TextSize = 14
            TitleLab.TextXAlignment = Enum.TextXAlignment.Left
            TitleLab.TextTruncate = Enum.TextTruncate.AtEnd

            local ValueLab = Instance.new("TextLabel")
            ValueLab.Parent = SliderFrame
            ValueLab.BackgroundTransparency = 1
            ValueLab.Position = UDim2.new(0, 15, 0, 10)
            ValueLab.Size = UDim2.new(1, -30, 0, 20)
            ValueLab.Font = Enum.Font.Ubuntu
            ValueLab.Text = fmt(default)
            ValueLab.TextColor3 = Color3.fromRGB(150, 150, 150)
            ValueLab.TextSize = 14
            ValueLab.TextXAlignment = Enum.TextXAlignment.Right

            local TrackBG = Instance.new("Frame")
            TrackBG.Parent = SliderFrame
            TrackBG.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
            TrackBG.Position = UDim2.new(0, 15, 1, -15)
            TrackBG.Size = UDim2.new(1, -30, 0, 6)
            local TCorner = Instance.new("UICorner")
            TCorner.CornerRadius = UDim.new(1, 0)
            TCorner.Parent = TrackBG

            local TrackFill = Instance.new("Frame")
            TrackFill.Parent = TrackBG
            TrackFill.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
            TrackFill.Size = UDim2.new(0, 0, 1, 0)
            local FCorner = Instance.new("UICorner")
            FCorner.CornerRadius = UDim.new(1, 0)
            FCorner.Parent = TrackFill

            -- Drag handle circle
            local Handle = Instance.new("Frame")
            Handle.Parent = TrackBG
            Handle.Size = UDim2.new(0, 12, 0, 12)
            Handle.AnchorPoint = Vector2.new(0.5, 0.5)
            Handle.Position = UDim2.new((default - min) / math.max(max - min, 0.0001), 0, 0.5, 0)
            Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Handle.BorderSizePixel = 0
            Handle.ZIndex = 3
            Instance.new("UICorner", Handle).CornerRadius = UDim.new(1, 0)
            local HandleShadow = Instance.new("UIStroke", Handle)
            HandleShadow.Color = Color3.fromRGB(0, 0, 0)
            HandleShadow.Thickness = 1
            HandleShadow.Transparency = 0.6

            local DragBtn = Instance.new("TextButton")
            DragBtn.Parent = TrackBG
            DragBtn.BackgroundTransparency = 1
            DragBtn.Position = UDim2.new(0, -15, 0, -10)
            DragBtn.Size = UDim2.new(1, 30, 1, 20)
            DragBtn.Text = ""
            DragBtn.ZIndex = 5

            SliderFrame.MouseEnter:Connect(function() Utility:Tween(SliderFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}) end)
            SliderFrame.MouseLeave:Connect(function() Utility:Tween(SliderFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}) end)

            local dragging = false
            local function updateSlider(input)
                local trackWidth = TrackBG.AbsoluteSize.X
                if trackWidth == 0 then trackWidth = 1 end
                local sizeX = math.clamp((input.Position.X - TrackBG.AbsolutePosition.X) / trackWidth, 0, 1)
                local raw   = min + (max - min) * sizeX
                local value = snap(raw)
                local fillX = (value - min) / math.max(max - min, 0.0001)
                Utility:Tween(TrackFill, {0.05}, {Size = UDim2.new(fillX, 0, 1, 0)})
                Handle.Position = UDim2.new(fillX, 0, 0.5, 0)
                ValueLab.Text = fmt(value)
                callback(value)
            end

            DragBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end)
            DragBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)

            -- Set initial fill
            local initFill = (default - min) / math.max(max - min, 0.0001)
            TrackFill.Size = UDim2.new(math.clamp(initFill, 0, 1), 0, 1, 0)
            Handle.Position = UDim2.new(math.clamp(initFill, 0, 1), 0, 0.5, 0)
        end

        -- LABEL (informational text row)
        function Elements:CreateLabel(options)
            local text    = options.Text or "Label"
            local color   = options.Color or Color3.fromRGB(180, 180, 180)
            local size    = options.TextSize or 13

            local LFrame = Instance.new("Frame")
            LFrame.Parent = TabPage
            LFrame.BackgroundTransparency = 1
            LFrame.Size = UDim2.new(1, 0, 0, 28)

            local LText = Instance.new("TextLabel")
            LText.Parent = LFrame
            LText.BackgroundTransparency = 1
            LText.Position = UDim2.new(0, 15, 0, 0)
            LText.Size = UDim2.new(1, -30, 1, 0)
            LText.Font = Enum.Font.Ubuntu
            LText.Text = text
            LText.TextColor3 = color
            LText.TextSize = size
            LText.TextXAlignment = Enum.TextXAlignment.Left
            LText.TextWrapped = true
            LText.RichText = true

            local function SetText(newText) LText.Text = newText end
            local function SetColor(newCol) LText.TextColor3 = newCol end
            return {SetText = SetText, SetColor = SetColor}
        end

        -- SEPARATOR (horizontal divider line with optional label)
        function Elements:CreateSeparator(options)
            local text = options and options.Text or ""

            local SepFrame = Instance.new("Frame")
            SepFrame.Parent = TabPage
            SepFrame.BackgroundTransparency = 1
            SepFrame.Size = UDim2.new(1, 0, 0, 24)

            local Line = Instance.new("Frame")
            Line.Parent = SepFrame
            Line.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            Line.BorderSizePixel = 0
            Line.AnchorPoint = Vector2.new(0, 0.5)
            Line.Position = UDim2.new(0, 15, 0.5, 0)
            Line.Size = UDim2.new(1, -30, 0, 1)
            Instance.new("UICorner", Line).CornerRadius = UDim.new(1, 0)

            if text ~= "" then
                local SepLab = Instance.new("TextLabel")
                SepLab.Parent = SepFrame
                SepLab.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
                SepLab.Size = UDim2.new(0, 0, 0, 16)
                SepLab.AutomaticSize = Enum.AutomaticSize.X
                SepLab.AnchorPoint = Vector2.new(0.5, 0.5)
                SepLab.Position = UDim2.new(0.5, 0, 0.5, 0)
                SepLab.Font = Enum.Font.Ubuntu
                SepLab.Text = "  " .. text .. "  "
                SepLab.TextColor3 = Color3.fromRGB(120, 120, 125)
                SepLab.TextSize = 11
                SepLab.ZIndex = 2
            end
        end

        -- KEYBIND
        function Elements:CreateKeybind(options)
            local name     = options.Name or "Keybind"
            local default  = options.CurrentKey or Enum.KeyCode.Unknown
            local callback = options.Callback or function() end

            local listening = false
            local currentKey = default

            local KFrame = Instance.new("Frame")
            KFrame.Parent = TabPage
            KFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            KFrame.Size = UDim2.new(1, 0, 0, 42)

            local KCorner = Instance.new("UICorner")
            KCorner.CornerRadius = UDim.new(0, 6)
            KCorner.Parent = KFrame

            local KStroke = Instance.new("UIStroke")
            KStroke.Parent = KFrame
            KStroke.Color = Color3.fromRGB(45, 45, 50)
            KStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local KLabel = Instance.new("TextLabel")
            KLabel.Parent = KFrame
            KLabel.BackgroundTransparency = 1
            KLabel.Position = UDim2.new(0, 15, 0, 0)
            KLabel.Size = UDim2.new(1, -100, 1, 0)
            KLabel.Font = Enum.Font.Ubuntu
            KLabel.Text = name
            KLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            KLabel.TextSize = 14
            KLabel.TextXAlignment = Enum.TextXAlignment.Left
            KLabel.TextTruncate = Enum.TextTruncate.AtEnd

            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Parent = KFrame
            KeyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
            KeyBtn.Position = UDim2.new(1, -90, 0.5, -12)
            KeyBtn.Size = UDim2.new(0, 78, 0, 24)
            KeyBtn.Font = Enum.Font.Code
            KeyBtn.Text = currentKey.Name
            KeyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            KeyBtn.TextSize = 12
            KeyBtn.AutoButtonColor = false
            Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 4)
            local KBStroke = Instance.new("UIStroke", KeyBtn)
            KBStroke.Color = Color3.fromRGB(55, 55, 60)

            KFrame.MouseEnter:Connect(function() Utility:Tween(KFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}) end)
            KFrame.MouseLeave:Connect(function() Utility:Tween(KFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}) end)

            KeyBtn.MouseButton1Click:Connect(function()
                listening = true
                KeyBtn.Text = "..."
                Utility:Tween(KBStroke, {0.2}, {Color = Color3.fromRGB(220, 220, 220)})
            end)

            UserInputService.InputBegan:Connect(function(input, gp)
                if not listening then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Escape then
                        currentKey = Enum.KeyCode.Unknown
                    else
                        currentKey = input.KeyCode
                    end
                    listening = false
                    KeyBtn.Text = currentKey.Name
                    Utility:Tween(KBStroke, {0.2}, {Color = Color3.fromRGB(55, 55, 60)})
                    callback(currentKey)
                end
            end)
        end

        -- DROPDOWN
        function Elements:CreateDropdown(options)
            local name    = options.Name or "Dropdown"
            local list    = options.Options or {}
            local current = options.CurrentOption or (list[1] or "")
            local callback = options.Callback or function() end

            -- Wrapper: sabit yükseklikteki "header" şeridi
            local DropOuter = Instance.new("Frame")
            DropOuter.Parent = TabPage
            DropOuter.BackgroundTransparency = 1
            DropOuter.Size = UDim2.new(1, 0, 0, 42)
            DropOuter.ClipsDescendants = false
            DropOuter.ZIndex = 10

            -- Header kutusu
            local DropFrame = Instance.new("Frame")
            DropFrame.Parent = DropOuter
            DropFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            DropFrame.Size = UDim2.new(1, 0, 0, 42)
            DropFrame.ClipsDescendants = false
            DropFrame.ZIndex = 10

            local DCorner = Instance.new("UICorner")
            DCorner.CornerRadius = UDim.new(0, 6)
            DCorner.Parent = DropFrame

            local DStroke = Instance.new("UIStroke")
            DStroke.Parent = DropFrame
            DStroke.Color = Color3.fromRGB(45, 45, 50)
            DStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local DropBtn = Instance.new("TextButton")
            DropBtn.Parent = DropFrame
            DropBtn.BackgroundTransparency = 1
            DropBtn.Size = UDim2.new(1, 0, 1, 0)
            DropBtn.Text = ""
            DropBtn.ZIndex = 12

            local TitleLab = Instance.new("TextLabel")
            TitleLab.Parent = DropFrame
            TitleLab.BackgroundTransparency = 1
            TitleLab.Position = UDim2.new(0, 15, 0, 0)
            TitleLab.Size = UDim2.new(1, -60, 1, 0)
            TitleLab.Font = Enum.Font.Ubuntu
            TitleLab.Text = name .. "  ›  " .. tostring(current)
            TitleLab.TextColor3 = Color3.fromRGB(220, 220, 220)
            TitleLab.TextSize = 14
            TitleLab.TextXAlignment = Enum.TextXAlignment.Left
            TitleLab.TextTruncate = Enum.TextTruncate.AtEnd
            TitleLab.ZIndex = 11

            local ArrowLab = Instance.new("TextLabel")
            ArrowLab.Parent = DropFrame
            ArrowLab.BackgroundTransparency = 1
            ArrowLab.Position = UDim2.new(1, -32, 0, 0)
            ArrowLab.Size = UDim2.new(0, 24, 1, 0)
            ArrowLab.Font = Enum.Font.Ubuntu
            ArrowLab.Text = "▼"
            ArrowLab.TextColor3 = Color3.fromRGB(150, 150, 150)
            ArrowLab.TextSize = 12
            ArrowLab.ZIndex = 11

            -- Liste paneli (header'ın hemen altında, diğer elemanların ÜSTÜNDEKİ katmanda)
            local ListPanel = Instance.new("Frame")
            ListPanel.Parent = DropFrame
            ListPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            ListPanel.Position = UDim2.new(0, 0, 1, 4)
            ListPanel.Size = UDim2.new(1, 0, 0, 0)
            ListPanel.ClipsDescendants = true
            ListPanel.ZIndex = 50
            ListPanel.Visible = false

            local LCorner = Instance.new("UICorner")
            LCorner.CornerRadius = UDim.new(0, 6)
            LCorner.Parent = ListPanel

            local LStroke = Instance.new("UIStroke")
            LStroke.Parent = ListPanel
            LStroke.Color = Color3.fromRGB(55, 55, 62)
            LStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local ListScroll = Instance.new("ScrollingFrame")
            ListScroll.Parent = ListPanel
            ListScroll.BackgroundTransparency = 1
            ListScroll.Size = UDim2.new(1, 0, 1, 0)
            ListScroll.ScrollBarThickness = 2
            ListScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65)
            ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            ListScroll.ZIndex = 51

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = ListScroll
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local ListPad = Instance.new("UIPadding")
            ListPad.Parent = ListScroll
            ListPad.PaddingTop = UDim.new(0, 4)
            ListPad.PaddingBottom = UDim.new(0, 4)

            local expanded = false
            local ITEM_H = 34

            local function buildList()
                for _, v in pairs(ListScroll:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end
                for _, option in ipairs(list) do
                    local isCurrent = tostring(option) == tostring(current)
                    local Opt = Instance.new("TextButton")
                    Opt.Parent = ListScroll
                    Opt.BackgroundColor3 = isCurrent and Color3.fromRGB(50, 50, 58) or Color3.fromRGB(30, 30, 36)
                    Opt.BackgroundTransparency = isCurrent and 0 or 1
                    Opt.Size = UDim2.new(1, 0, 0, ITEM_H)
                    Opt.Font = Enum.Font.Ubuntu
                    Opt.Text = "  " .. (isCurrent and "▶  " or "    ") .. tostring(option)
                    Opt.TextColor3 = isCurrent and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 185)
                    Opt.TextSize = 13
                    Opt.TextXAlignment = Enum.TextXAlignment.Left
                    Opt.AutoButtonColor = false
                    Opt.ZIndex = 52

                    Opt.MouseEnter:Connect(function()
                        if not isCurrent then
                            Utility:Tween(Opt, {0.12}, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(42, 42, 50), TextColor3 = Color3.fromRGB(240, 240, 240)})
                        end
                    end)
                    Opt.MouseLeave:Connect(function()
                        if not isCurrent then
                            Utility:Tween(Opt, {0.12}, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(180, 180, 185)})
                        end
                    end)
                    Opt.MouseButton1Click:Connect(function()
                        current = option
                        TitleLab.Text = name .. "  ›  " .. tostring(current)
                        expanded = false
                        Utility:Tween(ListPanel, {0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Size = UDim2.new(1, 0, 0, 0)})
                        Utility:Tween(ArrowLab, {0.2}, {Rotation = 0})
                        task.wait(0.28)
                        ListPanel.Visible = false
                        buildList()
                        callback(current)
                    end)
                end
                local total = #list * ITEM_H + 8
                ListScroll.CanvasSize = UDim2.new(0, 0, 0, total)
            end

            buildList()

            local function toggleDropdown()
                expanded = not expanded
                if expanded then
                    local panelH = math.clamp(#list * ITEM_H + 8, 0, 180)
                    ListPanel.Visible = true
                    ListPanel.Size = UDim2.new(1, 0, 0, 0)
                    Utility:Tween(ListPanel, {0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Size = UDim2.new(1, 0, 0, panelH)})
                    Utility:Tween(ArrowLab, {0.25}, {Rotation = 180})
                    Utility:Tween(DropFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(38, 38, 44)})
                else
                    Utility:Tween(ListPanel, {0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Size = UDim2.new(1, 0, 0, 0)})
                    Utility:Tween(ArrowLab, {0.2}, {Rotation = 0})
                    Utility:Tween(DropFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)})
                    task.wait(0.28)
                    if not expanded then ListPanel.Visible = false end
                end
            end

            DropBtn.MouseButton1Click:Connect(toggleDropdown)

            DropFrame.MouseEnter:Connect(function()
                if not expanded then Utility:Tween(DropFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(36, 36, 42)}) end
            end)
            DropFrame.MouseLeave:Connect(function()
                if not expanded then Utility:Tween(DropFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}) end
            end)

            -- Dışarıda bir yere tıklanınca otomatik kapat
            UserInputService.InputBegan:Connect(function(input)
                if expanded and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local pos = input.Position
                    local panelPos = ListPanel.AbsolutePosition
                    local panelSz  = ListPanel.AbsoluteSize
                    local headPos  = DropFrame.AbsolutePosition
                    local headSz   = DropFrame.AbsoluteSize
                    local inHead   = pos.X >= headPos.X and pos.X <= headPos.X + headSz.X and pos.Y >= headPos.Y and pos.Y <= headPos.Y + headSz.Y
                    local inPanel  = pos.X >= panelPos.X and pos.X <= panelPos.X + panelSz.X and pos.Y >= panelPos.Y and pos.Y <= panelPos.Y + panelSz.Y
                    if not inHead and not inPanel then
                        task.spawn(function()
                            expanded = false
                            Utility:Tween(ListPanel, {0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Size = UDim2.new(1, 0, 0, 0)})
                            Utility:Tween(ArrowLab, {0.2}, {Rotation = 0})
                            Utility:Tween(DropFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)})
                            task.wait(0.28)
                            ListPanel.Visible = false
                        end)
                    end
                end
            end)

            -- Dışarıya referans ver: seçimi programatik güncelle
            local DropAPI = {}
            function DropAPI:Set(option)
                current = option
                TitleLab.Text = name .. "  ›  " .. tostring(current)
                buildList()
                callback(current)
            end
            function DropAPI:GetSelected()
                return current
            end
            function DropAPI:Refresh(newList)
                list = newList
                buildList()
            end
            return DropAPI
        end

        -- INPUT / TEXTBOX
        function Elements:CreateInput(options)
            local name = options.Name or "Input"
            local placeholder = options.PlaceholderText or "Type here..."
            local callback = options.Callback or function() end

            local InputFrame = Instance.new("Frame")
            InputFrame.Parent = TabPage
            InputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            InputFrame.Size = UDim2.new(1, 0, 0, 42)
            
            local ICorner = Instance.new("UICorner")
            ICorner.CornerRadius = UDim.new(0, 6)
            ICorner.Parent = InputFrame
            
            local IStroke = Instance.new("UIStroke")
            IStroke.Parent = InputFrame
            IStroke.Color = Color3.fromRGB(45, 45, 50)
            IStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local TitleLab = Instance.new("TextLabel")
            TitleLab.Parent = InputFrame
            TitleLab.BackgroundTransparency = 1
            TitleLab.Position = UDim2.new(0, 15, 0, 0)
            TitleLab.Size = UDim2.new(0.4, 0, 1, 0)
            TitleLab.Font = Enum.Font.Ubuntu
            TitleLab.Text = name
            TitleLab.TextColor3 = Color3.fromRGB(220, 220, 220)
            TitleLab.TextSize = 14
            TitleLab.TextXAlignment = Enum.TextXAlignment.Left
            TitleLab.TextTruncate = Enum.TextTruncate.AtEnd

            local TextBoxBG = Instance.new("Frame")
            TextBoxBG.Parent = InputFrame
            TextBoxBG.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
            TextBoxBG.Position = UDim2.new(0.4, 15, 0.5, -12)
            TextBoxBG.Size = UDim2.new(0.6, -30, 0, 24)
            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = TextBoxBG

            local TextBox = Instance.new("TextBox")
            TextBox.Parent = TextBoxBG
            TextBox.BackgroundTransparency = 1
            TextBox.Size = UDim2.new(1, -10, 1, 0)
            TextBox.Position = UDim2.new(0, 5, 0, 0)
            TextBox.Font = Enum.Font.Ubuntu
            TextBox.Text = ""
            TextBox.PlaceholderText = placeholder
            TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
            TextBox.TextSize = 13
            TextBox.TextXAlignment = Enum.TextXAlignment.Left

            TextBox.FocusLost:Connect(function(enterPressed)
                callback(TextBox.Text)
            end)
        end

        -- COLOR PICKER
        function Elements:CreateColorPicker(options)
            local name = options.Name or "Color Picker"
            local default = options.Default or Color3.fromRGB(255, 0, 0)
            local callback = options.Callback or function() end

            local currentH, currentS, currentV = Color3.toHSV(default)
            local expanded = false
            local svDragging = false
            local hueDragging = false

            -- Header row (collapsed by default)
            local CPFrame = Instance.new("Frame")
            CPFrame.Parent = TabPage
            CPFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            CPFrame.Size = UDim2.new(1, 0, 0, 42)
            CPFrame.ClipsDescendants = true

            local CPCorner = Instance.new("UICorner")
            CPCorner.CornerRadius = UDim.new(0, 6)
            CPCorner.Parent = CPFrame

            local CPStroke = Instance.new("UIStroke")
            CPStroke.Parent = CPFrame
            CPStroke.Color = Color3.fromRGB(45, 45, 50)
            CPStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            -- Label
            local CPLabel = Instance.new("TextLabel")
            CPLabel.Parent = CPFrame
            CPLabel.BackgroundTransparency = 1
            CPLabel.Position = UDim2.new(0, 15, 0, 0)
            CPLabel.Size = UDim2.new(1, -90, 0, 42)
            CPLabel.Font = Enum.Font.Ubuntu
            CPLabel.Text = name
            CPLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            CPLabel.TextSize = 14
            CPLabel.TextXAlignment = Enum.TextXAlignment.Left

            -- Color preview swatch
            local Swatch = Instance.new("Frame")
            Swatch.Parent = CPFrame
            Swatch.BackgroundColor3 = default
            Swatch.Position = UDim2.new(1, -68, 0.5, -10)
            Swatch.Size = UDim2.new(0, 36, 0, 20)
            local SwatchCorner = Instance.new("UICorner")
            SwatchCorner.CornerRadius = UDim.new(0, 4)
            SwatchCorner.Parent = Swatch
            local SwatchStroke = Instance.new("UIStroke")
            SwatchStroke.Parent = Swatch
            SwatchStroke.Color = Color3.fromRGB(70, 70, 75)
            SwatchStroke.Thickness = 1

            -- Arrow icon
            local ArrowIcon = Instance.new("ImageLabel")
            ArrowIcon.Parent = CPFrame
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Position = UDim2.new(1, -26, 0.5, -8)
            ArrowIcon.Size = UDim2.new(0, 16, 0, 16)
            ArrowIcon.Image = "rbxassetid://10888331510"
            ArrowIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
            ArrowIcon.Rotation = 90

            -- Toggle button
            local HeaderBtn = Instance.new("TextButton")
            HeaderBtn.Parent = CPFrame
            HeaderBtn.BackgroundTransparency = 1
            HeaderBtn.Size = UDim2.new(1, 0, 0, 42)
            HeaderBtn.Text = ""
            HeaderBtn.ZIndex = 2

            -- SV Palette (inside collapsed frame, below header)
            local Palette = Instance.new("ImageLabel")
            Palette.Parent = CPFrame
            Palette.Size = UDim2.new(1, -30, 0, 150)
            Palette.Position = UDim2.new(0, 15, 0, 52)
            Palette.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
            Palette.Image = "rbxassetid://4155801252"
            Palette.ZIndex = 3
            Instance.new("UICorner", Palette).CornerRadius = UDim.new(0, 4)

            -- SV Cursor
            local SVCursor = Instance.new("Frame")
            SVCursor.Parent = Palette
            SVCursor.Size = UDim2.new(0, 10, 0, 10)
            SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
            SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SVCursor.BorderSizePixel = 0
            SVCursor.ZIndex = 5
            SVCursor.Position = UDim2.new(currentS, 0, 1 - currentV, 0)
            Instance.new("UICorner", SVCursor).CornerRadius = UDim.new(1, 0)
            local SVStroke = Instance.new("UIStroke", SVCursor)
            SVStroke.Color = Color3.fromRGB(0, 0, 0)
            SVStroke.Thickness = 1

            -- Hue Bar
            local HueBar = Instance.new("ImageLabel")
            HueBar.Parent = CPFrame
            HueBar.Size = UDim2.new(1, -30, 0, 14)
            HueBar.Position = UDim2.new(0, 15, 0, 212)
            HueBar.Image = "rbxassetid://698052001"
            HueBar.ZIndex = 3
            Instance.new("UICorner", HueBar).CornerRadius = UDim.new(0, 4)

            -- Hue Cursor
            local HueCursor = Instance.new("Frame")
            HueCursor.Parent = HueBar
            HueCursor.Size = UDim2.new(0, 5, 1, 4)
            HueCursor.AnchorPoint = Vector2.new(0.5, 0)
            HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HueCursor.BorderSizePixel = 0
            HueCursor.ZIndex = 5
            HueCursor.Position = UDim2.new(currentH, 0, 0, -2)
            Instance.new("UICorner", HueCursor).CornerRadius = UDim.new(0, 2)
            local HueStroke = Instance.new("UIStroke", HueCursor)
            HueStroke.Color = Color3.fromRGB(0, 0, 0)
            HueStroke.Thickness = 1

            -- Hex label at bottom
            local HexLabel = Instance.new("TextLabel")
            HexLabel.Parent = CPFrame
            HexLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
            HexLabel.Position = UDim2.new(0, 15, 0, 236)
            HexLabel.Size = UDim2.new(1, -30, 0, 22)
            HexLabel.Font = Enum.Font.Code
            HexLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            HexLabel.TextSize = 12
            HexLabel.ZIndex = 3
            local HexCorner = Instance.new("UICorner")
            HexCorner.CornerRadius = UDim.new(0, 4)
            HexCorner.Parent = HexLabel

            local function updateColor()
                local color = Color3.fromHSV(currentH, currentS, currentV)
                Swatch.BackgroundColor3 = color
                Palette.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
                local r = math.floor(color.R * 255)
                local g = math.floor(color.G * 255)
                local b = math.floor(color.B * 255)
                HexLabel.Text = string.format("  #%02X%02X%02X  (R:%d G:%d B:%d)", r, g, b, r, g, b)
                SVCursor.Position = UDim2.new(currentS, 0, 1 - currentV, 0)
                HueCursor.Position = UDim2.new(currentH, 0, 0, -2)
                callback(color)
            end

            updateColor()

            -- Toggle expand/collapse
            HeaderBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    Utility:Tween(CPFrame, {0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Size = UDim2.new(1, 0, 0, 270)})
                    Utility:Tween(ArrowIcon, {0.3}, {Rotation = -90})
                else
                    Utility:Tween(CPFrame, {0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Size = UDim2.new(1, 0, 0, 42)})
                    Utility:Tween(ArrowIcon, {0.3}, {Rotation = 90})
                end
            end)

            HeaderBtn.MouseEnter:Connect(function()
                Utility:Tween(CPFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(35, 35, 40)})
            end)
            HeaderBtn.MouseLeave:Connect(function()
                Utility:Tween(CPFrame, {0.2}, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)})
            end)

            -- SV drag
            Palette.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    svDragging = true
                    local relX = math.clamp((input.Position.X - Palette.AbsolutePosition.X) / Palette.AbsoluteSize.X, 0, 1)
                    local relY = math.clamp((input.Position.Y - Palette.AbsolutePosition.Y) / Palette.AbsoluteSize.Y, 0, 1)
                    currentS = relX
                    currentV = 1 - relY
                    updateColor()
                end
            end)
            Palette.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = false end
            end)

            -- Hue drag
            HueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    hueDragging = true
                    local relX = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                    currentH = relX
                    updateColor()
                end
            end)
            HueBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = false end
            end)

            -- Global mouse move
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if svDragging then
                        local relX = math.clamp((input.Position.X - Palette.AbsolutePosition.X) / Palette.AbsoluteSize.X, 0, 1)
                        local relY = math.clamp((input.Position.Y - Palette.AbsolutePosition.Y) / Palette.AbsoluteSize.Y, 0, 1)
                        currentS = relX
                        currentV = 1 - relY
                        updateColor()
                    elseif hueDragging then
                        local relX = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                        currentH = relX
                        updateColor()
                    end
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    svDragging = false
                    hueDragging = false
                end
            end)
        end

        return Elements
    end

    return Window
end

-- ============================================================
--  MeisterUI:KeySystem({ Key, GetKeyURL, Title, Subtitle })
--  Themed to match MeisterUI's dark monochrome aesthetic.
--  Call BEFORE CreateWindow. Blocks until correct key entered.
-- ============================================================
function MeisterUI:KeySystem(config)
    local validKey = config.Key       or ""
    local linkURL  = config.GetKeyURL or ""
    local title    = config.Title     or "MEISTER"
    local subtitle = config.Subtitle  or "Enter your key to continue"

    local KGui = Instance.new("ScreenGui")
    KGui.Name           = "MeisterUI_KeySystem"
    KGui.DisplayOrder   = 9999
    KGui.IgnoreGuiInset = true
    KGui.ResetOnSpawn   = false
    KGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KGui.Parent         = ParentGui

    -- Dark overlay — same as IntroOverlay
    local Overlay = Instance.new("Frame", KGui)
    Overlay.Size                  = UDim2.fromScale(1,1)
    Overlay.BackgroundColor3      = Color3.fromRGB(0,0,0)
    Overlay.BackgroundTransparency= 1   -- fade in
    Overlay.BorderSizePixel       = 0
    Overlay.ZIndex                = 100

    -- Card — matches MainFrame colour RGB(15,15,18)
    local Card = Instance.new("Frame", KGui)
    Card.AnchorPoint      = Vector2.new(0.5,0.5)
    Card.Position         = UDim2.fromScale(0.5, 0.52)   -- starts a bit low
    Card.Size             = UDim2.fromOffset(360, 200)    -- starts small
    Card.BackgroundColor3 = Color3.fromRGB(15,15,18)
    Card.BorderSizePixel  = 0
    Card.ZIndex           = 101
    Instance.new("UICorner",Card).CornerRadius = UDim.new(0,10)

    -- Card stroke — matches MainStroke RGB(50,50,55)
    local CardStroke = Instance.new("UIStroke",Card)
    CardStroke.Color           = Color3.fromRGB(50,50,55)
    CardStroke.Thickness       = 1
    CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Drop shadow — child of card, behind it (ZIndex -1)
    local Shadow = Instance.new("Frame",Card)
    Shadow.BackgroundColor3       = Color3.fromRGB(0,0,0)
    Shadow.Size                   = UDim2.new(1,10,1,10)
    Shadow.Position               = UDim2.new(0,-5,0,-5)
    Shadow.BackgroundTransparency = 0.8
    Shadow.ZIndex                 = -1
    Shadow.BorderSizePixel        = 0
    Instance.new("UICorner",Shadow).CornerRadius = UDim.new(0,14)

    -- Header bar — matches Topbar colour RGB(22,22,26)
    local Header = Instance.new("Frame",Card)
    Header.Size             = UDim2.new(1,0,0,35)
    Header.BackgroundColor3 = Color3.fromRGB(22,22,26)
    Header.BorderSizePixel  = 0
    Header.ZIndex           = 102
    Instance.new("UICorner",Header).CornerRadius = UDim.new(0,10)

    -- Fix bottom corners of header (same as TopbarFix)
    local HFix = Instance.new("Frame",Header)
    HFix.BackgroundColor3 = Color3.fromRGB(22,22,26)
    HFix.Position         = UDim2.new(0,0,1,-10)
    HFix.Size             = UDim2.new(1,0,0,10)
    HFix.BorderSizePixel  = 0

    -- Header divider — matches TopbarDivider RGB(40,40,45)
    local HDiv = Instance.new("Frame",Header)
    HDiv.BackgroundColor3 = Color3.fromRGB(40,40,45)
    HDiv.Position         = UDim2.new(0,0,1,-1)
    HDiv.Size             = UDim2.new(1,0,0,1)
    HDiv.BorderSizePixel  = 0

    -- Title — matches MainTitle (Font.Ubuntu, 14px, white, left-aligned)
    local TitleLb = Instance.new("TextLabel",Header)
    TitleLb.BackgroundTransparency = 1
    TitleLb.Position       = UDim2.new(0,15,0,0)
    TitleLb.Size           = UDim2.new(1,-20,1,0)
    TitleLb.Font           = Enum.Font.Ubuntu
    TitleLb.Text           = title
    TitleLb.TextColor3     = Color3.fromRGB(255,255,255)
    TitleLb.TextSize       = 14
    TitleLb.TextXAlignment = Enum.TextXAlignment.Left
    TitleLb.ZIndex         = 103

    -- Subtitle — matches secondary label colour RGB(150,150,150)
    local SubLb = Instance.new("TextLabel",Card)
    SubLb.BackgroundTransparency = 1
    SubLb.Position       = UDim2.new(0,18,0,46)
    SubLb.Size           = UDim2.new(1,-36,0,18)
    SubLb.Font           = Enum.Font.Ubuntu
    SubLb.Text           = subtitle
    SubLb.TextColor3     = Color3.fromRGB(150,150,150)
    SubLb.TextSize       = 13
    SubLb.TextXAlignment = Enum.TextXAlignment.Left
    SubLb.ZIndex         = 102

    -- Input background — matches notification frame RGB(25,25,25)
    local IBg = Instance.new("Frame",Card)
    IBg.Size             = UDim2.new(1,-36,0,36)
    IBg.Position         = UDim2.new(0,18,0,74)
    IBg.BackgroundColor3 = Color3.fromRGB(25,25,25)
    IBg.BorderSizePixel  = 0
    IBg.ZIndex           = 102
    Instance.new("UICorner",IBg).CornerRadius = UDim.new(0,8)

    local IStroke = Instance.new("UIStroke",IBg)
    IStroke.Color           = Color3.fromRGB(50,50,55)
    IStroke.Thickness       = 1
    IStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local IBox = Instance.new("TextBox",IBg)
    IBox.Size                  = UDim2.new(1,-14,1,0)
    IBox.Position              = UDim2.new(0,7,0,0)
    IBox.BackgroundTransparency= 1
    IBox.Text                  = ""
    IBox.PlaceholderText       = "Paste your key here..."
    IBox.PlaceholderColor3     = Color3.fromRGB(70,70,75)
    IBox.TextColor3            = Color3.fromRGB(240,240,240)
    IBox.Font                  = Enum.Font.Code
    IBox.TextSize              = 13
    IBox.ClearTextOnFocus      = false
    IBox.ZIndex                = 103

    -- Status text — secondary colour, left align
    local StatusLb = Instance.new("TextLabel",Card)
    StatusLb.BackgroundTransparency = 1
    StatusLb.Position       = UDim2.new(0,18,0,118)
    StatusLb.Size           = UDim2.new(1,-36,0,16)
    StatusLb.Font           = Enum.Font.Ubuntu
    StatusLb.Text           = ""
    StatusLb.TextColor3     = Color3.fromRGB(150,150,150)
    StatusLb.TextSize       = 12
    StatusLb.TextXAlignment = Enum.TextXAlignment.Left
    StatusLb.ZIndex         = 102

    -- Button factory — matches tab button style exactly
    local btnY = 143
    local function MakeBtn(text, xOff, width, isPrimary)
        local B = Instance.new("TextButton",Card)
        B.Size             = UDim2.new(0, width, 0, 32)
        B.Position         = UDim2.new(0, xOff, 0, btnY)
        B.BackgroundColor3 = Color3.fromRGB(22,22,26)
        B.BorderSizePixel  = 0
        B.AutoButtonColor  = false
        B.Font             = Enum.Font.Ubuntu
        B.Text             = "   "..text
        B.TextColor3       = isPrimary and Color3.fromRGB(220,220,220) or Color3.fromRGB(150,150,150)
        B.TextSize         = 13
        B.TextXAlignment   = Enum.TextXAlignment.Left
        B.ZIndex           = 102
        Instance.new("UICorner",B).CornerRadius = UDim.new(0,6)

        local BS = Instance.new("UIStroke",B)
        BS.Color           = Color3.fromRGB(50,50,55)
        BS.Thickness       = 1
        BS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        -- Accent indicator — same as SelectedIndicator in tabs (white bar on left)
        if isPrimary then
            local Ind = Instance.new("Frame",B)
            Ind.BackgroundColor3 = Color3.fromRGB(220,220,220)
            Ind.Size             = UDim2.new(0,3,0,14)
            Ind.Position         = UDim2.new(0,0,0.5,-7)
            Ind.BorderSizePixel  = 0
            Instance.new("UICorner",Ind).CornerRadius = UDim.new(1,0)
        end

        B.MouseEnter:Connect(function()
            Utility:Tween(B,{0.2},{BackgroundColor3=Color3.fromRGB(30,30,36)})
            Utility:Tween(BS,{0.2},{Color=Color3.fromRGB(80,80,85)})
        end)
        B.MouseLeave:Connect(function()
            Utility:Tween(B,{0.2},{BackgroundColor3=Color3.fromRGB(22,22,26)})
            Utility:Tween(BS,{0.2},{Color=Color3.fromRGB(50,50,55)})
        end)
        return B
    end

    local btnW   = (420-36-8) / 2   -- two buttons with 8px gap
    local BtnGet    = MakeBtn("Get Key", 18,          btnW, false)
    local BtnSubmit = MakeBtn("Submit",  18+btnW+8,   btnW, true)

    -- Footer — same as GameLab style
    local FooterLb = Instance.new("TextLabel",Card)
    FooterLb.BackgroundTransparency = 1
    FooterLb.Position       = UDim2.new(0,18,1,-22)
    FooterLb.Size           = UDim2.new(1,-36,0,14)
    FooterLb.Font           = Enum.Font.Ubuntu
    FooterLb.Text           = "meister library"
    FooterLb.TextColor3     = Color3.fromRGB(60,60,65)
    FooterLb.TextSize       = 11
    FooterLb.TextXAlignment = Enum.TextXAlignment.Left
    FooterLb.ZIndex         = 102

    -- Animate in — same Quart/Back style as CreateWindow
    Utility:Tween(Overlay,{0.4},{BackgroundTransparency=0.35})
    Utility:Tween(Card,{0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out},{
        Size     = UDim2.fromOffset(420,195),
        Position = UDim2.fromScale(0.5,0.5),
    })

    -- Input focus — stroke brightens (same style as rest of lib)
    IBox.Focused:Connect(function()
        Utility:Tween(IStroke,{0.2},{Color=Color3.fromRGB(120,120,130),Thickness=1.5})
    end)
    IBox.FocusLost:Connect(function()
        Utility:Tween(IStroke,{0.2},{Color=Color3.fromRGB(50,50,55),Thickness=1})
    end)

    -- Shake (matching MakeDraggable delta style)
    local function Shake()
        local orig = Card.Position
        for i = 1,7 do
            Card.Position = orig + UDim2.fromOffset(i%2==0 and 7 or -7, 0)
            task.wait(0.035)
        end
        Card.Position = orig
    end

    -- Get Key — copy link
    BtnGet.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(linkURL) end)
        StatusLb.TextColor3 = Color3.fromRGB(130,190,130)
        StatusLb.Text = "Link copied to clipboard."
    end)

    -- Validate key
    local _done = false
    local function TryKey()
        if string.gsub(IBox.Text, "%s+", "") == string.gsub(validKey, "%s+", "") then
            _done = true
            StatusLb.TextColor3 = Color3.fromRGB(130,190,130)
            StatusLb.Text = "Key accepted. Loading..."
            -- Close: shrink + fade, same as ToggleUI close
            Utility:Tween(Card,{0.35,Enum.EasingStyle.Back,Enum.EasingDirection.In},{
                Size=UDim2.fromOffset(360,160),Position=UDim2.fromScale(0.5,0.52)})
            Utility:Tween(Overlay,{0.35},{BackgroundTransparency=1})
            task.delay(0.4, function() KGui:Destroy() end)
        else
            StatusLb.TextColor3 = Color3.fromRGB(190,120,120)
            StatusLb.Text = "Invalid key. Click 'Get Key' to receive yours."
            task.spawn(Shake)
        end
    end

    BtnSubmit.MouseButton1Click:Connect(TryKey)
    IBox.FocusLost:Connect(function(enter) if enter then TryKey() end end)

    repeat task.wait(0.05) until _done
end

return MeisterUI
