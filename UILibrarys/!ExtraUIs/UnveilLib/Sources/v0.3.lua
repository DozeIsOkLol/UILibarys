--// --- Part 1: Paste the Unveil UI library V1.0 code above this line ---
local UnveilUI = --[[ The library code ]]

--// --- Part 2: Example Script using Unveil UI ---
local Window = UnveilUI:CreateWindow("Unveil UI - Example", 300, 450)

-- A label to act as a title for a section
Window:AddLabel({
    text = "Demonstration Elements",
    align = Enum.TextXAlignment.Center,
    textSize = 18
})

-- A standard button
Window:AddButton({
    text = "Test Button",
    color = Color3.fromRGB(88, 101, 242), -- Optional color
    callback = function()
        Window:SetStatus("Test Button clicked!", Color3.fromRGB(255, 255, 255))
        print("Test Button clicked!")
    end
})

-- A toggle button that manages its own state
Window:AddToggle({
    text = "Test Toggle",
    state = false, -- Optional: initial state
    callback = function(state)
        Window:SetStatus("Toggle is now: " .. tostring(state))
        print("Toggle is now: " .. tostring(state))
    end
})

-- A visual separator
Window:AddSeparator()

-- A text input field with a submit button
Window:AddInput({
    placeholder = "Type here...",
    buttonText = "Submit",
    callback = function(text)
        Window:SetStatus("Submitted: " .. text)
        print("Submitted text: " .. text)
    end
})

-- A slider for numeric input
Window:AddSlider({
    text = "Test Slider",
    min = 1,
    max = 100,
    default = 50,
    onDrag = function(value)
        -- This function fires every time the slider moves (live feedback)
        print("Slider dragging at: " .. value)
    end,
    callback = function(value)
        -- This function fires when the mouse is released
        Window:SetStatus("Slider set to: " .. value)
        print("Slider released at: " .. value)
    end
})

-- A final label for credits or notes
Window:AddLabel({
    text = "Created with Unveil UI v1.0",
    align = Enum.TextXAlignment.Center,
    textSize = 12,
    color = Color3.fromRGB(100, 100, 100)
})

-- Initialize the UI and set a custom toggle key
Window:Init({
    toggleKey = Enum.KeyCode.PageUp
})