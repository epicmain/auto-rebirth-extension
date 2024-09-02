getgenv().autoEgg = true

getgenv().autoEggConfig = {
    GEM_WAIT_DELAY = 5, -- time it will wait before checking your gem count again
    RANK_WAIT_DELAY = 5 -- time it will wait before checking your rank again
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/auto-egg-slots.lua"))()
