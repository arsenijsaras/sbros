local Fluent = loadstring(game:HttpGet("https://github.com"))()

local Window = Fluent:CreateWindow({
    Title = "Fling Things Mod Menu",
    SubTitle = "arsenijsaras | Delta Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 340),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Настройки", Icon = "settings" }),
    Combat = Window:AddTab({ Title = "Бой и Троллинг", Icon = "swords" })
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera

local AntiGrab_Enabled = false
local SuperThrow_Enabled = false
local ThrowVelocity = 500  
local SilentAim_Enabled = false
local SilentAim_FOV = 100 
local FOVCircle_Visible = false

-- === ОТРИСОВКА КРУГА FOV ===
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = SilentAim_FOV
FOVCircle.Filled = false
FOVCircle.Visible = false

RunService.RenderStepped:Connect(function()
    if FOVCircle_Visible and SilentAim_Enabled then
        local mouse = LocalPlayer:GetMouse()
        FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
        FOVCircle.Radius = SilentAim_FOV
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

-- === ЛОГИКА ANTI-GRAB (АНТИ-ЗАХВАТ) ===
RunService.Heartbeat:Connect(function()
    if AntiGrab_Enabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("Weld") or part:IsA("WeldConstraint") or part:IsA("TouchTransmitter") then
                if part.Name ~= "Neck" and part.Name ~= "RootJoint" and not part.Parent:IsA("Tool") then
                    part:Destroy()
                end
            end
        end
    end
end)

-- === НАСТРОЙКА ИНТЕРФЕЙСА (UI) ===

-- Вкладка 1: Главные настройки
local ToggleAntiGrab = Tabs.Main:AddToggle("AntiGrab", {Title = "Анти-Захват (Anti-Grab)", Default = false})
ToggleAntiGrab:OnChanged(function(Value) AntiGrab_Enabled = Value end)

local ToggleSuperThrow = Tabs.Main:AddToggle("SuperThrow", {Title = "Супер-Бросок", Default = false})
ToggleSuperThrow:OnChanged(function(Value) SuperThrow_Enabled = Value end)

local SliderThrow = Tabs.Main:AddSlider("ThrowSpeed", {
    Title = "Скорость броска",
    Description = "Регулирует дальность полета предметов и людей",
    Default = 500,
    Min = 100,
    Max = 5000,
    Rounding = 0
})
SliderThrow:OnChanged(function(Value) ThrowVelocity = Value end)

-- Вкладка 2: Бой и Троллинг
local ToggleSilent = Tabs.Combat:AddToggle("SilentAim", {Title = "Активировать Silent Aim", Default = false})
ToggleSilent:OnChanged(function(Value) SilentAim_Enabled = Value end)

local ToggleFOVShow = Tabs.Combat:AddToggle("ShowFOV", {Title = "Показывать круг FOV", Default = false})
ToggleFOVShow:OnChanged(function(Value) FOVCircle_Visible = Value end)

local SliderFOV = Tabs.Combat:AddSlider("SilentFOV", {
    Title = "Радиус Aim (FOV)",
    Description = "Настройка зоны захвата целей",
    Default = 100,
    Min = 10,
    Max = 800,
    Rounding = 0
})
SliderFOV:OnChanged(function(Value) SilentAim_FOV = Value end)

-- === ЛОГИКА SILENT AIM И СУПЕР-БРОСКА ===
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mouse = LocalPlayer:GetMouse()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                if distance < shortestDistance and distance <= SilentAim_FOV then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

game.Workspace.ChildAdded:Connect(function(child)
    if SuperThrow_Enabled and child:IsA("BasePart") then
        task.wait()
        
        local targetDirection = LocalPlayer:GetMouse().UnitRay.Direction
        
        if SilentAim_Enabled then
            local targetPlayer = getClosestPlayer()
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                targetDirection = (targetPlayer.Character.HumanoidRootPart.Position - child.Position).Unit
            end
        end
        
        child.AssemblyLinearVelocity = targetDirection * ThrowVelocity
    end
end)

Fluent:Notify({
    Title = "Скрипт загружен!",
    Content = "Мод-меню для игры успешно запущено.",
    Duration = 5
})
