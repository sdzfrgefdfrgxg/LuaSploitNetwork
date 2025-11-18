local WindowControls = {}

function WindowControls.Attach(window)
    local button = Instance.new("TextButton")
    button.Text = "-"
    button.Size = UDim2.new(0, 25, 0, 25)
    button.Parent = window

    local minimized = false

    button.MouseButton1Click:Connect(function()
        minimized = not minimized
        for _, v in ipairs(window:GetChildren()) do
            if v ~= button then
                v.Visible = not minimized
            end
        end
    end)
end

return WindowControls
