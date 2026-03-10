# 🌌 Isotopia UI Library

A high-performance, sleek, and modern UI library for Luau environments. Optimized for speed, customizability, and ease of use.

---

## 🚀 Quick Start (Example Usage)

```lua
local window = Isotopia:Window({
    Title = "Isotopia UI",
    Icon = "sword",
    MainColor = Color3.fromRGB(255, 0, 0),
    Transparent = false,
    Size = UDim2.fromOffset(700, 500),
    Spinning = true,
    AnimatedTitle = {
        AnimationColor = Color3.fromRGB(0, 255, 0),
        AnimationSide = "Right",
        AnimationSpeed = 5
    }
})

window:SetToggleKey(Enum.KeyCode.Insert)

local tab = window:Tab({ Title = "Main", Icon = "home" })
local section = tab:Section({ Side = "left" })

local myToggle = section:Toggle({
    Title = "My Toggle",
    Description = "Enable/disable feature",
    Default = false,
    Callback = function(state) print("Toggle:", state) end
})

section:Button({
    Title = "Click Me",
    Description = "A test button",
    Callback = function() print("Button clicked!") end
})

window:load()
```
📑 API Reference
<details>
<summary><b>⚙️ Settings Configurations (Table Definitions)</b></summary>

```lua
Window Settings
{
    Title = string,                 -- Window title
    Icon = string,                  -- Lucide icon name or ID
    MainColor = Color3,             -- Accent color
    Transparent = boolean,          -- Background transparency
    Size = UDim2,                   -- Initial size
    Spinning = boolean,             -- Icon rotation state
    AnimatedTitle = {               -- Optional title animation
        AnimationColor = Color3,
        AnimationSide = string,     -- "Left" or "Right"
        AnimationSpeed = number
    }
}

Module Settings (General)
{
    Title = string,
    Description = string,           -- Subtext for the module
    Default = any,                  -- Initial value
    Callback = function(v) end,     -- Function triggered on change
    -- Dropdown specific
    Values = {"Option 1", "Option 2"}
    -- Slider specific
    Min = number,
    Max = number
}
```
</details>
<details>
<summary><b>🪟 Window Functions</b></summary>

```lua
local window = Isotopia:Window(settings)

window:load()                           -- Loads and displays the window
window:Toggle()                         -- Toggles window minimize/open
window:change_visiblity(state)          -- Changes window visibility (true/false)
window:EditOpenButton(settings)         -- Customize minimize button behavior
window:SetMainColor(color)              -- Changes the main accent color
window:SetSize(newSize)                 -- Changes window size (UDim2)
window:GetSize()                        -- Returns current window size
window:SetTransparent(state)            -- Toggles transparency
window:GetTransparent()                 -- Returns transparency state
window:SetAnimationSettings(settings)   -- Configures title animation
window:GetAnimationSettings()           -- Returns animation settings
window:SetToggleKey(keyCode)            -- Sets window toggle keybind
window:GetToggleKey()                   -- Returns toggle key
window:ClearToggleKey()                 -- Clears toggle keybind
window:SetSpinning(state)               -- Toggles icon spinning
window:GetSpinning()                    -- Returns spinning state
```
</details>
<details>
<summary><b>📂 Tab & Section Functions</b></summary>

```lua
-- Tab Manager
local tab = window:Tab(settings)

-- Section Manager
local section = tab:Section(settings)

-- Creating Modules
local toggle = section:Toggle(settings)
local button = section:Button(settings)
local slider = section:Slider(settings)
local dropdown = section:Dropdown(settings)
local label = section:Label(settings)
local checkbox = section:Checkbox(settings)
local input = section:Input(settings)
local divider = section:Divider(settings)
```
</details>
<details>
<summary><b>🧩 Module-Specific Methods</b></summary>
Toggle Module

```lua
toggle:Toggle(value)                    -- Toggles state (or sets specific value)

Slider Module
slider:Set(value)                       -- Sets slider value

Dropdown Module
dropdown:Set(value, isToggle)           -- Sets dropdown value
dropdown:Toggle()                       -- Toggles dropdown visibility
dropdown:GetValue()                     -- Returns current value(s)
dropdown:SetValue(value)                -- Sets value directly
dropdown:Clear()                        -- Clears selection

Checkbox Module
checkbox:change_state(state)            -- Changes checkbox state
checkbox:scale_keybind(empty)           -- Adjusts keybind UI size
checkbox:connect_keybind()              -- Connects keybind listener

Input Module
input:update_text(text)                 -- Updates input text
```
</details>
<details>
<summary><b>🛠️ Utilities & Notifications</b></summary>
Notifications

```lua
Isotopia:Notify(settings)               -- Creates a notification popup

Utility Functions
Isotopia.Theme                          -- Theme colors table
Config:save(file_name, config)          -- Saves configuration
Config:load(file_name, config)          -- Loads configuration
Util:map(value, in_min, in_max, out_min, out_max) -- Maps value ranges
Util:viewport_point_to_world(location, distance) -- Converts viewport to world
Util:get_offset()                       -- Gets UI offset based on screen size
```
</details>

