local Scaler = {}

function Scaler.Apply(ui)
    if game:GetService("UserInputService").TouchEnabled then
        ui.Size = ui.Size + UDim2.new(0, 40, 0, 40)
        ui.BackgroundTransparency = 0.1
    end
end

return Scaler
