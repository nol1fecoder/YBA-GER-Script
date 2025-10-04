--[[
    GER Script for YBA v2.6 - Стиль "Frosted Glass" / Акрил
    - Кардинально новый дизайн с прозрачностью.
    - Вкладки перемещены в верхнюю часть.
    - Вся логика (Silent Aim, PB, Fire Delay) из v2.5 сохранена.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players:GetLocalPlayer() -- Использование GetLocalPlayer() предпочтительнее
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = game.Workspace.CurrentCamera

-- КОНСТАНТЫ И ЦВЕТА
local Settings = {
    AutoPB = false,
    GERAim = false,
    PBMode = 1,
    AimFOV = 99,
    FireDelay = 340,
    ShowAimCircle = true
}

-- ЦВЕТОВАЯ СХЕМА: Frosted Glass / Neon (Кардинально меняем стиль)
local PrimaryColor = Color3.fromRGB(255, 230, 0)         -- Неоново-желтый (Акцент)
local SecondaryColor = Color3.fromRGB(0, 200, 255)       -- Неоново-голубой (Второй акцент/Окантовка)
local GlassBaseColor = Color3.fromRGB(15, 20, 30)        -- Темный базовый цвет для "стекла"
local BaseTransparency = 0.35                           -- Прозрачность основного фона (КЛЮЧЕВОЙ МОМЕНТ)
local LightGlowColor = Color3.fromRGB(255, 255, 255)     -- Белый для эффектов свечения
local TextColor = Color3.fromRGB(240, 240, 240)         -- Светлый текст

-- Таблица задержек атак (Оставлена без изменений)
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

-- =========================================================================
--  ФУНКЦИЯ: ВИЗУАЛИЗАТОР SILENT AIM (ИЗ V2.5)
-- =========================================================================

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

    billboardGui.Parent = game.CoreGui

    TweenService:Create(frame, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()

    game:GetService("Debris"):AddItem(billboardGui.Adornee, duration + 0.1)
    game:GetService("Debris"):AddItem(billboardGui, duration + 0.1)
end

-- =========================================================================
--  ФУНКЦИЯ: АКТИВАЦИЯ GER LASER (ИЗ V2.5)
-- =========================================================================

local function ActivateGERLaser(targetHRP)
    local Remote = LocalPlayer.Character:FindFirstChild("RemoteEvent")
    if not Remote then return end

    if targetHRP and targetHRP.Parent then
        local originalCFrame = Camera.CFrame
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetHRP.Position)

        local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local tween = TweenService:Create(Camera, tweenInfo, {CFrame = targetCFrame})

        tween:Play()

        local totalDelaySeconds = Settings.FireDelay / 1000
        local tweenDuration = 0.05
        local remainingWaitTime = totalDelaySeconds - tweenDuration

        task.wait(remainingWaitTime > 0 and remainingWaitTime or 0)

        createAimCircle(targetHRP.Position, PrimaryColor, 0.5)

        -- !!! ВСТАВЬТЕ СЮДА СВОЮ РАБОЧУЮ КОМАНДУ FireServer.
        -- Remote:FireServer("ActivateSkill", Enum.KeyCode.X)

        Camera.CFrame = originalCFrame
    end
end

-- =========================================================================
--  ФУНКЦИИ PB (БЕЗ ИЗМЕНЕНИЙ)
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

-- =========================================================================
--  GUI: КАРДИНАЛЬНАЯ ПЕРЕСТРОЙКА ДИЗАЙНА (Frosted Glass / Акрил)
-- =========================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GERMenu"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 360) -- Шире для горизонтальных вкладок
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = GlassBaseColor
MainFrame.BackgroundTransparency = BaseTransparency -- КЛЮЧЕВОЙ МОМЕНТ: Прозрачность
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- ** Эффект Неонового Свечения/Блика **
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = SecondaryColor -- Используем неоновый голубой для контура
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.8
MainStroke.Parent = MainFrame
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- === Title Bar ===
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = GlassBaseColor
TitleBar.BackgroundTransparency = BaseTransparency -- Прозрачность заголовка
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GER | Frosted Core v2.6"
Title.TextColor3 = PrimaryColor -- Неоновый желтый для заголовка
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- === ГОРИЗОНТАЛЬНЫЕ ВКЛАДКИ ===
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0.5, -30, 0, 40) -- Подгоняем размер под заголовок
TabFrame.Position = UDim2.new(0.5, 15, 0, 0) -- Смещаем вправо
TabFrame.BackgroundColor3 = GlassBaseColor
TabFrame.BackgroundTransparency = 1 -- Прозрачный фон для контейнера кнопок
TabFrame.BorderSizePixel = 0
TabFrame.Parent = TitleBar

local TabList = Instance.new("UIListLayout")
TabList.Parent = TabFrame
TabList.FillDirection = Enum.FillDirection.Horizontal -- КЛЮЧЕВОЙ МОМЕНТ: Горизонтальный список
TabList.Padding = UDim.new(0, 10)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Right -- Выравнивание по правому краю

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -30, 1, -65) -- Учитываем высоту TitleBar и отступы
ContentFrame.Position = UDim2.new(0, 15, 0, 55)
ContentFrame.BackgroundColor3 = GlassBaseColor
ContentFrame.BackgroundTransparency = BaseTransparency -- Прозрачность содержимого
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = ContentFrame

local ContentList = Instance.new("UIListLayout")
ContentList.Parent = ContentFrame
ContentList.Padding = UDim.new(0, 10)
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.FillDirection = Enum.FillDirection.Vertical -- Элементы идут сверху вниз
ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center -- Выравнивание по центру

local Tabs = {
    Aim = Instance.new("Frame"),
    Combat = Instance.new("Frame")
}

for name, frame in pairs(Tabs) do
    frame.Name = name
    frame.Size = UDim2.new(1, -20, 1, -20) -- Отступы внутри ContentFrame
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

    -- Создаем кнопку для вкладки
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Button"
    TabButton.Size = UDim2.new(0, 80, 0, 30) -- Фиксированный размер для горизонтальных вкладок
    TabButton.BackgroundColor3 = GlassBaseColor
    TabButton.BackgroundTransparency = 0.5 -- Слегка прозрачные кнопки
    TabButton.Text = name
    TabButton.TextColor3 = TextColor
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Parent = TabFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = TabButton

    -- Неоновый контур для кнопок вкладок
    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = SecondaryColor
    TabStroke.Thickness = 1
    TabStroke.Transparency = 1 -- Изначально невидимый
    TabStroke.Parent = TabButton
    TabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    TabButton.MouseButton1Click:Connect(function()
        for _, otherFrame in pairs(Tabs) do otherFrame.Visible = false end
        frame.Visible = true

        -- Стилизация активной вкладки
        for _, btn in pairs(TabFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = TextColor, BackgroundTransparency = 0.5}):Play()
                if btn:FindFirstChildOfClass("UIStroke") then btn:FindFirstChildOfClass("UIStroke").Transparency = 1 end
            end
        end
        -- Активация: яркий текст, чуть менее прозрачный фон и неоновый контур
        TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = PrimaryColor, BackgroundTransparency = 0.2}):Play()
        if TabStroke then TabStroke.Transparency = 0.2 end
    end)
end

-- Устанавливаем вкладку Aim активной по умолчанию
Tabs.Aim.Visible = true
local DefaultTabButton = TabFrame:FindFirstChild("AimButton")
if DefaultTabButton then
    DefaultTabButton.TextColor3 = PrimaryColor
    DefaultTabButton.BackgroundTransparency = 0.2
    if DefaultTabButton:FindFirstChildOfClass("UIStroke") then DefaultTabButton:FindFirstChildOfClass("UIStroke").Transparency = 0.2 end
end

-- === Переопределение функций создания элементов для Frosted Glass ===

local function createButton(text, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 45) -- Отступы по бокам
    Button.Position = UDim2.new(0, 10, 0, 0)
    Button.BackgroundColor3 = GlassBaseColor
    Button.BackgroundTransparency = 0.4 -- Прозрачность кнопок
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button

    -- Неоновый контур для кнопок
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = SecondaryColor
    ButtonStroke.Thickness = 1
    ButtonStroke.Transparency = 0.7 -- Слегка видимый контур
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

    -- Анимация наведения: фон чуть светлее, контур ярче
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

    -- Неоновый контур для слайдера
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
    SliderBack.BackgroundTransparency = 0.6 -- Более прозрачный фон трека
    SliderBack.BorderSizePixel = 0
    SliderBack.Parent = Container

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(1, 0)
    SliderCorner.Parent = SliderBack

    local SliderFill = Instance.new("Frame")
    local initialPos = (default - min) / (max - min)
    SliderFill.Size = UDim2.new(initialPos, 0, 1, 0)
    SliderFill.BackgroundColor3 = PrimaryColor -- Неоновый желтый для заполнения
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBack

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill

    return Container, ValueLabel, SliderBack, SliderFill, min, max, step
end

-- Элементы управления
local GERAimButton, GERAimStatus = createButton("GER Aimbot (X)", Tabs.Aim)
local AimCircleButton, AimCircleStatus = createButton("Show Aim Circle", Tabs.Aim)
local FOVSlider, FOVValue, FOVBack, FOVFill, FOVMin, FOVMax, FOVStep = createSlider("Aim FOV (studs)", 30, 100, 99, 1, Tabs.Aim)
local DelaySlider, DelayValue, DelayBack, DelayFill, DelayMin, DelayMax, DelayStep = createSlider("Fire Delay (ms)", 100, 700, Settings.FireDelay, 10, Tabs.Aim)

local AutoPBButton, AutoPBStatus = createButton("Auto Perfect Block", Tabs.Combat)
local PBModeButton, PBModeStatus = createButton("Block Mode", Tabs.Combat)

local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 25) -- Немного уменьшим футер
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundColor3 = GlassBaseColor
Footer.BackgroundTransparency = BaseTransparency -- Прозрачный футер
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, -20, 1, 0)
InfoText.Position = UDim2.new(0, 10, 0, 0)
InfoText.BackgroundTransparency = 1
InfoText.Text = "RightShift - Toggle Menu | Code by Gemini"
InfoText.TextColor3 = Color3.fromRGB(180, 180, 180) -- Чуть более светлый текст
InfoText.TextSize = 11
InfoText.Font = Enum.Font.Gotham
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.Parent = Footer

-- ЛОГИКА АКТИВАЦИИ КНОПОК
AutoPBButton.MouseButton1Click:Connect(function()
    Settings.AutoPB = not Settings.AutoPB
    AutoPBStatus.Text = Settings.AutoPB and "ON" or "OFF"
    AutoPBStatus.BackgroundColor3 = Settings.AutoPB and ActiveColor or GlassBaseColor -- Цвет активного статуса
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
    PBModeStatus.BackgroundColor3 = Settings.PBMode == 2 and SecondaryColor or GlassBaseColor -- Для Interrupt используем синий акцент
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

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("GER Script v2.6 loaded! RightShift = menu")
