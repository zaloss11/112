-- TraderManager.lua - Система торговца и экономики
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TraderManager = {}

-- Настройки торговца
TraderManager.Config = {
    TRADER_POSITION = Vector3.new(50, 5, 0),
    TILE_COST_BASE = 100, -- Базовая стоимость клетки
    TILE_COST_MULTIPLIER = 1.5, -- Множитель роста цены
}

-- Цены на ресурсы
TraderManager.ResourcePrices = {
    Stone = 1,
    Copper = 5,
    Tin = 8,
}

-- Создание торговца
function TraderManager:CreateTrader()
    local gameObjects = game.Workspace.GameObjects
    if not gameObjects then return end
    
    local npcsFolder = gameObjects.NPCs
    
    -- Создаем модель торговца
    local trader = Instance.new("Model")
    trader.Name = "Trader"
    trader.Parent = npcsFolder
    
    -- Основная часть торговца (торс)
    local torso = Instance.new("Part")
    torso.Name = "Torso"
    torso.Size = Vector3.new(4, 6, 2)
    torso.Color = Color3.new(0.8, 0.6, 0.4) -- Цвет кожи
    torso.Material = Enum.Material.Plastic
    torso.Shape = Enum.PartType.Block
    torso.CanCollide = true
    torso.Anchored = true
    torso.Position = self.Config.TRADER_POSITION
    torso.Parent = trader
    
    -- Голова
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 2, 2)
    head.Color = Color3.new(0.8, 0.6, 0.4)
    head.Material = Enum.Material.Plastic
    head.Shape = Enum.PartType.Ball
    head.CanCollide = false
    head.Anchored = true
    head.Position = torso.Position + Vector3.new(0, 4, 0)
    head.Parent = trader
    
    -- Табличка с именем
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = head
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Торговец Камней"
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Parent = billboard
    
    -- Прилавок
    local counter = Instance.new("Part")
    counter.Name = "Counter"
    counter.Size = Vector3.new(6, 3, 4)
    counter.Color = Color3.new(0.4, 0.2, 0.1) -- Коричневый цвет дерева
    counter.Material = Enum.Material.Wood
    counter.Shape = Enum.PartType.Block
    counter.CanCollide = true
    counter.Anchored = true
    counter.Position = torso.Position + Vector3.new(0, -2, 3)
    counter.Parent = trader
    
    -- ClickDetector для взаимодействия
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 20
    clickDetector.Parent = counter
    
    -- Обработка клика
    clickDetector.MouseClick:Connect(function(player)
        self:OpenTradeGUI(player)
    end)
    
    print("Торговец создан!")
end

-- Открытие торгового интерфейса
function TraderManager:OpenTradeGUI(player)
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    -- Удаляем существующий GUI, если есть
    local existingGUI = playerGui:FindFirstChild("TradeGUI")
    if existingGUI then
        existingGUI:Destroy()
    end
    
    -- Создаем новый GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TradeGUI"
    screenGui.Parent = playerGui
    
    -- Основная рамка
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.new(0.8, 0.8, 0.8)
    mainFrame.Parent = screenGui
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    titleLabel.Text = "ТОРГОВЕЦ КАМНЕЙ"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    -- Кнопка закрытия
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 10)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = mainFrame
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Создаем секции продажи ресурсов
    local yOffset = 60
    for resourceName, price in pairs(self.ResourcePrices) do
        self:CreateResourceSellSection(mainFrame, resourceName, price, yOffset, player)
        yOffset = yOffset + 80
    end
    
    -- Секция покупки клеток
    self:CreateTilePurchaseSection(mainFrame, yOffset, player)
end

-- Создание секции продажи ресурса
function TraderManager:CreateResourceSellSection(parent, resourceName, price, yPos, player)
    local GameManager = require(game.ServerScriptService.GameManager)
    
    -- Получаем количество ресурса у игрока
    local playerData = GameManager.PlayerData[player.UserId]
    if not playerData then return end
    
    local resourceAmount = playerData.Inventory[resourceName] or 0
    
    -- Рамка для ресурса
    local resourceFrame = Instance.new("Frame")
    resourceFrame.Size = UDim2.new(1, -20, 0, 70)
    resourceFrame.Position = UDim2.new(0, 10, 0, yPos)
    resourceFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    resourceFrame.BorderSizePixel = 1
    resourceFrame.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
    resourceFrame.Parent = parent
    
    -- Название ресурса
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.3, 0, 1, 0)
    nameLabel.Position = UDim2.new(0, 5, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = resourceName
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.Parent = resourceFrame
    
    -- Количество у игрока
    local amountLabel = Instance.new("TextLabel")
    amountLabel.Size = UDim2.new(0.2, 0, 1, 0)
    amountLabel.Position = UDim2.new(0.3, 0, 0, 0)
    amountLabel.BackgroundTransparency = 1
    amountLabel.Text = tostring(resourceAmount)
    amountLabel.TextColor3 = Color3.new(0.8, 0.8, 1)
    amountLabel.TextScaled = true
    amountLabel.Font = Enum.Font.SourceSans
    amountLabel.Parent = resourceFrame
    
    -- Цена
    local priceLabel = Instance.new("TextLabel")
    priceLabel.Size = UDim2.new(0.2, 0, 1, 0)
    priceLabel.Position = UDim2.new(0.5, 0, 0, 0)
    priceLabel.BackgroundTransparency = 1
    priceLabel.Text = price .. "₽"
    priceLabel.TextColor3 = Color3.new(1, 1, 0.5)
    priceLabel.TextScaled = true
    priceLabel.Font = Enum.Font.SourceSans
    priceLabel.Parent = resourceFrame
    
    -- Кнопка продажи
    local sellButton = Instance.new("TextButton")
    sellButton.Size = UDim2.new(0.25, -5, 0.8, 0)
    sellButton.Position = UDim2.new(0.75, 0, 0.1, 0)
    sellButton.BackgroundColor3 = Color3.new(0.2, 0.7, 0.2)
    sellButton.Text = "Продать"
    sellButton.TextColor3 = Color3.new(1, 1, 1)
    sellButton.TextScaled = true
    sellButton.Font = Enum.Font.SourceSansBold
    sellButton.Parent = resourceFrame
    
    -- Обновляем активность кнопки
    sellButton.Active = resourceAmount > 0
    if resourceAmount <= 0 then
        sellButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
    end
    
    sellButton.MouseButton1Click:Connect(function()
        self:SellResource(player, resourceName, 1)
        -- Обновляем GUI
        wait(0.1)
        self:OpenTradeGUI(player)
    end)
end

-- Создание секции покупки клеток
function TraderManager:CreateTilePurchaseSection(parent, yPos, player)
    local GameManager = require(game.ServerScriptService.GameManager)
    local playerData = GameManager.PlayerData[player.UserId]
    if not playerData then return end
    
    local nextTileCost = self:CalculateNextTileCost(playerData.UnlockedTiles)
    
    -- Рамка для покупки клеток
    local tileFrame = Instance.new("Frame")
    tileFrame.Size = UDim2.new(1, -20, 0, 100)
    tileFrame.Position = UDim2.new(0, 10, 0, yPos)
    tileFrame.BackgroundColor3 = Color3.new(0.1, 0.3, 0.5)
    tileFrame.BorderSizePixel = 2
    tileFrame.BorderColor3 = Color3.new(0.3, 0.6, 0.8)
    tileFrame.Parent = parent
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "РАСШИРЕНИЕ ШАХТЫ"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = tileFrame
    
    -- Информация о стоимости
    local costLabel = Instance.new("TextLabel")
    costLabel.Size = UDim2.new(0.6, 0, 0.3, 0)
    costLabel.Position = UDim2.new(0, 5, 0.4, 0)
    costLabel.BackgroundTransparency = 1
    costLabel.Text = "Следующая клетка: " .. nextTileCost .. "₽"
    costLabel.TextColor3 = Color3.new(1, 1, 0.5)
    costLabel.TextScaled = true
    costLabel.Font = Enum.Font.SourceSans
    costLabel.Parent = tileFrame
    
    -- Деньги игрока
    local moneyLabel = Instance.new("TextLabel")
    moneyLabel.Size = UDim2.new(0.6, 0, 0.3, 0)
    moneyLabel.Position = UDim2.new(0, 5, 0.7, 0)
    moneyLabel.BackgroundTransparency = 1
    moneyLabel.Text = "Ваши деньги: " .. playerData.Money .. "₽"
    moneyLabel.TextColor3 = Color3.new(0.8, 1, 0.8)
    moneyLabel.TextScaled = true
    moneyLabel.Font = Enum.Font.SourceSans
    moneyLabel.Parent = tileFrame
    
    -- Кнопка покупки
    local buyButton = Instance.new("TextButton")
    buyButton.Size = UDim2.new(0.35, -5, 0.6, 0)
    buyButton.Position = UDim2.new(0.65, 0, 0.2, 0)
    buyButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.8)
    buyButton.Text = "КУПИТЬ"
    buyButton.TextColor3 = Color3.new(1, 1, 1)
    buyButton.TextScaled = true
    buyButton.Font = Enum.Font.SourceSansBold
    buyButton.Parent = tileFrame
    
    -- Проверяем, может ли игрок купить
    local canBuy = playerData.Money >= nextTileCost
    buyButton.Active = canBuy
    if not canBuy then
        buyButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        buyButton.Text = "НЕ ХВАТАЕТ\nДЕНЕГ"
    end
    
    buyButton.MouseButton1Click:Connect(function()
        if canBuy then
            self:PurchaseNextTile(player)
            wait(0.1)
            self:OpenTradeGUI(player)
        end
    end)
end

-- Продажа ресурса
function TraderManager:SellResource(player, resourceName, amount)
    local GameManager = require(game.ServerScriptService.GameManager)
    local playerData = GameManager.PlayerData[player.UserId]
    
    if not playerData then return false end
    
    local currentAmount = playerData.Inventory[resourceName] or 0
    if currentAmount < amount then return false end
    
    local price = self.ResourcePrices[resourceName] * amount
    
    -- Убираем ресурс и добавляем деньги
    playerData.Inventory[resourceName] = currentAmount - amount
    playerData.Money = playerData.Money + price
    
    -- Проигрываем денежный эффект
    local EffectsManager = require(game.ServerScriptService.EffectsManager)
    EffectsManager:PlayMoneyEffect(player, price, true)
    
    print(player.Name .. " продал " .. amount .. " " .. resourceName .. " за " .. price .. "₽")
    return true
end

-- Покупка новой клетки
function TraderManager:PurchaseNextTile(player)
    local GameManager = require(game.ServerScriptService.GameManager)
    local playerData = GameManager.PlayerData[player.UserId]
    
    if not playerData then return false end
    
    local cost = self:CalculateNextTileCost(playerData.UnlockedTiles)
    if playerData.Money < cost then return false end
    
    -- Находим следующую клетку для разблокировки
    local nextTile = self:FindNextTileToUnlock(playerData.UnlockedTiles)
    if not nextTile then return false end
    
    -- Покупаем клетку
    playerData.Money = playerData.Money - cost
    playerData.UnlockedTiles = playerData.UnlockedTiles + 1
    
    -- Разблокируем клетку
    GameManager:UnlockTile(nextTile)
    
    -- Проигрываем эффекты
    local EffectsManager = require(game.ServerScriptService.EffectsManager)
    EffectsManager:PlayMoneyEffect(player, cost, false) -- Трата денег
    EffectsManager:PlayTileUnlockEffect(nextTile) -- Разблокировка клетки
    
    print(player.Name .. " купил новую клетку за " .. cost .. "₽")
    return true
end

-- Расчет стоимости следующей клетки
function TraderManager:CalculateNextTileCost(unlockedTiles)
    return math.floor(self.Config.TILE_COST_BASE * (self.Config.TILE_COST_MULTIPLIER ^ (unlockedTiles - 1)))
end

-- Поиск следующей клетки для разблокировки
function TraderManager:FindNextTileToUnlock(unlockedTiles)
    local platformFolder = game.Workspace.GameObjects.Platform
    
    -- Простая логика: разблокируем по спирали от центра
    local unlockOrder = self:GenerateUnlockOrder()
    
    if unlockedTiles < #unlockOrder then
        local nextPos = unlockOrder[unlockedTiles + 1]
        local tileName = "Tile_" .. nextPos.x .. "_" .. nextPos.z
        return platformFolder:FindFirstChild(tileName)
    end
    
    return nil
end

-- Генерация порядка разблокировки клеток (спираль)
function TraderManager:GenerateUnlockOrder()
    local order = {}
    local visited = {}
    
    -- Инициализируем посещенные клетки
    for x = 1, 10 do
        visited[x] = {}
        for z = 1, 10 do
            visited[x][z] = false
        end
    end
    
    -- Начинаем с центра (1,1)
    table.insert(order, {x = 1, z = 1})
    visited[1][1] = true
    
    -- Направления: право, вниз, лево, верх
    local directions = {
        {dx = 1, dz = 0},
        {dx = 0, dz = 1},
        {dx = -1, dz = 0},
        {dx = 0, dz = -1}
    }
    
    local x, z = 1, 1
    local dirIndex = 1
    local steps = 1
    
    while #order < 100 do
        for _ = 1, 2 do -- Каждое направление используется дважды в спирали
            for _ = 1, steps do
                local dir = directions[dirIndex]
                x = x + dir.dx
                z = z + dir.dz
                
                if x >= 1 and x <= 10 and z >= 1 and z <= 10 and not visited[x][z] then
                    table.insert(order, {x = x, z = z})
                    visited[x][z] = true
                end
            end
            dirIndex = dirIndex % 4 + 1
        end
        steps = steps + 1
    end
    
    return order
end

-- Инициализация торговца
function TraderManager:Initialize()
    self:CreateTrader()
    print("TraderManager инициализирован!")
end

return TraderManager