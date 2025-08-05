-- PlayerController.lua
-- Клиентский скрипт для управления взаимодействиями игрока

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Получаем RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local MineStoneEvent = RemoteEvents:WaitForChild("MineStone")
local BuyCellEvent = RemoteEvents:WaitForChild("BuyCell")
local SellResourceEvent = RemoteEvents:WaitForChild("SellResource")
local UpdateDataEvent = RemoteEvents:WaitForChild("UpdateData")

-- Переменные для интерфейса
local gui = nil
local inventoryFrame = nil
local coinsLabel = nil
local playerData = {
	Coins = 0,
	Inventory = {
		["Stone"] = 0,
		["Copper"] = 0,
		["Tin"] = 0,
		["Iron"] = 0
	},
	UnlockedCells = 1
}

-- Создание интерфейса
local function CreateGUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MiningGameGUI"
	screenGui.Parent = player.PlayerGui
	
	-- Основной фрейм
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 300, 0, 400)
	mainFrame.Position = UDim2.new(1, -320, 0, 20)
	mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	
	-- Заголовок
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 40)
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	titleLabel.Text = "Mining Game"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = mainFrame
	
	-- Информация о монетах
	coinsLabel = Instance.new("TextLabel")
	coinsLabel.Name = "CoinsLabel"
	coinsLabel.Size = UDim2.new(1, 0, 0, 30)
	coinsLabel.Position = UDim2.new(0, 0, 0, 40)
	coinsLabel.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	coinsLabel.Text = "Coins: 0"
	coinsLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	coinsLabel.TextScaled = true
	coinsLabel.Font = Enum.Font.Gotham
	coinsLabel.Parent = mainFrame
	
	-- Инвентарь
	inventoryFrame = Instance.new("Frame")
	inventoryFrame.Name = "InventoryFrame"
	inventoryFrame.Size = UDim2.new(1, 0, 0, 200)
	inventoryFrame.Position = UDim2.new(0, 0, 0, 80)
	inventoryFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	inventoryFrame.BorderSizePixel = 0
	inventoryFrame.Parent = mainFrame
	
	-- Заголовок инвентаря
	local inventoryTitle = Instance.new("TextLabel")
	inventoryTitle.Name = "InventoryTitle"
	inventoryTitle.Size = UDim2.new(1, 0, 0, 25)
	inventoryTitle.Position = UDim2.new(0, 0, 0, 0)
	inventoryTitle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	inventoryTitle.Text = "Inventory"
	inventoryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	inventoryTitle.TextScaled = true
	inventoryTitle.Font = Enum.Font.Gotham
	inventoryTitle.Parent = inventoryFrame
	
	-- Кнопки действий
	local actionsFrame = Instance.new("Frame")
	actionsFrame.Name = "ActionsFrame"
	actionsFrame.Size = UDim2.new(1, 0, 0, 100)
	actionsFrame.Position = UDim2.new(0, 0, 0, 290)
	actionsFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	actionsFrame.BorderSizePixel = 0
	actionsFrame.Parent = mainFrame
	
	-- Кнопка покупки клетки
	local buyCellButton = Instance.new("TextButton")
	buyCellButton.Name = "BuyCellButton"
	buyCellButton.Size = UDim2.new(0.45, 0, 0, 40)
	buyCellButton.Position = UDim2.new(0, 5, 0, 5)
	buyCellButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
	buyCellButton.Text = "Buy Cell"
	buyCellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyCellButton.TextScaled = true
	buyCellButton.Font = Enum.Font.Gotham
	buyCellButton.Parent = actionsFrame
	
	-- Кнопка продажи ресурсов
	local sellButton = Instance.new("TextButton")
	sellButton.Name = "SellButton"
	sellButton.Size = UDim2.new(0.45, 0, 0, 40)
	sellButton.Position = UDim2.new(0.55, 0, 0, 5)
	sellButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	sellButton.Text = "Sell All"
	sellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	sellButton.TextScaled = true
	sellButton.Font = Enum.Font.Gotham
	sellButton.Parent = actionsFrame
	
	gui = screenGui
end

-- Обновление интерфейса
local function UpdateGUI()
	if not gui then return end
	
	-- Обновляем отображение монет
	if coinsLabel then
		coinsLabel.Text = "Coins: " .. playerData.Coins
	end
	
	-- Обновляем инвентарь
	if inventoryFrame then
		-- Очищаем старые элементы
		for _, child in pairs(inventoryFrame:GetChildren()) do
			if child.Name ~= "InventoryTitle" then
				child:Destroy()
			end
		end
		
		-- Добавляем новые элементы инвентаря
		local resources = {"Stone", "Copper", "Tin", "Iron"}
		for i, resource in ipairs(resources) do
			local resourceLabel = Instance.new("TextLabel")
			resourceLabel.Name = resource .. "Label"
			resourceLabel.Size = UDim2.new(1, 0, 0, 30)
			resourceLabel.Position = UDim2.new(0, 0, 0, 25 + (i-1) * 35)
			resourceLabel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			resourceLabel.Text = resource .. ": " .. (playerData.Inventory[resource] or 0)
			resourceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			resourceLabel.TextScaled = true
			resourceLabel.Font = Enum.Font.Gotham
			resourceLabel.Parent = inventoryFrame
		end
	end
end

-- Обработка клика по камню
local function HandleStoneClick(stone)
	if not stone then return end
	
	-- Проверяем, что это камень
	local stoneName = stone.Name
	if string.find(stoneName, "Stone") then
		-- Анимация добычи
		local tween = TweenService:Create(stone, TweenInfo.new(0.5), {
			Size = Vector3.new(0, 0, 0),
			Transparency = 1
		})
		tween:Play()
		
		tween.Completed:Connect(function()
			-- Отправляем событие на сервер
			MineStoneEvent:FireServer(stone)
		end)
	end
end

-- Обработка клика по торговцу
local function HandleTraderClick(trader)
	if not trader then return end
	
	-- Отправляем событие продажи всех ресурсов
	SellResourceEvent:FireServer("ALL")
end

-- Обработка клика по кнопке покупки клетки
local function HandleBuyCellClick()
	BuyCellEvent:FireServer()
end

-- Обработка клика по кнопке продажи
local function HandleSellClick()
	SellResourceEvent:FireServer("ALL")
end

-- Основная функция обработки кликов
local function HandleClick()
	local target = mouse.Target
	if not target then return end
	
	-- Проверяем тип объекта
	if string.find(target.Name, "Stone") then
		HandleStoneClick(target)
	elseif string.find(target.Name, "Trader") then
		HandleTraderClick(target)
	end
end

-- Обработка нажатий клавиш
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		HandleClick()
	end
end)

-- Обработка кнопок интерфейса
local function SetupButtonHandlers()
	if not gui then return end
	
	local buyCellButton = gui.MainFrame.ActionsFrame.BuyCellButton
	local sellButton = gui.MainFrame.ActionsFrame.SellButton
	
	if buyCellButton then
		buyCellButton.MouseButton1Click:Connect(HandleBuyCellClick)
	end
	
	if sellButton then
		sellButton.MouseButton1Click:Connect(HandleSellClick)
	end
end

-- Обработка обновления данных с сервера
UpdateDataEvent.OnClientEvent:Connect(function(data)
	playerData = data
	UpdateGUI()
end)

-- Инициализация
local function Initialize()
	CreateGUI()
	SetupButtonHandlers()
	UpdateGUI()
end

-- Запуск инициализации
Initialize()

print("PlayerController initialized for " .. player.Name)