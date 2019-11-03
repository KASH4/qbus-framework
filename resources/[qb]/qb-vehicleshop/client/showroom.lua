local currentCarKey, currentCarValue = nil
local inMenu = false

local fakecar = {model = '', car = nil}

vehshop = {
	opened = false,
	title = "Vehicle Shop",
	currentmenu = "main",
	lastmenu = nil,
	currentpos = nil,
	selectedbutton = 0,
	marker = { r = 0, g = 155, b = 255, a = 250, type = 1 },
	menu = {
		x = 0.14,
		y = 0.15,
		width = 0.12,
		height = 0.03,
		buttons = 10,
		from = 1,
		to = 10,
		scale = 0.29,
		font = 0,
		["main"] = {
			title = "CATEGORIES",
			name = "main",
			buttons = {
				{name = "Voertuigen", description = ""},
			}
		},
		["vehicles"] = {
			title = "VEHICLES",
			name = "vehicles",
			buttons = {
				{name = "Coupes", description = ''},
				{name = "Sedans", description = ''},
				{name = "Super", description = ''},
				{name = "Sports", description = ''},
				{name = "Motoren", description = ""},
			}
		},
		["coupes"] = {
			title = "coupes",
			name = "coupes",
			buttons = {}
		},
		["sedans"] = {
			title = "sedans",
			name = "sedans",
			buttons = {}
		},
		["super"] = {
			title = "super",
			name = "super",
			buttons = {}
		},
		["sports"] = {
			title = "sports",
			name = "sports",
			buttons = {}
		},		
	}
}

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    for i = 1, #shopVehicles["coupes"], 1 do
        table.insert(vehshop.menu["coupes"].buttons, {
            name = shopVehicles["coupes"][i]["name"],
            costs = shopVehicles["coupes"][i]["price"],
            description = {},
            model = shopVehicles["coupes"][i]["model"]
        })
    end
    for i = 1, #shopVehicles["sedans"], 1 do
        table.insert(vehshop.menu["sedans"].buttons, {
            name = shopVehicles["sedans"][i]["name"],
            costs = shopVehicles["sedans"][i]["price"],
            description = {},
            model = shopVehicles["sedans"][i]["model"]
        })
    end
    for i = 1, #shopVehicles["super"], 1 do
        table.insert(vehshop.menu["super"].buttons, {
            name = shopVehicles["super"][i]["name"],
            costs = shopVehicles["super"][i]["price"],
            description = {},
            model = shopVehicles["super"][i]["model"]
        })
    end
    for i = 1, #shopVehicles["sports"], 1 do
        table.insert(vehshop.menu["sports"].buttons, {
            name = shopVehicles["sports"][i]["name"],
            costs = shopVehicles["sports"][i]["price"],
            description = {},
            model = shopVehicles["sports"][i]["model"]
        })
    end
end)

function drawMenuButton(button,x,y,selected)
	local menu = vehshop.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(0.25, 0.25)
	if selected then
		SetTextColour(0, 0, 0, 255)
	else
		SetTextColour(255, 255, 255, 255)
	end
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(button.name)
	if selected then
		DrawRect(x,y,menu.width,menu.height,255,255,255,255)
	else
		DrawRect(x,y,menu.width,menu.height,0, 0, 0,220)
	end
	DrawText(x - menu.width/2 + 0.005, y - menu.height/2 + 0.0028)
end

function drawMenuInfo(text)
	local menu = vehshop.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(0.25, 0.25)
	SetTextColour(255, 255, 255, 255)
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawRect(0.675, 0.95,0.65,0.050,0,0,0,250)
	DrawText(0.255, 0.254)
end

function drawMenuRight(txt,x,y,selected)
	local menu = vehshop.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(0.2, 0.2)
	--SetTextRightJustify(1)
	if selected then
		SetTextColour(0,0,0, 255)
	else
		SetTextColour(255, 255, 255, 255)
		
	end
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(txt)
	DrawText(x + menu.width/2 + 0.025, y - menu.height/3 + 0.0002)

	if selected then
		DrawRect(x + menu.width/2 + 0.025, y,menu.width / 3,menu.height,255, 255, 255,250)
	else
		DrawRect(x + menu.width/2 + 0.025, y,menu.width / 3,menu.height,0, 0, 0,250) 
	end
end

function drawMenuTitle(txt,x,y)
	local menu = vehshop.menu
	SetTextFont(2)
	SetTextProportional(0)
	SetTextScale(0.25, 0.25)

	SetTextColour(255, 255, 255, 255)
	SetTextEntry("STRING")
	AddTextComponentString(txt)
	DrawRect(x,y,menu.width,menu.height,0,0,0,250)
	DrawText(x - menu.width/2 + 0.005, y - menu.height/2 + 0.0028)
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function ButtonSelected(button)
	local ped = GetPlayerPed(-1)
	local this = vehshop.currentmenu
    local btn = button.name
    
	if this == "main" then
		if btn == "Voertuigen" then
			OpenMenu('vehicles')
		end
	elseif this == "vehicles" then
		if btn == "Sports" then
			OpenMenu('sports')
		elseif btn == "Sedans" then
			OpenMenu('sedans')
		elseif btn == "Compacts" then
			OpenMenu('compacts')
		elseif btn == "Coupes" then
			OpenMenu('coupes')
		elseif btn == "Sports Classics" then
			OpenMenu("sportsclassics")
		elseif btn == "Super" then
			OpenMenu('super')
		elseif btn == "Muscle" then
			OpenMenu('muscle')
		elseif btn == "Off-Road" then
			OpenMenu('offroad')
		elseif btn == "SUVs" then
			OpenMenu('suvs')
		elseif btn == "Vans" then
			OpenMenu('vans')
		end
	end
end

function OpenMenu(menu)
    vehshop.lastmenu = vehshop.currentmenu
    fakecar = {model = '', car = nil}
	if menu == "vehicles" then
		vehshop.lastmenu = "main"
	end
	vehshop.menu.from = 1
	vehshop.menu.to = 10
	vehshop.selectedbutton = 0
	vehshop.currentmenu = menu
end

function Back()
	if backlock then
		return
	end
	backlock = true
	if vehshop.currentmenu == "main" then
		CloseCreator()
	elseif vehshop.currentmenu == "coupes" or vehshop.currentmenu == "sedans" or vehshop.currentmenu == "super" or vehshop.currentmenu == "sports" then
		if DoesEntityExist(fakecar.car) then
			Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(fakecar.car))
		end
		fakecar = {model = '', car = nil}
		OpenMenu(vehshop.lastmenu)
	else
		OpenMenu(vehshop.lastmenu)
	end
end

function CloseCreator(name, veh, price, financed)
	Citizen.CreateThread(function()
		local ped = GetPlayerPed(-1)
		vehshop.opened = false
		vehshop.menu.from = 1
		vehshop.menu.to = 10
	end)
end

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

function MenuVehicleList()
    ped = GetPlayerPed(-1);
    MenuTitle = "Dealer"
    ClearMenu()
    Menu.addButton("Assortiment Bekijken", "VehicleCategories", nil)
    Menu.addButton("Sluit Menu", "close", nil) 
end

function VehicleCategories()
    ped = GetPlayerPed(-1);
    MenuTitle = "Veh Cats"
    ClearMenu()
    for k, v in pairs(QB.VehicleMenuCategories) do
        Menu.addButton(QB.VehicleMenuCategories[k].label, "GetCatVehicles", k)
    end
    
    Menu.addButton("Sluit Menu", "close", nil) 
end

function GetCatVehicles(catergory)
    ped = GetPlayerPed(-1)
    MenuTitle = "Cat Vehs"
    ClearMenu()
    Menu.addButton("Sluit Menu", "close", nil) 
    for k, v in pairs(shopVehicles[catergory]) do
        Menu.addButton(shopVehicles[catergory][k].name, "SelectVehicle", v, catergory, "€"..shopVehicles[catergory][k]["price"])
    end
end

function SelectVehicle(vehicleData)
    TriggerServerEvent('qb-vehicleshop:server:setShowroomVehicle', vehicleData, currentCarKey)
    close()
end

function close()
    Menu.hidden = true
    ClearMenu()
    QB.ShowroomVehicles[currentCarKey].inUse = false
    TriggerServerEvent('qb-vehicleshop:server:setShowroomCarInUse', currentCarKey, false)
    inMenu = false
    currentCarKey, currentCarValue = nil
end

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    for i = 1, #QB.ShowroomVehicles, 1 do
        local oldVehicle = GetClosestVehicle(QB.ShowroomVehicles[i].coords.x, QB.ShowroomVehicles[i].coords.y, QB.ShowroomVehicles[i].coords.z, 1.0, 0, 70)
        if oldVehicle ~= 0 then
            QBCore.Functions.DeleteVehicle(oldVehicle)
        end

		local model = GetHashKey(QB.ShowroomVehicles[i].chosenVehicle)
		RequestModel(model)
		while not HasModelLoaded(model) do
			Citizen.Wait(0)
		end

		local veh = CreateVehicle(model, QB.ShowroomVehicles[i].coords.x, QB.ShowroomVehicles[i].coords.y, QB.ShowroomVehicles[i].coords.z, false, false)
		SetModelAsNoLongerNeeded(model)
		SetVehicleOnGroundProperly(veh)
		SetEntityInvincible(veh,true)
        SetEntityHeading(veh, QB.ShowroomVehicles[i].coords.h)
        SetVehicleDoorsLocked(veh, 3)

		FreezeEntityPosition(veh,true)
		SetVehicleNumberPlateText(veh, i .. "CARSALE")
    end
end)

function OpenCreator()
	vehshop.currentmenu = "main"
	vehshop.opened = true
	vehshop.selectedbutton = 0
end

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        
        local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped)

        for k, v in pairs(QB.ShowroomVehicles) do
            local dist = GetDistanceBetweenCoords(pos, QB.ShowroomVehicles[k].coords.x, QB.ShowroomVehicles[k].coords.y, QB.ShowroomVehicles[k].coords.z)

            if dist < 2.5 then
                if not QB.ShowroomVehicles[k].inUse then
                    local vehicleHash = GetHashKey(QB.ShowroomVehicles[k].chosenVehicle)
                    local displayName = QBCore.Shared.Vehicles[QB.ShowroomVehicles[k].chosenVehicle]["name"]
                    local vehPrice = QBCore.Shared.Vehicles[QB.ShowroomVehicles[k].chosenVehicle]["price"]

                    -- DrawText3Ds(QB.ShowroomVehicles[k].coords.x, QB.ShowroomVehicles[k].coords.y, QB.ShowroomVehicles[k].coords.z + 0.8, '[G] - Verander Voertuig (~g~'..displayName..'~w~) | [H] - Testrit')
                    if not vehshop.opened then
                        if not buySure then
                            DrawText3Ds(QB.ShowroomVehicles[k].coords.x, QB.ShowroomVehicles[k].coords.y, QB.ShowroomVehicles[k].coords.z + 0.8, '~g~G~w~ - Verander Voertuig (~g~'..displayName..'~w~)')
                        end
                        if not buySure then
                            DrawText3Ds(QB.ShowroomVehicles[k].coords.x, QB.ShowroomVehicles[k].coords.y, QB.ShowroomVehicles[k].coords.z + 0.65, '~g~E~w~ - Voertuig Kopen (~g~€'..vehPrice..'~w~)')
                        elseif buySure then
                            DrawText3Ds(QB.ShowroomVehicles[k].coords.x, QB.ShowroomVehicles[k].coords.y, QB.ShowroomVehicles[k].coords.z + 0.65, 'Weet je het zeker? | ~g~[7]~w~ Ja -/- ~r~[8]~w~ Nee')
                        end
                    elseif vehshop.opened then
                        DrawText3Ds(QB.ShowroomVehicles[k].coords.x, QB.ShowroomVehicles[k].coords.y, QB.ShowroomVehicles[k].coords.z + 0.65, 'Voertuig aan het kiezen')
                    end
                    if not vehshop.opened then
                        if IsControlJustPressed(0, Keys["G"]) then
                            if vehshop.opened then
                                CloseCreator()
                                currentCarKey, currentCarValue = nil, nil
                            else
                                OpenCreator()
                                currentCarKey, currentCarValue = k, v
                            end
                        end
                    end
                        if vehshop.opened then

                            local ped = GetPlayerPed(-1)
                            local menu = vehshop.menu[vehshop.currentmenu]
                            local y = vehshop.menu.y + 0.12
                            buttoncount = tablelength(menu.buttons)
                            local selected = false

                            for i,button in pairs(menu.buttons) do
                                if i >= vehshop.menu.from and i <= vehshop.menu.to then

                                    if i == vehshop.selectedbutton then
                                        selected = true
                                    else
                                        selected = false
                                    end
                                    drawMenuButton(button,vehshop.menu.x,y,selected)
                                    if button.costs ~= nil then

                                        drawMenuRight("€"..button.costs,vehshop.menu.x,y,selected)

                                    end
                                    y = y + 0.04
                                    if vehshop.currentmenu == "coupes" or vehshop.currentmenu == "sedans" or vehshop.currentmenu == "super" or vehshop.currentmenu == "sports" then
                                        if selected then
                                            if QB.ShowroomVehicles[k].chosenVehicle ~= button.model then
                                                QB.ShowroomVehicles[k].chosenVehicle = button.model
                                                TriggerServerEvent('qb-vehicleshop:server:setShowroomVehicle', button.model, currentCarKey)
                                            end
                                        end
                                    end
                                    if selected and ( IsControlJustPressed(1,38) or IsControlJustPressed(1, 18) ) then
                                        ButtonSelected(button)
                                    end
                                end
                            end
                        end
                        if vehshop.opened then
                            if IsControlJustPressed(1,202) then
                                Back()
                            end
                            if IsControlJustReleased(1,202) then
                                backlock = false
                            end
                            if IsControlJustPressed(1,188) then
                                if vehshop.selectedbutton > 1 then
                                    vehshop.selectedbutton = vehshop.selectedbutton -1
                                    if buttoncount > 10 and vehshop.selectedbutton < vehshop.menu.from then
                                        vehshop.menu.from = vehshop.menu.from -1
                                        vehshop.menu.to = vehshop.menu.to - 1
                                    end
                                end
                            end
                            if IsControlJustPressed(1,187)then
                                if vehshop.selectedbutton < buttoncount then
                                    vehshop.selectedbutton = vehshop.selectedbutton +1
                                    if buttoncount > 10 and vehshop.selectedbutton > vehshop.menu.to then
                                        vehshop.menu.to = vehshop.menu.to + 1
                                        vehshop.menu.from = vehshop.menu.from + 1
                                    end
                                end
                            end
                        end

                    if GetVehiclePedIsTryingToEnter(GetPlayerPed(-1)) ~= nil and GetVehiclePedIsTryingToEnter(GetPlayerPed(-1)) ~= 0 then
                        ClearPedTasksImmediately(GetPlayerPed(-1))
                    end

                    if IsControlJustPressed(0, Keys["E"]) then
                        if not vehshop.opened then
                            if not buySure then
                                buySure = true
                            end
                        end
                    end

                    if IsDisabledControlJustPressed(0, Keys["7"]) then
                        if buySure then
                            local class = QBCore.Shared.Vehicles[QB.ShowroomVehicles[k].chosenVehicle]["category"]
                            TriggerServerEvent('qb-vehicleshop:server:buyShowroomVehicle', QB.ShowroomVehicles[k].chosenVehicle, class)
                            buySure = false
                        end
                    end
                    if IsDisabledControlJustPressed(0, Keys["8"]) then
                        QBCore.Functions.Notify('Je hebt het voertuig niet gekocht', 'error', 3500)
                        buySure = false
                    end
                    DisableControlAction(0, Keys["7"], true)
                    DisableControlAction(0, Keys["8"], true)
                elseif QB.ShowroomVehicles[k].inUse then
                    DrawText3Ds(QB.ShowroomVehicles[k].coords.x, QB.ShowroomVehicles[k].coords.y, QB.ShowroomVehicles[k].coords.z + 0.5, 'Voertuig is in gebruik')
                end
            end
        end

        Citizen.Wait(3)
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		

	end
end)

RegisterNetEvent('qb-vehicleshop:client:setShowroomCarInUse')
AddEventHandler('qb-vehicleshop:client:setShowroomCarInUse', function(showroomVehicle, inUse)
    QB.ShowroomVehicles[showroomVehicle].inUse = inUse
end)

RegisterNetEvent('qb-vehicleshop:client:setShowroomVehicle')
AddEventHandler('qb-vehicleshop:client:setShowroomVehicle', function(showroomVehicle, k)
    QBCore.Functions.DeleteVehicle(GetClosestVehicle(QB.ShowroomVehicles[k].coords.x, QB.ShowroomVehicles[k].coords.y, QB.ShowroomVehicles[k].coords.z, 1.0, 0, 70))
    if QB.ShowroomVehicles[k] ~= showroomVehicle then
        local model = GetHashKey(showroomVehicle)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end
        local veh = CreateVehicle(model, QB.ShowroomVehicles[k].coords.x, QB.ShowroomVehicles[k].coords.y, QB.ShowroomVehicles[k].coords.z, false, false)
        SetModelAsNoLongerNeeded(model)
        SetVehicleOnGroundProperly(veh)
        SetEntityInvincible(veh,true)
        SetEntityHeading(veh, QB.ShowroomVehicles[k].coords.h)
        SetVehicleDoorsLocked(veh, 3)

        FreezeEntityPosition(veh, true)
        SetVehicleNumberPlateText(veh, k .. "CARSALE")
    end

    QB.ShowroomVehicles[k].chosenVehicle = showroomVehicle
end)



RegisterNetEvent('qb-vehicleshop:client:buyShowroomVehicle')
AddEventHandler('qb-vehicleshop:client:buyShowroomVehicle', function(vehicle, plate)
    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
        TaskWarpPedIntoVehicle(GetPlayerPed(-1), veh, -1)
        exports['LegacyFuel']:SetFuel(veh, 100)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityHeading(veh, QB.DefaultBuySpawn.h)
		TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
    end, QB.DefaultBuySpawn, false)
end)