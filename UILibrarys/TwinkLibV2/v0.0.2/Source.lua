--[[
    ████████╗██╗    ██╗██╗███╗   ██╗██╗  ██╗    ██╗   ██╗██╗
       ██╔══╝██║    ██║██║████╗  ██║██║ ██╔╝    ██║   ██║██║
       ██║   ██║ █╗ ██║██║██╔██╗ ██║█████╔╝     ██║   ██║██║
       ██║   ██║███╗██║██║██║╚██╗██║██╔═██╗     ██║   ██║██║
       ██║   ╚███╔███╔╝██║██║ ╚████║██║  ██╗    ╚██████╔╝██║
       ╚═╝    ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝    ╚═════╝ ╚═╝

    Layout v3  
      - 3-Section Title Bar  (Hub Name | Game Name | Version + arrow)
      - Tabs fill the full left sidebar
      - Player avatar + "Welcome, Name!" pinned to the BOTTOM of the sidebar

    Usage:
        local UI = UILibrary.Load("Twink UI", "Adopt Me", "v2.0")
        local Page = UI.AddPage("Home")
        Page.AddButton("Click Me", function() end)
--]]

local Player        = game.Players.LocalPlayer
local Mouse         = Player:GetMouse()

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local CoreGuiService    = game:GetService("CoreGui")
local RunService        = game:GetService("RunService")
local TextService       = game:GetService("TextService")
local PlayersService    = game:GetService("Players")

local TweenTime = 0.1
local Level     = 1

local GlobalTweenInfo  = TweenInfo.new(TweenTime)
local AlteredTweenInfo = TweenInfo.new(TweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local DropShadowID           = "rbxassetid://297774371"
local DropShadowTransparency = 0.3
local IconLibraryID          = "rbxassetid://3926305904"
local IconLibraryID2         = "rbxassetid://3926307971"
local MainFont               = Enum.Font.Gotham

-- ================================================================
--  Constructors
-- ================================================================
local function GetXY(GuiObject)
    local X, Y = Mouse.X - GuiObject.AbsolutePosition.X, Mouse.Y - GuiObject.AbsolutePosition.Y
    local MaxX, MaxY = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
    X, Y = math.clamp(X,0,MaxX), math.clamp(Y,0,MaxY)
    return X, Y, X/MaxX, Y/MaxY
end

local function TitleIcon(ButtonOrNot)
    local i = Instance.new(ButtonOrNot and "ImageButton" or "ImageLabel")
    i.Name="TitleIcon"; i.BackgroundTransparency=1; i.Image=IconLibraryID
    i.ImageRectOffset=Vector2.new(524,764); i.ImageRectSize=Vector2.new(36,36)
    i.Size=UDim2.new(0,14,0,14); i.Position=UDim2.new(1,-17,0.5,-7)
    i.Rotation=180; i.ZIndex=Level; return i
end

local function TickIcon(ButtonOrNot)
    local i = Instance.new(ButtonOrNot and "ImageButton" or "ImageLabel")
    i.Name="TickIcon"; i.BackgroundTransparency=1; i.Image="rbxassetid://3926305904"
    i.ImageRectOffset=Vector2.new(312,4); i.ImageRectSize=Vector2.new(24,24)
    i.Size=UDim2.new(1,-6,1,-6); i.Position=UDim2.new(0,3,0,3); i.ZIndex=Level; return i
end

local function DropdownIcon(ButtonOrNot)
    local i = Instance.new(ButtonOrNot and "ImageButton" or "ImageLabel")
    i.Name="DropdownIcon"; i.BackgroundTransparency=1; i.Image=IconLibraryID2
    i.ImageRectOffset=Vector2.new(324,364); i.ImageRectSize=Vector2.new(36,36)
    i.Size=UDim2.new(0,16,0,16); i.Position=UDim2.new(1,-18,0,2); i.ZIndex=Level; return i
end

local function SearchIcon()
    local i = Instance.new("ImageLabel")
    i.Name="SearchIcon"; i.BackgroundTransparency=1; i.Image=IconLibraryID
    i.ImageRectOffset=Vector2.new(964,324); i.ImageRectSize=Vector2.new(36,36)
    i.Size=UDim2.new(0,16,0,16); i.Position=UDim2.new(0,2,0,2); i.ZIndex=Level; return i
end

local function RoundBox(r, btn)
    local i = Instance.new(btn and "ImageButton" or "ImageLabel")
    i.BackgroundTransparency=1; i.Image="rbxassetid://3570695787"
    i.SliceCenter=Rect.new(100,100,100,100)
    i.SliceScale=math.clamp((r or 5)*0.01,0.01,1)
    i.ScaleType=Enum.ScaleType.Slice; i.ZIndex=Level; return i
end

local function DropShadow()
    local i = Instance.new("ImageLabel")
    i.Name="DropShadow"; i.BackgroundTransparency=1; i.Image=DropShadowID
    i.ImageTransparency=DropShadowTransparency; i.Size=UDim2.new(1,0,1,0); i.ZIndex=Level; return i
end

local function Frame()
    local i = Instance.new("Frame")
    i.BorderSizePixel=0; i.ZIndex=Level; return i
end

local function ScrollingFrame()
    local i = Instance.new("ScrollingFrame")
    i.BackgroundTransparency=1; i.BorderSizePixel=0; i.ScrollBarThickness=0; i.ZIndex=Level; return i
end

local function TextButton(Text, Size)
    local i = Instance.new("TextButton")
    i.Text=Text; i.AutoButtonColor=false; i.Font=MainFont
    i.TextColor3=Color3.fromRGB(255,255,255); i.BackgroundTransparency=1
    i.TextSize=Size or 12; i.Size=UDim2.new(1,0,1,0); i.ZIndex=Level; return i
end

local function TextBox(Text, Size)
    local i = Instance.new("TextBox")
    i.Text=Text; i.Font=MainFont; i.TextColor3=Color3.fromRGB(255,255,255)
    i.BackgroundTransparency=1; i.TextSize=Size or 12; i.Size=UDim2.new(1,0,1,0); i.ZIndex=Level; return i
end

local function TextLabel(Text, Size)
    local i = Instance.new("TextLabel")
    i.Text=Text; i.Font=MainFont; i.TextColor3=Color3.fromRGB(255,255,255)
    i.BackgroundTransparency=1; i.TextSize=Size or 12; i.Size=UDim2.new(1,0,1,0); i.ZIndex=Level; return i
end

local function Tween(obj, props)
    local t = TweenService:Create(obj, GlobalTweenInfo, props); t:Play(); return t
end

-- ================================================================
--  UILibrary
-- ================================================================
local UILibrary = {}

function UILibrary.Load(HubName, GameName, Version)
    HubName  = HubName  or "Twink UI"
    GameName = GameName or "Unknown Game"
    Version  = Version  or "v1.0"

    local TargetedParent = RunService:IsStudio()
        and Player:WaitForChild("PlayerGui") or CoreGuiService

    local old = TargetedParent:FindFirstChild(HubName)
    if old then old:Destroy() end

    -- Root
    local NewInstance = Instance.new("ScreenGui")
    NewInstance.Name = HubName; NewInstance.Parent = TargetedParent

    -- Outer container
    local ContainerFrame = Frame()
    ContainerFrame.Name="ContainerFrame"; ContainerFrame.Size=UDim2.new(0,500,0,300)
    ContainerFrame.Position=UDim2.new(0.5,-250,0.5,-150); ContainerFrame.BackgroundTransparency=1
    ContainerFrame.Parent=NewInstance

    local ContainerShadow = DropShadow()
    ContainerShadow.Name="Shadow"; ContainerShadow.Parent=ContainerFrame

    Level += 1

    local MainFrame = RoundBox(5)
    MainFrame.ClipsDescendants=true; MainFrame.Name="MainFrame"
    MainFrame.Size=UDim2.new(1,-50,1,-30); MainFrame.Position=UDim2.new(0,25,0,15)
    MainFrame.ImageColor3=Color3.fromRGB(30,30,30); MainFrame.Parent=ContainerFrame

    -- ============================================================
    --  TITLE BAR  ─  3 sections  (HubName | GameName | Version▼)
    -- ============================================================
    local TitleBar = RoundBox(5)
    TitleBar.Name="TitleBar"; TitleBar.ImageColor3=Color3.fromRGB(40,40,40)
    TitleBar.Size=UDim2.new(1,-10,0,24); TitleBar.Position=UDim2.new(0,5,0,5)
    TitleBar.Parent=MainFrame

    Level += 1

    -- Left — Hub Name
    local HubLabel = TextLabel(HubName, 12)
    HubLabel.Font=Enum.Font.GothamBold; HubLabel.TextXAlignment=Enum.TextXAlignment.Left
    HubLabel.Size=UDim2.new(0.33,0,1,0); HubLabel.Position=UDim2.new(0,8,0,0)
    HubLabel.ZIndex=Level; HubLabel.Parent=TitleBar

    -- Divider 1
    local D1 = Frame()
    D1.BackgroundColor3=Color3.fromRGB(70,70,70); D1.Size=UDim2.new(0,1,0.45,0)
    D1.Position=UDim2.new(0.35,0,0.275,0); D1.ZIndex=Level; D1.Parent=TitleBar

    -- Centre — Game Name
    local GameLabel = TextLabel(GameName, 11)
    GameLabel.TextXAlignment=Enum.TextXAlignment.Center; GameLabel.TextTransparency=0.25
    GameLabel.Size=UDim2.new(0.3,0,1,0); GameLabel.Position=UDim2.new(0.35,4,0,0)
    GameLabel.ZIndex=Level; GameLabel.Parent=TitleBar

    -- Divider 2
    local D2 = Frame()
    D2.BackgroundColor3=Color3.fromRGB(70,70,70); D2.Size=UDim2.new(0,1,0.45,0)
    D2.Position=UDim2.new(0.65,4,0.275,0); D2.ZIndex=Level; D2.Parent=TitleBar

    -- Right — Version
    local VersionLabel = TextLabel(Version, 10)
    VersionLabel.TextXAlignment=Enum.TextXAlignment.Right; VersionLabel.TextTransparency=0.4
    VersionLabel.Size=UDim2.new(0.28,-20,1,0); VersionLabel.Position=UDim2.new(0.67,6,0,0)
    VersionLabel.ZIndex=Level; VersionLabel.Parent=TitleBar

    -- Minimise arrow
    local MinimiseToggle = true
    local MinimiseButton = TitleIcon(true)
    MinimiseButton.Name="Minimise"; MinimiseButton.Parent=TitleBar

    MinimiseButton.MouseButton1Down:Connect(function()
        MinimiseToggle = not MinimiseToggle
        if not MinimiseToggle then
            Tween(MainFrame,{Size=UDim2.new(1,-50,0,30)})
            Tween(MinimiseButton,{Rotation=0})
            Tween(ContainerShadow,{ImageTransparency=1})
        else
            Tween(MainFrame,{Size=UDim2.new(1,-50,1,-30)})
            Tween(MinimiseButton,{Rotation=180})
            Tween(ContainerShadow,{ImageTransparency=DropShadowTransparency})
        end
    end)

    -- Drag zone
    local TitleDrag = TextButton("",14)
    TitleDrag.Name="TitleDrag"; TitleDrag.Size=UDim2.new(1,-20,1,0); TitleDrag.ZIndex=Level
    TitleDrag.Parent=TitleBar

    TitleDrag.MouseButton1Down:Connect(function()
        local lx,ly = Mouse.X, Mouse.Y
        local mv, kl
        mv = Mouse.Move:Connect(function()
            local nx,ny = Mouse.X,Mouse.Y
            ContainerFrame.Position += UDim2.new(0,nx-lx,0,ny-ly)
            lx,ly = nx,ny
        end)
        kl = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                mv:Disconnect(); kl:Disconnect()
            end
        end)
    end)

    Level += 1

    -- ============================================================
    --  LAYOUT MATH
    --  MainFrame inner height = 270px (300 - 30 shadow padding)
    --  TitleBar     : y=5,  h=24  → bottom y=29
    --  Gap          : 4px         → content starts y=33
    --  UserInfo     : h=46, sits at y=219  (270-5-46)
    --  MenuBar      : y=33, h=181 (219-33-5 gap)
    --  DisplayFrame : y=33, h=232 (full right column)
    -- ============================================================

    -- Tab sidebar
    local MenuBar = ScrollingFrame()
    MenuBar.Name="MenuBar"; MenuBar.BackgroundTransparency=0.7
    MenuBar.BackgroundColor3=Color3.fromRGB(20,20,20)
    MenuBar.Size=UDim2.new(0,100,0,181); MenuBar.Position=UDim2.new(0,5,0,33)
    MenuBar.CanvasSize=UDim2.new(0,0,0,0); MenuBar.Parent=MainFrame

    -- Content area
    local DisplayFrame = RoundBox(5)
    DisplayFrame.Name="Display"; DisplayFrame.ImageColor3=Color3.fromRGB(20,20,20)
    DisplayFrame.Size=UDim2.new(1,-115,0,232); DisplayFrame.Position=UDim2.new(0,110,0,33)
    DisplayFrame.Parent=MainFrame

    -- ============================================================
    --  PLAYER INFO  ─  bottom of sidebar  (WetWipes layout)
    --  Small avatar circle on left, "Welcome," + "Name!" stacked right
    -- ============================================================
    local UserInfoPanel = RoundBox(5)
    UserInfoPanel.Name="UserInfo"; UserInfoPanel.ImageColor3=Color3.fromRGB(35,35,35)
    UserInfoPanel.Size=UDim2.new(0,100,0,46); UserInfoPanel.Position=UDim2.new(0,5,0,219)
    UserInfoPanel.ClipsDescendants=true; UserInfoPanel.Parent=MainFrame

    -- Top accent
    local Accent = Frame()
    Accent.BackgroundColor3=Color3.fromRGB(85,65,155); Accent.BackgroundTransparency=0.55
    Accent.Size=UDim2.new(1,0,0,2); Accent.ZIndex=Level; Accent.Parent=UserInfoPanel

    -- Avatar circle
    local AvatarHolder = Frame()
    AvatarHolder.Name="AvatarHolder"; AvatarHolder.BackgroundColor3=Color3.fromRGB(50,50,50)
    AvatarHolder.Size=UDim2.new(0,30,0,30); AvatarHolder.Position=UDim2.new(0,7,0.5,-15)
    AvatarHolder.ZIndex=Level; AvatarHolder.Parent=UserInfoPanel
    Instance.new("UICorner",AvatarHolder).CornerRadius=UDim.new(1,0)

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name="AvatarImage"; AvatarImage.BackgroundTransparency=1
    AvatarImage.Size=UDim2.new(1,0,1,0); AvatarImage.ZIndex=Level+1; AvatarImage.Parent=AvatarHolder
    Instance.new("UICorner",AvatarImage).CornerRadius=UDim.new(1,0)

    -- Status dot
    local Dot = Frame()
    Dot.BackgroundColor3=Color3.fromRGB(0,200,90); Dot.Size=UDim2.new(0,7,0,7)
    Dot.Position=UDim2.new(1,-7,1,-7); Dot.ZIndex=Level+2; Dot.Parent=AvatarHolder
    Instance.new("UICorner",Dot).CornerRadius=UDim.new(1,0)

    -- "Welcome," text
    local WelcomeLine = TextLabel("Welcome,", 9)
    WelcomeLine.TextXAlignment=Enum.TextXAlignment.Left; WelcomeLine.TextTransparency=0.4
    WelcomeLine.TextTruncate=Enum.TextTruncate.AtEnd
    WelcomeLine.Size=UDim2.new(1,-44,0,12); WelcomeLine.Position=UDim2.new(0,42,0,9)
    WelcomeLine.ZIndex=Level; WelcomeLine.Parent=UserInfoPanel

    -- "DisplayName!" text  (bold)
    local NameLine = TextLabel(Player.DisplayName.."!", 11)
    NameLine.Font=Enum.Font.GothamBold; NameLine.TextXAlignment=Enum.TextXAlignment.Left
    NameLine.TextTruncate=Enum.TextTruncate.AtEnd
    NameLine.Size=UDim2.new(1,-44,0,13); NameLine.Position=UDim2.new(0,42,0,23)
    NameLine.ZIndex=Level; NameLine.Parent=UserInfoPanel

    -- Async headshot fetch
    task.spawn(function()
        local ok, thumb = pcall(function()
            return PlayersService:GetUserThumbnailAsync(
                Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        if ok and thumb then AvatarImage.Image = thumb end
    end)

    -- ============================================================
    --  TAB / PAGE SYSTEM
    -- ============================================================
    Level += 1

    local MenuList = Instance.new("UIListLayout")
    MenuList.SortOrder=Enum.SortOrder.LayoutOrder; MenuList.Padding=UDim.new(0,5)
    MenuList.Parent=MenuBar

    MenuList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        MenuBar.CanvasSize = UDim2.new(0,0,0,MenuList.AbsoluteContentSize.Y+5)
    end)

    local TabCount   = 0
    local TabLibrary = {}

    function TabLibrary.AddPage(PageTitle, SearchBarIncluded)
        SearchBarIncluded = (SearchBarIncluded==nil) and true or SearchBarIncluded

        local PageContainer = RoundBox(5)
        PageContainer.Name=PageTitle; PageContainer.Size=UDim2.new(1,0,0,20)
        PageContainer.LayoutOrder=TabCount
        PageContainer.ImageColor3=(TabCount==0) and Color3.fromRGB(50,50,50) or Color3.fromRGB(40,40,40)
        PageContainer.Parent=MenuBar

        local PageButton = TextButton(PageTitle,12)
        PageButton.Name=PageTitle.."Button"
        PageButton.TextTransparency=(TabCount==0) and 0 or 0.45
        PageButton.Parent=PageContainer

        local DisplayPage = ScrollingFrame()
        DisplayPage.Visible=(TabCount==0); DisplayPage.Name=PageTitle
        DisplayPage.Size=UDim2.new(1,0,1,0); DisplayPage.Parent=DisplayFrame

        TabCount += 1

        PageButton.MouseButton1Down:Connect(function()
            task.spawn(function()
                for _,btn in next,MenuBar:GetChildren() do
                    if btn:IsA("GuiObject") then
                        local match = string.find(btn.Name:lower(), PageContainer.Name:lower())
                        local inner = btn:FindFirstChild(btn.Name.."Button")
                        Tween(btn,{ImageColor3=match and Color3.fromRGB(50,50,50) or Color3.fromRGB(40,40,40)})
                        if inner then Tween(inner,{TextTransparency=match and 0 or 0.45}) end
                    end
                end
            end)
            task.spawn(function()
                for _,disp in next,DisplayFrame:GetChildren() do
                    if disp:IsA("GuiObject") then
                        disp.Visible = string.find(disp.Name:lower(),PageContainer.Name:lower()) and true or false
                    end
                end
            end)
        end)

        local DisplayList = Instance.new("UIListLayout")
        DisplayList.SortOrder=Enum.SortOrder.LayoutOrder; DisplayList.Padding=UDim.new(0,5)
        DisplayList.Parent=DisplayPage

        DisplayList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            DisplayPage.CanvasSize=UDim2.new(0,0,(DisplayList.AbsoluteContentSize.Y/DisplayPage.AbsoluteWindowSize.Y)+0.05,0)
        end)

        local Pad=Instance.new("UIPadding")
        Pad.PaddingBottom=UDim.new(0,5); Pad.PaddingTop=UDim.new(0,5)
        Pad.PaddingLeft=UDim.new(0,5); Pad.PaddingRight=UDim.new(0,5)
        Pad.Parent=DisplayPage

        if SearchBarIncluded then
            local SBContainer=RoundBox(5)
            SBContainer.Name="SearchBar"; SBContainer.ImageColor3=Color3.fromRGB(35,35,35)
            SBContainer.Size=UDim2.new(1,0,0,20); SBContainer.Parent=DisplayPage

            local SBox=TextBox("Search...")
            SBox.Name="SearchInput"; SBox.Position=UDim2.new(0,20,0,0)
            SBox.Size=UDim2.new(1,-20,1,0); SBox.TextTransparency=0.5
            SBox.TextXAlignment=Enum.TextXAlignment.Left; SBox.Parent=SBContainer
            SearchIcon().Parent=SBContainer

            SBox:GetPropertyChangedSignal("Text"):Connect(function()
                local v=SBox.Text
                for _,el in next,DisplayPage:GetChildren() do
                    if el:IsA("Frame") and not string.find(el.Name:lower(),"label") then
                        el.Visible=string.find(el.Name:lower(),v:lower()) and true or false
                    end
                end
            end)
        end

        local PageLibrary = {}

        function PageLibrary.AddButton(Text, Callback, Parent, Underline)
            local BC=Frame(); BC.Name=Text.."BUTTON"; BC.Size=UDim2.new(1,0,0,20)
            BC.BackgroundTransparency=1; BC.Parent=Parent or DisplayPage

            local BF=RoundBox(5); BF.Name="ButtonForeground"; BF.Size=UDim2.new(1,0,1,0)
            BF.ImageColor3=Color3.fromRGB(35,35,35); BF.Parent=BC

            if Underline then
                local ts=TextService:GetTextSize(Text,12,Enum.Font.Gotham,Vector2.new(0,0))
                local be=Frame(); be.Size=UDim2.new(0,ts.X,0,1)
                be.Position=UDim2.new(0.5,(-ts.X/2)-1,1,-1)
                be.BackgroundColor3=Color3.fromRGB(255,255,255); be.BackgroundTransparency=0.5; be.Parent=BF
            end

            local HB=TextButton(Text,12); HB.Parent=BF
            HB.MouseButton1Down:Connect(function()
                Callback(); Tween(BF,{ImageColor3=Color3.fromRGB(45,45,45)}); Tween(HB,{TextTransparency=0.5})
                wait(TweenTime); Tween(BF,{ImageColor3=Color3.fromRGB(35,35,35)}); Tween(HB,{TextTransparency=0})
            end)
        end

        function PageLibrary.AddLabel(Text)
            local LC=Frame(); LC.Name=Text.."LABEL"; LC.Size=UDim2.new(1,0,0,20)
            LC.BackgroundTransparency=1; LC.Parent=DisplayPage
            local LF=RoundBox(5); LF.Name="LabelForeground"; LF.ImageColor3=Color3.fromRGB(45,45,45)
            LF.Size=UDim2.new(1,0,1,0); LF.Parent=LC
            TextLabel(Text,12).Parent=LF
        end

        function PageLibrary.AddDropdown(Text, ConfigArray, Callback)
            local Arr=ConfigArray or {}; local Toggle=false

            local DC=Frame(); DC.Size=UDim2.new(1,0,0,20); DC.Name=Text.."DROPDOWN"
            DC.BackgroundTransparency=1; DC.Parent=DisplayPage

            local DF=RoundBox(5); DF.ClipsDescendants=true; DF.ImageColor3=Color3.fromRGB(35,35,35)
            DF.Size=UDim2.new(1,0,1,0); DF.Parent=DC

            local DE=DropdownIcon(true); DE.Parent=DF
            local DL=TextLabel(Text,12); DL.Size=UDim2.new(1,0,0,20); DL.Parent=DF

            local DFrame=Frame(); DFrame.Position=UDim2.new(0,0,0,20)
            DFrame.BackgroundTransparency=1; DFrame.Size=UDim2.new(1,0,0,#Arr*20); DFrame.Parent=DF
            Instance.new("UIListLayout").Parent=DFrame

            for idx,opt in next,Arr do
                PageLibrary.AddButton(opt,function() Callback(opt); DL.Text=Text..": "..opt end,DFrame,idx<#Arr)
            end

            DE.MouseButton1Down:Connect(function()
                Toggle=not Toggle
                Tween(DC,{Size=Toggle and UDim2.new(1,0,0,20+(#Arr*20)) or UDim2.new(1,0,0,20)})
                Tween(DE,{Rotation=Toggle and 135 or 0})
            end)
        end

        function PageLibrary.AddColourPicker(Text, DefaultColour, Callback)
            DefaultColour=DefaultColour or Color3.fromRGB(255,255,255)
            local cd={white=Color3.fromRGB(255,255,255),black=Color3.fromRGB(0,0,0),
                      red=Color3.fromRGB(255,0,0),green=Color3.fromRGB(0,255,0),blue=Color3.fromRGB(0,0,255)}
            if typeof(DefaultColour)=="table" then
                DefaultColour=Color3.fromRGB(DefaultColour[1] or 255,DefaultColour[2] or 255,DefaultColour[3] or 255)
            elseif typeof(DefaultColour)=="string" then
                DefaultColour=cd[DefaultColour:lower()] or cd["white"]
            end

            local PC=Frame(); PC.ClipsDescendants=true; PC.Size=UDim2.new(1,0,0,20)
            PC.Name=Text.."COLOURPICKER"; PC.BackgroundTransparency=1; PC.Parent=DisplayPage

            local CT=Instance.new("Color3Value"); CT.Value=DefaultColour; CT.Parent=PC

            local PL,PR,PF=RoundBox(5),RoundBox(5),RoundBox(5)
            PL.Size=UDim2.new(1,-22,1,0); PL.ImageColor3=Color3.fromRGB(35,35,35); PL.Parent=PC
            PR.Size=UDim2.new(0,20,1,0); PR.Position=UDim2.new(1,-20,0,0); PR.ImageColor3=DefaultColour; PR.Parent=PC
            PF.ImageColor3=Color3.fromRGB(35,35,35); PF.Size=UDim2.new(1,-22,0,60)
            PF.Position=UDim2.new(0,0,0,20); PF.Parent=PC

            local Plist=Instance.new("UIListLayout"); Plist.SortOrder=Enum.SortOrder.LayoutOrder; Plist.Parent=PF

            PageLibrary.AddSlider("R",{Min=0,Max=255,Def=CT.Value.R*255},function(v) CT.Value=Color3.fromRGB(v,CT.Value.G*255,CT.Value.B*255); Callback(CT.Value) end,PF)
            PageLibrary.AddSlider("G",{Min=0,Max=255,Def=CT.Value.G*255},function(v) CT.Value=Color3.fromRGB(CT.Value.R*255,v,CT.Value.B*255); Callback(CT.Value) end,PF)
            PageLibrary.AddSlider("B",{Min=0,Max=255,Def=CT.Value.B*255},function(v) CT.Value=Color3.fromRGB(CT.Value.R*255,CT.Value.G*255,v); Callback(CT.Value) end,PF)

            local EL,ER=Frame(),Frame()
            EL.BackgroundColor3=Color3.fromRGB(35,35,35); EL.Position=UDim2.new(1,-5,0,0); EL.Size=UDim2.new(0,5,1,0); EL.Parent=PL
            ER.BackgroundColor3=DefaultColour; ER.Size=UDim2.new(0,5,1,0); ER.Parent=PR

            local Plabel=TextLabel(Text,12); Plabel.Size=UDim2.new(1,0,0,20); Plabel.Parent=PL

            CT:GetPropertyChangedSignal("Value"):Connect(function()
                ER.BackgroundColor3=CT.Value; PR.ImageColor3=CT.Value
            end)

            local pt=false; local pb=TextButton(""); pb.Parent=PR
            pb.MouseButton1Down:Connect(function()
                pt=not pt
                Tween(PC,{Size=pt and UDim2.new(1,0,0,80) or UDim2.new(1,0,0,20)})
            end)
        end

        function PageLibrary.AddSlider(Text, Config, Callback, Parent)
            local Min=Config.Minimum or Config.minimum or Config.Min or Config.min
            local Max=Config.Maximum or Config.maximum or Config.Max or Config.max
            local Def=Config.Default or Config.default or Config.Def or Config.def
            if Min>Max then Min,Max=Max,Min end
            Def=math.clamp(Def,Min,Max)
            local DS=Def/Max

            local SC=Frame(); SC.Name=Text.."SLIDER"; SC.Size=UDim2.new(1,0,0,20)
            SC.BackgroundTransparency=1; SC.Parent=Parent or DisplayPage

            local SF=RoundBox(5); SF.Name="SliderForeground"; SF.ImageColor3=Color3.fromRGB(35,35,35)
            SF.Size=UDim2.new(1,0,1,0); SF.Parent=SC

            local SB=TextButton(Text..": "..Def); SB.Size=UDim2.new(1,0,1,0); SB.ZIndex=6; SB.Parent=SF

            local Fill=RoundBox(5); Fill.Size=UDim2.new(DS,0,1,0); Fill.ImageColor3=Color3.fromRGB(70,70,70)
            Fill.ZIndex=5; Fill.ImageTransparency=0.7; Fill.Parent=SB

            SB.MouseButton1Down:Connect(function()
                Tween(Fill,{ImageTransparency=0.5})
                local _,_,xs=GetXY(SB); local val=math.floor(Min+(Max-Min)*xs)
                Callback(val); SB.Text=Text..": "..val; Tween(Fill,{Size=UDim2.new(xs,0,1,0)})
                local smv,skl
                smv=Mouse.Move:Connect(function()
                    Tween(Fill,{ImageTransparency=0.5})
                    local _,_,xs2=GetXY(SB); local v2=math.floor(Min+(Max-Min)*xs2)
                    Callback(v2); SB.Text=Text..": "..v2; Tween(Fill,{Size=UDim2.new(xs2,0,1,0)})
                end)
                skl=UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                        Tween(Fill,{ImageTransparency=0.7}); smv:Disconnect(); skl:Disconnect()
                    end
                end)
            end)
        end

        function PageLibrary.AddToggle(Text, Default, Callback)
            local State=Default or false

            local TC=Frame(); TC.Name=Text.."TOGGLE"; TC.Size=UDim2.new(1,0,0,20)
            TC.BackgroundTransparency=1; TC.Parent=DisplayPage

            local TL,TR=RoundBox(5),RoundBox(5)
            local EF,RT=Frame(),TickIcon()
            local FL,FR=Frame(),Frame()

            TL.Size=UDim2.new(1,-22,1,0); TL.ImageColor3=Color3.fromRGB(35,35,35); TL.Parent=TC
            TR.Position=UDim2.new(1,-20,0,0); TR.Size=UDim2.new(0,20,1,0)
            TR.ImageColor3=Color3.fromRGB(45,45,45); TR.Parent=TC

            FL.BackgroundColor3=Color3.fromRGB(35,35,35); FL.Size=UDim2.new(0,5,1,0)
            FL.Position=UDim2.new(1,-5,0,0); FL.Parent=TL
            FR.BackgroundColor3=Color3.fromRGB(45,45,45); FR.Size=UDim2.new(0,5,1,0); FR.Parent=TR

            EF.BackgroundColor3=State and Color3.fromRGB(0,255,109) or Color3.fromRGB(255,160,160)
            EF.Position=UDim2.new(1,-22,0.2,0); EF.Size=UDim2.new(0,2,0.6,0); EF.Parent=TC

            RT.ImageTransparency=State and 0 or 1; RT.Parent=TR

            local TB=TextButton(Text,12); TB.Name="ToggleButton"; TB.Parent=TL
            TB.MouseButton1Down:Connect(function()
                State=not State
                Tween(EF,{BackgroundColor3=State and Color3.fromRGB(0,255,109) or Color3.fromRGB(255,160,160)})
                Tween(RT,{ImageTransparency=State and 0 or 1})
                Callback(State)
            end)
        end

        return PageLibrary
    end

    return TabLibrary
end

return UILibrary
