QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

-- Code

RegisterServerEvent('qb-cityhall:server:requestId')
AddEventHandler('qb-cityhall:server:requestId', function(identityData)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)

    local licenses = {
        ["driver"] = true,
        ["business"] = false
    }

    ply.Functions.AddItem(identityData.item, 1)

    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[identityData.item], 'add')
end)

RegisterServerEvent('qb-cityhall:server:ApplyJob')
AddEventHandler('qb-cityhall:server:ApplyJob', function(job)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local JobInfo = QBCore.Player.GetJobInfo(job)

    Player.Functions.SetJob(job)

    TriggerClientEvent('QBCore:Notify', src, 'Gefeliciteerd met je nieuwe baan! ('..JobInfo.label..')')
end)