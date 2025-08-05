-- CameraController.lua
-- Клиентский скрипт для управления камерой

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Настройки камеры
local cameraSettings = {
	Distance = 20,
	Height = 15,
	Angle = math.rad(-30),
	RotationSpeed = 2,
	ZoomSpeed = 5,
	MinDistance = 10,
	MaxDistance = 50
}

-- Переменные состояния
local cameraRotation = 0
local targetRotation = 0
local isRotating = false

-- Функция обновления позиции камеры
local function UpdateCamera()
	local targetPosition = Vector3.new(0, 0, 0) -- Центр платформы
	
	local cameraPosition = targetPosition + Vector3.new(
		math.sin(cameraRotation) * cameraSettings.Distance,
		cameraSettings.Height,
		math.cos(cameraRotation) * cameraSettings.Distance
	)
	
	camera.CFrame = CFrame.lookAt(cameraPosition, targetPosition) * CFrame.Angles(cameraSettings.Angle, 0, 0)
end

-- Обработка вращения камеры
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isRotating = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isRotating = false
	end
end)

-- Обработка движения мыши
UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseMovement and isRotating then
		targetRotation = targetRotation - input.Delta.X * cameraSettings.RotationSpeed * 0.01
	end
end)

-- Обработка прокрутки колесика мыши
UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		local zoomDelta = input.Position.Z * cameraSettings.ZoomSpeed
		cameraSettings.Distance = math.clamp(
			cameraSettings.Distance - zoomDelta,
			cameraSettings.MinDistance,
			cameraSettings.MaxDistance
		)
	end
end)

-- Плавное вращение камеры
RunService.RenderStepped:Connect(function()
	if isRotating then
		cameraRotation = cameraRotation + (targetRotation - cameraRotation) * 0.1
	end
	
	UpdateCamera()
end)

-- Инициализация камеры
local function InitializeCamera()
	-- Ждем загрузки персонажа
	player.CharacterAdded:Connect(function(character)
		wait(1) -- Небольшая задержка для загрузки
		UpdateCamera()
	end)
	
	-- Начальная настройка камеры
	UpdateCamera()
end

InitializeCamera()

print("CameraController initialized for " .. player.Name)