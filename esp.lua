-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Settings
local espEnabled = false
local espLabels = {}
local guiVisible = true
local espRange = 1000

-- List of allowed BrickColors for filtering
local allowedColors = {
    BrickColor.new("Cocoa"),
    BrickColor.new("Lime green"),
    BrickColor.new("Royal purple"),
    BrickColor.new("Toothpaste"),
    BrickColor.new("Tr. Flu. Yellow")
}

-- GUI Setup
local espGui = Instance.new("ScreenGui")
espGui.Name = "DynamicESPGui"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.Parent = playerGui

-- ESP labels container (to be behind main UI)
local espLabelsContainer = Instance.new("Frame")
espLabelsContainer.Size = UDim2.new(1, 0, 1, 0)
espLabelsContainer.BackgroundTransparency = 1
espLabelsContainer.ZIndex = 0 -- Make sure this is behind the main container
espLabelsContainer.Parent = espGui

-- Main UI Container
local container = Instance.new("Frame")
container.Size = UDim2.new(0, 212, 0, 188)
container.Position = UDim2.new(0, 20, 0, 200)
container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
container.BorderSizePixel = 0
container.Visible = true
container.Active = true
container.ZIndex = 1 -- Above espLabelsContainer
container.Parent = espGui


local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 8)
containerCorner.Parent = container

-- Header
local headerBackground = Instance.new("Frame")
headerBackground.Size = UDim2.new(1, 0, 0, 25)
headerBackground.Position = UDim2.new(0, 0, 0, 0)
headerBackground.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
headerBackground.BorderSizePixel = 0
headerBackground.ZIndex = 1
headerBackground.Parent = container

local headerBackgroundCorner = Instance.new("UICorner")
headerBackgroundCorner.CornerRadius = UDim.new(0, 8)
headerBackgroundCorner.Parent = headerBackground

local headerText = Instance.new("TextLabel")
headerText.Size = UDim2.new(1, -10, 1, 0)
headerText.Position = UDim2.new(0, 10, 0, 0)
headerText.BackgroundTransparency = 1
headerText.Text = "ParkourBagESP"
headerText.TextColor3 = Color3.fromRGB(220, 220, 220)
headerText.TextXAlignment = Enum.TextXAlignment.Left
headerText.Font = Enum.Font.SourceSansBold
headerText.TextSize = 18
headerText.TextYAlignment = Enum.TextYAlignment.Center
headerText.ZIndex = 2
headerText.Parent = headerBackground

-- Range Label
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(1, 0, 0, 12.5)
rangeLabel.Position = UDim2.new(0, 0, 0, 40)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "ESP Range"
rangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
rangeLabel.TextSize = 16
rangeLabel.Font = Enum.Font.SourceSansBold
rangeLabel.TextXAlignment = Enum.TextXAlignment.Center
rangeLabel.TextYAlignment = Enum.TextYAlignment.Center
rangeLabel.Parent = container

-- Range Input
local rangeInput = Instance.new("TextBox")
rangeInput.Size = UDim2.new(0, 192, 0, 30)
rangeInput.Position = UDim2.new(0, 10, 0, 60)
rangeInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
rangeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
rangeInput.TextSize = 18
rangeInput.Font = Enum.Font.SourceSansBold
rangeInput.Text = tostring(espRange)
rangeInput.ClearTextOnFocus = false
rangeInput.Parent = container

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = rangeInput

rangeInput.FocusLost:Connect(function()
    local value = tonumber(rangeInput.Text)
    if value and value >= 100 and value <= 7000 then
        espRange = math.floor(value)
    else
        rangeInput.Text = tostring(espRange)
    end
end)

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 192, 0, 43)
toggleButton.Position = UDim2.new(0, 10, 0, 100)
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.BorderSizePixel = 0
toggleButton.TextSize = 20
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextColor3 = Color3.fromRGB(255, 0, 0)
toggleButton.Text = "DISABLED"
toggleButton.Parent = container

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = toggleButton

-- Side Panel Toggle Button
local sideToggleButton = Instance.new("TextButton")
sideToggleButton.Size = UDim2.new(0, 192, 0, 25)
sideToggleButton.Position = UDim2.new(0, 10, 0, 153)
sideToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sideToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sideToggleButton.TextSize = 16
sideToggleButton.Font = Enum.Font.SourceSansBold
sideToggleButton.Text = "Open Configuration"
sideToggleButton.Parent = container

local sideToggleCorner = Instance.new("UICorner")
sideToggleCorner.CornerRadius = UDim.new(0, 6)
sideToggleCorner.Parent = sideToggleButton

local sidePanel = Instance.new("Frame")
sidePanel.Size = UDim2.new(0, 150, 0, 162.5)
sidePanel.Position = UDim2.new(0, container.Position.X.Offset + container.Size.X.Offset + 10, 0, container.Position.Y.Offset)
sidePanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
sidePanel.BorderSizePixel = 0
sidePanel.Visible = false
sidePanel.Parent = espGui

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 8)
sideCorner.Parent = sidePanel

local sideVisible = false

-- "Only Locate" label
local onlyLocateLabel = Instance.new("TextLabel")
onlyLocateLabel.Size = UDim2.new(1, 0, 0, 20)
onlyLocateLabel.Position = UDim2.new(0, 0, 0, 5)
onlyLocateLabel.BackgroundTransparency = 1
onlyLocateLabel.Text = "Only Locate:"
onlyLocateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
onlyLocateLabel.TextSize = 14
onlyLocateLabel.Font = Enum.Font.SourceSansBold
onlyLocateLabel.TextXAlignment = Enum.TextXAlignment.Center
onlyLocateLabel.Parent = sidePanel

-- BrickColor filter buttons
local selectedColors = {}

local brickColors = {
    {displayName = "Common", colorName = "Cocoa"},
    {displayName = "Uncommon", colorName = "Lime green"},
    {displayName = "Rare", colorName = "Royal purple"},
    {displayName = "Epic", colorName = "Toothpaste"},
    {displayName = "Legendary", colorName = "Tr. Flu. Yellow"},
    {displayName = "Ultimate", colorName = "Really red", filterColor = BrickColor.new("Really black")},
}

local function isColorSelected(color)
    for _, c in ipairs(selectedColors) do
        if c == color then
            return true
        end
    end
    return false
end

local function addColor(color)
    if not isColorSelected(color) then
        table.insert(selectedColors, color)
    end
end

local function removeColor(color)
    for i, c in ipairs(selectedColors) do
        if c == color then
            table.remove(selectedColors, i)
            break
        end
    end
end

for i, info in ipairs(brickColors) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 20)
    btn.Position = UDim2.new(0, 5, 0, 5 + i * 22)
    btn.BackgroundColor3 = BrickColor.new(info.colorName).Color
    btn.Text = info.displayName
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = sidePanel

    local filterColor = info.filterColor or BrickColor.new(info.colorName)

    btn.MouseButton1Click:Connect(function()
        if isColorSelected(filterColor) then
            removeColor(filterColor)
            btn.Text = info.displayName
        else
            addColor(filterColor)
            btn.Text = info.displayName .. " (Selected)"
        end
    end)
end

sideToggleButton.MouseButton1Click:Connect(function()
    sideVisible = not sideVisible
    sidePanel.Visible = sideVisible
    sideToggleButton.Text = sideVisible and "Close Configuration" or "Open Configuration"
    sidePanel.Position = UDim2.new(0, container.Position.X.Offset + container.Size.X.Offset + 10, 0, container.Position.Y.Offset)
end)

-- Dragging
local dragging = false
local dragOffset = Vector2.new()
local inputConnection

container.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local guiInset = GuiService:GetGuiInset()
        local mousePos = UserInputService:GetMouseLocation() - guiInset
        dragOffset = mousePos - Vector2.new(container.Position.X.Offset, container.Position.Y.Offset)
        dragging = true
        if inputConnection then inputConnection:Disconnect() end
        inputConnection = RunService.RenderStepped:Connect(function()
            if dragging then
                local newMousePos = UserInputService:GetMouseLocation() - guiInset
                local newPosition = newMousePos - dragOffset
                container.Position = UDim2.new(0, newPosition.X, 0, newPosition.Y)
                if sidePanel.Visible then
                    sidePanel.Position = UDim2.new(0, newPosition.X + container.Size.X.Offset + 10, 0, newPosition.Y)
                end
            end
        end)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        if inputConnection then inputConnection:Disconnect() inputConnection = nil end
    end
end)

-- Toggle ESP
local function updateToggleState()
    espEnabled = not espEnabled
    toggleButton.Text = espEnabled and "ENABLED" or "DISABLED"
    toggleButton.TextColor3 = espEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end

toggleButton.MouseButton1Click:Connect(updateToggleState)

-- F2 to toggle GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F2 then
        guiVisible = not guiVisible
        container.Visible = guiVisible
        sidePanel.Visible = guiVisible and sideVisible or false
    end
end)

-- ESP label template
local function createLabelTemplate()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 70, 0, 24)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 10

    local dot = Instance.new("TextLabel")
    dot.Name = "Dot"
    dot.Size = UDim2.new(0, 42, 0, 42)
    dot.BackgroundTransparency = 1
    dot.TextStrokeTransparency = 1
    dot.TextSize = 65
    dot.Font = Enum.Font.SourceSansBold
    dot.Text = "."
    dot.Position = UDim2.new(-0.15, 0, -1, 0)
    dot.Parent = frame

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "Distance"
    distLabel.Size = UDim2.new(0, 50, 0, 24)
    distLabel.BackgroundTransparency = 1
    distLabel.TextStrokeTransparency = 0.5
    distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    distLabel.TextSize = 14
    distLabel.Font = Enum.Font.SourceSansBold
    distLabel.TextColor3 = Color3.new(1, 1, 1)
    distLabel.Position = UDim2.new(0, 12.5, -0.5, 0)
    distLabel.Text = "0"
    distLabel.TextXAlignment = Enum.TextXAlignment.Left
    distLabel.Parent = frame

    frame.Visible = false
    return frame
end

local labelTemplate = createLabelTemplate()
labelTemplate.Parent = espGui

local function isSevenDigitNumber(name)
    return string.match(name, "^%d%d%d%d%d%d%d$") ~= nil
end

local function isInValidGroup(part)
    local parent = part.Parent
    return parent and isSevenDigitNumber(parent.Name)
end

local function getAllValidMainParts()
    local results = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Main" and isInValidGroup(obj) then
            table.insert(results, obj)
        end
    end
    return results
end

local allParts = getAllValidMainParts()

-- Refresh parts list periodically
coroutine.wrap(function()
    while true do
        allParts = getAllValidMainParts()
        task.wait(30)
    end
end)()

-- Radar ESP scanning
local radarIndex = 1
local partsPerFrame = 15

local function createESPLabel(part)
    local label = labelTemplate:Clone()
    label.Dot.TextColor3 = part.BrickColor.Color
    label.Parent = espLabelsContainer -- Parent inside the ESP container
    espLabels[part] = label
end

RunService.RenderStepped:Connect(function()
    local character = localPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for i = 1, partsPerFrame do
        local part = allParts[radarIndex]
        if part then
            -- Filter by color if onlyLocateColor is set
            if #selectedColors == 0 or isColorSelected(part.BrickColor) then
                local dist = (hrp.Position - part.Position).Magnitude
                if dist <= espRange then
                    local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        if not espLabels[part] then
                            createESPLabel(part)
                        end
                    else
                        if espLabels[part] then espLabels[part]:Destroy() espLabels[part] = nil end
                    end
                else
                    if espLabels[part] then espLabels[part]:Destroy() espLabels[part] = nil end
                end
            else
                -- color filtered out
                if espLabels[part] then espLabels[part]:Destroy() espLabels[part] = nil end
            end
        end

        radarIndex = radarIndex + 1
        if radarIndex > #allParts then
            radarIndex = 1
        end
    end

    for part, label in pairs(espLabels) do
        if part and part.Parent then
            local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
            if onScreen then
                label.Visible = espEnabled
                label.Position = UDim2.new(0, screenPos.X - 10, 0, screenPos.Y - 10)

                local dist = (localPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude
                label.Distance.Text = tostring(math.floor(dist))
                label.Dot.TextColor3 = part.BrickColor.Color
            else
                label.Visible = false
            end
        else
            label:Destroy()
            espLabels[part] = nil
        end
    end
end)
