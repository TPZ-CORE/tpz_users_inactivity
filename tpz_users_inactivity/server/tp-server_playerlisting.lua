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

function RegisterConnectedPlayer(charidentifier)
    if ConnectedPlayers[charidentifier] == nil then
        ConnectedPlayers[charidentifier] = true
    end
end
