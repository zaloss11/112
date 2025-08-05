-- EffectsManager.lua - Система визуальных эффектов
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local EffectsManager = {}

-- Эффект добычи камня
function EffectsManager:PlayMiningEffect(stone, dropData)
    -- Эффект разрушения камня
    self:CreateDestructionEffect(stone)
    
    -- Эффект дропа ресурсов
    for _, drop in pairs(dropData) do
        self:CreateResourceDropEffect(stone.Position, drop.item, drop.amount)
    end
    
    -- Звуковой эффект (если есть)
    self:PlayMiningSound(stone.Position)
end

-- Эффект разрушения камня
function EffectsManager:CreateDestructionEffect(stone)
    local stonePosition = stone.Position
    local stoneColor = stone.Color
    
    -- Создаем частицы разрушения
    for i = 1, 8 do
        local particle = Instance.new("Part")
        particle.Name = "StoneParticle"
        particle.Size = Vector3.new(0.5, 0.5, 0.5)
        particle.Color = stoneColor
        particle.Material = Enum.Material.Rock
        particle.Shape = Enum.PartType.Block
        particle.CanCollide = false
        particle.Anchored = false
        particle.Position = stonePosition + Vector3.new(
            math.random(-1, 1),
            math.random(0, 2),
            math.random(-1, 1)
        )
        particle.Parent = game.Workspace
        
        -- Применяем случайную скорость
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(
            math.random(-20, 20),
            math.random(5, 25),
            math.random(-20, 20)
        )
        bodyVelocity.Parent = particle
        
        -- Анимация исчезновения
        local fadeInfo = TweenInfo.new(
            2, -- Длительность
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        
        local fadeTween = TweenService:Create(particle, fadeInfo, {
            Transparency = 1,
            Size = Vector3.new(0.1, 0.1, 0.1)
        })
        
        fadeTween:Play()
        
        -- Удаляем частицу через 2 секунды
        Debris:AddItem(particle, 2)
    end
end

-- Эффект дропа ресурса
function EffectsManager:CreateResourceDropEffect(position, resourceType, amount)
    -- Цвета для разных ресурсов
    local resourceColors = {
        Stone = Color3.new(0.5, 0.5, 0.5),
        Copper = Color3.new(0.8, 0.4, 0.2),
        Tin = Color3.new(0.7, 0.7, 0.8)
    }
    
    local resourceColor = resourceColors[resourceType] or Color3.new(1, 1, 1)
    
    -- Создаем текстовый эффект
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = game.Workspace
    
    -- Невидимая часть для позиционирования
    local anchor = Instance.new("Part")
    anchor.Size = Vector3.new(0.1, 0.1, 0.1)
    anchor.Transparency = 1
    anchor.CanCollide = false
    anchor.Anchored = true
    anchor.Position = position
    anchor.Parent = game.Workspace
    billboard.Parent = anchor
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "+" .. amount .. " " .. resourceType
    textLabel.TextColor3 = resourceColor
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard
    
    -- Анимация всплытия текста
    local moveInfo = TweenInfo.new(
        1.5, -- Длительность
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local moveTween = TweenService:Create(billboard, moveInfo, {
        StudsOffset = Vector3.new(0, 6, 0)
    })
    
    local fadeTween = TweenService:Create(textLabel, moveInfo, {
        Transparency = 1
    })
    
    moveTween:Play()
    fadeTween:Play()
    
    -- Удаляем эффект
    Debris:AddItem(anchor, 1.5)
end

-- Звуковой эффект добычи
function EffectsManager:PlayMiningSound(position)
    -- Простой звуковой эффект (можно заменить на настоящие звуки)
    -- В Roblox можно использовать звуки из библиотеки
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxasset://sounds/impact_water.mp3" -- Стандартный звук
    sound.Volume = 0.5
    sound.Pitch = math.random(80, 120) / 100 -- Случайная высота тона
    sound.Parent = game.Workspace
    
    sound:Play()
    
    -- Удаляем звук после проигрывания
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Эффект покупки новой клетки
function EffectsManager:PlayTileUnlockEffect(tile)
    -- Эффект разблокировки клетки
    self:CreateSparkleEffect(tile.Position + Vector3.new(0, 2, 0))
    
    -- Анимация появления клетки
    local originalColor = tile.Color
    tile.Color = Color3.new(1, 1, 0) -- Желтый на мгновение
    
    local colorInfo = TweenInfo.new(
        0.5,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local colorTween = TweenService:Create(tile, colorInfo, {
        Color = originalColor
    })
    
    colorTween:Play()
end

-- Эффект искорок
function EffectsManager:CreateSparkleEffect(position)
    for i = 1, 12 do
        local sparkle = Instance.new("Part")
        sparkle.Name = "Sparkle"
        sparkle.Size = Vector3.new(0.2, 0.2, 0.2)
        sparkle.Color = Color3.new(1, 1, 0.5) -- Золотистый цвет
        sparkle.Material = Enum.Material.Neon
        sparkle.Shape = Enum.PartType.Ball
        sparkle.CanCollide = false
        sparkle.Anchored = false
        sparkle.Position = position
        sparkle.Parent = game.Workspace
        
        -- Случайное направление
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(
            math.random(-15, 15),
            math.random(5, 20),
            math.random(-15, 15)
        )
        bodyVelocity.Parent = sparkle
        
        -- Анимация исчезновения
        local fadeInfo = TweenInfo.new(
            1, -- Длительность
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        
        local fadeTween = TweenService:Create(sparkle, fadeInfo, {
            Transparency = 1,
            Size = Vector3.new(0.05, 0.05, 0.05)
        })
        
        fadeTween:Play()
        
        -- Удаляем искорку
        Debris:AddItem(sparkle, 1)
    end
end

-- Эффект денежной транзакции
function EffectsManager:PlayMoneyEffect(player, amount, isGain)
    if not player or not player.Character then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Создаем денежный эффект
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 120, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Parent = humanoidRootPart
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = (isGain and "+" or "-") .. amount .. "₽"
    textLabel.TextColor3 = isGain and Color3.new(0.2, 1, 0.2) or Color3.new(1, 0.2, 0.2)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard
    
    -- Анимация всплытия
    local moveInfo = TweenInfo.new(
        2, -- Длительность
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local moveTween = TweenService:Create(billboard, moveInfo, {
        StudsOffset = Vector3.new(0, 8, 0)
    })
    
    local fadeTween = TweenService:Create(textLabel, moveInfo, {
        Transparency = 1
    })
    
    moveTween:Play()
    fadeTween:Play()
    
    -- Удаляем эффект
    Debris:AddItem(billboard, 2)
end

-- Эффект пульсации для важных объектов
function EffectsManager:CreatePulseEffect(object, color, duration)
    duration = duration or 2
    
    local originalColor = object.Color
    
    local pulseInfo = TweenInfo.new(
        duration / 4,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut,
        -1, -- Повторять бесконечно
        true -- Обратная анимация
    )
    
    local pulseTween = TweenService:Create(object, pulseInfo, {
        Color = color
    })
    
    pulseTween:Play()
    
    -- Останавливаем через заданное время
    wait(duration)
    pulseTween:Cancel()
    object.Color = originalColor
end

-- Инициализация
function EffectsManager:Initialize()
    print("EffectsManager инициализирован!")
end

return EffectsManager