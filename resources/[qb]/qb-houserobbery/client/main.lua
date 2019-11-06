QBCore = nil

Citizen.CreateThread(function()
	while QBCore == nil do
		TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
		Citizen.Wait(0)
	end
end)

-- Code

local inside = false
local currentHouse = nil
local closestHouse

local inRange

local lockpicking = false

local houseObj = {}
local POIOffsets = nil

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

Citizen.CreateThread(function()
    while true do
        inRange = false
        local PlayerPed = GetPlayerPed(-1)
        local PlayerPos = GetEntityCoords(PlayerPed)
        closestHouse = nil

        if not inside then
            for k, v in pairs(Config.Houses) do
                local dist = GetDistanceBetweenCoords(PlayerPos, Config.Houses[k]["coords"]["x"], Config.Houses[k]["coords"]["y"], Config.Houses[k]["coords"]["z"], true)
                if dist <= 5 then
                    inRange = true
                    closestHouse = k
                    if dist <= 1.5 then
                        if Config.Houses[k]["opened"] then
                            DrawText3Ds(Config.Houses[k]["coords"]["x"], Config.Houses[k]["coords"]["y"], Config.Houses[k]["coords"]["z"], '~g~E~w~ - Om naar binnen te gaan')
                            if IsControlJustPressed(0, Keys["E"]) then
                                enterRobberyHouse(k)
                            end
                        end
                    end
                end
            end
        end

        if inside then
            Citizen.Wait(1000)
        end

        if not inRange then
            Citizen.Wait(5000)
        end

        Citizen.Wait(5)
    end
end)

Citizen.CreateThread(function()
    while true do

        local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped)

        if inside then
            if IsControlJustPressed(0, Keys["H"]) then
                print(json.encode({x = Config.Houses[currentHouse]["coords"]["x"] - pos.x, y = Config.Houses[currentHouse]["coords"]["y"] - pos.y, z = Config.Houses[currentHouse]["coords"]["z"] - pos.z}))
            end

            if(GetDistanceBetweenCoords(pos, Config.Houses[currentHouse]["coords"]["x"] + POIOffsets.exit.x, Config.Houses[currentHouse]["coords"]["y"] + POIOffsets.exit.y, Config.Houses[currentHouse]["coords"]["z"] - 35 + POIOffsets.exit.z, true) < 1.5)then
                DrawText3Ds(Config.Houses[currentHouse]["coords"]["x"] + POIOffsets.exit.x, Config.Houses[currentHouse]["coords"]["y"] + POIOffsets.exit.y, Config.Houses[currentHouse]["coords"]["z"] - 35 + POIOffsets.exit.z, '~g~E~w~ - Om huis te verlaten')
                if IsControlJustPressed(0, Keys["E"]) then
                    leaveRobberyHouse(currentHouse)
                end
            end

            for k, v in pairs(Config.Houses[currentHouse]["furniture"]) do
                if (GetDistanceBetweenCoords(pos, Config.Houses[currentHouse]["coords"]["x"] + Config.Houses[currentHouse]["furniture"][k]["coords"]["x"], Config.Houses[currentHouse]["coords"]["y"] + Config.Houses[currentHouse]["furniture"][k]["coords"]["y"], Config.Houses[currentHouse]["coords"]["z"] + Config.Houses[currentHouse]["furniture"][k]["coords"]["z"] - 35, true) < 1.5) then
                    if not Config.Houses[currentHouse]["furniture"][k]["searched"] then
                        DrawText3Ds(Config.Houses[currentHouse]["coords"]["x"] + Config.Houses[currentHouse]["furniture"][k]["coords"]["x"], Config.Houses[currentHouse]["coords"]["y"] + Config.Houses[currentHouse]["furniture"][k]["coords"]["y"], Config.Houses[currentHouse]["coords"]["z"] + Config.Houses[currentHouse]["furniture"][k]["coords"]["z"] - 35, '~g~E~w~ - '..Config.Houses[currentHouse]["furniture"][k]["text"])
                        if IsControlJustPressed(0, Keys["E"]) then
                            searchCabin(k)
                        end
                    else
                        DrawText3Ds(Config.Houses[currentHouse]["coords"]["x"] + Config.Houses[currentHouse]["furniture"][k]["coords"]["x"], Config.Houses[currentHouse]["coords"]["y"] + Config.Houses[currentHouse]["furniture"][k]["coords"]["y"], Config.Houses[currentHouse]["coords"]["z"] + Config.Houses[currentHouse]["furniture"][k]["coords"]["z"] - 35, 'Kastje is leeg..')
                    end
                end
            end
        end

        if not inside then 
            Citizen.Wait(5000)
        end

        Citizen.Wait(3)
    end
end)

function enterRobberyHouse(house)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
    openHouseAnim()
    Citizen.Wait(250)
    local coords = { x = Config.Houses[house]["coords"]["x"], y = Config.Houses[house]["coords"]["y"], z= Config.Houses[house]["coords"]["z"] - 35}
    if Config.Houses[house]["tier"] == 1 then
        data = exports['qb-interior']:CreateTier1HouseFurnished(coords)
    end
    Citizen.Wait(100)
    houseObj = data[1]
    POIOffsets = data[2]
    inside = true
    currentHouse = house
    Citizen.Wait(500)
    SetRainFxIntensity(0.0)
    TriggerEvent('qb-weathersync:client:DisableSync')
    Citizen.Wait(100)
    SetWeatherTypePersist('EXTRASUNNY')
    SetWeatherTypeNow('EXTRASUNNY')
    SetWeatherTypeNowPersist('EXTRASUNNY')
    NetworkOverrideClockTime(23, 0, 0)
end

function leaveRobberyHouse(house)
    local ped = GetPlayerPed(-1)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
    openHouseAnim()
    Citizen.Wait(250)
    DoScreenFadeOut(250)
    Citizen.Wait(500)
    exports['qb-interior']:DespawnInterior(houseObj, function()
        TriggerEvent('qb-weathersync:client:EnableSync')
        Citizen.Wait(250)
        DoScreenFadeIn(250)
        SetEntityCoords(ped, Config.Houses[house]["coords"]["x"], Config.Houses[house]["coords"]["y"], Config.Houses[house]["coords"]["z"] + 0.5)
        SetEntityHeading(ped, Config.Houses[house]["coords"]["h"])
        inside = false
        currentHouse = nil
    end)
end

RegisterNetEvent('qb-houserobbery:client:enterHouse')
AddEventHandler('qb-houserobbery:client:enterHouse', function(house)
    enterRobberyHouse(house)
end)

function openHouseAnim()
    loadAnimDict("anim@heists@keycard@") 
    TaskPlayAnim( GetPlayerPed(-1), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Citizen.Wait(400)
    ClearPedTasks(GetPlayerPed(-1))
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

RegisterNetEvent('lockpicks:UseLockpick')
AddEventHandler('lockpicks:UseLockpick', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
        if closestHouse ~= nil then
            if result then
                if not Config.Houses[closestHouse]["opened"] then
                    TriggerEvent('qb-lockpick:client:openLockpick', lockpickFinish)
                else
                    QBCore.Functions.Notify('De deur is al open..', 'error', 3500)
                end
            else
                QBCore.Functions.Notify('Het lijkt erop dat je iets mist...', 'error', 3500)
            end
        end
    end, "screwdriverset")
end)

function lockpickFinish(success)
    if success then
        TriggerServerEvent('qb-houserobbery:server:enterHouse', closestHouse)
        QBCore.Functions.Notify('Het is gelukt!', 'success', 2500)
    else
        QBCore.Functions.Notify('Het is niet gelukt..', 'error', 2500)
    end
end


RegisterNetEvent('qb-houserobbery:client:setHouseState')
AddEventHandler('qb-houserobbery:client:setHouseState', function(house, state)
    Config.Houses[house]["opened"] = state
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if houseObj ~= nil then
            exports['qb-interior']:DespawnInterior(houseObj, function()
                TriggerEvent('qb-weathersync:client:EnableSync')
                DoScreenFadeIn(500)
                while not IsScreenFadedOut() do
                    Citizen.Wait(10)
                end
                SetEntityCoords(GetPlayerPed(-1), Config.Houses[currentHouse]["coords"]["x"], Config.Houses[currentHouse]["coords"]["x"], Config.Houses[currentHouse]["coords"]["x"] + 0.5)
                Citizen.Wait(1000)
                inside = false
                DoScreenFadeIn(1000)
                currentHouse = nil
            end)
        end
    end
end)

function searchCabin(cabin)
    QBCore.Functions.Progressbar("search_cabin", "Kastje aan het doorzoeken..", math.random(4000, 8000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "veh@break_in@0h@p_m_one@",
        anim = "low_force_entry_ds",
        flags = 16,
    }, {}, {}, function() -- Done
        ClearPedTasks(GetPlayerPed(-1))
        TriggerServerEvent('qb-houserobbery:server:searchCabin', cabin, currentHouse)
        Config.Houses[currentHouse]["furniture"][cabin]["searched"] = true
    end, function() -- Cancel
        ClearPedTasks(GetPlayerPed(-1))
        QBCore.Functions.Notify("Proces geannuleerd..", "error")
    end)
end

RegisterNetEvent('qb-houserobbery:client:setCabinState')
AddEventHandler('qb-houserobbery:client:setCabinState', function(house, cabin, state)
    Config.Houses[house]["furniture"][cabin]["searched"] = state
end)