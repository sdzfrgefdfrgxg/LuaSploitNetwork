local Resize = {}

function Resize.Add(frame)
    local drag = Instance.new("Frame")
    drag.Name = "LSN_ResizeHandle"
    drag.Size = UDim2.new(0, 10, 0, 10)
    drag.AnchorPoint = Vector2.new(1, 1)
    drag.Position = UDim2.new(1, 0, 1, 0)
    drag.BackgroundTransparency = 0.5
    drag.Parent = frame

    local UIS = game:GetService("UserInputService")
    local run = game:GetService("RunService")

    drag.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local start = UIS:GetMouseLocation()
            local startSize = frame.Size
            local con
            con = run.RenderStepped:Connect(function()
                local delta = UIS:GetMouseLocation() - start
                frame.Size = UDim2.new(0, startSize.X.Offset + delta.X, 0, startSize.Y.Offset + delta.Y)
            end)
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    con:Disconnect()
                end
            end)
        end
    end)
end

return Resize
