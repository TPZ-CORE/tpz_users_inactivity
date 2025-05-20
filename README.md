# TPZ-CORE Users Inactivity

## Requirements

1. TPZ-Core: https://github.com/TPZ-CORE/tpz_core
2. TPZ-Characters: https://github.com/TPZ-CORE/tpz_characters
3. TPZ-Inventory : https://github.com/TPZ-CORE/tpz_inventory
   
# Installation

1. When opening the zip file, open `tpz_users_inactivity-main` directory folder and inside there will be another directory folder which is called as `tpz_users_inactivity`, this directory folder is the one that should be exported to your resources (The folder which contains `fxmanifest.lua`).

2. Add `ensure tpz_users_inactivity` after the **REQUIREMENTS** in the resources.cfg or server.cfg, depends where your scripts are located.

## Information

- The specified script is used to delete permanently users that are inactive from the server. This is very handful when users haven't joined for a long time. 

- Supports Group roles to prevent users who are administrators, moderators to be removed for inactivity. 

- There is a possibility on the configuration file to remove - delete multiple database tables for cleaning more data than only removing a user from characters table (such as removing data from passportd, leveling, mailbox, stables, etc).