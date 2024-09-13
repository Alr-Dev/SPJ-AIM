print('========\\//========')
print('==================')
print('Loading Key Verification...')

-- SPJ Services
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui") -- Adicionado StarterGui
local OrionLib1 = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))() -- Renamed to OrionLib1

-- Local API Keys (Replace with your actual keys)
local validKeys = {'0x893ksl1m!kc'}

-- Function to verify API Key
local function verifyApiKey(apiKey, callback)
    for _, key in pairs(validKeys) do
        if key == apiKey then
            callback(true)
            return
        end
    end
    callback(false)
end

-- Create Key Input Window
local function createKeyWindow()
    local Window13 = OrionLib1:MakeWindow({
        Name = "API KEY",
        HidePremium = false,
        SaveConfig = false,
        ConfigFolder = "OrionTest",
        IntroEnabled = true,  -- Habilita a introdução
        IntroText = "Welcome to API Key Verification!",  -- Texto da introdução
        IntroIcon = "rbxassetid://4483345998"  -- Ícone da introdução (substitua com o ID correto se necessário)
    })

    local Tab = Window13:MakeTab({
        Name = "Key Input",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    Tab:AddTextbox({
        Name = "Enter API Key",
        Default = "",
        TextDisappear = true,
        Callback = function(apiKey)
            verifyApiKey(apiKey, function(isValid)
                if isValid then
                    StarterGui:SetCore("SendNotification", {
                        Title = "API Key Valid",
                        Text = "Access Granted. Loading script...",
                        Duration = 2
                    })
                    OrionLib1:Destroy()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Alr-Dev/SPJ-AIM/main/versions/otherload.lua", true))()

                else
                    StarterGui:SetCore("SendNotification", {
                        Title = "404 error: API Key Invalid",
                        Text = "Invalid API Key. Please try again.",
                        Duration = 2
                    })
                end
            end)
        end
    })
end

createKeyWindow() -- Show key window on start
