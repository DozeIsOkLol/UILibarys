--[[
    ████████╗██╗    ██╗██╗███╗   ██╗██╗  ██╗    ██╗   ██╗██╗
       ██╔══╝██║    ██║██║████╗  ██║██║ ██╔╝    ██║   ██║██║
       ██║   ██║ █╗ ██║██║██╔██╗ ██║█████╔╝     ██║   ██║██║
       ██║   ██║███╗██║██║██║╚██╗██║██╔═██╗     ██║   ██║██║
       ██║   ╚███╔███╔╝██║██║ ╚████║██║  ██╗    ╚██████╔╝██║
       ╚═╝    ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝    ╚═════╝ ╚═╝
    
    Updated with:
      - 3-Section Title Bar  (Hub Name | Game Name | Version)
      - Player Avatar + Username panel
      
    Usage:
        local UI = UILibrary.Load("My Hub", "Adopt Me", "v2.0")
--]]

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGuiService = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local PlayersService = game:GetService("Players")

local TweenTime = 0.1
local Level = 1

local GlobalTweenInfo = TweenInfo.new(TweenTime)
local AlteredTweenInfo = TweenInfo.new(TweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local DropShadowID = "rbxassetid://297774371"
local DropShadowTransparency = 0.3

local IconLibraryID = "rbxassetid://3926305904"
local IconLibraryID2 = "rbxassetid://3926307971"

local MainFont = Enum.Font.Gotham

local function GetXY(GuiObject)
	local X, Y = Mouse.X - GuiObject.AbsolutePosition.X, Mouse.Y - GuiObject.AbsolutePosition.Y
	local MaxX, MaxY = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
	X, Y = math.clamp(X, 0, MaxX), math.clamp(Y, 0, MaxY)
	return X, Y, X/MaxX, Y/MaxY
end

local function TitleIcon(ButtonOrNot)
	local NewTitleIcon = Instance.new(ButtonOrNot and "ImageButton" or "ImageLabel")
	NewTitleIcon.Name = "TitleIcon"
	NewTitleIcon.BackgroundTransparency = 1
	NewTitleIcon.Image = IconLibraryID
	NewTitleIcon.ImageRectOffset = Vector2.new(524, 764)
	NewTitleIcon.ImageRectSize = Vector2.new(36, 36)
	NewTitleIcon.Size = UDim2.new(0,14,0,14)
	NewTitleIcon.Position = UDim2.new(1,-17,0,5)
	NewTitleIcon.Rotation = 180
	NewTitleIcon.ZIndex = Level
	return NewTitleIcon
end

local function TickIcon(ButtonOrNot)
	local NewTickIcon = Instance.new(ButtonOrNot and "ImageButton" or "ImageLabel")
	NewTickIcon.Name = "TickIcon"
	NewTickIcon.BackgroundTransparency = 1
	NewTickIcon.Image = "rbxassetid://3926305904"
	NewTickIcon.ImageRectOffset = Vector2.new(312,4)
	NewTickIcon.ImageRectSize = Vector2.new(24,24)
	NewTickIcon.Size = UDim2.new(1,-6,1,-6)
	NewTickIcon.Position = UDim2.new(0,3,0,3)
	NewTickIcon.ZIndex = Level
	return NewTickIcon
end

local function DropdownIcon(ButtonOrNot)
	local NewDropdownIcon = Instance.new(ButtonOrNot and "ImageButton" or "ImageLabel")
	NewDropdownIcon.Name = "DropdownIcon"
	NewDropdownIcon.BackgroundTransparency = 1
	NewDropdownIcon.Image = IconLibraryID2
	NewDropdownIcon.ImageRectOffset = Vector2.new(324,364)
	NewDropdownIcon.ImageRectSize = Vector2.new(36,36)
	NewDropdownIcon.Size = UDim2.new(0,16,0,16)
	NewDropdownIcon.Position = UDim2.new(1,-18,0,2)
	NewDropdownIcon.ZIndex = Level
	return NewDropdownIcon
end

local function SearchIcon(ButtonOrNot)
	local NewSearchIcon = Instance.new(ButtonOrNot and "ImageButton" or "ImageLabel")
	NewSearchIcon.Name = "SearchIcon"
	NewSearchIcon.BackgroundTransparency = 1
	NewSearchIcon.Image = IconLibraryID
	NewSearchIcon.ImageRectOffset = Vector2.new(964,324)
	NewSearchIcon.ImageRectSize = Vector2.new(36,36)
	NewSearchIcon.Size = UDim2.new(0,16,0,16)
	NewSearchIcon.Position = UDim2.new(0,2,0,2)
	NewSearchIcon.ZIndex = Level
	return NewSearchIcon
end

local function RoundBox(CornerRadius, ButtonOrNot)
	local NewRoundBox = Instance.new(ButtonOrNot and "ImageButton" or "ImageLabel")
	NewRoundBox.BackgroundTransparency = 1
	NewRoundBox.Image = "rbxassetid://3570695787"
	NewRoundBox.SliceCenter = Rect.new(100,100,100,100)
	NewRoundBox.SliceScale = math.clamp((CornerRadius or 5) * 0.01, 0.01, 1)
	NewRoundBox.ScaleType = Enum.ScaleType.Slice
	NewRoundBox.ZIndex = Level
	return NewRoundBox
end

local function DropShadow()
	local NewDropShadow = Instance.new("ImageLabel")
	NewDropShadow.Name = "DropShadow"
	NewDropShadow.BackgroundTransparency = 1
	NewDropShadow.Image = DropShadowID
	NewDropShadow.ImageTransparency = DropShadowTransparency
	NewDropShadow.Size = UDim2.new(1,0,1,0)
	NewDropShadow.ZIndex = Level
	return NewDropShadow
end

local function Frame()
	local NewFrame = Instance.new("Frame")
	NewFrame.BorderSizePixel = 0
	NewFrame.ZIndex = Level
	return NewFrame
end

local function ScrollingFrame()
	local NewScrollingFrame = Instance.new("ScrollingFrame")
	NewScrollingFrame.BackgroundTransparency = 1
	NewScrollingFrame.BorderSizePixel = 0
	NewScrollingFrame.ScrollBarThickness = 0
	NewScrollingFrame.ZIndex = Level
	return NewScrollingFrame
end

local function TextButton(Text, Size)
	local NewTextButton = Instance.new("TextButton")
	NewTextButton.Text = Text
	NewTextButton.AutoButtonColor = false
	NewTextButton.Font = MainFont
	NewTextButton.TextColor3 = Color3.fromRGB(255,255,255)
	NewTextButton.BackgroundTransparency = 1
	NewTextButton.TextSize = Size or 12
	NewTextButton.Size = UDim2.new(1,0,1,0)
	NewTextButton.ZIndex = Level
	return NewTextButton
end

local function TextBox(Text, Size)
	local NewTextBox = Instance.new("TextBox")
	NewTextBox.Text = Text
	NewTextBox.Font = MainFont
	NewTextBox.TextColor3 = Color3.fromRGB(255,255,255)
	NewTextBox.BackgroundTransparency = 1
	NewTextBox.TextSize = Size or 12
	NewTextBox.Size = UDim2.new(1,0,1,0)
	NewTextBox.ZIndex = Level
	return NewTextBox
end

local function TextLabel(Text, Size)
	local NewTextLabel = Instance.new("TextLabel")
	NewTextLabel.Text = Text
	NewTextLabel.Font = MainFont
	NewTextLabel.TextColor3 = Color3.fromRGB(255,255,255)
	NewTextLabel.BackgroundTransparency = 1
	NewTextLabel.TextSize = Size or 12
	NewTextLabel.Size = UDim2.new(1,0,1,0)
	NewTextLabel.ZIndex = Level
	return NewTextLabel
end

local function Tween(GuiObject, Dictionary)
	local TweenBase = TweenService:Create(GuiObject, GlobalTweenInfo, Dictionary)
	TweenBase:Play()
	return TweenBase
end

local UILibrary = {}

-- ============================================================
--  UILibrary.Load
--  HubName    : string  — left section of the title bar
--  GameName   : string  — centre section of the title bar
--  Version    : string  — right section of the title bar (e.g. "v2.0")
-- ============================================================
function UILibrary.Load(HubName, GameName, Version)
	HubName  = HubName  or "Twink UI"
	GameName = GameName or "Unknown Game"
	Version  = Version  or "v1.0"

	local TargetedParent = RunService:IsStudio() and Player:WaitForChild("PlayerGui") or CoreGuiService

	-- Remove any old instance with the same hub name
	local FindOldInstance = TargetedParent:FindFirstChild(HubName)
	if FindOldInstance then
		FindOldInstance:Destroy()
	end

	local NewInstance, ContainerFrame, ContainerShadow, MainFrame

	NewInstance = Instance.new("ScreenGui")
	NewInstance.Name = HubName
	NewInstance.Parent = TargetedParent

	ContainerFrame = Frame()
	ContainerFrame.Name = "ContainerFrame"
	ContainerFrame.Size = UDim2.new(0,500,0,300)
	ContainerFrame.Position = UDim2.new(0.5,-250,0.5,-150)
	ContainerFrame.BackgroundTransparency = 1
	ContainerFrame.Parent = NewInstance

	ContainerShadow = DropShadow()
	ContainerShadow.Name = "Shadow"
	ContainerShadow.Parent = ContainerFrame

	Level += 1

	MainFrame = RoundBox(5)
	MainFrame.ClipsDescendants = true
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(1,-50,1,-30)
	MainFrame.Position = UDim2.new(0,25,0,15)
	MainFrame.ImageColor3 = Color3.fromRGB(30,30,30)
	MainFrame.Parent = ContainerFrame

	-- --------------------------------------------------------
	--  TITLE BAR  (3 sections)
	--    Left   → Hub Name
	--    Centre → Game Name  (dimmed, smaller)
	--    Right  → Version    (dimmed, smallest)
	-- --------------------------------------------------------
	local TitleBar
	TitleBar = RoundBox(5)
	TitleBar.Name = "TitleBar"
	TitleBar.ImageColor3 = Color3.fromRGB(40,40,40)
	TitleBar.Size = UDim2.new(1,-10,0,25)   -- 5 px taller than original
	TitleBar.Position = UDim2.new(0,5,0,5)
	TitleBar.Parent = MainFrame

	Level += 1

	-- Invisible drag button (same behaviour as original TitleButton)
	local TitleDragZone = TextButton("", 14)
	TitleDragZone.Name = "TitleDragZone"
	TitleDragZone.Size = UDim2.new(1,-20,1,0)
	TitleDragZone.Parent = TitleBar

	-- Hub Name label  (left)
	local HubLabel = TextLabel(HubName, 12)
	HubLabel.Name = "HubLabel"
	HubLabel.Font = Enum.Font.GothamBold
	HubLabel.TextXAlignment = Enum.TextXAlignment.Left
	HubLabel.Size = UDim2.new(0.42,0,1,0)
	HubLabel.Position = UDim2.new(0,6,0,0)
	HubLabel.ZIndex = Level
	HubLabel.Parent = TitleBar

	-- Separator  |  hub / game
	local Sep1 = Frame()
	Sep1.Name = "Sep1"
	Sep1.BackgroundColor3 = Color3.fromRGB(80,80,80)
	Sep1.Size = UDim2.new(0,1,0.5,0)
	Sep1.Position = UDim2.new(0.42,0,0.25,0)
	Sep1.ZIndex = Level
	Sep1.Parent = TitleBar

	-- Game Name label  (centre)
	local GameLabel = TextLabel(GameName, 10)
	GameLabel.Name = "GameLabel"
	GameLabel.TextXAlignment = Enum.TextXAlignment.Center
	GameLabel.TextTransparency = 0.3
	GameLabel.Size = UDim2.new(0.3,0,1,0)
	GameLabel.Position = UDim2.new(0.43,0,0,0)
	GameLabel.ZIndex = Level
	GameLabel.Parent = TitleBar

	-- Separator  |  game / version
	local Sep2 = Frame()
	Sep2.Name = "Sep2"
	Sep2.BackgroundColor3 = Color3.fromRGB(80,80,80)
	Sep2.Size = UDim2.new(0,1,0.5,0)
	Sep2.Position = UDim2.new(0.73,0,0.25,0)
	Sep2.ZIndex = Level
	Sep2.Parent = TitleBar

	-- Version label  (right, before minimise button)
	local VersionLabel = TextLabel(Version, 9)
	VersionLabel.Name = "VersionLabel"
	VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
	VersionLabel.TextTransparency = 0.45
	VersionLabel.Size = UDim2.new(0.22,0,1,0)
	VersionLabel.Position = UDim2.new(0.74,-2,0,0)
	VersionLabel.ZIndex = Level
	VersionLabel.Parent = TitleBar

	-- Minimise button  (unchanged behaviour)
	local MinimiseButton
	local MinimiseToggle = true

	MinimiseButton = TitleIcon(true)
	MinimiseButton.Name = "Minimise"
	MinimiseButton.Parent = TitleBar

	MinimiseButton.MouseButton1Down:Connect(function()
		MinimiseToggle = not MinimiseToggle
		if not MinimiseToggle then
			Tween(MainFrame, {Size = UDim2.new(1,-50,0,30)})
			Tween(MinimiseButton, {Rotation = 0})
			Tween(ContainerShadow, {ImageTransparency = 1})
		else
			Tween(MainFrame, {Size = UDim2.new(1,-50,1,-30)})
			Tween(MinimiseButton, {Rotation = 180})
			Tween(ContainerShadow, {ImageTransparency = DropShadowTransparency})
		end
	end)

	-- Drag logic (attached to the invisible overlay button)
	TitleDragZone.MouseButton1Down:Connect(function()
		local LastMX, LastMY = Mouse.X, Mouse.Y
		local Move, Kill
		Move = Mouse.Move:Connect(function()
			local NewMX, NewMY = Mouse.X, Mouse.Y
			local DX, DY = NewMX - LastMX, NewMY - LastMY
			ContainerFrame.Position += UDim2.new(0,DX,0,DY)
			LastMX, LastMY = NewMX, NewMY
		end)
		Kill = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				Move:Disconnect()
				Kill:Disconnect()
			end
		end)
	end)

	Level += 1

	-- --------------------------------------------------------
	--  PLAYER INFO PANEL  (avatar + username)
	--  Sits in the left column, just below the title bar
	-- --------------------------------------------------------
	local UserInfoFrame = RoundBox(5)
	UserInfoFrame.Name = "UserInfo"
	UserInfoFrame.ImageColor3 = Color3.fromRGB(35,35,35)
	UserInfoFrame.Size = UDim2.new(0,100,0,52)
	UserInfoFrame.Position = UDim2.new(0,5,0,34)
	UserInfoFrame.ClipsDescendants = true
	UserInfoFrame.Parent = MainFrame

	-- Subtle tinted gradient strip at top of panel
	local InfoAccent = Frame()
	InfoAccent.Name = "Accent"
	InfoAccent.BackgroundColor3 = Color3.fromRGB(100,80,180)
	InfoAccent.BackgroundTransparency = 0.75
	InfoAccent.Size = UDim2.new(1,0,0,2)
	InfoAccent.ZIndex = Level
	InfoAccent.Parent = UserInfoFrame

	-- Avatar container (circular)
	local AvatarHolder = Frame()
	AvatarHolder.Name = "AvatarHolder"
	AvatarHolder.BackgroundColor3 = Color3.fromRGB(50,50,50)
	AvatarHolder.Size = UDim2.new(0,36,0,36)
	AvatarHolder.Position = UDim2.new(0,7,0.5,-18)
	AvatarHolder.ZIndex = Level
	AvatarHolder.Parent = UserInfoFrame

	local AvatarCorner = Instance.new("UICorner")
	AvatarCorner.CornerRadius = UDim.new(1,0)
	AvatarCorner.Parent = AvatarHolder

	local AvatarImage = Instance.new("ImageLabel")
	AvatarImage.Name = "AvatarImage"
	AvatarImage.BackgroundTransparency = 1
	AvatarImage.Size = UDim2.new(1,0,1,0)
	AvatarImage.ZIndex = Level + 1
	AvatarImage.Parent = AvatarHolder

	local AvatarImageCorner = Instance.new("UICorner")
	AvatarImageCorner.CornerRadius = UDim.new(1,0)
	AvatarImageCorner.Parent = AvatarImage

	-- Online status dot
	local StatusDot = Frame()
	StatusDot.Name = "StatusDot"
	StatusDot.BackgroundColor3 = Color3.fromRGB(0,200,90)
	StatusDot.Size = UDim2.new(0,8,0,8)
	StatusDot.Position = UDim2.new(1,-8,1,-8)
	StatusDot.ZIndex = Level + 2
	StatusDot.Parent = AvatarHolder

	local StatusDotCorner = Instance.new("UICorner")
	StatusDotCorner.CornerRadius = UDim.new(1,0)
	StatusDotCorner.Parent = StatusDot

	-- Display name label
	local DisplayNameLabel = TextLabel(Player.DisplayName, 11)
	DisplayNameLabel.Name = "DisplayName"
	DisplayNameLabel.Font = Enum.Font.GothamBold
	DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	DisplayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	DisplayNameLabel.Size = UDim2.new(1,-52,0,14)
	DisplayNameLabel.Position = UDim2.new(0,48,0,10)
	DisplayNameLabel.ZIndex = Level
	DisplayNameLabel.Parent = UserInfoFrame

	-- Username label  (@username, slightly dimmed)
	local UsernameLabel = TextLabel("@"..Player.Name, 9)
	UsernameLabel.Name = "Username"
	UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
	UsernameLabel.TextTransparency = 0.4
	UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	UsernameLabel.Size = UDim2.new(1,-52,0,11)
	UsernameLabel.Position = UDim2.new(0,48,0,26)
	UsernameLabel.ZIndex = Level
	UsernameLabel.Parent = UserInfoFrame

	-- Async-fetch the player's headshot thumbnail
	task.spawn(function()
		local ok, thumb = pcall(function()
			return PlayersService:GetUserThumbnailAsync(
				Player.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size48x48
			)
		end)
		if ok and thumb then
			AvatarImage.Image = thumb
		end
	end)

	-- --------------------------------------------------------
	--  MENU BAR  (tabs – pushed down to make room for UserInfo)
	-- --------------------------------------------------------
	local MenuBar, DisplayFrame

	MenuBar = ScrollingFrame()
	MenuBar.Name = "MenuBar"
	MenuBar.BackgroundTransparency = 0.7
	MenuBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
	MenuBar.Size = UDim2.new(0,100,0,175)    -- was 235 — reduced by 60 (UserInfo 52 + 8 gap)
	MenuBar.Position = UDim2.new(0,5,0,91)   -- was 30  — pushed down
	MenuBar.CanvasSize = UDim2.new(0,0,0,0)
	MenuBar.Parent = MainFrame

	DisplayFrame = RoundBox(5)
	DisplayFrame.Name = "Display"
	DisplayFrame.ImageColor3 = Color3.fromRGB(20,20,20)
	DisplayFrame.Size = UDim2.new(1,-115,0,232)   -- full height on right column (unchanged start)
	DisplayFrame.Position = UDim2.new(0,110,0,30)
	DisplayFrame.Parent = MainFrame

	Level += 1

	local MenuListLayout

	MenuListLayout = Instance.new("UIListLayout")
	MenuListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	MenuListLayout.Padding = UDim.new(0,5)
	MenuListLayout.Parent = MenuBar

	local TabCount = 0

	local TabLibrary = {}

	function TabLibrary.AddPage(PageTitle, SearchBarIncluded)
		local SearchBarIncluded = (SearchBarIncluded == nil) and true or SearchBarIncluded

		local PageContainer = RoundBox(5)
		PageContainer.Name = PageTitle
		PageContainer.Size = UDim2.new(1,0,0,20)
		PageContainer.LayoutOrder = TabCount
		PageContainer.ImageColor3 = (TabCount == 0) and Color3.fromRGB(50,50,50) or Color3.fromRGB(40,40,40)
		PageContainer.Parent = MenuBar

		local PageButton = TextButton(PageTitle, 14)
		PageButton.Name = PageTitle.."Button"
		PageButton.TextTransparency = (TabCount == 0) and 0 or 0.5
		PageButton.Parent = PageContainer

		PageButton.MouseButton1Down:Connect(function()
			spawn(function()
				for _, Button in next, MenuBar:GetChildren() do
					if Button:IsA("GuiObject") then
						local IsButton = string.find(Button.Name:lower(), PageContainer.Name:lower())
						local Button2 = Button:FindFirstChild(Button.Name.."Button")
						Tween(Button, {ImageColor3 = IsButton and Color3.fromRGB(50,50,50) or Color3.fromRGB(40,40,40)})
						Tween(Button2, {TextTransparency = IsButton and 0 or 0.5})
					end
				end
			end)
			spawn(function()
				for _, Display in next, DisplayFrame:GetChildren() do
					if Display:IsA("GuiObject") then
						Display.Visible = string.find(Display.Name:lower(), PageContainer.Name:lower())
					end
				end
			end)
		end)

		local DisplayPage = ScrollingFrame()
		DisplayPage.Visible = (TabCount == 0)
		DisplayPage.Name = PageTitle
		DisplayPage.Size = UDim2.new(1,0,1,0)
		DisplayPage.Parent = DisplayFrame

		TabCount += 1

		local DisplayList = Instance.new("UIListLayout")
		DisplayList.SortOrder = Enum.SortOrder.LayoutOrder
		DisplayList.Padding = UDim.new(0,5)
		DisplayList.Parent = DisplayPage

		DisplayList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			local Y1 = DisplayList.AbsoluteContentSize.Y
			local Y2 = DisplayPage.AbsoluteWindowSize.Y
			DisplayPage.CanvasSize = UDim2.new(0,0,(Y1/Y2)+0.05,0)
		end)

		local DisplayPadding = Instance.new("UIPadding")
		DisplayPadding.PaddingBottom = UDim.new(0,5)
		DisplayPadding.PaddingTop = UDim.new(0,5)
		DisplayPadding.PaddingLeft = UDim.new(0,5)
		DisplayPadding.PaddingRight = UDim.new(0,5)
		DisplayPadding.Parent = DisplayPage

		if SearchBarIncluded then
			local SearchBarContainer = RoundBox(5)
			SearchBarContainer.Name = "SearchBar"
			SearchBarContainer.ImageColor3 = Color3.fromRGB(35,35,35)
			SearchBarContainer.Size = UDim2.new(1,0,0,20)
			SearchBarContainer.Parent = DisplayPage

			local SearchBox = TextBox("Search...")
			SearchBox.Name = "SearchInput"
			SearchBox.Position = UDim2.new(0,20,0,0)
			SearchBox.Size = UDim2.new(1,-20,1,0)
			SearchBox.TextTransparency = 0.5
			SearchBox.TextXAlignment = Enum.TextXAlignment.Left
			SearchBox.Parent = SearchBarContainer

			local SearchIconInst = SearchIcon()
			SearchIconInst.Parent = SearchBarContainer

			SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
				local NewValue = SearchBox.Text

				for _, Element in next, DisplayPage:GetChildren() do
					if Element:IsA("Frame") then
						if not string.find(Element.Name:lower(), "label") then
							if string.find(Element.Name:lower(), NewValue:lower()) then
								Element.Visible = true
							else
								Element.Visible = false
							end
						end
					end
				end
			end)
		end

		local PageLibrary = {}

		function PageLibrary.AddButton(Text, Callback, Parent, Underline)
			local ButtonContainer = Frame()
			ButtonContainer.Name = Text.."BUTTON"
			ButtonContainer.Size = UDim2.new(1,0,0,20)
			ButtonContainer.BackgroundTransparency = 1
			ButtonContainer.Parent = Parent or DisplayPage

			local ButtonForeground = RoundBox(5)
			ButtonForeground.Name = "ButtonForeground"
			ButtonForeground.Size = UDim2.new(1,0,1,0)
			ButtonForeground.ImageColor3 = Color3.fromRGB(35,35,35)
			ButtonForeground.Parent = ButtonContainer

			if Underline then
				local TextSize = TextService:GetTextSize(Text, 12, Enum.Font.Gotham, Vector2.new(0,0))

				local BottomEffect = Frame()
				BottomEffect.Size = UDim2.new(0,TextSize.X,0,1)
				BottomEffect.Position = UDim2.new(0.5,(-TextSize.X/2)-1,1,-1)
				BottomEffect.BackgroundColor3 = Color3.fromRGB(255,255,255)
				BottomEffect.BackgroundTransparency = 0.5
				BottomEffect.Parent = ButtonForeground
			end

			local HiddenButton = TextButton(Text, 12)
			HiddenButton.Parent = ButtonForeground

			HiddenButton.MouseButton1Down:Connect(function()
				Callback()
				Tween(ButtonForeground, {ImageColor3 = Color3.fromRGB(45,45,45)})
				Tween(HiddenButton, {TextTransparency = 0.5})
				wait(TweenTime)
				Tween(ButtonForeground, {ImageColor3 = Color3.fromRGB(35,35,35)})
				Tween(HiddenButton, {TextTransparency = 0})
			end)
		end

		function PageLibrary.AddLabel(Text)
			local LabelContainer = Frame()
			LabelContainer.Name = Text.."LABEL"
			LabelContainer.Size = UDim2.new(1,0,0,20)
			LabelContainer.BackgroundTransparency = 1
			LabelContainer.Parent = DisplayPage

			local LabelForeground = RoundBox(5)
			LabelForeground.Name = "LabelForeground"
			LabelForeground.ImageColor3 = Color3.fromRGB(45,45,45)
			LabelForeground.Size = UDim2.new(1,0,1,0)
			LabelForeground.Parent = LabelContainer

			local HiddenLabel = TextLabel(Text, 12)
			HiddenLabel.Parent = LabelForeground
		end

		function PageLibrary.AddDropdown(Text, ConfigurationArray, Callback)
			local DropdownArray = ConfigurationArray or {}

			local DropdownToggle = false

			local DropdownContainer = Frame()
			DropdownContainer.Size = UDim2.new(1,0,0,20)
			DropdownContainer.Name = Text.."DROPDOWN"
			DropdownContainer.BackgroundTransparency = 1
			DropdownContainer.Parent = DisplayPage

			local DropdownForeground = RoundBox(5)
			DropdownForeground.ClipsDescendants = true
			DropdownForeground.ImageColor3 = Color3.fromRGB(35,35,35)
			DropdownForeground.Size = UDim2.new(1,0,1,0)
			DropdownForeground.Parent = DropdownContainer

			local DropdownExpander = DropdownIcon(true)
			DropdownExpander.Parent = DropdownForeground

			local DropdownLabel = TextLabel(Text, 12)
			DropdownLabel.Size = UDim2.new(1,0,0,20)
			DropdownLabel.Parent = DropdownForeground

			local DropdownFrame = Frame()
			DropdownFrame.Position = UDim2.new(0,0,0,20)
			DropdownFrame.BackgroundTransparency = 1
			DropdownFrame.Size = UDim2.new(1,0,0,#DropdownArray*20)
			DropdownFrame.Parent = DropdownForeground

			local DropdownList = Instance.new("UIListLayout")
			DropdownList.Parent = DropdownFrame

			for OptionIndex, Option in next, DropdownArray do
				PageLibrary.AddButton(Option, function()
					Callback(Option)
					DropdownLabel.Text = Text..": "..Option
				end, DropdownFrame, OptionIndex < #DropdownArray)
			end

			DropdownExpander.MouseButton1Down:Connect(function()
				DropdownToggle = not DropdownToggle
				Tween(DropdownContainer, {Size = DropdownToggle and UDim2.new(1,0,0,20+(#DropdownArray*20)) or UDim2.new(1,0,0,20)})
				Tween(DropdownExpander, {Rotation = DropdownToggle and 135 or 0})
			end)
		end

		function PageLibrary.AddColourPicker(Text, DefaultColour, Callback)
			local DefaultColour = DefaultColour or Color3.fromRGB(255,255,255)

			local ColourDictionary = {
				white = Color3.fromRGB(255,255,255),
				black = Color3.fromRGB(0,0,0),
				red = Color3.fromRGB(255,0,0),
				green = Color3.fromRGB(0,255,0),
				blue = Color3.fromRGB(0,0,255)
			}

			if typeof(DefaultColour) == "table" then
				DefaultColour = Color3.fromRGB(DefaultColour[1] or 255, DefaultColour[2] or 255, DefaultColour[3] or 255)
			elseif typeof(DefaultColour) == "string" then
				DefaultColour = ColourDictionary[DefaultColour:lower()] or ColourDictionary["white"]
			end

			local PickerContainer = Frame()
			PickerContainer.ClipsDescendants = true
			PickerContainer.Size = UDim2.new(1,0,0,20)
			PickerContainer.Name = Text.."COLOURPICKER"
			PickerContainer.BackgroundTransparency = 1
			PickerContainer.Parent = DisplayPage

			local ColourTracker = Instance.new("Color3Value")
			ColourTracker.Value = DefaultColour
			ColourTracker.Parent = PickerContainer

			local PickerLeftSide, PickerRightSide, PickerFrame = RoundBox(5), RoundBox(5), RoundBox(5)

			PickerLeftSide.Size = UDim2.new(1,-22,1,0)
			PickerLeftSide.ImageColor3 = Color3.fromRGB(35,35,35)
			PickerLeftSide.Parent = PickerContainer

			PickerRightSide.Size = UDim2.new(0,20,1,0)
			PickerRightSide.Position = UDim2.new(1,-20,0,0)
			PickerRightSide.ImageColor3 = DefaultColour
			PickerRightSide.Parent = PickerContainer

			PickerFrame.ImageColor3 = Color3.fromRGB(35,35,35)
			PickerFrame.Size = UDim2.new(1,-22,0,60)
			PickerFrame.Position = UDim2.new(0,0,0,20)
			PickerFrame.Parent = PickerContainer

			local PickerList = Instance.new("UIListLayout")
			PickerList.SortOrder = Enum.SortOrder.LayoutOrder
			PickerList.Parent = PickerFrame

			local RedPicker = PageLibrary.AddSlider("R", {Min = 0, Max = 255, Def = ColourTracker.Value.R * 255}, function(Value)
				ColourTracker.Value = Color3.fromRGB(Value, ColourTracker.Value.G * 255, ColourTracker.Value.B * 255)
				Callback(ColourTracker.Value)
			end, PickerFrame)

			local BluePicker = PageLibrary.AddSlider("G", {Min = 0, Max = 255, Def = ColourTracker.Value.G * 255}, function(Value)
				ColourTracker.Value = Color3.fromRGB(ColourTracker.Value.R * 255, Value, ColourTracker.Value.B * 255)
				Callback(ColourTracker.Value)
			end, PickerFrame)

			local GreenPicker = PageLibrary.AddSlider("B", {Min = 0, Max = 255, Def = ColourTracker.Value.B * 255}, function(Value)
				ColourTracker.Value = Color3.fromRGB(ColourTracker.Value.R * 255, ColourTracker.Value.G * 255, Value)
				Callback(ColourTracker.Value)
			end, PickerFrame)

			local EffectLeft, EffectRight = Frame(), Frame()

			EffectLeft.BackgroundColor3 = Color3.fromRGB(35,35,35)
			EffectLeft.Position = UDim2.new(1,-5,0,0)
			EffectLeft.Size = UDim2.new(0,5,1,0)
			EffectLeft.Parent = PickerLeftSide

			EffectRight.BackgroundColor3 = DefaultColour
			EffectRight.Size = UDim2.new(0,5,1,0)
			EffectRight.Parent = PickerRightSide

			local PickerLabel = TextLabel(Text, 12)
			PickerLabel.Size = UDim2.new(1,0,0,20)
			PickerLabel.Parent = PickerLeftSide

			ColourTracker:GetPropertyChangedSignal("Value"):Connect(function()
				local NewValue = ColourTracker.Value
				EffectRight.BackgroundColor3 = NewValue
				PickerRightSide.ImageColor3 = NewValue
			end)

			local PickerToggle = false

			local PickerButton = TextButton("")
			PickerButton.Parent = PickerRightSide

			PickerButton.MouseButton1Down:Connect(function()
				PickerToggle = not PickerToggle
				Tween(PickerContainer, {Size = PickerToggle and UDim2.new(1,0,0,80) or UDim2.new(1,0,0,20)})
			end)
		end

		function PageLibrary.AddSlider(Text, ConfigurationDictionary, Callback, Parent)
			local Configuration = ConfigurationDictionary
			local Minimum = Configuration.Minimum or Configuration.minimum or Configuration.Min or Configuration.min
			local Maximum = Configuration.Maximum or Configuration.maximum or Configuration.Max or Configuration.max
			local Default = Configuration.Default or Configuration.default or Configuration.Def or Configuration.def

			if Minimum > Maximum then
				local StoreValue = Minimum
				Minimum = Maximum
				Maximum = StoreValue
			end

			Default = math.clamp(Default, Minimum, Maximum)

			local DefaultScale = Default/Maximum

			local SliderContainer = Frame()
			SliderContainer.Name = Text.."SLIDER"
			SliderContainer.Size = UDim2.new(1,0,0,20)
			SliderContainer.BackgroundTransparency = 1
			SliderContainer.Parent = Parent or DisplayPage

			local SliderForeground = RoundBox(5)
			SliderForeground.Name = "SliderForeground"
			SliderForeground.ImageColor3 = Color3.fromRGB(35,35,35)
			SliderForeground.Size = UDim2.new(1,0,1,0)
			SliderForeground.Parent = SliderContainer

			local SliderButton = TextButton(Text..": "..Default)
			SliderButton.Size = UDim2.new(1,0,1,0)
			SliderButton.ZIndex = 6
			SliderButton.Parent = SliderForeground

			local SliderFill = RoundBox(5)
			SliderFill.Size = UDim2.new(DefaultScale,0,1,0)
			SliderFill.ImageColor3 = Color3.fromRGB(70,70,70)
			SliderFill.ZIndex = 5
			SliderFill.ImageTransparency = 0.7
			SliderFill.Parent = SliderButton

			SliderButton.MouseButton1Down:Connect(function()
				Tween(SliderFill, {ImageTransparency = 0.5})
				local X, Y, XScale, YScale = GetXY(SliderButton)
				local Value = math.floor(Minimum + ((Maximum - Minimum) * XScale))
				Callback(Value)
				SliderButton.Text = Text..": "..tostring(Value)
				local TargetSize = UDim2.new(XScale,0,1,0)
				Tween(SliderFill, {Size = TargetSize})
				local SliderMove, SliderKill
				SliderMove = Mouse.Move:Connect(function()
					Tween(SliderFill, {ImageTransparency = 0.5})
					local X, Y, XScale, YScale = GetXY(SliderButton)
					local Value = math.floor(Minimum + ((Maximum - Minimum) * XScale))
					Callback(Value)
					SliderButton.Text = Text..": "..tostring(Value)
					local TargetSize = UDim2.new(XScale,0,1,0)
					Tween(SliderFill, {Size = TargetSize})
				end)
				SliderKill = UserInputService.InputEnded:Connect(function(UserInput)
					if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
						Tween(SliderFill, {ImageTransparency = 0.7})
						SliderMove:Disconnect()
						SliderKill:Disconnect()
					end
				end)
			end)
		end

		function PageLibrary.AddToggle(Text, Default, Callback)
			local ThisToggle = Default or false

			local ToggleContainer = Frame()
			ToggleContainer.Name = Text.."TOGGLE"
			ToggleContainer.Size = UDim2.new(1,0,0,20)
			ToggleContainer.BackgroundTransparency = 1
			ToggleContainer.Parent = DisplayPage

			local ToggleLeftSide, ToggleRightSide, EffectFrame, RightTick = RoundBox(5), RoundBox(5), Frame(), TickIcon()
			local FlatLeft, FlatRight = Frame(), Frame()

			ToggleLeftSide.Size = UDim2.new(1,-22,1,0)
			ToggleLeftSide.ImageColor3 = Color3.fromRGB(35,35,35)
			ToggleLeftSide.Parent = ToggleContainer

			ToggleRightSide.Position = UDim2.new(1,-20,0,0)
			ToggleRightSide.Size = UDim2.new(0,20,1,0)
			ToggleRightSide.ImageColor3 = Color3.fromRGB(45,45,45)
			ToggleRightSide.Parent = ToggleContainer

			FlatLeft.BackgroundColor3 = Color3.fromRGB(35,35,35)
			FlatLeft.Size = UDim2.new(0,5,1,0)
			FlatLeft.Position = UDim2.new(1,-5,0,0)
			FlatLeft.Parent = ToggleLeftSide

			FlatRight.BackgroundColor3 = Color3.fromRGB(45,45,45)
			FlatRight.Size = UDim2.new(0,5,1,0)
			FlatRight.Parent = ToggleRightSide

			EffectFrame.BackgroundColor3 = ThisToggle and Color3.fromRGB(0,255,109) or Color3.fromRGB(255,160,160)
			EffectFrame.Position = UDim2.new(1,-22,0.2,0)
			EffectFrame.Size = UDim2.new(0,2,0.6,0)
			EffectFrame.Parent = ToggleContainer

			RightTick.ImageTransparency = ThisToggle and 0 or 1
			RightTick.Parent = ToggleRightSide

			local ToggleButton = TextButton(Text, 12)
			ToggleButton.Name = "ToggleButton"
			ToggleButton.Size = UDim2.new(1,0,1,0)
			ToggleButton.Parent = ToggleLeftSide

			ToggleButton.MouseButton1Down:Connect(function()
				ThisToggle = not ThisToggle
				Tween(EffectFrame, {BackgroundColor3 = ThisToggle and Color3.fromRGB(0,255,109) or Color3.fromRGB(255,160,160)})
				Tween(RightTick, {ImageTransparency = ThisToggle and 0 or 1})
				Callback(ThisToggle)
			end)
		end

		return PageLibrary
	end

	return TabLibrary
end

return UILibrary
