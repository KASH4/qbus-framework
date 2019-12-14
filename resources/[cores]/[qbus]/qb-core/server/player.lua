QBCore.Players = {}
QBCore.Player = {}

QBCore.Player.Login = function(source, citizenid, newData)
	if source ~= nil then
		if citizenid then
			QBCore.Functions.ExecuteSql("SELECT * FROM `players` WHERE `citizenid` = '"..citizenid.."'", function(result)
				local PlayerData = result[1]
				if PlayerData ~= nil then
					PlayerData.money = json.decode(PlayerData.money)
					PlayerData.job = json.decode(PlayerData.job)
					PlayerData.position = json.decode(PlayerData.position)
					PlayerData.metadata = json.decode(PlayerData.metadata)
					PlayerData.charinfo = json.decode(PlayerData.charinfo)
				end
				QBCore.Player.CheckPlayerData(source, PlayerData)
			end)
		else
			QBCore.Player.CheckPlayerData(source, newData)
		end
		return true
	else
		QBCore.ShowError(GetCurrentResourceName(), "ERROR QBCORE.PLAYER.LOGIN - NO SOURCE GIVEN!")
		return false
	end
end

QBCore.Player.CheckPlayerData = function(source, PlayerData)
	PlayerData = PlayerData ~= nil and PlayerData or {}

	PlayerData.source = source
	PlayerData.citizenid = PlayerData.citizenid ~= nil and PlayerData.citizenid or QBCore.Player.CreateCitizenId()
	PlayerData.steam = PlayerData.steam ~= nil and PlayerData.steam or QBCore.Functions.GetIdentifier(source, "steam")
	PlayerData.license = PlayerData.license ~= nil and PlayerData.license or QBCore.Functions.GetIdentifier(source, "license")
	PlayerData.name = GetPlayerName(source)
	PlayerData.cid = PlayerData.cid ~= nil and PlayerData.cid or 1

	PlayerData.money = PlayerData.money ~= nil and PlayerData.money or {}
	for moneytype, startamount in pairs(QBCore.Config.Money.MoneyTypes) do
		PlayerData.money[moneytype] = PlayerData.money[moneytype] ~= nil and PlayerData.money[moneytype] or startamount
	end

	PlayerData.charinfo = PlayerData.charinfo ~= nil and PlayerData.charinfo or {}
	PlayerData.charinfo.firstname = PlayerData.charinfo.firstname ~= nil and PlayerData.charinfo.firstname or "Firstname"
	PlayerData.charinfo.lastname = PlayerData.charinfo.lastname ~= nil and PlayerData.charinfo.lastname or "Lastname"
	PlayerData.charinfo.birthdate = PlayerData.charinfo.birthdate ~= nil and PlayerData.charinfo.birthdate or "00-00-0000"
	PlayerData.charinfo.gender = PlayerData.charinfo.gender ~= nil and PlayerData.charinfo.gender or 0
	PlayerData.charinfo.backstory = PlayerData.charinfo.backstory ~= nil and PlayerData.charinfo.backstory or "placeholder backstory"
	PlayerData.charinfo.nationality = PlayerData.charinfo.nationality ~= nil and PlayerData.charinfo.nationality or "Nederlands"
	PlayerData.charinfo.phone = PlayerData.charinfo.phone ~= nil and PlayerData.charinfo.phone or "06"..math.random(11111111, 99999999)
	PlayerData.charinfo.account = PlayerData.charinfo.account ~= nil and PlayerData.charinfo.account or "NL0"..math.random(1,9).."QBUS"..math.random(1111,9999)..math.random(1111,9999)..math.random(11,99)
	
	PlayerData.metadata = PlayerData.metadata ~= nil and PlayerData.metadata or {}
	PlayerData.metadata["hunger"] = PlayerData.metadata["hunger"] ~= nil and PlayerData.metadata["hunger"] or 100
	PlayerData.metadata["thirst"] = PlayerData.metadata["thirst"] ~= nil and PlayerData.metadata["thirst"] or 100
	PlayerData.metadata["isdead"] = PlayerData.metadata["isdead"] ~= nil and PlayerData.metadata["isdead"] or false
	PlayerData.metadata["armor"]  = PlayerData.metadata["armor"]  ~= nil and PlayerData.metadata["armor"] or 0
	PlayerData.metadata["ishandcuffed"] = PlayerData.metadata["ishandcuffed"] ~= nil and PlayerData.metadata["ishandcuffed"] or false	
	PlayerData.metadata["tracker"] = PlayerData.metadata["tracker"] ~= nil and PlayerData.metadata["tracker"] or false
	PlayerData.metadata["injail"] = PlayerData.metadata["injail"] ~= nil and PlayerData.metadata["injail"] or 0
	PlayerData.metadata["jailitems"] = PlayerData.metadata["jailitems"] ~= nil and PlayerData.metadata["jailitems"] or {}
	PlayerData.metadata["status"] = PlayerData.metadata["status"] ~= nil and PlayerData.metadata["status"] or {}
	PlayerData.metadata["phone"] = PlayerData.metadata["phone"] ~= nil and PlayerData.metadata["phone"] or {}
	PlayerData.metadata["fitbit"] = PlayerData.metadata["fitbit"] ~= nil and PlayerData.metadata["fitbit"] or {}
	PlayerData.metadata["commandbinds"] = PlayerData.metadata["commandbinds"] ~= nil and PlayerData.metadata["commandbinds"] or {}
	PlayerData.metadata["bloodtype"] = PlayerData.metadata["bloodtype"] ~= nil and PlayerData.metadata["bloodtype"] or QBCore.Config.Player.Bloodtypes[math.random(1, #QBCore.Config.Player.Bloodtypes)]
	PlayerData.metadata["dealerrep"] = PlayerData.metadata["dealerrep"] ~= nil and PlayerData.metadata["dealerrep"] or 0
	PlayerData.metadata["craftingrep"] = PlayerData.metadata["craftingrep"] ~= nil and PlayerData.metadata["craftingrep"] or 0
	PlayerData.metadata["currentapartment"] = PlayerData.metadata["currentapartment"] ~= nil and PlayerData.metadata["currentapartment"] or nil
	PlayerData.metadata["jobrep"] = PlayerData.metadata["jobrep"] ~= nil and PlayerData.metadata["jobrep"] or {
		["tow"] = 0,
		["trucker"] = 0,
		["taxi"] = 0,
	}
	PlayerData.metadata["callsign"] = PlayerData.metadata["callsign"] ~= nil and PlayerData.metadata["callsign"] or "NO CALLSIGN"
	PlayerData.metadata["fingerprint"] = PlayerData.metadata["fingerprint"] ~= nil and PlayerData.metadata["fingerprint"] or QBCore.Player.CreateFingerId()
	PlayerData.metadata["criminalrecord"] = PlayerData.metadata["criminalrecord"] ~= nil and PlayerData.metadata["criminalrecord"] or {
		["hasRecord"] = false,
		["date"] = nil
	}	
	PlayerData.metadata["licences"] = PlayerData.metadata["licences"] ~= nil and PlayerData.metadata["licences"] or {
		["driver"] = true,
		["business"] = false
	}

	PlayerData.job = PlayerData.job ~= nil and PlayerData.job or {}
	PlayerData.job.name = PlayerData.job.name ~= nil and PlayerData.job.name or "unemployed"
	PlayerData.job.label = PlayerData.job.label ~= nil and PlayerData.job.label or "Werkloos"
	PlayerData.job.payment = PlayerData.job.payment ~= nil and PlayerData.job.payment or 10
	PlayerData.job.onduty = PlayerData.job.onduty ~= nil and PlayerData.job.onduty or true

	PlayerData.position = PlayerData.position ~= nil and PlayerData.position or QBConfig.DefaultSpawn

	PlayerData = QBCore.Player.LoadInventory(PlayerData)
	QBCore.Player.CreatePlayer(PlayerData)
end

QBCore.Player.CreatePlayer = function(PlayerData)
	local self = {}
	self.Functions = {}
	self.PlayerData = PlayerData

	self.Functions.UpdatePlayerData = function()
		TriggerClientEvent("QBCore:Player:SetPlayerData", self.PlayerData.source, self.PlayerData)
		QBCore.Commands.Refresh(self.PlayerData.source)
	end

	self.Functions.SetJob = function(job)
		local job = job:lower()
		local grade = tonumber(grade)
		if QBCore.Shared.Jobs[job] ~= nil then
			self.PlayerData.job.name = job
			self.PlayerData.job.label = QBCore.Shared.Jobs[job].label
			self.PlayerData.job.payment = QBCore.Shared.Jobs[job].payment
			self.PlayerData.job.onduty = QBCore.Shared.Jobs[job].defaultDuty
			self.Functions.UpdatePlayerData()
			TriggerClientEvent("QBCore:Client:OnJobUpdate", self.PlayerData.source, self.PlayerData.job)
			--TriggerEvent("QBCore:Server:OnJobUpdate", self.PlayerData.job)
		end
	end

	self.Functions.SetJobDuty = function(onDuty)
		self.PlayerData.job.onduty = onDuty
		self.Functions.UpdatePlayerData()
	end

	self.Functions.SetMetaData = function(meta, val)
		local meta = meta:lower()
		if val ~= nil then
			self.PlayerData.metadata[meta] = val
			self.Functions.UpdatePlayerData()
		end
	end

	self.Functions.AddJobReputation = function(amount)
		local amount = tonumber(amount)
		self.PlayerData.metadata["jobrep"][self.PlayerData.job.name] = self.PlayerData.metadata["jobrep"][self.PlayerData.job.name] + amount
		self.Functions.UpdatePlayerData()
	end

	self.Functions.AddMoney = function(moneytype, amount)
		local moneytype = moneytype:lower()
		local amount = tonumber(amount)
		if self.PlayerData.money[moneytype] ~= nil then
			self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype]+amount
			self.Functions.UpdatePlayerData()
			if amount > 100000 then
				TriggerEvent("qb-log:server:CreateLog", "playermoney", "AddMoney", "lightgreen", "**"..GetPlayerName(self.PlayerData.source) .. "** €"..amount .. " ("..moneytype..") erbij, nieuw "..moneytype.." balans: "..self.PlayerData.money[moneytype], true)
			else
				TriggerEvent("qb-log:server:CreateLog", "playermoney", "AddMoney", "lightgreen", "**"..GetPlayerName(self.PlayerData.source) .. "** €"..amount .. " ("..moneytype..") erbij, nieuw "..moneytype.." balans: "..self.PlayerData.money[moneytype])
			end
			TriggerClientEvent("hud:client:OnMoneyChange", self.PlayerData.source, moneytype, amount, false)
			return true
		end
		return false
	end

	self.Functions.RemoveMoney = function(moneytype, amount)
		local moneytype = moneytype:lower()
		local amount = tonumber(amount)
		if self.PlayerData.money[moneytype] ~= nil then
			for _, mtype in pairs(QBCore.Config.Money.DontAllowMinus) do
				if mtype == moneytype then
					if self.PlayerData.money[moneytype] - amount < 0 then return false end
				end
			end
			self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount
			self.Functions.UpdatePlayerData()
			if amount > 100000 then
				TriggerEvent("qb-log:server:CreateLog", "playermoney", "RemoveMoney", "red", "**"..GetPlayerName(self.PlayerData.source) .. "** €"..amount .. " ("..moneytype..") eraf, nieuw "..moneytype.." balans: "..self.PlayerData.money[moneytype], true)
			else
				TriggerEvent("qb-log:server:CreateLog", "playermoney", "RemoveMoney", "red", "**"..GetPlayerName(self.PlayerData.source) .. "** €"..amount .. " ("..moneytype..") eraf, nieuw "..moneytype.." balans: "..self.PlayerData.money[moneytype])
			end
			TriggerClientEvent("hud:client:OnMoneyChange", self.PlayerData.source, moneytype, amount, true)
			return true
		end
		return false
	end

	self.Functions.SetMoney = function(moneytype, amount)
		local moneytype = moneytype:lower()
		local amount = tonumber(amount)
		if self.PlayerData.money[moneytype] ~= nil then
			self.PlayerData.money[moneytype] = amount
			self.Functions.UpdatePlayerData()
			TriggerEvent("qb-log:server:CreateLog", "playermoney", "SetMoney", "green", "**"..GetPlayerName(self.PlayerData.source) .. "** €"..amount .. " ("..moneytype..") gezet, nieuw "..moneytype.." balans: "..self.PlayerData.money[moneytype])
			return true
		end
		return false
	end

	self.Functions.AddItem = function(item, amount, slot, info)
		local totalWeight = QBCore.Player.GetTotalWeight(self.PlayerData.items)
		local itemInfo = QBCore.Shared.Items[item:lower()]
		if itemInfo == nil then TriggerClientEvent('chatMessage', -1, "SYSTEM",  "warning", "No item found??") return end
		local amount = tonumber(amount)
		local slot = tonumber(slot) ~= nil and tonumber(slot) or QBCore.Player.GetFirstSlotByItem(self.PlayerData.items, item)
		if itemInfo["type"] == "weapon" and info == nil then
			info = {
				serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4)),
			}
		end
		if (totalWeight + (itemInfo["weight"] * amount)) <= QBCore.Config.Player.MaxWeight then
			if (slot ~= nil and self.PlayerData.items[slot] ~= nil) and (self.PlayerData.items[slot].name:lower() == item:lower()) and (itemInfo["type"] == "item" and not itemInfo["unique"]) then
				self.PlayerData.items[slot].amount = self.PlayerData.items[slot].amount + amount
				self.Functions.UpdatePlayerData()
				TriggerEvent("qb-log:server:CreateLog", "playerinventory", "AddItem", "green", "**"..GetPlayerName(self.PlayerData.source) .. "** krijgt item: [slot:" ..slot.."], itemname: " .. self.PlayerData.items[slot].name .. ", added amount: " .. amount ..", new total amount: ".. self.PlayerData.items[slot].amount)
				--TriggerClientEvent('QBCore:Notify', self.PlayerData.source, itemInfo["label"].. " toegevoegd!", "success")
				return true
			elseif (not itemInfo["unique"] and slot or slot ~= nil and self.PlayerData.items[slot] == nil) then
				self.PlayerData.items[slot] = {name = itemInfo["name"], amount = amount, info = info ~= nil and info or "", label = itemInfo["label"], description = itemInfo["description"] ~= nil and itemInfo["description"] or "", weight = itemInfo["weight"], type = itemInfo["type"], unique = itemInfo["unique"], useable = itemInfo["useable"], image = itemInfo["image"], shouldClose = itemInfo["shouldClose"], slot = slot, combinable = itemInfo["combinable"]}
				self.Functions.UpdatePlayerData()
				TriggerEvent("qb-log:server:CreateLog", "playerinventory", "AddItem", "green", "**"..GetPlayerName(self.PlayerData.source) .. "** krijgt item: [slot:" ..slot.."], itemname: " .. self.PlayerData.items[slot].name .. ", added amount: " .. amount ..", new total amount: ".. self.PlayerData.items[slot].amount)
				--TriggerClientEvent('QBCore:Notify', self.PlayerData.source, itemInfo["label"].. " toegevoegd!", "success")
				return true
			elseif (itemInfo["unique"]) or (not slot or slot == nil) or (itemInfo["type"] == "weapon") then
				for i = 1, QBConfig.Player.MaxInvSlots, 1 do
					if self.PlayerData.items[i] == nil then
						self.PlayerData.items[i] = {name = itemInfo["name"], amount = amount, info = info ~= nil and info or "", label = itemInfo["label"], description = itemInfo["description"] ~= nil and itemInfo["description"] or "", weight = itemInfo["weight"], type = itemInfo["type"], unique = itemInfo["unique"], useable = itemInfo["useable"], image = itemInfo["image"], shouldClose = itemInfo["shouldClose"], slot = i, combinable = itemInfo["combinable"]}
						self.Functions.UpdatePlayerData()
						TriggerEvent("qb-log:server:CreateLog", "playerinventory", "AddItem", "green", "**"..GetPlayerName(self.PlayerData.source) .. "** krijgt item: [slot:" ..i.."], itemname: " .. self.PlayerData.items[i].name .. ", added amount: " .. amount ..", new total amount: ".. self.PlayerData.items[i].amount)
						--TriggerClientEvent('QBCore:Notify', self.PlayerData.source, itemInfo["label"].. " toegevoegd!", "success")
						return true
					end
				end
			end
		end
		return false
	end

	self.Functions.RemoveItem = function(item, amount, slot)
		local itemInfo = QBCore.Shared.Items[item:lower()]
		local amount = tonumber(amount)
		local slot = tonumber(slot)
		if slot ~= nil then
			if self.PlayerData.items[slot].amount > amount then
				self.PlayerData.items[slot].amount = self.PlayerData.items[slot].amount - amount
				self.Functions.UpdatePlayerData()
				TriggerEvent("qb-log:server:CreateLog", "playerinventory", "RemoveItem", "red", "**"..GetPlayerName(self.PlayerData.source) .. "** verliest item: [slot:" ..slot.."], itemname: " .. self.PlayerData.items[slot].name .. ", removed amount: " .. amount ..", new total amount: ".. self.PlayerData.items[slot].amount)
				--TriggerClientEvent('QBCore:Notify', self.PlayerData.source, itemInfo["label"].. " verwijderd!", "error")
				return true
			else
				self.PlayerData.items[slot] = nil
				self.Functions.UpdatePlayerData()
				TriggerEvent("qb-log:server:CreateLog", "playerinventory", "RemoveItem", "red", "**"..GetPlayerName(self.PlayerData.source) .. "** verliest item: [slot:" ..slot.."], itemname: " .. item .. ", removed amount: " .. amount ..", item removed")
				--TriggerClientEvent('QBCore:Notify', self.PlayerData.source, itemInfo["label"].. " verwijderd!", "error")
				return true
			end
		else
			local slots = QBCore.Player.GetSlotsByItem(self.PlayerData.items, item)
			local amountToRemove = amount
			if slots ~= nil then
				for _, slot in pairs(slots) do
					if self.PlayerData.items[slot].amount > amountToRemove then
						self.PlayerData.items[slot].amount = self.PlayerData.items[slot].amount - amountToRemove
						self.Functions.UpdatePlayerData()
						TriggerEvent("qb-log:server:CreateLog", "playerinventory", "RemoveItem", "red", "**"..GetPlayerName(self.PlayerData.source) .. "** verliest item: [slot:" ..slot.."], itemname: " .. self.PlayerData.items[slot].name .. ", removed amount: " .. amount ..", new total amount: ".. self.PlayerData.items[slot].amount)
						--TriggerClientEvent('QBCore:Notify', self.PlayerData.source, itemInfo["label"].. " verwijderd!", "error")
						return true
					elseif self.PlayerData.items[slot].amount == amountToRemove then
						self.PlayerData.items[slot] = nil
						self.Functions.UpdatePlayerData()
						TriggerEvent("qb-log:server:CreateLog", "playerinventory", "RemoveItem", "red", "**"..GetPlayerName(self.PlayerData.source) .. "** verliest item: [slot:" ..slot.."], itemname: " .. item .. ", removed amount: " .. amount ..", item removed")
						--TriggerClientEvent('QBCore:Notify', self.PlayerData.source, itemInfo["label"].. " verwijderd!", "error")
						return true
					end
				end
			end
		end
		return false
	end

	self.Functions.SetInventory = function(items)
		self.PlayerData.items = items
		self.Functions.UpdatePlayerData()
		TriggerEvent("qb-log:server:CreateLog", "playerinventory", "SetInventory", "blue", "**"..GetPlayerName(self.PlayerData.source) .. " items set: " .. json.encode(items))
	end

	self.Functions.ClearInventory = function()
		self.PlayerData.items = {}
		self.Functions.UpdatePlayerData()
		TriggerEvent("qb-log:server:CreateLog", "playerinventory", "ClearInventory", "red", "**"..GetPlayerName(self.PlayerData.source) .. " inventory cleared")
	end

	self.Functions.GetItemByName = function(item)
		local item = tostring(item):lower()
		local slot = QBCore.Player.GetFirstSlotByItem(self.PlayerData.items, item)
		if slot ~= nil then
			return self.PlayerData.items[slot]
		end
		return nil
	end

	self.Functions.GetItemBySlot = function(slot)
		local slot = tonumber(slot)
		if self.PlayerData.items[slot] ~= nil then
			return self.PlayerData.items[slot]
		end
		return nil
	end

	self.Functions.Save = function()
		QBCore.Player.Save(self.PlayerData.source)
	end
	
	QBCore.Players[self.PlayerData.source] = self
	QBCore.Player.Save(self.PlayerData.source)
	self.Functions.UpdatePlayerData()
end

QBCore.Player.Save = function(source)
	local PlayerData = QBCore.Players[source].PlayerData
	QBCore.Player.SaveInventory(source)
	if PlayerData ~= nil then
		QBCore.Functions.ExecuteSql("SELECT * FROM `players` WHERE `citizenid` = '"..PlayerData.citizenid.."'", function(result)
			if result[1] == nil then
				QBCore.Functions.ExecuteSql("INSERT INTO `players` (`citizenid`, `cid`, `steam`, `license`, `name`, `money`, `charinfo`, `job`, `position`, `metadata`) VALUES ('"..PlayerData.citizenid.."', '"..tonumber(PlayerData.cid).."', '"..PlayerData.steam.."', '"..PlayerData.license.."', '"..PlayerData.name.."', '"..json.encode(PlayerData.money).."', '"..json.encode(PlayerData.charinfo).."', '"..json.encode(PlayerData.job).."', '"..json.encode(PlayerData.position).."', '"..json.encode(PlayerData.metadata).."')")
			else
				QBCore.Functions.ExecuteSql("UPDATE `players` SET steam='"..PlayerData.steam.."',license='"..PlayerData.license.."',name='"..PlayerData.name.."',money='"..json.encode(PlayerData.money).."',charinfo='"..json.encode(PlayerData.charinfo).."',job='"..json.encode(PlayerData.job).."',position='"..json.encode(PlayerData.position).."',metadata='"..json.encode(PlayerData.metadata).."' WHERE `citizenid` = '"..PlayerData.citizenid.."'")
			end
	    end)
		QBCore.ShowSuccess(GetCurrentResourceName(), PlayerData.name .." PLAYER SAVED!")
	else
		QBCore.ShowError(GetCurrentResourceName(), "ERROR QBCORE.PLAYER.SAVE - PLAYERDATA IS EMPTY!")
	end
end

QBCore.Player.Logout = function(source)
	TriggerClientEvent('QBCore:Client:OnPlayerUnload', source)
	TriggerClientEvent("QBCore:Player:UpdatePlayerData", source)
	Citizen.Wait(200)
	-- TriggerEvent('QBCore:Server:OnPlayerUnload')
	--QBCore.Players[source].Functions.Save()
	QBCore.Players[source] = nil
end

QBCore.Player.DeleteCharacter = function(source, citizenid)
	QBCore.Functions.ExecuteSql("DELETE FROM `players` WHERE `citizenid` = '"..citizenid.."'")
end

QBCore.Player.LoadInventory = function(PlayerData)
	PlayerData.items = {}
	QBCore.Functions.ExecuteSql("SELECT * FROM `playeritems` WHERE `citizenid` = '"..PlayerData.citizenid.."'", function(oldInventory)
		if oldInventory[1] ~= nil then
			for _, item in pairs(oldInventory) do
				if item ~= nil then
					local itemInfo = QBCore.Shared.Items[item.name:lower()]
					PlayerData.items[item.slot] = {name = itemInfo["name"], amount = item.amount, info = json.decode(item.info) ~= nil and json.decode(item.info) or "", label = itemInfo["label"], description = itemInfo["description"] ~= nil and itemInfo["description"] or "", weight = itemInfo["weight"], type = itemInfo["type"], unique = itemInfo["unique"], useable = itemInfo["useable"], image = itemInfo["image"], shouldClose = itemInfo["shouldClose"], slot = item.slot, combinable = itemInfo["combinable"]}
				end
				Citizen.Wait(1)
			end
			QBCore.Functions.ExecuteSql("DELETE FROM `playeritems` WHERE `citizenid` = '"..PlayerData.citizenid.."'")
		else
			QBCore.Functions.ExecuteSql("SELECT * FROM `players` WHERE `citizenid` = '"..PlayerData.citizenid.."'", function(result)
				if result[1].inventory ~= nil then
					result[1].inventory = json.decode(result[1].inventory)
					for _, item in pairs(result[1].inventory) do
						if item ~= nil then
							local itemInfo = QBCore.Shared.Items[item.name:lower()]
							PlayerData.items[item.slot] = {
								name = itemInfo["name"], 
								amount = item.amount, 
								info = json.decode(item.info) ~= nil and json.decode(item.info) or "", 
								label = itemInfo["label"], 
								description = itemInfo["description"] ~= nil and itemInfo["description"] or "", 
								weight = itemInfo["weight"], 
								type = itemInfo["type"], 
								unique = itemInfo["unique"], 
								useable = itemInfo["useable"], 
								image = itemInfo["image"], 
								shouldClose = itemInfo["shouldClose"], 
								slot = item.slot, 
								combinable = itemInfo["combinable"]
							}
						end
					end
				end
			end)
		end
	end)
	return PlayerData
end

local function escape_str(s)
	local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
	local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
	for i, c in ipairs(in_char) do
	  s = s:gsub(c, '\\' .. out_char[i])
	end
	return s
end

QBCore.Player.SaveInventory = function(source)
	local PlayerData = QBCore.Players[source].PlayerData
	local items = PlayerData.items
	local ItemsJson = {}
	if items ~= nil and next(items) ~= nil then
		for slot, item in pairs(items) do
			if items[slot] ~= nil then
				table.insert(ItemsJson, {
					name = item.name,
					amount = item.amount,
					info = escape_str(json.encode(item.info)),
					type = item.type,
					slot = slot,
				})
			end
		end

		QBCore.Functions.ExecuteSql("UPDATE `players` SET `inventory` = '"..json.encode(ItemsJson).."' WHERE `citizenid` = '"..PlayerData.citizenid.."'")
	end
end

QBCore.Player.GetTotalWeight = function(items)
	local weight = 0
	if items ~= nil then
		for slot, item in pairs(items) do
			weight = weight + (item.weight * item.amount)
		end
	end
	return tonumber(weight)
end

QBCore.Player.GetSlotsByItem = function(items, itemName)
	local slotsFound = {}
	if items ~= nil then
		for slot, item in pairs(items) do
			if item.name:lower() == itemName:lower() then
				table.insert(slotsFound, slot)
			end
		end
	end
	return slotsFound
end

QBCore.Player.GetFirstSlotByItem = function(items, itemName)
	if items ~= nil then
		for slot, item in pairs(items) do
			if item.name:lower() == itemName:lower() then
				return tonumber(slot)
			end
		end
	end
	return nil
end

QBCore.Player.CreateCitizenId = function()
	local UniqueFound = false
	local CitizenId = nil

	while not UniqueFound do
		CitizenId = tostring(QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(5)):upper()
		QBCore.Functions.ExecuteSql("SELECT COUNT(*) as count FROM `players` WHERE `citizenid` = '"..CitizenId.."'", function(result)
			if result[1].count == 0 then
				UniqueFound = true
			end
		end)
	end
	return CitizenId
end

QBCore.Player.CreateFingerId = function()
	local UniqueFound = false
	local FingerId = nil
	while not UniqueFound do
		FingerId = tostring(QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(1) .. QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(4))
		QBCore.Functions.ExecuteSql("SELECT COUNT(*) as count FROM `players` WHERE `metadata` LIKE '%"..FingerId.."%'", function(result)
			if result[1].count == 0 then
				UniqueFound = true
			end
		end)
	end
	return FingerId
end