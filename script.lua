--[[
    GER Script for YBA v1.2
    Fixed: Silent Aim now works properly
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Settings = {
    AutoPB = false,
    GERAim = false,
    PBMode = 1,
    AimFOV = 99
}

local Attacks = {
    ["Kick Barrage"] = 0,
    ["Sticky Fingers Finisher"] = 0.35,
    ["Gun_Shot1"] = 0.15,
    ["Heavy_Charge"] = 0.35,
    ["Erasure"] = 0.35,
    ["Disc"] = 0.35,
    ["Propeller Charge"] = 0.35,
    ["Platinum Slam"] = 0.25,
    ["Chomp"] = 0.25,
    ["Scary Monsters Bite"] = 0.25,
    ["D4C Love Train Finisher"] = 0.35,
    ["D4C Finisher"] = 0.35,
    ["Tusk ACT 4 Finisher"] = 0.35,
    ["Gold Experience Finisher"] = 0.35,
    ["Gold Experience Requiem Finisher"] = 0.35,
    ["Scary Monsters Finisher"] = 0.35,
    ["White Album Finisher"] = 0.35,
    ["Star Platinum Finisher"] = 0.35,
    ["Star Platinum: The World Finisher"] = 0.35,
    ["King Crimson Finisher"] = 0.35,
    ["King Crimson Requiem Finisher"] = 0.35,
    ["Crazy Diamond Finisher"] = 0.35,
    ["The World Alternate Universe Finisher"] = 0.35,
    ["The World Finisher"] = 0.45,
    ["The World Finisher2"] = 0.45,
    ["Purple Haze Finisher"] = 0.35,
    ["Hermit Purple Finisher"] = 0.35,
    ["Made in Heaven Finisher"] = 0.35,
    ["Whitesnake Finisher"] = 0.40,
    ["C-Moon Finisher"] = 0.35,
    ["Red Hot Chili Pepper Finisher"] = 0.35,
    ["Six Pistols Finisher"] = 0.45,
    ["Stone Free Finisher"] = 0.35,
    ["Ora Kicks"] = 0.15,
    ["lightning_jabs"] = 0.15,
}

-- GUI (оставляю как есть, не буду дублировать весь код GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GERMenu"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 340)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
}
Gradient.Rotation = 45
Gradient.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GER Menu"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(0, 40, 0, 20)
Version.Position = UDim2.new(1, -50, 0, 15)
Version.BackgroundTransparency = 1
Version.Text = "v1.2"
Version.TextColor3 = Color3.fromRGB(150, 150, 150)
Version.TextSize = 12
Version.Font = Enum.Font.GothamBold
Version.Parent = TitleBar

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -30, 1, -100)
Content.Position = UDim2.new(0, 15, 0, 60)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = Content
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 10)

local function createButton(text, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 45)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button
    
    local ButtonText = Instance.new("TextLabel")
    ButtonText.Size = UDim2.new(1, -20, 1, 0)
    ButtonText.Position = UDim2.new(0, 10, 0, 0)
    ButtonText.BackgroundTransparency = 1
    ButtonText.Text = text
    ButtonText.TextColor3 = Color3.new(1, 1, 1)
    ButtonText.TextSize = 16
    ButtonText.Font = Enum.Font.GothamBold
    ButtonText.TextXAlignment = Enum.TextXAlignment.Left
    ButtonText.Parent = Button
    
    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(0, 50, 0, 25)
    Status.Position = UDim2.new(1, -60, 0.5, -12.5)
    Status.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    Status.BorderSizePixel = 0
    Status.Text = "OFF"
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 12
    Status.Font = Enum.Font.GothamBold
    Status.Parent = Button
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = Status
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
    end)
    
    return Button, Status
end

local function createSlider(text, min, max, default, parent)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 60)
    Container.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Container.BorderSizePixel = 0
    Container.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 25)
    ValueLabel.Position = UDim2.new(1, -60, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = Container
    
    local SliderBack = Instance.new("Frame")
    SliderBack.Size = UDim2.new(1, -20, 0, 6)
    SliderBack.Position = UDim2.new(0, 10, 0, 40)
    SliderBack.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBack.BorderSizePixel = 0
    SliderBack.Parent = Container
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(1, 0)
    SliderCorner.Parent = SliderBack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBack
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill
    
    return Container, ValueLabel, SliderBack, SliderFill
end

local AutoPBButton, AutoPBStatus = createButton("Auto Perfect Block", Content)
local GERAimButton, GERAimStatus = createButton("GER Aim", Content)
local PBModeButton, PBModeStatus = createButton("Block Mode", Content)
local FOVSlider, FOVValue, FOVBack, FOVFill = createSlider("Aim FOV (studs)", 30, 100, 99, Content)

local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 40)
Footer.Position = UDim2.new(0, 0, 1, -40)
Footer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterCorner = Instance.new("UICorner")
FooterCorner.CornerRadius = UDim.new(0, 15)
FooterCorner.Parent = Footer

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, -20, 1, 0)
InfoText.Position = UDim2.new(0, 10, 0, 0)
InfoText.BackgroundTransparency = 1
InfoText.Text = "RightShift - Toggle Menu | Made for YBA"
InfoText.TextColor3 = Color3.fromRGB(120, 120, 120)
InfoText.TextSize = 12
InfoText.Font = Enum.Font.Gotham
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.Parent = Footer

Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)

-- Functions
local function checkSound(soundID)
    local success, result = pcall(function()
        for _, v in pairs(game.ReplicatedStorage.Sounds:GetChildren()) do
            if v.SoundId and v.SoundId == soundID then
                return v.Name
            end
        end
    end)
    return success and result or nil
end

local function performBlock(mode)
    local character = LocalPlayer.Character
    if not character then return end
    
    local remoteEvent = character:FindFirstChild("RemoteEvent")
    if not remoteEvent then return end
    
    pcall(function()
        if mode == 2 then
            remoteEvent:FireServer("InputEnded", {Input = Enum.KeyCode.E})
            remoteEvent:FireServer("InputEnded", {Input = Enum.KeyCode.R})
            task.wait(0.05)
        end
        
        remoteEvent:FireServer("StartBlocking")
        task.wait(0.6)
        remoteEvent:FireServer("StopBlocking")
    end)
end

local function checkPBMove(player, move)
    if not Settings.AutoPB then return end
    if not Attacks[move] then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local playerHRP = player:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not playerHRP then return end
    
    local distance = (hrp.Position - playerHRP.Position).Magnitude
    
    if distance < 30 then
        local delay = Attacks[move]
        task.wait(delay)
        performBlock(Settings.PBMode)
    end
end

local function getClosestPlayer()
    local closest = nil
    local shortestDist = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    local dist = (myHRP.Position - rootPart.Position).Magnitude
                    if dist < shortestDist and dist < Settings.AimFOV then
                        closest = player
                        shortestDist = dist
                    end
                end
            end
        end
    end
    
    return closest
end

-- Buttons
AutoPBButton.MouseButton1Click:Connect(function()
    Settings.AutoPB = not Settings.AutoPB
    AutoPBStatus.Text = Settings.AutoPB and "ON" or "OFF"
    AutoPBStatus.BackgroundColor3 = Settings.AutoPB and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 55)
    AutoPBStatus.TextColor3 = Settings.AutoPB and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 200)
end)

GERAimButton.MouseButton1Click:Connect(function()
    Settings.GERAim = not Settings.GERAim
    GERAimStatus.Text = Settings.GERAim and "ON" or "OFF"
    GERAimStatus.BackgroundColor3 = Settings.GERAim and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 55)
    GERAimStatus.TextColor3 = Settings.GERAim and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 200)
end)

PBModeButton.MouseButton1Click:Connect(function()
    Settings.PBMode = Settings.PBMode == 1 and 2 or 1
    local modeText = Settings.PBMode == 1 and "Normal" or "Interrupt"
    PBModeStatus.Text = modeText
    PBModeStatus.BackgroundColor3 = Settings.PBMode == 2 and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(50, 50, 55)
end)

-- FOV Slider
local draggingFOV = false
FOVBack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFOV = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFOV = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingFOV and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = math.clamp((input.Position.X - FOVBack.AbsolutePosition.X) / FOVBack.AbsoluteSize.X, 0, 1)
        local value = math.floor(30 + (100 - 30) * pos)
        Settings.AimFOV = value
        FOVValue.Text = tostring(value)
        FOVFill.Size = UDim2.new(pos, 0, 1, 0)
    end
end)

-- AutoPB System
local function setupPlayer(player)
    if player == LocalPlayer.Character then return end
    
    player.DescendantAdded:Connect(function(child)
        if not Settings.AutoPB then return end
        if child:IsA("Sound") and child.SoundId then
            local moveName = checkSound(child.SoundId)
            if moveName then
                task.spawn(function()
                    checkPBMove(player, moveName)
                end)
            end
        end
    end)
end

for _, player in pairs(Workspace.Living:GetChildren()) do
    setupPlayer(player)
end

Workspace.Living.ChildAdded:Connect(function(player)
    task.wait(0.5)
    setupPlayer(player)
end)

-- GER Silent Aim - НОВЫЙ МЕТОД
local aimConnection = nil
local originalCFrame = nil

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or input.KeyCode ~= Enum.KeyCode.X then return end
    
    if Settings.GERAim then
        local target = getClosestPlayer()
        if target and target.Character then
            local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if targetHRP and myHRP then
                -- Сохраняем оригинальный CFrame
                originalCFrame = myHRP.CFrame
                
                -- Постоянно обновляем направление пока X зажат
                aimConnection = RunService.RenderStepped:Connect(function()
                    if targetHRP and myHRP and myHRP.Parent then
                        local lookVector = (targetHRP.Position - myHRP.Position).Unit
                        myHRP.CFrame = CFrame.new(myHRP.Position, myHRP.Position + lookVector)
                    end
                end)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.X then
        -- Отключаем aim и возвращаем оригинальный CFrame
        if aimConnection then
            aimConnection:Disconnect()
            aimConnection = nil
        end
        
        if originalCFrame then
            task.wait(0.1)
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHRP and myHRP.Parent then
                myHRP.CFrame = originalCFrame
            end
            originalCFrame = nil
        end
    end
end)

-- Toggle Menu
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("GER Script v1.2 loaded! RightShift = menu")
