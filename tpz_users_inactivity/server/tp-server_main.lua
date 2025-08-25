local TPZ = exports.tpz_core:getCoreAPI()
local ConnectedPlayers = {}

-----------------------------------------------------------
--[[ Local Functions  ]]--
-----------------------------------------------------------

local IsPlayerBlacklisted = function(currentIdentifier)

  if Config.BlacklistedUsers and TPZ.GetTableLength(Config.BlacklistedUsers) > 0 then

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

  ConnectedPlayers = nil
end)

-----------------------------------------------------------
--[[ General Events  ]]--
-----------------------------------------------------------

-- At first, we set the inactivity time for users back to 0 since they logged in.
-- If the player has not been registered, we register the player and reset the inactivity time.
-- If the player does exist, and connected again, we replace the source.

RegisterServerEvent("tpz_users_inactivity:registerLoggedInData")
AddEventHandler("tpz_users_inactivity:registerLoggedInData", function()
  local _source = source
  local xPlayer = TPZ.GetPlayer(_source)

  if not xPlayer.loaded() then 
    return
  end

  local identifier = xPlayer.getIdentifier()

  if not ConnectedPlayers[identifier] then
    ConnectedPlayers[identifier] = true

    -- We don't want to update every time the player joins, if the server restart, the ConnectedPlayers list will reset eitherway
    -- The player will not be deleted for few hours or even a day since the configuration is always more than that.
    -- It will be updated on every restart just once if the player joins, no need to update it more.
    exports.ghmattimysql:execute("UPDATE `users` SET `inactivity_time` = 0, `notified_inactivity` = 0 WHERE `identifier` = @identifier",  { ['identifier']  = identifier })
  
  end

end)

-----------------------------------------------------------
--[[ Threads  ]]--
-----------------------------------------------------------

Citizen.CreateThread(function()
	while true do
		Wait(60000 * Config.TimeUpdatingInDatabase)

    exports.ghmattimysql:execute("SELECT * FROM users", {}, function(charResult)

      for index, character in pairs (charResult) do

        local identifier       = character.identifier
        local steamName        = character.steamname
        local inactivity_time  = character.inactivity_time
        local notified         = character.notified_inactivity

        local playerExists     = false

        local IsPlayerBlacklisted = IsPlayerBlacklisted(identifier)

        if not IsPlayerBlacklisted and inactivity_time ~= -1 then

          if ConnectedPlayers[identifier] then
            playerExists = true
          end

          if not playerExists then

            local Parameters = { ['identifier'] = identifier, ['inactivity_time'] = Config.TimeUpdatingInDatabase }
            exports.ghmattimysql:execute("UPDATE `users` SET `inactivity_time` = `inactivity_time` + @inactivity_time WHERE `identifier` = @identifier", Parameters)

            inactivity_time = inactivity_time + Config.TimeUpdatingInDatabase

            local notifyTime = Config.NotifyAbsenceAfter * 1440

            if tonumber(inactivity_time) >= notifyTime and notified == 0 then

              if Config.Debug then
                print(string.format(" [!] The following user ( %s ) is inactive for over  %s days. ", identifier, Config.NotifyAbsenceAfter))
              end

              local webhookData = Config.Webhooking

              if webhookData.Enabled then
                  local title   = string.format("⚠️` [WARNING] Inactive User - %s Days.`", Config.NotifyAbsenceAfter)
                  local message = "**Steam name: **`" .. steamName .. "`**\nIdentifier: **`" .. identifier .. "`"
               
                  TPZ.SendToDiscord(webhookData.Url, title, message, webhookData.Color)
              end

              exports.ghmattimysql:execute("UPDATE `users` SET `notified_inactivity` = 1 WHERE `identifier` = @identifier", { ['identifier'] = identifier } )

            end

            local deleteDataTime = Config.RemoveDatabaseDataAfter * 1440

            if tonumber(inactivity_time) >= tonumber(deleteDataTime) then

              local finished = false

              local UserParameters = { ['identifier'] = identifier }

              for _, database in pairs(Config.RemoveFromDatabaseDataList) do
               
                exports.ghmattimysql:execute(database.table, UserParameters)

                if next(Config.RemoveFromDatabaseDataList, _) == nil then
                  finished = true
                end
                
              end

              while not finished do
                Wait(250)
              end

              -- DELETE ALL CHARACTERS AND RESET USER.
              exports.ghmattimysql:execute("DELETE FROM `characters` WHERE `identifier` = @identifier", UserParameters)
              exports.ghmattimysql:execute("UPDATE `users` SET `inactivity_time` = -1 WHERE `identifier` = @identifier", UserParameters) -- SETS THE USER AS ALREADY CHARS REMOVE FOR PREVENTING ERRORS.

              if Config.Debug then
                print(" [!] The following player was inactive for too long, we deleted all data from: " .. identifier)
              end

              local webhookData = Config.Webhooking

              if webhookData.Enabled then
                  local title   = "🗑️` All Characters and the configured data have been permanently removed due to inactivity.`"
                  local message = "**Steam name: **`" .. steamName .. "`**\nIdentifier: **`" .. identifier .. "`"
               
                  TPZ.SendToDiscord(webhookData.Url, title, message, webhookData.Color)
              end

            end

          end

        end

      end

    end)

	end

end)

