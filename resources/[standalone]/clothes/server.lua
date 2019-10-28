QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

RegisterServerEvent("clothes:saveSkin")
AddEventHandler('clothes:saveSkin', function(model, skin)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if model ~= nil and skin ~= nil then 
        QBCore.Functions.ExecuteSql("DELETE FROM `playerskins` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'")
        Citizen.Wait(100)
        QBCore.Functions.ExecuteSql("INSERT INTO `playerskins` (`citizenid`, `model`, `skin`) VALUES ('"..Player.PlayerData.citizenid.."', '"..model.."', '"..skin.."')")
    end
end)

RegisterServerEvent("clothes:saveOutfit")
AddEventHandler('clothes:saveOutfit', function(model, skin, outfitname)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if model ~= nil and skin ~= nil then
        QBCore.Functions.ExecuteSql("INSERT INTO `player_outfits` (`citizenid`, `outfitname`, `model`, `skin`) VALUES ('"..Player.PlayerData.citizenid.."', '"..outfitname.."', '"..model.."', '"..skin.."')")
    end
end)

RegisterServerEvent("clothes:selectOutfit")
AddEventHandler('clothes:selectOutfit', function(model, skin)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    TriggerClientEvent("clothes:loadSkin", src, false, model, skin)
end)

RegisterServerEvent("clothes:removeOutfit")
AddEventHandler('clothes:removeOutfit', function(outfitname)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql("DELETE FROM `player_outfits` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `outfitname` = '"..outfitname.."'")
end)

RegisterServerEvent("clothes:loadPlayerSkin")
AddEventHandler('clothes:loadPlayerSkin', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    QBCore.Functions.ExecuteSql("SELECT * FROM `playerskins` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `active` = 1", function(result)
        if result[1] ~= nil then
            TriggerClientEvent("clothes:loadSkin", src, false, result[1].model, result[1].skin)
        else
            TriggerClientEvent("clothes:loadSkin", src, true)
        end
    end)
end)