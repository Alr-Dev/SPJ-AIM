wait(5)
    local Filters = {
    '░██████╗██████╗░░░░░░██╗  ░█████╗░██╗███╗░░░███╗', -- ASCII art needs color red.
    '██╔════╝██╔══██╗░░░░░██║  ██╔══██╗██║████╗░████║',
    '╚█████╗░██████╔╝░░░░░██║  ███████║██║██╔████╔██║',
    '░╚═══██╗██╔═══╝░██╗░░██║  ██╔══██║██║██║╚██╔╝██║',
    '██████╔╝██║░░░░░╚█████╔╝  ██║░░██║██║██║░╚═╝░██║',
    '╚═════╝░╚═╝░░░░░░╚════╝░  ╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝',
    'Getting Latest version',
    'Setting Functions',
    'Setting variables',
    'Setting UI elements',
    'Finished',
     'New update avaiable!',
    '1.2.1',
    'Loading modules', -- Color orange
    'Fetching drawing API', -- Color orange
    'Loading scripts', -- Color orange
    'Getting cursor lock API', -- Color orange
    'Loading functions', -- Color orange
    'Getting Latest version', -- Color orange
    'Up to dating', -- Color yellow
    'Starting', -- Color green
    'Script loaded', -- Color green
    'Info', -- Color yellow
    'Instances', -- Color yellow
    'Variables', -- Color yellow
    'ModuleScripts', -- Color yellow
    'Functions', -- Color yellow
    'UI elements', -- Color yellow
    'Closing in', -- Color yellow
};

local CoreGui = game:GetService('CoreGui')
local DevConsoleUI = CoreGui.DevConsoleMaster.DevConsoleWindow.DevConsoleUI

local function FindString(str)
    local Found = {}
    for i = 1, #Filters do
        if string.find(str, Filters[i]) then
            table.insert(Found, Filters[i])
        end
    end
    return Found
end

DevConsoleUI.DescendantAdded:Connect(function(ins)
    if ins:IsA('TextLabel') then
        local Found = FindString(ins.Text)
        if #Found ~= 0 then
            ins.RichText = true
            for i = 1, #Found do
                local color = "#e8f31d" -- Default color (yellow)
                if string.find(Found[i], '░██████╗██████╗░░░░░░██╗') or string.find(Found[i], '██╔════╝██╔══██╗░░░░░██║') or string.find(Found[i], '╚█████╗░██████╔╝░░░░░██║') or string.find(Found[i], '░╚═══██╗██╔═══╝░██╗░░██║') or string.find(Found[i], '██████╔╝██║░░░░░╚█████╔╝') or string.find(Found[i], '╚═════╝░╚═╝░░░░░░╚════╝░') then
                    color = "#ff0000" -- Red for ASCII art
                elseif string.find(Found[i], 'Loading modules') or string.find(Found[i], 'Fetching drawing API') or string.find(Found[i], 'Loading scripts') or string.find(Found[i], 'Getting cursor lock API') or string.find(Found[i], 'Loading functions') then
                    color = "#ffa500" -- Orange for loading messages
                elseif string.find(Found[i], 'Starting') or string.find(Found[i], 'Script loaded') or string.find(Found[i], '1.2.1') or string.find(Found[i], 'New version') or string.find(Found[i], 'Finished') or string.find(Found[i], 'New update avaiable!') or string.find(Found[i], 'Getting Latest version') or string.find(Found[i], 'New update avaiable!') or string.find(Found[i], 'Setting Functions') or string.find(Found[i], 'Setting Variables') or string.find(Found[i], 'Setting UI elements') then
                    color = "#00ff00" -- Green for starting messages
                end
                ins.Text = string.gsub(ins.Text, Found[i], '<font color="'..color..'">'..Found[i]..'</font>')
            end
        end
    end
end)
print('░██████╗██████╗░░░░░░██╗  ░█████╗░██╗███╗░░░███╗')
print('██╔════╝██╔══██╗░░░░░██║  ██╔══██╗██║████╗░████║')
print('╚█████╗░██████╔╝░░░░░██║  ███████║██║██╔████╔██║')
print('░╚═══██╗██╔═══╝░██╗░░██║  ██╔══██║██║██║╚██╔╝██║')
print('██████╔╝██║░░░░░╚█████╔╝  ██║░░██║██║██║░╚═╝░██║')
print('╚═════╝░╚═╝░░░░░░╚════╝░  ╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝')
print('version 1.2.1')
game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)
warn('[-] Loading modules..')
wait(1)
warn('[-] Fetching drawing API..')
wait(1)
warn('[-] Loading scripts..')
wait(1)
warn('[-] Getting cursor lock API..')
wait(1)
warn('[-] Loading functions..')
wait(1)
warn('[-] Getting Latest version..')
wait(1)
warn('[-] Setting Functions..')
wait(2)
warn('[-] Setting Variables..')
wait(2)
warn('[-] Setting UI elements')
wait(2)
warn('[-] Up to dating..')
wait(1)
warn('[-] Starting..')
wait(1)
game:GetService("StarterGui"):SetCore("DevConsoleVisible", false)
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
local espColor = Color3.new(1, 1, 1) -- Default ESP color

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

-- Initialize Variables
local cursorSpeed = 10 -- Default cursor speed
local cursorAccuracy = 100 -- Default cursor accuracy
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
		local accuracy = cursorAccuracy / 1000
		velocityX = (velocityX * (1 - accuracy)) + (diffX * accuracy)
		velocityY = (velocityY * (1 - accuracy)) + (diffY * accuracy)

		-- Cap the velocity to prevent too fast movements
		velocityX = math.clamp(velocityX, -cursorSpeed, cursorSpeed)
		velocityY = math.clamp(velocityY, -cursorSpeed, cursorSpeed)

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
				box.Color = showTeamColor and (player.TeamColor.Color) or espColor
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
				tracer.Color = showTeamColor and (player.TeamColor.Color) or espColor
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
	espBox.Color = espColor
	espBox.Thickness = 2
	espBox.Transparency = 1

	local tracer = Drawing.new("Line")
	tracer.Visible = false
	tracer.Color = espColor
	tracer.Thickness = 1
	tracer.Transparency = 1

	local nameTag = Drawing.new("Text")
	nameTag.Visible = false
	nameTag.Color = espColor
	nameTag.Size = 18
	nameTag.Center = true
	nameTag.Outline = true
	nameTag.Transparency = 1

	local healthTag = Drawing.new("Text")
	healthTag.Visible = false
	healthTag.Color = espColor
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
	Min = 0,
	Max = 900,
	Default = 100,
	Color = Color3.fromRGB(255, 0, 0),
	Increment = 1,
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

-- UI elements for Settings Tab
SettingsTab:AddSlider({
	Name = "Cursor Speed",
	Min = 0,
	Max = 30,
	Default = 0,
	Color = Color3.fromRGB(255, 0, 0),
	Increment = 1,
	ValueName = "speed",
	Callback = function(Value)
		cursorSpeed = Value
	end    
})
SettingsTab:AddSlider({
	Name = "Cursor Accuracy",
	Min = 0,
	Max = 1000,
	Default = 0,
	Color = Color3.fromRGB(0, 255, 0),
	Increment = 1,
	ValueName = "%",
	Callback = function(Value)
		cursorAccuracy = Value
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

local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local esptoggle = false -- Variable to track toggle state
local connections = {} -- Table to store connections for disconnecting later

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

EspTab:AddToggle({
	Name = "Create Esp for new players / For all players",
	Default = true,
	Callback = function(Value)
		esptoggle = Value
		toggleESP() -- Call the toggle function when the toggle changes
	end
})



-- Add Color Picker for FOV and ESP customization
SettingsTab:AddColorpicker({
	Name = "FOV Color",
	Default = Color3.fromRGB(255, 255, 255),
	Callback = function(Value)
		fovCircle.Color = Value
	end	  
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

fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
fovCircle.Radius = fovRadius
updateRainbowFOV()

-- Input handling
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Q then
		isFollowing = not isFollowing
		if isFollowing then
			targetEnemy = findNearestEnemy()
			followEnemy()
		end
	end
end)



-- Function to update ESP elements for all players
local function updateAllEsp()
	for _, player in ipairs(Players:GetPlayers()) do
		updateEspForPlayer(player)
	end
end

-- Initialize ESP for all current players
for _, player in ipairs(Players:GetPlayers()) do
	updateEspForPlayer(player)
end

-- Event Handler for Player Removing
Players.PlayerRemoving:Connect(function(player)
	removeEspForPlayer(player)
end)
-- Finalize the script
OrionLib:MakeNotification({ 
	Name = "Script Loaded",
	Content = "All settings and ESP are now active.",
	Image = "rbxassetid://4483345998",
	Time = 5
})
