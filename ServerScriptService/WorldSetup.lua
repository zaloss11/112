-- WorldSetup.lua - Настройка игрового мира
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local WorldSetup = {}

-- Настройка освещения
function WorldSetup:SetupLighting()
    -- Основные настройки освещения
    Lighting.Ambient = Color3.new(0.3, 0.3, 0.4) -- Слегка синеватый окружающий свет
    Lighting.Brightness = 2
    Lighting.ClockTime = 12 -- Полдень
    Lighting.FogColor = Color3.new(0.7, 0.8, 0.9)
    Lighting.FogEnd = 1000
    Lighting.FogStart = 100
    
    -- Создаем солнце
    local sun = Instance.new("SunRaysEffect")
    sun.Intensity = 0.25
    sun.Spread = 0.2
    sun.Parent = Lighting
    
    -- Настройка неба
    local sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.jpg"
    sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.jpg"
    sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.jpg"
    sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.jpg"
    sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.jpg"
    sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.jpg"
    sky.Parent = Lighting
    
    print("Освещение настроено!")
end

-- Создание базового ландшафта
function WorldSetup:CreateBaseTerrain()
    -- Создаем базовую поверхность под шахтой
    local baseGround = Instance.new("Part")
    baseGround.Name = "BaseGround"
    baseGround.Size = Vector3.new(200, 5, 200)
    baseGround.Position = Vector3.new(40, -5, 40)
    baseGround.Color = Color3.new(0.4, 0.3, 0.2) -- Коричневый цвет земли
    baseGround.Material = Enum.Material.Ground
    baseGround.Anchored = true
    baseGround.CanCollide = true
    baseGround.Parent = Workspace
    
    -- Создаем декоративные холмы вокруг
    for i = 1, 5 do
        local hill = Instance.new("Part")
        hill.Name = "Hill_" .. i
        hill.Size = Vector3.new(
            math.random(30, 60),
            math.random(10, 25),
            math.random(30, 60)
        )
        hill.Position = Vector3.new(
            math.random(-100, 200),
            hill.Size.Y / 2 - 3,
            math.random(-100, 200)
        )
        hill.Color = Color3.new(0.3, 0.5, 0.2) -- Зеленый цвет травы
        hill.Material = Enum.Material.Grass
        hill.Shape = Enum.PartType.Ball
        hill.Anchored = true
        hill.CanCollide = true
        hill.Parent = Workspace
    end
    
    -- Создаем несколько деревьев для атмосферы
    self:CreateTrees()
    
    print("Базовый ландшафт создан!")
end

-- Создание декоративных деревьев
function WorldSetup:CreateTrees()
    for i = 1, 8 do
        local treeModel = Instance.new("Model")
        treeModel.Name = "Tree_" .. i
        treeModel.Parent = Workspace
        
        -- Ствол дерева
        local trunk = Instance.new("Part")
        trunk.Name = "Trunk"
        trunk.Size = Vector3.new(2, 12, 2)
        trunk.Position = Vector3.new(
            math.random(-80, 150),
            6,
            math.random(-80, 150)
        )
        trunk.Color = Color3.new(0.4, 0.2, 0.1) -- Коричневый
        trunk.Material = Enum.Material.Wood
        trunk.Shape = Enum.PartType.Cylinder
        trunk.Anchored = true
        trunk.CanCollide = true
        trunk.Parent = treeModel
        
        -- Поворачиваем ствол вертикально
        trunk.CFrame = trunk.CFrame * CFrame.Angles(math.rad(90), 0, 0)
        
        -- Крона дерева
        local crown = Instance.new("Part")
        crown.Name = "Crown"
        crown.Size = Vector3.new(8, 8, 8)
        crown.Position = trunk.Position + Vector3.new(0, 8, 0)
        crown.Color = Color3.new(0.2, 0.6, 0.2) -- Зеленый
        crown.Material = Enum.Material.Grass
        crown.Shape = Enum.PartType.Ball
        crown.Anchored = true
        crown.CanCollide = false
        crown.Parent = treeModel
    end
    
    print("Деревья созданы!")
end

-- Создание спавна для игроков
function WorldSetup:CreateSpawnLocation()
    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "MainSpawn"
    spawnLocation.Size = Vector3.new(6, 1, 6)
    spawnLocation.Position = Vector3.new(-10, 2, -10)
    spawnLocation.BrickColor = BrickColor.new("Bright green")
    spawnLocation.Material = Enum.Material.Neon
    spawnLocation.Anchored = true
    spawnLocation.CanCollide = true
    spawnLocation.Parent = Workspace
    
    -- Добавляем табличку спавна
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = spawnLocation
    
    local spawnLabel = Instance.new("TextLabel")
    spawnLabel.Size = UDim2.new(1, 0, 1, 0)
    spawnLabel.BackgroundTransparency = 1
    spawnLabel.Text = "🏁 СТАРТ"
    spawnLabel.TextColor3 = Color3.new(1, 1, 1)
    spawnLabel.TextScaled = true
    spawnLabel.Font = Enum.Font.SourceSansBold
    spawnLabel.Parent = billboard
    
    print("Спавн создан!")
end

-- Создание указателей направления
function WorldSetup:CreateDirectionSigns()
    -- Указатель к шахте
    local mineSign = self:CreateSign(
        Vector3.new(-5, 5, -15),
        "⛏️ ШАХТА ⛏️\n👆 Добывайте камни",
        Color3.new(0.6, 0.4, 0.2)
    )
    
    -- Указатель к торговцу
    local traderSign = self:CreateSign(
        Vector3.new(40, 5, -10),
        "💰 ТОРГОВЕЦ 💰\n👆 Продавайте ресурсы",
        Color3.new(0.2, 0.6, 0.2)
    )
    
    print("Указатели созданы!")
end

-- Создание указательного знака
function WorldSetup:CreateSign(position, text, color)
    local signModel = Instance.new("Model")
    signModel.Name = "DirectionSign"
    signModel.Parent = Workspace
    
    -- Столб знака
    local post = Instance.new("Part")
    post.Name = "Post"
    post.Size = Vector3.new(0.5, 6, 0.5)
    post.Position = position + Vector3.new(0, -1, 0)
    post.Color = Color3.new(0.4, 0.2, 0.1)
    post.Material = Enum.Material.Wood
    post.Anchored = true
    post.CanCollide = true
    post.Parent = signModel
    
    -- Табличка
    local sign = Instance.new("Part")
    sign.Name = "Sign"
    sign.Size = Vector3.new(6, 3, 0.2)
    sign.Position = position
    sign.Color = color
    sign.Material = Enum.Material.SmoothPlastic
    sign.Anchored = true
    sign.CanCollide = false
    sign.Parent = signModel
    
    -- Текст на табличке
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Front
    surfaceGui.Parent = sign
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = surfaceGui
    
    return signModel
end

-- Главная функция инициализации мира
function WorldSetup:Initialize()
    print("Настройка мира...")
    
    self:SetupLighting()
    self:CreateBaseTerrain()
    self:CreateSpawnLocation()
    self:CreateDirectionSigns()
    
    print("Мир настроен!")
end

return WorldSetup