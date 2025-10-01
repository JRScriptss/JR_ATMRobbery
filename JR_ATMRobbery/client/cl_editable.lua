lib.locale()
utils = {}

function utils.JRScriptsNotify(title, msg, type)
    lib.notify({
        title = title,
        description = msg,
        type = type,
        position = 'top-right',
    })
end

RegisterNetEvent('JRScripts:showNotification', utils.JRScriptsNotify)

    RegisterNetEvent('JRScripts:Client:PoliceAlert')
    AddEventHandler('JRScripts:Client:PoliceAlert', function(coords)
    utils.JRScriptsNotify(locale('notification_title'), locale('police_alert'), 'info')

    local coords = GetEntityCoords(PlayerPedId())

    local alphatengo = 250
    local BlipsPolice = AddBlipForRadius(coords.x, coords.y, coords.z, 50.0)

    SetBlipHighDetail(BlipsPolice, true)
    SetBlipColour(BlipsPolice, 1)
    SetBlipAlpha(BlipsPolice, alphatengo)
    SetBlipAsShortRange(BlipsPolice, true)

    while alphatengo ~= 0 do
        Citizen.Wait(500)
        alphatengo = alphatengo - 1
        SetBlipAlpha(BlipsPolice, alphatengo)

        if alphatengo == 0 then
            RemoveBlip(BlipsPolice)
            return
        end
    end
end)


function utils.JRScriptsPoliceAlert(coords)
if Config.Dispatch == "cd_dispatch" then
    local data = exports['cd_dispatch']:GetPlayerInfo()
    local coords = GetEntityCoords(PlayerPedId())
    local street = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(street)

    TriggerServerEvent('cd_dispatch:AddNotification', {
        job_table = Config.PoliceJob or {'police'},
        coords = coords,
        title = '10-31 - ATM Robbery',
        message = 'A ' .. data.sex .. ' is attempting to rob an ATM at ' .. streetName,
        flash = 0,
        unique_id = data.unique_id,
        sound = 1,
        blip = {
            sprite = 500, -- ATM or money-related icon
            scale = 1.2,
            colour = 3,
            flashes = true,
            text = '911 - ATM Robbery',
            time = 5,
            radius = 0,
        }
    })
    elseif Config.Dispatch == "qs-dispatch" then
        local data = exports['qs-dispatch']:GetPlayerInfo()
            TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
                job = Config.PoliceJob,
                callLocation = data.coords,
                callCode = { code = 'Robbery ATM', snippet = '10-50' },
                message = locale('police_alert') .. data.street_1.. ", ".. data.street_2,
                flashes = false,
                blip = {
                    sprite = 161, -- number -> The blip sprite: Find them here (https://docs.fivem.net/docs/game-references/blips/#blips)
                    scale = 1.5, -- number -> The blip scale
                    colour = 3, -- number -> The blip colour: Find them here (https://docs.fivem.net/docs/game-references/blips/#blip-colors)
                    flashes = true,
                    text = locale('blips_alert_police'),
                    time = 5 * 60 * 1000,
                }
            })
    elseif Config.Dispatch == "rcore_dispatch" then
        local data = {
            code = '10-50', -- string -> The alert code, can be for example '10-64' or a little bit longer sentence like '10-64 - Shop robbery'
            default_priority = 'medium', -- 'low' | 'medium' | 'high' -> The alert priority
            coords = coords, -- vector3 -> The coords of the alert
            job = Config.PoliceJob, -- string | table -> The job, for example 'police' or a table {'police', 'ambulance'}
            text = locale('police_alert'), -- string -> The alert text
            type = 'alerts', -- alerts | shop_robbery | car_robbery | bank_robbery -> The alert type to track stats
            blip_time = 5, -- number (optional) -> The time until the blip fades
            blip = { -- Blip table (optional)
                sprite = 161, -- number -> The blip sprite: Find them here (https://docs.fivem.net/docs/game-references/blips/#blips)
                colour = 3, -- number -> The blip colour: Find them here (https://docs.fivem.net/docs/game-references/blips/#blip-colors)
                scale = 1.5, -- number -> The blip scale
                text = locale('blips_alert_police'), -- number (optional) -> The blip text
                flashes = false, -- boolean (optional) -> Make the blip flash
                radius = 0, -- number (optional) -> Create a radius blip instead of a normal one
            }
        }
        TriggerServerEvent('rcore_dispatch:server:sendAlert', data)
    elseif Config.Dispatch == "ps-dispatch" then
        exports['ps-dispatch']:ATMRobbery()
    end
end

function utils.StartAnimation(dict, anim)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 49, 0, false, false, false)
end

function utils.StopAnimation()
    ClearPedTasks(PlayerPedId())
end

local atmProps = {
    "prop_atm_01",
    "prop_atm_02",
    "prop_atm_03",
    "prop_fleeca_atm",
    "v_5_b_atm1",
    "v_5_b_atm2",
    "amb_prop_pine_atm"
}

local function isNearATMClient()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local isNear = false

    for _, atmProp in ipairs(atmProps) do
        local atmObject = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 1.5, GetHashKey(atmProp), false, false, false)
        if atmObject ~= 0 then
            isNear = true
            break
        end
    end

    return isNear
end

function giveReward()
    TriggerServerEvent("JRScriptsATM:GiveReward")
end

function utils.OnSuccess()
    if isNearATMClient() then
        utils.JRScriptsNotify(locale('notification_title'), locale('notification_success_rob'), 'info')
        local progressbar = lib.progressCircle({
            duration = 7000,
            label = locale('progress_money_recovery'),
            position = 'bottom',
            disable = {
                car = true,
                combat = true,
                move = true,
            },
	    anim = {
 	       dict = 'pickup_object',
	       clip = 'pickup_low'
	   }
        })

	giveReward()
    end
end


function utils.OnFailure(reason)
    Wait(4000)
    utils.JRScriptsNotify(locale('notification_title'), locale('notification_not_completed_atm_message'), 'error')
end
