local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/GeradLib/Source.lua"))()

-- Create a window
local window = library:CreateWindow("GeradLib Demo")

-- Add a section (collapsible header)
local section = window:Section("Main Controls")  -- Returns section object

-- Label inside section
section:Label("Welcome to GeradLib!")

-- Button example
section:Button("Test Button", function()
    print("Button clicked! Hello from GeradLib.")
end)

-- Toggle example (if supported; source has basic toggle logic in UI)
-- Note: Source has toggle visuals but no explicit :Toggle method — simulate with button or check runtime
section:Button("Toggle Godmode (simulate)", function()
    print("Godmode toggled! (check console or add real logic)")
end)

-- Add another section
local extras = window:Section("Extras")

extras:Label("More stuff here")

extras:Button("Spawn Notification (print)", function()
    print("Notification: This is a test from GeradLib!")
end)


local Tableeeeeeee = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'Wally', 'Wally Is Cool', 'bit', 'byte', 'megabyte', 'byte-chan:tm: is smart'}


extras:Toggle("Am toggle", {flag = 'EpicFlag', Default = true})
extras:Box('Am box', {flag = 'BoxFlag'})
extras:Label('A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z.')
extras:Bind('am KEYbind', {flag = 'KeYbInD'}, function() print("AAAAAA") end)
extras:Slider('am sliderino', {flag = "Slideeeeee"; Min = -100; Max = 100; Default = 0 ; Precise = false })
extras:Dropdown('ima drop', {flag = 'Dropperino', list = Tableeeeeeee, Type = 'Toggle'})
extras:ColorPicker('colour not color >:D', {flag = 'AMCOLOUR'})
-- Window toggle (built-in "-" / "+" button on top bar)
print("GeradLib Demo loaded!")
print("→ Window created with title 'GeradLib Demo'")
print("→ Drag top bar to move")
print("→ Click section headers to collapse/expand")
print("→ Click buttons for console prints")
print("→ Toggle window visibility with the '-' / '+' button on top")
print("→ Press F9 to see output. UI uses CoreGui – check Roblox player")
