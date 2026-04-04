-- put me out of my misery

local gameId = game.PlaceId

local scripts = {
    -- the stabby block game
    [142823291] = {
        Name = "Murder Mystery 2",
        Url = "https://raw.githubusercontent.com/showzayn/klaytools/refs/heads/main/MM2.lua"
    },
    -- the sweaty pew pew game
    [17625359962] = {
        Name = "Rivals",
        Url = "https://raw.githubusercontent.com/showzayn/klaytools/refs/heads/main/Rivals.lua"
    }
}

local scriptData = scripts[gameId]

if scriptData then
    print("[klaytools] oh boy here we go again... detected: " .. scriptData.Name)
    print("[klaytools] booting up the magic, don't crash on me now...")
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet(scriptData.Url))()
    end)
    
    if not success then
        warn("[klaytools] bruh the script broke for " .. scriptData.Name .. " complain to the dev:\n" .. tostring(result))
    end
else
    warn("[klaytools] bro what game is this even? unsupported place ID: " .. tostring(gameId))
    
    -- if they execute in some random tycoon or simulator idfk
    pcall(function()
        getgenv().SecureMode = true
        local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
        local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
        
        Starlight:Notification({
            Title = "klaytools Loader",
            Content = "Current game is unsupported.\nPlace ID: " .. tostring(gameId),
            Duration = 6,
            Icon = NebulaIcons:GetIcon('skull', 'Lucide')
        }, "klaytools_unsupported")
    end)
end
