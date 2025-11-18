local ScriptHub = {}

function ScriptHub.LoadFromURL(url)
    local data = game:HttpGet(url)
    local decoded = game:GetService("HttpService"):JSONDecode(data)
    return decoded -- table of script entries
end

return ScriptHub
