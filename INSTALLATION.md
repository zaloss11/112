# Инструкции по установке в Roblox Studio

## Шаги установки

### 1. Создание нового места в Roblox Studio
1. Откройте Roblox Studio
2. Создайте новое место (Place)
3. Удалите все существующие объекты из workspace

### 2. Создание структуры папок

#### ServerScriptService
Создайте следующие скрипты в ServerScriptService:

1. **RemoteEventsSetup** (Script)
   - Скопируйте содержимое `ServerScripts/RemoteEventsSetup.lua`

2. **GameManager** (Script)
   - Скопируйте содержимое `ServerScripts/GameManager.lua`

3. **RemoteHandler** (Script)
   - Скопируйте содержимое `ServerScripts/RemoteHandler.lua`

4. **PlayerSpawner** (Script)
   - Скопируйте содержимое `ServerScripts/PlayerSpawner.lua`

#### StarterPlayerScripts
Создайте следующие LocalScripts в StarterPlayerScripts:

1. **PlayerController** (LocalScript)
   - Скопируйте содержимое `LocalScripts/PlayerController.lua`

2. **CameraController** (LocalScript)
   - Скопируйте содержимое `LocalScripts/CameraController.lua`

3. **VisualEffects** (LocalScript)
   - Скопируйте содержимое `LocalScripts/VisualEffects.lua`

### 3. Настройка игры

#### Настройка игрока
1. В StarterPlayer настройте:
   - WalkSpeed: 16
   - JumpPower: 50
   - CameraMinZoomDistance: 10
   - CameraMaxZoomDistance: 50

#### Настройка освещения
1. В Lighting настройте:
   - Ambient: RGB(100, 100, 100)
   - Brightness: 2
   - OutdoorAmbient: RGB(100, 100, 100)

### 4. Тестирование
1. Нажмите F5 для запуска игры
2. Игрок должен появиться над платформой
3. Используйте левую кнопку мыши для добычи камней
4. Используйте правую кнопку мыши для вращения камеры
5. Используйте колесико мыши для зума

## Управление

- **ЛКМ** - Добыча камней
- **ПКМ** - Вращение камеры
- **Колесико мыши** - Зум камеры
- **Кнопка "Buy Cell"** - Покупка новой клетки
- **Кнопка "Sell All"** - Продажа всех ресурсов
- **Клик по торговцу** - Продажа всех ресурсов

## Типы камней

- **Обычный камень** (серый) - 2 камня
- **Медь** (коричневый) - 1 камень + 1 медь
- **Олово** (серебристый) - 1 камень + 2 олово
- **Железо** (темно-коричневый) - 1 камень + 1 железо

## Цены ресурсов

- Камень: 1 монета
- Медь: 3 монеты
- Олово: 5 монет
- Железо: 10 монет

## Стоимость клеток

Стоимость каждой новой клетки увеличивается: 10, 20, 30, 40, 50... монет