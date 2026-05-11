# Moonshine UI Documentation (Addon API)

This guide details all the methods available in `getgenv().MoonshineAPI.UI` to extend the Moonshine interface.

## 1. Accessing the API
First, ensure the API is loaded:
```lua
local API = getgenv().MoonshineAPI
while not API do task.wait(0.5) API = getgenv().MoonshineAPI end
```

---

## 2. Windows and Pages (Tabs)

### Creating a new Page (Tab)
If you don't want to use the existing tabs (`Combat`, `Visuals`, etc.), you can create your own in the main window.
```lua
local Window = API.UI.Library.Holder -- Reference to the main window
local MyPage = API.UI.Library:Page({
    Name = "My Tab",
    Columns = 2, -- 1 or 2 columns
    Subtabs = true -- Enable sub-tabs if desired
})
```

### Existing Pages
You can directly access the native pages:
* `API.UI.Pages.Combat`
* `API.UI.Pages.Visuals`
* `API.UI.Pages.Movement`
* `API.UI.Pages.Misc`
* `API.UI.Pages.Settings`

---

## 3. Sections and Sub-Tabs

### Creating a Sub-Tab (Only if the page has `Subtabs = true`)
```lua
local MySubPage = MyPage:SubPage({
    Name = "Sub Tab 1",
    Columns = 2 -- 1 or 2 columns
})
```

### Creating a Section
Sections are containers for buttons, toggles, and other controls.
```lua
local MySection = MyPage:Section({
    Name = "My Section",
    Side = 1 -- 1 for left side, 2 for right side
})
```

---

## 4. UI Elements (Controls)

All these methods are called from a **Section** object.

### Toggle
```lua
local Toggle = MySection:Toggle({
    Name = "Toggle Name",
    Flag = "MyPlugin_Toggle1", -- Unique identifier for configs
    Default = false,
    Callback = function(Value)
        print("Toggle is:", Value)
    end
})
```

### Slider
```lua
MySection:Slider({
    Name = "Speed",
    Flag = "MyPlugin_Slider1",
    Min = 0,
    Max = 100,
    Default = 50,
    Decimals = 1, -- Optional
    Suffix = " studs", -- Optional
    Compact = false, -- If true, moves the name inside the bar to save space
    Callback = function(Value)
        print("Slider is:", Value)
    end
})
```

### Dropdown
```lua
local MyDropdown = MySection:Dropdown({
    Name = "Select Mode",
    Flag = "MyPlugin_Drop1",
    Items = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Multi = false, -- true to allow multiple selections
    Callback = function(Value)
        print("Selected:", Value)
    end
})

-- Extra methods for Dropdowns:
-- MyDropdown:Add("New Option")
-- MyDropdown:Remove("Option 1")
-- MyDropdown:Refresh({"A", "B", "C"})
```

### Button
```lua
MySection:Button({
    Name = "Execute Action",
    Callback = function()
        print("Button pressed")
    end
})
```

### Textbox
```lua
MySection:Textbox({
    Name = "Username",
    Flag = "MyPlugin_Text1",
    Placeholder = "Type here...",
    Default = "",
    Callback = function(Value)
        print("Text entered:", Value)
    end
})
```

### Keybind
Keybinds can be added as standalone elements or chained to a Toggle.
```lua
-- Standalone
MySection:Keybind({
    Name = "Panic Key",
    Flag = "MyPlugin_Key1",
    Default = Enum.KeyCode.P,
    Callback = function(Key)
        print("Key pressed:", Key)
    end
})

-- Chained to a Toggle (Very common)
MySection:Toggle({Name = "Aimbot", ...}):Keybind({Default = Enum.KeyCode.F})
```

### Colorpicker
**IMPORTANT:** In this library, the Colorpicker must be chained to a Toggle or a Label.
```lua
MySection:Toggle({Name = "ESP Boxes", ...}):Colorpicker({
    Name = "Box Color",
    Flag = "MiPlugin_Color1",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        print("Color selected:", Color)
    end
})
```

### Listbox
A list of items that is always visible (not a dropdown).
```lua
MySection:Listbox({
    Name = "Players List",
    Flag = "MyPlugin_List1",
    Items = {"Player1", "Player2"},
    Size = 150, -- Height in pixels
    Multi = false,
    Callback = function(Value) end
})
```

### Label and Divider
```lua
MySection:Label({Name = "Important information"})
MySection:Divider() -- A horizontal separator line
```

---

## 5. Extra Utilities

### Notifications
```lua
API.UI.Library:Notification("Plugin loaded successfully!", 5, Color3.fromRGB(0, 255, 0))
```

### Watermark
```lua
local Watermark = API.UI.Library:Watermark("Moonshine Addon System")
Watermark:SetVisibility(true)
```
