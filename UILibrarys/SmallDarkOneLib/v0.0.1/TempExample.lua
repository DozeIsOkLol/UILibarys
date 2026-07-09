local SmallDarkOneLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/SmallDarkOneLib/v0.0.1/Source.lua"))()

		local Window = SmallDarkOneLib:CreateWindow({
			Title    = "SMALL DARK ONE",
			Subtitle = "v1.0.0",
			Theme    = "Bloodmoon", -- or "Voidspider"
		})

		local Tab = Window:CreateTab("Main")
		local Section = Tab:CreateSection("Settings")
		Section:CreateButton({ Name = "Click me", Callback = function() end })
