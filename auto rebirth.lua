loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/waitForGameLoad.lua"))()
print("Updated hatching.")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = ReplicatedStorage:WaitForChild("Library")
local Client = Library.Client
local LocalPlayer = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")

local map
local PlaceId = game.PlaceId
if PlaceId == 8737899170 then
    map = Workspace.Map
elseif PlaceId == 16498369169 then
    map = Workspace.Map2
end

local rankCmds = require(Client.RankCmds)
local currencyCmds = require(Client.CurrencyCmds)
local zoneCmds = require(Client.ZoneCmds)
local clientSaveGet = require(Client.Save).Get()
local inventory = clientSaveGet.Inventory
local unfinished = true
local currentZone
local rebirthCmds = require(Client.RebirthCmds)
local hypeCmds = require(Client.HypeEventCmds)
local nextRebirthData = rebirthCmds.GetNextRebirth()
local rebirthNumber
local rebirthZone
local originalPosition

local startAutoHatchEggDelay = tick()
local autoHatchEggDelay = 120

-- vvv Egg hatching variables vvv
local bestEgg = nil
local timeStart = tick()
local fastestHatchTime = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Egg Opening Frontend"]).computeSpeedMult() * 2
local currentMaxHatch = require(Client.EggCmds).GetMaxHatch()
local eggData
local eggCFrame
local maxHatchAmount = 10
local eggHatchedBefore = 0
-- ^^^ Egg hatching variables ^^^

--- vvv EggSlot variables vvv
local currentEggSlots
local currentmaxPurchaseableEggs = rankCmds.GetMaxPurchasableEggSlots()
local eggSlotTimeStart = tick()
local checkEggSlotDelay = 5 -- time it will wait before checking your gem count again
local MAX_EGG_SLOTS = 10
-- ^^^ EggSlot variables ^^^

--- vvv Pet slot variables vvv
local currentEquipSlots
local currentmaxPurchaseableEquips = rankCmds.GetMaxPurchasableEquipSlots()
local checkPetSlotDelay = 5
local petEquipSlotTimeStart = tick()
local MAX_PET_SLOTS = 35
--- ^^^ Pet slot variables ^^^

-- vvv Fruit variables vvv
local fruitInventory = clientSaveGet.Inventory.Fruit -- id and _am
local fruitCmds = require(Client.FruitCmds)
local maxFruitQueue = fruitCmds.ComputeFruitQueueLimit()
-- local activeFruits = require(Client.FruitCmds).GetActiveFruits() -- returns nested table active fruits .Normal .Shiny
-- ^^^ Fruit variables ^^^

-- vvv Auto potions variables vvv
local potionCmds = require(Client.PotionCmds)
local highestTierPotion = 0
local highestTierPotionId = nil
local unconsumedPotions -- Diamonds, Treasure Hunter, Damage, Lucky, Coins ... Walkspeed is useless
-- ^^^ Auto potions variables ^^^

-- vvv Enchant variables vvv
local enchantCmds = require(Client.EnchantCmds)
local enchantEquipTimeStart = tick()
local equipEnchantDelay = 60
local enchantIdToName
local enchants = {
    [1] = "Tap Power", 
    [2] = "Coins", 
    [3] = "Tap Power", 
    [4] = "Coins", 
    [5] = "Treasure Hunter"
}
local bestEnchants = {
    ["Coins"] = {["tier"] = 0, ["id"] = ""},
    ["Tap Power"] = {["tier"] = 0, ["id"] = ""},
    ["Criticals"] = {["tier"] = 0, ["id"] = ""},
    ["Diamonds"] = {["tier"] = 0, ["id"] = ""},
    ["Lucky Eggs"] = {["tier"] = 0, ["id"] = ""},
    ["Strong Pets"] = {["tier"] = 0, ["id"] = ""},
    ["Treasure Hunter"] = {["tier"] = 0, ["id"] = ""}
}
-- ^^^ Enchant variables ^^^

-- vvv Upgrades variables vvv
local upgradeCmds = require(game:GetService("ReplicatedStorage").Library.Client.UpgradeCmds)
local MAX_UPGRADE_GEM = 20000
-- ^^^ Upgrades variables ^^^

local buffCmds = require(Client.BuffCmds)


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


local eggSlotDiamondCost = {
    [1] = 150,
    [2] = 300,
    [3] = 600,
    [4] = 900,
    [5] = 1350,
    [6] = 1800,
    [7] = 2400,
    [8] = 3000,
    [9] = 3600,
    [10] = 4200,
    [12] = 10600,
    [14] = 13600,
    [16] = 16600,
    [18] = 20100,
    [20] = 23700,
    [22] = 27300,
    [24] = 30900,
    [26] = 34500,
    [28] = 38500,
    [30] = 42700,
    [33] = 72000,
    [34] = 26100,
    [37] = 85500,
    [40] = 96300,
    [43] = 107000,
    [46] = 117000,
    [49] = 128000,
    [52] = 750000,
    [55] = 1200000,
    [58] = 1650000,
    [61] = 2100000,
    [64] = 2550000,
    [67] = 3000000,
    [68] = 1100000,
    [69] = 1150000,
    [70] = 1200000,
    [71] = 1250000,
    [72] = 1250000,
    [73] = 1300000,
    [74] = 1350000,
    [75] = 1400000,
    [76] = 1450000,
    [77] = 1500000,
    [78] = 1550000,
    [79] = 1600000,
    [80] = 1650000
}


local petSlotDiamondCost = {
    [1] = 250,
    [2] = 500,
    [3] = 750,
    [4] = 1000,
    [5] = 1250,
    [6] = 1500,
    [7] = 1750,
    [8] = 2000,
    [9] = 2250,
    [10] = 2500,
    [11] = 2750,
    [12] = 3000,
    [13] = 3250,
    [14] = 3500,
    [15] = 3750,
    [16] = 4000,
    [17] = 4250,
    [18] = 4500,
    [19] = 4750,
    [20] = 5000,
    [21] = 5250,
    [22] = 5500,
    [23] = 5750,
    [24] = 6000,
    [25] = 6250,
    [26] = 7000,
    [27] = 8500,
    [28] = 10000,
    [29] = 15000,
    [30] = 20000,
    [31] = 30000,
    [32] = 35000,
    [33] = 45000,
    [34] = 60000,
    [35] = 70000,
    [36] = 85000,
    [37] = 100000,
    [38] = 100000,
    [39] = 150000,
    [40] = 150000,
    [41] = 200000,
    [42] = 200000,
    [43] = 250000,
    [44] = 250000,
    [45] = 300000,
    [46] = 300000,
    [47] = 350000,
    [48] = 400000,
    [49] = 400000,
    [50] = 450000,
    [51] = 500000,
    [52] = 550000,
    [53] = 600000,
    [54] = 650000,
    [55] = 700000,
    [56] = 750000,
    [57] = 800000,
    [58] = 850000,
    [59] = 900000,
    [60] = 950000,
    [61] = 1000000,
    [62] = 1050000,
    [63] = 1100000,
    [64] = 1150000,
    [65] = 1200000,
    [66] = 1250000,
    [67] = 1300000,
    [68] = 1350000,
    [69] = 1400000,
    [70] = 1450000,
    [71] = 1500000,
    [72] = 1550000,
    [73] = 1600000,
    [74] = 1650000,
    [75] = 1700000,
    [76] = 1750000,
    [77] = 1800000,
    [78] = 1850000,
    [79] = 1900000,
    [80] = 1950000
}


local upgrades = {
    {"Walkspeed", 2, "Colorful Forest", 30},
    {"Magnet", 3, "Castle", 100},
    {"Diamonds", 4, "Green Forest", 200},
    {"Walkspeed", 6, "Cherry Blossom", 150},
    {"Tap Damage", 8, "Backyard", 300},
    {"Diamonds", 10, "Mine", 400},
    {"Pet Speed", 12, "Dead Forest", 500},
    {"Magnet", 14, "Mushroom Field", 800},
    {"Drops", 16, "Crimson Forest", 650},
    {"Pet Damage", 18, "Jungle Temple", 700},
    {"Diamonds", 20, "Beach", 900},
    {"Luck", 22, "Shipwreck", 1000},
    {"Magnet", 24, "Palm Beach", 2000},
    {"Coins", 26, "Pirate Cove", 1250},
    {"Tap Damage", 28, "Shanty Town", 1500},
    {"Pet Speed", 30, "Fossil Digsite", 1250},
    {"Diamonds", 33, "Wild West", 2000},
    {"Pet Damage", 36, "Mountains", 2500},
    {"Coins", 40, "Ski Town", 2750},
    {"Drops", 44, "Obsidian Cave", 3000},
    {"Magnet", 47, "Underworld Bridge", 4000},
    {"Luck", 49, "Metal Dojo", 4500},
    {"Pet Damage", 51, "Samurai Village", 7500},
    {"Tap Damage", 53, "Zen Garden", 8000},
    {"Pet Speed", 56, "Fairytale Castle", 5500},
    {"Luck", 58, "Fairy Castle", 7500},
    {"Coins", 60, "Rainbow River", 7500},
    {"Magnet", 63, "Frost Mountains", 6000},
    {"Diamonds", 66, "Ice Castle", 12000},
    {"Drops", 68, "Firefly Cold Forest", 15000},
    {"Tap Damage", 74, "Witch Marsh", 17500},
    {"Luck", 77, "Haunted Mansion", 25000},
    {"Magnet", 80, "Treasure Dungeon", 35000},
    {"Coins", 84, "Gummy Forest", 45000},
    {"Pet Speed", 88, "Carnival", 60000},
    {"Pet Damage", 93, "Cloud Houses", 75000},
    {"Diamonds", 98, "Colorful Clouds", 100000}
}



local function len(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end


local function teleportToMaxZone()
    print("in teleportToMaxZone()")

    local zoneName, maxZoneData = zoneCmds.GetMaxOwnedZone()
    print("Teleporting to: ", zoneName)
    while currentZone == zoneName do
        zoneName, maxZoneData = zoneCmds.GetMaxOwnedZone()
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
        print(magnitude)
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


local function teleportToEggMachine()
    local zonePath = Workspace.Map["8 | Backyard"]
    -- teleport to zone first to load eggmachine cframe
    LocalPlayer.Character.HumanoidRootPart.CFrame = zonePath.PERSISTENT.Teleport.CFrame
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

    LocalPlayer.Character.HumanoidRootPart.CFrame = zonePath.INTERACT.Machines.EggSlotsMachine.PadGlow.CFrame
end


local function teleportToPetEquipMachine()
    local zonePath = Workspace.Map["4 | Green Forest"]
    LocalPlayer.Character.HumanoidRootPart.CFrame = zonePath.PERSISTENT.Teleport.CFrame
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

    LocalPlayer.Character.HumanoidRootPart.CFrame = zonePath.INTERACT.Machines.EquipSlotsMachine.PadGlow.CFrame
end


local function checkAndPurchaseEggSlot()
    if (tick() - eggSlotTimeStart) >= checkEggSlotDelay then
        currentEggSlots = clientSaveGet.EggSlotsPurchased

        -- if 0 to 9, 33, 67 to 79 -> +1 to currentEggSlots
        -- if 10 to 28 -> +2 to currentEggSlots
        -- if 30, 34 to 64 -> +3 to currentEggSlots
        if (currentEggSlots <= 9) or (currentEggSlots == 33) or (currentEggSlots >= 67 and currentEggSlots <= 79) then
            currentEggSlots = currentEggSlots + 1
        elseif (currentEggSlots >= 10 and currentEggSlots <= 28) then
            currentEggSlots = currentEggSlots + 2
        elseif (currentEggSlots == 30) or (currentEggSlots >= 34 and currentEggSlots <= 64) then
            currentEggSlots = currentEggSlots + 3
        else
            print("CANT FIND currentEggSlots!!!")
        end

        -- check if can afford egg slot
        if currencyCmds.Get("Diamonds") >= eggSlotDiamondCost[currentEggSlots] then
            if currentEggSlots < rankCmds.GetMaxPurchasableEggSlots() and currentEggSlots <= MAX_EGG_SLOTS then
                originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
                print("Buying slot " .. tostring(currentEggSlots) .. " for " .. tostring(eggSlotDiamondCost[currentEggSlots]) .. " diamonds")

                teleportToEggMachine()

                task.wait(1)

                local args = {
                    [1] = currentEggSlots
                }

                ReplicatedStorage.Network.EggHatchSlotsMachine_RequestPurchase:InvokeServer(unpack(args))

                print("Purchased egg slot " .. tostring(currentEggSlots))
                task.wait(1)
                LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
            end
        end
        eggSlotTimeStart = tick() -- restart timer
    end
end


local function checkAndPurchasePetSlot()
    if (tick() - petEquipSlotTimeStart) >= checkPetSlotDelay then 
        currentEquipSlots = clientSaveGet.PetSlotsPurchased + 1
        if currencyCmds.Get("Diamonds") >= petSlotDiamondCost[currentEquipSlots] then
            if currentEquipSlots < rankCmds.GetMaxPurchasableEquipSlots() and currentEquipSlots <= MAX_PET_SLOTS then
                originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
                print("Buying slot " .. tostring(currentEquipSlots) .. " for " .. tostring(petSlotDiamondCost[currentEquipSlots]) .. " diamonds")

                teleportToPetEquipMachine()

                task.wait(1)

                local args = {
                    [1] = currentEquipSlots
                }
                ReplicatedStorage.Network.EquipSlotsMachine_RequestPurchase:InvokeServer(unpack(args))
                currentEquipSlots = currentEquipSlots

                print("Purchased pet equip slot " .. tostring(currentEquipSlots))
                task.wait(1)
                LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
            end
        end
        petEquipSlotTimeStart = tick()
    end
end


-- Function to extract numeric values from a string
local function extractNumber(str)
    return tonumber(str:match("%d+")) or math.huge  -- Return a large number if no digits are found
end


-- Still need an update to overwrite and consume best potion
local function findUnconsumedPotions()
    unconsumedPotions = {"Diamonds", "Treasure Hunter", "Damage", "Lucky", "Coins"}
    for i = #unconsumedPotions, 1, -1 do -- Loop backward so index wouldnt mess up when removing
        if not (potionCmds.GetActivePotions()[unconsumedPotions[i]] == nil) then
            if len(potionCmds.GetActivePotions()[unconsumedPotions[i]]) > 0 then
                table.remove(unconsumedPotions, i)
            end
        end
    end
end


local function findBestEnchantTier()
    for enchantId, tbl in pairs(inventory.Enchant) do
        if tbl.id == "Coins" or tbl.id == "Tap Power" or tbl.id == "Criticals" or tbl.id == "Diamonds" or 
        tbl.id == "Lucky Eggs" or tbl.id == "Strong Pets" or tbl.id == "Treasure Hunter" then
            if bestEnchants[tbl.id]["tier"] < tbl.tn then
                bestEnchants[tbl.id]["tier"] = tbl.tn
                bestEnchants[tbl.id]["id"] = enchantId
            end
        end
    end
end


local function checkAndEquipBestSpecifiedEnchants()
    findBestEnchantTier()
    if (tick() - enchantEquipTimeStart) >= equipEnchantDelay then 
        for enchantSlotNumber, enchantName in pairs(enchants) do
            task.wait(0.1)
            if enchantSlotNumber <= clientSaveGet.MaxEnchantsEquipped then
                local redo = true
                -- 1. Check if equipped with best tier, 2. if not equipped, try to equip
                if clientSaveGet.EquippedEnchants[tostring(enchantSlotNumber)] == bestEnchants[enchantName]["id"] then  -- EquippedEnchants[string number]
                    print("Best enchant: ", enchantName, " already equipped.")
                else
                    print("No best enchant found for slot ", enchantSlotNumber)
                    enchantCmds.Unequip(enchantSlotNumber)
                    task.wait(1)
                    enchantCmds.Equip(bestEnchants[enchantName]["id"])
                    task.wait(1)
                    if clientSaveGet.EquippedEnchants[tostring(enchantSlotNumber)] == bestEnchants[enchantName]["id"] then
                        print("Empty slot equipped ", enchantName)
                    else
                        local secondaryBestEnchantTier = bestEnchants[enchantName]["tier"]
                        while redo do
                            secondaryBestEnchantTier = secondaryBestEnchantTier - 1 -- best enchant for the other slot that wanted the same enchant
                            
                            if secondaryBestEnchantTier >= 1 then -- if its more than tier 1, continue
                                for enchantId, tbl in pairs(inventory.Enchant) do
                                    if tbl.id == "Coins" or tbl.id == "Tap Power" or tbl.id == "Criticals" or tbl.id == "Diamonds" or 
                                    tbl.id == "Lucky Eggs" or tbl.id == "Strong Pets" or tbl.id == "Treasure Hunter" then

                                        if tbl.tn == secondaryBestEnchantTier and tbl.id == enchantName then -- if tier found in inventory same as downgraded tier, equip it
                                            print(tbl.id)
                                            enchantCmds.Unequip(enchantSlotNumber)
                                            enchantCmds.Equip(enchantId)
                                            redo = false
                                            break
                                        end
                                    end
                                end
                            else
                                print("No enchant found for ", enchantSlotNumber, " slot.")
                                redo = false
                            end
                        end
                    end
                end
            end
        end
        enchantEquipTimeStart = tick()
    end
end


-- update upgrades to only purchase if pet/egg slots are max/specific max
local function checkAndPurchaseUpgrades()
    local zonePath
    local zoneName, zoneData = zoneCmds.GetMaxOwnedZone()
    -- Reverse iterate through the upgrades table
    for i = #upgrades, 1, -1 do
        local upgrade = upgrades[i]
        local ability = upgrade[1]
        local areaNumber = upgrade[2]
        local mapName = upgrade[3]
        local gemAmount = upgrade[4]

        -- logic for processing upgrades
        if areaNumber < zoneData.ZoneNumber then
            if upgradeCmds.Owns(ability, mapName) then
                table.remove(upgrades, i)
            elseif not upgradeCmds.Owns(ability, mapName) and currencyCmds.Get("Diamonds") > gemAmount and gemAmount < MAX_UPGRADE_GEM then
                originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame -- save original position
                -- Teleport to zone so it can detect if owned, if too far it will detect false.
                for _, v in pairs(map:GetChildren()) do
                    if string.find(v.Name, tostring(areaNumber) .. " | " .. mapName) then
                        zonePath = v
                    end
                end
                LocalPlayer.Character.HumanoidRootPart.CFrame = zonePath:WaitForChild("PERSISTENT").Teleport.CFrame + Vector3.new(0, 10, 0)
                for _, v in pairs(zonePath:WaitForChild("INTERACT").Upgrades:GetChildren()) do
                    LocalPlayer.Character.HumanoidRootPart.CFrame = v.Center.CFrame + Vector3.new(0, 10, 0)
                    task.wait(1)
                end

                -- Check if owned or affordable
                if not upgradeCmds.Owns(ability, mapName) and currencyCmds.Get("Diamonds") > gemAmount then
                    task.wait(1)
                    print("Bought " .. ability .. " from " .. mapName)
                    upgradeCmds.Purchase(ability, mapName)
                    table.remove(upgrades, i)
                    task.wait(1)
                    LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
                elseif upgradeCmds.Owns(ability, mapName) then
                    table.remove(upgrades, i)
                    task.wait(1)
                    LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
                end
            end  
        end
    end
end


local function autoHatchWithoutAnimation()
    -- disable egg hatch animation
    hookfunction(getsenv(game.Players.LocalPlayer.PlayerScripts.Scripts.Game["Egg Opening Frontend"]).PlayEggAnimation, function()
        return
    end)

    -- auto hatch with delay
    if (tick() - timeStart) >= fastestHatchTime then
        timeStart = tick()
        if currentMaxHatch <= maxHatchAmount then
            ReplicatedStorage.Network.Eggs_RequestPurchase:InvokeServer(eggData.name, currentMaxHatch)
        else
            ReplicatedStorage.Network.Eggs_RequestPurchase:InvokeServer(eggData.name, maxHatchAmount)
        end
    end
end


-- local function getBestEggData()
--     bestEgg = clientSaveGet.MaximumAvailableEgg
--     eggData = require(Library.Util.EggsUtil).GetByNumber(bestEgg) -- gets eggData.name, .eggNumber
-- end


local function teleportAndHatch()
    bestEgg = clientSaveGet.MaximumAvailableEgg
    eggData = require(Library.Util.EggsUtil).GetByNumber(bestEgg) -- gets eggData.name, .eggNumber
    print("New obtained eggData: ", eggData.name, " (", eggData.eggNumber, ")")
    
    originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
    -- Teleport to Best Egg
    for _, v in pairs(game:GetService("Workspace").__THINGS.Eggs.Main:GetChildren()) do
        if string.find(v.Name, tostring(eggData.eggNumber) .. " - ") then
            eggCFrame = v.Tier.CFrame + Vector3.new(0, 10, 0)
        end
    end
    task.wait(1)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = eggCFrame  -- Teleport to egg

    -- Hatch eggs
    for i=1, 11 do  -- hatch 10 times
        autoHatchWithoutAnimation()
        task.wait(fastestHatchTime)
    end
    eggHatchedBefore = eggData.eggNumber
    print("Hatching", eggData.name)
    print("Done Hatching...")

    LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
end


local function removeValue(t, value)
    for i, v in ipairs(t) do
        if v == value then
            table.remove(t, i)
            break  -- Exit the loop after removing the value
        end
    end
end


local function checkAndRedeemGift()
    for giftIndex, seconds in pairs(giftTiming) do
        if clientSaveGet.FreeGiftsTime >= seconds then
            print("Redeeming Free Gift ", giftIndex)
            ReplicatedStorage:WaitForChild("Network"):WaitForChild("Redeem Free Gift"):InvokeServer(giftIndex)
            task.wait(1) -- wait to collect gifts properly
        else
            break
        end
    end

    for i, _ in pairs(clientSaveGet.FreeGiftsRedeemed) do
        if giftTiming[clientSaveGet.FreeGiftsRedeemed[i]] ~= nil then
            giftTiming[clientSaveGet.FreeGiftsRedeemed[i]] = nil
        end
    end
end


local function checkAndRedeemRankRewards()
    -- claim all ranked quest when all rewards ready
    if rankCmds.AllRewardsReady() then
        for i=1, clientSaveGet.RankStars do
            task.wait(1)
            if clientSaveGet.RedeemedRankRewards[tostring(i)] ~= true then
                print("Redeeming ", i, " rank reward.")
                ReplicatedStorage:WaitForChild("Network"):WaitForChild("Ranks_ClaimReward"):FireServer(i)
            end
        end
    end
end


local function checkAndConsumeFruits()
    for fruitId, tbl in pairs(fruitInventory) do
        task.wait(0.5)
        if fruitCmds.GetActiveFruits()[tbl.id] ~= nil then
            if (#fruitCmds.GetActiveFruits()[tbl.id]["Normal"] < maxFruitQueue) and (tbl._am ~= nil) then
                print("Continue consuming ", tbl.id)
                if tbl._am < fruitCmds.GetMaxConsume(fruitId) then
                    fruitCmds.Consume(fruitId, tonumber(tbl._am))
                else
                    fruitCmds.Consume(fruitId, fruitCmds.GetMaxConsume(fruitId))
                end
            end
        else
            fruitCmds.Consume(fruitId)
        end
    end
end


local function checkAndConsumeGifts()
    for itemId, value in pairs(inventory.Misc) do
        if string.find(value.id:lower(), "bundle") or string.find(value.id:lower(), "gift bag") or (value.id == "Mini Chest") then
            if not value._am then
                print("Consuming ", value.id)
                ReplicatedStorage:WaitForChild("Network"):WaitForChild("GiftBag_Open"):InvokeServer(value.id)
            elseif value._am < 100 then
                print("Consuming ", value.id)
                ReplicatedStorage:WaitForChild("Network"):WaitForChild("GiftBag_Open"):InvokeServer(value.id, value._am)
            else
                print("Consuming ", value.id)
                ReplicatedStorage:WaitForChild("Network"):WaitForChild("GiftBag_Open"):InvokeServer(value.id, 100)
            end
            task.wait(1)
        end
    end
end


local function checkAndConsumePotions()
    findUnconsumedPotions()
    for i, potionName in ipairs(unconsumedPotions) do
        highestTierPotion = 0  -- reset tier for other potions
        highestTierPotionId = nil
        for itemId, value in pairs(inventory.Potion) do
            if value.id == potionName then
                if highestTierPotion < value.tn then
                    highestTierPotion = value.tn
                    highestTierPotionId = itemId
                end
            end
        end
        if highestTierPotion > 0 then
            print("Consuming ", potionName, ", Tier: ", highestTierPotion)
            task.wait(1)
            potionCmds.Consume(highestTierPotionId)
        end
    end
end


local function checkAndConsumeToys()
    -- No Toyball, useless with maxspeed
    for itemId, value in pairs(inventory.Misc) do
        if value.id == "Squeaky Toy" then
            if not buffCmds.IsActive("Squeaky Toy") then
                print("Consuming Squeak Toy.")
                task.wait(1)
                ReplicatedStorage:WaitForChild("Network"):WaitForChild("SqueakyToy_Consume"):InvokeServer()
            end
        elseif value.id == "Toy Bone" then
            if not buffCmds.IsActive("Toy Bone") then
                print("Consuming Toy Bone")
                task.wait(1)
                ReplicatedStorage:WaitForChild("Network"):WaitForChild("ToyBone_Consume"):InvokeServer()
            end
        end
    end
end
    

-- Pet speed 200%
require(Client.PlayerPet).CalculateSpeedMultiplier = function(...)
    return 200
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

ReplicatedStorage:WaitForChild("Network"):WaitForChild("ForeverPacks: Claim Free"):InvokeServer("Default")  -- collect free foreverpack
if not clientSaveGet.PickedStarterPet then
    print("New Account Detected... Picking Starter Pets.")
    ReplicatedStorage:WaitForChild("Network"):WaitForChild("Pick Starter Pets"):InvokeServer(unpack({"Cat", "Dog"}))
end 


if nextRebirthData then
    rebirthNumber = nextRebirthData.RebirthNumber
    rebirthZone = nextRebirthData.ZoneNumberRequired
end


task.spawn(function()
    task.wait(5)
    print("Starting zone purchase service")
    while unfinished do
        local nextZoneName, nextZoneData = zoneCmds.GetNextZone()
        local success, _ = ReplicatedStorage.Network.Zones_RequestPurchase:InvokeServer(nextZoneName)
        if success then
            print("Successfully purchased " .. nextZoneName)
            if getgenv().autoWorldConfig.AUTO_REBIRTH then
                pcall(function()
                    if nextZoneData.ZoneNumber >= rebirthZone then
                        print("Rebirthing")
                        ReplicatedStorage.Network.Rebirth_Request:InvokeServer(tostring(rebirthNumber))
                        task.wait(15)
                        nextRebirthData = rebirthCmds.GetNextRebirth()
                        if nextRebirthData then
                            rebirthNumber = nextRebirthData.RebirthNumber
                            rebirthZone = nextRebirthData.ZoneNumberRequired
                        end
                    end
                end)
            end
            teleportToMaxZone()
            startAutoHatchEggDelay = tick()
        end
        if (tick() - startAutoHatchEggDelay) >= autoHatchEggDelay and eggHatchedBefore ~= eggData.eggNumber then
            teleportAndHatch()
            startAutoHatchEggDelay = tick()
        end

        if not (inventory.Fruit == nil) then
            checkAndConsumeFruits()
            checkAndConsumeGifts() -- misc
            checkAndConsumeToys() -- misc
        end
        if not (inventory.Potion == nil) then
            checkAndConsumePotions()
        end
        if not (inventory.Enchant == nil) then
            checkAndEquipBestSpecifiedEnchants()
        end

        local zoneName, maxZoneData = zoneCmds.GetMaxOwnedZone()
        if maxZoneData.ZoneNumber >= 2 then -- still gotta check if petslot and eggslot is fully maxed
            checkAndPurchaseUpgrades()  -- stil buggy, loop keeps teleporting to it even when cant afford
        end
        if maxZoneData.ZoneNumber >= 4 then
            checkAndPurchasePetSlot()
        end
        if maxZoneData.ZoneNumber >= 8 then
            checkAndPurchaseEggSlot()
        end
        if maxZoneData.ZoneNumber >= 12 then
            checkAndRedeemGift()
        end
        checkAndRedeemRankRewards()
        
        if hypeCmds.IsActive() and hypeCmds.GetTimeRemaining() == 0 and not hypeCmds.IsCompleted() then
            game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Hype Wheel: Claim"):InvokeServer()
        end

        task.wait(getgenv().autoWorldConfig.PURCHASE_CHECK_DELAY)
    end
end)

teleportToMaxZone()  - delay before starting parallel functions.


