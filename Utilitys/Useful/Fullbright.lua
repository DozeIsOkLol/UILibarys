local Lighting = game:GetService("Lighting")

local originalBrightness = Lighting.Brightness
local originalClockTime = Lighting.ClockTime
local originalFogEnd = Lighting.FogEnd
local originalGlobalShadows = Lighting.GlobalShadows
local originalEnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
local original.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale

local function setFullbright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    print("Fullbright ON.")
end

local function resetLighting()
    Lighting.Brightness = originalBrightness
    Lighting.ClockTime = originalClockTime
    Lighting.FogEnd = originalFogEnd
    Lighting.GlobalShadows = originalGlobalShadows
    Lighting.EnvironmentDiffuseScale = originalEnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale = originalEnvironmentSpecularScale
    print("Fullbright OFF.")
end

-- Toggle with 'B'
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.B then
        if Lighting.Brightness == 2 then
            resetLighting()
        else
            setFullbright()
        end
    end
end)

setFullbright()  -- Start with fullbright
print("Fullbright loaded! Press 'B' to toggle.")
