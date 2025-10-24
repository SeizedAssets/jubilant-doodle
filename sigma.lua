-- Services
local http_service = game:GetService("HttpService")
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")
local marketplace = game:GetService("MarketplaceService")

-- Initialize library table
if not library then
    library = {}
end
library.directory = "DogicaTest"

-- Ensure fonts folder exists
if not isfolder(library.directory .. "/fonts") then
    makefolder(library.directory .. "/fonts")
end

-- Download Dogica font
writefile(library.directory .. "/fonts/main.ttf", game:HttpGet("https://github.com/SeizedAssets/jubilant-doodle/raw/refs/heads/main/dogica.ttf"))

-- Encode and load font
pcall(function()
    local dogica_font_data = {
        name = "Dogica",
        faces = {
            {
                name = "Regular",
                weight = 400,
                style = "normal",
                assetId = getcustomasset(library.directory .. "/fonts/main.ttf")
            }
        }
    }

    writefile(library.directory .. "/fonts/main_encoded.ttf", http_service:JSONEncode(dogica_font_data))
    library.font = Font.new(getcustomasset(library.directory .. "/fonts/main_encoded.ttf"), Enum.FontWeight.Regular)
end)

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.Enabled = false

-- Full-screen dark overlay
local backgroundFrame = Instance.new("Frame")
backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
backgroundFrame.Position = UDim2.new(0, 0, 0, 0)
backgroundFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backgroundFrame.BackgroundTransparency = 0.85
backgroundFrame.BorderSizePixel = 0
backgroundFrame.Parent = screenGui

-- ViewportFrame for spinning model
local viewport = Instance.new("ViewportFrame")
viewport.Size = UDim2.new(0, 300, 0, 300)
viewport.Position = UDim2.new(0.5, 0, 0.5, -30)
viewport.AnchorPoint = Vector2.new(0.5, 0.5)
viewport.BackgroundTransparency = 1
viewport.BorderSizePixel = 0
viewport.Parent = screenGui

-- Load the model
local model = game:GetObjects("rbxassetid://14867566912")[1]
model.Parent = viewport

-- Camera setup
local camera = Instance.new("Camera")
camera.Parent = viewport
viewport.CurrentCamera = camera

-- Center the model
local function getModelCenter(mod)
    local parts = {}
    for _, obj in ipairs(mod:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    if #parts == 0 then return Vector3.new(0,0,0) end
    local sum = Vector3.new(0,0,0)
    for _, p in ipairs(parts) do
        sum += p.Position
    end
    return sum / #parts
end

local center = getModelCenter(model)
for _, part in ipairs(model:GetDescendants()) do
    if part:IsA("BasePart") then
        part.CFrame = part.CFrame - center
    end
end

local cameraDistance = 10
camera.CFrame = CFrame.new(Vector3.new(0,0,cameraDistance), Vector3.new(0,0,0))
local rotationSpeed = math.rad(0.5)
runService.RenderStepped:Connect(function()
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CFrame = part.CFrame * CFrame.Angles(0, rotationSpeed, 0)
        end
    end
    camera.CFrame = CFrame.new(Vector3.new(0,0,cameraDistance), Vector3.new(0,0,0))
end)

local watermark_frame = Instance.new("Frame")
watermark_frame.Size = UDim2.new(0, 700, 0, 15)
watermark_frame.Position = UDim2.new(0.5, 0, 0.5, 155)
watermark_frame.AnchorPoint = Vector2.new(0.5, 0.5)
watermark_frame.BackgroundTransparency = 1
watermark_frame.Parent = screenGui

local textLabel = Instance.new("TextLabel")
textLabel.Parent = watermark_frame
textLabel.Name = "WatermarkLabel"
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.Position = UDim2.new(0, 0, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextScaled = false
textLabel.TextSize = 6
textLabel.TextWrapped = true
if library.font then
    textLabel.FontFace = library.font
else
    textLabel.Font = Enum.Font.SourceSans
end
textLabel.RichText = true
local function updateWatermark()
    local game_name = "Unknown Game"
    pcall(function()
        game_name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)

    local roblox_username = player.Name
    local custom_tag = '<font color="rgb(128,0,128)">[ g o n e . l o l ]</font>'
    local time_text = os.date("%I:%M")
    local time_suffix = string.lower(os.date("%p"))

    textLabel.Text = string.format("[%s] | [%s] | %s | [%s %s]", 
        game_name, roblox_username, custom_tag, time_text, time_suffix)
end

updateWatermark()
spawn(function()
    while true do
        updateWatermark()
        wait(60)
    end
end)

userInput.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        screenGui.Enabled = not screenGui.Enabled
    end
end)
