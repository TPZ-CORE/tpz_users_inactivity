ConnectedPlayers = {}

-----------------------------------------------------------
--[[ General Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    ConnectedPlayers = {}

end)

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

-- When first joining the game, we request the player to be added into the list
-- The following list handles the players and their metabolism correctly.
function RegisterConnectedPlayer(charidentifier)

    if ConnectedPlayers[charidentifier] == nil then

        ConnectedPlayers[charidentifier] = true
    end
end
