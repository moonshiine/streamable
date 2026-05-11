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

## 5. Example

### simple esp

```lua
local API = getgenv().MoonshineAPI
while not API do task.wait(1) API = getgenv().MoonshineAPI end

local Library = API.UI.Library
local VisualsPage = API.UI.Pages.Visuals

local Config = {
    Enabled = false,
    MaxDistance = 2500,
    TeamCheck = false,
    
    Boxes = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxFill = false,
    BoxFillColor = Color3.fromRGB(255, 255, 255),
    BoxFillAlpha = 0.2,
    
    HealthBar = false,
    
    Names = false,
    NameColor = Color3.fromRGB(255, 255, 255),
    Distance = false,
    DistanceColor = Color3.fromRGB(200, 200, 200),
    Weapon = false,
    WeaponColor = Color3.fromRGB(255, 200, 100),
    
    Tracers = false,
    TracerColor = Color3.fromRGB(255, 255, 255),
    TracerOrigin = "Bottom"
}

local ESPSection = VisualsPage:Section({Name = "Advanced Manual ESP", Side = 2})

ESPSection:Toggle({Name = "Enable Master Switch", Flag = "AdvESP_Master", Default = false, Callback = function(v) Config.Enabled = v end})
ESPSection:Slider({Name = "Max Distance", Flag = "AdvESP_Dist", Min = 0, Max = 5000, Default = 2500, Suffix = "s", Callback = function(v) Config.MaxDistance = v end})
ESPSection:Toggle({Name = "Team Check", Flag = "AdvESP_Team", Default = false, Callback = function(v) Config.TeamCheck = v end})

ESPSection:Divider()

ESPSection:Toggle({Name = "Show Boxes", Flag = "AdvESP_Box", Default = false, Callback = function(v) Config.Boxes = v end})
    :Colorpicker({Name = "Box Color", Flag = "AdvESP_BoxColor", Default = Config.BoxColor, Callback = function(c) Config.BoxColor = c end})

ESPSection:Toggle({Name = "Fill Boxes", Flag = "AdvESP_Fill", Default = false, Callback = function(v) Config.BoxFill = v end})
    :Colorpicker({Name = "Fill Color", Flag = "AdvESP_FillColor", Default = Config.BoxFillColor, Alpha = Config.BoxFillAlpha, Callback = function(c, a) Config.BoxFillColor = c; Config.BoxFillAlpha = a end})

ESPSection:Toggle({Name = "Health Bar", Flag = "AdvESP_Health", Default = false, Callback = function(v) Config.HealthBar = v end})

ESPSection:Divider()

ESPSection:Toggle({Name = "Show Names", Flag = "AdvESP_Names", Default = false, Callback = function(v) Config.Names = v end})
    :Colorpicker({Name = "Name Color", Flag = "AdvESP_NameColor", Default = Config.NameColor, Callback = function(c) Config.NameColor = c end})

ESPSection:Toggle({Name = "Show Distance", Flag = "AdvESP_Distance", Default = false, Callback = function(v) Config.Distance = v end})
    :Colorpicker({Name = "Distance Color", Flag = "AdvESP_DistColor", Default = Config.DistanceColor, Callback = function(c) Config.DistanceColor = c end})

ESPSection:Toggle({Name = "Show Weapon", Flag = "AdvESP_Weapon", Default = false, Callback = function(v) Config.Weapon = v end})
    :Colorpicker({Name = "Weapon Color", Flag = "AdvESP_WeapColor", Default = Config.WeaponColor, Callback = function(c) Config.WeaponColor = c end})

ESPSection:Divider()

ESPSection:Toggle({Name = "Show Tracers", Flag = "AdvESP_Tracers", Default = false, Callback = function(v) Config.Tracers = v end})
    :Colorpicker({Name = "Tracer Color", Flag = "AdvESP_TracColor", Default = Config.TracerColor, Callback = function(c) Config.TracerColor = c end})

ESPSection:Dropdown({Name = "Tracer Origin", Flag = "AdvESP_TracOrig", Items = {"Bottom", "Center", "Mouse"}, Default = "Bottom", Callback = function(v) Config.TracerOrigin = v end})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP_Cache = {}

local function CreateESP(player)
    local esp = {
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        BoxFill = Drawing.new("Square"),
        HealthOutline = Drawing.new("Square"),
        Health = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Weapon = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }

    esp.BoxOutline.Thickness = 3; esp.BoxOutline.Color = Color3.new(0,0,0); esp.BoxOutline.Filled = false
    esp.Box.Thickness = 1; esp.Box.Filled = false
    esp.BoxFill.Thickness = 1; esp.BoxFill.Filled = true
    
    esp.HealthOutline.Thickness = 1; esp.HealthOutline.Color = Color3.new(0,0,0); esp.HealthOutline.Filled = true
    esp.Health.Thickness = 1; esp.Health.Filled = true
    
    for _, textObj in pairs({esp.Name, esp.Distance, esp.Weapon}) do
        textObj.Center = true; textObj.Outline = true; textObj.Size = 13; textObj.Font = 2
    end
    
    esp.Tracer.Thickness = 1
    
    ESP_Cache[player] = esp
    return esp
end

local function RemoveESP(player)
    if ESP_Cache[player] then
        for _, drawing in pairs(ESP_Cache[player]) do
            drawing:Remove()
        end
        ESP_Cache[player] = nil
    end
end

local function UpdateVisibility(esp, state)
    for _, drawing in pairs(esp) do
        drawing.Visible = state
    end
end

RunService.RenderStepped:Connect(function()
    if not Config.Enabled then
        for _, esp in pairs(ESP_Cache) do UpdateVisibility(esp, false) end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local esp = ESP_Cache[player] or CreateESP(player)
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            local isValid = root and head and hum and hum.Health > 0
            if Config.TeamCheck and player.Team == LocalPlayer.Team then isValid = false end

            if isValid then
                local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                
                if onScreen and dist <= Config.MaxDistance then
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.6
                    local boxSize = Vector2.new(width, height)
                    local boxPos = Vector2.new(rootPos.X - width/2, headPos.Y)

                    if Config.Boxes then
                        esp.BoxOutline.Size = boxSize; esp.BoxOutline.Position = boxPos; esp.BoxOutline.Visible = true
                        esp.Box.Size = boxSize; esp.Box.Position = boxPos; esp.Box.Color = Config.BoxColor; esp.Box.Visible = true
                    else
                        esp.BoxOutline.Visible = false; esp.Box.Visible = false
                    end

                    if Config.BoxFill then
                        esp.BoxFill.Size = boxSize; esp.BoxFill.Position = boxPos
                        esp.BoxFill.Color = Config.BoxFillColor; esp.BoxFill.Transparency = Config.BoxFillAlpha
                        esp.BoxFill.Visible = true
                    else
                        esp.BoxFill.Visible = false
                    end

                    if Config.HealthBar then
                        local hpPct = hum.Health / hum.MaxHealth
                        local healthColor = Color3.fromRGB(255 - (hpPct * 255), hpPct * 255, 0)
                        
                        esp.HealthOutline.Size = Vector2.new(4, height + 2)
                        esp.HealthOutline.Position = Vector2.new(boxPos.X - 6, boxPos.Y - 1)
                        esp.HealthOutline.Visible = true

                        esp.Health.Size = Vector2.new(2, height * hpPct)
                        esp.Health.Position = Vector2.new(boxPos.X - 5, boxPos.Y + height - (height * hpPct))
                        esp.Health.Color = healthColor
                        esp.Health.Visible = true
                    else
                        esp.HealthOutline.Visible = false; esp.Health.Visible = false
                    end

                    local textOffset = 0
                    if Config.Names then
                        esp.Name.Text = player.Name
                        esp.Name.Position = Vector2.new(boxPos.X + width/2, boxPos.Y - 15)
                        esp.Name.Color = Config.NameColor
                        esp.Name.Visible = true
                    else
                        esp.Name.Visible = false
                    end

                    if Config.Distance then
                        esp.Distance.Text = math.floor(dist) .. "s"
                        esp.Distance.Position = Vector2.new(boxPos.X + width/2, boxPos.Y + height + 2 + textOffset)
                        esp.Distance.Color = Config.DistanceColor
                        esp.Distance.Visible = true
                        textOffset = textOffset + 13
                    else
                        esp.Distance.Visible = false
                    end

                    if Config.Weapon then
                        local tool = char:FindFirstChildOfClass("Tool")
                        esp.Weapon.Text = tool and tool.Name or "None"
                        esp.Weapon.Position = Vector2.new(boxPos.X + width/2, boxPos.Y + height + 2 + textOffset)
                        esp.Weapon.Color = Config.WeaponColor
                        esp.Weapon.Visible = true
                    else
                        esp.Weapon.Visible = false
                    end

                    if Config.Tracers then
                        local origin
                        if Config.TracerOrigin == "Bottom" then
                            origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        elseif Config.TracerOrigin == "Center" then
                            origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        elseif Config.TracerOrigin == "Mouse" then
                            origin = UserInputService:GetMouseLocation()
                        end

                        esp.Tracer.From = origin
                        esp.Tracer.To = Vector2.new(boxPos.X + width/2, boxPos.Y + height)
                        esp.Tracer.Color = Config.TracerColor
                        esp.Tracer.Visible = true
                    else
                        esp.Tracer.Visible = false
                    end

                else
                    UpdateVisibility(esp, false)
                end
            else
                UpdateVisibility(esp, false)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

Library:Notification("Advanced ESP Addon Loaded!", 4, Color3.fromRGB(150, 0, 255))
```
