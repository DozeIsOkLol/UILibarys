--[[
	ModernTwinkUI - Update by DOZE/SouljaWitchSrc
	Version: 0.0.1
	
	Features:
	- Modern design with customizable themes
	- Smooth animations and transitions
	- Rich UI components (buttons, toggles, sliders, inputs, etc.)
	- Notification system
	- Search functionality
	- Keybind support
	- HSV color picker
]]

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGuiService = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Configuration
local Config = {
	TweenSpeed = 0.2,
	TweenStyle = Enum.EasingStyle.Quint,
	TweenDirection = Enum.EasingDirection.Out,
	
	-- Modern color scheme
	Colors = {
		Background = Color3.fromRGB(18, 18, 18),
		Surface = Color3.fromRGB(25, 25, 25),
		SurfaceHover = Color3.fromRGB(30, 30, 30),
		Primary = Color3.fromRGB(99, 102, 241), -- Indigo
		PrimaryHover = Color3.fromRGB(129, 140, 248),
		Success = Color3.fromRGB(34, 197, 94),
		Danger = Color3.fromRGB(239, 68, 68),
		Warning = Color3.fromRGB(251, 146, 60),
		Text = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(156, 163, 175),
		Border = Color3.fromRGB(55, 65, 81),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	
	Fonts = {
		Primary = Enum.Font.GothamBold,
		Secondary = Enum.Font.Gotham,
	},
	
	IconLibrary = "rbxassetid://3926305904",
	IconLibrary2 = "rbxassetid://3926307971",
}

local ZIndex = 1

-- Utility Functions
local function GetXY(GuiObject)
	local X = Mouse.X - GuiObject.AbsolutePosition.X
	local Y = Mouse.Y - GuiObject.AbsolutePosition.Y
	local MaxX, MaxY = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
	X = math.clamp(X, 0, MaxX)
	Y = math.clamp(Y, 0, MaxY)
	return X, Y, X/MaxX, Y/MaxY
end

local function Tween(GuiObject, Properties, Duration, Style, Direction)
	Duration = Duration or Config.TweenSpeed
	Style = Style or Config.TweenStyle
	Direction = Direction or Config.TweenDirection
	
	local TweenInfo = TweenInfo.new(Duration, Style, Direction)
	local Tween = TweenService:Create(GuiObject, TweenInfo, Properties)
	Tween:Play()
	return Tween
end

local function RippleEffect(GuiObject, X, Y)
	local Ripple = Instance.new("ImageLabel")
	Ripple.Name = "Ripple"
	Ripple.BackgroundTransparency = 1
	Ripple.Image = "rbxassetid://3570695787"
	Ripple.ImageColor3 = Color3.fromRGB(255, 255, 255)
	Ripple.ImageTransparency = 0.7
	Ripple.Size = UDim2.new(0, 0, 0, 0)
	Ripple.Position = UDim2.new(0, X, 0, Y)
	Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	Ripple.ZIndex = GuiObject.ZIndex + 1
	Ripple.Parent = GuiObject
	
	local Size = math.max(GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y) * 2
	
	Tween(Ripple, {
		Size = UDim2.new(0, Size, 0, Size),
		ImageTransparency = 1
	}, 0.6, Enum.EasingStyle.Linear)
	
	task.delay(0.6, function()
		Ripple:Destroy()
	end)
end

-- Element Creation Helpers
local function CreateRoundBox(CornerRadius, Parent)
	local Box = Instance.new("Frame")
	Box.BackgroundColor3 = Config.Colors.Surface
	Box.BorderSizePixel = 0
	Box.ZIndex = ZIndex
	Box.Parent = Parent
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, CornerRadius or 8)
	Corner.Parent = Box
	
	return Box
end

local function CreateStroke(Color, Thickness, Parent)
	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color or Config.Colors.Border
	Stroke.Thickness = Thickness or 1
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Parent = Parent
	return Stroke
end

local function CreateShadow(Parent)
	local Shadow = Instance.new("ImageLabel")
	Shadow.Name = "Shadow"
	Shadow.BackgroundTransparency = 1
	Shadow.Image = "rbxassetid://297774371"
	Shadow.ImageColor3 = Config.Colors.Shadow
	Shadow.ImageTransparency = 0.5
	Shadow.Size = UDim2.new(1, 30, 1, 30)
	Shadow.Position = UDim2.new(0, -15, 0, -15)
	Shadow.ZIndex = ZIndex - 1
	Shadow.Parent = Parent
	return Shadow
end

local function CreateTextLabel(Text, Size, Font, Parent)
	local Label = Instance.new("TextLabel")
	Label.Text = Text
	Label.Font = Font or Config.Fonts.Secondary
	Label.TextSize = Size or 14
	Label.TextColor3 = Config.Colors.Text
	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.ZIndex = ZIndex
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Parent
	return Label
end

local function CreateTextButton(Text, Size, Font, Parent)
	local Button = Instance.new("TextButton")
	Button.Text = Text
	Button.Font = Font or Config.Fonts.Secondary
	Button.TextSize = Size or 14
	Button.TextColor3 = Config.Colors.Text
	Button.BackgroundTransparency = 1
	Button.AutoButtonColor = false
	Button.Size = UDim2.new(1, 0, 1, 0)
	Button.ZIndex = ZIndex
	Button.Parent = Parent
	return Button
end

local function CreateIcon(ImageRectOffset, ImageRectSize, Parent, Size)
	local Icon = Instance.new("ImageLabel")
	Icon.BackgroundTransparency = 1
	Icon.Image = Config.IconLibrary
	Icon.ImageRectOffset = ImageRectOffset
	Icon.ImageRectSize = ImageRectSize
	Icon.Size = Size or UDim2.new(0, 20, 0, 20)
	Icon.ZIndex = ZIndex
	Icon.Parent = Parent
	return Icon
end

local function CreateScrollingFrame(Parent)
	local ScrollFrame = Instance.new("ScrollingFrame")
	ScrollFrame.BackgroundTransparency = 1
	ScrollFrame.BorderSizePixel = 0
	ScrollFrame.ScrollBarThickness = 4
	ScrollFrame.ScrollBarImageColor3 = Config.Colors.Primary
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollFrame.ZIndex = ZIndex
	ScrollFrame.Parent = Parent
	
	local ListLayout = Instance.new("UIListLayout")
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.Padding = UDim.new(0, 6)
	ListLayout.Parent = ScrollFrame
	
	-- Auto-update canvas size
	ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 12)
	end)
	
	return ScrollFrame
end

-- Notification System
local NotificationContainer = nil

local function CreateNotification(Title, Message, Type, Duration)
	if not NotificationContainer then
		NotificationContainer = Instance.new("ScreenGui")
		NotificationContainer.Name = "ModernTwinkNotifications"
		NotificationContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		NotificationContainer.Parent = RunService:IsStudio() and Player:WaitForChild("PlayerGui") or CoreGuiService
		
		local Container = Instance.new("Frame")
		Container.Name = "Container"
		Container.BackgroundTransparency = 1
		Container.Size = UDim2.new(0, 300, 1, -20)
		Container.Position = UDim2.new(1, -310, 0, 10)
		Container.Parent = NotificationContainer
		
		local Layout = Instance.new("UIListLayout")
		Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Padding = UDim.new(0, 10)
		Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		Layout.Parent = Container
	end
	
	Duration = Duration or 5
	Type = Type or "Info"
	
	local TypeColors = {
		Success = Config.Colors.Success,
		Error = Config.Colors.Danger,
		Warning = Config.Colors.Warning,
		Info = Config.Colors.Primary,
	}
	
	local AccentColor = TypeColors[Type] or Config.Colors.Primary
	
	local NotifFrame = CreateRoundBox(8, NotificationContainer.Container)
	NotifFrame.Size = UDim2.new(1, 0, 0, 0)
	NotifFrame.BackgroundColor3 = Config.Colors.Surface
	NotifFrame.ClipsDescendants = true
	
	CreateStroke(AccentColor, 2, NotifFrame)
	
	local Accent = Instance.new("Frame")
	Accent.BackgroundColor3 = AccentColor
	Accent.BorderSizePixel = 0
	Accent.Size = UDim2.new(0, 4, 1, 0)
	Accent.Parent = NotifFrame
	
	local ContentFrame = Instance.new("Frame")
	ContentFrame.BackgroundTransparency = 1
	ContentFrame.Size = UDim2.new(1, -20, 1, -16)
	ContentFrame.Position = UDim2.new(0, 12, 0, 8)
	ContentFrame.Parent = NotifFrame
	
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Text = Title
	TitleLabel.Font = Config.Fonts.Primary
	TitleLabel.TextSize = 14
	TitleLabel.TextColor3 = Config.Colors.Text
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Size = UDim2.new(1, 0, 0, 16)
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = ContentFrame
	
	local MessageLabel = Instance.new("TextLabel")
	MessageLabel.Text = Message
	MessageLabel.Font = Config.Fonts.Secondary
	MessageLabel.TextSize = 12
	MessageLabel.TextColor3 = Config.Colors.TextSecondary
	MessageLabel.BackgroundTransparency = 1
	MessageLabel.Size = UDim2.new(1, 0, 1, -20)
	MessageLabel.Position = UDim2.new(0, 0, 0, 20)
	MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
	MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
	MessageLabel.TextWrapped = true
	MessageLabel.Parent = ContentFrame
	
	-- Calculate required height
	local TextHeight = TextService:GetTextSize(
		Message,
		12,
		Config.Fonts.Secondary,
		Vector2.new(ContentFrame.AbsoluteSize.X, math.huge)
	).Y
	
	local RequiredHeight = math.max(60, TextHeight + 40)
	
	Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, RequiredHeight)}, 0.3)
	
	-- Auto-dismiss
	task.delay(Duration, function()
		Tween(NotifFrame, {
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1
		}, 0.3)
		
		task.wait(0.3)
		NotifFrame:Destroy()
	end)
end

-- Main Library
local ModernTwinkUI = {}

function ModernTwinkUI.Load(Title, Options)
	Options = Options or {}
	local Theme = Options.Theme or "Dark"
	local Size = Options.Size or {Width = 550, Height = 400}
	
	-- Destroy old instance if exists
	local TargetParent = RunService:IsStudio() and Player:WaitForChild("PlayerGui") or CoreGuiService
	local OldInstance = TargetParent:FindFirstChild(Title)
	if OldInstance then
		OldInstance:Destroy()
	end
	
	-- Create main ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = Title
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = TargetParent
	
	-- Main container
	local MainContainer = Instance.new("Frame")
	MainContainer.Name = "MainContainer"
	MainContainer.BackgroundTransparency = 1
	MainContainer.Size = UDim2.new(0, Size.Width, 0, Size.Height)
	MainContainer.Position = UDim2.new(0.5, -Size.Width/2, 0.5, -Size.Height/2)
	MainContainer.Parent = ScreenGui
	
	CreateShadow(MainContainer)
	
	ZIndex = ZIndex + 1
	
	-- Main frame
	local MainFrame = CreateRoundBox(12, MainContainer)
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(1, 0, 1, 0)
	MainFrame.BackgroundColor3 = Config.Colors.Background
	MainFrame.ClipsDescendants = true
	
	CreateStroke(Config.Colors.Border, 1, MainFrame)
	
	-- Title bar
	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.BackgroundColor3 = Config.Colors.Surface
	TitleBar.BorderSizePixel = 0
	TitleBar.Size = UDim2.new(1, 0, 0, 40)
	TitleBar.Parent = MainFrame
	
	-- Title gradient
	local TitleGradient = Instance.new("UIGradient")
	TitleGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Config.Colors.Surface),
		ColorSequenceKeypoint.new(1, Config.Colors.Background)
	}
	TitleGradient.Rotation = 90
	TitleGradient.Parent = TitleBar
	
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Text = Title
	TitleLabel.Font = Config.Fonts.Primary
	TitleLabel.TextSize = 16
	TitleLabel.TextColor3 = Config.Colors.Text
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Size = UDim2.new(1, -100, 1, 0)
	TitleLabel.Position = UDim2.new(0, 16, 0, 0)
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = TitleBar
	
	-- Close button
	local CloseButton = CreateRoundBox(6, TitleBar)
	CloseButton.Name = "CloseButton"
	CloseButton.Size = UDim2.new(0, 28, 0, 28)
	CloseButton.Position = UDim2.new(1, -34, 0.5, -14)
	CloseButton.BackgroundColor3 = Config.Colors.Surface
	
	local CloseIcon = CreateTextLabel("✕", 16, Config.Fonts.Primary, CloseButton)
	CloseIcon.TextColor3 = Config.Colors.Text
	CloseIcon.TextXAlignment = Enum.TextXAlignment.Center
	
	local CloseBtn = CreateTextButton("", nil, nil, CloseButton)
	CloseBtn.MouseEnter:Connect(function()
		Tween(CloseButton, {BackgroundColor3 = Config.Colors.Danger})
	end)
	CloseBtn.MouseLeave:Connect(function()
		Tween(CloseButton, {BackgroundColor3 = Config.Colors.Surface})
	end)
	CloseBtn.MouseButton1Click:Connect(function()
		Tween(MainContainer, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
		task.wait(0.3)
		ScreenGui:Destroy()
	end)
	
	-- Minimize button
	local MinimizeButton = CreateRoundBox(6, TitleBar)
	MinimizeButton.Name = "MinimizeButton"
	MinimizeButton.Size = UDim2.new(0, 28, 0, 28)
	MinimizeButton.Position = UDim2.new(1, -66, 0.5, -14)
	MinimizeButton.BackgroundColor3 = Config.Colors.Surface
	
	local MinimizeIcon = CreateTextLabel("−", 18, Config.Fonts.Primary, MinimizeButton)
	MinimizeIcon.TextColor3 = Config.Colors.Text
	MinimizeIcon.TextXAlignment = Enum.TextXAlignment.Center
	
	local MinimizeBtn = CreateTextButton("", nil, nil, MinimizeButton)
	local IsMinimized = false
	MinimizeBtn.MouseEnter:Connect(function()
		Tween(MinimizeButton, {BackgroundColor3 = Config.Colors.SurfaceHover})
	end)
	MinimizeBtn.MouseLeave:Connect(function()
		Tween(MinimizeButton, {BackgroundColor3 = Config.Colors.Surface})
	end)
	MinimizeBtn.MouseButton1Click:Connect(function()
		IsMinimized = not IsMinimized
		if IsMinimized then
			Tween(MainContainer, {Size = UDim2.new(0, Size.Width, 0, 40)}, 0.3)
		else
			Tween(MainContainer, {Size = UDim2.new(0, Size.Width, 0, Size.Height)}, 0.3)
		end
	end)
	
	-- Dragging
	local Dragging, DragInput, DragStart, StartPos
	
	TitleBar.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			DragStart = Input.Position
			StartPos = MainContainer.Position
			
			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)
	
	TitleBar.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			DragInput = Input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(Input)
		if Input == DragInput and Dragging then
			local Delta = Input.Position - DragStart
			MainContainer.Position = UDim2.new(
				StartPos.X.Scale,
				StartPos.X.Offset + Delta.X,
				StartPos.Y.Scale,
				StartPos.Y.Offset + Delta.Y
			)
		end
	end)
	
	-- Content area
	local ContentFrame = Instance.new("Frame")
	ContentFrame.Name = "ContentFrame"
	ContentFrame.BackgroundTransparency = 1
	ContentFrame.Size = UDim2.new(1, 0, 1, -40)
	ContentFrame.Position = UDim2.new(0, 0, 0, 40)
	ContentFrame.Parent = MainFrame
	
	-- Sidebar
	local Sidebar = CreateRoundBox(0, ContentFrame)
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 140, 1, -16)
	Sidebar.Position = UDim2.new(0, 8, 0, 8)
	Sidebar.BackgroundColor3 = Config.Colors.Surface
	
	local SidebarScroll = CreateScrollingFrame(Sidebar)
	SidebarScroll.Size = UDim2.new(1, -12, 1, -12)
	SidebarScroll.Position = UDim2.new(0, 6, 0, 6)
	
	-- Display area
	local DisplayFrame = CreateRoundBox(0, ContentFrame)
	DisplayFrame.Name = "DisplayFrame"
	DisplayFrame.Size = UDim2.new(1, -164, 1, -16)
	DisplayFrame.Position = UDim2.new(0, 156, 0, 8)
	DisplayFrame.BackgroundColor3 = Config.Colors.Surface
	
	-- Tab system
	local TabLibrary = {}
	TabLibrary.Tabs = {}
	TabLibrary.ActiveTab = nil
	
	function TabLibrary.AddPage(PageName, Icon)
		local PageData = {}
		PageData.Name = PageName
		
		-- Tab button in sidebar
		local TabButton = CreateRoundBox(6, SidebarScroll)
		TabButton.Name = PageName.."Tab"
		TabButton.Size = UDim2.new(1, -8, 0, 36)
		TabButton.BackgroundColor3 = Config.Colors.Background
		
		local TabIcon = Instance.new("TextLabel")
		TabIcon.Text = Icon or "📄"
		TabIcon.Font = Config.Fonts.Secondary
		TabIcon.TextSize = 16
		TabIcon.BackgroundTransparency = 1
		TabIcon.Size = UDim2.new(0, 24, 1, 0)
		TabIcon.Position = UDim2.new(0, 8, 0, 0)
		TabIcon.TextXAlignment = Enum.TextXAlignment.Left
		TabIcon.Parent = TabButton
		
		local TabLabel = CreateTextLabel(PageName, 13, Config.Fonts.Secondary, TabButton)
		TabLabel.Position = UDim2.new(0, 36, 0, 0)
		TabLabel.Size = UDim2.new(1, -36, 1, 0)
		
		local TabBtn = CreateTextButton("", nil, nil, TabButton)
		
		-- Page content
		local PageScroll = CreateScrollingFrame(DisplayFrame)
		PageScroll.Name = PageName.."Content"
		PageScroll.Size = UDim2.new(1, -16, 1, -16)
		PageScroll.Position = UDim2.new(0, 8, 0, 8)
		PageScroll.Visible = false
		
		local function SelectTab()
			-- Deselect all tabs
			for _, Tab in pairs(TabLibrary.Tabs) do
				Tab.Button.BackgroundColor3 = Config.Colors.Background
				Tab.Content.Visible = false
			end
			
			-- Select this tab
			TabButton.BackgroundColor3 = Config.Colors.Primary
			PageScroll.Visible = true
			TabLibrary.ActiveTab = PageData
		end
		
		TabBtn.MouseEnter:Connect(function()
			if TabLibrary.ActiveTab ~= PageData then
				Tween(TabButton, {BackgroundColor3 = Config.Colors.SurfaceHover})
			end
		end)
		
		TabBtn.MouseLeave:Connect(function()
			if TabLibrary.ActiveTab ~= PageData then
				Tween(TabButton, {BackgroundColor3 = Config.Colors.Background})
			end
		end)
		
		TabBtn.MouseButton1Click:Connect(function()
			local X, Y = GetXY(TabButton)
			RippleEffect(TabButton, X, Y)
			SelectTab()
		end)
		
		PageData.Button = TabButton
		PageData.Content = PageScroll
		PageData.SelectTab = SelectTab
		
		table.insert(TabLibrary.Tabs, PageData)
		
		-- Select first tab by default
		if #TabLibrary.Tabs == 1 then
			SelectTab()
		end
		
		-- Page element library
		local PageLibrary = {}
		
		function PageLibrary.AddLabel(Text, Options)
			Options = Options or {}
			local Size = Options.Size or 14
			local Color = Options.Color or Config.Colors.Text
			
			local LabelContainer = Instance.new("Frame")
			LabelContainer.Name = Text.."Label"
			LabelContainer.BackgroundTransparency = 1
			LabelContainer.Size = UDim2.new(1, -8, 0, 30)
			LabelContainer.Parent = PageScroll
			
			local Label = Instance.new("TextLabel")
			Label.Text = Text
			Label.Font = Config.Fonts.Primary
			Label.TextSize = Size
			Label.TextColor3 = Color
			Label.BackgroundTransparency = 1
			Label.Size = UDim2.new(1, 0, 1, 0)
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = LabelContainer
			
			local Divider = Instance.new("Frame")
			Divider.BackgroundColor3 = Config.Colors.Border
			Divider.BorderSizePixel = 0
			Divider.Size = UDim2.new(1, 0, 0, 1)
			Divider.Position = UDim2.new(0, 0, 1, -1)
			Divider.Parent = LabelContainer
			
			return LabelContainer
		end
		
		function PageLibrary.AddButton(Text, Callback, Options)
			Options = Options or {}
			local Color = Options.Color or Config.Colors.Primary
			
			local ButtonContainer = CreateRoundBox(6, PageScroll)
			ButtonContainer.Name = Text.."Button"
			ButtonContainer.Size = UDim2.new(1, -8, 0, 36)
			ButtonContainer.BackgroundColor3 = Color
			
			local ButtonLabel = CreateTextLabel(Text, 14, Config.Fonts.Secondary, ButtonContainer)
			ButtonLabel.TextXAlignment = Enum.TextXAlignment.Center
			
			local Button = CreateTextButton("", nil, nil, ButtonContainer)
			
			Button.MouseEnter:Connect(function()
				Tween(ButtonContainer, {BackgroundColor3 = Config.Colors.PrimaryHover})
			end)
			
			Button.MouseLeave:Connect(function()
				Tween(ButtonContainer, {BackgroundColor3 = Color})
			end)
			
			Button.MouseButton1Click:Connect(function()
				local X, Y = GetXY(ButtonContainer)
				RippleEffect(ButtonContainer, X, Y)
				if Callback then
					Callback()
				end
			end)
			
			return ButtonContainer
		end
		
		function PageLibrary.AddToggle(Text, Default, Callback, Options)
			Options = Options or {}
			local State = Default or false
			
			local ToggleContainer = CreateRoundBox(6, PageScroll)
			ToggleContainer.Name = Text.."Toggle"
			ToggleContainer.Size = UDim2.new(1, -8, 0, 36)
			ToggleContainer.BackgroundColor3 = Config.Colors.Background
			
			local ToggleLabel = CreateTextLabel(Text, 14, Config.Fonts.Secondary, ToggleContainer)
			ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
			ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
			
			local ToggleFrame = CreateRoundBox(12, ToggleContainer)
			ToggleFrame.Size = UDim2.new(0, 48, 0, 24)
			ToggleFrame.Position = UDim2.new(1, -54, 0.5, -12)
			ToggleFrame.BackgroundColor3 = State and Config.Colors.Success or Config.Colors.Border
			
			local ToggleKnob = CreateRoundBox(10, ToggleFrame)
			ToggleKnob.Size = UDim2.new(0, 20, 0, 20)
			ToggleKnob.Position = State and UDim2.new(0, 26, 0, 2) or UDim2.new(0, 2, 0, 2)
			ToggleKnob.BackgroundColor3 = Config.Colors.Text
			
			local ToggleButton = CreateTextButton("", nil, nil, ToggleContainer)
			
			ToggleButton.MouseButton1Click:Connect(function()
				State = not State
				
				Tween(ToggleFrame, {
					BackgroundColor3 = State and Config.Colors.Success or Config.Colors.Border
				})
				
				Tween(ToggleKnob, {
					Position = State and UDim2.new(0, 26, 0, 2) or UDim2.new(0, 2, 0, 2)
				})
				
				if Callback then
					Callback(State)
				end
			end)
			
			local ToggleAPI = {}
			function ToggleAPI:SetValue(Value)
				State = Value
				Tween(ToggleFrame, {
					BackgroundColor3 = State and Config.Colors.Success or Config.Colors.Border
				})
				Tween(ToggleKnob, {
					Position = State and UDim2.new(0, 26, 0, 2) or UDim2.new(0, 2, 0, 2)
				})
			end
			
			return ToggleAPI
		end
		
		function PageLibrary.AddSlider(Text, Config, Callback, Options)
			Options = Options or {}
			local Min = Config.Min or Config.Minimum or 0
			local Max = Config.Max or Config.Maximum or 100
			local Default = Config.Default or Config.Def or Min
			local Increment = Config.Increment or 1
			
			Default = math.clamp(Default, Min, Max)
			
			local SliderContainer = CreateRoundBox(6, PageScroll)
			SliderContainer.Name = Text.."Slider"
			SliderContainer.Size = UDim2.new(1, -8, 0, 50)
			SliderContainer.BackgroundColor3 = Config.Colors.Background
			
			local SliderLabel = CreateTextLabel(Text, 14, Config.Fonts.Secondary, SliderContainer)
			SliderLabel.Size = UDim2.new(1, -70, 0, 20)
			SliderLabel.Position = UDim2.new(0, 12, 0, 8)
			
			local ValueLabel = CreateTextLabel(tostring(Default), 14, Config.Fonts.Primary, SliderContainer)
			ValueLabel.Size = UDim2.new(0, 60, 0, 20)
			ValueLabel.Position = UDim2.new(1, -66, 0, 8)
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValueLabel.TextColor3 = Config.Colors.Primary
			
			local SliderTrack = CreateRoundBox(4, SliderContainer)
			SliderTrack.Size = UDim2.new(1, -24, 0, 8)
			SliderTrack.Position = UDim2.new(0, 12, 1, -18)
			SliderTrack.BackgroundColor3 = Config.Colors.Border
			
			local SliderFill = CreateRoundBox(4, SliderTrack)
			SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
			SliderFill.BackgroundColor3 = Config.Colors.Primary
			
			local SliderButton = CreateTextButton("", nil, nil, SliderTrack)
			
			local function UpdateSlider(Input)
				local X = math.clamp(Input.Position.X - SliderTrack.AbsolutePosition.X, 0, SliderTrack.AbsoluteSize.X)
				local Percentage = X / SliderTrack.AbsoluteSize.X
				local Value = math.floor(Min + (Max - Min) * Percentage)
				Value = math.floor(Value / Increment + 0.5) * Increment
				Value = math.clamp(Value, Min, Max)
				
				ValueLabel.Text = tostring(Value)
				Tween(SliderFill, {Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)}, 0.1)
				
				if Callback then
					Callback(Value)
				end
			end
			
			local Dragging = false
			
			SliderButton.MouseButton1Down:Connect(function()
				Dragging = true
				UpdateSlider({Position = Mouse})
			end)
			
			UserInputService.InputEnded:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = false
				end
			end)
			
			UserInputService.InputChanged:Connect(function(Input)
				if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
					UpdateSlider(Input)
				end
			end)
			
			return SliderContainer
		end
		
		function PageLibrary.AddInput(Text, Placeholder, Callback, Options)
			Options = Options or {}
			local Numeric = Options.Numeric or false
			
			local InputContainer = CreateRoundBox(6, PageScroll)
			InputContainer.Name = Text.."Input"
			InputContainer.Size = UDim2.new(1, -8, 0, 50)
			InputContainer.BackgroundColor3 = Config.Colors.Background
			
			local InputLabel = CreateTextLabel(Text, 14, Config.Fonts.Secondary, InputContainer)
			InputLabel.Size = UDim2.new(1, -16, 0, 20)
			InputLabel.Position = UDim2.new(0, 12, 0, 6)
			
			local InputBox = CreateRoundBox(4, InputContainer)
			InputBox.Size = UDim2.new(1, -24, 0, 24)
			InputBox.Position = UDim2.new(0, 12, 1, -28)
			InputBox.BackgroundColor3 = Config.Colors.Surface
			
			CreateStroke(Config.Colors.Border, 1, InputBox)
			
			local TextBox = Instance.new("TextBox")
			TextBox.PlaceholderText = Placeholder or ""
			TextBox.Text = ""
			TextBox.Font = Config.Fonts.Secondary
			TextBox.TextSize = 13
			TextBox.TextColor3 = Config.Colors.Text
			TextBox.PlaceholderColor3 = Config.Colors.TextSecondary
			TextBox.BackgroundTransparency = 1
			TextBox.Size = UDim2.new(1, -16, 1, 0)
			TextBox.Position = UDim2.new(0, 8, 0, 0)
			TextBox.TextXAlignment = Enum.TextXAlignment.Left
			TextBox.ClearTextOnFocus = false
			TextBox.Parent = InputBox
			
			if Numeric then
				TextBox.TextChanged:Connect(function()
					TextBox.Text = TextBox.Text:gsub("[^%d.]", "")
				end)
			end
			
			TextBox.FocusLost:Connect(function()
				if Callback then
					Callback(TextBox.Text)
				end
			end)
			
			return InputContainer
		end
		
		function PageLibrary.AddDropdown(Text, Items, Callback, Options)
			Options = Options or {}
			local Default = Options.Default
			local SelectedItem = Default or (Items[1] or "None")
			
			local DropdownContainer = CreateRoundBox(6, PageScroll)
			DropdownContainer.Name = Text.."Dropdown"
			DropdownContainer.Size = UDim2.new(1, -8, 0, 36)
			DropdownContainer.BackgroundColor3 = Config.Colors.Background
			DropdownContainer.ClipsDescendants = true
			
			local DropdownLabel = CreateTextLabel(Text, 14, Config.Fonts.Secondary, DropdownContainer)
			DropdownLabel.Size = UDim2.new(1, -40, 0, 36)
			DropdownLabel.Position = UDim2.new(0, 12, 0, 0)
			
			local DropdownValue = CreateTextLabel(SelectedItem, 13, Config.Fonts.Secondary, DropdownContainer)
			DropdownValue.Size = UDim2.new(0, 120, 0, 36)
			DropdownValue.Position = UDim2.new(1, -136, 0, 0)
			DropdownValue.TextXAlignment = Enum.TextXAlignment.Right
			DropdownValue.TextColor3 = Config.Colors.TextSecondary
			
			local DropdownIcon = CreateTextLabel("▼", 10, Config.Fonts.Secondary, DropdownContainer)
			DropdownIcon.Size = UDim2.new(0, 24, 0, 36)
			DropdownIcon.Position = UDim2.new(1, -28, 0, 0)
			DropdownIcon.TextColor3 = Config.Colors.TextSecondary
			DropdownIcon.TextXAlignment = Enum.TextXAlignment.Center
			
			local DropdownButton = CreateTextButton("", nil, nil, DropdownContainer)
			DropdownButton.Size = UDim2.new(1, 0, 0, 36)
			
			local ItemsFrame = Instance.new("Frame")
			ItemsFrame.BackgroundTransparency = 1
			ItemsFrame.Size = UDim2.new(1, 0, 0, 0)
			ItemsFrame.Position = UDim2.new(0, 0, 0, 36)
			ItemsFrame.Parent = DropdownContainer
			
			local ItemsList = Instance.new("UIListLayout")
			ItemsList.SortOrder = Enum.SortOrder.LayoutOrder
			ItemsList.Parent = ItemsFrame
			
			local IsOpen = false
			
			for _, Item in ipairs(Items) do
				local ItemButton = CreateRoundBox(0, ItemsFrame)
				ItemButton.Size = UDim2.new(1, 0, 0, 32)
				ItemButton.BackgroundColor3 = Config.Colors.Surface
				
				local ItemLabel = CreateTextLabel(Item, 13, Config.Fonts.Secondary, ItemButton)
				ItemLabel.Position = UDim2.new(0, 12, 0, 0)
				
				local ItemBtn = CreateTextButton("", nil, nil, ItemButton)
				
				ItemBtn.MouseEnter:Connect(function()
					Tween(ItemButton, {BackgroundColor3 = Config.Colors.SurfaceHover})
				end)
				
				ItemBtn.MouseLeave:Connect(function()
					Tween(ItemButton, {BackgroundColor3 = Config.Colors.Surface})
				end)
				
				ItemBtn.MouseButton1Click:Connect(function()
					SelectedItem = Item
					DropdownValue.Text = Item
					
					IsOpen = false
					Tween(DropdownContainer, {Size = UDim2.new(1, -8, 0, 36)}, 0.2)
					Tween(DropdownIcon, {Rotation = 0}, 0.2)
					
					if Callback then
						Callback(Item)
					end
				end)
			end
			
			DropdownButton.MouseButton1Click:Connect(function()
				IsOpen = not IsOpen
				
				if IsOpen then
					local Height = 36 + (#Items * 32)
					Tween(DropdownContainer, {Size = UDim2.new(1, -8, 0, Height)}, 0.2)
					Tween(DropdownIcon, {Rotation = 180}, 0.2)
				else
					Tween(DropdownContainer, {Size = UDim2.new(1, -8, 0, 36)}, 0.2)
					Tween(DropdownIcon, {Rotation = 0}, 0.2)
				end
			end)
			
			return DropdownContainer
		end
		
		function PageLibrary.AddColorPicker(Text, Default, Callback, Options)
			Options = Options or {}
			local CurrentColor = Default or Color3.fromRGB(255, 255, 255)
			
			if typeof(CurrentColor) == "string" then
				local ColorDictionary = {
					white = Color3.fromRGB(255,255,255),
					black = Color3.fromRGB(0,0,0),
					red = Color3.fromRGB(255,0,0),
					green = Color3.fromRGB(0,255,0),
					blue = Color3.fromRGB(0,0,255)
				}
				CurrentColor = ColorDictionary[CurrentColor:lower()] or Color3.fromRGB(255,255,255)
			end
			
			local PickerContainer = CreateRoundBox(6, PageScroll)
			PickerContainer.Name = Text.."ColorPicker"
			PickerContainer.Size = UDim2.new(1, -8, 0, 36)
			PickerContainer.BackgroundColor3 = Config.Colors.Background
			PickerContainer.ClipsDescendants = true
			
			local PickerLabel = CreateTextLabel(Text, 14, Config.Fonts.Secondary, PickerContainer)
			PickerLabel.Size = UDim2.new(1, -60, 0, 36)
			PickerLabel.Position = UDim2.new(0, 12, 0, 0)
			
			local ColorDisplay = CreateRoundBox(6, PickerContainer)
			ColorDisplay.Size = UDim2.new(0, 44, 0, 24)
			ColorDisplay.Position = UDim2.new(1, -52, 0.5, -12)
			ColorDisplay.BackgroundColor3 = CurrentColor
			
			CreateStroke(Config.Colors.Border, 1, ColorDisplay)
			
			local ColorButton = CreateTextButton("", nil, nil, ColorDisplay)
			
			local IsOpen = false
			
			local PickerFrame = Instance.new("Frame")
			PickerFrame.BackgroundTransparency = 1
			PickerFrame.Size = UDim2.new(1, -16, 0, 0)
			PickerFrame.Position = UDim2.new(0, 8, 0, 44)
			PickerFrame.Parent = PickerContainer
			
			-- RGB Sliders
			local RSlider = PageLibrary.AddSlider("R", {
				Min = 0, Max = 255,
				Def = math.floor(CurrentColor.R * 255)
			}, function(Value)
				CurrentColor = Color3.fromRGB(Value, CurrentColor.G * 255, CurrentColor.B * 255)
				ColorDisplay.BackgroundColor3 = CurrentColor
				if Callback then Callback(CurrentColor) end
			end, {Parent = PickerFrame})
			RSlider.Parent = PickerFrame
			RSlider.Visible = false
			
			local GSlider = PageLibrary.AddSlider("G", {
				Min = 0, Max = 255,
				Def = math.floor(CurrentColor.G * 255)
			}, function(Value)
				CurrentColor = Color3.fromRGB(CurrentColor.R * 255, Value, CurrentColor.B * 255)
				ColorDisplay.BackgroundColor3 = CurrentColor
				if Callback then Callback(CurrentColor) end
			end, {Parent = PickerFrame})
			GSlider.Parent = PickerFrame
			GSlider.Visible = false
			
			local BSlider = PageLibrary.AddSlider("B", {
				Min = 0, Max = 255,
				Def = math.floor(CurrentColor.B * 255)
			}, function(Value)
				CurrentColor = Color3.fromRGB(CurrentColor.R * 255, CurrentColor.G * 255, Value)
				ColorDisplay.BackgroundColor3 = CurrentColor
				if Callback then Callback(CurrentColor) end
			end, {Parent = PickerFrame})
			BSlider.Parent = PickerFrame
			BSlider.Visible = false
			
			ColorButton.MouseButton1Click:Connect(function()
				IsOpen = not IsOpen
				
				RSlider.Visible = IsOpen
				GSlider.Visible = IsOpen
				BSlider.Visible = IsOpen
				
				if IsOpen then
					Tween(PickerContainer, {Size = UDim2.new(1, -8, 0, 200)}, 0.3)
				else
					Tween(PickerContainer, {Size = UDim2.new(1, -8, 0, 36)}, 0.3)
				end
			end)
			
			return PickerContainer
		end
		
		function PageLibrary.AddKeybind(Text, Default, Callback, Options)
			Options = Options or {}
			local CurrentKey = Default or Enum.KeyCode.E
			
			local KeybindContainer = CreateRoundBox(6, PageScroll)
			KeybindContainer.Name = Text.."Keybind"
			KeybindContainer.Size = UDim2.new(1, -8, 0, 36)
			KeybindContainer.BackgroundColor3 = Config.Colors.Background
			
			local KeybindLabel = CreateTextLabel(Text, 14, Config.Fonts.Secondary, KeybindContainer)
			KeybindLabel.Size = UDim2.new(1, -100, 1, 0)
			KeybindLabel.Position = UDim2.new(0, 12, 0, 0)
			
			local KeyDisplay = CreateRoundBox(6, KeybindContainer)
			KeyDisplay.Size = UDim2.new(0, 80, 0, 24)
			KeyDisplay.Position = UDim2.new(1, -88, 0.5, -12)
			KeyDisplay.BackgroundColor3 = Config.Colors.Surface
			
			CreateStroke(Config.Colors.Border, 1, KeyDisplay)
			
			local KeyLabel = CreateTextLabel(CurrentKey.Name, 12, Config.Fonts.Secondary, KeyDisplay)
			KeyLabel.TextXAlignment = Enum.TextXAlignment.Center
			KeyLabel.TextColor3 = Config.Colors.TextSecondary
			
			local KeyButton = CreateTextButton("", nil, nil, KeyDisplay)
			local IsListening = false
			
			KeyButton.MouseButton1Click:Connect(function()
				IsListening = true
				KeyLabel.Text = "..."
				KeyDisplay.BackgroundColor3 = Config.Colors.Primary
			end)
			
			UserInputService.InputBegan:Connect(function(Input, GameProcessed)
				if IsListening and Input.UserInputType == Enum.UserInputType.Keyboard then
					CurrentKey = Input.KeyCode
					KeyLabel.Text = CurrentKey.Name
					KeyDisplay.BackgroundColor3 = Config.Colors.Surface
					IsListening = false
				elseif not GameProcessed and Input.KeyCode == CurrentKey then
					if Callback then
						Callback()
					end
				end
			end)
			
			return KeybindContainer
		end
		
		function PageLibrary.AddDivider()
			local Divider = Instance.new("Frame")
			Divider.Name = "Divider"
			Divider.BackgroundColor3 = Config.Colors.Border
			Divider.BorderSizePixel = 0
			Divider.Size = UDim2.new(1, -8, 0, 1)
			Divider.Parent = PageScroll
			
			return Divider
		end
		
		return PageLibrary
	end
	
	-- Notification function
	function TabLibrary.Notify(Title, Message, Type, Duration)
		CreateNotification(Title, Message, Type, Duration)
	end
	
	return TabLibrary
end

return ModernTwinkUI
