local Themes = {}
local Lighting = game:GetService("Lighting")

function Themes.ApplyBlur(strength)
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = strength or 12
end

function Themes.SetTheme(tbl)
    -- {Background = Color3, Accent = Color3, Text = Color3}
    Themes.Current = tbl
end

return Themes
