-- ╔══════════════════════════════════════════╗
-- ║         Sorcerer LIBRARY v0.0.1          ║
-- ╚══════════════════════════════════════════╝
-- Load via HTTP or paste Source.lua into your executor and use:
--   local Library = loadstring(game:HttpGet("YOUR_RAW_URL"))()
-- For local testing (paste Source.lua first):
--   local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/Source.lua"))()

-- ─── Load Library ────────────────────────────
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/MadeByDoze/sorcerer/v0.0.1/Source.lua"))()

-- ─── Create Window ───────────────────────────
local MainMenuWindow = Library:NewWindow("Combat")

-- ─── Create Section ──────────────────────────
local MainMenu = MainMenuWindow:NewSection("Kill Options")

-- ┌─────────────────────────────────────────────┐
-- │  Button                                      │
-- └─────────────────────────────────────────────┘
MainMenu:CreateButton("Button", function()
    print("Button clicked!")
end)

-- ┌─────────────────────────────────────────────┐
-- │  TextBox                                     │
-- └─────────────────────────────────────────────┘
MainMenu:CreateTextbox("TextBox", function(text)
    print("TextBox submitted:", text)
end)

-- ┌─────────────────────────────────────────────┐
-- │  Toggle                                      │
-- └─────────────────────────────────────────────┘
local autoEzToggle = MainMenu:CreateToggle("Auto Ez", function(value)
    print("Auto Ez:", value)
end)

-- ┌─────────────────────────────────────────────┐
-- │  Dropdown                                    │
-- └─────────────────────────────────────────────┘
local dropdown = MainMenu:CreateDropdown("DropDown", {"Hello", "World", "Hello World"}, 2, function(text)
    print("Dropdown selected:", text)
end)

-- ┌─────────────────────────────────────────────┐
-- │  Slider                                      │
-- └─────────────────────────────────────────────┘
local slider = MainMenu:CreateSlider("Slider", 0, 100, 15, true, function(value)
    print("Slider value:", value)
end)

-- ┌─────────────────────────────────────────────┐
-- │  Color Picker                                │
-- └─────────────────────────────────────────────┘
local colorPicker = MainMenu:CreateColorPicker("Picker", Color3.new(1, 1, 1), function(value)
    print("Color picked:", value)
end)

-- ─── Extra Section Example ───────────────────
local ExtraSection = MainMenuWindow:NewSection("Player Options")

ExtraSection:CreateLabel("-- Walk Speed --", Color3.fromRGB(0, 210, 230))

local speedSlider = ExtraSection:CreateSlider("WalkSpeed", 16, 500, 16, true, function(value)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

ExtraSection:CreateSeparator()

ExtraSection:CreateLabel("-- Jump Power --", Color3.fromRGB(0, 210, 230))

local jumpSlider = ExtraSection:CreateSlider("JumpPower", 50, 500, 50, true, function(value)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = value
    end
end)

ExtraSection:CreateToggle("Infinite Jump", function(value)
    _G.InfiniteJump = value
end)

-- Infinite jump logic
game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfiniteJump then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ─── Programmatic Control Examples ──────────
-- You can also set values from code:
-- autoEzToggle:Set(true)     -- turn toggle on
-- slider:Set(50)             -- move slider to 50
-- dropdown:Set("Hello")      -- change dropdown option
-- colorPicker:Set(Color3.fromRGB(255, 0, 0))  -- set red
