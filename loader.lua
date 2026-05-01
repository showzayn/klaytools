-- put me out of my misery

local gameId = game.GameId
local placeId = game.PlaceId

local scripts = {
    -- the stabby block game
    [66654135] = {
        Name = "Murder Mystery 2",
        Url = "https://raw.githubusercontent.com/showzayn/klaytools/refs/heads/main/MM2.lua",
        LocalPath = "works/scripts/mm2/MM2.lua"
    },
    -- the sweaty pew pew game
    [6035872082] = {
        Name = "Rivals",
        Url = "https://raw.githubusercontent.com/showzayn/klaytools/refs/heads/main/Rivals.lua",
        LocalPath = "works/scripts/rivals/Rivals.lua"
    },
    -- nextbots running simulator
    [3647333358] = {
        Name = "Evade [BUGGY]",
        Url = "https://raw.githubusercontent.com/showzayn/klaytools/refs/heads/main/Evade.lua",
        LocalPath = "works/scripts/Evade.lua"
    }
}

local scriptData = scripts[gameId]

-- fallback ig
if not scriptData then
    if placeId == 142823291 or placeId == 335132309 or placeId == 636649648 then
        scriptData = scripts[66654135]
    elseif placeId == 17625359962 then
        scriptData = scripts[6035872082]
    elseif placeId == 9872472334 then
        scriptData = scripts[3647333358]
    end
end

if scriptData then
    print("[klaytools] oh boy here we go again... detected: " .. scriptData.Name)
    print("[klaytools] booting up the magic, don't crash on me now...")
    
    local success, result = pcall(function()
        if getgenv and getgenv().KlaytoolsUseLocalFiles and type(isfile) == "function" and type(readfile) == "function" and scriptData.LocalPath and isfile(scriptData.LocalPath) then
            return loadstring(readfile(scriptData.LocalPath))()
        end
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
        local Starlight = loadstring(game:HttpGet("https://raw.githubusercontent.com/showzayn/klaytools/refs/heads/main/starlight_modified.lua"))()
        local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
        
        Starlight:Notification({
            Title = "klaytools Loader",
            Content = "Current game is unsupported.\nPlace ID: " .. tostring(gameId),
            Duration = 6,
            Icon = NebulaIcons:GetIcon('skull', 'Lucide')
        }, "klaytools_unsupported")
    end)
end
