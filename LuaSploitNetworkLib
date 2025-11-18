--[[
    ----------------------------------------------------
            LuaSploitNetwork UI Library (LSN)
           Mixed Naming: Main = LuaSploitNetwork
                     Prefix = LSN_
    ----------------------------------------------------
]]

local LuaSploitNetwork = {}

-- === THEME ===
LuaSploitNetwork.Theme = {
    Background = Color3.fromRGB(20,20,20),
    TabBackground = Color3.fromRGB(15,15,15),
    Element = Color3.fromRGB(40,40,40),
    Accent = Color3.fromRGB(80,120,255),
    Text = Color3.new(1,1,1)
}

-- === ANIMATION HELPER ===
local function LSN_Tween(obj, info, props)
    game.TweenService:Create(obj, TweenInfo.new(info.Time or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play()
end

-- === NOTIFICATIONS ===
function LuaSploitNetwork:Notify(title, message, time)
    time = time or 3

    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "LSN_Notification_" .. math.random(1,9999)
    gui.ResetOnSpawn = false

    local box = Instance.new("Frame", gui)
    box.Size = UDim2.fromOffset(260, 80)
    box.Position = UDim2.new(1, -280, 1, -120)
    box.BackgroundColor3 = LuaSploitNetwork.Theme.Background
    box.BorderSizePixel = 0

    local titleLabel = Instance.new("TextLabel", box)
    titleLabel.Size = UDim2.new(1, -10, 0, 25)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = LuaSploitNetwork.Theme.Accent
    titleLabel.TextSize = 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local msgLabel = Instance.new("TextLabel", box)
    msgLabel.Size = UDim2.new(1, -10, 0, 40)
    msgLabel.Position = UDim2.new(0, 5, 0, 30)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = LuaSploitNetwork.Theme.Text
    msgLabel.TextSize = 16
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left

    LSN_Tween(box, {Time=0.25}, {Position = UDim2.new(1, -280, 1, -160)})
    task.wait(time)
    LSN_Tween(box, {Time=0.25}, {Position = UDim2.new(1, 50, 1, -160)})
    task.wait(0.3)
    gui:Destroy()
end

-- === WINDOW CREATION ===
function LuaSploitNetwork:CreateWindow(settings)
    local title = settings.Title or "LuaSploitNetwork"
    local size = UDim2.fromOffset(500, 350)

    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "LSN_MainUI"
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame", gui)
    main.Size = size
    main.Position = UDim2.new(0.5, -250, 0.5, -175)
    main.BackgroundColor3 = LuaSploitNetwork.Theme.Background
    main.Active = true
    main.Draggable = true
    main.Name = "LSN_Window"

    local titlebar = Instance.new("TextLabel", main)
    titlebar.Size = UDim2.new(1, 0, 0, 40)
    titlebar.BackgroundColor3 = LuaSploitNetwork.Theme.TabBackground
    titlebar.Text = title
    titlebar.TextColor3 = LuaSploitNetwork.Theme.Text
    titlebar.TextSize = 22

    local tabHolder = Instance.new("Frame", main)
    tabHolder.Size = UDim2.new(0, 120, 1, -40)
    tabHolder.Position = UDim2.new(0, 0, 0, 40)
    tabHolder.BackgroundColor3 = LuaSploitNetwork.Theme.TabBackground
    tabHolder.Name = "LSN_TabHolder"

    local pageHolder = Instance.new("Frame", main)
    pageHolder.Size = UDim2.new(1, -120, 1, -40)
    pageHolder.Position = UDim2.new(0, 120, 0, 40)
    pageHolder.BackgroundColor3 = LuaSploitNetwork.Theme.Background
    pageHolder.Name = "LSN_PageHolder"

    LuaSploitNetwork.Main = main
    LuaSploitNetwork.TabHolder = tabHolder
    LuaSploitNetwork.PageHolder = pageHolder

    return LuaSploitNetwork
end

-- === TAB CREATION ===
function LuaSploitNetwork:AddTab(text)
    local btn = Instance.new("TextButton", LuaSploitNetwork.TabHolder)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, (#LuaSploitNetwork.TabHolder:GetChildren()-1)*40)
    btn.BackgroundColor3 = LuaSploitNetwork.Theme.Element
    btn.Text = text
    btn.TextColor3 = LuaSploitNetwork.Theme.Text
    btn.Name = "LSN_Tab"

    local page = Instance.new("ScrollingFrame", LuaSploitNetwork.PageHolder)
    page.Visible = false
    page.Size = UDim2.new(1,0,1,0)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.BackgroundTransparency = 1
    page.Name = "LSN_Page"

    btn.MouseButton1Click:Connect(function()
        for _, c in pairs(LuaSploitNetwork.PageHolder:GetChildren()) do
            if c:IsA("ScrollingFrame") then c.Visible = false end
        end
        LSN_Tween(btn, {Time=0.2}, {BackgroundColor3 = LuaSploitNetwork.Theme.Accent})
        page.Visible = true
    end)

    return page
end

-- === BUTTON ELEMENT ===
function LuaSploitNetwork:AddButton(page, info)
    local btn = Instance.new("TextButton", page)
    btn.Size = UDim2.fromOffset(200, 35)
    btn.Position = UDim2.new(0, 10, 0, (#page:GetChildren()-1)*40)
    btn.BackgroundColor3 = LuaSploitNetwork.Theme.Element
    btn.Text = info.Name
    btn.TextColor3 = LuaSploitNetwork.Theme.Text
    btn.Name = "LSN_Button"

    page.CanvasSize = UDim2.new(0,0,0,#page:GetChildren()*40)

    btn.MouseButton1Click:Connect(function()
        LSN_Tween(btn, {Time=0.1}, {BackgroundColor3 = LuaSploitNetwork.Theme.Accent})
        task.wait(0.1)
        LSN_Tween(btn, {Time=0.1}, {BackgroundColor3 = LuaSploitNetwork.Theme.Element})
        info.Callback()
    end)
end

-- === TOGGLE ELEMENT ===
function LuaSploitNetwork:AddToggle(page, info)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.fromOffset(200, 35)
    frame.Position = UDim2.new(0, 10, 0, (#page:GetChildren()-1)*40)
    frame.BackgroundColor3 = LuaSploitNetwork.Theme.Element
    frame.Name = "LSN_ToggleFrame"

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Text = info.Name
    label.BackgroundTransparency = 1
    label.TextColor3 = LuaSploitNetwork.Theme.Text

    local toggle = Instance.new("Frame", frame)
    toggle.Size = UDim2.fromOffset(30, 30)
    toggle.Position = UDim2.new(1, -35, 0.5, -15)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggle.Name = "LSN_Toggle"

    local on = false

    toggle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            on = not on
            LSN_Tween(toggle, {Time=0.2}, {BackgroundColor3 = on and LuaSploitNetwork.Theme.Accent or Color3.fromRGB(60,60,60)})
            info.Callback(on)
        end
    end)
end

-- === SLIDER ELEMENT ===
function LuaSploitNetwork:AddSlider(page, info)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.fromOffset(220, 45)
    frame.Position = UDim2.new(0, 10, 0, (#page:GetChildren()-1)*50)
    frame.BackgroundColor3 = LuaSploitNetwork.Theme.Element
    frame.Name = "LSN_SliderFrame"

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,0,20)
    label.BackgroundTransparency = 1
    label.TextColor3 = LuaSploitNetwork.Theme.Text
    label.Text = info.Name

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, -20, 0, 8)
    bar.Position = UDim2.new(0, 10, 0, 28)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = LuaSploitNetwork.Theme.Accent

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local move
            move = game.UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(rel,0,1,0)

                    local value = math.floor(info.Min + ((info.Max - info.Min) * rel))
                    info.Callback(value)
                    label.Text = info.Name.." - "..value
                end
            end)

            game.UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if move then move:Disconnect() end
                end
            end)
        end
    end)
end

-- === DROPDOWN ELEMENT ===
function LuaSploitNetwork:AddDropdown(page, info)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.fromOffset(200, 35)
    frame.Position = UDim2.new(0, 10, 0, (#page:GetChildren()-1)*40)
    frame.BackgroundColor3 = LuaSploitNetwork.Theme.Element
    frame.Name = "LSN_DropdownFrame"

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = info.Name .. ": " .. (info.Default or "")
    label.TextColor3 = LuaSploitNetwork.Theme.Text

    local dropdown = Instance.new("Frame", frame)
    dropdown.Size = UDim2.new(1,0,0,0)
    dropdown.Position = UDim2.new(0,0,1,0)
    dropdown.BackgroundColor3 = LuaSploitNetwork.Theme.TabBackground
    dropdown.Visible = false
    dropdown.Name = "LSN_Dropdown"

    local open = false

    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            open = not open
            dropdown.Visible = open
        end
    end)

    for i,v in ipairs(info.Options) do
        local opt = Instance.new("TextButton", dropdown)
        opt.Size = UDim2.new(1,0,0,25)
        opt.Position = UDim2.new(0,0,0,(i-1)*25)
        opt.BackgroundColor3 = Color3.fromRGB(40,40,40)
        opt.TextColor3 = LuaSploitNetwork.Theme.Text
        opt.Text = v
        opt.Name = "LSN_Option"

        opt.MouseButton1Click:Connect(function()
            label.Text = info.Name..": "..v
            dropdown.Visible = false
            open = false
            info.Callback(v)
        end)
    end
end

return LuaSploitNetwork
