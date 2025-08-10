local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Tuturial_UI_Library/main/UI_Template_1"))()
local Window = Library.CreateLib("XSV", "RJTheme3")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Animate
local humanoid = game.Players.LocalPlayer.Character.Humanoid
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://5918726674"
local track = humanoid:LoadAnimation(animation)

local Settings = {
    Esp = false,
    Fly = false,
    FlySpeed = 10,
    NoClip = false,
    Speed = 19,
    Jump = 30,
    Players = {},
    CurrentPlayer,
    The404 = false
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
local Troll = TabTroll:NewSection("Current")

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
    -- Полностью очищаем секцию
    for _, button in ipairs(Settings.Players) do
        button.object:Destroy()
    end
    Settings.Players = {}

    -- Добавляем всех игроков
    for _, player in pairs(Players:GetPlayers()) do
        local button = List:NewButton(player.Name, "The Player", function()
            Settings.CurrentPlayer = player
        end)

        table.insert(Settings.Players, button)
    end
end)

-- Troll
Troll:NewToggle("404", "Enable/Disable TP", function(state)
    Settings.The404 = state

    if state then
        track = humanoid:LoadAnimation(animation)
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
        track:AdjustSpeed(1.0)  -- Скорость воспроизведения
    else
        if track then
            track:Stop()
        end
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

    if Settings.The404 then
        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Settings.CurrentPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
    end
end)
