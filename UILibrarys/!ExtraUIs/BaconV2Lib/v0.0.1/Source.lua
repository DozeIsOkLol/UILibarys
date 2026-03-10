--[[
    Glow Pro UI Library v1.0.1 (Fixed)
    A comprehensive, feature-rich UI library for external use.
    Designed as a superior, modern alternative to BaconLib.
    This script is self-contained and includes a full usage example at the bottom.
]]

-- // INITIALIZATION //
local GlowPro = {}
GlowPro.Version = "1.0.1"

-- Find a valid parent for the UI, preferring CoreGui
local CGUI = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Clean up any previous instances of this UI to prevent stacking
for _, v in pairs(CGUI:GetChildren()) do
    if v.Name == "_GLOWPRO_ROOT" then
        v:Destroy()
    end
end

-- // THEME CONFIGURATION //
-- All visual customization happens in this table.
GlowPro.Theme = {
    Title = "Glow Pro",
    Width = 280,
    
    -- Colors
    Accent = Color3.fromRGB(110, 80, 255),
    TitleBar = Color3.fromRGB(31, 31, 31),
    Background = Color3.fromRGB(36, 36, 36),
    Control = Color3.fromRGB(45, 45, 45),
    ControlHover = Color3.fromRGB(60, 60, 60),
    Text = Color3.fromRGB(255, 255, 255),
    MutedText = Color3.fromRGB(180, 180, 180),
    
    -- Fonts
    Font = Enum.Font.SourceSans,
    TitleFont = Enum.Font.SourceSansSemibold,
    
    -- Sizes
    TextSize = 14,
    TitleSize = 16,
    
    -- Padding
    WindowPadding = 10,
    ControlPadding = 8,
    
    -- Animation
    AnimationSpeed = 0.25,
    EasingStyle = Enum.EasingStyle.Quart,
    EasingDirection = Enum.EasingDirection.Out
}

-- // UTILITY FUNCTIONS //
local function MakeDraggable(guiObject, handle)
    local dragging, dragInput, startPosition, dragStart
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = guiObject.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false 
                    conn:Disconnect()
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
            TweenService:Create(guiObject, TweenInfo.new(0.1), {Position = newPos}):Play()
        end
    end)
end

-- // MAIN WINDOW CONSTRUCTOR //
function GlowPro:CreateWindow(title, keybind)
    title = title or GlowPro.Theme.Title
    keybind = keybind or Enum.KeyCode.RightShift

    local window = {}
    local isWindowOpen = true
    local isContainerOpen = true
    local isAnimating = false
    local contentHeight = 0

    -- Create Root UI Objects
    local screenGui = Instance.new("ScreenGui")
    screenGui.DisplayOrder = 999
    screenGui.ResetOnSpawn = false
    screenGui.Name = "_GLOWPRO_ROOT"
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, GlowPro.Theme.Width, 0, 35) -- Start collapsed
    mainFrame.Position = UDim2.new(0.5, -GlowPro.Theme.Width / 2, 0.5, -150)
    mainFrame.BackgroundColor3 = GlowPro.Theme.TitleBar
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 0, 35)
    titleLabel.Position = UDim2.fromOffset(GlowPro.Theme.WindowPadding, 0)
    titleLabel.Text = title
    titleLabel.TextColor3 = GlowPro.Theme.Text
    titleLabel.Font = GlowPro.Theme.TitleFont
    titleLabel.TextSize = GlowPro.Theme.TitleSize
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = mainFrame
    
    -- Toggle Button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 35, 0, 35)
    toggleButton.Position = UDim2.new(1, -35, 0, 0)
    toggleButton.Text = "-"
    toggleButton.TextColor3 = GlowPro.Theme.Text
    toggleButton.Font = GlowPro.Theme.Font
    toggleButton.TextSize = 24
    toggleButton.BackgroundTransparency = 1
    toggleButton.Parent = mainFrame
    
    -- Controls Container
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, -35)
    container.Position = UDim2.fromOffset(0, 35)
    container.BackgroundColor3 = GlowPro.Theme.Background
    container.BorderSizePixel = 0
    container.Parent = mainFrame

    -- Layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, GlowPro.Theme.ControlPadding)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = container
    
    -- Top Padding
    Instance.new("Frame", container).Size = UDim2.new(1,0,0,GlowPro.Theme.WindowPadding / 2)
    
    -- Dragging Logic
    MakeDraggable(mainFrame, mainFrame)
    
    -- Keybind Logic
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == keybind then
            isWindowOpen = not isWindowOpen
            screenGui.Enabled = isWindowOpen
        end
    end)
    
    -- Animation Logic
    local animationInfo = TweenInfo.new(GlowPro.Theme.AnimationSpeed, GlowPro.Theme.EasingStyle, GlowPro.Theme.EasingDirection)
    
    local function updateContainerHeight(delta)
        contentHeight = contentHeight + delta
        if isContainerOpen then
            local targetSize = UDim2.new(0, GlowPro.Theme.Width, 0, 35 + contentHeight + GlowPro.Theme.WindowPadding)
            TweenService:Create(mainFrame, animationInfo, {Size = targetSize}):Play()
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        if isAnimating then return end
        isAnimating = true
        isContainerOpen = not isContainerOpen
        
        local targetHeight = isContainerOpen and (35 + contentHeight + GlowPro.Theme.WindowPadding) or 35
        local tween = TweenService:Create(mainFrame, animationInfo, {Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, targetHeight)})
        tween:Play()
        
        toggleButton.Text = isContainerOpen and "-" or "+"
        tween.Completed:Connect(function() isAnimating = false end)
    end)
    
    -- Initial parent
    RunService.Stepped:Wait()
    screenGui.Parent = CGUI
    updateContainerHeight(0) -- Initial size calculation
    
    
    -- // WINDOW API METHODS //
    
    -- Add a text label
    function window:AddLabel(text)
        local height = 20
        updateContainerHeight(height)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -GlowPro.Theme.WindowPadding * 2, 0, height)
        label.Text = text
        label.TextColor3 = GlowPro.Theme.MutedText
        label.Font = GlowPro.Theme.Font
        label.TextSize = GlowPro.Theme.TextSize
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.BackgroundTransparency = 1
        label.Parent = container
        
        return label
    end

    -- Add a button
    function window:AddButton(text, callback)
        local height = 30
        updateContainerHeight(height + GlowPro.Theme.ControlPadding)

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -GlowPro.Theme.WindowPadding * 2, 0, height)
        button.Text = text
        button.BackgroundColor3 = GlowPro.Theme.Control
        button.TextColor3 = GlowPro.Theme.Text
        button.Font = GlowPro.Theme.Font
        button.TextSize = GlowPro.Theme.TextSize
        button.BorderSizePixel = 0
        button.Parent = container

        button.MouseEnter:Connect(function() button.BackgroundColor3 = GlowPro.Theme.ControlHover end)
        button.MouseLeave:Connect(function() button.BackgroundColor3 = GlowPro.Theme.Control end)
        button.MouseButton1Click:Connect(callback or function() end)

        return button
    end
    
    -- Add a toggle switch
    function window:AddToggle(text, startState, callback)
        local height = 30
        updateContainerHeight(height + GlowPro.Theme.ControlPadding)
        local toggled = startState or false
        
        local frame = Instance.new("TextButton")
        frame.Size = UDim2.new(1, -GlowPro.Theme.WindowPadding * 2, 0, height)
        frame.BackgroundColor3 = GlowPro.Theme.Control
        frame.BorderSizePixel = 0
        frame.Text = ""
        frame.Parent = container
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, -40, 1, 0)
        label.Text = text
        label.TextColor3 = GlowPro.Theme.Text
        label.Font = GlowPro.Theme.Font
        label.TextSize = GlowPro.Theme.TextSize
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        label.Position = UDim2.fromOffset(10, 0)
        
        local indicator = Instance.new("Frame", frame)
        indicator.Size = UDim2.fromOffset(20, 20)
        indicator.Position = UDim2.new(1, -30, 0.5, -10)
        indicator.BackgroundColor3 = toggled and GlowPro.Theme.Accent or GlowPro.Theme.Background
        
        frame.MouseButton1Click:Connect(function()
            toggled = not toggled
            TweenService:Create(indicator, animationInfo, {BackgroundColor3 = toggled and GlowPro.Theme.Accent or GlowPro.Theme.Background}):Play()
            if callback then callback(toggled) end
        end)
        
        return frame
    end

    -- Add a text input box
    function window:AddTextBox(placeholder, callback)
        local height = 30
        updateContainerHeight(height + GlowPro.Theme.ControlPadding)

        local textbox = Instance.new("TextBox")
        textbox.Size = UDim2.new(1, -GlowPro.Theme.WindowPadding * 2, 0, height)
        textbox.PlaceholderText = placeholder or ""
        textbox.Text = ""
        textbox.BackgroundColor3 = GlowPro.Theme.Control
        textbox.TextColor3 = GlowPro.Theme.Text
        textbox.PlaceholderColor3 = GlowPro.Theme.MutedText
        textbox.Font = GlowPro.Theme.Font
        textbox.TextSize = GlowPro.Theme.TextSize
        textbox.BorderSizePixel = 0
        textbox.ClearTextOnFocus = false
        textbox.Parent = container

        textbox.FocusLost:Connect(function(enterPressed)
            if enterPressed and callback then
                callback(textbox.Text)
            end
        end)
        
        return textbox
    end

    -- Add a slider
    function window:AddSlider(name, min, max, start, callback)
        min, max, start = tonumber(min) or 0, tonumber(max) or 100, tonumber(start) or 0
        local height = 40
        updateContainerHeight(height + GlowPro.Theme.ControlPadding)

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -GlowPro.Theme.WindowPadding * 2, 0, height)
        frame.BackgroundTransparency = 1
        frame.Parent = container
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 0, 18)
        label.Text = name .. ": " .. math.floor(start)
        label.TextColor3 = GlowPro.Theme.Text
        label.Font = GlowPro.Theme.Font
        label.TextSize = GlowPro.Theme.TextSize
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        
        local bar = Instance.new("Frame", frame)
        bar.Size = UDim2.new(1, 0, 0, 12)
        bar.Position = UDim2.new(0, 0, 0, 22)
        bar.BackgroundColor3 = GlowPro.Theme.Control

        local fill = Instance.new("Frame", bar)
        fill.BackgroundColor3 = GlowPro.Theme.Accent
        
        local function updateSlider(value, fireCallback)
            local percentage = (value - min) / (max - min)
            percentage = math.clamp(percentage, 0, 1)
            fill.Size = UDim2.new(percentage, 0, 1, 0)
            label.Text = name .. ": " .. math.floor(value)
            if fireCallback and callback then callback(value) end
        end

        local isSliding = false
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = true end
        end)
        bar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isSliding = false
                local percentage = fill.Size.X.Scale
                local value = min + (max - min) * percentage
                updateSlider(value, true)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouseX = UserInputService:GetMouseLocation().X
                local barStart = bar.AbsolutePosition.X
                local barWidth = bar.AbsoluteSize.X
                local percentage = math.clamp((mouseX - barStart) / barWidth, 0, 1)
                local value = min + (max - min) * percentage
                updateSlider(value, false)
            end
        end)
        
        updateSlider(start, false)
        return frame
    end
    
    -- Add a keybind selector
    function window:AddKeybind(name, defaultKey, callback)
        local height = 30
        updateContainerHeight(height + GlowPro.Theme.ControlPadding)
        local currentKey = defaultKey or "..."

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -GlowPro.Theme.WindowPadding * 2, 0, height)
        frame.BackgroundTransparency = 1
        frame.Parent = container

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.Text = name
        label.TextColor3 = GlowPro.Theme.Text
        label.Font = GlowPro.Theme.Font
        label.TextSize = GlowPro.Theme.TextSize
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1

        local button = Instance.new("TextButton", frame)
        button.Size = UDim2.new(0.3, 0, 1, 0)
        button.Position = UDim2.new(0.7, 0, 0, 0)
        button.Text = tostring(currentKey):gsub("Enum.KeyCode.", "")
        button.BackgroundColor3 = GlowPro.Theme.Control
        button.TextColor3 = GlowPro.Theme.Text
        button.Font = GlowPro.Theme.Font
        button.TextSize = GlowPro.Theme.TextSize

        local isCapturing = false
        button.MouseButton1Click:Connect(function()
            isCapturing = true
            button.Text = "..."
            local conn
            conn = UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe or not isCapturing then return end
                isCapturing = false
                currentKey = input.KeyCode
                button.Text = tostring(currentKey):gsub("Enum.KeyCode.", "")
                conn:Disconnect()
            end)
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and not isCapturing and input.KeyCode == currentKey then
                if callback then callback() end
            end
        end)
        
        return frame
    end
    
    -- Add a collapsible dropdown
    function window:AddDropdown(name)
        local dropdown = {}
        local dropdownContentHeight = 0
        local isDropdownOpen = false
        
        local totalHeight = 30
        updateContainerHeight(totalHeight + GlowPro.Theme.ControlPadding)
        
        local main = Instance.new("Frame")
        main.Size = UDim2.new(1, -GlowPro.Theme.WindowPadding * 2, 0, 30)
        main.BackgroundTransparency = 1
        main.ClipsDescendants = true
        main.Parent = container
        
        local top = Instance.new("Frame", main)
        top.Size = UDim2.new(1, 0, 0, 30)
        top.BackgroundColor3 = GlowPro.Theme.Control
        
        local label = Instance.new("TextLabel", top)
        label.Size = UDim2.new(1, -30, 1, 0)
        label.Position = UDim2.fromOffset(10, 0)
        label.Text = name
        label.TextColor3 = GlowPro.Theme.Text
        label.Font = GlowPro.Theme.Font
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        
        local button = Instance.new("TextButton", top)
        button.Size = UDim2.new(0, 30, 0, 30)
        button.Position = UDim2.new(1, -30, 0, 0)
        button.Text = "+"
        button.TextColor3 = GlowPro.Theme.Text
        button.Font = GlowPro.Theme.Font
        button.TextSize = 20
        button.BackgroundTransparency = 1
        
        local dropdownContainer = Instance.new("Frame", main)
        dropdownContainer.Size = UDim2.new(1, 0, 1, -30)
        dropdownContainer.Position = UDim2.fromOffset(0, 30)
        dropdownContainer.BackgroundColor3 = GlowPro.Theme.Control
        dropdownContainer.BackgroundTransparency = 0.5
        
        local dropdownLayout = Instance.new("UIListLayout", dropdownContainer)
        dropdownLayout.Padding = UDim.new(0, GlowPro.Theme.ControlPadding / 2)
        dropdownLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local function updateDropdownHeight(delta)
            dropdownContentHeight = dropdownContentHeight + delta
            if isDropdownOpen then
                local newHeight = 30 + dropdownContentHeight
                updateContainerHeight(delta)
                TweenService:Create(main, animationInfo, {Size = UDim2.new(main.Size.X.Scale, main.Size.X.Offset, 0, newHeight)}):Play()
            end
        end
        
        button.MouseButton1Click:Connect(function()
            isDropdownOpen = not isDropdownOpen
            local heightChange = isDropdownOpen and dropdownContentHeight or -dropdownContentHeight
            updateContainerHeight(heightChange)
            
            local targetSize = isDropdownOpen and 30 + dropdownContentHeight or 30
            TweenService:Create(main, animationInfo, {Size = UDim2.new(main.Size.X.Scale, main.Size.X.Offset, 0, targetSize)}):Play()
            button.Text = isDropdownOpen and "-" or "+"
        end)
        
        function dropdown:AddButton(text, callback)
            local height = 25
            updateDropdownHeight(height + dropdownLayout.Padding.Offset)
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -GlowPro.Theme.WindowPadding, 0, height)
            btn.Text = text
            btn.BackgroundColor3 = GlowPro.Theme.ControlHover
            btn.TextColor3 = GlowPro.Theme.Text
            btn.Font = GlowPro.Theme.Font
            btn.Parent = dropdownContainer
            
            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = GlowPro.Theme.Background end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3 = GlowPro.Theme.ControlHover end)
            btn.MouseButton1Click:Connect(callback or function() end)

            return btn
        end
        
        return dropdown
    end

    return window
end

-- // NOTIFICATION SYSTEM //
local notificationQueue = {}
function GlowPro:CreateNotification(title, text, duration)
    title = title or "Notification"
    text = text or "..."
    duration = duration or 3

    local notification = {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 60)
    frame.BackgroundColor3 = GlowPro.Theme.Background
    frame.Position = UDim2.new(1, 260, 1, -70 - (#notificationQueue * 70)) -- Start off-screen
    frame.Parent = CGUI
    
    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1, -10, 0, 25)
    titleLabel.Position = UDim2.fromOffset(5, 0)
    titleLabel.Text = title
    titleLabel.TextColor3 = GlowPro.Theme.Accent
    titleLabel.Font = GlowPro.Theme.TitleFont
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1
    
    local textLabel = Instance.new("TextLabel", frame)
    textLabel.Size = UDim2.new(1, -10, 1, -25)
    textLabel.Position = UDim2.fromOffset(5, 25)
    textLabel.Text = text
    textLabel.TextColor3 = GlowPro.Theme.Text
    textLabel.Font = GlowPro.Theme.Font
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.BackgroundTransparency = 1
    
    table.insert(notificationQueue, frame)

    local animInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(frame, animInfo, {Position = UDim2.new(1, -260, 1, -70 - ((#notificationQueue-1) * 70))}):Play()
    
    delay(duration, function()
        TweenService:Create(frame, animInfo, {Position = UDim2.new(1, 260, frame.Position.Y.Scale, frame.Position.Y.Offset)}):Play()
        task.wait(0.4)
        local pos = table.find(notificationQueue, frame)
        if pos then table.remove(notificationQueue, pos) end
        frame:Destroy()
        -- Adjust remaining notifications
        for i, v in ipairs(notificationQueue) do
            TweenService:Create(v, animInfo, {Position = UDim2.new(1, -260, 1, -70 - ((i-1) * 70))}):Play()
        end
    end)
end

-- [CRITICAL FIX] REMOVED the 'return GlowPro' line that was causing the script to error.

-- ================================================================= --
-- //                    EXAMPLE USAGE                            // --
-- ================================================================= --
-- The code below uses the Glow Pro library defined above to create
-- a window demonstrating all of its features.

-- Create the main window, toggle with RightShift
local Window = GlowPro:CreateWindow("Glow Pro Demo", Enum.KeyCode.RightShift)

-- Add a simple text label
Window:AddLabel("Welcome to Glow Pro!")

-- Add a button that prints to the console
Window:AddButton("Print Message", function()
    print("Glow Pro button was clicked!")
    GlowPro:CreateNotification("Button Clicked", "You pressed the print button.", 4)
end)

-- Add a toggle switch
local isSpamming = false
Window:AddToggle("Spam Notifications", false, function(state)
    isSpamming = state
    print("Spamming state is now:", state)
end)

-- Add a text box
Window:AddTextBox("Enter text and press enter", function(text)
    GlowPro:CreateNotification("Textbox Submitted", "You entered: " .. text, 5)
end)

-- Add a slider for speed control
Window:AddSlider("WalkSpeed", 16, 100, game.Players.LocalPlayer.Character.Humanoid.WalkSpeed, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

-- Add a keybind to trigger a notification
Window:AddKeybind("Notify Key", Enum.KeyCode.V, function()
    GlowPro:CreateNotification("Keybind Pressed", "You pressed the custom keybind!")
end)

-- Add a dropdown menu for options
local Dropdown = Window:AddDropdown("Options")

-- Add buttons inside the dropdown
Dropdown:AddButton("Reset WalkSpeed", function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    GlowPro:CreateNotification("Options", "WalkSpeed has been reset.")
end)

Dropdown:AddButton("Say 'Hello'", function()
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Hello, I'm using Glow Pro!", "All")
end)


-- Example of a loop that uses a toggle state
spawn(function()
    while task.wait(1) do
        if isSpamming then
            GlowPro:CreateNotification("Spam!", "This is a spam notification.", 1)
        end
    end
end)
