-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
-- Logo Gui
local TweenService = game:GetService("TweenService")
local screenGui = Instance.new("ScreenGui")
local StarterGui = game:GetService("StarterGui")
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
-- Logo
local image = Instance.new("ImageLabel")
image.Parent = screenGui
image.Size = UDim2.new(0, 200, 0, 200)
image.AnchorPoint = Vector2.new(0.5, 0.5)
image.Position = UDim2.new(0.5, 0, 0.5, 0)
image.BackgroundTransparency = 1
image.Image = "rbxassetid://91438373912852"
-- Message
StarterGui:SetCore("SendNotification", {
    Title = "XSV 4.0R",
    Text = "Welcome!",
    Icon = "rbxassetid://91438373912852",
    Duration = 5
})
--Logo Apply
local function LogoShow()
    -- Уменьшение
    TweenService:Create(
        image,
        TweenInfo.new(3, Enum.EasingStyle.Quad),
        {Size = UDim2.new(0, 200 * 0.6, 0, 200 * 0.6)}
    ):Play()
    task.wait(3)

    -- Увеличение
    TweenService:Create(
        image,
        TweenInfo.new(3, Enum.EasingStyle.Quad),
        {Size = UDim2.new(0, 200 * 0.9, 0, 200 * 0.9)}
    ):Play()
    task.wait(3)

    TweenService:Create(
        image,
        TweenInfo.new(1, Enum.EasingStyle.Quad),
        {ImageTransparency = 1} -- полностью прозрачно
    ):Play()

    task.wait(2)

    image:Destroy()
end
-- Show Logo
LogoShow()
-- Gui
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/GHOST-428/XSV-Roblox/refs/heads/main/modded-gui.lua"))()
local Window = Library.CreateLib("XSV [4.2R][Nemor03]", "RJTheme3")

-- Boxes
local track
local fling
local bodyGyro, bodyVelocity, flyConnection

local function InitAnim(animID)
    local animation = Instance.new("Animation")
    animation.AnimationId = animID
    track = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation)
end

local Settings = {
    Esp = false,
    Fly = false,
    FlySpeed = 10,
    NoClip = false,
    GodMode = false,
    Speed = 19,
    Jump = 30,
    Bang = false,
    FaceSit = false,
    Flinging = false,
    TouchFlinging = false,
    PartsForControll = {},
    RingParts = false,
    RingRadius = 30,
    RingPower = 5,
    LevitateParts = false,
    StormParts = false,
    StormIntensity = 30
}

local function shouldAffectPart(part)
    if not part or not part.Parent then return false end
    if part:IsDescendantOf(Players.LocalPlayer.Character) then return false end
    if part:IsA("Terrain") or part.Name == "Baseplate" or part.Name == "BasePlate" then return false end
    if part.Anchored then return false end
    if part.Name == "Handle" or part:FindFirstAncestorWhichIsA("Tool") then return false end
    return true
end

local function addPart(part)
    if part:IsA("BasePart") and shouldAffectPart(part) and not table.find(Settings.PartsForControll, part) then
        part.CanCollide = false
        table.insert(Settings.PartsForControll, part)
    end
end

local function removePart(part)
    part.CanCollide = true
    local index = table.find(Settings.PartsForControll, part)
    if index then table.remove(Settings.PartsForControll, index) end
end

local function startFly()
    local character = Players.LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    -- Очистка предыдущих соединений
    if flyConnection then
        flyConnection:Disconnect()
    end
    
    -- Создание BodyGyro и BodyVelocity
    bodyGyro = Instance.new("BodyGyro")
    bodyVelocity = Instance.new("BodyVelocity")
    
    bodyGyro.P = 100000
    bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Parent = rootPart
    
    humanoid.PlatformStand = true
    
    -- Управление полетом
    flyConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Fly or not bodyGyro or not bodyVelocity then return end
        
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new()
        
        -- Управление WASD
        if UIS:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        
        -- Управление высотой (Space/Shift)
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        -- Нормализация и применение скорости
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * Settings.FlySpeed
        end
        
        bodyVelocity.Velocity = moveDirection
        bodyGyro.CFrame = camera.CFrame
    end)
end

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    local character = Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid then
            humanoid.PlatformStand = false
        end
        
        if rootPart then
            if bodyGyro then
                bodyGyro:Destroy()
                bodyGyro = nil
            end
            if bodyVelocity then
                bodyVelocity:Destroy()
                bodyVelocity = nil
            end
        end
    end
end

-- Initialize parts
for _, part in pairs(workspace:GetDescendants()) do 
    addPart(part) 
end

workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("BasePart") then addPart(descendant) end
end)

workspace.DescendantRemoving:Connect(function(descendant)
    if descendant:IsA("BasePart") then removePart(descendant) end
end)

--- Player
local TabPlayer = Window:NewTab("Player")
-- Section
local Player = TabPlayer:NewSection("Movement")
local Fly = TabPlayer:NewSection("Fly")
local Noclip = TabPlayer:NewSection("NoClip")
local GodMode = TabPlayer:NewSection("GodMode")

--- Visual
local TabVisual = Window:NewTab("Visual")
-- Section
local Visual = TabVisual:NewSection("ESP")

--- Players
local TabPlayers = Window:NewTab("Players")
-- Section
local List = TabPlayers:NewSection("List")

--- Fun
local TabTroll = Window:NewTab("Troll")
-- Section
local Current = TabTroll:NewSection("Current")
local All = TabTroll:NewSection("All")

--- Animations
local TabAnimations = Window:NewTab("Animations")
-- Section
local R15 = TabAnimations:NewSection("R15")
local Controll2 = TabAnimations:NewSection("Controll")

--- God's Power
local TabGod = Window:NewTab("God's power")
-- Section
local Ring = TabGod:NewSection("Ring Parts")
local Levitate = TabGod:NewSection("Levitate Parts")
local Storm = TabGod:NewSection("Storm Parts")

--- Exploits
local Exploit = Window:NewTab("Exploit's")
-- Section
local Gears = Exploit:NewSection("Gears")
local Mods = Exploit:NewSection("[FE] Mods")

-- Player
Player:NewSlider("Speed", "Walk Speed", 1000, 1, function(s)
    Settings.Speed = s
end)

Player:NewSlider("Jump Power", "Jump Height", 600, 1, function(s)
    Settings.Jump = s
end)

Fly:NewToggle("Enable", "Enable/Disable Fly", function(state)
    Settings.Fly = state
    if state then
        startFly()
    else
        stopFly()
    end
end)

Fly:NewSlider("Speed", "Fly speed", 500, 10, function(s)
    Settings.FlySpeed = s
end)

Noclip:NewToggle("Enable", "Enable/Disable Noclip", function(state)
    Settings.NoClip = state
end)

GodMode:NewToggle("Enable", "Enable/Disable GodMode", function(state)
    Settings.GodMode = state
end)

-- Visual
Visual:NewToggle("Player", "Show player ESP", function(state)
    Settings.Esp = state
end)

-- List
local TheList = List:NewPlayerList(function(selectedPlayer)
    -- List
end)

-- Troll
Current:NewToggle("Bang", "Enable/Disable Bang", function(state)
    Settings.Bang = state

    if state then
        if game.Players.LocalPlayer.Character.Humanoid.RigType == "R15" then
            InitAnim("rbxassetid://5918726674")
        else
            InitAnim("rbxassetid://148840371")
        end
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
        track:AdjustSpeed(1.0)  -- Скорость воспроизведения
    else
        if track then
            track:Stop()
        end
    end
end)

Current:NewToggle("FaceSit", "Enable/Disable Sit on Face", function(state)
    Settings.FaceSit = state

    if state then
        game.Players.LocalPlayer.Character.Humanoid.Sit = true
    else
        game.Players.LocalPlayer.Character.Humanoid.Sit = false
    end
end)

Current:NewButton("Fling", "The Fling for Selected Player", function()
    -- Players.LocalPlayer
    -- TheList:GetSelectedPlayer()

    local Thrust = Instance.new('BodyThrust', Players.LocalPlayer.Character.HumanoidRootPart)
    Thrust.Force = Vector3.new(9999,9999,9999)
    Thrust.Name = "YeetForce"

    repeat
        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = TheList:GetSelectedPlayer().Character.HumanoidRootPart.CFrame
        Thrust.Location = TheList:GetSelectedPlayer().Character.HumanoidRootPart.Position
        RunService.Heartbeat:wait()
    until not TheList:GetSelectedPlayer().Character:FindFirstChild("Head") or not TheList:GetSelectedPlayer().Character:FindFirstChild("HumanoidRootPart")

    if Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("YeetForce") then
        Players.LocalPlayer.Character.HumanoidRootPart.YeetForce:Destroy()
    end
end)

All:NewToggle("Fling", "Enable/Disable Fling on Touch", function(state)
    local character = Players.LocalPlayer.Character
    Settings.TouchFlinging = state

    if state then
        -- Включение флинга
        fling = Instance.new("BodyAngularVelocity")
        fling.Name = "1R_Module"
        fling.Parent = character.HumanoidRootPart
        fling.AngularVelocity = Vector3.new(0, 99999, 0)
        fling.MaxTorque = Vector3.new(0, math.huge, 0)
        fling.P = math.huge

        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("BasePart") then
                child.CanCollide = false
                child.Massless = true
                child.Velocity = Vector3.new(0, 0, 0)
            end
        end

        repeat
            fling.AngularVelocity = Vector3.new(0,99999,0)
            wait(.2)
            fling.AngularVelocity = Vector3.new(0,0,0)
            wait(.1)
        until Settings.TouchFlinging == false
    else
        -- Выключение флинга
        fling:Destroy()
        for _, child in pairs(Players.LocalPlayer.Character:GetDescendants()) do
            if child.ClassName == "Part" or child.ClassName == "MeshPart" then
                child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
            end
        end
    end
end)

-- Animations
R15:NewButton("Godlike", "The Animation", function()
    if track then
        track:Stop()
    end

    InitAnim("rbxassetid://10714347256")

    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.0)  -- Скорость воспроизведения
end)

R15:NewButton("Float", "The Animation", function()
    if track then
        track:Stop()
    end

    InitAnim("rbxassetid://123867580718466")

    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.0)  -- Скорость воспроизведения
end)

R15:NewButton("Idle Floating", "The Animation", function()
    if track then
        track:Stop()
    end

    InitAnim("rbxassetid://103578898641453")

    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.0)  -- Скорость воспроизведения
end)

R15:NewButton("God Float", "The Animation", function()
    if track then
        track:Stop()
    end

    InitAnim("rbxassetid://100681208320300")

    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.0)  -- Скорость воспроизведения
end)

R15:NewButton("Build", "The Animation", function()
    if track then
        track:Stop()
    end

    InitAnim("rbxassetid://109873544976020")

    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.0)  -- Скорость воспроизведения
end)

R15:NewButton("Angel Fly", "The Animation", function()
    if track then
        track:Stop()
    end

    InitAnim("rbxassetid://77529400769588")

    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.0)  -- Скорость воспроизведения
end)

R15:NewButton("MetroMan", "The Animation", function()
    if track then
        track:Stop()
    end

    InitAnim("rbxassetid://120686345381920")

    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.0)  -- Скорость воспроизведения
end)

Controll2:NewButton("Stop", "Stop All Animations", function()
    if track then
        track:Stop()
    end
end)

-- Rage
Ring:NewToggle("Enable", "Enable/Disable Ring Parts", function(state)
    Settings.RingParts = state

    if not state then
        for _, part in pairs(Settings.PartsForControll) do
            if part and part.Parent then
                part.Velocity = Vector3.new(0, 0, 0)
                part.CanCollide = true
            end
        end
    end
end)

Ring:NewSlider("Radius", "Radius for Parts", 5000, 5, function(s)
    Settings.RingRadius = s
end)

Ring:NewSlider("Power", "Ring Rotation Speed", 6000, 5, function(s)
    Settings.RingPower = s
end)

Levitate:NewToggle("Enable", "Enable/Disable Levitate Parts", function(state)
    Settings.LevitateParts = state

    if not state then
        for _, part in pairs(Settings.PartsForControll) do
            if part and part.Parent then
                part.Velocity = Vector3.new(0, 0, 0)
                part.CanCollide = true
            end
        end
    end
end)

Storm:NewToggle("Enable", "Enable/Disable Storm Parts", function(state)
    Settings.StormParts = state

    if not state then
        for _, part in pairs(Settings.PartsForControll) do
            if part and part.Parent then
                part.Velocity = Vector3.new(0, 0, 0)
                part.CanCollide = true
            end
        end
    end
end)

Storm:NewSlider("Intensity", "Just Power", 3000, 30, function(s)
    Settings.StormIntensity = s
end)

Gears:NewButton("Give All", "Clone all Gears to BackPack", function()
    for i, v in pairs(game:GetDescendants()) do
        if v:IsA("Tool") and v.Parent.Parent ~= game:GetService("Players").LocalPlayer then
            local clonedTool = v:Clone()
            clonedTool.Parent = game:GetService("Players").LocalPlayer:WaitForChild("Backpack")
        end
    end

    StarterGui:SetCore("SendNotification", {
        Title = "XSV 3.1X",
        Text = "All tools received!",
        Icon = "rbxassetid://91438373912852",
        Duration = 5
    })
end)

Mods:NewButton("Cool Admin", "Mod", function()
    local animateScript = game.Players.LocalPlayer.Character:FindFirstChild("Animate")
    local RunAnimate = animateScript:FindFirstChild("run")
    local FallAnimate = animateScript:FindFirstChild("fall")
    local JumpAnimate = animateScript:FindFirstChild("jump")

    for _, object in pairs(RunAnimate:GetChildren()) do
        if object:IsA("Animation") and object.Name == "RunAnim" then
            object.AnimationId = "rbxassetid://103578898641453"
            break
        end
    end

    for _, object in pairs(FallAnimate:GetChildren()) do
        if object:IsA("Animation") and object.Name == "FallAnim" then
            object.AnimationId = "rbxassetid://77529400769588"
            break
        end
    end

    for _, object in pairs(JumpAnimate:GetChildren()) do
        if object:IsA("Animation") and object.Name == "JumpAnim" then
            object.AnimationId = "rbxassetid://77529400769588"
            break
        end
    end

    StarterGui:SetCore("SendNotification", {
        Title = "XSV 3.1X",
        Text = "Hah, now you're an admin",
        Icon = "rbxassetid://91438373912852",
        Duration = 5
    })
end)

game.Players.LocalPlayer.Character.Humanoid.HealthChanged:Connect(function()
    if Settings.GodMode then
        game.Players.LocalPlayer.Character.Humanoid.Health = 100
    end
end)

-- Loop
RunService.Heartbeat:Connect(function()
    Players.LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed
    Players.LocalPlayer.Character.Humanoid.JumpPower = Settings.Jump
    
    if Settings.Esp then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                local char = player.Character
                if char then
                    local humanoidRoot = char:FindFirstChild("HumanoidRootPart")

                    -- Создаем или обновляем ESP Box
                    if not char:FindFirstChild("UUPBOXXXXX") then
                        local box = Instance.new("BoxHandleAdornment")
                        box.Name = "UUPBOXXXXX"
                        box.Adornee = char
                        box.Size = char:GetExtentsSize() * 1.1
                        box.Transparency = 0.7
                        box.Color3 = Color3.fromRGB(255, 0, 0)
                        box.AlwaysOnTop = true
                        box.ZIndex = 10
                        box.Parent = char
                    end
                        
                    -- Создаем или обновляем текст с ником
                    if humanoidRoot and not char:FindFirstChild("UU100SKLOOP") then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "UU100SKLOOP"
                        billboard.Adornee = humanoidRoot
                        billboard.Size = UDim2.new(0, 100, 0, 40)
                        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                        billboard.AlwaysOnTop = true
                        billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                            
                        local textLabel = Instance.new("TextLabel")
                        textLabel.Text = player.DisplayName
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.TextStrokeTransparency = 0.5
                        textLabel.Font = Enum.Font.SourceSansBold
                        textLabel.TextSize = 18
                        textLabel.Parent = billboard
                            
                        billboard.Parent = char
                    end
                end
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                if player.Character:FindFirstChild("UUPBOXXXXX") then
                    player.Character.UUPBOXXXXX:Destroy()
                end

                if player.Character:FindFirstChild("UU100SKLOOP") then
                    player.Character.UU100SKLOOP:Destroy()
                end
            end
        end
    end

    if Settings.NoClip then
        for _, part in ipairs(Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if Settings.Bang then
        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = TheList:GetSelectedPlayer().Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
    end

    if Settings.FaceSit then
        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = TheList:GetSelectedPlayer().Character.HumanoidRootPart.CFrame * CFrame.new(0, 1.6, -0.6) * CFrame.Angles(0, math.pi, 0)
    end

    if Settings.RingParts then
        local rootPart = Players.LocalPlayer.Character.HumanoidRootPart
        local center = rootPart.Position

        for _, part in pairs(Settings.PartsForControll) do
            if part:IsA("BasePart") and not part.Anchored then
                if not part:IsDescendantOf(Players.LocalPlayer.Character) and
                not part:IsA("Terrain") and
                part.Name ~= "Baseplate" and
                part.Name ~= "BasePlate" and
                part.Name ~= "Handle" and
                not part:FindFirstAncestorWhichIsA("Tool") then
                    local pos = part.Position
                    local distance = (Vector3.new(pos.X, center.Y, pos.Z) - center).Magnitude
                    
                    -- Только если часть в радиусе влияния
                    if distance < 100 then
                        local angle = math.atan2(pos.Z - center.Z, pos.X - center.X)
                        local newAngle = angle + math.rad(50)
                        
                        local targetPos = Vector3.new(
                            center.X + math.cos(newAngle) * math.min(Settings.RingPower, distance),
                            center.Y + 6,
                            center.Z + math.sin(newAngle) * math.min(Settings.RingPower, distance)
                        )
                        
                        local direction = (targetPos - part.Position).unit
                        part.Velocity = direction * Settings.RingRadius
                    else
                        -- Если часть далеко, сбрасываем velocity
                        part.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    end

    if Settings.LevitateParts then
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored then
                if not part:IsDescendantOf(Players.LocalPlayer.Character) and
                not part:IsA("Terrain") and
                part.Name ~= "Baseplate" and
                part.Name ~= "BasePlate" and
                part.Name ~= "Handle" and
                not part:FindFirstAncestorWhichIsA("Tool") then
                    part.Velocity = Vector3.new(0, 35, 0)
                end
            end
        end
    end

    if Settings.StormParts then
        local rootPart = Players.LocalPlayer.Character.HumanoidRootPart
        local center = rootPart.Position
        local tornadoHeight = 30 -- Высота торнадо
        local tornadoRadius = 15 -- Радиус торнадо
        
        for _, part in pairs(Settings.PartsForControll) do
            if part and part.Parent then
                -- Вычисляем позицию части относительно центра торнадо
                local offset = part.Position - center
                local distance2D = Vector3.new(offset.X, 0, offset.Z).Magnitude
                
                -- Угол для кругового движения
                local angle = math.atan2(offset.Z, offset.X)
                local newAngle = angle + math.rad(Settings.StormIntensity * 2) -- Скорость вращения
                
                -- Целевая позиция в торнадо
                local targetPos = Vector3.new(
                    center.X + math.cos(newAngle) * math.min(distance2D, tornadoRadius),
                    center.Y + (part.Position.Y - center.Y) * 0.5 + tornadoHeight * (1 - distance2D / tornadoRadius),
                    center.Z + math.sin(newAngle) * math.min(distance2D, tornadoRadius)
                )
                
                -- Сила притяжения к центру и подъема
                local pullForce = (center - Vector3.new(part.Position.X, center.Y, part.Position.Z)) * 0.3
                local liftForce = Vector3.new(0, Settings.StormIntensity * 2, 0)
                
                -- Вращательная сила
                local rotationalForce = Vector3.new(
                    math.sin(newAngle) * Settings.StormIntensity * 3,
                    0,
                    -math.cos(newAngle) * Settings.StormIntensity * 3
                )
                
                -- Комбинируем все силы
                part.Velocity = pullForce + liftForce + rotationalForce
            end
        end
    end
end)
