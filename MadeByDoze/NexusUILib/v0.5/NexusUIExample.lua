--[[
    NexusLib v3.0 — Example Script
    Replace RAW_URL with your hosted NexusLib_v3.lua raw link

    Available Themes: "Dark" | "Light" | "Midnight" | "Rose"
]]

local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/MadeByDoze/NexusUILib/v0.5/NexusLib.lua"))()

local Win = Nexus:CreateWindow({
    Title     = "My Script",
    Subtitle  = "v0.5",
    Size      = UDim2.new(0, 580, 0, 415),
    ToggleKey = Enum.KeyCode.RightShift,
    ConfigDir = "MyScript",
    Theme     = "Dark",        -- "Dark" | "Light" | "Midnight" | "Rose"
})

-- Optional: live clock watermark in the top-left
local wm = Win:AddWatermark("My Script")

-- ─── TAB: Home ────────────────────────────────────────────────────────────────
local Home = Win:AddTab({ Name = "Home", Icon = "🏠" })

Home:AddLabel({
    Text = "Welcome to My Script v.4!\nUse the tabs on the left to navigate. Right-click any element for quick options.",
})

Home:AddImage({
    Image   = "rbxassetid://7072706796",  -- replace with any rbxassetid
    Height  = 90,
    Caption = "Script Banner",
    Tooltip = "Your script's banner image",
})

Home:AddSection("Quick Actions")

Home:AddButton({
    Name       = "Rejoin Server",
    ButtonText = "Rejoin",
    Tooltip    = "Teleports you to a fresh server",
    Context    = {
        { Label = "Rejoin", Callback = function() print("Rejoining...") end },
        { Label = "Copy server ID", Callback = function() pcall(setclipboard, tostring(game.JobId)) end },
    },
    Callback   = function()
        Nexus:Notify({ Title = "Rejoining", Message = "Finding a new server...", Type = "Info" })
    end,
})

Home:AddButton({
    Name       = "Copy Player ID",
    ButtonText = "Copy",
    Color      = Color3.fromRGB(90, 180, 90),
    Callback   = function()
        pcall(setclipboard, tostring(game.Players.LocalPlayer.UserId))
        Nexus:Notify({ Title = "Copied", Message = "Your user ID has been copied.", Type = "Success" })
    end,
})

-- ─── TAB: Combat (Sub-Tabs) ───────────────────────────────────────────────────
local Combat = Win:AddTab({ Name = "Combat", Icon = "⚔" })

-- Sub-Tab: Aimbot
local Aimbot = Combat:AddSubTab({ Name = "Aimbot" })

Aimbot:AddSection("Aimbot")

Aimbot:AddToggle({
    Id       = "aimbot_on",
    Name     = "Enable Aimbot",
    Default  = false,
    Tooltip  = "Snaps aim toward the nearest target",
    Context  = {
        { Label = "Enable",  Callback = function() print("enabled") end },
        { Label = "Disable", Callback = function() print("disabled") end },
    },
    Callback = function(v) print("Aimbot:", v) end,
})

Aimbot:AddSlider({
    Id       = "aimbot_fov",
    Name     = "FOV Radius",
    Min = 10, Max = 350, Default = 120, Step = 5,
    Tooltip  = "Detection radius in pixels",
    Callback = function(v) print("FOV:", v) end,
})

Aimbot:AddSlider({
    Id       = "aimbot_smooth",
    Name     = "Smoothness",
    Min = 0, Max = 100, Default = 40,
    Tooltip  = "Higher = slower, more human-like movement",
    Callback = function(v) print("Smooth:", v) end,
})

Aimbot:AddDropdown({
    Id       = "aimbot_part",
    Name     = "Target Part",
    Items    = { "Head", "HumanoidRootPart", "Torso", "UpperTorso" },
    Default  = "Head",
    Callback = function(v) print("Target:", v) end,
})

Aimbot:AddColorPicker({
    Id       = "aimbot_fov_color",
    Name     = "FOV Circle Color",
    Default  = Color3.fromRGB(255, 255, 255),
    Callback = function(c) print("FOV color:", c) end,
})

-- Sub-Tab: ESP
local ESP = Combat:AddSubTab({ Name = "ESP" })

ESP:AddSection("Player ESP")

ESP:AddToggle({
    Id       = "esp_on",
    Name     = "Enable ESP",
    Default  = false,
    Tooltip  = "Renders information on all players",
    Callback = function(v) print("ESP:", v) end,
})

ESP:AddMultiDropdown({
    Id       = "esp_features",
    Name     = "ESP Features",
    Items    = { "Box", "Name", "Health Bar", "Distance", "Tracers", "Skeleton" },
    Default  = { "Box", "Name", "Health Bar" },
    Tooltip  = "Select which ESP overlays to draw",
    Callback = function(arr) print("ESP features:", table.concat(arr, ", ")) end,
})

ESP:AddColorPicker({
    Id       = "esp_color_ally",
    Name     = "Ally Color",
    Default  = Color3.fromRGB(99, 157, 255),
    Callback = function(c) print("Ally:", c) end,
})

ESP:AddColorPicker({
    Id       = "esp_color_enemy",
    Name     = "Enemy Color",
    Default  = Color3.fromRGB(255, 80, 80),
    Callback = function(c) print("Enemy:", c) end,
})

-- Sub-Tab: Misc Combat
local MiscCombat = Combat:AddSubTab({ Name = "Misc" })

MiscCombat:AddSection("Extras")
MiscCombat:AddToggle({ Id = "silent_aim", Name = "Silent Aim", Default = false, Callback = function(v) print("Silent Aim:", v) end })
MiscCombat:AddToggle({ Id = "no_recoil", Name = "No Recoil",  Default = false, Callback = function(v) print("No Recoil:", v) end })
MiscCombat:AddSlider({ Id = "hit_chance", Name = "Hit Chance %", Min = 0, Max = 100, Default = 100, Callback = function(v) print("Hit:", v) end })

-- ─── TAB: Player ──────────────────────────────────────────────────────────────
local Player = Win:AddTab({ Name = "Player", Icon = "🏃" })

Player:AddSection("Movement")

Player:AddSlider({
    Id = "walkspeed", Name = "Walk Speed",
    Min = 16, Max = 300, Default = 16, Step = 1,
    Tooltip = "Default Roblox speed is 16",
    Callback = function(v)
        local c = game.Players.LocalPlayer.Character
        if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
    end,
})

Player:AddSlider({
    Id = "jumppower", Name = "Jump Power",
    Min = 50, Max = 500, Default = 50, Step = 10,
    Callback = function(v)
        local c = game.Players.LocalPlayer.Character
        if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v end
    end,
})

Player:AddToggle({
    Id = "noclip", Name = "Noclip",
    Default = false, Tooltip = "Walk through walls",
    Callback = function(v) print("Noclip:", v) end,
})

Player:AddSection("Keybinds")

Player:AddKeybind({
    Id      = "fly_key",
    Name    = "Fly Toggle",
    Default = Enum.KeyCode.F,
    Tooltip = "Press to toggle flight mode",
    OnPress = function() print("Fly toggled!") end,
    Callback = function(k) print("Fly key changed:", k.Name) end,
})

Player:AddKeybind({
    Id      = "speed_key",
    Name    = "Speed Boost Hold",
    Default = Enum.KeyCode.LeftShift,
    OnPress = function() print("Speed boost!") end,
})

Player:AddSection("Info")

Player:AddLabel({
    Text    = "Changes to WalkSpeed and JumpPower reset when your character respawns. Attach a CharacterAdded listener to re-apply them automatically.",
    Tooltip = "Pro tip",
})

-- ─── TAB: Visual ─────────────────────────────────────────────────────────────
local Visual = Win:AddTab({ Name = "Visual", Icon = "👁" })

Visual:AddSection("World")

Visual:AddToggle({ Id = "fullbright", Name = "Fullbright",   Default = false, Callback = function(v) print("Fullbright:", v) end })
Visual:AddToggle({ Id = "no_fog",     Name = "Remove Fog",   Default = false, Callback = function(v) print("No fog:", v) end })
Visual:AddToggle({ Id = "no_hats",    Name = "Remove Hats",  Default = false, Callback = function(v) print("No hats:", v) end })

Visual:AddSlider({ Id = "fov_cam", Name = "Camera FOV", Min = 60, Max = 120, Default = 70, Callback = function(v)
    game.Workspace.CurrentCamera.FieldOfView = v
end })

Visual:AddSection("Crosshair")

Visual:AddToggle({ Id = "custom_ch", Name = "Custom Crosshair", Default = false, Callback = function(v) print("Crosshair:", v) end })
Visual:AddColorPicker({ Id = "ch_color", Name = "Crosshair Color", Default = Color3.fromRGB(255,255,255), Callback = function(c) print("CH color:", c) end })

-- ─── TAB: Settings ────────────────────────────────────────────────────────────
local Settings = Win:AddTab({ Name = "Settings", Icon = "⚙" })

Settings:AddSection("Appearance")

Settings:AddDropdown({
    Name     = "Theme",
    Items    = { "Dark", "Midnight", "Rose", "Light" },
    Default  = "Dark",
    Tooltip  = "Changes the UI colour scheme",
    Callback = function(v)
        Win:SetTheme(v)
        Nexus:Notify({ Title = "Theme", Message = "Switched to "..v.." theme.", Type = "Info", Duration = 2 })
    end,
})

Settings:AddTextInput({
    Name        = "Watermark Text",
    Placeholder = "My Script",
    Tooltip     = "Text shown in the top-left watermark",
    Callback    = function(text)
        if wm then wm:SetText(text) end
    end,
})

Settings:AddSection("Notifications")

Settings:AddButton({ Name = "Test Info",    ButtonText = "Send", Callback = function() Nexus:Notify({ Title = "Info",    Message = "This is an info notification.",    Type = "Info",    Duration = 3 }) end })
Settings:AddButton({ Name = "Test Success", ButtonText = "Send", Callback = function() Nexus:Notify({ Title = "Success", Message = "Operation completed successfully!", Type = "Success", Duration = 3 }) end })
Settings:AddButton({ Name = "Test Warning", ButtonText = "Send", Callback = function() Nexus:Notify({ Title = "Warning", Message = "Careful with this setting.",          Type = "Warning", Duration = 3 }) end })
Settings:AddButton({ Name = "Test Error",   ButtonText = "Send", Callback = function() Nexus:Notify({ Title = "Error",   Message = "Something went wrong.",             Type = "Error",   Duration = 3 }) end })

-- Config panel (tabbed: Manage / Export / Import)
Settings:AddConfigPanel()

-- ─── Welcome ──────────────────────────────────────────────────────────────────
Nexus:Notify({
    Title    = "My Script",
    Message  = "NexusLib v.4 loaded. Press RightShift to toggle.",
    Type     = "Success",
    Duration = 5,
})
