--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                   NovaUI v1.3 (Polished)                  ║
    ║        A feature-rich, modern Lua GUI framework.          ║
    ║               Final, stable, and readable.                ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local NovaUI = { _windows = {} }
NovaUI.__index = NovaUI

-- Services & Utils
local TweenService = game:GetService("UserInputService") and game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function tween(inst, props)
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local newTween = TweenService:Create(inst, info, props)
    newTween:Play()
    return newTween
end

-- Constructor
function NovaUI.new()
    local self = setmetatable({}, NovaUI)
    self.activeKeybind = nil
    self.screenGui = Instance.new("ScreenGui", gethui and gethui() or game:GetService("CoreGui"))
    self.screenGui.Name = "NovaUI_Root_"..math.random(1,1000)
    self.screenGui.ResetOnSpawn, self.screenGui.ZIndexBehavior = false, Enum.ZIndexBehavior.Sibling

    self.theme = {
        Background = Color3.fromRGB(25,25,30), Primary = Color3.fromRGB(35,35,40),
        Secondary = Color3.fromRGB(50,50,55), Accent = Color3.fromRGB(0,120,255),
        Text = Color3.fromRGB(255,255,255), TextDim = Color3.fromRGB(170,170,170)
    }
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or not self.activeKeybind then return end
        local keybind = self.activeKeybind; self.activeKeybind = nil
        keybind:update(input.KeyCode.Name)
        if keybind.callback then pcall(keybind.callback, input.KeyCode.Name) end
    end)
    return self
end

function NovaUI:createWindow(config)
    local nova, window = self, { tabs = {}, activeTab = nil }
    local main = Instance.new("Frame", nova.screenGui)
    window.mainFrame = main
    main.Name, main.Size, main.Position = config.title or "NovaWindow", config.size or UDim2.new(0,540,0,400), config.position or UDim2.new(0.5,-270,0.5,-200)
    main.BackgroundColor3, main.BorderSizePixel, main.ClipsDescendants = nova.theme.Background, 0, true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

    local header = Instance.new("Frame", main)
    header.Size, header.BackgroundColor3 = UDim2.new(1,0,0,40), nova.theme.Primary
    
    local title = Instance.new("TextLabel", header)
    title.Size, title.Position, title.BackgroundTransparency = UDim2.new(1,-50,1,0), UDim2.new(0,15,0,0), 1
    title.Font, title.Text, title.TextColor3, title.TextXAlignment, title.TextSize = Enum.Font.GothamBold, config.title, nova.theme.Text, Enum.TextXAlignment.Left, 16

    local tabContainer = Instance.new("ScrollingFrame", main)
    tabContainer.Size, tabContainer.Position, tabContainer.BackgroundColor3 = UDim2.new(0,140,1,-40), UDim2.new(0,0,0,40), nova.theme.Primary
    tabContainer.BorderSizePixel, tabContainer.ScrollBarThickness = 0, 0
    Instance.new("UIListLayout", tabContainer).Padding = UDim.new(0,5)
    Instance.new("UIPadding", tabContainer).PaddingTop = UDim.new(0,10)

    local contentContainer = Instance.new("Frame", main)
    contentContainer.Size, contentContainer.Position, contentContainer.BackgroundTransparency = UDim2.new(1,-140,1,-40), UDim2.new(0,140,0,40), 1
    
    function window:destroy() self.mainFrame:Destroy() end

    header.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then local d,s=i.Position,main.Position local m,u m=UserInputService.InputChanged:Connect(function(c) if c.UserInputType==Enum.UserInputType.MouseMovement then main.Position=UDim2.new(s.X.Scale,s.X.Offset+(c.Position.X-d.X),s.Y.Scale,s.Y.Offset+(c.Position.Y-d.Y))end end) u=UserInputService.InputEnded:Connect(function(e)if e.UserInputType==Enum.UserInputType.MouseButton1 then m:Disconnect() u:Disconnect()end end)end end)

    function window:createTab(name)
        local tab = {}
        local btn = Instance.new("TextButton",tabContainer); btn.Name,btn.Size,btn.AnchorPoint,btn.Position=name,UDim2.new(1,-20,0,35),Vector2.new(0.5,0),UDim2.new(0.5,0,0,0); btn.BackgroundColor3,btn.Text,btn.Font,btn.TextColor3,btn.TextSize=nova.theme.Secondary,name,Enum.Font.GothamSemibold,nova.theme.Text,14; Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
        local content=Instance.new("ScrollingFrame",contentContainer); content.Size,content.Position,content.BackgroundTransparency=UDim2.new(1,-20,1,-10),UDim2.new(0,10,0,5),1; content.BorderSizePixel,content.ScrollBarThickness,content.ScrollBarImageColor3,content.Visible=0,4,nova.theme.Accent,false; Instance.new("UIListLayout",content).Padding=UDim.new(0,8)
        local function act() for _,t in pairs(window.tabs)do t.content.Visible=false tween(t.button,{BackgroundColor3=nova.theme.Secondary})end content.Visible=true tween(btn,{BackgroundColor3=nova.theme.Accent})window.activeTab=tab end
        btn.MouseButton1Click:Connect(act); tab.button,tab.content=btn,content; table.insert(window.tabs,tab); if not window.activeTab then act()end
        
        function tab:addLabel(text, props)
            local label = Instance.new("TextLabel", content); label.Size, label.BackgroundTransparency = UDim2.new(1, 0, 0, 20), 1; label.Text = text; label.Font = (props or {}).bold and Enum.Font.GothamBold or Enum.Font.Gotham; label.TextSize = (props or {}).size or 16; label.TextColor3 = nova.theme.Text; label.TextXAlignment = Enum.TextXAlignment.Left; return label
        end

        function tab:addButton(text, callback)
            local frame = Instance.new("Frame", content); frame.Size, frame.BackgroundColor3 = UDim2.new(1,0,0,35), nova.theme.Primary; Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6); local textLabel = Instance.new("TextLabel", frame); textLabel.Size, textLabel.BackgroundTransparency = UDim2.new(1,0,1,0), 1; textLabel.Text, textLabel.Font, textLabel.TextColor3, textLabel.TextSize = text, Enum.Font.Gotham, nova.theme.Text, 14; local button = Instance.new("TextButton", frame); button.Size, button.BackgroundTransparency = UDim2.new(1,0,1,0), 1; button.MouseEnter:Connect(function() tween(frame, {BackgroundColor3 = nova.theme.Accent}) end); button.MouseLeave:Connect(function() tween(frame, {BackgroundColor3 = nova.theme.Primary}) end); if callback then button.MouseButton1Click:Connect(callback) end; return frame
        end

        function tab:addToggle(text, default, callback)
            local toggled = default or false; local container = Instance.new("Frame", content); container.Size, container.BackgroundColor3 = UDim2.new(1,0,0,40), nova.theme.Primary; Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
            local label = Instance.new("TextLabel", container); label.Size, label.Position, label.BackgroundTransparency, label.Font, label.Text, label.TextSize, label.TextColor3, label.TextXAlignment = UDim2.new(1,-60,1,0), UDim2.new(0,15,0,0), 1, Enum.Font.Gotham, text, 14, nova.theme.Text, Enum.TextXAlignment.Left
            local switch = Instance.new("Frame", container); switch.Size, switch.Position, switch.BackgroundColor3 = UDim2.new(0,40,0,20), UDim2.new(1,-55,0.5,-10), toggled and nova.theme.Accent or nova.theme.Secondary; Instance.new("UICorner", switch).CornerRadius = UDim.new(0,10)
            local knob = Instance.new("Frame", switch); knob.Size, knob.Position, knob.BackgroundColor3 = UDim2.new(0,16,0,16), toggled and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8), Color3.new(1,1,1); Instance.new("UICorner", knob).CornerRadius = UDim.new(0,8)
            local button = Instance.new("TextButton", container); button.Size, button.BackgroundTransparency = UDim2.new(1,0,1,0), 1; button.MouseButton1Click:Connect(function() toggled = not toggled; tween(switch, {BackgroundColor3 = toggled and nova.theme.Accent or nova.theme.Secondary}); tween(knob, {Position = toggled and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}); if callback then pcall(callback, toggled) end end); return container
        end
        
        return tab
    end
    return window
end

return NovaUI
