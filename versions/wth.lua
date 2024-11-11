
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
	Name = "SPJ Aim",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "OrionTest",
})

-- Create Tabs
local SettingsTab = Window:MakeTab({
	Name = "Aim Settings",
	Icon = "rbxassetid://9947946243",
	PremiumOnly = false
})

local EspTab = Window:MakeTab({
	Name = "ESP",
	Icon = "rbxassetid://12907910066",
	PremiumOnly = false
})
local LegitTab = Window:MakeTab({
	Name = "Legit",
	Icon = "rbxassetid://690033270",
	PremiumOnly = false
})
local CustomizeTab = Window:MakeTab({
	Name = "Customize",
	Icon = "rbxassetid://6020038044",
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


local xSmoothness = 0
local ySmoothness = 0
local legitAimEnabled = false
local stickyAimEnabled = false
local fovRadius = 100
local targetEnemy = nil
local rainbowEnabled = false
local wallCheckEnabled = true
local teamCheckEnabled = true
local hitPart = "Head"
local xOffset = 0
local yOffset = 0
local offset = 1
-- Services
local Players = game:GetChildren()[13]
local Workspace = workspace
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()
local mode = 'cursor'
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

local aliveCheckEnabled = true 


local function aliveCheck(targetPlayer)
	if not aliveCheckEnabled then return true end
	local character = targetPlayer.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		return humanoid and humanoid.Health > 0
	end
	return false
end
local ignoreTransparency = true -- Make sure this is set appropriately

local function isPlayerTransparent(player)
    if ignoreTransparency then
        local character = player.Character
        if character then
            local transparent = false
            -- Check for transparency in both LeftLeg and RightLeg
            for _, part in ipairs(character:GetDescendants()) do
                if part.Name == "Left Leg" or part.Name == "Right Leg" or 
                   part.Name == "Left arm" or part.Name == "Right arm" then
                    print("Checking transparency for", part.Name, "of", player.Name, ":", part.Transparency)
                    if part.Transparency == 1 then -- Changed to == 1 for exact match
                        transparent = true
                        break
                    end
                end
            end
            if transparent then
                print("Player " .. player.Name .. " has transparent legs.")
            else
                print("Player " .. player.Name .. " does not have transparent legs.")
            end
            return transparent
        else
            print("Character not found for player: " .. player.Name)
        end
    end
    return false
end
local function wallCheck(targetPlayer)
    if not wallCheckEnabled then return true end
    local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
    local direction = (targetPosition - Camera.CFrame.Position).unit * 500
    local ray = Ray.new(Camera.CFrame.Position, direction)
    local hitPart, hitPosition = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
    
    if hitPart and not hitPart:IsDescendantOf(targetPlayer.Character) then
        return false
    end

    return true
end
local findLowHealthEnemy = false  -- VariÃ¡vel para o toggle
local isFollowing = false
local velocityX, velocityY = 0, 0
local predictionTime = 0
-- Initialize Variables
local cursorSpeed = 10 -- Default cursor speed
local cursorAccuracy = 100 -- Default cursor accuracy
local function findNearestEnemy()
    local nearestDistance = fovRadius
    local nearestEnemy = nil
    local lowestHealth = fovRadius

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= LocalPlayer and teamCheck(otherPlayer) and aliveCheck(otherPlayer) then
            if ignoreTransparency and isPlayerTransparent(otherPlayer) then
                continue
            end

            local character = otherPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToScreenPoint(humanoidRootPart.Position)
                local mousePos = Vector2.new(mouse.X, mouse.Y)
                local distanceFromCursor = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                if findLowHealthEnemy then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health < lowestHealth and wallCheck(otherPlayer) then
                        lowestHealth = humanoid.Health
                        nearestEnemy = otherPlayer
                    end
                else
                    if onScreen and distanceFromCursor < nearestDistance and wallCheck(otherPlayer) then
                        nearestDistance = distanceFromCursor
                        nearestEnemy = otherPlayer
                    end
                end
            end
        end
    end

    return nearestEnemy
end

local function followEnemy()
    if not isFollowing then
        velocityX, velocityY = 0, 0
        isFollowing = true
    end

    if targetEnemy and targetEnemy.Character and targetEnemy.Character:FindFirstChild("HumanoidRootPart") then
        if not aliveCheck(targetEnemy) or not wallCheck(targetEnemy) then
            print("Target failed aliveCheck or wallCheck, finding new enemy.")
            targetEnemy = findNearestEnemy()
            velocityX, velocityY = 0, 0
            return
        end

        local targetPart = targetEnemy.Character:FindFirstChild(hitPart) or targetEnemy.Character:FindFirstChild("HumanoidRootPart")
        local targetPosition = targetPart.Position + (targetEnemy.Character.HumanoidRootPart.Velocity * predictionTime)

        -- Logic based on mode
        if mode == 'cursor' then
            -- Cursor aiming logic
            local screenPos = Camera:WorldToScreenPoint(targetPosition)

            local adjustedY = math.clamp(-targetEnemy.Character.HumanoidRootPart.Velocity.Y * predictionTime, -5, 5)
            if math.abs(adjustedY) < 10 then
                screenPos = screenPos + Vector3.new(0, adjustedY, 0)
            end

            local targetPos = Vector2.new(screenPos.X + xOffset, screenPos.Y + yOffset)
            local currentPos = Vector2.new(mouse.X, mouse.Y)
            local diffX, diffY = targetPos.X - currentPos.X, targetPos.Y - currentPos.Y

            local accuracy = legitAimEnabled and (cursorAccuracy / 500) or (cursorAccuracy / 1000)
            local speed = legitAimEnabled and (cursorSpeed / 2) or cursorSpeed

            velocityX = (velocityX * (1 - accuracy)) + (diffX * accuracy)
            velocityY = (velocityY * (1 - accuracy)) + (diffY * accuracy)

            velocityX = math.clamp(velocityX, -speed, speed)
            velocityY = math.clamp(velocityY, -5, 5)

            mousemoverel(velocityX, velocityY)

            if math.abs(diffX) < 5 and math.abs(diffY) < 5 then
                velocityX = 0
                velocityY = 0
            end

        elseif mode == 'cam' then
            -- Camlock aiming logic with checks
            if not aliveCheck(targetEnemy) or not wallCheck(targetEnemy) then
                print("Target failed aliveCheck or wallCheck, finding new enemy.")
                targetEnemy = findNearestEnemy()
                velocityX, velocityY = 0, 0
                return
            end

             local lookVector = (targetPart.Position - Camera.CFrame.Position).unit
            local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
            Camera.CFrame = newCFrame
        end
    else
        targetEnemy = findNearestEnemy()
        velocityX, velocityY = 0, 0
    end
end

RunService.RenderStepped:Connect(function()
    if isFollowing then
        followEnemy()
    end

    fovCircle.Position = Vector2.new(mouse.X, mouse.Y - offset) -- Move the FOV circle up by 'offset'
    fovCircle.Radius = fovRadius
    updateRainbowFOV()
end)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        isFollowing = not isFollowing
        if isFollowing then
            velocityX, velocityY = 0, 0
            targetEnemy = findNearestEnemy()
        else
            targetEnemy = nil
        end
    end
end)
LegitTab:AddToggle({
    Name = "Ignore Transparent Players",
    Default = false,
    Callback = function(Value)
        ignoreTransparency = Value
        print("Ignore Transparent Players: " .. tostring(ignoreTransparency))
    end    
})
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
SettingsTab:AddSlider({
	Name = "Predction time",
	Min = 0,
	Max = 10,
	Default = 0,
	Color = Color3.fromRGB(255, 0, 0),
	Increment = 0.1,
	ValueName = "TP",
	Callback = function(value)
		predictionTime = value
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
	Max = 20,
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
CustomizeTab:AddSlider({
	Name = "Fov offset",
	Min = 0,
	Max = 100,
	Default = 0,
	Color = Color3.fromRGB(0, 255, 0),
	Increment = 1,
	ValueName = "%",
	Callback = function(Value)
		offset = Value
	end    
})
CustomizeTab:AddSlider({
	Name = "Fov -offset",
	Min = 0,
	Max = 100,
	Default = 0,
	Color = Color3.fromRGB(0, 255, 0),
	Increment = 1,
	ValueName = "%",
	Callback = function(Value)
		offset = -Value
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
SettingsTab:AddToggle({
	Name = "Alive Check",
	Default = true,
	Callback = function(Value)
		aliveCheckEnabled = Value
		print("Alive Check: " .. tostring(aliveCheckEnabled))
	end    
})
SettingsTab:AddToggle({
    Name = "Find Nearest Enemy with Low Health",
    Default = false,
    Callback = function(Value)
        findLowHealthEnemy = Value
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
SettingsTab:AddDropdown({
	Name = "Aim method",
	Default = "cursor",
	Options = {"cursor", "cam"},
	Callback = function(Value)
		mode = Value
	end    
})


LegitTab:AddSlider({
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

LegitTab:AddSlider({
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

LegitTab:AddSlider({
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

LegitTab:AddSlider({
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


-- Add Color Picker for FOV and ESP customization
CustomizeTab:AddColorpicker({
	Name = "FOV Color",
	Default = Color3.fromRGB(255, 255, 255),
	Callback = function(Value)
		fovCircle.Color = Value
	end	  
})
local legitAimEnabled = false
local stickyAimEnabled = false

-- Add Toggles for Legit Aim and Sticky Aim
LegitTab:AddToggle({
    Name = "Legit Aim",
    Default = false,
    Callback = function(Value)
        legitAimEnabled = Value
        stickyAimEnabled = not Value -- Ensure only one mode is active at a time
        print("Legit Aim: " .. tostring(legitAimEnabled))
    end    
})

LegitTab:AddToggle({
    Name = "Sticky Aim",
    Default = false,
    Callback = function(Value)
        stickyAimEnabled = Value
        legitAimEnabled = not Value -- Ensure only one mode is active at a time
        print("Sticky Aim: " .. tostring(stickyAimEnabled))
    end    
})



-- Initialize OrionLib
OrionLib:Init()
local ESP_ENABLED = true
local TRACERS_ENABLED = true
local BOXES_ENABLED = true
local HEALTH_TEXT_ENABLED = true
local HEALTH_BAR_ENABLED = true
local TEAM_COLOR_ENABLED = true
local RAINBOW_ESP_ENABLED = false
local CUSTOM_COLOR_ENABLED = true
local CUSTOM_COLOR = Color3.fromRGB(255, 255, 255)
local SHOW_HITBOX = true
local HIDE_TEAMMATES = true
local SHOW_PLAYER_NAMES = true
local SHOW_WEAPONS = true
local SHOW_METERS = true
local chamsEnabled = true  -- This is the toggle variable (change to enable/disable chams)
local players = {}  -- Table to store player names




-- UI elements for ESP settings
EspTab:AddToggle({
	Name = "ESP Enabled",
	Default = true,
	Callback = function(Value)
		ESP_ENABLED = Value
	end
})

EspTab:AddToggle({
	Name = "Tracers Enabled",
	Default = true,
	Callback = function(Value)
		TRACERS_ENABLED = Value
	end
})

EspTab:AddToggle({
	Name = "Boxes Enabled",
	Default = true,
	Callback = function(Value)
		BOXES_ENABLED = Value
	end
})

EspTab:AddToggle({
	Name = "Health Text Enabled",
	Default = true,
	Callback = function(Value)
		HEALTH_TEXT_ENABLED = Value
	end
})

EspTab:AddToggle({
	Name = "Health Bar Enabled",
	Default = true,
	Callback = function(Value)
		HEALTH_BAR_ENABLED = Value
	end
})

CustomizeTab:AddToggle({
	Name = "Esp Team Color Enabled",
	Default = true,
	Callback = function(Value)
		TEAM_COLOR_ENABLED = Value
	end
})

CustomizeTab:AddToggle({
	Name = "Rainbow ESP Enabled",
	Default = false,
	Callback = function(Value)
		RAINBOW_ESP_ENABLED = Value
	end
})

EspTab:AddToggle({
	Name = "Show Hitbox",
	Default = true,
	Callback = function(Value)
		SHOW_HITBOX = Value
	end
})

EspTab:AddToggle({
	Name = "Hide Teammates",
	Default = true,
	Callback = function(Value)
		HIDE_TEAMMATES = Value
	end
})

EspTab:AddToggle({
	Name = "Show Player Names",
	Default = true,
	Callback = function(Value)
		SHOW_PLAYER_NAMES = Value
	end
})



EspTab:AddToggle({
	Name = "Show Weapons",
	Default = true,
	Callback = function(Value)
		SHOW_WEAPONS = Value
	end
})

EspTab:AddToggle({
	Name = "Show Meters",
	Default = true,
	Callback = function(Value)
		SHOW_METERS = Value
	end
})

CustomizeTab:AddColorpicker({
	Name = "Custom ESP Color",
	Default = Color3.fromRGB(255, 255, 255),
	Callback = function(Value)
		CUSTOM_COLOR = Value
	end
})
local ESPObjects = {}

-- Helper function to hide a specific ESP element without affecting others
local function hideElement(element)
    if element then
        element.Visible = false
    end
end

local function setElementVisibility(player)
    if ESPObjects[player] then
        -- Box
        if ESPObjects[player].box then
            ESPObjects[player].box.Visible = BOXES_ENABLED and ESP_ENABLED
        end

        -- Tracers
        if ESPObjects[player].tracer then
            ESPObjects[player].tracer.Visible = TRACERS_ENABLED and ESP_ENABLED
        end

        -- Health Bar
        if ESPObjects[player].healthBar then
            ESPObjects[player].healthBar.Visible = HEALTH_BAR_ENABLED and ESP_ENABLED
        end

        -- Health Text
        if ESPObjects[player].healthText then
            ESPObjects[player].healthText.Visible = HEALTH_TEXT_ENABLED and ESP_ENABLED
        end

        -- Hitbox
        if ESPObjects[player].hitbox then
            ESPObjects[player].hitbox.Visible = SHOW_HITBOX and ESP_ENABLED
        end

        -- Player Name
        if ESPObjects[player].name then
            ESPObjects[player].name.Visible = SHOW_PLAYER_NAMES and ESP_ENABLED
        end

        -- Weapons
        if ESPObjects[player].weapon then
            ESPObjects[player].weapon.Visible = SHOW_WEAPONS and ESP_ENABLED
        end

        -- Meters
        if ESPObjects[player].meters then
            ESPObjects[player].meters.Visible = SHOW_METERS and ESP_ENABLED
        end
    end
end

local function createDrawing(type, properties)
    local drawing = Drawing.new(type)
    for prop, value in pairs(properties) do
        drawing[prop] = value
    end
    return drawing
end


local function getTeamColor(player)
    if player.Team then
        return player.Team.TeamColor.Color
    end
    return CUSTOM_COLOR
end

local function getRainbowColor()
    local hue = tick() % 5 / 5
    return Color3.fromHSV(hue, 1, 1)
end

local function createChamsAtPlayer(player)
    -- Skip if it's the local player or teammates (when hiding teammates is enabled)
    if player == game.Players.LocalPlayer or (HIDE_TEAMMATES and player.Team == game.Players.LocalPlayer.Team) then
        return
    end

    -- Create chams if chams are enabled and player doesn't already have a "Highlight"
    if chamsEnabled and player.Character and not player.Character:FindFirstChildOfClass("Highlight") then
        local chams = Instance.new("Highlight")
        -- Respect team color or custom color
        local teamColor = TEAM_COLOR_ENABLED and getTeamColor(player) or CUSTOM_COLOR
        if RAINBOW_ESP_ENABLED then
            teamColor = getRainbowColor()
        end
        chams.FillColor = teamColor
        chams.FillTransparency = 0.5
        chams.OutlineColor = Color3.fromRGB(255, 255, 255)
        chams.OutlineTransparency = 0
        chams.Parent = player.Character  -- Parent chams to the player's character
    end
end

-- Function to remove chams for a player
local function removeChamsAtPlayer(player)
    -- Skip if it's the local player
    if player == game.Players.LocalPlayer then
        return
    end

    -- Find and remove the cham if it exists
    if player.Character and player.Character:FindFirstChildOfClass("Highlight") then
        player.Character:FindFirstChildOfClass("Highlight"):Destroy()
    end
end

-- Function to toggle chams on or off for all players
local function toggleChams()
    for _, player in ipairs(game:GetService('Players'):GetPlayers()) do
        if chamsEnabled then
            createChamsAtPlayer(player)  -- Apply chams
        else
            removeChamsAtPlayer(player)  -- Remove chams
        end
    end
end

-- Function to handle player addition, respawn, or death
local function onPlayerAdded(player)
    -- Add player to the players table if not local player
    if player ~= game.Players.LocalPlayer then
        table.insert(players, player.Name)
    end

    -- Handle character added (when player spawns or respawns)
    player.CharacterAdded:Connect(function(character)
        if chamsEnabled then
            createChamsAtPlayer(player)  -- Create chams when the character is added
        end
    end)

    -- If the player already has a character (if they were already spawned)
    if player.Character then
        createChamsAtPlayer(player)
    end
end

-- Connect the PlayerAdded event for future players
game:GetService('Players').PlayerAdded:Connect(onPlayerAdded)

-- Loop through all existing players and apply or remove the chams based on the toggle
for _, player in ipairs(game:GetService('Players'):GetPlayers()) do
    onPlayerAdded(player)
end
-- Function to update ESP for all players
local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
            local humanoid = player.Character.Humanoid
            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character.Head
            local camera = Workspace.CurrentCamera
            local rootScreenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
            local headScreenPos = camera:WorldToViewportPoint(head.Position)

            if HIDE_TEAMMATES and player.Team == game.Players.LocalPlayer.Team then
                if ESPObjects[player] then
                    hideElement(ESPObjects[player].box)
                    hideElement(ESPObjects[player].healthBar)
                    hideElement(ESPObjects[player].healthText)
                    hideElement(ESPObjects[player].tracer)
                    hideElement(ESPObjects[player].hitbox)
                    hideElement(ESPObjects[player].name)
                    hideElement(ESPObjects[player].weapon)
                    hideElement(ESPObjects[player].meters)
                end
                continue
            end
            
            if ESP_ENABLED and onScreen then
                -- Set team or custom color, apply rainbow if enabled
                local teamColor = TEAM_COLOR_ENABLED and getTeamColor(player) or CUSTOM_COLOR
                if RAINBOW_ESP_ENABLED then
                    teamColor = getRainbowColor()
                end
                
                if not ESPObjects[player] then
                    ESPObjects[player] = {
                        box = createDrawing("Square", {Thickness = 0.5}),
                        healthBar = createDrawing("Square", { Filled = true}),
                        healthText = createDrawing("Text", {Size = 5, Outline = true, Center = true}),
                        name = createDrawing("Text", {Size = 10, Outline = true, Center = true}),
                        tracer = createDrawing("Line", {Thickness = 1}),
                        hitbox = createDrawing("Square", {Thickness = 1, Color = Color3.new(1, 0, 0)}),
                        weapon = createDrawing("Text", {Size = 10, Outline = true, Center = true}),
                        meters = createDrawing("Text", {Size = 10, Outline = true, Center = true})
                    }
                end

                -- Set visibility for each element based on settings
                setElementVisibility(player)
                createChamsAtPlayer(player)

                -- Update box size and position
                local box = ESPObjects[player].box
                local sizeX = math.abs(headScreenPos.X - rootScreenPos.X)
                local sizeY = math.abs(headScreenPos.Y - rootScreenPos.Y)

                box.Size = Vector2.new(sizeX * 1.5, sizeY * 1.8)
                box.Position = Vector2.new(headScreenPos.X - box.Size.X / 2, headScreenPos.Y)
                box.Color = teamColor

                -- Update health bar
                local healthBar = ESPObjects[player].healthBar
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local healthBarHeight = box.Size.Y * healthPercent
                healthBar.Size = Vector2.new(4, healthBarHeight)
                healthBar.Position = Vector2.new(box.Position.X - 6, box.Position.Y + (box.Size.Y - healthBarHeight))
                healthBar.Color = Color3.fromRGB(255 - (healthPercent * 255), healthPercent * 255, 0)

                -- Update health text
                local healthText = ESPObjects[player].healthText
                healthText.Position = Vector2.new(headScreenPos.X, headScreenPos.Y - 20)
                healthText.Text = string.format("HP: %d", math.floor(humanoid.Health))
                healthText.Color = teamColor

                -- Update player name
                local name = ESPObjects[player].name
                name.Position = Vector2.new(headScreenPos.X, headScreenPos.Y - 40)
                name.Text = player.Name
                name.Color = teamColor

                -- Update tracer
                local tracer = ESPObjects[player].tracer
                tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                tracer.To = Vector2.new(rootScreenPos.X, rootScreenPos.Y)
                tracer.Color = teamColor

                -- Update hitbox
                local hitbox = ESPObjects[player].hitbox
                if SHOW_HITBOX then
                    hitbox.Size = Vector2.new(30, 30)  -- Adjust size as needed
                    hitbox.Position = Vector2.new(rootScreenPos.X - hitbox.Size.X / 2, rootScreenPos.Y - hitbox.Size.Y / 2)
                    hitbox.Color = Color3.new(1, 0, 0) -- Hitbox color
                else
                    hitbox.Visible = false
                end

                -- Update weapon
                local weapon = ESPObjects[player].weapon
                if SHOW_WEAPONS and player.Character:FindFirstChildOfClass("Tool") then
                    weapon.Text = player.Character:FindFirstChildOfClass("Tool").Name
                else
                    weapon.Text = ""
                end
                weapon.Position = Vector2.new(headScreenPos.X, headScreenPos.Y + 20)
                weapon.Color = teamColor

                -- Update distance in meters
                local meters = ESPObjects[player].meters
                if SHOW_METERS then
                    local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).magnitude)
                    meters.Text = string.format("%dm", distance)
                else
                    meters.Text = ""
                end
                meters.Position = Vector2.new(headScreenPos.X, headScreenPos.Y + 40)
                meters.Color = teamColor
            else
                if ESPObjects[player] then
                    hideElement(ESPObjects[player].box)
                    hideElement(ESPObjects[player].healthBar)
                    hideElement(ESPObjects[player].healthText)
                    hideElement(ESPObjects[player].tracer)
                    hideElement(ESPObjects[player].hitbox)
                    hideElement(ESPObjects[player].name)
                    hideElement(ESPObjects[player].weapon)
                    hideElement(ESPObjects[player].meters)
                end
                -- Set visibility for each element based on settings
            end
            end
        end
end

RunService.RenderStepped:Connect(updateESP)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj then
                obj:Remove()
            end
        end
        ESPObjects[player] = nil
    end
end)
EspTab:AddToggle({
	Name = "Chams Enabled",
	Default = true,
	Callback = function(Value)
		chamsEnabled = Value
        toggleChams()
	end
})

OrionLib:MakeNotification({ 
	Name = "Script Loaded",
	Content = "All settings and ESP are now active.",
	Image = "rbxassetid://4483345998",
	Time = 5
})
