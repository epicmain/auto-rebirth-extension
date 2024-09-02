_G.autoPetSlot = true

local GEM_WAIT_DELAY = 5 -- time it will wait before checking your gem count again
local RANK_WAIT_DELAY = 5 -- time it will wait before checking your rank again


local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = ReplicatedStorage:WaitForChild("Library")
local LocalPlayer = game:GetService("Players").LocalPlayer

local diamondCost = {
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
    [26] = 6500,
    [27] = 6750,
    [28] = 7000,
    [29] = 6250,
    [30] = 7250,
    [31] = 8500,
    [32] = 10000,
    [33] = 15000,
    [34] = 20000,
    [35] = 30000,
    [36] = 35000,
    [37] = 45000,
    [38] = 60000,
    [39] = 70000,
    [40] = 85000,
    [41] = 100000,
    [42] = 150000,
    [43] = 200000,
    [44] = 250000,
    [45] = 300000,
    [46] = 350000,
    [47] = 400000,
    [48] = 450000,
    [49] = 500000,
    [50] = 550000,
    [51] = 600000,
    [52] = 650000,
    [53] = 700000,
    [54] = 750000,
    [55] = 800000,
    [56] = 850000,
    [57] = 900000,
    [58] = 950000,
    [59] = 1000000,
    [60] = 1050000,
    [61] = 1100000,
    [62] = 1150000,
    [63] = 1200000,
    [64] = 1250000,
    [65] = 1300000,
    [66] = 1350000,
    [67] = 1400000,
    [68] = 1450000,
    [69] = 1500000,
    [70] = 1550000,
    [71] = 1600000,
    [72] = 1650000,
    [73] = 1700000,
    [74] = 1750000,
    [75] = 1800000,
    [76] = 1850000,
    [77] = 1900000,
    [78] = 1950000,
    [79] = 2000000,
    [80] = 2050000,
    [81] = 2100000,
    [82] = 2150000,
    [83] = 2200000,
    [84] = 2250000,
    [85] = 2300000,
    [86] = 2350000,
    [87] = 2400000,
    [88] = 2450000,
    [89] = 2500000
}


local currentEquips = require(Library.Client.Save).Get().PetSlotsPurchased
local currentmaxPurchaseableEquips = require(Library.Client.RankCmds).GetMaxPurchasableEquipSlots()
local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame

local function teleportToEquipMachine()
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

print("Starting auto pet slot purchase")
while _G.autoPetSlot do

    print("Waiting for enough gems")
    while require(Library.Client.CurrencyCmds).Get("Diamonds") < diamondCost[currentEquips + 1] do
        task.wait(GEM_WAIT_DELAY)
    end

    if currentEquips < require(Library.Client.RankCmds).GetMaxPurchasableEquipSlots() then
        print("Buying slot " .. tostring(currentEquips + 1) .. " for " .. tostring(diamondCost[currentEquips + 1]) .. " diamonds")

        teleportToEquipMachine()

        task.wait()

        local args = {
            [1] = currentEquips + 1
        }

        game:GetService("ReplicatedStorage").Network.EquipSlotsMachine_RequestPurchase:InvokeServer(unpack(args))
        currentEquips = currentEquips + 1

        print("Purchased pet equip slot " .. tostring(currentEquips + 1))
        LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
    else
        print("Already have max amount of pet equip slots, waiting for rankup")
        while currentmaxPurchaseableEquips == require(Library.Client.RankCmds).GetMaxPurchasableEquipSlots() do
            task.wait(RANK_WAIT_DELAY)
        end
    end
end