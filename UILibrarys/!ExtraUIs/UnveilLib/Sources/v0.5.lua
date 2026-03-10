--[[
    Modern Dev Console v1.1
--]]

--// Services
local UserInputService = game:GetService("UserInputService")
local LogService = game:GetService("LogService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

--// Configuration Table (Customize everything here!)
local Config = {
    -- Dimensions
    WindowSize = Vector2.new(650, 400),
    TitleBarHeight = 32,
    TabBarHeight = 30,
    IndicatorHeight = 2,
    CommandBarHeight = 30,

    -- Fonts
    Font_UI = Enum.Font.GothamSemibold,
    Font_Code = Enum.Font.Code,
    FontSize_Title = 16,
    FontSize_Tab = 14,
    FontSize_Log = 14,

    -- Colors (Professional Palette)
    Color_Background = Color3.fromRGB(30, 31, 34),
    Color_Primary = Color3.fromRGB(45, 46, 49),
    Color_Content_Inset = Color3.fromRGB(24, 25, 27),
    Color_Stroke = Color3.fromRGB(65, 66, 70),
    Color_Text = Color3.fromRGB(210, 212, 214),
    Color_Text_Secondary = Color3.fromRGB(150, 152, 155),
    Color_CloseButton = Color3.fromRGB(231, 76, 60),

    -- Tab Specific Colors
    TabColors = {
        Output = Color3.fromRGB(200, 200, 200),
        Information = Color3.fromRGB(52, 152, 219),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Settings = Color3.fromRGB(142, 68, 173)
    },
    
    Settings = { ShowTimestamps = true, LogFontSize = 14 }
}

--// Main Script Logic
local success, err = pcall(function()
    local MasterLog, LogCounters = {}, { Output = 0, Information = 0, Warning = 0, Error = 0 }
    local CommandHistory, HistoryIndex = {}, 0
    local CurrentSearchTerm, SelectedTab = "", "Output"

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModernDevConsole"; screenGui.ResetOnSpawn = false; screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"; mainFrame.Size = UDim2.new(0, Config.WindowSize.X, 0, Config.WindowSize.Y)
    mainFrame.Position = UDim2.new(0.5, -Config.WindowSize.X / 2, 0.5, -Config.WindowSize.Y / 2)
    mainFrame.BackgroundColor3 = Config.Color_Background; mainFrame.ClipsDescendants = true
    mainFrame.Active = true; mainFrame.Draggable = true; mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", mainFrame).Color = Config.Color_Stroke

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"; titleBar.Size = UDim2.new(1, 0, 0, Config.TitleBarHeight)
    titleBar.BackgroundColor3 = Config.Color_Primary; titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"; titleLabel.Size = UDim2.new(0, 150, 1, 0); titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1; titleLabel.Text = "Mini Dev Console"; titleLabel.TextColor3 = Config.Color_Text
    titleLabel.Font = Config.Font_UI; titleLabel.TextSize = Config.FontSize_Title; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local searchBar = Instance.new("TextBox")
    searchBar.Name = "SearchBar"; searchBar.Size = UDim2.new(1, -210, 0, 22); searchBar.Position = UDim2.new(0, 160, 0.5, -11)
    searchBar.BackgroundColor3 = Config.Color_Content_Inset; searchBar.TextColor3 = Config.Color_Text
    searchBar.Text = "" -- [FIX] Set default text to empty to show placeholder
    searchBar.PlaceholderText = "Search logs..."
    searchBar.PlaceholderColor3 = Config.Color_Text_Secondary
    searchBar.Font = Config.Font_UI; searchBar.TextSize = 13; searchBar.ClearTextOnFocus = false
    searchBar.Parent = titleBar
    Instance.new("UICorner", searchBar).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", searchBar).Color = Config.Color_Stroke

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"; closeBtn.Size = UDim2.new(0, 20, 0, 20); closeBtn.Position = UDim2.new(1, -26, 0.5, -10)
    closeBtn.BackgroundColor3 = Config.Color_CloseButton; closeBtn.Text = ""; closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"; tabContainer.Size = UDim2.new(1, 0, 0, Config.TabBarHeight)
    tabContainer.Position = UDim2.new(0, 0, 0, Config.TitleBarHeight); tabContainer.BackgroundColor3 = Config.Color_Primary
    tabContainer.Parent = mainFrame
    Instance.new("UIListLayout", tabContainer).FillDirection = Enum.FillDirection.Horizontal
    Instance.new("UIPadding", tabContainer).PaddingLeft = UDim.new(0, 8)

    local indicatorContainer = Instance.new("Frame", mainFrame)
    indicatorContainer.Name = "IndicatorContainer"; indicatorContainer.Size = UDim2.new(1, 0, 0, Config.IndicatorHeight)
    indicatorContainer.Position = UDim2.new(0, 0, 0, Config.TitleBarHeight + Config.TabBarHeight); indicatorContainer.BackgroundColor3 = Config.Color_Stroke
    local tabIndicator = Instance.new("Frame", indicatorContainer)
    tabIndicator.Name = "TabIndicator"; tabIndicator.Size = UDim2.new(0, 0, 1, 0); tabIndicator.BackgroundColor3 = Color3.new(1, 1, 1); tabIndicator.BorderSizePixel = 0
    Instance.new("UICorner", tabIndicator).CornerRadius = UDim.new(1, 0)

    local contentYPos = Config.TitleBarHeight + Config.TabBarHeight + Config.IndicatorHeight
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"; contentArea.Size = UDim2.new(1, 0, 1, -contentYPos - Config.CommandBarHeight)
    contentArea.Position = UDim2.new(0, 0, 0, contentYPos); contentArea.BackgroundColor3 = Config.Color_Background
    contentArea.Parent = mainFrame
    
    local tabNames = {"Output", "Information", "Warning", "Error", "Settings"}
    local tabs, contentFrames = {}, {}
    local updateDisplay
    for _, tabName in ipairs(tabNames) do
        local btn = Instance.new("TextButton"); btn.Name = tabName.."Tab"; btn.Size = UDim2.new(0,100,1,0); btn.BackgroundTransparency = 1
        btn.TextColor3 = Config.Color_Text_Secondary; btn.Text = tabName; btn.Font = Config.Font_UI
        btn.TextSize = Config.FontSize_Tab; btn.Parent = tabContainer; tabs[tabName] = btn

        local contentFrame = Instance.new(tabName == "Settings" and "Frame" or "ScrollingFrame")
        contentFrame.Name = tabName.."Content"; contentFrame.Size = UDim2.new(1,0,1,0)
        contentFrame.BackgroundColor3 = Config.Color_Background; contentFrame.BorderSizePixel = 0
        contentFrame.Visible = false; contentFrame.Parent = contentArea; contentFrames[tabName] = contentFrame

        if contentFrame:IsA("ScrollingFrame") then
            contentFrame.Size = UDim2.new(1,0,1,-38); contentFrame.BackgroundColor3 = Config.Color_Content_Inset
            contentFrame.ScrollBarThickness = 6; contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIListLayout", contentFrame).Padding = UDim.new(0, 4)
            local p = Instance.new("UIPadding", contentFrame); p.PaddingTop=UDim.new(0,8); p.PaddingLeft=UDim.new(0,8); p.PaddingRight=UDim.new(0,8)
            local actionBar = Instance.new("Frame", contentArea)
            actionBar.Name=tabName.."ActionBar"; actionBar.Size=UDim2.new(1,0,0,30); actionBar.Position=UDim2.new(0,0,1,-30)
            actionBar.BackgroundTransparency = 1; actionBar.Visible = false
            local function createActionButton(name, text, position)
                local ab=Instance.new("TextButton", actionBar); ab.Name=name; ab.Size=UDim2.new(0,80,0,22); ab.Position=position
                ab.BackgroundColor3=Config.Color_Primary; ab.TextColor3=Config.Color_Text_Secondary; ab.Font=Config.Font_UI; ab.TextSize=13; ab.Text=text
                Instance.new("UICorner",ab).CornerRadius=UDim.new(0,4); Instance.new("UIStroke",ab).Color=Config.Color_Stroke
                local op=ab.Position; ab.MouseButton1Down:Connect(function() ab.Position=UDim2.new(op.X.Scale, op.X.Offset, op.Y.Scale, op.Y.Offset + 1) end)
                ab.MouseButton1Up:Connect(function() ab.Position = op end); return ab
            end
            local clearBtn=createActionButton("Clear","Clear",UDim2.new(1,-178,0.5,-11))
            local copyBtn=createActionButton("CopyAll","Copy All",UDim2.new(1,-90,0.5,-11))
            clearBtn.MouseButton1Click:Connect(function() for i=#MasterLog,1,-1 do if MasterLog[i].Type==tabName then table.remove(MasterLog,i) end end; updateDisplay() end)
            copyBtn.MouseButton1Click:Connect(function() local l={}; for _,e in ipairs(MasterLog) do if e.Type==tabName then table.insert(l,e.Text) end end; if setclipboard then setclipboard(table.concat(l,"\n")) end; local ot=copyBtn.Text; copyBtn.Text="Copied!"; task.wait(1); copyBtn.Text=ot end)
        end
    end

    do
        local settingsFrame=contentFrames.Settings; Instance.new("UIListLayout",settingsFrame).Padding=UDim.new(0,10)
        local padding=Instance.new("UIPadding",settingsFrame); padding.PaddingTop=UDim.new(0,12); padding.PaddingLeft=UDim.new(0,12)
        local function createSetting(title, controlType)
            local holder=Instance.new("Frame",settingsFrame); holder.BackgroundTransparency=1; holder.Size=UDim2.new(1,0,0,25)
            local label=Instance.new("TextLabel",holder); label.BackgroundTransparency=1; label.Size=UDim2.new(0,150,1,0); label.Text=title
            label.Font=Config.Font_UI; label.TextSize=14; label.TextColor3=Config.Color_Text; label.TextXAlignment=Enum.TextXAlignment.Left
            if controlType=="Checkbox" then local c=Instance.new("TextButton",holder);c.Size=UDim2.new(0,22,0,22);c.Position=UDim2.new(0,160,0.5,-11);c.BackgroundColor3=Config.Color_Content_Inset;c.Text="";Instance.new("UICorner",c).CornerRadius=UDim.new(0,4);Instance.new("UIStroke",c).Color=Config.Color_Stroke;local k=Instance.new("Frame",c);k.BackgroundColor3=Config.TabColors.Information;k.Size=UDim2.new(1,-8,1,-8);k.AnchorPoint=Vector2.new(.5,.5);k.Position=UDim2.fromScale(.5,.5);Instance.new("UICorner",k).CornerRadius=UDim.new(0,2);return c,k
            elseif controlType=="FontSize" then local m,p,d=Instance.new("TextButton",holder),Instance.new("TextButton",holder),Instance.new("TextLabel",holder);m.Size=UDim2.new(0,25,0,25);m.Position=UDim2.new(0,160,0.5,-12.5);m.Text="-";m.Font=Config.Font_UI;m.TextSize=18;m.BackgroundColor3=Config.Color_Content_Inset;Instance.new("UICorner",m).CornerRadius=UDim.new(0,4);p.Size=UDim2.new(0,25,0,25);p.Position=UDim2.new(0,220,0.5,-12.5);p.Text="+";p.Font=Config.Font_UI;p.TextSize=18;p.BackgroundColor3=Config.Color_Content_Inset;Instance.new("UICorner",p).CornerRadius=UDim.new(0,4);d.Size=UDim2.new(0,30,1,0);d.Position=UDim2.new(0,188,0,0);d.BackgroundTransparency=1;d.Text=Config.Settings.LogFontSize;d.Font=Config.Font_Code;d.TextColor3=Config.Color_Text;return m,p,d
            elseif controlType=="Button" then local b=Instance.new("TextButton",holder);b.Size=UDim2.new(0,120,1,0);b.Position=UDim2.new(0,160,0,0);b.BackgroundColor3=Config.Color_CloseButton;b.Text=title;b.Font=Config.Font_UI;b.TextColor3=Color3.new(1,1,1);b.TextSize=14;Instance.new("UICorner",b).CornerRadius=UDim.new(0,4);return b end
        end
        local tsCheckbox,tsCheck=createSetting("Show Timestamps","Checkbox");tsCheck.Visible=Config.Settings.ShowTimestamps;tsCheckbox.MouseButton1Click:Connect(function()Config.Settings.ShowTimestamps=not Config.Settings.ShowTimestamps;tsCheck.Visible=Config.Settings.ShowTimestamps;updateDisplay()end)
        local fsMinus,fsPlus,fsDisplay=createSetting("Log Font Size","FontSize");fsMinus.MouseButton1Click:Connect(function()Config.Settings.LogFontSize=math.max(8,Config.Settings.LogFontSize-1);fsDisplay.Text=Config.Settings.LogFontSize;updateDisplay()end);fsPlus.MouseButton1Click:Connect(function()Config.Settings.LogFontSize=math.min(24,Config.Settings.LogFontSize+1);fsDisplay.Text=Config.Settings.LogFontSize;updateDisplay()end)
        local clearAllBtn=createSetting("Clear All Logs","Button");clearAllBtn.MouseButton1Click:Connect(function()MasterLog={};for k in pairs(LogCounters)do LogCounters[k]=0 end;updateDisplay()end)
    end
    
    local commandBar=Instance.new("TextBox");commandBar.Name="CommandBar";commandBar.Size=UDim2.new(1,0,0,Config.CommandBarHeight);commandBar.Position=UDim2.new(0,0,1,-Config.CommandBarHeight);commandBar.BackgroundColor3=Config.Color_Primary;commandBar.TextColor3=Config.Color_Text;commandBar.Font=Config.Font_Code;commandBar.TextSize=14
    commandBar.Text = "" -- [FIX] Set default text to empty to show placeholder
    commandBar.PlaceholderText="Execute Lua code here..."
    commandBar.PlaceholderColor3=Config.Color_Text_Secondary
    commandBar.ClearTextOnFocus=false;commandBar.Parent=mainFrame;Instance.new("UIPadding",commandBar).PaddingLeft=UDim.new(0,8)
    
    updateDisplay=function()
        if SelectedTab=="Settings"then return end
        local scrollFrame=contentFrames[SelectedTab]
        for _,v in ipairs(scrollFrame:GetChildren())do if v:IsA("TextBox")then v:Destroy()end end
        local searchTermLower=CurrentSearchTerm:lower()
        for _,entry in ipairs(MasterLog)do 
            if entry.Type==SelectedTab then 
                local textLower=entry.Text:lower()
                if searchTermLower==""or textLower:find(searchTermLower,1,true)then 
                    local prefix=Config.Settings.ShowTimestamps and entry.Timestamp.." "or""
                    local logEntry=Instance.new("TextBox")
                    logEntry.Text=prefix..entry.Text;logEntry.Selectable=true;logEntry.TextEditable=false;logEntry.ClearTextOnFocus=false
                    logEntry.BackgroundTransparency=1;logEntry.BorderSizePixel=0;logEntry.Font=Config.Font_Code
                    logEntry.TextSize=Config.Settings.LogFontSize;logEntry.TextColor3=entry.Color;logEntry.TextWrapped=true
                    logEntry.TextXAlignment=Enum.TextXAlignment.Left;logEntry.TextYAlignment=Enum.TextYAlignment.Top
                    local size=game:GetService("TextService"):GetTextSize(logEntry.Text,logEntry.TextSize,logEntry.Font,Vector2.new(scrollFrame.AbsoluteSize.X-20,math.huge))
                    logEntry.Size=UDim2.new(1,0,0,size.Y+2);logEntry.Parent=scrollFrame 
                end 
            end 
        end
        task.wait();scrollFrame.CanvasPosition=Vector2.new(0,scrollFrame.CanvasSize.Y.Offset)
        for name,btn in pairs(tabs)do 
            if name~="Settings"then 
                local count=LogCounters[name]
                btn.Text=count>0 and string.format("%s (%d)",name,count)or name 
            end 
        end 
    end
    
    local function selectTab(name)
        SelectedTab=name
        for tName,btn in pairs(tabs)do 
            local isSelected=(tName==name);local frame=contentFrames[tName];frame.Visible=isSelected
            if frame:IsA("ScrollingFrame")then contentArea:FindFirstChild(tName.."ActionBar").Visible=isSelected end
            btn.TextColor3=isSelected and Config.Color_Text or Config.Color_Text_Secondary 
        end
        tabIndicator:TweenSizeAndPosition(UDim2.new(0,tabs[name].AbsoluteSize.X,1,0),UDim2.new(0,tabs[name].AbsolutePosition.X-indicatorContainer.AbsolutePosition.X,0,0),"Out","Quad",0.15)
        tabIndicator.BackgroundColor3=Config.TabColors[name]
        if name~="Settings" and LogCounters[name] then LogCounters[name]=0 end
        updateDisplay()
    end
    for name,btn in pairs(tabs)do btn.MouseButton1Click:Connect(function()selectTab(name)end)end
    
    local function appendLog(logType,text)
        table.insert(MasterLog,{Type=logType,Text=text,Timestamp=os.date("[%H:%M:%S]"),Color=Config.TabColors[logType]})
        if logType~=SelectedTab and LogCounters[logType] then LogCounters[logType]=LogCounters[logType]+1 end
        updateDisplay()
    end
    
    searchBar.Changed:Connect(function(prop)if prop=="Text"then CurrentSearchTerm=searchBar.Text;updateDisplay()end end)
    
    commandBar.FocusLost:Connect(function(enterPressed)
        if enterPressed and commandBar.Text~=""then 
            local source=commandBar.Text;table.insert(CommandHistory,1,source);HistoryIndex=0;commandBar.Text=""
            appendLog("Output","> "..source)
            local func,err=loadstring(source)
            if func then 
                local results={pcall(func)};local success=table.remove(results,1)
                if success then 
                    local returnValues={};for i,v in ipairs(results)do table.insert(returnValues,tostring(v))end
                    if #returnValues>0 then appendLog("Information",table.concat(returnValues,", "))end 
                else 
                    appendLog("Error",tostring(results[1]))
                end 
            else 
                appendLog("Error",err)
            end 
        end 
    end)
    
    commandBar.InputBegan:Connect(function(input)
        if input.KeyCode==Enum.KeyCode.Up then 
            HistoryIndex=math.min(#CommandHistory,HistoryIndex+1)
            if HistoryIndex>0 then commandBar.Text=CommandHistory[HistoryIndex]end 
        elseif input.KeyCode==Enum.KeyCode.Down then 
            HistoryIndex=math.max(0,HistoryIndex-1)
            if HistoryIndex>0 then commandBar.Text=CommandHistory[HistoryIndex]else commandBar.Text=""end 
        end 
    end)
    
    local function hookFunction(tabName,originalFunc)
        return function(...)
            local args=table.pack(...);local strings={};for i=1,args.n do strings[i]=tostring(args[i])end
            appendLog(tabName,table.concat(strings,"\t"))
            if originalFunc then return originalFunc(...)end 
        end 
    end
    print=hookFunction("Output",print);warn=hookFunction("Warning",warn);error=hookFunction("Error",error)
    LogService.MessageOut:Connect(function(message,messageType)
        local tabName;if messageType==Enum.MessageType.MessageInfo then tabName="Information"elseif messageType==Enum.MessageType.MessageWarning then tabName="Warning"elseif messageType==Enum.MessageType.MessageError then tabName="Error"elseif messageType==Enum.MessageType.MessageOutput then tabName="Output"end
        if tabName then appendLog(tabName,message)end 
    end)
    UserInputService.InputBegan:Connect(function(input,gp)if not gp and input.KeyCode==Enum.KeyCode.F9 then mainFrame.Visible=not mainFrame.Visible end end)
    
    task.wait();selectTab("Output");print("Modern Dev Console loaded. Press F9 to toggle.")
end)

if not success then warn("[ModernDevConsole] Setup failed: " .. tostring(err)) end