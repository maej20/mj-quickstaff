local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add(Config.ToggleCommand, 'Toggles Staff Duty State (Admin Only)', {}, false, function(source, args)
  local src = source
  TriggerClientEvent("mj-stafftoggle:client:ToggleStaffMode", src)
end, "admin")

QBCore.Functions.CreateCallback('mj-stafftoggle:server:getStaffOutfit', function(source, cb)
  local src = source
  if QBCore.Functions.HasPermission(src, 'admin') then
    local Player = QBCore.Functions.GetPlayer(src)
    local staffOutfit = {}
    local result = exports.oxmysql:executeSync('SELECT skin,model FROM player_outfits WHERE outfitname = ? AND citizenid = ? ', { 'staff', Player.PlayerData.citizenid })

    if result[1] ~= nil then
      staffOutfit.skin = result[1].skin
      staffOutfit.model = result[1].model
      cb(staffOutfit)
    end
    cb(nil)
  end
end)

QBCore.Functions.CreateCallback('mj-stafftoggle:server:getPreviousOutfit', function(source, cb)
  local src = source
  if QBCore.Functions.HasPermission(src, 'admin') then
    local Player = QBCore.Functions.GetPlayer(src)
    local prevSkin = {}
    local result = exports.oxmysql:executeSync('SELECT skin,model FROM playerskins WHERE citizenid = ? AND active = ?', { Player.PlayerData.citizenid, 1 })

    if result[1] ~= nil then
      prevSkin.skin = result[1].skin
      prevSkin.model = result[1].model
      cb(prevSkin)
    end
    cb(nil)
  end
end)