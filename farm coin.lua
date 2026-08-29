-- ROBOT ESCAPE — ФАРМ МОНЕТ v3.0 (MEGA UPDATE)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()

-- === УДАЛЯЕМ СТАРЫЕ GUI ===
for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name:find("CoinFarm") or v.Name:find("RobotEscape") then
        v:Destroy()
    end
end

-- === ПОЛУЧЕНИЕ ВСЕХ МОНЕТ ===
local function getAllCoins()
    local coins = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("coin") then
            if obj and obj.Parent and obj.Parent:IsA("Model") then
                table.insert(coins, obj)
            end
        end
    end
    return coins
end

-- === NOCLIP ===
local function setNoClip(enabled)
    if not Char then return end
    for _, part in ipairs(Char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enabled
        end
    end
end

-- === ПЛАВНЫЙ ПОЛЁТ ===
local flySpeed = 30

local function flyToCoin(coin)
    if not coin or not Char or not Char:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local hrp = Char.HumanoidRootPart
    local targetPos = coin.Position + Vector3.new(0, 2, 0)
    local distance = (hrp.Position - targetPos).Magnitude
    
    if distance < 2 then
        return true
    end
    
    local duration = math.min(distance / flySpeed, 4)
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, tweenInfo, {
        CFrame = CFrame.new(targetPos)
    })
    
    tween:Play()
    tween.Completed:Wait()
    
    return true
end

-- === ESP МОНЕТ ===
local espObjects = {}
local espEnabled = true

local function updateCoinESP()
    for _, v in ipairs(espObjects) do v:Destroy() end
    espObjects = {}
    
    if not espEnabled then return end
    
    local coins = getAllCoins()
    local cam = workspace.CurrentCamera
    
    for _, coin in ipairs(coins) do
        if coin and coin:IsA("BasePart") then
            local pos = coin.Position
            local vec, onScreen = cam:WorldToScreenPoint(pos)
            
            if onScreen then
                local circle = Instance.new("Frame")
                circle.Parent = game:GetService("CoreGui")
                circle.Size = UDim2.new(0, 25, 0, 25)
                circle.Position = UDim2.new(0, vec.X - 12, 0, vec.Y - 35)
                circle.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                circle.BackgroundTransparency = 0.3
                circle.BorderSizePixel = 2
                circle.BorderColor3 = Color3.fromRGB(255, 200, 0)
                
                local icon = Instance.new("TextLabel", circle)
                icon.Size = UDim2.new(1, 0, 1, 0)
                icon.BackgroundTransparency = 1
                icon.Text = "🪙"
                icon.TextColor3 = Color3.fromRGB(255, 200, 0)
                icon.TextSize = 16
                icon.TextScaled = true
                icon.Font = Enum.Font.GothamBold
                
                table.insert(espObjects, circle)
            end
        end
    end
end

-- === МИНИ-КАРТА ===
local minimapObjects = {}
local minimapEnabled = true

local function updateMinimap()
    for _, v in ipairs(minimapObjects) do v:Destroy() end
    minimapObjects = {}
    
    if not minimapEnabled then return end
    
    local coins = getAllCoins()
    local cam = workspace.CurrentCamera
    local viewport = cam.ViewportSize
    
    -- Рамка мини-карты
    local mapFrame = Instance.new("Frame")
    mapFrame.Parent = game:GetService("CoreGui")
    mapFrame.Size = UDim2.new(0, 120, 0, 120)
    mapFrame.Position = UDim2.new(0.01, 0, 0.01, 0)
    mapFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mapFrame.BackgroundTransparency = 0.5
    mapFrame.BorderSizePixel = 2
    mapFrame.BorderColor3 = Color3.fromRGB(255, 200, 0)
    table.insert(minimapObjects, mapFrame)
    
    -- Надпись
    local mapLabel = Instance.new("TextLabel", mapFrame)
    mapLabel.Size = UDim2.new(1, 0, 0, 15)
    mapLabel.Position = UDim2.new(0, 0, 0, 0)
    mapLabel.BackgroundTransparency = 1
    mapLabel.Text = "🗺️ " .. #coins .. " монет"
    mapLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    mapLabel.TextSize = 10
    mapLabel.Font = Enum.Font.GothamBold
    table.insert(minimapObjects, mapLabel)
    
    -- Точки монет
    for _, coin in ipairs(coins) do
        if coin and coin:IsA("BasePart") then
            local pos = coin.Position
            local vec, onScreen = cam:WorldToScreenPoint(pos)
            
            if onScreen then
                local dot = Instance.new("Frame", mapFrame)
                dot.Size = UDim2.new(0, 6, 0, 6)
                dot.Position = UDim2.new(
                    0, math.clamp(vec.X / viewport.X * 100, 5, 110),
                    0, math.clamp(vec.Y / viewport.Y * 100 + 15, 20, 110)
                )
                dot.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                dot.BorderSizePixel = 0
                table.insert(minimapObjects, dot)
            end
        end
    end
end

-- === СОЗДАНИЕ GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CoinFarmGUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- ОСНОВНАЯ ПАНЕЛЬ
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 200, 0)
MainFrame.Position = UDim2.new(0.5, -220, 0.5, -260)
MainFrame.Size = UDim2.new(0, 440, 0, 520)
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true

-- ЗАГОЛОВОК
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🪙 ФАРМ МОНЕТ v3.0"
Title.TextColor3 = Color3.fromRGB(255, 200, 0)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -42, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseBtn.BackgroundTransparency = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 18
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- КОНТЕЙНЕР
local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, 0, 1, -50)
Container.Position = UDim2.new(0, 0, 0, 50)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.CanvasSize = UDim2.new(0, 0, 0, 500)
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 0)

-- === КРУГЛАЯ КНОПКА ФАРМА ===
local FarmBtn = Instance.new("TextButton", Container)
FarmBtn.Size = UDim2.new(0.5, 0, 0.25, 0)
FarmBtn.Position = UDim2.new(0.25, 0, 0.02, 0)
FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
FarmBtn.BackgroundTransparency = 0
FarmBtn.Text = "🪙\nФАРМ"
FarmBtn.TextColor3 = Color3.new(1, 1, 1)
FarmBtn.TextSize = 22
FarmBtn.BorderSizePixel = 3
FarmBtn.BorderColor3 = Color3.fromRGB(0, 255, 150)
FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.ClipsDescendants = true

local UICorner = Instance.new("UICorner", FarmBtn)
UICorner.CornerRadius = UDim.new(1, 0)

local FarmStatus = Instance.new("TextLabel", FarmBtn)
FarmStatus.Size = UDim2.new(1, 0, 0.3, 0)
FarmStatus.Position = UDim2.new(0, 0, 0.7, 0)
FarmStatus.BackgroundTransparency = 1
FarmStatus.Text = "НАЖМИ"
FarmStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
FarmStatus.TextSize = 13
FarmStatus.Font = Enum.Font.GothamBold

-- === КНОПКИ УПРАВЛЕНИЯ ===
local EspBtn = Instance.new("TextButton", Container)
EspBtn.Size = UDim2.new(0.3, 0, 0.15, 0)
EspBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
EspBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
EspBtn.BackgroundTransparency = 0
EspBtn.Text = "👁️\nESP"
EspBtn.TextColor3 = Color3.new(1, 1, 1)
EspBtn.TextSize = 14
EspBtn.BorderSizePixel = 2
EspBtn.BorderColor3 = Color3.fromRGB(0, 200, 255)
EspBtn.Font = Enum.Font.GothamBold
EspBtn.ClipsDescendants = true

local EspCorner = Instance.new("UICorner", EspBtn)
EspCorner.CornerRadius = UDim.new(0.3, 0)

local MapBtn = Instance.new("TextButton", Container)
MapBtn.Size = UDim2.new(0.3, 0, 0.15, 0)
MapBtn.Position = UDim2.new(0.35, 0, 0.3, 0)
MapBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
MapBtn.BackgroundTransparency = 0
MapBtn.Text = "🗺️\nКАРТА"
MapBtn.TextColor3 = Color3.new(1, 1, 1)
MapBtn.TextSize = 14
MapBtn.BorderSizePixel = 2
MapBtn.BorderColor3 = Color3.fromRGB(200, 100, 255)
MapBtn.Font = Enum.Font.GothamBold
MapBtn.ClipsDescendants = true

local MapCorner = Instance.new("UICorner", MapBtn)
MapCorner.CornerRadius = UDim.new(0.3, 0)

local ResetBtn = Instance.new("TextButton", Container)
ResetBtn.Size = UDim2.new(0.3, 0, 0.15, 0)
ResetBtn.Position = UDim2.new(0.65, 0, 0.3, 0)
ResetBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
ResetBtn.BackgroundTransparency = 0
ResetBtn.Text = "🔄\nСБРОС"
ResetBtn.TextColor3 = Color3.new(1, 1, 1)
ResetBtn.TextSize = 14
ResetBtn.BorderSizePixel = 2
ResetBtn.BorderColor3 = Color3.fromRGB(255, 150, 50)
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.ClipsDescendants = true

local ResetCorner = Instance.new("UICorner", ResetBtn)
ResetCorner.CornerRadius = UDim.new(0.3, 0)

-- === СТАТИСТИКА ===
local StatsText = Instance.new("TextLabel", Container)
StatsText.Size = UDim2.new(0.9, 0, 0.12, 0)
StatsText.Position = UDim2.new(0.05, 0, 0.48, 0)
StatsText.BackgroundTransparency = 1
StatsText.Text = "📊 Собрано: 0 | ⏱️ 0с | 🚀 0 монет/мин"
StatsText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsText.TextSize = 13
StatsText.Font = Enum.Font.Gotham

-- === СТАТУС ===
local StatusText = Instance.new("TextLabel", Container)
StatusText.Size = UDim2.new(0.9, 0, 0.1, 0)
StatusText.Position = UDim2.new(0.05, 0, 0.62, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "🟢 Готов"
StatusText.TextColor3 = Color3.fromRGB(150, 150, 180)
StatusText.TextSize = 13
StatusText.Font = Enum.Font.Gotham

-- === ИНФО О МОНЕТЕ ===
local CoinInfo = Instance.new("TextLabel", Container)
CoinInfo.Size = UDim2.new(0.9, 0, 0.1, 0)
CoinInfo.Position = UDim2.new(0.05, 0, 0.73, 0)
CoinInfo.BackgroundTransparency = 1
CoinInfo.Text = "🎯 Поиск монет..."
CoinInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
CoinInfo.TextSize = 12
CoinInfo.Font = Enum.Font.Gotham

-- === ТАЙМЕР ===
local TimerText = Instance.new("TextLabel", Container)
TimerText.Size = UDim2.new(0.9, 0, 0.1, 0)
TimerText.Position = UDim2.new(0.05, 0, 0.84, 0)
TimerText.BackgroundTransparency = 1
TimerText.Text = "⏱️ Ожидание: 0с"
TimerText.TextColor3 = Color3.fromRGB(255, 200, 100)
TimerText.TextSize = 12
TimerText.Font = Enum.Font.Gotham

-- === КНОПКА ОТКРЫТИЯ/ЗАКРЫТИЯ ===
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
ToggleBtn.BackgroundTransparency = 0
ToggleBtn.Text = "🪙"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextSize = 28
ToggleBtn.BorderSizePixel = 2
ToggleBtn.BorderColor3 = Color3.fromRGB(255, 220, 50)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Visible = true

local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(1, 0)

-- Перетаскивание кнопки
local toggleDragging = false
local dragStart, dragStartPos

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDragging = true
        dragStart = input.Position
        dragStartPos = ToggleBtn.Position
    end
end)

ToggleBtn.InputChanged:Connect(function(input)
    if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            dragStartPos.X.Scale + delta.X / game:GetService("CoreGui").AbsoluteSize.X,
            0,
            dragStartPos.Y.Scale + delta.Y / game:GetService("CoreGui").AbsoluteSize.Y,
            0
        )
        ToggleBtn.Position = newPos
    end
end)

ToggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDragging = false
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- === ЛОГИКА ===
local farming = false
local coinsCollected = 0
local startTime = os.time()
local waitTimer = 0

-- === ФУНКЦИЯ ОБНОВЛЕНИЯ КНОПКИ ===
local function updateButton(isFarming)
    if isFarming then
        FarmBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        FarmBtn.BorderColor3 = Color3.fromRGB(255, 100, 100)
        FarmStatus.Text = "ФАРМ"
        FarmStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
        StatusText.Text = "🔴 Фарм запущен!"
    else
        FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        FarmBtn.BorderColor3 = Color3.fromRGB(0, 255, 150)
        FarmStatus.Text = "НАЖМИ"
        FarmStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
        StatusText.Text = "🟢 Остановлен"
    end
end

-- === ФАРМ ЛУП ===
local function farmLoop()
    while farming do
        RunService.Heartbeat:Wait()
        
        setNoClip(true)
        
        local coins = getAllCoins()
        local coin = nil
        
        if #coins > 0 then
            coin = coins[1]
        end
        
        if not coin then
            StatusText.Text = "⏳ Ожидание монет..."
            CoinInfo.Text = "❌ Монет нет на карте"
            TimerText.Text = "⏱️ Ожидание: " .. waitTimer .. "с"
            waitTimer = waitTimer + 1
            wait(1)
            continue
        end
        
        waitTimer = 0
        TimerText.Text = "⏱️ Монета найдена!"
        
        CoinInfo.Text = "✅ Монета найдена! Летим..."
        StatusText.Text = "🚀 Летим к монете..."
        FarmStatus.Text = "ЛЕТИТ"
        
        local success = flyToCoin(coin)
        
        if success then
            coinsCollected = coinsCollected + 1
            local elapsed = os.time() - startTime
            local rate = elapsed > 0 and math.floor(coinsCollected / elapsed * 60) or 0
            
            StatsText.Text = "📊 Собрано: " .. coinsCollected .. " | ⏱️ " .. elapsed .. "с | 🚀 " .. rate .. " монет/мин"
            StatusText.Text = "✅ Монета собрана! (" .. coinsCollected .. ")"
            FarmStatus.Text = "ГОТОВ"
            wait(0.5)
        else
            StatusText.Text = "⚠️ Ошибка полёта"
            FarmStatus.Text = "ОШИБКА"
            wait(1)
        end
        
        wait(0.3)
    end
    
    setNoClip(false)
    updateButton(false)
    CoinInfo.Text = "✅ Готов"
    TimerText.Text = "⏱️ Остановлен"
end

-- === ОБРАБОТЧИКИ ===
FarmBtn.MouseButton1Click:Connect(function()
    if farming then
        farming = false
        updateButton(false)
    else
        farming = true
        updateButton(true)
        startTime = os.time()
        coinsCollected = 0
        waitTimer = 0
        StatsText.Text = "📊 Собрано: 0 | ⏱️ 0с | 🚀 0 монет/мин"
        CoinInfo.Text = "🪙 Поиск монет..."
        coroutine.wrap(farmLoop)()
    end
end)

EspBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    EspBtn.Text = espEnabled and "👁️\nESP" or "👁️\nВЫКЛ"
    EspBtn.BorderColor3 = espEnabled and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(200, 50, 50)
    if not espEnabled then
        for _, v in ipairs(espObjects) do v:Destroy() end
        espObjects = {}
    end
end)

MapBtn.MouseButton1Click:Connect(function()
    minimapEnabled = not minimapEnabled
    MapBtn.Text = minimapEnabled and "🗺️\nКАРТА" or "🗺️\nВЫКЛ"
    MapBtn.BorderColor3 = minimapEnabled and Color3.fromRGB(200, 100, 255) or Color3.fromRGB(200, 50, 50)
    if not minimapEnabled then
        for _, v in ipairs(minimapObjects) do v:Destroy() end
        minimapObjects = {}
    end
end)

ResetBtn.MouseButton1Click:Connect(function()
    if Char and Char:FindFirstChild("HumanoidRootPart") then
        Char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        StatusText.Text = "🔄 Позиция сброшена!"
        waitTimer = 0
        TimerText.Text = "⏱️ Сброс позиции"
    end
end)

-- === ОБНОВЛЕНИЯ ===
coroutine.wrap(function()
    while true do
        RunService.Heartbeat:Wait()
        updateCoinESP()
        updateMinimap()
    end
end)()

-- === ОТКРЫТИЕ ПО ALT ===
UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightAlt or input.KeyCode == Enum.KeyCode.LeftAlt then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- === ПРИ ПЕРЕСОЗДАНИИ ПЕРСОНАЖА ===
LP.CharacterAdded:Connect(function(newChar)
    Char = newChar
end)

-- === СТАРТ ===
local coins = getAllCoins()
CoinInfo.Text = #coins > 0 and "✅ Найдено монет: " .. #coins or "❌ Монет не найдено!"
StatusText.Text = #coins > 0 and "🟢 Нажми ФАРМ" or "❌ Проверь путь!"

print("🪙 ФАРМ МОНЕТ v3.0 (MEGA UPDATE)")
print("📊 Счётчик монет | ⏱️ Таймер | 🗺️ Мини-карта")
print("📱 Кнопка 🪙 перетаскивается")
print("🎯 Alt — открыть/закрыть")