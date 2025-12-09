--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                   ZenithUI v1.0 (Definitive)              ║
    ║        A polished, feature-complete GUI Framework         ║
    ║        Inspired by BloxHub with a modern layout           ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local ZenithUI = {}
ZenithUI.__index = ZenithUI

--// Services & Utilities
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function tween(inst, props)
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local newTween = TweenService:Create(inst, info, props)
    newTween:Play()
    return newTween
end

--// Constructor
function ZenithUI.new()
    local self = setmetatable({}, ZenithUI)
    self.activeKeybind = nil
    self.windows = {}

    self.screenGui = Instance.new("ScreenGui", gethui and gethui() or game:GetService("CoreGui"))
    self.screenGui.Name = "ZenithUI_Root_"..math.random(1,1000)
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    self.Themes = {
        Dark = { Background=Color3.fromRGB(25,25,30), Primary=Color3.fromRGB(35,35,40), Secondary=Color3.fromRGB(50,50,55), Accent=Color3.fromRGB(0,120,255), Text=Color3.fromRGB(255,255,255), TextDim=Color3.fromRGB(170,170,170) },
        Light = { Background=Color3.fromRGB(240,240,245), Primary=Color3.fromRGB(255,255,255), Secondary=Color3.fromRGB(230,230,240), Accent=Color3.fromRGB(0,120,255), Text=Color3.fromRGB(20,20,30), TextDim=Color3.fromRGB(100,100,110) },
        Purple = { Background=Color3.fromRGB(20,15,30), Primary=Color3.fromRGB(30,25,45), Secondary=Color3.fromRGB(45,35,60), Accent=Color3.fromRGB(138,43,226), Text=Color3.fromRGB(255,255,255), TextDim=Color3.fromRGB(180,170,200) }
    }
    self.theme = self.Themes.Dark
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or not self.activeKeybind then return end
        local keybind = self.activeKeybind; self.activeKeybind = nil
        keybind:update(input.KeyCode.Name)
        if keybind.callback then pcall(keybind.callback, input.KeyCode.Name) end
    end)
    
    return self
end

function ZenithUI:setTheme(name)
    local newTheme = self.Themes[name]
    if not newTheme then return end
    self.theme = newTheme
    
    for _, window in pairs(self.windows) do
        pcall(function() window:_updateTheme(newTheme) end)
    end
end

function ZenithUI:createWindow(config)
    local zenith, window = self, { tabs = {}, components = {} }
    table.insert(zenith.windows, window)

    local main = Instance.new("Frame", zenith.screenGui)
    window.mainFrame = main
    main.Name, main.Size, main.Position = config.title or "ZenithWindow", config.size or UDim2.new(0,560,0,420), config.position or UDim2.new(0.5,-280,0.5,-210)
    main.BackgroundColor3, main.BorderSizePixel, main.ClipsDescendants = zenith.theme.Background, 0, true
    local mainCorner = Instance.new("UICorner", main); mainCorner.CornerRadius = UDim.new(0, 12)
    window.mainCorner = mainCorner
    
    local header = Instance.new("Frame", main)
    window.header = header
    header.Size, header.BackgroundColor3 = UDim2.new(1,0,0,40), zenith.theme.Primary
    local headerCorner = Instance.new("UICorner", header); headerCorner.CornerRadius = UDim.new(0, 12)
    window.headerCorner = headerCorner
    
    local title = Instance.new("TextLabel", header)
    window.titleLabel = title
    title.Size, title.Position, title.BackgroundTransparency = UDim2.new(1,-50,1,0), UDim2.new(0,20,0,0), 1
    title.Font, title.Text, title.TextColor3, title.TextXAlignment, title.TextSize = Enum.Font.GothamBold, config.title, zenith.theme.Text, Enum.TextXAlignment.Left, 16

    local tabContainer = Instance.new("Frame", main)
    window.tabContainer = tabContainer
    tabContainer.Size, tabContainer.Position, tabContainer.BackgroundColor3, tabContainer.BorderSizePixel = UDim2.new(0,150,1,-40), UDim2.new(0,0,0,40), zenith.theme.Primary, 0
    local tabLayout = Instance.new("UIListLayout", tabContainer); tabLayout.Padding, tabLayout.HorizontalAlignment = UDim.new(0,8), Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", tabContainer).PaddingTop = UDim.new(0,15)
    
    local contentContainer = Instance.new("ScrollingFrame", main)
    contentContainer.Size, contentContainer.Position, contentContainer.BackgroundTransparency = UDim2.new(1,-150,1,-40), UDim2.new(0,150,0,40), 1
    contentContainer.BorderSizePixel, contentContainer.ScrollBarThickness, contentContainer.ScrollBarImageColor3 = 0, 4, zenith.theme.Accent
    local listLayout = Instance.new("UIListLayout", contentContainer); listLayout.Padding = UDim.new(0, 10)
    Instance.new("UIPadding", contentContainer).Padding = UDim.new(0, 20)
    window.contentLayout = listLayout
    
    function window:destroy() self.mainFrame:Destroy() end
    header.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then local d,s=i.Position,main.Position local m,u m=UserInputService.InputChanged:Connect(function(c) if c.UserInputType==Enum.UserInputType.MouseMovement then main.Position=UDim2.new(s.X.Scale,s.X.Offset+(c.Position.X-d.X),s.Y.Scale,s.Y.Offset+(c.Position.Y-d.Y))end end) u=UserInputService.InputEnded:Connect(function(e)if e.UserInputType==Enum.UserInputType.MouseButton1 then m:Disconnect() u:Disconnect()end end)end end)

    function window:_updateTheme(theme)
        main.BackgroundColor3 = theme.Background
        header.BackgroundColor3, tabContainer.BackgroundColor3 = theme.Primary, theme.Primary
        title.TextColor3 = theme.Text
        contentContainer.ScrollBarImageColor3 = theme.Accent
        for _, comp in pairs(self.components) do comp:_updateTheme(theme) end
        for _, tab in pairs(self.tabs) do
            if tab ~= self.activeTab then tab.button.BackgroundColor3 = theme.Secondary else tab.button.BackgroundColor3 = theme.Accent end
            tab.button.TextColor3 = theme.Text
        end
    end

    function window:createTab(name)
        local tab = { components = {} }
        local btn = Instance.new("TextButton",tabContainer); btn.Name,btn.Size,btn.AutoButtonColor=name,UDim2.new(1,-30,0,35),false; btn.BackgroundColor3,btn.Text,btn.Font,btn.TextColor3,btn.TextSize=zenith.theme.Secondary,name,Enum.Font.GothamSemibold,zenith.theme.Text,14; Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
        local contentFrame=Instance.new("Frame", contentContainer); contentFrame.Name=name.."_Content"; contentFrame.Size,contentFrame.BackgroundTransparency=UDim2.new(1,0,0,0),1; contentFrame.AutomaticSize=Enum.AutomaticSize.Y
        local contentLayout = Instance.new("UIListLayout",contentFrame); contentLayout.Padding=UDim.new(0,10)
        contentFrame.Visible=false
        
        local function act() for _,t in pairs(window.tabs)do t.content.Visible=false; tween(t.button,{BackgroundColor3=zenith.theme.Secondary})end; contentFrame.Visible=true; tween(btn,{BackgroundColor3=zenith.theme.Accent}); window.activeTab=tab end
        btn.MouseButton1Click:Connect(act); tab.button,tab.content,tab.layout=btn,contentFrame,contentLayout; table.insert(window.tabs,tab); if not window.activeTab then act()end
        
        local function addComponent(component) table.insert(window.components, component); table.insert(tab.components, component); return component end

        function tab:addLabel(text, props)
            local label = Instance.new("TextLabel", tab.content); label.Size, label.BackgroundTransparency = UDim2.new(1,0,0,20), 1; label.Text = text; label.Font = (props or {}).bold and Enum.Font.GothamBold or Enum.Font.Gotham; label.TextSize = (props or {}).size or 16; label.TextColor3 = zenith.theme.Text; label.TextXAlignment = Enum.TextXAlignment.Left; 
            function label:_updateTheme(theme) self.TextColor3 = theme.Text end; return addComponent(label)
        end

        function tab:addButton(text, callback)
            local frame = Instance.new("Frame", tab.content); frame.Size, frame.BackgroundColor3 = UDim2.new(1,0,0,35), zenith.theme.Primary; Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6); local textLabel = Instance.new("TextLabel", frame); textLabel.Size, textLabel.BackgroundTransparency = UDim2.new(1,0,1,0), 1; textLabel.Text, textLabel.Font, textLabel.TextColor3, textLabel.TextSize = text, Enum.Font.Gotham, zenith.theme.Text, 14; local button = Instance.new("TextButton", frame); button.Size, button.BackgroundTransparency, button.Text = UDim2.new(1,0,1,0), 1, ""; button.MouseEnter:Connect(function() tween(frame, {BackgroundColor3 = zenith.theme.Accent}) end); button.MouseLeave:Connect(function() tween(frame, {BackgroundColor3 = zenith.theme.Primary}) end); if callback then button.MouseButton1Click:Connect(callback) end; 
            function frame:_updateTheme(theme) self.BackgroundColor3=theme.Primary; textLabel.TextColor3=theme.Text end; return addComponent(frame)
        end
        
        function tab:addTextBox(text, placeholder, callback)
            local container = Instance.new("Frame", tab.content); container.Size, container.BackgroundColor3 = UDim2.new(1,0,0,40), zenith.theme.Primary; Instance.new("UICorner", container).CornerRadius = UDim2.new(0, 6);
            local label = Instance.new("TextLabel", container); label.Size, label.Position, label.BackgroundTransparency, label.Font, label.Text, label.TextColor3, label.TextXAlignment, label.TextSize = UDim2.new(0.4,0,1,0), UDim2.new(0,15,0,0), 1, Enum.Font.Gotham, text, zenith.theme.Text, Enum.TextXAlignment.Left, 14;
            local box = Instance.new("TextBox", container); box.Size, box.Position, box.AnchorPoint = UDim2.new(0.6,-15,1,-10), UDim2.new(0.4,0,0.5,0), Vector2.new(0,0.5); box.BackgroundColor3, box.Font, box.TextColor3, box.PlaceholderText, box.PlaceholderColor3 = zenith.theme.Secondary, Enum.Font.Gotham, zenith.theme.Text, placeholder or "", zenith.theme.TextDim; box.ClearTextOnFocus=false; Instance.new("UICorner", box).CornerRadius=UDim2.new(0,4); Instance.new("UIPadding",box).PaddingLeft=UDim.new(0,10); if callback then box.FocusLost:Connect(function(ep) pcall(callback, box.Text, ep) end) end;
            function container:_updateTheme(theme) self.BackgroundColor3=theme.Primary; label.TextColor3=theme.Text; box.BackgroundColor3=theme.Secondary; box.TextColor3=theme.Text; box.PlaceholderColor3=theme.TextDim end; return addComponent(container)
        end
        
        function tab:addDropdown(text, options, callback)
            local expanded, selected = false, options[1]; local container = Instance.new("Frame", tab.content); container.Size, container.BackgroundColor3, container.ZIndex = UDim2.new(1,0,0,40), zenith.theme.Primary, #window.components + 1; Instance.new("UICorner",container).CornerRadius=UDim.new(0,6)
            local label = Instance.new("TextLabel", container); label.Size, label.Position, label.BackgroundTransparency, label.Font, label.Text, label.TextColor3, label.TextXAlignment, label.TextSize = UDim2.new(0.5,0,1,0), UDim2.new(0,15,0,0), 1, Enum.Font.Gotham, text, zenith.theme.Text, Enum.TextXAlignment.Left, 14;
            local dropdown = Instance.new("TextButton", container); dropdown.Size, dropdown.Position, dropdown.AnchorPoint = UDim2.new(0.5,-15,1,-10), UDim2.new(0.5,0,0.5,0), Vector2.new(0,0.5); dropdown.BackgroundColor3, dropdown.Font, dropdown.TextColor3, dropdown.Text = zenith.theme.Secondary, Enum.Font.GothamSemibold, zenith.theme.Text, selected.." ▼"; Instance.new("UICorner", dropdown).CornerRadius=UDim.new(0,4);
            local optionsHolder = Instance.new("Frame", zenith.screenGui); optionsHolder.BackgroundColor3, optionsHolder.BorderSizePixel, optionsHolder.Visible, optionsHolder.ZIndex = zenith.theme.Secondary, 0, false, 999; Instance.new("UICorner", optionsHolder).CornerRadius = UDim2.new(0,6); Instance.new("UIListLayout",optionsHolder).Padding=UDim.new(0,5); local pad=Instance.new("UIPadding",optionsHolder); pad.PaddingLeft,pad.PaddingRight,pad.PaddingTop,pad.PaddingBottom=UDim.new(0,5),UDim.new(0,5),UDim.new(0,5),UDim.new(0,5);
            local function updateOptions() for _,c in pairs(optionsHolder:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end; for _,o in pairs(options) do local btn=Instance.new("TextButton", optionsHolder); btn.Size,btn.BackgroundColor3,btn.Text,btn.Font,btn.TextColor3,btn.AutoButtonColor=UDim2.new(1,0,0,28),zenith.theme.Primary,o,Enum.Font.Gotham,zenith.theme.Text,false;Instance.new("UICorner",btn).CornerRadius=UDim.new(0,4);btn.MouseEnter:Connect(function()tween(btn,{BackgroundColor3=zenith.theme.Accent})end)btn.MouseLeave:Connect(function()tween(btn,{BackgroundColor3=zenith.theme.Primary})end)btn.MouseButton1Click:Connect(function() selected=o;dropdown.Text=selected.." ▼";optionsHolder.Visible=false;expanded=false;if callback then pcall(callback,o)end end) end; optionsHolder.Size=UDim2.fromOffset(dropdown.AbsoluteSize.X, #options*33+10) end
            updateOptions(); dropdown.MouseButton1Click:Connect(function() expanded=not expanded; optionsHolder.Visible=expanded; optionsHolder.Position=UDim2.fromOffset(dropdown.AbsolutePosition.X,dropdown.AbsolutePosition.Y+dropdown.AbsoluteSize.Y); dropdown.Text=selected..(expanded and " ▲" or " ▼") end);
            function container:_updateTheme(theme) self.BackgroundColor3=theme.Primary;label.TextColor3=theme.Text;dropdown.BackgroundColor3=theme.Secondary;dropdown.TextColor3=theme.Text;optionsHolder.BackgroundColor3=theme.Secondary;for _,b in pairs(optionsHolder:GetChildren())do if b:IsA("TextButton")then b.BackgroundColor3=theme.Primary;b.TextColor3=theme.Text end end end; return addComponent(container)
        end
        
        return tab
    end
    
    return window
end

return ZenithUI
