--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                   NovaUI v1.2 (Complete)                  ║
    ║        A feature-rich, modern Lua GUI framework.          ║
    ║      Combines the best of BloxHub and StarlightUI.        ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local NovaUI = { _windows = {} }
NovaUI.__index = NovaUI

-- Services & Utils
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function tween(inst, props, dur, style, dir)
    local info = TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local newTween = TweenService:Create(inst, info, props); newTween:Play(); return newTween
end

-- Constructor
function NovaUI.new()
    local self = setmetatable({}, NovaUI)
    self.activeKeybind = nil
    self.screenGui = Instance.new("ScreenGui", gethui and gethui() or game:GetService("CoreGui"))
    self.screenGui.Name = "NovaUI_Root_"..math.random(1,1000)
    self.screenGui.ResetOnSpawn, self.screenGui.ZIndexBehavior = false, Enum.ZIndexBehavior.Sibling

    -- Themes Table --
    self.theme = {
        Background=Color3.fromRGB(25,25,30), Primary=Color3.fromRGB(35,35,40),
        Secondary=Color3.fromRGB(50,50,55), Accent=Color3.fromRGB(0,120,255),
        Text=Color3.fromRGB(255,255,255), TextDim=Color3.fromRGB(170,170,170)
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
    Instance.new("UIListLayout", tabContainer).Padding, Instance.new("UIPadding", tabContainer).PaddingTop = UDim.new(0,5), UDim.new(0,10)

    local contentContainer = Instance.new("Frame", main)
    contentContainer.Size, contentContainer.Position, contentContainer.BackgroundTransparency = UDim2.new(1,-140,1,-40), UDim2.new(0,140,0,40), 1
    
    function window:destroy() self.mainFrame:Destroy() end

    header.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then local d,s=i.Position,main.Position local m,u m=UserInputService.InputChanged:Connect(function(c) if c.UserInputType==Enum.UserInputType.MouseMovement then main.Position=UDim2.new(s.X.Scale,s.X.Offset+(c.Position.X-d.X),s.Y.Scale,s.Y.Offset+(c.Position.Y-d.Y))end end) u=UserInputService.InputEnded:Connect(function(e)if e.UserInputType==Enum.UserInputType.MouseButton1 then m:Disconnect() u:Disconnect()end end)end end)

    function window:createTab(name)
        local tab = {}
        local btn = Instance.new("TextButton",tabContainer); btn.Name,btn.Size,btn.AnchorPoint,btn.Position=name,UDim2.new(1,-20,0,35),Vector2.new(0.5,0),UDim2.new(0.5,0,0,0)
        btn.BackgroundColor3,btn.Text,btn.Font,btn.TextColor3,btn.TextSize=nova.theme.Secondary,name,Enum.Font.GothamSemibold,nova.theme.Text,14
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
        local content=Instance.new("ScrollingFrame",contentContainer);content.Size,content.Position,content.BackgroundTransparency=UDim2.new(1,-20,1,-10),UDim2.new(0,10,0,5),1
        content.BorderSizePixel,content.ScrollBarThickness,content.ScrollBarImageColor3,content.Visible=0,4,nova.theme.Accent,false
        Instance.new("UIListLayout",content).Padding=UDim.new(0,8)
        local function act() for _,t in pairs(window.tabs)do t.content.Visible=false tween(t.button,{BackgroundColor3=nova.theme.Secondary})end content.Visible=true tween(btn,{BackgroundColor3=nova.theme.Accent})window.activeTab=tab end
        btn.MouseButton1Click:Connect(act); tab.button,tab.content=btn,content;table.insert(window.tabs,tab);if not window.activeTab then act()end
        
        function tab:addLabel(text,p) local l=Instance.new("TextLabel",content);l.Size,l.BackgroundTransparency=UDim2.new(1,0,0,20),1;l.Text,l.Font,l.TextSize,l.TextColor3,l.TextXAlignment=text,(p or{}).bold and Enum.Font.GothamBold or Enum.Font.Gotham,(p or{}).size or 16,nova.theme.Text,Enum.TextXAlignment.Left;return l end
        function tab:addButton(text,cb) local f=Instance.new("Frame",content);f.Size,f.BackgroundColor3=UDim2.new(1,0,0,35),nova.theme.Primary;Instance.new("UICorner",f).CornerRadius=UDim.new(0,6);local l=Instance.new("TextLabel",f);l.Size,l.BackgroundTransparency,l.Text,l.Font,l.TextColor3,l.TextSize=UDim2.new(1,0,1,0),1,text,Enum.Font.Gotham,nova.theme.Text,14;local b=Instance.new("TextButton",f);b.Size,b.BackgroundTransparency=UDim2.new(1,0,1,0),1;b.MouseEnter:Connect(function()tween(f,{BackgroundColor3=nova.theme.Accent})end)b.MouseLeave:Connect(function()tween(f,{BackgroundColor3=nova.theme.Primary})end)if cb then b.MouseButton1Click:Connect(cb)end;return f end
        function tab:addToggle(text,def,cb) local t=def or false local f=Instance.new("Frame",content);f.Size,f.BackgroundColor3=UDim2.new(1,0,0,40),nova.theme.Primary;Instance.new("UICorner",f).CornerRadius=UDim.new(0,6);Instance.new("TextLabel",f)._ref={Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,15,0,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=text,TextSize=14,TextColor3=nova.theme.Text,TextXAlignment=Enum.TextXAlignment.Left};local s=Instance.new("Frame",f);s.Size,s.Position=UDim2.new(0,40,0,20),UDim2.new(1,-55,0.5,-10);s.BackgroundColor3=t and nova.theme.Accent or nova.theme.Secondary;Instance.new("UICorner",s).CornerRadius=UDim.new(0,10);local k=Instance.new("Frame",s);k.Size,k.Position=UDim2.new(0,16,0,16),t and UDim2.new(1,-18,0.5,-8)or UDim2.new(0,2,0.5,-8);k.BackgroundColor3=Color3.new(1,1,1);Instance.new("UICorner",k).CornerRadius=UDim.new(0,8);local b=Instance.new("TextButton",f);b.Size,b.BackgroundTransparency=UDim2.new(1,0,1,0),1;b.MouseButton1Click:Connect(function()t=not t tween(s,{BackgroundColor3=t and nova.theme.Accent or nova.theme.Secondary})tween(k,{Position=t and UDim2.new(1,-18,0.5,-8)or UDim2.new(0,2,0.5,-8)})if cb then pcall(cb,t)end end);return end
        function tab:addSlider(text,min,max,def,cb) local val=def or min local f=Instance.new("Frame",content);f.Size,f.BackgroundColor3=UDim2.new(1,0,0,50),nova.theme.Primary;Instance.new("UICorner",f).CornerRadius=UDim.new(0,6);Instance.new("TextLabel",f)._ref={Size=UDim2.new(0.7,0,0,20),Position=UDim2.new(0,15,0,5),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=text,TextSize=14,TextColor3=nova.theme.Text,TextXAlignment=Enum.TextXAlignment.Left};local vl=Instance.new("TextLabel",f);vl.Size,vl.Position,vl.BackgroundTransparency,vl.Font,vl.TextSize,vl.TextColor3,vl.TextXAlignment,vl.Text=UDim2.new(0.3,-15,0,20),UDim2.new(0.7,0,0,5),1,Enum.Font.GothamBold,14,nova.theme.TextDim,Enum.TextXAlignment.Right,tostring(math.floor(val));local tr=Instance.new("Frame",f);tr.Size,tr.Position,tr.AnchorPoint,tr.BackgroundColor3=UDim2.new(1,-30,0,4),UDim2.new(0.5,0,1,-15),Vector2.new(0.5,0.5),nova.theme.Secondary;Instance.new("UICorner",tr).CornerRadius=UDim.new(0,2);local fi=Instance.new("Frame",tr);fi.Size,fi.BackgroundColor3=UDim2.new((val-min)/(max-min),0,1,0),nova.theme.Accent;Instance.new("UICorner",fi).CornerRadius=UDim.new(0,2);local dr=Instance.new("TextButton",tr);dr.Size,dr.BackgroundTransparency,dr.Position,dr.AnchorPoint=UDim2.new(1,0,3,0),1,UDim2.new(0,0,0.5,0),Vector2.new(0,0.5);local function u(x)local p=math.clamp((x-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)val=min+(max-min)*p fi.Size=UDim2.new(p,0,1,0)vl.Text=tostring(math.floor(val))if cb then pcall(cb,math.floor(val))end end;dr.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then u(i.Position.X)local m,e m=UserInputService.InputChanged:Connect(function(c)if c.UserInputType==Enum.UserInputType.MouseMovement then u(c.Position.X)end end)e=UserInputService.InputEnded:Connect(function(o)if o.UserInputType==Enum.UserInputType.MouseButton1 then m:Disconnect() e:Disconnect()end end)end end);return end
        function tab:addKeybind(text,def,cb) local key=def or"..."local f=Instance.new("Frame",content);f.Size,f.BackgroundColor3=UDim2.new(1,0,0,40),nova.theme.Primary;Instance.new("UICorner",f).CornerRadius=UDim.new(0,6);Instance.new("TextLabel",f)._ref={Size=UDim2.new(0.6,0,1,0),Position=UDim2.new(0,15,0,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=text,TextSize=14,TextColor3=nova.theme.Text,TextXAlignment=Enum.TextXAlignment.Left};local kb=Instance.new("TextButton",f);kb.Size,kb.Position,kb.AnchorPoint,kb.BackgroundColor3=UDim2.new(0.4,-15,1,-10),UDim2.new(0.6,0,0.5,0),Vector2.new(0,0.5),nova.theme.Secondary;kb.Text,kb.Font,kb.TextColor3=key,Enum.Font.GothamSemibold,nova.theme.TextDim;Instance.new("UICorner",kb).CornerRadius=UDim.new(0,4);local kbind={button=kb,callback=cb,key=key};function kbind:update(nk)self.key=nk self.button.Text=nk end;kb.MouseButton1Click:Connect(function()kb.Text="..."nova.activeKeybind=kbind end);return end
        function tab:addTextBox(text,ph,cb) local f=Instance.new("Frame",content);f.Size,f.BackgroundColor3=UDim2.new(1,0,0,40),nova.theme.Primary;Instance.new("UICorner",f).CornerRadius=UDim.new(0,6);Instance.new("TextLabel",f)._ref={Size=UDim2.new(0.35,0,1,0),Position=UDim2.new(0,15,0,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=text,TextSize=14,TextColor3=nova.theme.Text,TextXAlignment=Enum.TextXAlignment.Left};local b=Instance.new("TextBox",f);b.Size,b.Position,b.AnchorPoint,b.BackgroundColor3=UDim2.new(0.65,-15,1,-10),UDim2.new(0.35,0,0.5,0),Vector2.new(0,0.5),nova.theme.Secondary;b.Font,b.TextColor3,b.PlaceholderText,b.PlaceholderColor3,b.ClearTextOnFocus=Enum.Font.Gotham,nova.theme.Text,ph or"",nova.theme.TextDim,false;Instance.new("UICorner",b).CornerRadius=UDim.new(0,4);Instance.new("UIPadding",b).PaddingLeft=UDim.new(0,10);if cb then b.FocusLost:Connect(function(e)pcall(cb,b.Text,e)end)end;return end
        function tab:addDropdown(text,opts,cb) local ex,sel=false,opts[1]local f=Instance.new("Frame",content);f.Size,f.BackgroundColor3,f.ZIndex=UDim2.new(1,0,0,40),nova.theme.Primary,2;Instance.new("UICorner",f).CornerRadius=UDim.new(0,6);Instance.new("TextLabel",f)._ref={Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,15,0,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=text,TextSize=14,TextColor3=nova.theme.Text,TextXAlignment=Enum.TextXAlignment.Left};local dr=Instance.new("TextButton",f);dr.Size,dr.Position,dr.AnchorPoint,dr.BackgroundColor3=UDim2.new(0.5,-15,1,-10),UDim2.new(0.5,0,0.5,0),Vector2.new(0,0.5),nova.theme.Secondary;dr.Font,dr.TextColor3,dr.Text=Enum.Font.GothamSemibold,nova.theme.Text,sel.." ▼";Instance.new("UICorner",dr).CornerRadius=UDim.new(0,4);local oh=Instance.new("Frame",nova.screenGui);oh.Size,oh.BackgroundColor3,oh.BorderSizePixel,oh.Visible,oh.ZIndex=UDim2.fromOffset(dr.AbsoluteSize.X,#opts*33+10),nova.theme.Primary,0,false,10;Instance.new("UICorner",oh).CornerRadius=UDim.new(0,6);Instance.new("UIListLayout",oh).Padding=UDim.new(0,5);local p=Instance.new("UIPadding",oh);p.PaddingLeft,p.PaddingRight,p.PaddingTop=UDim.new(0,5),UDim.new(0,5),UDim.new(0,5);for _,o in pairs(opts)do local b=Instance.new("TextButton",oh);b.Size,b.BackgroundColor3,b.Text,b.Font,b.TextColor3=UDim2.new(1,0,0,28),nova.theme.Secondary,o,Enum.Font.Gotham,nova.theme.Text;Instance.new("UICorner",b).CornerRadius=UDim.new(0,4);b.MouseButton1Click:Connect(function()sel=o dr.Text=sel.." ▼"oh.Visible=false ex=false if cb then pcall(cb,o)end end)end;dr.MouseButton1Click:Connect(function()ex=not ex oh.Visible=ex oh.Position=UDim2.fromOffset(dr.AbsolutePosition.X,dr.AbsolutePosition.Y+dr.AbsoluteSize.Y)dr.Text=sel..(ex and" ▲"or" ▼")end);return end
        return tab
    end
    return window
end

return NovaUI
