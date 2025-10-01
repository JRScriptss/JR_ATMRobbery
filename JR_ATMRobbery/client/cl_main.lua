lib.locale()

-- Framework setup
if Config.Framework then
    if Config.Framework == "ESX" then
        ESX = exports['es_extended']:getSharedObject()
    elseif Config.Framework == "Qb" then
        QBCore = exports['qb-core']:GetCoreObject()
    end
end

-- ATM Models
local atmProps = {
    "prop_atm_01",
    "prop_atm_02",
    "prop_atm_03",
    "prop_fleeca_atm",
    "v_5_b_atm1",
    "v_5_b_atm2"
}

-- ox_target integration
if Config.Target == "ox_target" then
    exports.ox_target:addModel(atmProps, {
        {
            name = 'hackingATM',
            icon = 'fa-solid fa-mobile-retro',
            label = locale('target_rob_atm'),
            onSelect = function()
                local hasItem = lib.callback.await('JRScriptsATM:HasItem', Config.ItemRequire)
                if not hasItem then
                    utils.JRScriptsNotify(locale('notification_title'), locale('notification_noobeject_message'), 'error')
                    return
                end

                local policeCount = lib.callback.await('JRScripts:GetPoliceCount')
                if policeCount < Config.MinPolice then
                    utils.JRScriptsNotify(locale('notification_title'), locale('not_enough_police'), 'error')
                    return
                end

                TriggerEvent("JRScripts:AtmRob")
            end
        }
    })

-- qb-target integration
elseif Config.Target == "qb-target" then
    exports['qb-target']:AddTargetModel(atmProps, {
        options = {
            {
                num = 1,
                type = "client",
                icon = 'fa-solid fa-mobile-retro',
                label = locale('target_rob_atm'),
                action = function()
                    local hasItem = lib.callback.await('JRScriptsATM:HasItem', Config.ItemRequire)
                    if not hasItem then
                        utils.JRScriptsNotify(locale('notification_title'), locale('notification_noobeject_message'), 'error')
                        return
                    end

                    local policeCount = lib.callback.await('JRScripts:GetPoliceCount')
                    if policeCount < Config.MinPolice then
                        utils.JRScriptsNotify(locale('notification_title'), locale('not_enough_police'), 'error')
                        return
                    end

                    TriggerEvent("JRScripts:AtmRob")
                end
            }
        },
        distance = 2.5,
    })
end

function removeRequiredItem()
    TriggerServerEvent("JRScriptsATM:RemoveItem", Config.ItemRequire)
end

-- Robbery logic
RegisterNetEvent('JRScripts:AtmRob')
AddEventHandler('JRScripts:AtmRob', function()
    utils.JRScriptsNotify(locale('notification_title'), locale('notification_startatm_message'), 'info')

    local progressbar = lib.progressCircle({
        duration = 3000,
        label = locale('progress_insertion_card'),
        position = 'bottom',
        disable = {
            car = true,
            combat = true,
            move = true,
        },
        anim = {
            dict = 'anim@amb@prop_human_atm@interior@male@enter',
            clip = 'enter'
        }
    })
	removeRequiredItem()	
    -- Alert police
    if Config.Framework and (Config.Framework == "ESX" or Config.Framework == "Qb") then
        local coords = GetEntityCoords(PlayerPedId())
        utils.JRScriptsPoliceAlert(coords)
    end

    -- Handle mini-games
    if Config.MiniGame == "digital" then
        utils.StartAnimation('anim@amb@prop_human_atm@interior@male@enter', 'enter')
        TriggerEvent("utk_fingerprint:Start", 3, 2, 2, function(outcome, reason)
            utils.StopAnimation()
            if outcome then
                Wait(4500)
                utils.OnSuccess()
            else
                utils.OnFailure(reason)
            end
        end)

    elseif Config.MiniGame == "thermite" then
        utils.StartAnimation('anim@amb@prop_human_atm@interior@male@enter', 'enter')
        exports['ps-ui']:Thermite(function(success)
            utils.StopAnimation()
            if success then
                utils.OnSuccess()
            else
                utils.OnFailure("Thermite failed")
            end
        end, 10, 5, 3)

    elseif Config.MiniGame == "number_maze" then
        utils.StartAnimation('anim@amb@prop_human_atm@interior@male@enter', 'enter')
        exports['ps-ui']:Maze(function(success)
            utils.StopAnimation()
            if success then
                utils.OnSuccess()
            else
                utils.OnFailure("Maze failed")
            end
        end, 20)

    else
    end
end)
