local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = ReplicatedStorage:WaitForChild("Library")
local Client = Library:WaitForChild("Client")
local LocalPlayer = game:GetService("Players").LocalPlayer
local myHumanoidRootPart = LocalPlayer.Character.HumanoidRootPart

local maxBreakableDistance = 50  -- 150 is max
local zoneName = require(game:GetService("ReplicatedStorage").Library.Client.ZoneCmds).GetMaxOwnedZone()
local normalOrChest
local Active = game:GetService("Workspace")["__THINGS"]["__INSTANCE_CONTAINER"].Active

repeat
    task.wait()
until #Active:GetChildren() <= 0

local settingsCmds = require(Client.SettingsCmds)

local map = Workspace:WaitForChild("Map")


local PlaceId = game.PlaceId
if PlaceId == 8737899170 then
    map = Workspace.Map
elseif PlaceId == 16498369169 then
    map = Workspace.Map2
end


-- vvv CPU Optimizer vvv
local Terrain = Workspace:WaitForChild("Terrain")
Terrain.WaterReflectance = 0
Terrain.WaterTransparency = 1
Terrain.WaterWaveSize = 0
Terrain.WaterWaveSpeed = 0

local Lighting = game:GetService("Lighting")
Lighting.Brightness = 0
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e100
Lighting.FogStart = 0

game:GetService("Lighting"):ClearAllChildren()
print("Clearing lightnings")


local function clearTextures(v)
    if v:IsA("BasePart") and not v:IsA("MeshPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
        v.Transparency = 1
    elseif (v:IsA("Decal") or v:IsA("Texture")) then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("MeshPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
        v.TextureID = 10385902758728957
    elseif v:IsA("SpecialMesh") then
        v.TextureId = 0
    elseif v:IsA("ShirtGraphic") then
        v.Graphic = 1
    elseif (v:IsA("Shirt") or v:IsA("Pants")) then
        v[v.ClassName .. "Template"] = 1
    elseif v.Name == "Foilage" and v:IsA("Folder") then
        v:Destroy()
    elseif string.find(v.Name, "Tree") or string.find(v.Name, "Bush") or string.find(v.Name, "grass") then
        task.wait()
        v:Destroy()
    end
end


for _, v in pairs(game:GetService("Workspace"):FindFirstChild("__THINGS"):GetChildren()) do
    if table.find({"Ornaments", "Ski Chairs", "ShinyRelics"}, v.Name) then
        v:Destroy()
    end
end

-- Pet speed 200%
require(Client.PlayerPet).CalculateSpeedMultiplier = function(...)
    return 200
end


for _, lootbag in pairs(Workspace.__THINGS:FindFirstChild("Lootbags"):GetChildren()) do
    task.wait(0.2)
    if lootbag then
        ReplicatedStorage.Network:WaitForChild("Lootbags_Claim"):FireServer(unpack( { [1] = { [1] = lootbag.Name, }, } ))
        lootbag:Destroy()
    end
end

Workspace.__THINGS:FindFirstChild("Lootbags").ChildAdded:Connect(function(lootbag)
    task.wait(0.2)
    if lootbag then
        ReplicatedStorage.Network:WaitForChild("Lootbags_Claim"):FireServer(unpack( { [1] = { [1] = lootbag.Name, }, } ))
        lootbag:Destroy()
    end
end)

local orb = require(game:GetService("ReplicatedStorage").Library.Client.OrbCmds.Orb)

orb.DefaultPickupDistance = 0  -- slowly comes to player, disable
orb.CollectDistance = 100  -- insane instant magnet
orb.BillboardDistance = 0  -- disables gui showing collected coins
orb.SoundDistance = 0
orb.CombineDelay = 0
orb.CombineDistance = 400

-- Settings toggling not working.
print(require(Client.SettingsCmds).Get("PotatoMode"))
if settingsCmds.Get("PotatoMode") == "On" then
    -- turn off and on for it to work
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Toggle Setting"):InvokeServer("PotatoMode")
    task.wait(1)
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Toggle Setting"):InvokeServer("PotatoMode")
else
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Toggle Setting"):InvokeServer("PotatoMode")
end


hookfunction(getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Breakables["Breakables Frontend"]).updateBreakable, function()
    return
end)

hookfunction(require(game:GetService("ReplicatedStorage").Library.Client.PlayerPet).SetTarget, function()
    return
end)

hookfunction(require(game:GetService("ReplicatedStorage").Library.Client.OrbCmds.Orb).RenderParticles, function()
    return
end)

hookfunction(require(game:GetService("ReplicatedStorage").Library.Client.OrbCmds.Orb).SimulatePhysics, function()
    return
end)


print("PetSFX")
if settingsCmds.Get("PetSFX") == "On" then
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Toggle Setting"):InvokeServer("PetSFX")
end

print("calling p function")
pcall(function()
    game:GetService("Workspace").ALWAYS_RENDERING:Destroy()

    for i, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v:IsA("ScreenGui") then
            v.Enabled = false
        end
    end

    -- Disables 3D Rendering (Whitescreen)
    -- local RunService = game:GetService("RunService")
    -- RunService:Set3dRenderingEnabled(false)
    print("after coregui runservice")
    
    sethiddenproperty(Lighting, "Technology", 2)
    sethiddenproperty(Terrain, "Decoration", false)
end)

print("screengui")
for i,v in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
    if v:IsA("ScreenGui") then
        v.Enabled = false
    end
end

for i,v in pairs(game.Players.LocalPlayer.PlayerGui._MACHINES:GetChildren()) do
    if v:IsA("ScreenGui") then
        v.Enabled = false
    end
end


-- Clearing Textures to optimize CPU
for _, v in pairs(Workspace:GetDescendants()) do
    clearTextures(v)
end

Workspace.DescendantAdded:Connect(function(v)
    task.wait()
    clearTextures(v)
end)

-- disable starter gui
for i, v in pairs(game:GetService("StarterGui"):GetChildren()) do
    if v:IsA("ScreenGui") then
        v.Enabled = false
    end
end

-- make all player invisible
for _, v in pairs(game.Players:GetChildren()) do
    for _, v2 in pairs(v.Character:GetDescendants()) do
        if v2:IsA("BasePart") or v2:IsA("Decal") then
            v2.Transparency = 1
        end
    end
end

print("Done Clearing")


local function len(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

local function tapAura()
    local nearestBreakable = nil
    repeat 
        nearestBreakable = getsenv(LocalPlayer.PlayerScripts.Scripts.GUIs["Auto Tapper"]).GetNearestBreakable()
        task.wait()
    until nearestBreakable and nearestBreakable:GetModelCFrame()

    local breakableDistance = (nearestBreakable:GetModelCFrame().Position - myHumanoidRootPart.CFrame.Position).Magnitude
    -- auto break nearby breakables
    if breakableDistance <= maxBreakableDistance then
        ReplicatedStorage.Network["Breakables_PlayerDealDamage"]:FireServer(nearestBreakable.Name)
    end
end

local function activateUlti()
    -- activate ultimate
    local ultiActive = require(ReplicatedStorage.Library.Client.UltimateCmds).IsCharged("Ground Pound")
    if ultiActive then
        getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs["Ultimates HUD"]).activateUltimate()
    end
end

local function antiAFK()
    -- disable idle tracking event
    LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false
    if getconnections then
        for _, v in pairs(getconnections(LocalPlayer.Idled)) do
            v:Disable()
        end
    else
        LocalPlayer.Idled:Connect(function()
            virtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            virtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
    print("[Anti-AFK Activated!]")
end

local function petTargetEventAndBreakables(zone)
    local chest
    local normal = {}
    for v in require(Client.BreakableCmds).AllByZoneAndClass(zone, normalOrChest) do
        if normalOrChest == "Chest" then
            chest = v
        else
            table.insert(normal, v)
        end
    end

    local normalNum = 0
    local args = {
        [1] = {}
    }
    for petId, _ in pairs(require(game:GetService("ReplicatedStorage").Library.Client.PlayerPet).GetAll()) do
        normalNum = normalNum + 1
        if normalOrChest == "Chest" then 
            args[1][petId] = chest
        else
            args[1][petId] = normal[normalNum]
        end
    end
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk"):FireServer(unpack(args))
end

antiAFK()


while true do
    task.wait(0.25)
    local activeChild = #Active:GetChildren()
    if activeChild == 0 then
        tapAura()
        activateUlti()
        if len(require(Client.BreakableCmds).AllByZoneAndClass(zoneName, "Chest")) >= 1 then
            normalOrChest = "Chest"
            petTargetEventAndBreakables(zoneName)
        else
            normalOrChest = "Normal"
            petTargetEventAndBreakables(zoneName)
        end
    end
end


for x, y in game:GetService("Workspace")["__THINGS"].Orbs:FindChildren() do
    game.ReplicatedStorage.Network:FindFirstChild("Orbs: Collect"):FireServer(unpack( { [1] = { [1] = tonumber(y.Name), }, } ))
end
