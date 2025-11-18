-- RayfieldLite.lua
-- A clean, modular UI library inspired by Rayfield/Sirius layouts.
-- Features implemented: Core Window System, Buttons, Toggles, Sliders,
-- Dropdowns, Color Picker, Keybinds, Textboxes, Notifications, Script Hub,
-- Tabs, Theme Manager, Mobile support and animations.
-- NOTE: This is a single-file reference implementation. Some features (custom fonts via asset id,
-- auto http loading) depend on runtime environment permissions.

local RayfieldLite = {}
RayfieldLite.__index = RayfieldLite

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
autoScale = true

-- Default config
local DEFAULT_THEME = {
    Name = "Dark",
    Background = Color3.fromRGB(22, 22, 22),
    Window = Color3.fromRGB(28, 28, 28),
    Accent = Color3.fromRGB(98, 0, 238),
    Text = Color3.fromRGB(235, 235, 235),
    SubText = Color3.fromRGB(180,180,180)
}

-- Utility functions
local function tween(obj, props, info)
    info = info or TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function create(class, props)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k == "Parent" then
                inst.Parent = v
            else
                inst[k] = v
            end
        end
    end
    return inst
end

local function clamp(v, a, b) return math.max(a, math.min(b, v)) end

-- Root GUI
function RayfieldLite.new(opts)
    opts = opts or {}
    local self = setmetatable({}, RayfieldLite)

    self._theme = opts.Theme or DEFAULT_THEME
    self._windows = {}
    self._notifications = {}
    self._fonts = opts.Fonts or {}
    self._allowMultiWindow = opts.MultiWindow or true

    -- Build ScreenGui
    local screenGui = create("ScreenGui", {Parent = CoreGui, Name = opts.Name or "RayfieldLiteUI", ResetOnSpawn = false})
    if not (screenGui:IsDescendantOf(game)) then
        -- fallback to PlayerGui
        screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    end

    self.gui = screenGui

    -- Notification container
    local notifFrame = create("Frame", {
        Name = "Notifications",
        Parent = screenGui,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 10),
        Size = UDim2.new(0, 300, 0, 200),
        BackgroundTransparency = 1,
    })
    self._notifFrame = notifFrame

    return self
end

-- Theme manager
function RayfieldLite:SetTheme(theme)
    -- theme: table with fields Background, Window, Accent, Text, SubText
    self._theme = theme
    -- Apply theme to active windows
    for _, win in pairs(self._windows) do
        if win.ApplyTheme then
            win:ApplyTheme(theme)
        end
    end
end

function RayfieldLite:GetTheme()
    return self._theme
end

-- Font loader (simple) - accept Enum.Font or assetId number
function RayfieldLite:RegisterFont(name, font)
    -- font can be Enum.Font or number (asset id) - use accordingly when setting TextLabel.Font
    self._fonts[name] = font
end

-- Window creation
function RayfieldLite:CreateWindow(title, opts)
    opts = opts or {}
    if not self._allowMultiWindow and #self._windows > 0 then
        error("Multi-window support disabled")
    end

    local win = {}
    win.Title = title or "Window"
    win._elements = {}
    win.Visible = true
    win.Size = opts.Size or UDim2.new(0, 600, 0, 400)
    win.Position = opts.Position or UDim2.new(0.5, -300, 0.5, -200)
    win.MinSize = Vector2.new(320, 180)

    -- Build window frame
    local container = create("Frame", {
        Name = title .. "_Window",
        Parent = self.gui,
        Size = win.Size,
        Position = win.Position,
        BackgroundColor3 = self._theme.Window,
        BorderSizePixel = 0,
        ZIndex = 3,
        ClipsDescendants = true
    })

    -- UI Corner & effects
    create("UICorner", {Parent = container, CornerRadius = UDim.new(0, 8)})
    create("UIStroke", {Parent = container, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1, Color = Color3.fromRGB(30,30,30), Transparency = 0.3})

    -- Topbar
    local topbar = create("Frame", {Parent = container, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
    local titleLabel = create("TextLabel", {
        Parent = topbar,
        Text = win.Title,
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = self._theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
    })

    -- Control buttons: minimize, maximize, close
    local btns = create("Frame", {Parent = topbar, Size = UDim2.new(0,110,1,0), Position = UDim2.new(1, -110, 0, 0), BackgroundTransparency = 1})

    local function makeButton(iconText, x)
        local b = create("TextButton", {Parent = btns, Size = UDim2.new(0,30,0,26), Position = UDim2.new(0, x, 0, 5), BackgroundTransparency = 1, Text = iconText, Font = Enum.Font.SourceSansBold, TextSize = 18, TextColor3 = self._theme.SubText})
        create("UICorner", {Parent = b, CornerRadius = UDim.new(0,4)})
        return b
    end

    local btnMin = makeButton("—", 0)
    local btnMax = makeButton("⬜", 0.32)
    local btnClose = makeButton("✕", 0.64)

    -- Content area
    local content = create("Frame", {Parent = container, Position = UDim2.new(0,0,0,36), Size = UDim2.new(1,0,1,-36), BackgroundTransparency = 1})
    local layout = create("UIListLayout", {Parent = content, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})

    -- Theme application
    function win:ApplyTheme(theme)
        container.BackgroundColor3 = theme.Window
        titleLabel.TextColor3 = theme.Text
        for _, c in pairs(container:GetDescendants()) do
            if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox") then
                c.TextColor3 = theme.Text
            end
            if c.Name == "Accent" and c:IsA("Frame") then
                c.BackgroundColor3 = theme.Accent
            end
        end
    end

    win.ApplyTheme = win.ApplyTheme

    -- Dragging
    local dragging = false
    local dragOffset = Vector2.new()

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local mouse = UserInputService:GetMouseLocation()
            local absPos = container.AbsolutePosition
            dragOffset = Vector2.new(mouse.X - absPos.X, mouse.Y - absPos.Y)
        end
    end)
    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and container.Parent then
            local mouse = UserInputService:GetMouseLocation()
            local newX = mouse.X - dragOffset.X
            local newY = mouse.Y - dragOffset.Y
            container.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    -- Minimize / maximize
    local isMinimized = false
    local isMaximized = false
    local lastPos, lastSize

    btnMin.MouseButton1Click:Connect(function()
        if isMinimized then
            content.Visible = true
            container.Size = lastSize or win.Size
            isMinimized = false
        else
            lastSize = container.Size
            content.Visible = false
            container.Size = UDim2.new(container.Size.X.Scale, container.Size.X.Offset, 0, 36)
            isMinimized = true
        end
    end)

    btnMax.MouseButton1Click:Connect(function()
        if isMaximized then
            container.Size = lastSize or win.Size
            container.Position = lastPos or win.Position
            isMaximized = false
        else
            lastSize = container.Size; lastPos = container.Position
            container.Position = UDim2.new(0, 0, 0, 0)
            container.Size = UDim2.new(1, 0, 1, 0)
            isMaximized = true
        end
    end)

    btnClose.MouseButton1Click:Connect(function()
        container:Destroy()
        self._windows[title] = nil
    end)

    -- Resize handles (bottom-right draggable)
    local resizeGrip = create("Frame", {Parent = container, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -14, 1, -14), BackgroundTransparency = 1})
    local resizing = false
    local startPos, startSize

    resizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            startPos = UserInputService:GetMouseLocation()
            startSize = Vector2.new(container.AbsoluteSize.X, container.AbsoluteSize.Y)
        end
    end)
    resizeGrip.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if resizing then
            local m = UserInputService:GetMouseLocation()
            local dx = m.X - startPos.X
            local dy = m.Y - startPos.Y
            local newW = clamp(startSize.X + dx, win.MinSize.X, math.max(800, startSize.X + dx))
            local newH = clamp(startSize.Y + dy, win.MinSize.Y, math.max(600, startSize.Y + dy))
            container.Size = UDim2.new(0, newW, 0, newH)
        end
    end)

    -- Container API to add components
    function win:AddLabel(text)
        local lbl = create("TextLabel", {Parent = content, Size = UDim2.new(1, -12, 0, 22), BackgroundTransparency = 1, Text = text or "Label", Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
        return lbl
    end

    function win:AddButton(text, callback)
        local btn = create("TextButton", {Parent = content, Size = UDim2.new(1, -12, 0, 34), BackgroundColor3 = Color3.fromRGB(40,40,40), Text = text or "Button", Font = Enum.Font.Gotham, TextSize = 14})
        create("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
        local accent = create("Frame", {Parent = btn, Name = "Accent", Size = UDim2.new(0,6,1,0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = self._theme.Accent})
        btn.MouseButton1Click:Connect(function()
            spawn(function()
                tween(btn, {BackgroundTransparency = 0.4}, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
                wait(0.08)
                tween(btn, {BackgroundTransparency = 0}, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
            end)
            if callback then
                pcall(callback)
            end
        end)
        return btn
    end

    function win:AddToggle(text, default, callback)
        default = default or false
        local frame = create("Frame", {Parent = content, Size = UDim2.new(1, -12, 0, 30), BackgroundTransparency = 1})
        local lbl = create("TextLabel", {Parent = frame, Text = text or "Toggle", BackgroundTransparency = 1, Position = UDim2.new(0,0,0,0), Size = UDim2.new(1, -50, 1,0), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 14})
        local toggleBtn = create("TextButton", {Parent = frame, Size = UDim2.new(0, 40, 0, 22), Position = UDim2.new(1, -40, 0,4), BackgroundColor3 = Color3.fromRGB(60,60,60), Text = ""})
        create("UICorner", {Parent = toggleBtn, CornerRadius = UDim.new(0,10)})
        local dot = create("Frame", {Parent = toggleBtn, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0,2,0,2), BackgroundColor3 = Color3.fromRGB(220,220,220)})
        create("UICorner", {Parent = dot, CornerRadius = UDim.new(0,8)})
        local state = default
        local function refresh()
            if state then
                tween(toggleBtn, {BackgroundColor3 = self._theme.Accent})
                tween(dot, {Position = UDim2.new(1, -20, 0, 2)})
            else
                tween(toggleBtn, {BackgroundColor3 = Color3.fromRGB(60,60,60)})
                tween(dot, {Position = UDim2.new(0, 2, 0, 2)})
            end
        end
        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            refresh()
            if callback then pcall(callback, state) end
        end)
        refresh()
        return {Get = function() return state end, Set = function(v) state = v; refresh() end}
    end

    function win:AddSlider(text, min, max, default, decimals, callback)
        min = min or 0; max = max or 100; default = default or min; decimals = decimals or 0
        local frame = create("Frame", {Parent = content, Size = UDim2.new(1,-12,0,46), BackgroundTransparency = 1})
        local lbl = create("TextLabel", {Parent = frame, Text = (text or "Slider") .. " - " .. tostring(default), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0,0,0,0), Size = UDim2.new(1, -12, 0, 18)})
        local bar = create("Frame", {Parent = frame, Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,0,24), BackgroundColor3 = Color3.fromRGB(60,60,60)})
        create("UICorner", {Parent = bar, CornerRadius = UDim.new(0,6)})
        local fill = create("Frame", {Parent = bar, Size = UDim2.new(0,(default-min)/(max-min),1,0), BackgroundColor3 = self._theme.Accent})
        create("UICorner", {Parent = fill, CornerRadius = UDim.new(0,6)})
        local dragging = false
        local function updateFromX(x)
            local sizeX = clamp(x,0,bar.AbsoluteSize.X)
            local t = sizeX / bar.AbsoluteSize.X
            local value = min + (max-min) * t
            if decimals >= 0 then value = math.floor(value * (10^decimals)) / (10^decimals) end
            fill.Size = UDim2.new(t,0,1,0)
            lbl.Text = (text or "Slider") .. " - " .. tostring(value)
            if callback then pcall(callback, value) end
        end
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        bar.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        RunService.RenderStepped:Connect(function()
            if dragging then
                local m = UserInputService:GetMouseLocation()
                local p = bar.AbsolutePosition
                updateFromX(m.X - p.X)
            end
        end)
        return {Set = function(v) local t = (v - min)/(max-min); fill.Size = UDim2.new(t,0,1,0); lbl.Text = (text or "Slider").." - "..tostring(v) end}
    end

    function win:AddDropdown(text, options, callback)
        options = options or {}
        local frame = create("Frame", {Parent = content, Size = UDim2.new(1,-12,0,30), BackgroundTransparency = 1})
        local button = create("TextButton", {Parent = frame, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.fromRGB(40,40,40), Text = text or "Dropdown", Font = Enum.Font.Gotham, TextSize = 14})
        create("UICorner", {Parent = button, CornerRadius = UDim.new(0,6)})
        local list = create("ScrollingFrame", {Parent = frame, Visible = false, BackgroundColor3 = Color3.fromRGB(30,30,30), Size = UDim2.new(1,0,0,120), Position = UDim2.new(0,0,1,6), CanvasSize = UDim2.new(0,0,0,0)})
        create("UICorner", {Parent = list, CornerRadius = UDim.new(0,6)})
        local layout = create("UIListLayout", {Parent = list, Padding = UDim.new(0,4)})
        local function rebuild()
            for _, c in pairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            for i, opt in ipairs(options) do
                local optBtn = create("TextButton", {Parent = list, Size = UDim2.new(1, -8, 0, 28), Position = UDim2.new(0,4,0,0), BackgroundTransparency = 1, Text = tostring(opt), Font = Enum.Font.Gotham, TextSize = 14})
                optBtn.MouseButton1Click:Connect(function()
                    button.Text = tostring(opt)
                    list.Visible = false
                    if callback then pcall(callback, opt) end
                end)
            end
            list.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 8)
        end
        rebuild()
        button.MouseButton1Click:Connect(function()
            list.Visible = not list.Visible
        end)
        return {Update = function(newOptions) options = newOptions; rebuild() end}
    end

    function win:AddColorPicker(text, default, callback)
        default = default or {r=1,g=0,h=0}
        local frame = create("Frame", {Parent = content, Size = UDim2.new(1,-12,0,120), BackgroundTransparency = 1})
        local label = create("TextLabel", {Parent = frame, Text = text or "Color", BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 14})
        local picker = create("Frame", {Parent = frame, Position = UDim2.new(0,0,0,28), Size = UDim2.new(1,0,0,64), BackgroundColor3 = Color3.fromRGB(50,50,50)})
        create("UICorner", {Parent = picker, CornerRadius = UDim.new(0,6)})
        local hue = create("Frame", {Parent = frame, Position = UDim2.new(1, -28, 0, 28), Size = UDim2.new(0, 18, 0, 64), BackgroundColor3 = Color3.fromRGB(255,0,0)})
        create("UICorner", {Parent = hue, CornerRadius = UDim.new(0,4)})
        local color = Color3.fromHSV(default.h or 0, default.s or 1, default.v or 1)
        local preview = create("Frame", {Parent = frame, Position = UDim2.new(0, 0, 0, 96), Size = UDim2.new(0, 40, 0, 16), BackgroundColor3 = color})
        create("UICorner", {Parent = preview, CornerRadius = UDim.new(0,4)})

        -- Basic click-drag to pick hue/brightness/sat by mouse position
        local picking = false
        picker.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then picking = true end
        end)
        picker.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then picking = false end
        end)
        RunService.RenderStepped:Connect(function()
            if picking then
                local m = UserInputService:GetMouseLocation()
                local p = picker.AbsolutePosition
                local relX = clamp((m.X - p.X) / picker.AbsoluteSize.X, 0, 1)
                local relY = clamp((m.Y - p.Y) / picker.AbsoluteSize.Y, 0, 1)
                local h = relX
                local s = 1 - relY
                local v = 1
                local c3 = Color3.fromHSV(h, s, v)
                preview.BackgroundColor3 = c3
                if callback then pcall(callback, c3) end
            end
        end)
        return {Set = function(c3) preview.BackgroundColor3 = c3 end}
    end

    function win:AddKeybind(text, defaultKey, callback)
        defaultKey = defaultKey or Enum.KeyCode.LeftControl
        local frame = create("Frame", {Parent = content, Size = UDim2.new(1,-12,0,36), BackgroundTransparency = 1})
        local btn = create("TextButton", {Parent = frame, Size = UDim2.new(0,160,0,28), BackgroundColor3 = Color3.fromRGB(40,40,40), Text = tostring(defaultKey), Font = Enum.Font.Gotham, TextSize = 14})
        create("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
        local current = defaultKey
        local rebinding = false
        btn.MouseButton1Click:Connect(function()
            btn.Text = "Press a key..."
            rebinding = true
        end)
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if rebinding and input.KeyCode then
                current = input.KeyCode
                btn.Text = tostring(current)
                rebinding = false
                if callback then pcall(callback, current) end
            else
                if input.KeyCode == current then
                    if callback then pcall(callback) end
                end
            end
        end)
        return {Get = function() return current end, Set = function(k) current = k; btn.Text = tostring(k) end}
    end

    function win:AddTextbox(placeholder, callback, numericOnly)
        local tb = create("TextBox", {Parent = content, Size = UDim2.new(1,-12,0,30), PlaceholderText = placeholder or "", Text = "", Font = Enum.Font.Gotham, TextSize = 14, BackgroundColor3 = Color3.fromRGB(40,40,40)})
        create("UICorner", {Parent = tb, CornerRadius = UDim.new(0,6)})
        tb.FocusLost:Connect(function(enter)
            if numericOnly then
                local n = tonumber(tb.Text)
                if n then
                    if callback then pcall(callback, n) end
                else
                    if callback then pcall(callback, nil) end
                end
            else
                if callback then pcall(callback, tb.Text) end
            end
        end)
        return tb
    end

    function win:Notify(text, type, time)
        local t = type or "info"
        time = time or 5
        local notif = create("Frame", {Parent = self._notifFrame, Size = UDim2.new(1,0,0,50), BackgroundColor3 = Color3.fromRGB(40,40,40)})
        create("UICorner", {Parent = notif, CornerRadius = UDim.new(0,6)})
        local lbl = create("TextLabel", {Parent = notif, Text = text or "Notification", BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 14, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0)})
        tween(notif, {Position = UDim2.new(1, -310, 0, 10 + #self._notifications * 60)})
        table.insert(self._notifications, notif)
        delay(time, function()
            pcall(function() notif:Destroy() end)
            for i, v in ipairs(self._notifications) do if v == notif then table.remove(self._notifications, i); break end end
        end)
    end

    -- Script hub system - basic
    function win:CreateScriptHub(list)
        list = list or {}
        local hubTab = create("Frame", {Parent = content, Size = UDim2.new(1, -12, 0, 200)})
        local listFrame = create("ScrollingFrame", {Parent = hubTab, Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0,6,0,0), BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0)})
        local layout = create("UIListLayout", {Parent = listFrame, Padding = UDim.new(0,6)})
        local function rebuild()
            for _, c in pairs(listFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            for _, entry in ipairs(list) do
                local b = create("TextButton", {Parent = listFrame, Size = UDim2.new(1, -8, 0, 44), BackgroundColor3 = Color3.fromRGB(40,40,40), Text = entry.Name or "Script: unknown", Font = Enum.Font.Gotham, TextSize = 14})
                create("UICorner", {Parent = b, CornerRadius = UDim.new(0,6)})
                local runBtn = create("TextButton", {Parent = b, Size = UDim2.new(0,80,1,0), Position = UDim2.new(1, -84, 0, 0), Text = "Run", Font = Enum.Font.Gotham, TextSize = 14})
                runBtn.MouseButton1Click:Connect(function()
                    -- Auto-load via HttpGet
                    if entry.Url then
                        if pcall(function() return HttpService:GetAsync(entry.Url) end) then
                            local ok, res = pcall(function() return game:HttpGet(entry.Url) end)
                            if ok then
                                local fn, err = loadstring(res)
                                if fn then
                                    pcall(fn)
                                    self:Notify("Ran: " .. (entry.Name or "script"), "success", 4)
                                else
                                    self:Notify("Load error: "..tostring(err), "error", 5)
                                end
                            else
                                self:Notify("HttpGet failed for: "..tostring(entry.Url), "warning", 4)
                            end
                        else
                            self:Notify("HttpService:GetAsync not permitted.", "warning", 4)
                        end
                    elseif entry.Code then
                        local fn, err = loadstring(entry.Code)
                        if fn then pcall(fn); self:Notify("Ran: "..(entry.Name or "script"), "success", 4) else self:Notify("Load error: "..tostring(err), "error", 5) end
                    end
                end)
            end
            listFrame.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 8)
        end
        rebuild()
        return {Update = function(newList) list = newList; rebuild() end}
    end

    -- Tabs system (simple)
    local tabBar = create("Frame", {Parent = container, Size = UDim2.new(1,0,0,28), Position = UDim2.new(0,0,1,-28), BackgroundTransparency = 1})
    local tabs = {}
    function win:AddTab(name)
        local t = {Name=name, Content = create("Frame", {Parent = content, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1})}
        for _, c in pairs(content:GetChildren()) do if c ~= layout and c ~= t.Content then c.Visible = false end end
        local tabBtn = create("TextButton", {Parent = topbar, Size = UDim2.new(0,90,0,26), Position = UDim2.new(0, 10 + #tabs*95, 0, 5), Text = name, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 14})
        tabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(tabs) do p.Content.Visible = false end
            t.Content.Visible = true
        end)
        t.Button = tabBtn
        t.Content.Visible = false
        table.insert(tabs, t)
        return t.Content
    end

    -- Expose window API
    win.Container = container
    win.Content = content

    self._windows[title] = win
    -- Apply theme
    win:ApplyTheme(self._theme)
    return win
end

-- Mobile-friendly scaling utility
function RayfieldLite:EnableMobileScaling(enable)
    self._mobileScale = enable
    if enable then
        self.gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            local size = self.gui.AbsoluteSize
            local scale = math.clamp(size.X / 1366, 0.5, 1)
            for _, w in pairs(self._windows) do
                if w.Container then
                    w.Container.Size = UDim2.new(w.Container.Size.X.Scale * scale, w.Container.Size.X.Offset * scale, w.Container.Size.Y.Scale * scale, w.Container.Size.Y.Offset * scale)
                end
            end
        end)
    end
end

-- Simple loader to produce an instance of the library
return RayfieldLite
