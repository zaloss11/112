-- VisualEffects.lua
-- Клиентский скрипт для визуальных эффектов

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Эффект парения для камней
local function CreateFloatingEffect(stone)
	if not stone then return end
	
	-- Создаем анимацию парения
	local originalPosition = stone.Position
	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	
	local tween = TweenService:Create(stone, tweenInfo, {
		Position = originalPosition + Vector3.new(0, 0.5, 0)
	})
	
	tween:Play()
	
	-- Добавляем свечение для редких камней
	local stoneName = stone.Name
	if string.find(stoneName, "Copper") or string.find(stoneName, "Tin") or string.find(stoneName, "Iron") then
		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = 0.5
		pointLight.Range = 3
		
		if string.find(stoneName, "Copper") then
			pointLight.Color = Color3.fromRGB(255, 140, 0)
		elseif string.find(stoneName, "Tin") then
			pointLight.Color = Color3.fromRGB(192, 192, 192)
		elseif string.find(stoneName, "Iron") then
			pointLight.Color = Color3.fromRGB(139, 69, 19)
		end
		
		pointLight.Parent = stone
	end
end

-- Эффект добычи камня
local function CreateMiningEffect(position)
	-- Создаем частицы
	local particleEmitter = Instance.new("Part")
	particleEmitter.Size = Vector3.new(0, 0, 0)
	particleEmitter.Position = position
	particleEmitter.Anchored = true
	particleEmitter.CanCollide = false
	particleEmitter.Transparency = 1
	particleEmitter.Parent = workspace
	
	local attachment = Instance.new("Attachment")
	attachment.Parent = particleEmitter
	
	local particleSystem = Instance.new("ParticleEmitter")
	particleSystem.Parent = attachment
	particleSystem.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleSystem.Lifetime = NumberRange.new(1, 2)
	particleSystem.Rate = 50
	particleSystem.Speed = NumberRange.new(5, 10)
	particleSystem.SpreadAngle = Vector2.new(0, 180)
	particleSystem.Size = NumberSequence.new(0.5, 0)
	particleSystem.Transparency = NumberSequence.new(0, 1)
	particleSystem.Color = ColorSequence.new(Color3.fromRGB(128, 128, 128))
	
	-- Удаляем эффект через 2 секунды
	spawn(function()
		wait(2)
		particleEmitter:Destroy()
	end)
end

-- Эффект получения ресурсов
local function CreateResourceEffect(resourceType, amount, position)
	-- Создаем текст с количеством ресурса
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(0, 200, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 2, 0)
	billboardGui.Adornee = Instance.new("Part")
	billboardGui.Adornee.Size = Vector3.new(0, 0, 0)
	billboardGui.Adornee.Position = position
	billboardGui.Adornee.Anchored = true
	billboardGui.Adornee.CanCollide = false
	billboardGui.Adornee.Transparency = 1
	billboardGui.Adornee.Parent = workspace
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "+" .. amount .. " " .. resourceType
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboardGui
	
	-- Анимация появления
	local tween = TweenService:Create(textLabel, TweenInfo.new(2), {
		Position = UDim2.new(0, 0, 0, -50),
		TextTransparency = 1
	})
	tween:Play()
	
	tween.Completed:Connect(function()
		billboardGui:Destroy()
	end)
end

-- Эффект покупки клетки
local function CreateCellUnlockEffect(cell)
	if not cell then return end
	
	-- Создаем эффект разблокировки
	local unlockEffect = Instance.new("Part")
	unlockEffect.Size = cell.Size
	unlockEffect.Position = cell.Position
	unlockEffect.Anchored = true
	unlockEffect.CanCollide = false
	unlockEffect.Material = Enum.Material.Neon
	unlockEffect.Color = Color3.fromRGB(0, 255, 0)
	unlockEffect.Transparency = 0.3
	unlockEffect.Parent = workspace
	
	-- Анимация появления и исчезновения
	local tween = TweenService:Create(unlockEffect, TweenInfo.new(1), {
		Transparency = 1,
		Size = unlockEffect.Size * 1.5
	})
	tween:Play()
	
	tween.Completed:Connect(function()
		unlockEffect:Destroy()
	end)
end

-- Обработка событий
local function SetupEventHandlers()
	-- Обработка появления новых камней
	workspace.ChildAdded:Connect(function(child)
		if string.find(child.Name, "Stone") then
			wait(0.1) -- Небольшая задержка для загрузки
			CreateFloatingEffect(child)
		end
	end)
end

-- Инициализация
local function Initialize()
	SetupEventHandlers()
	
	-- Применяем эффекты к существующим камням
	for _, child in pairs(workspace:GetChildren()) do
		if string.find(child.Name, "Stone") then
			CreateFloatingEffect(child)
		end
	end
end

Initialize()

print("VisualEffects initialized for " .. player.Name)