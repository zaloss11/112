-- ClientGUI.lua - Клиентский интерфейс игрока
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ClientGUI = {}

-- Создание основного GUI
function ClientGUI:CreateMainGUI()
    -- Удаляем существующий GUI, если есть
    local existingGUI = playerGui:FindFirstChild("MainGUI")
    if existingGUI then
        existingGUI:Destroy()
    end
    
    -- Создаем основной GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MainGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Основная панель ресурсов
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "ResourcePanel"
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.new(0.8, 0.8, 0.8)
    mainFrame.Parent = screenGui
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
    titleLabel.Text = "РЕСУРСЫ"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    -- Деньги
    local moneyFrame = Instance.new("Frame")
    moneyFrame.Size = UDim2.new(1, -10, 0, 25)
    moneyFrame.Position = UDim2.new(0, 5, 0, 35)
    moneyFrame.BackgroundColor3 = Color3.new(0.2, 0.5, 0.2)
    moneyFrame.BorderSizePixel = 1
    moneyFrame.BorderColor3 = Color3.new(0.4, 0.8, 0.4)
    moneyFrame.Parent = mainFrame
    
    local moneyLabel = Instance.new("TextLabel")
    moneyLabel.Size = UDim2.new(1, 0, 1, 0)
    moneyLabel.BackgroundTransparency = 1
    moneyLabel.Text = "Деньги: 0₽"
    moneyLabel.TextColor3 = Color3.new(1, 1, 1)
    moneyLabel.TextScaled = true
    moneyLabel.Font = Enum.Font.SourceSansBold
    moneyLabel.Parent = moneyFrame
    
    -- Ресурсы
    local resources = {"Stone", "Copper", "Tin"}
    local resourceLabels = {}
    
    for i, resourceName in ipairs(resources) do
        local resourceFrame = Instance.new("Frame")
        resourceFrame.Size = UDim2.new(1, -10, 0, 25)
        resourceFrame.Position = UDim2.new(0, 5, 0, 65 + (i-1) * 30)
        resourceFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        resourceFrame.BorderSizePixel = 1
        resourceFrame.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
        resourceFrame.Parent = mainFrame
        
        local resourceLabel = Instance.new("TextLabel")
        resourceLabel.Size = UDim2.new(1, 0, 1, 0)
        resourceLabel.BackgroundTransparency = 1
        resourceLabel.Text = resourceName .. ": 0"
        resourceLabel.TextColor3 = Color3.new(1, 1, 1)
        resourceLabel.TextScaled = true
        resourceLabel.Font = Enum.Font.SourceSans
        resourceLabel.Parent = resourceFrame
        
        resourceLabels[resourceName] = resourceLabel
    end
    
    -- Сохраняем ссылки для обновления
    self.MoneyLabel = moneyLabel
    self.ResourceLabels = resourceLabels
    
    -- Создаем панель информации о разблокированных клетках
    self:CreateTileInfoPanel(screenGui)
end

-- Создание панели информации о клетках
function ClientGUI:CreateTileInfoPanel(parent)
    local tileInfoFrame = Instance.new("Frame")
    tileInfoFrame.Name = "TileInfoPanel"
    tileInfoFrame.Size = UDim2.new(0, 200, 0, 100)
    tileInfoFrame.Position = UDim2.new(0, 20, 0, 240)
    tileInfoFrame.BackgroundColor3 = Color3.new(0.1, 0.2, 0.4)
    tileInfoFrame.BackgroundTransparency = 0.2
    tileInfoFrame.BorderSizePixel = 2
    tileInfoFrame.BorderColor3 = Color3.new(0.3, 0.6, 0.8)
    tileInfoFrame.Parent = parent
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.new(0.05, 0.1, 0.2)
    titleLabel.Text = "ШАХТА"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = tileInfoFrame
    
    -- Количество разблокированных клеток
    local tilesLabel = Instance.new("TextLabel")
    tilesLabel.Size = UDim2.new(1, -10, 0, 30)
    tilesLabel.Position = UDim2.new(0, 5, 0, 35)
    tilesLabel.BackgroundTransparency = 1
    tilesLabel.Text = "Клетки: 1/100"
    tilesLabel.TextColor3 = Color3.new(0.8, 0.8, 1)
    tilesLabel.TextScaled = true
    tilesLabel.Font = Enum.Font.SourceSans
    tilesLabel.Parent = tileInfoFrame
    
    -- Следующая стоимость
    local nextCostLabel = Instance.new("TextLabel")
    nextCostLabel.Size = UDim2.new(1, -10, 0, 30)
    nextCostLabel.Position = UDim2.new(0, 5, 0, 65)
    nextCostLabel.BackgroundTransparency = 1
    nextCostLabel.Text = "Следующая: 100₽"
    nextCostLabel.TextColor3 = Color3.new(1, 1, 0.5)
    nextCostLabel.TextScaled = true
    nextCostLabel.Font = Enum.Font.SourceSans
    nextCostLabel.Parent = tileInfoFrame
    
    self.TilesLabel = tilesLabel
    self.NextCostLabel = nextCostLabel
end

-- Создание панели управления
function ClientGUI:CreateControlPanel()
    local screenGui = playerGui:FindFirstChild("MainGUI")
    if not screenGui then return end
    
    local controlFrame = Instance.new("Frame")
    controlFrame.Name = "ControlPanel"
    controlFrame.Size = UDim2.new(0, 150, 0, 150)
    controlFrame.Position = UDim2.new(1, -170, 0, 20)
    controlFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    controlFrame.BackgroundTransparency = 0.2
    controlFrame.BorderSizePixel = 2
    controlFrame.BorderColor3 = Color3.new(0.8, 0.8, 0.8)
    controlFrame.Parent = screenGui
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    titleLabel.Text = "УПРАВЛЕНИЕ"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = controlFrame
    
    -- Кнопка перехода к торговцу
    local traderButton = Instance.new("TextButton")
    traderButton.Size = UDim2.new(1, -10, 0, 40)
    traderButton.Position = UDim2.new(0, 5, 0, 35)
    traderButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    traderButton.Text = "К ТОРГОВЦУ"
    traderButton.TextColor3 = Color3.new(1, 1, 1)
    traderButton.TextScaled = true
    traderButton.Font = Enum.Font.SourceSansBold
    traderButton.Parent = controlFrame
    
    traderButton.MouseButton1Click:Connect(function()
        self:TeleportToTrader()
    end)
    
    -- Кнопка возврата к шахте
    local mineButton = Instance.new("TextButton")
    mineButton.Size = UDim2.new(1, -10, 0, 40)
    mineButton.Position = UDim2.new(0, 5, 0, 80)
    mineButton.BackgroundColor3 = Color3.new(0.6, 0.4, 0.2)
    mineButton.Text = "К ШАХТЕ"
    mineButton.TextColor3 = Color3.new(1, 1, 1)
    mineButton.TextScaled = true
    mineButton.Font = Enum.Font.SourceSansBold
    mineButton.Parent = controlFrame
    
    mineButton.MouseButton1Click:Connect(function()
        self:TeleportToMine()
    end)
end

-- Телепорт к торговцу
function ClientGUI:TeleportToTrader()
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Позиция рядом с торговцем
    humanoidRootPart.CFrame = CFrame.new(45, 5, 5)
end

-- Телепорт к шахте
function ClientGUI:TeleportToMine()
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Позиция над первой клеткой
    humanoidRootPart.CFrame = CFrame.new(-5, 10, -5)
end

-- Обновление данных GUI (заглушка - будет обновляться через RemoteEvents)
function ClientGUI:UpdateGUI(playerData)
    if not playerData then return end
    
    -- Обновляем деньги
    if self.MoneyLabel then
        self.MoneyLabel.Text = "Деньги: " .. playerData.Money .. "₽"
    end
    
    -- Обновляем ресурсы
    if self.ResourceLabels and playerData.Inventory then
        for resourceName, amount in pairs(playerData.Inventory) do
            local label = self.ResourceLabels[resourceName]
            if label then
                label.Text = resourceName .. ": " .. amount
            end
        end
    end
    
    -- Обновляем информацию о клетках
    if self.TilesLabel and playerData.UnlockedTiles then
        self.TilesLabel.Text = "Клетки: " .. playerData.UnlockedTiles .. "/100"
    end
    
    if self.NextCostLabel and playerData.UnlockedTiles then
        local nextCost = math.floor(100 * (1.5 ^ (playerData.UnlockedTiles - 1)))
        self.NextCostLabel.Text = "Следующая: " .. nextCost .. "₽"
    end
end

-- Создание подсказок для новых игроков
function ClientGUI:CreateTutorialHints()
    local screenGui = playerGui:FindFirstChild("MainGUI")
    if not screenGui then return end
    
    local hintFrame = Instance.new("Frame")
    hintFrame.Name = "TutorialHints"
    hintFrame.Size = UDim2.new(0, 350, 0, 120)
    hintFrame.Position = UDim2.new(0.5, -175, 1, -140)
    hintFrame.BackgroundColor3 = Color3.new(0.1, 0.3, 0.1)
    hintFrame.BackgroundTransparency = 0.1
    hintFrame.BorderSizePixel = 2
    hintFrame.BorderColor3 = Color3.new(0.3, 0.8, 0.3)
    hintFrame.Parent = screenGui
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.new(0.05, 0.2, 0.05)
    titleLabel.Text = "ПОДСКАЗКИ"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = hintFrame
    
    -- Текст подсказок
    local hintsText = {
        "• Кликайте по камням для добычи ресурсов",
        "• Продавайте ресурсы торговцу за деньги",
        "• Покупайте новые клетки для расширения шахты",
        "• Разные камни дают разные ресурсы"
    }
    
    for i, hint in ipairs(hintsText) do
        local hintLabel = Instance.new("TextLabel")
        hintLabel.Size = UDim2.new(1, -10, 0, 20)
        hintLabel.Position = UDim2.new(0, 5, 0, 20 + i * 22)
        hintLabel.BackgroundTransparency = 1
        hintLabel.Text = hint
        hintLabel.TextColor3 = Color3.new(0.9, 1, 0.9)
        hintLabel.TextScaled = true
        hintLabel.Font = Enum.Font.SourceSans
        hintLabel.TextXAlignment = Enum.TextXAlignment.Left
        hintLabel.Parent = hintFrame
    end
end

-- Инициализация
function ClientGUI:Initialize()
    -- Ждем загрузки персонажа
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    -- Создаем GUI
    self:CreateMainGUI()
    self:CreateControlPanel()
    self:CreateTutorialHints()
    
    print("ClientGUI инициализирован!")
end

-- Запуск при загрузке
ClientGUI:Initialize()

-- Обновление GUI каждую секунду (простое решение)
-- В реальной игре лучше использовать RemoteEvents
spawn(function()
    while true do
        wait(1)
        -- Здесь бы была логика получения данных с сервера
        -- Пока что GUI показывает статическую информацию
    end
end)

return ClientGUI