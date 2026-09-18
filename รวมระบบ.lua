local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()
local camera = workspace.CurrentCamera

-- สถานะฟังก์ชั่นต่าง ๆ
local speedEnabled = false
local infJumpEnabled = false
local flyEnabled = false
local clickTpEnabled = false
local noclipEnabled = false
local invisibleEnabled = false

-- สถานะฟังก์ชั่นเครื่องมือ
local fpsBoostEnabled = false
local fastEEnabled = false
local flingEnabled = false

-- สถานะฟังก์ชั่นต่อสู้
local aimbotEnabled = false
local fovVisible = true
local fovRadius = 120
local hitboxEnabled = false
local hitboxSize = 10

-- สถานะฟังก์ชั่นมอง (ESP)
local playerEspEnabled = false
local npcEspEnabled = false

local fastSpeed = 64
local defaultSpeed = 16

-- ระบบบิน (Fly)
local flySpeed = 50
local flyUp = false
local flyDown = false
local flyGui = nil
local flyConnection = nil
local bodyVel = nil
local bodyGyro = nil
local flyToggleObj = nil

-- ตั้งค่า ID เสียง
local SOUND_STARTUP = "rbxassetid://4590662766" -- เสียงตอนรันสคริปต์
local SOUND_CLICK   = "rbxassetid://6895079853" -- เสียงตอนกดปุ่ม / Toggle

-- ฟังก์ชันสำหรับเล่นเสียง
local function playSound(soundId)
    task.spawn(function()
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = 1.5
        sound.Parent = SoundService
        sound:Play()
        Debris:AddItem(sound, 2)
    end)
end

-- คำนวณ FPS
local currentFPS = 60
local frameCount = 0
local lastFPSTime = tick()

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = tick()
    if currentTime - lastFPSTime >= 1 then
        currentFPS = frameCount
        frameCount = 0
        lastFPSTime = currentTime
    end
end)

-- ดึงชื่อแมป
local mapName = "Unknown Map"
pcall(function()
    mapName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

-- สร้างวงกลม FOV สำหรับ Aimbot
local fovCircle = nil
if Drawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.5
    fovCircle.NumSides = 60
    fovCircle.Radius = fovRadius
    fovCircle.Filled = false
    fovCircle.Visible = false
    fovCircle.Color = Color3.fromRGB(255, 50, 50)
end

-- ค้นหาผู้เล่นที่ใกล้เมาส์ที่สุดในขอบเขต FOV
local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = fovRadius
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid.Health > 0 then
                local head = player.Character.Head
                local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- อัปเดตตำแหน่งวงกลม FOV และระบบล็อคหัว
RunService.RenderStepped:Connect(function()
    if fovCircle then
        fovCircle.Position = UserInputService:GetMouseLocation()
        fovCircle.Radius = fovRadius
        fovCircle.Visible = fovVisible and aimbotEnabled
    end

    if aimbotEnabled then
        local target = getClosestPlayerInFOV()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- ระบบขยาย Hitbox ผู้เล่น
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if hitboxEnabled then
                hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                hrp.Transparency = 0.7
                hrp.BrickColor = BrickColor.new("Really red")
                hrp.Material = Enum.Material.Neon
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
            end
        end
    end
end)

-- ==================== ระบบมองทะลุ (ESP) ====================
local function updatePlayerEsp()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if playerEspEnabled and player.Character then
                local highlight = player.Character:FindFirstChild("EXC_PlayerESP")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "EXC_PlayerESP"
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = player.Character
                end
            else
                if player.Character and player.Character:FindFirstChild("EXC_PlayerESP") then
                    player.Character.EXC_PlayerESP:Destroy()
                end
            end
        end
    end
end

local function isNPC(model)
    if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(model) then
        return true
    end
    return false
end

local function updateNpcEsp()
    for _, v in ipairs(workspace:GetDescendants()) do
        if isNPC(v) then
            if npcEspEnabled then
                local highlight = v:FindFirstChild("EXC_NpcESP")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "EXC_NpcESP"
                    highlight.FillColor = Color3.fromRGB(50, 255, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = v
                end
            else
                if v:FindFirstChild("EXC_NpcESP") then
                    v.EXC_NpcESP:Destroy()
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if playerEspEnabled then
        updatePlayerEsp()
    end
    if npcEspEnabled then
        updateNpcEsp()
    end
end)

-- อัปเดตความเร็วตัวละคร
local function updateSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if speedEnabled then
            humanoid.WalkSpeed = fastSpeed
        else
            humanoid.WalkSpeed = defaultSpeed
        end
    end
end

-- ระบบหายตัว (Invisibility)
local function setInvisibility(state)
    local char = LocalPlayer.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                if state then
                    if not v:FindFirstChild("SavedTransparency") then
                        local tag = Instance.new("NumberValue")
                        tag.Name = "SavedTransparency"
                        tag.Value = v.Transparency
                        tag.Parent = v
                    end
                    v.Transparency = 1
                else
                    if v:FindFirstChild("SavedTransparency") then
                        v.Transparency = v.SavedTransparency.Value
                        v.SavedTransparency:Destroy()
                    else
                        v.Transparency = 0
                    end
                end
            end
        end
    end
end

-- ระบบเดินทะลุกำแพง (Noclip)
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ระบบวาปตามจุดที่กด (Click TP)
mouse.Button1Down:Connect(function()
    if clickTpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if mouse.Hit then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)

-- ระบบหยิบของเร็ว E (Fast ProximityPrompt)
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if fastEEnabled then
        fireproximityprompt(prompt)
    end
end)

RunService.Stepped:Connect(function()
    if fastEEnabled then
        for _, prompt in pairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0
            end
        end
    end
end)

-- ระบบชนผู้เล่นกระเด็น (Touch Fling)
RunService.Heartbeat:Connect(function()
    if flingEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.AssemblyAngularVelocity = Vector3.new(0, 999999, 0)
    end
end)

-- ระบบลดกราฟิก เพิ่ม FPS
local function applyFpsBoost(state)
    if state then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = false
            end
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    end
end

-- ระบบย้ายเข้าเซิฟเวอร์คนน้อย
local function joinLowServer()
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(Api))
    end)
    
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers and server.playing > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                return
            end
        end
    end
end

-- หยุดการบิน
local function stopFlying()
    flyEnabled = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if bodyVel then bodyVel:Destroy() bodyVel = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if flyGui then flyGui:Destroy() flyGui = nil end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end
    flyUp = false
    flyDown = false
end

-- สร้าง UI ควบคุมการบิน
local function createFlyGui()
    if flyGui then flyGui:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EXCHubFlyGui"
    ScreenGui.ResetOnSpawn = false
    
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 190, 0, 160)
    Frame.Position = UDim2.new(0.05, 0, 0.35, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.Text = "FLY CONTROL (ลากได้)"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 11
    Title.Font = Enum.Font.SourceSansBold
    Title.BackgroundTransparency = 1
    Title.Parent = Frame
    
    local UpBtn = Instance.new("TextButton")
    UpBtn.Size = UDim2.new(0.43, 0, 0, 30)
    UpBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    UpBtn.Text = "ขึ้น ▲"
    UpBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    UpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    UpBtn.Font = Enum.Font.SourceSansBold
    UpBtn.Parent = Frame
    Instance.new("UICorner", UpBtn).CornerRadius = UDim.new(0, 6)
    
    UpBtn.MouseButton1Down:Connect(function() flyUp = true end)
    UpBtn.MouseButton1Up:Connect(function() flyUp = false end)
    
    local DownBtn = Instance.new("TextButton")
    DownBtn.Size = UDim2.new(0.43, 0, 0, 30)
    DownBtn.Position = UDim2.new(0.52, 0, 0.2, 0)
    DownBtn.Text = "ลง ▼"
    DownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    DownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DownBtn.Font = Enum.Font.SourceSansBold
    DownBtn.Parent = Frame
    Instance.new("UICorner", DownBtn).CornerRadius = UDim.new(0, 6)
    
    DownBtn.MouseButton1Down:Connect(function() flyDown = true end)
    DownBtn.MouseButton1Up:Connect(function() flyDown = false end)
    
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
    SpeedLabel.Position = UDim2.new(0, 0, 0.44, 0)
    SpeedLabel.Text = "ความเร็ว: " .. flySpeed
    SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SpeedLabel.TextSize = 12
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Parent = Frame
    
    local SpeedMinus = Instance.new("TextButton")
    SpeedMinus.Size = UDim2.new(0.43, 0, 0, 25)
    SpeedMinus.Position = UDim2.new(0.05, 0, 0.58, 0)
    SpeedMinus.Text = "- ช้าลง"
    SpeedMinus.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    SpeedMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedMinus.Parent = Frame
    Instance.new("UICorner", SpeedMinus).CornerRadius = UDim.new(0, 6)
    
    SpeedMinus.MouseButton1Click:Connect(function()
        playSound(SOUND_CLICK)
        flySpeed = math.max(10, flySpeed - 10)
        SpeedLabel.Text = "ความเร็ว: " .. flySpeed
    end)
    
    local SpeedPlus = Instance.new("TextButton")
    SpeedPlus.Size = UDim2.new(0.43, 0, 0, 25)
    SpeedPlus.Position = UDim2.new(0.52, 0, 0.58, 0)
    SpeedPlus.Text = "+ เร็วขึ้น"
    SpeedPlus.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    SpeedPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedPlus.Parent = Frame
    Instance.new("UICorner", SpeedPlus).CornerRadius = UDim.new(0, 6)
    
    SpeedPlus.MouseButton1Click:Connect(function()
        playSound(SOUND_CLICK)
        flySpeed = math.min(300, flySpeed + 10)
        SpeedLabel.Text = "ความเร็ว: " .. flySpeed
    end)
    
    local StopBtn = Instance.new("TextButton")
    StopBtn.Size = UDim2.new(0.9, 0, 0, 25)
    StopBtn.Position = UDim2.new(0.05, 0, 0.78, 0)
    StopBtn.Text = "เลิกบิน"
    StopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopBtn.Font = Enum.Font.SourceSansBold
    StopBtn.Parent = Frame
    Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)
    
    StopBtn.MouseButton1Click:Connect(function()
        playSound(SOUND_CLICK)
        if flyToggleObj then
            flyToggleObj:SetValue(false)
        else
            stopFlying()
        end
    end)
    
    flyGui = ScreenGui
end

-- เริ่มบิน
local function startFlying()
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    flyEnabled = true
    humanoid.PlatformStand = true

    bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent = hrp

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.P = 9000
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    createFlyGui()

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            stopFlying()
            return
        end

        local currentHumanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local moveVector = currentHumanoid and currentHumanoid.MoveDirection or Vector3.zero
        local cameraCFrame = camera.CFrame
        
        local velocity = Vector3.zero

        if moveVector.Magnitude > 0 then
            velocity = moveVector * flySpeed
        end

        if flyUp then
            velocity = velocity + Vector3.new(0, flySpeed, 0)
        end
        if flyDown then
            velocity = velocity - Vector3.new(0, flySpeed, 0)
        end

        bodyVel.Velocity = velocity
        bodyGyro.CFrame = cameraCFrame
    end)
end

-- ระบบกระโดดไม่จำกัด (Infinite Jump)
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- เล่นเสียงทันทีตอนรันสคริปต์
playSound(SOUND_STARTUP)

-- ตั้งค่าตัวละครเกิดใหม่
LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        task.wait(0.1)
        if speedEnabled then
            humanoid.WalkSpeed = fastSpeed
        end
        if invisibleEnabled then
            setInvisibility(true)
        end
        if flyEnabled then
            stopFlying()
            if flyToggleObj then
                flyToggleObj:SetValue(false)
            end
        end
    end
end)

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "EXC HUB [รวมฟังก์ชั่น]",
    Author = "EXC HUB",
    Folder = "RunLuaConfig",
    Size = UDim2.fromOffset(580, 480),
    Transparent = true,
    Theme = "Dark",
    Background = "rbxthumb://type=Asset&id=559906823&w=768&h=432",
    BackgroundImageTransparency = 0.55
})

-- ==================== หน้าหลัก ====================
local MainTab = Window:Tab({ Title = "หน้าหลัก", Icon = "home" })

-- ==================== การ์ดโปรไฟล์สถานะผู้เล่น ====================
local function createProfileWidget(parentTab)
    local Container = Instance.new("Frame")
    Container.Name = "ProfileWidget"
    Container.Size = UDim2.new(1, 0, 0, 150)
    Container.BackgroundColor3 = Color3.fromRGB(15, 23, 36)
    Container.BorderSizePixel = 0
    Container.Parent = parentTab:GetInstance()

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Container

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(28, 55, 80)
    Stroke.Thickness = 1.5
    Stroke.Parent = Container

    -- รูปหัวตัวละคร
    local AvatarFrame = Instance.new("Frame")
    AvatarFrame.Size = UDim2.new(0, 60, 0, 60)
    AvatarFrame.Position = UDim2.new(0, 12, 0, 12)
    AvatarFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    AvatarFrame.BorderSizePixel = 0
    AvatarFrame.Parent = Container

    Instance.new("UICorner", AvatarFrame).CornerRadius = UDim.new(0, 12)
    local AvatarStroke = Instance.new("UIStroke")
    AvatarStroke.Color = Color3.fromRGB(0, 140, 220)
    AvatarStroke.Thickness = 1.5
    AvatarStroke.Parent = AvatarFrame

    local AvatarImg = Instance.new("ImageLabel")
    AvatarImg.Size = UDim2.new(1, 0, 1, 0)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    AvatarImg.Parent = AvatarFrame
    Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(0, 12)

    -- Display Name
    local DisplayLabel = Instance.new("TextLabel")
    DisplayLabel.Size = UDim2.new(0, 200, 0, 20)
    DisplayLabel.Position = UDim2.new(0, 82, 0, 12)
    DisplayLabel.Text = LocalPlayer.DisplayName
    DisplayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DisplayLabel.TextSize = 15
    DisplayLabel.Font = Enum.Font.SourceSansBold
    DisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
    DisplayLabel.BackgroundTransparency = 1
    DisplayLabel.Parent = Container

    -- Username
    local UserLabel = Instance.new("TextLabel")
    UserLabel.Size = UDim2.new(0, 200, 0, 16)
    UserLabel.Position = UDim2.new(0, 82, 0, 32)
    UserLabel.Text = "@" .. LocalPlayer.Name
    UserLabel.TextColor3 = Color3.fromRGB(140, 160, 180)
    UserLabel.TextSize = 12
    UserLabel.Font = Enum.Font.SourceSans
    UserLabel.TextXAlignment = Enum.TextXAlignment.Left
    UserLabel.BackgroundTransparency = 1
    UserLabel.Parent = Container

    -- Badge แสดง FPS
    local FpsBadge = Instance.new("Frame")
    FpsBadge.Size = UDim2.new(0, 75, 0, 20)
    FpsBadge.Position = UDim2.new(0, 82, 0, 52)
    FpsBadge.BackgroundColor3 = Color3.fromRGB(10, 30, 48)
    FpsBadge.BorderSizePixel = 0
    FpsBadge.Parent = Container

    Instance.new("UICorner", FpsBadge).CornerRadius = UDim.new(0, 6)
    local FpsStroke = Instance.new("UIStroke")
    FpsStroke.Color = Color3.fromRGB(0, 100, 150)
    FpsStroke.Thickness = 1
    FpsStroke.Parent = FpsBadge

    local FpsLabel = Instance.new("TextLabel")
    FpsLabel.Size = UDim2.new(1, 0, 1, 0)
    FpsLabel.Text = "FPS 60"
    FpsLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    FpsLabel.TextSize = 11
    FpsLabel.Font = Enum.Font.SourceSansBold
    FpsLabel.BackgroundTransparency = 1
    FpsLabel.Parent = FpsBadge

    -- Health Section
    local HealthTitle = Instance.new("TextLabel")
    HealthTitle.Size = UDim2.new(0, 100, 0, 16)
    HealthTitle.Position = UDim2.new(0, 12, 0, 80)
    HealthTitle.Text = "Health"
    HealthTitle.TextColor3 = Color3.fromRGB(180, 190, 200)
    HealthTitle.TextSize = 12
    HealthTitle.Font = Enum.Font.SourceSans
    HealthTitle.TextXAlignment = Enum.TextXAlignment.Left
    HealthTitle.BackgroundTransparency = 1
    HealthTitle.Parent = Container

    local HealthValueLabel = Instance.new("TextLabel")
    HealthValueLabel.Size = UDim2.new(0, 100, 0, 16)
    HealthValueLabel.Position = UDim2.new(1, -112, 0, 80)
    HealthValueLabel.Text = "100 / 100"
    HealthValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    HealthValueLabel.TextSize = 12
    HealthValueLabel.Font = Enum.Font.SourceSansBold
    HealthValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    HealthValueLabel.BackgroundTransparency = 1
    HealthValueLabel.Parent = Container

    -- Health Bar Background
    local HealthBg = Instance.new("Frame")
    HealthBg.Size = UDim2.new(1, -24, 0, 8)
    HealthBg.Position = UDim2.new(0, 12, 0, 98)
    HealthBg.BackgroundColor3 = Color3.fromRGB(25, 35, 45)
    HealthBg.BorderSizePixel = 0
    HealthBg.Parent = Container
    Instance.new("UICorner", HealthBg).CornerRadius = UDim.new(1, 0)

    -- Health Bar Fill
    local HealthFill = Instance.new("Frame")
    HealthFill.Size = UDim2.new(1, 0, 1, 0)
    HealthFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    HealthFill.BorderSizePixel = 0
    HealthFill.Parent = HealthBg
    Instance.new("UICorner", HealthFill).CornerRadius = UDim.new(1, 0)

    -- Map Info & Player Count
    local MapLabel = Instance.new("TextLabel")
    MapLabel.Size = UDim2.new(1, -24, 0, 14)
    MapLabel.Position = UDim2.new(0, 12, 0, 112)
    MapLabel.Text = "Map: " .. mapName
    MapLabel.TextColor3 = Color3.fromRGB(200, 210, 220)
    MapLabel.TextSize = 11
    MapLabel.Font = Enum.Font.SourceSans
    MapLabel.TextXAlignment = Enum.TextXAlignment.Left
    MapLabel.TextTruncate = Enum.TextTruncate.AtEnd
    MapLabel.BackgroundTransparency = 1
    MapLabel.Parent = Container

    local ServerLabel = Instance.new("TextLabel")
    ServerLabel.Size = UDim2.new(1, -24, 0, 14)
    ServerLabel.Position = UDim2.new(0, 12, 0, 128)
    ServerLabel.Text = "ID: " .. game.PlaceId .. "  -  Players: " .. #Players:GetPlayers()
    ServerLabel.TextColor3 = Color3.fromRGB(100, 120, 140)
    ServerLabel.TextSize = 10
    ServerLabel.Font = Enum.Font.SourceSans
    ServerLabel.TextXAlignment = Enum.TextXAlignment.Left
    ServerLabel.BackgroundTransparency = 1
    ServerLabel.Parent = Container

    -- อัปเดตข้อมูลแบบ Real-time
    RunService.RenderStepped:Connect(function()
        FpsLabel.Text = "FPS " .. currentFPS

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local health = math.clamp(hum.Health, 0, hum.MaxHealth)
            local maxHealth = hum.MaxHealth
            HealthValueLabel.Text = math.floor(health) .. " / " .. math.floor(maxHealth)
            HealthFill.Size = UDim2.new(health / maxHealth, 0, 1, 0)
        end

        ServerLabel.Text = "ID: " .. game.PlaceId .. "  -  Players: " .. #Players:GetPlayers()
    end)
end

-- เรียกใช้การ์ดข้อมูลผู้เล่น
createProfileWidget(MainTab)

MainTab:Section({ Title = "ช่องทางผู้สร้าง" })

MainTab:Button({
    Title = "ไอจีคนสร้าง",
    Desc = "คลิกเพื่อก๊อปปี้ลิงก์ Instagram",
    Callback = function()
        playSound(SOUND_CLICK)
        setclipboard("https://www.instagram.com/your_instagram")
    end
})

MainTab:Button({
    Title = "ดิสคนสร้าง",
    Desc = "คลิกเพื่อก๊อปปี้ลิงก์ Discord",
    Callback = function()
        playSound(SOUND_CLICK)
        setclipboard("https://discord.gg/your_discord")
    end
})

MainTab:Button({
    Title = "ติ๊กต๊อกคนสร้าง",
    Desc = "คลิกเพื่อก๊อปปี้ลิงก์ TikTok",
    Callback = function()
        playSound(SOUND_CLICK)
        setclipboard("https://www.tiktok.com/@your_tiktok")
    end
})

-- ==================== หมวดหมู่: หลัก ====================
local PlayerTab = Window:Tab({ Title = "หลัก", Icon = "user" })

PlayerTab:Section({ Title = "สถานะตัวละคร" })

PlayerTab:Toggle({
    Title = "เปิด/ปิด วิ่งไว (4x)",
    Value = false,
    Callback = function(Value)
        playSound(SOUND_CLICK)
        speedEnabled = Value
        updateSpeed()
    end
})

PlayerTab:Toggle({
    Title = "เปิด/ปิด กระโดดไม่จำกัด (Infinite Jump)",
    Value = false,
    Callback = function(Value)
        playSound(SOUND_CLICK)
        infJumpEnabled = Value
    end
})

flyToggleObj = PlayerTab:Toggle({
    Title = "เปิด/ปิด บิน (Fly)",
    Value = false,
    Callback = function(Value)
        playSound(SOUND_CLICK)
        if Value then
            startFlying()
        else
            stopFlying()
        end
    end
})

PlayerTab:Section({ Title = "ระบบเคลื่อนที่พิเศษ" })

PlayerTab:Toggle({
    Title = "เปิด/ปิด วาปตามจุดที่กด (Click TP)",
    Value = false,
    Callback = function(Value)
        playSound(SOUND_CLICK)
        clickTpEnabled = Value
    end
})

PlayerTab:Toggle({
    Title = "เปิด/ปิด เดินทะลุกำแพง (Noclip)",
    Value = false,
    Callback = function(Value)
        playSound(SOUND_CLICK)
        noclipEnabled = Value
    end
})

PlayerTab:Toggle({
    Title = "เปิด/ปิด หายตัว (Invisible)",
    Value = false,
    Callback = function(Value)
        playSound(SOUND_CLICK)
        invisibleEnabled = Value
        setInvisibility(Value)
    end
})

-- ==================== หมวดหมู่: ต่อสู้ ====================
local CombatTab = Window:Tab({ Title = "ต่อสู้", Icon = "swords" })

CombatTab:Section({ Title = "ระบบช่วยเล็ง (Aimbot)" })

CombatTab:Toggle({
    Title = "เปิด/ปิด ล็อคหัวผู้เล่น (Aimbot Head)",
    Desc = "ล็อคเป้าหมายไปที่หัวของผู้เล่นที่ใกล้ที่สุดในระยะ FOV",
    Value = false,
    Callback = function(Value)
        playSound(SOUND_CLICK)
        aimbotEnabled = Value
    end
})

CombatTab:Toggle({
    Title = "แสดงวงกลม FOV",
    Desc = "เปิด/ปิด การแสดงวงกลมขอบเขตการล็อค",
    Value = true,
    Callback = function(Value)
        playSound(SOUND_CLICK)
        fovVisible = Value
    end
})

CombatTab:Slider({
    Title = "ปรับขนาดขอบเขต FOV",
    Min = 30,
    Max = 500,
    Default = 120,
    Step = 5,
    Callback = function(Value)
        fovRadius = Value
    end
})

CombatTab:Section({ Title = "ระบบปรับขนาดเป้าหมาย" })

CombatTab:Toggle({
    Title = "เปิด/ปิด ขยาย Hitbox",
    Desc = "ขยายขนาดตัวผู้เล่นอื่นทำให้ยิง/ตีโดนง่ายขึ้น",
    Value = false,
    Callback = function(Value)
        playSound(SOUND_CLICK)
        hitboxEnabled = Value
    end
})

CombatTab:Slider({
    Title = "ปรับขนาด Hitbox",
    Min = 2,
    Max = 50,
    Default = 10,
    Step = 1,
    Callback = function(Value)
        hitboxSize = Value
    end
})

-- ==================== หมวดหมู่: มอง ====================
local VisualsTab = Window:Tab({ Title = "มอง", Icon = "eye" })

VisualsTab:Section({ Title = "ระบบมองทะลุ (ESP)" })

VisualsTab:Toggle({
    Title = "มองทะลุผู้เล่น (Player ESP)",
    Desc = "แสดงไฮไลท์สีแดงมองทะลุกำแพงสำหรับผู้เล่นทุกคน",
    Value = false,
    Callback = function(Value)
        playSound(SOUND_CLICK)
        playerEspEnabled = Value
        if not Value then
            updatePlayerEsp()
        end
    end
})

VisualsTab:Toggle({
    Title = "มองทะลุ NPC (NPC ESP)",
    Desc = "แสดงไฮไลท์สีเขียวมองทะลุกำแพงสำหรับ NPC ในแมป",
    Value = false,
    Callback = function(Value)
        playSound(SOUND_CLICK)
        npcEspEnabled = Value
        if not Value then
            updateNpcEsp()
        end
    end
})

-- ==================== หมวดหมู่: เครื่องมือ ====================
local ToolsTab = Window:Tab({ Title = "เครื่องมือ", Icon = "wrench" })

ToolsTab:Section({ Title = "ประสิทธิภาพ & อำนวยความสะดวก" })

ToolsTab:Toggle({
    Title = "ลดกราฟิก เพิ่ม FPS",
    Desc = "ปิดเอฟเฟกต์และปรับแมปเป็นพลาสติกเพื่อลื่นขึ้น",
    Value = false,
    Callback = function(Value)
        playSound(SOUND_CLICK)
        fpsBoostEnabled = Value
        applyFpsBoost(Value)
    end
})

ToolsTab:Toggle({
    Title = "หยิบของเร็ว (กด E ทันที)",
    Desc = "ไม่ต้องกด E ค้างไว้ หยิบได้ทันที",
    Value = false,
    Callback = function(Value)
        playSound(SOUND_CLICK)
        fastEEnabled = Value
    end
})

ToolsTab:Section({ Title = "ระบบเซิฟเวอร์ & ต่อสู้" })

ToolsTab:Button({
    Title = "เข้าเซิฟเวอร์คนน้อย",
    Desc = "ค้นหาและวาปไปเซิฟเวอร์ที่มีคนอยู่น้อยที่สุด",
    Callback = function()
        playSound(SOUND_CLICK)
        joinLowServer()
    end
})

ToolsTab:Toggle({
    Title = "ชนผู้เล่นกระเด็น (Touch Fling)",
    Desc = "เดินไปชนผู้เล่นอื่นเพื่อให้กระเด็นไปไกล",
    Value = false,
    Callback = function(Value)
        playSound(SOUND_CLICK)
        flingEnabled = Value
    end
})