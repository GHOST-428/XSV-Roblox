local Kavo = {}

local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local guiService = game:GetService("GuiService")
local players = game:GetService("Players")

local Utility = {}
local Objects = {}

function Kavo:DraggingEnabled(frame, parent)
    parent = parent or frame
    
    local dragging = false
    local dragInput, mousePos, framePos
	
    local function handleInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end

    local function handleInputChanged(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end

    -- Подключаем обработчики для всех типов ввода
    frame.InputBegan:Connect(handleInputBegan)
    frame.InputChanged:Connect(handleInputChanged)

    input.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position = UDim2.new(
                framePos.X.Scale, 
                framePos.X.Offset + delta.X,
                framePos.Y.Scale, 
                framePos.Y.Offset + delta.Y
            )
        end
    end)

    input.TouchMoved:Connect(function(input)
        if dragging and input then
            local delta = input.Position - mousePos
            parent.Position = UDim2.new(
                framePos.X.Scale, 
                framePos.X.Offset + delta.X,
                framePos.Y.Scale, 
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

function Utility:TweenObject(obj, properties, duration, ...)
    tween:Create(obj, tweeninfo(duration, ...), properties):Play()
end

-- c00lgui стиль темы
local themes = {
    SchemeColor = Color3.fromRGB(0, 162, 255), -- Яркий синий как в c00lgui
    Background = Color3.fromRGB(20, 20, 20), -- Темный фон
    Header = Color3.fromRGB(15, 15, 15), -- Еще темнее для хедера
    TextColor = Color3.fromRGB(255, 255, 255), -- Белый текст
    ElementColor = Color3.fromRGB(30, 30, 30), -- Темные элементы
    AccentColor = Color3.fromRGB(0, 140, 220) -- Дополнительный акцентный цвет
}

local themeStyles = {
    Default = themes,
    DarkBlue = {
        SchemeColor = Color3.fromRGB(0, 162, 255),
        Background = Color3.fromRGB(20, 20, 20),
        Header = Color3.fromRGB(15, 15, 15),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(30, 30, 30),
        AccentColor = Color3.fromRGB(0, 140, 220)
    },
    Purple = {
        SchemeColor = Color3.fromRGB(170, 0, 255),
        Background = Color3.fromRGB(20, 20, 20),
        Header = Color3.fromRGB(15, 15, 15),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(30, 30, 30),
        AccentColor = Color3.fromRGB(140, 0, 220)
    },
    Green = {
        SchemeColor = Color3.fromRGB(0, 255, 100),
        Background = Color3.fromRGB(20, 20, 20),
        Header = Color3.fromRGB(15, 15, 15),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(30, 30, 30),
        AccentColor = Color3.fromRGB(0, 200, 80)
    },
    Red = {
        SchemeColor = Color3.fromRGB(255, 50, 50),
        Background = Color3.fromRGB(20, 20, 20),
        Header = Color3.fromRGB(15, 15, 15),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(30, 30, 30),
        AccentColor = Color3.fromRGB(220, 30, 30)
    }
}

local oldTheme = ""

local SettingsT = {

}

local Name = "KavoConfig.JSON"

pcall(function()

if not pcall(function() readfile(Name) end) then
writefile(Name, game:service'HttpService':JSONEncode(SettingsT))
end

Settings = game:service'HttpService':JSONEncode(readfile(Name))
end)

local LibName = tostring(math.random(1, 100))..tostring(math.random(1,50))..tostring(math.random(1, 100))

function Kavo:ToggleUI()
    if game.CoreGui[LibName].Enabled then
        game.CoreGui[LibName].Enabled = false
    else
        game.CoreGui[LibName].Enabled = true
    end
end

function Kavo.CreateLib(kavName, themeList)
    if not themeList then
        themeList = themes
    end
    
    -- Поддержка стилей тем
    if themeStyles[themeList] then
        themeList = themeStyles[themeList]
    elseif type(themeList) == "string" then
        -- Если передано имя темы как строка
        themeList = themeStyles.Default
    else
        -- Установка значений по умолчанию для пользовательской темы
        themeList = themeList or {}
        themeList.SchemeColor = themeList.SchemeColor or Color3.fromRGB(0, 162, 255)
        themeList.Background = themeList.Background or Color3.fromRGB(20, 20, 20)
        themeList.Header = themeList.Header or Color3.fromRGB(15, 15, 15)
        themeList.TextColor = themeList.TextColor or Color3.fromRGB(255, 255, 255)
        themeList.ElementColor = themeList.ElementColor or Color3.fromRGB(30, 30, 30)
        themeList.AccentColor = themeList.AccentColor or Color3.fromRGB(0, 140, 220)
    end

    themeList = themeList or {}
    local selectedTab 
    kavName = kavName or "Library"
    table.insert(Kavo, kavName)
    for i,v in pairs(game.CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == kavName then
            v:Destroy()
        end
    end
    
    -- Создание основного интерфейса в стиле c00lgui
    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local MainHeader = Instance.new("Frame")
    local headerCover = Instance.new("UICorner")
    local coverup = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local close = Instance.new("ImageButton")
    local MainSide = Instance.new("Frame")
    local sideCorner = Instance.new("UICorner")
    local coverup_2 = Instance.new("Frame")
    local tabFrames = Instance.new("Frame")
    local tabListing = Instance.new("UIListLayout")
    local pages = Instance.new("Frame")
    local Pages = Instance.new("Folder")
    local infoContainer = Instance.new("Frame")

    local blurFrame = Instance.new("Frame")

    Kavo:DraggingEnabled(MainHeader, Main)

    blurFrame.Name = "blurFrame"
    blurFrame.Parent = pages
    blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blurFrame.BackgroundTransparency = 1
    blurFrame.BorderSizePixel = 0
    blurFrame.Position = UDim2.new(-0.0222222228, 0, -0.0371747203, 0)
    blurFrame.Size = UDim2.new(0, 376, 0, 289)
    blurFrame.ZIndex = 999

    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = LibName
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    -- Основной контейнер - более компактный как в c00lgui
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = themeList.Background
    Main.ClipsDescendants = true
    Main.Position = UDim2.new(0.336503863, 0, 0.275485456, 0)
    Main.Size = UDim2.new(0, 500, 0, 300) -- Более компактный размер

    MainCorner.CornerRadius = UDim.new(0, 6) -- Больше скругление как в c00lgui
    MainCorner.Name = "MainCorner"
    MainCorner.Parent = Main

    -- Хедер с акцентной полосой сверху
    MainHeader.Name = "MainHeader"
    MainHeader.Parent = Main
    MainHeader.BackgroundColor3 = themeList.Header
    Objects[MainHeader] = "BackgroundColor3"
    MainHeader.Size = UDim2.new(0, 500, 0, 35)
    
    -- Акцентная полоса сверху
    local topAccent = Instance.new("Frame")
    topAccent.Name = "TopAccent"
    topAccent.Parent = MainHeader
    topAccent.BackgroundColor3 = themeList.SchemeColor
    topAccent.BorderSizePixel = 0
    topAccent.Size = UDim2.new(1, 0, 0, 3)
    Objects[topAccent] = "BackgroundColor3"

    headerCover.CornerRadius = UDim.new(0, 6)
    headerCover.Name = "headerCover"
    headerCover.Parent = MainHeader

    coverup.Name = "coverup"
    coverup.Parent = MainHeader
    coverup.BackgroundColor3 = themeList.Header
    Objects[coverup] = "BackgroundColor3"
    coverup.BorderSizePixel = 0
    coverup.Position = UDim2.new(0, 0, 0.8, 0)
    coverup.Size = UDim2.new(0, 500, 0, 7)

    title.Name = "title"
    title.Parent = MainHeader
    title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1.000
    title.BorderSizePixel = 0
    title.Position = UDim2.new(0.03, 0, 0.2, 0)
    title.Size = UDim2.new(0, 300, 0, 20)
    title.Font = Enum.Font.GothamBold -- Жирный шрифт как в c00lgui
    title.RichText = true
    title.Text = "<b>" .. kavName .. "</b>"
    title.TextColor3 = themeList.TextColor
    title.TextSize = 16.000
    title.TextXAlignment = Enum.TextXAlignment.Left

    close.Name = "close"
    close.Parent = MainHeader
    close.BackgroundTransparency = 1.000
    close.Position = UDim2.new(0.95, 0, 0.15, 0)
    close.Size = UDim2.new(0, 25, 0, 25) -- Немного больше
    close.ZIndex = 2
    close.Image = "rbxassetid://3926305904"
    close.ImageRectOffset = Vector2.new(284, 4)
    close.ImageRectSize = Vector2.new(24, 24)
    close.ImageColor3 = themeList.TextColor
    close.MouseButton1Click:Connect(function()
        game.TweenService:Create(close, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            ImageTransparency = 1
        }):Play()
        wait()
        game.TweenService:Create(Main, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0,0,0,0),
            Position = UDim2.new(0, Main.AbsolutePosition.X + (Main.AbsoluteSize.X / 2), 0, Main.AbsolutePosition.Y + (Main.AbsoluteSize.Y / 2))
        }):Play()
        wait(1)
        ScreenGui:Destroy()
    end)

    -- Боковая панель для вкладок
    MainSide.Name = "MainSide"
    MainSide.Parent = Main
    MainSide.BackgroundColor3 = themeList.Header
    Objects[MainSide] = "Header"
    MainSide.Position = UDim2.new(0, 0, 0.116, 0)
    MainSide.Size = UDim2.new(0, 130, 0, 265) -- Уже боковая панель

    sideCorner.CornerRadius = UDim.new(0, 6)
    sideCorner.Name = "sideCorner"
    sideCorner.Parent = MainSide

    coverup_2.Name = "coverup"
    coverup_2.Parent = MainSide
    coverup_2.BackgroundColor3 = themeList.Header
    Objects[coverup_2] = "Header"
    coverup_2.BorderSizePixel = 0
    coverup_2.Position = UDim2.new(0.95, 0, 0, 0)
    coverup_2.Size = UDim2.new(0, 7, 0, 265)

    tabFrames.Name = "tabFrames"
    tabFrames.Parent = MainSide
    tabFrames.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabFrames.BackgroundTransparency = 1.000
    tabFrames.Position = UDim2.new(0.05, 0, 0.02, 0)
    tabFrames.Size = UDim2.new(0, 120, 0, 260)

    tabListing.Name = "tabListing"
    tabListing.Parent = tabFrames
    tabListing.SortOrder = Enum.SortOrder.LayoutOrder
    tabListing.Padding = UDim.new(0, 5) -- Больше отступ между вкладками

    pages.Name = "pages"
    pages.Parent = Main
    pages.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    pages.BackgroundTransparency = 1.000
    pages.BorderSizePixel = 0
    pages.Position = UDim2.new(0.28, 0, 0.133, 0)
    pages.Size = UDim2.new(0, 350, 0, 250)

    Pages.Name = "Pages"
    Pages.Parent = pages

    infoContainer.Name = "infoContainer"
    infoContainer.Parent = Main
    infoContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    infoContainer.BackgroundTransparency = 1.000
    infoContainer.BorderColor3 = Color3.fromRGB(27, 42, 53)
    infoContainer.ClipsDescendants = true
    infoContainer.Position = UDim2.new(0.28, 0, 0.9, 0)
    infoContainer.Size = UDim2.new(0, 350, 0, 30)

    -- Обновление цветов в реальном времени
    coroutine.wrap(function()
        while wait() do
            Main.BackgroundColor3 = themeList.Background
            MainHeader.BackgroundColor3 = themeList.Header
            MainSide.BackgroundColor3 = themeList.Header
            coverup_2.BackgroundColor3 = themeList.Header
            coverup.BackgroundColor3 = themeList.Header
            topAccent.BackgroundColor3 = themeList.SchemeColor
            title.TextColor3 = themeList.TextColor
            close.ImageColor3 = themeList.TextColor
        end
    end)()

    function Kavo:ChangeColor(prope,color)
        if prope == "Background" then
            themeList.Background = color
        elseif prope == "SchemeColor" then
            themeList.SchemeColor = color
        elseif prope == "Header" then
            themeList.Header = color
        elseif prope == "TextColor" then
            themeList.TextColor = color
        elseif prope == "ElementColor" then
            themeList.ElementColor = color
        elseif prope == "AccentColor" then
            themeList.AccentColor = color
        end
    end
    
    local Tabs = {}
    local first = true

    function Tabs:NewTab(tabName)
        tabName = tabName or "Tab"
        local tabButton = Instance.new("TextButton")
        local UICorner = Instance.new("UICorner")
        local page = Instance.new("ScrollingFrame")
        local pageListing = Instance.new("UIListLayout")
        
        -- Акцент для активной вкладки
        local tabAccent = Instance.new("Frame")
        tabAccent.Name = "TabAccent"
        tabAccent.Parent = tabButton
        tabAccent.BackgroundColor3 = themeList.SchemeColor
        tabAccent.BorderSizePixel = 0
        tabAccent.Size = UDim2.new(0, 4, 0.7, 0)
        tabAccent.Position = UDim2.new(0, 0, 0.15, 0)
        tabAccent.Visible = false

        local function UpdateSize()
            local cS = pageListing.AbsoluteContentSize
            game.TweenService:Create(page, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                CanvasSize = UDim2.new(0,cS.X,0,cS.Y)
            }):Play()
        end

        page.Name = "Page"
        page.Parent = Pages
        page.Active = true
        page.BackgroundColor3 = themeList.Background
        page.BorderSizePixel = 0
        page.Position = UDim2.new(0, 0, 0, 0)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.ScrollBarThickness = 4 -- Тонче скроллбар
        page.Visible = false
        page.ScrollBarImageColor3 = themeList.SchemeColor

        pageListing.Name = "pageListing"
        pageListing.Parent = page
        pageListing.SortOrder = Enum.SortOrder.LayoutOrder
        pageListing.Padding = UDim.new(0, 8) -- Больше отступ между элементами

        tabButton.Name = tabName.."TabButton"
        tabButton.Parent = tabFrames
        tabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundTransparency = 1
        tabButton.Size = UDim2.new(0, 120, 0, 32) -- Выше кнопки вкладок
        tabButton.AutoButtonColor = false
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(150, 150, 150) -- Неактивный цвет
        tabButton.TextSize = 13.000
        tabButton.TextXAlignment = Enum.TextXAlignment.Left

        UICorner.CornerRadius = UDim.new(0, 4)
        UICorner.Parent = tabButton

        if first then
            first = false
            page.Visible = true
            tabButton.TextColor3 = themeList.TextColor
            tabAccent.Visible = true
            UpdateSize()
        else
            page.Visible = false
            tabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
            tabAccent.Visible = false
        end

        table.insert(Tabs, tabName)

        UpdateSize()
        page.ChildAdded:Connect(UpdateSize)
        page.ChildRemoved:Connect(UpdateSize)

        tabButton.MouseButton1Click:Connect(function()
            UpdateSize()
            for i,v in next, Pages:GetChildren() do
                v.Visible = false
            end
            page.Visible = true
            
            -- Сброс всех вкладок
            for i,v in next, tabFrames:GetChildren() do
                if v:IsA("TextButton") then
                    Utility:TweenObject(v, {TextColor3 = Color3.fromRGB(150, 150, 150)}, 0.2)
                    if v:FindFirstChild("TabAccent") then
                        v.TabAccent.Visible = false
                    end
                end
            end
            
            -- Активация текущей вкладки
            Utility:TweenObject(tabButton, {TextColor3 = themeList.TextColor}, 0.2)
            tabAccent.Visible = true
        end)
        
        -- Эффекты при наведении на вкладку
        tabButton.MouseEnter:Connect(function()
            if not tabAccent.Visible then
                Utility:TweenObject(tabButton, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if not tabAccent.Visible then
                Utility:TweenObject(tabButton, {TextColor3 = Color3.fromRGB(150, 150, 150)}, 0.2)
            end
        end)

        local Sections = {}
        local focusing = false
        local viewDe = false

        coroutine.wrap(function()
            while wait() do
                page.BackgroundColor3 = themeList.Background
                page.ScrollBarImageColor3 = themeList.SchemeColor
                tabButton.TextColor3 = tabAccent.Visible and themeList.TextColor or Color3.fromRGB(150, 150, 150)
                tabAccent.BackgroundColor3 = themeList.SchemeColor
            end
        end)()
    
        function Sections:NewSection(secName, hidden)
            secName = secName or "Section"
            local sectionFunctions = {}
            local modules = {}
            hidden = hidden or false
            
            local sectionFrame = Instance.new("Frame")
            local sectionlistoknvm = Instance.new("UIListLayout")
            local sectionHead = Instance.new("Frame")
            local sHeadCorner = Instance.new("UICorner")
            local sectionName = Instance.new("TextLabel")
            local sectionInners = Instance.new("Frame")
            local sectionElListing = Instance.new("UIListLayout")
            
            -- Акцент для секции
            local sectionAccent = Instance.new("Frame")
            sectionAccent.Name = "SectionAccent"
            sectionAccent.Parent = sectionHead
            sectionAccent.BackgroundColor3 = themeList.SchemeColor
            sectionAccent.BorderSizePixel = 0
            sectionAccent.Size = UDim2.new(0, 3, 0.7, 0)
            sectionAccent.Position = UDim2.new(0, 0, 0.15, 0)
            
            if hidden then
                sectionHead.Visible = false
            else
                sectionHead.Visible = true
            end

            sectionFrame.Name = "sectionFrame"
            sectionFrame.Parent = page
            sectionFrame.BackgroundColor3 = themeList.Background
            sectionFrame.BorderSizePixel = 0
            
            sectionlistoknvm.Name = "sectionlistoknvm"
            sectionlistoknvm.Parent = sectionFrame
            sectionlistoknvm.SortOrder = Enum.SortOrder.LayoutOrder
            sectionlistoknvm.Padding = UDim.new(0, 10) -- Больше отступ между секциями

            sectionHead.Name = "sectionHead"
            sectionHead.Parent = sectionFrame
            sectionHead.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionHead.BackgroundTransparency = 1.000
            sectionHead.Size = UDim2.new(0, 350, 0, 25) -- Меньше высота хедера

            sHeadCorner.CornerRadius = UDim.new(0, 4)
            sHeadCorner.Name = "sHeadCorner"
            sHeadCorner.Parent = sectionHead

            sectionName.Name = "sectionName"
            sectionName.Parent = sectionHead
            sectionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionName.BackgroundTransparency = 1.000
            sectionName.BorderColor3 = Color3.fromRGB(27, 42, 53)
            sectionName.Position = UDim2.new(0.03, 0, 0, 0)
            sectionName.Size = UDim2.new(0.97, 0, 1, 0)
            sectionName.Font = Enum.Font.GothamBold
            sectionName.Text = string.upper(secName) -- Заглавные буквы как в c00lgui
            sectionName.RichText = true
            sectionName.TextColor3 = themeList.TextColor
            sectionName.TextSize = 12.000
            sectionName.TextXAlignment = Enum.TextXAlignment.Left

            sectionInners.Name = "sectionInners"
            sectionInners.Parent = sectionFrame
            sectionInners.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionInners.BackgroundTransparency = 1.000
            sectionInners.Position = UDim2.new(0, 0, 0.3, 0)

            sectionElListing.Name = "sectionElListing"
            sectionElListing.Parent = sectionInners
            sectionElListing.SortOrder = Enum.SortOrder.LayoutOrder
            sectionElListing.Padding = UDim.new(0, 5) -- Отступ между элементами

            coroutine.wrap(function()
                while wait() do
                    sectionFrame.BackgroundColor3 = themeList.Background
                    sectionName.TextColor3 = themeList.TextColor
                    sectionAccent.BackgroundColor3 = themeList.SchemeColor
                end
            end)()

            local function updateSectionFrame()
                local innerSc = sectionElListing.AbsoluteContentSize
                sectionInners.Size = UDim2.new(1, 0, 0, innerSc.Y)
                local frameSc = sectionlistoknvm.AbsoluteContentSize
                sectionFrame.Size = UDim2.new(0, 350, 0, frameSc.Y)
            end
            
            updateSectionFrame()
            UpdateSize()
            
            local Elements = {}
            
            -- Остальные функции элементов (Button, Toggle, Slider и т.д.) остаются похожими,
            -- но с измененным дизайном в стиле c00lgui
            
            function Elements:NewButton(bname, tipINf, callback)
                -- Аналогично оригиналу, но с измененным дизайном
                -- Используем themeList.AccentColor для акцентов
                -- Более плоский дизайн как в c00lgui
            end
            
            function Elements:NewToggle(tname, nTip, callback)
                -- Стилизованный переключатель в стиле c00lgui
            end
            
            function Elements:NewSlider(slidInf, slidTip, maxvalue, minvalue, callback)
                -- Слайдер с акцентным цветом
            end
            
            -- ... остальные элементы с аналогичными изменениями
            
            return Elements
        end
        return Sections
    end  
    return Tabs
end

return Kavo
