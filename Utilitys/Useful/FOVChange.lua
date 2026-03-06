-- FOV Changer (Hold 'F' to zoom out FOV to 120)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local originalFOV = camera.FieldOfView
local wideFOV = 120
local enabled = false

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        enabled = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        enabled = false
        camera.FieldOfView = originalFOV
    end
end)

RunService.RenderStepped:Connect(function()
    if enabled then
        camera.FieldOfView = wideFOV
    end
end)

print("FOV Changer loaded! Hold 'F' for wide FOV (120).")
