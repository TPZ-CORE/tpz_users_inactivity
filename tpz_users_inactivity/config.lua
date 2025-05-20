Config = {}

Config.Debug = true

---------------------- INFORMATION ----------------------
-- The system reads the users directly from `characters` table,
---------------------------------------------------------

Config.Webhooking = { 
    Enable = true, 
    Url = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", -- The discord webhook url.
    Color = 10038562,
}

-- Updating every x minutes the players who are not online in `users` table.
-- When someone logs in (does not matter what selected character will be), the time sets back to `0`.
-- When someone is not logged in, the time updating will be added on the players `users` table.
Config.TimeUpdatingInDatabase  = 15 
Config.RemoveDatabaseDataAfter = 90 -- The time is in days, if a user has equal or higher than this number, all data will be deleted.

-- Blacklisted roles won't have any time updating.
Config.BlacklistedGroupRoles = { 
    'admin',
    'mod',
    'moderator',
    'staff',
}

-- Blacklisted users won't have any time updating / counting (in case someone is going to be off for personal reasons).
Config.BlacklistedUsers = {
    'steam:xxxxxxxxxxxxxxx',
}

-- The system removes an inactive character not all characters
-- If a user has 2 characters and for over 3 months the second character
-- havent been played, this is the character that is going to be deleted.
-- (!) ON DELETE, ALWAYS CHECK FOR CHARIDENTIFIER ONLY AS THE EXAMPLE BELOW!

Config.RemoveFromDatabaseDataList = {
    --{ table = "DELETE FROM characters WHERE charidentifier = @charidentifier" }, -- EXAMPLE ONLY! THIS DATABASE TABLE (characters) IS EXECUTED FROM SYSTEM ITSELF. 
}
