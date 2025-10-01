lib.locale()

local ESX = nil
local QBCore = nil
local activeRobberies = {}

if Config.Framework == "ESX" then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == "Qb" then
    QBCore = exports['qb-core']:GetCoreObject()
end

local function formatMessage(template, variables)
    return (template:gsub("{{(.-)}}", function(key)
        return tostring(variables[key] or key)
    end))
end

local lastRobbedTime = 0
local cooldownTime = 900

local function getPlayerFromId(source)
    if Config.Framework == "ESX" then
        return ESX.GetPlayerFromId(source)
    elseif Config.Framework == "Qb" then
        return QBCore.Functions.GetPlayer(source)
    end
    return nil
end

local function startRobbery(playerId)
    activeRobberies[playerId] = true
end

local function endRobbery(playerId)
    activeRobberies[playerId] = nil
end

local function isRobberyActive(playerId)
    return activeRobberies[playerId] ~= nil
end

RegisterServerEvent("JRScriptsATM:RemoveItem")
AddEventHandler("JRScriptsATM:RemoveItem", function(item)
    local playerId = source
    exports.ox_inventory:RemoveItem(playerId, item, 1)
end)

RegisterServerEvent("JRScriptsATM:GiveReward")
AddEventHandler("JRScriptsATM:GiveReward", function()
    local playerId = source
    local xPlayer = getPlayerFromId(playerId)

    if not xPlayer then
        return
    end

    local reward = math.random(10000, 15000)
    local account = Config.AccountGain or "black_money"

    if Config.Framework == "ESX" then
        xPlayer.addAccountMoney(account, reward)
    elseif Config.Framework == "Qb" then
        xPlayer.Functions.AddMoney(account, reward)
    end

    TriggerClientEvent('JRScripts:showNotification', playerId, locale('notification_title'), locale('notification_stolen_gain') .. reward, 'success')

    local playerName = xPlayer.getName and xPlayer.getName() or xPlayer.PlayerData.name
    local playerIdentifier = xPlayer.identifier or xPlayer.PlayerData.citizenid

    webhooks(formatMessage(locale('logs_gain'), {
        playerName = playerName,
        playerId = playerId,
        playerIdentifier = playerIdentifier,
        reward = reward
    }), 3066993)

    print("[JR_ATMRobbery] Gave £" .. reward .. " (" .. account .. ") to player " .. playerId)
end)

RegisterServerEvent("JRScriptsATM:AttemptRob")
AddEventHandler("JRScriptsATM:AttemptRob", function()
    local currentTime = os.time()
    local playerId = source
    local xPlayer = getPlayerFromId(playerId)

    if not xPlayer then
        print("Error: Player data not found.")
        return
    end

    if isRobberyActive(playerId) then
        TriggerClientEvent('JRScripts:showNotification', playerId, locale('notification_title'), locale('robbery_active'), 'error')
        return
    end

    local playerName = xPlayer.getName and xPlayer.getName() or xPlayer.PlayerData.name
    local playerIdentifier = xPlayer.identifier or xPlayer.PlayerData.citizenid

    if currentTime - lastRobbedTime >= cooldownTime then
        lastRobbedTime = currentTime
        startRobbery(playerId)
        TriggerClientEvent("JRScripts:AtmRob", playerId)

        if Config.RemoveItem then
            framework.removeItem({ player = playerId, item = Config.ItemRequire, count = 1 })
        else
            print('no remove item')
        end

        webhooks(formatMessage(locale('logs_success'), {playerName = playerName, playerId = playerId, playerIdentifier = playerIdentifier}), 3066993)
    else
        local timeLeft = math.ceil((cooldownTime - (currentTime - lastRobbedTime)) / 60)
        TriggerClientEvent('JRScripts:showNotification', playerId, locale('notification_title'), locale('notification_timeleft_partone') .. timeLeft .. locale('notification_timeleft_parttwo'), 'error')

        webhooks(formatMessage(locale('logs_failure'), {playerName = playerName, playerId = playerId, playerIdentifier = playerIdentifier, timeLeft = timeLeft}), 15158332)
    end
end)

RegisterServerEvent('JRScripts:Server:PoliceAlert')
AddEventHandler('JRScripts:Server:PoliceAlert', function(coords)
    if Config.Framework then
        if Config.Framework == "ESX" then
            local players = ESX.GetPlayers()
            for i = 1, #players do
                local player = ESX.GetPlayerFromId(players[i])
                for k, v in pairs(Config.PoliceJob) do
                    if player.job.name == v then
                        TriggerClientEvent('JRScripts:Client:PoliceAlert', players[i], coords)
                    end
                end
            end
        elseif Config.Framework == "Qb" then
            local players = QBCore.Functions.GetPlayers()
            for i = 1, #players do
                local player = QBCore.Functions.GetPlayer(players[i])
                for k, v in pairs(Config.PoliceJob) do
                    if player.PlayerData.job.name == v then
                        TriggerClientEvent('JRScripts:Client:PoliceAlert', players[i], coords)
                    end
                end
            end
        end
    end
end)

lib.callback.register('JRScriptsATM:HasItem', function(source)
    return framework.hasItems({ player = source, items = Config.ItemRequire })
end)

-- Server-side utility to count police
lib.callback.register('JRScripts:GetPoliceCount', function(source)
    local count = 0
    for _, id in pairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(id) -- Change to QBCore/Qbox if needed
        if xPlayer and xPlayer.job and xPlayer.job.name == Config.PoliceJob then
            count += 1
        end
    end
    return count
end)
