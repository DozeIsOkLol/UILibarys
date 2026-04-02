--[[

    ███████╗██╗  ██╗██████╗ ██╗      ██████╗  ██████╗ ██████╗ 
    ██╔═══██╗╚██╗██╔╝██╔══██╗██║     ██╔═══██╗██╔═══██╗██╔══██╗
    ██║   ██║ ╚███╔╝ ██████╔╝██║     ██║   ██║██║   ██║██║  ██║
    ██║   ██║ ██╔██╗ ██╔══██╗██║     ██║   ██║██║   ██║██║  ██║
    ╚██████╔╝██╔╝ ██╗██████╔╝███████╗╚██████╔╝╚██████╔╝██████╔╝
     ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝ 

        OxBlood UI Library — v0.0.3 

]]

local OxBlood = {}
OxBlood.__index = OxBlood

--// Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// Prevent multiple instances
if CoreGui:FindFirstChild("OxBlood_UI") then
    CoreGui:FindFirstChild("OxBlood_UI"):Destroy()
end

--// Theme (STRICTLY PRESERVED + EXTENDABLE)
local Theme = {
    Accent = Color3.fromRGB(160, 20, 40),
    Background = Color3.fromRGB(18, 18, 18),
    DarkBackground = Color3.fromRGB(12, 12, 12),
    LightBackground = Color3.fromRGB(28, 28, 28),

    Text = Color3.fromRGB(235, 235, 235),
    SubText = Color3.fromRGB(180, 180, 180),

    Success = Color3.fromRGB(60, 180, 90),
    Error = Color3.fromRGB(200, 60, 60),
    Warning = Color3.fromRGB(255, 140, 0),
    Info = Color3.fromRGB(140, 20, 40),
}

function OxBlood:CreateTheme(overrides)
    for k,v in pairs(overrides) do
        if Theme[k] then
            Theme[k] = v
        end
    end
end

--// Utility
local function Tween(obj, time, props, style, dir)
    return TweenService:Create(
        obj,
        TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    )
end

local function Create(class, props)
    local inst = Instance.new(class)
    for i,v in pairs(props or {}) do
        inst[i] = v
    end
    return inst
end

--// MAIN LOAD FUNCTION
function OxBlood.Load(config)
    local self = setmetatable({}, OxBlood)

    --// ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "OxBlood_UI",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })

    --// MAIN WINDOW
    local Main = Create("Frame", {
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })

    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Main})

    --// TITLE BAR
    local Top = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Theme.DarkBackground,
        Parent = Main
    })

    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Top})

    local Title = Create("TextLabel", {
        Text = config.Name or "OxBlood",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Top
    })

    --// MINIMIZE
    local Minimize = Create("TextButton", {
        Text = "▼",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.SubText,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(1, -30, 0, 0),
        Parent = Top
    })

    --// DRAGGING
    local dragging, dragInput, dragStart, startPos

    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    Top.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)

    --// SIDEBAR
    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 150, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundColor3 = Theme.DarkBackground,
        Parent = Main
    })

    --// CONTENT
    local Content = Create("Frame", {
        Size = UDim2.new(1, -150, 1, -35),
        Position = UDim2.new(0, 150, 0, 35),
        BackgroundTransparency = 1,
        Parent = Main
    })

    --// MINIMIZE LOGIC
    local minimized = false

    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized

        Tween(Main, 0.3, {
            Size = minimized and UDim2.new(0, 600, 0, 35) or UDim2.new(0, 600, 0, 400)
        }):Play()
    end)

    ----------------------------------------------------------------
    -- 🔥 PREMIUM NOTIFICATION SYSTEM (v0.0.3)
    ----------------------------------------------------------------

    local NotifGui = Create("ScreenGui", {
        Name = "OxBlood_Notifications",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })

    local Holder = Create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 10),
        Size = UDim2.new(0, 300, 1, -20),
        BackgroundTransparency = 1,
        Parent = NotifGui
    })

    local Layout = Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Parent = Holder
    })

    local function GetColor(type)
        return type == "Success" and Theme.Success
            or type == "Error" and Theme.Error
            or type == "Warning" and Theme.Warning
            or Theme.Accent
    end

    function self:Notify(data)
        local TitleText = data.Title or "Notification"
        local Desc = data.Description or ""
        local Duration = data.Duration or 4
        local Type = data.Type or "Info"

        local Card = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Theme.LightBackground,
            Parent = Holder,
            ClipsDescendants = true
        })

        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Card})

        -- Glow
        local Stroke = Create("UIStroke", {
            Color = GetColor(Type),
            Thickness = 1.2,
            Transparency = 0.3,
            Parent = Card
        })

        local Padding = Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            Parent = Card
        })

        local TitleLabel = Create("TextLabel", {
            Text = TitleText,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Card
        })

        local DescLabel = Create("TextLabel", {
            Text = Desc,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Theme.SubText,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 18),
            Size = UDim2.new(1, 0, 0, 30),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Card
        })

        local Bar = Create("Frame", {
            Size = UDim2.new(0, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = GetColor(Type),
            BorderSizePixel = 0,
            Parent = Card
        })

        -- OPEN ANIMATION
        Tween(Card, 0.4, {Size = UDim2.new(1, 0, 0, 60)}):Play()

        Tween(Bar, Duration, {Size = UDim2.new(1, 0, 0, 2)}):Play()

        -- CLICK TO DISMISS
        Card.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                Duration = 0
            end
        end)

        -- CLOSE
        task.delay(Duration, function()
            Tween(Card, 0.3, {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()

            task.wait(0.3)
            Card:Destroy()
        end)
    end

    ----------------------------------------------------------------
----------------------------------------------------------------
-- 📑 PAGE SYSTEM
----------------------------------------------------------------

local Pages = {}
local CurrentPage = nil

function self:AddPage(name)
    local Page = {}

    local Button = Create("TextButton", {
        Text = name,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Theme.SubText,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = Sidebar
    })

    local Container = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 3,
        BackgroundTransparency = 1,
        Visible = false,
        Parent = Content
    })

    local Layout = Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        Parent = Container
    })

    local function UpdateCanvas()
        Container.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
    end

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

    Button.MouseButton1Click:Connect(function()
        for _,p in pairs(Pages) do
            p.Container.Visible = false
        end
        Container.Visible = true
        CurrentPage = Page
    end)

    Page.Container = Container

    ----------------------------------------------------------------
    -- 📦 ELEMENTS
    ----------------------------------------------------------------

    function Page:AddSection(text)
        local Section = Create("TextLabel", {
            Text = text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = Container
        })
    end

    --------------------------------------------------
    -- 🔘 BUTTON
    --------------------------------------------------

    function Page:AddButton(data)
        local Btn = Create("TextButton", {
            Text = data.Text or "Button",
            Font = Enum.Font.Gotham,
            TextSize = 13,
            BackgroundColor3 = Theme.LightBackground,
            TextColor3 = Theme.Text,
            Size = UDim2.new(1, 0, 0, 30),
            Parent = Container
        })

        Create("UICorner", {CornerRadius = UDim.new(0,6), Parent = Btn})

        Btn.MouseButton1Click:Connect(function()
            if data.Callback then
                data.Callback()
            end
        end)
    end

    --------------------------------------------------
    -- 🔥 TOGGLE (ANIMATED)
    --------------------------------------------------

    function Page:AddToggle(data)
        local Value = data.Default or false

        local Frame = Create("Frame", {
            Size = UDim2.new(1,0,0,30),
            BackgroundColor3 = Theme.LightBackground,
            Parent = Container
        })

        Create("UICorner", {CornerRadius = UDim.new(0,6), Parent = Frame})

        local Label = Create("TextLabel", {
            Text = data.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0,10,0,0),
            Size = UDim2.new(1,-50,1,0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Frame
        })

        local Toggle = Create("Frame", {
            Size = UDim2.new(0,36,0,18),
            Position = UDim2.new(1,-45,0.5,-9),
            BackgroundColor3 = Theme.DarkBackground,
            Parent = Frame
        })

        Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = Toggle})

        local Knob = Create("Frame", {
            Size = UDim2.new(0,14,0,14),
            Position = UDim2.new(0,2,0.5,-7),
            BackgroundColor3 = Theme.SubText,
            Parent = Toggle
        })

        Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = Knob})

        local function Set(state)
            Value = state

            Tween(Knob, 0.25, {
                Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),
                BackgroundColor3 = state and Theme.Accent or Theme.SubText
            }):Play()

            if data.Callback then
                data.Callback(Value)
            end
        end

        Frame.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                Set(not Value)
            end
        end)

        Set(Value)
    end

    --------------------------------------------------
    -- 🎚 SLIDER (SMOOTH + STEP)
    --------------------------------------------------

    function Page:AddSlider(data)
        local Min, Max = data.Min or 0, data.Max or 100
        local Value = data.Default or Min
        local Step = data.Step or 1

        local Frame = Create("Frame", {
            Size = UDim2.new(1,0,0,40),
            BackgroundColor3 = Theme.LightBackground,
            Parent = Container
        })

        Create("UICorner", {CornerRadius = UDim.new(0,6), Parent = Frame})

        local Label = Create("TextLabel", {
            Text = data.Text .. ": " .. Value,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0,10,0,0),
            Size = UDim2.new(1,-20,0,18),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Frame
        })

        local Bar = Create("Frame", {
            Size = UDim2.new(1,-20,0,6),
            Position = UDim2.new(0,10,1,-12),
            BackgroundColor3 = Theme.DarkBackground,
            Parent = Frame
        })

        Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = Bar})

        local Fill = Create("Frame", {
            Size = UDim2.new(0,0,1,0),
            BackgroundColor3 = Theme.Accent,
            Parent = Bar
        })

        Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = Fill})

        local dragging = false

        local function Update(x)
            local percent = math.clamp((x - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1)
            local raw = Min + (Max-Min)*percent
            Value = math.floor(raw/Step+0.5)*Step

            Fill.Size = UDim2.new(percent,0,1,0)
            Label.Text = data.Text .. ": " .. Value

            if data.Callback then
                data.Callback(Value)
            end
        end

        Bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                Update(i.Position.X)
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                Update(i.Position.X)
            end
        end)

        Update(Bar.AbsolutePosition.X)
    end

    --------------------------------------------------
    -- 🔽 DROPDOWN (SEARCH + MULTI)
    --------------------------------------------------

    function Page:AddDropdown(data)
        local Options = data.Options or {}
        local Multi = data.Multi or false
        local Selected = {}

        local Frame = Create("Frame", {
            Size = UDim2.new(1,0,0,35),
            BackgroundColor3 = Theme.LightBackground,
            Parent = Container
        })

        Create("UICorner", {CornerRadius = UDim.new(0,6), Parent = Frame})

        local Box = Create("TextBox", {
            PlaceholderText = data.Text or "Select...",
            Text = "",
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,-10,1,0),
            Position = UDim2.new(0,10,0,0),
            Parent = Frame
        })

        local Drop = Create("Frame", {
            Size = UDim2.new(1,0,0,0),
            BackgroundColor3 = Theme.DarkBackground,
            Visible = false,
            Parent = Frame
        })

        local Layout = Create("UIListLayout", {Parent = Drop})

        local function Refresh(filter)
            Drop:ClearAllChildren()
            Layout.Parent = Drop

            for _,opt in pairs(Options) do
                if not filter or string.find(string.lower(opt), string.lower(filter)) then
                    local Btn = Create("TextButton", {
                        Text = opt,
                        Font = Enum.Font.Gotham,
                        TextSize = 13,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1,0,0,25),
                        Parent = Drop
                    })

                    Btn.MouseButton1Click:Connect(function()
                        if Multi then
                            Selected[opt] = not Selected[opt]
                        else
                            Selected = {[opt]=true}
                            Drop.Visible = false
                        end

                        if data.Callback then
                            data.Callback(Selected)
                        end
                    end)
                end
            end
        end

        Box.Focused:Connect(function()
            Drop.Visible = true
            Tween(Drop,0.25,{Size = UDim2.new(1,0,0,120)}):Play()
        end)

        Box:GetPropertyChangedSignal("Text"):Connect(function()
            Refresh(Box.Text)
        end)

        Refresh()
    end

    --------------------------------------------------
    -- ⌨ KEYBIND
    --------------------------------------------------

    function Page:AddKeybind(data)
        local Key = data.Default or Enum.KeyCode.F

        local Btn = Create("TextButton", {
            Text = data.Text .. " ["..Key.Name.."]",
            Font = Enum.Font.Gotham,
            TextSize = 13,
            BackgroundColor3 = Theme.LightBackground,
            TextColor3 = Theme.Text,
            Size = UDim2.new(1,0,0,30),
            Parent = Container
        })

        Create("UICorner", {CornerRadius = UDim.new(0,6), Parent = Btn})

        Btn.MouseButton1Click:Connect(function()
            Btn.Text = "Press any key..."

            local conn
            conn = UserInputService.InputBegan:Connect(function(i)
                if i.KeyCode ~= Enum.KeyCode.Unknown then
                    Key = i.KeyCode
                    Btn.Text = data.Text.." ["..Key.Name.."]"
                    conn:Disconnect()
                end
            end)
        end)

        UserInputService.InputBegan:Connect(function(i)
            if i.KeyCode == Key then
                if data.Callback then
                    data.Callback()
                end
            end
        end)
    end

    --------------------------------------------------
    -- 📝 INPUT (IMPROVED)
    --------------------------------------------------

    function Page:AddInput(data)
        local Frame = Create("Frame", {
            Size = UDim2.new(1,0,0,30),
            BackgroundColor3 = Theme.LightBackground,
            Parent = Container
        })

        Create("UICorner", {CornerRadius = UDim.new(0,6), Parent = Frame})

        local Box = Create("TextBox", {
            PlaceholderText = data.Placeholder or "Enter...",
            Text = "",
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,-30,1,0),
            Position = UDim2.new(0,10,0,0),
            Parent = Frame
        })

        local Clear = Create("TextButton", {
            Text = "X",
            Size = UDim2.new(0,20,1,0),
            Position = UDim2.new(1,-20,0,0),
            BackgroundTransparency = 1,
            Parent = Frame
        })

        Clear.MouseButton1Click:Connect(function()
            Box.Text = ""
        end)

        Box.FocusLost:Connect(function()
            if data.Callback then
                data.Callback(Box.Text)
            end
        end)
    end

    --------------------------------------------------
    -- ➕ NEW ELEMENTS
    --------------------------------------------------

    function Page:AddSeparator(text)
        local Sep = Create("TextLabel", {
            Text = text or "────────",
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Theme.SubText,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,15),
            Parent = Container
        })
    end

    function Page:AddParagraph(text)
        local P = Create("TextLabel", {
            Text = text,
            RichText = true,
            TextWrapped = true,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,50),
            Parent = Container
        })
    end

    function Page:AddProgress(data)
        local Frame = Create("Frame", {
            Size = UDim2.new(1,0,0,20),
            BackgroundColor3 = Theme.DarkBackground,
            Parent = Container
        })

        local Fill = Create("Frame", {
            Size = UDim2.new(data.Value or 0,0,1,0),
            BackgroundColor3 = Theme.Accent,
            Parent = Frame
        })

        return {
            Set = function(v)
                Tween(Fill,0.3,{Size = UDim2.new(v,0,1,0)}):Play()
            end
        }
    end

    function Page:AddImage(id)
        Create("ImageLabel", {
            Image = id,
            Size = UDim2.new(1,0,0,100),
            BackgroundTransparency = 1,
            Parent = Container
        })
    end

    --------------------------------------------------

    table.insert(Pages, Page)

    if not CurrentPage then
        Container.Visible = true
        CurrentPage = Page
    end

    return Page
end

----------------------------------------------------------------
-- 🧠 FLAGS SYSTEM
----------------------------------------------------------------

local Flags = {}

function self:GetFlag(name)
    return Flags[name]
end

local function SetFlag(name, value)
    Flags[name] = value
end

----------------------------------------------------------------
-- 💾 CONFIG SYSTEM
----------------------------------------------------------------

local HttpService = game:GetService("HttpService")

local function SafeCall(func)
    local ok, res = pcall(func)
    return ok and res
end

function self:SaveConfig(name)
    if not writefile then return end

    local data = HttpService:JSONEncode(Flags)

    SafeCall(function()
        writefile("OxBlood_"..name..".json", data)
    end)

    self:Notify({
        Title = "Config Saved",
        Description = name,
        Type = "Success"
    })
end

function self:LoadConfig(name)
    if not readfile then return end

    local raw = SafeCall(function()
        return readfile("OxBlood_"..name..".json")
    end)

    if raw then
        local decoded = HttpService:JSONDecode(raw)

        for k,v in pairs(decoded) do
            Flags[k] = v
        end

        self:Notify({
            Title = "Config Loaded",
            Description = name,
            Type = "Info"
        })
    end
end

----------------------------------------------------------------
-- 🔍 GLOBAL SEARCH SYSTEM
----------------------------------------------------------------

function self:CreateSearchBar()
    local Search = Create("TextBox", {
        PlaceholderText = "Search...",
        Size = UDim2.new(1, -10, 0, 30),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = Theme.LightBackground,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        Parent = Content
    })

    Create("UICorner", {CornerRadius = UDim.new(0,6), Parent = Search})

    Search:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(Search.Text)

        for _,page in pairs(Pages) do
            for _,obj in pairs(page.Container:GetChildren()) do
                if obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    local text = (obj.Text or ""):lower()
                    obj.Visible = query == "" or string.find(text, query)
                end
            end
        end
    end)
end

----------------------------------------------------------------
-- 💬 TOOLTIP SYSTEM
----------------------------------------------------------------

function self:CreateTooltip(text, parent)
    local Tip = Create("TextLabel", {
        Text = text,
        BackgroundColor3 = Theme.DarkBackground,
        TextColor3 = Theme.SubText,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Visible = false,
        Parent = ScreenGui
    })

    Create("UICorner", {CornerRadius = UDim.new(0,6), Parent = Tip})

    parent.MouseEnter:Connect(function()
        Tip.Visible = true
        Tip.Position = UDim2.new(0, parent.AbsolutePosition.X, 0, parent.AbsolutePosition.Y - 25)
    end)

    parent.MouseLeave:Connect(function()
        Tip.Visible = false
    end)
end

----------------------------------------------------------------
-- 📱 MOBILE / TOUCH IMPROVEMENTS
----------------------------------------------------------------

UserInputService.TouchEnabled = true

-- Better dragging for touch
Top.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        Main.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
    end
end)

----------------------------------------------------------------
-- 👁 VISIBILITY CONTROL
----------------------------------------------------------------

function self:Hide()
    ScreenGui.Enabled = false
end

function self:Show()
    ScreenGui.Enabled = true
end

function self:Destroy()
    ScreenGui:Destroy()
    NotifGui:Destroy()
end

----------------------------------------------------------------
-- 🧹 CLEANUP SYSTEM
----------------------------------------------------------------

local Connections = {}

function self:BindConnection(conn)
    table.insert(Connections, conn)
end

function self:Cleanup()
    for _,c in pairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
end

----------------------------------------------------------------
-- 🏁 FINAL RETURN
----------------------------------------------------------------

    return self
end

return OxBlood
