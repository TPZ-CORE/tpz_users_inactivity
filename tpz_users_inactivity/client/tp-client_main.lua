
-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

-- Once a character user is selected, we trigger the server event
-- to reset the inactivity time. 
AddEventHandler("tpz_core:isPlayerReady", function()
    TriggerServerEvent('tpz_users_inactivity:registerLoggedInData')
end)
