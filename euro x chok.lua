-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local CorrectKey = "euro x chok"
local InstagramLink = "https://www.instagram.com/your_instagram_username" -- 🔴 ใส่ลิงก์ IG ของคุณตรงนี้

-- Target Parent Gui for Delta / Arceus / Hydrogen / Codex Executors
local ParentGui = (gethui and gethui()) or CoreGui

-- Cleanup Old UI
if ParentGui:FindFirstChild("EuroXChokMM2_V7") then
    ParentGui.EuroXChokMM2_V7:Destroy()
end

-- Custom Smooth Draggable System (แก้ไขปัญหา UI เลื่อนไม่ได้บนมือถือ)
local function makeDraggable(gui)
    local dragging = false
    local dragInput, dragStart, startPos

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Sound Effect (Ting Sound)
local TingSound = Instance.new("Sound")
TingSound.SoundId = "rbxassetid://6895079853"
TingSound.Volume = 1.5
TingSound.Parent = SoundService

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EuroXChokMM2_V7"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

---------------------------------------------------------
-- MM2 CORE LOGIC & INSTANT SHOOT SYSTEM (แก้ไขปืนยิงออกทันที)
---------------------------------------------------------
local EspEnabled = false
local GunEspEnabled = false
local NoclipEnabled = false

local function getRoles()
    local murderer, sheriff = nil, nil
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                murderer = p
            elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                sheriff = p
            end
        end
    end
    return murderer, sheriff
end

-- Instant Shoot Function
local function shootMurdererTarget()
    local murderer, _ = getRoles()
    if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") or not myChar:FindFirstChildOfClass("Humanoid") then 
        return 
    end
    
    local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or myChar:FindFirstChild("Gun")
    if not gun then 
        return 
    end

    -- 1. สวมปืนเข้ามือทันทีแบบไม่รอ Delay
    if gun.Parent ~= myChar then
        gun.Parent = myChar
    end
    
    -- 2. คำนวณตำแหน่งยิงนำหน้า
    local targetHRP = murderer.Character.HumanoidRootPart
    local vel = targetHRP.AssemblyLinearVelocity or targetHRP.Velocity or Vector3.new(0,0,0)
    local predictedPos = targetHRP.Position + (vel * 0.12)
    local myPos = myChar.HumanoidRootPart.Position

    -- 3. หันตัวผู้เล่นไปหาเป้าหมาย
    myChar.HumanoidRootPart.CFrame = CFrame.new(myPos, Vector3.new(predictedPos.X, myPos.Y, predictedPos.Z))

    -- 4. ส่งสัญญาณสั่งยิงกระสุนออกทันที (Direct Fire Remote & Activate)
    local shootCFrame = CFrame.new(myPos, predictedPos)
    local shootRemote = gun:FindFirstChild("Shoot") or gun:FindFirstChildWhichIsA("RemoteEvent", true)
    
    if shootRemote then
        shootRemote:FireServer(shootCFrame)
    end

    -- สั่งลั่นไกซ้ำให้ตัวปืนปล่อยกระสุน
    pcall(function()
        gun:Activate()
    end)
end

-- Render Loops
RunService.RenderStepped:Connect(function()
    if EspEnabled then
        local murderer, sheriff = getRoles()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local highlight = p.Character:FindFirstChild("RoleHighlight")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "RoleHighlight"
                    highlight.Parent = p.Character
                end
                
                if p == murderer then
                    highlight.FillColor = Color3.fromRGB(255, 40, 40)
                elseif p == sheriff then
                    highlight.FillColor = Color3.fromRGB(40, 120, 255)
                else
                    highlight.FillColor = Color3.fromRGB(40, 255, 100)
                end
                highlight.Enabled = true
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("RoleHighlight") then
                p.Character.RoleHighlight:Destroy()
            end
        end
    end

    -- Gun ESP
    local gunDrop = Workspace:FindFirstChild("GunDrop", true)
    if gunDrop then
        local highlight = gunDrop:FindFirstChild("GunHighlight")
        if GunEspEnabled then
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "GunHighlight"
                highlight.FillColor = Color3.fromRGB(255, 230, 0)
                highlight.Parent = gunDrop
            end
            highlight.Enabled = true
        elseif highlight then
            highlight:Destroy()
        end
    end

    -- Noclip Loop
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

---------------------------------------------------------
-- 1. FLOATING SHOOT BUTTON
---------------------------------------------------------
local FloatingShootBtn = Instance.new("TextButton")
FloatingShootBtn.Name = "FloatingShootBtn"
FloatingShootBtn.Size = UDim2.new(0, 70, 0, 70)
FloatingShootBtn.Position = UDim2.new(0.85, -35, 0.45, -35)
FloatingShootBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
FloatingShootBtn.BackgroundTransparency = 0
FloatingShootBtn.Text = "🎯\nSHOOT"
FloatingShootBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
FloatingShootBtn.TextSize = 13
FloatingShootBtn.Font = Enum.Font.GothamBold
FloatingShootBtn.Active = true
FloatingShootBtn.Visible = false
FloatingShootBtn.Parent = ScreenGui

Instance.new("UICorner", FloatingShootBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingShootBtn)
FloatStroke.Color = Color3.fromRGB(255, 40, 40)
FloatStroke.Thickness = 2.5

makeDraggable(FloatingShootBtn)

FloatingShootBtn.MouseButton1Click:Connect(function()
    shootMurdererTarget()
end)

---------------------------------------------------------
-- 2. DARK SOLID KEY SYSTEM UI (LEAN & DRAGGABLE)
---------------------------------------------------------
local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Size = UDim2.new(0, 350, 0, 265)
KeyFrame.Position = UDim2.new(0.5, -175, 0.5, -132)
KeyFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12) -- โทนดำมืดทึบ 100%
KeyFrame.BackgroundTransparency = 0
KeyFrame.Active = true
KeyFrame.Parent = ScreenGui

Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 14)
local KeyStroke = Instance.new("UIStroke", KeyFrame)
KeyStroke.Color = Color3.fromRGB(230, 30, 60)
KeyStroke.Thickness = 2

makeDraggable(KeyFrame) -- ทำให้หน้าคีย์เลื่อนได้แน่นอน

-- Title
local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 28)
KeyTitle.Position = UDim2.new(0, 0, 0, 12)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "🔑 KEY SYSTEM"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 18
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Parent = KeyFrame

-- Subtitle Credit
local KeySubTitle = Instance.new("TextLabel")
KeySubTitle.Size = UDim2.new(1, 0, 0, 16)
KeySubTitle.Position = UDim2.new(0, 0, 0, 38)
KeySubTitle.BackgroundTransparency = 1
KeySubTitle.Text = "by euro x chok"
KeySubTitle.TextColor3 = Color3.fromRGB(230, 30, 60)
KeySubTitle.TextSize = 12
KeySubTitle.Font = Enum.Font.GothamBold
KeySubTitle.Parent = KeyFrame

-- Input Box Dark Solid
local KeyInputFrame = Instance.new("Frame")
KeyInputFrame.Size = UDim2.new(0.85, 0, 0, 38)
KeyInputFrame.Position = UDim2.new(0.075, 0, 0.28, 0)
KeyInputFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
KeyInputFrame.BackgroundTransparency = 0
KeyInputFrame.Parent = KeyFrame
Instance.new("UICorner", KeyInputFrame).CornerRadius = UDim.new(0, 8)

local KeyInputStroke = Instance.new("UIStroke", KeyInputFrame)
KeyInputStroke.Color = Color3.fromRGB(45, 45, 55)
KeyInputStroke.Thickness = 1.5

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -20, 1, 0)
KeyInput.Position = UDim2.new(0, 10, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.PlaceholderText = "Enter Key..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 13
KeyInput.Font = Enum.Font.GothamMedium
KeyInput.Parent = KeyInputFrame

-- Submit Button
local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.85, 0, 0, 38)
SubmitBtn.Position = UDim2.new(0.075, 0, 0.47, 0)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(230, 30, 60)
SubmitBtn.BackgroundTransparency = 0
SubmitBtn.Text = "VERIFY KEY"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 12
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.Parent = KeyFrame
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 8)

-- 📸 Instagram Get Key Button
local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.85, 0, 0, 38)
GetKeyBtn.Position = UDim2.new(0.075, 0, 0.72, 0)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
GetKeyBtn.BackgroundTransparency = 0
GetKeyBtn.Text = "📸 GET KEY ON INSTAGRAM"
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 180, 200)
GetKeyBtn.TextSize = 11
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.Parent = KeyFrame
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 8)

local GetKeyStroke = Instance.new("UIStroke", GetKeyBtn)
GetKeyStroke.Color = Color3.fromRGB(180, 50, 120)
GetKeyStroke.Thickness = 1.5

---------------------------------------------------------
-- 3. MAIN HUB UI (DARK SOLID THEME)
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 270)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MainFrame.BackgroundTransparency = 0
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(230, 30, 60)
MainStroke.Thickness = 1.5

makeDraggable(MainFrame)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(0, 250, 1, 0)
HubTitle.Position = UDim2.new(0, 15, 0, 0)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "EURO X CHOK • MM2"
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 15
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 110, 1, -50)
Sidebar.Position = UDim2.new(0, 10, 0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
Sidebar.BackgroundTransparency = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 5)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -140, 1, -50)
ContentContainer.Position = UDim2.new(0, 130, 0, 42)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local TabFrames = {}

local function CreateTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.9, 0, 0, 32)
    tabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    tabBtn.BackgroundTransparency = 0
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(150, 150, 165)
    tabBtn.TextSize = 11
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.Parent = Sidebar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.Visible = false
    page.Parent = ContentContainer
    
    local grid = Instance.new("UIGridLayout", page)
    grid.CellSize = UDim2.new(0, 155, 0, 42)
    grid.CellPadding = UDim2.new(0, 8, 0, 8)
    
    TabFrames[name] = {Btn = tabBtn, Page = page}
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(TabFrames) do
            tab.Page.Visible = false
            tab.Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
            tab.Btn.TextColor3 = Color3.fromRGB(150, 150, 165)
        end
        page.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(230, 30, 60)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    return page
end

-- Create Tabs
local VisualsPage = CreateTab("👁️ Visuals")
local MovementPage = CreateTab("⚡ Movement")
local CombatPage = CreateTab("⚔️ Combat")

TabFrames["👁️ Visuals"].Page.Visible = true
TabFrames["👁️ Visuals"].Btn.BackgroundColor3 = Color3.fromRGB(230, 30, 60)
TabFrames["👁️ Visuals"].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

local function AddFeatureButton(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    btn.BackgroundTransparency = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = page
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(45, 45, 55)
    stroke.Thickness = 1
    
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    return btn
end

---------------------------------------------------------
-- FEATURES SETUP
---------------------------------------------------------
-- Visuals
AddFeatureButton(VisualsPage, "ESP (Players)", function(btn)
    EspEnabled = not EspEnabled
    btn.BackgroundColor3 = EspEnabled and Color3.fromRGB(230, 30, 60) or Color3.fromRGB(18, 18, 24)
end)

AddFeatureButton(VisualsPage, "ESP (Gun)", function(btn)
    GunEspEnabled = not GunEspEnabled
    btn.BackgroundColor3 = GunEspEnabled and Color3.fromRGB(230, 30, 60) or Color3.fromRGB(18, 18, 24)
end)

-- Movement
AddFeatureButton(MovementPage, "Noclip (ทะลุกำแพง)", function(btn)
    NoclipEnabled = not NoclipEnabled
    btn.BackgroundColor3 = NoclipEnabled and Color3.fromRGB(230, 30, 60) or Color3.fromRGB(18, 18, 24)
end)

AddFeatureButton(MovementPage, "TP To Gun (วาปเก็บปืน)", function()
    local gunDrop = Workspace:FindFirstChild("GunDrop", true)
    if gunDrop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = gunDrop.CFrame + Vector3.new(0, 2, 0)
    end
end)

AddFeatureButton(MovementPage, "TP To Sheriff (วาปหานายอำเภอ)", function()
    local _, sheriff = getRoles()
    if sheriff and sheriff.Character and sheriff.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = sheriff.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 3)
    end
end)

-- Combat
AddFeatureButton(CombatPage, "Toggle Shoot Button\n(เปิด/ปิด ปุ่มลอยยิง)", function(btn)
    FloatingShootBtn.Visible = not FloatingShootBtn.Visible
    btn.BackgroundColor3 = FloatingShootBtn.Visible and Color3.fromRGB(230, 30, 60) or Color3.fromRGB(18, 18, 24)
end)

AddFeatureButton(CombatPage, "Instant Shoot Murderer\n(กดเพื่อยิงทันที)", function()
    shootMurdererTarget()
end)

AddFeatureButton(CombatPage, "Bring All\n(ดึงคนมาฆ่า - ฆาตกร)", function()
    local murderer, _ = getRoles()
    if murderer == LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, -2)
            end
        end
    end
end)

---------------------------------------------------------
-- 4. BOTTOM USER PROFILE BAR
---------------------------------------------------------
local UserBar = Instance.new("Frame")
UserBar.Name = "UserBar"
UserBar.Size = UDim2.new(0, 240, 0, 50)
UserBar.Position = UDim2.new(0.5, -120, 1, -65)
UserBar.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
UserBar.BackgroundTransparency = 0
UserBar.Active = true
UserBar.Visible = false
UserBar.Parent = ScreenGui

Instance.new("UICorner", UserBar).CornerRadius = UDim.new(0, 25)
local UserStroke = Instance.new("UIStroke", UserBar)
UserStroke.Color = Color3.fromRGB(230, 30, 60)
UserStroke.Thickness = 1.5

makeDraggable(UserBar)

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(0, 38, 0, 38)
AvatarImg.Position = UDim2.new(0, 6, 0.5, -19)
AvatarImg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
AvatarImg.Parent = UserBar
Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    local content = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    AvatarImg.Image = content
end)

local UserNameLabel = Instance.new("TextLabel")
UserNameLabel.Size = UDim2.new(0, 110, 0, 18)
UserNameLabel.Position = UDim2.new(0, 50, 0, 8)
UserNameLabel.BackgroundTransparency = 1
UserNameLabel.Text = LocalPlayer.Name
UserNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UserNameLabel.TextSize = 12
UserNameLabel.Font = Enum.Font.GothamBold
UserNameLabel.TextXAlignment = Enum.TextXAlignment.Left
UserNameLabel.Parent = UserBar

local UserStatusLabel = Instance.new("TextLabel")
UserStatusLabel.Size = UDim2.new(0, 110, 0, 14)
UserStatusLabel.Position = UDim2.new(0, 50, 0, 26)
UserStatusLabel.BackgroundTransparency = 1
UserStatusLabel.Text = "● Active"
UserStatusLabel.TextColor3 = Color3.fromRGB(230, 30, 60)
UserStatusLabel.TextSize = 10
UserStatusLabel.Font = Enum.Font.Gotham
UserStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
UserStatusLabel.Parent = UserBar

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 65, 0, 28)
OpenBtn.Position = UDim2.new(1, -72, 0.5, -14)
OpenBtn.BackgroundColor3 = Color3.fromRGB(230, 30, 60)
OpenBtn.Text = "OPEN"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 11
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Parent = UserBar
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 14)

---------------------------------------------------------
-- LOGIC & EVENTS
---------------------------------------------------------
SubmitBtn.MouseButton1Click:Connect(function()
    if string.lower(KeyInput.Text) == string.lower(CorrectKey) then
        TingSound:Play()
        KeyFrame.Visible = false
        MainFrame.Visible = true
    else
        SubmitBtn.Text = "INVALID KEY!"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
        task.wait(1.5)
        SubmitBtn.Text = "VERIFY KEY"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(230, 30, 60)
    end
end)

GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(InstagramLink)
    end
    GetKeyBtn.Text = "📋 COPIED IG LINK!"
    GetKeyBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    task.wait(2)
    GetKeyBtn.Text = "📸 GET KEY ON INSTAGRAM"
    GetKeyBtn.TextColor3 = Color3.fromRGB(255, 180, 200)
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    UserBar.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    UserBar.Visible = false
    MainFrame.Visible = true
end)