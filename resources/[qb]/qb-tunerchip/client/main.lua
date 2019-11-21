Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}

QBCore = nil

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(10)
        if QBCore == nil then
            TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)    
            Citizen.Wait(200)
        end
    end
end)

-- Code

local inTuner = false

function setVehData(veh,data)
    local multp = 0.12
    local dTrain = 0.0
    if tonumber(data.drivetrain) == 2 then dTrain = 0.5 elseif tonumber(data.drivetrain) == 3 then dTrain = 1.0 end
    if not DoesEntityExist(veh) or not data then return nil end
    SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", data.boost * multp)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia", data.acceleration * multp)
    SetVehicleEnginePowerMultiplier(veh, data.gearchange * multp)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", dTrain*1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront", data.breaking * multp)
end

function resetVeh(veh)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", 1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia", 1.0)
    SetVehicleEnginePowerMultiplier(veh, 1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", 0.5)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront", 1.0)
end

RegisterNUICallback('save', function(data)
    local ped = GetPlayerPed(-1)
    local veh = GetVehiclePedIsUsing(ped)
    setVehData(veh, data)
    QBCore.Functions.Notify('Tjoenertjip v1.05: Voertuig aangepast!', 'error')

    TriggerServerEvent('qb-tunerchip:server:TuneStatus', GetVehicleNumberPlateText(veh), true)
end)

RegisterNetEvent('qb-tunerchip:server:TuneStatus')
AddEventHandler('qb-tunerchip:server:TuneStatus', function()
    local ped = GetPlayerPed(-1)
    local closestVehicle = GetClosestVehicle(GetEntityCoords(ped), 5.0, 0, 70)
    local plate = GetVehicleNumberPlateText(closestVehicle)
    local vehModel = GetEntityModel(closestVehicle)

    local displayName = GetLabelText(GetDisplayNameFromVehicleModel(vehModel))

    QBCore.Functions.TriggerCallback('qb-tunerchip:server:GetStatus', function(status)
        if status then
            TriggerEvent("chatMessage", "VOERTUIG STATUS", "warning", displayName..": Chiptuned: Ja")
        else
            TriggerEvent("chatMessage", "VOERTUIG STATUS", "warning", displayName..": Chiptuned: Nee")
        end
    end, plate)
end)

RegisterNUICallback('checkItem', function(data, cb)
    local retval = false
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
        if result then
            retval = true
        end
        cb(retval)
    end, data.software)
end)

RegisterNUICallback('reset', function(data)
    local ped = GetPlayerPed(-1)
    local veh = GetVehiclePedIsUsing(ped)
    resetVeh(veh)
    QBCore.Functions.Notify('Tjoenertjip v1.05: Voertuig is gereset!', 'error')
end)

RegisterNetEvent('qb-tunerchip:client:openChip')
AddEventHandler('qb-tunerchip:client:openChip', function()
    local ped = GetPlayerPed(-1)
    local inVehicle = IsPedInAnyVehicle(ped)

    if inVehicle then
        QBCore.Functions.Progressbar("connect_laptop", "Tunerlaptop wordt aangesloten..", 2000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 16,
        }, {}, {}, function() -- Done
            StopAnimTask(GetPlayerPed(-1), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            openTunerLaptop(true)
        end, function() -- Cancel
            StopAnimTask(GetPlayerPed(-1), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            QBCore.Functions.Notify("Geannuleerd..", "error")
        end)
    else
        QBCore.Functions.Notify("Je zit niet in een voertuig..", "error")
    end
end)

RegisterNUICallback('exit', function()
    openTunerLaptop(false)
    SetNuiFocus(false, false)
    inTuner = false
end)

RegisterNUICallback('saveNeon', function(data)
    local ped = GetPlayerPed(-1)
    local veh = GetVehiclePedIsIn(ped)

    if tonumber(data.neonEnabled) == 1 then
        SetVehicleNeonLightEnabled(veh, 0, true)
		SetVehicleNeonLightEnabled(veh, 1, true)
		SetVehicleNeonLightEnabled(veh, 2, true)
        SetVehicleNeonLightEnabled(veh, 3, true)
        if tonumber(data.r) ~= nil and tonumber(data.g) ~= nil and tonumber(data.b) ~= nil then
            SetVehicleNeonLightsColour(veh, tonumber(data.r), tonumber(data.g), tonumber(data.b))
        else
            SetVehicleNeonLightsColour(veh, 255, 255, 255)
        end
    else
        SetVehicleNeonLightEnabled(veh, 0, false)
		SetVehicleNeonLightEnabled(veh, 1, false)
		SetVehicleNeonLightEnabled(veh, 2, false)
        SetVehicleNeonLightEnabled(veh, 3, false)
    end
end)

RegisterNUICallback('saveHeadlights', function(data)
    local ped = GetPlayerPed(-1)
    local veh = GetVehiclePedIsIn(ped)
    local value = tonumber(data.value)

    ToggleVehicleMod(veh, 22, true)
    SetVehicleHeadlightsColour(veh, value)

    print(value)
end)

function openTunerLaptop(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "ui",
        toggle = bool
    })
    inTuner = bool
end