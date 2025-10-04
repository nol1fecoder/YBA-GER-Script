local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- === ОБНОВЛЕННЫЕ НАСТРОЙКИ ===
local Settings = {
    AutoPB = false,
    GERAim = false,
    AutoBlock = false,
    AimPart = "HumanoidRootPart", -- НОВАЯ НАСТРОЙКА
    AimFOV = 100
}

local Attacks = {
    ["Kick Barrage"] = 0, ["Sticky Fingers Finisher"] = 0.35, ["Gun_Shot1"] = 0.15,
    ["Heavy_Charge"] = 0.35, ["Erasure"] = 0.35, ["Disc"] = 0.35,
    ["Propeller Charge"] = 0.35, ["Platinum Slam"] = 0.25, ["Chomp"] = 0.25,
    ["Scary Monsters Bite"] = 0.25, ["D4C Love Train Finisher"] = 0.35,
    ["D4C Finisher"] = 0.35, ["Tusk ACT 4 Finisher"] = 0.35,
    ["Gold Experience Finisher"] = 0.35, ["Gold Experience Requiem Finisher"] = 0.35,
    ["Scary Monsters Finisher"] = 0.35, ["White Album Finisher"] = 0.35,
    ["Star Platinum Finisher"] = 0.35, ["Star Platinum: The World Finisher"] = 0.35,
    ["King Crimson Finisher"] = 0.35, ["King Crimson Requiem Finisher"] = 0.35,
    ["Crazy Diamond Finisher"] = 0.35, ["The World Alternate Universe Finisher"] = 0.35,
    ["The World Finisher"] = 0.45, ["The World Finisher2"] = 0.45,
    ["Purple Haze Finisher"] = 0.35, ["Hermit Purple Finisher"] = 0.35,
    ["Made in Heaven Finisher"] = 0.35, ["Whitesnake Finisher"] = 0.40,
    ["C-Moon Finisher"] = 0.35, ["Red Hot Chili Pepper Finisher"] = 0.35,
    ["Six Pistols Finisher"] = 0.45, ["Stone Free Finisher"] = 0.35, ["Ora Kicks"] = 0.15
}

-- === МЕНЮ (НАЧАЛО) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GERHubMenu"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 320)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 215, 0)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 65)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local TitleGradient = Instance.new("Frame")
TitleGradient.Size = UDim2.new(1, 0, 1, 0)
TitleGradient.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
TitleGradient.BorderSizePixel = 0
TitleGradient.Parent = TitleBar

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 16)
TitleCorner.Parent = TitleGradient

local TitleCover = Instance.new("Frame")
TitleCover.Size = UDim2.new(1, 0, 0, 20)
TitleCover.Position = UDim2.new(0, 0, 1, -20)
TitleCover.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
TitleCover.BorderSizePixel = 0
TitleCover.Parent = TitleGradient

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 0, 35)
TitleText.Position = UDim2.new(0, 20, 0, 8)
TitleText.BackgroundTransparency = 1
TitleText.Text = "GER HUB"
TitleText.TextColor3 = Color3.fromRGB(0, 0, 0)
TitleText.TextSize = 28
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -40, 0, 18)
Subtitle.Position = UDim2.new(0, 20, 0, 40)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "YBA Script | RightShift to Toggle"
Subtitle.TextColor3 = Color3.fromRGB(0, 0, 0)
Subtitle.TextSize = 12
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.TextTransparency = 0.3
Subtitle.Parent = TitleBar

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -30, 1, -85)
Content.Position = UDim2.new(0, 15, 0, 75)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Content
Layout.Padding = UDim.new(0, 12)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

local function createToggle(text, settingKey, description)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 70)
    Container.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    Container.BorderSizePixel = 0
    Container.Parent = Content
    
    local ContCorner = Instance.new("UICorner")
    ContCorner.CornerRadius = UDim.new(0, 10)
    ContCorner.Parent = Container
    
    local Glow = Instance.new("UIStroke")
    Glow.Color = Color3.fromRGB(50, 50, 55)
    Glow.Thickness = 1
    Glow.Transparency = 0.5
    Glow.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -90, 0, 22)
    Label.Position = UDim2.new(0, 15, 0, 12)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextSize = 17
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1, -90, 0, 16)
    Desc.Position = UDim2.new(0, 15, 0, 38)
    Desc.BackgroundTransparency = 1
    Desc.Text = description
    Desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    Desc.TextSize = 11
    Desc.Font = Enum.Font.Gotham
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = Container
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 60, 0, 30)
    ToggleBtn.Position = UDim2.new(1, -70, 0.5, -15)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Container
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleBtn
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 24, 0, 24)
    Circle.Position = UDim2.new(0, 3, 0.5, -12)
    Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Circle.BorderSizePixel = 0
    Circle.Parent = ToggleBtn
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        
        if Settings[settingKey] then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = Color3.fromRGB(255, 215, 0)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -27, 0.5, -12), BackgroundColor3 = Color3.new(0, 0, 0)}):Play()
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 3, 0.5, -12), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
    end)
    
    Container.MouseEnter:Connect(function()
        TweenService:Create(Container, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
        TweenService:Create(Glow, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 215, 0), Transparency = 0.3}):Play()
    end)
    
    Container.MouseLeave:Connect(function()
        TweenService:Create(Container, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 28, 32)}):Play()
        TweenService:Create(Glow, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 55), Transparency = 0.5}):Play()
    end)
end

local function createSlider(text, settingKey, min, max, description)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 80)
    Container.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    Container.BorderSizePixel = 0
    Container.Parent = Content
    
    local ContCorner = Instance.new("UICorner")
    ContCorner.CornerRadius = UDim.new(0, 10)
    ContCorner.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 0, 22)
    Label.Position = UDim2.new(0, 15, 0, 12)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextSize = 17
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local Value = Instance.new("TextLabel")
    Value.Size = UDim2.new(0, 60, 0, 22)
    Value.Position = UDim2.new(1, -70, 0, 12)
    Value.BackgroundTransparency = 1
    Value.Text = tostring(Settings[settingKey])
    Value.TextColor3 = Color3.fromRGB(255, 215, 0)
    Value.TextSize = 17
    Value.Font = Enum.Font.GothamBold
    Value.Parent = Container
    
    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1, -30, 0, 14)
    Desc.Position = UDim2.new(0, 15, 0, 38)
    Desc.BackgroundTransparency = 1
    Desc.Text = description
    Desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    Desc.TextSize = 11
    Desc.Font = Enum.Font.Gotham
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = Container
    
    local SliderBack = Instance.new("Frame")
    SliderBack.Size = UDim2.new(1, -30, 0, 8)
    SliderBack.Position = UDim2.new(0, 15, 0, 60)
    SliderBack.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    SliderBack.BorderSizePixel = 0
    SliderBack.Parent = Container
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(1, 0)
    SliderCorner.Parent = SliderBack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((Settings[settingKey] - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBack
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill
    
    local dragging = false
    SliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * pos)
            Settings[settingKey] = value
            Value.Text = tostring(value)
            TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
        end
    end)
end

-- === НОВАЯ ФУНКЦИЯ ДЛЯ DROPDOWN ===
local function createDropdown(text, settingKey, values, description)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 70)
    Container.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    Container.BorderSizePixel = 0
    Container.Parent = Content
    
    local ContCorner = Instance.new("UICorner")
    ContCorner.CornerRadius = UDim.new(0, 10)
    ContCorner.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -160, 0, 22)
    Label.Position = UDim2.new(0, 15, 0, 12)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextSize = 17
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1, -30, 0, 16)
    Desc.Position = UDim2.new(0, 15, 0, 38)
    Desc.BackgroundTransparency = 1
    Desc.Text = description
    Desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    Desc.TextSize = 11
    Desc.Font = Enum.Font.Gotham
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = Container
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0, 100, 0, 30)
    DropdownBtn.Position = UDim2.new(1, -115, 0.5, -15)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    DropdownBtn.BorderSizePixel = 0
    DropdownBtn.Text = Settings[settingKey]
    DropdownBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    DropdownBtn.TextSize = 14
    DropdownBtn.Font = Enum.Font.GothamBold
    DropdownBtn.Parent = Container
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 8)
    DropdownCorner.Parent = DropdownBtn
    
    local DropdownList = Instance.new("Frame")
    DropdownList.Size = UDim2.new(0, 100, 0, 0)
    DropdownList.Position = UDim2.new(1, -115, 1, 5)
    DropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    DropdownList.BorderSizePixel = 0
    DropdownList.ZIndex = 2
    DropdownList.Visible = false
    DropdownList.Parent = MainFrame
    
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 8)
    ListCorner.Parent = DropdownList
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.FillDirection = Enum.FillDirection.Vertical
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    ListLayout.Parent = DropdownList
    
    local function selectValue(value)
        Settings[settingKey] = value
        DropdownBtn.Text = value
        DropdownList.Visible = false
    end
    
    for i, value in ipairs(values) do
        local ItemBtn = Instance.new("TextButton")
        ItemBtn.Size = UDim2.new(1, 0, 0, 25)
        ItemBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        ItemBtn.BorderSizePixel = 0
        ItemBtn.Text = value
        ItemBtn.TextColor3 = Color3.new(1, 1, 1)
        ItemBtn.TextSize = 14
        ItemBtn.Font = Enum.Font.Gotham
        ItemBtn.Parent = DropdownList
        
        ItemBtn.MouseButton1Click:Connect(function()
            selectValue(value)
        end)
    end
    
    DropdownList.Size = UDim2.new(0, 100, 0, #values * 27) -- 25 size + 2 padding
    
    DropdownBtn.MouseButton1Click:Connect(function()
        DropdownList.Visible = not DropdownList.Visible
        -- Перемещаем список, чтобы он был поверх всего
        DropdownList:SetAttribute("ZIndex", 100)
    end)
    
    -- Скрывать список, если клик вне его
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and DropdownList.Visible then
            local mousePos = input.Position
            local listAbsPos = DropdownList.AbsolutePosition
            local listAbsSize = DropdownList.AbsoluteSize
            
            if not (mousePos.X >= listAbsPos.X and mousePos.X <= listAbsPos.X + listAbsSize.X and
                    mousePos.Y >= listAbsPos.Y and mousePos.Y <= listAbsPos.Y + listAbsSize.Y) then
                if input.Target ~= DropdownBtn then
                    DropdownList.Visible = false
                end
            end
        end
    end)
end

-- === ВЫЗОВЫ ЭЛЕМЕНТОВ МЕНЮ ===
createToggle("Auto Perfect Block", "AutoPB", "Block attacks automatically")
createToggle("GER Aim", "GERAim", "Auto-aim when holding X")
createToggle("Auto Block Keyhold", "AutoBlock", "Automatically holds the block key (F)")
createSlider("Aim FOV", "AimFOV", 30, 200, "Maximum distance to lock targets")
createDropdown("Aim Target Part", "AimPart", {"Head", "HumanoidRootPart", "Torso"}, "The part of the enemy body to aim at.")

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)
end)

-- === AUTO PB ===
local blockingInProgress = false
local function checkSound(soundID)
    for _, v in pairs(game.ReplicatedStorage.Sounds:GetChildren()) do
        if v.SoundId == soundID then return v.Name end
    end
end

local function performBlock()
    if blockingInProgress then return end
    blockingInProgress = true
    
    local remote = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("RemoteEvent")
    if remote then
        pcall(function()
            remote:FireServer("InputEnded", {Input = Enum.KeyCode.E}) 
            remote:FireServer("InputEnded", {Input = Enum.KeyCode.R}) 
            remote:FireServer("StopBlocking") 
        end)
        
        task.wait(0.05) 
        
        pcall(function()
            remote:FireServer("StartBlocking")
        end)
        
        task.wait(0.6)
        
        pcall(function()
            remote:FireServer("StopBlocking")
        end)
    end
    
    blockingInProgress = false
end

local function setupPlayer(player)
    if not player.Character then return end
    player.Character.DescendantAdded:Connect(function(child)
        if not Settings.AutoPB or not child:IsA("Sound") then return end
        local moveName = checkSound(child.SoundId)
        if Attacks[moveName] then
            task.spawn(function() 
                task.wait(Attacks[moveName])
                performBlock()
            end)
        end
    end)
end

for _, player in pairs(game.Workspace.Living:GetChildren()) do setupPlayer(player) end
game.Workspace.Living.ChildAdded:Connect(function(player) task.wait(0.5) setupPlayer(player) end)

-- === GER AIM (УЛУЧШЕННАЯ ЛОГИКА) ===
local function getClosestPlayer()
    local closest, shortestDist = nil, Settings.AimFOV
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Динамически выбираем часть для цели
            local targetPart = player.Character:FindFirstChild(Settings.AimPart)
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if targetPart and humanoid and humanoid.Health > 0 then
                local dist = (myHrp.Position - targetPart.Position).Magnitude
                if dist < shortestDist then closest, shortestDist = player, dist end
            end
        end
    end
    return closest
end

local aimConnection = nil
UserInputService.InputBegan:Connect(function(input, processed)
    if processed or input.KeyCode ~= Enum.KeyCode.X then return end
    if Settings.GERAim then
        local target = getClosestPlayer()
        if target and target.Character then
            -- Получаем часть тела для прицеливания
            local targetHRP = target.Character:FindFirstChild(Settings.AimPart)
            if aimConnection then aimConnection:Disconnect() end
            
            aimConnection = RunService.RenderStepped:Connect(function()
                if blockingInProgress then return end -- Приоритет PB
                
                local hum = target.Character:FindFirstChildOfClass("Humanoid")
                
                -- Перепроверяем targetPart внутри цикла, т.к. цель может умереть или сменить стойку
                local currentTargetPart = target.Character:FindFirstChild(Settings.AimPart) 

                if currentTargetPart and target.Character and hum and hum.Health > 0 then
                    -- Прицеливание: устанавливаем CFrame камеры на позицию игрока, смотрящего на цель
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, currentTargetPart.Position)
                else
                    if aimConnection then aimConnection:Disconnect() aimConnection = nil end
                end
            end)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.X and aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
end)

-- === AUTO BLOCK KEYHOLD LOGIC ===
RunService.RenderStepped:Connect(function()
    -- Если AutoBlock включен И Perfect Block не активен (приоритет PB)
    if Settings.AutoBlock and not blockingInProgress then
        local remote = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("RemoteEvent")
        if remote then
            -- Постоянно отправляем StartBlocking
            pcall(function()
                remote:FireServer("StartBlocking")
            end)
        end
    elseif not Settings.AutoBlock and not blockingInProgress then 
        local remote = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("RemoteEvent")
        if remote then
            pcall(function()
                remote:FireServer("StopBlocking")
            end)
        end
    end
end)


-- === TOGGLE MENU ===
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("GER HUB loaded! RightShift = toggle")
