# Moonshine GUI - Custom Support API Documentation

The **Custom Support API** allows developers or Moonshine GUI users to integrate custom configurations for games that are not in the official database. This is achieved by injecting the configuration locally before executing the main script.

This prevents the main script from downloading the cloud configuration and depending on an external connection.

---

## 🔥 Quick Start

To use the custom support system, you simply need to define the `CustomSupportEnable` environment variable and provide a Lua table in `CustomSupport`, **before executing Moonshine GUI**.

```lua
-- 1. Enable Custom Support mode
getgenv().CustomSupportEnable = true

-- 2. Declare the game configuration table
getgenv().CustomSupport = {
    namegame = "Da Hood",
    RemoteName = "MainEvent",
    RemoteParent = "ReplicatedStorage",
    ArgName = "UpdateMousePosI2",
    UseOldSystem = false,
    NeedAimviewer = true,
    Adonis = false
}

-- 3. The Moonshine GUI loadstring or main script goes here
-- loadstring(game:HttpGet("..."))()
```

---

## ⚙️ `CustomSupport` Table Parameters

Below is a detailed list of every expected option inside the `getgenv().CustomSupport` table.

| Parameter | Type | Description | Example |
|:---:|:---:|---|:---:|
| `namegame` | `string` | **Required.** Internal name given to the current game within the script. Some special functions (like bypasses) trigger if this name matches a specific one (e.g. `"flame hood"`, `"dea hood"`, `"das hood"`, etc). | `"Da Hood"` |
| `RemoteName` | `string` | **Required.** The name of the `RemoteEvent` the game uses to fire / pass the mouse position to the server. | `"MainEvent"` |
| `RemoteParent` | `string` | **Required.** Indicates the main location where the Remote is usually hosted (for example: `"ReplicatedStorage"` or `"workspace"`). | `"ReplicatedStorage"` |
| `ArgName` | `string` | **Required.** The key, Action (or Identifier) that goes inside the firing RemoteEvent parameters when shooting Silent Aim/Anti-Aim to the server. | `"UpdateMousePosI2"` |
| `UseOldSystem` | `boolean` | Determines if the aim prediction or calculation system will use legacy methods. Usually left as `false`. | `false` |
| `NeedAimviewer` | `boolean` | Indicates if the game requires specific "Aim Viewer" bypasses. | `true` |
| `Adonis` | `boolean` | If set to `true`, Moonshine GUI will inject a secondary script to bypass the Adonis Anti-Cheat. Useful for Da Hood copies with high security. | `false` |

---

## 🛠️ Practical Examples
```lua
getgenv().CustomSupportEnable = true
getgenv().CustomSupport = {
    namegame = "Da Hood",
    RemoteName = "MainEvent",
    RemoteParent = "ReplicatedStorage",
    ArgName = "UpdateMousePosI2",
    UseOldSystem = false, --mouse.hit
    NeedAimviewer = false, 
    Adonis = false
}
```

```lua
getgenv().CustomSupportEnable = true
getgenv().CustomSupport = {
    namegame = "Flame Hood (Custom)",
    RemoteName = "MainRemoteEvent",
    RemoteParent = "ReplicatedStorage",
    ArgName = "UpdateAim",
    UseOldSystem = true, --//"fireserver 
    NeedAimviewer = true,
    Adonis = true
}
```

---

## ⚠️ Warnings & Troubleshooting

1. **Execution Order**: The environment (`getgenv()`) must be set **strictly before** the heavy script (`guiver.lua` or the Moonshine loadstring). If done after, Moonshine will download and default to invalidating your custom script by using the external JSON PlaceId.
2. **Lua vs JSON Syntax**: Remember that the `getgenv().CustomSupport` table uses **Lua table syntax**. This means string keys don't require quotes (e.g. `namegame = "Name"` instead of `"namegame": "Name"`), and assignments are made with an equal sign (`=`) instead of a colon (`:`).
3. **Case Sensitivity**: Make sure booleans are lowercase `true` or `false`. `True` or `False` will throw syntax errors in Lua.
