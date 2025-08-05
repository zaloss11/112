-- RemoteEventsSetup.lua
-- Серверный скрипт для создания RemoteEvents

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Создаем папку для RemoteEvents
local RemoteEvents = Instance.new("Folder")
RemoteEvents.Name = "RemoteEvents"
RemoteEvents.Parent = ReplicatedStorage

-- Создаем RemoteEvents для связи клиент-сервер
local MineStoneEvent = Instance.new("RemoteEvent")
MineStoneEvent.Name = "MineStone"
MineStoneEvent.Parent = RemoteEvents

local BuyCellEvent = Instance.new("RemoteEvent")
BuyCellEvent.Name = "BuyCell"
BuyCellEvent.Parent = RemoteEvents

local SellResourceEvent = Instance.new("RemoteEvent")
SellResourceEvent.Name = "SellResource"
SellResourceEvent.Parent = RemoteEvents

local UpdateDataEvent = Instance.new("RemoteEvent")
UpdateDataEvent.Name = "UpdateData"
UpdateDataEvent.Parent = RemoteEvents

print("RemoteEvents setup completed!")