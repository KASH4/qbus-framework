cornerselling = false
hasTarget = false
busySelling = false

startLocation = nil

currentPed = nil

lastPed = {}

availableDrugs = {}

local policeMessage = {
    "Verdachte situtie op ",
    "Mogelijk cornerselling op ",
}

RegisterNetEvent('qb-drugs:client:cornerselling')
AddEventHandler('qb-drugs:client:cornerselling', function(data)
    QBCore.Functions.TriggerCallback('qb-drugs:server:cornerselling:getAvailableDrugs', function(result)
        if result ~= nil then
            availableDrugs = result

            if not cornerselling then
                cornerselling = true
                QBCore.Functions.Notify('Standje cornerselling ingeschakeld.. yeet')
                startLocation = GetEntityCoords(GetPlayerPed(-1))
                -- TaskStartScenarioInPlace(GetPlayerPed(-1), "CODE_HUMAN_CROSS_ROAD_WAIT", 0, false)
            else
                cornerselling = false
                QBCore.Functions.Notify('Standje cornerselling uitgeschakeld.. yeet')
                -- ClearPedTasks(GetPlayerPed(-1))
            end
        else
            QBCore.Functions.Notify('Je hebt geen drugs op je..', 'error')
        end
    end)
end)

function toFarAway()
    QBCore.Functions.Notify('Je bent teveel aan het lopen.. begin maar weer opnieuw!', 'error')
    cornerselling = false
    hasTarget = false
    busySelling = false
    startLocation = nil
    currentPed = nil
    availableDrugs = {}
    Citizen.Wait(5000)
end

function callPolice()
    local msg = math.random(1, #policeMessage)
    local pCoords = GetEntityCoords(GetPlayerPed(-1))
    local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, pCoords.x, pCoords.y, pCoords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)
    local streetLabel = street1
    if street2 ~= nil then streetLabel = street1..' '..street2 end

    TriggerServerEvent('police:server:PoliceAlertMessage', "Verdachte situtie op "..streetLabel)
    hasTarget = false
    Citizen.Wait(5000)
end

Citizen.CreateThread(function()
    while true do

        if cornerselling then
            if not hasTarget then
                local PlayerPeds = {}
                if next(PlayerPeds) == nil then
                    for _, player in ipairs(GetActivePlayers()) do
                        local ped = GetPlayerPed(player)
                        table.insert(PlayerPeds, ped)
                    end
                end
                local player = GetPlayerPed(-1)
                local coords = GetEntityCoords(player)
                local closestPed, closestDistance = QBCore.Functions.GetClosestPed(coords, PlayerPeds)

                if closestDistance < 15.0 and closestPed ~= 0 then
                    SellToPed(closestPed)
                end
            end

            local startDist = GetDistanceBetweenCoords(startLocation, GetEntityCoords(GetPlayerPed(-1)))

            if startDist > 10 then
                toFarAway()
            end
        end

        if not cornerselling then
            Citizen.Wait(1000)
        end

        Citizen.Wait(3)
    end
end)

RegisterNetEvent('qb-drugs:client:refreshAvailableDrugs')
AddEventHandler('qb-drugs:client:refreshAvailableDrugs', function(items)
    availableDrugs = items
end)

function SellToPed(ped)
    hasTarget = true
    for i = 1, #lastPed, 1 do
        if lastPed[i] == ped then
            hasTarget = false
            return
        end
    end

    local succesChance = math.random(1, 20)

    local getRobbed = math.random(1, 20)

    print(succesChance)

    if succesChance <= 7 then
        hasTarget = false
        return
    elseif succesChance >= 17 then
        callPolice()
        return
    end

    local drugType = math.random(1, #availableDrugs)
    local bagAmount = math.random(1, availableDrugs[drugType].amount)

    if bagAmount > 7 then
        bagAmount = math.random(1, 7)
    end

    local randomPrice = math.random(100, 200) * bagAmount

    currentOfferDrug = availableDrugs[drugType]

    SetEntityAsNoLongerNeeded(ped)
    ClearPedTasks(ped)

    local coords = GetEntityCoords(GetPlayerPed(-1), true)
    local pedCoords = GetEntityCoords(ped)
    local pedDist = GetDistanceBetweenCoords(coords, pedCoords)

    if getRobbed >= 17 then
        TaskGoStraightToCoord(ped, coords, 15.0, -1, 0.0, 0.0)
    else
        TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
    end

    while pedDist > 1.5 do
        coords = GetEntityCoords(GetPlayerPed(-1), true)
        pedCoords = GetEntityCoords(ped)    
        if getRobbed >= 17 then
            TaskGoStraightToCoord(ped, coords, 15.0, -1, 0.0, 0.0)
        else
            TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
        end
        TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
        pedDist = GetDistanceBetweenCoords(coords, pedCoords)

        Citizen.Wait(100)
    end

    TaskLookAtEntity(ped, GetPlayerPed(-1), 5500.0, 2048, 3)
    TaskTurnPedToFaceEntity(ped, GetPlayerPed(-1), 5500)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT_UPRIGHT", 0, false)
    currentPed = ped

    if hasTarget then
        while pedDist < 1.5 do
            coords = GetEntityCoords(GetPlayerPed(-1), true)
            pedCoords = GetEntityCoords(ped)
            pedDist = GetDistanceBetweenCoords(coords, pedCoords)

            if getRobbed >= 17 then
                TriggerServerEvent('qb-drugs:server:robCornerDrugs', availableDrugs[drugType].item, bagAmount)
                QBCore.Functions.Notify('Je bent beroofd van '..bagAmount..' zakje(\'s) '..availableDrugs[drugType].label, 'error')

                hasTarget = false

                local rand = (math.random(6,9) / 100) + 0.3
                local rand2 = (math.random(6,9) / 100) + 0.3
                if math.random(10) > 5 then
                    rand = 0.0 - rand
                end
            
                if math.random(10) > 5 then
                    rand2 = 0.0 - rand2
                end
            
                local moveto = GetEntityCoords(GetPlayerPed(-1))
                local movetoCoords = {x = moveto.x + math.random(100, 500), y = moveto.y + math.random(100, 500), z = moveto.z, }
                ClearPedTasksImmediately(ped)
                TaskGoStraightToCoord(ped, movetoCoords.x, movetoCoords.y, movetoCoords.z, 15.0, -1, 0.0, 0.0)

                table.insert(lastPed, ped)
                break
            else
                if pedDist < 1.5 then
                    DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z, '[E] '..bagAmount..'x '..currentOfferDrug.label..' voor €'..randomPrice..'? / [G] Aanbod afwijzen')
                    if IsControlJustPressed(0, Keys["E"]) then
                        QBCore.Functions.Notify('Aanbod geaccepteerd!', 'success')
                        TriggerServerEvent('qb-drugs:server:sellCornerDrugs', availableDrugs[drugType].item, bagAmount, randomPrice)
                        hasTarget = false

                        loadAnimDict("gestures@f@standing@casual")
                        TaskPlayAnim(GetPlayerPed(-1), "gestures@f@standing@casual", "gesture_point", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
                        Citizen.Wait(650)
                        ClearPedTasks(GetPlayerPed(-1))

                        SetPedKeepTask(ped, false)
                        SetEntityAsNoLongerNeeded(ped)
                        ClearPedTasksImmediately(ped)
                        table.insert(lastPed, ped)
                        break
                    end

                    if IsControlJustPressed(0, Keys["G"]) then
                        QBCore.Functions.Notify('Aanbod geweigerd!', 'error')
                        hasTarget = false

                        SetPedKeepTask(ped, false)
                        SetEntityAsNoLongerNeeded(ped)
                        ClearPedTasksImmediately(ped)
                        table.insert(lastPed, ped)
                        break
                    end
                end
            end
            
            Citizen.Wait(3)
        end
        
        Citizen.Wait(math.random(4000, 7000))
    end
end

function loadAnimDict(dict)
    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
end

function runAnimation(target)
    RequestAnimDict("mp_character_creation@lineup@male_a")
    while not HasAnimDictLoaded("mp_character_creation@lineup@male_a") do
    Citizen.Wait(0)
    end
    if not IsEntityPlayingAnim(target, "mp_character_creation@lineup@male_a", "loop_raised", 3) then
        TaskPlayAnim(target, "mp_character_creation@lineup@male_a", "loop_raised", 8.0, -8, -1, 49, 0, 0, 0, 0)
    end
end