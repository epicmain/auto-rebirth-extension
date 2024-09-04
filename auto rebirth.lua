loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/waitForGameLoad.lua"))()
print("rebirth started.")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")

local map
local PlaceId = game.PlaceId
if PlaceId == 8737899170 then
    map = Workspace.Map
elseif PlaceId == 16498369169 then
    map = Workspace.Map2
end

local clientSave = require(game:GetService("ReplicatedStorage").Library.Client.Save).Get()
local unfinished = true
local currentZone

-- vvv Egg hatching variables vvv
local mainEggs = game:GetService("Workspace")["__THINGS"].Eggs.Main
local lowestNumberEgg = nil
local timeStart = tick()
local fastestHatchTime = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Egg Opening Frontend"]).computeSpeedMult() * 2
local hatchAmount = require(game:GetService("ReplicatedStorage").Library.Client.EggCmds).GetMaxHatch()
local eggData
local eggCFrame
-- ^^^ Egg hatching variables ^^^

-- vvv Fruit variables vvv
local fruitCmds = require(game:GetService("ReplicatedStorage").Library.Client.FruitCmds)
local inventoryFruit = clientSave.Inventory.Fruit
local emptyFruits = {}
local fruitId = {}
local uneatenFruits = {}
-- ^^^ Fruit variables ^^^

local giftTiming = {
    [1] = 300,
    [2] = 600,
    [3] = 900,
    [4] = 1200,
    [5] = 1800,
    [6] = 2400,
    [7] = 3000,
    [8] = 3600,
    [9] = 4500,
    [10] = 5400,
    [11] = 7200,
    [12] = 10800
}

require(ReplicatedStorage.Library.Client.PlayerPet).CalculateSpeedMultiplier = function(...)
    return 200
end

local function teleportToMaxZone()
    print("in teleportToMaxZone()")
    local zoneName, maxZoneData = require(ReplicatedStorage.Library.Client.ZoneCmds).GetMaxOwnedZone()
    print(zoneName)
    print(currentZone)
    while currentZone == zoneName do
        zoneName, maxZoneData = require(ReplicatedStorage.Library.Client.ZoneCmds).GetMaxOwnedZone()
        task.wait()
    end
    currentZone = zoneName
    print("Teleporting to zone: " .. zoneName)

    local zonePath
    for _, v in pairs(map:GetChildren()) do
        if string.find(v.Name, tostring(maxZoneData.ZoneNumber) .. " | " .. zoneName) then
            zonePath = v
        end
    end
    LocalPlayer.Character.HumanoidRootPart.CFrame = zonePath:WaitForChild("PERSISTENT").Teleport.CFrame + Vector3.new(0, 10, 0)
    task.wait()

    if not zonePath:FindFirstChild("INTERACT") then
        local loaded = false
        local detectLoad = zonePath.ChildAdded:Connect(function(child)
            if child.Name == "INTERACT" then
                loaded = true
            end
        end)

        repeat
            task.wait()
        until loaded

        detectLoad:Disconnect()
    end

    local dist = 999
    local closestBreakZone = nil
    for _, v in pairs(zonePath.INTERACT.BREAK_ZONES:GetChildren()) do
        local magnitude = (LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude
        if magnitude <= dist then
            dist = magnitude
            closestBreakZone = v
        end
    end

    LocalPlayer.Character.HumanoidRootPart.CFrame = closestBreakZone.CFrame + Vector3.new(0, 10, 0)

    if maxZoneData.ZoneNumber >= getgenv().autoWorldConfig.ZONE_TO_REACH then
        print("Reached selected zone")
        unfinished = false
    end
end


-- Function to extract numeric values from a string
local function extractNumber(str)
    return tonumber(str:match("%d+")) or math.huge  -- Return a large number if no digits are found
end


local function getEgg()
    lowestNumberEgg = require(game:GetService("ReplicatedStorage").Library.Client.Save).Get().MaximumAvailableEgg
    
    while true do
        local eggData = require(game:GetService("ReplicatedStorage").Library.Util.EggsUtil).GetByNumber(lowestNumberEgg - 1)
        if eggData then
            print(eggData.name)
            print(eggData.eggNumber)
            return eggData
        else
            print("NO BEST EGG FOUND!")
            break
        end
    end
    return nil
end


local function autoHatchWithoutAnimation(eggData)
    -- disable egg hatch animation
    hookfunction(getsenv(game.Players.LocalPlayer.PlayerScripts.Scripts.Game["Egg Opening Frontend"]).PlayEggAnimation, function()
        return
    end)

    -- auto hatch with delay
    if (tick() - timeStart) >= fastestHatchTime then
        timeStart = tick()
        game:GetService("ReplicatedStorage").Network.Eggs_RequestPurchase:InvokeServer(eggData.name, hatchAmount)
    end
end


local function teleportAndHatch()
    currentZone = nil  -- reset current zone to teleport back smoothly
    eggData = getEgg()
    -- Teleport to Egg
    for _, v in pairs(game:GetService("Workspace").__THINGS.Eggs.Main:GetChildren()) do
        if string.find(v.Name, tostring(eggData.eggNumber) .. " - ") then
            eggCFrame = v.Tier.CFrame + Vector3.new(0, 10, 0)
        end
    end
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = eggCFrame  -- Teleport to egg

    -- Hatch eggs
    for i=1, 10 do
        autoHatchWithoutAnimation(eggData)
        task.wait(fastestHatchTime)
    end

    print("Done Hatching...")
end


local function removeValue(t, value)
    for i, v in ipairs(t) do
        if v == value then
            table.remove(t, i)
            break  -- Exit the loop after removing the value
        end
    end
end


local function checkFruitEmpty(key)
    for _, name in pairs(emptyFruits) do 
        if name == key then
            return true
        end
    end
end


local function checkAndEatFruits()
    -- update encrypted fruitId
    for key, value in pairs(inventoryFruit) do
        fruitId[value["id"]] = key
    end

    -- check if 0 fruit
    for fruitId, value in pairs(inventoryFruit) do
        local length = 0
        for _ in pairs(value) do
            length = length + 1
        end
        if length == 1 then
            -- value["id"] is name of fruit
            table.insert(emptyFruits, value["id"])
        end
    end

    uneatenFruits = {"Orange", "Pineapple", "Apple", "Banana", "Rainbow", "Watermelon"}
    for fruitName, value in pairs(fruitCmds.GetActiveFruits()) do 
        removeValue(uneatenFruits, fruitName)
        if #value["Normal"] < fruitCmds.ComputeFruitQueueLimit() then  -- if current fruit queue not max, eat
            -- check if fruit is available
            if checkFruitEmpty(fruitName) ~= true then
                fruitCmds.Consume(fruitId[fruitName])
                task.wait(1)
            end
        end
    end

    -- Eat any fruits that are not in queue
    for _, fruitName in pairs(uneatenFruits) do
        if checkFruitEmpty(fruitName) ~= true then
            fruitCmds.Consume(fruitId[fruitName])
            task.wait(1)
        end
    end
    print('Done eating fruits...')
end


local function checkAndRedeemGift()
    for giftIndex, seconds in pairs(giftTiming) do
        if clientSave.FreeGiftsTime >= seconds then
            print("Redeeming Gift ", giftIndex)
            game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Redeem Free Gift"):InvokeServer(giftIndex)
            task.wait(2) -- wait to collect gifts properly
        else
            break
        end
    end

    for i, _ in pairs(clientSave.FreeGiftsRedeemed) do
        if giftTiming[clientSave.FreeGiftsRedeemed[i]] ~= nil then
            giftTiming[clientSave.FreeGiftsRedeemed[i]] = nil
        end
    end
end


for _, lootbag in pairs(Workspace.__THINGS:FindFirstChild("Lootbags"):GetChildren()) do
    if lootbag then
        ReplicatedStorage.Network:WaitForChild("Lootbags_Claim"):FireServer(unpack( { [1] = { [1] = lootbag.Name, }, } ))
        lootbag:Destroy()
        task.wait()
    end
end

Workspace.__THINGS:FindFirstChild("Lootbags").ChildAdded:Connect(function(lootbag)
    task.wait()
    if lootbag then
        ReplicatedStorage.Network:WaitForChild("Lootbags_Claim"):FireServer(unpack( { [1] = { [1] = lootbag.Name, }, } ))
        lootbag:Destroy()
    end
end)

Workspace.__THINGS:FindFirstChild("Orbs").ChildAdded:Connect(function(orb)
    task.wait()
    if orb then
        ReplicatedStorage.Network:FindFirstChild("Orbs: Collect"):FireServer(unpack( { [1] = { [1] = tonumber(orb.Name), }, } ))
        orb:Destroy()
    end
end)

game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("ForeverPacks: Claim Free"):InvokeServer("Default")  -- collect free foreverpack



local nextRebirthData = require(game:GetService("ReplicatedStorage").Library.Client.RebirthCmds).GetNextRebirth()
local rebirthNumber
local rebirthZone
local startAutoHatchEggDelay = tick()
local autoHatchEggDelay = 180

if nextRebirthData then
    rebirthNumber = nextRebirthData.RebirthNumber
    rebirthZone = nextRebirthData.ZoneNumberRequired
end

task.spawn(function()
    print("Starting zone purchase service")
    while unfinished do
        local nextZoneName, nextZoneData = require(game:GetService("ReplicatedStorage").Library.Client.ZoneCmds).GetNextZone()
        local success, _ = game:GetService("ReplicatedStorage").Network.Zones_RequestPurchase:InvokeServer(nextZoneName)
        if success then
            lowestNumberEgg = nil
            print("Successfully purchased " .. nextZoneName)
            if getgenv().autoWorldConfig.AUTO_REBIRTH then
                pcall(function()
                    if nextZoneData.ZoneNumber >= rebirthZone then
                        print("Rebirthing")
                        game:GetService("ReplicatedStorage").Network.Rebirth_Request:InvokeServer(tostring(rebirthNumber))
                        task.wait(15)
                        nextRebirthData = require(game:GetService("ReplicatedStorage").Library.Client.RebirthCmds).GetNextRebirth()
                        if nextRebirthData then
                            rebirthNumber = nextRebirthData.RebirthNumber
                            rebirthZone = nextRebirthData.ZoneNumberRequired
                        end
                    end
                end)
            end
            teleportToMaxZone()
            task.wait(30)
            teleportAndHatch()
            print("Teleporting To Max Zone After Hatching.")
            teleportToMaxZone()
            startAutoHatchEggDelay = tick()
        end
        if (tick() - startAutoHatchEggDelay) >= autoHatchEggDelay then
            teleportAndHatch()
            print("Teleporting To Max Zone After Hatching.")
            teleportToMaxZone()
            startAutoHatchEggDelay = tick()
        end
        checkAndEatFruits()
        checkAndRedeemGift()
        task.wait(getgenv().autoWorldConfig.PURCHASE_CHECK_DELAY)
    end
end)

teleportToMaxZone()
