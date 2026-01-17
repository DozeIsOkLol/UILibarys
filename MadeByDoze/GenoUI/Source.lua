-- GENOUI Library
-- DM [Your Discord Here] for support (don't forget the dot at the end!)

local GENOUI = {}
GENOUI.__index = GENOUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

-- Helper functions
local function createUICorner(parent, radius)
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, radius or 10)
    uiCorner.Parent = parent
    return uiCorner
end

local function createUIStroke(parent, color, thickness)
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = color or Color3.fromRGB(50, 50, 50)
    uiStroke.Thickness = thickness or 1
    uiStroke.Parent = parent
    return uiStroke
end

local function setupButtonHover(button, normalColor, hoverColor)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = hoverColor})
    local reverseTween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = normalColor})
    
    button.MouseEnter:Connect(function()
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        reverseTween:Play()
    end)
end

local function setupButtonClick(button, normalColor, clickColor)
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, tweenInfo, {BackgroundColor3 = clickColor or Color3.fromRGB(40, 40, 40)}):Play()
    end)
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, tweenInfo, {BackgroundColor3 = normalColor}):Play()
    end)
end

-- Window class
local Window = {}
Window.__index = Window

function GENOUI:CreateWindow(options)
    local self = setmetatable({}, Window)
    
    self.Title = options.Title or "GENO"
    self.Subtitle = options.Subtitle or "Your game name here"
    self.Size = options.Size or UDim2.new(0, 580, 0, 400)
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "GENOUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = self.Size
    self.MainFrame.Position = UDim2.new(0.5, -self.Size.X.Offset / 2, 0.5, -self.Size.Y.Offset / 2)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    self.MainFrame.Parent = self.ScreenGui
    
    self.UICorner = createUICorner(self.MainFrame, 10)
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(0.5, 0, 0, 20)
    self.TitleLabel.Position = UDim2.new(0, 10, 0, 10)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextScaled = true
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextSize = 14
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.MainFrame
    
    self.BadgesContainer = Instance.new("Frame")
    self.BadgesContainer.Name = "BadgesContainer"
    self.BadgesContainer.Size = UDim2.new(0, 0, 0, 20)
    self.BadgesContainer.Position = UDim2.new(0, 60, 0, 10)
    self.BadgesContainer.BackgroundTransparency = 1
    self.BadgesContainer.Parent = self.MainFrame
    
    self.BadgesLayout = Instance.new("UIListLayout")
    self.BadgesLayout.FillDirection = Enum.FillDirection.Horizontal
    self.BadgesLayout.Padding = UDim.new(0, 5)
    self.BadgesLayout.Parent = self.BadgesContainer
    
    self.SubtitleLabel = Instance.new("TextLabel")
    self.SubtitleLabel.Name = "Subtitle"
    self.SubtitleLabel.Size = UDim2.new(0.5, 0, 0, 10)
    self.SubtitleLabel.Position = UDim2.new(0, 10, 0, 30)
    self.SubtitleLabel.BackgroundTransparency = 1
    self.SubtitleLabel.Text = self.Subtitle
    self.SubtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.SubtitleLabel.TextScaled = true
    self.SubtitleLabel.Font = Enum.Font.GothamBold
    self.SubtitleLabel.TextSize = 6
    self.SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.SubtitleLabel.Parent = self.MainFrame
    
    self.CloseButton = Instance.new("ImageButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 25, 0, 25)
    self.CloseButton.Position = UDim2.new(1, -30, 0, 10)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.CloseButton.Image = "rbxassetid://6302778252"
    self.CloseButton.ScaleType = Enum.ScaleType.Fit
    self.CloseButton.AutoButtonColor = false
    self.CloseButton.Parent = self.MainFrame
    createUICorner(self.CloseButton, 5)
    createUIStroke(self.CloseButton, Color3.fromRGB(50, 50, 50))
    setupButtonHover(self.CloseButton, Color3.fromRGB(40, 40, 40), Color3.fromRGB(220, 60, 60))
    
    self.FullscreenButton = Instance.new("ImageButton")
    self.FullscreenButton.Name = "FullscreenButton"
    self.FullscreenButton.Size = UDim2.new(0, 25, 0, 25)
    self.FullscreenButton.Position = UDim2.new(1, -90, 0, 10)
    self.FullscreenButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.FullscreenButton.Image = "rbxassetid://13471134084"
    self.FullscreenButton.ScaleType = Enum.ScaleType.Fit
    self.FullscreenButton.AutoButtonColor = false
    self.FullscreenButton.Parent = self.MainFrame
    createUICorner(self.FullscreenButton, 5)
    createUIStroke(self.FullscreenButton, Color3.fromRGB(50, 50, 50))
    setupButtonHover(self.FullscreenButton, Color3.fromRGB(40, 40, 40), Color3.fromRGB(60, 60, 60))
    
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "MinimizeButton"
    self.MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    self.MinimizeButton.Position = UDim2.new(1, -60, 0, 10)
    self.MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.MinimizeButton.Text = "-"
    self.MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.MinimizeButton.Font = Enum.Font.GothamBold
    self.MinimizeButton.TextSize = 14
    self.MinimizeButton.AutoButtonColor = false
    self.MinimizeButton.Parent = self.MainFrame
    createUICorner(self.MinimizeButton, 5)
    createUIStroke(self.MinimizeButton, Color3.fromRGB(50, 50, 50))
    setupButtonHover(self.MinimizeButton, Color3.fromRGB(40, 40, 40), Color3.fromRGB(60, 60, 60))
    
    self.RestoreButton = Instance.new("TextButton")
    self.RestoreButton.Name = "RestoreButton"
    self.RestoreButton.Size = UDim2.new(0, 120, 0, 40)
    self.RestoreButton.Position = UDim2.new(0.5, 0, 0, 10)
    self.RestoreButton.AnchorPoint = Vector2.new(0.5, 0)
    self.RestoreButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.RestoreButton.Text = "Open " .. self.Title
    self.RestoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.RestoreButton.Font = Enum.Font.GothamBold
    self.RestoreButton.TextSize = 12
    self.RestoreButton.AutoButtonColor = false
    self.RestoreButton.Visible = false
    self.RestoreButton.Parent = self.ScreenGui
    createUICorner(self.RestoreButton, 5)
    createUIStroke(self.RestoreButton, Color3.fromRGB(60, 60, 60))
    setupButtonHover(self.RestoreButton, Color3.fromRGB(40, 40, 40), Color3.fromRGB(60, 60, 60))
    
    self.ConfirmDialog = Instance.new("Frame")
    self.ConfirmDialog.Name = "ConfirmDialog"
    self.ConfirmDialog.Size = UDim2.new(0, 300, 0, 150)
    self.ConfirmDialog.Position = UDim2.new(0.5, -150, 0.5, -75)
    self.ConfirmDialog.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.ConfirmDialog.BorderSizePixel = 0
    self.ConfirmDialog.Visible = false
    self.ConfirmDialog.ZIndex = 10
    self.ConfirmDialog.Parent = self.MainFrame
    createUICorner(self.ConfirmDialog, 10)
    createUIStroke(self.ConfirmDialog, Color3.fromRGB(60, 60, 60), 2)
    
    self.DialogTitle = Instance.new("TextLabel")
    self.DialogTitle.Name = "DialogTitle"
    self.DialogTitle.Size = UDim2.new(1, 0, 0, 40)
    self.DialogTitle.BackgroundTransparency = 1
    self.DialogTitle.Text = "Close Application"
    self.DialogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.DialogTitle.Font = Enum.Font.GothamBold
    self.DialogTitle.TextSize = 16
    self.DialogTitle.ZIndex = 11
    self.DialogTitle.Parent = self.ConfirmDialog
    
    self.DialogMessage = Instance.new("TextLabel")
    self.DialogMessage.Name = "DialogMessage"
    self.DialogMessage.Size = UDim2.new(1, -20, 0, 40)
    self.DialogMessage.Position = UDim2.new(0, 10, 0, 40)
    self.DialogMessage.BackgroundTransparency = 1
    self.DialogMessage.Text = "Are you sure you want to close " .. self.Title .. "?"
    self.DialogMessage.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.DialogMessage.Font = Enum.Font.GothamBold
    self.DialogMessage.TextSize = 14
    self.DialogMessage.TextWrapped = true
    self.DialogMessage.ZIndex = 11
    self.DialogMessage.Parent = self.ConfirmDialog
    
    self.ButtonContainer = Instance.new("Frame")
    self.ButtonContainer.Name = "ButtonContainer"
    self.ButtonContainer.Size = UDim2.new(1, -20, 0, 30)
    self.ButtonContainer.Position = UDim2.new(0, 10, 1, -40)
    self.ButtonContainer.BackgroundTransparency = 1
    self.ButtonContainer.ZIndex = 11
    self.ButtonContainer.Parent = self.ConfirmDialog
    
    self.ButtonLayout = Instance.new("UIListLayout")
    self.ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    self.ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    self.ButtonLayout.Padding = UDim.new(0, 10)
    self.ButtonLayout.Parent = self.ButtonContainer
    
    self.CancelButton = Instance.new("TextButton")
    self.CancelButton.Name = "CancelButton"
    self.CancelButton.Size = UDim2.new(0, 80, 1, 0)
    self.CancelButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    self.CancelButton.Text = "Cancel"
    self.CancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.CancelButton.Font = Enum.Font.GothamBold
    self.CancelButton.TextSize = 14
    self.CancelButton.AutoButtonColor = false
    self.CancelButton.ZIndex = 12
    self.CancelButton.Parent = self.ButtonContainer
    createUICorner(self.CancelButton, 5)
    createUIStroke(self.CancelButton, Color3.fromRGB(80, 80, 80))
    setupButtonHover(self.CancelButton, Color3.fromRGB(60, 60, 60), Color3.fromRGB(80, 80, 80))
    setupButtonClick(self.CancelButton, Color3.fromRGB(60, 60, 60))
    
    self.ConfirmButton = Instance.new("TextButton")
    self.ConfirmButton.Name = "ConfirmButton"
    self.ConfirmButton.Size = UDim2.new(0, 80, 1, 0)
    self.ConfirmButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    self.ConfirmButton.Text = "Confirm"
    self.ConfirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.ConfirmButton.Font = Enum.Font.GothamBold
    self.ConfirmButton.TextSize = 14
    self.ConfirmButton.AutoButtonColor = false
    self.ConfirmButton.ZIndex = 12
    self.ConfirmButton.Parent = self.ButtonContainer
    createUICorner(self.ConfirmButton, 5)
    createUIStroke(self.ConfirmButton, Color3.fromRGB(180, 50, 50))
    setupButtonHover(self.ConfirmButton, Color3.fromRGB(220, 60, 60), Color3.fromRGB(200, 50, 50))
    setupButtonClick(self.ConfirmButton, Color3.fromRGB(220, 60, 60))
    
    -- Tab container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(1, -20, 0, 30)
    self.TabContainer.Position = UDim2.new(0, 10, 0, 50)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.MainFrame
    
    self.TabListLayout = Instance.new("UIListLayout")
    self.TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    self.TabListLayout.Padding = UDim.new(0, 5)
    self.TabListLayout.Parent = self.TabContainer
    
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Name = "ContentFrame"
    self.ContentFrame.Size = UDim2.new(1, -20, 1, -90)
    self.ContentFrame.Position = UDim2.new(0, 10, 0, 85)
    self.ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.ContentFrame.BorderSizePixel = 0
    self.ContentFrame.Parent = self.MainFrame
    createUICorner(self.ContentFrame, 8)
    createUIStroke(self.ContentFrame, Color3.fromRGB(50, 50, 50))
    
    self.Tabs = {}
    self.TabButtons = {}
    self.OriginalSize = self.Size
    self.OriginalPosition = self.MainFrame.Position
    self.IsFullscreen = false
    
    -- Setup functionality
    self:SetupFunctionality()
    
    return self
end

function Window:SetupFunctionality()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local fadeTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    -- Fullscreen
    self.FullscreenButton.MouseButton1Click:Connect(function()
        if self.IsFullscreen then
            TweenService:Create(self.MainFrame, tweenInfo, {Size = self.OriginalSize, Position = self.OriginalPosition}):Play()
            TweenService:Create(self.UICorner, tweenInfo, {CornerRadius = UDim.new(0, 10)}):Play()
            self.MainFrame.Draggable = true
            self.IsFullscreen = false
        else
            local fullscreenSize = UDim2.new(1, 0, 1, 0)
            local fullscreenPosition = UDim2.new(0, 0, 0, 0)
            TweenService:Create(self.MainFrame, tweenInfo, {Size = fullscreenSize, Position = fullscreenPosition}):Play()
            TweenService:Create(self.UICorner, tweenInfo, {CornerRadius = UDim.new(0, 0)}):Play()
            self.MainFrame.Draggable = false
            self.IsFullscreen = true
        end
    end)
    
    -- Minimize
    self.MinimizeButton.MouseButton1Click:Connect(function()
        TweenService:Create(self.MainFrame, fadeTweenInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(self.RestoreButton, fadeTweenInfo, {BackgroundTransparency = 0}):Play()
        self.MainFrame.Visible = false
        self.RestoreButton.Visible = true
    end)
    
    -- Restore
    self.RestoreButton.MouseButton1Click:Connect(function()
        self.MainFrame.Visible = true
        TweenService:Create(self.MainFrame, fadeTweenInfo, {BackgroundTransparency = 0}):Play()
        TweenService:Create(self.RestoreButton, fadeTweenInfo, {BackgroundTransparency = 1}):Play()
        self.RestoreButton.Visible = false
    end)
    
    -- Close with dialog
    self.CloseButton.MouseButton1Click:Connect(function()
        self:ShowConfirmDialog()
    end)
    
    self.CancelButton.MouseButton1Click:Connect(function()
        self:HideConfirmDialog()
    end)
    
    self.ConfirmButton.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(self.MainFrame, tweenInfo, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            self.ScreenGui:Destroy()
        end)
    end)
end

function Window:ShowConfirmDialog()
    self.ConfirmDialog.Visible = true
    self.ConfirmDialog.BackgroundTransparency = 1
    self.ConfirmDialog.Size = UDim2.new(0, 10, 0, 10)
    self.ConfirmDialog.Position = UDim2.new(0.5, -5, 0.5, -5)
    
    TweenService:Create(self.ConfirmDialog, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
    TweenService:Create(self.ConfirmDialog, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 300, 0, 150),
        Position = UDim2.new(0.5, -150, 0.5, -75)
    }):Play()
end

function Window:HideConfirmDialog()
    TweenService:Create(self.ConfirmDialog, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    local sizeTween = TweenService:Create(self.ConfirmDialog, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0.5, -5, 0.5, -5)
    })
    sizeTween:Play()
    sizeTween.Completed:Connect(function()
        self.ConfirmDialog.Visible = false
    end)
end

function Window:AddBadge(text, bgColor, textColor)
    local badge = Instance.new("Frame")
    badge.Name = text .. "Badge"
    badge.Size = UDim2.new(0, 0, 0, 16)
    badge.BackgroundColor3 = bgColor or Color3.fromRGB(255, 165, 0)
    badge.BorderSizePixel = 0
    createUICorner(badge, 4)
    createUIStroke(badge, Color3.fromRGB(bgColor.R * 255 + 20, bgColor.G * 255 + 20, bgColor.B * 255 + 20))
    
    local badgeText = Instance.new("TextLabel")
    badgeText.Size = UDim2.new(1, -8, 1, 0)
    badgeText.Position = UDim2.new(0, 4, 0, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Text = text
    badgeText.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
    badgeText.Font = Enum.Font.GothamBold
    badgeText.TextSize = 10
    badgeText.TextXAlignment = Enum.TextXAlignment.Center
    badgeText.TextYAlignment = Enum.TextYAlignment.Center
    badgeText.Parent = badge
    
    local textSize = TextService:GetTextSize(badgeText.Text, badgeText.TextSize, badgeText.Font, Vector2.new(1000, 1000))
    badge.Size = UDim2.new(0, textSize.X + 12, 0, 16)
    
    badge.Parent = self.BadgesContainer
    self.BadgesContainer.Size = UDim2.new(0, self.BadgesLayout.AbsoluteContentSize.X, 0, 20)
end

function Window:AddTab(name)
    local tab = {}
    
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(0, 80, 1, 0)
    tabButton.BackgroundColor3 = #self.TabButtons == 0 and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(30, 30, 30)
    tabButton.Text = name
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextSize = 12
    tabButton.AutoButtonColor = false
    createUICorner(tabButton, 5)
    createUIStroke(tabButton, Color3.fromRGB(50, 50, 50))
    tabButton.Parent = self.TabContainer
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 5
    tabContent.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.Visible = #self.TabButtons == 0
    tabContent.Parent = self.ContentFrame
    
    local contentListLayout = Instance.new("UIListLayout")
    contentListLayout.Padding = UDim.new(0, 10)
    contentListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentListLayout.Parent = tabContent
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.Parent = tabContent
    
    tab.AddToggle = function(_, options)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, -20, 0, 40)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        toggleFrame.BorderSizePixel = 0
        createUICorner(toggleFrame, 6)
        createUIStroke(toggleFrame, Color3.fromRGB(60, 60, 60))
        toggleFrame.Parent = tabContent
        
        local toggleText = Instance.new("TextLabel")
        toggleText.Size = UDim2.new(0.7, 0, 1, 0)
        toggleText.Position = UDim2.new(0, 10, 0, 0)
        toggleText.BackgroundTransparency = 1
        toggleText.Text = options.Name or "Toggle"
        toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleText.Font = Enum.Font.GothamBold
        toggleText.TextSize = 14
        toggleText.TextXAlignment = Enum.TextXAlignment.Left
        toggleText.TextYAlignment = Enum.TextYAlignment.Center
        toggleText.Parent = toggleFrame
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0, 50, 0, 25)
        toggleButton.Position = UDim2.new(1, -60, 0.5, -12.5)
        toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        toggleButton.Text = ""
        toggleButton.AutoButtonColor = false
        createUICorner(toggleButton, 12)
        createUIStroke(toggleButton, Color3.fromRGB(100, 100, 100))
        toggleButton.Parent = toggleFrame
        
        local toggleKnob = Instance.new("Frame")
        toggleKnob.Size = UDim2.new(0, 21, 0, 21)
        toggleKnob.Position = UDim2.new(0, 2, 0, 2)
        toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createUICorner(toggleKnob, 10)
        toggleKnob.Parent = toggleButton
        
        local state = options.Default or false
        if state then
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            toggleKnob.Position = UDim2.new(0, 27, 0, 2)
            toggleText.Text = options.Name .. ": ON"
        end
        
        toggleButton.MouseButton1Click:Connect(function()
            state = not state
            if state then
                TweenService:Create(toggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(0, 170, 0)}):Play()
                TweenService:Create(toggleKnob, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 27, 0, 2)}):Play()
                toggleText.Text = options.Name .. ": ON"
            else
                TweenService:Create(toggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
                TweenService:Create(toggleKnob, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0, 2)}):Play()
                toggleText.Text = options.Name
            end
            if options.Callback then options.Callback(state) end
        end)
    end
    
    tab.AddButton = function(_, options)
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Size = UDim2.new(1, -20, 0, 40)
        buttonFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        buttonFrame.BorderSizePixel = 0
        createUICorner(buttonFrame, 6)
        createUIStroke(buttonFrame, Color3.fromRGB(60, 60, 60))
        buttonFrame.Parent = tabContent
        
        local buttonText = Instance.new("TextLabel")
        buttonText.Size = UDim2.new(0.7, 0, 1, 0)
        buttonText.Position = UDim2.new(0, 10, 0, 0)
        buttonText.BackgroundTransparency = 1
        buttonText.Text = options.Name or "Button"
        buttonText.TextColor3 = Color3.fromRGB(255, 255, 255)
        buttonText.Font = Enum.Font.GothamBold
        buttonText.TextSize = 14
        buttonText.TextXAlignment = Enum.TextXAlignment.Left
        buttonText.TextYAlignment = Enum.TextYAlignment.Center
        buttonText.Parent = buttonFrame
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 80, 0, 30)
        button.Position = UDim2.new(1, -90, 0.5, -15)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.Text = options.ButtonText or "Click"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 14
        button.AutoButtonColor = false
        createUICorner(button, 6)
        createUIStroke(button, Color3.fromRGB(80, 80, 80))
        button.Parent = buttonFrame
        setupButtonHover(button, Color3.fromRGB(60, 60, 60), Color3.fromRGB(80, 80, 80))
        setupButtonClick(button, Color3.fromRGB(60, 60, 60))
        
        button.MouseButton1Click:Connect(function()
            if options.Callback then options.Callback() end
        end)
    end
    
    tab.AddDropdown = function(_, options)
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(1, -20, 0, 40)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        dropdownFrame.BorderSizePixel = 0
        createUICorner(dropdownFrame, 6)
        createUIStroke(dropdownFrame, Color3.fromRGB(60, 60, 60))
        dropdownFrame.Parent = tabContent
        
        local dropdownText = Instance.new("TextLabel")
        dropdownText.Size = UDim2.new(0.7, 0, 1, 0)
        dropdownText.Position = UDim2.new(0, 10, 0, 0)
        dropdownText.BackgroundTransparency = 1
        dropdownText.Text = options.Name or "Dropdown"
        dropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownText.Font = Enum.Font.GothamBold
        dropdownText.TextSize = 14
        dropdownText.TextXAlignment = Enum.TextXAlignment.Left
        dropdownText.TextYAlignment = Enum.TextYAlignment.Center
        dropdownText.Parent = dropdownFrame
        
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Size = UDim2.new(0, 80, 0, 30)
        dropdownButton.Position = UDim2.new(1, -90, 0.5, -15)
        dropdownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        dropdownButton.Text = "Select"
        dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownButton.Font = Enum.Font.GothamBold
        dropdownButton.TextSize = 14
        dropdownButton.AutoButtonColor = false
        createUICorner(dropdownButton, 6)
        createUIStroke(dropdownButton, Color3.fromRGB(80, 80, 80))
        dropdownButton.Parent = dropdownFrame
        setupButtonHover(dropdownButton, Color3.fromRGB(60, 60, 60), Color3.fromRGB(80, 80, 80))
        setupButtonClick(dropdownButton, Color3.fromRGB(60, 60, 60))
        
        local dropdownOptions = Instance.new("Frame")
        dropdownOptions.Size = UDim2.new(1, 0, 0, 120)
        dropdownOptions.Position = UDim2.new(0, 0, 1, 5)
        dropdownOptions.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        dropdownOptions.BorderSizePixel = 0
        dropdownOptions.Visible = false
        dropdownOptions.ZIndex = 15
        createUICorner(dropdownOptions, 6)
        createUIStroke(dropdownOptions, Color3.fromRGB(70, 70, 70))
        dropdownOptions.Parent = dropdownButton
        
        local dropdownScrolling = Instance.new("ScrollingFrame")
        dropdownScrolling.Size = UDim2.new(1, 0, 1, 0)
        dropdownScrolling.BackgroundTransparency = 1
        dropdownScrolling.BorderSizePixel = 0
        dropdownScrolling.ScrollBarThickness = 3
        dropdownScrolling.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        dropdownScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
        dropdownScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
        dropdownScrolling.ZIndex = 16
        dropdownScrolling.Parent = dropdownOptions
        
        local dropdownLayout = Instance.new("UIListLayout")
        dropdownLayout.Padding = UDim.new(0, 2)
        dropdownLayout.Parent = dropdownScrolling
        
        local items = options.Options or {"Option 1", "Option 2", "Option 3"}
        for _, item in ipairs(items) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, -10, 0, 30)
            optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            optionButton.Text = item
            optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            optionButton.Font = Enum.Font.GothamBold
            optionButton.TextSize = 14
            optionButton.AutoButtonColor = false
            optionButton.ZIndex = 17
            createUICorner(optionButton, 4)
            optionButton.Parent = dropdownScrolling
            
            optionButton.MouseEnter:Connect(function()
                optionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            end)
            
            optionButton.MouseLeave:Connect(function()
                optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                dropdownButton.Text = item
                dropdownOptions.Visible = false
                if options.Callback then options.Callback(item) end
            end)
        end
        
        local dropdownOpen = false
        dropdownButton.MouseButton1Click:Connect(function()
            dropdownOpen = not dropdownOpen
            dropdownOptions.Visible = dropdownOpen
        end)
    end
    
    tab.AddInformation = function(_, options)
        local infoFrame = Instance.new("Frame")
        infoFrame.Size = UDim2.new(1, -20, 0, 60)
        infoFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        infoFrame.BorderSizePixel = 0
        createUICorner(infoFrame, 6)
        createUIStroke(infoFrame, Color3.fromRGB(60, 60, 60))
        infoFrame.Parent = tabContent
        
        local infoIcon = Instance.new("ImageLabel")
        infoIcon.Size = UDim2.new(0, 30, 0, 30)
        infoIcon.Position = UDim2.new(0, 10, 0.5, -15)
        infoIcon.BackgroundTransparency = 1
        infoIcon.Image = "rbxassetid://7072718266" -- Info icon
        infoIcon.Parent = infoFrame
        
        local infoTitle = Instance.new("TextLabel")
        infoTitle.Size = UDim2.new(1, -50, 0, 20)
        infoTitle.Position = UDim2.new(0, 50, 0, 5)
        infoTitle.BackgroundTransparency = 1
        infoTitle.Text = options.Title or "Information"
        infoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        infoTitle.Font = Enum.Font.GothamBold
        infoTitle.TextSize = 14
        infoTitle.TextXAlignment = Enum.TextXAlignment.Left
        infoTitle.Parent = infoFrame
        
        local infoMessage = Instance.new("TextLabel")
        infoMessage.Size = UDim2.new(1, -50, 0, 30)
        infoMessage.Position = UDim2.new(0, 50, 0, 25)
        infoMessage.BackgroundTransparency = 1
        infoMessage.Text = options.Message or "Information message."
        infoMessage.TextColor3 = Color3.fromRGB(200, 200, 200)
        infoMessage.Font = Enum.Font.GothamBold
        infoMessage.TextSize = 12
        infoMessage.TextXAlignment = Enum.TextXAlignment.Left
        infoMessage.TextYAlignment = Enum.TextYAlignment.Top
        infoMessage.TextWrapped = true
        infoMessage.Parent = infoFrame
    end
    
    tab.AddWarning = function(_, options)
        local warningFrame = Instance.new("Frame")
        warningFrame.Size = UDim2.new(1, -20, 0, 60)
        warningFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        warningFrame.BorderSizePixel = 0
        createUICorner(warningFrame, 6)
        createUIStroke(warningFrame, Color3.fromRGB(60, 60, 60))
        warningFrame.Parent = tabContent
        
        local warningIcon = Instance.new("ImageLabel")
        warningIcon.Size = UDim2.new(0, 30, 0, 30)
        warningIcon.Position = UDim2.new(0, 10, 0.5, -15)
        warningIcon.BackgroundTransparency = 1
        warningIcon.Image = "rbxassetid://7072987152" -- Warning icon
        warningIcon.Parent = warningFrame
        
        local warningTitle = Instance.new("TextLabel")
        warningTitle.Size = UDim2.new(1, -50, 0, 20)
        warningTitle.Position = UDim2.new(0, 50, 0, 5)
        warningTitle.BackgroundTransparency = 1
        warningTitle.Text = options.Title or "Warning"
        warningTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
        warningTitle.Font = Enum.Font.GothamBold
        warningTitle.TextSize = 14
        warningTitle.TextXAlignment = Enum.TextXAlignment.Left
        warningTitle.Parent = warningFrame
        
        local warningMessage = Instance.new("TextLabel")
        warningMessage.Size = UDim2.new(1, -50, 0, 30)
        warningMessage.Position = UDim2.new(0, 50, 0, 30)
        warningMessage.BackgroundTransparency = 1
        warningMessage.Text = options.Message or "Warning message."
        warningMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
        warningMessage.Font = Enum.Font.GothamBold
        warningMessage.TextSize = 12
        warningMessage.TextXAlignment = Enum.TextXAlignment.Left
        warningMessage.TextYAlignment = Enum.TextYAlignment.Top
        warningMessage.TextWrapped = true
        warningMessage.Parent = warningFrame
    end
    
    tab.AddParagraph = function(_, options)
        local paragraphFrame = Instance.new("Frame")
        paragraphFrame.Size = UDim2.new(1, -20, 0, options.Height or 80)
        paragraphFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        paragraphFrame.BorderSizePixel = 0
        createUICorner(paragraphFrame, 6)
        createUIStroke(paragraphFrame, Color3.fromRGB(60, 60, 60))
        paragraphFrame.Parent = tabContent
        
        local paragraphText = Instance.new("TextLabel")
        paragraphText.Size = UDim2.new(1, -20, 1, -20)
        paragraphText.Position = UDim2.new(0, 10, 0, 10)
        paragraphText.BackgroundTransparency = 1
        paragraphText.Text = options.Text or "Paragraph text."
        paragraphText.TextColor3 = Color3.fromRGB(255, 255, 255)
        paragraphText.Font = Enum.Font.GothamBold
        paragraphText.TextSize = 12
        paragraphText.TextXAlignment = Enum.TextXAlignment.Left
        paragraphText.TextYAlignment = Enum.TextYAlignment.Top
        paragraphText.TextWrapped = true
        paragraphText.Parent = paragraphFrame

        local paragraphObject = {}

        function paragraphObject:SetContent(newText)
            paragraphText.Text = newText
        end

        return paragraphObject
    end
    
    tab.AddSlider = function(_, options)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, -20, 0, 60)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        sliderFrame.BorderSizePixel = 0
        createUICorner(sliderFrame, 6)
        createUIStroke(sliderFrame, Color3.fromRGB(60, 60, 60))
        sliderFrame.Parent = tabContent
        
        local sliderText = Instance.new("TextLabel")
        sliderText.Size = UDim2.new(1, -20, 0, 20)
        sliderText.Position = UDim2.new(0, 10, 0, 5)
        sliderText.BackgroundTransparency = 1
        sliderText.Text = options.Name or "Slider"
        sliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
        sliderText.Font = Enum.Font.GothamBold
        sliderText.TextSize = 14
        sliderText.TextXAlignment = Enum.TextXAlignment.Left
        sliderText.Parent = sliderFrame
        
        local sliderTrack = Instance.new("Frame")
        sliderTrack.Size = UDim2.new(1, -20, 0, 6)
        sliderTrack.Position = UDim2.new(0, 10, 0, 35)
        sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        createUICorner(sliderTrack, 3)
        sliderTrack.Parent = sliderFrame
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new(0, 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        createUICorner(sliderFill, 3)
        sliderFill.Parent = sliderTrack
        
        local sliderButton = Instance.new("TextButton")
        sliderButton.Size = UDim2.new(0, 16, 0, 16)
        sliderButton.Position = UDim2.new(0, -8, 0.5, -8)
        sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderButton.Text = ""
        sliderButton.AutoButtonColor = false
        createUICorner(sliderButton, 8)
        createUIStroke(sliderButton, Color3.fromRGB(100, 100, 100), 2)
        sliderButton.Parent = sliderTrack
        
        local min = options.Min or 0
        local max = options.Max or 100
        local value = options.Default or min
        local dragging = false
        
        local function updateValue(newValue)
            value = math.clamp(newValue, min, max)
            local relative = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(relative, 0, 1, 0)
            sliderButton.Position = UDim2.new(relative, -8, 0.5, -8)
            sliderText.Text = options.Name .. ": " .. math.floor(value)
            if options.Callback then options.Callback(value) end
        end
        
        updateValue(value)
        
        sliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local mousePos = UserInputService:GetMouseLocation()
                local trackPos = sliderTrack.AbsolutePosition
                local trackSize = sliderTrack.AbsoluteSize
                local relative = math.clamp((mousePos.X - trackPos.X) / trackSize.X, 0, 1)
                updateValue(min + relative * (max - min))
            end
        end)
    end
    
    tab.AddDialogueMessage = function(_, options)
        local dialogueFrame = Instance.new("Frame")
        dialogueFrame.Size = UDim2.new(1, -20, 0, 40)
        dialogueFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        dialogueFrame.BorderSizePixel = 0
        createUICorner(dialogueFrame, 6)
        createUIStroke(dialogueFrame, Color3.fromRGB(60, 60, 60))
        dialogueFrame.Parent = tabContent
        
        local dialogueText = Instance.new("TextLabel")
        dialogueText.Size = UDim2.new(0.7, 0, 1, 0)
        dialogueText.Position = UDim2.new(0, 10, 0, 0)
        dialogueText.BackgroundTransparency = 1
        dialogueText.Text = options.Name or "Show Message"
        dialogueText.TextColor3 = Color3.fromRGB(255, 255, 255)
        dialogueText.Font = Enum.Font.GothamBold
        dialogueText.TextSize = 14
        dialogueText.TextXAlignment = Enum.TextXAlignment.Left
        dialogueText.TextYAlignment = Enum.TextYAlignment.Center
        dialogueText.Parent = dialogueFrame
        
        local openButton = Instance.new("TextButton")
        openButton.Size = UDim2.new(0, 80, 0, 30)
        openButton.Position = UDim2.new(1, -90, 0.5, -15)
        openButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        openButton.Text = "Open"
        openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        openButton.Font = Enum.Font.GothamBold
        openButton.TextSize = 14
        openButton.AutoButtonColor = false
        createUICorner(openButton, 6)
        createUIStroke(openButton, Color3.fromRGB(80, 80, 80))
        openButton.Parent = dialogueFrame
        setupButtonHover(openButton, Color3.fromRGB(60, 60, 60), Color3.fromRGB(80, 80, 80))
        setupButtonClick(openButton, Color3.fromRGB(60, 60, 60))
        
        local messageDialog = Instance.new("Frame")
        messageDialog.Size = UDim2.new(0, 280, 0, 160)
        messageDialog.Position = UDim2.new(0.5, -140, 0.5, -80)
        messageDialog.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        messageDialog.BorderSizePixel = 0
        messageDialog.Visible = false
        messageDialog.ZIndex = 10
        messageDialog.Parent = self.MainFrame
        createUICorner(messageDialog, 10)
        createUIStroke(messageDialog, Color3.fromRGB(60, 60, 60), 2)
        
        local messageTitle = Instance.new("TextLabel")
        messageTitle.Size = UDim2.new(1, 0, 0, 40)
        messageTitle.BackgroundTransparency = 1
        messageTitle.Text = options.Title or "Information"
        messageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        messageTitle.Font = Enum.Font.GothamBold
        messageTitle.TextSize = 16
        messageTitle.ZIndex = 11
        messageTitle.Parent = messageDialog
        
        local messageMessage = Instance.new("TextLabel")
        messageMessage.Size = UDim2.new(1, -20, 0, 60)
        messageMessage.Position = UDim2.new(0, 10, 0, 40)
        messageMessage.BackgroundTransparency = 1
        messageMessage.Text = options.Message or "Message here."
        messageMessage.TextColor3 = Color3.fromRGB(200, 200, 200)
        messageMessage.Font = Enum.Font.GothamBold
        messageMessage.TextSize = 14
        messageMessage.TextWrapped = true
        messageMessage.ZIndex = 11
        messageMessage.Parent = messageDialog
        
        local messageButtonContainer = Instance.new("Frame")
        messageButtonContainer.Size = UDim2.new(1, -20, 0, 30)
        messageButtonContainer.Position = UDim2.new(0, 10, 1, -40)
        messageButtonContainer.BackgroundTransparency = 1
        messageButtonContainer.ZIndex = 11
        messageButtonContainer.Parent = messageDialog
        
        local messageButtonLayout = Instance.new("UIListLayout")
        messageButtonLayout.FillDirection = Enum.FillDirection.Horizontal
        messageButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        messageButtonLayout.Padding = UDim.new(0, 10)
        messageButtonLayout.Parent = messageButtonContainer
        
        local messageCloseButton = Instance.new("TextButton")
        messageCloseButton.Size = UDim2.new(0, 80, 1, 0)
        messageCloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        messageCloseButton.Text = "OK"
        messageCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        messageCloseButton.Font = Enum.Font.GothamBold
        messageCloseButton.TextSize = 14
        messageCloseButton.AutoButtonColor = false
        messageCloseButton.ZIndex = 12
        messageCloseButton.Parent = messageButtonContainer
        createUICorner(messageCloseButton, 5)
        createUIStroke(messageCloseButton, Color3.fromRGB(80, 80, 80))
        setupButtonHover(messageCloseButton, Color3.fromRGB(60, 60, 60), Color3.fromRGB(80, 80, 80))
        setupButtonClick(messageCloseButton, Color3.fromRGB(60, 60, 60))
        
        local function showDialog()
            messageDialog.Visible = true
            messageDialog.BackgroundTransparency = 1
            messageDialog.Size = UDim2.new(0, 10, 0, 10)
            messageDialog.Position = UDim2.new(0.5, -5, 0.5, -5)
            
            TweenService:Create(messageDialog, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
            TweenService:Create(messageDialog, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 280, 0, 160),
                Position = UDim2.new(0.5, -140, 0.5, -80)
            }):Play()
            
            if options.Callback then options.Callback(true) end
        end
        
        local function hideDialog()
            TweenService:Create(messageDialog, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
            local sizeTween = TweenService:Create(messageDialog, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 10, 0, 10),
                Position = UDim2.new(0.5, -5, 0.5, -5)
            })
            sizeTween:Play()
            sizeTween.Completed:Connect(function()
                messageDialog.Visible = false
            end)
        end
        
        openButton.MouseButton1Click:Connect(showDialog)
        messageCloseButton.MouseButton1Click:Connect(hideDialog)
    end
    
    tab.AddDialogueDropdown = function(_, options)
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(1, -20, 0, 40)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        dropdownFrame.BorderSizePixel = 0
        createUICorner(dropdownFrame, 6)
        createUIStroke(dropdownFrame, Color3.fromRGB(60, 60, 60))
        dropdownFrame.Parent = tabContent
        
        local dropdownText = Instance.new("TextLabel")
        dropdownText.Size = UDim2.new(0.7, 0, 1, 0)
        dropdownText.Position = UDim2.new(0, 10, 0, 0)
        dropdownText.BackgroundTransparency = 1
        dropdownText.Text = options.Name or "Open Dropdown"
        dropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownText.Font = Enum.Font.GothamBold
        dropdownText.TextSize = 14
        dropdownText.TextXAlignment = Enum.TextXAlignment.Left
        dropdownText.TextYAlignment = Enum.TextYAlignment.Center
        dropdownText.Parent = dropdownFrame
        
        local openButton = Instance.new("TextButton")
        openButton.Size = UDim2.new(0, 80, 0, 30)
        openButton.Position = UDim2.new(1, -90, 0.5, -15)
        openButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        openButton.Text = "Open"
        openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        openButton.Font = Enum.Font.GothamBold
        openButton.TextSize = 14
        openButton.AutoButtonColor = false
        createUICorner(openButton, 6)
        createUIStroke(openButton, Color3.fromRGB(80, 80, 80))
        openButton.Parent = dropdownFrame
        setupButtonHover(openButton, Color3.fromRGB(60, 60, 60), Color3.fromRGB(80, 80, 80))
        setupButtonClick(openButton, Color3.fromRGB(60, 60, 60))
        
        local dropdownDialog = Instance.new("Frame")
        dropdownDialog.Size = UDim2.new(0, 250, 0, 180)
        dropdownDialog.Position = UDim2.new(0.5, -125, 0.5, -90)
        dropdownDialog.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        dropdownDialog.BorderSizePixel = 0
        dropdownDialog.Visible = false
        dropdownDialog.ZIndex = 10
        dropdownDialog.Parent = self.MainFrame
        createUICorner(dropdownDialog, 10)
        createUIStroke(dropdownDialog, Color3.fromRGB(60, 60, 60), 2)
        
        local dropdownTitle = Instance.new("TextLabel")
        dropdownTitle.Size = UDim2.new(1, 0, 0, 40)
        dropdownTitle.BackgroundTransparency = 1
        dropdownTitle.Text = options.Title or "Select Option"
        dropdownTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownTitle.Font = Enum.Font.GothamBold
        dropdownTitle.TextSize = 16
        dropdownTitle.ZIndex = 11
        dropdownTitle.Parent = dropdownDialog
        
        local dropdownMessage = Instance.new("TextLabel")
        dropdownMessage.Size = UDim2.new(1, -20, 0, 40)
        dropdownMessage.Position = UDim2.new(0, 10, 0, 40)
        dropdownMessage.BackgroundTransparency = 1
        dropdownMessage.Text = options.Message or "Choose an option:"
        dropdownMessage.TextColor3 = Color3.fromRGB(200, 200, 200)
        dropdownMessage.Font = Enum.Font.GothamBold
        dropdownMessage.TextSize = 14
        dropdownMessage.TextWrapped = true
        dropdownMessage.ZIndex = 11
        dropdownMessage.Parent = dropdownDialog
        
        local dropdownInnerFrame = Instance.new("Frame")
        dropdownInnerFrame.Size = UDim2.new(1, -20, 0, 35)
        dropdownInnerFrame.Position = UDim2.new(0, 10, 0, 90)
        dropdownInnerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        dropdownInnerFrame.BorderSizePixel = 0
        dropdownInnerFrame.ZIndex = 11
        createUICorner(dropdownInnerFrame, 6)
        createUIStroke(dropdownInnerFrame, Color3.fromRGB(70, 70, 70))
        dropdownInnerFrame.Parent = dropdownDialog
        
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Size = UDim2.new(1, 0, 1, 0)
        dropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        dropdownButton.Text = "Select Option ▼"
        dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownButton.Font = Enum.Font.GothamBold
        dropdownButton.TextSize = 14
        dropdownButton.AutoButtonColor = false
        dropdownButton.ZIndex = 12
        createUICorner(dropdownButton, 6)
        dropdownButton.Parent = dropdownInnerFrame
        setupButtonHover(dropdownButton, Color3.fromRGB(40, 40, 40), Color3.fromRGB(60, 60, 60))
        setupButtonClick(dropdownButton, Color3.fromRGB(40, 40, 40))
        
        local dropdownOptions = Instance.new("Frame")
        dropdownOptions.Size = UDim2.new(1, 0, 0, 120)
        dropdownOptions.Position = UDim2.new(0, 0, 1, 5)
        dropdownOptions.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        dropdownOptions.BorderSizePixel = 0
        dropdownOptions.Visible = false
        dropdownOptions.ZIndex = 15
        createUICorner(dropdownOptions, 6)
        createUIStroke(dropdownOptions, Color3.fromRGB(70, 70, 70))
        dropdownOptions.Parent = dropdownInnerFrame
        
        local dropdownScrolling = Instance.new("ScrollingFrame")
        dropdownScrolling.Size = UDim2.new(1, 0, 1, 0)
        dropdownScrolling.BackgroundTransparency = 1
        dropdownScrolling.BorderSizePixel = 0
        dropdownScrolling.ScrollBarThickness = 3
        dropdownScrolling.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        dropdownScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
        dropdownScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
        dropdownScrolling.ZIndex = 16
        dropdownScrolling.Parent = dropdownOptions
        
        local dropdownLayout = Instance.new("UIListLayout")
        dropdownLayout.Padding = UDim.new(0, 2)
        dropdownLayout.Parent = dropdownScrolling
        
        local items = options.Options or {"Option 1", "Option 2", "Option 3"}
        for i, item in ipairs(items) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, -10, 0, 30)
            optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            optionButton.Text = item
            optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            optionButton.Font = Enum.Font.GothamBold
            optionButton.TextSize = 14
            optionButton.AutoButtonColor = false
            optionButton.ZIndex = 17
            createUICorner(optionButton, 4)
            optionButton.Parent = dropdownScrolling
            
            optionButton.MouseEnter:Connect(function()
                optionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            end)
            
            optionButton.MouseLeave:Connect(function()
                optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                dropdownButton.Text = item .. " ▼"
                dropdownOptions.Visible = false
                if options.Callback then options.Callback(item) end
            end)
        end
        
        local dropdownButtonContainer = Instance.new("Frame")
        dropdownButtonContainer.Size = UDim2.new(1, -20, 0, 30)
        dropdownButtonContainer.Position = UDim2.new(0, 10, 1, -40)
        dropdownButtonContainer.BackgroundTransparency = 1
        dropdownButtonContainer.ZIndex = 11
        dropdownButtonContainer.Parent = dropdownDialog
        
        local dropdownButtonLayout = Instance.new("UIListLayout")
        dropdownButtonLayout.FillDirection = Enum.FillDirection.Horizontal
        dropdownButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        dropdownButtonLayout.Padding = UDim.new(0, 10)
        dropdownButtonLayout.Parent = dropdownButtonContainer
        
        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 80, 1, 0)
        closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        closeButton.Text = "Close"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.Font = Enum.Font.GothamBold
        closeButton.TextSize = 14
        closeButton.AutoButtonColor = false
        closeButton.ZIndex = 12
        createUICorner(closeButton, 5)
        createUIStroke(closeButton, Color3.fromRGB(80, 80, 80))
        closeButton.Parent = dropdownButtonContainer
        setupButtonHover(closeButton, Color3.fromRGB(60, 60, 60), Color3.fromRGB(80, 80, 80))
        setupButtonClick(closeButton, Color3.fromRGB(60, 60, 60))
        
        local dropdownOpen = false
        dropdownButton.MouseButton1Click:Connect(function()
            dropdownOpen = not dropdownOpen
            dropdownOptions.Visible = dropdownOpen
            dropdownButton.Text = dropdownOpen and "Select Option ▲" or "Select Option ▼"
        end)
        
        local function showDialog()
            dropdownDialog.Visible = true
            dropdownDialog.BackgroundTransparency = 1
            dropdownDialog.Size = UDim2.new(0, 10, 0, 10)
            dropdownDialog.Position = UDim2.new(0.5, -5, 0.5, -5)
            
            TweenService:Create(dropdownDialog, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
            TweenService:Create(dropdownDialog, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 250, 0, 180),
                Position = UDim2.new(0.5, -125, 0.5, -90)
            }):Play()
        end
        
        local function hideDialog()
            TweenService:Create(dropdownDialog, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
            local sizeTween = TweenService:Create(dropdownDialog, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 10, 0, 10),
                Position = UDim2.new(0.5, -5, 0.5, -5)
            })
            sizeTween:Play()
            sizeTween.Completed:Connect(function()
                dropdownDialog.Visible = false
                dropdownOpen = false
                dropdownOptions.Visible = false
                dropdownButton.Text = "Select Option ▼"
            end)
        end
        
        openButton.MouseButton1Click:Connect(showDialog)
        closeButton.MouseButton1Click:Connect(hideDialog)
    end
    
    tabButton.MouseButton1Click:Connect(function()
        for _, content in pairs(self.Tabs) do
            content.Visible = false
        end
        for _, btn in ipairs(self.TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
        tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tabContent.Visible = true
    end)
    
    table.insert(self.Tabs, tabContent)
    table.insert(self.TabButtons, tabButton)
    
    return tab
end

return GENOUI
