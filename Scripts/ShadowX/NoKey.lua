local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("ShadowX") then
    playerGui.ShadowX:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShadowX"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local isMobile = UserInputService.TouchEnabled

-- Global connection tracker to prevent memory leaks and thread crashes
local connections = {}
local function connect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(connections, conn)
    return conn
end

-- Spring physics helper for spring shake and snaps (no drag delay)
local function createSpring(stiffness, damping, initialValue)
    return {
        Target = initialValue or 0,
        Position = initialValue or 0,
        Velocity = 0,
        Stiffness = stiffness or 150,
        Damping = damping or 12,
        Update = function(self, dt)
            local steps = math.clamp(math.floor(dt / 0.01) + 1, 1, 10)
            local stepDt = dt / steps
            for i = 1, steps do
                local force = (self.Target - self.Position) * self.Stiffness - self.Velocity * self.Damping
                self.Velocity = self.Velocity + force * stepDt
                self.Position = self.Position + self.Velocity * stepDt
            end
            return self.Position
        end
    }
end

local function createUDim2Spring(stiffness, damping, initialValue)
    local sx = createSpring(stiffness, damping, initialValue.X.Offset)
    local sy = createSpring(stiffness, damping, initialValue.Y.Offset)
    return {
        ScaleX = initialValue.X.Scale,
        ScaleY = initialValue.Y.Scale,
        X = sx,
        Y = sy,
        SetTarget = function(self, target)
            self.ScaleX = target.X.Scale
            self.ScaleY = target.Y.Scale
            self.X.Target = target.X.Offset
            self.Y.Target = target.Y.Offset
        end,
        SetPosition = function(self, pos)
            self.ScaleX = pos.X.Scale
            self.ScaleY = pos.Y.Scale
            self.X.Position = pos.X.Offset
            self.Y.Position = pos.Y.Offset
            self.X.Velocity = 0
            self.Y.Velocity = 0
        end,
        Update = function(self, dt)
            return UDim2.new(self.ScaleX, self.X:Update(dt), self.ScaleY, self.Y:Update(dt))
        end
    }
end

-- Core UI helper functions
local function corner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or Color3.fromRGB(120, 80, 200)
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Transparency = 0.2
    return s
end

local function glowStroke(parent, color1, color2, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Thickness = thickness or 1.2
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Transparency = 0.1
    
    local grad = Instance.new("UIGradient", s)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    })
    grad.Rotation = 45
    return s
end

local function applyGradient(frame, color1, color2)
    local grad = Instance.new("UIGradient", frame)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    })
    grad.Rotation = 45
    return grad
end

local function applyTextGradient(label, color1, color2)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    local grad = Instance.new("UIGradient", label)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    })
    grad.Rotation = 0
    return grad
end

local function getTime()
    return os.date("%H:%M:%S")
end

-- Reusable hover and squash micro-animations for buttons
local function hoverEffect(btn, activeBg, inactiveBg, activeStroke, inactiveStroke)
    local scale = Instance.new("UIScale", btn)
    scale.Scale = 1
    
    local uistroke = btn:FindFirstChildOfClass("UIStroke")
    
    local function isStateValid()
        return btn.Text == "Run" or btn.Text == "Copy" or btn.Text == "S" or btn.Text == "-" or btn.Text == "✕" or btn.Text == "+"
    end

    btn.MouseEnter:Connect(function()
        if not isStateValid() then return end
        TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Out), {Scale = 1.04}):Play()
        if typeof(activeBg) == "Color3" then
            TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = activeBg}):Play()
        end
        if uistroke and activeStroke then
            TweenService:Create(uistroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Color = activeStroke}):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Out), {Scale = 1}):Play()
        if not isStateValid() then return end
        if typeof(inactiveBg) == "Color3" then
            TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = inactiveBg}):Play()
        end
        if uistroke and inactiveStroke then
            TweenService:Create(uistroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Color = inactiveStroke}):Play()
        end
    end)

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(scale, TweenInfo.new(0.08, Enum.EasingStyle.Out), {Scale = 0.95}):Play()
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local targetScale = (btn.AbsoluteSize ~= Vector2.new() and scale.Scale ~= 0.95) and 1.04 or 1
            TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Out), {Scale = targetScale}):Play()
        end
    end)
end

-- Expanding Sonar Pulse animation helper
local function createPulse(parent, color)
    local pulse = Instance.new("Frame", parent)
    pulse.AnchorPoint = Vector2.new(0.5, 0.5)
    pulse.Position = UDim2.new(0.5, 0, 0.5, 0)
    pulse.Size = UDim2.new(1, 0, 1, 0)
    pulse.BackgroundColor3 = color
    pulse.BorderSizePixel = 0
    pulse.ZIndex = parent.ZIndex - 1
    corner(pulse, 999)

    task.spawn(function()
        while pulse and pulse.Parent and screenGui and screenGui.Parent do
            pulse.Size = UDim2.new(1, 0, 1, 0)
            pulse.BackgroundTransparency = 0.4
            
            TweenService:Create(pulse, TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(2.5, 0, 2.5, 0),
                BackgroundTransparency = 1
            }):Play()
            
            task.wait(1.8)
        end
    end)
    return pulse
end

-- UI Layout Configuration
local panelSize
local fontSizeScale = isMobile and 0.8 or 1
local buttonHeight = isMobile and 28 or 22
local titleBarHeight = isMobile and 30 or 34

if isMobile then
    panelSize = UDim2.new(0.65, 0, 0.45, 0)
else
    panelSize = UDim2.new(0, 480, 0, 320)
end

local panelPosition = UDim2.new(0.5, 0, 0.25, 0)
local panelTargetPos = panelPosition

-- MAIN PANEL (Liquid Gray Glass)
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 0, 0, 0)
panel.Position = panelPosition
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
panel.BackgroundTransparency = 0.3
panel.BorderSizePixel = 0
panel.Visible = false
panel.ClipsDescendants = true
panel.Parent = screenGui
corner(panel, 14)
glowStroke(panel, Color3.fromRGB(145, 80, 255), Color3.fromRGB(0, 240, 200), 1.5)

-- Reopen button reference
local reopenButton = nil
local reopenSpring = createUDim2Spring(18, 12, UDim2.new(0, 0, 0, 0))
local reopenSnapping = false

-- Physics update integration loop (Sub-step safe, disconnects automatically)
connect(RunService.RenderStepped, function(dt)
    dt = math.min(dt, 0.1)
    
    if panel and panel.Visible then
        panel.Position = panelTargetPos
    end
    
    if reopenButton and reopenButton.Parent and reopenButton.Visible and reopenSnapping then
        reopenButton.Position = reopenSpring:Update(dt)
        if math.abs(reopenSpring.X.Velocity) < 1 and math.abs(reopenSpring.X.Position - reopenSpring.X.Target) < 1 then
            reopenSnapping = false
            reopenButton.Position = UDim2.new(reopenSpring.ScaleX, reopenSpring.X.Target, reopenSpring.ScaleY, reopenSpring.Y.Target)
        end
    end
end)

local resizing = false
local lastNormalSize = panelSize
local isMinimized = false

local dragging = false
local dragStart, startPos

local function onInputBegan(input)
    if not isMobile and (input.UserInputType == Enum.UserInputType.MouseButton1) and not resizing then
        dragging = true
        dragStart = input.Position
        startPos = panelTargetPos
    end
end

local function onInputChanged(input)
    if not isMobile and dragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        panelTargetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end

local function onInputEnded(input)
    if not isMobile and (input.UserInputType == Enum.UserInputType.MouseButton1) then
        if dragging then
            dragging = false
            panelPosition = panelTargetPos
        end
    end
end

-- Title Bar (Liquid Gray Glass)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, titleBarHeight)
titleBar.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
titleBar.Parent = panel

-- Clean Violet-Cyan Gradient Separator Line
local separator = Instance.new("Frame")
separator.Size = UDim2.new(1, 0, 0, 1)
separator.Position = UDim2.new(0, 0, 1, -1)
separator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
separator.BorderSizePixel = 0
separator.Parent = titleBar
local sepGrad = applyGradient(separator, Color3.fromRGB(145, 80, 255), Color3.fromRGB(0, 240, 200))
sepGrad.Rotation = 0

titleBar.InputBegan:Connect(onInputBegan)
connect(UserInputService.InputChanged, onInputChanged)
connect(UserInputService.InputEnded, onInputEnded)

local liveDot = Instance.new("Frame")
liveDot.Size = UDim2.new(0, 8, 0, 8)
liveDot.Position = UDim2.new(0, 16, 0.5, -4)
liveDot.BackgroundColor3 = Color3.fromRGB(0, 255, 180)
liveDot.BorderSizePixel = 0
liveDot.ZIndex = titleBar.ZIndex + 2
liveDot.Parent = titleBar
corner(liveDot, 999)
createPulse(liveDot, Color3.fromRGB(0, 255, 180))

local liveLabel = Instance.new("TextLabel")
liveLabel.Size = UDim2.new(0, 50, 0, 20)
liveLabel.Position = UDim2.new(0, 28, 0.5, -10)
liveLabel.BackgroundTransparency = 1
liveLabel.Text = "LIVE"
liveLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
liveLabel.TextSize = 10 * fontSizeScale
liveLabel.Font = Enum.Font.GothamBold
liveLabel.TextXAlignment = Enum.TextXAlignment.Left
liveLabel.ZIndex = titleBar.ZIndex + 2
liveLabel.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 200, 1, 0)
titleText.Position = UDim2.new(0.5, -100, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "ShadowX"
titleText.TextSize = 13 * fontSizeScale
titleText.Font = Enum.Font.GothamBold
titleText.ZIndex = titleBar.ZIndex + 2
titleText.Parent = titleBar
applyTextGradient(titleText, Color3.fromRGB(145, 80, 255), Color3.fromRGB(0, 240, 200))

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -6, 0.5, 0)
closeBtn.AnchorPoint = Vector2.new(1, 0.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 25)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 110, 140)
closeBtn.TextSize = 10 * fontSizeScale
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 10
closeBtn.Parent = titleBar
corner(closeBtn, 999)
stroke(closeBtn, Color3.fromRGB(140, 40, 60), 1)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 20, 0, 20)
minBtn.Position = UDim2.new(1, -32, 0.5, 0)
minBtn.AnchorPoint = Vector2.new(1, 0.5)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
minBtn.TextSize = 12 * fontSizeScale
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 10
minBtn.Parent = titleBar
corner(minBtn, 999)
stroke(minBtn, Color3.fromRGB(80, 80, 90), 1)

hoverEffect(closeBtn, Color3.fromRGB(80, 25, 35), Color3.fromRGB(50, 20, 25), Color3.fromRGB(255, 110, 140), Color3.fromRGB(140, 40, 60))
hoverEffect(minBtn, Color3.fromRGB(40, 40, 44), Color3.fromRGB(30, 30, 34), Color3.fromRGB(145, 80, 255), Color3.fromRGB(80, 80, 90))

local resizeHandle = nil
if not isMobile then
    resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 12, 0, 12)
    resizeHandle.Position = UDim2.new(1, -12, 1, -12)
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
    resizeHandle.BorderSizePixel = 0
    resizeHandle.Parent = panel
    corner(resizeHandle, 999)
    glowStroke(resizeHandle, Color3.fromRGB(145, 80, 255), Color3.fromRGB(0, 240, 200), 1.5)

    local resizeStartPos, startSize
    resizeHandle.InputBegan:Connect(function(input)
        if not isMinimized and input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStartPos = input.Position
            startSize = panel.AbsoluteSize
        end
    end)
    connect(UserInputService.InputChanged, function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStartPos
            local newWidth = math.clamp(startSize.X + delta.X, 300, 900)
            local newHeight = math.clamp(startSize.Y + delta.Y, 200, 600)
            local newSize = UDim2.new(0, newWidth, 0, newHeight)
            panel.Size = newSize
            if not isMinimized then
                lastNormalSize = newSize
            end
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
end

local logArea = Instance.new("ScrollingFrame")
logArea.Name = "LogArea"
logArea.Size = UDim2.new(1, -12, 1, -(titleBarHeight + 34)) -- Room for the watermark at the bottom
logArea.Position = UDim2.new(0, 6, 0, titleBarHeight + 6)
logArea.BackgroundTransparency = 1
logArea.BorderSizePixel = 0
logArea.ScrollBarThickness = isMobile and 4 or 3
logArea.ScrollBarImageColor3 = Color3.fromRGB(145, 80, 255)
logArea.CanvasSize = UDim2.new(0, 0, 0, 0)
logArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
logArea.Parent = panel

-- Watermark Label
local watermarkLabel = Instance.new("TextLabel")
watermarkLabel.Name = "Watermark"
watermarkLabel.Size = UDim2.new(1, 0, 0, 20)
watermarkLabel.Position = UDim2.new(0, 0, 1, -24)
watermarkLabel.BackgroundTransparency = 1
watermarkLabel.Text = "Key Removed by EvolEzod"
watermarkLabel.TextSize = 11 * fontSizeScale
watermarkLabel.Font = Enum.Font.GothamMedium
watermarkLabel.TextXAlignment = Enum.TextXAlignment.Center
watermarkLabel.Parent = panel
applyTextGradient(watermarkLabel, Color3.fromRGB(145, 80, 255), Color3.fromRGB(0, 240, 200))

minBtn.MouseButton1Click:Connect(function()
    if resizing then return end
    isMinimized = not isMinimized
    local targetSize
    if isMinimized then
        minBtn.Text = "+"
        targetSize = UDim2.new(panel.Size.X.Scale, panel.Size.X.Offset, 0, titleBarHeight)
        logArea.Visible = false
        watermarkLabel.Visible = false
        if resizeHandle then resizeHandle.Visible = false end
    else
        minBtn.Text = "-"
        targetSize = lastNormalSize
        logArea.Visible = true
        watermarkLabel.Visible = true
        if resizeHandle then resizeHandle.Visible = true end
    end
    TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

local listLayout = Instance.new("UIListLayout", logArea)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, isMobile and 6 or 4)
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local logPad = Instance.new("UIPadding", logArea)
logPad.PaddingTop = UDim.new(0, 2)
logPad.PaddingBottom = UDim.new(0, 2)
logPad.PaddingLeft = UDim.new(0, 2)
logPad.PaddingRight = UDim.new(0, 2)

local uiVisible = true

local function showGui()
    if not screenGui.Enabled then
        screenGui.Enabled = true
        uiVisible = true
        
        if reopenButton then reopenButton.Visible = false end
        
        panelTargetPos = panelPosition
        panel.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = panelSize}):Play()
    end
end

local function hideGui()
    if screenGui.Enabled then
        uiVisible = false
        local panelT = TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        panelT:Play()
        panelT.Completed:Connect(function()
            if not uiVisible then
                screenGui.Enabled = false
            end
        end)

        if isMobile then
            if not reopenButton or not reopenButton.Parent then
                reopenButton = Instance.new("TextButton")
                reopenButton.Name = "ShadowX_Reopen"
                reopenButton.Size = UDim2.new(0, 48, 0, 48)
                reopenButton.AnchorPoint = Vector2.new(0.5, 0.5)
                
                -- Center coordinate corresponding to bottom-right placement
                local screenWidth = screenGui.AbsoluteSize.X
                local screenHeight = screenGui.AbsoluteSize.Y
                local startX = screenWidth - 39
                local startY = screenHeight - 39
                
                reopenButton.Position = UDim2.new(0, startX, 0, startY)
                reopenSpring:SetPosition(reopenButton.Position)
                reopenSpring:SetTarget(reopenButton.Position)
                
                reopenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
                reopenButton.BackgroundTransparency = 0.2
                reopenButton.Text = "S"
                reopenButton.TextColor3 = Color3.fromRGB(240, 240, 245)
                reopenButton.TextSize = 20
                reopenButton.Font = Enum.Font.GothamBold
                reopenButton.BorderSizePixel = 0
                reopenButton.ZIndex = 100
                reopenButton.Parent = playerGui
                corner(reopenButton, 24)
                glowStroke(reopenButton, Color3.fromRGB(145, 80, 255), Color3.fromRGB(0, 240, 200), 1.5)
                createPulse(reopenButton, Color3.fromRGB(145, 80, 255))

                hoverEffect(reopenButton, Color3.fromRGB(40, 40, 44), Color3.fromRGB(30, 30, 34), Color3.fromRGB(0, 240, 200), Color3.fromRGB(145, 80, 255))

                local reopenDragging = false
                local reopenDragStart, reopenStartPos
                reopenButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        reopenDragging = true
                        reopenSnapping = false
                        reopenDragStart = input.Position
                        reopenStartPos = reopenButton.Position
                    end
                end)

                connect(UserInputService.InputChanged, function(input2)
                    if reopenDragging and (input2.UserInputType == Enum.UserInputType.Touch or input2.UserInputType == Enum.UserInputType.MouseMovement) then
                        local delta = input2.Position - reopenDragStart
                        reopenButton.Position = UDim2.new(reopenStartPos.X.Scale, reopenStartPos.X.Offset + delta.X, reopenStartPos.Y.Scale, reopenStartPos.Y.Offset + delta.Y)
                    end
                end)

                connect(UserInputService.InputEnded, function(input2)
                    if input2.UserInputType == Enum.UserInputType.Touch or input2.UserInputType == Enum.UserInputType.MouseButton1 then
                        if reopenDragging then
                            reopenDragging = false
                            reopenSnapping = true
                            
                            -- Snapping to edges magnetically
                            local sw = screenGui.AbsoluteSize.X
                            local sh = screenGui.AbsoluteSize.Y
                            local curX = reopenButton.Position.X.Offset
                            local targetX
                            
                            if curX < sw / 2 then
                                targetX = 39 -- left edge snapped
                            else
                                targetX = sw - 39 -- right edge snapped
                            end
                            
                            local targetY = math.clamp(reopenButton.Position.Y.Offset, 39, sh - 39)
                            reopenSpring:SetPosition(reopenButton.Position)
                            reopenSpring:SetTarget(UDim2.new(0, targetX, 0, targetY))
                        end
                    end
                end)

                reopenButton.MouseButton1Click:Connect(showGui)
            else
                reopenButton.Visible = true
            end
        end
    end
end

closeBtn.MouseButton1Click:Connect(hideGui)

if not isMobile then
    connect(UserInputService.InputBegan, function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            if uiVisible then hideGui() else showGui() end
        end
    end)
end

local eventCount = 0
local entries = {}
local suppressCounter = 0

local function fireFakeSignal(signalType, id)
    suppressCounter = suppressCounter + 1
    pcall(function()
        if signalType == "Product" then
            MarketplaceService:SignalPromptProductPurchaseFinished(player.UserId, id, true)
        elseif signalType == "Gamepass" then
            MarketplaceService:SignalPromptGamePassPurchaseFinished(player, id, true)
        elseif signalType == "Bulk" then
            MarketplaceService:SignalPromptBulkPurchaseFinished(player.UserId, id, true)
        elseif signalType == "Purchase" then
            MarketplaceService:SignalPromptPurchaseFinished(player.UserId, id, true)
        end
    end)
    suppressCounter = suppressCounter - 1
end

local function makeEmptyLabel()
    local el = Instance.new("TextLabel")
    el.Name = "EmptyState"
    el.Size = UDim2.new(1, 0, 0, 180)
    el.BackgroundTransparency = 1
    el.Text = "Waiting for events…\nAll marketplace events will appear here."
    el.TextColor3 = Color3.fromRGB(120, 120, 130)
    el.TextSize = 11 * fontSizeScale
    el.Font = Enum.Font.GothamMedium
    el.TextWrapped = true
    el.LayoutOrder = 99999
    el.Parent = logArea
    return el
end

local function setEmpty(show)
    local e = logArea:FindFirstChild("EmptyState")
    if show and not e then
        makeEmptyLabel()
    elseif not show and e then
        e:Destroy()
    end
end

local activeSpamButtons = {}

local function makeButton(text, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 48, 0, buttonHeight)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(180, 180, 190)
    btn.TextSize = 10 * fontSizeScale
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = parent
    corner(btn, 6)
    stroke(btn, Color3.fromRGB(80, 80, 90), 1)
    
    hoverEffect(btn, 
        Color3.fromRGB(40, 40, 44), -- activeBg
        Color3.fromRGB(30, 30, 34), -- inactiveBg
        Color3.fromRGB(0, 240, 200), -- activeStroke
        Color3.fromRGB(80, 80, 90) -- inactiveStroke
    )
    
    return btn
end

local function addLog(label, id, signalType)
    if suppressCounter > 0 then return end
    setEmpty(false)
    
    local entryHeight = isMobile and 46 or 38
    local entry = Instance.new("Frame")
    entry.Name = "EntryLog"
    entry.Size = UDim2.new(1, -2, 0, 0)
    entry.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
    entry.BackgroundTransparency = 1
    entry.BorderSizePixel = 0
    entry.ClipsDescendants = true
    entry.LayoutOrder = -(eventCount)
    entry.Parent = logArea
    
    corner(entry, 8)
    local entryStroke = stroke(entry, Color3.fromRGB(80, 80, 90), 1)
    entryStroke.Transparency = 1
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 10, 0.5, -3)
    dot.BackgroundColor3 = Color3.fromRGB(0, 240, 200)
    dot.BackgroundTransparency = 1
    dot.BorderSizePixel = 0
    dot.Parent = entry
    corner(dot, 999)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 64, 1, 0)
    lbl.Position = UDim2.new(0, 20, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(label)
    lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
    lbl.TextTransparency = 1
    lbl.TextSize = 9 * fontSizeScale
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = entry

    local idEl = Instance.new("TextLabel")
    idEl.Size = UDim2.new(0, 110, 1, 0)
    idEl.Position = UDim2.new(0, 88, 0, 0)
    idEl.BackgroundTransparency = 1
    idEl.Text = tostring(id)
    idEl.TextColor3 = Color3.fromRGB(240, 240, 245)
    idEl.TextTransparency = 1
    idEl.TextSize = 11 * fontSizeScale
    idEl.Font = Enum.Font.Code
    idEl.TextXAlignment = Enum.TextXAlignment.Left
    idEl.TextTruncate = Enum.TextTruncate.AtEnd
    idEl.Parent = entry

    local timeEl = Instance.new("TextLabel")
    timeEl.Size = UDim2.new(0, 50, 1, 0)
    timeEl.Position = UDim2.new(0, 202, 0, 0)
    timeEl.BackgroundTransparency = 1
    timeEl.Text = getTime()
    timeEl.TextColor3 = Color3.fromRGB(130, 130, 140)
    timeEl.TextTransparency = 1
    timeEl.TextSize = 9 * fontSizeScale
    timeEl.Font = Enum.Font.GothamMedium
    timeEl.Parent = entry

    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(0, 110, 1, 0)
    buttonFrame.Position = UDim2.new(1, -116, 0, 0)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = entry

    local horizontalLayout = Instance.new("UIListLayout")
    horizontalLayout.FillDirection = Enum.FillDirection.Horizontal
    horizontalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    horizontalLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    horizontalLayout.Padding = UDim.new(0, 6)
    horizontalLayout.Parent = buttonFrame

    local copyBtn = makeButton("Copy", buttonFrame)
    local runBtn = makeButton("Run", buttonFrame)

    -- Animate expansion and fade-in of the new row item
    TweenService:Create(entry, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -2, 0, entryHeight)}):Play()
    
    local function fadeIn(obj, property, targetVal)
        TweenService:Create(obj, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {[property] = targetVal}):Play()
    end
    
    fadeIn(entry, "BackgroundTransparency", 0.3)
    fadeIn(entryStroke, "Transparency", 0.2)
    fadeIn(dot, "BackgroundTransparency", 0)
    fadeIn(lbl, "TextTransparency", 0)
    fadeIn(idEl, "TextTransparency", 0)
    fadeIn(timeEl, "TextTransparency", 0)
    fadeIn(copyBtn, "TextTransparency", 0)
    fadeIn(runBtn, "TextTransparency", 0)
    
    local copyBtnStroke = copyBtn:FindFirstChildOfClass("UIStroke")
    local runBtnStroke = runBtn:FindFirstChildOfClass("UIStroke")
    if copyBtnStroke then fadeIn(copyBtnStroke, "Transparency", 0.2) end
    if runBtnStroke then fadeIn(runBtnStroke, "Transparency", 0.2) end

    copyBtn.MouseButton1Click:Connect(function()
        pcall(setclipboard, tostring(id))
        copyBtn.Text = "Copied!"
        copyBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
        local str = copyBtn:FindFirstChildOfClass("UIStroke")
        if str then str.Color = Color3.fromRGB(0, 255, 170) end
        
        task.wait(1.5)
        
        if copyBtn.Parent then
            copyBtn.Text = "Copy"
            copyBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
            if str then str.Color = Color3.fromRGB(80, 80, 90) end
        end
    end)

    local holdStart = nil
    local holdConnection = nil
    local spamLoop = nil
    local isSpamming = false
    
    local function startSpam()
        if isSpamming then return end
        isSpamming = true
        runBtn.Text = "Spam"
        runBtn.TextColor3 = Color3.fromRGB(255, 180, 50)
        local str = runBtn:FindFirstChildOfClass("UIStroke")
        if str then str.Color = Color3.fromRGB(255, 180, 50) end
        
        spamLoop = task.spawn(function()
            while isSpamming and runBtn.Parent do
                fireFakeSignal(signalType, id)
                task.wait(0.1)
            end
        end)
        activeSpamButtons[runBtn] = {active = true, loop = spamLoop}
    end
    
    local function stopSpam()
        isSpamming = false
        if spamLoop then task.cancel(spamLoop) end
        activeSpamButtons[runBtn] = nil
        if runBtn.Parent then
            runBtn.Text = "Run"
            runBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
            local str = runBtn:FindFirstChildOfClass("UIStroke")
            if str then str.Color = Color3.fromRGB(80, 80, 90) end
        end
    end

    local function onRunPress()
        if isSpamming then return end
        holdStart = tick()
        holdConnection = task.spawn(function()
            while holdStart and (tick() - holdStart) < 3 do
                task.wait(0.1)
            end
            if holdStart and not isSpamming then
                startSpam()
            end
        end)
    end

    local function onRunRelease()
        local heldDuration = holdStart and (tick() - holdStart) or 0
        holdStart = nil
        if holdConnection then task.cancel(holdConnection) end
        if isSpamming then
            stopSpam()
        elseif heldDuration < 3 then
            fireFakeSignal(signalType, id)
            runBtn.Text = "Sent!"
            runBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
            local str = runBtn:FindFirstChildOfClass("UIStroke")
            if str then str.Color = Color3.fromRGB(0, 255, 170) end
            
            task.spawn(function()
                task.wait(1.5)
                if runBtn.Parent and not isSpamming then
                    runBtn.Text = "Run"
                    runBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
                    if str then str.Color = Color3.fromRGB(80, 80, 90) end
                end
            end)
        end
    end

    runBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            onRunPress()
        end
    end)
    runBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            onRunRelease()
        end
    end)

    entry.AncestryChanged:Connect(function()
        if not entry.Parent then
            if isSpamming then stopSpam() end
            for i, e in ipairs(entries) do
                if e == entry then
                    table.remove(entries, i)
                    break
                end
            end
        end
    end)

    eventCount = eventCount + 1
    table.insert(entries, entry)
end

connect(MarketplaceService.PromptProductPurchaseFinished, function(plr, id, bought)
    if suppressCounter == 0 then addLog("Product", id, "Product") end
end)
connect(MarketplaceService.PromptGamePassPurchaseFinished, function(plr, id, bought)
    if suppressCounter == 0 then addLog("Gamepass", id, "Gamepass") end
end)
connect(MarketplaceService.PromptBulkPurchaseFinished, function(userId, id, bought)
    if suppressCounter == 0 then addLog("Bulk", id, "Bulk") end
end)
connect(MarketplaceService.PromptPurchaseFinished, function(userId, id, bought)
    if suppressCounter == 0 then addLog("Purchase", id, "Purchase") end
end)

-- Auto disconnect and cleanup when UI is destroyed
connect(screenGui.AncestryChanged, function(_, parent)
    if not parent then
        for _, conn in ipairs(connections) do
            if conn.Connected then
                conn:Disconnect()
            end
        end
        table.clear(connections)
    end
end)

setEmpty(true)

-- Initialize the Main Interface immediately without a key system
panel.Visible = true
local popInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
TweenService:Create(panel, popInfo, {Size = panelSize}):Play()
