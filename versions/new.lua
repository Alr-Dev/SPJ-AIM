-- Script Header
print('░██████╗██████╗░░░░░░██╗  ░█████╗░██╗███╗░░░███╗')
print('██╔════╝██╔══██╗░░░░░██║  ██╔══██╗██║████╗░████║')
print('╚█████╗░██████╔╝░░░░░██║  ███████║██║██╔████╔██║')
print('░╚═══██╗██╔═══╝░██╗░░██║  ██╔══██║██║██║╚██╔╝██║')
print('██████╔╝██║░░░░░╚█████╔╝  ██║░░██║██║██║░╚═╝░██║')
print('╚═════╝░╚═╝░░░░░░╚════╝░  ╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝')
print('version 1.0.5')

-- Boot The OrionLibrary
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
	Name = "SPJ Aim",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "OrionTest",
})

-- Create Tabs
local SettingsTab = Window:MakeTab({
	Name = "Settings",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local EspTab = Window:MakeTab({
	Name = "ESP",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Create Sections
local SettingsSection = SettingsTab:AddSection({
	Name = "Configuration"
})

local EspSection = EspTab:AddSection({
	Name = "ESP Configuration"
})

-- Initialize Variables
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Radius = 200
fovCircle.Filled = false
fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Visible = false

local targetEnemy = nil
local rainbowEnabled = false
local isFollowing = false
local fovRadius = 200
local wallCheckEnabled = true
local teamCheckEnabled = true
local cursorFollowAccuracy = 10
local hitPart = "Head"
local xOffset = 0
local yOffset = 0
local velocityX, velocityY = 0, 0

-- ESP variables
local showEsp = true
local showBoxes = true
local showPlayerHealth = true
local showEspTracers = true
local showTeamColor = true

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

-- Function to check if the target is on the opposite team
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

-- Updated function to smoothly follow the enemy, with percentage accuracy
local function followEnemy()
	if targetEnemy and targetEnemy.Character and targetEnemy.Character:FindFirstChild("HumanoidRootPart") then
		local targetPart = targetEnemy.Character:FindFirstChild(hitPart) or targetEnemy.Character:FindFirstChild("HumanoidRootPart")
		local screenPos = Camera:WorldToScreenPoint(targetPart.Position)

		-- Apply velocity adjustment to the target position
		local velocity = targetEnemy.Character.HumanoidRootPart.Velocity

		-- Limit vertical adjustment to avoid excessive upward drift
		local velocityFactor = 0.05 -- Fine-tune this factor
		screenPos = screenPos + Vector3.new(0, -velocity.Y * velocityFactor, 0)

		local targetPos = Vector2.new(screenPos.X + xOffset, screenPos.Y + yOffset)
		local currentPos = Vector2.new(mouse.X, mouse.Y)

		-- Calculate the difference between the current and target positions
		local diffX, diffY = targetPos.X - currentPos.X, targetPos.Y - currentPos.Y

		-- Introduce percentage accuracy for smoother movement
		local accuracy = cursorFollowAccuracy / 100
		velocityX = (velocityX * (1 - accuracy)) + (diffX * accuracy)
		velocityY = (velocityY * (1 - accuracy)) + (diffY * accuracy)

		-- Cap the velocity to prevent too fast movements
		velocityX = math.clamp(velocityX, -10, 10)
		velocityY = math.clamp(velocityY, -5, 5) -- Lower cap on Y-axis velocity to reduce upward drift

		-- Move the mouse relative to its current position
		mousemoverel(velocityX, velocityY)

		-- Reset velocities if we're within the deadzone
		if math.abs(diffX) < 5 and math.abs(diffY) < 5 then
			velocityX = 0
			velocityY = 0
		end
	end
end
local function updateEspForPlayer(player)
	if player ~= LocalPlayer then
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			-- Check if ESP elements already exist
			if not character:FindFirstChild("ESP") then
				local esp = Instance.new("Folder")
				esp.Name = "ESP"
				esp.Parent = character

				local box = Drawing.new("Square")
				box.Color = showTeamColor and (player.TeamColor.Color) or Color3.new(1, 1, 1)
				box.Thickness = 1
				box.Filled = false
				box.Visible = showBoxes
				box.Parent = esp

				local healthText = Drawing.new("Text")
				healthText.Color = Color3.new(1, 1, 1)
				healthText.Outline = true
				healthText.Size = 18
				healthText.Visible = showPlayerHealth
				healthText.Parent = esp

				local tracer = Drawing.new("Line")
				tracer.Color = showTeamColor and (player.TeamColor.Color) or Color3.new(1, 1, 1)
				tracer.Thickness = 1
				tracer.Visible = showEspTracers
				tracer.Parent = esp
			end
		end
	end
end

-- Function to remove ESP for a specific player
local function removeEspForPlayer(player)
	local character = player.Character
	if character then
		local esp = character:FindFirstChild("ESP")
		if esp then
			esp:Destroy()
		end
	end
end

-- Event Handler for Player Removing
Players.PlayerRemoving:Connect(function(player)
	removeEspForPlayer(player)
end)

-- Initialize ESP for all current players
for _, player in ipairs(Players:GetPlayers()) do
	updateEspForPlayer(player)
end

-- Correct ESP code for script update
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local camera = game.Workspace.CurrentCamera

-- Function to create ESP for a player
local function createESP(player)
    -- Create ESP elements
    local espBox = Drawing.new("Square")
    espBox.Visible = false
    espBox.Color = Color3.new(1, 1, 1)
    espBox.Thickness = 2
    espBox.Transparency = 1

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.new(1, 1, 1)
    tracer.Thickness = 1
    tracer.Transparency = 1

    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = Color3.new(1, 1, 1)
    nameTag.Size = 18
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Transparency = 1

    local healthTag = Drawing.new("Text")
    healthTag.Visible = false
    healthTag.Color = Color3.new(1, 1, 1)
    healthTag.Size = 18
    healthTag.Center = true
    healthTag.Outline = true
    healthTag.Transparency = 1

    -- Function to update ESP elements
    local function update()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character.Head
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

            local rootPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
            local headPos = camera:WorldToViewportPoint(head.Position)
            local distance = (camera.CFrame.Position - rootPart.Position).Magnitude

            if onScreen then
                espBox.Size = Vector2.new(2000 / distance, 3000 / distance)
                espBox.Position = Vector2.new(rootPos.X - espBox.Size.X / 2, rootPos.Y - espBox.Size.Y / 2)
                espBox.Visible = true

                tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                tracer.Visible = true

                nameTag.Position = Vector2.new(rootPos.X, rootPos.Y - espBox.Size.Y / 2 - 20)
                nameTag.Text = player.Name
                nameTag.Visible = true

                healthTag.Position = Vector2.new(rootPos.X, rootPos.Y + espBox.Size.Y / 2 + 20)
                healthTag.Text = "Health: " .. math.floor(humanoid.Health)
                healthTag.Visible = true

                if player.Team then
                    espBox.Color = player.TeamColor.Color
                    tracer.Color = player.TeamColor.Color
                    nameTag.Color = player.TeamColor.Color
                    healthTag.Color = player.TeamColor.Color
                end
            else
                espBox.Visible = false
                tracer.Visible = false
                nameTag.Visible = false
                healthTag.Visible = false
            end
        else
            espBox.Visible = false
            tracer.Visible = false
            nameTag.Visible = false
            healthTag.Visible = false
        end
    end

    runService.RenderStepped:Connect(update)
end


-- UI elements for Settings Tab
SettingsTab:AddSlider({
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

SettingsTab:AddToggle({
	Name = "Wall Check",
	Default = true,
	Callback = function(Value)
		wallCheckEnabled = Value
	end    
})

SettingsTab:AddSlider({
	Name = "Cursor Follow Accuracy",
	Min = 0,
	Max = 100,
	Default = 10,
	Color = Color3.fromRGB(0, 255, 0),
	Increment = 1,
	ValueName = "%",
	Callback = function(Value)
		cursorFollowAccuracy = Value
	end    
})

SettingsTab:AddToggle({
	Name = "Rainbow FOV",
	Default = false,
	Callback = function(Value)
		rainbowEnabled = Value
	end    
})

SettingsTab:AddToggle({
	Name = "Show FOV",
	Default = false,
	Callback = function(Value)
		fovCircle.Visible = Value
	end    
})

SettingsTab:AddToggle({
	Name = "Team Check",
	Default = true,  
	Callback = function(Value)
		teamCheckEnabled = Value
	end    
})

SettingsTab:AddDropdown({
	Name = "HitPart",
	Default = "Head",
	Options = {"Head", "Torso", "Arms", "Legs", "Random"},
	Callback = function(Value)
		hitPart = Value
	end    
})

SettingsTab:AddSlider({
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

SettingsTab:AddSlider({
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

SettingsTab:AddSlider({
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

SettingsTab:AddSlider({
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

-- UI elements for ESP Tab
EspTab:AddToggle({
	Name = "Show ESP",
	Default = true,
	Callback = function(Value)
		showEsp = Value
	end    
})
----------------------------------------------------------------------
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local esptoggle = false -- Variable to track toggle state
local connections = {} -- Table to store connections for disconnecting later
----------------------------------------------------------------------
local function toggleESP()
    if esptoggle then
        -- Create ESP for all existing players
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer then
                createESP(player)
            end
        end

        -- Create ESP for new players
        connections[#connections + 1] = players.PlayerAdded:Connect(function(player)
            if player ~= localPlayer then
                createESP(player)
            end
        end)
    else
        -- Disable ESP by disconnecting all connections
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
        connections = {} -- Clear the connections table
    end
end
---------------------------------------------------------------
EspTab:AddToggle({
    Name = "Create Esp for new players / For all players",
    Default = true,
    Callback = function(Value)
        esptoggle = Value
        toggleESP() -- Call the toggle function when the toggle changes
    end
})

EspTab:AddToggle({
	Name = "Show Boxes",
	Default = true,
	Callback = function(Value)
		showBoxes = Value
	end    
})

EspTab:AddToggle({
	Name = "Show Player Health",
	Default = true,
	Callback = function(Value)
		showPlayerHealth = Value
	end    
})

EspTab:AddToggle({
	Name = "Show ESP Tracers",
	Default = true,
	Callback = function(Value)
		showEspTracers = Value
	end    
})

EspTab:AddToggle({
	Name = "Show Player Team Color",
	Default = true,
	Callback = function(Value)
		showTeamColor = Value
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
		end
	end

	fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
	fovCircle.Radius = fovRadius
	updateRainbowFOV()
end)

-- Input handling
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Q then
		isFollowing = not isFollowing
		if not isFollowing then
			firstDetection = true
		end
	end
end)
