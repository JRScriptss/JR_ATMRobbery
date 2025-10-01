Config = {}
-- Framework
Config.Framework = "ESX" -- ESX or Qb
Config.AccountGain = "black_money" -- black_money/money/bank // For ESX || Cash for QbCore

Config.Fiveguard = false -- Use fiveguard ? For Ban 
Config.FiveguardName = "fiveguard" -- The name of your fiveguard file

-- MiniGame
Config.MiniGame = "digital" -- Options: "digital", "thermite", "number_maze"

-- Target
Config.Target = "ox_target" -- ox_target or qb-target

-- Dispatch & Police
Config.Dispatch = "cd_dispatch" -- cd_dispatch | qs_dispatch | rcore_dispatch | ps-dispatch | default
Config.MinPolice = 2
Config.PoliceJob = "police"

-- Item
Config.ItemRequire = "hack_usb" -- Item to start the ATM Robbery
Config.RemoveItem = true -- true or false

-- Gain Stolen
Config.GainStolen = math.random(10000, 15000) -- Ammount of money player gets from doing the atm

Config.WebhooksLinks = "https://discord.com/api/webhooks/1391416277100134430/S4qgG6-NaPPeSqRRe_E0fR2dAbjQrd6wHjtzJ_80IVNAuUgdGQaD__iNFAQMR6DVFKHB" -- Discord Logs
