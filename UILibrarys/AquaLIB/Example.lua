local Aqua = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/AquaLIB/Source.lua"))()

-- Create the window exactly as in screenshot
local window = Aqua.createWindow("AquaLIB", "AquaLIB", true)  -- draggable

-- Create the single tab
local tab = window.createTab("This Is A Tab")

-- Create the main section (collapsible, but starts open by default if not specified)
local section = tab.createSection("Test Section", true)  -- true = expanded

-- 1. Text label (top item)
section.createText("This Is A")

-- 2. First Dropdown (shows "Test Dropdown: Option 7" – label + selected value in UI)
section.createDropdown(
    "Test Dropdown",
    {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5", "Option 6", "Option 7", "Option 8", "Option 9", "Option 10"},
    "Option 7",
    function(value)
        print("Dropdown 1 selected:", value)
    end
)

-- 3. Test Button
section.createButton("Test Button", function()
    print("Test Button pressed!")
end)

-- 4. Create Notification Button (on tab to match screenshot positioning)
tab.createButton("Create Notification", function()
    window.notification("Test Notification", "Hello from AquaLIB!")
    print("Notification triggered!")
end)

-- 5. Test Toggle (red indicator when off, as in screenshot)
section.createToggle("Test Toggle", false, function(state)
    print("Toggle changed to:", state)
end)

-- 6. Test Text label
section.createText("Test Text")

-- 7. Second Dropdown (duplicate to match screenshot having two)
section.createDropdown(
    "Test Dropdown",
    {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5", "Option 6", "Option 7", "Option 8", "Option 9", "Option 10"},
    "Option 7",
    function(value)
        print("Dropdown 2 selected:", value)
    end
)

-- 8. Test Slider (green fill, default 50)
section.createSlider("Test Slider", {min = 1, max = 100, defualt = 50}, function(value)
    print("Slider value:", value)
end)

-- 9. Test TextBox (with placeholder "Test", and shows "Test" as if typed)
local textbox = section.createTextBox("Test TextBox", "Test")
-- Optional: Simulate pre-filled text as in screenshot (AquaLIB may not support setting initial value directly, but placeholder is there)
-- If you want to force initial text, some libs allow it via instance, but here we just use placeholder

print("AquaLIB Screenshot-Matched Demo loaded!")
print("→ Window: TestWindow")
print("→ Tab: This Is A Tab")
print("→ Section: Test Section")
print("→ All elements added in visual order from the screenshot")
print("→ Interact with everything and check F9 console")
