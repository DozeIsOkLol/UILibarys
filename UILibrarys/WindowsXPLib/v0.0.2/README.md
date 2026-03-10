# WinXP UI

> A Roblox UI library that faithfully recreates the classic **Windows XP Luna** desktop aesthetic — raised 3-D borders, blue gradient title bars, Luna tabs, sunken input fields, and all.

<p align="center">
  <img src="https://github.com/DozeIsOkLol/UILibarys/blob/main/UILibrarys/WindowsXPLib/v0.0.2/Preview.png" alt="WinXP UI preview" width="540"/>
</p>

---

## ✨ Features

| Component | Description |
|-----------|-------------|
| **Window** | Draggable, minimise / maximise / close, toggle keybind |
| **Tabs** | Classic flush-bottom XP tab strip |
| **Button** | Raised 3-D push button with hover & press states |
| **Toggle** | Sunken checkbox with ✓ tick mark |
| **Slider** | Sunken track with fill bar, decimal support |
| **Dropdown** | Sunken combobox with scrollable option list |
| **Textbox** | Sunken single-line input, enter-only mode |
| **Keybind** | Click-to-rebind keybind row |
| **ColorPicker** | Inline RGB channel sliders |
| **Label** | Plain text label with `Set()` method |
| **Section** | Bold blue heading + double ruled line |
| **Separator** | Thin etched horizontal divider |
| **Notify** | Toast notification (Info / Success / Warning / Error) with countdown bar |

---

## ⚡ Quick Start

### 1 — Load in your executor

```lua
local WinXP = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOUR_USERNAME/WinXP-UI/main/Source.lua"
))()
```

### 2 — Create a window

```lua
local Window = WinXP:CreateWindow({
    Title     = "My Script",
    Size      = UDim2.new(0, 540, 0, 420),
    ToggleKey = Enum.KeyCode.RightControl,
})
```

### 3 — Add tabs and elements

```lua
local Tab = Window:AddTab("Main")

Tab:AddSection("Player")

Tab:AddSlider({
    Text     = "Walk Speed",
    Min      = 8,
    Max      = 300,
    Default  = 16,
    Suffix   = " studs/s",
    Callback = function(v)
        game.Players.LocalPlayer.Character
            :FindFirstChildOfClass("Humanoid").WalkSpeed = v
    end,
})

Tab:AddToggle({
    Text     = "God Mode",
    Default  = false,
    Callback = function(state)
        print("God Mode:", state)
    end,
})

Window:Notify({
    Title   = "Loaded",
    Message = "Script is ready!",
    Type    = "Success",
})
```

---

## 📁 Repository Structure

```
WinXP-UI/
├── Source.lua      ← Library source (loadstring this)
├── Example.lua     ← Full featured example script
├── README.md       ← You are here
└── Docs.md         ← Complete API reference
```

---

## 🎨 Custom Theme

Override any colour in the theme table before creating windows:

```lua
WinXP:SetTheme({
    TitleGradLeft  = Color3.fromRGB(80, 0, 120),   -- purple title bar
    TitleGradRight = Color3.fromRGB(200, 100, 255),
    WindowBody     = Color3.fromRGB(30, 30, 30),   -- dark window body
    LabelText      = Color3.fromRGB(230, 230, 230),
})
```

Call `WinXP:GetTheme()` to inspect all available keys.

---

## 🛡️ Executor Compatibility

The library auto-detects the best `ScreenGui` parent:

| Executor feature | Parent used |
|-----------------|-------------|
| `gethui()`      | `gethui()` result |
| CoreGui write access | `CoreGui` |
| Fallback | `PlayerGui` |

Tested on **Synapse X**, **KRNL**, and **Fluxus**.

---

## 📜 License

MIT — free to use, modify, and distribute. Credit appreciated but not required.
