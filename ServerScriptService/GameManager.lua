-- GameManager.lua - Основной менеджер игры
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local GameManager = {}

-- Настройки игры
GameManager.Config = {
    GRID_SIZE = 10,
    TILE_SIZE = 8,
    TILE_HEIGHT = 1,
    SPAWN_INTERVAL = 5, -- секунд между спавном камней
    INITIAL_TILES = 1,
}

-- Типы камней и их свойства
GameManager.StoneTypes = {
    Stone = {
        name = "Камень",
        color = Color3.new(0.5, 0.5, 0.5),
        rarity = 0.6,
        drops = {
            {item = "Stone", amount = 2}
        }
    },
    Copper = {
        name = "Медь",
        color = Color3.new(0.8, 0.4, 0.2),
        rarity = 0.25,
        drops = {
            {item = "Stone", amount = 1},
            {item = "Copper", amount = 1}
        }
    },
    Tin = {
        name = "Олово",
        color = Color3.new(0.7, 0.7, 0.8),
        rarity = 0.15,
        drops = {
            {item = "Stone", amount = 1},
            {item = "Tin", amount = 2}
        }
    }
}

-- Инициализация игры
function GameManager:Initialize()
    print("Инициализация GameManager...")
    
    -- Настраиваем мир
    local WorldSetup = require(script.Parent.WorldSetup)
    WorldSetup:Initialize()
    
    -- Создаем папки для организации
    self:CreateFolders()
    
    -- Создаем платформу
    self:CreatePlatform()
    
    -- Инициализируем данные игроков
    self.PlayerData = {}
    
    -- Инициализируем торговца
    local TraderManager = require(script.Parent.TraderManager)
    TraderManager:Initialize()
    
    -- Инициализируем систему эффектов
    local EffectsManager = require(script.Parent.EffectsManager)
    EffectsManager:Initialize()
    
    -- Запускаем основной игровой цикл
    self:StartGameLoop()
    
    print("GameManager инициализирован!")
end

-- Создание папок для организации объектов
function GameManager:CreateFolders()
    local workspace = game.Workspace
    
    if not workspace:FindFirstChild("GameObjects") then
        local gameObjects = Instance.new("Folder")
        gameObjects.Name = "GameObjects"
        gameObjects.Parent = workspace
        
        local platform = Instance.new("Folder")
        platform.Name = "Platform"
        platform.Parent = gameObjects
        
        local stones = Instance.new("Folder")
        stones.Name = "Stones"
        stones.Parent = gameObjects
        
        local npcs = Instance.new("Folder")
        npcs.Name = "NPCs"
        npcs.Parent = gameObjects
    end
end

-- Создание игровой платформы
function GameManager:CreatePlatform()
    local gameObjects = game.Workspace.GameObjects
    local platformFolder = gameObjects.Platform
    
    -- Создаем сетку 10x10
    for x = 1, self.Config.GRID_SIZE do
        for z = 1, self.Config.GRID_SIZE do
            local tile = self:CreateTile(x, z)
            tile.Parent = platformFolder
            
            -- Изначально доступна только первая клетка
            if x == 1 and z == 1 then
                self:UnlockTile(tile)
            else
                self:LockTile(tile)
            end
        end
    end
end

-- Создание отдельной клетки
function GameManager:CreateTile(x, z)
    local tile = Instance.new("Part")
    tile.Name = "Tile_" .. x .. "_" .. z
    tile.Size = Vector3.new(self.Config.TILE_SIZE, self.Config.TILE_HEIGHT, self.Config.TILE_SIZE)
    tile.Material = Enum.Material.Concrete
    tile.Anchored = true
    tile.CanCollide = true
    
    -- Позиционирование
    local posX = (x - 1) * self.Config.TILE_SIZE
    local posZ = (z - 1) * self.Config.TILE_SIZE
    tile.Position = Vector3.new(posX, 0, posZ)
    
    -- Добавляем атрибуты
    tile:SetAttribute("GridX", x)
    tile:SetAttribute("GridZ", z)
    tile:SetAttribute("Unlocked", false)
    tile:SetAttribute("HasStone", false)
    
    return tile
end

-- Разблокировка клетки
function GameManager:UnlockTile(tile)
    tile:SetAttribute("Unlocked", true)
    tile.Color = Color3.new(0.8, 0.8, 0.8)
    tile.Material = Enum.Material.Marble
end

-- Блокировка клетки
function GameManager:LockTile(tile)
    tile:SetAttribute("Unlocked", false)
    tile.Color = Color3.new(0.3, 0.3, 0.3)
    tile.Material = Enum.Material.Concrete
    tile.CanCollide = false
end

-- Инициализация данных игрока
function GameManager:InitializePlayerData(player)
    self.PlayerData[player.UserId] = {
        Money = 0,
        Inventory = {
            Stone = 0,
            Copper = 0,
            Tin = 0
        },
        UnlockedTiles = 1
    }
    
    print("Данные игрока " .. player.Name .. " инициализированы")
end

-- Основной игровой цикл
function GameManager:StartGameLoop()
    local lastSpawnTime = 0
    
    RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        
        -- Спавн камней каждые N секунд
        if currentTime - lastSpawnTime >= self.Config.SPAWN_INTERVAL then
            self:SpawnStones()
            lastSpawnTime = currentTime
        end
    end)
end

-- Спавн камней на разблокированных клетках
function GameManager:SpawnStones()
    local platformFolder = game.Workspace.GameObjects.Platform
    local stonesFolder = game.Workspace.GameObjects.Stones
    
    for _, tile in pairs(platformFolder:GetChildren()) do
        if tile:GetAttribute("Unlocked") and not tile:GetAttribute("HasStone") then
            -- Шанс появления камня (50%)
            if math.random() < 0.5 then
                local stone = self:CreateStone(tile)
                stone.Parent = stonesFolder
                tile:SetAttribute("HasStone", true)
            end
        end
    end
end

-- Создание камня
function GameManager:CreateStone(tile)
    local stoneType = self:GetRandomStoneType()
    
    local stone = Instance.new("Part")
    stone.Name = "Stone_" .. stoneType
    stone.Size = Vector3.new(2, 2, 2)
    stone.Shape = Enum.PartType.Block
    stone.Color = self.StoneTypes[stoneType].color
    stone.Material = Enum.Material.Rock
    stone.CanCollide = true
    stone.Anchored = true
    
    -- Позиционирование на клетке
    stone.Position = tile.Position + Vector3.new(0, stone.Size.Y/2 + tile.Size.Y/2, 0)
    
    -- Атрибуты камня
    stone:SetAttribute("StoneType", stoneType)
    stone:SetAttribute("TileX", tile:GetAttribute("GridX"))
    stone:SetAttribute("TileZ", tile:GetAttribute("GridZ"))
    
    -- Добавляем ClickDetector для взаимодействия
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 50
    clickDetector.Parent = stone
    
    -- Обработка клика по камню
    clickDetector.MouseClick:Connect(function(player)
        self:MineStone(player, stone, tile)
    end)
    
    return stone
end

-- Получение случайного типа камня
function GameManager:GetRandomStoneType()
    local rand = math.random()
    local cumulative = 0
    
    for stoneType, data in pairs(self.StoneTypes) do
        cumulative = cumulative + data.rarity
        if rand <= cumulative then
            return stoneType
        end
    end
    
    return "Stone" -- На всякий случай
end

-- Добыча камня
function GameManager:MineStone(player, stone, tile)
    local stoneType = stone:GetAttribute("StoneType")
    local stoneData = self.StoneTypes[stoneType]
    
    if not self.PlayerData[player.UserId] then
        self:InitializePlayerData(player)
    end
    
    local playerData = self.PlayerData[player.UserId]
    
    -- Проигрываем эффект добычи
    local EffectsManager = require(script.Parent.EffectsManager)
    EffectsManager:PlayMiningEffect(stone, stoneData.drops)
    
    -- Добавляем дроп в инвентарь
    for _, drop in pairs(stoneData.drops) do
        playerData.Inventory[drop.item] = playerData.Inventory[drop.item] + drop.amount
    end
    
    -- Удаляем камень
    stone:Destroy()
    tile:SetAttribute("HasStone", false)
    
    print(player.Name .. " добыл " .. stoneData.name)
    
    -- Обновляем GUI игрока
    self:UpdatePlayerGUI(player)
end

-- Обновление GUI игрока
function GameManager:UpdatePlayerGUI(player)
    -- Эта функция будет реализована позже с клиентским скриптом
end

-- Подключение нового игрока
Players.PlayerAdded:Connect(function(player)
    GameManager:InitializePlayerData(player)
end)

-- Отключение игрока
Players.PlayerRemoving:Connect(function(player)
    if GameManager.PlayerData[player.UserId] then
        GameManager.PlayerData[player.UserId] = nil
    end
end)

-- Запуск игры
GameManager:Initialize()

return GameManager