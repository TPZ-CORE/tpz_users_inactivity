
local TPZ         = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end) -- To get the Core Functions.

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

-- At first, we set the inactivity time for users back to 0 since they logged in.
-- If the player has not been registered, we register the player and reset the inactivity time.
-- If the player does exist, and connected again, we replace the source.

RegisterServerEvent("tp_users_inactivity:registerLoggedInData")
AddEventHandler("tp_users_inactivity:registerLoggedInData", function()
  local _source         = source
  local xPlayer         = TPZ.GetPlayer(_source)
  local charidentifier  = xPlayer.getCharacterIdentifier()

  RegisterConnectedPlayer(charidentifier)

  local Parameters = { ['charidentifier'] = charidentifier, ['inactivity_time'] = 0 }
  exports.ghmattimysql:execute("UPDATE characters SET inactivity_time = @inactivity_time WHERE charidentifier = @charidentifier", Parameters)

end)



AddEventHandler('playerDropped', function (reason)
  local _source         = source
  local xPlayer         = TPZ.GetPlayer(_source)
  local charidentifier  = xPlayer.getCharacterIdentifier()

  if ConnectedPlayers[charidentifier] then
    ConnectedPlayers[charidentifier] = nil
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

        if not Config.BlacklistedUsers[identifier] and not Config.BlacklistedRoles[group] then

          if ConnectedPlayers[tonumber(charidentifier)] then
            playerExists = true
          end

          if not playerExists then

            local Parameters = { ['charidentifier'] = charidentifier, ['inactivity_time'] = Config.TimeUpdatingInDatabase }
            exports.ghmattimysql:execute("UPDATE characters SET inactivity_time = inactivity_time + @inactivity_time WHERE charidentifier = @charidentifier", Parameters)

            inactivity_time = inactivity_time + Config.TimeUpdatingInDatabase

            local deleteDataTime = Config.RemoveDatabaseDataAfter * 1440

            if tonumber(inactivity_time) >= tonumber(deleteDataTime) then

              local finishedChecking = false

              local UserParameters = { ['charidentifier'] = charidentifier }

              for _d, database in pairs(Config.RemoveFromDatabaseDataList) do
               
                exports.ghmattimysql:execute(database.table, UserParameters)

                if next(Config.RemoveFromDatabaseDataList, _d) == nil then
                  finishedChecking = true
                end
                
              end

              while not finishedChecking do
                Wait(250)
              end

              exports.ghmattimysql:execute("DELETE FROM characters WHERE charidentifier = @charidentifier ", UserParameters)

              print(" [!] The following player was inactive for too long, we deleted all data from: " .. charidentifier)

              local webhookData = Config.Webhooking

              if webhookData.Enable then
                  local title   = "🗑️` A Character has been permanently removed due to inactivity.`"
                  
                  local message = "**Steam name: **`" .. steamName .. "`**\nIdentifier: **`" .. identifier .. " (Char: " .. charidentifier .. ") `"
                  TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
              end

            end

          end

        end

      end

    end)

	end

end)

