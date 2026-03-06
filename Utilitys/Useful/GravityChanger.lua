-- Gravity Changer (Keybind: 'G' to toggle low gravity)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local originalGravity = workspace.Gravity
local lowGravity = 50  -- Low gravity value
local enabled = false

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.G then
        enabled = not enabled
        workspace.Gravity = enabled and lowGravity or originalGravity
        print("Gravity toggled:", enabled and "Low (" .. lowGravity .. ")" or "Normal")
    end
end)

print("Gravity Changer loaded! Press 'G' to toggle low gravity.")
