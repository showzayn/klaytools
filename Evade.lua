if not game:IsLoaded() then game.Loaded:Wait() end

local queueteleport = queue_on_teleport or queueonteleport
if type(queueteleport) == "function" then
    pcall(function()
        queueteleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/showzayn/klaytools/refs/heads/main/Evade.lua"))()')
    end)
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if getgenv then
    getgenv().InterfaceName = "klaytools_evade"
end

local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

local uiIdCounter = 0
local function nextUiId(prefix)
    uiIdCounter += 1
    prefix = tostring(prefix or "ui"):gsub("[^%w_]", "_")
    return string.format("%s_%d", prefix, uiIdCounter)
end

local function getIcon(name)
    if type(name) == "number" then
        return name
    end

    if type(name) ~= "string" or name == "" then
        return nil
    end

    local numericIcon = tonumber(name)
    if numericIcon then
        return numericIcon
    end

    local ok, iconId = pcall(function()
        return NebulaIcons:GetIcon(name, "Lucide")
    end)
    if ok and iconId then
        return iconId
    end

    ok, iconId = pcall(function()
        return NebulaIcons:GetIcon(name, "Material")
    end)
    if ok and iconId then
        return iconId
    end

    return nil
end

local Window = Starlight:CreateWindow({
    Name = "klaytools",
    Subtitle = "Evade",
    Theme = "Neo (Dark)",
    Icon = getIcon("crosshair"),
    LoadingEnabled = true,
    LoadingSettings = {
        Title = "klaytools",
        Subtitle = "Evade"
    },
    BuildWarnings = false,
    InterfaceAdvertisingPrompts = false,
    NotifyOnCallbackError = true,
    FileSettings = {
        RootFolder = "klaytools",
        ConfigFolder = "evade"
    },
    KeySystem = {
        Enabled = false
    }
})

Starlight.WindowKeybind = Enum.KeyCode.RightControl.Name

--=============================================================================
-- EVADE LOGIC
--=============================================================================
local AUTO_OPTIONS_CONFIG = "options"
local autoOptionsEnabled = false
local autoOptionsSaveQueued = false

local function queueSettingsSave()
    if not autoOptionsEnabled or autoOptionsSaveQueued then
        return
    end

    local configPath = Starlight.FileSystem and Starlight.FileSystem.AutoloadConfigPath
    if not configPath then
        return
    end

    autoOptionsSaveQueued = true
    task.delay(0.35, function()
        autoOptionsSaveQueued = false
        pcall(function()
            Starlight.FileSystem:SaveConfig(AUTO_OPTIONS_CONFIG, configPath)
        end)
    end)
end

local function withSettingsSave(callback)
    return function(...)
        if callback then
            local result = callback(...)
            queueSettingsSave()
            return result
        end
    end
end

local function loadAutoOptionsConfig()
    local configPath = Starlight.FileSystem and Starlight.FileSystem.AutoloadConfigPath
    if not configPath then
        return
    end

    pcall(function()
        Starlight.FileSystem:LoadConfig(AUTO_OPTIONS_CONFIG, configPath)
    end)
end

local currentSettings = {
    Speed = 1500,
    JumpCap = 1,
    AirStrafeAcceleration = 187
}

getgenv().ApplyMode = "Optimized"

local requiredFields = {
    Friction = true,
    AirStrafeAcceleration = true,
    JumpHeight = true,
    RunDeaccel = true,
    JumpSpeedMultiplier = true,
    JumpCap = true,
    SprintCap = true,
    WalkSpeedMultiplier = true,
    BhopEnabled = true,
    Speed = true,
    AirAcceleration = true,
    RunAccel = true,
    SprintAcceleration = true
}

local function hasAllFields(tbl)
    if type(tbl) ~= "table" then return false end
    for field, _ in pairs(requiredFields) do
        if rawget(tbl, field) == nil then
            return false
        end
    end
    return true
end

local function getConfigTables()
    local tables = {}
    for _, obj in ipairs(getgc(true)) do
        local success, result = pcall(function()
            if hasAllFields(obj) then return obj end
        end)
        if success and result then
            table.insert(tables, result)
        end
    end
    return tables
end

local function applyToTables(callback)
    local targets = getConfigTables()
    if #targets == 0 then return end

    if getgenv().ApplyMode == "Optimized" then
        task.spawn(function()
            for i, tableObj in ipairs(targets) do
                if tableObj and typeof(tableObj) == "table" then
                    pcall(callback, tableObj)
                end
                if i % 3 == 0 then task.wait() end
            end
        end)
    else
        for i, tableObj in ipairs(targets) do
            if tableObj and typeof(tableObj) == "table" then
                pcall(callback, tableObj)
            end
        end
    end
end

--=============================================================================
-- UI TABS
--=============================================================================
local mainTabs = Window:CreateTabSection("Main", false)

local PlayerTab = mainTabs:CreateTab({ Name = "LocalPlayer", Icon = getIcon("user"), Columns = 2 }, "player_tab")

local physicsGroup = PlayerTab:CreateGroupbox({
    Name = "Physics Tweaks",
    Icon = getIcon("zap"),
    Column = 1
}, "physics_group")

physicsGroup:CreateInput({
    Name = "Player Speed",
    PlaceholderText = "1500",
    RemoveTextAfterFocusLost = false,
    Enter = true,
    Callback = function(text)
        local val = tonumber(text)
        if val and val >= 1450 then
            currentSettings.Speed = val
            applyToTables(function(obj)
                obj.Speed = val
            end)
        end
    end
}, 'klay_item_1')

physicsGroup:CreateInput({
    Name = "Jump Cap",
    PlaceholderText = "1",
    RemoveTextAfterFocusLost = false,
    Enter = true,
    Callback = function(text)
        local val = tonumber(text)
        if val and val >= 0.1 then
            currentSettings.JumpCap = val
            applyToTables(function(obj)
                obj.JumpCap = val
            end)
        end
    end
}, 'klay_item_2')

physicsGroup:CreateInput({
    Name = "Strafe Acceleration",
    PlaceholderText = "187",
    RemoveTextAfterFocusLost = false,
    Enter = true,
    Callback = function(text)
        local val = tonumber(text)
        if val and val >= 1 then
            currentSettings.AirStrafeAcceleration = val
            applyToTables(function(obj)
                obj.AirStrafeAcceleration = val
            end)
        end
    end
}, 'klay_item_3')

local cframeGroup = PlayerTab:CreateGroupbox({
    Name = "CFrame Movement",
    Icon = getIcon("move"),
    Column = 2
}, "cframe_group")

local shadow = {
    speedValue = 25,
    active = false,
    conn = nil,
    root = nil
}

local function setupCharacter(char)
    shadow.root = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")

    if shadow.conn then
        shadow.conn:Disconnect()
        shadow.conn = nil
    end

    if shadow.active then
        shadow.conn = RunService.Heartbeat:Connect(function(dt)
            if not shadow.active or not shadow.root or not humanoid then return end
            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                local newPos = shadow.root.Position + moveDir.Unit * shadow.speedValue * dt
                shadow.root.CFrame = CFrame.new(newPos, newPos + shadow.root.CFrame.LookVector)
            end
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)

cframeGroup:CreateToggle({
    Name = "CFrame Speed",
    CurrentValue = false,
    Callback = function(value)
        shadow.active = value
        if value and LocalPlayer.Character then
            setupCharacter(LocalPlayer.Character)
        elseif shadow.conn then
            shadow.conn:Disconnect()
            shadow.conn = nil
        end
    end
}, 'klay_item_4')

cframeGroup:CreateInput({
    Name = "CFrame Speed Ratio",
    PlaceholderText = "25",
    RemoveTextAfterFocusLost = false,
    Enter = true,
    Callback = function(text)
        local num = tonumber(text)
        if num then
            shadow.speedValue = num
        end
    end
}, 'klay_item_5')

--=============================================================================
-- EXTRA MOVEMENT
--=============================================================================
local extraMoveGroup = PlayerTab:CreateGroupbox({
    Name = "Extra Movement",
    Icon = getIcon("chevron-right"),
    Column = 1
}, "extra_move_group")

local SlideVars = { Enabled = false, Friction = -8, Conn = nil }
extraMoveGroup:CreateToggle({
    Name = "Infinite Slide",
    CurrentValue = false,
    Callback = function(value)
        SlideVars.Enabled = value
        if SlideVars.Conn then SlideVars.Conn:Disconnect() end
        
        if value then
            SlideVars.Conn = RunService.RenderStepped:Connect(function()
                if not LocalPlayer.Character then return end
                local state = LocalPlayer.Character:GetAttribute("State")
                if state == "Slide" then
                    pcall(function() LocalPlayer.Character:SetAttribute("State", "EmotingSlide") end)
                elseif state == "EmotingSlide" then
                    applyToTables(function(obj)
                        if rawget(obj, "Friction") then obj.Friction = SlideVars.Friction end
                    end)
                else
                    applyToTables(function(obj)
                        if rawget(obj, "Friction") then obj.Friction = 5 end
                    end)
                end
            end)
        else
            applyToTables(function(obj)
                if rawget(obj, "Friction") then obj.Friction = 5 end
            end)
        end
    end
}, 'klay_item_6')

extraMoveGroup:CreateInput({
    Name = "Slide Speed",
    PlaceholderText = "-8",
    RemoveTextAfterFocusLost = false,
    Enter = true,
    Callback = function(text)
        local num = tonumber(text)
        if num then SlideVars.Friction = num end
    end
}, 'klay_item_7')

local TrimpVars = { Enabled = false, Base = 50, Extra = 100, Drop = 0, Speed = 50, Push = nil }
extraMoveGroup:CreateToggle({
    Name = "Easy Trimp",
    CurrentValue = false,
    Callback = function(value)
        TrimpVars.Enabled = value
        if not value and TrimpVars.Push then
            TrimpVars.Push:Destroy()
            TrimpVars.Push = nil
        end
    end
}, 'klay_item_8')

RunService.RenderStepped:Connect(function(dt)
    if not TrimpVars.Enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    local inAir = hum.FloorMaterial == Enum.Material.Air
    local baseSpeed = TrimpVars.Base
    
    if inAir then
        TrimpVars.Speed = math.min(baseSpeed + TrimpVars.Extra, TrimpVars.Speed + math.max(0.1, 2.5 * dt))
    else
        TrimpVars.Speed = math.max(baseSpeed - TrimpVars.Drop, TrimpVars.Speed - (2.5 * dt))
    end

    if TrimpVars.Push then TrimpVars.Push:Destroy() end

    local look = workspace.CurrentCamera.CFrame.LookVector
    local moveDir = Vector3.new(look.X, 0, look.Z)
    if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = moveDir * TrimpVars.Speed
    bv.MaxForce = Vector3.new(4e5, 0, 4e5)
    bv.P = 1250
    bv.Parent = hrp
    game:GetService("Debris"):AddItem(bv, 0.1)
    TrimpVars.Push = bv
end)

extraMoveGroup:CreateInput({
    Name = "Trimp Base Speed",
    PlaceholderText = "50",
    RemoveTextAfterFocusLost = false,
    Enter = true,
    Callback = function(v) if tonumber(v) then TrimpVars.Base = tonumber(v) end end
}, 'klay_item_9')
extraMoveGroup:CreateInput({
    Name = "Trimp Extra Speed",
    PlaceholderText = "100",
    RemoveTextAfterFocusLost = false,
    Enter = true,
    Callback = function(v) if tonumber(v) then TrimpVars.Extra = tonumber(v) end end
}, 'klay_item_10')

--=============================================================================
-- BOUNCES & FEATURES (Column 2)
--=============================================================================
local bounceGroup = PlayerTab:CreateGroupbox({
    Name = "Bounces & Features",
    Icon = getIcon("zap"),
    Column = 2
}, "bounce_group")

local BounceVars = { Enabled = false, Multiplier = 80, Cooldown = 0.5, LastBoost = 0}
bounceGroup:CreateToggle({
    Name = "Bounce Mutliplier",
    CurrentValue = false,
    Callback = function(value) BounceVars.Enabled = value end
}, 'klay_item_11')

bounceGroup:CreateInput({
    Name = "Bounce Velocity",
    PlaceholderText = "80",
    RemoveTextAfterFocusLost = false,
    Enter = true,
    Callback = function(v) if tonumber(v) then BounceVars.Multiplier = tonumber(v) end end
}, 'klay_item_12')

local function triggerLag(duration)
    task.spawn(function()
        local start = tick()
        while tick() - start < duration do
            local a = math.random() * math.random()
        end
    end)
end

local LagVars = { Enabled = false, Duration = 0.5, Conn = nil }
bounceGroup:CreateToggle({
    Name = "Lag Switch (Key: L)",
    CurrentValue = false,
    Callback = function(value)
        LagVars.Enabled = value
        if value then
            LagVars.Conn = game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
                if not gpe and input.KeyCode == Enum.KeyCode.L then triggerLag(LagVars.Duration) end
            end)
        else
            if LagVars.Conn then LagVars.Conn:Disconnect(); LagVars.Conn = nil end
        end
    end
}, 'klay_item_13')

bounceGroup:CreateInput({
    Name = "Lag Duration",
    PlaceholderText = "0.5",
    RemoveTextAfterFocusLost = false,
    Enter = true,
    Callback = function(v) if tonumber(v) then LagVars.Duration = tonumber(v) end end
}, 'klay_item_14')

--=============================================================================
-- EXPLOITS & FARM TAB
--=============================================================================
local ExploitTab = mainTabs:CreateTab({ Name = "Exploits & Farm", Icon = getIcon("swords"), Columns = 2 }, "exploit_tab")

local exploitGroup = ExploitTab:CreateGroupbox({
    Name = "God Mode & Evade Logic",
    Icon = getIcon("shield"),
    Column = 1
}, "exploit_group")

local GodModeVars = {Enabled = false, Loop = nil}
exploitGroup:CreateToggle({
    Name = "God Mode (BETA)",
    CurrentValue = false,
    Callback = function(state)
        GodModeVars.Enabled = state
        if state then
            GodModeVars.Loop = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char and char:GetAttribute("State") == "Down" then
                    char:SetAttribute("State", "Run")
                    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Player"):WaitForChild("ChangePlayerMode"):FireServer(true)
                end
            end)
        elseif GodModeVars.Loop then
            GodModeVars.Loop:Disconnect()
            GodModeVars.Loop = nil
        end
    end
}, 'klay_item_15')

local ColaVars = { Unlimited = false, Hook = nil }
exploitGroup:CreateToggle({
    Name = "Unlimited Cola",
    CurrentValue = false,
    Callback = function(state)
        ColaVars.Unlimited = state
        local RemoteEvent = game:GetService("ReplicatedStorage").Events.Character.ToolAction
        local mt = getrawmetatable(RemoteEvent)
        if state and not ColaVars.Hook then
            setreadonly(mt, false)
            ColaVars.Hook = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                if method == "FireServer" and args[2] == 19 then return nil end
                return ColaVars.Hook(self, ...)
            end)
            setreadonly(mt, true)
        elseif not state and ColaVars.Hook then
            setreadonly(mt, false)
            mt.__namecall = ColaVars.Hook
            setreadonly(mt, true)
            ColaVars.Hook = nil
        end
    end
}, 'klay_item_16')

local farmGroup = ExploitTab:CreateGroupbox({
    Name = "Farming Settings",
    Icon = getIcon("piggy-bank"),
    Column = 2
}, "farm_group")

local FarmVars = { AutoXp = false, Loop = nil, SavedPos = nil, Part = nil }
local function GetSecurityPart()
    if FarmVars.Part then return FarmVars.Part end
    local sp = workspace:FindFirstChild("KL_Security") or Instance.new("Part")
    sp.Name = "KL_Security"
    sp.Size, sp.Position = Vector3.new(20, 1, 20), Vector3.new(0, 1500, 0)
    sp.Anchored, sp.Transparency, sp.CanCollide, sp.Parent = true, 0.5, true, workspace
    FarmVars.Part = sp
    return sp
end

farmGroup:CreateToggle({
    Name = "Auto XP / Safe Heaven",
    CurrentValue = false,
    Callback = function(state)
        FarmVars.AutoXp = state
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if state then
            if hrp and not FarmVars.SavedPos then FarmVars.SavedPos = hrp.CFrame end
            local sp = GetSecurityPart()
            FarmVars.Loop = RunService.Heartbeat:Connect(function()
                if hrp and hrp.Parent then hrp.CFrame = sp.CFrame + Vector3.new(0,3,0) end
            end)
        else
            if FarmVars.Loop then FarmVars.Loop:Disconnect() FarmVars.Loop = nil end
            if hrp and FarmVars.SavedPos then hrp.CFrame = FarmVars.SavedPos end
            FarmVars.SavedPos = nil
        end
    end
}, 'klay_item_17')

farmGroup:CreateToggle({
    Name = "Anti-Afk",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local VirtualUser = game:GetService("VirtualUser")
            getgenv().AntiAFKConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        else
            if getgenv().AntiAFKConnection then
                getgenv().AntiAFKConnection:Disconnect()
                getgenv().AntiAFKConnection = nil
            end
        end
    end
}, 'klay_item_18')

--=============================================================================
-- VISUALS TAB
--=============================================================================
local VisualsTab = mainTabs:CreateTab({ Name = "Visuals", Icon = getIcon("eye"), Columns = 2 }, "visuals_tab")

local visualGroup = VisualsTab:CreateGroupbox({
    Name = "Performance & Client",
    Icon = getIcon("sun"),
    Column = 1
}, "visual_group")

local BrightVars = { Enabled = false, Conn = nil, Orig = {} }
visualGroup:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Callback = function(state)
        local Lighting = game:GetService("Lighting")
        BrightVars.Enabled = state
        if state then
            BrightVars.Orig.Brightness = Lighting.Brightness
            BrightVars.Conn = RunService.Heartbeat:Connect(function()
                Lighting.Brightness = 2
                Lighting.Ambient = Color3.new(1,1,1)
                Lighting.GlobalShadows = false
            end)
        else
            if BrightVars.Conn then BrightVars.Conn:Disconnect(); BrightVars.Conn = nil end
            Lighting.Brightness = BrightVars.Orig.Brightness or 1
            Lighting.GlobalShadows = true
        end
    end
}, 'klay_item_19')

visualGroup:CreateButton({
    Name = "Anti Lag 1 (No Details)",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") then
                v:Destroy()
            end
        end
    end
}, 'klay_item_20')

visualGroup:CreateButton({
    Name = "Anti Lag 2 (Smooth Plastic)",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
        end
    end
}, 'klay_item_21')

local PlayerEspVars = { Enabled = false, Connections = {} }

local function clearPlayerEsp()
    for _, conn in ipairs(PlayerEspVars.Connections) do
        if conn then conn:Disconnect() end
    end
    table.clear(PlayerEspVars.Connections)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("PlayerHighlight")
            if highlight then highlight:Destroy() end
            
            local HRP = player.Character:FindFirstChild("HumanoidRootPart")
            local bill = HRP and HRP:FindFirstChild("PlayerBillboard")
            if bill then bill:Destroy() end
        end
    end
end

local function applyPlayerEsp(character, player)
    if not PlayerEspVars.Enabled or not character then return end
    if player == LocalPlayer then return end
    
    local HRP = character:WaitForChild("HumanoidRootPart", 5)
    if not HRP then return end
    
    local highlight = character:FindFirstChild("PlayerHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "PlayerHighlight"
        highlight.FillColor = Color3.new(1, 1, 1) -- White
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
    end

    local bill = HRP:FindFirstChild("PlayerBillboard")
    if not bill then
        bill = Instance.new("BillboardGui")
        bill.Name = "PlayerBillboard"
        bill.Size = UDim2.new(4, 0, 1, 0) -- Uses Scale instead of Offset
        bill.StudsOffset = Vector3.new(0, 3, 0)
        bill.AlwaysOnTop = true
        bill.Parent = HRP

        local label = Instance.new("TextLabel")
        label.Name = "PlayerText"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextScaled = true -- Scales font to fit the billboard size
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0
        label.Text = player.DisplayName or player.Name
        label.Parent = bill
        
        local conn = RunService.RenderStepped:Connect(function()
            if not PlayerEspVars.Enabled or not character.Parent then return end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (HRP.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                label.Text = string.format("%s [%.1f]", player.DisplayName or player.Name, math.floor(dist))
            end
        end)
        table.insert(PlayerEspVars.Connections, conn)
    end
end

local function setupPlayerEspLoop()
    clearPlayerEsp()
    if not PlayerEspVars.Enabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            task.spawn(applyPlayerEsp, player.Character, player)
        end
        
        local charAddConn = player.CharacterAdded:Connect(function(char)
            task.spawn(applyPlayerEsp, char, player)
        end)
        table.insert(PlayerEspVars.Connections, charAddConn)
    end
    
    local playerAddConn = Players.PlayerAdded:Connect(function(player)
        local charAddConn = player.CharacterAdded:Connect(function(char)
            task.spawn(applyPlayerEsp, char, player)
        end)
        table.insert(PlayerEspVars.Connections, charAddConn)
    end)
    table.insert(PlayerEspVars.Connections, playerAddConn)
end

visualGroup:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Callback = function(state)
        PlayerEspVars.Enabled = state
        if state then
            setupPlayerEspLoop()
        else
            clearPlayerEsp()
        end
    end
}, 'klay_item_player_esp')

local botsGroup = VisualsTab:CreateGroupbox({
    Name = "NextBots Tweaks",
    Icon = getIcon("smile"),
    Column = 2
}, "bots_group")

local BotEspVars = { Enabled = false, Connections = {} }

local function clearBotEsp()
    for _, conn in ipairs(BotEspVars.Connections) do
        if conn then conn:Disconnect() end
    end
    table.clear(BotEspVars.Connections)
    
    local gameFolder = workspace:FindFirstChild("Game")
    local playersFolder = gameFolder and gameFolder:FindFirstChild("Players")
    if not playersFolder then return end

    for _, model in pairs(playersFolder:GetChildren()) do
        if model:IsA("Model") then
            local highlight = model:FindFirstChild("BotHighlight")
            if highlight then highlight:Destroy() end
            
            local HRP = model:FindFirstChild("HumanoidRootPart")
            local bill = HRP and HRP:FindFirstChild("BotBillboard")
            if bill then bill:Destroy() end
        end
    end
end

local function applyBotEsp(model)
    if not BotEspVars.Enabled then return end
    
    -- Ignore actual players so we only highlight NextBots
    if Players:GetPlayerFromCharacter(model) or Players:FindFirstChild(model.Name) then return end
    
    local HRP = model:WaitForChild("HumanoidRootPart", 5)
    if not HRP then return end
    
    local highlight = model:FindFirstChild("BotHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "BotHighlight"
        highlight.FillColor = Color3.new(1, 0, 0)
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = model
    end

    local bill = HRP:FindFirstChild("BotBillboard")
    if not bill then
        bill = Instance.new("BillboardGui")
        bill.Name = "BotBillboard"
        bill.Size = UDim2.new(4, 0, 1, 0) -- Uses Scale instead of Offset
        bill.StudsOffset = Vector3.new(0, 3, 0)
        bill.AlwaysOnTop = true
        bill.Parent = HRP

        local label = Instance.new("TextLabel")
        label.Name = "BotText"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextScaled = true -- Scales font to fit the billboard size
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
        label.TextColor3 = Color3.new(1, 0, 0)
        label.TextStrokeTransparency = 0
        label.Text = model.Name
        label.Parent = bill
        
        local conn = RunService.RenderStepped:Connect(function()
            if not BotEspVars.Enabled or not model.Parent then return end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (HRP.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                label.Text = string.format("%s [%.1f]", model.Name, math.floor(dist))
            end
        end)
        table.insert(BotEspVars.Connections, conn)
    end
end

local function setupBotEspLoop()
    clearBotEsp()
    if not BotEspVars.Enabled then return end

    local gameFolder = workspace:WaitForChild("Game", 10)
    if not gameFolder then return end
    local playersFolder = gameFolder:WaitForChild("Players", 10)
    if not playersFolder then return end

    for _, model in pairs(playersFolder:GetChildren()) do
        if model:IsA("Model") then
            task.spawn(applyBotEsp, model)
        end
    end

    local addConn = playersFolder.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            task.spawn(applyBotEsp, child)
        end
    end)
    table.insert(BotEspVars.Connections, addConn)
end

botsGroup:CreateToggle({
    Name = "NextBot ESP",
    CurrentValue = false,
    Callback = function(state)
        BotEspVars.Enabled = state
        if state then
            setupBotEspLoop()
        else
            clearBotEsp()
        end
    end
}, 'klay_item_21_esp')

local NBTweaks = { ImageId = "", SoundId = "" }
botsGroup:CreateInput({
    Name = "NextBot Image ID",
    PlaceholderText = "123456",
    RemoveTextAfterFocusLost = false,
    Enter = true,
    Callback = function(v) NBTweaks.ImageId = v end
}, 'klay_item_22')

botsGroup:CreateInput({
    Name = "NextBot Sound ID",
    PlaceholderText = "123456",
    RemoveTextAfterFocusLost = false,
    Enter = true,
    Callback = function(v) NBTweaks.SoundId = v end
}, 'klay_item_23')

botsGroup:CreateButton({
    Name = "Apply Changes",
    Callback = function()
        local playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
        if not playersFolder then return end

        for _, model in pairs(playersFolder:GetChildren()) do
            if model:IsA("Model") then
                local HRP = model:FindFirstChild("HumanoidRootPart")
                if HRP then
                    local sound = HRP:FindFirstChild("Idle")
                    if sound and NBTweaks.SoundId ~= "" then
                        sound.SoundId = "rbxassetid://" .. NBTweaks.SoundId
                    end
                    local billboard = HRP:FindFirstChild("BillboardGui")
                    local imageLabel = billboard and billboard:FindFirstChild("ImageLabel")
                    if imageLabel and NBTweaks.ImageId ~= "" then
                        imageLabel.Image = "rbxassetid://" .. NBTweaks.ImageId
                    end
                end
            end
        end
    end
}, 'klay_item_24')

local SettingsTabs = Window:CreateTabSection("Settings", false)
local interfaceTab = SettingsTabs:CreateTab({ Name = "Interface", Icon = getIcon("settings"), Columns = 2 }, "interface_tab")

interfaceTab:BuildConfigGroupbox(1)
interfaceTab:BuildThemeGroupbox(2)

autoOptionsEnabled = true
loadAutoOptionsConfig()
