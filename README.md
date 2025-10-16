# THIS IS A LINUX SERVER

# hvh-16k-template

This is a drag-and-drop **LINUX** hvh 16k csgo server, I will be using Ubuntu 22.04 as Ubuntu is easier and you will not have to manually setup the panel <3

## Why?
The purpose of this repository is to provide an easy drag-and-drop linux 16k server. I want people to host their own servers with ease, with only their firewall and configuration files needing changes. There are many improvements that can be made, like replacing RankMe with Core or setting up RankMe scoring better, but at its base, it's perfect the way it is

## Recommendations
My recommended VPS providers are [Here!](./RECOMMENDATIONS.md)

## Instructions

1. **Setup the server** with **[pterodactyl-installer](https://github.com/pterodactyl-installer/pterodactyl-installer)** if you want a easy setup

3. **Download and extract** the `zip` file from [Releases](https://github.com/fastdlperson/hvh-16k-template/releases).

4. **Run the setup script**  
   - Right-click and run `MAIN.ps1`.  
   - When compiling plugins, press **Enter** for all three prompts.  
   - For most options, I recommend answering **Y**.

5. **Edit server settings**  
   - Open `cfg/server.cfg` to change the server name and other options (e.g., advertisement timing).

6. **Configure the RankMe database**  
   - Edit `addons/sourcemod/configs/databases.cfg` to update RankMe database credentials.  
   - **For easier setup, you can use SQLite**:  
     - Open `addons/sourcemod/configs/kento.rankme.cfg`  
     - Find `rankme_mysql` and set its value to `0`.

7. **Customize RankMe name and colors**  
   - Open `addons/sourcemod/translations/kento.rankme.phrases.txt`.

8. **Set up admin list**  
   - Edit `addons/sourcemod/configs/admins_simple.ini` to add admins.  
   - Reference: [Adding Admins (SourceMod)](https://wiki.alliedmods.net/Adding_Admins_(SourceMod)).

9. **Edit advertisements**  
   - Open `addons/sourcemod/configs/advertisements.txt`, [colors](https://raw.githubusercontent.com/KissLick/ColorVariables/master/csgo%20colors.png)

10. **(Optional) Enable Discord relay**  
   - Move `discord_api.smx` and `discordrelay.smx` from  
     `addons/sourcemod/plugins/disabled` → `addons/sourcemod/plugins`.  
   - Edit `cfg/sourcemod/discordrelay.cfg` to configure CS:GO to Discord chat and RCON relay.

11. **Deploy to server**  
   - Drag and drop the `csgo` folder into your FTP or server directory.  
   - Click **Yes** to overwrite.
     
12. **You'll need to replace the server's** `libgcc_s.so.1` with your system's.
    - So I would just do this `sudo dpkg --add-architecture i386 && sudo apt update && sudo apt install -y libcurl4:i386 libtinfo6:i386 libncurses6:i386 lib32stdc++6 lib32gcc-s1`
    - then `cd` to your pterodactyl server's bin, like this `cd /var/lib/pterodactyl/volumes/SERVER_ID_HERE/bin
`
    - then `mv libgcc_s.so.1 old.libgcc_s.so.1`

14. **Profit?**

## Issues
Have an issue? DM me on Discord: `shibabyte` or create an [issue](https://github.com/fastdlperson/hvh-16k-template/issues)

⚠️ I’m not obligated to provide support. If I receive too many requests, I may remove this section without notice.

## Credits
| Name          | Contribution                          |
|---------------|---------------------------------------|
| **[shiba](https://github.com/retree1)**     | Me, set everything up and made this |
| **[the1andrew](https://www.youtube.com/@JohnSmith-m3q5p)** | Paid for the hosting of nebula |
| **[adam](https://github.com/almostmeth)** | Giving me some useful plugins |

## License
[MIT](./LICENSE)
