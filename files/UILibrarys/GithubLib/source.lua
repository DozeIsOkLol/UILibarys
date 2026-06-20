--[[
GithubLib - UILibrary (source.lua)
A compact, executor-friendly Roblox UI library designed to be easy to load via executors (loadstring/httpget) or as a ModuleScript.
This file exposes a simple API to create windows, tabs, sections, and common controls: Button, Toggle, Slider, Dropdown, Textbox, and Notification.

Author: GitHubLib (generated)
License: MIT (feel free to adapt)
]]

local GithubLib = {}
GithubLib.__index = GithubLib

-- Utility functions
local function new(class, props)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    return inst
end

local function setProps(inst, props)
    for k, v in pairs(props) do inst[k] = v end
end

local function onClick(button, cb)
    button.MouseButton1Click:Connect(function() pcall(cb) end)
end

local function makeUICorner(inst, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0,6)
    corner.Parent = inst
    return corner
end

-- Simple theme
local Theme = {
    Background = Color3.fromRGB(17,17,17),
    Accent = Color3.fromRGB(30,144,255),
    Text = Color3.fromRGB(230,230,230),
    SubText = Color3.fromRGB(160,160,160),
}

-- Notifications
local function notify(text, duration)
    duration = duration or 4
    local sg = game:GetService("CoreGui")
    local notif = new("ScreenGui", {Name = "GithubLibNotification"})
    notif.ResetOnSpawn = false
    notif.Parent = sg

    local frame = new("Frame", {
        Size = UDim2.new(0,300,0,60),
        Position = UDim2.new(0.5,-150,0.1,0),
        BackgroundColor3 = Theme.Background,
        Parent = notif,
    })
    makeUICorner(frame, UDim.new(0,8))

    local label = new("TextLabel", {
        Size = UDim2.new(1,-16,1,-16),
        Position = UDim2.new(0,8,0,8),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextWrapped = true,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        Parent = frame,
    })

    spawn(function()
        wait(duration)
        pcall(function() notif:Destroy() end)
    end)
    return notif
end

-- Create main GUI
function GithubLib:Create(title)
    local self = setmetatable({}, GithubLib)
    self.Title = title or "GithubLib UI"
    self.Tabs = {}

    local sg = new("ScreenGui", {Name = "GithubLibUI", ResetOnSpawn = false})
    sg.Parent = game:GetService("CoreGui")

    local main = new("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(0,640,0,420),
        Position = UDim2.new(0.5,-320,0.5,-210),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Theme.Background,
        Parent = sg,
    })
    makeUICorner(main, UDim.new(0,10))

    local header = new("Frame", {
        Size = UDim2.new(1,0,0,44),
        BackgroundTransparency = 1,
        Parent = main,
    })
    local titleLbl = new("TextLabel", {
        Text = self.Title,
        Size = UDim2.new(0.6,0,1,0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0,14,0,0),
        Parent = header,
    })

    local tabsFrame = new("Frame", {
        Name = "Tabs",
        Size = UDim2.new(0,120,1,-44),
        Position = UDim2.new(0,0,0,44),
        BackgroundTransparency = 1,
        Parent = main,
    })

    local pagesHolder = new("Frame", {
        Name = "Pages",
        Size = UDim2.new(1,-120,1,-44),
        Position = UDim2.new(0,120,0,44),
        BackgroundTransparency = 1,
        Parent = main,
    })

    local tabsLayout = new("UIListLayout", {Parent = tabsFrame, Padding = UDim.new(0,8)})
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Methods
    function self:CreateTab(name)
        local tabbtn = new("TextButton", {
            Name = name .. "TabBtn",
            Text = name,
            Size = UDim2.new(1,-8,0,32),
            Position = UDim2.new(0,4,0,0),
            BackgroundColor3 = Color3.fromRGB(24,24,24),
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            Parent = tabsFrame,
        })
        makeUICorner(tabbtn, UDim.new(0,6))

        local page = new("Frame", {
            Name = name .. "Page",
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = pagesHolder,
        })

        local pageLayout = new("UIListLayout", {Parent = page})
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0,12)

        local function show()
            for _, p in pairs(pagesHolder:GetChildren()) do
                if p:IsA("Frame") and p ~= page then p.Visible = false end
            end
            page.Visible = true
            for _, b in pairs(tabsFrame:GetChildren()) do
                if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(24,24,24) end
            end
            tabbtn.BackgroundColor3 = Theme.Accent
        end

        tabbtn.MouseButton1Click:Connect(show)

        -- make first tab show by default
        if #self.Tabs == 0 then
            show()
        end

        local tab = {}
        function tab:CreateSection(title)
            local sec = new("Frame", {
                Name = title .. "Section",
                Size = UDim2.new(1,-8,0,120),
                BackgroundColor3 = Color3.fromRGB(22,22,22),
                Parent = page,
            })
            sec.LayoutOrder = #page:GetChildren()
            makeUICorner(sec, UDim.new(0,6))

            local secTitle = new("TextLabel", {
                Text = title,
                Size = UDim2.new(1,-12,0,22),
                Position = UDim2.new(0,6,0,6),
                BackgroundTransparency = 1,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sec,
            })

            local content = new("Frame", {
                Size = UDim2.new(1,-12,1,-36),
                Position = UDim2.new(0,6,0,30),
                BackgroundTransparency = 1,
                Parent = sec,
            })
            local contentLayout = new("UIListLayout", {Parent = content})
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            contentLayout.Padding = UDim.new(0,8)

            local sectionAPI = {}

            function sectionAPI:Button(text, callback)
                local btn = new("TextButton", {
                    Size = UDim2.new(1,0,0,34),
                    Text = text,
                    BackgroundColor3 = Color3.fromRGB(18,18,18),
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    Parent = content,
                })
                makeUICorner(btn, UDim.new(0,6))
                onClick(btn, callback or function() end)
                return btn
            end

            function sectionAPI:Toggle(text, enabled, callback)
                enabled = enabled or false
                local holder = new("Frame", {Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Parent=content})
                local lbl = new("TextLabel", {Text = text, BackgroundTransparency=1, TextColor3=Theme.Text, Font=Enum.Font.Gotham, TextSize=14, Position=UDim2.new(0,8,0,4), Size=UDim2.new(1,-56,1,0), Parent=holder})
                local toggle = new("TextButton", {Size=UDim2.new(0,36,0,20), Position=UDim2.new(1,-44,0,5), BackgroundColor3 = enabled and Theme.Accent or Color3.fromRGB(40,40,40), Parent=holder})
                makeUICorner(toggle, UDim.new(0,6))
                local state = enabled
                local function setState(s)
                    state = s
                    toggle.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(40,40,40)
                end
                onClick(toggle, function() setState(not state) pcall(callback, state) end)
                return {GetState = function() return state end, SetState = setState}
            end

            function sectionAPI:Slider(text, min, max, default, callback)
                min = min or 0; max = max or 100; default = default or min
                local holder = new("Frame", {Size=UDim2.new(1,0,0,54), BackgroundTransparency=1, Parent=content})
                local lbl = new("TextLabel", {Text = text .. " — " .. tostring(default), BackgroundTransparency=1, TextColor3=Theme.Text, Font=Enum.Font.Gotham, TextSize=14, Position=UDim2.new(0,8,0,2), Size=UDim2.new(1,-16,0,18), Parent=holder})
                local barBg = new("Frame", {Size=UDim2.new(1,-16,0,10), Position=UDim2.new(0,8,0,30), BackgroundColor3=Color3.fromRGB(38,38,38), Parent=holder})
                makeUICorner(barBg, UDim.new(0,6))
                local fill = new("Frame", {Size=UDim2.new( (default-min)/(max-min),0,1,0), BackgroundColor3=Theme.Accent, Parent=barBg})
                makeUICorner(fill, UDim.new(0,6))

                local dragging = false
                barBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                barBg.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                local function updateFromPos(x)
                    local localX = math.clamp(x - barBg.AbsolutePosition.X, 0, barBg.AbsoluteSize.X)
                    local ratio = localX / barBg.AbsoluteSize.X
                    local value = math.floor((min + (max-min) * ratio) * 100)/100
                    fill.Size = UDim2.new(ratio,0,1,0)
                    lbl.Text = text .. " — " .. tostring(value)
                    pcall(callback, value)
                    return value
                end
                game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateFromPos(input.Position.X)
                    end
                end)
                return {Set = function(v) local ratio = (v-min)/(max-min) fill.Size = UDim2.new(math.clamp(ratio,0,1),0,1,0) lbl.Text = text .. " — " .. tostring(v) end}
            end

            function sectionAPI:Dropdown(text, options, default, callback)
                options = options or {}
                default = default or options[1]
                local holder = new("Frame", {Size=UDim2.new(1,0,0,32), BackgroundTransparency=1, Parent=content})
                local lbl = new("TextLabel", {Text=text, BackgroundTransparency=1, TextColor3=Theme.Text, Font=Enum.Font.Gotham, TextSize=14, Position=UDim2.new(0,8,0,2), Size=UDim2.new(0.6,-8,1,0), Parent=holder})
                local selection = new("TextButton", {Text = tostring(default), Size=UDim2.new(0,160,0,28), Position=UDim2.new(1,-172,0,2), BackgroundColor3=Color3.fromRGB(28,28,28), Parent=holder})
                makeUICorner(selection, UDim.new(0,6))

                local dropFrame = new("Frame", {Size=UDim2.new(0,160,0,0), Position=UDim2.new(1,-172,0,34), BackgroundColor3=Color3.fromRGB(28,28,28), Parent=holder, ClipsDescendants=false})
                makeUICorner(dropFrame, UDim.new(0,6))
                local open = false
                local listLayout = new("UIListLayout", {Parent = dropFrame})
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder

                local function openDropdown()
                    if open then
                        dropFrame:TweenSize(UDim2.new(0,160,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
                    else
                        local height = math.min(#options*28, 200)
                        dropFrame:TweenSize(UDim2.new(0,160,0,height), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
                    end
                    open = not open
                end
                selection.MouseButton1Click:Connect(openDropdown)

                local function clearOptions()
                    for _, c in pairs(dropFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                end

                local function refresh()
                    clearOptions()
                    for i, opt in ipairs(options) do
                        local b = new("TextButton", {Text = tostring(opt), Size = UDim2.new(1,0,0,28), BackgroundColor3=Color3.fromRGB(24,24,24), Parent = dropFrame})
                        b.Font = Enum.Font.Gotham
                        b.TextSize = 13
                        makeUICorner(b, UDim.new(0,6))
                        b.MouseButton1Click:Connect(function()
                            selection.Text = tostring(opt)
                            pcall(callback, opt)
                            openDropdown()
                        end)
                    end
                end
                refresh()
                return {SetOptions = function(t) options = t refresh() end, Set = function(v) selection.Text = tostring(v) end}
            end

            function sectionAPI:Textbox(placeholder, callback)
                local box = new("TextBox", {Size = UDim2.new(1,0,0,28), Text = "", PlaceholderText = placeholder or "...", BackgroundColor3=Color3.fromRGB(28,28,28), TextColor3=Theme.Text, Font=Enum.Font.Gotham, TextSize=14, Parent=content})
                makeUICorner(box, UDim.new(0,6))
                box.FocusLost:Connect(function(enter)
                    if enter then pcall(callback, box.Text) end
                end)
                return box
            end

            return sectionAPI
        end

        table.insert(self.Tabs, tab)
        return tab
    end

    function self:Notify(text, duration)
        notify(text, duration)
    end

    function self:Destroy()
        pcall(function()
            local gui = game:GetService("CoreGui"):FindFirstChild("GithubLibUI")
            if gui then gui:Destroy() end
        end)
    end

    return self
end

return GithubLib
