---0.0.1
getgenv().Moonshine = {
	['Start'] = {
		['Options'] = { 
            ['IntroBlur'] = {['Active'] = true};
			['Intro'] = { ['Enabled'] = true, ['Use Sound'] = true, },
		},
		['Silent'] = {
			['Enabled'] = true,
			['Type'] = 'FOV', -- [[ FOV, Target ]]
            ['Syncwithcamera'] = true, --Technically, silent target <3
			['Prediction'] = 0,
			['Hitpart'] = 'UpperTorso',
			['AirPart'] = 'Head',
			['Mode'] = 'ClosestPoint', -- [[ ClosestPart, ClosestPoint ]]
            ["ClosestPointScale"] = 100,
			['HitChance'] = 100,
			['AirHitChance'] = 100,
			['Anti Aim Viewer'] = true,  --//dh and dashood only (temp)
			['FOV'] = {
				['Transparency'] = 1,
				['Visible'] = true,
				['Thickness'] = 1,
				['Color'] = Color3.fromRGB(72, 0, 255),
				['Radius'] = 120,
                ['VisualizeClosestMode'] = false,
			},
		},
		['AimbotOffsets'] = { 
			['Enabled'] = true, 
			['Jump'] = 1.7, 
			['Fall'] = 1
		},
		['Aimbot'] = {
			['Enabled'] = true,
			['Keybind'] = 'C',
            ['Mode'] = 'Hold', -- [[ Hold, Toggle ]]
			['Smoothness'] = 0.045,
			['Prediction'] = 0,
			['Hitpart'] = 'UpperTorso',
			['ClosestPart'] = true,
			['Notification'] = false,
			['FOV'] = {
				['Transparency'] = 1,
				['Visible'] = false,
				['Thickness'] = 1,
				['Color'] = Color3.fromRGB(111, 111, 11),
				['Radius'] = 70,
			},
		},
		['Style'] = {             
			['Easing'] = 'Circular', -- [[ Linear, Sine, Quad, Cubic, Exponential, Back, Bounce, Elastic, Quart, Quint, Circular ]]
			['Direction'] = 'InOut'  -- [[ In, Out, InOut ]]
		},
		['HitboxExpander'] = {
			['Enabled'] = false,
			['Visualize'] = false,
			['NormalSize'] = 15, 

			['Scaling'] = { ['Enabled'] = false, ['X'] = 11, ['Y'] = 1, ['Z'] = 1 },
		},
		['MouseTp'] = {
			['Enabled'] = true,
			['LerpValues'] = 0.045,
			['MousePrediction'] = 0.016334
		},
		['TriggerBot'] = {
			['Enabled'] = true,
			['Keybind'] = 'T',
			['Delay'] = 0.1, 
            ['ForceFieldCheck'] = true,
			['Notification'] = true,
			['Blacklisted'] = {

			"[Knife]"

			},
		},
		["Misc"] = {
			['Spread Modifier'] = {
				['Enabled'] = true,
				['Value'] = 100, 
			},

			['Spin'] = {
				['Enabled'] = true,
				['Keybind'] = 'M',
				['Degrees'] = 360,
				['Acceleration'] = 4900,
				['Directions'] = 'North',
				['Smoothness'] = 1,
			},
            ['WalkSpeed'] = {
                ['Enabled'] = true,          
                ['Active'] = true,
                ['Mode'] = 'Humanoid', -- [[ Humanoid, CFrame ]]
                ['Control'] = 'Toggle',
                ['Speed'] = 169,
                ['Keybind'] = 'Z',
            },
			['Checks'] = {
				['KO'] = true,
				['Visible'] = false,
				['Grabbed'] = true,
                ['Crew'] = true,
                ['FriendCheck'] = false,
                ['WallcheckSilent'] = true,
                ['WallcheckAimbot'] = true
			},
            ['TargetEsp'] = {
				['Enabled'] = true,
                ['Text'] = 'DisplayName', -- [[ Name, DisplayName,]]
                ['Keybind'] = 'N',
                ['LineThickness'] = 1.2,
                ['LineColor'] = Color3.fromRGB(255, 255, 255),
                ['TextSize'] = 14,
                ['MinBoxSize'] = 14,
			},
		},
	},
}
