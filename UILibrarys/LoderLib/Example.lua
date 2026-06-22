-- LoderLib Example Usage
-- Load the library from GitHub (update the URL to your raw file once uploaded)
local LoderLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUser/YourRepo/main/Source.lua"))()

---------------------------------------------------------
-- Create the window
---------------------------------------------------------
local win = LoderLib:Window("LoderLib Demo")

---------------------------------------------------------
-- TAB: General
---------------------------------------------------------
local general = win:Tab("General")

-- Section: Actions
local actions = general:Section("Actions")

actions:Button("Print Hello", function()
    print("Hello from LoderLib!")
end)

actions:Button("Send Notification", function()
    LoderLib:Notification("Success", "This is a notification from LoderLib.", "Got it!")
end)

actions:Separator()

actions:Label("Buttons above will print to output or show a notification.")

-- Section: Toggles
local toggles = general:Section("Toggles")

local godToggle = toggles:Toggle("God Mode", false, function(state)
    print("God Mode:", state)
end)

local espToggle = toggles:Toggle("ESP", true, function(state)
    print("ESP:", state)
end)

toggles:Button("Force God On", function()
    godToggle:Set(true)
end)

toggles:Button("Force ESP Off", function()
    espToggle:Set(false)
end)

---------------------------------------------------------
-- TAB: Settings
---------------------------------------------------------
local settings = win:Tab("Settings")

-- Section: Sliders
local sliders = settings:Section("Sliders")

local speedSlider = sliders:Slider("Walk Speed", 0, 500, 16, function(val)
    print("Speed:", val)
    -- game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
end)

local jumpSlider = sliders:Slider("Jump Power", 0, 200, 50, function(val)
    print("Jump:", val)
    -- game.Players.LocalPlayer.Character.Humanoid.JumpPower = val
end)

sliders:Button("Reset Speed", function()
    speedSlider:Change(16)
end)

sliders:Button("Max Speed", function()
    speedSlider:Change(500)
end)

-- Section: Textboxes
local textboxes = settings:Section("Textboxes")

local nameBox = textboxes:Textbox("Target Player", "Enter username...", true, function(text)
    print("Target set to:", text)
end)

textboxes:Button("Clear Target", function()
    nameBox:SetText("")
end)

---------------------------------------------------------
-- TAB: Visual
---------------------------------------------------------
local visual = win:Tab("Visual")

-- Section: Dropdowns
local dropdowns = visual:Section("Dropdowns")

local teamDrop = dropdowns:Dropdown("Select Team", {
    "Red Team",
    "Blue Team",
    "Green Team",
    "Yellow Team",
}, function(option)
    print("Team selected:", option)
end)

dropdowns:Button("Clear Selection", function()
    teamDrop:Clear()
end)

dropdowns:Button("Add Purple Team", function()
    teamDrop:Add("Purple Team")
end)

dropdowns:Button("Force Blue Team", function()
    teamDrop:Set("Blue Team")
end)

-- Section: Colorpickers
local colors = visual:Section("Colors")

local espColor = colors:Colorpicker("ESP Color", Color3.fromRGB(255, 50, 50), function(col)
    print("ESP Color changed:", col)
end)

local chamsColor = colors:Colorpicker("Chams Color", Color3.fromRGB(50, 100, 255), function(col)
    print("Chams Color changed:", col)
end)

colors:Button("Reset ESP Color", function()
    espColor:Set(Color3.fromRGB(255, 50, 50))
end)

---------------------------------------------------------
-- TAB: Binds
---------------------------------------------------------
local binds = win:Tab("Binds")

local bindSec = binds:Section("Keybinds")

bindSec:Bind("Kill Aura", Enum.KeyCode.E, function()
    print("Kill Aura triggered!")
    LoderLib:Notification("Kill Aura", "Activated kill aura!", "OK")
end)

bindSec:Bind("Teleport to Waypoint", Enum.KeyCode.T, function()
    print("Teleporting...")
end)

bindSec:Bind("Toggle UI", Enum.KeyCode.RightControl, function()
    print("UI toggled!")
end)

bindSec:Separator()
bindSec:Label("Click a keybind button then press any key to rebind it.")
