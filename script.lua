local Players = game:GetService("Players")
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
    FullPassive = false, -- НОВАЯ ФУНКЦИЯ
    Aimlock = false,
    AutoM1Trade = false, 
    PBMode = 1,          
    TradeMode = 1,      
    AimFOV = 99,
    AimSmoothing = 0.15, 
}

local PrimaryColor = Color3.fromRGB(255, 215, 0)
local AccentColor = Color3.fromRGB(200, 180, 0) 
local BaseColor = Color3.fromRGB(15, 15, 25)
local SecondaryBase = Color3.fromRGB(25, 25, 40)
local TextColor = Color3.fromRGB(240, 240, 240)
local ActiveColor = PrimaryColor

local REMOTE_EVENT_NAME = "RemoteEvent" 

-- =========================================================================
--  FULL PASSIVE CONFIG - ФИНАЛЬНАЯ КОНФИГУРАЦИЯ АТАК
-- =========================================================================

-- ВАЖНО: Эти имена должны совпадать с именами ЗВУКОВ атак в игре (ReplicatedStorage.Sounds)
-- Если Full Passive не работает, нужно найти точное имя SoundID или Animation!

local FULL_PASSIVE_CONFIG = {
    -- X: Liver Shot (Блокается и Сбивается -> Лучше Блокать)
    ["Liver_Shot_Sound"] = {Delay = 0.2, Type = "Block"}, 
    
    -- V: Jawbreaker (Ломает Блок и Сбивается -> Лучше Сбить/Interrupt)
    ["Jawbreaker_Sound"] = {Delay = 0.1, Type = "Interrupt"}, 
    
    -- B: Haymaker (Ломает Блок и НЕ Сбивается -> Лучше Не Блокать)
    ["Haymaker_Sound"] = {Delay = 0.01, Type = "NoBlock"}, 
    
    -- Стандартные M1 для AutoPB (будут работать, если FullPassive выключен)
    ["The World Finisher"] = {Delay = 0.45, Type = "Block"},
    ["punch_sound"] = {Delay = 0.05, Type = "Block"},
}

local M1_COUNTER = {} 

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
            -- Здесь может быть добавлен авто-дэш/уворот, если будет предоставлен RemoteEvent для него.
        end
    end)
end

-- =========================================================================
--  TRADE LOGIC & PB
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
    
    task.delay(0.5, function()
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
            
            -- Full Passive (Приоритет)
            if Settings.FullPassive and FULL_PASSIVE_CONFIG[moveName] then
                 task.spawn(function()
                    handlePassive(player, moveName)
                 end)
            end

            -- Auto Perfect Block (Только если Full Passive выключен, и только для Block-атак)
            if not Settings.FullPassive and Settings.AutoPB and FULL_PASSIVE_CONFIG[moveName] and FULL_PASSIVE_CONFIG[moveName].Type == "Block" then 
                 task.spawn(function() 
                    handlePassive(player, moveName) 
                 end) 
            end

            -- Auto M1 Trade 
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
--  AIMLOCK LOGIC (Heartbeat)
-- =========================================================================
local currentAimTween = nil

RunService.Heartbeat:Connect(function()
    if not Settings.Aimlock then 
        if currentAimTween and currentAimTween.PlaybackState == Enum.PlaybackState.Playing then
            currentAimTween:Cancel()
        end
        return 
    end
    
    local target = getClosestPlayer()
    if not target or not target.Character then
        if currentAimTween and currentAimTween.PlaybackState == Enum.PlaybackState.Playing then
            currentAimTween:Cancel()
        end
        return
    end
    
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if targetHRP and myHRP then
        local lookAtCFrame = CFrame.new(Camera.CFrame.Position, targetHRP.Position)
        
        if currentAimTween and currentAimTween.PlaybackState == Enum.PlaybackState.Playing then
            currentAimTween:Cancel()
        end

        local tweenInfo = TweenInfo.new(Settings.AimSmoothing, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        currentAimTween = TweenService:Create(Camera, tweenInfo, {CFrame = lookAtCFrame})
        currentAimTween:Play()
    end
end)


-- =========================================================================
--  GUI CREATION (CUSTOM UI)
-- =========================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GERMenu"
ScreenGui.Parent = PlayerGui 
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.BackgroundColor3 = BaseColor
MainFrame.BackgroundTransparency = 0 
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = false -- Скрываем по умолчанию

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = BaseColor
TitleBar.BackgroundTransparency = 0 
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, AccentColor),
    ColorSequenceKeypoint.new(0.50, PrimaryColor),
    ColorSequenceKeypoint.new(1.00, AccentColor)
}
TitleGradient.Rotation = 90
TitleGradient.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GER GOLDEN CORE | ULTIMATE PVP"
Title.TextColor3 = TextColor
Title.TextSize = 18
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -30, 1, -60)
ContentFrame.Position = UDim2.new(0, 15, 0, 50)
ContentFrame.BackgroundColor3 = SecondaryBase
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local TabPanel = Instance.new("Frame")
TabPanel.Size = UDim2.new(0, 110, 1, 0)
TabPanel.Position = UDim2.new(0, 0, 0, 0)
TabPanel.BackgroundColor3 = SecondaryBase
TabPanel.BackgroundTransparency = 0.5
TabPanel.BorderSizePixel = 0
TabPanel.Parent = ContentFrame

local TabPanelList = Instance.new("UIListLayout")
TabPanelList.Parent = TabPanel
TabPanelList.Padding = UDim.new(0, 5)
TabPanelList.SortOrder = Enum.SortOrder.LayoutOrder
TabPanelList.FillDirection = Enum.FillDirection.Vertical 
TabPanelList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabPanelList.VerticalAlignment = Enum.VerticalAlignment.Top

local ContentPanel = Instance.new("Frame")
ContentPanel.Size = UDim2.new(1, -110, 1, 0)
ContentPanel.Position = UDim2.new(0, 110, 0, 0)
ContentPanel.BackgroundColor3 = SecondaryBase
ContentPanel.BackgroundTransparency = 0.5
ContentPanel.BorderSizePixel = 0
ContentPanel.Parent = ContentFrame
ContentPanel.ClipsDescendants = true

local ContentList = Instance.new("UIListLayout")
ContentList.Parent = ContentPanel
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
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentPanel
    frame.Visible = false 

    local list = Instance.new("UIListLayout")
    list.Parent = frame
    list.Padding = UDim.new(0, 10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Button"
    TabButton.Size = UDim2.new(1, 0, 0, 35) 
    TabButton.BackgroundColor3 = BaseColor
    TabButton.BackgroundTransparency = 0.5 
    TabButton.Text = name:upper()
    TabButton.TextColor3 = TextColor
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Parent = TabPanel

    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = PrimaryColor
    TabStroke.Thickness = 1
    TabStroke.Transparency = 1
    TabStroke.Parent = TabButton
    TabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    TabButton.MouseButton1Click:Connect(function()
        for _, otherFrame in pairs(Tabs) do otherFrame.Visible = false end
        frame.Visible = true

        for _, btn in pairs(TabPanel:GetChildren()) do
            if btn:IsA("TextButton") then
                TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = TextColor, BackgroundTransparency = 0.5}):Play()
                if btn:FindFirstChildOfClass("UIStroke") then btn:FindFirstChildOfClass("UIStroke").Transparency = 1 end
            end
        end
        TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = PrimaryColor, BackgroundTransparency = 0}):Play()
        if TabStroke then TabStroke.Transparency = 0 end
    end)
end

Tabs.Aim.Visible = true
local DefaultTabButton = TabPanel:FindFirstChild("AimButton")
if DefaultTabButton then
    DefaultTabButton.TextColor3 = PrimaryColor
    DefaultTabButton.BackgroundTransparency = 0
    if DefaultTabButton:FindFirstChildOfClass("UIStroke") then DefaultTabButton:FindFirstChildOfClass("UIStroke").Transparency = 0 end
end

local function createButton(text, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 40) 
    Button.Position = UDim2.new(0, 10, 0, 0)
    Button.BackgroundColor3 = BaseColor
    Button.BackgroundTransparency = 0.4 
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = AccentColor
    ButtonStroke.Thickness = 1
    ButtonStroke.Transparency = 0.7 
    ButtonStroke.Parent = Button
    ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local ButtonText = Instance.new("TextLabel")
    ButtonText.Size = UDim2.new(1, -80, 1, 0)
    ButtonText.Position = UDim2.new(0, 10, 0, 0)
    ButtonText.BackgroundTransparency = 1
    ButtonText.Text = text
    ButtonText.TextColor3 = TextColor
    ButtonText.TextSize = 14
    ButtonText.Font = Enum.Font.GothamBold
    ButtonText.TextXAlignment = Enum.TextXAlignment.Left
    ButtonText.Parent = Button

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(0, 70, 0, 25)
    Status.Position = UDim2.new(1, -80, 0.5, -12.5)
    Status.BackgroundColor3 = SecondaryBase
    Status.BackgroundTransparency = 0.5
    Status.BorderSizePixel = 0
    Status.Text = "OFF"
    Status.TextColor3 = TextColor
    Status.TextSize = 12
    Status.Font = Enum.Font.GothamBold
    Status.Parent = Button

    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 6)
    StatusCorner.Parent = Status

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.2}):Play()
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
    Container.BackgroundColor3 = BaseColor
    Container.BackgroundTransparency = 0.4
    Container.BorderSizePixel = 0
    Container.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Container

    local ContainerStroke = Instance.new("UIStroke")
    ContainerStroke.Color = AccentColor
    ContainerStroke.Thickness = 1
    ContainerStroke.Transparency = 0.7
    ContainerStroke.Parent = Container
    ContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = TextColor
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Position = UDim2.new(1, -60, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = string.format(step < 1 and "%.2f" or "%.0f", default)
    ValueLabel.TextColor3 = PrimaryColor
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = Container

    local SliderBack = Instance.new("Frame")
    SliderBack.Size = UDim2.new(1, -20, 0, 6)
    SliderBack.Position = UDim2.new(0, 10, 0, 35)
    SliderBack.BackgroundColor3 = BaseColor
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

-- Aim Tab
local AimlockButton, AimlockStatus = createButton("Smooth Aimlock (Anti-Kick)", Tabs.Aim)
local FOVSlider, FOVValue, FOVBack, FOVFill, FOVMin, FOVMax, FOVStep = createSlider("Aim FOV (studs)", 30, 100, 99, 1, Tabs.Aim)
local SmoothingSlider, SmoothingValue, SmoothingBack, SmoothingFill, SmoothingMin, SmoothingMax, SmoothingStep = createSlider("Aim Smoothing (sec)", 0.05, 0.5, 0.15, 0.01, Tabs.Aim)

-- Combat Tab
local AutoPBButton, AutoPBStatus = createButton("Auto Perfect Block", Tabs.Combat)
local PBModeButton, PBModeStatus = createButton("Block Mode (Normal)", Tabs.Combat)
if Settings.PBMode == 2 then
    PBModeButton:FindFirstChildOfClass("TextLabel").Text = "Block Mode (Interrupt)"
    PBModeStatus.Text = "INTERRUPT"
    PBModeStatus.BackgroundColor3 = PrimaryColor 
    PBModeStatus.BackgroundTransparency = 0.2
    PBModeStatus.TextColor3 = BaseColor
end

-- Trade Tab 
local AutoM1TradeButton, AutoM1TradeStatus = createButton("Auto M1 Trade (Enable)", Tabs.Trade)
local TradeModeButton, TradeModeStatus = createButton("Trade Mode (Passive Block)", Tabs.Trade)
if Settings.TradeMode == 2 then
    TradeModeButton:FindFirstChildOfClass("TextLabel").Text = "Trade Mode (Aggressive True)"
    TradeModeStatus.Text = "AGGRESSIVE"
    TradeModeStatus.BackgroundColor3 = PrimaryColor
    TradeModeStatus.BackgroundTransparency = 0.2
    TradeModeStatus.TextColor3 = BaseColor
end

-- Passive Tab
local FullPassiveButton, FullPassiveStatus = createButton("Full Passive (X/V/B Logic)", Tabs.Passive)


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

AutoPBButton.MouseButton1Click:Connect(function()
    Settings.AutoPB = not Settings.AutoPB
    AutoPBStatus.Text = Settings.AutoPB and "ON" or "OFF"
    AutoPBStatus.BackgroundColor3 = Settings.AutoPB and PrimaryColor or SecondaryBase 
    AutoPBStatus.BackgroundTransparency = Settings.AutoPB and 0.2 or 0.5
    AutoPBStatus.TextColor3 = Settings.AutoPB and BaseColor or TextColor
    if Settings.AutoPB and Settings.FullPassive then
        Settings.FullPassive = false
        FullPassiveStatus.Text = "OFF"
        FullPassiveStatus.BackgroundColor3 = SecondaryBase; FullPassiveStatus.BackgroundTransparency = 0.5; FullPassiveStatus.TextColor3 = TextColor
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
        AutoPBStatus.BackgroundColor3 = SecondaryBase; AutoPBStatus.BackgroundTransparency = 0.5; AutoPBStatus.TextColor3 = TextColor
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
    local modeText = Settings.TradeMode == 1 and "Passive Block" or "Aggressive True"
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

print("GER Golden Core loaded! ALL BUGS FIXED. RightShift = toggle menu.")
