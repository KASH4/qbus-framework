QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

-- Code

RegisterServerEvent('qb-fitbit:server:setValue')
AddEventHandler('qb-fitbit:server:setValue', function(type, value)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)
    local fitbitData = {}

    if type == "thirst" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = value,
            food = currentMeta.food
        }
    elseif type == "food" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = currentMeta.thirst,
            food = value
        }
    end

    ply.Functions.SetMetaData('fitbit', fitbitData)
end)