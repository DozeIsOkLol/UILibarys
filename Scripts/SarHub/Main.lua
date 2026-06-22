--=====================================================================
-- ESCAPE KEYBOARD HUB | v1.0
-- Author : Meister
-- Toggle : INSERT
--=====================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

-- Load UI library
local MeisterUI
local ok, err = pcall(function()
    MeisterUI = loadstring(game:HttpGet(
        "https://pastebin.com/raw/LRzFynbz"
    ))()
end)
if not ok then
    error("[HUB] Failed to load MeisterUI: " .. tostring(err))
end


--=====================================================================
-- SERVICES
--=====================================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

--=====================================================================
-- CONFIGURATION STATE
--=====================================================================
local Cfg = {
    WinPos        = Vector3.new(-6809.3223, 531.2539, 1468.8073),
    WinSpeed      = 300,
    WinHeight     = 900,
    Fly           = false,
    FlySpeed      = 300,
    Noclip        = false,
    SpeedHack     = false,
    WalkSpeed     = 16,
    JumpPower     = 50,
    InfiniteJump  = false,
}

local FlyToggle
local StartFly, StopFly

--=====================================================================
-- WINDOW
--=====================================================================
local Window = MeisterUI:CreateWindow({
    Name     = "SARHUB BY SARpastes | Escape Keyboard Hub",
    HideKey  = Enum.KeyCode.Insert,
})

local FarmTab   = Window:CreateTab("Auto Farm")
local MoveTab   = Window:CreateTab("Movement")
local PlayerTab = Window:CreateTab("Player")
local MiscTab   = Window:CreateTab("Misc")

--=====================================================================
-- MOVEMENT LOGIC (Moved up for scope)
--=====================================================================

local FlyBV, FlyBG, FlyConn

StartFly = function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")

    if not root or not hum then return end

    if FlyBV then FlyBV:Destroy() end
    if FlyBG then FlyBG:Destroy() end
    if FlyConn then FlyConn:Disconnect() end

    hum.PlatformStand = true

    FlyBG = Instance.new("BodyGyro")
    FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBG.P         = 5e4
    FlyBG.CFrame    = root.CFrame
    FlyBG.Parent    = root

    FlyBV = Instance.new("BodyVelocity")
    FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBV.Velocity = Vector3.zero
    FlyBV.Parent   = root

    FlyConn = RunService.RenderStepped:Connect(function()
        if not Cfg.Fly then return end
        local cam = Camera.CFrame
        local spd = Cfg.FlySpeed
        local vel = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W)      then vel = vel + cam.LookVector   * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)      then vel = vel - cam.LookVector   * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)      then vel = vel - cam.RightVector   * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)      then vel = vel + cam.RightVector   * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)  then vel = vel + Vector3.yAxis     * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.yAxis * spd end

        FlyBV.Velocity = vel
        FlyBG.CFrame   = cam
    end)
end

StopFly = function()
    Cfg.Fly = false
    if FlyToggle then FlyToggle:Set(false) end -- Sync UI
    if FlyConn then FlyConn:Disconnect() ; FlyConn = nil end
    if FlyBV   then FlyBV:Destroy()      ; FlyBV   = nil end
    if FlyBG   then FlyBG:Destroy()      ; FlyBG   = nil end

    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then 
        hum.PlatformStand = false 
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
end

--=====================================================================
-- AUTO FARM TAB
--=====================================================================

-- Auto Walk: Simulates movement to fool the server
FarmTab:CreateToggle({
    Name = "Auto Walk",
    CurrentValue = false,
    Callback = function(v)
        Cfg.AutoWalk = v
        if v then
            task.spawn(function()
                while Cfg.AutoWalk do
                    local char = LocalPlayer.Character
                    local hum  = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        -- Simulate walk forward and backward slightly
                        hum:Move(Vector3.new(0, 0, 1), true)
                        task.wait(0.1)
                        hum:Move(Vector3.new(0, 0, -1), true)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

FarmTab:CreateSeparator()

-- Auto Win: Tweens to destination to bypass anti-cheat
FarmTab:CreateToggle({
    Name = "Auto Win (Smooth Travel)",
    CurrentValue = false,
    Callback = function(v)
        Cfg.AutoWin = v
        if v then
            task.spawn(function()
                while Cfg.AutoWin do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if root and Cfg.WinPos then
                        local dist = (root.Position - Cfg.WinPos).Magnitude

                        if dist > 5 then
                            -- Enable Fly and Noclip visual/state during travel
                            if not Cfg.Fly then
                                Cfg.Fly = true
                                StartFly()
                            end
                            local oldNoclip = Cfg.Noclip
                            Cfg.Noclip = true

                            -- Rise up first
                            MeisterUI:Notify({Title="Auto Win", Content="Rising up...", Duration=2})
                            local riseHeight = Cfg.WinHeight
                            local riseStart = root.CFrame
                            local riseEnd = riseStart * CFrame.new(0, riseHeight, 0)

                            for i = 0, 1, 0.05 do
                                if not Cfg.AutoWin or not root.Parent then break end
                                root.CFrame = riseStart:Lerp(riseEnd, i)
                                task.wait(0.02)
                            end

                            if not Cfg.AutoWin or not root.Parent then Cfg.Noclip = oldNoclip return end
                            task.wait(0.2)

                            -- Horizontal travel
                            MeisterUI:Notify({Title="Auto Win", Content="Traveling...", Duration=2})
                            local startCF = root.CFrame
                            local targetPos = Vector3.new(Cfg.WinPos.X, root.Position.Y, Cfg.WinPos.Z)
                            local targetCF = CFrame.new(targetPos, Vector3.new(targetPos.X, targetPos.Y, targetPos.Z + 1))

                            local distance = (root.Position - targetPos).Magnitude
                            local steps = math.floor(distance / (Cfg.WinSpeed / 30))

                            for i = 1, steps do
                                if not Cfg.AutoWin or not root.Parent then break end
                                root.CFrame = startCF:Lerp(targetCF, i/steps)
                                task.wait(0.03)
                            end

                            if not Cfg.AutoWin or not root.Parent then Cfg.Noclip = oldNoclip return end
                            task.wait(0.2)

                            -- Descend
                            MeisterUI:Notify({Title="Auto Win", Content="Descending...", Duration=2})
                            local currentCF = root.CFrame
                            local finalCF = CFrame.new(Cfg.WinPos)

                            for i = 0, 1, 0.01 do
                                if not Cfg.AutoWin or not root.Parent then break end
                                root.CFrame = currentCF:Lerp(finalCF, i)
                                task.wait(0.01)
                            end

                            if root.Parent then
                                root.CFrame = finalCF
                            end

                            Cfg.Noclip = oldNoclip
                            StopFly() -- This will also update the UI toggle

                            MeisterUI:Notify({
                                Title   = "Auto Win",
                                Content = "Arrived! Resetting in 3s...",
                                Duration = 3
                            })

                            task.wait(3)

                            -- Reset character to spawn
                            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if hum then hum.Health = 0 end

                            MeisterUI:Notify({
                                Title   = "Auto Win",
                                Content = "Resetting... Next loop in 5s.",
                                Duration = 5
                            })

                            task.wait(5)
                        end
                    end
                    task.wait(0.1) -- Fast poll for start
                end
            end)
        end
    end
})

--=====================================================================
-- MOVEMENT TAB
--=====================================================================

FlyToggle = MoveTab:CreateToggle({
    Name         = "Fly (WASD + Space / Ctrl)",
    CurrentValue = false,
    Callback = function(v)
        Cfg.Fly = v
        if v then StartFly() else StopFly() end
    end
})

MoveTab:CreateSlider({
    Name         = "Fly Speed",
    Range        = {10, 2000},
    Increment    = 10,
    CurrentValue = 300,
    Callback     = function(v) Cfg.FlySpeed = v end
})

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Cfg.Fly then StartFly() end
end)

MoveTab:CreateSeparator()

MoveTab:CreateToggle({
    Name         = "Noclip",
    CurrentValue = false,
    Callback     = function(v) Cfg.Noclip = v end
})

--=====================================================================
-- PLAYER TAB
--=====================================================================

PlayerTab:CreateSlider({
    Name         = "Walk Speed",
    Range        = {16, 1000},
    Increment    = 1,
    CurrentValue = 16,
    Callback = function(v)
        Cfg.WalkSpeed = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

PlayerTab:CreateSlider({
    Name         = "Jump Power",
    Range        = {50, 1000},
    Increment    = 1,
    CurrentValue = 50,
    Callback = function(v)
        Cfg.JumpPower = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower    = v
        end
    end
})

PlayerTab:CreateToggle({
    Name         = "Infinite Jump",
    CurrentValue = false,
    Callback     = function(v) Cfg.InfiniteJump = v end
})

UserInputService.JumpRequest:Connect(function()
    if Cfg.InfiniteJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

--=====================================================================
-- MISC TAB
--=====================================================================

MiscTab:CreateButton({
    Name = "Enable Anti-AFK",
    Callback = function()
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0, 0), Camera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0, 0), Camera.CFrame)
        end)
        MeisterUI:Notify({
            Title   = "Anti-AFK",
            Content = "Active",
            Duration = 3
        })
    end
})

--=====================================================================
-- PHYSICS LOOP
--=====================================================================
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    -- Noclip
    if Cfg.Noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Preserve WalkSpeed
    if hum and Cfg.WalkSpeed ~= 16 then
        hum.WalkSpeed = Cfg.WalkSpeed
    end
end)

MeisterUI:Notify({
    Title   = "SARHUB BY SARpastes Loaded",
    Content = "Press INSERT to toggle menu.",
    Duration = 5
})
