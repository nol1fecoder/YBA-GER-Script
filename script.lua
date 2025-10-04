local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer 
local Camera = game.Workspace.CurrentCamera 
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") 

local Settings = {
    AutoPB = false,
    GERAim = false,
    PBMode = 1,
    AimFOV = 99,
    FireDelay = 340, 
    ShowAimCircle = true,
}

local PrimaryColor = Color3.fromRGB(255, 230, 0)         
local SecondaryColor = Color3.fromRGB(0, 200, 255)      
local GlassBaseColor = Color3.fromRGB(15, 20, 30)        
local BaseTransparency = 0.35                           
local TextColor = Color3.fromRGB(240, 240, 240)         
local ActiveColor = PrimaryColor

local Attacks = {
    ["Kick Barrage"] = 0, ["Sticky Fingers Finisher"] = 0.35, ["Gun_Shot1"] = 0.15, ["Heavy_Charge"] = 0.35, ["Erasure"] = 0.35, 
    ["Disc"] = 0.35, ["Propeller Charge"] = 0.35, ["Platinum Slam"] = 0.25, ["Chomp"] = 0.25, ["Scary Monsters Bite"] = 0.25, 
    ["D4C Love Train Finisher"] = 0.35, ["D4C Finisher"] = 0.35, ["Tusk ACT 4 Finisher"] = 0.35, ["Gold Experience Finisher"] = 0.35, 
    ["Gold Experience Requiem Finisher"] = 0.35, ["Scary Monsters Finisher"] = 0.35, ["White Album Finisher"] = 0.35, 
    ["Star Platinum Finisher"] = 0.35, ["Star Platinum: The World Finisher"] = 0.35, ["King Crimson Finisher"] = 0.35, 
    ["King Crimson Requiem Finisher"] = 0.35, ["Crazy Diamond Finisher"] = 0.35, ["The World Alternate Universe Finisher"] = 0.35, 
    ["The World Finisher"] = 0.45, ["The World Finisher2"] = 0.45, ["Purple Haze Finisher"] = 0.35, ["Hermit Purple Finisher"] = 0.35, 
    ["Made in Heaven Finisher"] = 0.35, ["Whitesnake Finisher"] = 0.40, ["C-Moon Finisher"] = 0.35, ["Red Hot Chili Pepper Finisher"] = 0.35, 
    ["Six Pistols Finisher"] = 0.45, ["Stone Free Finisher"] = 0.35, ["Ora Kicks"] = 0.15, ["lightning_jabs"] = 0.15,
}

local function createAimCircle(position, color, duration)
    if not Settings.ShowAimCircle then return end
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 50, 0, 50) 
    billboardGui.Adornee = Instance.new("Part") 
    billboardGui.Adornee.Transparency = 1
    billboardGui.Adornee.CanCollide = false
    billboardGui.Adornee.Anchored = true
    billboardGui.Adornee.Position = position
    billboardGui.Adornee.Parent = game.Workspace
    billboardGui.ExtentsOffset = Vector3.new(0, 2, 0) 
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = 0.6 
    frame.BorderSizePixel = 0
    frame.Parent = billboardGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0) 
    corner.Parent = frame
    billboardGui.Parent = PlayerGui 
    TweenService:Create(frame, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    Debris:AddItem(billboardGui.Adornee, duration + 0.1)
    Debris:AddItem(billboardGui, duration + 0.1)
end

local function ActivateGERLaser(targetHRP)
    local Character = LocalPlayer.Character
    if not Character then return end
    local Remote = Character:FindFirstChild("RemoteEvent") 
    if not Remote then return end
    
    if targetHRP and targetHRP.Parent then
        local originalCFrame = Camera.CFrame
        local targetPosition = targetHRP.Position - Vector3.new(0, 1.5, 0) 
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
        local totalDelaySeconds = Settings.FireDelay / 1000
        local tweenDuration = 0.05
        local remainingWaitTime = totalDelaySeconds - tweenDuration
        local tweenInfo = TweenInfo.new(tweenDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        
        local tween = TweenService:Create(Camera, tweenInfo, {CFrame = targetCFrame})
        tween:Play() 
        
        task.wait(remainingWaitTime > 0 and remainingWaitTime or 0)
        
        createAimCircle(targetHRP.Position, PrimaryColor, 0.5) 
        
        Remote:FireServer("ActivateSkill", Enum.KeyCode.X) 
        
        Camera.CFrame = originalCFrame
    end
end

local function checkSound(soundID)
    local success, result = pcall(function()
        for _, v in pairs(game.ReplicatedStorage.Sounds:GetChildren()) do
            if v.SoundId and v.SoundId == soundID then return v.Name end
        end
    end)
    return success and result or nil
end

local function performBlock(mode)
    local character = LocalPlayer.Character
    if not character then return end
    local remoteEvent = character:FindFirstChild("RemoteEvent")
    if not remoteEvent then return end
    
    if character:FindFirstChildOfClass("Humanoid") and character:FindFirstChildOfClass("Humanoid").Blocking then return end
    
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
    if not Settings.AutoPB or not Attacks[move] then return end
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart"); local playerHRP = player:FindFirstChild("HumanoidRootPart")
    if not hrp or not playerHRP then return end
    
    local distance = (hrp.Position - playerHRP.Position).Magnitude
    if distance < 30 then 
        local delay = Attacks[move]
        task.delay(delay, function() 
            performBlock(Settings.PBMode) 
        end)
    end
end

local function getClosestPlayer()
    local closest, shortestDist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid"); local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and rootPart then
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    local dist = (myHRP.Position - rootPart.Position).Magnitude
                    if dist < shortestDist and dist < Settings.AimFOV then closest, shortestDist = player, dist end
                end
            end
        end
    end
    return closest
end

local function setupPlayer(player)
    if not player.Character then return end
    player.Character.DescendantAdded:Connect(function(child)
        if not Settings.AutoPB then return end
        if child:IsA("Sound") and child.SoundId then
            local moveName = checkSound(child.SoundId)
            if moveName then 
                task.spawn(function() 
                    checkPBMove(player.Character, moveName) 
                end) 
            end
        end
    end)
end

for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then setupPlayer(player) end end
Players.PlayerAdded:Connect(function(player) player.CharacterAdded:Connect(function(character) task.wait(0.5); setupPlayer(player) end) end)


UserInputService.InputBegan:Connect(function(input, processed)
    if processed or input.KeyCode ~= Enum.KeyCode.X or not Settings.GERAim then return end

    local target = getClosestPlayer()
    if target and target.Character then
        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        
        if targetHRP then
            task.spawn(function()
                ActivateGERLaser(targetHRP)
            end)
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GERMenu"
ScreenGui.Parent = PlayerGui 
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 360) 
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = GlassBaseColor
MainFrame.BackgroundTransparency = BaseTransparency 
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = true 

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = SecondaryColor 
MainStroke.Thickness = 1.5 
MainStroke.Transparency = 0.8
MainStroke.Parent = MainFrame
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = GlassBaseColor
TitleBar.BackgroundTransparency = BaseTransparency 
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GER | Frosted Core v4.1"
Title.TextColor3 = PrimaryColor 
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0.5, -30, 0, 40) 
TabFrame.Position = UDim2.new(0.5, 15, 0, 0) 
TabFrame.BackgroundColor3 = GlassBaseColor
TabFrame.BackgroundTransparency = 1 
TabFrame.BorderSizePixel = 0
TabFrame.Parent = TitleBar

local TabList = Instance.new("UIListLayout")
TabList.Parent = TabFrame
TabList.FillDirection = Enum.FillDirection.Horizontal 
TabList.Padding = UDim.new(0, 10)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Right 

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -30, 1, -65)
ContentFrame.Position = UDim2.new(0, 15, 0, 55)
ContentFrame.BackgroundColor3 = GlassBaseColor
ContentFrame.BackgroundTransparency = BaseTransparency 
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = ContentFrame

local ContentList = Instance.new("UIListLayout")
ContentList.Parent = ContentFrame
ContentList.Padding = UDim.new(0, 10)
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.FillDirection = Enum.FillDirection.Vertical 
ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center 

local Tabs = {
    Aim = Instance.new("Frame"),
    Combat = Instance.new("Frame")
}

for name, frame in pairs(Tabs) do
    frame.Name = name
    frame.Size = UDim2.new(1, -20, 1, -20)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentFrame
    frame.Visible = false 

    local list = Instance.new("UIListLayout")
    list.Parent = frame
    list.Padding = UDim.new(0, 10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Button"
    TabButton.Size = UDim2.new(0, 80, 0, 30) 
    TabButton.BackgroundColor3 = GlassBaseColor
    TabButton.BackgroundTransparency = 0.5 
    TabButton.Text = name
    TabButton.TextColor3 = TextColor
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Parent = TabFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = TabButton

    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = SecondaryColor
    TabStroke.Thickness = 1
    TabStroke.Transparency = 1
    TabStroke.Parent = TabButton
    TabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    TabButton.MouseButton1Click:Connect(function()
        for _, otherFrame in pairs(Tabs) do otherFrame.Visible = false end
        frame.Visible = true

        for _, btn in pairs(TabFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = TextColor, BackgroundTransparency = 0.5}):Play()
                if btn:FindFirstChildOfClass("UIStroke") then btn:FindFirstChildOfClass("UIStroke").Transparency = 1 end
            end
        end
        TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = PrimaryColor, BackgroundTransparency = 0.2}):Play()
        if TabStroke then TabStroke.Transparency = 0.2 end
    end)
end

Tabs.Aim.Visible = true
local DefaultTabButton = TabFrame:FindFirstChild("AimButton")
if DefaultTabButton then
    DefaultTabButton.TextColor3 = PrimaryColor
    DefaultTabButton.BackgroundTransparency = 0.2
    if DefaultTabButton:FindFirstChildOfClass("UIStroke") then DefaultTabButton:FindFirstChildOfClass("UIStroke").Transparency = 0.2 end
end


local function createButton(text, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 45) 
    Button.Position = UDim2.new(0, 10, 0, 0)
    Button.BackgroundColor3 = GlassBaseColor
    Button.BackgroundTransparency = 0.4 
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button

    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = SecondaryColor
    ButtonStroke.Thickness = 1
    ButtonStroke.Transparency = 0.7 
    ButtonStroke.Parent = Button
    ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local ButtonText = Instance.new("TextLabel")
    ButtonText.Size = UDim2.new(1, -20, 1, 0)
    ButtonText.Position = UDim2.new(0, 10, 0, 0)
    ButtonText.BackgroundTransparency = 1
    ButtonText.Text = text
    ButtonText.TextColor3 = TextColor
    ButtonText.TextSize = 16
    ButtonText.Font = Enum.Font.GothamBold
    ButtonText.TextXAlignment = Enum.TextXAlignment.Left
    ButtonText.Parent = Button

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(0, 50, 0, 25)
    Status.Position = UDim2.new(1, -60, 0.5, -12.5)
    Status.BackgroundColor3 = GlassBaseColor
    Status.BackgroundTransparency = 0.5
    Status.BorderSizePixel = 0
    Status.Text = "OFF"
    Status.TextColor3 = TextColor
    Status.TextSize = 12
    Status.Font = Enum.Font.GothamBold
    Status.Parent = Button

    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = Status

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
        if ButtonStroke then TweenService:Create(ButtonStroke, TweenInfo.new(0.1), {Transparency = 0.4}):Play() end
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play()
        if ButtonStroke then TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {Transparency = 0.7}):Play() end
    end)

    return Button, Status
end

local function createSlider(text, min, max, default, step, parent)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -20, 0, 60)
    Container.Position = UDim2.new(0, 10, 0, 0)
    Container.BackgroundColor3 = GlassBaseColor
    Container.BackgroundTransparency = 0.4
    Container.BorderSizePixel = 0
    Container.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Container

    local ContainerStroke = Instance.new("UIStroke")
    ContainerStroke.Color = SecondaryColor
    ContainerStroke.Thickness = 1
    ContainerStroke.Transparency = 0.7
    ContainerStroke.Parent = Container
    ContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = TextColor
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 25)
    ValueLabel.Position = UDim2.new(1, -60, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = PrimaryColor
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = Container

    local SliderBack = Instance.new("Frame")
    SliderBack.Size = UDim2.new(1, -20, 0, 6)
    SliderBack.Position = UDim2.new(0, 10, 0, 40)
    SliderBack.BackgroundColor3 = GlassBaseColor
    SliderBack.BackgroundTransparency = 0.6 
    SliderBack.BorderSizePixel = 0
    SliderBack.Parent = Container

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(1, 0)
    SliderCorner.Parent = SliderBack

    local SliderFill = Instance.new("Frame")
    local initialPos = (default - min) / (max - min)
    SliderFill.Size = UDim2.new(initialPos, 0, 1, 0)
    SliderFill.BackgroundColor3 = PrimaryColor 
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBack

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill

    return Container, ValueLabel, SliderBack, SliderFill, min, max, step
end

local GERAimButton, GERAimStatus = createButton("GER Aimbot (X)", Tabs.Aim)
local AimCircleButton, AimCircleStatus = createButton("Show Aim Circle", Tabs.Aim)
local FOVSlider, FOVValue, FOVBack, FOVFill, FOVMin, FOVMax, FOVStep = createSlider("Aim FOV (studs)", 30, 100, 99, 1, Tabs.Aim)
local DelaySlider, DelayValue, DelayBack, DelayFill, DelayMin, DelayMax, DelayStep = createSlider("Fire Delay (ms)", 100, 700, Settings.FireDelay, 10, Tabs.Aim)

local AutoPBButton, AutoPBStatus = createButton("Auto Perfect Block", Tabs.Combat)
local PBModeButton, PBModeStatus = createButton("Block Mode", Tabs.Combat)

local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 25) 
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundColor3 = GlassBaseColor
Footer.BackgroundTransparency = BaseTransparency 
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, -20, 1, 0)
InfoText.Position = UDim2.new(0, 10, 0, 0)
InfoText.BackgroundTransparency = 1
InfoText.Text = "RightShift - Toggle Menu | v4.1"
InfoText.TextColor3 = Color3.fromRGB(180, 180, 180) 
InfoText.TextSize = 11
InfoText.Font = Enum.Font.Gotham
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.Parent = Footer

AutoPBButton.MouseButton1Click:Connect(function()
    Settings.AutoPB = not Settings.AutoPB
    AutoPBStatus.Text = Settings.AutoPB and "ON" or "OFF"
    AutoPBStatus.BackgroundColor3 = Settings.AutoPB and ActiveColor or GlassBaseColor 
    AutoPBStatus.BackgroundTransparency = Settings.AutoPB and 0.2 or 0.5
    AutoPBStatus.TextColor3 = Settings.AutoPB and GlassBaseColor or TextColor
end)

GERAimButton.MouseButton1Click:Connect(function()
    Settings.GERAim = not Settings.GERAim
    GERAimStatus.Text = Settings.GERAim and "ON" or "OFF"
    GERAimStatus.BackgroundColor3 = Settings.GERAim and ActiveColor or GlassBaseColor
    GERAimStatus.BackgroundTransparency = Settings.GERAim and 0.2 or 0.5
    GERAimStatus.TextColor3 = Settings.GERAim and GlassBaseColor or TextColor
end)

AimCircleButton.MouseButton1Click:Connect(function()
    Settings.ShowAimCircle = not Settings.ShowAimCircle
    AimCircleStatus.Text = Settings.ShowAimCircle and "ON" or "OFF"
    AimCircleStatus.BackgroundColor3 = Settings.ShowAimCircle and ActiveColor or GlassBaseColor
    AimCircleStatus.BackgroundTransparency = Settings.ShowAimCircle and 0.2 or 0.5
    AimCircleStatus.TextColor3 = Settings.ShowAimCircle and GlassBaseColor or TextColor
end)

PBModeButton.MouseButton1Click:Connect(function()
    Settings.PBMode = Settings.PBMode == 1 and 2 or 1
    local modeText = Settings.PBMode == 1 and "Normal" or "Interrupt"
    PBModeStatus.Text = modeText
    PBModeStatus.BackgroundColor3 = Settings.PBMode == 2 and SecondaryColor or GlassBaseColor 
    PBModeStatus.BackgroundTransparency = Settings.PBMode == 2 and 0.2 or 0.5
    PBModeStatus.TextColor3 = Settings.PBMode == 2 and GlassBaseColor or TextColor
end)

local function handleSliderInput(sliderBack, sliderFill, valueLabel, minVal, maxVal, settingKey, step)
    local dragging = false
    local function updateValue(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
            local rawValue = minVal + (maxVal - minVal) * pos
            local steppedValue = math.floor(rawValue / step) * step

            Settings[settingKey] = steppedValue
            valueLabel.Text = tostring(steppedValue)

            local newPos = (steppedValue - minVal) / (maxVal - minVal)
            sliderFill.Size = UDim2.new(newPos, 0, 1, 0)
        end
    end

    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateValue(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(updateValue)
end

handleSliderInput(FOVBack, FOVFill, FOVValue, FOVMin, FOVMax, "AimFOV", 1)
handleSliderInput(DelayBack, DelayFill, DelayValue, DelayMin, DelayMax, "FireDelay", 10)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("GER Script v4.1 loaded! RightShift = toggle")
