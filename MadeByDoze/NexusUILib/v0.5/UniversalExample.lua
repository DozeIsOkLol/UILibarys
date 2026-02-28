--[[
    NexusLib v0.5 —  Universal Script
  
    
    Available Themes: "Dark" | "Light" | "Midnight" | "Rose"
]]

local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/MadeByDoze/NexusUILib/v0.5/NexusLib.lua"))()

local Win = Nexus:CreateWindow({
    Title     = "Nexus Universal Script",
    Subtitle  = "v0.1",
    Size      = UDim2.new(0, 600, 0, 450),
    ToggleKey = Enum.KeyCode.RightShift,
    ConfigDir = "NexusUSE",
    Theme     = "Dark",
})

local wm = Win:AddWatermark("Nexus Universal Script | " .. game.Players.LocalPlayer.Name)

-- ═══════════════════════════════════════════════════════════════════════════
-- GLOBAL VARIABLES & FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- State variables
local FlyEnabled = false
local NoclipEnabled = false
local ESPEnabled = false
local FullbrightEnabled = false
local InfiniteJumpEnabled = false
local AntiAFKEnabled = true
local SpeedHackActive = false
local AutoFarmActive = false

-- Connections
local Connections = {}

-- Helper function to get character
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- Helper function to get humanoid
local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Helper function to get root part
local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB: HOME
-- ═══════════════════════════════════════════════════════════════════════════

local Home = Win:AddTab({ Name = "Home", Icon = "🏠" })

Home:AddLabel({
    Text = "Welcome to Universal Script Pro v2.0!\n\nThis script works on all Roblox games and includes:\n• Advanced Player Modifications\n• Combat Enhancements\n• ESP & Visuals\n• Teleportation System\n• Auto-Farm Tools\n• And much more!",
})

Home:AddImage({
    Image   = "rbxassetid://7072706796",
    Height  = 90,
    Caption = "Universal Script Pro",
    Tooltip = "Works on all Roblox games",
})

Home:AddSection("Quick Actions")

Home:AddButton({
    Name       = "Rejoin Server",
    ButtonText = "Rejoin",
    Tooltip    = "Instantly rejoin a new server",
    Callback   = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})

Home:AddButton({
    Name       = "Server Hop",
    ButtonText = "Hop",
    Color      = Color3.fromRGB(100, 150, 255),
    Tooltip    = "Find and join a different server",
    Callback   = function()
        Nexus:Notify({ Title = "Server Hop", Message = "Finding new server...", Type = "Info" })
        -- Server hop logic would go here
    end,
})

Home:AddButton({
    Name       = "Copy Game ID",
    ButtonText = "Copy",
    Callback   = function()
        pcall(setclipboard, tostring(game.PlaceId))
        Nexus:Notify({ Title = "Copied", Message = "Game ID copied to clipboard", Type = "Success" })
    end,
})

Home:AddButton({
    Name       = "Copy User ID",
    ButtonText = "Copy",
    Callback   = function()
        pcall(setclipboard, tostring(LocalPlayer.UserId))
        Nexus:Notify({ Title = "Copied", Message = "Your User ID copied", Type = "Success" })
    end,
})

Home:AddSection("Player Info")

Home:AddLabel({
    Text = string.format("Username: %s\nDisplay Name: %s\nUser ID: %d\nAccount Age: %d days",
        LocalPlayer.Name,
        LocalPlayer.DisplayName,
        LocalPlayer.UserId,
        LocalPlayer.AccountAge
    ),
})

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB: PLAYER
-- ═══════════════════════════════════════════════════════════════════════════

local Player = Win:AddTab({ Name = "Player", Icon = "🏃" })

-- ─── Movement ───────────────────────────────────────────────────────────────
local Movement = Player:AddSubTab({ Name = "Movement" })

Movement:AddSection("Speed & Jump")

Movement:AddSlider({
    Id = "walkspeed", 
    Name = "Walk Speed",
    Min = 16, Max = 500, Default = 16, Step = 1,
    Tooltip = "Default is 16. Higher = faster movement",
    Callback = function(v)
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = v end
    end,
})

Movement:AddSlider({
    Id = "jumppower", 
    Name = "Jump Power",
    Min = 50, Max = 1000, Default = 50, Step = 10,
    Tooltip = "Default is 50. Higher = bigger jumps",
    Callback = function(v)
        local hum = GetHumanoid()
        if hum then 
            hum.JumpPower = v
            hum.JumpHeight = v / 10
        end
    end,
})

Movement:AddSlider({
    Id = "hipheight", 
    Name = "Hip Height",
    Min = 0, Max = 50, Default = 0, Step = 0.5,
    Tooltip = "Raises your character off the ground",
    Callback = function(v)
        local hum = GetHumanoid()
        if hum then hum.HipHeight = v end
    end,
})

Movement:AddSlider({
    Id = "gravity", 
    Name = "Gravity",
    Min = 0, Max = 196.2, Default = 196.2, Step = 10,
    Tooltip = "Lower = floatier jumps. Default is 196.2",
    Callback = function(v)
        Workspace.Gravity = v
    end,
})

Movement:AddToggle({
    Id = "infinite_jump",
    Name = "Infinite Jump",
    Default = false,
    Tooltip = "Jump infinitely without touching ground",
    Callback = function(v)
        InfiniteJumpEnabled = v
        if v then
            Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
                local hum = GetHumanoid()
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        elseif Connections.InfiniteJump then
            Connections.InfiniteJump:Disconnect()
        end
    end,
})

Movement:AddSection("Flight")

Movement:AddToggle({
    Id = "fly",
    Name = "Enable Flight",
    Default = false,
    Tooltip = "Fly freely around the map (WASD + Space/Shift)",
    Callback = function(v)
        FlyEnabled = v
        if v then
            local BV, BG
            local Speed = 50
            
            Connections.Fly = RunService.Heartbeat:Connect(function()
                if not FlyEnabled then return end
                
                local root = GetRootPart()
                local hum = GetHumanoid()
                if not root or not hum then return end
                
                if not BV then
                    BV = Instance.new("BodyVelocity", root)
                    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    BV.Velocity = Vector3.new(0, 0, 0)
                    
                    BG = Instance.new("BodyGyro", root)
                    BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    BG.CFrame = root.CFrame
                end
                
                hum.PlatformStand = true
                
                local moveVector = Vector3.new(0, 0, 0)
                local cam = Workspace.CurrentCamera
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + (cam.CFrame.LookVector * Speed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector - (cam.CFrame.LookVector * Speed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector - (cam.CFrame.RightVector * Speed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + (cam.CFrame.RightVector * Speed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveVector = moveVector + Vector3.new(0, Speed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveVector = moveVector - Vector3.new(0, Speed, 0)
                end
                
                BV.Velocity = moveVector
                BG.CFrame = cam.CFrame
            end)
        else
            if Connections.Fly then
                Connections.Fly:Disconnect()
            end
            
            local root = GetRootPart()
            if root then
                if root:FindFirstChild("BodyVelocity") then
                    root.BodyVelocity:Destroy()
                end
                if root:FindFirstChild("BodyGyro") then
                    root.BodyGyro:Destroy()
                end
            end
            
            local hum = GetHumanoid()
            if hum then
                hum.PlatformStand = false
            end
        end
    end,
})

Movement:AddSlider({
    Id = "fly_speed",
    Name = "Flight Speed",
    Min = 10, Max = 500, Default = 50, Step = 5,
    Tooltip = "How fast you fly",
    Callback = function(v)
        Speed = v
    end,
})

Movement:AddSection("Noclip")

Movement:AddToggle({
    Id = "noclip",
    Name = "Noclip",
    Default = false,
    Tooltip = "Walk through walls and objects",
    Callback = function(v)
        NoclipEnabled = v
        if v then
            Connections.Noclip = RunService.Stepped:Connect(function()
                if not NoclipEnabled then return end
                local char = GetCharacter()
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        elseif Connections.Noclip then
            Connections.Noclip:Disconnect()
            local char = GetCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end,
})

Movement:AddSection("Auto Walk")

Movement:AddToggle({
    Id = "auto_walk",
    Name = "Auto Walk Forward",
    Default = false,
    Callback = function(v)
        if v then
            Connections.AutoWalk = RunService.RenderStepped:Connect(function()
                local hum = GetHumanoid()
                if hum then
                    hum:Move(Vector3.new(0, 0, -1), true)
                end
            end)
        elseif Connections.AutoWalk then
            Connections.AutoWalk:Disconnect()
        end
    end,
})

-- ─── Character ──────────────────────────────────────────────────────────────
local Character = Player:AddSubTab({ Name = "Character" })

Character:AddSection("Appearance")

Character:AddButton({
    Name = "Remove Accessories",
    ButtonText = "Remove",
    Tooltip = "Remove all hats and accessories",
    Callback = function()
        local char = GetCharacter()
        if char then
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("Accessory") then
                    v:Destroy()
                end
            end
            Nexus:Notify({ Title = "Success", Message = "Accessories removed", Type = "Success" })
        end
    end,
})

Character:AddButton({
    Name = "Invisible Character",
    ButtonText = "Toggle",
    Tooltip = "Make your character invisible",
    Callback = function()
        local char = GetCharacter()
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Decal") then
                    v.Transparency = v.Transparency == 0 and 1 or 0
                end
            end
        end
    end,
})

Character:AddButton({
    Name = "Remove Limbs",
    ButtonText = "Remove",
    Tooltip = "Remove arms and legs (visual only)",
    Callback = function()
        local char = GetCharacter()
        if char then
            local limbs = {"LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
            for _, limbName in pairs(limbs) do
                local limb = char:FindFirstChild(limbName)
                if limb then limb.Transparency = 1 end
            end
        end
    end,
})

Character:AddSlider({
    Id = "scale",
    Name = "Character Scale",
    Min = 0.5, Max = 3, Default = 1, Step = 0.1,
    Tooltip = "Make your character bigger or smaller",
    Callback = function(v)
        local char = GetCharacter()
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.BodyHeightScale.Value = v
            char.Humanoid.BodyWidthScale.Value = v
            char.Humanoid.BodyDepthScale.Value = v
            char.Humanoid.HeadScale.Value = v
        end
    end,
})

Character:AddSection("Health & Stats")

Character:AddToggle({
    Id = "god_mode",
    Name = "God Mode",
    Default = false,
    Tooltip = "Infinite health (may not work on all games)",
    Callback = function(v)
        if v then
            Connections.GodMode = RunService.Heartbeat:Connect(function()
                local hum = GetHumanoid()
                if hum and hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end)
        elseif Connections.GodMode then
            Connections.GodMode:Disconnect()
        end
    end,
})

Character:AddButton({
    Name = "Full Health",
    ButtonText = "Heal",
    Color = Color3.fromRGB(100, 255, 100),
    Callback = function()
        local hum = GetHumanoid()
        if hum then
            hum.Health = hum.MaxHealth
            Nexus:Notify({ Title = "Healed", Message = "Health restored to maximum", Type = "Success" })
        end
    end,
})

Character:AddButton({
    Name = "Kill Character",
    ButtonText = "Kill",
    Color = Color3.fromRGB(255, 100, 100),
    Tooltip = "Instantly die (respawn)",
    Callback = function()
        local hum = GetHumanoid()
        if hum then hum.Health = 0 end
    end,
})

Character:AddButton({
    Name = "Respawn",
    ButtonText = "Respawn",
    Tooltip = "Reset your character",
    Callback = function()
        LocalPlayer:LoadCharacter()
    end,
})

-- ─── Keybinds ───────────────────────────────────────────────────────────────
local Keybinds = Player:AddSubTab({ Name = "Keybinds" })

Keybinds:AddSection("Movement Hotkeys")

Keybinds:AddKeybind({
    Id = "fly_key",
    Name = "Toggle Flight",
    Default = Enum.KeyCode.F,
    Tooltip = "Quick toggle for flight",
    OnPress = function()
        FlyEnabled = not FlyEnabled
        Nexus:Notify({ Title = "Flight", Message = FlyEnabled and "Enabled" or "Disabled", Type = "Info" })
    end,
})

Keybinds:AddKeybind({
    Id = "noclip_key",
    Name = "Toggle Noclip",
    Default = Enum.KeyCode.N,
    OnPress = function()
        NoclipEnabled = not NoclipEnabled
        Nexus:Notify({ Title = "Noclip", Message = NoclipEnabled and "Enabled" or "Disabled", Type = "Info" })
    end,
})

Keybinds:AddKeybind({
    Id = "speed_key",
    Name = "Speed Boost (Hold)",
    Default = Enum.KeyCode.LeftControl,
    Tooltip = "Hold for temporary speed boost",
    OnPress = function()
        local hum = GetHumanoid()
        if hum then
            SpeedHackActive = true
            hum.WalkSpeed = hum.WalkSpeed * 2
        end
    end,
})

Keybinds:AddSection("Utility Hotkeys")

Keybinds:AddKeybind({
    Id = "tp_to_spawn",
    Name = "TP to Spawn",
    Default = Enum.KeyCode.Home,
    OnPress = function()
        local spawnLocation = Workspace:FindFirstChild("SpawnLocation")
        local root = GetRootPart()
        if root and spawnLocation then
            root.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
        end
    end,
})

-- ─── Anti-AFK ───────────────────────────────────────────────────────────────
local AntiAFK = Player:AddSubTab({ Name = "Anti-AFK" })

AntiAFK:AddSection("Stay Active")

AntiAFK:AddToggle({
    Id = "anti_afk",
    Name = "Anti-AFK",
    Default = true,
    Tooltip = "Prevents being kicked for inactivity",
    Callback = function(v)
        AntiAFKEnabled = v
        if v then
            Connections.AntiAFK = RunService.Heartbeat:Connect(function()
                if AntiAFKEnabled then
                    local vu = game:GetService("VirtualUser")
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new())
                end
            end)
        elseif Connections.AntiAFK then
            Connections.AntiAFK:Disconnect()
        end
    end,
})

AntiAFK:AddLabel({
    Text = "Anti-AFK prevents you from being kicked for inactivity.\nThis feature is enabled by default.",
})

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB: COMBAT
-- ═══════════════════════════════════════════════════════════════════════════

local Combat = Win:AddTab({ Name = "Combat", Icon = "⚔" })

-- ─── Aimbot ─────────────────────────────────────────────────────────────────
local Aimbot = Combat:AddSubTab({ Name = "Aimbot" })

Aimbot:AddSection("Aimbot Configuration")

Aimbot:AddToggle({
    Id = "aimbot_on",
    Name = "Enable Aimbot",
    Default = false,
    Tooltip = "Automatically aim at nearby players",
    Callback = function(v) 
        print("Aimbot:", v)
        -- Aimbot logic would go here
    end,
})

Aimbot:AddToggle({
    Id = "aimbot_visible_check",
    Name = "Visible Check",
    Default = true,
    Tooltip = "Only target players you can see",
    Callback = function(v) print("Visible check:", v) end,
})

Aimbot:AddToggle({
    Id = "aimbot_team_check",
    Name = "Team Check",
    Default = true,
    Tooltip = "Don't target teammates",
    Callback = function(v) print("Team check:", v) end,
})

Aimbot:AddSlider({
    Id = "aimbot_fov",
    Name = "FOV Circle Radius",
    Min = 10, Max = 500, Default = 120, Step = 5,
    Tooltip = "Detection radius in pixels",
    Callback = function(v) print("FOV:", v) end,
})

Aimbot:AddSlider({
    Id = "aimbot_smooth",
    Name = "Smoothness",
    Min = 0, Max = 100, Default = 40, Step = 1,
    Tooltip = "Higher = smoother, more human-like aim",
    Callback = function(v) print("Smooth:", v) end,
})

Aimbot:AddSlider({
    Id = "aimbot_prediction",
    Name = "Prediction Amount",
    Min = 0, Max = 0.5, Default = 0.1, Step = 0.01,
    Tooltip = "Predict player movement",
    Callback = function(v) print("Prediction:", v) end,
})

Aimbot:AddDropdown({
    Id = "aimbot_part",
    Name = "Target Body Part",
    Items = { "Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso" },
    Default = "Head",
    Callback = function(v) print("Target part:", v) end,
})

Aimbot:AddDropdown({
    Id = "aimbot_mode",
    Name = "Aim Mode",
    Items = { "Camera", "Mouse", "Silent" },
    Default = "Camera",
    Tooltip = "How aimbot aims at targets",
    Callback = function(v) print("Aim mode:", v) end,
})

Aimbot:AddSection("FOV Visualization")

Aimbot:AddToggle({
    Id = "show_fov",
    Name = "Show FOV Circle",
    Default = true,
    Tooltip = "Display the detection circle",
    Callback = function(v) print("Show FOV:", v) end,
})

Aimbot:AddColorPicker({
    Id = "aimbot_fov_color",
    Name = "FOV Circle Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(c) print("FOV color:", c) end,
})

Aimbot:AddSlider({
    Id = "fov_transparency",
    Name = "FOV Transparency",
    Min = 0, Max = 1, Default = 0.5, Step = 0.1,
    Callback = function(v) print("FOV transparency:", v) end,
})

-- ─── ESP ────────────────────────────────────────────────────────────────────
local ESP = Combat:AddSubTab({ Name = "ESP" })

ESP:AddSection("Player ESP")

ESP:AddToggle({
    Id = "esp_on",
    Name = "Enable ESP",
    Default = false,
    Tooltip = "See players through walls",
    Callback = function(v) 
        ESPEnabled = v
        print("ESP:", v)
        -- ESP logic would go here
    end,
})

ESP:AddToggle({
    Id = "esp_team_check",
    Name = "Team Check",
    Default = true,
    Tooltip = "Different colors for teammates",
    Callback = function(v) print("ESP team check:", v) end,
})

ESP:AddMultiDropdown({
    Id = "esp_features",
    Name = "ESP Elements",
    Items = { "Box", "Name", "Health Bar", "Distance", "Tracers", "Skeleton", "Head Dot", "Look Direction" },
    Default = { "Box", "Name", "Health Bar" },
    Tooltip = "Select which ESP elements to display",
    Callback = function(arr) print("ESP features:", table.concat(arr, ", ")) end,
})

ESP:AddSection("ESP Colors")

ESP:AddColorPicker({
    Id = "esp_color_ally",
    Name = "Team Color",
    Default = Color3.fromRGB(99, 157, 255),
    Callback = function(c) print("Ally color:", c) end,
})

ESP:AddColorPicker({
    Id = "esp_color_enemy",
    Name = "Enemy Color",
    Default = Color3.fromRGB(255, 80, 80),
    Callback = function(c) print("Enemy color:", c) end,
})

ESP:AddColorPicker({
    Id = "esp_tracer_color",
    Name = "Tracer Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(c) print("Tracer color:", c) end,
})

ESP:AddSection("ESP Settings")

ESP:AddSlider({
    Id = "esp_distance",
    Name = "Max Distance",
    Min = 100, Max = 10000, Default = 2000, Step = 100,
    Tooltip = "Maximum render distance for ESP",
    Callback = function(v) print("Max distance:", v) end,
})

ESP:AddSlider({
    Id = "esp_thickness",
    Name = "Line Thickness",
    Min = 1, Max = 5, Default = 2, Step = 1,
    Callback = function(v) print("Thickness:", v) end,
})

ESP:AddDropdown({
    Id = "tracer_origin",
    Name = "Tracer Origin",
    Items = { "Bottom", "Center", "Top", "Mouse" },
    Default = "Bottom",
    Tooltip = "Where tracers start from",
    Callback = function(v) print("Tracer origin:", v) end,
})

ESP:AddSection("Object ESP")

ESP:AddToggle({
    Id = "item_esp",
    Name = "Item ESP",
    Default = false,
    Tooltip = "Highlight items and pickups",
    Callback = function(v) print("Item ESP:", v) end,
})

ESP:AddToggle({
    Id = "chest_esp",
    Name = "Chest ESP",
    Default = false,
    Tooltip = "Highlight chests and loot boxes",
    Callback = function(v) print("Chest ESP:", v) end,
})

ESP:AddToggle({
    Id = "vehicle_esp",
    Name = "Vehicle ESP",
    Default = false,
    Tooltip = "Highlight vehicles",
    Callback = function(v) print("Vehicle ESP:", v) end,
})

-- ─── Silent Aim & Misc ──────────────────────────────────────────────────────
local MiscCombat = Combat:AddSubTab({ Name = "Misc" })

MiscCombat:AddSection("Weapon Mods")

MiscCombat:AddToggle({
    Id = "silent_aim",
    Name = "Silent Aim",
    Default = false,
    Tooltip = "Hit targets without moving camera",
    Callback = function(v) print("Silent Aim:", v) end,
})

MiscCombat:AddToggle({
    Id = "no_recoil",
    Name = "No Recoil",
    Default = false,
    Tooltip = "Remove weapon recoil",
    Callback = function(v) print("No Recoil:", v) end,
})

MiscCombat:AddToggle({
    Id = "no_spread",
    Name = "No Spread",
    Default = false,
    Tooltip = "Perfect accuracy",
    Callback = function(v) print("No Spread:", v) end,
})

MiscCombat:AddToggle({
    Id = "rapid_fire",
    Name = "Rapid Fire",
    Default = false,
    Tooltip = "Shoot faster",
    Callback = function(v) print("Rapid Fire:", v) end,
})

MiscCombat:AddToggle({
    Id = "infinite_ammo",
    Name = "Infinite Ammo",
    Default = false,
    Tooltip = "Never reload",
    Callback = function(v) print("Infinite Ammo:", v) end,
})

MiscCombat:AddSlider({
    Id = "hit_chance",
    Name = "Hit Chance %",
    Min = 0, Max = 100, Default = 100, Step = 1,
    Tooltip = "Chance to hit with aimbot (looks more legit)",
    Callback = function(v) print("Hit chance:", v) end,
})

MiscCombat:AddSection("Combat Assist")

MiscCombat:AddToggle({
    Id = "auto_parry",
    Name = "Auto Parry",
    Default = false,
    Tooltip = "Automatically parry attacks",
    Callback = function(v) print("Auto Parry:", v) end,
})

MiscCombat:AddToggle({
    Id = "auto_block",
    Name = "Auto Block",
    Default = false,
    Tooltip = "Automatically block incoming damage",
    Callback = function(v) print("Auto Block:", v) end,
})

MiscCombat:AddToggle({
    Id = "kill_aura",
    Name = "Kill Aura",
    Default = false,
    Tooltip = "Attack nearby enemies automatically",
    Callback = function(v) print("Kill Aura:", v) end,
})

MiscCombat:AddSlider({
    Id = "kill_aura_range",
    Name = "Kill Aura Range",
    Min = 5, Max = 50, Default = 15, Step = 1,
    Callback = function(v) print("Aura range:", v) end,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB: VISUALS
-- ═══════════════════════════════════════════════════════════════════════════

local Visual = Win:AddTab({ Name = "Visual", Icon = "👁" })

-- ─── World ──────────────────────────────────────────────────────────────────
local World = Visual:AddSubTab({ Name = "World" })

World:AddSection("Lighting")

World:AddToggle({
    Id = "fullbright",
    Name = "Fullbright",
    Default = false,
    Tooltip = "See everything clearly",
    Callback = function(v)
        FullbrightEnabled = v
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end
    end,
})

World:AddToggle({
    Id = "no_fog",
    Name = "Remove Fog",
    Default = false,
    Callback = function(v)
        if v then
            Lighting.FogEnd = 100000
        else
            Lighting.FogEnd = 1000
        end
    end,
})

World:AddToggle({
    Id = "no_blur",
    Name = "Remove Blur",
    Default = false,
    Callback = function(v)
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BlurEffect") then
                effect.Enabled = not v
            end
        end
    end,
})

World:AddSlider({
    Id = "time_of_day",
    Name = "Time of Day",
    Min = 0, Max = 24, Default = 14, Step = 0.5,
    Tooltip = "Change world time (0 = midnight, 12 = noon)",
    Callback = function(v)
        Lighting.ClockTime = v
    end,
})

World:AddSlider({
    Id = "brightness",
    Name = "Brightness",
    Min = 0, Max = 10, Default = 1, Step = 0.5,
    Callback = function(v)
        Lighting.Brightness = v
    end,
})

World:AddSection("Atmosphere")

World:AddColorPicker({
    Id = "ambient",
    Name = "Ambient Color",
    Default = Color3.fromRGB(128, 128, 128),
    Callback = function(c)
        Lighting.Ambient = c
    end,
})

World:AddColorPicker({
    Id = "outdoor_ambient",
    Name = "Outdoor Ambient",
    Default = Color3.fromRGB(128, 128, 128),
    Callback = function(c)
        Lighting.OutdoorAmbient = c
    end,
})

World:AddSection("World Modifications")

World:AddToggle({
    Id = "x_ray",
    Name = "X-Ray Vision",
    Default = false,
    Tooltip = "See through walls",
    Callback = function(v)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
                obj.LocalTransparencyModifier = v and 0.5 or 0
            end
        end
    end,
})

World:AddButton({
    Name = "Remove Shadows",
    ButtonText = "Remove",
    Callback = function()
        Lighting.GlobalShadows = false
        Nexus:Notify({ Title = "Success", Message = "Shadows removed", Type = "Success" })
    end,
})

World:AddButton({
    Name = "Remove Terrain",
    ButtonText = "Remove",
    Tooltip = "Delete all terrain (can cause lag)",
    Callback = function()
        Workspace.Terrain:Clear()
        Nexus:Notify({ Title = "Success", Message = "Terrain cleared", Type = "Success" })
    end,
})

-- ─── Camera ─────────────────────────────────────────────────────────────────
local Camera = Visual:AddSubTab({ Name = "Camera" })

Camera:AddSection("Camera Settings")

Camera:AddSlider({
    Id = "fov",
    Name = "Field of View",
    Min = 60, Max = 120, Default = 70, Step = 1,
    Tooltip = "Wider FOV = see more",
    Callback = function(v)
        Workspace.CurrentCamera.FieldOfView = v
    end,
})

Camera:AddToggle({
    Id = "freecam",
    Name = "Free Camera",
    Default = false,
    Tooltip = "Move camera freely (spectate mode)",
    Callback = function(v)
        print("Freecam:", v)
        -- Freecam logic would go here
    end,
})

Camera:AddToggle({
    Id = "third_person",
    Name = "Force Third Person",
    Default = false,
    Callback = function(v)
        if v then
            LocalPlayer.CameraMaxZoomDistance = 100
            LocalPlayer.CameraMinZoomDistance = 10
        else
            LocalPlayer.CameraMaxZoomDistance = 128
            LocalPlayer.CameraMinZoomDistance = 0.5
        end
    end,
})

Camera:AddSlider({
    Id = "zoom_distance",
    Name = "Zoom Distance",
    Min = 1, Max = 500, Default = 15, Step = 1,
    Callback = function(v)
        LocalPlayer.CameraMaxZoomDistance = v
    end,
})

Camera:AddSection("Camera Effects")

Camera:AddToggle({
    Id = "no_camera_shake",
    Name = "No Camera Shake",
    Default = false,
    Callback = function(v)
        print("No shake:", v)
    end,
})

Camera:AddToggle({
    Id = "no_headbob",
    Name = "No Head Bob",
    Default = false,
    Callback = function(v)
        print("No headbob:", v)
    end,
})

-- ─── Crosshair ──────────────────────────────────────────────────────────────
local Crosshair = Visual:AddSubTab({ Name = "Crosshair" })

Crosshair:AddSection("Crosshair Settings")

Crosshair:AddToggle({
    Id = "custom_crosshair",
    Name = "Custom Crosshair",
    Default = false,
    Tooltip = "Display a custom crosshair",
    Callback = function(v)
        print("Crosshair:", v)
        -- Crosshair logic would go here
    end,
})

Crosshair:AddDropdown({
    Id = "crosshair_style",
    Name = "Crosshair Style",
    Items = { "Cross", "Dot", "Circle", "Square", "Plus" },
    Default = "Cross",
    Callback = function(v) print("Crosshair style:", v) end,
})

Crosshair:AddSlider({
    Id = "crosshair_size",
    Name = "Size",
    Min = 1, Max = 50, Default = 10, Step = 1,
    Callback = function(v) print("Size:", v) end,
})

Crosshair:AddSlider({
    Id = "crosshair_thickness",
    Name = "Thickness",
    Min = 1, Max = 10, Default = 2, Step = 1,
    Callback = function(v) print("Thickness:", v) end,
})

Crosshair:AddColorPicker({
    Id = "crosshair_color",
    Name = "Crosshair Color",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(c) print("Color:", c) end,
})

Crosshair:AddToggle({
    Id = "rainbow_crosshair",
    Name = "Rainbow Crosshair",
    Default = false,
    Callback = function(v) print("Rainbow:", v) end,
})

-- ─── UI Mods ────────────────────────────────────────────────────────────────
local UIMods = Visual:AddSubTab({ Name = "UI" })

UIMods:AddSection("Interface")

UIMods:AddToggle({
    Id = "hide_hud",
    Name = "Hide Default HUD",
    Default = false,
    Tooltip = "Hide game's default UI elements",
    Callback = function(v)
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "NexusLib" then
                gui.Enabled = not v
            end
        end
    end,
})

UIMods:AddToggle({
    Id = "hide_chat",
    Name = "Hide Chat",
    Default = false,
    Callback = function(v)
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not v)
    end,
})

UIMods:AddToggle({
    Id = "hide_leaderboard",
    Name = "Hide Leaderboard",
    Default = false,
    Callback = function(v)
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not v)
    end,
})

UIMods:AddSection("Indicators")

UIMods:AddToggle({
    Id = "fps_counter",
    Name = "FPS Counter",
    Default = false,
    Tooltip = "Show frames per second",
    Callback = function(v) print("FPS counter:", v) end,
})

UIMods:AddToggle({
    Id = "ping_display",
    Name = "Ping Display",
    Default = false,
    Callback = function(v) print("Ping display:", v) end,
})

UIMods:AddToggle({
    Id = "position_display",
    Name = "Position Display",
    Default = false,
    Tooltip = "Show your coordinates",
    Callback = function(v) print("Position:", v) end,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB: TELEPORTS
-- ═══════════════════════════════════════════════════════════════════════════

local Teleport = Win:AddTab({ Name = "Teleport", Icon = "📍" })

-- ─── Player TP ──────────────────────────────────────────────────────────────
local PlayerTP = Teleport:AddSubTab({ Name = "Players" })

PlayerTP:AddSection("Teleport to Players")

local playerList = {}
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(playerList, player.Name)
    end
end

PlayerTP:AddDropdown({
    Id = "tp_player_select",
    Name = "Select Player",
    Items = playerList,
    Default = playerList[1] or "",
    Callback = function(v) 
        _G.SelectedPlayer = v
    end,
})

PlayerTP:AddButton({
    Name = "Teleport to Player",
    ButtonText = "TP",
    Color = Color3.fromRGB(100, 150, 255),
    Tooltip = "Teleport to selected player",
    Callback = function()
        if _G.SelectedPlayer then
            local targetPlayer = Players:FindFirstChild(_G.SelectedPlayer)
            if targetPlayer and targetPlayer.Character then
                local root = GetRootPart()
                if root then
                    root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                    Nexus:Notify({ Title = "Teleported", Message = "Teleported to " .. _G.SelectedPlayer, Type = "Success" })
                end
            end
        end
    end,
})

PlayerTP:AddToggle({
    Id = "tp_loop",
    Name = "Loop Teleport",
    Default = false,
    Tooltip = "Continuously teleport to player",
    Callback = function(v)
        if v then
            Connections.LoopTP = RunService.Heartbeat:Connect(function()
                if _G.SelectedPlayer then
                    local targetPlayer = Players:FindFirstChild(_G.SelectedPlayer)
                    if targetPlayer and targetPlayer.Character then
                        local root = GetRootPart()
                        if root then
                            root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                        end
                    end
                end
            end)
        elseif Connections.LoopTP then
            Connections.LoopTP:Disconnect()
        end
    end,
})

PlayerTP:AddSection("Quick Actions")

PlayerTP:AddButton({
    Name = "Bring All Players",
    ButtonText = "Bring",
    Tooltip = "Teleport all players to you (server-side only)",
    Callback = function()
        local root = GetRootPart()
        if root then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    player.Character.HumanoidRootPart.CFrame = root.CFrame
                end
            end
        end
    end,
})

-- ─── Location TP ────────────────────────────────────────────────────────────
local LocationTP = Teleport:AddSubTab({ Name = "Locations" })

LocationTP:AddSection("Common Locations")

LocationTP:AddButton({
    Name = "Spawn Point",
    ButtonText = "TP",
    Callback = function()
        local spawnLocation = Workspace:FindFirstChild("SpawnLocation")
        local root = GetRootPart()
        if root and spawnLocation then
            root.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
            Nexus:Notify({ Title = "Teleported", Message = "Teleported to spawn", Type = "Success" })
        end
    end,
})

LocationTP:AddSection("Coordinate Teleport")

LocationTP:AddTextInput({
    Name = "X Position",
    Placeholder = "0",
    Callback = function(text)
        _G.TPX = tonumber(text) or 0
    end,
})

LocationTP:AddTextInput({
    Name = "Y Position",
    Placeholder = "0",
    Callback = function(text)
        _G.TPY = tonumber(text) or 0
    end,
})

LocationTP:AddTextInput({
    Name = "Z Position",
    Placeholder = "0",
    Callback = function(text)
        _G.TPZ = tonumber(text) or 0
    end,
})

LocationTP:AddButton({
    Name = "Teleport to Coordinates",
    ButtonText = "TP",
    Color = Color3.fromRGB(100, 255, 100),
    Callback = function()
        local root = GetRootPart()
        if root then
            local x = _G.TPX or 0
            local y = _G.TPY or 0
            local z = _G.TPZ or 0
            root.CFrame = CFrame.new(x, y, z)
            Nexus:Notify({ Title = "Teleported", Message = string.format("Teleported to (%.1f, %.1f, %.1f)", x, y, z), Type = "Success" })
        end
    end,
})

LocationTP:AddSection("Waypoint System")

LocationTP:AddButton({
    Name = "Save Current Position",
    ButtonText = "Save",
    Callback = function()
        local root = GetRootPart()
        if root then
            _G.SavedPosition = root.CFrame
            Nexus:Notify({ Title = "Saved", Message = "Position saved", Type = "Success" })
        end
    end,
})

LocationTP:AddButton({
    Name = "Teleport to Saved Position",
    ButtonText = "Load",
    Callback = function()
        if _G.SavedPosition then
            local root = GetRootPart()
            if root then
                root.CFrame = _G.SavedPosition
                Nexus:Notify({ Title = "Teleported", Message = "Loaded saved position", Type = "Success" })
            end
        else
            Nexus:Notify({ Title = "Error", Message = "No position saved", Type = "Error" })
        end
    end,
})

-- ─── Advanced TP ────────────────────────────────────────────────────────────
local AdvancedTP = Teleport:AddSubTab({ Name = "Advanced" })

AdvancedTP:AddSection("Teleport Settings")

AdvancedTP:AddToggle({
    Id = "tp_behind",
    Name = "TP Behind Player",
    Default = false,
    Tooltip = "Teleport behind instead of on top",
    Callback = function(v)
        _G.TPBehind = v
    end,
})

AdvancedTP:AddSlider({
    Id = "tp_offset",
    Name = "Teleport Distance",
    Min = 0, Max = 50, Default = 5, Step = 1,
    Tooltip = "Distance from target",
    Callback = function(v)
        _G.TPOffset = v
    end,
})

AdvancedTP:AddSection("Smart Teleport")

AdvancedTP:AddToggle({
    Id = "avoid_obstacles",
    Name = "Avoid Obstacles",
    Default = false,
    Tooltip = "Try to avoid walls when teleporting",
    Callback = function(v) print("Avoid obstacles:", v) end,
})

AdvancedTP:AddToggle({
    Id = "walk_tp",
    Name = "Walk Teleport",
    Default = false,
    Tooltip = "Teleport gradually (looks more legit)",
    Callback = function(v) print("Walk TP:", v) end,
})

AdvancedTP:AddSlider({
    Id = "walk_speed_tp",
    Name = "Walk TP Speed",
    Min = 1, Max = 100, Default = 10, Step = 1,
    Callback = function(v) print("Walk TP speed:", v) end,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB: AUTO-FARM
-- ═══════════════════════════════════════════════════════════════════════════

local AutoFarm = Win:AddTab({ Name = "Auto-Farm", Icon = "🌾" })

AutoFarm:AddSection("Auto Farming")

AutoFarm:AddToggle({
    Id = "auto_farm_on",
    Name = "Enable Auto Farm",
    Default = false,
    Tooltip = "Automatically farm resources/coins/items",
    Callback = function(v)
        AutoFarmActive = v
        print("Auto Farm:", v)
        -- Auto farm logic would go here
    end,
})

AutoFarm:AddSection("Farm Settings")

AutoFarm:AddMultiDropdown({
    Id = "farm_targets",
    Name = "Farm Targets",
    Items = { "Coins", "Items", "NPCs", "Resources", "Chests", "Orbs" },
    Default = { "Coins", "Items" },
    Tooltip = "What to automatically collect",
    Callback = function(arr) print("Farm targets:", table.concat(arr, ", ")) end,
})

AutoFarm:AddSlider({
    Id = "farm_range",
    Name = "Farm Range",
    Min = 10, Max = 500, Default = 100, Step = 10,
    Tooltip = "How far to search for items",
    Callback = function(v) print("Farm range:", v) end,
})

AutoFarm:AddSlider({
    Id = "farm_delay",
    Name = "Collection Delay (ms)",
    Min = 0, Max = 1000, Default = 100, Step = 50,
    Tooltip = "Delay between collections",
    Callback = function(v) print("Farm delay:", v) end,
})

AutoFarm:AddSection("Collection Method")

AutoFarm:AddDropdown({
    Id = "collection_method",
    Name = "Collection Method",
    Items = { "Teleport", "Walk", "Tween", "Instant" },
    Default = "Teleport",
    Tooltip = "How to collect items",
    Callback = function(v) print("Collection method:", v) end,
})

AutoFarm:AddToggle({
    Id = "avoid_players",
    Name = "Avoid Players",
    Default = true,
    Tooltip = "Don't farm near other players",
    Callback = function(v) print("Avoid players:", v) end,
})

AutoFarm:AddSection("Auto Actions")

AutoFarm:AddToggle({
    Id = "auto_sell",
    Name = "Auto Sell",
    Default = false,
    Tooltip = "Automatically sell collected items",
    Callback = function(v) print("Auto sell:", v) end,
})

AutoFarm:AddToggle({
    Id = "auto_craft",
    Name = "Auto Craft",
    Default = false,
    Callback = function(v) print("Auto craft:", v) end,
})

AutoFarm:AddToggle({
    Id = "auto_rebirth",
    Name = "Auto Rebirth",
    Default = false,
    Tooltip = "Automatically rebirth when possible",
    Callback = function(v) print("Auto rebirth:", v) end,
})

AutoFarm:AddSection("Statistics")

AutoFarm:AddLabel({
    Text = "Items Collected: 0\nTime Farming: 0m\nEstimated Profit: 0",
})

AutoFarm:AddButton({
    Name = "Reset Statistics",
    ButtonText = "Reset",
    Callback = function()
        -- Reset stats logic
        Nexus:Notify({ Title = "Reset", Message = "Statistics cleared", Type = "Info" })
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB: UTILITIES
-- ═══════════════════════════════════════════════════════════════════════════

local Utility = Win:AddTab({ Name = "Utilities", Icon = "🔧" })

-- ─── Game Info ──────────────────────────────────────────────────────────────
local GameInfo = Utility:AddSubTab({ Name = "Info" })

GameInfo:AddSection("Game Information")

GameInfo:AddLabel({
    Text = string.format("Game: %s\nPlace ID: %d\nJob ID: %s\nCreator: %s",
        game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
        game.PlaceId,
        game.JobId,
        game.CreatorId
    ),
})

GameInfo:AddButton({
    Name = "Copy Game Link",
    ButtonText = "Copy",
    Callback = function()
        pcall(setclipboard, "https://www.roblox.com/games/" .. game.PlaceId)
        Nexus:Notify({ Title = "Copied", Message = "Game link copied", Type = "Success" })
    end,
})

GameInfo:AddSection("Server Info")

GameInfo:AddLabel({
    Text = string.format("Players: %d/%d\nPing: %d ms",
        #Players:GetPlayers(),
        Players.MaxPlayers or 50,
        math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    ),
})

-- ─── Chat Spam ──────────────────────────────────────────────────────────────
local ChatSpam = Utility:AddSubTab({ Name = "Chat" })

ChatSpam:AddSection("Chat Spam")

ChatSpam:AddTextInput({
    Name = "Spam Message",
    Placeholder = "Enter message...",
    Callback = function(text)
        _G.SpamMessage = text
    end,
})

ChatSpam:AddToggle({
    Id = "chat_spam",
    Name = "Enable Chat Spam",
    Default = false,
    Tooltip = "Spam message in chat (use responsibly)",
    Callback = function(v)
        if v then
            Connections.ChatSpam = RunService.Heartbeat:Connect(function()
                if _G.SpamMessage and #_G.SpamMessage > 0 then
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(_G.SpamMessage, "All")
                    wait(2)
                end
            end)
        elseif Connections.ChatSpam then
            Connections.ChatSpam:Disconnect()
        end
    end,
})

ChatSpam:AddSection("Quick Messages")

ChatSpam:AddButton({
    Name = "GG",
    ButtonText = "Send",
    Callback = function()
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("GG!", "All")
    end,
})

ChatSpam:AddButton({
    Name = "Hello",
    ButtonText = "Send",
    Callback = function()
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Hello everyone!", "All")
    end,
})

-- ─── Misc Tools ─────────────────────────────────────────────────────────────
local MiscTools = Utility:AddSubTab({ Name = "Tools" })

MiscTools:AddSection("Developer Tools")

MiscTools:AddButton({
    Name = "Remote Spy",
    ButtonText = "Open",
    Tooltip = "Monitor game remotes",
    Callback = function()
        Nexus:Notify({ Title = "Remote Spy", Message = "Feature coming soon", Type = "Info" })
    end,
})

MiscTools:AddButton({
    Name = "Script Hub",
    ButtonText = "Open",
    Callback = function()
        Nexus:Notify({ Title = "Script Hub", Message = "Feature coming soon", Type = "Info" })
    end,
})

MiscTools:AddButton({
    Name = "Copy Game Scripts",
    ButtonText = "Copy",
    Tooltip = "Copy all game scripts",
    Callback = function()
        -- Script copying logic
        Nexus:Notify({ Title = "Info", Message = "This feature requires Synapse X or similar", Type = "Warning" })
    end,
})

MiscTools:AddSection("Utilities")

MiscTools:AddToggle({
    Id = "free_gamepass",
    Name = "Free Gamepass",
    Default = false,
    Tooltip = "Attempt to unlock gamepasses (rarely works)",
    Callback = function(v) print("Free gamepass:", v) end,
})

MiscTools:AddButton({
    Name = "Unlock All Tools",
    ButtonText = "Unlock",
    Callback = function()
        Nexus:Notify({ Title = "Info", Message = "Game-specific feature", Type = "Info" })
    end,
})

MiscTools:AddButton({
    Name = "Infinite Money",
    ButtonText = "Apply",
    Color = Color3.fromRGB(255, 215, 0),
    Tooltip = "Client-side only (visual)",
    Callback = function()
        Nexus:Notify({ Title = "Info", Message = "Client-side only - not real", Type = "Warning" })
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB: SETTINGS
-- ═══════════════════════════════════════════════════════════════════════════

local Settings = Win:AddTab({ Name = "Settings", Icon = "⚙" })

Settings:AddSection("UI Appearance")

Settings:AddDropdown({
    Name = "Theme",
    Items = { "Dark", "Midnight", "Rose", "Light" },
    Default = "Dark",
    Tooltip = "Change UI color scheme",
    Callback = function(v)
        Win:SetTheme(v)
        Nexus:Notify({ Title = "Theme Changed", Message = "Switched to " .. v .. " theme", Type = "Info", Duration = 2 })
    end,
})

Settings:AddTextInput({
    Name = "Watermark Text",
    Placeholder = "Universal Script Pro",
    Tooltip = "Customize top-left watermark",
    Callback = function(text)
        if wm then 
            wm:SetText(text)
        end
    end,
})

Settings:AddToggle({
    Id = "show_watermark",
    Name = "Show Watermark",
    Default = true,
    Callback = function(v)
        if wm then
            wm:SetVisible(v)
        end
    end,
})

Settings:AddSection("Performance")

Settings:AddToggle({
    Id = "low_graphics",
    Name = "Low Graphics Mode",
    Default = false,
    Tooltip = "Reduce graphics for better performance",
    Callback = function(v)
        local qualityLevel = v and 1 or 10
        settings().Rendering.QualityLevel = qualityLevel
    end,
})

Settings:AddToggle({
    Id = "boost_fps",
    Name = "FPS Boost",
    Default = false,
    Tooltip = "Optimize performance",
    Callback = function(v)
        if v then
            settings().Rendering.QualityLevel = 1
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = false
                end
            end
        end
    end,
})

Settings:AddSlider({
    Id = "render_distance",
    Name = "Render Distance",
    Min = 100, Max = 5000, Default = 1000, Step = 100,
    Callback = function(v)
        settings().Rendering.ViewportSize = v
    end,
})

Settings:AddSection("Notifications")

Settings:AddButton({
    Name = "Test Info",
    ButtonText = "Send",
    Callback = function()
        Nexus:Notify({ Title = "Info", Message = "This is an info notification", Type = "Info", Duration = 3 })
    end,
})

Settings:AddButton({
    Name = "Test Success",
    ButtonText = "Send",
    Callback = function()
        Nexus:Notify({ Title = "Success", Message = "Operation completed!", Type = "Success", Duration = 3 })
    end,
})

Settings:AddButton({
    Name = "Test Warning",
    ButtonText = "Send",
    Callback = function()
        Nexus:Notify({ Title = "Warning", Message = "Be careful with this setting", Type = "Warning", Duration = 3 })
    end,
})

Settings:AddButton({
    Name = "Test Error",
    ButtonText = "Send",
    Callback = function()
        Nexus:Notify({ Title = "Error", Message = "Something went wrong!", Type = "Error", Duration = 3 })
    end,
})

Settings:AddSection("Configuration")

-- Config panel with tabbed interface
Settings:AddConfigPanel()

Settings:AddSection("Script Management")

Settings:AddButton({
    Name = "Destroy GUI",
    ButtonText = "Destroy",
    Color = Color3.fromRGB(255, 100, 100),
    Tooltip = "Remove the script completely",
    Callback = function()
        for name, connection in pairs(Connections) do
            connection:Disconnect()
        end
        Win:Destroy()
        Nexus:Notify({ Title = "Goodbye", Message = "Script destroyed", Type = "Info", Duration = 2 })
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

-- Welcome notification
Nexus:Notify({
    Title = "Nexus Universal Script ",
    Message = "Successfully loaded! Press RightShift to toggle UI.",
    Type = "Success",
    Duration = 5,
})

-- Auto-save settings
spawn(function()
    while wait(30) do
        -- Auto-save logic
    end
end)

-- Clean up on character respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    -- Reset some features on respawn
    if FlyEnabled then
        FlyEnabled = false
        -- Reset fly
    end
    if NoclipEnabled then
        NoclipEnabled = false
        if Connections.Noclip then
            Connections.Noclip:Disconnect()
        end
    end
end)

print("Nexus Universal Script loaded successfully!")
