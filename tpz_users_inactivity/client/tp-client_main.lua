
-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

AddEventHandler("tpz_core:isPlayerReady", function()
    TriggerServerEvent('tp_users_inactivity:registerLoggedInData')
end)