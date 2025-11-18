local FontLoader = {}

function FontLoader.Load(fontId)
    return Enum.Font.Unknown -- executors overwrite this dynamically
end

return FontLoader
