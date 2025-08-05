-- RemoteHandler.lua
-- Серверный скрипт для обработки RemoteEvents

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Получаем RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local MineStoneEvent = RemoteEvents:WaitForChild("MineStone")
local BuyCellEvent = RemoteEvents:WaitForChild("BuyCell")
local SellResourceEvent = RemoteEvents:WaitForChild("SellResource")

-- Создаем RemoteEvents для обновления данных клиентов
local UpdateDataEvent = Instance.new("RemoteEvent")
UpdateDataEvent.Name = "UpdateData"
UpdateDataEvent.Parent = RemoteEvents

-- Глобальные переменные (должны быть доступны из GameManager)
local PlayerData = {}
local gameCells = {}

-- Функция для получения данных игрока
local function GetPlayerData(player)
	return PlayerData[player.UserId]
end

-- Функция для обновления данных игрока
local function UpdatePlayerData(player, data)
	if PlayerData[player.UserId] then
		for key, value in pairs(data) do
			PlayerData[player.UserId][key] = value
		end
		
		-- Отправляем обновленные данные клиенту
		UpdateDataEvent:FireClient(player, PlayerData[player.UserId])
	end
end

-- Обработка добычи камня
MineStoneEvent.OnServerEvent:Connect(function(player, stone)
	if not stone or not stone.Parent then return end
	
	-- Находим клетку, на которой находится камень
	local stonePosition = stone.Position
	local cellFound = false
	
	for x = 1, #gameCells do
		for z = 1, #gameCells[x] do
			local cell = gameCells[x][z]
			if cell.Part and (cell.Part.Position - stonePosition).Magnitude < 5 then
				if cell.HasStone and cell.StonePart == stone then
					-- Проверяем, что клетка разблокирована
					if not cell.IsUnlocked then
						-- Уведомляем игрока
						-- TODO: Добавить уведомление
						return
					end
					
					-- Добываем камень
					local playerData = GetPlayerData(player)
					if not playerData then return end
					
					local stoneType = cell.StoneType
					local drop = {
						["Stone"] = {
							Drop = {["Stone"] = 2},
							Rarity = 0.6
						},
						["Copper"] = {
							Drop = {["Stone"] = 1, ["Copper"] = 1},
							Rarity = 0.25
						},
						["Tin"] = {
							Drop = {["Stone"] = 1, ["Tin"] = 2},
							Rarity = 0.1
						},
						["Iron"] = {
							Drop = {["Stone"] = 1, ["Iron"] = 1},
							Rarity = 0.05
						}
					}
					
					local stoneData = drop[stoneType]
					if stoneData then
						-- Добавляем ресурсы игроку
						for resource, amount in pairs(stoneData.Drop) do
							playerData.Inventory[resource] = playerData.Inventory[resource] + amount
						end
						
						-- Удаляем камень
						cell.HasStone = false
						cell.StoneType = nil
						cell.StonePart = nil
						
						-- Обновляем данные
						UpdatePlayerData(player, playerData)
						
						-- Уведомляем игрока
						-- TODO: Добавить уведомление о полученных ресурсах
					end
					
					cellFound = true
					break
				end
			end
		end
		if cellFound then break end
	end
end)

-- Обработка покупки клетки
BuyCellEvent.OnServerEvent:Connect(function(player)
	local playerData = GetPlayerData(player)
	if not playerData then return end
	
	local cost = playerData.UnlockedCells * 10 -- увеличивающаяся стоимость
	
	if playerData.Coins >= cost then
		playerData.Coins = playerData.Coins - cost
		playerData.UnlockedCells = playerData.UnlockedCells + 1
		
		-- Разблокируем следующую клетку
		local unlockedCount = playerData.UnlockedCells
		local cellIndex = 1
		
		for x = 1, #gameCells do
			for z = 1, #gameCells[x] do
				if cellIndex <= unlockedCount then
					gameCells[x][z].IsUnlocked = true
					-- Визуально показываем разблокированную клетку
					gameCells[x][z].Part.Material = Enum.Material.Sand
				else
					gameCells[x][z].IsUnlocked = false
					-- Визуально показываем заблокированную клетку
					gameCells[x][z].Part.Material = Enum.Material.Slate
					gameCells[x][z].Part.Color = Color3.fromRGB(100, 100, 100)
				end
				cellIndex = cellIndex + 1
			end
		end
		
		-- Обновляем данные
		UpdatePlayerData(player, playerData)
		
		-- Уведомляем игрока
		-- TODO: Добавить уведомление о покупке клетки
	else
		-- Уведомляем игрока о недостатке монет
		-- TODO: Добавить уведомление
	end
end)

-- Обработка продажи ресурсов
SellResourceEvent.OnServerEvent:Connect(function(player, resourceType, amount)
	local playerData = GetPlayerData(player)
	if not playerData then return end
	
	local prices = {
		["Stone"] = 1,
		["Copper"] = 3,
		["Tin"] = 5,
		["Iron"] = 10
	}
	
	if resourceType == "ALL" then
		-- Продаем все ресурсы
		local totalEarnings = 0
		for resource, count in pairs(playerData.Inventory) do
			if count > 0 and prices[resource] then
				local earnings = count * prices[resource]
				totalEarnings = totalEarnings + earnings
				playerData.Inventory[resource] = 0
			end
		end
		
		if totalEarnings > 0 then
			playerData.Coins = playerData.Coins + totalEarnings
			UpdatePlayerData(player, playerData)
			
			-- Уведомляем игрока
			-- TODO: Добавить уведомление о продаже
		end
	else
		-- Продаем конкретный ресурс
		if playerData.Inventory[resourceType] and playerData.Inventory[resourceType] >= amount then
			local price = prices[resourceType] * amount
			playerData.Inventory[resourceType] = playerData.Inventory[resourceType] - amount
			playerData.Coins = playerData.Coins + price
			
			UpdatePlayerData(player, playerData)
			
			-- Уведомляем игрока
			-- TODO: Добавить уведомление о продаже
		end
	end
end)

-- Функция для инициализации данных (вызывается из GameManager)
local function InitializeRemoteHandler(playerData, cells)
	PlayerData = playerData
	gameCells = cells
end

-- Экспортируем функцию для использования в GameManager
return {
	InitializeRemoteHandler = InitializeRemoteHandler,
	UpdatePlayerData = UpdatePlayerData
}