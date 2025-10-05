-- =========================================================================
--  MELLSTROY HUB - CORE INITIALIZATION
-- =========================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = game.Workspace.CurrentCamera 

-- COLOR DEFINITIONS
local TornadoGray = Color3.fromRGB(150, 160, 170) 
local DarkAccent = Color3.fromRGB(35, 35, 40)
local BackgroundColor = Color3.fromRGB(20, 20, 25)
local TextColorBright = Color3.fromRGB(240, 240, 240)
local TextColorDark = Color3.fromRGB(30, 30, 30)

-- Settings 
local Settings = {
    AutoPB = false,
    GERAim = false,
    PBMode = 1,
    AimFOV = 99,
    PBKey = Enum.KeyCode.F,      -- Key to toggle AutoPB (Default: F)
    GERKeyToggle = Enum.KeyCode.G -- Key to toggle GER Aim on/off (Default: G)
}

local Attacks = {
    -- Attack data (unchanged)
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

-- =========================================================================
--  GUI SETUP (Main Hub)
-- =========================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GERMenu"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 340)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -170)
MainFrame.BackgroundColor3 = BackgroundColor
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = TornadoGray 
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.7
MainStroke.Parent = MainFrame

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
Title.Text = "Mellstroy hub"
Title.TextColor3 = TornadoGray
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -30, 1, -100)
Content.Position = UDim2.new(0, 15, 0, 60)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = TornadoGray
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = Content
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 10)

local function createButton(text, parent, isKeyBind)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 45)
    Button.BackgroundColor3 = DarkAccent
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
    ButtonText.TextColor3 = TextColorBright
    ButtonText.TextSize = 16
    ButtonText.Font = Enum.Font.GothamBold
    ButtonText.TextXAlignment = Enum.TextXAlignment.Left
    ButtonText.Parent = Button
    
    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(0, 50, 0, 25)
    Status.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    Status.BorderSizePixel = 0
    Status.Text = "OFF"
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 12
    Status.Font = Enum.Font.GothamBold
    
    local KeyDisplay = nil
    
    if isKeyBind then
        Status.Position = UDim2.new(1, -115, 0.5, -12.5) 
        
        KeyDisplay = Instance.new("TextLabel")
        KeyDisplay.Size = UDim2.new(0, 50, 0, 25)
        KeyDisplay.Position = UDim2.new(1, -60, 0.5, -12.5)
        KeyDisplay.BackgroundColor3 = DarkAccent 
        KeyDisplay.BorderSizePixel = 0
        KeyDisplay.Text = "KEY" 
        KeyDisplay.TextColor3 = TornadoGray
        KeyDisplay.TextSize = 12
        KeyDisplay.Font = Enum.Font.GothamBold
        KeyDisplay.Parent = Button
        
        local KeyCorner = Instance.new("UICorner")
        KeyCorner.CornerRadius = UDim.new(0, 8)
        KeyCorner.Parent = KeyDisplay
    else
        Status.Position = UDim2.new(1, -60, 0.5, -12.5)
    end

    Status.Parent = Button
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = Status
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = DarkAccent}):Play()
    end)
    
    return Button, Status, KeyDisplay 
end

local function createSlider(text, min, max, default, parent)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 60)
    Container.BackgroundColor3 = DarkAccent
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
    Label.TextColor3 = TextColorBright
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 25)
    ValueLabel.Position = UDim2.new(1, -60, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = TornadoGray
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
    SliderFill.BackgroundColor3 = TornadoGray
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBack
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill
    
    return Container, ValueLabel, SliderBack, SliderFill
end

-- Кнопки с биндом
local AutoPBButton, AutoPBStatus, AutoPBKeyDisplay = createButton("Auto Perfect Block (Toggle)", Content, true)
AutoPBKeyDisplay.Text = Settings.PBKey.Name 
local GERAimButton, GERAimStatus, GERAimKeyDisplay = createButton("GER Aim (Toggle)", Content, true) 
GERAimKeyDisplay.Text = Settings.GERKeyToggle.Name 
local PBModeButton, PBModeStatus = createButton("Block Mode", Content, false)
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
InfoText.Text = "RightShift - Menu | F/G - Toggle Features | X - Use GER Aim"
InfoText.TextColor3 = Color3.fromRGB(120, 120, 120)
InfoText.TextSize = 12
InfoText.Font = Enum.Font.Gotham
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.Parent = Footer

Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)

-- =========================================================================
--  UI HANDLERS
-- =========================================================================

local isListeningForKey = false
local keyToRebind = nil

local function updateToggleStatus(Status, settingState)
    Status.Text = settingState and "ON" or "OFF"
    Status.BackgroundColor3 = settingState and TornadoGray or Color3.fromRGB(50, 50, 55) 
    Status.TextColor3 = settingState and TextColorDark or Color3.fromRGB(200, 200, 200)
end

-- Логика изменения бинда для AutoPB
AutoPBButton.MouseButton1Click:Connect(function()
    if isListeningForKey then return end
    isListeningForKey = true
    keyToRebind = "PBKey"
    AutoPBKeyDisplay.Text = "[...]"
    AutoPBKeyDisplay.BackgroundColor3 = Color3.fromRGB(255, 150, 0) 
    AutoPBKeyDisplay.TextColor3 = TextColorDark
end)

-- Логика изменения бинда для GERAim
GERAimButton.MouseButton1Click:Connect(function()
    if isListeningForKey then return end
    isListeningForKey = true
    keyToRebind = "GERKeyToggle"
    GERAimKeyDisplay.Text = "[...]"
    GERAimKeyDisplay.BackgroundColor3 = Color3.fromRGB(255, 150, 0) 
    GERAimKeyDisplay.TextColor3 = TextColorDark
end)

PBModeButton.MouseButton1Click:Connect(function()
    Settings.PBMode = Settings.PBMode == 1 and 2 or 1
    local modeText = Settings.PBMode == 1 and "Normal" or "Interrupt"
    PBModeStatus.Text = modeText
    PBModeStatus.BackgroundColor3 = Settings.PBMode == 2 and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(50, 50, 55)
end)

-- =========================================================================
--  GAME LOGIC
-- =========================================================================

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
    pcall(function()
        if mode == 2 then
            remoteEvent:FireServer("InputEnded", {Input = Enum.KeyCode.E}); remoteEvent:FireServer("InputEnded", {Input = Enum.KeyCode.R}); task.wait(0.05)
        end
        remoteEvent:FireServer("StartBlocking"); task.wait(0.6); remoteEvent:FireServer("StopBlocking")
    end)
end

local function checkPBMove(player, move)
    if not Settings.AutoPB or not Attacks[move] then return end
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart"); local playerHRP = player:FindFirstChild("HumanoidRootPart")
    if not hrp or not playerHRP then return end
    local distance = (hrp.Position - playerHRP.Position).Magnitude
    if distance < 30 then task.wait(Attacks[move]); performBlock(Settings.PBMode) end
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
            if moveName then task.spawn(function() checkPBMove(player.Character, moveName) end) end
        end
    end)
end

for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then setupPlayer(player) end end
Players.PlayerAdded:Connect(function(player) player.CharacterAdded:Connect(function(character) task.wait(0.5); setupPlayer(player) end) end)

local aimConnection = nil
local originalCameraCFrame = nil 
local remoteEvent = game:GetService("Players").LocalPlayer.Character:WaitForChild("RemoteEvent")

-- =========================================================================
--  INPUT HANDLER (Custom Binds)
-- =========================================================================

UserInputService.InputBegan:Connect(function(input, processed)
    local KeyCode = input.KeyCode

    -- 1. ЛОГИКА ПРОСЛУШИВАНИЯ БИНДА (Key Listener)
    if isListeningForKey and not processed and KeyCode.Value ~= 0 and KeyCode ~= Enum.KeyCode.RightShift then
        
        Settings[keyToRebind] = KeyCode
        isListeningForKey = false
        
        local KeyDisplayElement
        if keyToRebind == "PBKey" then
            KeyDisplayElement = AutoPBKeyDisplay
        elseif keyToRebind == "GERKeyToggle" then
            KeyDisplayElement = GERAimKeyDisplay
        end
        
        KeyDisplayElement.Text = KeyCode.Name
        KeyDisplayElement.BackgroundColor3 = DarkAccent 
        KeyDisplayElement.TextColor3 = TornadoGray 
        
        keyToRebind = nil 
        return
    end

    -- 2. ЛОГИКА TOGGLE AUTO PB
    if KeyCode == Settings.PBKey and not isListeningForKey and not processed then
        Settings.AutoPB = not Settings.AutoPB
        updateToggleStatus(AutoPBStatus, Settings.AutoPB)
    end
    
    -- 3. ЛОГИКА TOGGLE GER AIM
    if KeyCode == Settings.GERKeyToggle and not isListeningForKey and not processed then
        Settings.GERAim = not Settings.GERAim
        updateToggleStatus(GERAimStatus, Settings.GERAim)
    end
    
    -- 4. ЛОГИКА GER AIM (X key - ACTION)
    if not processed and KeyCode == Enum.KeyCode.X and Settings.GERAim then
        local target = getClosestPlayer()
        if target and target.Character then
            local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
            
            if targetHRP then
                originalCameraCFrame = Camera.CFrame
                
                aimConnection = RunService.RenderStepped:Connect(function()
                    if targetHRP and targetHRP.Parent and (targetHRP.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= Settings.AimFOV then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHRP.Position)
                    else
                        if aimConnection then aimConnection:Disconnect(); aimConnection = nil end
                        if originalCameraCFrame then Camera.CFrame = originalCameraCFrame; originalCameraCFrame = nil end
                        
                        -- Если цель потеряна, отключаем Aim и отправляем InputEnded
                        if remoteEvent then
                            remoteEvent:FireServer("InputEnded", {Input = Enum.KeyCode.X})
                        end
                    end
                end)
                
                -- АКТИВАЦИЯ GER AIM: FireServer(InputBegan)
                if remoteEvent then
                    remoteEvent:FireServer("InputBegan", {Input = Enum.KeyCode.X})
                end
            end
        end
    end
    
    -- 5. TOGGLE MENU (RightShift)
    if KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.X then
        if aimConnection then aimConnection:Disconnect(); aimConnection = nil end
        if originalCameraCFrame then Camera.CFrame = originalCameraCFrame; originalCameraCFrame = nil end

        -- ОТКЛЮЧЕНИЕ GER AIM: FireServer(InputEnded)
        if remoteEvent then
            remoteEvent:FireServer("InputEnded", {Input = Enum.KeyCode.X})
        end
    end
end)

print("Mellstroy hub loaded! RightShift = toggle menu, F/G = toggle features, X = use GER Aim")
