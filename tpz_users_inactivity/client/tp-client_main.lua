
-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

AddEventHandler("tpz_core:isPlayerReady", function()
    TriggerServerEvent('tpz_users_inactivity:registerLoggedInData')
end)
