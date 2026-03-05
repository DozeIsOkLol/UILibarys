# Custom Roblox UI Library

A modern, feature-rich Roblox UI library with dropdown tabs, smooth animations, and extensive customization options.

## Features

✨ **Modern Design**
- Clean, dark-themed interface
- Smooth animations and transitions
- Ripple click effects
- Gradient accent lines

🎯 **Dropdown/Tab System**
- Multiple dropdown tabs per window
- Collapsible sections
- Automatic size management
- Smooth open/close animations

🛠️ **UI Elements**
- Buttons
- Toggles
- Sliders
- Labels
- Textboxes
- Keybinds

⚡ **Performance**
- Optimized tweening
- Efficient element management
- Minimal resource usage

🎨 **Customizable**
- Easy color configuration
- Adjustable sizes
- Custom keybinds

## Installation

### Method 1: Direct Load (Recommended)
```lua
local Library = loadstring(game:HttpGet("YOUR_RAW_GITHUB_URL_HERE"))()
```

### Method 2: Local Script
1. Copy the contents of `CustomUILib.lua`
2. Paste into your executor
3. Execute the script

## Quick Start

```lua
-- Load the library
local Library = loadstring(game:HttpGet("path/to/CustomUILib.lua"))()

-- Create a window
local Window = Library:CreateWindow("My UI", Enum.KeyCode.RightShift)

-- Create a dropdown/tab
local Tab = Window:CreateDropdown("Main")

-- Add elements
Tab:AddButton("Click Me", function()
    print("Button clicked!")
end)

Tab:AddToggle("Toggle Me", false, function(state)
    print("Toggle state:", state)
end)

Tab:AddSlider("Value", 0, 100, 50, function(value)
    print("Slider value:", value)
end)
```

## Documentation

### Creating a Window

```lua
Library:CreateWindow(windowName, toggleKey)
```

**Parameters:**
- `windowName` (string): The title of the window
- `toggleKey` (KeyCode): Key to toggle UI visibility (default: RightShift)

**Returns:** Window object

**Example:**
```lua
local Window = Library:CreateWindow("Custom UI", Enum.KeyCode.RightShift)
```

---

### Creating a Dropdown/Tab

```lua
Window:CreateDropdown(dropdownName)
```

**Parameters:**
- `dropdownName` (string): Name of the dropdown tab

**Returns:** Dropdown object

**Example:**
```lua
local CombatTab = Window:CreateDropdown("Combat")
local PlayerTab = Window:CreateDropdown("Player")
```

---

### Adding Elements

#### Button
```lua
Dropdown:AddButton(buttonName, callback)
```

**Parameters:**
- `buttonName` (string): Text displayed on the button
- `callback` (function): Function called when button is clicked

**Example:**
```lua
Tab:AddButton("Teleport", function()
    -- Your code here
end)
```

---

#### Toggle
```lua
Dropdown:AddToggle(toggleName, default, callback)
```

**Parameters:**
- `toggleName` (string): Text displayed next to toggle
- `default` (boolean): Initial state (default: false)
- `callback` (function): Function called when toggled, receives state (boolean)

**Example:**
```lua
Tab:AddToggle("Auto Farm", false, function(state)
    if state then
        print("Auto farm enabled")
    else
        print("Auto farm disabled")
    end
end)
```

---

#### Slider
```lua
Dropdown:AddSlider(sliderName, min, max, default, callback)
```

**Parameters:**
- `sliderName` (string): Text displayed above slider
- `min` (number): Minimum value (default: 0)
- `max` (number): Maximum value (default: 100)
- `default` (number): Initial value (default: min)
- `callback` (function): Function called when value changes, receives value (number)

**Example:**
```lua
Tab:AddSlider("Walk Speed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
```

---

#### Label
```lua
Dropdown:AddLabel(text)
```

**Parameters:**
- `text` (string): Text to display

**Example:**
```lua
Tab:AddLabel("--- Settings ---")
```

---

#### Textbox
```lua
Dropdown:AddTextbox(placeholder, callback)
```

**Parameters:**
- `placeholder` (string): Placeholder text
- `callback` (function): Function called when Enter is pressed, receives text (string)

**Example:**
```lua
Tab:AddTextbox("Enter Player Name", function(text)
    print("Entered:", text)
end)
```

---

#### Keybind
```lua
Dropdown:AddKeybind(keybindName, defaultKey, callback)
```

**Parameters:**
- `keybindName` (string): Text displayed next to keybind
- `defaultKey` (KeyCode): Default key (default: E)
- `callback` (function): Function called when key is pressed, receives key (KeyCode)

**Example:**
```lua
Tab:AddKeybind("Fly", Enum.KeyCode.F, function(key)
    print("Fly activated with key:", key.Name)
end)
```

---

## Complete Example

```lua
local Library = loadstring(game:HttpGet("path/to/CustomUILib.lua"))()

-- Create window
local Window = Library:CreateWindow("Game Hub", Enum.KeyCode.RightShift)

-- Combat Tab
local Combat = Window:CreateDropdown("Combat")
Combat:AddButton("Kill All", function()
    -- Kill all code
end)
Combat:AddToggle("Auto Attack", false, function(state)
    -- Auto attack code
end)
Combat:AddSlider("Damage", 1, 100, 10, function(value)
    -- Set damage
end)

-- Player Tab
local Player = Window:CreateDropdown("Player")
Player:AddLabel("--- Movement ---")
Player:AddSlider("Walk Speed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
Player:AddSlider("Jump Power", 50, 200, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)
Player:AddToggle("Infinite Jump", false, function(state)
    -- Infinite jump code
end)

-- Visuals Tab
local Visuals = Window:CreateDropdown("Visuals")
Visuals:AddToggle("ESP", false, function(state)
    -- ESP code
end)
Visuals:AddToggle("Tracers", false, function(state)
    -- Tracers code
end)
Visuals:AddSlider("FOV", 70, 120, 70, function(value)
    workspace.CurrentCamera.FieldOfView = value
end)

-- Misc Tab
local Misc = Window:CreateDropdown("Miscellaneous")
Misc:AddButton("Rejoin", function()
    -- Rejoin code
end)
Misc:AddTextbox("Player Name", function(text)
    print("Target:", text)
end)
Misc:AddKeybind("Toggle UI", Enum.KeyCode.RightShift, function()
    -- Custom toggle code
end)
```

## Customization

You can customize colors by modifying the Config table in the library:

```lua
local Config = {
    MainColor = Color3.fromRGB(35, 35, 35),
    SecondaryColor = Color3.fromRGB(45, 45, 45),
    AccentColor = Color3.fromRGB(120, 120, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    ToggleOn = Color3.fromRGB(14, 255, 110),
    ToggleOff = Color3.fromRGB(255, 44, 44),
}
```

## Features Comparison

| Feature | 0x Library | Bacon Library | Custom Library |
|---------|-----------|---------------|----------------|
| Dropdown Tabs | ❌ | ✅ | ✅ (Enhanced) |
| Multiple Tabs | ❌ | ✅ | ✅ |
| Ripple Effects | ✅ | ❌ | ✅ |
| Smooth Animations | ✅ | ✅ | ✅ |
| Keybinds | ❌ | ✅ | ✅ |
| Sliders | ✅ | ✅ | ✅ (Improved) |
| Textboxes | ❌ | ✅ | ✅ |
| Modern Design | ✅ | ⚠️ | ✅ |

## Credits

Inspired by:
- 0x UI Library (Design & Animations)
- BaconLib (Dropdown System)

## License

Free to use and modify for personal projects.

## Support

For issues or suggestions, please contact the developer or submit an issue on GitHub.

---

**Made with ❤️ for the Roblox scripting community**
