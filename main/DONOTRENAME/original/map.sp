#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <mapchooser>
#include <cstrike>
#include <csgocolors>

#define PLUGIN_VERSION "1.0"

bool g_bVoteStarted;
ConVar g_cvEndVote;
ConVar g_cvMaxRounds;

public Plugin myinfo = 
{
    name = "mapvote",
    author = "shiba",
    description = "fix mapvote",
    version = PLUGIN_VERSION
};

public void OnPluginStart()
{
    char game[32];
    GetGameFolderName(game, sizeof(game));
    if (!StrEqual(game, "csgo"))
        SetFailState("This plugin supports CS:GO only.");
    
    HookEvent("round_end", Event_RoundEnd);
    HookEvent("cs_win_panel_match", Event_MatchEnd, EventHookMode_PostNoCopy);
    
    g_cvMaxRounds = FindConVar("mp_maxrounds");
    if (g_cvMaxRounds == null)
        SetFailState("Could not find mp_maxrounds convar");
    
    g_cvEndVote = FindConVar("sm_mapvote_endvote");
    if (g_cvEndVote == null)
        g_cvEndVote = CreateConVar("sm_halftime_endvote", "0", "Disable standard endvote when halftime vote is active", _, true, 0.0, true, 1.0);
    
    AutoExecConfig(true, "halftimevote");
}

public void OnMapStart()
{
    g_bVoteStarted = false;
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    if (g_bVoteStarted || !LibraryExists("mapchooser"))
        return;
    
    // Get max rounds from convar
    int maxRounds = g_cvMaxRounds.IntValue;
    if (maxRounds <= 0) return;
    
    // Get current round scores
    int roundsCT = CS_GetTeamScore(CS_TEAM_CT);
    int roundsT = CS_GetTeamScore(CS_TEAM_T);
    int roundsPlayed = roundsCT + roundsT;
    
    // Check if we're at halftime
    if (roundsPlayed == maxRounds / 2)
    {
        StartHalftimeVote();
    }
}

void StartHalftimeVote()
{
    // Disable standard endvote if configured
    if (g_cvEndVote.BoolValue)
    {
        ConVar stdEndVote = FindConVar("sm_mapvote_endvote");
        if (stdEndVote != null) stdEndVote.SetInt(0);
    }
    
    // Configure runoff votes
    ConVar runoff = FindConVar("sm_mapvote_runoff");
    ConVar runoffPct = FindConVar("sm_mapvote_runoffpercent");
    if (runoff != null && runoffPct != null)
    {
        runoff.SetInt(1); // Enable runoff
        runoffPct.SetInt(40); // 40% threshold for runoff
    }
    
    // Start vote with MapChange_MapEnd to change after match
    InitiateMapChooserVote(MapChange_MapEnd);
    g_bVoteStarted = true;
    
    CPrintToChatAll("\x03[nebula]\x01 Map vote started! Vote for next map!");
}

public void Event_MatchEnd(Event event, const char[] name, bool dontBroadcast)
{
    if (g_bVoteStarted)
    {
        char nextMap[128];
        GetNextMap(nextMap, sizeof(nextMap));
        CPrintToChatAll("\x03[nebula]\x01 Next map: %s", nextMap);
    }
}

// Prevent duplicate votes if halftime is re-triggered
public Action Command_Mapvote(int client, int args)
{
    if (g_bVoteStarted)
    {
        ReplyToCommand(client, "[SM] Map vote already started during halftime.");
        return Plugin_Handled;
    }
    return Plugin_Continue;
}