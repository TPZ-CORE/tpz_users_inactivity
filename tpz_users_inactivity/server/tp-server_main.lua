local TPZ = exports.tpz_core:getCoreAPI()
local ConnectedPlayers = {}

-----------------------------------------------------------
--[[ Local Functions  ]]--
-----------------------------------------------------------

-- @GetTableLength returns the length of a table.
local function GetTableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local IsPlayerBlacklisted = function(currentIdentifier, currentGroup)

  if Config.BlacklistedGroupRoles and GetTableLength(Config.BlacklistedGroupRoles) > 0 then

    for index, group in pairs (Config.BlacklistedGroupRoles) do

      if group == currentGroup then
        return true
      end

    end

  end

  if Config.BlacklistedUsers and GetTableLength(Config.BlacklistedUsers) > 0 then

    for index, user in pairs (Config.BlacklistedUsers) do

      if user == currentIdentifier then
        return true
      end

    end

  end

  return false

end

-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end

  ConnectedPlayers = {}
end)

AddEventHandler('playerDropped', function (reason)
  local _source         = source
  local xPlayer         = TPZ.GetPlayer(_source)

  if not xPlayer.loaded() then 
    return
  end

  local charidentifier  = xPlayer.getCharacterIdentifier()

  -- Even if the list does not container the charId, it will not cause any errors.
  -- Not need to check for ~= nil.
  ConnectedPlayers[charidentifier] = nil
 
end)


-----------------------------------------------------------
--[[ General Events  ]]--
-----------------------------------------------------------

-- At first, we set the inactivity time for users back to 0 since they logged in.
-- If the player has not been registered, we register the player and reset the inactivity time.
-- If the player does exist, and connected again, we replace the source.

RegisterServerEvent("tpz_users_inactivity:registerLoggedInData")
AddEventHandler("tpz_users_inactivity:registerLoggedInData", function()
  local _source         = source
  local xPlayer         = TPZ.GetPlayer(_source)

  local charidentifier  = xPlayer.getCharacterIdentifier()

  if not ConnectedPlayers[charidentifier] then
    ConnectedPlayers[charidentifier] = true

    -- We don't want to update every time the player joins, if the server restart, the ConnectedPlayers list will reset eitherway
    -- The player will not be deleted for few hours or even a day since the configuration is always more than that.
    -- It will be updated on every restart just once if the player joins, no need to update it more.
    local Parameters = { 
      ['charidentifier']  = charidentifier, 
      ['inactivity_time'] = 0 
    }
  
    exports.ghmattimysql:execute("UPDATE `characters` SET `inactivity_time` = @inactivity_time WHERE `charidentifier` = @charidentifier", Parameters)
  
  end

end)

-----------------------------------------------------------
--[[ Threads  ]]--
-----------------------------------------------------------

Citizen.CreateThread(function()
	while true do
		Wait(60000 * Config.TimeUpdatingInDatabase)

    exports.ghmattimysql:execute("SELECT * FROM characters", {}, function(charResult)

      for index, character in pairs (charResult) do

        local identifier       = charResult[index].identifier
        local charidentifier   = charResult[index].charidentifier
        local steamName        = charResult[index].steamname

        local group            = charResult[index].group
        local inactivity_time  = charResult[index].inactivity_time

        local playerExists     = false

        local IsPlayerBlacklisted = IsPlayerBlacklisted(identifier, group)

        if not IsPlayerBlacklisted then

          if ConnectedPlayers[tonumber(charidentifier)] then
            playerExists = true
          end

          if not playerExists then

            local Parameters = { ['charidentifier'] = charidentifier, ['inactivity_time'] = Config.TimeUpdatingInDatabase }
            exports.ghmattimysql:execute("UPDATE characters SET inactivity_time = inactivity_time + @inactivity_time WHERE charidentifier = @charidentifier", Parameters)

            inactivity_time = inactivity_time + Config.TimeUpdatingInDatabase

            local deleteDataTime = Config.RemoveDatabaseDataAfter * 1440

            if tonumber(inactivity_time) >= tonumber(deleteDataTime) then

              local finished = false

              local UserParameters = { ['charidentifier'] = charidentifier }

              for _, database in pairs(Config.RemoveFromDatabaseDataList) do
               
                exports.ghmattimysql:execute(database.table, UserParameters)

                if next(Config.RemoveFromDatabaseDataList, _) == nil then
                  finished = true
                end
                
              end

              while not finished do
                Wait(250)
              end

              exports.ghmattimysql:execute("DELETE FROM `characters` WHERE `charidentifier` = @charidentifier ", UserParameters)

              if Config.Debug then
                print(" [!] The following player was inactive for too long, we deleted all data from: " .. charidentifier)
              end

              local webhookData = Config.Webhooking

              if webhookData.Enable then
                  local title   = "🗑️` A Character has been permanently removed due to inactivity.`"
                  local message = "**Steam name: **`" .. steamName .. "`**\nIdentifier: **`" .. identifier .. " (Char: " .. charidentifier .. ") `"
               
                  TPZ.SendToDiscord(webhookData.Url, title, message, webhookData.Color)
              end

            end

          end

        end

      end

    end)

	end

end)

