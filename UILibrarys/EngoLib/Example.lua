local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/EngoLib/Source.lua", true))()

local main = library:CreateMain("Yes", "", Enum.KeyCode.LeftAlt)

local tab = main:CreateTab("Yes TAB")

tab:CreateLabel("Main")

tab:CreateToggle("Toggle", function(value)
   
end);
