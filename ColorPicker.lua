local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(params)
    local self = setmetatable({}, ColorPicker)

    local frame = Instance.new("Frame")
    frame.Name = "LSN_ColorPicker"
    frame.Size = UDim2.new(0, 150, 0, 60)
    frame.BackgroundColor3 = params.Default or Color3.new(1, 0, 0)
    frame.Parent = params.Parent

    frame.InputBegan:Connect(function()
        local newColor = Color3.fromHSV(math.random(), 1, 1)
        frame.BackgroundColor3 = newColor
        params.Callback(newColor)
    end)

    self.Color = frame
    return self
end

return ColorPicker
