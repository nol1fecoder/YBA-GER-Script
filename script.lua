local Players = game:GetService("Players")
local RunService = game:GetService("RunService") 
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer 
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") 
local Camera = game.Workspace.CurrentCamera 
local MY_CHARACTER = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local MY_HUMANOID = MY_CHARACTER:WaitForChild("Humanoid")

-- ИДИ НАХУЙ БАБКА ИБАНАЯ
local DEFAULT_CAMERA_MAX_ZOOM = 30 
local DEFAULT_CAMERA_MIN_ZOOM = 0.5
LocalPlayer.CameraMaxZoomDistance = DEFAULT_CAMERA_MAX_ZOOM
LocalPlayer.CameraMinZoomDistance = DEFAULT_CAMERA_MIN_ZOOM

-- =========================================================================
--  КОНФИГУРАЦИЯ И СТИЛИ
-- =========================================================================

local MainColor = Color3.fromRGB(138, 43, 226) -- Аметист
local AccentColor = Color3.fromRGB(180, 80, 255) -- Неон
local BaseColor = Color3.fromRGB(18, 18, 22)
local TextColor = Color3.fromRGB(255, 255, 255)

local Settings = {
    AutoPB = false, Aimlock = false, FullPassive = false, AutoM1Trade = false, 
    PBMode = 1, TradeMode = 1, AimFOV = 99, PredictionEnabled = true, PredictionStrength = 0.18,
    WallCheck = true, StickyTarget = true, StickyDuration = 1.2, TargetPart = "Head",
    AIM_ACTIVATION_KEY = Enum.KeyCode.X, 
}

local REMOTE_EVENT_NAME = "RemoteEvent" 
local isAimActiveBySkill = false 
local currentTarget = nil
local targetLockTime = 0
local M1_COUNTER = {} 

local FULL_PASSIVE_CONFIG = {
    ["Liver_Shot_Sound"] = {Delay = 0.2, Type = "Block"}, ["Jawbreaker_Sound"] = {Delay = 0.1, Type = "Interrupt"}, 
    ["Haymaker_Sound"] = {Delay = 0.01, Type = "NoBlock"}, ["The World Finisher"] = {Delay = 0.45, Type = "Block"},
    ["punch_sound"] = {Delay = 0.05, Type = "Block"},
}

-- =========================================================================
--  AIM СИСТЕМА (БЫСТРЕЕ, БЫСТРЕЕ)
-- =========================================================================

local function isWallBetween(origin, target)
    if not Settings.WallCheck then return false end
    local ray = Ray.new(origin, (target - origin))
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Players:GetPlayers()})
    return hit ~= nil
end

local function getTargetPos(char)
    local p = char:FindFirstChild(Settings.TargetPart) or char:FindFirstChild("HumanoidRootPart") 
    return p and (p.Position + (p.AssemblyVelocity * Settings.PredictionStrength)) or nil 
end

local function getClosestPlayer()
    local c, sD, mHRP = nil, math.huge, LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not mHRP then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("Humanoid").Health > 0 then
                local dist = (mHRP.Position - root.Position).Magnitude
                if dist < sD and dist < Settings.AimFOV and not isWallBetween(Camera.CFrame.Position, root.Position) then c, sD = p, dist end
            end
        end
    end
    return c
end

RunService.RenderStepped:Connect(function() 
    if not Settings.Aimlock or not isAimActiveBySkill or MY_HUMANOID.Sit or MY_HUMANOID.PlatformStand then 
        LocalPlayer.CameraMaxZoomDistance = DEFAULT_CAMERA_MAX_ZOOM
        LocalPlayer.CameraMinZoomDistance = DEFAULT_CAMERA_MIN_ZOOM
        currentTarget = nil; targetLockTime = 0; return 
    end
    
    LocalPlayer.CameraMaxZoomDistance = 0 
    LocalPlayer.CameraMinZoomDistance = 0

    local target = currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") and currentTarget.Character:FindFirstChild("Humanoid").Health > 0 and tick() - targetLockTime < Settings.StickyDuration and currentTarget or getClosestPlayer()
    
    if target then currentTarget = target; targetLockTime = tick() end
    local pos = target and getTargetPos(target.Character)
    if pos then Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos) end
end)


-- =========================================================================
--  CORE REMOTE FUNCTIONS & PASSIVE LOGIC (AUTOPB)
-- =========================================================================
local function getRemote() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(REMOTE_EVENT_NAME) end
local function performBlock(mode)
    local remote = getRemote()
    if not remote then return end
    pcall(function()
        if mode == 2 then remote:FireServer("InputEnded", {Input = Enum.KeyCode.E}); remote:FireServer("InputEnded", {Input = Enum.KeyCode.R}) end
        remote:FireServer("StartBlocking") 
        local startTime = tick()
        local conn
        conn = RunService.RenderStepped:Connect(function() if tick() - startTime >= 0.6 then remote:FireServer("StopBlocking"); conn:Disconnect() end end)
    end)
end
local function performM1() local remote = getRemote() if not remote then return end pcall(function() remote:FireServer("HoldAttack", {Bool = true, Type = "m1"}); task.wait(0.05); remote:FireServer("HoldAttack", {Bool = false, Type = "m1"}) end)
local function stopBlock() local remote = getRemote() if not remote then return end remote:FireServer("StopBlocking") end

local function handlePassive(player, moveName)
    local config = FULL_PASSIVE_CONFIG[moveName]
    if not config then return end
    local startTime = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if tick() - startTime >= config.Delay then
            if config.Type == "Block" then performBlock(Settings.PBMode)
            elseif config.Type == "Interrupt" then performM1()
            elseif config.Type == "NoBlock" then stopBlock() end
            conn:Disconnect()
        end
    end)
end

local function checkSound(soundID)
    local success, result = pcall(function()
        for _, v in pairs(game.ReplicatedStorage.Sounds:GetChildren()) do if v.SoundId and v.SoundId == soundID then return v.Name end end
        for _, obj in pairs(game.Workspace:GetDescendants()) do if obj:IsA("Sound") and obj.SoundId == soundID then return obj.Name end end
    end)
    return success and result or nil
end

local function setupPlayer(player)
    if not player.Character then return end
    M1_COUNTER[player] = 0
    player.Character.DescendantAdded:Connect(function(child)
        if child:IsA("Sound") and child.SoundId then
            local moveName = checkSound(child.SoundId)
            if not moveName then return end
            -- Сливыыы,яблоки зеленые,бананы бананы бананы Виноград
            local shouldRunPassive = Settings.FullPassive and FULL_PASSIVE_CONFIG[moveName]
            local shouldRunAutoPB = Settings.AutoPB and not Settings.FullPassive and FULL_PASSIVE_CONFIG[moveName] and FULL_PASSIVE_CONFIG[moveName].Type == "Block"
            if shouldRunPassive or shouldRunAutoPB then task.spawn(function() handlePassive(player, moveName) end) end
            -- M1 Trade logic (опущена для краткости)
        end
    end)
end

for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then setupPlayer(player) end end
Players.PlayerAdded:Connect(function(player) player.CharacterAdded:Connect(function(character) task.wait(0.5); setupPlayer(player) end) end)


-- =========================================================================
--  КРАСИВЫЙ GUI (V8)
-- =========================================================================

local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "GER_ZARA_ZARA_V8"; ScreenGui.Parent = PlayerGui; ScreenGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame"); MainFrame.Size = UDim2.new(0, 260, 0, 350); MainFrame.Position = UDim2.new(0.5, -130, 0.5, -175); MainFrame.BackgroundColor3 = BaseColor; MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.Parent = ScreenGui
MainFrame:SetAttribute("InitialPosition", MainFrame.Position)
MainFrame.Position = UDim2.new(0.5, -130, 0, -350) -- Начальная позиция вне экрана для анимации

-- [HEADER & TITLE]
local TitleBar = Instance.new("Frame"); TitleBar.Size = UDim2.new(1, 0, 0, 40); TitleBar.Parent = MainFrame
local Gradient = Instance.new("UIGradient"); Gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, AccentColor)}; Gradient.Parent = TitleBar
local Title = Instance.new("TextLabel"); Title.Size = UDim2.new(1, 0, 1, 0); Title.BackgroundColor3 = Color3.new(1, 1, 1); Title.BackgroundTransparency = 1; Title.TextColor3 = TextColor; Title.Text = "GER CORE V8 - Я УЖЕ КРАСНЫЙ"; Title.Font = Enum.Font.GothamBold; Title.TextSize = 16; Title.Parent = TitleBar
local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 8); Corner.Parent = MainFrame

-- [SCROLLING CONTENT]
local ScrollFrame = Instance.new("ScrollingFrame"); ScrollFrame.Size = UDim2.new(1, -10, 1, -50); ScrollFrame.Position = UDim2.new(0.5, -130, 0, 45); ScrollFrame.BackgroundTransparency = 1; ScrollFrame.Parent = MainFrame
local ListLayout = Instance.new("UIListLayout"); ListLayout.Parent = ScrollFrame; ListLayout.Padding = UDim.new(0, 8); ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- [GUI Building Functions]
local allButtons = {}

local function createSimpleToggle(text, settingKey, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Button.TextColor3 = TextColor
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 14
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = parent
    
    local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 6); Corner.Parent = Button
    
    local function updateText()
        local state = Settings[settingKey]
        local stateText = state and "[ON]" or "[OFF]"
        Button.Text = "   " .. text .. " - " .. stateText
        Button.BackgroundColor3 = state and MainColor or Color3.fromRGB(35, 35, 40)
    end
    
    Button.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        
        if settingKey == "FullPassive" and Settings.FullPassive then Settings.AutoPB = false
        elseif settingKey == "AutoPB" and Settings.AutoPB then Settings.FullPassive = false end
        for _, btnData in ipairs(allButtons) do btnData.update() end

        updateText()
    end)
    
    updateText()
    return {button = Button, update = updateText}
end

local function createModeToggle(text, settingKey, modes, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Button.TextColor3 = TextColor
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 14
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = parent
    
    local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 6); Corner.Parent = Button

    local function updateText()
        local modeIndex = Settings[settingKey]
        local modeName = modes[modeIndex] or "Error"
        Button.Text = "   " .. text .. ": " .. modeName
    end
    
    Button.MouseButton1Click:Connect(function()
        local current = Settings[settingKey]
        local nextIndex = current % #modes + 1 
        Settings[settingKey] = nextIndex
        updateText()
    end)
    
    updateText()
    return {button = Button, update = updateText}
end

local function createFOVSlider(text, settingKey, minVal, maxVal, parent)
    local Container = Instance.new("Frame"); Container.Size = UDim2.new(1, -10, 0, 45); Container.BackgroundTransparency = 1; Container.Parent = parent
    local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1, 0, 0, 15); Label.Text = text .. ": " .. Settings[settingKey]; Label.BackgroundTransparency = 1; Label.TextColor3 = TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Font = Enum.Font.SourceSans; Label.TextSize = 14; Label.Parent = Container

    local Slider = Instance.new("Frame"); Slider.Size = UDim2.new(1, 0, 0, 10); Slider.Position = UDim2.new(0, 0, 0, 25); Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Slider.Parent = Container
    local Corner1 = Instance.new("UICorner"); Corner1.CornerRadius = UDim.new(0, 5); Corner1.Parent = Slider

    local SliderHandle = Instance.new("Frame"); 
    local ratio = (Settings[settingKey] - minVal) / (maxVal - minVal)
    SliderHandle.Size = UDim2.new(0, 15, 1.5, 0); SliderHandle.Position = UDim2.new(ratio, -7.5, -0.25, 0); SliderHandle.BackgroundColor3 = AccentColor; SliderHandle.Parent = Slider
    local Corner2 = Instance.new("UICorner"); Corner2.CornerRadius = UDim.new(0, 8); Corner2.Parent = SliderHandle
    
    SliderHandle.ZIndex = 2
    Slider.ZIndex = 1

    local function updateValue(input)
        local pos = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
        local value = math.floor((minVal + (maxVal - minVal) * pos) / 1 + 0.5) * 1 
        
        Settings[settingKey] = value
        Label.Text = text .. ": " .. value

        local newRatio = (value - minVal) / (maxVal - minVal)
        SliderHandle.Position = UDim2.new(newRatio, -7.5, -0.25, 0)
    end
    
    local dragging = false
    SliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateValue(input) end
    end)
    Slider.MouseButton1Click:Connect(updateValue)
    
    return {button = Container, update = function() end}
end

-- СОЗДАНИЕ ВСЕХ КНОПОК
table.insert(allButtons, createSimpleToggle("Aimlock (HOLD X)", "Aimlock", ScrollFrame))
table.insert(allButtons, createFOVSlider("Aim FOV", "AimFOV", 30, 200, ScrollFrame))
table.insert(allButtons, createSimpleToggle("Prediction", "PredictionEnabled", ScrollFrame))
table.insert(allButtons, createSimpleToggle("Wall Check", "WallCheck", ScrollFrame))
table.insert(allButtons, createSimpleToggle("Sticky Target", "StickyTarget", ScrollFrame))
table.insert(allButtons, createSimpleToggle("Auto Perfect Block", "AutoPB", ScrollFrame))
table.insert(allButtons, createModeToggle("PB Mode", "PBMode", {"Normal", "Interrupt"}, ScrollFrame))
table.insert(allButtons, createSimpleToggle("Full Passive", "FullPassive", ScrollFrame))
table.insert(allButtons, createSimpleToggle("Auto M1 Trade", "AutoM1Trade", ScrollFrame))
table.insert(allButtons, createModeToggle("Trade Mode", "TradeMode", {"Passive", "Aggressive"}, ScrollFrame))


-- Автоматическое обновление размера ScrollFrame
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
end)


-- Анимация GUI и активация
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
        gameProcessedEvent = MainFrame.Visible 
        
        if MainFrame.Visible then
            -- Анимация входа
            MainFrame:TweenPosition(MainFrame:GetAttribute("InitialPosition"), "Out", "Quart", 0.3, true)
            print("Шо ты думал в сказку попал? хуй тебе")
        else
            -- Анимация выхода
            MainFrame:TweenPosition(UDim2.new(0.5, -130, 0, -350), "In", "Quart", 0.3, true)
        end
    end
    
    if not gameProcessedEvent and input.KeyCode == Settings.AIM_ACTIVATION_KEY then
        isAimActiveBySkill = true
        print("ам")
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Settings.AIM_ACTIVATION_KEY then
        isAimActiveBySkill = false
    end
end)

print("GER CORE V8 - ФИНАЛЬНЫЙ СТИЛЬ. Поехали!")
