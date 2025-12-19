shared.Moonshine = {
    Core = {
        Intro = {
            Blur = true,
            Enabled = true,
            Sound = true,
            Ver = "0.0.2",
        },
    },

    Visuals = {
        FOV = {
            Silent = {
                Visible = true,
                Transparency = 1,
                Thickness = 1,
                Color = Color3.fromRGB(72, 0, 255),
                Radius = 120,
                VisualizeClosest = false,
                Dynamic = false,
                Ranges = { Close = 55, CloseDist = 15, Mid = 34, MidDist = 30, Far = 15 },
            },
            Aimbot = {
                Visible = false,
                Transparency = 1,
                Thickness = 1,
                Color = Color3.fromRGB(111, 111, 11),
                Radius = 70,
            },
        },
        TargetESP = {
            Enabled = true,
            Key = "N",
            Text = "DisplayName", -- [[ Name, DisplayName,]]
            TextSize = 14,
            MinBox = 14,
            Line = { Thick = 1.2, Color = Color3.fromRGB(255, 255, 255) },
        },
    },

    Aim = {
        Silent = {
            Enabled = true,
            Type = "FOV", -- [[ FOV, Target ]]
            SyncCam = true, --Technically, silent target <3
            Predict = 0,
            HitPart = "UpperTorso",
            AirPart = "Head",
            Mode = "ClosestPart", -- [[ ClosestPart, ClosestPoint ]] use closestpart because point is kind of buggy
            PointScale = 100,
            Chance = 100,
            AirChance = 100,
            AntiViewer = true,  --//
        },
        Legit = {
            Enabled = true,
            Key = "C",
            Mode = "Hold", -- [[ Hold, Toggle ]]
            Smooth = 0.045,
            Predict = 0,
            Part = "UpperTorso",
            Closest = true,
            Notify = false,
            Offset = { Enabled = true, Jump = 1.7, Fall = 1 },
            AimbotOffsets = {
                Enabled = true,
                Jump = 1.7,
                Fall = 1,
            },
            Style = {
                Easing = "Circular", -- [[ Linear, Sine, Quad, Cubic, Exponential, Back, Bounce, Elastic, Quart, Quint, Circular ]]
                Direction = "InOut",  -- [[ In, Out, InOut ]]
            },
            MouseTP = {
                Enabled = true,
                Lerp = 0.045,
                Predict = 0.016334,
            },
        },
    },

    Trigger = {
        Enabled = true,
        Key = "T",
        Delay = 0.1,
        Notify = true,
        FFCheck = true,
        Blacklist = { "[Knife]" },
    },

    Hitbox = {
        Enabled = false,
        Visualize = false,
        Size = 15,
        Scale = { Enabled = false, X = 11, Y = 1, Z = 1 },
    },

    Movement = {
        Speed = {
            Enabled = true,
            Active = true,
            Method = "Humanoid", -- [[ Humanoid, CFrame ]]
            Toggle = true,
            Value = 169,
            Key = "Z",
        },
        Spin = {
            Enabled = true,
            Key = "M",
            Degrees = 360,
            Accel = 4900,
            Dir = "North",
            Smooth = 0.8,
        },
    },

    Misc = {
        Spread = { Enabled = true, Value = 100 },
        Checks = {
            KO = true,
            Visible = false,
            Grabbed = true,
            Crew = true,
            Friend = false,
            WallSilent = true,
            WallAimbot = true,
        },
    },
}
