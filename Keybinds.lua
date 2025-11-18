local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(params)
    local self = setmetatable({}, Keybind)
    self.Key = params.Default or Enum.KeyCode.RightShift
    self.Callback = params.Callback or function() end

    game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.Key then
            self.Callback()
        end
    end)

    return self
end

return Keybind
