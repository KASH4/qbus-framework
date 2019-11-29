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

local isLoggedIn = true
local RentedVehiclePlate = nil
local CurrentRentalPoint = nil
local RentedVehicleData = nil

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

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
        local inRange = false
        local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped)
        
        if isLoggedIn then
            for k, v in pairs(Config.RentalPoints) do
                local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.RentalPoints[k]["coords"]["x"], Config.RentalPoints[k]["coords"]["y"], Config.RentalPoints[k]["coords"]["z"])

                if dist < 30 then
                    inRange = true
                    DrawMarker(2, Config.RentalPoints[k]["coords"]["x"], Config.RentalPoints[k]["coords"]["y"], Config.RentalPoints[k]["coords"]["z"], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 155, 22, 22, 155, 0, 0, 0, 1, 0, 0, 0)

                    if dist < 1 then
                        DrawText3Ds(Config.RentalPoints[k]["coords"]["x"], Config.RentalPoints[k]["coords"]["y"], Config.RentalPoints[k]["coords"]["z"] + 0.35, '~g~E~w~ - Om voertuig te huren')
                        if IsControlJustPressed(0, Keys["E"]) then
                            RentalMenu()
                            Menu.hidden = not Menu.hidden
                            CurrentRentalPoint = k
                        end
                        Menu.renderGUI()
                    end

                    if dist > 1.5 then
                        CloseMenu()
                    end
                end
            end
        end

        if not inRange then
            Citizen.Wait(1500)
        end

        Citizen.Wait(3)
    end
end)

Citizen.CreateThread(function()
    for k, v in pairs(Config.RentalPoints) do
        RentalPoints = AddBlipForCoord(v["coords"]["x"], v["coords"]["y"], v["coords"]["z"])

        SetBlipSprite (RentalPoints, 379)
        SetBlipDisplay(RentalPoints, 4)
        SetBlipScale  (RentalPoints, 0.65)
        SetBlipAsShortRange(RentalPoints, true)
        SetBlipColour(RentalPoints, 3)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Verhuurpunt")
        EndTextCommandSetBlipName(RentalPoints)
    end
end)

-- Menu's

RentVehicleMenu = function()
    ClearMenu()
    for k, v in pairs(Config.RentalVehicles) do
        Menu.addButton(Config.RentalVehicles[k]["label"].." - Borg Kosten: €"..Config.RentalVehicles[k]["price"], "RentVehicle", k)
    end
    Menu.addButton("Terug", "RentalMenu", nil) 
end

RentVehicle = function(selectedVehicle)
    local ped = GetPlayerPed(-1)

    if IsPedInAnyVehicle(ped) then
        QBCore.Functions.Notify('Dit kan alleen te voet..', 'error')
        return
    end

    local vehiclePlate = "QBR"..math.random(1, 100)
    TriggerServerEvent('qb-vehiclerental:server:SetVehicleRented', vehiclePlate, true, Config.RentalVehicles[selectedVehicle])

    RentedVehicleData = selectedVehicle
end

RegisterNetEvent('qb-vehiclerental:server:SpawnRentedVehicle')
AddEventHandler('qb-vehiclerental:server:SpawnRentedVehicle', function(vehiclePlate, vehicleData)
    local ped = GetPlayerPed(-1)
    QBCore.Functions.SpawnVehicle(vehicleData["model"], function(veh)
        local spawnCoords = {
            x = Config.RentalPoints[CurrentRentalPoint]["coords"]["x"],
            y = Config.RentalPoints[CurrentRentalPoint]["coords"]["y"],
            z = Config.RentalPoints[CurrentRentalPoint]["coords"]["z"],
        }

        SetVehicleNumberPlateText(veh, vehiclePlate)
        TaskWarpPedIntoVehicle(ped, veh, -1)
        exports['LegacyFuel']:SetFuel(veh, 100)
        SetVehicleEngineOn(veh, true, true)
        RentedVehiclePlate = vehiclePlate

        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
    end, spawnCoords, true)
    RentalMenu()
end)

ReturnVehicle = function()
    ClearMenu()
    if RentedVehiclePlate ~= nil then
        Menu.addButton("Bevestigen", "AcceptReturn", nil)
        Menu.addButton("Terug", "RentalMenu", nil) 
        return
    end
    QBCore.Functions.Notify('Je hebt geen borg open staan..', 'error')
end

AcceptReturn = function()
    local Ped = GetPlayerPed(-1)
    local CurrentVehicle = GetVehiclePedIsIn(Ped)
    local VehiclePlate = GetVehicleNumberPlateText(CurrentVehicle)
    if noSpace(VehiclePlate) ~= noSpace(RentedVehiclePlate) then
        QBCore.Functions.Notify('Dit is geen gehuurd voertuig..', 'error')
    else
        TriggerServerEvent('qb-vehiclerental:server:SetVehicleRented', RentedVehiclePlate, false, Config.RentalVehicles[RentedVehicleData])
        QBCore.Functions.DeleteVehicle(CurrentVehicle)
        RentedVehiclePlate = nil
        RentedVehicleData = nil
    end
    RentalMenu()
end

-- Menu Functions

RentalMenu = function()
    ClearMenu()
    Menu.addButton("Voertuig Huren", "RentVehicleMenu", nil)
    Menu.addButton("Voertuig Inleveren", "ReturnVehicle", nil) 
    Menu.addButton("Sluit Menu", "CloseMenu", nil) 
end

CloseMenu = function()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

ClearMenu = function()
	--Menu = {}
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.selection = 0
end

function noSpace(str)
    local normalisedString = string.gsub(str, "%s+", "")
    return normalisedString
end