local Players = game:GetService("Players")
local RunService = game:GetService("RunService") 
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer 
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") 
local Camera = game.Workspace.CurrentCamera 
local MY_CHARACTER = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local MY_HUMANOID = MY_CHARACTER:WaitForChild("Humanoid")

-- Я уже красный культурно уже не получится нахуй 
-- Новые переменные для контроля камеры
local DEFAULT_CAMERA_MAX_ZOOM = 30 
local DEFAULT_CAMERA_MIN_ZOOM = 0.5

-- Сброс камеры на дефолт, если она была изменена предыдущими версиями
LocalPlayer.CameraMaxZoomDistance = DEFAULT_CAMERA_MAX_ZOOM
LocalPlayer.CameraMinZoomDistance = DEFAULT_CAMERA_MIN_ZOOM

-- =========================================================================
--  КОНФИГУРАЦИЯ
-- =========================================================================

local PrimaryColor = Color3.fromRGB(138, 43, 226)
local BaseColor = Color3.fromRGB(22, 22, 26)
local TextColor = Color3.fromRGB(255, 255, 255)

local Settings = {
    AutoPB = false,
    FullPassive = false,
    Aimlock = false, 
    AutoM1Trade = false, 
    PBMode = 1,          
    TradeMode = 1,      
    AimFOV = 99,
    
    PredictionEnabled = true,
    PredictionStrength = 0.18,
    WallCheck = true,
    StickyTarget = true,
    StickyDuration = 1.2,
    TargetPart = "Head",
    MaxAimSpeed = 1000, 
    
    AIM_ACTIVATION_KEY = Enum.KeyCode.X, 
}

local REMOTE_EVENT_NAME = "RemoteEvent" 

-- =========================================================================
--  ПЕРЕМЕННЫЕ СОСТОЯНИЯ
-- =========================================================================

local isAimActiveBySkill = false 
local currentTarget = nil
local targetLockTime = 0
local M1_COUNTER = {} 

-- =========================================================================
--  AIM СИСТЕМА (БЫСТРЕЕ, БЫСТРЕЕ)
-- =========================================================================
-- ... (Остальные функции Aim System без изменений) ...

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

-- ГЛАВНЫЙ ЦИКЛ AIMLOCK (RenderStepped)
RunService.RenderStepped:Connect(function() 
    if not Settings.Aimlock or not isAimActiveBySkill or MY_HUMANOID.Sit or MY_HUMANOID.PlatformStand then 
        -- СБРОС НАСТРОЕК КАМЕРЫ ПРИ ВЫКЛЮЧЕННОМ АИМЕ
        LocalPlayer.CameraMaxZoomDistance = DEFAULT_CAMERA_MAX_ZOOM
        LocalPlayer.CameraMinZoomDistance = DEFAULT_CAMERA_MIN_ZOOM
        currentTarget = nil
        targetLockTime = 0
        return 
    end
    
    -- БЛОКИРОВКА КАМЕРЫ НА 1-ОЕ ЛИЦО, ПОКА АИМ АКТИВЕН
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

local FULL_PASSIVE_CONFIG = {
    ["Liver_Shot_Sound"] = {Delay = 0.2, Type = "Block"}, ["Jawbreaker_Sound"] = {Delay = 0.1, Type = "Interrupt"}, 
    ["Haymaker_Sound"] = {Delay = 0.01, Type = "NoBlock"}, ["The World Finisher"] = {Delay = 0.45, Type = "Block"},
    ["punch_sound"] = {Delay = 0.05, Type = "Block"},
}
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
--  GUI & ВХОД
-- =========================================================================

local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "ZARA_ZARA_AIM"; ScreenGui.Parent = PlayerGui; ScreenGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame"); MainFrame.Size = UDim2.new(0, 250, 0, 300); MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150); MainFrame.BackgroundColor3 = BaseColor; MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.Parent = ScreenGui
local Title = Instance.new("TextLabel"); Title.Size = UDim2.new(1, 0, 0, 30); Title.BackgroundColor3 = PrimaryColor; Title.TextColor3 = TextColor; Title.Text = "Я УЖЕ КРАСНЫЙ (V7 FUCK 1ST PERSON)"; Title.Font = Enum.Font.GothamBold; Title.TextSize = 15; Title.Parent = MainFrame
local ScrollFrame = Instance.new("ScrollingFrame"); ScrollFrame.Size = UDim2.new(1, 0, 1, -30); ScrollFrame.Position = UDim2.new(0, 0, 0, 30); ScrollFrame.BackgroundTransparency = 1; ScrollFrame.Parent = MainFrame
local ListLayout = Instance.new("UIListLayout"); ListLayout.Parent = ScrollFrame; ListLayout.Padding = UDim.new(0, 5); ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- [GUI Building functions - omitted for brevity, logic remains the same]

local allButtons = {}
-- ... (кнопки GUI создаются здесь) ...
-- Я УЖЕ КРАСНЫЙ (GUI без изменений)
local function createSimpleToggle(text, settingKey, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 30)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Button.TextColor3 = TextColor
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 14
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = parent
    
    local function updateText()
        local state = Settings[settingKey]
        local stateText = state and "[ON]" or "[OFF]"
        Button.Text = text .. " " .. stateText
        Button.BackgroundColor3 = state and PrimaryColor or Color3.fromRGB(30, 30, 35)
    end
    
    Button.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        
        if settingKey == "FullPassive" and Settings.FullPassive then
            Settings.AutoPB = false
            for _, btnData in ipairs(allButtons) do btnData.update() end
        elseif settingKey == "AutoPB" and Settings.AutoPB then
            Settings.FullPassive = false
            for _, btnData in ipairs(allButtons) do btnData.update() end
        end

        updateText()
    end)
    
    updateText()
    return {button = Button, update = updateText}
end

local function createModeToggle(text, settingKey, modes, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 30)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Button.TextColor3 = TextColor
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 14
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = parent
    
    local function updateText()
        local modeIndex = Settings[settingKey]
        local modeName = modes[modeIndex] or "Error"
        Button.Text = text .. ": " .. modeName
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
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 40)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 15)
    Label.Text = text .. ": " .. Settings[settingKey]
    Label.BackgroundTransparency = 1
    Label.TextColor3 = TextColor
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.Parent = Container

    local Slider = Instance.new("TextButton")
    Slider.Size = UDim2.new(1, 0, 0, 15)
    Slider.Position = UDim2.new(0, 0, 0, 20)
    Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Slider.Text = ""
    Slider.Parent = Container

    local SliderHandle = Instance.new("Frame")
    local ratio = (Settings[settingKey] - minVal) / (maxVal - minVal)
    SliderHandle.Size = UDim2.new(0, 8, 1, 0)
    SliderHandle.Position = UDim2.new(ratio, -4, 0, 0)
    SliderHandle.BackgroundColor3 = PrimaryColor
    SliderHandle.Parent = Slider

    local dragging = false
    local function updateValue(input)
        if dragging or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
            local value = math.floor((minVal + (maxVal - minVal) * pos) / 1 + 0.5) * 1 
            
            Settings[settingKey] = value
            Label.Text = text .. ": " .. value

            local newRatio = (value - minVal) / (maxVal - minVal)
            SliderHandle.Position = UDim2.new(newRatio, -4, 0, 0)
        end
    end

    Slider.InputBegan:Connect(function(input)
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
    
    return {button = Container, update = function() end}
end

table.insert(allButtons, createSimpleToggle("1. Aimlock (HOLD X)", "Aimlock", ScrollFrame))
table.insert(allButtons, createFOVSlider("2. Aim FOV", "AimFOV", 30, 200, ScrollFrame))
table.insert(allButtons, createSimpleToggle("3. Prediction", "PredictionEnabled", ScrollFrame))
table.insert(allButtons, createSimpleToggle("4. Wall Check (Anti-Ban)", "WallCheck", ScrollFrame))
table.insert(allButtons, createSimpleToggle("5. Sticky Target Lock", "StickyTarget", ScrollFrame))
table.insert(allButtons, createSimpleToggle("6. Auto Perfect Block", "AutoPB", ScrollFrame))
table.insert(allButtons, createModeToggle("7. PB Mode", "PBMode", {"Normal", "Interrupt"}, ScrollFrame))
table.insert(allButtons, createSimpleToggle("8. Full Passive (V/X/B)", "FullPassive", ScrollFrame))
table.insert(allButtons, createSimpleToggle("9. Auto M1 Trade", "AutoM1Trade", ScrollFrame))
table.insert(allButtons, createModeToggle("10. Trade Mode", "TradeMode", {"Passive", "Aggressive"}, ScrollFrame))

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10) end)


UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.RightControl then MainFrame.Visible = not MainFrame.Visible; gameProcessedEvent = MainFrame.Visible; print("Шо ты думал в сказку попал? хуй тебе") end
    if not gameProcessedEvent and input.KeyCode == Settings.AIM_ACTIVATION_KEY then isAimActiveBySkill = true; print("ам") end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Settings.AIM_ACTIVATION_KEY then isAimActiveBySkill = false end
end)

print("GER CORE V7 - КАМЕРА ПОФИКСЕНА. ПОЕХАЛИ.")
