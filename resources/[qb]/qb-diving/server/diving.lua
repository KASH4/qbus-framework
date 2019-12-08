local CurrentDivingArea = math.random(1, #QBDiving.Locations)
local LastLocation = 0

QBCore.Functions.CreateCallback('qb-diving:server:GetDivingConfig', function(source, cb)
    cb(QBDiving.Locations, CurrentDivingArea)
end)

RegisterServerEvent('qb-diving:server:TakeCoral')
AddEventHandler('qb-diving:server:TakeCoral', function(Area, Coral, Bool)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local CoralType = math.random(1, #QBDiving.CoralTypes)
    local Amount = math.random(1, QBDiving.CoralTypes[CoralType].maxAmount)
    local ItemData = QBCore.Shared.Items[QBDiving.CoralTypes[CoralType].item]

    if Amount > 1 then
        for i = 1, Amount, 1 do
            Player.Functions.AddItem(ItemData["name"], 1)
            TriggerClientEvent('inventory:client:ItemBox', src, ItemData, "add")
            Citizen.Wait(250)
        end
    else
        Player.Functions.AddItem(ItemData["name"], Amount)
        TriggerClientEvent('inventory:client:ItemBox', src, ItemData, "add")
    end

    if (QBDiving.Locations[Area].TotalCoral - 1) == 0 then
        local newLocation = math.random(1, #QBDiving.Locations)
        while (newLocation == CurrentDivingArea) do
            Citizen.Wait(100)
            newLocation = math.random(1, #QBDiving.Locations)
        end
        LastLocation = Area
        CurrentDivingArea = newLocation
        

        for k, v in pairs(QBDiving.Locations[Area].coords.Coral) do
            v.PickedUp = false
        end
        QBDiving.Locations[Area].TotalCoral = QBDiving.Locations[Area].DefaultCoral
        
        TriggerClientEvent('qb-diving:client:NewLocations', -1)
    else
        QBDiving.Locations[Area].TotalCoral = QBDiving.Locations[Area].TotalCoral - 1
    end

    QBDiving.Locations[Area].coords.Coral[Coral].PickedUp = Bool
    TriggerClientEvent('qb-diving:server:UpdateCoral', -1, Area, Coral, Bool)
end)

RegisterServerEvent('qb-diving:server:GearItem')
AddEventHandler('qb-diving:server:GearItem', function(action)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if action == "add" then
        Player.Functions.AddItem("diving_gear", 1)
    elseif action == "remove" then
        Player.Functions.RemoveItem("diving_gear", 1)
    end
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["diving_gear"], action)
end)