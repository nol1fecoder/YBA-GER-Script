--[[
    GER Script for YBA v2.3 - Стиль "Soft Neumorphism"
    - Логика адаптивного аима (v2.2) сохранена.
    - Полностью переработан дизайн GUI: мягкие, объемные формы.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
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
    FireDelay = 400 
}

-- ЦВЕТОВАЯ СХЕМА: Soft Neumorphism (Мягкие формы)
local PrimaryColor = Color3.fromRGB(255, 200, 0)         -- Мягкий Золотисто-желтый
local BaseBackground = Color3.fromRGB(35, 40, 50)       -- Основной фон (Мягкий темно-серый)
local LightShadow = Color3.fromRGB(50, 60, 70)          -- Светлая тень (Для "поднятия")
local DarkShadow = Color3.fromRGB(20, 25, 30)           -- Темная тень (Для "вдавления")
local TextColor = Color3.fromRGB(220, 220, 220)         -- Белый/Серый текст
local ActiveIndicator = PrimaryColor                    -- Индикатор активности

-- ... (Остальные массивы и функции игры остаются без изменений) ...

-- =========================================================================
--  НАСТРОЙКА GUI (Стиль: Soft Neumorphism)
-- =========================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GERMenu"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 380)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
MainFrame.BackgroundColor3 = BaseBackground
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = MainFrame

-- *** Neumorphism: Светлая и Темная тень на MainFrame ***
-- Мы используем две обводки UIStroke для имитации двух теней.
local MainStrokeLight = Instance.new("UIStroke")
MainStrokeLight.Color = LightShadow
MainStrokeLight.Thickness = 3
MainStrokeLight.Transparency = 0.5
MainStrokeLight.Parent = MainFrame
MainStrokeLight.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local MainStrokeDark = Instance.new("UIStroke")
MainStrokeDark.Color = DarkShadow
MainStrokeDark.Thickness = 3
MainStrokeDark.Transparency = 0.5
MainStrokeDark.Parent = MainFrame
MainStrokeDark.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStrokeDark.LineJoinMode = Enum.LineJoinMode.Bevel -- Для лучшего угла тени


local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = BaseBackground -- Сливается с фоном
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GER Script | Neumorphic Core"
Title.TextColor3 = PrimaryColor
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- === Вкладки ===
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0, 100, 1, -50)
TabFrame.Position = UDim2.new(0, 0, 0, 50)
TabFrame.BackgroundColor3 = BaseBackground -- Сливается с фоном
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local TabList = Instance.new("UIListLayout")
TabList.Parent = TabFrame
TabList.Padding = UDim.new(0, 5)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.SortOrder = Enum.SortOrder.LayoutOrder


local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -110, 1, -60)
ContentFrame.Position = UDim2.new(0, 105, 0, 55)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Создание страниц вкладок (ОСТАВЛЕНО БЕЗ ИЗМЕНЕНИЙ)
local Tabs = {
    Aim = Instance.new("Frame"),
    Combat = Instance.new("Frame")
}

for name, frame in pairs(Tabs) do
    frame.Name = name
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentFrame
    frame.Visible = false 
    
    local list = Instance.new("UIListLayout")
    list.Parent = frame
    list.Padding = UDim.new(0, 10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Создаем кнопку для вкладки
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Button"
    TabButton.Size = UDim2.new(1, -10, 0, 40)
    TabButton.BackgroundColor3 = BaseBackground -- Сливается с фоном
    TabButton.Text = name
    TabButton.TextColor3 = TextColor
    TabButton.TextSize = 16
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Parent = TabFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = TabButton

    -- *** Neumorphism: Тени для кнопок вкладок ***
    local TabStrokeLight = Instance.new("UIStroke")
    TabStrokeLight.Color = LightShadow
    TabStrokeLight.Thickness = 2
    TabStrokeLight.Transparency = 0.5
    TabStrokeLight.Parent = TabButton
    TabStrokeLight.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local TabStrokeDark = Instance.new("UIStroke")
    TabStrokeDark.Color = DarkShadow
    TabStrokeDark.Thickness = 2
    TabStrokeDark.Transparency = 0.5
    TabStrokeDark.Parent = TabButton
    TabStrokeDark.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    TabButton.MouseButton1Click:Connect(function()
        for _, otherFrame in pairs(Tabs) do otherFrame.Visible = false end
        frame.Visible = true
        
        -- Стилизация активной вкладки
        for _, btn in pairs(TabFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                -- Деактивация: Вдавленное состояние
                TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = TextColor, BackgroundColor3 = BaseBackground}):Play()
                btn:FindFirstChild("UIStroke").Transparency = 0.5
                btn:FindFirstChild("UIStroke").Color = LightShadow -- Светлая тень
                if btn:FindFirstChild("UIStroke", true) then btn:FindFirstChild("UIStroke", true).Color = DarkShadow end -- Темная тень
            end
        end
        -- Активация: Слегка поднятое состояние + активный текст
        TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = PrimaryColor, BackgroundColor3 = BaseBackground}):Play()
        TabStrokeLight.Color = DarkShadow -- Меняем тени, чтобы создать эффект "нажатия/свечения"
        TabStrokeDark.Color = LightShadow 
    end)
end

-- Устанавливаем вкладку Aim активной по умолчанию
Tabs.Aim.Visible = true
local DefaultTabButton = TabFrame:FindFirstChild("AimButton")
if DefaultTabButton then
    DefaultTabButton.TextColor3 = PrimaryColor
    local TabStrokeLight = DefaultTabButton:FindFirstChild("UIStroke")
    local TabStrokeDark = DefaultTabButton:FindFirstChild("UIStroke", true)
    if TabStrokeLight and TabStrokeDark then
        TabStrokeLight.Color = DarkShadow
        TabStrokeDark.Color = LightShadow
    end
end


-- === Переопределение функций создания элементов для Neumorphism ===

local function createButton(text, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 45)
    Button.BackgroundColor3 = BaseBackground
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button
    
    -- *** Neumorphism: Тени для кнопок ***
    local ButtonStrokeLight = Instance.new("UIStroke")
    ButtonStrokeLight.Color = LightShadow
    ButtonStrokeLight.Thickness = 2
    ButtonStrokeLight.Transparency = 0.5
    ButtonStrokeLight.Parent = Button
    ButtonStrokeLight.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local ButtonStrokeDark = Instance.new("UIStroke")
    ButtonStrokeDark.Color = DarkShadow
    ButtonStrokeDark.Thickness = 2
    ButtonStrokeDark.Transparency = 0.5
    ButtonStrokeDark.Parent = Button
    ButtonStrokeDark.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
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
    Status.BackgroundColor3 = DarkShadow -- Темный фон для индикатора
    Status.BorderSizePixel = 0
    Status.Text = "OFF"
    Status.TextColor3 = TextColor
    Status.TextSize = 12
    Status.Font = Enum.Font.GothamBold
    Status.Parent = Button
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = Status
    
    -- Анимация наведения: немного меняем тени для эффекта "вдавления"
    Button.MouseEnter:Connect(function() 
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = BaseBackground}):Play()
        ButtonStrokeLight.Color = DarkShadow 
        ButtonStrokeDark.Color = LightShadow 
    end)
    Button.MouseLeave:Connect(function() 
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = BaseBackground}):Play()
        ButtonStrokeLight.Color = LightShadow
        ButtonStrokeDark.Color = DarkShadow
    end)
    
    return Button, Status
end

local function createSlider(text, min, max, default, step, parent)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 60)
    Container.BackgroundColor3 = BaseBackground
    Container.BorderSizePixel = 0
    Container.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Container
    
    -- *** Neumorphism: Тени для слайдера ***
    local ContainerStrokeLight = Instance.new("UIStroke")
    ContainerStrokeLight.Color = LightShadow
    ContainerStrokeLight.Thickness = 2
    ContainerStrokeLight.Transparency = 0.5
    ContainerStrokeLight.Parent = Container
    ContainerStrokeLight.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local ContainerStrokeDark = Instance.new("UIStroke")
    ContainerStrokeDark.Color = DarkShadow
    ContainerStrokeDark.Thickness = 2
    ContainerStrokeDark.Transparency = 0.5
    ContainerStrokeDark.Parent = Container
    ContainerStrokeDark.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
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
    SliderBack.BackgroundColor3 = DarkShadow -- Слайдер трек "вдавлен"
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

-- Элементы управления
local GERAimButton, GERAimStatus = createButton("GER Aimbot (X)", Tabs.Aim)
local FOVSlider, FOVValue, FOVBack, FOVFill, FOVMin, FOVMax, FOVStep = createSlider("Aim FOV (studs)", 30, 100, 99, 1, Tabs.Aim)
local DelaySlider, DelayValue, DelayBack, DelayFill, DelayMin, DelayMax, DelayStep = createSlider("Fire Delay (ms)", 100, 700, 400, 10, Tabs.Aim)

local AutoPBButton, AutoPBStatus = createButton("Auto Perfect Block", Tabs.Combat)
local PBModeButton, PBModeStatus = createButton("Block Mode", Tabs.Combat)

local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 30)
Footer.Position = UDim2.new(0, 0, 1, -30)
Footer.BackgroundColor3 = DarkShadow
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, -20, 1, 0)
InfoText.Position = UDim2.new(0, 10, 0, 0)
InfoText.BackgroundTransparency = 1
InfoText.Text = "RightShift - Toggle Menu | Code by Gemini"
InfoText.TextColor3 = Color3.fromRGB(120, 120, 120)
InfoText.TextSize = 12
InfoText.Font = Enum.Font.Gotham
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.Parent = Footer

-- ... (Вся игровая логика и обработка инпута в конце остается неизменной) ...

-- ЛОГИКА АКТИВАЦИИ КНОПОК
AutoPBButton.MouseButton1Click:Connect(function()
    Settings.AutoPB = not Settings.AutoPB
    AutoPBStatus.Text = Settings.AutoPB and "ON" or "OFF"
    AutoPBStatus.BackgroundColor3 = Settings.AutoPB and ActiveIndicator or DarkShadow
    AutoPBStatus.TextColor3 = Settings.AutoPB and DarkShadow or TextColor
end)

GERAimButton.MouseButton1Click:Connect(function()
    Settings.GERAim = not Settings.GERAim
    GERAimStatus.Text = Settings.GERAim and "ON" or "OFF"
    GERAimStatus.BackgroundColor3 = Settings.GERAim and ActiveIndicator or DarkShadow
    GERAimStatus.TextColor3 = Settings.GERAim and DarkShadow or TextColor
end)

PBModeButton.MouseButton1Click:Connect(function()
    Settings.PBMode = Settings.PBMode == 1 and 2 or 1
    local modeText = Settings.PBMode == 1 and "Normal" or "Interrupt"
    PBModeStatus.Text = modeText
    PBModeStatus.BackgroundColor3 = Settings.PBMode == 2 and Color3.fromRGB(255, 100, 0) or DarkShadow
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

print("GER Script v2.3 loaded! RightShift = menu")
