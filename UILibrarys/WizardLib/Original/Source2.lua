local _L0_1_0 = game:GetService("UserInputService")
local _L1_1_0 = game:GetService("TweenService")
local _L2_1_0 = game:GetService("RunService")
local _L3_1_0 = game:GetService("Players")
local _L3_1_1 = _L3_1_0.LocalPlayer:GetMouse()
local _L9_1_0 = game:GetService("CoreGui")
local _L9_1_1 = _L9_1_0:FindFirstChild("WizardLibrary")

if not _L9_1_1 then
else
  local _L9_1_2 = game:GetService("CoreGui")
  
  local _L9_1_3 = _L9_1_2:FindFirstChild("WizardLibrary")
  _L9_1_3:Destroy()
end
local _L9_1_4 = Instance.new("ScreenGui")
local _L10_1_0 = Instance.new("Frame")

_L9_1_4.Name = "WizardLibrary"
local _L11_1_0 = game:GetService("CoreGui")

_L9_1_4.Parent = _L11_1_0

_L10_1_0.Name = "Container"
_L10_1_0.Parent = _L9_1_4
local _L11_1_1 = Color3.new(1, 1, 1)

_L10_1_0.BackgroundColor3 = _L11_1_1
_L10_1_0.BackgroundTransparency = 1
local _L11_1_2 = UDim2.new(0, 100, 0, 100)

_L10_1_0.Size = _L11_1_2

_L0_1_0.InputBegan:Connect(function(_A0_2_0)
  if _A0_2_0.KeyCode == Enum.KeyCode.RightControl then
    CoastifiedLibrary.Enabled = not CoastifiedLibrary.Enabled
  end
end)

function Dragging(_A0_2_0)
  _A0_2_0.InputBegan:Connect(function(_A0_3_0)
    if _A0_3_0.UserInputType == Enum.UserInputType.MouseButton1 then
    elseif _A0_3_0.UserInputType ~= Enum.UserInputType.Touch then
      goto lbl_28
    end
    _UPVALUE_0_ = true
    _UPVALUE_1_ = _A0_3_0.Position
    _UPVALUE_2_ = _A0_2_0.Position
    
    _A0_3_0.Changed:Connect(function()
      if _A0_3_0.UserInputState == Enum.UserInputState.End then
        _UPVALUE_1_ = false
      end
    end)
    ::lbl_28::
  end)
  
  _A0_2_0.InputChanged:Connect(function(_A0_3_0)
    if _A0_3_0.UserInputType == Enum.UserInputType.MouseMovement then
    else
    end
    
    if _A0_3_0.UserInputType == Enum.UserInputType.Touch then
      _UPVALUE_0_ = _A0_3_0
    end
  end)
  
  _L0_1_0.InputChanged:Connect(function(_A0_3_0)
    if _A0_3_0 ~= _UPVALUE_0_ or not _UPVALUE_1_ then
    else
      _UPVALUE_2_(_A0_3_0)
    end
  end)
end

local _L12_1_0 = coroutine.wrap

local function _L13_1_0()
  while true do
    local _L0_2_0 = wait()
    
    if not _L0_2_0 then
      break
    end
    _UPVALUE_0_ = _UPVALUE_0_ + 0.00392156862745098
    
    if not (1 <= _UPVALUE_0_) then
    else
      _UPVALUE_0_ = 0
    end
  end
end

_L12_1_0(_L13_1_0)()

local _L12_1_1 = {}

function _L12_1_1.NewWindow(_A0_2_0, _A1_2_0)
  local _L2_2_0 = Instance.new("ImageLabel")
  local _L3_2_0 = Instance.new("Frame")
  local _L4_2_0 = Instance.new("TextButton")
  local _L5_2_0 = Instance.new("TextLabel")
  local _L6_2_0 = Instance.new("Frame")
  local _L7_2_0 = Instance.new("ImageLabel")
  local _L8_2_0 = Instance.new("UIListLayout")
  local _L9_2_0 = Instance.new("Frame")
  local _L10_2_0 = _L11_1_0(_A1_2_0)
  _UPVALUE_1_ = _UPVALUE_1_ + 2
  local _L11_2_0 = 35
  local _L15_2_0 = _L10_2_0 .. "Window"
  
  _L2_2_0.Name = _L15_2_0
  _L2_2_0.Parent = _L10_1_0
  local _L15_2_1 = Color3.new(0.0980392, 0.0980392, 0.0980392)
  
  _L2_2_0.BackgroundColor3 = _L15_2_1
  _L2_2_0.BackgroundTransparency = 1
  local _L15_2_2 = UDim2.new(_UPVALUE_1_, -100, 3, -265)
  
  _L2_2_0.Position = _L15_2_2
  local _L15_2_3 = UDim2.new(0, 170, 0, 30)
  
  _L2_2_0.Size = _L15_2_3
  _L2_2_0.ZIndex = 2
  _L2_2_0.Image = "rbxassetid://3570695787"
  local _L15_2_4 = Color3.new(0.0980392, 0.0980392, 0.0980392)
  
  _L2_2_0.ImageColor3 = _L15_2_4
  _L2_2_0.ScaleType = Enum.ScaleType.Slice
  local _L15_2_5 = Rect.new(100, 100, 100, 100)
  
  _L2_2_0.SliceCenter = _L15_2_5
  _L2_2_0.SliceScale = 0.05
  
  _L3_2_0.Name = "Topbar"
  _L3_2_0.Parent = _L2_2_0
  local _L15_2_6 = Color3.new(1, 1, 1)
  
  _L3_2_0.BackgroundColor3 = _L15_2_6
  _L3_2_0.BackgroundTransparency = 1
  _L3_2_0.BorderSizePixel = 0
  local _L15_2_7 = UDim2.new(0, 170, 0, 30)
  
  _L3_2_0.Size = _L15_2_7
  _L3_2_0.ZIndex = 2
  
  _L4_2_0.Name = "WindowToggle"
  _L4_2_0.Parent = _L3_2_0
  local _L15_2_8 = Color3.new(1, 1, 1)
  
  _L4_2_0.BackgroundColor3 = _L15_2_8
  _L4_2_0.BackgroundTransparency = 1
  local _L15_2_9 = UDim2.new(0.822450161, 0, 0, 0)
  
  _L4_2_0.Position = _L15_2_9
  local _L15_2_10 = UDim2.new(0, 30, 0, 30)
  
  _L4_2_0.Size = _L15_2_10
  _L4_2_0.ZIndex = 2
  _L4_2_0.Font = Enum.Font.SourceSansSemibold
  _L4_2_0.Text = "-"
  local _L15_2_11 = Color3.new(1, 1, 1)
  
  _L4_2_0.TextColor3 = _L15_2_11
  _L4_2_0.TextSize = 20
  _L4_2_0.TextWrapped = true
  
  _L4_2_0.MouseButton1Down:Connect(function()
    if _UPVALUE_0_ then
    else
      _UPVALUE_0_ = true
      
      _L1_3_0 = _L1_1_0
      local _L0_3_0 = _L1_1_0.Create
      local _L2_3_0 = _L4_2_0
      local _L3_3_0 = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
      
      local _L4_3_0 = {}
      
      _L4_3_0.TextTransparency = 1
      local _L0_3_1 = _L0_3_0(_L1_3_0, _L2_3_0, _L3_3_0, _L4_3_0)
      _L0_3_1:Play()
      _L4_2_0.Text = "-"
      
      _L4_2_0.TextSize = 20
      
      _L4_2_0.Visible = false
      
      while true do
        wait()
        
        if _L4_2_0.TextTransparency == 1 then
          break
        end
      end
      _L4_2_0.Visible = true
      _L1_3_1 = _L1_1_0
      local _L0_3_2 = _L1_1_0.Create
      local _L2_3_1 = _L4_2_0
      local _L3_3_1 = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
      
      local _L4_3_1 = {}
      
      _L4_3_1.TextTransparency = 0
      local _L0_3_3 = _L0_3_2(_L1_3_1, _L2_3_1, _L3_3_1, _L4_3_1)
      _L0_3_3:Play()
      
      goto lbl_115
    end
    
    if not _UPVALUE_0_ then
    else
      _UPVALUE_0_ = false
      
      _L1_3_2 = _L1_1_0
      local _L0_3_4 = _L1_1_0.Create
      local _L2_3_2 = _L4_2_0
      local _L3_3_2 = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
      
      local _L4_3_2 = {}
      
      _L4_3_2.TextTransparency = 1
      local _L0_3_5 = _L0_3_4(_L1_3_2, _L2_3_2, _L3_3_2, _L4_3_2)
      _L0_3_5:Play()
      _L4_2_0.Text = "v"
      
      _L4_2_0.TextSize = 14
      
      _L4_2_0.Visible = false
      
      repeat
        wait()
      until _L4_2_0.TextTransparency == 1
      _L4_2_0.Visible = true
      _L1_3_3 = _L1_1_0
      local _L0_3_6 = _L1_1_0.Create
      local _L2_3_3 = _L4_2_0
      local _L3_3_3 = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
      
      local _L4_3_3 = {}
      
      _L4_3_3.TextTransparency = 0
      local _L0_3_7 = _L0_3_6(_L1_3_3, _L2_3_3, _L3_3_3, _L4_3_3)
      _L0_3_7:Play()
    end
    ::lbl_115::
  end)
  _L5_2_0.Name = "WindowTitle"
  _L5_2_0.Parent = _L3_2_0
  local _L15_2_12 = Color3.new(1, 1, 1)
  
  _L5_2_0.BackgroundColor3 = _L15_2_12
  _L5_2_0.BackgroundTransparency = 1
  local _L15_2_13 = UDim2.new(0, 170, 0, 30)
  
  _L5_2_0.Size = _L15_2_13
  _L5_2_0.ZIndex = 2
  _L5_2_0.Font = Enum.Font.SourceSansBold
  _L5_2_0.Text = _A1_2_0
  local _L15_2_14 = Color3.new(1, 1, 1)
  
  _L5_2_0.TextColor3 = _L15_2_14
  _L5_2_0.TextSize = 17
  
  _L6_2_0.Name = "BottomRoundCover"
  _L6_2_0.Parent = _L3_2_0
  local _L15_2_15 = Color3.new(0.0980392, 0.0980392, 0.0980392)
  
  _L6_2_0.BackgroundColor3 = _L15_2_15
  _L6_2_0.BorderSizePixel = 0
  local _L15_2_16 = UDim2.new(0, 0, 0.833333313, 0)
  
  _L6_2_0.Position = _L15_2_16
  local _L15_2_17 = UDim2.new(0, 170, 0, 5)
  
  _L6_2_0.Size = _L15_2_17
  _L6_2_0.ZIndex = 2
  
  _L7_2_0.Name = "Body"
  _L7_2_0.Parent = _L2_2_0
  local _L15_2_18 = Color3.new(0.137255, 0.137255, 0.137255)
  
  _L7_2_0.BackgroundColor3 = _L15_2_18
  _L7_2_0.BackgroundTransparency = 1
  _L7_2_0.ClipsDescendants = true
  local _L15_2_19 = UDim2.new(0, 170, 0, _L11_2_0)
  
  _L7_2_0.Size = _L15_2_19
  _L7_2_0.Image = "rbxassetid://3570695787"
  local _L15_2_20 = Color3.new(0.137255, 0.137255, 0.137255)
  
  _L7_2_0.ImageColor3 = _L15_2_20
  _L7_2_0.ScaleType = Enum.ScaleType.Slice
  local _L15_2_21 = Rect.new(100, 100, 100, 100)
  
  _L7_2_0.SliceCenter = _L15_2_21
  _L7_2_0.SliceScale = 0.05
  
  _L8_2_0.Name = "Sorter"
  _L8_2_0.Parent = _L7_2_0
  _L8_2_0.SortOrder = Enum.SortOrder.LayoutOrder
  
  _L9_2_0.Name = "TopbarBodyCover"
  _L9_2_0.Parent = _L7_2_0
  local _L15_2_22 = Color3.new(1, 1, 1)
  
  _L9_2_0.BackgroundColor3 = _L15_2_22
  _L9_2_0.BackgroundTransparency = 1
  _L9_2_0.BorderSizePixel = 0
  local _L15_2_23 = UDim2.new(0, 170, 0, 30)
  
  _L9_2_0.Size = _L15_2_23
  Dragging(_L2_2_0)
  
  local _L15_2_24 = {}
  
  function _L15_2_24.NewSection(_A0_3_0, _A1_3_0)
    local _L2_3_0 = Instance.new("Frame")
    local _L3_3_0 = Instance.new("Frame")
    local _L4_3_0 = Instance.new("TextButton")
    local _L5_3_0 = Instance.new("TextLabel")
    local _L6_3_0 = Instance.new("UIListLayout")
    local _L7_3_0 = _L11_1_0(_A1_3_0)
    local _L9_3_0 = 30
    
    local function _L11_3_0(_A0_4_0)
      _L9_3_0 = _L9_3_0 + _A0_4_0
      _L2_4_0 = _L1_1_0
      local _L1_4_0 = _L1_1_0.Create
      local _L3_4_0 = _L2_3_0
      local _L4_4_0 = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
      
      local _L5_4_0 = {}
      
      _L5_4_0.Size = UDim2.new(0, 170, 0, _L9_3_0)
      local _L1_4_1 = _L1_4_0(_L2_4_0, _L3_4_0, _L4_4_0, _L5_4_0)
      _L1_4_1:Play()
    end
    
    local function _L12_3_0(_A0_4_0)
      _L9_3_0 = _L9_3_0 - _A0_4_0
      _L2_4_0 = _L1_1_0
      local _L1_4_0 = _L1_1_0.Create
      local _L3_4_0 = _L2_3_0
      local _L4_4_0 = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
      
      local _L5_4_0 = {}
      
      _L5_4_0.Size = UDim2.new(0, 170, 0, _L9_3_0)
      local _L1_4_1 = _L1_4_0(_L2_4_0, _L3_4_0, _L4_4_0, _L5_4_0)
      _L1_4_1:Play()
    end
    
    local _L13_3_0 = _L7_3_0 .. "Section"
    
    _L2_3_0.Name = _L13_3_0
    _L2_3_0.Parent = _L7_2_0
    local _L13_3_1 = Color3.new(0.176471, 0.176471, 0.176471)
    
    _L2_3_0.BackgroundColor3 = _L13_3_1
    _L2_3_0.BorderSizePixel = 0
    _L2_3_0.ClipsDescendants = true
    local _L13_3_2 = UDim2.new(0, 170, 0, _L9_3_0)
    
    _L2_3_0.Size = _L13_3_2
    _UPVALUE_3_(30)
    _L3_3_0.Name = "SectionInfo"
    _L3_3_0.Parent = _L2_3_0
    local _L13_3_3 = Color3.new(1, 1, 1)
    
    _L3_3_0.BackgroundColor3 = _L13_3_3
    _L3_3_0.BackgroundTransparency = 1
    local _L13_3_4 = UDim2.new(0, 170, 0, 30)
    
    _L3_3_0.Size = _L13_3_4
    
    _L4_3_0.Name = "SectionToggle"
    _L4_3_0.Parent = _L3_3_0
    local _L13_3_5 = Color3.new(1, 1, 1)
    
    _L4_3_0.BackgroundColor3 = _L13_3_5
    _L4_3_0.BackgroundTransparency = 1
    local _L13_3_6 = UDim2.new(0.822450161, 0, 0, 0)
    
    _L4_3_0.Position = _L13_3_6
    local _L13_3_7 = UDim2.new(0, 30, 0, 30)
    
    _L4_3_0.Size = _L13_3_7
    _L4_3_0.ZIndex = 2
    _L4_3_0.Text, _L4_3_0.Font = "v", Enum.Font.SourceSansSemibold
    local _L13_3_8 = Color3.new(1, 1, 1)
    
    _L4_3_0.TextColor3 = _L13_3_8
    _L4_3_0.TextSize = 14
    _L4_3_0.TextWrapped = true
    
    _L5_3_0.Name = "SectionTitle"
    _L5_3_0.Parent = _L3_3_0
    local _L13_3_9 = Color3.new(1, 1, 1)
    
    _L5_3_0.BackgroundColor3 = _L13_3_9
    _L5_3_0.BackgroundTransparency = 1
    _L5_3_0.BorderSizePixel = 0
    local _L13_3_10 = UDim2.new(0.052941177, 0, 0, 0)
    
    _L5_3_0.Position = _L13_3_10
    local _L13_3_11 = UDim2.new(0, 125, 0, 30)
    
    _L5_3_0.Size = _L13_3_11
    _L5_3_0.Font = Enum.Font.SourceSansBold
    _L5_3_0.Text = _A1_3_0
    local _L13_3_12 = Color3.new(1, 1, 1)
    
    _L5_3_0.TextColor3 = _L13_3_12
    _L5_3_0.TextSize = 17
    _L5_3_0.TextXAlignment = Enum.TextXAlignment.Left
    
    _L6_3_0.Name = "Layout"
    _L6_3_0.Parent = _L2_3_0
    _L6_3_0.SortOrder = Enum.SortOrder.LayoutOrder
    
    _L4_2_0.MouseButton1Down:Connect(function()
      if _UPVALUE_0_ then
      else
        _UPVALUE_1_(30)
        
        _L4_3_0.Text = _UPVALUE_3_
        _L1_4_0 = _L1_1_0
        local _L0_4_0 = _L1_1_0.Create
        local _L2_4_0 = _L2_3_0
        local _L3_4_0 = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        local _L4_4_0 = {}
        
        _L4_4_0.BackgroundTransparency = 0
        local _L0_4_1 = _L0_4_0(_L1_4_0, _L2_4_0, _L3_4_0, _L4_4_0)
        _L0_4_1:Play()
        
        goto lbl_56
      end
      
      if _UPVALUE_0_ then
        _UPVALUE_6_(30)
        _L4_3_0.Text = ""
        _L1_4_1 = _L1_1_0
        local _L0_4_2 = _L1_1_0.Create
        local _L2_4_1 = _L2_3_0
        local _L3_4_1 = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        local _L4_4_1 = {}
        
        _L4_4_1.BackgroundTransparency = 1
        local _L0_4_3 = _L0_4_2(_L1_4_1, _L2_4_1, _L3_4_1, _L4_4_1)
        _L0_4_3:Play()
      end
      ::lbl_56::
    end)
    
    _L4_3_0.MouseButton1Down:Connect(function()
      if _UPVALUE_0_ then
      else
        _UPVALUE_0_ = true
        
        _UPVALUE_1_ = "-"
        _L1_4_0 = _L1_1_0
        local _L0_4_0 = _L1_1_0.Create
        local _L2_4_0 = _L4_3_0
        local _L3_4_0 = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        local _L4_4_0 = {}
        
        _L4_4_0.TextTransparency = 1
        local _L0_4_1 = _L0_4_0(_L1_4_0, _L2_4_0, _L3_4_0, _L4_4_0)
        _L0_4_1:Play()
        _L1_4_1 = _L1_1_0
        local _L0_4_2 = _L1_1_0.Create
        local _L2_4_1 = _L4_2_0
        local _L3_4_1 = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        local _L4_4_1 = {}
        
        _L4_4_1.TextTransparency = 1
        local _L0_4_3 = _L0_4_2(_L1_4_1, _L2_4_1, _L3_4_1, _L4_4_1)
        _L0_4_3:Play()
        _L4_3_0.Text = _UPVALUE_1_
        
        _L4_3_0.TextSize = 20
        
        _L4_3_0.Visible = false
        
        _L4_2_0.Visible = false
        
        repeat
          wait()
        until _L4_3_0.TextTransparency == 1 and _L4_2_0.TextTransparency == 1
        _L4_3_0.Visible = true
        
        _L4_2_0.Visible = true
        _L1_4_2 = _L1_1_0
        local _L0_4_4 = _L1_1_0.Create
        local _L2_4_2 = _L4_3_0
        local _L3_4_2 = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        local _L4_4_2 = {}
        
        _L4_4_2.TextTransparency = 0
        local _L0_4_5 = _L0_4_4(_L1_4_2, _L2_4_2, _L3_4_2, _L4_4_2)
        _L0_4_5:Play()
        _L1_4_3 = _L1_1_0
        local _L0_4_6 = _L1_1_0.Create
        local _L2_4_3 = _L4_2_0
        local _L3_4_3 = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        local _L4_4_3 = {}
        
        _L4_4_3.TextTransparency = 0
        local _L0_4_7 = _L0_4_6(_L1_4_3, _L2_4_3, _L3_4_3, _L4_4_3)
        _L0_4_7:Play()
        
        goto lbl_207
      end
      
      if _UPVALUE_0_ then
        _UPVALUE_0_ = false
        _UPVALUE_1_ = "v"
        _L1_4_4 = _L1_1_0
        local _L0_4_8 = _L1_1_0.Create
        local _L2_4_4 = _L4_3_0
        local _L3_4_4 = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        local _L4_4_4 = {}
        
        _L4_4_4.TextTransparency = 1
        local _L0_4_9 = _L0_4_8(_L1_4_4, _L2_4_4, _L3_4_4, _L4_4_4)
        _L0_4_9:Play()
        _L1_4_5 = _L1_1_0
        local _L0_4_10 = _L1_1_0.Create
        local _L2_4_5 = _L4_2_0
        local _L3_4_5 = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        local _L4_4_5 = {}
        
        _L4_4_5.TextTransparency = 1
        local _L0_4_11 = _L0_4_10(_L1_4_5, _L2_4_5, _L3_4_5, _L4_4_5)
        _L0_4_11:Play()
        _L4_3_0.Text = _UPVALUE_1_
        
        _L4_3_0.TextSize = 14
        
        _L4_3_0.Visible = false
        
        _L4_2_0.Visible = false
        
        repeat
          wait()
        until _L4_3_0.TextTransparency == 1 and _L4_2_0.TextTransparency == 1
        _L4_3_0.Visible = true
        
        _L4_2_0.Visible = true
        _L1_4_6 = _L1_1_0
        local _L0_4_12 = _L1_1_0.Create
        local _L2_4_6 = _L4_3_0
        local _L3_4_6 = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        local _L4_4_6 = {}
        
        _L4_4_6.TextTransparency = 0
        local _L0_4_13 = _L0_4_12(_L1_4_6, _L2_4_6, _L3_4_6, _L4_4_6)
        _L0_4_13:Play()
        _L1_4_7 = _L1_1_0
        local _L0_4_14 = _L1_1_0.Create
        local _L2_4_7 = _L4_2_0
        local _L3_4_7 = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        local _L4_4_7 = {}
        
        _L4_4_7.TextTransparency = 0
        local _L0_4_15 = _L0_4_14(_L1_4_7, _L2_4_7, _L3_4_7, _L4_4_7)
        _L0_4_15:Play()
      end
      ::lbl_207::
    end)
    
    local _L13_3_13 = {}
    
    function _L13_3_13.CreateToggle(_A0_4_0, _A1_4_0, _A2_4_0)
      local _L3_4_0 = Instance.new("Frame")
      local _L4_4_0 = Instance.new("TextLabel")
      local _L5_4_0 = Instance.new("ImageLabel")
      local _L6_4_0 = Instance.new("ImageButton")
      local _L7_4_0 = _L11_1_0(_A1_4_0)
      
      _L3_4_0.Name = _L7_4_0 .. "ToggleHolder"
      _L3_4_0.Parent = _L2_3_0
      local _L9_4_0 = Color3.new(0.137255, 0.137255, 0.137255)
      
      _L3_4_0.BackgroundColor3 = _L9_4_0
      _L3_4_0.BorderSizePixel = 0
      local _L9_4_1 = UDim2.new(0, 170, 0, 30)
      
      _L3_4_0.Size = _L9_4_1
      
      _L4_4_0.Name = "ToggleTitle"
      _L4_4_0.Parent = _L3_4_0
      local _L9_4_2 = Color3.new(1, 1, 1)
      
      _L4_4_0.BackgroundColor3 = _L9_4_2
      _L4_4_0.BackgroundTransparency = 1
      _L4_4_0.BorderSizePixel = 0
      local _L9_4_3 = UDim2.new(0.052941177, 0, 0, 0)
      
      _L4_4_0.Position = _L9_4_3
      local _L9_4_4 = UDim2.new(0, 125, 0, 30)
      
      _L4_4_0.Size = _L9_4_4
      _L4_4_0.Font = Enum.Font.SourceSansBold
      _L4_4_0.Text = _A1_4_0
      local _L9_4_5 = Color3.new(1, 1, 1)
      
      _L4_4_0.TextColor3 = _L9_4_5
      _L4_4_0.TextSize = 17
      _L4_4_0.TextXAlignment = Enum.TextXAlignment.Left
      
      _L5_4_0.Name = "ToggleBackground"
      _L5_4_0.Parent = _L3_4_0
      local _L9_4_6 = Color3.new(1, 1, 1)
      
      _L5_4_0.BackgroundColor3 = _L9_4_6
      _L5_4_0.BackgroundTransparency = 1
      _L5_4_0.BorderSizePixel = 0
      local _L9_4_7 = UDim2.new(0.847058833, 0, 0.166666672, 0)
      
      _L5_4_0.Position = _L9_4_7
      local _L9_4_8 = UDim2.new(0, 20, 0, 20)
      
      _L5_4_0.Size = _L9_4_8
      _L5_4_0.Image = "rbxassetid://3570695787"
      local _L9_4_9 = Color3.new(0.254902, 0.254902, 0.254902)
      
      _L5_4_0.ImageColor3 = _L9_4_9
      
      _L6_4_0.Name = "ToggleButton"
      _L6_4_0.Parent = _L5_4_0
      local _L9_4_10 = Color3.new(1, 1, 1)
      
      _L6_4_0.BackgroundColor3 = _L9_4_10
      _L6_4_0.BackgroundTransparency = 1
      local _L9_4_11 = UDim2.new(0, 2, 0, 2)
      
      _L6_4_0.Position = _L9_4_11
      local _L9_4_12 = UDim2.new(0, 16, 0, 16)
      
      _L6_4_0.Size = _L9_4_12
      _L6_4_0.Image = "rbxassetid://3570695787"
      local _L9_4_13 = Color3.new(1, 0.341176, 0.341176)
      
      _L6_4_0.ImageColor3 = _L9_4_13
      _L6_4_0.ImageTransparency = 1
      
      _L6_4_0.MouseButton1Down:Connect(function()
        _UPVALUE_0_ = not _UPVALUE_0_
        
        if _UPVALUE_0_ then
          _L1_5_0 = _L1_1_0
          local _L0_5_0 = _L1_1_0.Create
          local _L2_5_0 = _L6_4_0
          local _L3_5_0 = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
          
          local _L4_5_0 = {}
          
          _L4_5_0.ImageTransparency = 0
          local _L0_5_1 = _L0_5_0(_L1_5_0, _L2_5_0, _L3_5_0, _L4_5_0)
          _L0_5_1:Play()
          
          break -- pseudo-goto
        end
        
        if not _UPVALUE_0_ then
          _L1_5_1 = _L1_1_0
          local _L0_5_2 = _L1_1_0.Create
          local _L2_5_1 = _L6_4_0
          local _L3_5_1 = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
          
          local _L4_5_1 = {}
          
          repeat
            _L4_5_1.ImageTransparency = 1
            local _L0_5_3 = _L0_5_2(_L1_5_1, _L2_5_1, _L3_5_1, _L4_5_1)
            _L0_5_3:Play()
          until true
        end
        _A2_4_0(_UPVALUE_0_)
      end)
      
      _L4_3_0.MouseButton1Down:Connect(function()
        if not _UPVALUE_0_ then
          _L11_3_0(30)
          _UPVALUE_2_(30)
        
        elseif _UPVALUE_0_ then
          _L12_3_0(30)
          _UPVALUE_4_(30)
        end
      end)
      
      _L4_2_0.MouseButton1Down:Connect(function()
        if not _UPVALUE_0_ then
          if _UPVALUE_1_ then
            _UPVALUE_2_(30)
            _L1_5_0 = _L1_1_0
            local _L0_5_0 = _L1_1_0.Create
            local _L2_5_0 = _L4_3_0
            local _L3_5_0 = TweenInfo.new(0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            
            local _L4_5_0 = {}
            
            _L4_5_0.Rotation = 360
            local _L0_5_1 = _L0_5_0(_L1_5_0, _L2_5_0, _L3_5_0, _L4_5_0)
            _L0_5_1:Play()
            _L1_5_1 = _L1_1_0
            local _L0_5_2 = _L1_1_0.Create
            local _L2_5_1 = _L2_3_0
            local _L3_5_1 = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            
            local _L4_5_1 = {}
            
            _L4_5_1.BackgroundTransparency = 0
            local _L0_5_3 = _L0_5_2(_L1_5_1, _L2_5_1, _L3_5_1, _L4_5_1)
            _L0_5_3:Play()
            
            break -- pseudo-goto
          end
          
          if _UPVALUE_1_ then
            goto lbl_138
          end
          _L1_5_2 = _L1_1_0
          local _L0_5_4 = _L1_1_0.Create
          local _L2_5_2 = _L2_3_0
          local _L3_5_2 = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
          
          local _L4_5_2 = {}
          
          _L4_5_2.BackgroundTransparency = 0
          local _L0_5_5 = _L0_5_4(_L1_5_2, _L2_5_2, _L3_5_2, _L4_5_2)
          _L0_5_5:Play()
          
          break -- pseudo-goto
        end
        
        if not _UPVALUE_0_ then
        else
          if _UPVALUE_1_ then
            _UPVALUE_6_(30)
            
            _L1_5_3 = _L1_1_0
            local _L0_5_6 = _L1_1_0.Create
            local _L2_5_3 = _L4_3_0
            local _L3_5_3 = TweenInfo.new(0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            
            local _L4_5_3 = {}
            
            _L4_5_3.Rotation = 0
            local _L0_5_7 = _L0_5_6(_L1_5_3, _L2_5_3, _L3_5_3, _L4_5_3)
            _L0_5_7:Play()
            _L1_5_4 = _L1_1_0
            local _L0_5_8 = _L1_1_0.Create
            local _L2_5_4 = _L2_3_0
            local _L3_5_4 = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            
            local _L4_5_4 = {}
            
            _L4_5_4.BackgroundTransparency = 1
            local _L0_5_9 = _L0_5_8(_L1_5_4, _L2_5_4, _L3_5_4, _L4_5_4)
            _L0_5_9:Play()
            
            break -- pseudo-goto
          end
          
          if _UPVALUE_1_ then
          else
            _L1_5_5 = _L1_1_0
            
            local _L0_5_10 = _L1_1_0.Create
            local _L2_5_5 = _L2_3_0
            local _L3_5_5 = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            
            local _L4_5_5 = {}
            
            repeat
              _L4_5_5.BackgroundTransparency = 1
              local _L0_5_11 = _L0_5_10(_L1_5_5, _L2_5_5, _L3_5_5, _L4_5_5)
              _L0_5_11:Play()
            until true
          end
        end
        ::lbl_138::
        _L1_5_6 = _L1_1_0
        local _L0_5_12 = _L1_1_0.Create
        local _L2_5_6 = _L4_3_0
        local _L3_5_6 = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        local _L4_5_6 = {}
        
        _L4_5_6.TextTransparency = 1
        local _L0_5_13 = _L0_5_12(_L1_5_6, _L2_5_6, _L3_5_6, _L4_5_6)
        _L0_5_13:Play()
        _L4_3_0.Visible = false
        
        repeat
          wait()
        until _L4_3_0.TextTransparency == 1
        _L4_3_0.Visible = true
        _L1_5_7 = _L1_1_0
        local _L0_5_14 = _L1_1_0.Create
        local _L2_5_7 = _L4_3_0
        local _L3_5_7 = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        local _L4_5_7 = {}
        
        _L4_5_7.TextTransparency = 0
        local _L0_5_15 = _L0_5_14(_L1_5_7, _L2_5_7, _L3_5_7, _L4_5_7)
        _L0_5_15:Play()
      end)
    end
    
    function _L13_3_13.CreateSlider(_A0_4_0, _A1_4_0, _A2_4_0, _A3_4_0, _A4_4_0, _A5_4_0, _A6_4_0)
      local _L7_4_0 = Instance.new("Frame")
      local _L8_4_0 = Instance.new("TextLabel")
      local _L9_4_0 = Instance.new("ImageLabel")
      local _L10_4_0 = Instance.new("TextLabel")
      local _L11_4_0 = Instance.new("ImageLabel")
      local _L12_4_0 = Instance.new("ImageLabel")
      local _L13_4_0 = _L11_1_0(_A1_4_0)
      
      _L7_4_0.Name = _L13_4_0 .. "SliderHolder"
      _L7_4_0.Parent = _L2_3_0
      local _L16_4_0 = Color3.new(0.137255, 0.137255, 0.137255)
      
      _L7_4_0.BackgroundColor3 = _L16_4_0
      _L7_4_0.BorderSizePixel = 0
      local _L16_4_1 = UDim2.new(0, 170, 0, 30)
      
      _L7_4_0.Size = _L16_4_1
      
      _L8_4_0.Name = "SliderTitle"
      _L8_4_0.Parent = _L7_4_0
      local _L16_4_2 = Color3.new(1, 1, 1)
      
      _L8_4_0.BackgroundColor3 = _L16_4_2
      _L8_4_0.BackgroundTransparency = 1
      _L8_4_0.BorderSizePixel = 0
      local _L16_4_3 = UDim2.new(0.052941177, 0, 0, 0)
      
      _L8_4_0.Position = _L16_4_3
      local _L16_4_4 = UDim2.new(0, 125, 0, 15)
      
      _L8_4_0.Size = _L16_4_4
      _L8_4_0.Font = Enum.Font.SourceSansSemibold
      _L8_4_0.Text = _A1_4_0
      local _L16_4_5 = Color3.new(1, 1, 1)
      
      _L8_4_0.TextColor3 = _L16_4_5
      _L8_4_0.TextSize = 17
      _L8_4_0.TextXAlignment = Enum.TextXAlignment.Left
      
      _L9_4_0.Name = "SliderValueHolder"
      _L9_4_0.Parent = _L7_4_0
      local _L16_4_6 = Color3.new(0.254902, 0.254902, 0.254902)
      
      _L9_4_0.BackgroundColor3 = _L16_4_6
      _L9_4_0.BackgroundTransparency = 1
      local _L16_4_7 = UDim2.new(0.747058809, 0, 0, 0)
      
      _L9_4_0.Position = _L16_4_7
      local _L16_4_8 = UDim2.new(0, 35, 0, 15)
      
      _L9_4_0.Size = _L16_4_8
      _L9_4_0.Image = "rbxassetid://3570695787"
      local _L16_4_9 = Color3.new(0.254902, 0.254902, 0.254902)
      
      _L9_4_0.ImageColor3 = _L16_4_9
      _L9_4_0.ImageTransparency = 0.5
      _L9_4_0.ScaleType = Enum.ScaleType.Slice
      local _L16_4_10 = Rect.new(100, 100, 100, 100)
      
      _L9_4_0.SliceCenter = _L16_4_10
      _L9_4_0.SliceScale = 0.02
      
      _L10_4_0.Name = "SliderValue"
      _L10_4_0.Parent = _L9_4_0
      local _L16_4_11 = Color3.new(1, 1, 1)
      
      _L10_4_0.BackgroundColor3 = _L16_4_11
      _L10_4_0.BackgroundTransparency = 1
      local _L16_4_12 = UDim2.new(0, 35, 0, 15)
      
      _L10_4_0.Size = _L16_4_12
      _L10_4_0.Font = Enum.Font.SourceSansSemibold
      
      if not _A4_4_0 and _A5_4_0 then
      end
      local _L16_4_13 = tostring((tonumber(string.format("%.2f", _A4_4_0))))
      
      _L10_4_0.Text = _L16_4_13
      local _L16_4_14 = Color3.new(1, 1, 1)
      
      _L10_4_0.TextColor3 = _L16_4_14
      _L10_4_0.TextSize = 14
      
      _L11_4_0.Name = "SliderBackground"
      _L11_4_0.Parent = _L7_4_0
      local _L16_4_15 = Color3.new(0.254902, 0.254902, 0.254902)
      
      _L11_4_0.BackgroundColor3 = _L16_4_15
      _L11_4_0.BackgroundTransparency = 1
      local _L16_4_16 = UDim2.new(0.0529999994, 0, 0.649999976, 0)
      
      _L11_4_0.Position = _L16_4_16
      _L11_4_0.Selectable = true
      local _L16_4_17 = UDim2.new(0, 153, 0, 5)
      
      _L11_4_0.Size = _L16_4_17
      _L11_4_0.Image = "rbxassetid://3570695787"
      local _L16_4_18 = Color3.new(0.254902, 0.254902, 0.254902)
      
      _L11_4_0.ImageColor3 = _L16_4_18
      _L11_4_0.ImageTransparency = 0.5
      _L11_4_0.ScaleType = Enum.ScaleType.Slice
      local _L16_4_19 = Rect.new(100, 100, 100, 100)
      
      _L11_4_0.SliceCenter = _L16_4_19
      _L11_4_0.ClipsDescendants = true
      _L11_4_0.SliceScale = 0.02
      
      _L12_4_0.Name = "Slider"
      _L12_4_0.Parent = _L11_4_0
      local _L16_4_20 = Color3.new(1, 1, 1)
      
      _L12_4_0.BackgroundColor3 = _L16_4_20
      _L12_4_0.BackgroundTransparency = 1
      
      if not _A4_4_0 then
      end
      local _L16_4_21 = UDim2.new((_A2_4_0 - _A2_4_0) / (_A3_4_0 - _A2_4_0), 0, 0, 5)
      
      _L12_4_0.Size = _L16_4_21
      _L12_4_0.Image = "rbxassetid://3570695787"
      _L12_4_0.ScaleType = Enum.ScaleType.Slice
      local _L16_4_22 = Rect.new(100, 100, 100, 100)
      
      _L12_4_0.SliceCenter = _L16_4_22
      _L12_4_0.SliceScale = 0.02
      
      local function _L16_4_23(_A0_5_0)
        local _L1_5_0 = UDim2.new(math.clamp((_A0_5_0.Position.X - _L11_4_0.AbsolutePosition.X) / _L11_4_0.AbsoluteSize.X, 0, 1), 0, 1.15, 0)
        _L3_5_0 = _L1_1_0
        local _L2_5_0 = _L1_1_0.Create
        local _L4_5_0 = _L12_4_0
        local _L5_5_0 = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        local _L6_5_0 = {}
        
        _L6_5_0.Size = _L1_5_0
        local _L2_5_1 = _L2_5_0(_L3_5_0, _L4_5_0, _L5_5_0, _L6_5_0)
        _L2_5_1:Play()
        local _L2_5_2 = math.floor(_L1_5_0.X.Scale * _A3_4_0 / _A3_4_0 * (_A3_4_0 - _A2_4_0) + _A2_4_0)
        
        if not _UPVALUE_5_ then
        else
        end
        
        if not (_L1_5_0.X.Scale * _A3_4_0 / _A3_4_0 * (_A3_4_0 - _A2_4_0) + _A2_4_0) then
          local _L4_5_1 = _L2_5_2
        end
        local _L5_5_1 = tonumber(string.format("%.2f", _L4_5_1))
        local _L4_5_2 = _L5_5_1
        local _L6_5_1 = tostring(_L4_5_2)
        
        _L10_4_0.Text = _L6_5_1
        _A6_4_0(_L4_5_2)
      end
      
      _L11_4_0.InputBegan:Connect(function(_A0_5_0)
        if _A0_5_0.UserInputType == Enum.UserInputType.MouseButton1 then
          _UPVALUE_0_ = true
        end
      end)
      
      _L11_4_0.InputEnded:Connect(function(_A0_5_0)
        if _A0_5_0.UserInputType == Enum.UserInputType.MouseButton1 then
          _UPVALUE_0_ = false
        end
      end)
      
      _L11_4_0.InputBegan:Connect(function(_A0_5_0)
        if _A0_5_0.UserInputType == Enum.UserInputType.MouseButton1 then
          _L16_4_23(_A0_5_0)
        end
      end)
      
      _L0_1_0.InputChanged:Connect(function(_A0_5_0)
        if _UPVALUE_0_ and _A0_5_0.UserInputType == Enum.UserInputType.MouseMovement then
          _L16_4_23(_A0_5_0)
        end
      end)
      
      _L4_3_0.MouseButton1Down:Connect(function()
        if _UPVALUE_0_ then
        else
          _L11_3_0(30)
          
          _UPVALUE_2_(30)
          
          goto lbl_22
        end
        
        if not _UPVALUE_0_ then
        else
          _L12_3_0(30)
          
          _UPVALUE_4_(30)
        end
        ::lbl_22::
      end)
      
      _L4_2_0.MouseButton1Down:Connect(function()
