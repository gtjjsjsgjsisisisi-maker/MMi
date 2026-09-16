-- =====================================================
-- 1. EuroXChok UI Library (Core System)
-- =====================================================
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local ParentContainer = (gethui and gethui()) or (cloneref and cloneref(CoreGui)) or CoreGui

local EuroXChok = {
    Options = {},
    Flags = {},
    Theme = {
        Background = Color3.fromRGB(18, 18, 22),
        TopBar = Color3.fromRGB(24, 24, 30),
        Section = Color3.fromRGB(28, 28, 36),
        Element = Color3.fromRGB(35, 35, 45),
        Accent = Color3.fromRGB(85, 110, 240),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(160, 160, 175)
    }
}

local function Tween(object, info, properties)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(gui, handle)
    handle = handle or gui
    local dragging = false
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
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

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function EuroXChok:CreateWindow(Settings)
    if type(Settings) == "string" then
        Settings = { Title = Settings }
    end
    Settings = Settings or {}
    local TitleText = Settings.Title or Settings.Name or "EuroXChok UI"

    if ParentContainer:FindFirstChild("EuroXChok_MobileUI") then
        ParentContainer["EuroXChok_MobileUI"]:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EuroXChok_MobileUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = ParentContainer

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "FloatingToggle"
    ToggleBtn.Size = UDim2.fromOffset(48, 48)
    ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    ToggleBtn.BackgroundColor3 = EuroXChok.Theme.TopBar
    ToggleBtn.Text = "EXC"
    ToggleBtn.TextColor3 = EuroXChok.Theme.Accent
    ToggleBtn.TextSize = 14
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Active = true
    ToggleBtn.Parent = ScreenGui

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleBtn

    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = EuroXChok.Theme.Accent
    ToggleStroke.Thickness = 1.5
    ToggleStroke.Parent = ToggleBtn

    MakeDraggable(ToggleBtn)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.fromOffset(350, 260)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -130)
    MainFrame.BackgroundColor3 = EuroXChok.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(45, 45, 55)
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 38)
    TopBar.BackgroundColor3 = EuroXChok.Theme.TopBar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.Text = TitleText
    TitleLabel.TextColor3 = EuroXChok.Theme.Text
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.fromOffset(28, 28)
    CloseBtn.Position = UDim2.new(1, -33, 0.5, -14)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    CloseBtn.BackgroundTransparency = 0.8
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseBtn.TextSize = 12
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TopBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    MakeDraggable(MainFrame, TopBar)

    ToggleBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)

    local TabBar = Instance.new("ScrollingFrame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(1, -16, 0, 30)
    TabBar.Position = UDim2.new(0, 8, 0, 44)
    TabBar.BackgroundTransparency = 1
    TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
    TabBar.ScrollBarThickness = 0
    TabBar.Parent = MainFrame

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 6)
    TabListLayout.Parent = TabBar

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -16, 1, -86)
    ContentContainer.Position = UDim2.new(0, 8, 0, 78)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    local WindowFunctions = {}
    local FirstTab = true

    function WindowFunctions:Tab(TabSettings)
        if type(TabSettings) == "string" then
            TabSettings = { Name = TabSettings }
        end
        TabSettings = TabSettings or {}
        local TabName = TabSettings.Name or "Tab"

        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName .. "Button"
        TabButton.Size = UDim2.new(0, 80, 1, 0)
        TabButton.AutomaticSize = Enum.AutomaticSize.X
        TabButton.BackgroundColor3 = EuroXChok.Theme.Section
        TabButton.Text = "  " .. TabName .. "  "
        TabButton.TextColor3 = EuroXChok.Theme.TextDim
        TabButton.TextSize = 12
        TabButton.Font = Enum.Font.Gotham
        TabButton.Parent = TabBar

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = TabName .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = EuroXChok.Theme.Accent
        TabContent.Visible = false
        TabContent.Parent = ContentContainer

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 8)
        ContentLayout.Parent = TabContent

        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingRight = UDim.new(0, 4)
        ContentPadding.Parent = TabContent

        if FirstTab then
            FirstTab = false
            TabContent.Visible = true
            TabButton.BackgroundColor3 = EuroXChok.Theme.Accent
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, child in ipairs(ContentContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            for _, child in ipairs(TabBar:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = EuroXChok.Theme.Section
                    child.TextColor3 = EuroXChok.Theme.TextDim
                end
            end
            TabContent.Visible = true
            TabButton.BackgroundColor3 = EuroXChok.Theme.Accent
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        local TabFunctions = {}

        function TabFunctions:Section(SectionSettings)
            if type(SectionSettings) == "string" then
                SectionSettings = { Name = SectionSettings }
            end
            SectionSettings = SectionSettings or {}
            local SecName = SectionSettings.Name or "Section"

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = SecName .. "Section"
            SectionFrame.Size = UDim2.new(1, 0, 0, 30)
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.BackgroundColor3 = EuroXChok.Theme.Section
            SectionFrame.Parent = TabContent

            local SecCorner = Instance.new("UICorner")
            SecCorner.CornerRadius = UDim.new(0, 6)
            SecCorner.Parent = SectionFrame

            local SecLayout = Instance.new("UIListLayout")
            SecLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SecLayout.Padding = UDim.new(0, 6)
            SecLayout.Parent = SectionFrame

            local SecPadding = Instance.new("UIPadding")
            SecPadding.PaddingTop = UDim.new(0, 8)
            SecPadding.PaddingBottom = UDim.new(0, 8)
            SecPadding.PaddingLeft = UDim.new(0, 8)
            SecPadding.PaddingRight = UDim.new(0, 8)
            SecPadding.Parent = SectionFrame

            local SecTitle = Instance.new("TextLabel")
            SecTitle.Name = "SecTitle"
            SecTitle.Size = UDim2.new(1, 0, 0, 18)
            SecTitle.Text = SecName
            SecTitle.TextColor3 = EuroXChok.Theme.Accent
            SecTitle.TextSize = 13
            SecTitle.Font = Enum.Font.GothamBold
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left
            SecTitle.BackgroundTransparency = 1
            SecTitle.Parent = SectionFrame

            local SectionFunctions = {}

            function SectionFunctions:Button(Settings, Callback)
                if type(Settings) == "string" then
                    Settings = { Name = Settings, Callback = Callback }
                end
                Settings = Settings or {}
                local BtnName = Settings.Name or "Button"
                local BtnCb = Settings.Callback or function() end

                local Btn = Instance.new("TextButton")
                Btn.Name = BtnName
                Btn.Size = UDim2.new(1, 0, 0, 32)
                Btn.BackgroundColor3 = EuroXChok.Theme.Element
                Btn.Text = BtnName
                Btn.TextColor3 = EuroXChok.Theme.Text
                Btn.TextSize = 12
                Btn.Font = Enum.Font.Gotham
                Btn.Parent = SectionFrame

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 6)
                BtnCorner.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, TweenInfo.new(0.1), {BackgroundColor3 = EuroXChok.Theme.Accent})
                    task.delay(0.1, function()
                        Tween(Btn, TweenInfo.new(0.1), {BackgroundColor3 = EuroXChok.Theme.Element})
                    end)
                    task.spawn(BtnCb)
                end)

                return {
                    SetText = function(_, newText) Btn.Text = newText end
                }
            end

            function SectionFunctions:Toggle(Settings, Flag)
                local ToggleFunctions = { Settings = Settings, Class = "Toggle" }
                if type(Settings) == "string" then
                    Settings = { Name = Settings, Default = false, Callback = Flag }
                end
                Settings = Settings or {}
                local TglName = Settings.Name or "Toggle"
                local Value = Settings.Default or false
                local Callback = Settings.Callback or function() end

                local TglFrame = Instance.new("Frame")
                TglFrame.Name = TglName
                TglFrame.Size = UDim2.new(1, 0, 0, 32)
                TglFrame.BackgroundColor3 = EuroXChok.Theme.Element
                TglFrame.Parent = SectionFrame

                local TglCorner = Instance.new("UICorner")
                TglCorner.CornerRadius = UDim.new(0, 6)
                TglCorner.Parent = TglFrame

                local TglTitle = Instance.new("TextLabel")
                TglTitle.Size = UDim2.new(1, -50, 1, 0)
                TglTitle.Position = UDim2.new(0, 8, 0, 0)
                TglTitle.Text = TglName
                TglTitle.TextColor3 = EuroXChok.Theme.Text
                TglTitle.TextSize = 12
                TglTitle.Font = Enum.Font.Gotham
                TglTitle.TextXAlignment = Enum.TextXAlignment.Left
                TglTitle.BackgroundTransparency = 1
                TglTitle.Parent = TglFrame

                local Switch = Instance.new("Frame")
                Switch.Size = UDim2.fromOffset(36, 18)
                Switch.Position = UDim2.new(1, -44, 0.5, -9)
                Switch.BackgroundColor3 = Value and EuroXChok.Theme.Accent or Color3.fromRGB(50, 50, 60)
                Switch.Parent = TglFrame

                local SwitchCorner = Instance.new("UICorner")
                SwitchCorner.CornerRadius = UDim.new(1, 0)
                SwitchCorner.Parent = Switch

                local Circle = Instance.new("Frame")
                Circle.Size = UDim2.fromOffset(14, 14)
                Circle.Position = Value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Circle.Parent = Switch

                local CircleCorner = Instance.new("UICorner")
                CircleCorner.CornerRadius = UDim.new(1, 0)
                CircleCorner.Parent = Circle

                local ClickBtn = Instance.new("TextButton")
                ClickBtn.Size = UDim2.new(1, 0, 1, 0)
                ClickBtn.BackgroundTransparency = 1
                ClickBtn.Text = ""
                ClickBtn.Parent = TglFrame

                local function UpdateToggle(val)
                    Value = val
                    Tween(Switch, TweenInfo.new(0.2), {
                        BackgroundColor3 = Value and EuroXChok.Theme.Accent or Color3.fromRGB(50, 50, 60)
                    })
                    Tween(Circle, TweenInfo.new(0.2), {
                        Position = Value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                    })
                    task.spawn(function()
                        Callback(Value)
                    end)
                end

                ClickBtn.MouseButton1Click:Connect(function()
                    UpdateToggle(not Value)
                end)

                function ToggleFunctions:SetValue(Val)
                    UpdateToggle(Val)
                end

                if Flag and type(Flag) == "string" then
                    EuroXChok.Options[Flag] = ToggleFunctions
                end

                return ToggleFunctions
            end

            function SectionFunctions:Slider(Settings, Flag)
                local SliderFunctions = { Settings = Settings, Class = "Slider" }
                if type(Settings) == "string" then
                    Settings = { Name = Settings }
                end
                Settings = Settings or {}
                local SldrName = Settings.Name or "Slider"
                local Min = Settings.Min or 0
                local Max = Settings.Max or 100
                local Default = Settings.Default or Min
                local Callback = Settings.Callback or function() end

                local SldrFrame = Instance.new("Frame")
                SldrFrame.Name = SldrName
                SldrFrame.Size = UDim2.new(1, 0, 0, 42)
                SldrFrame.BackgroundColor3 = EuroXChok.Theme.Element
                SldrFrame.Parent = SectionFrame

                local SldrCorner = Instance.new("UICorner")
                SldrCorner.CornerRadius = UDim.new(0, 6)
                SldrCorner.Parent = SldrFrame

                local SldrTitle = Instance.new("TextLabel")
                SldrTitle.Size = UDim2.new(1, -60, 0, 20)
                SldrTitle.Position = UDim2.new(0, 8, 0, 2)
                SldrTitle.Text = SldrName
                SldrTitle.TextColor3 = EuroXChok.Theme.Text
                SldrTitle.TextSize = 12
                SldrTitle.Font = Enum.Font.Gotham
                SldrTitle.TextXAlignment = Enum.TextXAlignment.Left
                SldrTitle.BackgroundTransparency = 1
                SldrTitle.Parent = SldrFrame

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0, 50, 0, 20)
                ValueLabel.Position = UDim2.new(1, -58, 0, 2)
                ValueLabel.Text = tostring(Default)
                ValueLabel.TextColor3 = EuroXChok.Theme.TextDim
                ValueLabel.TextSize = 12
                ValueLabel.Font = Enum.Font.Gotham
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Parent = SldrFrame

                local BarBackground = Instance.new("Frame")
                BarBackground.Size = UDim2.new(1, -16, 0, 8)
                BarBackground.Position = UDim2.new(0, 8, 1, -14)
                BarBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                BarBackground.Parent = SldrFrame

                local BarCorner = Instance.new("UICorner")
                BarCorner.CornerRadius = UDim.new(1, 0)
                BarCorner.Parent = BarBackground

                local Fill = Instance.new("Frame")
                local alpha = math.clamp((Default - Min) / (Max - Min), 0, 1)
                Fill.Size = UDim2.new(alpha, 0, 1, 0)
                Fill.BackgroundColor3 = EuroXChok.Theme.Accent
                Fill.Parent = BarBackground

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = Fill

                local dragging = false

                local function UpdateSlider(input)
                    local pos = input.Position.X
                    local barAbsPos = BarBackground.AbsolutePosition.X
                    local barAbsSize = BarBackground.AbsoluteSize.X
                    local pct = math.clamp((pos - barAbsPos) / barAbsSize, 0, 1)
                    local val = math.floor(Min + (Max - Min) * pct)

                    Fill.Size = UDim2.new(pct, 0, 1, 0)
                    ValueLabel.Text = tostring(val)
                    task.spawn(function()
                        Callback(val)
                    end)
                end

                BarBackground.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)

                BarBackground.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input)
                    end
                end)

                function SliderFunctions:SetValue(Val)
                    local pct = math.clamp((Val - Min) / (Max - Min), 0, 1)
                    Fill.Size = UDim2.new(pct, 0, 1, 0)
                    ValueLabel.Text = tostring(Val)
                    task.spawn(function()
                        Callback(Val)
                    end)
                end

                if Flag and type(Flag) == "string" then
                    EuroXChok.Options[Flag] = SliderFunctions
                end

                return SliderFunctions
            end

            function SectionFunctions:Textbox(Settings, Flag)
                local TextboxFunctions = { Settings = Settings, Class = "Textbox" }
                if type(Settings) == "string" then
                    Settings = { Name = Settings }
                end
                Settings = Settings or {}
                local BoxName = Settings.Name or "Textbox"
                local Placeholder = Settings.Placeholder or "Type here..."
                local Callback = Settings.Callback or function() end

                local BoxFrame = Instance.new("Frame")
                BoxFrame.Name = BoxName
                BoxFrame.Size = UDim2.new(1, 0, 0, 34)
                BoxFrame.BackgroundColor3 = EuroXChok.Theme.Element
                BoxFrame.Parent = SectionFrame

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 6)
                BoxCorner.Parent = BoxFrame

                local BoxTitle = Instance.new("TextLabel")
                BoxTitle.Size = UDim2.new(0.5, -8, 1, 0)
                BoxTitle.Position = UDim2.new(0, 8, 0, 0)
                BoxTitle.Text = BoxName
                BoxTitle.TextColor3 = EuroXChok.Theme.Text
                BoxTitle.TextSize = 12
                BoxTitle.Font = Enum.Font.Gotham
                BoxTitle.TextXAlignment = Enum.TextXAlignment.Left
                BoxTitle.BackgroundTransparency = 1
                BoxTitle.Parent = BoxFrame

                local InputBox = Instance.new("TextBox")
                InputBox.Size = UDim2.new(0.5, -8, 0, 22)
                InputBox.Position = UDim2.new(0.5, 0, 0.5, -11)
                InputBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
                InputBox.Text = Settings.Default or ""
                InputBox.PlaceholderText = Placeholder
                InputBox.TextColor3 = EuroXChok.Theme.Text
                InputBox.PlaceholderColor3 = EuroXChok.Theme.TextDim
                InputBox.TextSize = 11
                InputBox.Font = Enum.Font.Gotham
                InputBox.Parent = BoxFrame

                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 4)
                InputCorner.Parent = InputBox

                InputBox.FocusLost:Connect(function(enterPressed)
                    task.spawn(function()
                        Callback(InputBox.Text, enterPressed)
                    end)
                end)

                function TextboxFunctions:SetValue(Val)
                    InputBox.Text = tostring(Val)
                end

                if Flag and type(Flag) == "string" then
                    EuroXChok.Options[Flag] = TextboxFunctions
                end

                return TextboxFunctions
            end

            function SectionFunctions:Dropdown(Settings, Flag)
                local DropdownFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Dropdown" }
                if type(Settings) == "string" then
                    Settings = { Name = Settings, Options = {} }
                end
                Settings = Settings or {}
                local DropName = Settings.Name or "Dropdown"
                local Options = Settings.Options or {}
                local Selected = Settings.Default or (Options[1] or "Select...")
                local Callback = Settings.Callback or function() end

                local dropdown = Instance.new("Frame")
                dropdown.Name = DropName
                dropdown.AutomaticSize = Enum.AutomaticSize.Y
                dropdown.BackgroundColor3 = EuroXChok.Theme.Element
                dropdown.Size = UDim2.new(1, 0, 0, 36)
                dropdown.Parent = SectionFrame

                local dropCorner = Instance.new("UICorner")
                dropCorner.CornerRadius = UDim.new(0, 6)
                dropCorner.Parent = dropdown

                local dropdownName = Instance.new("TextLabel")
                dropdownName.Name = "DropdownName"
                dropdownName.Text = DropName
                dropdownName.TextColor3 = EuroXChok.Theme.Text
                dropdownName.TextSize = 12
                dropdownName.Font = Enum.Font.Gotham
                dropdownName.TextXAlignment = Enum.TextXAlignment.Left
                dropdownName.Position = UDim2.new(0, 8, 0, 8)
                dropdownName.Size = UDim2.new(0.5, 0, 0, 20)
                dropdownName.BackgroundTransparency = 1
                dropdownName.Parent = dropdown

                local selectedText = Instance.new("TextButton")
                selectedText.Name = "SelectedText"
                selectedText.Text = tostring(Selected)
                selectedText.TextColor3 = EuroXChok.Theme.Accent
                selectedText.TextSize = 11
                selectedText.Font = Enum.Font.GothamBold
                selectedText.Position = UDim2.new(0.5, 0, 0, 6)
                selectedText.Size = UDim2.new(0.5, -8, 0, 24)
                selectedText.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
                selectedText.Parent = dropdown

                local selectedUICorner = Instance.new("UICorner")
                selectedUICorner.CornerRadius = UDim.new(0, 4)
                selectedUICorner.Parent = selectedText

                local optionHolder = Instance.new("Frame")
                optionHolder.Name = "OptionHolder"
                optionHolder.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
                optionHolder.Visible = false
                optionHolder.Size = UDim2.new(1, -16, 0, 0)
                optionHolder.Position = UDim2.new(0, 8, 0, 36)
                optionHolder.AutomaticSize = Enum.AutomaticSize.Y
                optionHolder.Parent = dropdown

                local optionHolderCorner = Instance.new("UICorner")
                optionHolderCorner.CornerRadius = UDim.new(0, 4)
                optionHolderCorner.Parent = optionHolder

                local optionListLayout = Instance.new("UIListLayout")
                optionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                optionListLayout.Padding = UDim.new(0, 2)
                optionListLayout.Parent = optionHolder

                local opened = false

                local function SelectOption(val)
                    Selected = val
                    selectedText.Text = tostring(val)
                    task.spawn(function()
                        Callback(val)
                    end)
                end

                local function RefreshOptions()
                    for _, child in ipairs(optionHolder:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end

                    for _, opt in ipairs(Settings.Options or {}) do
                        local optButton = Instance.new("TextButton")
                        optButton.Name = tostring(opt)
                        optButton.Text = tostring(opt)
                        optButton.TextColor3 = (opt == Selected) and EuroXChok.Theme.Accent or EuroXChok.Theme.TextDim
                        optButton.TextSize = 11
                        optButton.Font = Enum.Font.Gotham
                        optButton.BackgroundTransparency = 1
                        optButton.Size = UDim2.new(1, 0, 0, 24)
                        optButton.Parent = optionHolder

                        optButton.MouseButton1Click:Connect(function()
                            SelectOption(opt)
                            opened = false
                            optionHolder.Visible = false
                        end)
                    end
                end

                selectedText.MouseButton1Click:Connect(function()
                    opened = not opened
                    optionHolder.Visible = opened
                    if opened then
                        RefreshOptions()
                    end
                end)

                function DropdownFunctions:SetValue(Val)
                    SelectOption(Val)
                end

                function DropdownFunctions:SetOptions(NewOptions)
                    Settings.Options = NewOptions
                    RefreshOptions()
                end

                function DropdownFunctions:UpdateName(Name)
                    dropdownName.Text = Name
                end

                function DropdownFunctions:SetVisibility(State)
                    dropdown.Visible = State
                    if not State then
                        optionHolder.Visible = false
                    end
                end

                if Flag and type(Flag) == "string" then
                    EuroXChok.Options[Flag] = DropdownFunctions
                end

                return DropdownFunctions
            end

            return SectionFunctions
        end

        return TabFunctions
    end

    return WindowFunctions
end

-- =====================================================
-- 2. สั่งสร้างหน้าต่างเมนูบนจอ
-- =====================================================
local Window = EuroXChok:CreateWindow("EuroXChok Hub")
local MainTab = Window:Tab("Main")
local MainSection = MainTab:Section("Main Features")

MainSection:Button("Test Button", function()
    print("Button Clicked!")
end)

MainSection:Toggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(Value)
        print("Auto Farm:", Value)
    end
}, "AutoFarmFlag")

MainSection:Slider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
}, "WalkSpeedFlag")

MainSection:Dropdown({
    Name = "Select Weapon",
    Options = {"Sword", "Bow", "Magic"},
    Default = "Sword",
    Callback = function(Value)
        print("Selected:", Value)
    end
}, "WeaponDropdown")