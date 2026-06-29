
local Library = loadstring(Game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
local Window = Library:NewWindow("Lift Wall Sim")
local MainTab = Window:NewSection("Main")

MainTab:CreateTextbox("Get Power", function(number)
    local args = { tonumber(number), 1, "Normal" }
    game:GetService("ReplicatedStorage").Events.Game.Punch:FireServer(unpack(args))
end)

MainTab:CreateTextbox("Hatch Egg", function(number)
    local args = { "Basic", -tonumber(number), {
        ["Autumn"] = {},
        ["Majestic Heaven"] = {},
        ["Forest"] = {},
        ["Dragon"] = {},
        ["Heavenly"] = {},
        ["Cactus"] = {},
        ["Basic"] = {},
        ["Earth"] = {},
        ["Farm"] = {},
        ["Frozen"] = {}
    }}
    game:GetService("ReplicatedStorage").Events.Pets.OpenEgg:FireServer(unpack(args))
end)

local hatchRobuxEggLoop = false
MainTab:CreateToggle("Hatch Robux Egg", function(state)
    hatchRobuxEggLoop = state
    while hatchRobuxEggLoop do
        local args = { "Majestic Heaven", 1, {
            ["Autumn"] = {},
            ["Majestic Heaven"] = {},
            ["Forest"] = {},
            ["Dragon"] = {},
            ["Heavenly"] = {},
            ["Cactus"] = {},
            ["Basic"] = {},
            ["Earth"] = {},
            ["Farm"] = {},
            ["Frozen"] = {}
        }}
        game:GetService("ReplicatedStorage").Events.Pets.OpenEgg:FireServer(unpack(args))
        wait(0.1)
    end
end)

local autoRebirthLoop = false
MainTab:CreateToggle("Auto Rebirth", function(state)
    autoRebirthLoop = state
    while autoRebirthLoop do
        game:GetService("ReplicatedStorage").Events.Player.Rebirth:FireServer()
        wait(0.00000000000000000000001)
    end
end)

local YTSection = Window:NewSection("Cr:SimpleScripter")

local function applyStyles()
    for _, v in pairs(game.CoreGui:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "Lift Wall Sim" then
            v.Font = Enum.Font.Bangers
            v.TextSize = 20
        elseif v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
            v.Font = Enum.Font.FredokaOne
        end
    end
end
applyStyles()
