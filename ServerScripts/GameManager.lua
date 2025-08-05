-- GameManager.lua
-- Основной серверный скрипт для управления игрой

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Создаем папки для хранения данных
local GameData = Instance.new("Folder")
GameData.Name = "GameData"
GameData.Parent = ReplicatedStorage

-- Конфигурация игры
local GameConfig = {
	GRID_SIZE = 10,
	CELL_SIZE = 4,
	SPAWN_INTERVAL = 30, -- секунды между спавном камней
	INITIAL_CELLS = 1
}

-- Типы камней и их дропы
local StoneTypes = {
	["Stone"] = {
		Model = "Stone",
		Drop = {
			["Stone"] = 2
		},
		Rarity = 0.6
	},
	["Copper"] = {
		Model = "Copper",
		Drop = {
			["Stone"] = 1,
			["Copper"] = 1
		},
		Rarity = 0.25
	},
	["Tin"] = {
		Model = "Tin",
		Drop = {
			["Stone"] = 1,
			["Tin"] = 2
		},
		Rarity = 0.1
	},
	["Iron"] = {
		Model = "Iron",
		Drop = {
			["Stone"] = 1,
			["Iron"] = 1
		},
		Rarity = 0.05
	}
}

-- Данные игроков
local PlayerData = {}

-- Создание платформы
local function CreatePlatform()
	local platform = Instance.new("Part")
	platform.Name = "MiningPlatform"
	platform.Size = Vector3.new(GameConfig.GRID_SIZE * GameConfig.CELL_SIZE, 1, GameConfig.GRID_SIZE * GameConfig.CELL_SIZE)
	platform.Position = Vector3.new(0, 0, 0)
	platform.Anchored = true
	platform.Material = Enum.Material.Grass
	platform.Parent = workspace
	
	-- Создаем сетку клеток
	local cells = {}
	for x = 1, GameConfig.GRID_SIZE do
		cells[x] = {}
		for z = 1, GameConfig.GRID_SIZE do
			local cell = Instance.new("Part")
			cell.Name = "Cell_" .. x .. "_" .. z
			cell.Size = Vector3.new(GameConfig.CELL_SIZE - 0.1, 0.1, GameConfig.CELL_SIZE - 0.1)
			cell.Position = Vector3.new(
				(x - GameConfig.GRID_SIZE/2 - 0.5) * GameConfig.CELL_SIZE,
				0.5,
				(z - GameConfig.GRID_SIZE/2 - 0.5) * GameConfig.CELL_SIZE
			)
			cell.Anchored = true
			cell.Material = Enum.Material.Sand
			cell.Parent = platform
			
			cells[x][z] = {
				Part = cell,
				HasStone = false,
				StoneType = nil,
				IsUnlocked = (x == 1 and z == 1) -- только первая клетка разблокирована
			}
		end
	end
	
	return cells
end

-- Создание камня
local function CreateStone(stoneType, position)
	local stone = Instance.new("Part")
	stone.Name = stoneType .. "Stone"
	stone.Size = Vector3.new(2, 2, 2)
	stone.Position = position + Vector3.new(0, 1, 0)
	stone.Anchored = true
	stone.Material = Enum.Material.Rock
	
	-- Настройка цвета в зависимости от типа
	if stoneType == "Copper" then
		stone.Color = Color3.fromRGB(184, 115, 51)
	elseif stoneType == "Tin" then
		stone.Color = Color3.fromRGB(192, 192, 192)
	elseif stoneType == "Iron" then
		stone.Color = Color3.fromRGB(139, 69, 19)
	else
		stone.Color = Color3.fromRGB(128, 128, 128)
	end
	
	return stone
end

-- Спавн камней
local function SpawnStones(cells)
	for x = 1, GameConfig.GRID_SIZE do
		for z = 1, GameConfig.GRID_SIZE do
			local cell = cells[x][z]
			if cell.IsUnlocked and not cell.HasStone then
				-- Шанс спавна камня
				if math.random() < 0.3 then
					-- Выбор типа камня на основе редкости
					local rand = math.random()
					local selectedType = "Stone"
					
					for stoneType, data in pairs(StoneTypes) do
						if rand <= data.Rarity then
							selectedType = stoneType
							break
						end
						rand = rand - data.Rarity
					end
					
					local stone = CreateStone(selectedType, cell.Part.Position)
					stone.Parent = workspace
					
					cell.HasStone = true
					cell.StoneType = selectedType
					cell.StonePart = stone
				end
			end
		end
	end
end

-- Инициализация данных игрока
local function InitializePlayerData(player)
	PlayerData[player.UserId] = {
		Coins = 0,
		Inventory = {
			["Stone"] = 0,
			["Copper"] = 0,
			["Tin"] = 0,
			["Iron"] = 0
		},
		UnlockedCells = 1
	}
end

-- Добыча камня
local function MineStone(player, cell)
	if not cell.HasStone then return end
	
	local stoneType = cell.StoneType
	local drop = StoneTypes[stoneType].Drop
	
	-- Добавляем ресурсы игроку
	for resource, amount in pairs(drop) do
		PlayerData[player.UserId].Inventory[resource] = PlayerData[player.UserId].Inventory[resource] + amount
	end
	
	-- Удаляем камень
	if cell.StonePart then
		cell.StonePart:Destroy()
	end
	
	cell.HasStone = false
	cell.StoneType = nil
	cell.StonePart = nil
	
	-- Обновляем интерфейс
	-- TODO: Добавить обновление GUI
end

-- Покупка клетки
local function BuyCell(player)
	local playerData = PlayerData[player.UserId]
	local cost = playerData.UnlockedCells * 10 -- увеличивающаяся стоимость
	
	if playerData.Coins >= cost then
		playerData.Coins = playerData.Coins - cost
		playerData.UnlockedCells = playerData.UnlockedCells + 1
		
		-- Разблокируем следующую клетку
		-- TODO: Логика разблокировки клеток
		
		return true
	end
	
	return false
end

-- Продажа ресурсов торговцу
local function SellResources(player, resourceType, amount)
	local playerData = PlayerData[player.UserId]
	
	if playerData.Inventory[resourceType] >= amount then
		local prices = {
			["Stone"] = 1,
			["Copper"] = 3,
			["Tin"] = 5,
			["Iron"] = 10
		}
		
		local price = prices[resourceType] * amount
		playerData.Inventory[resourceType] = playerData.Inventory[resourceType] - amount
		playerData.Coins = playerData.Coins + price
		
		return true
	end
	
	return false
end

-- Основная инициализация
local function InitializeGame()
	local cells = CreatePlatform()
	
	-- Спавн начальных камней
	SpawnStones(cells)
	
	-- Периодический спавн камней
	spawn(function()
		while true do
			wait(GameConfig.SPAWN_INTERVAL)
			SpawnStones(cells)
		end
	end)
	
	return cells
end

-- Обработка подключения игрока
Players.PlayerAdded:Connect(function(player)
	InitializePlayerData(player)
	
	-- Создаем торговца для игрока
	local trader = Instance.new("Part")
	trader.Name = "Trader_" .. player.Name
	trader.Size = Vector3.new(3, 6, 3)
	trader.Position = Vector3.new(20, 3, 0)
	trader.Anchored = true
	trader.Material = Enum.Material.Brick
	trader.Color = Color3.fromRGB(255, 215, 0)
	trader.Parent = workspace
	
	-- Отправляем начальные данные игроку
	local UpdateDataEvent = ReplicatedStorage.RemoteEvents.UpdateData
	UpdateDataEvent:FireClient(player, PlayerData[player.UserId])
end)

-- Обработка отключения игрока
Players.PlayerRemoving:Connect(function(player)
	PlayerData[player.UserId] = nil
end)

-- Инициализация игры
local gameCells = InitializeGame()

-- Инициализируем RemoteHandler
local RemoteHandler = require(script.Parent.RemoteHandler)
RemoteHandler.InitializeRemoteHandler(PlayerData, gameCells)

print("Mining Game initialized successfully!")