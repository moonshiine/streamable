
local module = {};

function module.loadAnimScript(originalScript)
	-- Configuración inicial basada en el nuevo script
	getfenv().script = originalScript
	local Character = script.Parent
	local Humanoid = Character:WaitForChild("Humanoid")
	
	-- Variables de estado (mapeadas a u1, u2, etc. del nuevo script)
	local pose = "Standing" -- u1
	local currentAnimName = "" -- u2
	local currentAnimInstance = nil -- u3
	local currentAnimTrack = nil -- u4
	local currentAnimKeyframeHandler = nil -- u5
	local currentAnimSpeed = 1.0 -- u6
	local runAnimTrack = nil -- u7
	local runAnimKeyframeHandler = nil -- u8
	
	local PreloadedAnims = {} -- u9
	local animTable = {} -- u10
	
	-- Feature Flags
	local success, removeEmoteChatHook = pcall(function() return UserSettings():IsUserFeatureEnabled("UserAnimateRemoveEmoteChatHook") end)
	local useChatEmotes = not (success and removeEmoteChatHook)
	
	local success2, useAbilityManager = pcall(function() return UserSettings():IsUserFeatureEnabled("UserAnimationAbilityManagerFixed") end)
	local useControllerManager = success2 and useAbilityManager

	-- Configuración de escala
	local AnimationSpeedDampeningObject = script:FindFirstChild("ScaleDampeningPercent")
	local HumanoidHipHeight = 2
	
	-- Helper para obtener escala (nuevo método getRigScale con protección)
	local function getRigScale()
		local success, scale = pcall(function() return Character:GetScale() end)
		return success and scale or 1
	end

	-- Tablas de animaciones (u11 y u12)
	local animNames = { 
		idle = 	{	
					{ id = "http://www.roblox.com/asset/?id=507766666", weight = 1 },
					{ id = "http://www.roblox.com/asset/?id=507766951", weight = 1 },
					{ id = "http://www.roblox.com/asset/?id=507766388", weight = 9 }
				},
		walk = 	{ 	
					{ id = "http://www.roblox.com/asset/?id=507777826", weight = 10 } 
				}, 
		run = 	{
					{ id = "http://www.roblox.com/asset/?id=507767714", weight = 10 } 
				}, 
		swim = 	{
					{ id = "http://www.roblox.com/asset/?id=507784897", weight = 10 } 
				}, 
		swimidle = 	{
					{ id = "http://www.roblox.com/asset/?id=507785072", weight = 10 } 
				}, 
		jump = 	{
					{ id = "http://www.roblox.com/asset/?id=507765000", weight = 10 } 
				}, 
		fall = 	{
					{ id = "http://www.roblox.com/asset/?id=507767968", weight = 10 } 
				}, 
		climb = {
					{ id = "http://www.roblox.com/asset/?id=507765644", weight = 10 } 
				}, 
		sit = 	{
					{ id = "http://www.roblox.com/asset/?id=2506281703", weight = 10 } 
				},	
		toolnone = {
					{ id = "http://www.roblox.com/asset/?id=507768375", weight = 10 } 
				},
		toolslash = {
					{ id = "http://www.roblox.com/asset/?id=522635514", weight = 10 } 
				},
		toollunge = {
					{ id = "http://www.roblox.com/asset/?id=522638767", weight = 10 } 
				},
		wave = {
					{ id = "http://www.roblox.com/asset/?id=507770239", weight = 10 } 
				},
		point = {
					{ id = "http://www.roblox.com/asset/?id=507770453", weight = 10 } 
				},
		dance = {
					{ id = "http://www.roblox.com/asset/?id=507771019", weight = 10 }, 
					{ id = "http://www.roblox.com/asset/?id=507771955", weight = 10 }, 
					{ id = "http://www.roblox.com/asset/?id=507772104", weight = 10 } 
				},
		dance2 = {
					{ id = "http://www.roblox.com/asset/?id=507776043", weight = 10 }, 
					{ id = "http://www.roblox.com/asset/?id=507776720", weight = 10 }, 
					{ id = "http://www.roblox.com/asset/?id=507776879", weight = 10 } 
				},
		dance3 = {
					{ id = "http://www.roblox.com/asset/?id=507777268", weight = 10 }, 
					{ id = "http://www.roblox.com/asset/?id=507777451", weight = 10 }, 
					{ id = "http://www.roblox.com/asset/?id=507777623", weight = 10 } 
				},
		laugh = {
					{ id = "http://www.roblox.com/asset/?id=507770818", weight = 10 } 
				},
		cheer = {
					{ id = "http://www.roblox.com/asset/?id=507770677", weight = 10 } 
				},
	}

	local emoteNames = { wave = false, point = false, dance = true, dance2 = true, dance3 = true, laugh = false, cheer = false}

	math.randomseed(tick())

	-- Controller Manager Logic (Nuevo en 2024+)
	local controllerManager = nil
	local groundSensor = nil
	local managerConnections = {}

	local function resetManagerListeners()
		for _, conn in pairs(managerConnections) do
			conn:Disconnect()
		end
		managerConnections = {}
	end

	local function setupManager(manager)
		controllerManager = manager
		groundSensor = manager.GroundSensor
		
		resetManagerListeners()
		
		table.insert(managerConnections, manager:GetPropertyChangedSignal("GroundSensor"):Connect(function()
			if controllerManager then
				groundSensor = controllerManager.GroundSensor
			end
		end))
		
		table.insert(managerConnections, manager:GetPropertyChangedSignal("RootPart"):Connect(function()
			if controllerManager and controllerManager.RootPart ~= Character.PrimaryPart then
				resetManagerListeners()
				controllerManager = nil
				lookForControllerManager()
			end
		end))
		
		table.insert(managerConnections, manager.AncestryChanged:Connect(function(_, parent)
			if parent == nil then
				resetManagerListeners()
				controllerManager = nil
				lookForControllerManager()
			end
		end))
	end

	local function lookForControllerManager()
		if useControllerManager then
			local manager = Character:FindFirstChildOfClass("ControllerManager")
			if manager then
				if manager.RootPart == Character.PrimaryPart then
					setupManager(manager)
				else
					local conn
					conn = manager:GetPropertyChangedSignal("RootPart"):Connect(function()
						if manager.RootPart == Character.PrimaryPart then
							conn:Disconnect()
							setupManager(manager)
						end
					end)
				end
			else
				local conn
				conn = Character.ChildAdded:Connect(function(child)
					if child:IsA("ControllerManager") then
						conn:Disconnect()
						lookForControllerManager()
					end
				end)
			end
		else
			controllerManager = nil
			groundSensor = nil
		end
	end

	lookForControllerManager()

	-- Funciones de Animación

	function findExistingAnimationInSet(set, anim)
		if set == nil or anim == nil then
			return 0
		end
		for idx = 1, set.count, 1 do 
			if set[idx].anim.AnimationId == anim.AnimationId then
				return idx
			end
		end
		return 0
	end

	function configureAnimationSet(name, fileList)
		if (animTable[name] ~= nil) then
			for _, connection in pairs(animTable[name].connections) do
				connection:disconnect()
			end
		end
		animTable[name] = {}
		animTable[name].count = 0
		animTable[name].totalWeight = 0	
		animTable[name].connections = {}

		local allowCustomAnimations = true
		local success, msg = pcall(function() allowCustomAnimations = game:GetService("StarterPlayer").AllowCustomAnimations end)
		if not success then
			allowCustomAnimations = true
		end

		local config = script:FindFirstChild(name)
		if (allowCustomAnimations and config ~= nil) then
			table.insert(animTable[name].connections, config.ChildAdded:connect(function(child) configureAnimationSet(name, fileList) end))
			table.insert(animTable[name].connections, config.ChildRemoved:connect(function(child) configureAnimationSet(name, fileList) end))
			
			for _, childPart in pairs(config:GetChildren()) do
				if (childPart:IsA("Animation")) then
					local newWeight = 1
					local weightObject = childPart:FindFirstChild("Weight")
					if (weightObject ~= nil) then
						newWeight = weightObject.Value
					end
					animTable[name].count = animTable[name].count + 1
					local idx = animTable[name].count
					animTable[name][idx] = {}
					animTable[name][idx].anim = childPart
					animTable[name][idx].weight = newWeight
					animTable[name].totalWeight = animTable[name].totalWeight + animTable[name][idx].weight
					
					table.insert(animTable[name].connections, childPart.Changed:connect(function(property) configureAnimationSet(name, fileList) end))
					table.insert(animTable[name].connections, childPart.ChildAdded:connect(function(property) configureAnimationSet(name, fileList) end))
					table.insert(animTable[name].connections, childPart.ChildRemoved:connect(function(property) configureAnimationSet(name, fileList) end))
				end
			end
		end
		
		if (animTable[name].count <= 0) then
			for idx, anim in pairs(fileList) do
				animTable[name][idx] = {}
				animTable[name][idx].anim = Instance.new("Animation")
				animTable[name][idx].anim.Name = name
				animTable[name][idx].anim.AnimationId = anim.id
				animTable[name][idx].weight = anim.weight
				animTable[name].count = animTable[name].count + 1
				animTable[name].totalWeight = animTable[name].totalWeight + anim.weight
			end
		end
		
		for i, animType in pairs(animTable) do
			for idx = 1, animType.count, 1 do
				if PreloadedAnims[animType[idx].anim.AnimationId] == nil then
					Humanoid:LoadAnimation(animType[idx].anim)
					PreloadedAnims[animType[idx].anim.AnimationId] = true
				end				
			end
		end
	end

	function scriptChildModified(child)
		local fileList = animNames[child.Name]
		if (fileList ~= nil) then
			configureAnimationSet(child.Name, fileList)
		end	
	end

	script.ChildAdded:connect(scriptChildModified)
	script.ChildRemoved:connect(scriptChildModified)

	local animator = (Humanoid and Humanoid:FindFirstChildOfClass("Animator") or nil)
	if animator then
		local animTracks = animator:GetPlayingAnimationTracks()
		for i,track in ipairs(animTracks) do
			track:Stop(0)
			track:Destroy()
		end
	end

	for name, fileList in pairs(animNames) do 
		configureAnimationSet(name, fileList)
	end	

	local toolAnimName = "None"
	local toolAnimTime = 0
	local jumpAnimTime = 0
	local jumpAnimDuration = 0.31
	local currentlyPlayingEmote = false

	local toolAnimTrack = nil
	local toolAnimInstance = nil
	local currentToolAnimKeyframeHandler = nil

	function stopAllAnimations()
		local oldAnim = currentAnimName

		if (emoteNames[oldAnim] ~= nil and emoteNames[oldAnim] == false) then
			oldAnim = "idle"
		end
		
		if currentlyPlayingEmote then
			oldAnim = "idle"
			currentlyPlayingEmote = false
		end

		currentAnimName = ""
		currentAnimInstance = nil
		if (currentAnimKeyframeHandler ~= nil) then
			currentAnimKeyframeHandler:disconnect()
		end

		if (currentAnimTrack ~= nil) then
			currentAnimTrack:Stop()
			currentAnimTrack:Destroy()
			currentAnimTrack = nil
		end

		if (runAnimKeyframeHandler ~= nil) then
			runAnimKeyframeHandler:disconnect()
		end
		
		if (runAnimTrack ~= nil) then
			runAnimTrack:Stop()
			runAnimTrack:Destroy()
			runAnimTrack = nil
		end
		
		return oldAnim
	end

	function getHeightScale()
		if not Humanoid then
			return getRigScale()
		end

		if not Humanoid.AutomaticScalingEnabled then
			return getRigScale()
		end
		
		local scale = Humanoid.HipHeight / HumanoidHipHeight
		if AnimationSpeedDampeningObject == nil then
			AnimationSpeedDampeningObject = script:FindFirstChild("ScaleDampeningPercent")
		end
		if AnimationSpeedDampeningObject ~= nil then
			scale = 1 + (Humanoid.HipHeight - HumanoidHipHeight) * AnimationSpeedDampeningObject.Value / HumanoidHipHeight
		end
		return scale
	end

	local function rootMotionCompensation(speed)
		return speed * 1.25 / getHeightScale()
	end

	local smallButNotZero = 0.0001
	
	local function setRunSpeed(speed)
		local runSpeed = rootMotionCompensation(speed)
		
		local walkAnimationWeight = smallButNotZero
		local runAnimationWeight = smallButNotZero
		local speedScale = 1

		if runSpeed <= 0.5 then
			speedScale = runSpeed / 0.5
			walkAnimationWeight = 1
		elseif runSpeed < 1 then
			runAnimationWeight = (runSpeed - 0.5) / 0.5
			walkAnimationWeight = 1 - runAnimationWeight
		else
			speedScale = runSpeed / 1
			runAnimationWeight = 1
		end

		if currentAnimTrack then
			currentAnimTrack:AdjustWeight(walkAnimationWeight)
			currentAnimTrack:AdjustSpeed(speedScale)
		end
		
		if runAnimTrack then
			runAnimTrack:AdjustWeight(runAnimationWeight)
			runAnimTrack:AdjustSpeed(speedScale)
		end
	end

	function setAnimationSpeed(speed)
		if currentAnimName == "walk" then
				setRunSpeed(speed)
		else
			if speed ~= currentAnimSpeed then
				currentAnimSpeed = speed
				if currentAnimTrack then
					currentAnimTrack:AdjustSpeed(currentAnimSpeed)
				end
			end
		end
	end

	function keyFrameReachedFunc(frameName)
		if (frameName == "End") then
			if currentAnimName == "walk" then
				if runAnimTrack and runAnimTrack.Looped ~= true then
					runAnimTrack.TimePosition = 0.0
				end
				if currentAnimTrack and currentAnimTrack.Looped ~= true then
					currentAnimTrack.TimePosition = 0.0
				end
			else
				local repeatAnim = currentAnimName
				if (emoteNames[repeatAnim] ~= nil and emoteNames[repeatAnim] == false) then
					repeatAnim = "idle"
				end
				
				if currentlyPlayingEmote then
					if currentAnimTrack and currentAnimTrack.Looped then
						return
					end
					
					repeatAnim = "idle"
					currentlyPlayingEmote = false
				end
				
				local animSpeed = currentAnimSpeed
				playAnimation(repeatAnim, 0.15, Humanoid)
				setAnimationSpeed(animSpeed)
			end
		end
	end

	function rollAnimation(animName)
		local roll = math.random(1, animTable[animName].totalWeight) 
		local idx = 1
		while (roll > animTable[animName][idx].weight) do
			roll = roll - animTable[animName][idx].weight
			idx = idx + 1
		end
		return idx
	end

	local function switchToAnim(anim, animName, transitionTime, humanoid)
		if (anim ~= currentAnimInstance) then
			
			if (currentAnimTrack ~= nil) then
				currentAnimTrack:Stop(transitionTime)
				currentAnimTrack:Destroy()
			end

			if (runAnimTrack ~= nil) then
				runAnimTrack:Stop(transitionTime)
				runAnimTrack:Destroy()
				runAnimTrack = nil
			end

			currentAnimSpeed = 1.0
		
			currentAnimTrack = humanoid:LoadAnimation(anim)
			currentAnimTrack.Priority = Enum.AnimationPriority.Core
			 
			currentAnimTrack:Play(transitionTime)
			currentAnimName = animName
			currentAnimInstance = anim

			if (currentAnimKeyframeHandler ~= nil) then
				currentAnimKeyframeHandler:disconnect()
			end
			currentAnimKeyframeHandler = currentAnimTrack.KeyframeReached:connect(keyFrameReachedFunc)
			
			if animName == "walk" then
				local runIdx = rollAnimation("run")
				runAnimTrack = humanoid:LoadAnimation(animTable["run"][runIdx].anim)
				runAnimTrack.Priority = Enum.AnimationPriority.Core
				runAnimTrack:Play(transitionTime)		
				
				if (runAnimKeyframeHandler ~= nil) then
					runAnimKeyframeHandler:disconnect()
				end
				runAnimKeyframeHandler = runAnimTrack.KeyframeReached:connect(keyFrameReachedFunc)	
			end
		end
	end

	function playAnimation(animName, transitionTime, humanoid) 	
		local idx = rollAnimation(animName)
		local anim = animTable[animName][idx].anim
		switchToAnim(anim, animName, transitionTime, humanoid)
		currentlyPlayingEmote = false
	end

	function playEmote(emoteAnim, transitionTime, humanoid)
		switchToAnim(emoteAnim, emoteAnim.Name, transitionTime, humanoid)
		currentlyPlayingEmote = true
	end

	function toolKeyFrameReachedFunc(frameName)
		if (frameName == "End") then
			playToolAnimation(toolAnimName, 0.0, Humanoid)
		end
	end

	function playToolAnimation(animName, transitionTime, humanoid, priority)	 		
			local idx = rollAnimation(animName)
			local anim = animTable[animName][idx].anim

			if (toolAnimInstance ~= anim) then
				
				if (toolAnimTrack ~= nil) then
					toolAnimTrack:Stop()
					toolAnimTrack:Destroy()
					transitionTime = 0
				end
						
				toolAnimTrack = humanoid:LoadAnimation(anim)
				if priority then
					toolAnimTrack.Priority = priority
				end
				 
				toolAnimTrack:Play(transitionTime)
				toolAnimName = animName
				toolAnimInstance = anim

				currentToolAnimKeyframeHandler = toolAnimTrack.KeyframeReached:connect(toolKeyFrameReachedFunc)
			end
	end

	function stopToolAnimations()
		local oldAnim = toolAnimName

		if (currentToolAnimKeyframeHandler ~= nil) then
			currentToolAnimKeyframeHandler:disconnect()
		end

		toolAnimName = ""
		toolAnimInstance = nil
		if (toolAnimTrack ~= nil) then
			toolAnimTrack:Stop()
			toolAnimTrack:Destroy()
			toolAnimTrack = nil
		end

		return oldAnim
	end

	function onRunning(speed)
		local heightScale = getHeightScale()
		
		-- Protegido contra errores si EvaluateStateMachine no existe en la versión de Roblox
		local evalSM = Humanoid.EvaluateStateMachine
		if evalSM == nil then evalSM = true end

		if groundSensor and evalSM == false then
			local RootPart = Humanoid.RootPart
			local SensedPart = groundSensor.SensedPart

			if SensedPart then
				local HitFrame = groundSensor:FindFirstChild("HitFrame")
				if HitFrame then
					local VelocityAtPosition = SensedPart:GetVelocityAtPosition(HitFrame.Position)
					local AssemblyLinearVelocity = RootPart.AssemblyLinearVelocity
					local Magnitude = Vector3.new(AssemblyLinearVelocity.X - VelocityAtPosition.X, 0, AssemblyLinearVelocity.Z - VelocityAtPosition.Z).Magnitude
					
					-- Protegido: ControllerManager.MovingDirection puede no existir en todos los rigs
					local moveDir = controllerManager and controllerManager.MovingDirection or Humanoid.MoveDirection
					local MoveDirMag = moveDir and moveDir.Magnitude or 0

					if MoveDirMag < 0.1 then
						Magnitude = 0
						MoveDirMag = 0
					elseif MoveDirMag > 1 then
						MoveDirMag = 1
					end

					speed = Magnitude * MoveDirMag
				end
			end
		end

		local threshold = 0.75
		if currentlyPlayingEmote and Humanoid.MoveDirection == Vector3.new(0, 0, 0) then
			threshold = (Humanoid.WalkSpeed / heightScale) or 0.75
		end
		
		local effectiveSpeed = speed
		
		if effectiveSpeed > threshold * heightScale then
			playAnimation("walk", 0.2, Humanoid)
			setAnimationSpeed(effectiveSpeed / 16)
			pose = "Running"
		else
			if emoteNames[currentAnimName] == nil and not currentlyPlayingEmote then
				playAnimation("idle", 0.2, Humanoid)
				pose = "Standing"
			end
		end
	end

	function onDied()
		pose = "Dead"
	end

	function onJumping()
		playAnimation("jump", 0.1, Humanoid)
		jumpAnimTime = jumpAnimDuration
		pose = "Jumping"
	end

	function onClimbing(speed)
		local scale = 5.0
		playAnimation("climb", 0.1, Humanoid)
		setAnimationSpeed(speed / scale)
		pose = "Climbing"
	end

	function onGettingUp()
		pose = "GettingUp"
	end

	function onFreeFall()
		if (jumpAnimTime <= 0) then
			playAnimation("fall", 0.2, Humanoid)
		end
		pose = "FreeFall"
	end

	function onFallingDown()
		pose = "FallingDown"
	end

	function onSeated()
		pose = "Seated"
	end

	function onPlatformStanding()
		pose = "PlatformStanding"
	end

	function onSwimming(speed)
		local scaledSpeed = speed / getHeightScale()
		if scaledSpeed > 1.00 then
			local scale = 10.0
			playAnimation("swim", 0.4, Humanoid)
			setAnimationSpeed(scaledSpeed / scale)
			pose = "Swimming"
		else
			playAnimation("swimidle", 0.4, Humanoid)
			pose = "Standing"
		end
	end

	function animateTool()
		if (toolAnimName == "None") then
			playToolAnimation("toolnone", 0.1, Humanoid, Enum.AnimationPriority.Idle)
			return
		end

		if (toolAnimName == "Slash") then
			playToolAnimation("toolslash", 0, Humanoid, Enum.AnimationPriority.Action)
			return
		end

		if (toolAnimName == "Lunge") then
			playToolAnimation("toollunge", 0, Humanoid, Enum.AnimationPriority.Action)
			return
		end
	end

	function getToolAnim(tool)
		for _, c in ipairs(tool:GetChildren()) do
			if c.Name == "toolanim" and c.className == "StringValue" then
				return c
			end
		end
		return nil
	end

	local lastTick = 0

	function stepAnimate(currentTime)
		local deltaTime = currentTime - lastTick
		lastTick = currentTime

		if (jumpAnimTime > 0) then
			jumpAnimTime = jumpAnimTime - deltaTime
		end

		if (pose == "FreeFall" and jumpAnimTime <= 0) then
			playAnimation("fall", 0.2, Humanoid)
		elseif (pose == "Seated") then
			playAnimation("sit", 0.5, Humanoid)
			return
		elseif (pose == "Running") then
			playAnimation("walk", 0.2, Humanoid)
		elseif (pose == "Dead" or pose == "GettingUp" or pose == "FallingDown" or pose == "Seated" or pose == "PlatformStanding") then
			stopAllAnimations()
		end

		local tool = Character:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			local animStringValueObject = getToolAnim(tool)

			if animStringValueObject then
				toolAnimName = animStringValueObject.Value
				animStringValueObject.Parent = nil
				toolAnimTime = currentTime + .3
			end

			if currentTime > toolAnimTime then
				toolAnimTime = 0
				toolAnimName = "None"
			end

			animateTool()		
		else
			stopToolAnimations()
			toolAnimName = "None"
			toolAnimInstance = nil
			toolAnimTime = 0
		end
	end

	Humanoid.Died:connect(onDied)
	Humanoid.Running:connect(onRunning)
	Humanoid.Jumping:connect(onJumping)
	Humanoid.Climbing:connect(onClimbing)
	Humanoid.GettingUp:connect(onGettingUp)
	Humanoid.FreeFalling:connect(onFreeFall)
	Humanoid.FallingDown:connect(onFallingDown)
	
	Humanoid.Seated:connect(onSeated)
	
	Humanoid.PlatformStanding:connect(onPlatformStanding)
	Humanoid.Swimming:connect(onSwimming)

	if useChatEmotes then
		local LocalPlayer = game:GetService("Players").LocalPlayer
		if LocalPlayer then
			LocalPlayer.Chatted:connect(function(msg)
				local emoteName = ""
				if string.sub(msg, 1, 3) == "/e " then
					emoteName = string.sub(msg, 4)
				elseif string.sub(msg, 1, 7) == "/emote " then
					emoteName = string.sub(msg, 8)
				end

				if pose == "Standing" and emoteNames[emoteName] ~= nil then
					playAnimation(emoteName, 0.1, Humanoid)
				end
			end)
		end
	end
	
	-- PlayEmote RemoteFunction compatibility
	local playEmoteFunc = script:FindFirstChild("PlayEmote") or script:FindFirstChildOfClass("RemoteFunction")
	if playEmoteFunc then
		playEmoteFunc.OnInvoke = function(emoteArg)
			if pose == "Standing" then
				if emoteNames[emoteArg] ~= nil then
					playAnimation(emoteArg, 0.1, Humanoid)
					return true, currentAnimTrack
				end

				if typeof(emoteArg) ~= "Instance" or not emoteArg:IsA("Animation") then
					return false
				end

				playEmote(emoteArg, 0.1, Humanoid)
				return true, currentAnimTrack
			end
		end
	end

	if Character.Parent ~= nil then
		playAnimation("idle", 0.1, Humanoid)
		pose = "Standing"
	end

	while Character.Parent ~= nil do
		local _, currentGameTime = wait(0.1)
		stepAnimate(currentGameTime)
	end
end

return module;
