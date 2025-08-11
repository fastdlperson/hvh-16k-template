# hvh-16k-template

This is a drag-and-drop **linux** hvh 16k csgo server

## Why?
The purpose of this repository is to provide an easy drag-and-drop linux 16k server. I want people to host their own servers with ease, with only their firewall and configuration files needing changes. There are many improvements that can be made, like replacing RankMe with Core or setting up RankMe scoring better, but at its base, it's perfect the way it is

## Instructions

1. **Run and follow** `MAIN.ps1`.

2. **Edit server settings**  
    - Open `cfg/server.cfg` to change the server name and other settings (such as advertisement timing).

3. **Configure the RankMe database**  
    - Open `addons/sourcemod/configs/databases.cfg` to change RankMe database credentials. This is required for RankMe to work.  
    - If you have enough storage or prefer easier database editing, use SQLite instead.  
    To do this, open `addons/sourcemod/configs/kento.rankme.cfg`, search for `rankme_mysql`, and change its value to `0`.

4. **Change RankMe name and color**  
    - Open `addons/sourcemod/translations/kento.rankme.phrases.txt` to change RankMe colors and name.

5. **Change admin list**  
    - Open `addons/sourcemod/configs/admins_simple.ini` and change the admin list to your liking.  
    Be sure to read [Adding Admins (SourceMod)](https://wiki.alliedmods.net/Adding_Admins_(SourceMod)).

6. **Edit advertisements**  
    - Open `addons/sourcemod/configs/advertisements.txt` to change advertisements.

7. **(Optional) Enable discord relay**  
    - Move `discord_api.smx` and `discordrelay.smx` from `addons/sourcemod/plugins/disabled` to `addons/sourcemod/plugins`.  
    Edit `cfg/sourcemod/discordrelay.cfg` to set up discord csgo chat and RCON relay.

8. **Profit?** 

## Isuses
Have a Isuse? Dm me on discord: `shibabyte`
I am in no way liable to help you, If i get multiple isuses at a time i will remove this section without notice.

## License
MIT

