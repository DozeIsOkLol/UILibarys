-- (Keybind: 'N' to toggle)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local noclip = false
local noclipConnection

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        noclip = not noclip
        print("Noclip:", noclip and "ON" or "OFF")
        if noclipConnection then noclipConnection:Disconnect() end
        if noclip then
            noclipConnection = RunService.Stepped:Connect(function()
                local character = player.Character
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
end)

print("Noclip loaded! Press 'N' to toggle.")
