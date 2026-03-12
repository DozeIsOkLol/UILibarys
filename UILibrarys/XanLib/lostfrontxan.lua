local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local Config = {
    ESP_Enabled = true,
    ESP_Box = true,
    ESP_Name = true,
    ESP_Distance = true,
    ESP_Health = true,
    ESP_Skeleton = true,
    ESP_TeamCheck = true,
    ESP_MaxDistance = 1500,
    ESP_BoxColor = Color3.fromRGB(255, 50, 50),
    
    AIM_Enabled = false,
    AIM_FOV = IsMobile and 350 or 200,
    AIM_Smooth = 0.05,
    AIM_TeamCheck = true,
    AIM_TargetPart = "Head",
    AIM_ShowFOV = true,
    AIM_Sticky = true,
    AIM_StickyTime = 0.8
}

local Bones = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

local State = {
    Unloaded = false,
    AimTarget = nil,
    AimTargetChar = nil,
    LastTargetSwitch = 0,
    Aiming = false,
    MobileAiming = false,
    MobileAimToggled = false,
    AimHoldMode = false
}

local Cache = {
    Targets = {},
    ESP = {},
    Visibility = {}
}

local Connections = {}

local function GetRoot(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHead(char)
    return char and char:FindFirstChild("Head")
end

local function GetHumanoid(char)
    return char and char:FindFirstChild("Humanoid")
end

local function IsAlive(char)
    local hum = GetHumanoid(char)
    return hum and hum.Health > 0
end

local function IsTeammate(char)
    if not LocalPlayer.Character then return false end
    if not char or not char.Parent then return false end
    local localParent = LocalPlayer.Character.Parent
    local charParent = char.Parent
    if not localParent or not charParent then return false end
    return localParent == charParent
end

local function IsSpectator(char)
    if not char or not char.Parent then return true end
    local parentName = char.Parent.Name:lower()
    if parentName:find("spectator") or parentName:find("dead") or parentName:find("observer") then
        return true
    end
    return false
end

local function GetDistance(position)
    local char = LocalPlayer.Character
    local root = GetRoot(char)
    if not root then return math.huge end
    return (position - root.Position).Magnitude
end

local function WorldToScreen(position)
    local cam = Workspace.CurrentCamera
    if not cam then return Vector2.new(0, 0), false, 0 end
    local screenPos, onScreen = cam:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function IsVisible(char)
    if not char then return false end
    local cam = Camera
    if not cam then return false end
    local origin = cam.CFrame.Position
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local filter = {cam}
    if LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
    table.insert(filter, char)
    rayParams.FilterDescendantsInstances = filter
    
    local head = GetHead(char)
    if head then
        local dir = (head.Position - origin)
        local result = Workspace:Raycast(origin, dir.Unit * dir.Magnitude, rayParams)
        if not result or (result.Position - head.Position).Magnitude < 5 then
            return true
        end
    end
    return false
end

local function RefreshTargets()
    local new = {}
    local myChar = LocalPlayer.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "HumanoidRootPart" and obj:IsA("BasePart") then
            local parent = obj.Parent
            if parent and parent ~= myChar and obj.Position.Y > -50 then
                if IsSpectator(parent) then continue end
                local hum = GetHumanoid(parent)
                if hum and hum.Health > 0 then
                    new[parent] = obj
                end
            end
        end
    end
    Cache.Targets = new
end

local ESP = {}

function ESP.Create()
    local drawings = {
        Box = {Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line")},
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBg = Drawing.new("Line"),
        HealthBar = Drawing.new("Line"),
        Skeleton = {}
    }
    
    for i = 1, 5 do
        drawings.Skeleton[i] = Drawing.new("Line")
        drawings.Skeleton[i].Thickness = 1
        drawings.Skeleton[i].Visible = false
    end
    
    for _, line in pairs(drawings.Box) do
        line.Thickness = 1
        line.Visible = false
    end
    
    drawings.Name.Size = IsMobile and 15 or 13
    drawings.Name.Font = Drawing.Fonts.Monospace
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Visible = false
    
    drawings.Distance.Size = IsMobile and 13 or 11
    drawings.Distance.Font = Drawing.Fonts.Monospace
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Visible = false
    
    drawings.HealthBg.Thickness = IsMobile and 5 or 4
    drawings.HealthBg.Color = Color3.new(0.1, 0.1, 0.1)
    drawings.HealthBg.Visible = false
    
    drawings.HealthBar.Thickness = IsMobile and 4 or 3
    drawings.HealthBar.Visible = false
    
    return drawings
end

function ESP.Get(char)
    if not Cache.ESP[char] then
        Cache.ESP[char] = ESP.Create()
    end
    return Cache.ESP[char]
end

function ESP.Hide(drawings)
    if not drawings then return end
    for _, line in pairs(drawings.Box) do line.Visible = false end
    drawings.Name.Visible = false
    drawings.Distance.Visible = false
    drawings.HealthBg.Visible = false
    drawings.HealthBar.Visible = false
    for _, line in pairs(drawings.Skeleton) do line.Visible = false end
end

function ESP.Destroy(drawings)
    if not drawings then return end
    pcall(function()
        for _, line in pairs(drawings.Box) do line:Remove() end
        drawings.Name:Remove()
        drawings.Distance:Remove()
        drawings.HealthBg:Remove()
        drawings.HealthBar:Remove()
        for _, line in pairs(drawings.Skeleton) do line:Remove() end
    end)
end

function ESP.Render(char, root)
    local drawings = ESP.Get(char)
    
    if not Config.ESP_Enabled then
        ESP.Hide(drawings)
        return
    end
    
    if not IsAlive(char) then
        ESP.Hide(drawings)
        return
    end
    
    if Config.ESP_TeamCheck and IsTeammate(char) then
        ESP.Hide(drawings)
        return
    end
    
    local distance = GetDistance(root.Position)
    if distance > Config.ESP_MaxDistance then
        ESP.Hide(drawings)
        return
    end
    
    local head = GetHead(char)
    local headPos = head and head.Position or (root.Position + Vector3.new(0, 2, 0))
    local feetPos = root.Position - Vector3.new(0, 3, 0)
    
    local rootScreen, onScreen, depth = WorldToScreen(root.Position)
    local headScreen = WorldToScreen(headPos + Vector3.new(0, 0.5, 0))
    local feetScreen = WorldToScreen(feetPos)
    
    if not onScreen or depth <= 0 then
        ESP.Hide(drawings)
        return
    end
    
    local visible = Cache.Visibility[char] or false
    local color = visible and Color3.fromRGB(0, 255, 0) or Config.ESP_BoxColor
    
    local boxHeight = math.abs(feetScreen.Y - headScreen.Y)
    local boxWidth = boxHeight * 0.6
    local cx = rootScreen.X
    
    if Config.ESP_Box then
        drawings.Box[1].From = Vector2.new(cx - boxWidth/2, headScreen.Y)
        drawings.Box[1].To = Vector2.new(cx + boxWidth/2, headScreen.Y)
        drawings.Box[2].From = Vector2.new(cx + boxWidth/2, headScreen.Y)
        drawings.Box[2].To = Vector2.new(cx + boxWidth/2, feetScreen.Y)
        drawings.Box[3].From = Vector2.new(cx + boxWidth/2, feetScreen.Y)
        drawings.Box[3].To = Vector2.new(cx - boxWidth/2, feetScreen.Y)
        drawings.Box[4].From = Vector2.new(cx - boxWidth/2, feetScreen.Y)
        drawings.Box[4].To = Vector2.new(cx - boxWidth/2, headScreen.Y)
        for _, line in pairs(drawings.Box) do
            line.Color = color
            line.Visible = true
        end
    else
        for _, line in pairs(drawings.Box) do line.Visible = false end
    end
    
    if Config.ESP_Name then
        local name = char.Name
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character == char then name = p.Name; break end
        end
        drawings.Name.Text = name
        drawings.Name.Position = Vector2.new(cx, headScreen.Y - 18)
        drawings.Name.Color = color
        drawings.Name.Visible = true
    else
        drawings.Name.Visible = false
    end
    
    if Config.ESP_Distance then
        drawings.Distance.Text = math.floor(distance) .. "m"
        drawings.Distance.Position = Vector2.new(cx, feetScreen.Y + 4)
        drawings.Distance.Color = Color3.fromRGB(180, 180, 180)
        drawings.Distance.Visible = true
    else
        drawings.Distance.Visible = false
    end
    
    if Config.ESP_Health then
        local hum = GetHumanoid(char)
        if hum then
            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barX = cx - boxWidth/2 - 6
            local barHeight = boxHeight * pct
            
            drawings.HealthBg.From = Vector2.new(barX, headScreen.Y)
            drawings.HealthBg.To = Vector2.new(barX, feetScreen.Y)
            drawings.HealthBg.Visible = true
            
            local healthColor = pct > 0.6 and Color3.fromRGB(0, 255, 0) or pct > 0.3 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0)
            drawings.HealthBar.From = Vector2.new(barX, feetScreen.Y - barHeight)
            drawings.HealthBar.To = Vector2.new(barX, feetScreen.Y)
            drawings.HealthBar.Color = healthColor
            drawings.HealthBar.Visible = true
        else
            drawings.HealthBg.Visible = false
            drawings.HealthBar.Visible = false
        end
    else
        drawings.HealthBg.Visible = false
        drawings.HealthBar.Visible = false
    end
    
    if Config.ESP_Skeleton then
        local skelColor = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
        for i, bone in ipairs(Bones) do
            local p1 = char:FindFirstChild(bone[1])
            local p2 = char:FindFirstChild(bone[2])
            if p1 and p2 then
                local s1, o1 = WorldToScreen(p1.Position)
                local s2, o2 = WorldToScreen(p2.Position)
                if o1 and o2 then
                    drawings.Skeleton[i].From = s1
                    drawings.Skeleton[i].To = s2
                    drawings.Skeleton[i].Color = skelColor
                    drawings.Skeleton[i].Visible = true
                else
                    drawings.Skeleton[i].Visible = false
                end
            else
                drawings.Skeleton[i].Visible = false
            end
        end
    else
        for _, line in pairs(drawings.Skeleton) do line.Visible = false end
    end
end

local Radar = {}
Radar.Frame = nil
Radar.Dots = {}
Radar.Size = 140
Radar.Range = 250
Radar.Enabled = true

function Radar.Create()
    local ScreenGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if not ScreenGui then
        ScreenGui = game:GetService("CoreGui")
    end
    
    local radarFrame = Instance.new("Frame")
    radarFrame.Name = "LostFrontRadar"
    radarFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    radarFrame.BorderSizePixel = 0
    radarFrame.Position = UDim2.new(0, 20, 1, -160)
    radarFrame.Size = UDim2.new(0, Radar.Size, 0, Radar.Size)
    radarFrame.ZIndex = 1000
    
    pcall(function()
        radarFrame.Parent = game:GetService("CoreGui")
    end)
    if not radarFrame.Parent then
        radarFrame.Parent = game:GetService("Players").LocalPlayer.PlayerGui
    end
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = radarFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(220, 60, 60)
    stroke.Thickness = 1
    stroke.Parent = radarFrame
    
    local cross1 = Instance.new("Frame")
    cross1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    cross1.BorderSizePixel = 0
    cross1.Size = UDim2.new(1, 0, 0, 1)
    cross1.Position = UDim2.new(0, 0, 0.5, 0)
    cross1.ZIndex = 1001
    cross1.Parent = radarFrame
    
    local cross2 = Instance.new("Frame")
    cross2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    cross2.BorderSizePixel = 0
    cross2.Size = UDim2.new(0, 1, 1, 0)
    cross2.Position = UDim2.new(0.5, 0, 0, 0)
    cross2.ZIndex = 1001
    cross2.Parent = radarFrame
    
    local center = Instance.new("Frame")
    center.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    center.BorderSizePixel = 0
    center.Size = UDim2.new(0, 4, 0, 4)
    center.Position = UDim2.new(0.5, -2, 0.5, -2)
    center.ZIndex = 1002
    center.Parent = radarFrame
    
    local centerCorner = Instance.new("UICorner")
    centerCorner.CornerRadius = UDim.new(1, 0)
    centerCorner.Parent = center
    
    Radar.Frame = radarFrame
    
    for i = 1, 30 do
        local dot = Instance.new("Frame")
        dot.Name = "Dot" .. i
        dot.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        dot.BorderSizePixel = 0
        dot.Size = UDim2.new(0, 3, 0, 3)
        dot.Visible = false
        dot.ZIndex = 1002
        dot.Parent = radarFrame
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        
        Radar.Dots[i] = dot
    end
end

function Radar.Update()
    if not Radar.Enabled or not Radar.Frame then
        if Radar.Frame then Radar.Frame.Visible = false end
        return
    end
    
    Radar.Frame.Visible = true
    Radar.Frame.Size = UDim2.new(0, Radar.Size, 0, Radar.Size)
    
    local myChar = LocalPlayer.Character
    if not myChar then return end
    
    local myRoot = GetRoot(myChar)
    if not myRoot then return end
    
    local cam = Camera
    if not cam then return end
    
    local myPos = myRoot.Position
    local camLook = cam.CFrame.LookVector
    local angle = math.atan2(camLook.X, camLook.Z)
    
    local dotIndex = 1
    for char, root in pairs(Cache.Targets) do
        if dotIndex > #Radar.Dots then break end
        if not root or not root.Parent then continue end
        
        local offset = root.Position - myPos
        local dist = math.sqrt(offset.X * offset.X + offset.Z * offset.Z)
        
        if dist <= Radar.Range then
            local rotatedX = offset.X * math.cos(-angle) - offset.Z * math.sin(-angle)
            local rotatedZ = offset.X * math.sin(-angle) + offset.Z * math.cos(-angle)
            
            local scale = Radar.Size / (Radar.Range * 2)
            local screenX = rotatedX * scale
            local screenY = -rotatedZ * scale
            
            local dot = Radar.Dots[dotIndex]
            dot.Position = UDim2.new(0.5, screenX - 1.5, 0.5, screenY - 1.5)
            
            local visible = Cache.Visibility[char] or false
            dot.BackgroundColor3 = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(220, 60, 60)
            dot.Visible = true
            
            dotIndex = dotIndex + 1
        end
    end
    
    for i = dotIndex, #Radar.Dots do
        Radar.Dots[i].Visible = false
    end
end

function Radar.Destroy()
    if Radar.Frame then
        pcall(function() Radar.Frame:Destroy() end)
        Radar.Frame = nil
    end
    Radar.Dots = {}
end

local Aimbot = {}

local FOVCircle = nil
local TargetCircle = nil

local function CreateFOVCircle()
    if FOVCircle then return end
    
    local success = pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 2
        FOVCircle.NumSides = 64
        FOVCircle.Filled = false
        FOVCircle.Visible = true
        FOVCircle.Color = Color3.new(1, 0, 0)
        FOVCircle.Transparency = 1
        FOVCircle.Radius = 180
        
        local cam = Workspace.CurrentCamera
        if cam then
            local center = cam.ViewportSize / 2
            FOVCircle.Position = Vector2.new(center.X, center.Y)
        end
        
        TargetCircle = Drawing.new("Circle")
        TargetCircle.Thickness = 2
        TargetCircle.NumSides = 32
        TargetCircle.Filled = false
        TargetCircle.Visible = false
        TargetCircle.Color = Color3.new(0, 1, 0)
        TargetCircle.Transparency = 1
        TargetCircle.Radius = 20
    end)
    
    if success and FOVCircle then
        UI.Success("FOV", "Circle created!")
    end
end

function Aimbot.UpdateFOV()
    if not FOVCircle then
        CreateFOVCircle()
    end
    if not FOVCircle then return end
    
    local cam = Workspace.CurrentCamera
    if not cam then return end
    
    local center = cam.ViewportSize / 2
    FOVCircle.Position = Vector2.new(center.X, center.Y)
    FOVCircle.Radius = Config.AIM_FOV
    FOVCircle.Visible = Config.AIM_ShowFOV
    
    if Config.AIM_Enabled then
        FOVCircle.Color = Color3.new(1, 0, 0)
    else
        FOVCircle.Color = Color3.new(0.6, 0.6, 0.6)
    end
    
    if TargetCircle then
        pcall(function()
            if State.AimTarget and State.AimTarget.Parent and State.Aiming and Config.AIM_Enabled then
                local screenPos, onScreen = cam:WorldToViewportPoint(State.AimTarget.Position)
                if onScreen and screenPos.Z > 0 then
                    TargetCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
                    TargetCircle.Visible = true
                else
                    TargetCircle.Visible = false
                end
            else
                TargetCircle.Visible = false
            end
        end)
    end
end

function Aimbot.GetTargetPart(char)
    if Config.AIM_TargetPart == "Head" then
        return GetHead(char)
    elseif Config.AIM_TargetPart == "Torso" then
        return char:FindFirstChild("Torso") or GetRoot(char)
    end
    return GetRoot(char)
end

function Aimbot.GetTarget()
    local cam = Workspace.CurrentCamera
    if not cam then return nil, nil end
    
    local screenCenter = cam.ViewportSize / 2
    local centerVec = Vector2.new(screenCenter.X, screenCenter.Y)
    local now = tick()
    
    if Config.AIM_Sticky and State.AimTargetChar then
        local currentChar = State.AimTargetChar
        if currentChar and currentChar.Parent and IsAlive(currentChar) then
            if not (Config.AIM_TeamCheck and IsTeammate(currentChar)) then
                local targetPart = Aimbot.GetTargetPart(currentChar)
                if targetPart and targetPart.Parent then
                    local sp, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                    if onScreen and sp.Z > 0 then
                        local dist = (Vector2.new(sp.X, sp.Y) - centerVec).Magnitude
                        if dist < Config.AIM_FOV * 2.5 then
                            return targetPart, currentChar
                        end
                    end
                end
            end
        end
        State.AimTargetChar = nil
    end
    
    local bestTarget = nil
    local bestChar = nil
    local bestDist = math.huge
    
    for char, root in pairs(Cache.Targets) do
        if not char or not char.Parent then continue end
        if not IsAlive(char) then continue end
        if Config.AIM_TeamCheck and IsTeammate(char) then continue end
        
        local targetPart = Aimbot.GetTargetPart(char)
        if not targetPart or not targetPart.Parent then continue end
        
        local sp, onScreen = cam:WorldToViewportPoint(targetPart.Position)
        if not onScreen or sp.Z <= 0 then continue end
        
        local screenDist = (Vector2.new(sp.X, sp.Y) - centerVec).Magnitude
        
        if screenDist <= Config.AIM_FOV and screenDist < bestDist then
            bestDist = screenDist
            bestTarget = targetPart
            bestChar = char
        end
    end
    
    if bestTarget and bestChar ~= State.AimTargetChar then
        State.LastTargetSwitch = now
        State.AimTargetChar = bestChar
    end
    
    return bestTarget, bestChar
end

RunService:BindToRenderStep("LostFrontAimbot", 2000, function()
    if State.Unloaded then return end
    if not Config.AIM_Enabled then
        State.Aiming = false
        return
    end
    
    local cam = Workspace.CurrentCamera
    if not cam then return end
    
    local keyDown = State.MobileAiming
    
    if not keyDown then
        local rmb = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        keyDown = rmb
    end
    
    if not keyDown then
        State.Aiming = false
        return
    end
    
    State.Aiming = true
    local target, targetChar = Aimbot.GetTarget()
    if not target or not target.Parent then
        State.AimTarget = nil
        return
    end
    
    State.AimTarget = target
    
    local camPos = cam.CFrame.Position
    local targetPos = target.Position
    
    local targetCF = CFrame.lookAt(camPos, targetPos)
    
    local smoothAmount = 1.0 - Config.AIM_Smooth
    smoothAmount = math.clamp(smoothAmount, 0.9, 1.0)
    
    local currentCF = cam.CFrame
    local newCF = currentCF:Lerp(targetCF, smoothAmount)
    
    cam.CFrame = newCF
    
    pcall(function()
        local vm = cam:FindFirstChild("ViewModel")
        if vm then
            local cb = vm:FindFirstChild("CameraBone")
            if cb then cb.CFrame = newCF end
            local hrp = vm:FindFirstChild("HRP")
            if hrp then hrp.CFrame = newCF end
        end
    end)
    
    pcall(function()
        local net = game.ReplicatedStorage:FindFirstChild("network")
        if net then
            local lv = net:FindFirstChild("characterLookvector")
            if lv then lv:FireServer(newCF.LookVector) end
        end
    end)
end)

local lastRefresh = 0
local lastVisRefresh = 0

local function MainLoop()
    if State.Unloaded then return end
    
    Camera = Workspace.CurrentCamera
    if not Camera then return end
    
    local now = tick()
    
    if now - lastRefresh > 0.5 then
        lastRefresh = now
        RefreshTargets()
    end
    
    if now - lastVisRefresh > 0.2 then
        lastVisRefresh = now
        for char in pairs(Cache.Targets) do
            Cache.Visibility[char] = IsVisible(char)
        end
    end
    
    for char in pairs(Cache.ESP) do
        if not Cache.Targets[char] then
            ESP.Hide(Cache.ESP[char])
            ESP.Destroy(Cache.ESP[char])
            Cache.ESP[char] = nil
        end
    end
    
    for char, root in pairs(Cache.Targets) do
        if root and root.Parent then
            ESP.Render(char, root)
        end
    end
    
    Aimbot.UpdateFOV()
    Radar.Update()
end

local function Cleanup()
    for char, drawings in pairs(Cache.ESP) do
        ESP.Destroy(drawings)
    end
    Cache.ESP = {}
    
    pcall(function() FOVCircle:Remove() end)
    pcall(function() TargetCircle:Remove() end)
    
    Radar.Destroy()
end

local function Unload()
    if State.Unloaded then return end
    State.Unloaded = true
    
    State.MobileAiming = false
    State.MobileAimToggled = false
    State.Aiming = false
    
    pcall(function() RunService:UnbindFromRenderStep("LostFrontAimbot") end)
    
    for _, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Connections = {}
    
    Cleanup()
    
    if AimBtn then
        pcall(function() AimBtn:Destroy() end)
    end
    
    pcall(function()
        local cam = Workspace.CurrentCamera
        if cam then
            cam.CameraType = Enum.CameraType.Custom
        end
    end)
    
    UI.Success("Unloaded", "Lost Front script removed")
end

CreateFOVCircle()
Aimbot.UpdateFOV()

Radar.Create()

Connections.Render = RunService.RenderStepped:Connect(MainLoop)

if IsMobile then
    UI.Loading({ Title = "Lost Front", Subtitle = "Mobile mode...", Duration = 1.5, Fullscreen = false })
else
    UI.Splash({ Title = "Lost Front", Subtitle = "Loading...", Duration = 1.5 })
end
task.wait(1.7)

local Window = UI.New({
    Title = "Lost Front",
    Subtitle = "ESP & Aimbot",
    Theme = "Default",
    Size = IsMobile and UDim2.new(0, 420, 0, 500) or UDim2.new(0, 480, 0, 420),
    ShowUserInfo = true,
    ShowActiveList = not IsMobile,
    Logo = UI.Logos.XanBar,
    ShowLogo = true
})

local AimbotTab = Window:AddTab("Aimbot", UI.Icons.Aimbot)

AimbotTab:AddSection("Aimbot")

AimbotTab:AddToggle("Enable Aimbot", { Default = false, Flag = "AimbotEnabled", ShowInActiveList = true }, function(v)
    Config.AIM_Enabled = v
    if not v then
        State.MobileAiming = false
        State.MobileAimToggled = false
        State.Aiming = false
        State.AimTarget = nil
        State.AimTargetChar = nil
    end
end)

AimbotTab:AddDropdown("Target Part", {"Head", "Torso"}, function(v)
    Config.AIM_TargetPart = v
end)

AimbotTab:AddSlider("FOV Size", { Min = 50, Max = 500, Default = Config.AIM_FOV, Increment = 25, Suffix = "px", Flag = "FOVSize" }, function(v)
    Config.AIM_FOV = v
    if FOVCircle then FOVCircle.Radius = v end
end)

AimbotTab:AddSlider("Smoothing", { Min = 0.01, Max = 0.15, Default = 0.05, Increment = 0.01, Flag = "AimSmooth" }, function(v)
    Config.AIM_Smooth = v
end)

AimbotTab:AddParagraph("Targeting", "Prioritizes: Closest to crosshair + world distance\nLower smoothing = instant snap\nSticky keeps locked on target")

AimbotTab:AddSection("Settings")

AimbotTab:AddToggle("Show FOV Circle", { Default = true, Flag = "ShowFOV" }, function(v)
    Config.AIM_ShowFOV = v
    if not FOVCircle then CreateFOVCircle() end
    if FOVCircle then FOVCircle.Visible = v end
end)

AimbotTab:AddToggle("Sticky Targeting", { Default = true, Flag = "StickyAim" }, function(v)
    Config.AIM_Sticky = v
end)

AimbotTab:AddSlider("Sticky Duration", { Min = 0.2, Max = 2.0, Default = 0.8, Increment = 0.1, Suffix = "s", Flag = "StickyTime" }, function(v)
    Config.AIM_StickyTime = v
end)

AimbotTab:AddToggle("Team Check", { Default = true, Flag = "AimTeamCheck" }, function(v)
    Config.AIM_TeamCheck = v
end)

local ESPTab = Window:AddTab("ESP", UI.Icons.ESP)

ESPTab:AddSection("ESP Settings")

ESPTab:AddToggle("Enable ESP", { Default = true, Flag = "ESPEnabled", ShowInActiveList = true }, function(v)
    Config.ESP_Enabled = v
end)

ESPTab:AddColorPicker("ESP Color", { Default = UI.RGB(255, 50, 50), Flag = "ESPColor" }, function(color)
    Config.ESP_BoxColor = color
end)

ESPTab:AddSlider("Max Distance", { Min = 500, Max = 3000, Default = 1500, Increment = 100, Suffix = "m", Flag = "ESPMaxDist" }, function(v)
    Config.ESP_MaxDistance = v
end)

ESPTab:AddSection("Display")

ESPTab:AddToggle("Show Box", { Default = true, Flag = "ESPBox" }, function(v)
    Config.ESP_Box = v
end)

ESPTab:AddToggle("Show Names", { Default = true, Flag = "ESPName" }, function(v)
    Config.ESP_Name = v
end)

ESPTab:AddToggle("Show Distance", { Default = true, Flag = "ESPDistance" }, function(v)
    Config.ESP_Distance = v
end)

ESPTab:AddToggle("Show Health", { Default = true, Flag = "ESPHealth" }, function(v)
    Config.ESP_Health = v
end)

ESPTab:AddToggle("Show Skeleton", { Default = true, Flag = "ESPSkeleton" }, function(v)
    Config.ESP_Skeleton = v
end)

ESPTab:AddSection("Filters")

ESPTab:AddToggle("Team Check", { Default = true, Flag = "ESPTeamCheck" }, function(v)
    Config.ESP_TeamCheck = v
end)

ESPTab:AddSection("Radar")

ESPTab:AddToggle("Enable Radar", { Default = true, Flag = "RadarEnabled", ShowInActiveList = true }, function(v)
    Radar.Enabled = v
end)

ESPTab:AddSlider("Radar Size", { Min = 80, Max = 200, Default = 140, Increment = 10, Suffix = "px", Flag = "RadarSize" }, function(v)
    Radar.Size = v
end)

ESPTab:AddSlider("Radar Range", { Min = 100, Max = 500, Default = 250, Increment = 25, Suffix = "m", Flag = "RadarRange" }, function(v)
    Radar.Range = v
end)

local MiscTab = Window:AddTab("Misc", UI.Icons.Misc)

MiscTab:AddSection("Actions")

MiscTab:AddDangerButton("Unload Script", function()
    UI.Warning("Unloading", "Goodbye!")
    task.wait(0.5)
    Window:Destroy()
    Unload()
end)

local AimBtn = nil

if IsMobile then
    AimBtn = UI.AimButton({ 
        Position = UDim2.new(1, -80, 0.5, -30),
        HoldMode = false,
        Callback = function(state)
            State.MobileAimToggled = state
            State.MobileAiming = state
            State.Aiming = state
            
            if state then
                UI.Pill("AIM ON")
            else
                State.AimTarget = nil
                State.AimTargetChar = nil
                UI.Pill("AIM OFF")
            end
        end
    })
    
    AimbotTab:AddSection("Mobile Aim Button")
    
    AimbotTab:AddDropdown("Aim Button Mode", {"Toggle", "Hold"}, function(v)
        local isHold = v == "Hold"
        State.AimHoldMode = isHold
        if AimBtn and AimBtn.SetHoldMode then
            AimBtn:SetHoldMode(isHold)
        end
        if isHold then
            State.MobileAimToggled = false
            State.MobileAiming = false
        end
        UI.Pill(v .. " Mode")
    end)
    
    AimbotTab:AddToggle("Reposition Aim Button", { Default = false, Flag = "DragAimBtn" }, function(v)
        if v then
            AimBtn:EnableRepositioning()
            UI.Pill("Drag mode ON")
        else
            AimBtn:DisableRepositioning()
            UI.Pill("Position locked")
        end
    end)
    
    AimbotTab:AddParagraph("Modes", "Toggle: Tap to lock/unlock\nHold: Hold button to aim")
    
    UI.FloatingButton({ 
        Position = UDim2.new(0.5, -28, 0, 20), 
        Size = 56, 
        Icon = UI.Logos.XanBar, 
        Label = "Menu", 
        Draggable = true, 
        Callback = function() Window:Toggle() end 
    })
    
    local MobileTab = Window:AddTab("Mobile", UI.Icons.Settings)
    
    MobileTab:AddSection("Mobile Settings")
    
    MobileTab:AddToggle("Show Aim Button", { Default = true, Flag = "ShowAimBtn" }, function(v) 
        if AimBtn then
            if v then AimBtn:Show() else AimBtn:Hide() end 
        end
    end)
    
    MobileTab:AddParagraph("Info", "Aim settings moved to Aimbot tab\nUse 'Mobile Aim Button' section")
    
    UI.Info("Mobile Mode", "Touch controls ready")
else
    Connections.InputBegan = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            Window:Toggle()
        elseif input.KeyCode == Enum.KeyCode.Home then
            Window:Destroy()
            Unload()
        end
    end)
end

UI.Success("Loaded!", "Lost Front ready")

