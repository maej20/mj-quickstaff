local QBCore = exports['qb-core']:GetCoreObject()

local StaffModeEnabled = false
local StaffOutfit = {}
local Previous = {
  health = nil,
  job = {},
  metadata = {},
  position = {},
  heading = nil,
  outfit = {}
}

RegisterNetEvent( 'mj-stafftoggle:client:ToggleStaffMode', function( source )
  local src = source
  if not StaffModeEnabled then
      EnableStaffMode()
    elseif StaffModeEnabled then
      DisableStaffMode()
  end
end)

function EnableStaffMode()
  QBCore.Functions.TriggerCallback( "mj-stafftoggle:server:getPreviousOutfit", function( result )
    Previous.outfit = result
    if Previous.outfit then

      QBCore.Functions.TriggerCallback( "mj-stafftoggle:server:getStaffOutfit", function( result )
        StaffOutfit = result

        if StaffOutfit then
          StaffModeEnabled = true
          local PlayerData = QBCore.Functions.GetPlayerData()
          local player = PlayerPedId()

          -- Store Player Data
          Previous.money = PlayerData.money
          Previous.metadata = PlayerData.metadata
          Previous.position = QBCore.Functions.GetCoords( player )  -- vector4
          -- Previous.position = GetEntityCoords(player, false)
          -- Previous.heading = GetEntityHeading(player)
          Previous.inventory = PlayerData.inventory
          Previous.job = PlayerData.job
          Previous.health = GetEntityHealth( player )

          -- Store Job Duty
          if Previous.job.onduty then TriggerServerEvent( "QBCore:ToggleDuty" ) end
          TriggerServerEvent( "police:server:SetHandcuffStatus", false )

          -- Set Player States
          SetPlayerHealthy()

          -- Load Staff Skin
          TriggerEvent( "qb-clothes:loadSkin", false, StaffOutfit.model, StaffOutfit.skin )
          TriggerEvent( "QBCore:Notify", "Staff Mode Enabled" )

        else
          TriggerEvent("QBCore:Notify", "Outfit \"STAFF\" not found!", "error", 7000)

        end
      end)

    else
      TriggerEvent("QBCore:Notify", "You don't have a saved outfit to change back into! You must save at least one outfit.", "error", 7000)
    end
  end)
end

function DisableStaffMode()
  local player = PlayerPedId()
  StaffModeEnabled = false

  -- Reset Metadata
  TriggerServerEvent( 'QBCore:Server:SetMetaData', "jailitems", Previous.metadata.jailitems )
  TriggerServerEvent( 'QBCore:Server:SetMetaData', "thirst", Previous.metadata.thirst )
  TriggerServerEvent( 'QBCore:Server:SetMetaData', "hunger", Previous.metadata.hunger )
  TriggerServerEvent( 'QBCore:Server:SetMetaData', "isdead", Previous.metadata.isdead )
  TriggerServerEvent( 'QBCore:Server:SetMetaData', "injail", Previous.metadata.injail )
  TriggerServerEvent( 'QBCore:Server:SetMetaData', "inside", Previous.metadata.inside )
  TriggerServerEvent( 'QBCore:Server:SetMetaData', "armor", Previous.metadata.armor )
  TriggerServerEvent( 'QBCore:Server:SetMetaData', "inlaststand", Previous.metadata.inlaststand )
  TriggerServerEvent( 'QBCore:Server:SetMetaData', "ishandcuffed", Previous.metadata.ishandcuffed )

  -- Reset Job Duty
  if Previous.job.onduty then TriggerServerEvent( "QBCore:ToggleDuty" ) end

  -- Normal Run Speed
  SetRunSprintMultiplierForPlayer( player, 1.0 )
  SetSwimMultiplierForPlayer( player, 1.0 )

  -- Reset Cuffed State
  TriggerServerEvent( "police:server:SetHandcuffStatus", Previous.ishandcuffed )
  if Previous.ishandcuffed then TriggerServerEvent( "InteractSound_SV:PlayOnSource", "Cuff", 0.2 ) end

  -- Load Normal Player Skin
  TriggerEvent( "qb-clothes:loadSkin", false, Previous.outfit.model, Previous.outfit.skin )

  -- Check If We Want To Return To Previous Location And If So....
  if Config.ReturnToLastLocation then
    local house = Previous.metadata.inside.house
    local apartment = Previous.metadata.inside.apartment.apartmentId

    -- Put In House/Apartment If Needed
    if house then exports['qb-houses']:enterOwnedHouse(house) end
    if apartment then TriggerEvent( 'apartments:client:EnterApartment' ) end

    -- Put Player Back Where They Were Outside
    -- or if they were in a spawned interior we'll put them on the ground above the interior
    -- this is the best I can come up with... Please submit a PR if you know a better way
    if not house and not apartment then
      for height = 1, 1000 do
        local foundGround, zPos = GetGroundZFor_3dCoord(Previous.position.x, Previous.position.y, height + 0.0, 1)
        if foundGround then
          SetEntityCoords(player, Previous.position.x, Previous.position.y, zPos)
          break
        end
      end
      -- SetEntityCoords(player, Previous.position.x, Previous.position.y, Previous.position.z)
      SetEntityHeading( player, Previous.position.w )
    end
  end

  -- Reset Health (must be in its own thread for some reason **and will only work JUST like this**)
  -- Please submit a PR if you have a better way of doing this!
  CreateThread(function()
    local player = PlayerPedId()
    local newHealth = tonumber(Previous.health)
    SetEntityHealth(player, newHealth)
    SetEntityMaxHealth(player, 200)
  end)

  TriggerEvent( "QBCore:Notify", "Staff Mode Disabled" )
end

-- Player States
function SetPlayerHealthy()
  local player = PlayerPedId()
  DetachEntity(player, true, false)
  ClearPedTasksImmediately(player)
  ResetPedMovementClipset(player, 0.0)
  TriggerEvent( "hospital:client:Revive" )
  SetRunSprintMultiplierForPlayer(player, 1.49)
  SetSwimMultiplierForPlayer(player, 1.49)
end

-- Godmode
if Config.AutoGodMode then
  Citizen.CreateThread(function()
    while true do
      if StaffModeEnabled then
        local ped = PlayerPedId()
        local pid = PlayerId()

        SetPlayerSprint(pid, true)
        SetEntityInvincible(ped, true)
        SetPlayerInvincible(pid, true)
        SetPedCanRagdoll(ped, false)
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
        ClearPedLastWeaponDamage(ped)
        SetEntityProofs(ped, true, true, true, true, true, true, true, true)
        SetEntityCanBeDamaged(ped, false)
        RestorePlayerStamina(pid, 1.0)
        if IsPedInAnyVehicle(ped, false) then
            currVeh = GetVehiclePedIsIn(ped, false)
            SetVehicleDirtLevel(currVeh)
            SetVehicleUndriveable(currVeh, false)
            WashDecalsFromVehicle(currVeh, 1.0)
            if GetVehicleEngineHealth(currVeh) < 1000.0 then SetVehicleFixed(currVeh) end
            SetVehicleEngineOn(currVeh, true, false )
        end
      else
        SetEntityInvincible(ped, false)
        SetPlayerInvincible(PlayerId(), false)
        SetPedCanRagdoll(ped, true)
        ClearPedLastWeaponDamage(ped)
        SetEntityProofs(ped, false, false, false, false, false, false, false, false)
        SetEntityCanBeDamaged(ped, true)
      end
      Citizen.Wait(250)
    end
  end)
end

-- Thirst/Hunger/Stress
Citizen.CreateThread(function()
  local player = PlayerPedId()
  while true do
    if StaffModeEnabled then
      TriggerServerEvent( "hud:server:RelieveStress", 100)
      TriggerServerEvent( "QBCore:Server:SetMetaData", "hunger", 200 )
      TriggerServerEvent( "QBCore:Server:SetMetaData", "thirst", 200 )
      TriggerEvent( "hud:client:UpdateNeeds", player, 100, 100 )
    end
    Citizen.Wait(5*60*1000)
  end
end)

-- Overhead ID Stuff
if Config.AutoPlayerIds then
  CreateThread(function()
    while true do
      if StaffModeEnabled then
        for _, player in pairs(GetPlayersFromCoords(GetEntityCoords(PlayerPedId()), 10.0)) do
          local PlayerId = GetPlayerServerId(player)
          local PlayerPed = GetPlayerPed(player)
          local PlayerCoords = GetEntityCoords(PlayerPed)
          DrawText3D(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z + 1.0, '['..PlayerId..']')
        end
      end
      Wait(5)
    end
  end)
end

function GetPlayers()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
      local ped = GetPlayerPed(player)
      if DoesEntityExist(ped) then players[#players+1] = player end
    end
    return players
end

function GetPlayersFromCoords(coords, distance)
  local players = GetPlayers()
  local closePlayers = {}

  if coords == nil then coords = GetEntityCoords(PlayerPedId()) end
  if distance == nil then distance = 5.0 end

  for _, player in pairs(players) do
    local target = GetPlayerPed(player)
    local targetCoords = GetEntityCoords(target)
    local targetdistance = #(targetCoords - vector3(coords.x, coords.y, coords.z))
    if targetdistance <= distance then closePlayers[#closePlayers+1] = player end
  end
  return closePlayers
end

function DrawText3D(x, y, z, text)
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
-- End Overhead ID Stuff

exports("isStaffModeOn", function()
  return StaffModeEnabled
end)