-- UI
-- Boot the Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
-- Services
local targetEnemy = nil
local rainbowEnabled = false
local isFollowing = false
local fovRadius = 200
local wallCheckEnabled = true
local teamCheckEnabled = true  -- Add this line for the toggle
local smoothness = 0.1
local hitPart = "Head"
local xOffset = 0
local yOffset = 0
local firstDetection = true
local velocityX, velocityY = 0, 0

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()
-----------------------------------------------------
local Window = OrionLib:MakeWindow({
	Name = "SPJ Aim",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "OrionTest",
})

-- Create a Tab
local Tab = Window:MakeTab({
	Name = "Settings",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Create a Section
local Section = Tab:AddSection({
	Name = "Configuration"
})

-- Initialize variables
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Radius = 200
fovCircle.Filled = false
fovCircle.Color = Color3.new(1, 1, 1)

-- Functions
local function teamCheck(targetPlayer)
	return not teamCheckEnabled or targetPlayer.Team ~= LocalPlayer.Team
end

-- Function to generate a rainbow color
local function getRainbowColor(frequency)
	local time = tick() * frequency
	local red = math.sin(time + 0) * 127 + 128
	local green = math.sin(time + 2) * 127 + 128
	local blue = math.sin(time + 4) * 127 + 128
	return Color3.fromRGB(math.floor(red), math.floor(green), math.floor(blue))
end

-- Function to update the FOV circle color to a rainbow effect
local function updateRainbowFOV()
	if rainbowEnabled then
		fovCircle.Color = getRainbowColor(1)
	end
end

-- Function to check if the target is alive
local function aliveCheck(targetPlayer)
	local character = targetPlayer.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		return humanoid and humanoid.Health > 0
	end
	return false
end

-- Adjusted wall check function with smoother detection
local function wallCheck(targetPlayer)
	if not wallCheckEnabled then return true end
	local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
	local ray = Ray.new(Camera.CFrame.Position, (targetPosition - Camera.CFrame.Position).unit * 500)
	local hitPart = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
	return not hitPart or hitPart:IsDescendantOf(targetPlayer.Character)
end

-- Find the nearest enemy within FOV and perform all checks
local function findNearestEnemy()
	local nearestDistance = fovRadius
	local nearestEnemy = nil

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= LocalPlayer and teamCheck(otherPlayer) and aliveCheck(otherPlayer) then
			local character = otherPlayer.Character
			if character and character:FindFirstChild("HumanoidRootPart") then
				local screenPos, onScreen = Camera:WorldToScreenPoint(character.HumanoidRootPart.Position)
				local mousePos = Vector2.new(mouse.X, mouse.Y)
				local distanceFromCursor = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

				if onScreen and distanceFromCursor < nearestDistance and wallCheck(otherPlayer) then
					nearestDistance = distanceFromCursor
					nearestEnemy = otherPlayer
				end
			end
		end
	end
	return nearestEnemy
end

-- Updated function to smoothly follow the enemy
local function followEnemy()
	if targetEnemy and targetEnemy.Character and targetEnemy.Character:FindFirstChild("HumanoidRootPart") then
		local targetPart = targetEnemy.Character:FindFirstChild(hitPart) or targetEnemy.Character:FindFirstChild("HumanoidRootPart")
		local screenPos = Camera:WorldToScreenPoint(targetPart.Position)
		local targetPos = Vector2.new(screenPos.X + xOffset, screenPos.Y + yOffset)
		local currentPos = Vector2.new(mouse.X, mouse.Y)

		-- Calculate the difference between the current and target positions
		local diffX, diffY = targetPos.X - currentPos.X, targetPos.Y - currentPos.Y

		-- Introduce velocity-based smooth movement with friction
		velocityX = (velocityX * (1 - smoothness)) + (diffX * smoothness)
		velocityY = (velocityY * (1 - smoothness)) + (diffY * smoothness)

		-- Cap the velocity to prevent too fast movements
		velocityX = math.clamp(velocityX, -10, 10)
		velocityY = math.clamp(velocityY, -10, 10)

		-- Move the mouse relative to its current position
		mousemoverel(velocityX, velocityY)

		-- Add a deadzone to reduce minor shaking
		if math.abs(diffX) < 5 and math.abs(diffY) < 5 then
			velocityX = 0
			velocityY = 0
		end
	end
end

-- UI elements
Tab:AddSlider({
	Name = "FOV Radius",
	Min = 100,
	Max = 500,
	Default = 200,
	Color = Color3.fromRGB(255, 0, 0),
	Increment = 50,
	ValueName = "px",
	Callback = function(Value)
		fovRadius = Value
		fovCircle.Radius = fovRadius
	end    
})

Tab:AddToggle({
	Name = "Wall Check",
	Default = true,
	Callback = function(Value)
		wallCheckEnabled = Value
	end    
})

Tab:AddSlider({
	Name = "Smoothness",
	Min = 0.1,
	Max = 1,
	Default = 0.1,
	Color = Color3.fromRGB(0, 255, 0),
	Increment = 0.05,
	ValueName = "",
	Callback = function(Value)
		smoothness = Value
	end    
})

Tab:AddToggle({
	Name = "Rainbow FOV",
	Default = false,
	Callback = function(Value)
		rainbowEnabled = Value
	end    
})

Tab:AddToggle({
	Name = "Show Fov",
	Default = false,
	Callback = function(Value)
		fovCircle.Visible = Value
	end    
})

Tab:AddToggle({
	Name = "Team Check",
	Default = true,  -- Add default state for the team check toggle
	Callback = function(Value)
		teamCheckEnabled = Value
	end    
})

Tab:AddDropdown({
	Name = "HitPart",
	Default = "Head",
	Options = {"Head", "Torso"},
	Callback = function(Value)
		hitPart = Value
	end    
})

Tab:AddSlider({
	Name = "X Offset",
	Min = 0,
	Max = 100,
	Default = 0,
	Color = Color3.fromRGB(0, 0, 255),
	Increment = 5,
	ValueName = "",
	Callback = function(Value)
		xOffset = Value
	end    
})

Tab:AddSlider({
	Name = "Y Offset",
	Min = 0,
	Max = 100,
	Default = 0,
	Color = Color3.fromRGB(255, 255, 0),
	Increment = 5,
	ValueName = "",
	Callback = function(Value)
		yOffset = Value
	end    
})

Tab:AddSlider({
	Name = "X Smoothness",
	Min = 0.01,
	Max = 1,
	Default = 1/35,
	Color = Color3.fromRGB(255, 128, 0),
	Increment = 0.01,
	ValueName = "",
	Callback = function(Value)
		xSmoothness = Value
	end    
})

Tab:AddSlider({
	Name = "Y Smoothness",
	Min = 0.01,
	Max = 1,
	Default = 1/35,
	Color = Color3.fromRGB(128, 255, 128),
	Increment = 0.01,
	ValueName = "",
	Callback = function(Value)
		ySmoothness = Value
	end    
})

-- Notification example
OrionLib:MakeNotification({
	Name = "Welcome!",
	Content = "Script is loaded successfully.",
	Image = "rbxassetid://4483345998",
	Time = 5
})

-- Initialize OrionLib
OrionLib:Init()

-- Update loop to handle target finding, following, and rainbow FOV
RunService.RenderStepped:Connect(function()
	if isFollowing then
		targetEnemy = findNearestEnemy()
		if targetEnemy then
			followEnemy()
		else
			firstDetection = true
		end
	end

	fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
	fovCircle.Radius = fovRadius
	updateRainbowFOV()
end)

-- Input handling
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.P then
		isFollowing = not isFollowing
		if not isFollowing then
			firstDetection = true
		end
	end
end)

-- Cleanup function
local function cleanup()
	fovCircle:Remove()
end

getgenv().cleanup = cleanup
