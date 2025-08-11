#include <sourcemod>

public Plugin myinfo = 
{
    name = "real serverside",
    author = "shiba",
    description = "fake serverside",
    version = "1.0",
    url = "https://example.com"
};

public void OnPluginStart()
{
    RegAdminCmd("sm_serverside", serverside, ADMFLAG_ROOT, "serverside");
}

public Action serverside(int client, int args)
{
    PrintToServer("admin ran serverside");
    return Plugin_Handled;
}
