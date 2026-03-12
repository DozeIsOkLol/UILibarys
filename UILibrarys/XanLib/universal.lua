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
    ESP_BoxStyle = "Corner",
    ESP_Name = true,
    ESP_Distance = true,
    ESP_Health = true,
    ESP_Tracer = false,
    ESP_TeamCheck = true,
    ESP_MaxDistance = 1000,
    ESP_BoxColor = Color3.fromRGB(255, 75, 85),
    ESP_TracerOrigin = "Bottom",
    
    AIM_Enabled = false,
    AIM_FOV = IsMobile and 300 or 180,
    AIM_Smooth = IsMobile and 0.12 or 0.15,
    AIM_TeamCheck = true,
    AIM_TargetPart = "Head",
    AIM_ShowFOV = not IsMobile,
    AIM_ShowTarget = true,
    AIM_Key = Enum.UserInputType.MouseButton2,
    AIM_LockOn = IsMobile,
    AIM_Sticky = IsMobile,
    AIM_StickyTime = 0.5,
    AIM_StickyFOV = 500,
    AIM_HardLock = IsMobile,
    
    CHAMS_Enabled = false,
    CHAMS_FillColor = Color3.fromRGB(255, 75, 85),
    CHAMS_OutlineColor = Color3.fromRGB(255, 255, 255),
    CHAMS_FillTransparency = 0.5,
    CHAMS_OutlineTransparency = 0
}

local Tuning = {
    CacheInterval = 0.1,
    CleanupInterval = 1.0,
    BoxRatio = 0.55,
    CornerLength = IsMobile and 12 or 8,
    NameSize = IsMobile and 16 or 13,
    DistSize = IsMobile and 14 or 11,
    HealthBarWidth = IsMobile and 4 or 3
}

local State = {
    Unloaded = false,
    LastCache = 0,
    LastCleanup = 0,
    AimTarget = nil,
    AimTargetPlayer = nil,
    LastTargetSwitch = 0,
    Aiming = false,
    MobileAiming = false,
    MobileAimToggled = false,
    MobileTrigger = false,
    MobileTriggerToggled = false,
    CurrentAimVelocity = Vector2.new(0, 0),
    AimHoldMode = true,
    TriggerHoldMode = true
}

local Cache = {
    Players = {},
    ESP = {}
}

local Connections = {}
local Chams = {}

local function GetCharacter(player)
    return player.Character
end

local function GetRoot(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso"))
end

local function GetHead(character)
    return character and character:FindFirstChild("Head")
end

local function GetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function IsAlive(character)
    local humanoid = GetHumanoid(character)
    return humanoid and humanoid.Health > 0
end

local function IsTeammate(player)
    if not Config.ESP_TeamCheck and not Config.AIM_TeamCheck then return false end
    if not LocalPlayer.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function GetDistance(position)
    local char = GetCharacter(LocalPlayer)
    local root = GetRoot(char)
    if not root then return math.huge end
    return (position - root.Position).Magnitude
end

local function WorldToScreen(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local ESP = {}

function ESP.CreateDrawings()
    local drawings = {
        BoxTopLeft = Drawing.new("Line"),
        BoxTopRight = Drawing.new("Line"),
        BoxBottomLeft = Drawing.new("Line"),
        BoxBottomRight = Drawing.new("Line"),
        BoxTop = Drawing.new("Line"),
        BoxBottom = Drawing.new("Line"),
        BoxLeft = Drawing.new("Line"),
        BoxRight = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        HealthBarBG = Drawing.new("Line"),
        HealthBar = Drawing.new("Line")
    }
    
    for _, line in pairs({drawings.BoxTopLeft, drawings.BoxTopRight, drawings.BoxBottomLeft, drawings.BoxBottomRight, drawings.BoxTop, drawings.BoxBottom, drawings.BoxLeft, drawings.BoxRight}) do
        line.Thickness = 1
        line.Visible = false
    end
    
    drawings.Name.Size = Tuning.NameSize
    drawings.Name.Font = Drawing.Fonts.Monospace
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Visible = false
    
    drawings.Distance.Size = Tuning.DistSize
    drawings.Distance.Font = Drawing.Fonts.Monospace
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Visible = false
    
    drawings.Tracer.Thickness = 1
    drawings.Tracer.Visible = false
    
    drawings.HealthBarBG.Thickness = Tuning.HealthBarWidth + 2
    drawings.HealthBarBG.Color = Color3.new(0, 0, 0)
    drawings.HealthBarBG.Visible = false
    
    drawings.HealthBar.Thickness = Tuning.HealthBarWidth
    drawings.HealthBar.Visible = false
    
    return drawings
end

function ESP.Get(player)
    if not Cache.ESP[player] then
        Cache.ESP[player] = ESP.CreateDrawings()
    end
    return Cache.ESP[player]
end

function ESP.Hide(drawings)
    if not drawings then return end
    for _, obj in pairs(drawings) do
        if obj and obj.Visible ~= nil then
            obj.Visible = false
        end
    end
end

function ESP.Destroy(drawings)
    if not drawings then return end
    for _, obj in pairs(drawings) do
        pcall(function()
            if obj and obj.Remove then obj:Remove() end
        end)
    end
end

function ESP.RenderCornerBox(drawings, x, y, w, h, color)
    local cornerLen = math.min(Tuning.CornerLength, w / 3, h / 3)
    
    drawings.BoxTopLeft.From = Vector2.new(x, y)
    drawings.BoxTopLeft.To = Vector2.new(x + cornerLen, y)
    drawings.BoxTopLeft.Color = color
    drawings.BoxTopLeft.Visible = true
    
    drawings.BoxTop.From = Vector2.new(x, y)
    drawings.BoxTop.To = Vector2.new(x, y + cornerLen)
    drawings.BoxTop.Color = color
    drawings.BoxTop.Visible = true
    
    drawings.BoxTopRight.From = Vector2.new(x + w, y)
    drawings.BoxTopRight.To = Vector2.new(x + w - cornerLen, y)
    drawings.BoxTopRight.Color = color
    drawings.BoxTopRight.Visible = true
    
    drawings.BoxRight.From = Vector2.new(x + w, y)
    drawings.BoxRight.To = Vector2.new(x + w, y + cornerLen)
    drawings.BoxRight.Color = color
    drawings.BoxRight.Visible = true
    
    drawings.BoxBottomLeft.From = Vector2.new(x, y + h)
    drawings.BoxBottomLeft.To = Vector2.new(x + cornerLen, y + h)
    drawings.BoxBottomLeft.Color = color
    drawings.BoxBottomLeft.Visible = true
    
    drawings.BoxBottom.From = Vector2.new(x, y + h)
    drawings.BoxBottom.To = Vector2.new(x, y + h - cornerLen)
    drawings.BoxBottom.Color = color
    drawings.BoxBottom.Visible = true
    
    drawings.BoxBottomRight.From = Vector2.new(x + w, y + h)
    drawings.BoxBottomRight.To = Vector2.new(x + w - cornerLen, y + h)
    drawings.BoxBottomRight.Color = color
    drawings.BoxBottomRight.Visible = true
    
    drawings.BoxLeft.From = Vector2.new(x + w, y + h)
    drawings.BoxLeft.To = Vector2.new(x + w, y + h - cornerLen)
    drawings.BoxLeft.Color = color
    drawings.BoxLeft.Visible = true
end

function ESP.RenderFullBox(drawings, x, y, w, h, color)
    drawings.BoxTopLeft.From = Vector2.new(x, y)
    drawings.BoxTopLeft.To = Vector2.new(x + w, y)
    drawings.BoxTopLeft.Color = color
    drawings.BoxTopLeft.Visible = true
    
    drawings.BoxTopRight.From = Vector2.new(x + w, y)
    drawings.BoxTopRight.To = Vector2.new(x + w, y + h)
    drawings.BoxTopRight.Color = color
    drawings.BoxTopRight.Visible = true
    
    drawings.BoxBottomRight.From = Vector2.new(x + w, y + h)
    drawings.BoxBottomRight.To = Vector2.new(x, y + h)
    drawings.BoxBottomRight.Color = color
    drawings.BoxBottomRight.Visible = true
    
    drawings.BoxBottomLeft.From = Vector2.new(x, y + h)
    drawings.BoxBottomLeft.To = Vector2.new(x, y)
    drawings.BoxBottomLeft.Color = color
    drawings.BoxBottomLeft.Visible = true
    
    drawings.BoxTop.Visible = false
    drawings.BoxBottom.Visible = false
    drawings.BoxLeft.Visible = false
    drawings.BoxRight.Visible = false
end

function ESP.Render(player)
    local drawings = ESP.Get(player)
    
    if not Config.ESP_Enabled then
        ESP.Hide(drawings)
        return
    end
    
    if player == LocalPlayer then
        ESP.Hide(drawings)
        return
    end
    
    local character = GetCharacter(player)
    local root = GetRoot(character)
    local head = GetHead(character)
    local humanoid = GetHumanoid(character)
    
    if not character or not root or not humanoid then
        ESP.Hide(drawings)
        return
    end
    
    if not IsAlive(character) then
        ESP.Hide(drawings)
        return
    end
    
    if Config.ESP_TeamCheck and IsTeammate(player) then
        ESP.Hide(drawings)
        return
    end
    
    local distance = GetDistance(root.Position)
    if distance > Config.ESP_MaxDistance then
        ESP.Hide(drawings)
        return
    end
    
    local rootScreen, onScreen, depth = WorldToScreen(root.Position)
    if not onScreen or depth <= 0 then
        ESP.Hide(drawings)
        return
    end
    
    local boxHeight = math.clamp(2000 / depth, 20, Camera.ViewportSize.Y * 0.8)
    local boxWidth = boxHeight * Tuning.BoxRatio
    local boxX = rootScreen.X - boxWidth / 2
    local boxY = rootScreen.Y - boxHeight / 2
    
    local color = Config.ESP_BoxColor
    
    if Config.ESP_Box then
        if Config.ESP_BoxStyle == "Corner" then
            ESP.RenderCornerBox(drawings, boxX, boxY, boxWidth, boxHeight, color)
        else
            ESP.RenderFullBox(drawings, boxX, boxY, boxWidth, boxHeight, color)
        end
    else
        for _, line in pairs({drawings.BoxTopLeft, drawings.BoxTopRight, drawings.BoxBottomLeft, drawings.BoxBottomRight, drawings.BoxTop, drawings.BoxBottom, drawings.BoxLeft, drawings.BoxRight}) do
            line.Visible = false
        end
    end
    
    if Config.ESP_Name then
        drawings.Name.Text = player.DisplayName
        drawings.Name.Position = Vector2.new(rootScreen.X, boxY - Tuning.NameSize - 4)
        drawings.Name.Color = color
        drawings.Name.Visible = true
    else
        drawings.Name.Visible = false
    end
    
    if Config.ESP_Distance then
        drawings.Distance.Text = string.format("[%dm]", math.floor(distance))
        drawings.Distance.Position = Vector2.new(rootScreen.X, boxY + boxHeight + 2)
        drawings.Distance.Color = Color3.fromRGB(200, 200, 200)
        drawings.Distance.Visible = true
    else
        drawings.Distance.Visible = false
    end
    
    if Config.ESP_Tracer then
        local screenSize = Camera.ViewportSize
        local tracerStart
        if Config.ESP_TracerOrigin == "Top" then
            tracerStart = Vector2.new(screenSize.X / 2, 0)
        elseif Config.ESP_TracerOrigin == "Center" then
            tracerStart = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
        else
            tracerStart = Vector2.new(screenSize.X / 2, screenSize.Y)
        end
        drawings.Tracer.From = tracerStart
        drawings.Tracer.To = Vector2.new(rootScreen.X, boxY + boxHeight)
        drawings.Tracer.Color = color
        drawings.Tracer.Visible = true
    else
        drawings.Tracer.Visible = false
    end
    
    if Config.ESP_Health then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local barHeight = boxHeight * healthPercent
        local barX = boxX - 6
        
        drawings.HealthBarBG.From = Vector2.new(barX, boxY)
        drawings.HealthBarBG.To = Vector2.new(barX, boxY + boxHeight)
        drawings.HealthBarBG.Visible = true
        
        local healthColor = Color3.fromRGB(
            255 * (1 - healthPercent),
            255 * healthPercent,
            0
        )
        drawings.HealthBar.From = Vector2.new(barX, boxY + boxHeight - barHeight)
        drawings.HealthBar.To = Vector2.new(barX, boxY + boxHeight)
        drawings.HealthBar.Color = healthColor
        drawings.HealthBar.Visible = true
    else
        drawings.HealthBarBG.Visible = false
        drawings.HealthBar.Visible = false
    end
end

local Aimbot = {}

local FOVCircle = nil
local TargetIndicator = nil
local TargetLine = nil

function Aimbot.CreateFOV()
    if not FOVCircle then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1
        FOVCircle.NumSides = 64
        FOVCircle.Filled = false
        FOVCircle.Visible = false
        FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    end
    
    if not TargetIndicator then
        TargetIndicator = Drawing.new("Circle")
        TargetIndicator.Thickness = 2
        TargetIndicator.NumSides = 32
        TargetIndicator.Radius = 15
        TargetIndicator.Filled = false
        TargetIndicator.Visible = false
        TargetIndicator.Color = Color3.fromRGB(255, 50, 50)
    end
    
    if not TargetLine then
        TargetLine = Drawing.new("Line")
        TargetLine.Thickness = 1
        TargetLine.Visible = false
        TargetLine.Color = Color3.fromRGB(255, 50, 50)
    end
end

function Aimbot.UpdateFOV()
    if FOVCircle then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = Config.AIM_FOV
        FOVCircle.Visible = Config.AIM_ShowFOV and Config.AIM_Enabled and not IsMobile
    end
    
    if TargetIndicator and TargetLine then
        if State.AimTarget and State.Aiming and Config.AIM_Enabled and Config.AIM_ShowTarget then
            local screenPos, onScreen = WorldToScreen(State.AimTarget.Position)
            if onScreen then
                TargetIndicator.Position = screenPos
                TargetIndicator.Visible = true
                
                local screenCenter = Camera.ViewportSize / 2
                TargetLine.From = Vector2.new(screenCenter.X, screenCenter.Y)
                TargetLine.To = screenPos
                TargetLine.Visible = IsMobile or Config.AIM_LockOn
            else
                TargetIndicator.Visible = false
                TargetLine.Visible = false
            end
        else
            TargetIndicator.Visible = false
            TargetLine.Visible = false
        end
    end
end

function Aimbot.GetTargetPart(character)
    if Config.AIM_TargetPart == "Head" then
        return GetHead(character)
    elseif Config.AIM_TargetPart == "Torso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or GetRoot(character)
    elseif Config.AIM_TargetPart == "Closest" then
        local parts = {"Head", "UpperTorso", "Torso", "HumanoidRootPart"}
        local mousePos = UserInputService:GetMouseLocation()
        local closestPart, closestDist = nil, math.huge
        for _, partName in ipairs(parts) do
            local part = character:FindFirstChild(partName)
            if part then
                local screenPos, onScreen = WorldToScreen(part.Position)
                if onScreen then
                    local dist = (screenPos - mousePos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPart = part
                    end
                end
            end
        end
        return closestPart
    end
    return GetRoot(character)
end

function Aimbot.GetTarget()
    local screenCenter = Camera.ViewportSize / 2
    local mousePos = IsMobile and Vector2.new(screenCenter.X, screenCenter.Y) or UserInputService:GetMouseLocation()
    local now = tick()
    
    if Config.AIM_HardLock and State.AimTargetPlayer then
        local currentPlayer = State.AimTargetPlayer
        local character = GetCharacter(currentPlayer)
        
        if character and IsAlive(character) then
            if not (Config.AIM_TeamCheck and IsTeammate(currentPlayer)) then
                local targetPart = Aimbot.GetTargetPart(character)
                if targetPart then
                    return targetPart, currentPlayer
                end
            end
        end
        
        State.AimTargetPlayer = nil
    elseif Config.AIM_Sticky and State.AimTargetPlayer then
        local currentPlayer = State.AimTargetPlayer
        local character = GetCharacter(currentPlayer)
        
        if character and IsAlive(character) then
            if not (Config.AIM_TeamCheck and IsTeammate(currentPlayer)) then
                local targetPart = Aimbot.GetTargetPart(character)
                if targetPart then
                    local screenPos, onScreen = WorldToScreen(targetPart.Position)
                    if onScreen then
                        local dist = (screenPos - mousePos).Magnitude
                        if dist < Config.AIM_StickyFOV then
                            return targetPart, currentPlayer
                        end
                    end
                end
            end
        end
        
        State.AimTargetPlayer = nil
    end
    
    if Config.AIM_Sticky and (now - State.LastTargetSwitch) < Config.AIM_StickyTime then
        if State.AimTarget and State.AimTarget.Parent then
            return State.AimTarget, State.AimTargetPlayer
        end
    end
    
    local bestTarget = nil
    local bestPlayer = nil
    local bestDist = Config.AIM_FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Config.AIM_TeamCheck and IsTeammate(player) then continue end
        
        local character = GetCharacter(player)
        if not character then continue end
        if not IsAlive(character) then continue end
        
        local targetPart = Aimbot.GetTargetPart(character)
        if not targetPart then continue end
        
        local screenPos, onScreen = WorldToScreen(targetPart.Position)
        if not onScreen then continue end
        
        local dist = (screenPos - mousePos).Magnitude
        if dist < bestDist then
            bestDist = dist
            bestTarget = targetPart
            bestPlayer = player
        end
    end
    
    if bestTarget and bestPlayer ~= State.AimTargetPlayer then
        State.LastTargetSwitch = now
        State.AimTargetPlayer = bestPlayer
    end
    
    return bestTarget, bestPlayer
end

function Aimbot.Step()
    if not Config.AIM_Enabled then
        State.Aiming = false
        State.AimTarget = nil
        State.AimTargetPlayer = nil
        State.CurrentAimVelocity = Vector2.new(0, 0)
        return
    end
    
    local keyDown = State.MobileAiming
    
    if not keyDown then
        if Config.AIM_Key == Enum.UserInputType.MouseButton2 then
            keyDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        elseif Config.AIM_Key == Enum.UserInputType.MouseButton1 then
            keyDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        else
            pcall(function()
                keyDown = UserInputService:IsKeyDown(Config.AIM_Key)
            end)
        end
    end
    
    if not keyDown then
        State.Aiming = false
        State.AimTarget = nil
        State.AimTargetPlayer = nil
        State.CurrentAimVelocity = Vector2.new(0, 0)
        return
    end
    
    State.Aiming = true
    local target, targetPlayer = Aimbot.GetTarget()
    if not target then 
        State.AimTarget = nil
        State.AimTargetPlayer = nil
        return 
    end
    
    State.AimTarget = target
    State.AimTargetPlayer = targetPlayer
    
    if IsMobile or Config.AIM_LockOn then
        local char = GetCharacter(LocalPlayer)
        if not char then return end
        
        local targetPos = target.Position
        local camPos = Camera.CFrame.Position
        
        local currentLook = Camera.CFrame.LookVector
        local targetDirection = (targetPos - camPos).Unit
        
        local dot = currentLook:Dot(targetDirection)
        local angleToTarget = math.acos(math.clamp(dot, -1, 1))
        
        local baseSmoothness = Config.AIM_Smooth
        local dynamicSmooth = baseSmoothness
        
        if Config.AIM_HardLock then
            if angleToTarget > math.rad(45) then
                dynamicSmooth = baseSmoothness * 0.3
            elseif angleToTarget > math.rad(20) then
                dynamicSmooth = baseSmoothness * 0.5
            elseif angleToTarget > math.rad(5) then
                dynamicSmooth = baseSmoothness * 0.8
            else
                dynamicSmooth = baseSmoothness * 1.2
            end
            dynamicSmooth = math.clamp(dynamicSmooth, 0.03, 0.5)
        else
            if angleToTarget > math.rad(30) then
                dynamicSmooth = baseSmoothness * 0.5
            elseif angleToTarget > math.rad(10) then
                dynamicSmooth = baseSmoothness * 0.75
            elseif angleToTarget < math.rad(2) then
                dynamicSmooth = baseSmoothness * 1.5
            end
            dynamicSmooth = math.clamp(dynamicSmooth, 0.02, 0.3)
        end
        
        local currentCF = Camera.CFrame
        local targetCF = CFrame.lookAt(camPos, targetPos)
        
        local newCF = currentCF:Lerp(targetCF, dynamicSmooth)
        
        local currentAngles = Vector3.new(currentCF:ToEulerAnglesYXZ())
        local newAngles = Vector3.new(newCF:ToEulerAnglesYXZ())
        local targetAnglesVec = Vector3.new(targetCF:ToEulerAnglesYXZ())
        
        local angleDiff = (targetAnglesVec - currentAngles).Magnitude
        if angleDiff < 0.005 then
            return
        end
        
        Camera.CFrame = newCF
    else
        local screenPos = WorldToScreen(target.Position)
        local mousePos = UserInputService:GetMouseLocation()
        local delta = screenPos - mousePos
        
        if delta.Magnitude < 1 then return end
        
        local smoothed = delta * Config.AIM_Smooth
        
        pcall(function()
            if mousemoverel then
                mousemoverel(smoothed.X, smoothed.Y)
            end
        end)
    end
end

local ChamsModule = {}

function ChamsModule.Create(player)
    if Chams[player] then return end
    
    local character = GetCharacter(player)
    if not character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Config.CHAMS_FillColor
    highlight.OutlineColor = Config.CHAMS_OutlineColor
    highlight.FillTransparency = Config.CHAMS_FillTransparency
    highlight.OutlineTransparency = Config.CHAMS_OutlineTransparency
    highlight.Parent = character
    
    Chams[player] = highlight
end

function ChamsModule.Remove(player)
    if Chams[player] then
        pcall(function() Chams[player]:Destroy() end)
        Chams[player] = nil
    end
end

function ChamsModule.Update(player)
    if not Config.CHAMS_Enabled then
        ChamsModule.Remove(player)
        return
    end
    
    if player == LocalPlayer then
        ChamsModule.Remove(player)
        return
    end
    
    if Config.ESP_TeamCheck and IsTeammate(player) then
        ChamsModule.Remove(player)
        return
    end
    
    local character = GetCharacter(player)
    if not character or not IsAlive(character) then
        ChamsModule.Remove(player)
        return
    end
    
    if not Chams[player] then
        ChamsModule.Create(player)
    end
    
    if Chams[player] then
        Chams[player].FillColor = Config.CHAMS_FillColor
        Chams[player].OutlineColor = Config.CHAMS_OutlineColor
        Chams[player].FillTransparency = Config.CHAMS_FillTransparency
        Chams[player].OutlineTransparency = Config.CHAMS_OutlineTransparency
    end
end

function ChamsModule.ClearAll()
    for player, highlight in pairs(Chams) do
        pcall(function() highlight:Destroy() end)
    end
    Chams = {}
end

local GameRadar = nil
local RadarConfig = {
    Enabled = false,
    Range = 200,
    TeamCheck = true
}

local TriggerState = {
    LastFire = 0,
    Cooldown = 0.15,
    IsFiring = false
}

local function Triggerbot()
    if not State.MobileTrigger then return end
    if TriggerState.IsFiring then return end
    
    local now = tick()
    if now - TriggerState.LastFire < TriggerState.Cooldown then return end
    
    local target = Aimbot.GetTarget()
    if not target then return end
    
    local screenPos, onScreen = WorldToScreen(target.Position)
    if not onScreen then return end
    
    local cam = Workspace.CurrentCamera
    if not cam then return end
    
    local screenCenter = cam.ViewportSize / 2
    local dist = (screenPos - Vector2.new(screenCenter.X, screenCenter.Y)).Magnitude
    
    if dist < 50 then
        TriggerState.IsFiring = true
        TriggerState.LastFire = now
        
        task.spawn(function()
            pcall(function()
                local VIM = game:GetService("VirtualInputManager")
                VIM:SendMouseButtonEvent(screenCenter.X, screenCenter.Y, 0, true, game, 1)
                task.wait(0.03)
                VIM:SendMouseButtonEvent(screenCenter.X, screenCenter.Y, 0, false, game, 1)
            end)
            TriggerState.IsFiring = false
        end)
    end
end

local function MainLoop()
    if State.Unloaded then return end
    
    Camera = Workspace.CurrentCamera
    if not Camera then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        ESP.Render(player)
        ChamsModule.Update(player)
    end
    
    Aimbot.UpdateFOV()
    Aimbot.Step()
    
    if IsMobile then
        Triggerbot()
    end
end

local function Cleanup()
    for player, drawings in pairs(Cache.ESP) do
        ESP.Destroy(drawings)
    end
    Cache.ESP = {}
    ChamsModule.ClearAll()
    if GameRadar then
        pcall(function() GameRadar:Destroy() end)
        GameRadar = nil
    end
    if FOVCircle then
        pcall(function() FOVCircle:Remove() end)
        FOVCircle = nil
    end
    if TargetIndicator then
        pcall(function() TargetIndicator:Remove() end)
        TargetIndicator = nil
    end
    if TargetLine then
        pcall(function() TargetLine:Remove() end)
        TargetLine = nil
    end
end

local function Unload()
    if State.Unloaded then return end
    State.Unloaded = true
    
    for _, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Connections = {}
    
    Cleanup()
end

Aimbot.CreateFOV()

Connections.Render = RunService.RenderStepped:Connect(MainLoop)

Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
    if Cache.ESP[player] then
        ESP.Destroy(Cache.ESP[player])
        Cache.ESP[player] = nil
    end
    ChamsModule.Remove(player)
end)

if IsMobile then
    UI.Loading({ Title = "Universal ESP", Subtitle = "Loading mobile mode...", Duration = 2, Fullscreen = false })
else
    UI.Splash({ Title = "Universal ESP", Subtitle = "Loading...", Duration = 2 })
end
task.wait(2.2)

local Window = UI.New({
    Title = "Universal",
    Subtitle = "ESP & Aimbot",
    Theme = "Default",
    Size = UDim2.new(0, 620, 0, 480),
    ShowUserInfo = true,
    ShowActiveList = not IsMobile,
    Logo = UI.Logos.XanBar,
    ShowLogo = true
})

local Watermark = UI.Watermark({ 
    Text = "Universal ESP", 
    Position = IsMobile and UDim2.new(0.5, -60, 0, 10) or UDim2.new(0, 10, 0, 10), 
    ShowFPS = true, 
    ShowPing = true, 
    Visible = not IsMobile
})

local AimbotTab = Window:AddTab("Aimbot", UI.Icons.Aimbot)

AimbotTab:AddSection("Aimbot Settings")

AimbotTab:AddToggle("Enable Aimbot", { Default = false, Flag = "AimbotEnabled", ShowInActiveList = true }, function(v)
    Config.AIM_Enabled = v
    if FOVCircle then
        FOVCircle.Visible = v and Config.AIM_ShowFOV
    end
end)

AimbotTab:AddDropdown("Target Part", {"Head", "Torso", "Closest"}, function(v)
    Config.AIM_TargetPart = v
end)

AimbotTab:AddSlider("FOV Size", { Min = 50, Max = 500, Default = IsMobile and 300 or 180, Increment = 10, Suffix = "px", Flag = "FOVSize" }, function(v)
    Config.AIM_FOV = v
    if FOVCircle then
        FOVCircle.Radius = v
    end
end)

AimbotTab:AddGraph("Smoothing", { Min = 0.02, Max = 0.5, Default = IsMobile and 0.12 or 0.15, Flag = "AimSmooth" }, function(v)
    Config.AIM_Smooth = v
end)

AimbotTab:AddSection("FOV Circle")

AimbotTab:AddToggle("Show FOV Circle", { Default = not IsMobile, Flag = "ShowFOV" }, function(v)
    Config.AIM_ShowFOV = v
    if FOVCircle then
        FOVCircle.Visible = v and Config.AIM_Enabled and not IsMobile
    end
end)

AimbotTab:AddColorPicker("FOV Color", { Default = UI.RGB(255, 255, 255), Flag = "FOVColor" }, function(color)
    if FOVCircle then
        FOVCircle.Color = color
    end
end)

AimbotTab:AddSection("Target Indicator")

AimbotTab:AddToggle("Show Target Indicator", { Default = true, Flag = "ShowTargetInd" }, function(v)
    Config.AIM_ShowTarget = v
end)

AimbotTab:AddColorPicker("Target Color", { Default = UI.RGB(255, 50, 50), Flag = "TargetColor" }, function(color)
    if TargetIndicator then
        TargetIndicator.Color = color
    end
    if TargetLine then
        TargetLine.Color = color
    end
end)

AimbotTab:AddSection("Aim Mode")

AimbotTab:AddToggle("Lock-On Mode", { Default = IsMobile, Flag = "LockOn" }, function(v)
    Config.AIM_LockOn = v
end)

AimbotTab:AddToggle("Sticky Targeting", { Default = IsMobile, Flag = "StickyAim" }, function(v)
    Config.AIM_Sticky = v
end)

AimbotTab:AddToggle("Hard Lock (Mobile)", { Default = IsMobile, Flag = "HardLock", ShowInActiveList = true }, function(v)
    Config.AIM_HardLock = v
end)

AimbotTab:AddSlider("Sticky Time", { Min = 0.1, Max = 2, Default = 0.5, Increment = 0.1, Suffix = "s", Flag = "StickyTime" }, function(v)
    Config.AIM_StickyTime = v
end)

AimbotTab:AddParagraph("Info", IsMobile and "Hard Lock: Never loses target until they die\nSticky: Keeps target within large FOV" or "Lock-On: Camera follows target\nSticky: Prevents rapid target switching")

AimbotTab:AddSection("Target Filters")

AimbotTab:AddToggle("Team Check", { Default = true, Flag = "AimTeamCheck" }, function(v)
    Config.AIM_TeamCheck = v
end)

local ESPTab = Window:AddTab("ESP", UI.Icons.ESP)

ESPTab:AddSection("ESP Settings")

ESPTab:AddToggle("Enable ESP", { Default = true, Flag = "ESPEnabled", ShowInActiveList = true }, function(v)
    Config.ESP_Enabled = v
    if not v then
        for _, player in ipairs(Players:GetPlayers()) do
            local drawings = Cache.ESP[player]
            if drawings then ESP.Hide(drawings) end
        end
    end
end)

ESPTab:AddDropdown("Box Style", {"Full", "Corner"}, function(v)
    Config.ESP_BoxStyle = v
end)

ESPTab:AddColorPicker("ESP Color", { Default = UI.RGB(255, 75, 85), Flag = "ESPColor" }, function(color)
    Config.ESP_BoxColor = color
end)

ESPTab:AddSlider("Max Distance", { Min = 100, Max = 2000, Default = 1000, Increment = 50, Suffix = "m", Flag = "ESPMaxDist" }, function(v)
    Config.ESP_MaxDistance = v
end)

ESPTab:AddSection("Display Options")

ESPTab:AddToggle("Show Box", { Default = true, Flag = "ESPBox" }, function(v)
    Config.ESP_Box = v
end)

ESPTab:AddToggle("Show Names", { Default = true, Flag = "ESPName" }, function(v)
    Config.ESP_Name = v
end)

ESPTab:AddToggle("Show Distance", { Default = true, Flag = "ESPDistance" }, function(v)
    Config.ESP_Distance = v
end)

ESPTab:AddToggle("Show Health Bar", { Default = true, Flag = "ESPHealth" }, function(v)
    Config.ESP_Health = v
end)

ESPTab:AddSection("Tracers")

ESPTab:AddToggle("Show Tracers", { Default = false, Flag = "ESPTracer" }, function(v)
    Config.ESP_Tracer = v
end)

ESPTab:AddDropdown("Tracer Origin", {"Bottom", "Center", "Top"}, function(v)
    Config.ESP_TracerOrigin = v
end)

ESPTab:AddSection("Team Filter")

ESPTab:AddToggle("Team Check", { Default = true, Flag = "ESPTeamCheck" }, function(v)
    Config.ESP_TeamCheck = v
end)

local ChamsTab = Window:AddTab("Chams", UI.Icons.Visuals)

ChamsTab:AddSection("Chams Settings")

ChamsTab:AddToggle("Enable Chams", { Default = false, Flag = "ChamsEnabled", ShowInActiveList = true }, function(v)
    Config.CHAMS_Enabled = v
    if not v then
        ChamsModule.ClearAll()
    end
end)

ChamsTab:AddColorPicker("Fill Color", { Default = UI.RGB(255, 75, 85), Flag = "ChamsFill" }, function(color)
    Config.CHAMS_FillColor = color
end)

ChamsTab:AddColorPicker("Outline Color", { Default = UI.RGB(255, 255, 255), Flag = "ChamsOutline" }, function(color)
    Config.CHAMS_OutlineColor = color
end)

ChamsTab:AddSlider("Fill Transparency", { Min = 0, Max = 1, Default = 0.5, Increment = 0.1, Flag = "ChamsFillTrans" }, function(v)
    Config.CHAMS_FillTransparency = v
end)

ChamsTab:AddSlider("Outline Transparency", { Min = 0, Max = 1, Default = 0, Increment = 0.1, Flag = "ChamsOutlineTrans" }, function(v)
    Config.CHAMS_OutlineTransparency = v
end)

local MiscTab = Window:AddTab("Misc", UI.Icons.Misc)

MiscTab:AddSection("Crosshair")

local crosshairSettings = MiscTab:AddCrosshair({
    Name = "Custom Crosshair",
    Styles = {"None", "Dot", "Small Cross", "Cross", "Open Cross", "Circle", "Icon"},
    DefaultStyle = "Cross",
    DefaultColor = UI.Colors.Red,
    DefaultSize = 12,
    DefaultThickness = 2,
    DefaultGap = 4,
    Enabled = false,
    Flag = "Crosshair"
})

MiscTab:AddSection("Movement")

local SpeedMeter = MiscTab:AddSpeedometer({ Name = "Current Speed", Min = 0, Max = 200, Flag = "SpeedDisplay" })

MiscTab:AddSlider("Walk Speed", { Min = 16, Max = 200, Default = 16, Flag = "WalkSpeed" }, function(v)
    SpeedMeter:Set(v)
    local char = GetCharacter(LocalPlayer)
    local humanoid = char and GetHumanoid(char)
    if humanoid then
        humanoid.WalkSpeed = v
    end
end)

MiscTab:AddSlider("Jump Power", { Min = 50, Max = 200, Default = 50, Increment = 5, Flag = "JumpPower" }, function(v)
    local char = GetCharacter(LocalPlayer)
    local humanoid = char and GetHumanoid(char)
    if humanoid then
        humanoid.JumpPower = v
    end
end)

MiscTab:AddSection("Display")

MiscTab:AddToggle("Show Watermark", { Default = not IsMobile, Flag = "ShowWatermark", ShowInActiveList = false }, function(v)
    if v then Watermark:Show() else Watermark:Hide() end
end)

MiscTab:AddToggle("Show Active List", { Default = true, ShowInActiveList = false }, function(v)
    if v then Window:ShowActiveList() else Window:HideActiveList() end
end)

MiscTab:AddSection("Actions")

MiscTab:AddDangerButton("Unload Script", function()
    UI.Warning("Unloading", "Script will be unloaded...")
    task.wait(1)
    Window:Destroy()
    Watermark:Destroy()
    Unload()
end)

local RadarTab = Window:AddTab("Radar", UI.Icons.Radar)

RadarTab:AddSection("Radar Settings")

RadarTab:AddToggle("Show Radar", { Default = false, Flag = "ShowRadar", ShowInActiveList = true }, function(v)
    RadarConfig.Enabled = v
    if v then
        if not GameRadar then
            GameRadar = UI.EasyRadar({
                Position = IsMobile and UDim2.new(0, 10, 1, -130) or UDim2.new(0, 20, 1, -180),
                Size = IsMobile and UDim2.new(0, 100, 0, 100) or UDim2.new(0, 150, 0, 150),
                Range = RadarConfig.Range,
                TeamCheck = RadarConfig.TeamCheck,
                EnemyColor = Config.ESP_BoxColor,
                IsEnemy = function(player)
                    if not RadarConfig.TeamCheck then return true end
                    return not IsTeammate(player)
                end
            })
        else
            GameRadar:Show()
        end
    else
        if GameRadar then
            GameRadar:Hide()
        end
    end
end)

RadarTab:AddSlider("Radar Range", { Min = 50, Max = 500, Default = 200, Increment = 25, Suffix = " studs", Flag = "RadarRange" }, function(v)
    RadarConfig.Range = v
    if GameRadar then
        GameRadar:SetRange(v)
    end
end)

RadarTab:AddToggle("Radar Team Check", { Default = true, Flag = "RadarTeamCheck" }, function(v)
    RadarConfig.TeamCheck = v
    if GameRadar then
        GameRadar:SetTeamCheck(v)
    end
end)

RadarTab:AddColorPicker("Enemy Color", { Default = UI.RGB(255, 50, 50), Flag = "RadarEnemyColor" }, function(color)
    if GameRadar then
        GameRadar:SetEnemyColor(color)
    end
end)

RadarTab:AddParagraph("Info", "Radar auto-tracks enemies using the xan.bar library.\nEnemies appear as dots relative to your position.")

local AimBtn = nil
local TriggerBtn = nil
local MenuBtn = nil

if IsMobile then
    UI.MobileToggle({ Position = UDim2.new(0, 20, 1, -80), Window = Window })
    
    AimBtn = UI.AimButton({ 
        Position = UDim2.new(1, -90, 0.5, -60),
        HoldMode = true, 
        Callback = function(state)
            if State.AimHoldMode then
                State.MobileAiming = state
                if not state then
                    State.AimTarget = nil
                    State.AimTargetPlayer = nil
                    State.CurrentAimVelocity = Vector2.new(0, 0)
                end
            else
                if state then
                    State.MobileAimToggled = not State.MobileAimToggled
                    State.MobileAiming = State.MobileAimToggled
                    if not State.MobileAimToggled then
                        State.AimTarget = nil
                        State.AimTargetPlayer = nil
                        State.CurrentAimVelocity = Vector2.new(0, 0)
                    end
                end
            end
        end
    })
    
    TriggerBtn = UI.TriggerButton({ 
        Position = UDim2.new(1, -90, 0.5, 20),
        HoldMode = true, 
        Callback = function(state)
            if State.TriggerHoldMode then
                State.MobileTrigger = state
                if not state then
                    TriggerState.IsFiring = false
                end
            else
                if state then
                    State.MobileTriggerToggled = not State.MobileTriggerToggled
                    State.MobileTrigger = State.MobileTriggerToggled
                    if not State.MobileTriggerToggled then
                        TriggerState.IsFiring = false
                    end
                end
            end
        end
    })
    
    MenuBtn = UI.FloatingButton({ 
        Position = UDim2.new(0, 20, 1, -150), 
        Size = 50, 
        Icon = UI.Logos.XanBar, 
        Label = "Menu", 
        Draggable = true, 
        Callback = function() Window:Toggle() end 
    })
    
    local MobileTab = Window:AddTab("Mobile", UI.Icons.Settings)
    
    MobileTab:AddSection("Aim Button")
    
    MobileTab:AddToggle("Show Aim Button", { Default = true, Flag = "ShowAimBtn" }, function(v) 
        if AimBtn then
            if v then AimBtn:Show() else AimBtn:Hide() end 
        end
    end)
    
    MobileTab:AddToggle("Aim Hold Mode", { Default = true, Flag = "AimHoldMode" }, function(v)
        State.AimHoldMode = v
        if not v then
            State.MobileAimToggled = false
            State.MobileAiming = false
        end
        if AimBtn and AimBtn.SetHoldMode then
            AimBtn:SetHoldMode(v)
        end
    end)
    
    MobileTab:AddParagraph("Aim Mode Info", "Hold: Press and hold to aim\nToggle: Tap once to lock, tap again to unlock")
    
    MobileTab:AddSection("Trigger Button")
    
    MobileTab:AddToggle("Show Trigger Button", { Default = true, Flag = "ShowTriggerBtn" }, function(v) 
        if TriggerBtn then
            if v then TriggerBtn:Show() else TriggerBtn:Hide() end 
        end
    end)
    
    MobileTab:AddToggle("Trigger Hold Mode", { Default = true, Flag = "TriggerHoldMode" }, function(v)
        State.TriggerHoldMode = v
        if not v then
            State.MobileTriggerToggled = false
            State.MobileTrigger = false
        end
        if TriggerBtn and TriggerBtn.SetHoldMode then
            TriggerBtn:SetHoldMode(v)
        end
    end)
    
    MobileTab:AddSlider("Trigger Cooldown", { Min = 0.05, Max = 0.5, Default = 0.15, Increment = 0.01, Suffix = "s", Flag = "TriggerCooldown" }, function(v)
        TriggerState.Cooldown = v
    end)
    
    MobileTab:AddSection("Menu Button")
    
    MobileTab:AddToggle("Show Menu Button", { Default = true, Flag = "ShowMenuBtn" }, function(v) 
        if MenuBtn then
            if v then MenuBtn:Show() else MenuBtn:Hide() end 
        end
    end)
    
    MobileTab:AddSection("Tips")
    MobileTab:AddParagraph("Usage", "• Hold Mode: Hold button to activate\n• Toggle Mode: Tap to turn on/off\n• Drag buttons to reposition\n• Go crazy with toggle mode!")
    
    if FOVCircle then
        FOVCircle.Visible = false
        Config.AIM_ShowFOV = false
    end
    
    UI.Info("Mobile Mode", "Touch controls enabled")
else
    Connections.InputBegan = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            Window:Toggle()
        elseif input.KeyCode == Enum.KeyCode.Home then
            UI.Warning("Unloading", "Script will be unloaded...")
            task.wait(0.5)
            Window:Destroy()
            Watermark:Destroy()
            Unload()
        end
    end)
end

UI.Success("Loaded!", "Universal ESP & Aimbot ready")