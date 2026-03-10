# WinXP UI — API Reference

Complete documentation for every function, parameter, and return value in the library.

---

## Table of Contents

1. [Loading the Library](#1-loading-the-library)
2. [WinXP (root object)](#2-winxp-root-object)
3. [Window](#3-window)
4. [Tab](#4-tab)
   - [AddButton](#addbutton)
   - [AddToggle](#addtoggle)
   - [AddSlider](#addslider)
   - [AddDropdown](#adddropdown)
   - [AddTextbox](#addtextbox)
   - [AddKeybind](#addkeybind)
   - [AddColorPicker](#addcolorpicker)
   - [AddLabel](#addlabel)
   - [AddSection](#addsection)
   - [AddSeparator](#addseparator)
5. [Notify](#5-notify)
6. [Theme Customisation](#6-theme-customisation)
7. [Theme Keys Reference](#7-theme-keys-reference)

---

## 1. Loading the Library

```lua
local WinXP = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOUR_USERNAME/WinXP-UI/main/Source.lua"
))()
```

> **Requires** `game:HttpGet` permission. Enable it in your executor's settings if prompted.

---

## 2. WinXP (root object)

### `WinXP:CreateWindow(config)` → `Window`

Creates and displays a new WinXP-styled window.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.Title` | `string` | `"WinXP UI"` | Text shown in the title bar |
| `config.Size` | `UDim2` | `UDim2.new(0,540,0,420)` | Initial window size |
| `config.Position` | `UDim2` | Centred | Initial screen position |
| `config.Icon` | `string` | `""` | Roblox asset ID for a 16×16 icon (`"rbxassetid://…"`) |
| `config.ToggleKey` | `Enum.KeyCode` | `RightControl` | Key that shows/hides the window |

```lua
local Window = WinXP:CreateWindow({
    Title     = "My Cheat",
    Size      = UDim2.new(0, 540, 0, 440),
    ToggleKey = Enum.KeyCode.Insert,
})
```

---

### `WinXP:SetTheme(overrides)`

Overrides one or more colours in the global theme **before** creating any windows.

```lua
WinXP:SetTheme({
    TitleGradLeft  = Color3.fromRGB(0, 80, 0),
    TitleGradRight = Color3.fromRGB(80, 200, 80),
})
```

> See [Theme Keys Reference](#7-theme-keys-reference) for all available keys.

---

### `WinXP:GetTheme()` → `table`

Returns a reference to the current theme table so you can read existing values.

---

## 3. Window

The object returned by `WinXP:CreateWindow()`.

### `Window:AddTab(name)` → `Tab`

Adds a tab to the tab strip and returns a `Tab` object.

```lua
local MainTab = Window:AddTab("Main")
local VisualTab = Window:AddTab("Visuals")
```

The first tab added is automatically selected.

---

### `Window:Notify(config)`

Displays a toast notification in the bottom-right corner of the screen.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.Title` | `string` | `"Notification"` | Bold heading |
| `config.Message` | `string` | `""` | Body text (wraps automatically) |
| `config.Duration` | `number` | `4` | Seconds before auto-dismiss |
| `config.Type` | `string` | `"Info"` | Accent colour preset: `"Info"` `"Success"` `"Warning"` `"Error"` |

```lua
Window:Notify({
    Title    = "Speed Updated",
    Message  = "Walk speed set to 100 studs/s.",
    Type     = "Success",
    Duration = 3,
})
```

---

### `Window:Toggle()`

Toggles the visibility of the window frame. Equivalent to pressing the `ToggleKey`.

---

### `Window:SetTitle(text)`

Updates the text in the window's title bar at runtime.

```lua
Window:SetTitle("My Script  v2.0")
```

---

### `Window:Destroy()`

Removes the entire `ScreenGui` from the game. All UI elements are cleaned up.

---

## 4. Tab

Every element-adding method returns a **control object** with `Get()` / `Set()` methods (where applicable) so you can read or update values programmatically.

---

### `AddButton`

A classic raised push-button.

```lua
local btn = Tab:AddButton({
    Text     = "Teleport to Spawn",
    Disabled = false,           -- optional: grey out the button
    Callback = function()
        -- called on click
    end,
})
```

**Control object methods:**

| Method | Description |
|--------|-------------|
| `btn:SetText(text)` | Updates the button label |
| `btn:SetDisabled(bool)` | Enable or disable the button |

---

### `AddToggle`

A labelled checkbox toggle.

```lua
local toggle = Tab:AddToggle({
    Text     = "God Mode",
    Default  = false,
    Callback = function(state)
        -- state: boolean
    end,
})
```

**Control object methods:**

| Method | Returns | Description |
|--------|---------|-------------|
| `toggle:Get()` | `boolean` | Current toggle state |
| `toggle:Set(bool)` | — | Set state and fire callback |

---

### `AddSlider`

A horizontal slider with a sunken track.

```lua
local slider = Tab:AddSlider({
    Text     = "Walk Speed",
    Min      = 8,
    Max      = 300,
    Default  = 16,
    Suffix   = " studs/s",   -- appended to the displayed value
    Decimals = 0,             -- decimal places (0 = integer)
    Callback = function(value)
        -- value: number
    end,
})
```

**Control object methods:**

| Method | Returns | Description |
|--------|---------|-------------|
| `slider:Get()` | `number` | Current value |
| `slider:Set(number)` | — | Jump to value and fire callback |

---

### `AddDropdown`

A combobox with a scrollable option list (scrolls when > 6 items).

```lua
local dropdown = Tab:AddDropdown({
    Text     = "Game Mode",
    Options  = { "Normal", "Hardcore", "Sandbox" },
    Default  = "Normal",
    Callback = function(selected)
        -- selected: string
    end,
})
```

**Control object methods:**

| Method | Returns | Description |
|--------|---------|-------------|
| `dropdown:Get()` | `string` | Currently selected option |
| `dropdown:Set(string)` | — | Change selection and fire callback |
| `dropdown:Refresh(table)` | — | Replace the options list entirely |

---

### `AddTextbox`

A single-line text input.

```lua
local textbox = Tab:AddTextbox({
    Text        = "Player Name",
    Default     = "",
    Placeholder = "Enter a username…",
    EnterOnly   = true,   -- only fires callback when Enter is pressed
    Callback    = function(text)
        -- text: string
    end,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `EnterOnly` | `boolean` | `false` | `true` → callback fires on Enter; `false` → fires on every keystroke |

**Control object methods:**

| Method | Returns | Description |
|--------|---------|-------------|
| `textbox:Get()` | `string` | Current text content |
| `textbox:Set(string)` | — | Set text programmatically |

---

### `AddKeybind`

A click-to-rebind keybind row. Click the button, then press any key to rebind.

```lua
local kb = Tab:AddKeybind({
    Text     = "Toggle Noclip",
    Default  = Enum.KeyCode.V,
    Callback = function()
        -- fires when the bound key is pressed
    end,
})
```

**Control object methods:**

| Method | Returns | Description |
|--------|---------|-------------|
| `kb:Get()` | `Enum.KeyCode` | Current bound key |
| `kb:Set(Enum.KeyCode)` | — | Change the bound key |

---

### `AddColorPicker`

An expandable RGB color picker (click the color swatch to open three channel sliders).

```lua
local cp = Tab:AddColorPicker({
    Text     = "Beam Color",
    Default  = Color3.fromRGB(255, 100, 0),
    Callback = function(color)
        -- color: Color3
    end,
})
```

**Control object methods:**

| Method | Returns | Description |
|--------|---------|-------------|
| `cp:Get()` | `Color3` | Current color |
| `cp:Set(Color3)` | — | Set color and fire callback |

---

### `AddLabel`

A plain text label. Supports word-wrap.

```lua
local lbl = Tab:AddLabel("Walk speed is currently 16 studs/s.")
```

**Control object methods:**

| Method | Description |
|--------|-------------|
| `lbl:Set(string)` | Update the label text at runtime |
| `lbl:Get()` | Returns current text |

---

### `AddSection`

A bold blue section heading with an etched double-rule beneath it. Purely decorative — no return value.

```lua
Tab:AddSection("Player Settings")
```

---

### `AddSeparator`

A thin etched horizontal divider line. Purely decorative — no return value.

```lua
Tab:AddSeparator()
```

---

## 5. Notify

`Window:Notify(config)` supports four visual types. Each applies a different accent colour to the title bar strip, left edge, and countdown bar:

| Type | Colour |
|------|--------|
| `"Info"` | Dark blue (XP default) |
| `"Success"` | Green |
| `"Warning"` | Amber |
| `"Error"` | Red |

Multiple notifications stack vertically above each other and dismiss themselves after `Duration` seconds. The user can also close any notification early with the `✕` button.

---

## 6. Theme Customisation

Call `WinXP:SetTheme(overrides)` **before** the first `CreateWindow` call. You only need to supply the keys you want to change.

```lua
-- Dark / hacker theme example
WinXP:SetTheme({
    TitleGradLeft  = Color3.fromRGB(0,  0,  0),
    TitleGradRight = Color3.fromRGB(0,  60, 0),
    TitleText      = Color3.fromRGB(0,  255, 80),
    TitleShadow    = Color3.fromRGB(0,  80, 0),
    WindowOutline  = Color3.fromRGB(0,  255, 80),
    WindowBody     = Color3.fromRGB(18, 18, 18),
    ButtonFace     = Color3.fromRGB(30, 30, 30),
    ButtonText     = Color3.fromRGB(0,  255, 80),
    LabelText      = Color3.fromRGB(200, 200, 200),
    SectionText    = Color3.fromRGB(0,  200, 60),
    SectionLine    = Color3.fromRGB(0,  100, 30),
    TabActive      = Color3.fromRGB(18, 18, 18),
    TabInactive    = Color3.fromRGB(12, 12, 12),
    TabText        = Color3.fromRGB(180, 180, 180),
    InputBg        = Color3.fromRGB(10, 10, 10),
    InputText      = Color3.fromRGB(0,  255, 80),
    SliderFill     = Color3.fromRGB(0,  200, 60),
    NotifBg        = Color3.fromRGB(18, 18, 18),
    NotifText      = Color3.fromRGB(200, 200, 200),
})
```

---

## 7. Theme Keys Reference

| Key | Applies To |
|-----|-----------|
| `TitleGradLeft` | Title bar gradient (left / start colour) |
| `TitleGradRight` | Title bar gradient (right / end colour) |
| `TitleText` | Title bar text |
| `TitleShadow` | Title bar text drop-shadow |
| `WindowOutline` | 1-pixel outer frame / border colour |
| `WindowBody` | Window background fill |
| `BorderBright` | Outermost highlight of raised edges |
| `BorderLight` | Inner highlight of raised edges |
| `BorderDark` | Inner shadow of raised edges |
| `BorderDarker` | Outermost shadow of raised edges |
| `ButtonFace` | Button background |
| `ButtonText` | Button label colour |
| `ButtonHover` | Button background on mouse hover |
| `ButtonPressed` | Button background while held down |
| `CtrlBlue` | Minimize / Maximize button base colour |
| `CtrlBlueLight` | Minimize / Maximize button gradient end |
| `CtrlRed` | Close button base colour |
| `CtrlRedLight` | Close button gradient end |
| `TabActive` | Active tab background |
| `TabInactive` | Inactive tab background |
| `TabText` | Tab label colour |
| `TabBorder` | Tab separator line colour |
| `InputBg` | Textbox / slider track / dropdown background |
| `InputText` | Textbox entered text colour |
| `InputPlaceholder` | Textbox placeholder text colour |
| `SliderTrack` | Slider track fill background |
| `SliderFill` | Slider fill / progress colour |
| `CheckBg` | Checkbox inner background |
| `CheckMark` | Checkbox tick mark colour |
| `SectionText` | Section heading text colour |
| `SectionLine` | Section ruling line (dark stripe) |
| `LabelText` | Plain label text |
| `DropBg` | Dropdown list background |
| `DropHover` | Dropdown item highlight background |
| `DropText` | Dropdown item text |
| `DropHoverText` | Dropdown item text (highlighted) |
| `ScrollThumb` | Scrollbar thumb colour |
| `ScrollBg` | Scrollbar track background |
| `NotifBg` | Notification body background |
| `NotifText` | Notification message text |

---

*End of WinXP UI API Reference.*
