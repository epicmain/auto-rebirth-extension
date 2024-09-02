loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/cpuReducer.lua"))()

local RepStor = game:GetService("ReplicatedStorage")
local LocalPlayer = game.Players.LocalPlayer
local maxBreakableDistance = 50  -- 150 is max
-- local hatchAmount = require(RepStor.Library.Client.EggCmds).GetMaxHatch()
-- local bestEggName = 
-- local fastestHatchTime = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Egg Opening Frontend"]).computeSpeedMult() * 2
local timeStart = 0

local fruitCmds = require(RepStor.Library.Client.FruitCmds)
local availableFruits = require(RepStor.Library).Save.Get().Inventory.Fruit
local maxFruit = fruitCmds.ComputeFruitQueueLimit()
local totalCurrentFruits = 0


local function tapAura()
    local playerCFrame = LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
    local nearestBreakable = nil
    repeat 
        nearestBreakable = getsenv(LocalPlayer.PlayerScripts.Scripts.GUIs["Auto Tapper"]).GetNearestBreakable()
        task.wait(0.1)
    until nearestBreakable and nearestBreakable:GetModelCFrame()

    local breakableDistance = (nearestBreakable:GetModelCFrame().Position - playerCFrame.Position).Magnitude
    -- auto break nearby breakables
    if breakableDistance <= maxBreakableDistance then
        RepStor.Network["Breakables_PlayerDealDamage"]:FireServer(nearestBreakable.Name)
    end
end


local function autoFruits()
    -- auto fruits
    local activeFruitTable = {
        ["Apple"] = 0,
        ["Banana"] = 0,
        ["Orange"] = 0,
        ["Pineapple"] = 0,
        ["Watermelon"] = 0,
        ["Rainbow"] = 0
    }  -- stores currently used fruit amounts
    for fruitName, tb in fruitCmds.GetActiveFruits() do
        activeFruitTable[fruitName] = #tb
        totalCurrentFruits = totalCurrentFruits + #tb
    end

    if totalCurrentFruits < (maxFruit * 6) then
        print("Eating Fruits...")
        for fruitId, tb in pairs(availableFruits) do
            task.wait(0.2)
            RepStor:WaitForChild("Network"):WaitForChild("Fruits: Consume"):FireServer(fruitId, maxFruit - activeFruitTable[tb["id"]])
        end
        print("Done Eating Fruits...")
    end
end


-- local function autoHatchWithoutAnimation()
--     -- disable egg hatch animation
--     hookfunction(getsenv(LocalPlayer.PlayerScripts.Scripts.Game["Egg Opening Frontend"]).PlayEggAnimation, function()
--         return
--     end)

--     -- auto hatch with delay
--     if (tick() - timeStart) >= fastestHatchTime then
--         RepStor.Network.Eggs_RequestPurchase:InvokeServer(bestEggName, hatchAmount)
--     end
-- end


-- local function activateUlti()
--     -- activate ultimate
--     local ultiActive = require(RepStor.Library.Client.UltimateCmds).IsCharged("Nightmare")
--     if ultiActive then
--         print("Using Ultimate...")
--         getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs["Ultimates HUD"]).activateUltimate()
--     end
-- end

local function antiAFK()
    -- disable idle tracking event
    LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false
    if getconnections then
        for _, v in pairs(getconnections(LocalPlayer.Idled)) do
            v:Disable()
        end
    else
        LocalPlayer.Idled:Connect(function()
            virtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            task.wait(1)
            virtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
    end
    print("[Anti-AFK Activated!]")
end


maxPetSpeed()
antiAFK()

while true do
    task.wait()
    tapAura()
    -- activateUlti()
    autoFruits()



