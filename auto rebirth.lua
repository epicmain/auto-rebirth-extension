getgenv().autoWorldConfig = {
    AUTO_REBIRTH = true,
    ZONE_TO_REACH = 199,
    RANK_TO_REACH = 12,
    REBIRTH_TO_REACH = 8
}


-- Max Zone For World 1: 99
-- Max Zone For World 2: 124

-- VVV Wait for game load VVV
repeat
    task.wait()
until game:IsLoaded()

repeat
    task.wait()
until game.PlaceId ~= nil

repeat
    task.wait()
until game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart

repeat
    task.wait()
until game:GetService("Workspace").__THINGS and game:GetService("Workspace").__DEBRIS

print("[CLIENT] Loaded Game")
-- ^^^ Wait for game load ^^^


loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/antiStaff.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = ReplicatedStorage:WaitForChild("Library")
local Client = Library.Client
local LocalPlayer = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local Network = ReplicatedStorage:WaitForChild("Network")
local Character = LocalPlayer.Character
local myHumanoidRootPart = Character.HumanoidRootPart
local Active = game:GetService("Workspace").__THINGS.__INSTANCE_CONTAINER.Active
repeat
    task.wait()
    if Active:FindFirstChild("Fishing") then
        myHumanoidRootPart.CFrame = game:GetService("Workspace").__THINGS.Instances.Fishing.Teleports.Leave.CFrame + Vector3.new(0, 5, 0)
    elseif Active:FindFirstChild("Digsite") then
        myHumanoidRootPart.CFrame = game:GetService("Workspace").__THINGS.Instances.Digsite.Teleports.Leave.CFrame + Vector3.new(0, 5, 0)
    elseif Active:FindFirstChild("StairwayToHeaven") then
        myHumanoidRootPart.CFrame = game:GetService("Workspace").__THINGS.Instances.StairwayToHeaven.Teleports.Leave.CFrame + Vector3.new(0, 5, 0)
    end
until #Active:GetChildren() <= 0


local map
local PlaceId = game.PlaceId
if PlaceId == 8737899170 then
    map = Workspace.Map
elseif PlaceId == 16498369169 then
    map = Workspace.Map2
end


local petCmds = require(Client.PetCmds)
local eggCmds = require(Client.EggCmds)
local rankCmds = require(Client.RankCmds)
local zoneCmds = require(Client.ZoneCmds)
local buffCmds = require(Client.BuffCmds)
local fruitCmds = require(Client.FruitCmds)
local potionCmds = require(Client.PotionCmds)
local hypeCmds = require(Client.HypeEventCmds)
local enchantCmds = require(Client.EnchantCmds)
local rebirthCmds = require(Client.RebirthCmds)
local upgradeCmds = require(Client.UpgradeCmds)
local currencyCmds = require(Client.CurrencyCmds)
local breakableCmds = require(Client.BreakableCmds)
local randomEventCmds = require(Client.RandomEventCmds)
local flexibleFlagCmds = require(Client.FlexibleFlagCmds)


local worldEgg
local worldCoin
if PlaceId == 8737899170 then
    worldEgg = "Main"
    worldCoin = "Coins"
elseif PlaceId == 16498369169 then
    worldEgg = "World2"
    worldCoin = "TechCoins"
end


local clientSaveGet = require(Client.Save).Get()
local inventory = clientSaveGet.Inventory
local rebirthNotDone = true
local currentZone
local nextRebirthData = rebirthCmds.GetNextRebirth()
local rebirthNumber
local rebirthZone
local maxZoneName, maxZoneData = zoneCmds.GetMaxOwnedZone()


local startAutoHatchEggDelay = tick()
local autoHatchEggDelay = 120

-- vvv Egg hatching variables vvv
local bestEgg = nil
local timeStartEggHatch = tick()
local fastestHatchTime = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Egg Opening Frontend"]).computeSpeedMult() * 2
local currentMaxHatch = eggCmds.GetMaxHatch()
local eggData
local eggCFrame
local eggHatchedBefore = 0
-- ^^^ Egg hatching variables ^^^

--- vvv EggSlot variables vvv
local currentEggSlots
local currentmaxPurchaseableEggs = rankCmds.GetMaxPurchasableEggSlots()
local MAX_EGG_SLOTS = 50
-- ^^^ EggSlot variables ^^^

--- vvv Pet slot variables vvv
local currentEquipSlots
local currentmaxPurchaseableEquips = rankCmds.GetMaxPurchasableEquipSlots()
local MAX_PET_SLOTS = 45
--- ^^^ Pet slot variables ^^^

-- vvv Fruit variables vvv
local maxFruitQueue = fruitCmds.ComputeFruitQueueLimit()
-- local activeFruits = require(Client.FruitCmds).GetActiveFruits() -- returns nested table active fruits .Normal .Shiny
-- ^^^ Fruit variables ^^^

-- vvv Auto potions variables vvv
local highestTierPotion = 0
local highestTierPotionId = nil
local unconsumedPotions -- Diamonds, Treasure Hunter, Damage, Lucky, Coins ... Walkspeed is useless
-- ^^^ Auto potions variables ^^^

-- vvv Enchant variables vvv
local enchantEquipTimeStart = tick()
local equipEnchantDelay = 60
local enchantIdToName
local enchants = {
    [1] = "Tap Power", 
    [2] = "Coins", 
    [3] = "Tap Power", 
    [4] = "Strong Pets", 
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

local enchantsToUpgrade = {
    "Coins", 
    "Tap Power", 
    "Criticals", 
    "Diamonds", 
    "Lucky Eggs", 
    "Strong Pets", 
    "Treasure Hunter", 
    "Walkspeed", 
    "Magnet"
}
-- ^^^ Enchant variables ^^^

-- vvv Upgrades variables vvv
local MAX_UPGRADE_GEM = 20000
-- ^^^ Upgrades variables ^^^


local fishingOptimized = false


-- 10 = Golden Machine
-- 13 = Upgrade Potion Machine
-- 16 = Upgrade Enchant Machine
-- 31 = Rainbow Machine
local questName = nil
local questAmount = nil
local questProgress = nil
local questPotionTier = nil
local questEnchantTier = nil
local questActualAmount = nil

local goalsNumber
local BEST_EGG
local HATCH_RARE_PET
local totalBestPet


local bestEggPets = {}

local BigChests = {
    [1] = "Beach",
    [2] = "Underworld",
    [3] = "No Path Forest",
    [4] = "Heaven Gates"
}   

local vendingMachines = {
    [1] = "Cherry Blossom",
    [2] = "Misty Falls",
    [3] = "Mushroom Field",
    [4] = "Pirate Cove",
    [5] = "Safari",
    [6] = "Fire and Ice"
}

local vendingOrBossChestZonePath

local bossChestCooldown = 600
local beachBossChestCooldownStart = 0
local underWorldBossChestCooldownStart = 0
local noPathForestBossChestCooldownStart = 0
local heavenGatesBossChestCooldownStart = 0
local callByBoss = false
local normalOrChest

local Breakables = game:GetService("Workspace")["__DEBRIS"]


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


-- disable egg hatch animation
hookfunction(getsenv(game.Players.LocalPlayer.PlayerScripts.Scripts.Game["Egg Opening Frontend"]).PlayEggAnimation, function()
    return
end)


local function trim(string)
    if not string then
        return false
    end
    return string:match("^%s*(.-)%s*$")
end


local function split(input, separator)
    if separator == nil then
        separator = "%s"
    end
    local parts = {}
    for str in string.gmatch(input, "([^" .. separator .. "]+)") do
        table.insert(parts, str)
    end
    return parts
end


local function len(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end


local function checkType(number)
    for taskName, taskNumber in require(game:GetService("ReplicatedStorage").Library.Types.Quests).Goals do
        if number == taskNumber then
            return taskName
        end
    end
end 


local function DeleteAllTextures()
    for _, v in pairs(map:GetDescendants()) do
        if v:IsA("Part") or v:IsA("BasePart") then
            v.Transparency = 1
        end
    end
end


local function teleportToMaxZone()
    print("in teleportToMaxZone()")
    maxZoneName, maxZoneData = zoneCmds.GetMaxOwnedZone()
    print("Teleporting to: ", maxZoneName)
    while currentZone == maxZoneName do
        maxZoneName, maxZoneData = zoneCmds.GetMaxOwnedZone()
        task.wait()
    end
    currentZone = maxZoneName
    print("Teleporting to zone: " .. maxZoneName)

    local zonePath
    for _, v in pairs(map:GetChildren()) do
        if v.Name == tostring(maxZoneData.ZoneNumber) .. " | " .. maxZoneName then
            zonePath = v
            break
        end
    end

    task.wait()
    myHumanoidRootPart.CFrame = zonePath:WaitForChild("PERSISTENT").Teleport.CFrame + Vector3.new(0, 10, 0)
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
        local magnitude = (myHumanoidRootPart.Position - v.Position).Magnitude
        print(magnitude)
        if magnitude <= dist then
            dist = magnitude
            closestBreakZone = v
        end
    end

    myHumanoidRootPart.CFrame = closestBreakZone.CFrame + Vector3.new(0, 10, 0)

    Network:WaitForChild("Pets_UnequipAll"):FireServer()
    task.wait(2)
    require(game:GetService("ReplicatedStorage").Library.Client.PetCmds).Restore()
    task.wait(2)
    DeleteAllTextures()
    print("Pets Restored.")

    if maxZoneData.ZoneNumber >= getgenv().autoWorldConfig.ZONE_TO_REACH and rankCmds.GetMaxRank() >= getgenv().autoWorldConfig.RANK_TO_REACH and clientSaveGet.Rebirths >= getgenv().autoWorldConfig.REBIRTH_TO_REACH then
        print("Reached selected zone, rebirth and rank")
        rebirthNotDone = false
    end
end


local function teleportToPresentOrSafe(zoneDetail)
    local zonePath
    for _, v in pairs(map:GetChildren()) do
        if v.Name == zoneDetail then
            zonePath = v
            break
        end
    end

    task.wait()
    myHumanoidRootPart.CFrame = zonePath:WaitForChild("PERSISTENT").Teleport.CFrame + Vector3.new(0, 10, 0)
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
        local magnitude = (myHumanoidRootPart.Position - v.Position).Magnitude
        print(magnitude)
        if magnitude <= dist then
            dist = magnitude
            closestBreakZone = v
        end
    end

    myHumanoidRootPart.CFrame = closestBreakZone.CFrame + Vector3.new(0, 10, 0)

    Network:WaitForChild("Pets_UnequipAll"):FireServer()
    task.wait(2)
    require(game:GetService("ReplicatedStorage").Library.Client.PetCmds).Restore()
    task.wait(2)
    DeleteAllTextures()
    print("Pets Restored.")
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
                            task.wait()
                            secondaryBestEnchantTier = secondaryBestEnchantTier - 1 -- best enchant for the other slot that wanted the same enchant
                            
                            if secondaryBestEnchantTier >= 1 then -- if its more than tier 1, continue
                                for enchantId, tbl in pairs(inventory.Enchant) do
                                    if tbl.id == "Coins" or tbl.id == "Tap Power" or tbl.id == "Criticals" or tbl.id == "Diamonds" or 
                                    tbl.id == "Lucky Eggs" or tbl.id == "Strong Pets" or tbl.id == "Treasure Hunter" then

                                        if tbl.tn == secondaryBestEnchantTier and tbl.id == enchantName then -- if tier found in inventory same as downgraded tier, equip it
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


-- update upgrades
local function checkAndPurchaseUpgrades()
    local zonePath
    -- Reverse iterate through the upgrades table
    for i = #upgrades, 1, -1 do
        local upgrade = upgrades[i]
        local ability = upgrade[1]
        local areaNumber = upgrade[2]
        local mapName = upgrade[3]
        local gemAmount = upgrade[4]

        -- logic for processing upgrades
        if areaNumber <= maxZoneData.ZoneNumber then
            -- if owns upgrade, remove from table
            if upgradeCmds.Owns(ability, mapName) then
                table.remove(upgrades, i)
            elseif currencyCmds.Get("Diamonds") > gemAmount and gemAmount < MAX_UPGRADE_GEM then
                -- Teleport to zone so it can detect if owned, if too far it will detect false.
                for _, v in pairs(map:GetChildren()) do
                    if string.find(v.Name, tostring(areaNumber) .. " | " .. mapName) then
                        zonePath = v
                    end
                end
                -- Teleports to upgrade zone
                myHumanoidRootPart.CFrame = zonePath:WaitForChild("PERSISTENT").Teleport.CFrame + Vector3.new(0, 10, 0)
                for _, v in pairs(zonePath:WaitForChild("INTERACT").Upgrades:GetChildren()) do
                    myHumanoidRootPart.CFrame = v.Center.CFrame + Vector3.new(0, 10, 0)
                    task.wait(1)
                end

                -- Check if owned or affordable
                if not upgradeCmds.Owns(ability, mapName) and currencyCmds.Get("Diamonds") > gemAmount then
                    task.wait(1)
                    print("Bought " .. ability .. " from " .. mapName)
                    upgradeCmds.Purchase(ability, mapName)
                    table.remove(upgrades, i)
                    currentZone = nil
                    teleportToMaxZone()
                elseif upgradeCmds.Owns(ability, mapName) then
                    table.remove(upgrades, i)
                    currentZone = nil
                    teleportToMaxZone()
                end
            end  
        end
    end
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


local function checkAndConsumeFruits()
    for fruitId, tbl in pairs(inventory.Fruit) do
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


local function consumeGoalsPotion(questPotionTier)
    for itemId, value in pairs(inventory.Potion) do
        if questPotionTier == value.tn then
            print("Consuming ", value.id, ", Tier: ", questPotionTier)
            potionCmds.Consume(itemId)
            task.wait(1)
            break
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


local function teleportToInstance(instanceName)
    if not Active:FindFirstChild(instanceName) then
        myHumanoidRootPart.CFrame = game:GetService("Workspace").__THINGS.Instances[instanceName].Teleports.Enter.CFrame + Vector3.new(0, 5, 0)
    
        local loaded = false
        local detectLoad = Active.ChildAdded:Connect(function(child)
            if child.Name == instanceName then
                loaded = true
            end
        end)
    
        repeat
            task.wait()
        until loaded
    
        detectLoad:Disconnect()
        task.wait(1)
    end
end


local function teleportToDigsite()
    if not Active:FindFirstChild("Digsite") then
        myHumanoidRootPart.CFrame = game:GetService("Workspace").__THINGS.Instances.Digsite.Teleports.Enter.CFrame + Vector3.new(0, 5, 0)

        local loaded = false

        task.spawn(function()
            task.wait(10)
            if not loaded then
                task.wait(5)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/serverhop.lua"))()
            end
        end)

        local detectLoad = Active.ChildAdded:Connect(function(child)
            if child.Name == "Digsite" then
                loaded = true
            end
        end)

        repeat
            task.wait()
        until loaded

        detectLoad:Disconnect()
        task.wait(1)
    end
    print("Waiting for digsite blocks to load...")
    while #Active.Digsite.Important.ActiveBlocks:GetChildren() < 5 do
        task.wait()
    end
end


local function findBlock()
    local dist = 9999
    local block = nil
    for _, v in pairs(Active.Digsite.Important.ActiveBlocks:GetChildren()) do
        if v:IsA("BasePart") then
            local magnitude = (myHumanoidRootPart.Position - v.Position).Magnitude
            if magnitude <= dist then
                dist = magnitude
                block = v
            end
        end
    end
    return block
end


local function findChest()
    local dist = 9999
    local chest = nil
    for _, v in pairs(Active.Digsite.Important.ActiveChests:GetChildren()) do
        if v:IsA("Model") then
            local magnitude = (myHumanoidRootPart.Position - v.Top.Position).Magnitude
            if magnitude <= dist then
                dist = magnitude
                chest = v
            end
        end
    end
    return chest
end


local function hidePlayerFishing()
    print("Hiding player fishing...")
    myHumanoidRootPart.Anchored = true
    myHumanoidRootPart.CFrame = myHumanoidRootPart.CFrame + Vector3.new(Random.new():NextInteger(-10, 10), -20, Random.new():NextInteger(-10, 10))

    local platform = Instance.new("Part")
    platform.Parent = game:GetService("Workspace")
    platform.Anchored = true
    platform.CFrame = myHumanoidRootPart.CFrame + Vector3.new(0, -5, 0)
    platform.Size = Vector3.new(5, 1, 5)
    platform.Transparency = 1

    myHumanoidRootPart.Anchored = false
end


local function optimizeFishing()
    print("Optimizing fishing")
    local Fishing = Active.Fishing
    Fishing.Debris:ClearAllChildren()

    pcall(function()
        for _, v in pairs(Fishing:GetChildren()) do
            if string.find(v.Name, "Model") or string.find(v.Name, "Water") or string.find(v.Name, "Debris") then
                v:Destroy()
            elseif v.Name == "Map" then
                for _, v in pairs(v:GetChildren()) do
                    if v.Name ~= "Ground" then
                        v:Destroy()
                    end
                end
            end
        end
    end)

    game.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            for _, v in pairs(character:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Decal") then
                    v.Transparency = 1
                end
            end
        end)
    end)
end


local function teleportToVendingOrBossChestZone(selectedZone)
    local teleported = false

    while not teleported do
        for _, v in pairs(map:GetChildren()) do
            local zoneName = trim(split(v.Name, "|")[2])
            if zoneName and zoneName == selectedZone then
                myHumanoidRootPart.CFrame = map[v.Name].PERSISTENT.Teleport.CFrame + Vector3.new(0, 10, 0)
                teleported = true
                break
            end
        end
        task.wait()
    end
end


local function waitForVendingOrBossChestLoad(zone)
    for _, v in pairs(map:GetChildren()) do
        local zoneName = trim(split(v.Name, "|")[2])
        if zoneName and zoneName == zone then
            vendingOrBossChestZonePath = map[v.Name]
            break
        end
    end

    if not vendingOrBossChestZonePath:FindFirstChild("INTERACT") then
        local loaded = false
        local detectLoad = vendingOrBossChestZonePath.ChildAdded:Connect(function(child)
            if child.Name == "INTERACT" then
                loaded = true
            end
        end)

        repeat
            task.wait()
        until loaded

        detectLoad:Disconnect()
    end

    local function getVendingOrBreakZonesAmount()
        local counter = 0
        for _ in pairs(vendingOrBossChestZonePath.INTERACT.BREAK_ZONES:GetChildren()) do
            counter = counter + 1
        end
        return counter
    end

    local amountToCheck = 1 -- default 1 for (vending machine loaded INTERACT check)
    if zone == "Beach" or zone == "Underworld" or zone == "No Path Forest" or zone == "Heaven Gates" then
        amountToCheck = 2
    end

    if getVendingOrBreakZonesAmount() < amountToCheck then
        local loaded = false
        local detectLoad = vendingOrBossChestZonePath.INTERACT.BREAK_ZONES.ChildAdded:Connect(function(_)
            if getVendingOrBreakZonesAmount() == amountToCheck then
                loaded = true
            end
        end)
        repeat
            task.wait()
        until loaded
        detectLoad:Disconnect()
    end
end


local function breakChest(zone)

    local chest
    while not chest do
        for v in breakableCmds.AllByZoneAndClass(zone, "Chest") do
            chest = v
            break
        end
        task.wait()
    end

    local args = {
        [1] = {

        }
    }

    for petId, _ in pairs(require(game:GetService("ReplicatedStorage").Library.Client.PlayerPet).GetAll()) do
        args[1] = {
            [petId] = chest
        }
        Network:WaitForChild("Breakables_JoinPetBulk"):FireServer(unpack(args))
    end

    local brokeChest = false
    local breakableRemovedService = Breakables.ChildRemoved:Connect(function(breakable)
        task.wait()
        if string.find(breakable.Name, chest) then
            brokeChest = true
            print("Broke chest")
        end
    end)

    if callByBoss then
        myHumanoidRootPart.CFrame = vendingOrBossChestZonePath.INTERACT.BREAKABLE_SPAWNS.Boss.CFrame + Vector3.new(0, 10, 0)
    end

    local breakChestTimeLimit = 10
    local breakChestTimeStart = tick()
    repeat
        local args = {
            [1] = chest
        }
        Network.Breakables_PlayerDealDamage:FireServer(unpack(args))
        task.wait()
    until brokeChest or (tick() - breakChestTimeStart) >= breakChestTimeLimit

    breakableRemovedService:Disconnect()
end


local function isWithinRange(part)
    return (myHumanoidRootPart.CFrame.Position - part.CFrame.Position).magnitude <= 300
end


local function autoBossChest()
    local sortedKeys = {}
    for key in pairs(BigChests) do
        table.insert(sortedKeys, key)
    end
    table.sort(sortedKeys)

    for _, key in ipairs(sortedKeys) do
        local zoneName = BigChests[key]
        local noCooldown = false
        if zoneName == "Beach" and maxZoneData.ZoneNumber >= 20 then
            if os.time() - beachBossChestCooldownStart >= bossChestCooldown then
                noCooldown = true
            end
        elseif zoneName == "Underworld" and maxZoneData.ZoneNumber >= 46 then
            if os.time() - underWorldBossChestCooldownStart >= bossChestCooldown then
                noCooldown = true
            end
        elseif zoneName == "No Path Forest" and maxZoneData.ZoneNumber >= 70 then
            if os.time() - noPathForestBossChestCooldownStart >= bossChestCooldown then
                noCooldown = true
            end
        elseif zoneName == "Heaven Gates" and maxZoneData.ZoneNumber >= 95 then
            if os.time() - heavenGatesBossChestCooldownStart >= bossChestCooldown then
                noCooldown = true
            end
        end

        if len(clientSaveGet.Goals) == 0 then break end
        local questId = clientSaveGet.Goals[goalsNumber]["Type"]
        if noCooldown and 
        (checkType(questId) == "COLLECT_POTION" or checkType(questId) == "COLLECT_ENCHANT")  then
            print("Starting " .. zoneName)

            teleportToVendingOrBossChestZone(zoneName)
            waitForVendingOrBossChestLoad(zoneName)

            local timerFound = false

            while not timerFound do
                for _, v in pairs(Workspace.__DEBRIS:GetChildren()) do
                    local timer
                    local isTimer, _ = pcall(function()
                        timer = v.ChestTimer.Timer.Text
                    end)

                    if v.Name == "host" and isTimer and isWithinRange(v)then

                        timerFound = true

                        if timer == "00:00" then
                            print(zoneName .. " chest is available")
                            breakChest(zoneName)
                        -- else
                        --     print(zoneName .. " chest is not available " .. timer)
                        end

                        if zoneName == "Beach" then
                            beachBossChestCooldownStart = os.time()
                        elseif zoneName == "Underworld" then
                            underWorldBossChestCooldownStart = os.time()
                        elseif zoneName == "No Path Forest" then
                            noPathForestBossChestCooldownStart = os.time()
                        elseif zoneName == "Heaven Gates" then
                            heavenGatesBossChestCooldownStart = os.time()
                        end

                        break
                    end
                end
                task.wait()
            end

            -- warn("Finished " .. zoneName)

            if getgenv().STAFF_DETECTED then
                return
            end

            task.wait(2)
        end
    end
    currentZone = nil
    print("teleporting back")
    teleportToMaxZone()
end


local function buyVendingMachine()
    local sortedKeys = {}
    for key in pairs(vendingMachines) do
        table.insert(sortedKeys, key)
    end
    table.sort(sortedKeys)

    for _, key in ipairs(sortedKeys) do
        local zoneName = vendingMachines[key]
        local vendingMachineName, vendingMachineStock
        for machineName, stock in clientSaveGet.VendingStocks do
            if maxZoneData.ZoneNumber >= 6 and zoneName == "Cherry Blossom" and machineName == "PotionVendingMachine1" then
                vendingMachineName = machineName
                vendingMachineStock = stock
            elseif maxZoneData.ZoneNumber >= 9 and zoneName == "Misty Falls" and machineName == "EnchantVendingMachine1" then
                vendingMachineName = machineName
                vendingMachineStock = stock
            elseif maxZoneData.ZoneNumber >= 14 and zoneName == "Mushroom Field" and machineName == "FruitVendingMachine1" then
                vendingMachineName = machineName
                vendingMachineStock = stock
            elseif maxZoneData.ZoneNumber >= 26 and zoneName == "Pirate Cove" and machineName == "FruitVendingMachine2" then
                vendingMachineName = machineName
                vendingMachineStock = stock
            elseif maxZoneData.ZoneNumber >= 35 and zoneName == "Safari" and machineName == "PotionVendingMachine2" then
                vendingMachineName = machineName
                vendingMachineStock = stock
            elseif maxZoneData.ZoneNumber >= 42 and zoneName == "Fire and Ice" and machineName == "EnchantVendingMachine2" then
                vendingMachineName = machineName
                vendingMachineStock = stock
            end
        end
        
        if len(clientSaveGet.Goals) == 0 then break end
        local questId = clientSaveGet.Goals[goalsNumber]["Type"]
        if (vendingMachineName == "FruitVendingMachine1" or vendingMachineName == "FruitVendingMachine2") and 
        vendingMachineStock >= 4 then
            print("Buying Fruits " .. zoneName)

            teleportToVendingOrBossChestZone(zoneName)
            waitForVendingOrBossChestLoad(zoneName)
            
            myHumanoidRootPart.CFrame = vendingOrBossChestZonePath.INTERACT.Machines[vendingMachineName].PadGlow.CFrame + Vector3.new(10, 10, 0)
            task.wait(1)
            Network:WaitForChild("VendingMachines_Purchase"):InvokeServer(vendingMachineName,vendingMachineStock)
            currentZone = nil
            teleportToMaxZone()

        elseif checkType(questId) == "COLLECT_POTION" and 
        (vendingMachineName == "PotionVendingMachine1" or vendingMachineName == "PotionVendingMachine2") and 
        vendingMachineStock > 0 then
            print("Buying Potion: " .. zoneName)

            teleportToVendingOrBossChestZone(zoneName)
            waitForVendingOrBossChestLoad(zoneName)
            
            myHumanoidRootPart.CFrame = vendingOrBossChestZonePath.INTERACT.Machines[vendingMachineName].PadGlow.CFrame + Vector3.new(10, 10, 0)
            task.wait(1)
            Network:WaitForChild("VendingMachines_Purchase"):InvokeServer(vendingMachineName,vendingMachineStock)
            currentZone = nil
            teleportToMaxZone()

        elseif checkType(questId) == "COLLECT_ENCHANT" and 
        (vendingMachineName == "EnchantVendingMachine1" or vendingMachineName == "EnchantVendingMachine2") and 
        vendingMachineStock > 0 then
            print("Buying Enchant " .. zoneName)

            teleportToVendingOrBossChestZone(zoneName)
            waitForVendingOrBossChestLoad(zoneName)
            
            myHumanoidRootPart.CFrame = vendingOrBossChestZonePath.INTERACT.Machines[vendingMachineName].PadGlow.CFrame + Vector3.new(10, 10, 0)
            task.wait(1)
            Network:WaitForChild("VendingMachines_Purchase"):InvokeServer(vendingMachineName,vendingMachineStock)
            currentZone = nil
            teleportToMaxZone()
        end
    end
end


local function startFishing()
    print("Start Fishing...")
    if Active.Fishing.Interactable:FindFirstChild("WoodenFishingRod") then
        Network:WaitForChild("Instancing_FireCustomFromClient"):FireServer("Fishing", "ClaimRod")
    end

    -- Teleport to merchant, update merchant itemframe
    myHumanoidRootPart.CFrame = Active.Fishing.Interactable.Merchant.PadGlow.CFrame + Vector3.new(0, 10, 0)
    task.wait(3)

    hidePlayerFishing()
        
    for i=1, questActualAmount do
        local Fishing = Active.Fishing
        local sharkInPool

        local fishingCoins = currencyCmds.Get("Fishing")
        local fishingRodItem = game:GetService("Players").LocalPlayer.PlayerGui["_INSTANCES"].FishingMerchant.Frame.ItemsFrame.Items
        local sturdyFishingRodPrice = 100
        local advancedFishingRodPrice = 2500
        local superFishingRodPrice = 25000
        local proFishingRodPrice = 100000

        if not fishingRodItem["Sturdy Fishing Rod"].Buy.Cost.SoldOut.Visible and fishingCoins >= sturdyFishingRodPrice then
            print("Buying Sturdy Fishing Rod")
            Network.FishingMerchant_PurchaseRod:InvokeServer("Sturdy Fishing Rod")
            task.wait(3)
            break

        elseif not fishingRodItem["Advanced Fishing Rod"].Buy.Cost.SoldOut.Visible and fishingCoins >= advancedFishingRodPrice then
            print("Buying Advanced Fishing Rod")
            Network.FishingMerchant_PurchaseRod:InvokeServer("Advanced Fishing Rod")
            task.wait(3)
            break

        elseif not fishingRodItem["Super Fishing Rod"].Buy.Cost.SoldOut.Visible and fishingCoins >= superFishingRodPrice then
            print("Buying Super Fishing Rod")
            Network.FishingMerchant_PurchaseRod:InvokeServer("Super Fishing Rod")
            task.wait(3)
            break

        elseif not fishingRodItem["Pro Fishing Rod"].Buy.Cost.SoldOut.Visible and fishingCoins >= proFishingRodPrice then
            print("Buying Pro Fishing Rod")
            Network.FishingMerchant_PurchaseRod:InvokeServer("Pro Fishing Rod")
            task.wait(3)
            break
        end


        for _, instance in pairs(Fishing:FindFirstChild("Interactable"):GetChildren()) do
            if instance.Name == "Pet" then
                sharkInPool = instance
                break
            end
        end
    
        local castVector
        if sharkInPool then
            -- MAXIMUM: -/+ 5
            castVector = Vector3.new(sharkInPool.Position.X + Random.new():NextNumber(-4.75, 4.75), sharkInPool.Position.Y, sharkInPool.Position.Z + Random.new():NextNumber(-4.75, 4.75))
        else
            castVector = Vector3.new(1480.482421875 + Random.new():NextInteger(-20, 20), 61.62470245361328, -4451.23583984375 + Random.new():NextInteger(-20, 20))
        end
    
        Network.Instancing_FireCustomFromClient:FireServer("Fishing", "RequestCast", castVector)
    
    
        local bobbers = Fishing:FindFirstChild("Bobbers")
        bobbers:ClearAllChildren()
    
        local playerBobber
        local foundBobber = false
    
        while not foundBobber and Active:FindFirstChild("Fishing") do
            for _, v in pairs(bobbers:GetChildren()) do
                if v:FindFirstChild("Bobber") then
                    if v.Bobber.CFrame.X == castVector.X and v.Bobber.CFrame.Z == castVector.Z then
                        foundBobber = true
                        playerBobber = v.Bobber
                        break
                    end
                end
            end
            task.wait()
        end
    
        local previousPos
        while playerBobber do
            local bp = playerBobber.CFrame.Y
            if bp == previousPos then
                break
            end
            previousPos = bp
            task.wait()
        end
    
        local bobberPos = playerBobber.CFrame.Y
        local startTime = tick()
        while Active:FindFirstChild("Fishing") and playerBobber.CFrame.Y >= bobberPos and (tick() - startTime <= 10) do
            task.wait()
        end
    
        Network.Instancing_FireCustomFromClient:FireServer("Fishing", "RequestReel")
    
        while game.Players.LocalPlayer.Character:FindFirstChild("Model") and game.Players.LocalPlayer.Character.Model.Rod:FindFirstChild("FishingLine") do
            Network.Instancing_InvokeCustomFromClient:InvokeServer("Fishing", "Clicked")
            task.wait()
        end
    end
    myHumanoidRootPart.CFrame = game:GetService("Workspace").__THINGS.Instances.Fishing.Teleports.Leave.CFrame + Vector3.new(0, 5, 0)
    while Active:FindFirstChild("Fishing") do
        task.wait()
    end
end


local function startDigging()
    print("Start Digging...")
    if Active.Digsite.Important:FindFirstChild("Shovel") then
        Network:WaitForChild("Instancing_FireCustomFromClient"):FireServer("Digsite", "ClaimShovel")
    end

    -- Teleport to merchant, update merchant itemframe
    myHumanoidRootPart.CFrame = Active.Digsite.Important.Merchant.PadGlow.CFrame + Vector3.new(0, 10, 0)
    task.wait(3)

    local noChestCount = os.clock()
    pcall(function()
        while checkType(clientSaveGet.Goals[goalsNumber]["Type"]) == "DIGSITE" do
            local chest = findChest()
            local block = findBlock()

            local digsiteCoins = currencyCmds.Get("Digsite")
            local digsiteShovelItems = game:GetService("Players").LocalPlayer.PlayerGui["_INSTANCES"].DigsiteMerchant.Frame.ItemsFrame.Items
            local normalShovelPrice = 2000
            local bluesteelShovelPrice = 12500
            local sharpShovelPrice = 55000
            local proShovelPrice = 250000


            if not digsiteShovelItems["Normal Shovel"].Buy.Cost.SoldOut.Visible and digsiteCoins >= normalShovelPrice then
                print("Buying Normal Shovel")
                Network.DigsiteMerchant_PurchaseShovel:InvokeServer("Normal Shovel")
                task.wait(3)
                break

            elseif not digsiteShovelItems["Bluesteel Shovel"].Buy.Cost.SoldOut.Visible and digsiteCoins >= bluesteelShovelPrice then
                print("Buying Bluesteel Shovel")
                Network.DigsiteMerchant_PurchaseShovel:InvokeServer("Bluesteel Shovel")
                task.wait(3)
                break

            elseif not digsiteShovelItems["Sharp Shovel"].Buy.Cost.SoldOut.Visible and digsiteCoins >= sharpShovelPrice then
                print("Buying Sharp Shovel")
                Network.DigsiteMerchant_PurchaseShovel:InvokeServer("Sharp Shovel")
                task.wait(3)
                break

            elseif not digsiteShovelItems["Pro Shovel"].Buy.Cost.SoldOut.Visible and digsiteCoins >= proShovelPrice then
                print("Buying Pro Shovel")
                Network.DigsiteMerchant_PurchaseShovel:InvokeServer("Pro Shovel")
                task.wait(3)
                break
            end

            if not chest then
                if (os.clock() - noChestCount > 60) then
                    task.wait(5)
                    myHumanoidRootPart.CFrame = game:GetService("Workspace").__THINGS.Instances.Digsite.Teleports.Leave.CFrame + Vector3.new(0, 5, 0)
                    while Active:FindFirstChild("Digsite") do
                        task.wait()
                    end
                    return
                    print("NO CHEST FOUND, SERVER HOPPING...")
                    -- loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/serverhop.lua"))()
                end
            else
                noChestCount = os.clock()
            end

            if chest then
                myHumanoidRootPart.CFrame = chest.Top.CFrame
                Network:WaitForChild("Instancing_FireCustomFromClient"):FireServer("Digsite", "DigChest", chest:GetAttribute('Coord'))
            elseif block then
                myHumanoidRootPart.CFrame = block.CFrame
                Network:WaitForChild("Instancing_FireCustomFromClient"):FireServer("Digsite", "DigBlock", block:GetAttribute('Coord'))
            end
            task.wait()
        end
    end)
    myHumanoidRootPart.CFrame = game:GetService("Workspace").__THINGS.Instances.Digsite.Teleports.Leave.CFrame + Vector3.new(0, 5, 0)
    
    while Active:FindFirstChild("Digsite") do
        task.wait()
    end
    print("Done Digging...")
end

-- Might need additional check before starting spawn obby
local function startSpawnObby()
    pcall(function()
        myHumanoidRootPart.CFrame = myHumanoidRootPart.CFrame + Vector3.new(90, 5, 0)
        task.wait(5)    

        myHumanoidRootPart.CFrame = Active.SpawnObby.INTERACT.Chests["InstanceChest: 1"].Interact.CFrame + Vector3.new(0, 15, 0)
        task.wait(1)
        Network:WaitForChild("InstanceChests_Claim"):InvokeServer("InstanceChest: 1", "SpawnObby")            

        task.wait(10)
        myHumanoidRootPart.CFrame = Active.SpawnObby.Goal.Pad.CFrame + Vector3.new(-60, 5, 0)
        task.wait(3)
        local character = game.Players.LocalPlayer.Character

        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            local targetPosition = Active.SpawnObby.Goal.Pad.Position

            humanoid:MoveTo(targetPosition)
        end
    end)

    local startTime = tick()
    while Active:FindFirstChild("SpawnObby") do
        if tick() - startTime >= 10 then
            myHumanoidRootPart.CFrame = game:GetService("Workspace").__THINGS.Instances.SpawnObby.Teleports.Leave.CFrame + Vector3.new(0, 5, 0)
        end
        task.wait()
    end
end


local function startMinefield()
    local startBlock = 1
    pcall(function()
        while true do
            task.wait()
            myHumanoidRootPart.CFrame = Active.Minefield.Mines:GetChildren()[startBlock].Pad.CFrame + Vector3.new(0, 5, 0)
            task.wait(1)
            if tostring(Active.Minefield.Mines:GetChildren()[startBlock].Pad.BrickColor) == "Lime green" then
                startBlock = startBlock + 15
            elseif tostring(Active.Minefield.Mines:GetChildren()[startBlock].Pad.BrickColor) == "Really red" then
                if startBlock < 15 then
                    startBlock = startBlock + 1
                else
                    startBlock = startBlock - 15 + 1
                end
                task.wait(5)
            end
        end
    end)

    local character = game.Players.LocalPlayer.Character

    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        local targetPosition = (myHumanoidRootPart.CFrame + Vector3.new(20, 0, 0)).Position

        humanoid:MoveTo(targetPosition)
    end

    local startTime = tick()
    while Active:FindFirstChild("Minefield") do
        if tick() - startTime >= 10 then
            myHumanoidRootPart.CFrame = game:GetService("Workspace").__THINGS.Instances.Minefield.Teleports.Leave.CFrame + Vector3.new(0, 5, 0)
        end
        task.wait()
    end
    print("Done with minefield")
end


local function startJungleObby()
    pcall(function()
        myHumanoidRootPart.CFrame = myHumanoidRootPart.CFrame + Vector3.new(0, 0, 20)
        task.wait(10)
        myHumanoidRootPart.CFrame = Active.JungleObby.Sign2.CFrame + Vector3.new(-10, 0, 0)
        task.wait(10)
        myHumanoidRootPart.CFrame = Active.JungleObby.INTERACT.Chests["InstanceChest: 1"].Interact.CFrame + Vector3.new(0, 15, 0)
        task.wait(1)
        game.ReplicatedStorage:WaitForChild("Network"):WaitForChild("InstanceChests_Claim"):InvokeServer("InstanceChest: 1", "JungleObby")
        task.wait(10)
        myHumanoidRootPart.CFrame = Active.JungleObby.Interactable.Goal.Pad.CFrame + Vector3.new(-20, 0, 30)
        task.wait(5)
        local character = game.Players.LocalPlayer.Character

        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            local targetPosition = Active.JungleObby.Interactable.Goal.Pad.Position

            humanoid:MoveTo(targetPosition)
        end
    end)

    local startTime = tick()
    while Active:FindFirstChild("JungleObby") do
        if tick() - startTime >= 10 then
            myHumanoidRootPart.CFrame = game:GetService("Workspace").__THINGS.Instances.JungleObby.Teleports.Leave.CFrame + Vector3.new(0, 5, 0)
        end
        task.wait()
    end
    print("Done with JungleObby!")
end


local function startAtlantis()
    pcall(function()
        local ringPath = Active.Atlantis.Rings
        local ringNum = 1

        task.wait()
        if Active.Atlantis.Rings[tostring(ringNum)].Collision.CFrame then
            myHumanoidRootPart.CFrame = Active.Atlantis.Rings[tostring(ringNum)].Collision.CFrame
            ringNum = ringNum + 1
            task.wait(2)
        end
    end)

    local startTime = tick()
    while Active:FindFirstChild("Atlantis") do
        if tick() - startTime >= 10 then
            myHumanoidRootPart.CFrame = game:GetService("Workspace").__THINGS.Instances.Atlantis.Teleports.Leave.CFrame + Vector3.new(0, 5, 0)
        end
        task.wait()
    end
    print("Done with atlantis!")
end


local function startPyramidObby()
    pcall(function()
        myHumanoidRootPart.CFrame = myHumanoidRootPart.CFrame + Vector3.new(-25, 0, 0)
        task.wait(15)
        myHumanoidRootPart.CFrame = Active.PyramidObby.INTERACT.Chests["InstanceChest: 2"].Interact.CFrame + Vector3.new(0, 15, 0)
        task.wait(5)
        game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("InstanceChests_Claim"):InvokeServer("InstanceChest: 2", "PyramidObby")  
        task.wait(55)
        myHumanoidRootPart.CFrame = Active.PyramidObby.Interactable.Goal.PadGlow.CFrame + Vector3.new(0, 15, 0)
    end)
    
    local startTime = tick()
    while Active:FindFirstChild("PyramidObby") do
        if tick() - startTime >= 10 then
            myHumanoidRootPart.CFrame = game:GetService("Workspace").__THINGS.Instances.PyramidObby.Teleports.Leave.CFrame + Vector3.new(0, 5, 0)
        end
        task.wait()
    end
    print("Done with PyramidObby!")
end


local function startIceObby()
    pcall(function()
        myHumanoidRootPart.CFrame = Active.IceObby.INTERACT.Chests["InstanceChest: 3"].Interact.CFrame + Vector3.new(0, 15, 0)
        task.wait(1)
        game.ReplicatedStorage:WaitForChild("Network"):WaitForChild("InstanceChests_Claim"):InvokeServer("InstanceChest: 3", "IceObby")
        task.wait(100)
        myHumanoidRootPart.CFrame = Active.IceObby.Interactable.Goal.PadGlow.CFrame + Vector3.new(0, 15, 0)
    end)

    local startTime = tick()
    while Active:FindFirstChild("IceObby") do
        if tick() - startTime >= 10 then
            myHumanoidRootPart.CFrame = game:GetService("Workspace").__THINGS.Instances.IceObby.Teleports.Leave.CFrame + Vector3.new(0, 5, 0)
        end
        task.wait()
    end
    print("Done with IceObby!")
end


local function teleportToMachine(mapName)
    print("Teleporting to machine")
    local zonePath = map[mapName]
    myHumanoidRootPart.CFrame = zonePath.PERSISTENT.Teleport.CFrame + Vector3.new(0, 10, 0)
    task.wait()

    if not zonePath:FindFirstChild("INTERACT") then
        local loaded = false
        local detectLoad = zonePath.ChildAdded:Connect(function(child)
            task.wait()
            if child.Name == "INTERACT" then
                loaded = true
            end
        end)

        repeat
            task.wait()
        until loaded

        detectLoad:Disconnect()
    end
    
    if mapName == "4 | Green Forest" then
        myHumanoidRootPart.CFrame = zonePath.INTERACT.Machines.EquipSlotsMachine.PadGlow.CFrame + Vector3.new(10, 10, 0)

    elseif mapName == "8 | Backyard" then
        myHumanoidRootPart.CFrame = zonePath.INTERACT.Machines.EggSlotsMachine.PadGlow.CFrame + Vector3.new(10, 10, 0)

    elseif mapName == "10 | Mine" then
        myHumanoidRootPart.CFrame = zonePath.INTERACT.Machines.GoldMachine.PadGlow.CFrame + Vector3.new(10, 10, 0)

    elseif mapName == "13 | Dark Forest" then
        myHumanoidRootPart.CFrame = zonePath.INTERACT.Machines.UpgradePotionsMachine.PadGlow.CFrame + Vector3.new(10, 10, 0)

    elseif mapName == "16 | Crimson Forest" then
        myHumanoidRootPart.CFrame = zonePath.INTERACT.Machines.UpgradeEnchantsMachine.PadGlow.CFrame + Vector3.new(10, 10, 0)

    elseif mapName == "31 | Desert Pyramids" then
        myHumanoidRootPart.CFrame = zonePath.INTERACT.Machines.RainbowMachine.PadGlow.CFrame + Vector3.new(10, 10, 0)

    elseif mapName == "100 | Tech Spawn" then
        myHumanoidRootPart.CFrame = zonePath.INTERACT.Machines.SuperMachine.PadGlow.CFrame + Vector3.new(20, 10, 0)
    end
    task.wait(2)
    print("out of tp to machine")
end

local function checkAndPurchaseEggSlot()
    local teleportedToEggSlotMachine = false
    while true do
        task.wait()
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
        -- else
        --     print("CANT FIND currentEggSlots!!!")
        end

        -- check if can afford egg slot
        if currencyCmds.Get("Diamonds") >= eggSlotDiamondCost[currentEggSlots] and 
        currentEggSlots < rankCmds.GetMaxPurchasableEggSlots() and 
        currentEggSlots <= MAX_EGG_SLOTS then
            if PlaceId == 8737899170 and not teleportedToEggSlotMachine then
                teleportToMachine("8 | Backyard")
                teleportedToEggSlotMachine = true
            elseif not teleportedToEggSlotMachine then
                teleportToMachine("100 | Tech Spawn")
                teleportedToEggSlotMachine = true
            end

            print("Buying slot " .. tostring(currentEggSlots) .. " for " .. tostring(eggSlotDiamondCost[currentEggSlots]) .. " diamonds")
            Network.EggHatchSlotsMachine_RequestPurchase:InvokeServer(currentEggSlots)
            task.wait(4)

            print("Purchased egg slot " .. tostring(currentEggSlots))
        else
            break
        end
    end
    -- print("Broken out of loop")
    if teleportedToEggSlotMachine then
        currentZone = nil
        teleportToMaxZone()
    end
    currentMaxHatch = eggCmds.GetMaxHatch()
end


local function checkAndPurchasePetSlot()
    local teleportedToPetSlotMachine = false
    while true do
        task.wait()
        currentEquipSlots = clientSaveGet.PetSlotsPurchased + 1

        if currencyCmds.Get("Diamonds") >= petSlotDiamondCost[currentEquipSlots] and 
        currentEquipSlots < rankCmds.GetMaxPurchasableEquipSlots() and 
        currentEquipSlots + 4 <= MAX_PET_SLOTS then
            if PlaceId == 8737899170 and not teleportedToPetSlotMachine then
                teleportToMachine("4 | Green Forest")
                teleportedToPetSlotMachine = true
            elseif not teleportedToPetSlotMachine then
                teleportToMachine("100 | Tech Spawn")
                teleportedToPetSlotMachine = true
            end

            print("Buying slot " .. tostring(currentEquipSlots) .. " for " .. tostring(petSlotDiamondCost[currentEquipSlots]) .. " diamonds")
            Network.EquipSlotsMachine_RequestPurchase:InvokeServer(currentEquipSlots)
            task.wait(4)

            print("Purchased pet equip slot " .. tostring(currentEquipSlots))
        else
            break
        end
    end
    if teleportedToPetSlotMachine then
        currentZone = nil
        teleportToMaxZone()
    end
end


-- check if enough coins
local function checkEnoughCoinsToHatch(amountOfEggs)
    local bestEggPrice
    for eggName, eggTbl in require(Library.Directory.Eggs) do
        pcall(function()
            if eggData.name == eggName then
                bestEggPrice = require(Library.Balancing.CalcEggPrice)(eggTbl)
            end
        end)
    end
    
    if bestEggPrice * amountOfEggs <= currencyCmds.Get(worldCoin) then
        return true
    end
end


local function getBestEggData()
    bestEgg = clientSaveGet.MaximumAvailableEgg
    eggData = require(Library.Util.EggsUtil).GetByNumber(bestEgg) -- gets eggData.name, .eggNumber
    -- print("New obtained eggData: ", eggData.name, " (", eggData.eggNumber, ")")
end


local function getBestEggPets()
    bestEggPets = {}
    for _, v in game.ReplicatedStorage["__DIRECTORY"].Eggs["Zone Eggs"]:GetDescendants() do
        if string.find(v.Name, eggData.name) then
            for i=1, #require(v)["pets"] do
                table.insert(bestEggPets, require(v)["pets"][i][1])
            end
            break
        end
    end
end


local function autoHatchEgg()
    -- auto hatch with delay
    if (tick() - timeStartEggHatch) >= fastestHatchTime then
        timeStartEggHatch = tick()
        if checkEnoughCoinsToHatch(currentMaxHatch) and currentMaxHatch < MAX_EGG_SLOTS then
            Network.Eggs_RequestPurchase:InvokeServer(eggData.name, currentMaxHatch)
        elseif checkEnoughCoinsToHatch(MAX_EGG_SLOTS) then
            Network.Eggs_RequestPurchase:InvokeServer(eggData.name, MAX_EGG_SLOTS)
        else
            Network.Eggs_RequestPurchase:InvokeServer(eggData.name, 1)
        end
    end
    task.wait(fastestHatchTime)
end


local function teleportAndHatch()
    print("In teleport and hatch")
    -- Teleport to Best Egg
    for _, v in pairs(Workspace.__THINGS.Eggs[worldEgg]:GetChildren()) do
        if string.find(v.Name, tostring(eggData.eggNumber) .. " - ") then
            eggCFrame = v.Tier.CFrame + Vector3.new(0, 10, 0)
        end
    end
    task.wait(1)
    myHumanoidRootPart.CFrame = eggCFrame  -- Teleport to egg
    task.wait(1)
    DeleteAllTextures()

    -- Hatch eggs
    if questName == "BEST_GOLD_PET" then  -- +1 is to hatch 100 extra egg to make sure enough pets to upgrade gold
        for i=1, math.ceil((questActualAmount + 2) * 10 / currentMaxHatch) do
            print("Hatching", questName, ":", i)
            autoHatchEgg()
        end

    elseif questName == "BEST_RAINBOW_PET" then
        for i=1, math.ceil((((questActualAmount + 1) * 100) - totalBestPet) / currentMaxHatch) do
            print("Hatching", questName, ":", i)
            autoHatchEgg()
        end

    elseif BEST_EGG then
        for i=1, math.ceil((questActualAmount / currentMaxHatch)) do
            autoHatchEgg()
        end

    elseif HATCH_RARE_PET then
        while len(clientSaveGet.Goals) > 0 do
            task.wait()
            if clientSaveGet.Goals[goalsNumber]["Type"] == 42 then
                autoHatchEgg()
            else
                break
            end
        end
    elseif checkEnoughCoinsToHatch(math.ceil(60 / currentMaxHatch)) then
        for i=1, math.ceil(60 / currentMaxHatch) do
            autoHatchEgg()
        end
    else
        autoHatchEgg()
    end
        
        
    eggHatchedBefore = eggData.eggNumber
    print("Hatching", eggData.name)
    print("Done Hatching...")
end


-- only for "collect enchant" quest
local function checkEnoughEnchant()
    for enchantId, tbl in inventory.Enchant do
        task.wait()
        local enchantFound = false
        for _, enchantName in ipairs(enchantsToUpgrade) do
            if tbl.id == enchantName and tbl.tn == (questEnchantTier) and tbl._am ~= nil and tbl._am >= 5 then
                return true
            end
        end
    end
    return false
end


-- only for "collect potion" quest
local function checkEnoughPotion()
    for potionId, tbl in inventory.Potion do
        task.wait()
        if tbl.tn == (questPotionTier) and tbl._am ~= nil and tbl._am >= 3 then
            return true
        end
    end
    return false
end


local function thereIsAlreadySomethingInThisArea()
    for eventId, tbl in randomEventCmds.GetActive() do
        if tbl.parentID == currentZone then
            return true
        end
    end
    return false
end


local function consumeRandomEvent(itemName, itemCommand)
    for itemId, tbl in inventory.Misc do
        if tbl.id == itemName then
            print("Consuming", itemName)
            Network:WaitForChild(itemCommand):InvokeServer(itemId)
        end
    end
end


local function useGoldMachine(tbl)
    print("Using Gold Machine")
    if PlaceId == 8737899170 then
        teleportToMachine("10 | Mine")
    else
        teleportToMachine("100 | Tech Spawn")
    end
    print("Using Gold Machine")
    local usedGoldMachine = false
    for petId, tbl in inventory.Pet do
        for _, petName in ipairs(bestEggPets) do
            if tbl.id == petName and tbl._am ~= nil and tbl.pt == nil and tbl._am >= 10 then
                if questName == "BEST_RAINBOW_PET" and math.floor((tbl._am / 10)) * 10 >= (questActualAmount * 100) then
                    Network:WaitForChild("GoldMachine_Activate"):InvokeServer(petId, questActualAmount * 10)
                    task.wait(1)
                    return true
                elseif questName == "BEST_GOLD_PET" and math.floor((tbl._am / 10)) >= questActualAmount then
                    Network:WaitForChild("GoldMachine_Activate"):InvokeServer(petId, questActualAmount)
                    task.wait(1)
                    return true
                else
                    Network:WaitForChild("GoldMachine_Activate"):InvokeServer(petId, math.floor((tbl._am / 10)))
                    usedGoldMachine = true
                end
            end
        end
    end
    if usedGoldMachine then return true end
end


local function useRainbowMachine(tbl)
    print("Using Rainbow Machine")
    if PlaceId == 8737899170 then
        teleportToMachine("31 | Desert Pyramids")
    else
        teleportToMachine("100 | Tech Spawn")
    end
    print("Using Rainbow Machine")
    for petId, tbl in inventory.Pet do
        for _, petName in ipairs(bestEggPets) do
            if tbl.id == petName and tbl._am ~= nil and tbl.pt ~= nil and tbl._am >= 10 and tbl.pt == 1 then  -- tbl.pt if 1 means gold
                if questActualAmount >= math.floor((tbl._am / 10)) then
                    Network:WaitForChild("RainbowMachine_Activate"):InvokeServer(petId, math.floor((tbl._am / 10)))
                else
                    Network:WaitForChild("RainbowMachine_Activate"):InvokeServer(petId, questActualAmount)
                end
                task.wait(1)
                return true
            end
        end
    end
end

-- update upgradeEnchant to upgrade ALL tier ones before teleporting back
local function upgradeEnchant()
    local amountToUpgrade
    if PlaceId == 8737899170 then
        teleportToMachine("16 | Crimson Forest")
    else
        teleportToMachine("100 | Tech Spawn")
    end

    for enchantId, tbl in inventory.Enchant do
        local enchantFound = false
        for _, enchantName in ipairs(enchantsToUpgrade) do
            if tbl.id == enchantName then
                enchantFound = true
                break
            end
        end
        if tbl.tn == (questEnchantTier) and enchantFound then
            if tbl.tn <= 3 and tbl._am ~= nil and tbl._am >= 5 then
                if math.floor(tbl._am / 5) > questActualAmount then
                    amountToUpgrade = questActualAmount
                else
                    amountToUpgrade = math.floor(tbl._am / 5)
                end
                Network:WaitForChild("UpgradeEnchantsMachine_Activate"):InvokeServer(enchantId, amountToUpgrade)
                task.wait(2)
                break
            elseif tbl.tn >= 4 and tbl._am ~= nil and tbl._am >= 7 then
                if math.floor(tbl._am / 7) > questActualAmount then
                    amountToUpgrade = questActualAmount
                else
                    amountToUpgrade = math.floor(tbl._am / 7)
                end
                Network:WaitForChild("UpgradeEnchantsMachine_Activate"):InvokeServer(enchantId, amountToUpgrade)
                task.wait(2)
                break
            end
        end
    end
    currentZone = nil
    teleportToMaxZone()
end

-- update upgradePotion to upgrade ALL tier ones before teleporting back
local function upgradePotion()
    print("Upgrading Potion")
    local amountToUpgrade
    if PlaceId == 8737899170 then
        teleportToMachine("13 | Dark Forest")
    else
        teleportToMachine("100 | Tech Spawn")
    end

    for potionId, tbl in inventory.Potion do
        if tbl.tn == (questPotionTier) then
            if tbl.tn <= 2 and tbl._am ~= nil and tbl._am >= 3 then
                if math.floor(tbl._am / 3) > questActualAmount then
                    amountToUpgrade = questActualAmount
                else
                    amountToUpgrade = math.floor(tbl._am / 3)
                end
                Network:WaitForChild("UpgradePotionsMachine_Activate"):InvokeServer(potionId, amountToUpgrade)
                task.wait(2)
                break
            elseif tbl.tn >= 3 and tbl._am ~= nil and tbl._am >= 4 then
                if math.floor(tbl._am / 4) > questActualAmount then
                    amountToUpgrade = questActualAmount
                else
                    amountToUpgrade = math.floor(tbl._am / 4)
                end
                Network:WaitForChild("UpgradePotionsMachine_Activate"):InvokeServer(potionId, amountToUpgrade)
                task.wait(2)
                break
            end
        end
    end
    currentZone = nil
    teleportToMaxZone()
end


local function checkAndRedeemRankRewards()
    local RankStars = clientSaveGet.RankStars
    local RankTitle = rankCmds.GetTitle()
    local totalRankStars = 0

    for questNum, tbl in require(Library.Directory.Ranks)[RankTitle].Rewards do
        task.wait()
        totalRankStars = totalRankStars + tbl.StarsRequired
        if RankStars >= totalRankStars then
            if not clientSaveGet.RedeemedRankRewards[tostring(questNum)] then -- [num] num has to be string
                print("Redeeming Reward:", questNum)
                Network:WaitForChild("Ranks_ClaimReward"):FireServer(questNum)
                break
            end
        end
    end
end


if maxZoneData.ZoneNumber >= 99 and PlaceId == 8737899170 then
    Network["World2Teleport"]:InvokeServer()
    task.wait(10)
end


Network:WaitForChild("ForeverPacks: Claim Free"):InvokeServer("Default")  -- collect free foreverpack

if not clientSaveGet.PickedStarterPet then
    print("New Account Detected... Picking Starter Pets.")
    Network:WaitForChild("Pick Starter Pets"):InvokeServer(unpack({"Cat", "Dog"}))
    task.wait(5)
end

if nextRebirthData then
    rebirthNumber = nextRebirthData.RebirthNumber
    rebirthZone = nextRebirthData.ZoneNumberRequired
end


task.spawn(function()
    while true do
        task.wait(0.5)
        checkAndRedeemRankRewards()

        if inventory.Fruit ~= nil then
            checkAndConsumeFruits()
            checkAndConsumeGifts() -- misc
            checkAndConsumeToys() -- misc
        end
        if inventory.Potion ~= nil then
            checkAndConsumePotions()
        end
        if inventory.Enchant ~= nil then
            checkAndEquipBestSpecifiedEnchants()
        end

        local zoneName, maxZoneData = zoneCmds.GetMaxOwnedZone()
        if maxZoneData.ZoneNumber >= 12 then
            checkAndRedeemGift()
        end
        
        if hypeCmds.IsActive() and hypeCmds.GetTimeRemaining() == 0 and not hypeCmds.IsCompleted() then
            Network:WaitForChild("Hype Wheel: Claim"):InvokeServer()
        end

        if Active:FindFirstChild("StairwayToHeaven") then 
            myHumanoidRootPart.CFrame = game:GetService("Workspace")["__THINGS"].Instances.StairwayToHeaven.Teleports.Leave.CFrame + Vector3.new(0, 5, 0)
            task.wait(5)
            currentZone = nil
            teleportToMaxZone()
        end

        if LocalPlayer.PlayerGui.RankUp.Enabled then
            LocalPlayer.PlayerGui.RankUp.Enabled = false
        end
        
        if LocalPlayer.PlayerGui.Rebirth.Enabled then
            LocalPlayer.PlayerGui.Rebirth.Enabled = false
        end

        if LocalPlayer.PlayerGui.MasteryPerk.Enabled then
            LocalPlayer.PlayerGui.MasteryPerk.Enabled = false
        end

        if LocalPlayer.PlayerGui.Message.Enabled then
            LocalPlayer.PlayerGui.Message.Enabled = false
        end
    end
end)


print("Autorank Starting...")
teleportToMaxZone()
getBestEggData()
getBestEggPets()


startAutoHatchEggDelay = tick()

while rebirthNotDone do
    if PlaceId == 8737899170 then
        if maxZoneData.ZoneNumber >= 2 then 
            checkAndPurchaseUpgrades()  
        end
    end

    if maxZoneData.ZoneNumber >= 4 then
        checkAndPurchasePetSlot()
    end
    if maxZoneData.ZoneNumber >= 8 then
        checkAndPurchaseEggSlot()
    end


    if maxZoneData.ZoneNumber < getgenv().autoWorldConfig.ZONE_TO_REACH then
        local boughtNewZone = false
        while true do
            task.wait()
            local nextZoneName, nextZoneData = zoneCmds.GetNextZone()
            local success, _ = Network.Zones_RequestPurchase:InvokeServer(nextZoneName)
            if success then
                boughtNewZone = true
                print("Successfully purchased " .. nextZoneName)
                startAutoHatchEggDelay = tick()
                task.wait(1)
            else
                break
            end
        end
        if boughtNewZone then
            currentZone = nil
            teleportToMaxZone()
        end
    end

    if getgenv().autoWorldConfig.AUTO_REBIRTH then
        pcall(function()
            if maxZoneData.ZoneNumber >= rebirthZone then
                print("Rebirthing")
                Network.Rebirth_Request:InvokeServer(tostring(rebirthNumber))
                task.wait(15)
                maxZoneName, maxZoneData = zoneCmds.GetMaxOwnedZone()
                nextRebirthData = rebirthCmds.GetNextRebirth()
                if nextRebirthData then
                    rebirthNumber = nextRebirthData.RebirthNumber
                    rebirthZone = nextRebirthData.ZoneNumberRequired
                end
            end
        end)
    end

    getBestEggData()
    getBestEggPets()

    if maxZoneData.ZoneNumber < getgenv().autoWorldConfig.ZONE_TO_REACH and 
    (tick() - startAutoHatchEggDelay) >= autoHatchEggDelay and 
    eggHatchedBefore ~= eggData.eggNumber then

        local bestEggPrice
        for eggName, eggTbl in require(Library.Directory.Eggs) do
            pcall(function()
                if eggData.name == eggName then
                    bestEggPrice = require(Library.Balancing.CalcEggPrice)(eggTbl)
                end
            end)
        end
        
        local maxAmountToHatch = math.floor(currencyCmds.Get(worldCoin) / bestEggPrice)
        if maxAmountToHatch >= 40 then  -- limit hatch incase too many
            maxAmountToHatch = 40
        end

        if checkEnoughCoinsToHatch(maxAmountToHatch) then
            teleportAndHatch()
            currentZone = nil
            teleportToMaxZone()
            task.wait(1)
            startAutoHatchEggDelay = tick()
        end
    end


    if rankCmds.GetMaxRank() < getgenv().autoWorldConfig.RANK_TO_REACH then
        for goalsNum, tbl in clientSaveGet.Goals do
            task.wait()
            BEST_EGG = false
            goldToRainbow = false
            HATCH_RARE_PET = false

            goalsNumber = goalsNum
            questName = checkType(tbl["Type"])
            questAmount = tbl["Amount"]
            questProgress = tbl["Progress"]
            breakableType = tbl.BreakableType
            if tbl["PotionTier"] ~= nil and tbl["PotionTier"] > 1 then
                questPotionTier = tbl["PotionTier"] - 1
            else
                questPotionTier = 1  -- default questPotionTier 1, it will only enchant tier 1 when "collecting potion"
            end
            if tbl["EnchantTier"] ~= nil and tbl["EnchantTier"] > 1 then
                questEnchantTier = tbl["EnchantTier"] - 1
            else
                questEnchantTier = 1  -- default questEnchantTier 1, it will only enchant tier 1 when "collecting enchant"
            end

            questActualAmount = nil
            callByBoss = false

            questActualAmount = questAmount - questProgress


            -- Using Misc Items
            if questName == "BEST_LUCKYBLOCK" then
                print("Doing Quest:", questName)
                for itemId, tbl in inventory.Misc do
                    if tbl.id == "Mini Lucky Block" then
                        for i=1, questActualAmount do
                            while true do
                                task.wait()
                                if len(clientSaveGet.Goals) == 0 then break end
                                local questId = clientSaveGet.Goals[goalsNumber]["Type"]
                                if not thereIsAlreadySomethingInThisArea() and checkType(questId) == "BEST_LUCKYBLOCK" then
                                    consumeRandomEvent("Mini Lucky Block", "MiniLuckyBlock_Consume")
                                    startAutoHatchEggDelay = tick()
                                    while thereIsAlreadySomethingInThisArea() do
                                        task.wait(0.3)
                                    end
                                    break
                                elseif checkType(questId) ~= "BEST_LUCKYBLOCK" then
                                    break
                                end
                            end
                        end
                        break
                    end
                end



            elseif questName == "BEST_PINATA" then
                print("Doing Quest:", questName)
                for itemId, tbl in inventory.Misc do
                    if tbl.id == "Mini Pinata" then
                        for i=1, questActualAmount do
                            while true do
                                task.wait()
                                if len(clientSaveGet.Goals) == 0 then break end
                                local questId = clientSaveGet.Goals[goalsNumber]["Type"]
                                if not thereIsAlreadySomethingInThisArea() and checkType(questId) == "BEST_PINATA" then
                                    consumeRandomEvent("Mini Pinata", "MiniPinata_Consume")
                                    startAutoHatchEggDelay = tick()
                                    while thereIsAlreadySomethingInThisArea() do
                                        task.wait(0.3)
                                    end
                                    break
                                elseif checkType(questId) ~= "BEST_PINATA" then
                                    break
                                end
                            end
                        end
                        break
                    end
                end



            elseif questName == "BEST_COMET" or questName == "COMET" then
                print("Doing Quest:", questName)
                for itemId, tbl in inventory.Misc do
                    if tbl.id == "Comet" then
                        print(tbl.id, itemId)
                        for i=1, questActualAmount do
                            while true do
                                task.wait()
                                if len(clientSaveGet.Goals) == 0 then break end
                                local questId = clientSaveGet.Goals[goalsNumber]["Type"]
                                if not thereIsAlreadySomethingInThisArea() and (checkType(questId) == "BEST_COMET" or checkType(questId) == "COMET") then
                                    consumeRandomEvent("Comet", "Comet_Spawn")
                                    startAutoHatchEggDelay = tick()
                                    while thereIsAlreadySomethingInThisArea() do
                                        task.wait(0.3)
                                    end
                                    break
                                elseif checkType(questId) ~= "BEST_COMET" and checkType(questId) ~= "COMET" then
                                    break
                                end
                            end
                        end
                        break
                    end
                end



            elseif questName == "BEST_COIN_JAR" or questName == "COIN_JAR" then
                print("Doing Quest:", questName)
                local coinJar
                for itemId, tbl in inventory.Misc do
                    task.wait()
                    if tbl.id == "Basic Coin Jar" then
                        coinJar = tbl.id
                        break
                    elseif tbl.id == "Giant Coin Jar" then
                        coinJar = tbl.id
                    end
                end
                if coinJar ~= nil then
                    for i=1, questActualAmount do
                        while true do
                            task.wait()
                            if len(clientSaveGet.Goals) == 0 then break end
                            local questId = clientSaveGet.Goals[goalsNumber]["Type"]
                            if not thereIsAlreadySomethingInThisArea() and (checkType(questId) == "BEST_COIN_JAR" or checkType(questId) == "COIN_JAR") then
                                consumeRandomEvent(coinJar, "CoinJar_Spawn")
                                startAutoHatchEggDelay = tick()
                                while thereIsAlreadySomethingInThisArea() do
                                    task.wait(0.3)
                                end
                                break
                            elseif checkType(questId) ~= "BEST_COIN_JAR" and checkType(questId) ~= "COIN_JAR" then
                                break
                            end
                        end
                    end
                    break
                end


            -- Collecting (update required, boss chest zone)
            elseif questName == "COLLECT_POTION" or questName == "COLLECT_ENCHANT" then
                print("Doing Quest:", questName)
                print("Beach Boss Chest Cooldown Time: ".. (os.time() - beachBossChestCooldownStart))
                print("Underworld Boss Chest Cooldown Time: ".. (os.time() - underWorldBossChestCooldownStart))
                print("No Path Forest Boss Chest Cooldown Time: ".. (os.time() - noPathForestBossChestCooldownStart))
                print("Heaven Gates Boss Chest Cooldown Time: ".. (os.time() - heavenGatesBossChestCooldownStart))

                if PlaceId == 8737899170 and 
                ((os.time() - beachBossChestCooldownStart >= bossChestCooldown and maxZoneData.ZoneNumber >= 20) or
                (os.time() - underWorldBossChestCooldownStart >= bossChestCooldown and maxZoneData.ZoneNumber >= 46) or
                (os.time() - noPathForestBossChestCooldownStart >= bossChestCooldown and maxZoneData.ZoneNumber >= 70) or
                (os.time() - heavenGatesBossChestCooldownStart >= bossChestCooldown and maxZoneData.ZoneNumber >= 95)) then
                    callByBoss = true
                    autoBossChest()
                    currentZone = nil
                    teleportToMaxZone()
                elseif maxZoneData.ZoneNumber >= 16 and questName == "COLLECT_ENCHANT" and checkEnoughEnchant() then
                    upgradeEnchant()
                elseif maxZoneData.ZoneNumber >= 13 and questName == "COLLECT_POTION" and checkEnoughPotion() then
                    upgradePotion()
                elseif PlaceId == 8737899170 then
                    buyVendingMachine()
                end


            -- Upgrading
            elseif maxZoneData.ZoneNumber >= 13 and questName == "UPGRADE_POTION" then
                print("Doing Quest:", questName)
                -- tier 3 upgrade to 4 requires 4
                -- tier 1/2 upgrade to 2/3 requires 3
                upgradePotion()

            elseif maxZoneData.ZoneNumber >= 16 and questName == "UPGRADE_ENCHANT" then
                print("Doing Quest:", questName)
                -- tier 4 upgrade to 5 requires 7
                -- tier 1-3 upgrade to 2-4 requires 5
                upgradeEnchant()


            -- Upgrading Pets
            elseif maxZoneData.ZoneNumber >= 10 and questName == "BEST_GOLD_PET" then
                print("Doing Quest:", questName)
                startAutoHatchEggDelay = time()
                while checkType(clientSaveGet.Goals[goalsNumber]["Type"]) == "BEST_GOLD_PET" do
                    task.wait()
                    local usedGoldMachine
                    usedGoldMachine = useGoldMachine(tbl)  
                    if not usedGoldMachine then  -- get normal pets
                        if checkEnoughCoinsToHatch(math.ceil((questActualAmount + 2) * 10)) then
                            teleportAndHatch()
                        else
                            currentZone = nil
                            teleportToMaxZone()
                            while not checkEnoughCoinsToHatch(math.ceil((questActualAmount + 2) * 10)) do
                                task.wait(1)
                            end
                        end
                    end
                end
                currentZone = nil
                teleportToMaxZone()

            elseif maxZoneData.ZoneNumber >= 31 and questName == "BEST_RAINBOW_PET" then
                print("Doing Quest:", questName)
                startAutoHatchEggDelay = time()
                while checkType(clientSaveGet.Goals[goalsNumber]["Type"]) == "BEST_RAINBOW_PET" do
                    task.wait()
                    local usedRainbowMachine
                    totalBestPet = 0
                    usedRainbowMachine = useRainbowMachine(tbl)
                    if not usedRainbowMachine then  -- get golden pets
                        -- Check if have enough normal pet, just upgrade to gold
                        for petId, tbl in inventory.Pet do
                            for _, petName in ipairs(bestEggPets) do
                                task.wait()
                                -- if all best egg pet not enough
                                if tbl.id == petName and tbl._am ~= nil and tbl.pt == nil and tbl._am >= 10 then
                                    totalBestPet = totalBestPet + math.floor(tbl._am / 10) * 10
                                end
                            end
                        end

                        if totalBestPet >= questActualAmount * 100 then
                            useGoldMachine(tbl)
                        else
                            if checkEnoughCoinsToHatch(math.ceil((questActualAmount + 2) * 10)) then
                                teleportAndHatch()
                            else
                                currentZone = nil
                                teleportToMaxZone()
                                while not checkEnoughCoinsToHatch(math.ceil((((questActualAmount + 1) * 100) - totalBestPet))) do
                                    task.wait(1)
                                end
                            end
                        end
                    end
                end
                currentZone = nil
                teleportToMaxZone()

            -- Using Items
            -- Potions cooldown too long, have to drink when required for goals
            elseif questName == "USE_POTION" then
                print("Doing Quest:", questName)
                for i=1, questActualAmount do
                    questPotionTier = questPotionTier + 1
                    consumeGoalsPotion(questPotionTier)
                end

            -- Fruits ignored, will be eaten eventually within 5 mins.
            -- elseif questName == "USE_FRUIT" then
            elseif questName == "USE_FLAG" then
                print("Doing Quest:", questName)
                for i=1, questActualAmount do
                    if getupvalues(flexibleFlagCmds.GetActiveFlag)[3]["1!".. zoneCmds.GetMaxOwnedZone() .."!Main"] ~= nil then
                        local activeFlagName = getupvalues(flexibleFlagCmds.GetActiveFlag)[3]["1!".. zoneCmds.GetMaxOwnedZone() .."!Main"].FlagId  -- get active flag name in specified zone.
                        for itemId, tbl in inventory.Misc do
                            if tbl.id == activeFlagName then
                                print("Using ", tbl.id)
                                flexibleFlagCmds.Consume(tbl.id, itemId)
                                task.wait(1)
                            end
                        end
                    else
                        for itemId, tbl in inventory.Misc do
                            if tbl.id == "Coins Flag" or tbl.id == "Diamonds Flag" then
                                print("Using ", tbl.id)
                                flexibleFlagCmds.Consume(tbl.id, itemId)
                                task.wait(1)
                            end
                        end
                    end
                end
                

            -- Hatch Eggs
            elseif questName == "EGG" then
                if checkEnoughCoinsToHatch(tonumber(questActualAmount)) then
                    print("Doing Quest:", questName)
                    startAutoHatchEggDelay = time()
                    BEST_EGG = true
                    teleportAndHatch()
                    currentZone = nil
                    teleportToMaxZone()
                end
            elseif questName == "BEST_EGG" then
                if checkEnoughCoinsToHatch(tonumber(questActualAmount)) then
                    print("Doing Quest:", questName)
                    startAutoHatchEggDelay = time()
                    BEST_EGG = true
                    teleportAndHatch()
                    currentZone = nil
                    teleportToMaxZone()
                end
            elseif maxZoneData.ZoneNumber >= getgenv().autoWorldConfig.ZONE_TO_REACH and questName == "HATCH_RARE_PET" then
                if checkEnoughCoinsToHatch(1000) then
                    print("Doing Quest:", questName)
                    startAutoHatchEggDelay = time()
                    if len(clientSaveGet.Goals) > 0 then
                        HATCH_RARE_PET = true
                        teleportAndHatch()
                        currentZone = nil
                        teleportToMaxZone()
                    end
                end

            -- DIGGING AND FISHING
            elseif maxZoneData.ZoneNumber >= 27 and questName == "FISHING" and PlaceId == 8737899170 then
                print("Doing Quest:", questName)
                print("Doing Fishing")
                teleportToInstance("Fishing")
                startAutoHatchEggDelay = time()
                if not fishingOptimized then
                    fishingOptimized = true
                    optimizeFishing()
                end
                startFishing()
                currentZone = nil
                teleportToMaxZone()

            elseif maxZoneData.ZoneNumber >= 30 and questName == "DIGSITE" and PlaceId == 8737899170 then
                print("Doing Quest:", questName)
                if len(clientSaveGet.Goals) > 0 then
                    teleportToDigsite()
                    startAutoHatchEggDelay = time()
                    -- Delete digsite texture (SAVE CPU)
                    for _, v in pairs(Active.Digsite:GetChildren()) do
                        if string.find(v.Name, "hill") or string.find(v.Name, "Flower") or string.find(v.Name, "rock") or string.find(v.Name, "Meshes") or string.find(v.Name, "Sign") or string.find(v.Name, "Wood") or v.Name == "Model" then
                            v:Destroy()
                        end
                    end
                    startDigging()
                    currentZone = nil
                    teleportToMaxZone()
                end

            elseif maxZoneData.ZoneNumber >= 5 and questName == "SPAWN_OBBY" and PlaceId == 8737899170 then
                teleportToInstance("SpawnObby")
                startAutoHatchEggDelay = time()
                task.wait(2)
                startSpawnObby()

            elseif maxZoneData.ZoneNumber >= 11 and questName == "MINEFIELD" and PlaceId == 8737899170 then
                teleportToInstance("Minefield")
                startAutoHatchEggDelay = time()
                task.wait(2)
                startMinefield()

            elseif maxZoneData.ZoneNumber >= 18 and questName == "JUNGLE_OBBY" and PlaceId == 8737899170 then
                teleportToInstance("JungleObby")
                startAutoHatchEggDelay = time()
                task.wait(2)
                startJungleObby()

            elseif maxZoneData.ZoneNumber >= 23 and questName == "ATLANTIS" and PlaceId == 8737899170 then
                teleportToInstance("Atlantis")
                startAutoHatchEggDelay = time()
                task.wait(2)
                startAtlantis()

            elseif maxZoneData.ZoneNumber >= 31 and questName == "PYRAMID_OBBY" and PlaceId == 8737899170 then
                teleportToInstance("PyramidObby")
                startAutoHatchEggDelay = time()
                task.wait(2)
                startPyramidObby()

            elseif maxZoneData.ZoneNumber >= 38 and questName == "ICE_OBBY" and PlaceId == 8737899170 then
                teleportToInstance("IceObby")
                startAutoHatchEggDelay = time()
                task.wait(2)
                startIceObby()

            -- ignore sledrace (have to wait for progressing race to finish)

            elseif maxZoneData.ZoneNumber >= 6 and questName == "BREAKABLE" and breakableType == "Present" then
                print("Breaking Present")
                teleportToPresentOrSafe("6 | Cherry Blossom")
                startAutoHatchEggDelay = time()
                repeat
                    task.wait(1)
                until require(game:GetService("ReplicatedStorage").Library.Client.Save).Get().Goals[goalsNumber].BreakableType ~= "Present"
                currentZone = nil
                teleportToMaxZone()

            elseif maxZoneData.ZoneNumber >= 22 and questName == "BREAKABLE" and breakableType == "Safe" then
                print("Breaking Safe")
                teleportToPresentOrSafe("22 | Shipwreck")
                startAutoHatchEggDelay = time()
                repeat
                    task.wait(1)
                until require(game:GetService("ReplicatedStorage").Library.Client.Save).Get().Goals[goalsNumber].BreakableType ~= "Safe"
                currentZone = nil
                teleportToMaxZone()
            end
        end
    end

    task.wait()
end

print("Done with rank")



