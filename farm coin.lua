-- ROBOT ESCAPE — ФАРМ МОНЕТ v1.0
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

-- === ТВОЙ ПУТЬ К МОНЕТЕ ===
local function getCoin()
    local summerCoins = workspace:FindFirstChild("SummerCoinsLocal")
    if summerCoins then
        local children = summerCoins:GetChildren()
        if #children >= 3 then
            local obj = children[3]
            if obj then
                local coin = obj:FindFirstChild("Coin")
                if coin and coin:IsA("BasePart") then
                    return coin
                end
            end
        end
    end
    return nil
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

-- === ПЛАВНЫЙ ПОЛЁТ К МОНЕТЕ ===
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
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -180)
MainFrame.Size = UDim2.new(0, 360, 0, 360)
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
Title.Text = "🪙 ФАРМ МОНЕТ"
Title.TextColor3 = Color3.fromRGB(255, 200, 0)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold

-- КНОПКА ЗАКРЫТЬ
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
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, 0, 1, -50)
Container.Position = UDim2.new(0, 0, 0, 50)
Container.BackgroundTransparency = 1

-- === КРУГЛАЯ КНОПКА ФАРМА ===
local FarmBtn = Instance.new("TextButton", Container)
FarmBtn.Size = UDim2.new(0.6, 0, 0.5, 0)
FarmBtn.Position = UDim2.new(0.2, 0, 0.15, 0)
FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
FarmBtn.BackgroundTransparency = 0
FarmBtn.Text = "🪙\nФАРМ"
FarmBtn.TextColor3 = Color3.new(1, 1, 1)
FarmBtn.TextSize = 24
FarmBtn.BorderSizePixel = 3
FarmBtn.BorderColor3 = Color3.fromRGB(0, 255, 150)
FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.ClipsDescendants = true

-- Скругление кнопки
local UICorner = Instance.new("UICorner", FarmBtn)
UICorner.CornerRadius = UDim.new(1, 0)

-- Статус на кнопке
local FarmStatus = Instance.new("TextLabel", FarmBtn)
FarmStatus.Size = UDim2.new(1, 0, 0.3, 0)
FarmStatus.Position = UDim2.new(0, 0, 0.7, 0)
FarmStatus.BackgroundTransparency = 1
FarmStatus.Text = "НАЖМИ"
FarmStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
FarmStatus.TextSize = 14
FarmStatus.Font = Enum.Font.GothamBold

-- === СТАТУС ===
local StatusText = Instance.new("TextLabel", Container)
StatusText.Size = UDim2.new(0.9, 0, 0.15, 0)
StatusText.Position = UDim2.new(0.05, 0, 0.75, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "🟢 Готов"
StatusText.TextColor3 = Color3.fromRGB(150, 150, 180)
StatusText.TextSize = 14
StatusText.Font = Enum.Font.Gotham

-- === ИНФО О МОНЕТЕ ===
local CoinInfo = Instance.new("TextLabel", Container)
CoinInfo.Size = UDim2.new(0.9, 0, 0.15, 0)
CoinInfo.Position = UDim2.new(0.05, 0, 0.6, 0)
CoinInfo.BackgroundTransparency = 1
CoinInfo.Text = "🎯 Поиск монеты..."
CoinInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
CoinInfo.TextSize = 13
CoinInfo.Font = Enum.Font.Gotham

-- === КНОПКА ОТКРЫТИЯ/ЗАКРЫТИЯ (ПЕРЕТАСКИВАЕМАЯ) ===
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

-- Скругление кнопки
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
local farmRunning = false

-- === ФАРМ ЛУП ===
local function farmLoop()
    while farming do
        RunService.Heartbeat:Wait()
        
        -- Включаем NOCLIP
        setNoClip(true)
        
        local coin = getCoin()
        
        if not coin then
            StatusText.Text = "❌ Монета не найдена!"
            CoinInfo.Text = "❌ SummerCoinsLocal[3].Coin не найдена"
            wait(2)
            continue
        end
        
        CoinInfo.Text = "✅ Монета найдена! Летим..."
        StatusText.Text = "🚀 Летим к монете..."
        FarmStatus.Text = "ЛЕТИТ"
        
        local success = flyToCoin(coin)
        
        if success then
            StatusText.Text = "✅ Монета собрана! Повтор..."
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
    FarmStatus.Text = "НАЖМИ"
    StatusText.Text = "🟢 Остановлен"
    CoinInfo.Text = "✅ Готов"
end

-- === ОБРАБОТЧИК КНОПКИ ===
FarmBtn.MouseButton1Click:Connect(function()
    if farming then
        farming = false
        FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        FarmBtn.BorderColor3 = Color3.fromRGB(0, 255, 150)
        FarmStatus.Text = "НАЖМИ"
        StatusText.Text = "🟢 Остановлен"
    else
        local coin = getCoin()
        if not coin then
            StatusText.Text = "❌ Монета не найдена!"
            CoinInfo.Text = "❌ Проверь путь!"
            return
        end
        
        farming = true
        FarmBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        FarmBtn.BorderColor3 = Color3.fromRGB(255, 100, 100)
        FarmStatus.Text = "ФАРМ"
        StatusText.Text = "🟢 Фарм запущен!"
        CoinInfo.Text = "🪙 " .. coin:GetFullName()
        
        coroutine.wrap(farmLoop)()
    end
end)

-- === ПРОВЕРКА МОНЕТЫ ПРИ СТАРТЕ ===
local function checkCoinAtStart()
    local coin = getCoin()
    if coin then
        CoinInfo.Text = "✅ Монета найдена!"
        StatusText.Text = "🟢 Нажми ФАРМ"
    else
        CoinInfo.Text = "❌ Монета не найдена!"
        StatusText.Text = "❌ Проверь путь!"
    end
end

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
checkCoinAtStart()

print("🪙 ФАРМ МОНЕТ v1.0")
print("📂 Путь: workspace.SummerCoinsLocal[3].Coin")
print("📱 Кнопка 🪙 перетаскивается")
print("🎯 Alt — открыть/закрыть")
print("🔴 Нажми ФАРМ для старта")