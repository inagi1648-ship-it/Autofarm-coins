-- +1 SPEED KEYBOARD ESCAPE — УМНЫЙ БЕЗОПАСНЫЙ ФАРМ v4.1
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()

print("🧠 Умный безопасный фарм v4.1 загружен")

-- === НАСТРОЙКИ ===
local FLEE_RADIUS = 40
local DANGER_AROUND_PLAYER = 25
local DANGER_AROUND_COIN = 20
local FLY_SPEED = 70
local MIN_SPEED = 20
local MAX_SPEED = 120
local RECONNECT_TIMEOUT = 30
local STATE_FILE = "SmartFarmState.txt"

-- === СОХРАНЕНИЕ СОСТОЯНИЯ ===
local function saveState(state)
    pcall(function()
        if writefile then
            writefile(STATE_FILE, state and "ON" or "OFF")
        end
    end)
end

local function loadState()
    local state = "OFF"
    pcall(function()
        if isfile and isfile(STATE_FILE) then
            state = readfile(STATE_FILE)
        end
    end)
    return state == "ON"
end

-- === УДАЛЯЕМ СТАРЫЕ GUI ===
for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name:find("SmartFarm") then
        v:Destroy()
    end
end
for _, v in ipairs(LP:WaitForChild("PlayerGui"):GetChildren()) do
    if v.Name:find("SmartFarm") then
        v:Destroy()
    end
end

-- === ПОИСК МОНЕТ ===
local function getAllCoins()
    local coins = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("coin") then
            table.insert(coins, obj)
        end
    end
    return coins
end

-- === ПОИСК ОПАСНОСТЕЙ ===
local function getDangerousEntities()
    local dangers = {}
    local npc = workspace:FindFirstChild("NPC & Piege")
    if npc then
        local zone1 = npc:FindFirstChild("Zone1")
        if zone1 then
            local ballerina = zone1:FindFirstChild("BallerinaChocolita")
            if ballerina then
                local hitbox = ballerina:FindFirstChild("Hitbox")
                if hitbox and hitbox:IsA("BasePart") then
                    table.insert(dangers, hitbox)
                end
            end
        end
        local ball1 = npc:FindFirstChild("Ball1")
        if ball1 then
            local killBall = ball1:FindFirstChild("KillBall")
            if killBall and killBall:IsA("BasePart") then
                table.insert(dangers, killBall)
            end
        end
    end
    local structure = workspace:FindFirstChild("Structure")
    if structure then
        for _, stageName in ipairs({"Stage6", "Stage7", "Stage8"}) do
            local stage = structure:FindFirstChild(stageName)
            if stage then
                local wall = stage:FindFirstChild("TransparentWall" .. stageName)
                if wall and wall:IsA("BasePart") then
                    table.insert(dangers, wall)
                end
            end
        end
    end
    return dangers
end

-- === БЛИЖАЙШАЯ ОПАСНОСТЬ ===
local function getClosestDanger()
    local dangers = getDangerousEntities()
    if #dangers == 0 then return nil, math.huge end
    local hrp = Char and Char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, math.huge end
    local closest = nil
    local closestDist = math.huge
    for _, danger in ipairs(dangers) do
        if danger and danger:IsA("BasePart") then
            local dist = (danger.Position - hrp.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = danger
            end
        end
    end
    return closest, closestDist
end

-- === ПРОВЕРКА БЕЗОПАСНОСТИ МОНЕТЫ ===
local function isCoinSafe(coin)
    if not coin then return false end
    local dangers = getDangerousEntities()
    for _, danger in ipairs(dangers) do
        if danger and danger:IsA("BasePart") then
            local distToDanger = (coin.Position - danger.Position).Magnitude
            if distToDanger < DANGER_AROUND_COIN then
                return false
            end
        end
    end
    return true
end

-- === БЕЗОПАСНАЯ МОНЕТА ===
local function getClosestSafeCoin()
    local coins = getAllCoins()
    if #coins == 0 then return nil end
    local hrp = Char and Char:FindFirstChild("HumanoidRootPart")
    if not hrp then return coins[1] end
    local safeCoins = {}
    for _, coin in ipairs(coins) do
        if isCoinSafe(coin) then
            table.insert(safeCoins, coin)
        end
    end
    if #safeCoins == 0 then return nil end
    local closest = nil
    local closestDist = math.huge
    for _, coin in ipairs(safeCoins) do
        local dist = (coin.Position - hrp.Position).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = coin
        end
    end
    return closest
end

-- === БЕЗОПАСНОЕ МЕСТО ===
local function findSafePosition()
    local hrp = Char and Char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local danger, dist = getClosestDanger()
    if not danger then return nil end
    local direction = (hrp.Position - danger.Position).Unit
    for i = 30, 80, 10 do
        local testPos = hrp.Position + direction * i
        local ray = Ray.new(hrp.Position, direction * i)
        local hit = workspace:FindPartOnRay(ray, Char)
        if not hit then
            return testPos
        end
    end
    return hrp.Position + direction * 50
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

-- === ПОЛЁТ С ПРОВЕРКОЙ ===
local function flyToPositionSafely(targetPos)
    if not targetPos or not Char or not Char:FindFirstChild("HumanoidRootPart") then
        return false
    end
    local hrp = Char.HumanoidRootPart
    local startPos = hrp.Position
    local distance = (startPos - targetPos).Magnitude
    if distance < 3 then
        hrp.CFrame = CFrame.new(targetPos)
        return true
    end
    local danger, dist = getClosestDanger()
    if danger and dist < DANGER_AROUND_PLAYER then
        local safePos = findSafePosition()
        if safePos then
            local fleeTween = TweenService:Create(hrp, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
                CFrame = CFrame.new(safePos)
            })
            fleeTween:Play()
            fleeTween.Completed:Wait()
            StatusText.Text = "🏃 УБЕГАЮ!"
            return false
        end
    end
    local steps = math.max(5, math.min(20, math.floor(distance / 10)))
    local stepSize = 1 / steps
    for i = 1, steps do
        if not farming then return false end
        local progress = i * stepSize
        local currentPos = startPos + (targetPos - startPos) * progress
        local danger2, dist2 = getClosestDanger()
        if danger2 and dist2 < DANGER_AROUND_PLAYER then
            local safePos = findSafePosition()
            if safePos then
                local fleeTween = TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    CFrame = CFrame.new(safePos)
                })
                fleeTween:Play()
                fleeTween.Completed:Wait()
                return false
            end
        end
        local stepTween = TweenService:Create(hrp, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(currentPos)
        })
        stepTween:Play()
        stepTween.Completed:Wait()
    end
    local finalTween = TweenService:Create(hrp, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        CFrame = CFrame.new(targetPos)
    })
    finalTween:Play()
    finalTween.Completed:Wait()
    return true
end

-- === АВТО-РЕКОННЕКТ ===
local function reconnect()
    print("🔄 Авто-реконнект! Переход на другой сервер...")
    saveState(farming)
    task.wait(1)
    TeleportService:Teleport(game.PlaceId)
end

-- === GUI ===
local playerGui = LP:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SmartFarmGUI"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 100)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -260)
MainFrame.Size = UDim2.new(0, 400, 0, 520)
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "🧠 УМНЫЙ БЕЗОПАСНЫЙ ФАРМ v4.1"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextSize = 18
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

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, 0, 1, -50)
Container.Position = UDim2.new(0, 0, 0, 50)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.CanvasSize = UDim2.new(0, 0, 0, 600)
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 100)

local FarmBtn = Instance.new("TextButton", Container)
FarmBtn.Size = UDim2.new(0.5, 0, 0.15, 0)
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

-- === ПОЛЗУНОК СКОРОСТИ ===
local SpeedFrame = Instance.new("Frame", Container)
SpeedFrame.Size = UDim2.new(0.9, 0, 0, 55)
SpeedFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
SpeedFrame.BorderSizePixel = 0

local SpeedLabel = Instance.new("TextLabel", SpeedFrame)
SpeedLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
SpeedLabel.Position = UDim2.new(0.05, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "⚡ Скорость: " .. FLY_SPEED
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
SpeedLabel.TextSize = 14
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Font = Enum.Font.GothamBold

local SpeedSlider = Instance.new("Frame", SpeedFrame)
SpeedSlider.Size = UDim2.new(0.9, 0, 0.2, 0)
SpeedSlider.Position = UDim2.new(0.05, 0, 0.6, 0)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
SpeedSlider.BorderSizePixel = 0

local SpeedFill = Instance.new("Frame", SpeedSlider)
SpeedFill.Size = UDim2.new((FLY_SPEED - MIN_SPEED) / (MAX_SPEED - MIN_SPEED), 0, 1, 0)
SpeedFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
SpeedFill.BorderSizePixel = 0

local SpeedKnob = Instance.new("Frame", SpeedSlider)
SpeedKnob.Size = UDim2.new(0, 16, 0, 16)
SpeedKnob.Position = UDim2.new((FLY_SPEED - MIN_SPEED) / (MAX_SPEED - MIN_SPEED), -8, -0.5, -5)
SpeedKnob.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
SpeedKnob.BorderSizePixel = 0

local speedDragging = false
local function updateSpeedSlider(x)
    local trackSize = SpeedSlider.AbsoluteSize.X
    if trackSize == 0 then return end
    local relativeX = math.clamp((x - SpeedSlider.AbsolutePosition.X) / trackSize, 0, 1)
    SpeedFill.Size = UDim2.new(relativeX, 0, 1, 0)
    SpeedKnob.Position = UDim2.new(relativeX, -8, -0.5, -5)
    local value = math.round(MIN_SPEED + relativeX * (MAX_SPEED - MIN_SPEED))
    FLY_SPEED = value
    SpeedLabel.Text = "⚡ Скорость: " .. value
end

SpeedKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        speedDragging = true
        updateSpeedSlider(input.Position.X)
    end
end)
SpeedKnob.InputChanged:Connect(function(input)
    if speedDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSpeedSlider(input.Position.X)
    end
end)
SpeedKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        speedDragging = false
    end
end)

-- === СТАТУС ===
local StatusText = Instance.new("TextLabel", Container)
StatusText.Size = UDim2.new(0.9, 0, 0.08, 0)
StatusText.Position = UDim2.new(0.05, 0, 0.38, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "🟢 Готов"
StatusText.TextColor3 = Color3.fromRGB(150, 150, 180)
StatusText.TextSize = 14
StatusText.Font = Enum.Font.Gotham

local InfoText = Instance.new("TextLabel", Container)
InfoText.Size = UDim2.new(0.9, 0, 0.08, 0)
InfoText.Position = UDim2.new(0.05, 0, 0.48, 0)
InfoText.BackgroundTransparency = 1
InfoText.Text = "📦 Монет: 0"
InfoText.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoText.TextSize = 14
InfoText.Font = Enum.Font.Gotham

local DangerText = Instance.new("TextLabel", Container)
DangerText.Size = UDim2.new(0.9, 0, 0.08, 0)
DangerText.Position = UDim2.new(0.05, 0, 0.58, 0)
DangerText.BackgroundTransparency = 1
DangerText.Text = "🛡️ Опасностей: 0"
DangerText.TextColor3 = Color3.fromRGB(255, 200, 100)
DangerText.TextSize = 13
DangerText.Font = Enum.Font.Gotham

local TimerText = Instance.new("TextLabel", Container)
TimerText.Size = UDim2.new(0.9, 0, 0.08, 0)
TimerText.Position = UDim2.new(0.05, 0, 0.68, 0)
TimerText.BackgroundTransparency = 1
TimerText.Text = "⏱️ Бездействие: 0с"
TimerText.TextColor3 = Color3.fromRGB(255, 200, 100)
TimerText.TextSize = 13
TimerText.Font = Enum.Font.Gotham

local ReconnectStatus = Instance.new("TextLabel", Container)
ReconnectStatus.Size = UDim2.new(0.9, 0, 0.08, 0)
ReconnectStatus.Position = UDim2.new(0.05, 0, 0.78, 0)
ReconnectStatus.BackgroundTransparency = 1
ReconnectStatus.Text = ""
ReconnectStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
ReconnectStatus.TextSize = 14
ReconnectStatus.Font = Enum.Font.GothamBold

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
ToggleBtn.BackgroundTransparency = 0
ToggleBtn.Text = "🧠"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextSize = 28
ToggleBtn.BorderSizePixel = 2
ToggleBtn.BorderColor3 = Color3.fromRGB(0, 255, 150)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Visible = true
local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(1, 0)

-- Перетаскивание
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
            dragStartPos.X.Scale + delta.X / playerGui.AbsoluteSize.X,
            0,
            dragStartPos.Y.Scale + delta.Y / playerGui.AbsoluteSize.Y,
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
local collected = 0
local idleTime = 0

local function updateUI(isFarming)
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

FarmBtn.MouseButton1Click:Connect(function()
    if farming then
        farming = false
        updateUI(false)
        setNoClip(false)
        saveState(false)
        ReconnectStatus.Text = ""
        return
    end

    farming = true
    collected = 0
    idleTime = 0
    updateUI(true)
    StatusText.Text = "🧠 Умный фарм запущен"
    InfoText.Text = "📦 Собрано: 0"
    ReconnectStatus.Text = ""

    coroutine.wrap(function()
        while farming do
            setNoClip(true)

            -- 1. ОПАСНОСТЬ РЯДОМ С ИГРОКОМ
            local danger, dist = getClosestDanger()
            if danger and dist < DANGER_AROUND_PLAYER then
                local hrp = Char and Char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local safePos = findSafePosition()
                    if safePos then
                        flyToPositionSafely(safePos)
                        StatusText.Text = "🏃 УБЕГАЮ!"
                        task.wait(0.3)
                        continue
                    end
                end
            end

            -- 2. ПОИСК МОНЕТЫ
            local coin = getClosestSafeCoin()
            if not coin then
                idleTime = idleTime + 1
                TimerText.Text = "⏱️ Бездействие: " .. idleTime .. "с"
                
                -- Показываем предупреждение о реконнекте
                if idleTime >= RECONNECT_TIMEOUT - 5 then
                    ReconnectStatus.Text = "⚠️ Реконнект через " .. (RECONNECT_TIMEOUT - idleTime) .. "с"
                    ReconnectStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
                end
                
                if idleTime >= RECONNECT_TIMEOUT then
                    ReconnectStatus.Text = "🔄 Реконнект!"
                    ReconnectStatus.TextColor3 = Color3.fromRGB(255, 50, 50)
                    task.wait(3)
                    reconnect()
                    return
                end
                task.wait(1)
                continue
            end

            -- 3. СБРАСЫВАЕМ ТАЙМЕР
            idleTime = 0
            TimerText.Text = "⏱️ Бездействие: 0с"
            ReconnectStatus.Text = ""

            -- 4. ЛЕТИМ К МОНЕТЕ
            StatusText.Text = "🚀 Летим к монете..."
            local targetPos = coin.Position + Vector3.new(0, 1.5, 0)
            
            if not isCoinSafe(coin) then
                StatusText.Text = "🔄 М