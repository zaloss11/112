-- PlayerSpawner.lua
-- Серверный скрипт для размещения игрока в начале игры

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Обработка подключения игрока
Players.PlayerAdded:Connect(function(player)
	-- Ждем загрузки персонажа
	player.CharacterAdded:Connect(function(character)
		-- Размещаем игрока на платформе
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		humanoidRootPart.CFrame = CFrame.new(0, 5, 0) -- Над первой клеткой
		
		-- Настраиваем камеру
		local camera = workspace.CurrentCamera
		if camera then
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = CFrame.new(0, 15, 20) * CFrame.Angles(math.rad(-30), 0, 0)
		end
		
		-- Создаем подсказку для игрока
		local hint = Instance.new("Part")
		hint.Name = "Hint_" .. player.Name
		hint.Size = Vector3.new(8, 1, 8)
		hint.Position = Vector3.new(0, 0.5, 0)
		hint.Anchored = true
		hint.Material = Enum.Material.Neon
		hint.Color = Color3.fromRGB(0, 255, 0)
		hint.Transparency = 0.7
		hint.Parent = workspace
		
		-- Удаляем подсказку через 10 секунд
		spawn(function()
			wait(10)
			hint:Destroy()
		end)
	end)
end)

print("PlayerSpawner initialized!")