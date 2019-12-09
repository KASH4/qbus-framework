QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

local PaymentTax = 15

local Bail = {}

RegisterServerEvent('qb-trucker:server:DoBail')
AddEventHandler('qb-trucker:server:DoBail', function(bool)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if bool then
        Bail[Player.PlayerData.citizenid] = Config.BailPrice
        Player.Functions.RemoveMoney('cash', Config.BailPrice)
        TriggerClientEvent('QBCore:Notify', src, 'Je hebt de borg van 1000,- betaald', 'success')
    else
        if Bail[Player.PlayerData.citizenid] ~= nil then
            Player.Functions.AddMoney('cash', Bail[Player.PlayerData.citizenid])
            Bail[Player.PlayerData.citizenid] = nil
            TriggerClientEvent('QBCore:Notify', src, 'Je hebt de borg van 1000,- terug gekregen', 'success')
        end
    end
end)

RegisterNetEvent('qb-trucker:server:01101110')
AddEventHandler('qb-trucker:server:01101110', function(drops)
    local src = source 
    local Player = QBCore.Functions.GetPlayer(src)
    local drops = tonumber(drops)
    local bonus = 0
    local DropPrice = math.random(500, 850)
    if drops > 5 then 
        bonus = math.ceil((DropPrice / 100) * 5) + 100
    elseif drops > 10 then
        bonus = math.ceil((DropPrice / 100) * 7) + 300
    elseif drops > 15 then
        bonus = math.ceil((DropPrice / 100) * 10) + 400
    elseif drops > 20 then
        bonus = math.ceil((DropPrice / 100) * 12) + 500
    end
    local price = (DropPrice * drops) + bonus
    local taxAmount = math.ceil((price / 100) * PaymentTax)
    local payment = price - taxAmount
    Player.Functions.AddJobReputation(1)
    Player.Functions.AddMoney("bank", payment)
    TriggerClientEvent('chatMessage', source, "BAAN", "warning", "Je hebt je salaris ontvangen van: €"..payment..", bruto: €"..price.." (waarvan €"..bonus.." bonus) en €"..taxAmount.." belasting ("..PaymentTax.."%)")
end)

