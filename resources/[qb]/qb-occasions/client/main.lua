Keys = {
    ['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
    ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DELETE'] = 178,
    ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

QBCore = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if QBCore == nil then
            TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
            Citizen.Wait(200)
        end
    end
end)

-- Code

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local occasionVehicles = {}
local inRange
local vehiclesSpawned = false

Citizen.CreateThread(function()
    while true do
        inRange = false
        local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped)
        if QBCore ~= nil then
            for _,slot in pairs(Config.OccasionSlots) do
                local dist = GetDistanceBetweenCoords(pos, slot["x"], slot["y"], slot["z"])

                if dist <= 40 then
                    inRange = true
                    if not vehiclesSpawned then
                        vehiclesSpawned = true

                        QBCore.Functions.TriggerCallback('qb-occasions:server:getVehicles', function(vehicles)
                            occasionVehicles = vehicles
                            despawnOccasionsVehicles()
                            spawnOccasionsVehicles(vehicles)
                        end)
                    end
                end
            end

            if inRange then
                for i = 1, #Config.OccasionSlots, 1 do
                    local vehPos = GetEntityCoords(Config.OccasionSlots[i]["occasionId"])
                    local dstCheck = GetDistanceBetweenCoords(pos, vehPos)

                    if dstCheck <= 2 then
                        if not IsPedInAnyVehicle(ped) then
                            DrawText3Ds(vehPos.x, vehPos.y, vehPos.z + 1.45, '~g~E~w~ Om voertuig te bekijken')
                            DrawText3Ds(vehPos.x, vehPos.y, vehPos.z + 1.25, QBCore.Shared.Vehicles[Config.OccasionSlots[i]["model"]]["name"]..', Prijs: €'..Config.OccasionSlots[i]["price"]..',-')
                            if IsControlJustPressed(0, Keys["E"]) then
                                currentVehicle = i
                                
                                QBCore.Functions.TriggerCallback('qb-occasions:server:getSellerInformation', function(info)
                                    info.charinfo = json.decode(info.charinfo)
                                    openBuyContract(info, Config.OccasionSlots[currentVehicle])
                                end, Config.OccasionSlots[currentVehicle]["owner"])
                            end
                        end
                    end
                end

                local sellDist = GetDistanceBetweenCoords(pos, Config.SellVehicle["x"], Config.SellVehicle["y"], Config.SellVehicle["z"])

                if sellDist <= 1.5 and IsPedInAnyVehicle(ped) then
                    DrawText3Ds(Config.SellVehicle["x"], Config.SellVehicle["y"], Config.SellVehicle["z"], '~g~E~w~ - Voertuig te koop zetten')
                    if IsControlJustPressed(0, Keys["E"]) then
                        QBCore.Functions.TriggerCallback('qb-garage:server:checkVehicleOwner', function(owned)
                            -- if owned then
                                openSellContract(true)
                            -- else
                                -- QBCore.Functions.Notify('Dit is niet jou voertuig?', 'error', 3500)
                            -- end
                        end, GetVehicleNumberPlateText(GetVehiclePedIsUsing(GetPlayerPed(-1))))
                    end
                end
            end

            if not inRange then
                if vehiclesSpawned then
                    vehiclesSpawned = false
                    despawnOccasionsVehicles()
                end
                Citizen.Wait(1000)
            end
        end

        Citizen.Wait(3)
    end
end)

function spawnOccasionsVehicles(vehicles)
    local oSlot = Config.OccasionSlots

    if vehicles ~= nil then
        for i = 1, #vehicles, 1 do
            local model = GetHashKey(vehicles[i].model)
            RequestModel(model)
            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end

            oSlot[i]["occasionId"] = CreateVehicle(model, oSlot[i]["x"], oSlot[i]["y"], oSlot[i]["z"], false, false)
            QBCore.Functions.SetVehicleProperties(oSlot[i]["occasionId"], json.decode(vehicles[i].mods))

            oSlot[i]["price"] = vehicles[i].price
            oSlot[i]["owner"] = vehicles[i].seller
            oSlot[i]["model"] = vehicles[i].model
            oSlot[i]["plate"] = vehicles[i].plate
            oSlot[i]["oid"]   = vehicles[i].occasionId
            oSlot[i]["desc"]  = vehicles[i].description
            oSlot[i]["mods"]  = vehicles[i].mods

            SetModelAsNoLongerNeeded(model)
            SetVehicleOnGroundProperly(oSlot[i]["occasionId"])
            SetEntityInvincible(oSlot[i]["occasionId"],true)
            SetEntityHeading(oSlot[i]["occasionId"], oSlot[i]["h"])
            SetVehicleDoorsLocked(oSlot[i]["occasionId"], 3)

            SetVehicleNumberPlateText(oSlot[i]["occasionId"], vehicles[i].occasionId)
            FreezeEntityPosition(oSlot[i]["occasionId"],true)
        end
    end
end

function despawnOccasionsVehicles()
    for _, slot in pairs(Config.OccasionSlots) do
        local oldVehicle = GetClosestVehicle(slot["x"], slot["y"], slot["z"], 1.3, 0, 70)
        if oldVehicle ~= 0 then
            QBCore.Functions.DeleteVehicle(oldVehicle)
        end
    end
end

function openSellContract(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "sellVehicle",
        pData = QBCore.Functions.GetPlayerData(),
        plate = GetVehicleNumberPlateText(GetVehiclePedIsUsing(GetPlayerPed(-1)))
    })
end

function openBuyContract(sellerData, vehicleData)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "buyVehicle",
        sellerData = sellerData,
        vehicleData = vehicleData
    })
end

RegisterNUICallback('close', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('error', function(data)
    QBCore.Functions.Notify(data.message, 'error')
end)

RegisterNUICallback('buyVehicle', function()
    local vehData = Config.OccasionSlots[currentVehicle]
    DoScreenFadeOut(250)
    Citizen.Wait(500)
    TriggerServerEvent('qb-occasions:server:buyVehicle', vehData)
    QBCore.Functions.SpawnVehicle(vehData["model"], function(veh)

        SetVehicleNumberPlateText(veh, vehData["plate"])
        SetEntityHeading(veh, Config.BuyVehicle.h)
        TaskWarpPedIntoVehicle(GetPlayerPed(-1), veh, -1)
        exports['LegacyFuel']:SetFuel(veh, 100)
        QBCore.Functions.Notify("Voertuig gekocht", "success", 2500)
        TriggerEvent("vehiclekeys:client:SetOwner", vehData["plate"])
        SetVehicleEngineOn(veh, true, true)
        QBCore.Functions.SetVehicleProperties(veh, vehData["mods"])
    end, Config.BuyVehicle, true)
    Citizen.Wait(500)
    DoScreenFadeIn(250)
    currentVehicle = nil
end)

RegisterNUICallback('sellVehicle', function(data)
    local vehicleData = {}
    local PlayerData = QBCore.Functions.GetPlayerData()
    vehicleData.ent = GetVehiclePedIsUsing(GetPlayerPed(-1))
    vehicleData.model = QBCore.Shared.VehicleModels[GetEntityModel(vehicleData.ent)]["model"]
    vehicleData.plate = GetVehicleNumberPlateText(GetVehiclePedIsUsing(GetPlayerPed(-1)))
    vehicleData.mods = QBCore.Functions.GetVehicleProperties(vehicleData.ent)
    vehicleData.desc = data.desc

    TriggerServerEvent('qb-occasions:server:sellVehicle', data.price, vehicleData)
    sellVehicleWait(data.price)
end)

function sellVehicleWait(price)
    DoScreenFadeOut(250)
    Citizen.Wait(250)
    QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(GetPlayerPed(-1)))
    Citizen.Wait(1500)
    DoScreenFadeIn(250)
    QBCore.Functions.Notify('Uw auto staat te koop voor, €'..price..',-', 'success')
    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
end

RegisterNetEvent('qb-occasion:client:refreshVehicles')
AddEventHandler('qb-occasion:client:refreshVehicles', function()
    if inRange then
        QBCore.Functions.TriggerCallback('qb-occasions:server:getVehicles', function(vehicles)
            occasionVehicles = vehicles
            despawnOccasionsVehicles()
            spawnOccasionsVehicles(vehicles)
        end)
    end
end)

Citizen.CreateThread(function()
    OccasionBlip = AddBlipForCoord(Config.SellVehicle["x"], Config.SellVehicle["y"], Config.SellVehicle["z"])

    SetBlipSprite (OccasionBlip, 326)
    SetBlipDisplay(OccasionBlip, 4)
    SetBlipScale  (OccasionBlip, 0.75)
    SetBlipAsShortRange(OccasionBlip, true)
    SetBlipColour(OccasionBlip, 3)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Mosley's Occasions")
    EndTextCommandSetBlipName(OccasionBlip)
end)