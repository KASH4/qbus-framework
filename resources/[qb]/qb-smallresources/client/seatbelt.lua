local seatbeltOn = false
local SpeedBuffer = {}
local vehVelocity = {x = 0.0, y = 0.0, z = 0.0}
local vehHealth = 0.0
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if IsPedInAnyVehicle(GetPlayerPed(-1)) then
            --
        else
            seatbeltOn = false
        end
        
        if IsControlJustReleased(0, Keys["G"]) then 
            if IsPedInAnyVehicle(GetPlayerPed(-1)) and GetVehicleClass(GetVehiclePedIsIn(GetPlayerPed(-1))) ~= 8 and GetVehicleClass(GetVehiclePedIsIn(GetPlayerPed(-1))) ~= 13 and GetVehicleClass(GetVehiclePedIsIn(GetPlayerPed(-1))) ~= 14 then
                if seatbeltOn then
                    TriggerServerEvent("InteractSound_SV:PlayOnSource", "carunbuckle", 0.25)
                else
                    TriggerServerEvent("InteractSound_SV:PlayOnSource", "carbuckle", 0.25)
                end
                TriggerEvent("seatbelt:client:ToggleSeatbelt")
            end
        end
    end
end)

local handbrake = 0
RegisterNetEvent('resethandbrake')
AddEventHandler('resethandbrake', function()
    while handbrake > 0 do
        handbrake = handbrake - 1
        Citizen.Wait(30)
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    local newvehicleBodyHealth = 0
    local newvehicleEngineHealth = 0
    local currentvehicleEngineHealth = 0
    local currentvehicleBodyHealth = 0
    local frameBodyChange = 0
    local frameEngineChange = 0
    local lastFrameVehiclespeed = 0
    local lastFrameVehiclespeed2 = 0
    local thisFrameVehicleSpeed = 0
    local tick = 0
    local damagedone = false
    local modifierDensity = true
    while true do
        Citizen.Wait(5)
        local playerPed = GetPlayerPed(-1)
        local currentVehicle = GetVehiclePedIsIn(playerPed, false)
        local driverPed = GetPedInVehicleSeat(currentVehicle, -1)
        if currentVehicle ~= nil and currentVehicle ~= false and currentVehicle ~= 0 then
            SetPedHelmet(playerPed, false)
            lastVehicle = GetVehiclePedIsIn(playerPed, false)
            if driverPed == GetPlayerPed(-1) then
                if GetVehicleEngineHealth(currentVehicle) < 0.0 then
                    SetVehicleEngineHealth(currentVehicle,0.0)
                end
                if (GetVehicleHandbrake(currentVehicle) or (GetVehicleSteeringAngle(currentVehicle)) > 25.0 or (GetVehicleSteeringAngle(currentVehicle)) < -25.0) then
                    if handbrake == 0 then
                        handbrake = 100
                        TriggerEvent("resethandbrake")
                    else
                        handbrake = 100
                    end
                end

                thisFrameVehicleSpeed = GetEntitySpeed(currentVehicle) * 3.6
                currentvehicleBodyHealth = GetVehicleBodyHealth(currentVehicle)
                if currentvehicleBodyHealth == 1000 and frameBodyChange ~= 0 then
                    frameBodyChange = 0
                end
                if frameBodyChange ~= 0 then
                    if lastFrameVehiclespeed > 110 and thisFrameVehicleSpeed < (lastFrameVehiclespeed * 0.75) and not damagedone then
                        if frameBodyChange > 18.0 then
                            if not IsThisModelABike(currentVehicle) then 
                                TriggerServerEvent("carhud:ejection:server",GetVehicleNumberPlateText(currentVehicle))
                            end
                            if not seatbeltOn and not IsThisModelABike(currentVehicle) then
                                if math.random(math.ceil(lastFrameVehiclespeed)) > 110 then
                                    EjectFromVehicle()                           
                                end
                            elseif seatbeltOn and not IsThisModelABike(currentVehicle) then
                                if lastFrameVehiclespeed > 150 then
                                    if math.random(math.ceil(lastFrameVehiclespeed)) > 99 then
                                        EjectFromVehicle()                           
                                    end
                                end
                            end
                        else
                            if not IsThisModelABike(currentVehicle) then 
                                TriggerServerEvent("carhud:ejection:server",GetVehicleNumberPlateText(currentVehicle))
                            end     

                            if not seatbeltOn and not IsThisModelABike(currentVehicle) then
                                if math.random(math.ceil(lastFrameVehiclespeed)) > 60 then
                                    EjectFromVehicle()                           
                                end
                            elseif seatbeltOn and not IsThisModelABike(currentVehicle) then
                                if lastFrameVehiclespeed > 120 then
                                    if math.random(math.ceil(lastFrameVehiclespeed)) > 99 then
                                        EjectFromVehicle()                           
                                    end
                                end
                            end
                        end
                        damagedone = true       
                        SetVehicleTyreBurst(currentVehicle, tireToBurst, true, 1000) 
                        SetVehicleEngineHealth(currentVehicle, 0)
                        SetVehicleEngineOn(currentVehicle, false, true, true)
                    end
                    if currentvehicleBodyHealth < 350.0 and not damagedone then
                        damagedone = true
                        SetVehicleBodyHealth(targetVehicle, 945.0)
                        SetVehicleTyreBurst(currentVehicle, tireToBurst, true, 1000) 
                        SetVehicleEngineHealth(currentVehicle, 0)
                        SetVehicleEngineOn(currentVehicle, false, true, true)
                        Citizen.Wait(1000)
                    end
                end
                if lastFrameVehiclespeed < 100 then
                    Wait(100)
                    tick = 0
                end
                frameBodyChange = newvehicleBodyHealth - currentvehicleBodyHealth
                if tick > 0 then 
                    tick = tick - 1
                    if tick == 1 then
                        lastFrameVehiclespeed = GetEntitySpeed(currentVehicle) * 3.6
                    end
                else
                    if damagedone then
                        damagedone = false
                        frameBodyChange = 0
                        lastFrameVehiclespeed = GetEntitySpeed(currentVehicle) * 3.6
                    end
                    lastFrameVehiclespeed2 = GetEntitySpeed(currentVehicle) * 3.6
                    if lastFrameVehiclespeed2 > lastFrameVehiclespeed then
                        lastFrameVehiclespeed = GetEntitySpeed(currentVehicle) * 3.6
                    end
                    if lastFrameVehiclespeed2 < lastFrameVehiclespeed then
                        tick = 25
                    end

                end
                vels = GetEntityVelocity(currentVehicle)
                if tick < 0 then 
                    tick = 0
                end     
                newvehicleBodyHealth = GetVehicleBodyHealth(currentVehicle)
                if not modifierDensity then
                    modifierDensity = true
                end
            else
                vels = GetEntityVelocity(currentVehicle)
                if modifierDensity then
                    modifierDensity = false
                end
                Wait(1000)
            end
            veloc = GetEntityVelocity(currentVehicle)
        else
            if lastVehicle ~= nil then
                SetPedHelmet(playerPed, true)
                Citizen.Wait(200)
                newvehicleBodyHealth = GetVehicleBodyHealth(lastVehicle)
                if not damagedone and newvehicleBodyHealth < currentvehicleBodyHealth then
                    damagedone = true                   
                    SetVehicleTyreBurst(lastVehicle, tireToBurst, true, 1000) 
                    SetVehicleEngineHealth(lastVehicle, 0)
                    SetVehicleEngineOn(lastVehicle, false, true, true)
                    Citizen.Wait(1000)
                end
                lastVehicle = nil
            end
            lastFrameVehiclespeed2 = 0
            lastFrameVehiclespeed = 0
            newvehicleBodyHealth = 0
            currentvehicleBodyHealth = 0
            frameBodyChange = 0
            Citizen.Wait(2000)
        end
    end
end)

function GetFwd(entity)
    local hr = GetEntityHeading(entity) + 90.0
    if hr < 0.0 then hr = 360.0 + hr end
    hr = hr * 0.0174533
    return { x = math.cos(hr) * 5.73, y = math.sin(hr) * 5.73 }
end

function EjectFromVehicle()
    local veh = GetVehiclePedIsIn(GetPlayerPed(-1),false)
    local coords = GetOffsetFromEntityInWorldCoords(veh, 1.0, 0.0, 1.0)
    SetEntityCoords(GetPlayerPed(-1),coords)
    Citizen.Wait(1)
    SetPedToRagdoll(GetPlayerPed(-1), 5511, 5511, 0, 0, 0, 0)
    SetEntityVelocity(GetPlayerPed(-1), veloc.x*4,veloc.y*4,veloc.z*4)
    local ejectspeed = math.ceil(GetEntitySpeed(GetPlayerPed(-1)) * 8)
    SetEntityHealth( GetPlayerPed(-1), (GetEntityHealth(GetPlayerPed(-1)) - ejectspeed) )
end

RegisterNetEvent("seatbelt:client:ToggleSeatbelt")
AddEventHandler("seatbelt:client:ToggleSeatbelt", function()
    seatbeltOn = not seatbeltOn
end)