local notif = {}

function notif:Notification(title,desc,font,font2,visibletime)
pcall(function()
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

local instances = {
	["UICorner_1"] = Instance.new("UICorner"),
	["LocalScript_1"] = Instance.new("LocalScript"),
	["Frame_2"] = Instance.new("Frame"),
	["UICorner_2"] = Instance.new("UICorner"),
	["TextLabel_1"] = Instance.new("TextLabel"),
	["Frame_1"] = Instance.new("Frame"),
	["TextLabel_2"] = Instance.new("TextLabel"),
	["LocalScript_2"] = Instance.new("LocalScript"),
	["TextButton_1"] = Instance.new("TextButton"),
}


screenGui.Name = title
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

instances.Frame_1.Parent = screenGui
instances.Frame_1.Name = 'Main'


instances.Frame_1.BackgroundColor3 = Color3.new(0.0666667, 0.0666667, 0.0666667)
instances.Frame_1.BorderSizePixel = 0
instances.Frame_1.Position = UDim2.new(1, 0,0.509, 0)
instances.Frame_1.Size = UDim2.new(0, 331, 0, 61)

instances.Frame_2.Parent = instances.Frame_1
instances.Frame_2.BackgroundColor3 = Color3.new(0.0431373, 0.0431373, 0.0431373)
instances.Frame_2.Size = UDim2.new(0, 11, 0, 61)
instances.Frame_2.Name = 'Bar'

instances.UICorner_1.Parent = instances.Frame_2
instances.UICorner_1.CornerRadius = UDim.new(0, 10)

instances.UICorner_2.Parent = instances.Frame_1
instances.UICorner_2.CornerRadius = UDim.new(0, 7)

instances.TextLabel_1.Parent = instances.Frame_1
instances.TextLabel_1.Font = Enum.Font[font]
instances.TextLabel_1.Text = title
instances.TextLabel_1.TextColor3 = Color3.new(1, 1, 1)
instances.TextLabel_1.TextSize = 14
instances.TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
instances.TextLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
instances.TextLabel_1.BackgroundTransparency = 1
instances.TextLabel_1.Position = UDim2.new(0.08849557489156723, 0, 0, 0)
instances.TextLabel_1.Size = UDim2.new(0, 201, 0, 28)
instances.TextLabel_1.Name = 'Title'

instances.TextLabel_2.Parent = instances.Frame_1
instances.TextLabel_2.Font = Enum.Font[font2]
instances.TextLabel_2.Text = desc
instances.TextLabel_2.TextColor3 = Color3.new(1, 1, 1)
instances.TextLabel_2.TextSize = 13
instances.TextLabel_2.TextTruncate = Enum.TextTruncate.AtEnd
instances.TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left
instances.TextLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
instances.TextLabel_2.BackgroundTransparency = 1
instances.TextLabel_2.Position = UDim2.new(0.08645028620958328, 0, 0.6040353178977966, 0)
instances.TextLabel_2.Size = UDim2.new(0, 191, 0, 9)
instances.TextLabel_2.Name = 'Description'

instances.TextButton_1.Parent = instances.Frame_1
instances.TextButton_1.Font = Enum.Font.GothamSemibold
instances.TextButton_1.Text = 'X'
instances.TextButton_1.TextColor3 = Color3.new(1, 1, 1)
instances.TextButton_1.TextSize = 18
instances.TextButton_1.BackgroundColor3 = Color3.new(1, 1, 1)
instances.TextButton_1.BackgroundTransparency = 1
instances.TextButton_1.Position = UDim2.new(0.9070796370506287, 0, 0, 0)
instances.TextButton_1.Size = UDim2.new(0, 16, 0, 61)
instances.TextButton_1.Name = 'Close'

instances.LocalScript_1.Parent = instances.TextButton_1

instances.LocalScript_2.Parent = instances.Frame_1

local DO_NOT_COPY_THIS_VARIABLE_001 = {}
local DO_NOT_COPY_THIS_VARIABLE_002 = require

local require = function(object)
	local module = DO_NOT_COPY_THIS_VARIABLE_001[object]

	if module then
		return DO_NOT_COPY_THIS_VARIABLE_001[object]()
	end

	return DO_NOT_COPY_THIS_VARIABLE_002(object)
end



function Code_LocalScript_1() --LocalScript
	local script = instances.LocalScript_1

	script.Parent.MouseButton1Down:Connect(function()
	    script.Parent.Parent:TweenPosition(UDim2.new(50, 0,0,0),"InOut","Sine",7.2)
		wait(2)
		script.Parent.Parent.Parent:Destroy()
	end)
end
coroutine.wrap(Code_LocalScript_1)()


function Code_LocalScript_2()
	local script = instances.LocalScript_2
	local newpos = UDim2.new(0.82, 0,0.507, 0)
	
	
	script.Parent:TweenPosition(newpos,"InOut","Sine",0.5)
end
coroutine.wrap(Code_LocalScript_2)()
wait(visibletime)
		instances.Frame_1:TweenPosition(UDim2.new(50,0,0,0),"InOut","Sine",7.2)
		wait(2)
		screenGui:Destroy()
	
	

	end)
end
return notif
