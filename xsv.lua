-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
-- Logo Gui
local TweenService = game:GetService("TweenService")
local screenGui = Instance.new("ScreenGui")
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
local Window = Library.CreateLib("XSV [1.6F]", "RJTheme3")

-- Boxes
local track
local fling

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
    Speed = 19,
    Jump = 30,
    CurrentPlayer,
    Bang = false,
    FaceSit = false,
    Flinging = false,
    TouchFlinging = false
}

--- Player
local TabPlayer = Window:NewTab("Player")
-- Section
local Player = TabPlayer:NewSection("Movement")
local Fly = TabPlayer:NewSection("Fly")
local Noclip = TabPlayer:NewSection("NoClip")

--- Visual
local TabVisual = Window:NewTab("Visual")
-- Section
local Visual = TabVisual:NewSection("ESP")

--- Players
local TabPlayers = Window:NewTab("Players")
-- Section
local List = TabPlayers:NewSection("List")
local Controll = TabPlayers:NewSection("Controll")

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

-- Player
Player:NewSlider("Speed", "Walk Speed", 300, 1, function(s)
    Settings.Speed = s
end)

Player:NewSlider("Jump Power", "Jump Height", 300, 1, function(s)
    Settings.Jump = s
end)

Fly:NewToggle("Enable", "Enable/Disable Fly", function(state)
    Settings.Fly = state
end)

Fly:NewSlider("Speed", "Fly speed", 500, 10, function(s)
    Settings.FlySpeed = s
end)

Noclip:NewToggle("Enable", "Enable/Disable Noclip", function(state)
    Settings.NoClip = state
end)

-- Visual
Visual:NewToggle("Player", "Show player ESP", function(state)
    Settings.Esp = state
end)

-- List
Controll:NewButton("Refresh List", "Update Player List", function()
    -- Добавляем всех игроков
    for _, player in pairs(Players:GetPlayers()) do
        button = List:NewButton(player.DisplayName, "The Player", function()
            Settings.CurrentPlayer = player
        end)
    end
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
    -- Settings.CurrentPlayer

    local Thrust = Instance.new('BodyThrust', Players.LocalPlayer.Character.HumanoidRootPart)
    Thrust.Force = Vector3.new(9999,9999,9999)
    Thrust.Name = "YeetForce"

    repeat
        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Settings.CurrentPlayer.Character.HumanoidRootPart.CFrame
        Thrust.Location = Settings.CurrentPlayer.Character.HumanoidRootPart.Position
        RunService.Heartbeat:wait()
    until not Settings.CurrentPlayer.Character:FindFirstChild("Head") or not Settings.CurrentPlayer.Character:FindFirstChild("HumanoidRootPart")

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
        for _, child in pairs(speakerChar:GetDescendants()) do
            if child.ClassName == "Part" or child.ClassName == "MeshPart" then
                child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
            end
        end
    end
end)

R15:NewButton("Godlike", "The Animation", function()
    InitAnim("rbxassetid://10714347256")

    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.0)  -- Скорость воспроизведения
end)

R15:NewButton("Float", "The Animation", function()
    InitAnim("rbxassetid://123867580718466")

    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.0)  -- Скорость воспроизведения
end)

R15:NewButton("Gojo Floating", "The Animation", function()
    InitAnim("rbxassetid://73211757884080")

    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.0)  -- Скорость воспроизведения
end)

R15:NewButton("Idle Floating", "The Animation", function()
    InitAnim("rbxassetid://103578898641453")

    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.0)  -- Скорость воспроизведения
end)

R15:NewButton("God Float", "The Animation", function()
    InitAnim("rbxassetid://100681208320300")

    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.0)  -- Скорость воспроизведения
end)

R15:NewButton("Build", "The Animation", function()
    InitAnim("rbxassetid://113006894305390")

    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.0)  -- Скорость воспроизведения
end)

R15:NewButton("Angel Fly", "The Animation", function()
    InitAnim("rbxassetid://77529400769588")

    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.0)  -- Скорость воспроизведения
end)

Controll2:NewButton("Stop", "Stop All Animations", function()
    track:Stop()
end)

-- Loop
RunService.Heartbeat:Connect(function()
    Players.LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed
    Players.LocalPlayer.Character.Humanoid.JumpPower = Settings.Jump
    if Settings.Esp then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                local char = player.Character
                local humanoidRoot = char:FindFirstChild("HumanoidRootPart")

                -- Создаем или обновляем ESP Box
                if not char:FindFirstChild("ESPBox") then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "ESPBox"
                    box.Adornee = char
                    box.Size = char:GetExtentsSize() * 1.1
                    box.Transparency = 0.7
                    box.Color3 = Color3.fromRGB(255, 0, 0)
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Parent = char
                end
                    
                -- Создаем или обновляем текст с ником
                if not char:FindFirstChild("ESPLabel") then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ESPLabel"
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
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                if player.Character:FindFirstChild("ESPBox") then
                    player.Character.ESPBox:Destroy()
                end
                if player.Character:FindFirstChild("ESPLabel") then
                    player.Character.ESPLabel:Destroy()
                end
            end
        end
    end

    if Settings.Fly then
        local root = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera.CFrame
        
        if root then
            local move = Vector3.new()
            if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
            
            root.Velocity = move.Magnitude > 0 and move.Unit * Settings.FlySpeed or Vector3.new()
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
        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Settings.CurrentPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
    end

    if Settings.FaceSit then
        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Settings.CurrentPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 1.6, -0.6) * CFrame.Angles(0, math.pi, 0)
    end
end)
