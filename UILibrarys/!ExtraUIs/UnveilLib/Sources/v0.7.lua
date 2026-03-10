--[[
    Unveil UI - A Standalone UI Library (V1.1)
    All-in-One Script with Example Usage.
    
    - V1.1 FIX: Corrected a critical bug in the drag logic that caused a 'Disconnect on nil' error.
    - Press 'PageUp' to toggle the example window.
]]

--// --- Part 1: Unveil UI Library ---

local UnveilUI = {}
UnveilUI.__index = UnveilUI

--// Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")

-- This ensures only one ScreenGui is created for all scripts using this library
local screenGui = playerGui:FindFirstChild("UnveilUI_GUI") or Instance.new("ScreenGui", playerGui)
screenGui.Name = "UnveilUI_GUI"; screenGui.ResetOnSpawn = false

--// Main Window Creation
function UnveilUI:CreateWindow(title, width, height)
    local self = setmetatable({}, UnveilUI)
    
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Size = UDim2.new(0, width or 300, 0, height or 400);
    self.mainFrame.Position = UDim2.new(0.5, - (width or 300) / 2, 0.5, - (height or 400) / 2);
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(35, 37, 40);
    self.mainFrame.Visible = false;
    self.mainFrame.ClipsDescendants = true;
    self.mainFrame.Parent = screenGui
    Instance.new("UICorner", self.mainFrame).CornerRadius = UDim.new(0, 8);
    Instance.new("UIStroke", self.mainFrame).Color = Color3.fromRGB(85, 87, 90)

    local dragBar = Instance.new("Frame", self.mainFrame)
    dragBar.Size=UDim2.new(1,0,0,35); dragBar.BackgroundTransparency=1; dragBar.ZIndex=1

    local titleLabel = Instance.new("TextLabel", dragBar)
    titleLabel.Size=UDim2.new(1,-40,1,0); titleLabel.Position=UDim2.new(0,10,0,0); titleLabel.BackgroundTransparency=1; titleLabel.Text=title; titleLabel.TextColor3=Color3.fromRGB(255,255,255); titleLabel.Font=Enum.Font.GothamBold; titleLabel.TextSize=18; titleLabel.TextXAlignment=Enum.TextXAlignment.Left

    self.closeButton = Instance.new("TextButton", dragBar)
    self.closeButton.Size=UDim2.new(0,25,0,25); self.closeButton.Position=UDim2.new(1,-32,0.5,-12.5); self.closeButton.BackgroundColor3=Color3.fromRGB(200,50,50); self.closeButton.Text="X"; self.closeButton.Font=Enum.Font.GothamBold; self.closeButton.TextColor3=Color3.new(1,1,1)
    Instance.new("UICorner", self.closeButton).CornerRadius = UDim.new(0,6)

    self.contentFrame = Instance.new("ScrollingFrame", self.mainFrame)
    self.contentFrame.Size=UDim2.new(1,-20,1,-65); self.contentFrame.Position=UDim2.new(0,10,0,35); self.contentFrame.BackgroundTransparency=1; self.contentFrame.BorderSizePixel = 0; self.contentFrame.ScrollBarThickness = 5; self.contentFrame.CanvasSize = UDim2.new(0,0,0,0)

    local contentLayout = Instance.new("UIListLayout", self.contentFrame)
    contentLayout.Padding=UDim.new(0,10); contentLayout.SortOrder=Enum.SortOrder.LayoutOrder
    
    self.statusLabel=Instance.new("TextLabel",self.mainFrame); self.statusLabel.Size=UDim2.new(1,-20,0,25); self.statusLabel.Position=UDim2.new(0,10,1,-30); self.statusLabel.BackgroundTransparency=1; self.statusLabel.Text="Status: Idle"; self.statusLabel.TextColor3=Color3.fromRGB(150,150,150); self.statusLabel.Font=Enum.Font.Gotham; self.statusLabel.TextSize=14; self.statusLabel.TextXAlignment=Enum.TextXAlignment.Left

    self.focusStroke = Instance.new("UIStroke", nil)
    self.focusStroke.Color = Color3.fromRGB(100, 160, 255); self.focusStroke.Thickness = 1.5

    self.focusableElements, self.currentFocusIndex = {}, nil
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
    end)
    
    -- =================================================================
    -- V1.1 FIX: Corrected Dragging Logic
    -- =================================================================
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local startPos = input.Position
            local frameStartPos = self.mainFrame.Position
            local moveConn, endConn
            
            moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == input.UserInputType then
                    local delta = moveInput.Position - startPos
                    self.mainFrame.Position = UDim2.new(frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X, frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y)
                end
            end)
            
            endConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == input.UserInputType then
                    moveConn:Disconnect()
                    endConn:Disconnect()
                end
            end)
        end
    end)
    -- =================================================================
    
    return self
end

function UnveilUI:AddButton(opts)
    local button=Instance.new("TextButton", self.contentFrame); button.Name=opts.text; button.Size=UDim2.new(1,0,0,35); button.BackgroundColor3=opts.color or Color3.fromRGB(88,101,242); button.TextColor3=Color3.fromRGB(255,255,255); button.Font=Enum.Font.GothamBold; button.TextSize=16; button.Text=opts.text; Instance.new("UICorner",button).CornerRadius=UDim.new(0,6)
    button.MouseButton1Click:Connect(opts.callback)
    table.insert(self.focusableElements, button)
    return button
end

function UnveilUI:AddToggle(opts)
    local state = opts.state or false
    local toggleButton = self:AddButton({ text = (state and "Stop " or "Start ") .. opts.text, color = state and Color3.fromRGB(0,145,0) or Color3.fromRGB(200,40,40), callback = function()
        state = not state
        toggleButton.Text = (state and "Stop " or "Start ") .. opts.text
        toggleButton.BackgroundColor3 = state and Color3.fromRGB(0,145,0) or Color3.fromRGB(200,40,40)
        if opts.callback then opts.callback(state) end
    end})
    return toggleButton, function() return state end
end

function UnveilUI:AddLabel(opts)
    local label = Instance.new("TextLabel", self.contentFrame); label.Size = UDim2.new(1,0,0,25); label.BackgroundTransparency=1; label.Text=opts.text; label.TextColor3=opts.color or Color3.fromRGB(180,180,180); label.Font=opts.font or Enum.Font.Gotham; label.TextSize=opts.textSize or 16; label.TextXAlignment=opts.align or Enum.TextXAlignment.Left
    return label
end

function UnveilUI:AddInput(opts)
    local container = Instance.new("Frame", self.contentFrame); container.Size = UDim2.new(1,0,0,35); container.BackgroundTransparency = 1
    local input = Instance.new("TextBox", container); input.Size=UDim2.new(0.7,-5,1,0); input.BackgroundColor3=Color3.fromRGB(45,47,50); input.TextColor3=Color3.fromRGB(220,220,220); input.Font=Enum.Font.Gotham; input.TextSize=16; input.PlaceholderText=opts.placeholder or "Enter..."; Instance.new("UICorner",input).CornerRadius=UDim.new(0,6)
    local button = Instance.new("TextButton",container); button.Size=UDim2.new(0.3,-5,1,0); button.Position=UDim2.new(0.7,5,0,0); button.BackgroundColor3=Color3.fromRGB(0,145,0); button.TextColor3=Color3.fromRGB(255,255,255); button.Font=Enum.Font.GothamBold; button.TextSize=16; button.Text=opts.buttonText or "Submit"; Instance.new("UICorner",button).CornerRadius=UDim.new(0,6)
    button.MouseButton1Click:Connect(function() opts.callback(input.Text) end)
    table.insert(self.focusableElements, input); table.insert(self.focusableElements, button)
    return container, input, button
end

function UnveilUI:AddSlider(opts)
    local container = Instance.new("Frame", self.contentFrame); container.Size = UDim2.new(1,0,0,40); container.BackgroundTransparency=1
    local label = self:AddLabel({text = opts.text, textSize=14}); label.Parent = container
    local sliderFrame = Instance.new("Frame", container); sliderFrame.Size = UDim2.new(1, 0, 0, 16); sliderFrame.Position = UDim2.new(0, 0, 0, 20); sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70); Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 8)
    local sliderFill = Instance.new("Frame", sliderFrame); sliderFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255); Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 8)
    local sliderKnob = Instance.new("Frame", sliderFrame); sliderKnob.Size = UDim2.new(0, 20, 0, 20); sliderKnob.BackgroundColor3 = Color3.new(1,1,1); sliderKnob.ZIndex = 2; Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(0, 10); Instance.new("UIStroke", sliderKnob).Thickness = 2;
    local value = opts.default or opts.min
    local function updateSlider(percent)
        value = math.floor((opts.min + (opts.max - opts.min) * percent) + 0.5)
        label.Text = opts.text .. ": " .. value
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderKnob.Position = UDim2.new(percent, -10, 0.5, -10)
        if opts.onDrag then opts.onDrag(value) end
    end
    updateSlider((value - opts.min) / (opts.max - opts.min))
    local isDragging = false
    local function handleInput(input) local percent = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1); updateSlider(percent) end
    sliderFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging=true; handleInput(i) end end)
    UserInputService.InputChanged:Connect(function(i) if isDragging and i.UserInputType == Enum.UserInputType.MouseMovement then handleInput(i) end end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
            isDragging = false
            if opts.callback then opts.callback(value) end
        end
    end)
    table.insert(self.focusableElements, sliderKnob)
    return container, label
end

function UnveilUI:AddSeparator()
    local sep = Instance.new("Frame", self.contentFrame); sep.Size = UDim2.new(1,0,0,2); sep.BackgroundColor3 = Color3.fromRGB(60,62,70)
end

function UnveilUI:SetStatus(text, color)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
    local fadeOut = TweenService:Create(self.statusLabel, tweenInfo, {TextTransparency = 1})
    fadeOut:Play()
    fadeOut.Completed:Wait()
    self.statusLabel.Text = "Status: " .. text
    self.statusLabel.TextColor3 = color or Color3.fromRGB(150,150,150)
    TweenService:Create(self.statusLabel, tweenInfo, {TextTransparency = 0}):Play()
end

function UnveilUI:Init(opts)
    opts = opts or {}
    local uiVisible = false

    local function setFocus(index)
        if index and self.focusableElements[index] then
            self.currentFocusIndex = index
            self.focusStroke.Parent = self.focusableElements[self.currentFocusIndex]
        else
            self.currentFocusIndex = nil
            self.focusStroke.Parent = nil
        end
    end

    local function toggleUI()
        uiVisible = not uiVisible
        self.mainFrame.Visible = uiVisible
        setFocus(nil)
    end

    self.closeButton.MouseButton1Click:Connect(toggleUI)

    UserInputService.InputBegan:Connect(function(i, gpe)
        if not gpe and i.KeyCode == (opts.toggleKey or Enum.KeyCode.RightControl) then
            toggleUI()
        end

        if gpe or not uiVisible then return end

        if i.KeyCode == Enum.KeyCode.Tab then
            local newIndex = (self.currentFocusIndex or 0) + (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -1 or 1)
            if newIndex > #self.focusableElements then newIndex = 1
            elseif newIndex < 1 then newIndex = #self.focusableElements
            end
            setFocus(newIndex)
        elseif i.KeyCode == Enum.KeyCode.Return or i.KeyCode == Enum.KeyCode.Space then
            if self.currentFocusIndex then
                local el = self.focusableElements[self.currentFocusIndex]
                if el:IsA("TextButton") then
                    el.MouseButton1Click:Fire()
                end
            end
        end
    end)
    
    toggleUI() -- Show the UI on script start
end

--// --- Part 2: Example Script using Unveil UI ---
local Window = UnveilUI:CreateWindow("Unveil UI - Example", 300, 450)

-- A label to act as a title for a section
Window:AddLabel({
    text = "Demonstration Elements",
    align = Enum.TextXAlignment.Center,
    textSize = 18
})

-- A standard button
Window:AddButton({
    text = "Test Button",
    color = Color3.fromRGB(88, 101, 242), -- Optional color
    callback = function()
        Window:SetStatus("Test Button clicked!", Color3.fromRGB(255, 255, 255))
        print("Test Button clicked!")
    end
})

-- A toggle button that manages its own state
Window:AddToggle({
    text = "Test Toggle",
    state = false, -- Optional: initial state
    callback = function(state)
        Window:SetStatus("Toggle is now: " .. tostring(state))
        print("Toggle is now: " .. tostring(state))
    end
})

-- A visual separator
Window:AddSeparator()

-- A text input field with a submit button
Window:AddInput({
    placeholder = "Type here...",
    buttonText = "Submit",
    callback = function(text)
        Window:SetStatus("Submitted: " .. text)
        print("Submitted text: " .. text)
    end
})

-- A slider for numeric input
Window:AddSlider({
    text = "Test Slider",
    min = 1,
    max = 100,
    default = 50,
    onDrag = function(value)
        -- This function fires every time the slider moves (live feedback)
        print("Slider dragging at: " .. value)
    end,
    callback = function(value)
        -- This function fires when the mouse is released
        Window:SetStatus("Slider set to: " .. value)
        print("Slider released at: " .. value)
    end
})

-- A final label for credits or notes
Window:AddLabel({
    text = "Created with Unveil UI v1.1",
    align = Enum.TextXAlignment.Center,
    textSize = 12,
    color = Color3.fromRGB(100, 100, 100)
})

-- Initialize the UI and set a custom toggle key
Window:Init({
    toggleKey = Enum.KeyCode.PageUp
})