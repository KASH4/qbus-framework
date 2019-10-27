QBCore = nil

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(1)
        if QBCore == nil then
            TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)    
            Citizen.Wait(200)
        end
    end
end)

--- CODE

local currentHouseGarage = nil
local hasGarageKey = nil

RegisterNetEvent('qb-garages:client:setHouseGarage')
AddEventHandler('qb-garages:client:setHouseGarage', function(house, hasKey)
    currentHouseGarage = house
    hasGarageKey = hasKey
end)

local currentGarage = nil

Citizen.CreateThread(function()
    for k, v in pairs(Garages) do
        Garage = AddBlipForCoord(Garages[k].takeVehicle.x, Garages[k].takeVehicle.y, Garages[k].takeVehicle.z)

        SetBlipSprite (Garage, 357)
        SetBlipDisplay(Garage, 4)
        SetBlipScale  (Garage, 0.65)
        SetBlipAsShortRange(Garage, true)
        SetBlipColour(Garage, 3)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Garages[k].label)
        EndTextCommandSetBlipName(Garage)
    end
end)

function MenuGarage()
    ped = GetPlayerPed(-1);
    MenuTitle = "Garage"
    ClearMenu()
    Menu.addButton("Mijn Voertuigen", "VoertuigLijst", nil)
    Menu.addButton("Sluit Menu", "close", nil) 
end

function MenuDepot()
    ped = GetPlayerPed(-1);
    MenuTitle = "Depot"
    ClearMenu()
    Menu.addButton("Depot Voertuigen", "DepotLijst", nil)
    Menu.addButton("Sluit Menu", "close", nil) 
end

function MenuHouseGarage(house)
    ped = GetPlayerPed(-1);
    MenuTitle = HouseGarages[house].label
    ClearMenu()
    Menu.addButton("Mijn Voertuigen", "HouseGarage", house)
    Menu.addButton("Sluit Menu", "close", nil) 
end

function HouseGarage(house)
    QBCore.Functions.TriggerCallback("qb-garage:server:GetHouseVehicles", function(result)
        ped = GetPlayerPed(-1);
        MenuTitle = "Depot Voertuigen :"
        ClearMenu()

        if result == nil then
            QBCore.Functions.Notify("Je hebt geen voertuigen in je garage", "error", 5000)
            closeMenuFull()
        else
            Menu.addButton(HouseGarages[house].label, "yeet", HouseGarages[house].label)

            for k, v in pairs(result) do
                enginePercent = round(v.engine / 10, 0)
                bodyPercent = round(v.body / 10, 0)
                currentFuel = v.fuel
                curGarage = HouseGarages[house].label

                if v.state == 0 then
                    v.state = "Uit"
                elseif v.state == 1 then
                    v.state = "Garage"
                elseif v.state == 2 then
                    v.state = "In Beslag"
                end

                Menu.addButton(GetDisplayNameFromVehicleModel(GetHashKey(v.vehicle)), "TakeOutGarageVehicle", v, v.state, " Motor %:" .. enginePercent, " Body %:" .. bodyPercent, " Fuel %: "..currentFuel)
            end
        end
            
        Menu.addButton("Terug", "MenuHouseGarage", house)
    end, house)
end

function yeet(gar)
    print(gar)
end

function getPlayerVehicles(garage)
    local vehicles = {}

    return vehicles
end

function DepotLijst()
    QBCore.Functions.TriggerCallback("qb-garage:server:GetDepotVehicles", function(result)
        ped = GetPlayerPed(-1);
        MenuTitle = "Depot Voertuigen :"
        ClearMenu()

        if result == nil then
            QBCore.Functions.Notify("Er staan geen voertuigen in het depot", "error", 5000)
            closeMenuFull()
        else
            Menu.addButton(Depots[currentGarage].label, "yeet", Depots[currentGarage].label)

            for k, v in pairs(result) do
                enginePercent = round(v.engine / 10, 0)
                bodyPercent = round(v.body / 10, 0)
                currentFuel = v.fuel
                curGarage = Garages[v.garage].label


                if v.state == 0 then
                    v.state = "In"
                end

                Menu.addButton(GetDisplayNameFromVehicleModel(GetHashKey(v.vehicle)), "TakeOutDepotVehicle", v, v.state, " Motor %:" .. enginePercent, " Body %:" .. bodyPercent, " Fuel %: "..currentFuel)
            end
        end
            
        Menu.addButton("Terug", "MenuDepot",nil)
    end)
end

function VoertuigLijst()
    QBCore.Functions.TriggerCallback("qb-garage:server:GetUserVehicles", function(result)
        ped = GetPlayerPed(-1);
        MenuTitle = "My Vehicles :"
        ClearMenu()

        if result == nil then
            QBCore.Functions.Notify("Je hebt geen voertuigen in deze garage", "error", 5000)
            closeMenuFull()
        else
            Menu.addButton(Garages[currentGarage].label, "yeet", Garages[currentGarage].label)

            for k, v in pairs(result) do
                enginePercent = round(v.engine / 10, 0)
                bodyPercent = round(v.body / 10, 0)
                currentFuel = v.fuel
                curGarage = Garages[v.garage].label


                if v.state == 0 then
                    v.state = "Uit"
                elseif v.state == 1 then
                    v.state = "Garage"
                elseif v.state == 2 then
                    v.state = "In Beslag"
                end

                Menu.addButton(GetDisplayNameFromVehicleModel(GetHashKey(v.vehicle)), "TakeOutVehicle", v, v.state, " Motor: " .. enginePercent .. "%", " Body: " .. bodyPercent.. "%", " Fuel: "..currentFuel.. "%")
            end
        end
            
        Menu.addButton("Terug", "MenuGarage",nil)
    end, currentGarage)
end

function TakeOutVehicle(vehicle)
    if vehicle.state == "Garage" then
        QBCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
            SetVehicleNumberPlateText(veh, vehicle.plate)
            SetEntityHeading(veh, Garages[currentGarage].spawnPoint.h)
            print(Garages[currentGarage].spawnPoint.h)
            TaskWarpPedIntoVehicle(GetPlayerPed(-1), veh, -1)
            exports['LegacyFuel']:SetFuel(veh, vehicle.fuel)
            doCarDamage(veh, vehicle)
            TriggerServerEvent('qb-garage:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
            closeMenuFull()
        end, Garages[currentGarage].spawnPoint, true)
    elseif vehicle.state == "Uit" then
        QBCore.Functions.Notify("Staat je voertuig in het depot??", "error", 2500)
    elseif vehicle.state == "In Beslag" then
        QBCore.Functions.Notify("Dit voertuig is in beslag genomen door de Politie", "error", 4000)
    end
end

function TakeOutDepotVehicle(vehicle)
    if vehicle.state == "Garage" then
        QBCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
            SetVehicleNumberPlateText(veh, vehicle.plate)
            SetEntityHeading(veh, Depots[currentGarage].takeVehicle.h)
            print(Depots[currentGarage].takeVehicle.h)
            TaskWarpPedIntoVehicle(GetPlayerPed(-1), veh, -1)
            exports['LegacyFuel']:SetFuel(veh, vehicle.fuel)
            doCarDamage(veh, vehicle)
            TriggerServerEvent('qb-garage:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
            closeMenuFull()
        end, Depots[currentGarage].spawnPoint, true)
    end
end

function TakeOutGarageVehicle(vehicle)
    if vehicle.state == "Garage" then
        QBCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
            SetVehicleNumberPlateText(veh, vehicle.plate)
            SetEntityHeading(veh, HouseGarages[currentHouseGarage].takeVehicle.h)
            TaskWarpPedIntoVehicle(GetPlayerPed(-1), veh, -1)
            exports['LegacyFuel']:SetFuel(veh, vehicle.fuel)
            doCarDamage(veh, vehicle)
            TriggerServerEvent('qb-garage:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
            closeMenuFull()
        end, HouseGarages[currentHouseGarage].takeVehicle, true)
    end
end

function doCarDamage(currentVehicle, veh)
	smash = false
	damageOutside = false
	damageOutside2 = false 
	local engine = veh.engine + 0.0
	local body = veh.body + 0.0
	if engine < 200.0 then
		engine = 200.0
    end
    
    if engine  > 1000.0 then
        engine = 950.0
    end

	if body < 150.0 then
		body = 150.0
	end
	if body < 950.0 then
		smash = true
	end

	if body < 920.0 then
		damageOutside = true
	end

	if body < 920.0 then
		damageOutside2 = true
	end

    Citizen.Wait(100)
    SetVehicleEngineHealth(currentVehicle, engine)
	if smash then
		SmashVehicleWindow(currentVehicle, 0)
		SmashVehicleWindow(currentVehicle, 1)
		SmashVehicleWindow(currentVehicle, 2)
		SmashVehicleWindow(currentVehicle, 3)
		SmashVehicleWindow(currentVehicle, 4)
	end
	if damageOutside then
		SetVehicleDoorBroken(currentVehicle, 1, true)
		SetVehicleDoorBroken(currentVehicle, 6, true)
		SetVehicleDoorBroken(currentVehicle, 4, true)
	end
	if damageOutside2 then
		SetVehicleTyreBurst(currentVehicle, 1, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 2, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 3, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 4, false, 990.0)
	end
	if body < 1000 then
		SetVehicleBodyHealth(currentVehicle, 985.1)
	end
end

function close()
    Menu.hidden = true
end

function closeMenuFull()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

function ClearMenu()
	--Menu = {}
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.selection = 0
end

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped)

        for k, v in pairs(Garages) do
            local takeDist = GetDistanceBetweenCoords(pos, Garages[k].takeVehicle.x, Garages[k].takeVehicle.y, Garages[k].takeVehicle.z)
            if takeDist <= 15 then
                DrawMarker(2, Garages[k].takeVehicle.x, Garages[k].takeVehicle.y, Garages[k].takeVehicle.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                if takeDist <= 1.5 then
                    if not IsPedInAnyVehicle(ped) then
                        QBCore.Functions.DrawText3D(Garages[k].takeVehicle.x, Garages[k].takeVehicle.y, Garages[k].takeVehicle.z + 0.5, '~g~E~w~ - Garage')
                        if IsControlJustPressed(1, 177) and not Menu.hidden then
                            close()
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                        end
                        if IsControlJustPressed(0, 38) then
                            MenuGarage()
                            Menu.hidden = not Menu.hidden
                            currentGarage = k
                        end
                    else
                        QBCore.Functions.DrawText3D(Garages[k].takeVehicle.x, Garages[k].takeVehicle.y, Garages[k].takeVehicle.z, Garages[k].label)
                    end
                end

                Menu.renderGUI()

                if takeDist >= 4 and not Menu.hidden then
                    closeMenuFull()
                end
            end

            local putDist = GetDistanceBetweenCoords(pos, Garages[k].putVehicle.x, Garages[k].putVehicle.y, Garages[k].putVehicle.z)

            if putDist <= 15 and IsPedInAnyVehicle(ped) then
                DrawMarker(2, Garages[k].putVehicle.x, Garages[k].putVehicle.y, Garages[k].putVehicle.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 255, false, false, false, true, false, false, false)
                if putDist <= 1.5 then
                    QBCore.Functions.DrawText3D(Garages[k].putVehicle.x, Garages[k].putVehicle.y, Garages[k].putVehicle.z + 0.5, '~g~E~w~ - Parkeer Voertuig')
                    if IsControlJustPressed(0, 38) then
                        local curVeh = GetVehiclePedIsIn(ped)
                        local plate = GetVehicleNumberPlateText(curVeh)
                        QBCore.Functions.TriggerCallback('qb-garage:server:checkVehicleOwner', function(owned)
                            if owned then
                                local bodyDamage = round(GetVehicleBodyHealth(curVeh), 1)
                                local engineDamage = round(GetVehicleEngineHealth(curVeh), 1)
                                local totalFuel = exports['LegacyFuel']:GetFuel(curVeh)
        
                                TriggerServerEvent('qb-garage:server:updateVehicleStatus', totalFuel, engineDamage, bodyDamage, plate, k)
                                TriggerServerEvent('qb-garage:server:updateVehicleState', 1, plate, k)
                                QBCore.Functions.DeleteVehicle(curVeh)
                            else
                                QBCore.Functions.Notify("Niemand is in bezit van dit voertuig...", "error", 3500)
                            end
                        end, plate)
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    while true do
        local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped)

        if currentHouseGarage ~= nil then
            if hasGarageKey then
                for k, v in pairs(HouseGarages) do
                    local takeDist = GetDistanceBetweenCoords(pos, HouseGarages[currentHouseGarage].takeVehicle.x, HouseGarages[currentHouseGarage].takeVehicle.y, HouseGarages[currentHouseGarage].takeVehicle.z)
                    if takeDist <= 15 then
                        DrawMarker(2, HouseGarages[currentHouseGarage].takeVehicle.x, HouseGarages[currentHouseGarage].takeVehicle.y, HouseGarages[currentHouseGarage].takeVehicle.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                        if takeDist <= 1.5 then
                            if not IsPedInAnyVehicle(ped) then
                                QBCore.Functions.DrawText3D(HouseGarages[currentHouseGarage].takeVehicle.x, HouseGarages[currentHouseGarage].takeVehicle.y, HouseGarages[currentHouseGarage].takeVehicle.z + 0.5, '~g~E~w~ - Garage')
                                if IsControlJustPressed(1, 177) and not Menu.hidden then
                                    close()
                                    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                                end
                                if IsControlJustPressed(0, 38) then
                                    MenuHouseGarage(currentHouseGarage)
                                    Menu.hidden = not Menu.hidden
                                end
                            elseif IsPedInAnyVehicle(ped) then
                                QBCore.Functions.DrawText3D(HouseGarages[currentHouseGarage].takeVehicle.x, HouseGarages[currentHouseGarage].takeVehicle.y, HouseGarages[currentHouseGarage].takeVehicle.z + 0.5, '~g~E~w~ - Om te parkeren')
                                if IsControlJustPressed(0, 38) then
                                    local curVeh = GetVehiclePedIsIn(ped)
                                    local plate = GetVehicleNumberPlateText(curVeh)
                                    QBCore.Functions.TriggerCallback('qb-garage:server:checkVehicleOwner', function(owned)
                                        if owned then
                                            local bodyDamage = round(GetVehicleBodyHealth(curVeh), 1)
                                            local engineDamage = round(GetVehicleEngineHealth(curVeh), 1)
                                            local totalFuel = exports['LegacyFuel']:GetFuel(curVeh)
                    
                                            TriggerServerEvent('qb-garage:server:updateVehicleStatus', totalFuel, engineDamage, bodyDamage, plate, k)
                                            TriggerServerEvent('qb-garage:server:updateVehicleState', 1, plate, currentHouseGarage)
                                            QBCore.Functions.DeleteVehicle(curVeh)
                                        else
                                            QBCore.Functions.Notify("Niemand is in bezit van dit voertuig...", "error", 3500)
                                        end
                                    end, plate)
                                end
                            end
                        end

                        Menu.renderGUI()

                        if takeDist >= 4 and not Menu.hidden then
                            closeMenuFull()
                        end
                    end
                end
            end
        end

        Citizen.Wait(2)
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped)

        for k, v in pairs(Depots) do
            local takeDist = GetDistanceBetweenCoords(pos, Depots[k].takeVehicle.x, Depots[k].takeVehicle.y, Depots[k].takeVehicle.z)
            if takeDist <= 15 then
                DrawMarker(2, Depots[k].takeVehicle.x, Depots[k].takeVehicle.y, Depots[k].takeVehicle.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                if takeDist <= 1.5 then
                    if not IsPedInAnyVehicle(ped) then
                        QBCore.Functions.DrawText3D(Depots[k].takeVehicle.x, Depots[k].takeVehicle.y, Depots[k].takeVehicle.z + 0.5, '~g~E~w~ - Garage')
                        if IsControlJustPressed(1, 177) and not Menu.hidden then
                            close()
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                        end
                        if IsControlJustPressed(0, 38) then
                            MenuDepot()
                            Menu.hidden = not Menu.hidden
                            currentGarage = k
                        end
                    end
                end

                Menu.renderGUI()

                if takeDist >= 4 and not Menu.hidden then
                    closeMenuFull()
                end
            end
        end
        Citizen.Wait(2)
    end
end)

function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end