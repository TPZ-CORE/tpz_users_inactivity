Config = {}

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
Config.RemoveDatabaseDataAfter = 60 -- The time is in days, if a user has equal or higher than this number, all data will be deleted.

-- Blacklisted roles won't have any time updating.
Config.BlacklistedRoles = { 
    ['admin']     = true, 
    ['moderator'] = true, 
    ['staff']     = true,
}

-- Blacklisted users won't have any time updating / counting (in case someone is going to be off for personal reasons).
Config.BlacklistedUsers = {
    ['steam:1100001339c9bd5'] = true,
}

Config.RemoveFromDatabaseDataList = {
    { table = "DELETE FROM characters WHERE charidentifier = @charidentifier" },
    --{ table = "DELETE FROM tp_mailbox_mails_registrations WHERE charidentifier = @charidentifier" }, -- TP Mailbox
    --{ table = "DELETE FROM tp_mailbox_mails WHERE receiver_charidentifier = @charidentifier" }, -- TP Mailbox
}
