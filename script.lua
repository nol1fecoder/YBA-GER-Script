local ButtonText = Instance.new("TextLabel")
    ButtonText.Size = UDim2.new(1, -90, 1, 0)
    ButtonText.Position = UDim2.new(0, 15, 0, 0)
    ButtonText.BackgroundTransparency = 1
    ButtonText.Text = text
    ButtonText.TextColor3 = TextColor
    ButtonText.TextSize = 13
    ButtonText.Font = Enum.Font.GothamBold
    ButtonText.TextXAlignment = Enum.TextXAlignment.Left
    ButtonText.Parent = Button

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(0, 65, 0, 28)
    Status.Position = UDim2.new(1, -75, 0.5, -14)
    Status.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Status.BackgroundTransparency = 0.3
    Status.BorderSizePixel = 0
    Status.Text = "OFF"
    Status.TextColor3 = Color3.fromRGB(180, 180, 190)
    Status.TextSize = 12
    Status.Font = Enum.Font.GothamBold
    Status.Parent = Button

    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = Status

    local StatusStroke = Instance.new("UIStroke")
    StatusStroke.Color = Color3.fromRGB(40, 40, 55)
    Statuslocal Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer 
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") 
local Camera = game.Workspace.CurrentCamera 

-- =========================================================================
--  КОНФИГУРАЦИЯ И СТИЛИ
-- =========================================================================

local Settings = {
    AutoPB = false,
    FullPassive = false,
    Aimlock = false,
    AutoM1Trade = false, 
    PBMode = 1,          
    TradeMode = 1,      
    AimFOV = 99,
    AimSmoothing = 0.08,
    
    -- НОВЫЕ ПАРАМЕТРЫ АНТИ-КИК
    PredictionEnabled = true,
    PredictionStrength = 0.18,
    WallCheck = true,
    StickyTarget = true,
    StickyDuration = 1.2,
    TargetPart = "Head",
    ShakeReduction = true,
    MaxAimSpeed = 45,
    NaturalSway = false,
    SwayAmount = 0.2,
}

local PrimaryColor = Color3.fromRGB(138, 43, 226)
local AccentColor = Color3.fromRGB(186, 85, 211) 
local BaseColor = Color3.fromRGB(10, 10, 15)
local SecondaryBase = Color3.fromRGB(20, 20, 30)
local TextColor = Color3.fromRGB(255, 255, 255)
local GlowColor = Color3.fromRGB(138, 43, 226)

local REMOTE_EVENT_NAME = "RemoteEvent" 

-- =========================================================================
--  FULL PASSIVE CONFIG
-- =========================================================================

local FULL_PASSIVE_CONFIG = {
    ["Liver_Shot_Sound"] = {Delay = 0.2, Type = "Block"}, 
    ["Jawbreaker_Sound"] = {Delay = 0.1, Type = "Interrupt"}, 
    ["Haymaker_Sound"] = {Delay = 0.01, Type = "NoBlock"}, 
    ["The World Finisher"] = {Delay = 0.45, Type = "Block"},
    ["punch_sound"] = {Delay = 0.05, Type = "Block"},
}

local M1_COUNTER = {} 

-- =========================================================================
--  УЛУЧШЕННАЯ AIM СИСТЕМА (АНТИ-КИК)
-- =========================================================================

local currentTarget = nil
local targetLockTime = 0
local lastAimUpdateTime = tick()
local aimVelocityBuffer = {}
local naturalSwayOffset = Vector3.new(0, 0, 0)

local function isWallBetween(origin, target)
    if not Settings.WallCheck then return false end
    
    local ray = Ray.new(origin, (target - origin))
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Players:GetPlayers()})
    
    return hit ~= nil
end

local function getTargetVelocity(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return Vector3.new(0, 0, 0) end
    
    return hrp.AssemblyVelocity or hrp.Velocity or Vector3.new(0, 0, 0)
end

local function predictTargetPosition(character)
    if not Settings.PredictionEnabled then 
        local part = character:FindFirstChild(Settings.TargetPart) or character:FindFirstChild("HumanoidRootPart")
        return part and part.Position or nil
    end
    
    local part = character:FindFirstChild(Settings.TargetPart) or character:FindFirstChild("HumanoidRootPart")
    if not part then return nil end
    
    local velocity = getTargetVelocity(character)
    local predictedPos = part.Position + (velocity * Settings.PredictionStrength)
    
    return predictedPos
end

local function getClosestPlayerAdvanced()
    local closest, shortestDist = nil, math.huge
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local dist = (myHRP.Position - rootPart.Position).Magnitude
                
                if dist < shortestDist and dist < Settings.AimFOV then
                    if not isWallBetween(Camera.CFrame.Position, rootPart.Position) then
                        closest, shortestDist = player, dist
                    end
                end
            end
        end
    end
    
    return closest
end

local function applySmoothAim(targetCFrame)
    local currentTime = tick()
    local deltaTime = currentTime - lastAimUpdateTime
    lastAimUpdateTime = currentTime
    
    if deltaTime > 0.1 then deltaTime = 0.1 end
    
    local currentCFrame = Camera.CFrame
    local targetDirection = (targetCFrame.Position - currentCFrame.Position).Unit
    local currentDirection = currentCFrame.LookVector
    
    local angle = math.acos(math.clamp(currentDirection:Dot(targetDirection), -1, 1))
    local maxAnglePerFrame = math.rad(Settings.MaxAimSpeed) * deltaTime
    
    if angle > maxAnglePerFrame then
        local adjustedSmoothing = Settings.AimSmoothing * (angle / maxAnglePerFrame)
        Settings.AimSmoothing = math.min(adjustedSmoothing, 0.5)
    end
    
    if Settings.NaturalSway then
        local swayX = math.sin(currentTime * 2) * Settings.SwayAmount
        local swayY = math.cos(currentTime * 1.5) * Settings.SwayAmount
        naturalSwayOffset = Vector3.new(swayX, swayY, 0)
    end
    
    local finalTarget = targetCFrame.Position + naturalSwayOffset
    local finalCFrame = CFrame.new(Camera.CFrame.Position, finalTarget)
    
    local tweenInfo = TweenInfo.new(
        Settings.AimSmoothing, 
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(Camera, tweenInfo, {CFrame = finalCFrame})
    tween:Play()
    
    return tween
end

local currentAimTween = nil

RunService.Heartbeat:Connect(function()
    if not Settings.Aimlock then 
        if currentAimTween then currentAimTween:Cancel() end
        currentTarget = nil
        targetLockTime = 0
        return 
    end
    
    if Settings.StickyTarget and currentTarget and currentTarget.Character then
        local humanoid = currentTarget.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            if tick() - targetLockTime < Settings.StickyDuration then
                local predictedPos = predictTargetPosition(currentTarget.Character)
                if predictedPos then
                    local lookAtCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
                    if currentAimTween then currentAimTween:Cancel() end
                    currentAimTween = applySmoothAim(lookAtCFrame)
                end
                return
            end
        end
    end
    
    local target = getClosestPlayerAdvanced()
    if not target or not target.Character then
        if currentAimTween then currentAimTween:Cancel() end
        currentTarget = nil
        return
    end
    
    if target ~= currentTarget then
        currentTarget = target
        targetLockTime = tick()
    end
    
    local predictedPos = predictTargetPosition(target.Character)
    if predictedPos then
        local lookAtCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
        if currentAimTween then currentAimTween:Cancel() end
        currentAimTween = applySmoothAim(lookAtCFrame)
    end
end)

-- =========================================================================
--  CORE REMOTE FUNCTIONS
-- =========================================================================

local function getRemote()
    local character = LocalPlayer.Character
    if not character then return nil end
    return character:FindFirstChild(REMOTE_EVENT_NAME)
end

local function performBlock(mode)
    local remoteEvent = getRemote()
    if not remoteEvent then return end
    
    pcall(function()
        if mode == 2 then 
            remoteEvent:FireServer("InputEnded", {Input = Enum.KeyCode.E})
            remoteEvent:FireServer("InputEnded", {Input = Enum.KeyCode.R})
            task.wait(0.02)
        end
        
        remoteEvent:FireServer("StartBlocking") 
        task.wait(0.6) 
        remoteEvent:FireServer("StopBlocking")
    end)
end

local function performM1()
    local remoteEvent = getRemote()
    if not remoteEvent then return end

    pcall(function()
        remoteEvent:FireServer("HoldAttack", {Bool = true, Type = "m1"})
        task.wait(0.05) 
        remoteEvent:FireServer("HoldAttack", {Bool = false, Type = "m1"})
    end)
end

local function stopBlock()
    local remoteEvent = getRemote()
    if not remoteEvent then return end
    remoteEvent:FireServer("StopBlocking")
end

-- =========================================================================
--  FULL PASSIVE LOGIC
-- =========================================================================

local function handlePassive(player, moveName)
    local config = FULL_PASSIVE_CONFIG[moveName]
    if not config then return end

    task.delay(config.Delay, function() 
        if config.Type == "Block" then
            performBlock(Settings.PBMode)
        elseif config.Type == "Interrupt" then
            performM1()
        elseif config.Type == "NoBlock" then
            stopBlock() 
        end
    end)
end

-- =========================================================================
--  TRADE LOGIC
-- =========================================================================

local function checkSound(soundID)
    local success, result = pcall(function()
        for _, v in pairs(game.ReplicatedStorage.Sounds:GetChildren()) do
            if v.SoundId and v.SoundId == soundID then return v.Name end
        end
    end)
    return success and result or nil
end

local function handleM1Trade(player)
    if not Settings.AutoM1Trade then 
        M1_COUNTER[player] = 0
        return 
    end
    
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    M1_COUNTER[player] = (M1_COUNTER[player] or 0) + 1
    local currentCount = M1_COUNTER[player]
    local isEnemyBlocking = humanoid.Blocking 

    if Settings.TradeMode == 1 then
        if currentCount <= 4 then performBlock(1)
        elseif currentCount == 5 then stopBlock(); performM1(); M1_COUNTER[player] = 0 
        end
    elseif Settings.TradeMode == 2 then
        if not isEnemyBlocking and currentCount >= 1 and currentCount <= 2 then
            stopBlock(); performM1(); M1_COUNTER[player] = 0
            return 
        end
        if currentCount == 3 or currentCount == 4 then performBlock(1)
        elseif currentCount == 5 then stopBlock(); performM1(); M1_COUNTER[player] = 0 
        end
    end
    
    task.delay(0.4, function()
        if M1_COUNTER[player] == currentCount then 
            M1_COUNTER[player] = 0
        end
    end)
end

local function setupPlayer(player)
    if not player.Character then return end
    M1_COUNTER[player] = 0
    
    player.Character.DescendantAdded:Connect(function(child)
        if child:IsA("Sound") and child.SoundId then
            local moveName = checkSound(child.SoundId)
            if not moveName then return end
            
            if Settings.FullPassive and FULL_PASSIVE_CONFIG[moveName] then
                 task.spawn(function()
                    handlePassive(player, moveName)
                 end)
            end

            if not Settings.FullPassive and Settings.AutoPB and FULL_PASSIVE_CONFIG[moveName] and FULL_PASSIVE_CONFIG[moveName].Type == "Block" then 
                 task.spawn(function() 
                    handlePassive(player, moveName) 
                 end) 
            end

            if Settings.AutoM1Trade and (string.find(moveName:lower(), "punch") or string.find(moveName:lower(), "hit") or moveName == "punch_sound") then
                 task.spawn(function()
                    handleM1Trade(player)
                 end)
            end
        end
    end)
end

for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then setupPlayer(player) end end
Players.PlayerAdded:Connect(function(player) player.CharacterAdded:Connect(function(character) task.wait(0.5); setupPlayer(player) end) end)

-- =========================================================================
--  GUI CREATION
-- =========================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GERMenu"
ScreenGui.Parent = PlayerGui 
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 450)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -225)
MainFrame.BackgroundColor3 = BaseColor
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = false

local MainShadow = Instance.new("ImageLabel")
MainShadow.Name = "Shadow"
MainShadow.Size = UDim2.new(1, 30, 1, 30)
MainShadow.Position = UDim2.new(0, -15, 0, -15)
MainShadow.BackgroundTransparency = 1
MainShadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
MainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.ImageTransparency = 0.5
MainShadow.ScaleType = Enum.ScaleType.Slice
MainShadow.SliceCenter = Rect.new(10, 10, 10, 10)
MainShadow.ZIndex = 0
MainShadow.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TitleBar.BackgroundTransparency = 0 
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleGlow = Instance.new("Frame")
TitleGlow.Size = UDim2.new(1, 0, 0, 2)
TitleGlow.Position = UDim2.new(0, 0, 1, 0)
TitleGlow.BackgroundColor3 = PrimaryColor
TitleGlow.BorderSizePixel = 0
TitleGlow.Parent = TitleBar

local TitleGlowGradient = Instance.new("UIGradient")
TitleGlowGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.8),
    NumberSequenceKeypoint.new(0.5, 0),
    NumberSequenceKeypoint.new(1, 0.8)
}
TitleGlowGradient.Rotation = 0
TitleGlowGradient.Parent = TitleGlow

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ GER CORE V2"
Title.TextColor3 = TextColor
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -100, 0, 15)
SubTitle.Position = UDim2.new(0, 20, 1, -18)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "ANTI-KICK SYSTEM"
SubTitle.TextColor3 = PrimaryColor
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -45, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
CloseButton.Text = "✕"
CloseButton.TextColor3 = TextColor
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}):Play()
end)

CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
end)

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = PrimaryColor
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.6
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -30, 1, -70)
ContentFrame.Position = UDim2.new(0, 15, 0, 60)
ContentFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
ContentFrame.BackgroundTransparency = 0.3
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = ContentFrame

local TabPanel = Instance.new("Frame")
TabPanel.Size = UDim2.new(0, 120, 1, -10)
TabPanel.Position = UDim2.new(0, 5, 0, 5)
TabPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
TabPanel.BackgroundTransparency = 0.2
TabPanel.BorderSizePixel = 0
TabPanel.Parent = ContentFrame

local TabPanelCorner = Instance.new("UICorner")
TabPanelCorner.CornerRadius = UDim.new(0, 8)
TabPanelCorner.Parent = TabPanel

local TabPanelList = Instance.new("UIListLayout")
TabPanelList.Parent = TabPanel
TabPanelList.Padding = UDim.new(0, 8)
TabPanelList.SortOrder = Enum.SortOrder.LayoutOrder
TabPanelList.FillDirection = Enum.FillDirection.Vertical 
TabPanelList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabPanelList.VerticalAlignment = Enum.VerticalAlignment.Top

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 8)
TabPadding.PaddingBottom = UDim.new(0, 8)
TabPadding.Parent = TabPanel

local ContentPanel = Instance.new("Frame")
ContentPanel.Size = UDim2.new(1, -135, 1, -10)
ContentPanel.Position = UDim2.new(0, 130, 0, 5)
ContentPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
ContentPanel.BackgroundTransparency = 0.2
ContentPanel.BorderSizePixel = 0
ContentPanel.Parent = ContentFrame
ContentPanel.ClipsDescendants = true

local ContentPanelCorner = Instance.new("UICorner")
ContentPanelCorner.CornerRadius = UDim.new(0, 8)
ContentPanelCorner.Parent = ContentPanel

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = PrimaryColor
ScrollFrame.Parent = ContentPanel

local ContentList = Instance.new("UIListLayout")
ContentList.Parent = ScrollFrame
ContentList.Padding = UDim.new(0, 10)
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.FillDirection = Enum.FillDirection.Vertical
ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Tabs = {
    Aim = Instance.new("Frame"),
    Combat = Instance.new("Frame"),
    Trade = Instance.new("Frame"),
    Passive = Instance.new("Frame") 
}

for name, frame in pairs(Tabs) do
    frame.Name = name
    frame.Size = UDim2.new(1, -20, 0, 500)
    frame.BackgroundTransparency = 1
    frame.Parent = ScrollFrame
    frame.Visible = false 

    local list = Instance.new("UIListLayout")
    list.Parent = frame
    list.Padding = UDim.new(0, 10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Button"
    TabButton.Size = UDim2.new(1, -10, 0, 42) 
    TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    TabButton.BackgroundTransparency = 0.3 
    TabButton.Text = name:upper()
    TabButton.TextColor3 = TextColor
    TabButton.TextSize = 13
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Parent = TabPanel

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton

    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = PrimaryColor
    TabStroke.Thickness = 1.5
    TabStroke.Transparency = 1
    TabStroke.Parent = TabButton
    TabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local TabGlow = Instance.new("Frame")
    TabGlow.Size = UDim2.new(0, 3, 0.7, 0)
    TabGlow.Position = UDim2.new(0, 0, 0.15, 0)
    TabGlow.BackgroundColor3 = PrimaryColor
    TabGlow.BorderSizePixel = 0
    TabGlow.Visible = false
    TabGlow.Parent = TabButton

    local TabGlowCorner = Instance.new("UICorner")
    TabGlowCorner.CornerRadius = UDim.new(1, 0)
    TabGlowCorner.Parent = TabGlow

    TabButton.MouseButton1Click:Connect(function()
        for _, otherFrame in pairs(Tabs) do otherFrame.Visible = false end
        frame.Visible = true

        for _, btn in pairs(TabPanel:GetChildren()) do
            if btn:IsA("TextButton") then
                TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = TextColor, BackgroundTransparency = 0.3}):Play()
                if btn:FindFirstChildOfClass("UIStroke") then 
                    btn:FindFirstChildOfClass("UIStroke").Transparency = 1 
                end
                local glow = btn:FindFirstChild("Frame")
                if glow then glow.Visible = false end
            end
        end
        TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = PrimaryColor, BackgroundTransparency = 0}):Play()
        if TabStroke then TabStroke.Transparency = 0.3 end
        if TabGlow then TabGlow.Visible = true end
    end)
end

Tabs.Aim.Visible = true
local DefaultTabButton = TabPanel:FindFirstChild("AimButton")
if DefaultTabButton then
    DefaultTabButton.TextColor3 = PrimaryColor
    DefaultTabButton.BackgroundTransparency = 0
    if DefaultTabButton:FindFirstChildOfClass("UIStroke") then 
        DefaultTabButton:FindFirstChildOfClass("UIStroke").Transparency = 0.3
    end
    local glow = DefaultTabButton:FindFirstChild("Frame")
    if glow then glow.Visible = true end
end

local function createButton(text, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 48) 
    Button.Position = UDim2.new(0, 10, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    Button.BackgroundTransparency = 0.2
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button

    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(40, 40, 55)
    ButtonStroke.Thickness = 1
    ButtonStroke.Transparency = 0.5
    ButtonStroke.Parent = Button
    ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local ButtonGlow = Instance.new("Frame")
    ButtonGlow.Size = UDim2.new(1, 0, 1, 0)
    ButtonGlow.BackgroundColor3 = PrimaryColor
    ButtonGlow.BackgroundTransparency = 1
    ButtonGlow.BorderSizePixel = 0
    ButtonGlow.ZIndex = 0
    ButtonGlow.Parent = Button

    local GlowCorner = Instance.new("UICorner")
    GlowCorner.CornerRadius = UDim.new(0, 10)
    GlowCorner.Parent = ButtonGlow

    local StatusStroke = Instance.new("UIStroke")
    StatusStroke.Color = Color3.fromRGB(40, 40, 55)
    StatusStroke.Thickness = 1
    StatusStroke.Transparency = 0.5
    StatusStroke.Parent = Status
    StatusStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        TweenService:Create(ButtonStroke, TweenInfo.new(0.15), {Transparency = 0.2, Color = PrimaryColor}):Play()
        TweenService:Create(ButtonGlow, TweenInfo.new(0.15), {BackgroundTransparency = 0.92}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
        TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {Transparency = 0.5, Color = Color3.fromRGB(40, 40, 55)}):Play()
        TweenService:Create(ButtonGlow, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    end)

    return Button, Status
end

local function createSlider(text, min, max, default, step, parent)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -20, 0, 68)
    Container.Position = UDim2.new(0, 10, 0, 0)
    Container.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    Container.BackgroundTransparency = 0.2
    Container.BorderSizePixel = 0
    Container.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Container

    local ContainerStroke = Instance.new("UIStroke")
    ContainerStroke.Color = Color3.fromRGB(40, 40, 55)
    ContainerStroke.Thickness = 1
    ContainerStroke.Transparency = 0.5
    ContainerStroke.Parent = Container
    ContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 0, 22)
    Label.Position = UDim2.new(0, 15, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = TextColor
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 55, 0, 22)
    ValueLabel.Position = UDim2.new(1, -65, 0, 8)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = string.format(step < 1 and "%.2f" or "%.0f", default)
    ValueLabel.TextColor3 = PrimaryColor
    ValueLabel.TextSize = 13
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = Container

    local SliderBack = Instance.new("Frame")
    SliderBack.Size = UDim2.new(1, -30, 0, 8)
    SliderBack.Position = UDim2.new(0, 15, 0, 42)
    SliderBack.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    SliderBack.BackgroundTransparency = 0.3
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
    
    local FillGradient = Instance.new("UIGradient")
    FillGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, PrimaryColor),
        ColorSequenceKeypoint.new(1, AccentColor)
    }
    FillGradient.Rotation = 0
    FillGradient.Parent = SliderFill

    return Container, ValueLabel, SliderBack, SliderFill, min, max, step
end

-- AIM TAB
local AimlockButton, AimlockStatus = createButton("Anti-Kick Aimlock (V2.0)", Tabs.Aim)
local FOVSlider, FOVValue, FOVBack, FOVFill, FOVMin, FOVMax, FOVStep = createSlider("FOV Radius (studs)", 30, 150, 99, 1, Tabs.Aim)
local SmoothingSlider, SmoothingValue, SmoothingBack, SmoothingFill, SmoothingMin, SmoothingMax, SmoothingStep = createSlider("Smoothing (sec)", 0.05, 0.5, 0.15, 0.01, Tabs.Aim)
local PredictionButton, PredictionStatus = createButton("Movement Prediction", Tabs.Aim)
local WallCheckButton, WallCheckStatus = createButton("Wall Check (Anti-Ban)", Tabs.Aim)
local StickyButton, StickyStatus = createButton("Sticky Target Lock", Tabs.Aim)

-- COMBAT TAB
local AutoPBButton, AutoPBStatus = createButton("Auto Perfect Block", Tabs.Combat)
local PBModeButton, PBModeStatus = createButton("Block Mode (Normal)", Tabs.Combat)

-- TRADE TAB
local AutoM1TradeButton, AutoM1TradeStatus = createButton("Auto M1 Trade", Tabs.Trade)
local TradeModeButton, TradeModeStatus = createButton("Trade Mode (Passive)", Tabs.Trade)

-- PASSIVE TAB
local FullPassiveButton, FullPassiveStatus = createButton("Full Passive (X/V/B)", Tabs.Passive)

-- =========================================================================
--  INPUT HANDLERS
-- =========================================================================

AimlockButton.MouseButton1Click:Connect(function()
    Settings.Aimlock = not Settings.Aimlock
    AimlockStatus.Text = Settings.Aimlock and "ON" or "OFF"
    AimlockStatus.BackgroundColor3 = Settings.Aimlock and PrimaryColor or SecondaryBase
    AimlockStatus.BackgroundTransparency = Settings.Aimlock and 0.2 or 0.5
    AimlockStatus.TextColor3 = Settings.Aimlock and BaseColor or TextColor
end)

PredictionButton.MouseButton1Click:Connect(function()
    Settings.PredictionEnabled = not Settings.PredictionEnabled
    PredictionStatus.Text = Settings.PredictionEnabled and "ON" or "OFF"
    PredictionStatus.BackgroundColor3 = Settings.PredictionEnabled and PrimaryColor or SecondaryBase
    PredictionStatus.BackgroundTransparency = Settings.PredictionEnabled and 0.2 or 0.5
    PredictionStatus.TextColor3 = Settings.PredictionEnabled and BaseColor or TextColor
end)

WallCheckButton.MouseButton1Click:Connect(function()
    Settings.WallCheck = not Settings.WallCheck
    WallCheckStatus.Text = Settings.WallCheck and "ON" or "OFF"
    WallCheckStatus.BackgroundColor3 = Settings.WallCheck and PrimaryColor or SecondaryBase
    WallCheckStatus.BackgroundTransparency = Settings.WallCheck and 0.2 or 0.5
    WallCheckStatus.TextColor3 = Settings.WallCheck and BaseColor or TextColor
end)

StickyButton.MouseButton1Click:Connect(function()
    Settings.StickyTarget = not Settings.StickyTarget
    StickyStatus.Text = Settings.StickyTarget and "ON" or "OFF"
    StickyStatus.BackgroundColor3 = Settings.StickyTarget and PrimaryColor or SecondaryBase
    StickyStatus.BackgroundTransparency = Settings.StickyTarget and 0.2 or 0.5
    StickyStatus.TextColor3 = Settings.StickyTarget and BaseColor or TextColor
end)

AutoPBButton.MouseButton1Click:Connect(function()
    Settings.AutoPB = not Settings.AutoPB
    AutoPBStatus.Text = Settings.AutoPB and "ON" or "OFF"
    AutoPBStatus.BackgroundColor3 = Settings.AutoPB and PrimaryColor or SecondaryBase 
    AutoPBStatus.BackgroundTransparency = Settings.AutoPB and 0.2 or 0.5
    AutoPBStatus.TextColor3 = Settings.AutoPB and BaseColor or TextColor
    if Settings.AutoPB and Settings.FullPassive then
        Settings.FullPassive = false
        FullPassiveStatus.Text = "OFF"
        FullPassiveStatus.BackgroundColor3 = SecondaryBase
        FullPassiveStatus.BackgroundTransparency = 0.5
        FullPassiveStatus.TextColor3 = TextColor
    end
end)

FullPassiveButton.MouseButton1Click:Connect(function()
    Settings.FullPassive = not Settings.FullPassive
    FullPassiveStatus.Text = Settings.FullPassive and "ON" or "OFF"
    FullPassiveStatus.BackgroundColor3 = Settings.FullPassive and PrimaryColor or SecondaryBase 
    FullPassiveStatus.BackgroundTransparency = Settings.FullPassive and 0.2 or 0.5
    FullPassiveStatus.TextColor3 = Settings.FullPassive and BaseColor or TextColor
    if Settings.FullPassive then
        Settings.AutoPB = false
        AutoPBStatus.Text = "OFF"
        AutoPBStatus.BackgroundColor3 = SecondaryBase
        AutoPBStatus.BackgroundTransparency = 0.5
        AutoPBStatus.TextColor3 = TextColor
    end
end)

AutoM1TradeButton.MouseButton1Click:Connect(function()
    Settings.AutoM1Trade = not Settings.AutoM1Trade
    AutoM1TradeStatus.Text = Settings.AutoM1Trade and "ON" or "OFF"
    AutoM1TradeStatus.BackgroundColor3 = Settings.AutoM1Trade and PrimaryColor or SecondaryBase 
    AutoM1TradeStatus.BackgroundTransparency = Settings.AutoM1Trade and 0.2 or 0.5
    AutoM1TradeStatus.TextColor3 = Settings.AutoM1Trade and BaseColor or TextColor
    if not Settings.AutoM1Trade then 
        for player, _ in pairs(M1_COUNTER) do 
            M1_COUNTER[player] = 0 
        end
    end
end)

TradeModeButton.MouseButton1Click:Connect(function()
    Settings.TradeMode = Settings.TradeMode == 1 and 2 or 1
    local modeText = Settings.TradeMode == 1 and "Passive" or "Aggressive"
    TradeModeButton:FindFirstChildOfClass("TextLabel").Text = "Trade Mode (" .. modeText .. ")"
    TradeModeStatus.Text = Settings.TradeMode == 1 and "PASSIVE" or "AGGRESSIVE"
    TradeModeStatus.BackgroundColor3 = Settings.TradeMode == 2 and PrimaryColor or SecondaryBase 
    TradeModeStatus.BackgroundTransparency = 0.2
    TradeModeStatus.TextColor3 = Settings.TradeMode == 2 and BaseColor or TextColor
end)

PBModeButton.MouseButton1Click:Connect(function()
    Settings.PBMode = Settings.PBMode == 1 and 2 or 1
    local modeText = Settings.PBMode == 1 and "Normal" or "Interrupt"
    PBModeButton:FindFirstChildOfClass("TextLabel").Text = "Block Mode (" .. modeText .. ")"
    PBModeStatus.Text = Settings.PBMode == 1 and "NORMAL" or "INTERRUPT"
    PBModeStatus.BackgroundColor3 = Settings.PBMode == 2 and PrimaryColor or SecondaryBase 
    PBModeStatus.BackgroundTransparency = 0.2
    PBModeStatus.TextColor3 = Settings.PBMode == 2 and BaseColor or TextColor
end)

local function handleSliderInput(sliderBack, sliderFill, valueLabel, minVal, maxVal, settingKey, step)
    local dragging = false
    local function updateValue(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
            local rawValue = minVal + (maxVal - minVal) * pos
            local steppedValue = rawValue
            
            if step < 1 then 
                steppedValue = math.floor(rawValue / step + 0.5) * step 
            else
                steppedValue = math.floor(rawValue / step) * step 
            end
            
            Settings[settingKey] = steppedValue
            valueLabel.Text = string.format(step < 1 and "%.2f" or "%.0f", steppedValue) 

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
handleSliderInput(SmoothingBack, SmoothingFill, SmoothingValue, SmoothingMin, SmoothingMax, "AimSmoothing", 0.01)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible and currentAimTween then
            currentAimTween:Cancel()
        end
    end
end)

ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 20)
end)

if PredictionStatus then
    PredictionStatus.Text = Settings.PredictionEnabled and "ON" or "OFF"
    PredictionStatus.BackgroundColor3 = Settings.PredictionEnabled and PrimaryColor or SecondaryBase
    PredictionStatus.BackgroundTransparency = Settings.PredictionEnabled and 0.2 or 0.5
    PredictionStatus.TextColor3 = Settings.PredictionEnabled and BaseColor or TextColor
end

if WallCheckStatus then
    WallCheckStatus.Text = Settings.WallCheck and "ON" or "OFF"
    WallCheckStatus.BackgroundColor3 = Settings.WallCheck and PrimaryColor or SecondaryBase
    WallCheckStatus.BackgroundTransparency = Settings.WallCheck and 0.2 or 0.5
    WallCheckStatus.TextColor3 = Settings.WallCheck and BaseColor or TextColor
end

if StickyStatus then
    StickyStatus.Text = Settings.StickyTarget and "ON" or "OFF"
    StickyStatus.BackgroundColor3 = Settings.StickyTarget and PrimaryColor or SecondaryBase
    StickyStatus.BackgroundTransparency = Settings.StickyTarget and 0.2 or 0.5
    StickyStatus.TextColor3 = Settings.StickyTarget and BaseColor or TextColor
end

print("==============================================")
print("GER GOLDEN CORE V2.0 LOADED!")
print("ANTI-KICK AIM SYSTEM ACTIVE")
print("==============================================")
print("Features:")
print("✓ Movement Prediction")
print("✓ Wall Check (Anti-Ban)")
print("✓ Sticky Target Lock")
print("✓ Natural Sway Movement")
print("✓ Speed Limiting (Anti-Detection)")
print("==============================================")
print("Press RightShift to toggle menu")
print("==============================================)")
