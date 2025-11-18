local Textbox = {}
Textbox.__index = Textbox

function Textbox.new(params)
    local self = setmetatable({}, Textbox)
    local box = Instance.new("TextBox")
    box.Name = "LSN_Textbox"
    box.Size = UDim2.new(0, 200, 0, 30)
    box.PlaceholderText = params.Placeholder or "Type..."
    box.Parent = params.Parent

    box.FocusLost:Connect(function()
        if params.Callback then
            params.Callback(box.Text)
        end
    end)

    self.UI = box
    return self
end

return Textbox
